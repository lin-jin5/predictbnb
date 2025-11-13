// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GameSchemaRegistry
 * @notice Registry for game-specific data schemas to enable rich, flexible game results
 * @dev Allows games to define custom data structures while maintaining discoverability
 */
contract GameSchemaRegistry is Ownable {
    // Schema version struct
    struct SchemaVersion {
        uint8 major;
        uint8 minor;
        uint8 patch;
    }

    // Game schema definition
    struct GameSchema {
        bytes32 schemaId;           // keccak256(name + version)
        string name;                // e.g., "PvP-FPS-v1", "Racing-v1"
        SchemaVersion version;
        string description;         // Human-readable description
        string abiDefinition;       // JSON string of ABI for off-chain parsing
        bytes32[] fieldNames;       // Array of field name hashes for validation
        string[] fieldTypes;        // Parallel array: ["uint256", "address[]", ...]
        address creator;
        uint256 createdAt;
        bool isActive;
        bool isTemplate;            // True if this is a standard template
        uint256 usageCount;         // Number of games using this schema
    }

    // Storage
    mapping(bytes32 => GameSchema) public schemas;
    mapping(address => bytes32) public gameToSchema;        // Game contract => schema ID
    mapping(string => bytes32) public nameToLatestSchema;   // Schema name => latest version

    bytes32[] public allSchemaIds;
    bytes32[] public templateSchemaIds;

    // Events
    event SchemaRegistered(
        bytes32 indexed schemaId,
        string name,
        address indexed creator,
        bool isTemplate
    );

    event SchemaUpdated(
        bytes32 indexed schemaId,
        bool isActive
    );

    event GameSchemaSet(
        address indexed gameContract,
        bytes32 indexed schemaId,
        string schemaName
    );

    event SchemaUsageIncremented(
        bytes32 indexed schemaId,
        uint256 newCount
    );

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Register a new game data schema
     * @param _name Schema name (e.g., "PvP-FPS")
     * @param _version Version struct (major.minor.patch)
     * @param _description Human-readable description
     * @param _abiDefinition JSON string of ABI
     * @param _fieldNames Array of field name hashes
     * @param _fieldTypes Parallel array of field types
     * @param _isTemplate Whether this is a standard template (only owner)
     */
    function registerSchema(
        string calldata _name,
        SchemaVersion calldata _version,
        string calldata _description,
        string calldata _abiDefinition,
        bytes32[] calldata _fieldNames,
        string[] calldata _fieldTypes,
        bool _isTemplate
    ) external returns (bytes32) {
        require(bytes(_name).length > 0, "GameSchemaRegistry: Empty name");
        require(_fieldNames.length > 0, "GameSchemaRegistry: No fields");
        require(
            _fieldNames.length == _fieldTypes.length,
            "GameSchemaRegistry: Field arrays length mismatch"
        );

        // Only owner can create templates
        if (_isTemplate) {
            require(msg.sender == owner(), "GameSchemaRegistry: Only owner can create templates");
        }

        // Generate unique schema ID
        bytes32 schemaId = keccak256(
            abi.encodePacked(
                _name,
                _version.major,
                _version.minor,
                _version.patch
            )
        );

        require(schemas[schemaId].createdAt == 0, "GameSchemaRegistry: Schema already exists");

        // Store schema
        schemas[schemaId] = GameSchema({
            schemaId: schemaId,
            name: _name,
            version: _version,
            description: _description,
            abiDefinition: _abiDefinition,
            fieldNames: _fieldNames,
            fieldTypes: _fieldTypes,
            creator: msg.sender,
            createdAt: block.timestamp,
            isActive: true,
            isTemplate: _isTemplate,
            usageCount: 0
        });

        allSchemaIds.push(schemaId);

        if (_isTemplate) {
            templateSchemaIds.push(schemaId);
        }

        // Update latest version mapping
        nameToLatestSchema[_name] = schemaId;

        emit SchemaRegistered(schemaId, _name, msg.sender, _isTemplate);

        return schemaId;
    }

    /**
     * @notice Set schema for a game contract
     * @param _gameContract Address of the game contract
     * @param _schemaId Schema ID to use
     */
    function setGameSchema(address _gameContract, bytes32 _schemaId) external {
        require(_gameContract != address(0), "GameSchemaRegistry: Invalid game address");

        GameSchema storage schema = schemas[_schemaId];
        require(schema.createdAt > 0, "GameSchemaRegistry: Schema does not exist");
        require(schema.isActive, "GameSchemaRegistry: Schema not active");

        // Only game contract itself or owner can set schema
        require(
            msg.sender == _gameContract || msg.sender == owner(),
            "GameSchemaRegistry: Not authorized"
        );

        // Update mapping
        gameToSchema[_gameContract] = _schemaId;
        schema.usageCount++;

        emit GameSchemaSet(_gameContract, _schemaId, schema.name);
        emit SchemaUsageIncremented(_schemaId, schema.usageCount);
    }

    /**
     * @notice Deactivate a schema (can't be used by new games)
     * @param _schemaId Schema to deactivate
     */
    function deactivateSchema(bytes32 _schemaId) external {
        GameSchema storage schema = schemas[_schemaId];
        require(schema.createdAt > 0, "GameSchemaRegistry: Schema does not exist");
        require(
            msg.sender == schema.creator || msg.sender == owner(),
            "GameSchemaRegistry: Not authorized"
        );

        schema.isActive = false;

        emit SchemaUpdated(_schemaId, false);
    }

    /**
     * @notice Reactivate a schema
     * @param _schemaId Schema to reactivate
     */
    function reactivateSchema(bytes32 _schemaId) external {
        GameSchema storage schema = schemas[_schemaId];
        require(schema.createdAt > 0, "GameSchemaRegistry: Schema does not exist");
        require(
            msg.sender == schema.creator || msg.sender == owner(),
            "GameSchemaRegistry: Not authorized"
        );

        schema.isActive = true;

        emit SchemaUpdated(_schemaId, true);
    }

    /**
     * @notice Validate that encoded data matches schema
     * @param _schemaId Schema to validate against
     * @param _encodedData ABI-encoded data
     * @return isValid Whether data matches schema structure
     */
    function validateEncodedData(
        bytes32 _schemaId,
        bytes calldata _encodedData
    ) external view returns (bool isValid) {
        GameSchema storage schema = schemas[_schemaId];
        require(schema.createdAt > 0, "GameSchemaRegistry: Schema does not exist");

        // Basic length check
        if (_encodedData.length == 0) {
            return false;
        }

        // For more complex validation, would need to decode based on types
        // This is a simplified version - production would use assembly or libraries
        return _encodedData.length > 0;
    }

    // View functions

    /**
     * @notice Get full schema details
     * @param _schemaId Schema ID
     */
    function getSchema(bytes32 _schemaId) external view returns (GameSchema memory) {
        require(schemas[_schemaId].createdAt > 0, "GameSchemaRegistry: Schema does not exist");
        return schemas[_schemaId];
    }

    /**
     * @notice Get schema for a game contract
     * @param _gameContract Game contract address
     */
    function getGameSchema(address _gameContract) external view returns (GameSchema memory) {
        bytes32 schemaId = gameToSchema[_gameContract];
        require(schemaId != bytes32(0), "GameSchemaRegistry: No schema set for game");
        return schemas[schemaId];
    }

    /**
     * @notice Get latest version of a schema by name
     * @param _name Schema name
     */
    function getLatestSchemaByName(string calldata _name)
        external
        view
        returns (GameSchema memory)
    {
        bytes32 schemaId = nameToLatestSchema[_name];
        require(schemaId != bytes32(0), "GameSchemaRegistry: Schema name not found");
        return schemas[schemaId];
    }

    /**
     * @notice Get all template schemas
     */
    function getTemplateSchemas() external view returns (bytes32[] memory) {
        return templateSchemaIds;
    }

    /**
     * @notice Get all schemas
     */
    function getAllSchemas() external view returns (bytes32[] memory) {
        return allSchemaIds;
    }

    /**
     * @notice Get schema field info
     * @param _schemaId Schema ID
     */
    function getSchemaFields(bytes32 _schemaId)
        external
        view
        returns (bytes32[] memory fieldNames, string[] memory fieldTypes)
    {
        GameSchema storage schema = schemas[_schemaId];
        require(schema.createdAt > 0, "GameSchemaRegistry: Schema does not exist");
        return (schema.fieldNames, schema.fieldTypes);
    }

    /**
     * @notice Check if game has schema registered
     * @param _gameContract Game contract address
     */
    function hasSchema(address _gameContract) external view returns (bool) {
        return gameToSchema[_gameContract] != bytes32(0);
    }

    /**
     * @notice Get schema ID for game
     * @param _gameContract Game contract address
     */
    function getGameSchemaId(address _gameContract) external view returns (bytes32) {
        return gameToSchema[_gameContract];
    }

    /**
     * @notice Get total number of schemas
     */
    function getTotalSchemas() external view returns (uint256) {
        return allSchemaIds.length;
    }

    /**
     * @notice Get total number of template schemas
     */
    function getTotalTemplates() external view returns (uint256) {
        return templateSchemaIds.length;
    }

    /**
     * @notice Get schemas by creator
     * @param _creator Creator address
     */
    function getSchemasByCreator(address _creator)
        external
        view
        returns (bytes32[] memory)
    {
        uint256 count = 0;

        // Count schemas by creator
        for (uint256 i = 0; i < allSchemaIds.length; i++) {
            if (schemas[allSchemaIds[i]].creator == _creator) {
                count++;
            }
        }

        // Build result array
        bytes32[] memory result = new bytes32[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < allSchemaIds.length; i++) {
            if (schemas[allSchemaIds[i]].creator == _creator) {
                result[index] = allSchemaIds[i];
                index++;
            }
        }

        return result;
    }

    /**
     * @notice Check if schema is active
     * @param _schemaId Schema ID
     */
    function isSchemaActive(bytes32 _schemaId) external view returns (bool) {
        return schemas[_schemaId].isActive;
    }
}
