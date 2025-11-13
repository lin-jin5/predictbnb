// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../OracleCoreV2.sol";
import "../GameSchemaRegistry.sol";
import "../SchemaTemplates.sol";

/**
 * @title OnchainChessGame
 * @notice Example fully onchain chess game that uses the Turn-Based schema
 * @dev Demonstrates passive income for game developers via oracle integration
 */
contract OnchainChessGame {
    OracleCoreV2 public oracle;
    GameSchemaRegistry public schemaRegistry;
    SchemaTemplates public templates;

    enum GameState {
        WaitingForPlayers,
        InProgress,
        Completed
    }

    struct ChessGame {
        bytes32 gameId;
        address player1;        // White
        address player2;        // Black
        uint256 startTime;
        uint256 endTime;
        uint256 turnCount;
        uint256 moveCount;
        address winner;
        GameState state;
        bytes32 finalBoardState;
        bool submittedToOracle;
    }

    mapping(bytes32 => ChessGame) public games;
    bytes32[] public allGames;

    // Events
    event GameCreated(bytes32 indexed gameId, address indexed player1, address indexed player2);
    event MoveMade(bytes32 indexed gameId, address indexed player, uint256 moveNumber);
    event GameCompleted(bytes32 indexed gameId, address indexed winner, uint256 turns);
    event ResultSubmittedToOracle(bytes32 indexed gameId, bytes32 indexed matchId);

    constructor(
        address _oracleAddress,
        address _schemaRegistryAddress,
        address _templatesAddress
    ) {
        oracle = OracleCoreV2(_oracleAddress);
        schemaRegistry = GameSchemaRegistry(_schemaRegistryAddress);
        templates = SchemaTemplates(_templatesAddress);

        // Register this contract with the Turn-Based schema
        schemaRegistry.setGameSchema(address(this), templates.SCHEMA_TURN_BASED());
    }

    /**
     * @notice Create a new chess game
     * @param _opponent Address of the opponent
     */
    function createGame(address _opponent) external returns (bytes32) {
        require(_opponent != address(0), "OnchainChessGame: Invalid opponent");
        require(_opponent != msg.sender, "OnchainChessGame: Cannot play yourself");

        bytes32 gameId = keccak256(
            abi.encodePacked(msg.sender, _opponent, block.timestamp)
        );

        games[gameId] = ChessGame({
            gameId: gameId,
            player1: msg.sender,
            player2: _opponent,
            startTime: block.timestamp,
            endTime: 0,
            turnCount: 0,
            moveCount: 0,
            winner: address(0),
            state: GameState.InProgress,
            finalBoardState: bytes32(0),
            submittedToOracle: false
        });

        allGames.push(gameId);

        emit GameCreated(gameId, msg.sender, _opponent);

        return gameId;
    }

    /**
     * @notice Make a move (simplified - just tracking move count)
     * @param _gameId The game to make a move in
     */
    function makeMove(bytes32 _gameId) external {
        ChessGame storage game = games[_gameId];
        require(game.state == GameState.InProgress, "OnchainChessGame: Game not in progress");
        require(
            msg.sender == game.player1 || msg.sender == game.player2,
            "OnchainChessGame: Not a player"
        );

        game.moveCount++;

        // Each move by both players = 1 turn
        if (game.moveCount % 2 == 0) {
            game.turnCount++;
        }

        emit MoveMade(_gameId, msg.sender, game.moveCount);
    }

    /**
     * @notice Complete a game (simplified - winner declared)
     * @param _gameId The game to complete
     * @param _winner Address of the winner
     * @param _finalBoardState Final board state hash
     */
    function completeGame(
        bytes32 _gameId,
        address _winner,
        bytes32 _finalBoardState
    ) external {
        ChessGame storage game = games[_gameId];
        require(game.state == GameState.InProgress, "OnchainChessGame: Game not in progress");
        require(
            msg.sender == game.player1 || msg.sender == game.player2,
            "OnchainChessGame: Not a player"
        );
        require(
            _winner == game.player1 || _winner == game.player2 || _winner == address(0),
            "OnchainChessGame: Invalid winner"
        );

        game.winner = _winner;
        game.endTime = block.timestamp;
        game.state = GameState.Completed;
        game.finalBoardState = _finalBoardState;

        emit GameCompleted(_gameId, _winner, game.turnCount);
    }

    /**
     * @notice Submit game result to oracle for prediction markets to consume
     * @dev This is where the passive income magic happens!
     * @param _gameId The completed game
     * @param _matchId Match ID from GameRegistry
     */
    function submitToOracle(bytes32 _gameId, bytes32 _matchId) external {
        ChessGame storage game = games[_gameId];
        require(game.state == GameState.Completed, "OnchainChessGame: Game not completed");
        require(!game.submittedToOracle, "OnchainChessGame: Already submitted");
        require(
            msg.sender == game.player1 || msg.sender == game.player2,
            "OnchainChessGame: Not a player"
        );

        // Prepare participants and scores
        address[] memory participants = new address[](2);
        participants[0] = game.player1;
        participants[1] = game.player2;

        uint256[] memory scores = new uint256[](2);
        if (game.winner == game.player1) {
            scores[0] = 1; // Win
            scores[1] = 0; // Loss
        } else if (game.winner == game.player2) {
            scores[0] = 0;
            scores[1] = 1;
        } else {
            scores[0] = 0; // Draw
            scores[1] = 0;
        }

        // Determine winner index
        uint8 winnerIndex;
        if (game.winner == game.player1) {
            winnerIndex = 0;
        } else if (game.winner == game.player2) {
            winnerIndex = 1;
        } else {
            winnerIndex = 255; // Draw
        }

        // Encode custom data using Turn-Based schema
        uint256 thinkingTime = (game.endTime - game.startTime) / game.turnCount;
        bool perfectGame = game.turnCount < 20; // Arbitrary "perfect" threshold

        bytes memory customData = templates.encodeTurnBasedData(
            game.turnCount,
            game.moveCount,
            thinkingTime,
            perfectGame,
            0, // Strategy type (could be determined by move patterns)
            game.finalBoardState
        );

        // Submit to oracle
        oracle.submitResultV2(
            _matchId,
            address(this),
            participants,
            scores,
            winnerIndex,
            game.endTime - game.startTime,
            templates.SCHEMA_TURN_BASED(),
            customData
        );

        game.submittedToOracle = true;

        emit ResultSubmittedToOracle(_gameId, _matchId);
    }

    /**
     * @notice Get game details
     */
    function getGame(bytes32 _gameId) external view returns (ChessGame memory) {
        return games[_gameId];
    }

    /**
     * @notice Get total games
     */
    function getTotalGames() external view returns (uint256) {
        return allGames.length;
    }

    /**
     * @notice Get all games for a player
     */
    function getPlayerGames(address _player) external view returns (bytes32[] memory) {
        uint256 count = 0;

        // Count games
        for (uint256 i = 0; i < allGames.length; i++) {
            ChessGame storage game = games[allGames[i]];
            if (game.player1 == _player || game.player2 == _player) {
                count++;
            }
        }

        // Build result array
        bytes32[] memory result = new bytes32[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < allGames.length; i++) {
            ChessGame storage game = games[allGames[i]];
            if (game.player1 == _player || game.player2 == _player) {
                result[index] = allGames[i];
                index++;
            }
        }

        return result;
    }
}
