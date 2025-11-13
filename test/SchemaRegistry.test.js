const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GameSchemaRegistry and SchemaTemplates", function () {
  let schemaRegistry, schemaTemplates;
  let owner, gameDev1, gameDev2;

  beforeEach(async function () {
    [owner, gameDev1, gameDev2] = await ethers.getSigners();

    // Deploy GameSchemaRegistry
    const GameSchemaRegistry = await ethers.getContractFactory("GameSchemaRegistry");
    schemaRegistry = await GameSchemaRegistry.deploy();
    await schemaRegistry.waitForDeployment();

    // Deploy SchemaTemplates
    const SchemaTemplates = await ethers.getContractFactory("SchemaTemplates");
    schemaTemplates = await SchemaTemplates.deploy(await schemaRegistry.getAddress());
    await schemaTemplates.waitForDeployment();
  });

  describe("Schema Registration", function () {
    it("Should register a custom schema", async function () {
      const fieldNames = [
        ethers.id("customField1"),
        ethers.id("customField2")
      ];

      const fieldTypes = ["uint256", "address"];

      const tx = await schemaRegistry.connect(gameDev1).registerSchema(
        "CustomGame",
        { major: 1, minor: 0, patch: 0 },
        "A custom game schema",
        '[{"name":"customField1","type":"uint256"},{"name":"customField2","type":"address"}]',
        fieldNames,
        fieldTypes,
        false // not a template
      );

      await expect(tx).to.emit(schemaRegistry, "SchemaRegistered");

      const schemaId = ethers.keccak256(
        ethers.AbiCoder.defaultAbiCoder().encode(
          ["string", "uint8", "uint8", "uint8"],
          ["CustomGame", 1, 0, 0]
        )
      );

      const schema = await schemaRegistry.getSchema(schemaId);
      expect(schema.name).to.equal("CustomGame");
      expect(schema.creator).to.equal(gameDev1.address);
      expect(schema.isActive).to.be.true;
      expect(schema.isTemplate).to.be.false;
    });

    it("Should fail to register duplicate schema", async function () {
      const fieldNames = [ethers.id("field1")];
      const fieldTypes = ["uint256"];

      await schemaRegistry.connect(gameDev1).registerSchema(
        "TestGame",
        { major: 1, minor: 0, patch: 0 },
        "Test",
        '[]',
        fieldNames,
        fieldTypes,
        false
      );

      await expect(
        schemaRegistry.connect(gameDev1).registerSchema(
          "TestGame",
          { major: 1, minor: 0, patch: 0 },
          "Test",
          '[]',
          fieldNames,
          fieldTypes,
          false
        )
      ).to.be.revertedWith("GameSchemaRegistry: Schema already exists");
    });

    it("Should only allow owner to create templates", async function () {
      const fieldNames = [ethers.id("field1")];
      const fieldTypes = ["uint256"];

      await expect(
        schemaRegistry.connect(gameDev1).registerSchema(
          "Template",
          { major: 1, minor: 0, patch: 0 },
          "Template",
          '[]',
          fieldNames,
          fieldTypes,
          true // trying to create template
        )
      ).to.be.revertedWith("GameSchemaRegistry: Only owner can create templates");
    });

    it("Should fail with mismatched field arrays", async function () {
      const fieldNames = [ethers.id("field1"), ethers.id("field2")];
      const fieldTypes = ["uint256"]; // Only one type

      await expect(
        schemaRegistry.connect(gameDev1).registerSchema(
          "BadSchema",
          { major: 1, minor: 0, patch: 0 },
          "Bad",
          '[]',
          fieldNames,
          fieldTypes,
          false
        )
      ).to.be.revertedWith("GameSchemaRegistry: Field arrays length mismatch");
    });
  });

  describe("Schema Templates", function () {
    it("Should have all template schemas registered", async function () {
      const templates = await schemaRegistry.getTemplateSchemas();

      // Should have 8 templates (FPS, Racing, Card, Sports, BattleRoyale, MOBA, TurnBased, Puzzle)
      expect(templates.length).to.equal(8);
    });

    it("Should retrieve FPS schema", async function () {
      const fpsSchemaId = await schemaTemplates.SCHEMA_FPS_PVP();
      const schema = await schemaRegistry.getSchema(fpsSchemaId);

      expect(schema.name).to.equal("FPS-PvP");
      expect(schema.isTemplate).to.be.true;
      expect(schema.isActive).to.be.true;
      expect(schema.fieldNames.length).to.equal(6); // kills, deaths, assists, headshots, damageDealt, mvpPlayerId
    });

    it("Should retrieve Racing schema", async function () {
      const racingSchemaId = await schemaTemplates.SCHEMA_RACING();
      const schema = await schemaRegistry.getSchema(racingSchemaId);

      expect(schema.name).to.equal("Racing");
      expect(schema.isTemplate).to.be.true;
      expect(schema.fieldNames.length).to.equal(5);
    });

    it("Should retrieve MOBA schema", async function () {
      const mobaSchemaId = await schemaTemplates.SCHEMA_MOBA();
      const schema = await schemaRegistry.getSchema(mobaSchemaId);

      expect(schema.name).to.equal("MOBA");
      expect(schema.fieldNames.length).to.equal(7);
    });

    it("Should retrieve Turn-Based schema", async function () {
      const turnBasedSchemaId = await schemaTemplates.SCHEMA_TURN_BASED();
      const schema = await schemaRegistry.getSchema(turnBasedSchemaId);

      expect(schema.name).to.equal("Turn-Based");
      expect(schema.fieldNames.length).to.equal(6);
    });
  });

  describe("Game Schema Association", function () {
    it("Should set schema for a game contract", async function () {
      const schemaId = await schemaTemplates.SCHEMA_FPS_PVP();
      const gameAddress = gameDev1.address; // Simulating game contract address

      await expect(
        schemaRegistry.connect(gameDev1).setGameSchema(gameAddress, schemaId)
      ).to.emit(schemaRegistry, "GameSchemaSet")
        .withArgs(gameAddress, schemaId, "FPS-PvP");

      const retrievedSchemaId = await schemaRegistry.getGameSchemaId(gameAddress);
      expect(retrievedSchemaId).to.equal(schemaId);

      const hasSchema = await schemaRegistry.hasSchema(gameAddress);
      expect(hasSchema).to.be.true;
    });

    it("Should increment usage count when schema is set", async function () {
      const schemaId = await schemaTemplates.SCHEMA_FPS_PVP();

      const schemaBefore = await schemaRegistry.getSchema(schemaId);
      const usageBefore = schemaBefore.usageCount;

      await schemaRegistry.connect(gameDev1).setGameSchema(gameDev1.address, schemaId);

      const schemaAfter = await schemaRegistry.getSchema(schemaId);
      expect(schemaAfter.usageCount).to.equal(usageBefore + 1n);
    });

    it("Should fail to set inactive schema", async function () {
      const fieldNames = [ethers.id("field1")];
      const fieldTypes = ["uint256"];

      // Register and then deactivate a schema
      const tx = await schemaRegistry.connect(gameDev1).registerSchema(
        "InactiveTest",
        { major: 1, minor: 0, patch: 0 },
        "Test",
        '[]',
        fieldNames,
        fieldTypes,
        false
      );

      const receipt = await tx.wait();
      const event = receipt.logs.find(log => {
        try {
          return schemaRegistry.interface.parseLog(log).name === "SchemaRegistered";
        } catch {
          return false;
        }
      });

      const schemaId = schemaRegistry.interface.parseLog(event).args.schemaId;

      await schemaRegistry.connect(gameDev1).deactivateSchema(schemaId);

      await expect(
        schemaRegistry.connect(gameDev1).setGameSchema(gameDev1.address, schemaId)
      ).to.be.revertedWith("GameSchemaRegistry: Schema not active");
    });
  });

  describe("Schema Management", function () {
    let customSchemaId;

    beforeEach(async function () {
      const fieldNames = [ethers.id("testField")];
      const fieldTypes = ["uint256"];

      const tx = await schemaRegistry.connect(gameDev1).registerSchema(
        "TestSchema",
        { major: 1, minor: 0, patch: 0 },
        "Test",
        '[]',
        fieldNames,
        fieldTypes,
        false
      );

      const receipt = await tx.wait();
      const event = receipt.logs.find(log => {
        try {
          return schemaRegistry.interface.parseLog(log).name === "SchemaRegistered";
        } catch {
          return false;
        }
      });

      customSchemaId = schemaRegistry.interface.parseLog(event).args.schemaId;
    });

    it("Should allow creator to deactivate their schema", async function () {
      await expect(
        schemaRegistry.connect(gameDev1).deactivateSchema(customSchemaId)
      ).to.emit(schemaRegistry, "SchemaUpdated")
        .withArgs(customSchemaId, false);

      const isActive = await schemaRegistry.isSchemaActive(customSchemaId);
      expect(isActive).to.be.false;
    });

    it("Should allow creator to reactivate their schema", async function () {
      await schemaRegistry.connect(gameDev1).deactivateSchema(customSchemaId);
      await schemaRegistry.connect(gameDev1).reactivateSchema(customSchemaId);

      const isActive = await schemaRegistry.isSchemaActive(customSchemaId);
      expect(isActive).to.be.true;
    });

    it("Should not allow non-creator to deactivate schema", async function () {
      await expect(
        schemaRegistry.connect(gameDev2).deactivateSchema(customSchemaId)
      ).to.be.revertedWith("GameSchemaRegistry: Not authorized");
    });

    it("Should allow owner to deactivate any schema", async function () {
      await schemaRegistry.connect(owner).deactivateSchema(customSchemaId);

      const isActive = await schemaRegistry.isSchemaActive(customSchemaId);
      expect(isActive).to.be.false;
    });
  });

  describe("Schema Querying", function () {
    it("Should get latest schema by name", async function () {
      const fpsSchemaId = await schemaTemplates.SCHEMA_FPS_PVP();
      const schema = await schemaRegistry.getLatestSchemaByName("FPS-PvP");

      expect(schema.schemaId).to.equal(fpsSchemaId);
    });

    it("Should get schema fields", async function () {
      const fpsSchemaId = await schemaTemplates.SCHEMA_FPS_PVP();
      const [fieldNames, fieldTypes] = await schemaRegistry.getSchemaFields(fpsSchemaId);

      expect(fieldNames.length).to.equal(6);
      expect(fieldTypes.length).to.equal(6);
      expect(fieldTypes[0]).to.equal("uint256"); // kills
      expect(fieldTypes[5]).to.equal("uint8");   // mvpPlayerId
    });

    it("Should get all schemas", async function () {
      const allSchemas = await schemaRegistry.getAllSchemas();
      expect(allSchemas.length).to.be.greaterThan(0);
    });

    it("Should get schemas by creator", async function () {
      const fieldNames = [ethers.id("field1")];
      const fieldTypes = ["uint256"];

      await schemaRegistry.connect(gameDev1).registerSchema(
        "Game1",
        { major: 1, minor: 0, patch: 0 },
        "Test 1",
        '[]',
        fieldNames,
        fieldTypes,
        false
      );

      await schemaRegistry.connect(gameDev1).registerSchema(
        "Game2",
        { major: 1, minor: 0, patch: 0 },
        "Test 2",
        '[]',
        fieldNames,
        fieldTypes,
        false
      );

      const schemas = await schemaRegistry.getSchemasByCreator(gameDev1.address);
      expect(schemas.length).to.equal(2);
    });

    it("Should get total schemas count", async function () {
      const total = await schemaRegistry.getTotalSchemas();
      expect(total).to.be.greaterThan(0);
    });

    it("Should get total templates count", async function () {
      const total = await schemaRegistry.getTotalTemplates();
      expect(total).to.equal(8);
    });
  });

  describe("Schema Encoding Helpers", function () {
    it("Should encode FPS data correctly", async function () {
      const encoded = await schemaTemplates.encodeFPSData(
        10,  // kills
        5,   // deaths
        3,   // assists
        4,   // headshots
        2500, // damageDealt
        0    // mvpPlayerId
      );

      expect(encoded).to.not.equal("0x");
      expect(encoded.length).to.be.greaterThan(2);

      // Decode to verify
      const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
        ["uint256", "uint256", "uint256", "uint256", "uint256", "uint8"],
        encoded
      );

      expect(decoded[0]).to.equal(10n); // kills
      expect(decoded[1]).to.equal(5n);  // deaths
      expect(decoded[5]).to.equal(0);   // mvpPlayerId
    });

    it("Should encode Racing data correctly", async function () {
      const lapTimes = [60000, 58000, 57500]; // milliseconds

      const encoded = await schemaTemplates.encodeRacingData(
        lapTimes,
        250,  // topSpeed
        1,    // position (1st place)
        15000, // totalDistance
        true  // perfectRace
      );

      const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
        ["uint256[]", "uint256", "uint8", "uint256", "bool"],
        encoded
      );

      expect(decoded[0].length).to.equal(3);
      expect(decoded[0][0]).to.equal(60000n);
      expect(decoded[2]).to.equal(1); // position
      expect(decoded[4]).to.be.true;  // perfectRace
    });

    it("Should encode MOBA data correctly", async function () {
      const encoded = await schemaTemplates.encodeMOBAData(
        15,    // kills
        3,     // deaths
        10,    // assists
        12500, // goldEarned
        25000, // damageToChampions
        42,    // championId
        true   // firstBlood
      );

      const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
        ["uint256", "uint256", "uint256", "uint256", "uint256", "uint8", "bool"],
        encoded
      );

      expect(decoded[0]).to.equal(15n); // kills
      expect(decoded[5]).to.equal(42);  // championId
      expect(decoded[6]).to.be.true;    // firstBlood
    });
  });

  describe("Data Validation", function () {
    it("Should validate properly encoded data", async function () {
      const schemaId = await schemaTemplates.SCHEMA_FPS_PVP();

      const validData = await schemaTemplates.encodeFPSData(
        10, 5, 3, 4, 2500, 0
      );

      const isValid = await schemaRegistry.validateEncodedData(schemaId, validData);
      expect(isValid).to.be.true;
    });

    it("Should reject empty data", async function () {
      const schemaId = await schemaTemplates.SCHEMA_FPS_PVP();

      const isValid = await schemaRegistry.validateEncodedData(schemaId, "0x");
      expect(isValid).to.be.false;
    });
  });
});
