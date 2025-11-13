// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./GameRegistry.sol";
import "./GameSchemaRegistry.sol";

/**
 * @title OracleCoreV2
 * @notice Enhanced oracle with schema support for rich game data
 * @dev Supports both simple results (backward compatible) and schema-based custom data
 */
contract OracleCoreV2 is Ownable, ReentrancyGuard {
    GameRegistry public gameRegistry;
    GameSchemaRegistry public schemaRegistry;

    // Fast dispute window: 15 minutes (vs UMA's 24-48 hours)
    uint256 public constant DISPUTE_WINDOW = 15 minutes;

    // Dispute stake must be 2x registration stake
    uint256 public constant DISPUTE_STAKE = 0.2 ether;

    // Enhanced game result with schema support
    struct GameResult {
        bytes32 matchId;
        address gameContract;
        uint256 timestamp;
        uint256 duration;
        GameStatus status;

        // Participants (flexible arrays)
        address[] participants;
        uint256[] scores;           // Parallel array to participants
        uint8 winnerIndex;          // 255 = draw/no winner

        // Schema-based custom data
        bytes32 schemaId;           // References registered schema (0 if no custom data)
        bytes customData;           // ABI-encoded according to schema

        // Oracle metadata
        bytes32 resultHash;
        address submitter;
        uint256 submittedAt;
        uint256 disputeDeadline;
        bool isFinalized;
        bool isDisputed;
        address disputer;
        uint256 disputeStake;
        string disputeReason;
    }

    enum GameStatus {
        COMPLETED,
        CANCELLED,
        DISPUTED,
        ONGOING
    }

    // Validation check results
    struct ValidationChecks {
        bool timingValid;
        bool authorizedSubmitter;
        bool dataIntegrity;
        bool schemaValid;           // New: Schema validation
        bool participantsValid;
    }

    // Storage
    mapping(bytes32 => GameResult) public results;
    mapping(bytes32 => ValidationChecks) public validations;
    mapping(address => uint256) public disputerRewards;

    bytes32[] public allResults;

    // Events
    event ResultSubmittedV2(
        bytes32 indexed matchId,
        address indexed gameContract,
        address indexed submitter,
        bytes32 resultHash,
        bytes32 schemaId,
        uint256 disputeDeadline
    );

    event SchemaDataValidated(
        bytes32 indexed matchId,
        bytes32 indexed schemaId,
        bool isValid
    );

    event ResultDisputed(
        bytes32 indexed matchId,
        address indexed disputer,
        uint256 stakeAmount,
        string reason
    );

    event DisputeResolved(
        bytes32 indexed matchId,
        bool disputeSuccessful,
        address indexed winner,
        uint256 reward
    );

    event ResultFinalized(
        bytes32 indexed matchId,
        bytes32 resultHash,
        uint256 finalizedAt
    );

    constructor(
        address _gameRegistryAddress,
        address _schemaRegistryAddress
    ) Ownable(msg.sender) {
        require(_gameRegistryAddress != address(0), "OracleCoreV2: Invalid registry");
        require(_schemaRegistryAddress != address(0), "OracleCoreV2: Invalid schema registry");

        gameRegistry = GameRegistry(_gameRegistryAddress);
        schemaRegistry = GameSchemaRegistry(_schemaRegistryAddress);
    }

    /**
     * @notice Submit game result with optional schema-based custom data
     * @param _matchId The match this result is for
     * @param _gameContract Address of the game contract
     * @param _participants Array of participant addresses
     * @param _scores Array of scores (parallel to participants)
     * @param _winnerIndex Index of winner in participants array (255 for draw)
     * @param _duration Game duration in seconds
     * @param _schemaId Schema ID for custom data (0 for no custom data)
     * @param _customData ABI-encoded custom data according to schema
     */
    function submitResultV2(
        bytes32 _matchId,
        address _gameContract,
        address[] calldata _participants,
        uint256[] calldata _scores,
        uint8 _winnerIndex,
        uint256 _duration,
        bytes32 _schemaId,
        bytes calldata _customData
    ) external nonReentrant {
        // Get match details from registry
        GameRegistry.Match memory matchData = gameRegistry.getMatch(_matchId);
        require(matchData.scheduledTime > 0, "OracleCoreV2: Match does not exist");
        require(
            matchData.status == GameRegistry.MatchStatus.Scheduled ||
            matchData.status == GameRegistry.MatchStatus.InProgress,
            "OracleCoreV2: Match not in valid state"
        );

        // Get game details
        GameRegistry.Game memory game = gameRegistry.getGame(matchData.gameId);
        require(game.developer == msg.sender, "OracleCoreV2: Only game developer can submit");
        require(game.isActive, "OracleCoreV2: Game not active");

        // Ensure result not already submitted
        require(results[_matchId].submittedAt == 0, "OracleCoreV2: Result already submitted");

        // Validate participants and scores
        require(_participants.length > 0, "OracleCoreV2: No participants");
        require(
            _participants.length == _scores.length,
            "OracleCoreV2: Participants/scores length mismatch"
        );
        require(
            _winnerIndex < _participants.length || _winnerIndex == 255,
            "OracleCoreV2: Invalid winner index"
        );

        // Validate schema if provided
        bool schemaValid = true;
        if (_schemaId != bytes32(0)) {
            schemaValid = _validateSchema(_schemaId, _customData, _gameContract);
        }

        // Compute result hash
        bytes32 resultHash = keccak256(
            abi.encodePacked(
                _matchId,
                _gameContract,
                _participants,
                _scores,
                _winnerIndex,
                _schemaId,
                _customData,
                block.timestamp
            )
        );

        // Perform validation checks
        ValidationChecks memory checks = ValidationChecks({
            timingValid: block.timestamp >= matchData.scheduledTime,
            authorizedSubmitter: game.developer == msg.sender,
            dataIntegrity: true,
            schemaValid: schemaValid,
            participantsValid: _participants.length > 0
        });

        validations[_matchId] = checks;

        // If critical checks fail, reject
        if (!checks.authorizedSubmitter || !checks.schemaValid || !checks.participantsValid) {
            revert("OracleCoreV2: Validation failed");
        }

        // Store result
        uint256 disputeDeadline = block.timestamp + DISPUTE_WINDOW;

        GameResult storage result = results[_matchId];
        result.matchId = _matchId;
        result.gameContract = _gameContract;
        result.timestamp = block.timestamp;
        result.duration = _duration;
        result.status = GameStatus.COMPLETED;
        result.participants = _participants;
        result.scores = _scores;
        result.winnerIndex = _winnerIndex;
        result.schemaId = _schemaId;
        result.customData = _customData;
        result.resultHash = resultHash;
        result.submitter = msg.sender;
        result.submittedAt = block.timestamp;
        result.disputeDeadline = disputeDeadline;
        result.isFinalized = false;
        result.isDisputed = false;

        allResults.push(_matchId);

        // Update match status in registry
        gameRegistry.updateMatchStatus(_matchId, GameRegistry.MatchStatus.Completed);

        emit ResultSubmittedV2(
            _matchId,
            _gameContract,
            msg.sender,
            resultHash,
            _schemaId,
            disputeDeadline
        );

        if (_schemaId != bytes32(0)) {
            emit SchemaDataValidated(_matchId, _schemaId, schemaValid);
        }
    }

    /**
     * @notice Simplified submission for games without custom data (backward compatible)
     * @param _matchId The match this result is for
     * @param _resultData Legacy JSON string (for backward compatibility)
     */
    function submitResult(
        bytes32 _matchId,
        string calldata _resultData
    ) external nonReentrant {
        // This is a simplified wrapper that creates a basic GameResult
        // with no participants/scores tracking, for backward compatibility

        GameRegistry.Match memory matchData = gameRegistry.getMatch(_matchId);
        require(matchData.scheduledTime > 0, "OracleCoreV2: Match does not exist");

        GameRegistry.Game memory game = gameRegistry.getGame(matchData.gameId);
        require(game.developer == msg.sender, "OracleCoreV2: Only game developer can submit");

        require(results[_matchId].submittedAt == 0, "OracleCoreV2: Result already submitted");

        bytes32 resultHash = keccak256(abi.encodePacked(_resultData, _matchId, block.timestamp));
        uint256 disputeDeadline = block.timestamp + DISPUTE_WINDOW;

        GameResult storage result = results[_matchId];
        result.matchId = _matchId;
        result.gameContract = address(0);
        result.timestamp = block.timestamp;
        result.duration = 0;
        result.status = GameStatus.COMPLETED;
        result.winnerIndex = 255; // No winner tracking in legacy mode
        result.schemaId = bytes32(0);
        result.customData = bytes(_resultData); // Store legacy data in customData
        result.resultHash = resultHash;
        result.submitter = msg.sender;
        result.submittedAt = block.timestamp;
        result.disputeDeadline = disputeDeadline;
        result.isFinalized = false;
        result.isDisputed = false;

        allResults.push(_matchId);

        gameRegistry.updateMatchStatus(_matchId, GameRegistry.MatchStatus.Completed);

        emit ResultSubmittedV2(
            _matchId,
            address(0),
            msg.sender,
            resultHash,
            bytes32(0),
            disputeDeadline
        );
    }

    /**
     * @notice Dispute a submitted result
     * @param _matchId The match result to dispute
     * @param _reason Explanation for the dispute
     */
    function disputeResult(
        bytes32 _matchId,
        string calldata _reason
    ) external payable nonReentrant {
        GameResult storage result = results[_matchId];
        require(result.submittedAt > 0, "OracleCoreV2: Result does not exist");
        require(!result.isFinalized, "OracleCoreV2: Result already finalized");
        require(!result.isDisputed, "OracleCoreV2: Already disputed");
        require(block.timestamp < result.disputeDeadline, "OracleCoreV2: Dispute window closed");
        require(msg.value == DISPUTE_STAKE, "OracleCoreV2: Incorrect dispute stake");
        require(bytes(_reason).length > 0, "OracleCoreV2: Must provide reason");

        result.isDisputed = true;
        result.disputer = msg.sender;
        result.disputeStake = msg.value;
        result.disputeReason = _reason;
        result.status = GameStatus.DISPUTED;

        gameRegistry.updateMatchStatus(_matchId, GameRegistry.MatchStatus.Disputed);

        emit ResultDisputed(_matchId, msg.sender, msg.value, _reason);
    }

    /**
     * @notice Resolve a dispute (called by owner/governance)
     * @param _matchId The disputed match
     * @param _disputeValid Whether the dispute is valid
     */
    function resolveDispute(
        bytes32 _matchId,
        bool _disputeValid
    ) external onlyOwner nonReentrant {
        GameResult storage result = results[_matchId];
        require(result.isDisputed, "OracleCoreV2: Not disputed");
        require(!result.isFinalized, "OracleCoreV2: Already finalized");

        GameRegistry.Match memory matchData = gameRegistry.getMatch(_matchId);
        GameRegistry.Game memory game = gameRegistry.getGame(matchData.gameId);

        if (_disputeValid) {
            // Disputer wins
            uint256 reward = result.disputeStake + (gameRegistry.REGISTRATION_STAKE() / 2);
            disputerRewards[result.disputer] += reward;

            gameRegistry.slashStake(
                matchData.gameId,
                gameRegistry.REGISTRATION_STAKE() / 2,
                result.disputeReason
            );

            uint256 newReputation = game.reputationScore > 50 ? game.reputationScore - 50 : 0;
            gameRegistry.updateReputation(matchData.gameId, newReputation);

            emit DisputeResolved(_matchId, true, result.disputer, reward);
        } else {
            // Submitter wins
            disputerRewards[result.submitter] += result.disputeStake;

            uint256 newReputation = game.reputationScore < 990
                ? game.reputationScore + 10
                : 1000;
            gameRegistry.updateReputation(matchData.gameId, newReputation);

            result.isFinalized = true;
            result.status = GameStatus.COMPLETED;
            gameRegistry.updateMatchStatus(_matchId, GameRegistry.MatchStatus.Finalized);

            emit DisputeResolved(_matchId, false, result.submitter, result.disputeStake);
            emit ResultFinalized(_matchId, result.resultHash, block.timestamp);
        }
    }

    /**
     * @notice Finalize a result after dispute window
     * @param _matchId The match to finalize
     */
    function finalizeResult(bytes32 _matchId) external nonReentrant {
        GameResult storage result = results[_matchId];
        require(result.submittedAt > 0, "OracleCoreV2: Result does not exist");
        require(!result.isFinalized, "OracleCoreV2: Already finalized");
        require(!result.isDisputed, "OracleCoreV2: Cannot finalize disputed result");
        require(
            block.timestamp >= result.disputeDeadline,
            "OracleCoreV2: Dispute window not closed"
        );

        result.isFinalized = true;
        result.status = GameStatus.COMPLETED;

        gameRegistry.updateMatchStatus(_matchId, GameRegistry.MatchStatus.Finalized);

        GameRegistry.Match memory matchData = gameRegistry.getMatch(_matchId);
        GameRegistry.Game memory game = gameRegistry.getGame(matchData.gameId);

        uint256 newReputation = game.reputationScore < 995
            ? game.reputationScore + 5
            : 1000;
        gameRegistry.updateReputation(matchData.gameId, newReputation);

        emit ResultFinalized(_matchId, result.resultHash, block.timestamp);
    }

    /**
     * @notice Withdraw accumulated rewards
     */
    function withdrawRewards() external nonReentrant {
        uint256 amount = disputerRewards[msg.sender];
        require(amount > 0, "OracleCoreV2: No rewards to withdraw");

        disputerRewards[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // Internal functions

    /**
     * @notice Validate schema and custom data
     */
    function _validateSchema(
        bytes32 _schemaId,
        bytes calldata _customData,
        address _gameContract
    ) internal view returns (bool) {
        // Check schema exists and is active
        if (!schemaRegistry.isSchemaActive(_schemaId)) {
            return false;
        }

        // If game has a registered schema, verify it matches
        if (schemaRegistry.hasSchema(_gameContract)) {
            bytes32 gameSchemaId = schemaRegistry.getGameSchemaId(_gameContract);
            if (_schemaId != gameSchemaId) {
                return false;
            }
        }

        // Validate encoded data structure
        return schemaRegistry.validateEncodedData(_schemaId, _customData);
    }

    // View functions

    /**
     * @notice Get full result with schema data
     * @param _matchId The match to query
     */
    function getResultV2(bytes32 _matchId)
        external
        view
        returns (GameResult memory)
    {
        require(results[_matchId].submittedAt > 0, "OracleCoreV2: Result does not exist");
        return results[_matchId];
    }

    /**
     * @notice Get result for backward compatibility (returns simplified data)
     * @param _matchId The match to query
     */
    function getResult(bytes32 _matchId)
        external
        view
        returns (
            string memory resultData,
            bytes32 resultHash,
            bool isFinalized
        )
    {
        GameResult memory result = results[_matchId];
        require(result.submittedAt > 0, "OracleCoreV2: Result does not exist");

        // For backward compatibility, return customData as string if no schema
        if (result.schemaId == bytes32(0)) {
            resultData = string(result.customData);
        } else {
            resultData = ""; // Use getResultV2 for schema-based results
        }

        return (resultData, result.resultHash, result.isFinalized);
    }

    /**
     * @notice Check if result is finalized
     */
    function isResultFinalized(bytes32 _matchId) external view returns (bool) {
        return results[_matchId].isFinalized;
    }

    /**
     * @notice Get validation checks
     */
    function getValidationChecks(bytes32 _matchId)
        external
        view
        returns (ValidationChecks memory)
    {
        return validations[_matchId];
    }

    /**
     * @notice Get custom data for a result
     */
    function getCustomData(bytes32 _matchId)
        external
        view
        returns (bytes32 schemaId, bytes memory customData)
    {
        GameResult memory result = results[_matchId];
        return (result.schemaId, result.customData);
    }

    /**
     * @notice Get participants and scores
     */
    function getParticipantsAndScores(bytes32 _matchId)
        external
        view
        returns (
            address[] memory participants,
            uint256[] memory scores,
            uint8 winnerIndex
        )
    {
        GameResult memory result = results[_matchId];
        return (result.participants, result.scores, result.winnerIndex);
    }

    /**
     * @notice Get total results count
     */
    function getTotalResults() external view returns (uint256) {
        return allResults.length;
    }

    receive() external payable {}
}
