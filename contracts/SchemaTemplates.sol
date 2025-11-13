// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GameSchemaRegistry.sol";

/**
 * @title SchemaTemplates
 * @notice Pre-built schema templates for common game types
 * @dev Deploys with standard schemas that games can immediately use
 */
contract SchemaTemplates {
    GameSchemaRegistry public schemaRegistry;

    // Template schema IDs
    bytes32 public SCHEMA_FPS_PVP;
    bytes32 public SCHEMA_RACING;
    bytes32 public SCHEMA_CARD_GAME;
    bytes32 public SCHEMA_SPORTS;
    bytes32 public SCHEMA_BATTLE_ROYALE;
    bytes32 public SCHEMA_MOBA;
    bytes32 public SCHEMA_TURN_BASED;
    bytes32 public SCHEMA_PUZZLE;

    constructor(address _schemaRegistryAddress) {
        require(_schemaRegistryAddress != address(0), "SchemaTemplates: Invalid registry");
        schemaRegistry = GameSchemaRegistry(_schemaRegistryAddress);

        _registerAllTemplates();
    }

    /**
     * @notice Register all standard schema templates
     */
    function _registerAllTemplates() internal {
        SCHEMA_FPS_PVP = _registerFPSSchema();
        SCHEMA_RACING = _registerRacingSchema();
        SCHEMA_CARD_GAME = _registerCardGameSchema();
        SCHEMA_SPORTS = _registerSportsSchema();
        SCHEMA_BATTLE_ROYALE = _registerBattleRoyaleSchema();
        SCHEMA_MOBA = _registerMOBASchema();
        SCHEMA_TURN_BASED = _registerTurnBasedSchema();
        SCHEMA_PUZZLE = _registerPuzzleSchema();
    }

    /**
     * FPS PvP Schema
     * For games like CS:GO, Valorant, Call of Duty
     *
     * customData encoding:
     * abi.encode(
     *     uint256 kills,
     *     uint256 deaths,
     *     uint256 assists,
     *     uint256 headshots,
     *     uint256 damageDealt,
     *     uint8 mvpPlayerId
     * )
     */
    function _registerFPSSchema() internal returns (bytes32) {
        bytes32[] memory fieldNames = new bytes32[](6);
        fieldNames[0] = keccak256("kills");
        fieldNames[1] = keccak256("deaths");
        fieldNames[2] = keccak256("assists");
        fieldNames[3] = keccak256("headshots");
        fieldNames[4] = keccak256("damageDealt");
        fieldNames[5] = keccak256("mvpPlayerId");

        string[] memory fieldTypes = new string[](6);
        fieldTypes[0] = "uint256";
        fieldTypes[1] = "uint256";
        fieldTypes[2] = "uint256";
        fieldTypes[3] = "uint256";
        fieldTypes[4] = "uint256";
        fieldTypes[5] = "uint8";

        return schemaRegistry.registerSchema(
            "FPS-PvP",
            GameSchemaRegistry.SchemaVersion(1, 0, 0),
            "First-person shooter PvP game statistics",
            '[{"name":"kills","type":"uint256"},{"name":"deaths","type":"uint256"},{"name":"assists","type":"uint256"},{"name":"headshots","type":"uint256"},{"name":"damageDealt","type":"uint256"},{"name":"mvpPlayerId","type":"uint8"}]',
            fieldNames,
            fieldTypes,
            true // isTemplate
        );
    }

    /**
     * Racing Schema
     * For games like Mario Kart, racing simulators
     *
     * customData encoding:
     * abi.encode(
     *     uint256[] lapTimes,
     *     uint256 topSpeed,
     *     uint8 position,
     *     uint256 totalDistance,
     *     bool perfectRace
     * )
     */
    function _registerRacingSchema() internal returns (bytes32) {
        bytes32[] memory fieldNames = new bytes32[](5);
        fieldNames[0] = keccak256("lapTimes");
        fieldNames[1] = keccak256("topSpeed");
        fieldNames[2] = keccak256("position");
        fieldNames[3] = keccak256("totalDistance");
        fieldNames[4] = keccak256("perfectRace");

        string[] memory fieldTypes = new string[](5);
        fieldTypes[0] = "uint256[]";
        fieldTypes[1] = "uint256";
        fieldTypes[2] = "uint8";
        fieldTypes[3] = "uint256";
        fieldTypes[4] = "bool";

        return schemaRegistry.registerSchema(
            "Racing",
            GameSchemaRegistry.SchemaVersion(1, 0, 0),
            "Racing game statistics with lap times and performance metrics",
            '[{"name":"lapTimes","type":"uint256[]"},{"name":"topSpeed","type":"uint256"},{"name":"position","type":"uint8"},{"name":"totalDistance","type":"uint256"},{"name":"perfectRace","type":"bool"}]',
            fieldNames,
            fieldTypes,
            true
        );
    }

    /**
     * Card Game Schema
     * For games like Hearthstone, Magic: The Gathering Arena, Poker
     *
     * customData encoding:
     * abi.encode(
     *     uint256 turnCount,
     *     uint256 cardsPlayed,
     *     uint256 longestCombo,
     *     uint256 damageDealt,
     *     bool perfectGame,
     *     uint8 deckArchetype
     * )
     */
    function _registerCardGameSchema() internal returns (bytes32) {
        bytes32[] memory fieldNames = new bytes32[](6);
        fieldNames[0] = keccak256("turnCount");
        fieldNames[1] = keccak256("cardsPlayed");
        fieldNames[2] = keccak256("longestCombo");
        fieldNames[3] = keccak256("damageDealt");
        fieldNames[4] = keccak256("perfectGame");
        fieldNames[5] = keccak256("deckArchetype");

        string[] memory fieldTypes = new string[](6);
        fieldTypes[0] = "uint256";
        fieldTypes[1] = "uint256";
        fieldTypes[2] = "uint256";
        fieldTypes[3] = "uint256";
        fieldTypes[4] = "bool";
        fieldTypes[5] = "uint8";

        return schemaRegistry.registerSchema(
            "Card-Game",
            GameSchemaRegistry.SchemaVersion(1, 0, 0),
            "Card and deck-building game statistics",
            '[{"name":"turnCount","type":"uint256"},{"name":"cardsPlayed","type":"uint256"},{"name":"longestCombo","type":"uint256"},{"name":"damageDealt","type":"uint256"},{"name":"perfectGame","type":"bool"},{"name":"deckArchetype","type":"uint8"}]',
            fieldNames,
            fieldTypes,
            true
        );
    }

    /**
     * Sports Schema
     * For games like FIFA, NBA 2K, Madden
     *
     * customData encoding:
     * abi.encode(
     *     uint256[] quarterScores,
     *     uint256 possession,
     *     uint256 shots,
     *     uint256 fouls,
     *     bool overtime,
     *     uint8 mvpPlayerId
     * )
     */
    function _registerSportsSchema() internal returns (bytes32) {
        bytes32[] memory fieldNames = new bytes32[](6);
        fieldNames[0] = keccak256("quarterScores");
        fieldNames[1] = keccak256("possession");
        fieldNames[2] = keccak256("shots");
        fieldNames[3] = keccak256("fouls");
        fieldNames[4] = keccak256("overtime");
        fieldNames[5] = keccak256("mvpPlayerId");

        string[] memory fieldTypes = new string[](6);
        fieldTypes[0] = "uint256[]";
        fieldTypes[1] = "uint256";
        fieldTypes[2] = "uint256";
        fieldTypes[3] = "uint256";
        fieldTypes[4] = "bool";
        fieldTypes[5] = "uint8";

        return schemaRegistry.registerSchema(
            "Sports",
            GameSchemaRegistry.SchemaVersion(1, 0, 0),
            "Sports game statistics including quarters, possession, and performance",
            '[{"name":"quarterScores","type":"uint256[]"},{"name":"possession","type":"uint256"},{"name":"shots","type":"uint256"},{"name":"fouls","type":"uint256"},{"name":"overtime","type":"bool"},{"name":"mvpPlayerId","type":"uint8"}]',
            fieldNames,
            fieldTypes,
            true
        );
    }

    /**
     * Battle Royale Schema
     * For games like Fortnite, PUBG, Apex Legends
     *
     * customData encoding:
     * abi.encode(
     *     uint256 kills,
     *     uint256 damageDealt,
     *     uint256 survivalTime,
     *     uint8 placementRank,
     *     uint256 distanceTraveled,
     *     bool victoryRoyale
     * )
     */
    function _registerBattleRoyaleSchema() internal returns (bytes32) {
        bytes32[] memory fieldNames = new bytes32[](6);
        fieldNames[0] = keccak256("kills");
        fieldNames[1] = keccak256("damageDealt");
        fieldNames[2] = keccak256("survivalTime");
        fieldNames[3] = keccak256("placementRank");
        fieldNames[4] = keccak256("distanceTraveled");
        fieldNames[5] = keccak256("victoryRoyale");

        string[] memory fieldTypes = new string[](6);
        fieldTypes[0] = "uint256";
        fieldTypes[1] = "uint256";
        fieldTypes[2] = "uint256";
        fieldTypes[3] = "uint8";
        fieldTypes[4] = "uint256";
        fieldTypes[5] = "bool";

        return schemaRegistry.registerSchema(
            "Battle-Royale",
            GameSchemaRegistry.SchemaVersion(1, 0, 0),
            "Battle royale game statistics with survival and performance metrics",
            '[{"name":"kills","type":"uint256"},{"name":"damageDealt","type":"uint256"},{"name":"survivalTime","type":"uint256"},{"name":"placementRank","type":"uint8"},{"name":"distanceTraveled","type":"uint256"},{"name":"victoryRoyale","type":"bool"}]',
            fieldNames,
            fieldTypes,
            true
        );
    }

    /**
     * MOBA Schema
     * For games like League of Legends, Dota 2
     *
     * customData encoding:
     * abi.encode(
     *     uint256 kills,
     *     uint256 deaths,
     *     uint256 assists,
     *     uint256 goldEarned,
     *     uint256 damageToChampions,
     *     uint8 championId,
     *     bool firstBlood
     * )
     */
    function _registerMOBASchema() internal returns (bytes32) {
        bytes32[] memory fieldNames = new bytes32[](7);
        fieldNames[0] = keccak256("kills");
        fieldNames[1] = keccak256("deaths");
        fieldNames[2] = keccak256("assists");
        fieldNames[3] = keccak256("goldEarned");
        fieldNames[4] = keccak256("damageToChampions");
        fieldNames[5] = keccak256("championId");
        fieldNames[6] = keccak256("firstBlood");

        string[] memory fieldTypes = new string[](7);
        fieldTypes[0] = "uint256";
        fieldTypes[1] = "uint256";
        fieldTypes[2] = "uint256";
        fieldTypes[3] = "uint256";
        fieldTypes[4] = "uint256";
        fieldTypes[5] = "uint8";
        fieldTypes[6] = "bool";

        return schemaRegistry.registerSchema(
            "MOBA",
            GameSchemaRegistry.SchemaVersion(1, 0, 0),
            "MOBA game statistics with KDA, gold, damage metrics",
            '[{"name":"kills","type":"uint256"},{"name":"deaths","type":"uint256"},{"name":"assists","type":"uint256"},{"name":"goldEarned","type":"uint256"},{"name":"damageToChampions","type":"uint256"},{"name":"championId","type":"uint8"},{"name":"firstBlood","type":"bool"}]',
            fieldNames,
            fieldTypes,
            true
        );
    }

    /**
     * Turn-Based Schema
     * For games like Chess, Checkers, TFT, Civilization
     *
     * customData encoding:
     * abi.encode(
     *     uint256 turnCount,
     *     uint256 moveCount,
     *     uint256 thinkingTime,
     *     bool perfectGame,
     *     uint8 strategyType,
     *     bytes32 finalBoardState
     * )
     */
    function _registerTurnBasedSchema() internal returns (bytes32) {
        bytes32[] memory fieldNames = new bytes32[](6);
        fieldNames[0] = keccak256("turnCount");
        fieldNames[1] = keccak256("moveCount");
        fieldNames[2] = keccak256("thinkingTime");
        fieldNames[3] = keccak256("perfectGame");
        fieldNames[4] = keccak256("strategyType");
        fieldNames[5] = keccak256("finalBoardState");

        string[] memory fieldTypes = new string[](6);
        fieldTypes[0] = "uint256";
        fieldTypes[1] = "uint256";
        fieldTypes[2] = "uint256";
        fieldTypes[3] = "bool";
        fieldTypes[4] = "uint8";
        fieldTypes[5] = "bytes32";

        return schemaRegistry.registerSchema(
            "Turn-Based",
            GameSchemaRegistry.SchemaVersion(1, 0, 0),
            "Turn-based strategy and board game statistics",
            '[{"name":"turnCount","type":"uint256"},{"name":"moveCount","type":"uint256"},{"name":"thinkingTime","type":"uint256"},{"name":"perfectGame","type":"bool"},{"name":"strategyType","type":"uint8"},{"name":"finalBoardState","type":"bytes32"}]',
            fieldNames,
            fieldTypes,
            true
        );
    }

    /**
     * Puzzle Schema
     * For games like Tetris, Candy Crush, puzzle games
     *
     * customData encoding:
     * abi.encode(
     *     uint256 score,
     *     uint256 level,
     *     uint256 movesUsed,
     *     uint256 combo,
     *     uint256 timeBonus,
     *     bool threeStars
     * )
     */
    function _registerPuzzleSchema() internal returns (bytes32) {
        bytes32[] memory fieldNames = new bytes32[](6);
        fieldNames[0] = keccak256("score");
        fieldNames[1] = keccak256("level");
        fieldNames[2] = keccak256("movesUsed");
        fieldNames[3] = keccak256("combo");
        fieldNames[4] = keccak256("timeBonus");
        fieldNames[5] = keccak256("threeStars");

        string[] memory fieldTypes = new string[](6);
        fieldTypes[0] = "uint256";
        fieldTypes[1] = "uint256";
        fieldTypes[2] = "uint256";
        fieldTypes[3] = "uint256";
        fieldTypes[4] = "uint256";
        fieldTypes[5] = "bool";

        return schemaRegistry.registerSchema(
            "Puzzle",
            GameSchemaRegistry.SchemaVersion(1, 0, 0),
            "Puzzle game statistics with score, level, and combo metrics",
            '[{"name":"score","type":"uint256"},{"name":"level","type":"uint256"},{"name":"movesUsed","type":"uint256"},{"name":"combo","type":"uint256"},{"name":"timeBonus","type":"uint256"},{"name":"threeStars","type":"bool"}]',
            fieldNames,
            fieldTypes,
            true
        );
    }

    // Helper functions for encoding data

    /**
     * @notice Helper to encode FPS game data
     */
    function encodeFPSData(
        uint256 kills,
        uint256 deaths,
        uint256 assists,
        uint256 headshots,
        uint256 damageDealt,
        uint8 mvpPlayerId
    ) external pure returns (bytes memory) {
        return abi.encode(kills, deaths, assists, headshots, damageDealt, mvpPlayerId);
    }

    /**
     * @notice Helper to encode Racing game data
     */
    function encodeRacingData(
        uint256[] memory lapTimes,
        uint256 topSpeed,
        uint8 position,
        uint256 totalDistance,
        bool perfectRace
    ) external pure returns (bytes memory) {
        return abi.encode(lapTimes, topSpeed, position, totalDistance, perfectRace);
    }

    /**
     * @notice Helper to encode Card game data
     */
    function encodeCardGameData(
        uint256 turnCount,
        uint256 cardsPlayed,
        uint256 longestCombo,
        uint256 damageDealt,
        bool perfectGame,
        uint8 deckArchetype
    ) external pure returns (bytes memory) {
        return abi.encode(
            turnCount,
            cardsPlayed,
            longestCombo,
            damageDealt,
            perfectGame,
            deckArchetype
        );
    }

    /**
     * @notice Helper to encode Sports game data
     */
    function encodeSportsData(
        uint256[] memory quarterScores,
        uint256 possession,
        uint256 shots,
        uint256 fouls,
        bool overtime,
        uint8 mvpPlayerId
    ) external pure returns (bytes memory) {
        return abi.encode(quarterScores, possession, shots, fouls, overtime, mvpPlayerId);
    }

    /**
     * @notice Helper to encode Battle Royale game data
     */
    function encodeBattleRoyaleData(
        uint256 kills,
        uint256 damageDealt,
        uint256 survivalTime,
        uint8 placementRank,
        uint256 distanceTraveled,
        bool victoryRoyale
    ) external pure returns (bytes memory) {
        return abi.encode(
            kills,
            damageDealt,
            survivalTime,
            placementRank,
            distanceTraveled,
            victoryRoyale
        );
    }

    /**
     * @notice Helper to encode MOBA game data
     */
    function encodeMOBAData(
        uint256 kills,
        uint256 deaths,
        uint256 assists,
        uint256 goldEarned,
        uint256 damageToChampions,
        uint8 championId,
        bool firstBlood
    ) external pure returns (bytes memory) {
        return abi.encode(
            kills,
            deaths,
            assists,
            goldEarned,
            damageToChampions,
            championId,
            firstBlood
        );
    }

    /**
     * @notice Helper to encode Turn-Based game data
     */
    function encodeTurnBasedData(
        uint256 turnCount,
        uint256 moveCount,
        uint256 thinkingTime,
        bool perfectGame,
        uint8 strategyType,
        bytes32 finalBoardState
    ) external pure returns (bytes memory) {
        return abi.encode(
            turnCount,
            moveCount,
            thinkingTime,
            perfectGame,
            strategyType,
            finalBoardState
        );
    }

    /**
     * @notice Helper to encode Puzzle game data
     */
    function encodePuzzleData(
        uint256 score,
        uint256 level,
        uint256 movesUsed,
        uint256 combo,
        uint256 timeBonus,
        bool threeStars
    ) external pure returns (bytes memory) {
        return abi.encode(score, level, movesUsed, combo, timeBonus, threeStars);
    }
}
