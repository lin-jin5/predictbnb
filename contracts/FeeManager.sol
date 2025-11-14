// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./GameRegistry.sol";
import "./OracleCore.sol";

/**
 * @title FeeManager
 * @notice Manages fees for data access and distributes revenue to game developers based on usage
 * @dev Implements prepaid balance model: deposit funds, queries deduct from balance, developers earn per query
 */
contract FeeManager is Ownable, ReentrancyGuard {
    GameRegistry public gameRegistry;
    OracleCore public oracleCore;

    // Fee structure (V2 - Prepaid Balance Model)
    uint256 public constant BASE_QUERY_FEE = 0.003 ether;     // $1.80 per query
    uint256 public constant FREE_DAILY_QUERIES = 50;          // Free queries per day for new users

    // Volume discount bonuses (in basis points, 10000 = 100%)
    uint256 public constant BONUS_TIER_1 = 500;   // 5% bonus on 10+ BNB deposits
    uint256 public constant BONUS_TIER_2 = 1000;  // 10% bonus on 50+ BNB deposits
    uint256 public constant BONUS_TIER_3 = 1500;  // 15% bonus on 100+ BNB deposits

    uint256 public constant DEPOSIT_TIER_1 = 10 ether;
    uint256 public constant DEPOSIT_TIER_2 = 50 ether;
    uint256 public constant DEPOSIT_TIER_3 = 100 ether;

    // Revenue split percentages (in basis points, 10000 = 100%)
    uint256 public constant DEVELOPER_SHARE = 8000;     // 80% to game developer
    uint256 public constant PROTOCOL_SHARE = 1500;      // 15% to protocol treasury
    uint256 public constant DISPUTER_POOL_SHARE = 500;  // 5% to disputer rewards pool

    // Consumer (prediction market) struct
    struct Consumer {
        address consumerAddress;
        uint256 balance;            // Prepaid balance for queries
        uint256 totalDeposited;     // Total amount ever deposited
        uint256 totalQueriesMade;
        uint256 totalFeesPaid;      // Total fees paid from balance
        uint256 lastQueryReset;     // For daily free tier reset
        uint256 dailyQueriesUsed;
        bool isActive;
    }

    // Revenue tracking for game developers
    struct DeveloperRevenue {
        uint256 totalEarned;
        uint256 pendingWithdrawal;
        uint256 totalWithdrawn;
        uint256 queryCount;         // Total queries to their games
    }

    // Storage
    mapping(address => Consumer) public consumers;
    mapping(address => DeveloperRevenue) public developerRevenues;
    mapping(string => uint256) public gameQueryCounts;      // gameId => query count
    mapping(bytes32 => uint256) public matchQueryCounts;    // matchId => query count

    address[] public allConsumers;
    uint256 public protocolTreasury;
    uint256 public disputerPool;

    // Events
    event ConsumerRegistered(address indexed consumer);

    event BalanceDeposited(
        address indexed consumer,
        uint256 amount,
        uint256 bonusAmount,
        uint256 newBalance
    );

    event BalanceWithdrawn(
        address indexed consumer,
        uint256 amount,
        uint256 newBalance
    );

    event QueryFeePaid(
        address indexed consumer,
        bytes32 indexed matchId,
        string gameId,
        uint256 fee,
        uint256 remainingBalance
    );

    event RevenueDistributed(
        string indexed gameId,
        address indexed developer,
        uint256 amount,
        uint256 queryCount
    );

    event DeveloperWithdrawal(
        address indexed developer,
        uint256 amount
    );

    constructor(
        address _gameRegistryAddress,
        address _oracleCore
    ) Ownable(msg.sender) {
        require(_gameRegistryAddress != address(0), "FeeManager: Invalid registry address");
        require(_oracleCore != address(0), "FeeManager: Invalid oracle address");
        gameRegistry = GameRegistry(_gameRegistryAddress);
        oracleCore = OracleCore(_oracleCore);
    }

    /**
     * @notice Register as a data consumer (prediction market)
     */
    function registerConsumer() external {
        require(
            consumers[msg.sender].consumerAddress == address(0),
            "FeeManager: Already registered"
        );

        consumers[msg.sender] = Consumer({
            consumerAddress: msg.sender,
            balance: 0,
            totalDeposited: 0,
            totalQueriesMade: 0,
            totalFeesPaid: 0,
            lastQueryReset: block.timestamp,
            dailyQueriesUsed: 0,
            isActive: true
        });

        allConsumers.push(msg.sender);

        emit ConsumerRegistered(msg.sender);
    }

    /**
     * @notice Deposit funds to prepaid balance with volume bonus
     * @dev Larger deposits receive bonus credits
     *      10+ BNB = 5% bonus, 50+ BNB = 10% bonus, 100+ BNB = 15% bonus
     */
    function depositBalance() external payable nonReentrant {
        Consumer storage consumer = consumers[msg.sender];
        require(consumer.consumerAddress != address(0), "FeeManager: Not registered");
        require(msg.value > 0, "FeeManager: Must deposit non-zero amount");

        uint256 depositAmount = msg.value;
        uint256 bonusAmount = 0;

        // Calculate volume bonus
        if (depositAmount >= DEPOSIT_TIER_3) {
            bonusAmount = (depositAmount * BONUS_TIER_3) / 10000;
        } else if (depositAmount >= DEPOSIT_TIER_2) {
            bonusAmount = (depositAmount * BONUS_TIER_2) / 10000;
        } else if (depositAmount >= DEPOSIT_TIER_1) {
            bonusAmount = (depositAmount * BONUS_TIER_1) / 10000;
        }

        uint256 totalCredit = depositAmount + bonusAmount;
        consumer.balance += totalCredit;
        consumer.totalDeposited += depositAmount;

        emit BalanceDeposited(msg.sender, depositAmount, bonusAmount, consumer.balance);
    }

    /**
     * @notice Withdraw unused balance
     * @param _amount Amount to withdraw
     */
    function withdrawBalance(uint256 _amount) external nonReentrant {
        Consumer storage consumer = consumers[msg.sender];
        require(consumer.consumerAddress != address(0), "FeeManager: Not registered");
        require(_amount > 0, "FeeManager: Must withdraw non-zero amount");
        require(consumer.balance >= _amount, "FeeManager: Insufficient balance");

        consumer.balance -= _amount;
        payable(msg.sender).transfer(_amount);

        emit BalanceWithdrawn(msg.sender, _amount, consumer.balance);
    }


    /**
     * @notice Query game result - deducts from prepaid balance or uses free tier
     * @param _matchId The match to query
     * @return resultData The game result
     * @return resultHash Hash for verification
     * @return isFinalized Whether result is finalized
     */
    function queryResult(bytes32 _matchId)
        external
        nonReentrant
        returns (
            string memory resultData,
            bytes32 resultHash,
            bool isFinalized
        )
    {
        Consumer storage consumer = consumers[msg.sender];
        require(consumer.isActive, "FeeManager: Consumer not registered or inactive");

        // Get result from oracle
        (resultData, resultHash, isFinalized) = oracleCore.getResult(_matchId);
        require(isFinalized, "FeeManager: Result not finalized yet");

        // Get match and game info for revenue distribution
        GameRegistry.Match memory matchData = gameRegistry.getMatch(_matchId);
        GameRegistry.Game memory game = gameRegistry.getGame(matchData.gameId);

        // Update daily queries for free tier tracking
        _updateDailyQueries(consumer);

        uint256 fee = 0;

        // Check if within free daily limit
        if (consumer.dailyQueriesUsed < FREE_DAILY_QUERIES) {
            // Free query
            consumer.dailyQueriesUsed++;
        } else {
            // Paid query - deduct from balance
            fee = BASE_QUERY_FEE;
            require(consumer.balance >= fee, "FeeManager: Insufficient balance. Please deposit funds.");

            consumer.balance -= fee;
            consumer.totalFeesPaid += fee;

            // Distribute revenue to game developer (80%), protocol (15%), disputer pool (5%)
            _distributeRevenue(matchData.gameId, game.developer, fee);
        }

        // Update query counts
        consumer.totalQueriesMade++;
        matchQueryCounts[_matchId]++;
        gameQueryCounts[matchData.gameId]++;

        emit QueryFeePaid(msg.sender, _matchId, matchData.gameId, fee, consumer.balance);

        return (resultData, resultHash, isFinalized);
    }

    /**
     * @notice Batch query multiple results - deducts from prepaid balance
     * @param _matchIds Array of match IDs to query
     */
    function batchQueryResults(bytes32[] calldata _matchIds)
        external
        nonReentrant
        returns (string[] memory, bytes32[] memory, bool[] memory)
    {
        Consumer storage consumer = consumers[msg.sender];
        require(consumer.isActive, "FeeManager: Consumer not registered or inactive");
        require(_matchIds.length > 0, "FeeManager: Empty array");
        require(_matchIds.length <= 50, "FeeManager: Too many queries");

        string[] memory resultDataArray = new string[](_matchIds.length);
        bytes32[] memory resultHashArray = new bytes32[](_matchIds.length);
        bool[] memory isFinalizedArray = new bool[](_matchIds.length);

        // Update daily queries counter once
        _updateDailyQueries(consumer);

        uint256 totalFee = 0;

        // Process each query
        for (uint256 i = 0; i < _matchIds.length; i++) {
            // Get result from oracle
            (
                resultDataArray[i],
                resultHashArray[i],
                isFinalizedArray[i]
            ) = oracleCore.getResult(_matchIds[i]);

            // Get match and game info
            GameRegistry.Match memory matchData = gameRegistry.getMatch(_matchIds[i]);
            GameRegistry.Game memory game = gameRegistry.getGame(matchData.gameId);

            uint256 fee = 0;

            // Check if within free daily limit
            if (consumer.dailyQueriesUsed < FREE_DAILY_QUERIES) {
                consumer.dailyQueriesUsed++;
            } else {
                fee = BASE_QUERY_FEE;
                totalFee += fee;

                // Distribute revenue to game developer
                _distributeRevenue(matchData.gameId, game.developer, fee);
            }

            // Update counts
            consumer.totalQueriesMade++;
            matchQueryCounts[_matchIds[i]]++;
            gameQueryCounts[matchData.gameId]++;
        }

        // Deduct total fee from balance
        if (totalFee > 0) {
            require(consumer.balance >= totalFee, "FeeManager: Insufficient balance for batch query");
            consumer.balance -= totalFee;
            consumer.totalFeesPaid += totalFee;
        }

        return (resultDataArray, resultHashArray, isFinalizedArray);
    }

    /**
     * @notice Withdraw earned revenue (for game developers)
     */
    function withdrawRevenue() external nonReentrant {
        DeveloperRevenue storage revenue = developerRevenues[msg.sender];
        require(revenue.pendingWithdrawal > 0, "FeeManager: No revenue to withdraw");

        uint256 amount = revenue.pendingWithdrawal;
        revenue.pendingWithdrawal = 0;
        revenue.totalWithdrawn += amount;

        payable(msg.sender).transfer(amount);

        emit DeveloperWithdrawal(msg.sender, amount);
    }

    /**
     * @notice Withdraw protocol treasury (owner only)
     */
    function withdrawProtocolTreasury(uint256 _amount) external onlyOwner nonReentrant {
        require(_amount <= protocolTreasury, "FeeManager: Insufficient treasury");
        protocolTreasury -= _amount;
        payable(owner()).transfer(_amount);
    }

    /**
     * @notice Transfer funds to disputer pool in OracleCore
     */
    function fundDisputerPool(uint256 _amount) external onlyOwner nonReentrant {
        require(_amount <= disputerPool, "FeeManager: Insufficient disputer pool");
        disputerPool -= _amount;
        payable(address(oracleCore)).transfer(_amount);
    }

    // Internal functions

    /**
     * @notice Update daily query counter (reset after 24 hours)
     */
    function _updateDailyQueries(Consumer storage _consumer) internal {
        if (block.timestamp >= _consumer.lastQueryReset + 1 days) {
            _consumer.dailyQueriesUsed = 0;
            _consumer.lastQueryReset = block.timestamp;
        }
    }

    /**
     * @notice Distribute query revenue to stakeholders
     */
    function _distributeRevenue(
        string memory _gameId,
        address _developer,
        uint256 _totalFee
    ) internal {
        // Calculate splits
        uint256 developerAmount = (_totalFee * DEVELOPER_SHARE) / 10000;
        uint256 protocolAmount = (_totalFee * PROTOCOL_SHARE) / 10000;
        uint256 disputerAmount = (_totalFee * DISPUTER_POOL_SHARE) / 10000;

        // Update developer revenue
        DeveloperRevenue storage devRevenue = developerRevenues[_developer];
        devRevenue.totalEarned += developerAmount;
        devRevenue.pendingWithdrawal += developerAmount;
        devRevenue.queryCount++;

        // Add to protocol pools
        protocolTreasury += protocolAmount;
        disputerPool += disputerAmount;

        emit RevenueDistributed(_gameId, _developer, developerAmount, devRevenue.queryCount);
    }


    // View functions

    function getConsumer(address _consumer) external view returns (Consumer memory) {
        return consumers[_consumer];
    }

    function getDeveloperRevenue(address _developer)
        external
        view
        returns (DeveloperRevenue memory)
    {
        return developerRevenues[_developer];
    }

    function getGameQueryCount(string calldata _gameId) external view returns (uint256) {
        return gameQueryCounts[_gameId];
    }

    function getConsumerBalance(address _consumer) external view returns (uint256) {
        return consumers[_consumer].balance;
    }

    function getRemainingFreeQueries(address _consumer) external view returns (uint256) {
        Consumer memory consumer = consumers[_consumer];

        // Check if need to reset
        if (block.timestamp >= consumer.lastQueryReset + 1 days) {
            return FREE_DAILY_QUERIES;
        }

        if (consumer.dailyQueriesUsed >= FREE_DAILY_QUERIES) {
            return 0;
        }

        return FREE_DAILY_QUERIES - consumer.dailyQueriesUsed;
    }

    function calculateDepositBonus(uint256 _depositAmount) external pure returns (uint256) {
        if (_depositAmount >= DEPOSIT_TIER_3) {
            return (_depositAmount * BONUS_TIER_3) / 10000;
        } else if (_depositAmount >= DEPOSIT_TIER_2) {
            return (_depositAmount * BONUS_TIER_2) / 10000;
        } else if (_depositAmount >= DEPOSIT_TIER_1) {
            return (_depositAmount * BONUS_TIER_1) / 10000;
        }
        return 0;
    }

    function getTotalConsumers() external view returns (uint256) {
        return allConsumers.length;
    }

    receive() external payable {
        protocolTreasury += msg.value;
    }
}
