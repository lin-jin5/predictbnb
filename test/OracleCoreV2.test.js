const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("OracleCoreV2 with Schema Support", function () {
  let gameRegistry, schemaRegistry, schemaTemplates, oracleCore;
  let owner, gameDev, consumer;
  let matchId;

  const REGISTRATION_STAKE = ethers.parseEther("0.1");

  beforeEach(async function () {
    [owner, gameDev, consumer] = await ethers.getSigners();

    // Deploy GameRegistry
    const GameRegistry = await ethers.getContractFactory("GameRegistry");
    gameRegistry = await GameRegistry.deploy();
    await gameRegistry.waitForDeployment();

    // Deploy Schema Registry
    const GameSchemaRegistry = await ethers.getContractFactory("GameSchemaRegistry");
    schemaRegistry = await GameSchemaRegistry.deploy();
    await schemaRegistry.waitForDeployment();

    // Deploy Schema Templates
    const SchemaTemplates = await ethers.getContractFactory("SchemaTemplates");
    schemaTemplates = await SchemaTemplates.deploy(await schemaRegistry.getAddress());
    await schemaTemplates.waitForDeployment();

    // Deploy OracleCoreV2
    const OracleCoreV2 = await ethers.getContractFactory("OracleCoreV2");
    oracleCore = await OracleCoreV2.deploy(
      await gameRegistry.getAddress(),
      await schemaRegistry.getAddress()
    );
    await oracleCore.waitForDeployment();

    // Transfer GameRegistry ownership to OracleCore
    await gameRegistry.transferOwnership(await oracleCore.getAddress());

    // Register game and schedule match
    await gameRegistry.connect(gameDev).registerGame(
      "fps-game-001",
      "Test FPS Game",
      1, // FPS
      { value: REGISTRATION_STAKE }
    );

    const futureTime = (await time.latest()) + 3600;
    const tx = await gameRegistry.connect(gameDev).scheduleMatch(
      "fps-game-001",
      "match-001",
      futureTime,
      '{"map": "Dust2", "mode": "Competitive"}'
    );

    const receipt = await tx.wait();
    const event = receipt.logs.find(log => {
      try {
        return gameRegistry.interface.parseLog(log).name === "MatchScheduled";
      } catch {
        return false;
      }
    });

    matchId = gameRegistry.interface.parseLog(event).args.matchId;

    // Fast forward past match time
    await time.increase(3700);
  });

  describe("Result Submission with Schema", function () {
    it("Should submit result with FPS schema data", async function () {
      const fpsSchemaId = await schemaTemplates.SCHEMA_FPS_PVP();

      // Set schema for game
      await schemaRegistry.setGameSchema(gameDev.address, fpsSchemaId);

      // Prepare participants
      const player1 = ethers.Wallet.createRandom().address;
      const player2 = ethers.Wallet.createRandom().address;
      const participants = [player1, player2];
      const scores = [16, 14]; // Team 1 wins 16-14

      // Encode FPS data
      const customData = await schemaTemplates.encodeFPSData(
        25,   // kills
        10,   // deaths
        8,    // assists
        12,   // headshots
        3200, // damageDealt
        0     // mvpPlayerId (player1)
      );

      await expect(
        oracleCore.connect(gameDev).submitResultV2(
          matchId,
          gameDev.address,
          participants,
          scores,
          0, // winner index (Team A)
          2400, // duration (40 minutes)
          fpsSchemaId,
          customData
        )
      ).to.emit(oracleCore, "ResultSubmittedV2")
        .and.to.emit(oracleCore, "SchemaDataValidated");

      const result = await oracleCore.getResultV2(matchId);
      expect(result.participants.length).to.equal(2);
      expect(result.scores[0]).to.equal(16);
      expect(result.winnerIndex).to.equal(0);
      expect(result.schemaId).to.equal(fpsSchemaId);
      expect(result.customData).to.equal(customData);
    });

    it("Should submit result with MOBA schema data", async function () {
      const mobaSchemaId = await schemaTemplates.SCHEMA_MOBA();

      const player1 = ethers.Wallet.createRandom().address;
      const player2 = ethers.Wallet.createRandom().address;
      const participants = [player1, player2];
      const scores = [1, 0]; // Player 1 wins

      const customData = await schemaTemplates.encodeMOBAData(
        15,    // kills
        3,     // deaths
        10,    // assists
        12500, // goldEarned
        25000, // damageToChampions
        42,    // championId
        true   // firstBlood
      );

      await oracleCore.connect(gameDev).submitResultV2(
        matchId,
        gameDev.address,
        participants,
        scores,
        0, // winner
        1800, // 30 minutes
        mobaSchemaId,
        customData
      );

      const result = await oracleCore.getResultV2(matchId);
      expect(result.schemaId).to.equal(mobaSchemaId);

      // Decode and verify custom data
      const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
        ["uint256", "uint256", "uint256", "uint256", "uint256", "uint8", "bool"],
        result.customData
      );

      expect(decoded[0]).to.equal(15n); // kills
      expect(decoded[6]).to.be.true;    // firstBlood
    });

    it("Should submit result with Racing schema data", async function () {
      const racingSchemaId = await schemaTemplates.SCHEMA_RACING();

      const player1 = ethers.Wallet.createRandom().address;
      const participants = [player1];
      const scores = [1]; // 1st place

      const lapTimes = [62000, 61500, 61000]; // Improving lap times

      const customData = await schemaTemplates.encodeRacingData(
        lapTimes,
        285,   // topSpeed
        1,     // position (1st)
        12000, // totalDistance
        true   // perfectRace
      );

      await oracleCore.connect(gameDev).submitResultV2(
        matchId,
        gameDev.address,
        participants,
        scores,
        0, // winner (only one participant)
        184500, // duration (sum of lap times)
        racingSchemaId,
        customData
      );

      const result = await oracleCore.getResultV2(matchId);
      expect(result.schemaId).to.equal(racingSchemaId);

      const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
        ["uint256[]", "uint256", "uint8", "uint256", "bool"],
        result.customData
      );

      expect(decoded[0].length).to.equal(3);
      expect(decoded[0][2]).to.equal(61000n); // Best lap time
      expect(decoded[4]).to.be.true; // Perfect race
    });

    it("Should fail with invalid schema", async function () {
      const fakeSchemaId = ethers.keccak256(ethers.toUtf8Bytes("fake"));

      const participants = [gameDev.address];
      const scores = [1];

      await expect(
        oracleCore.connect(gameDev).submitResultV2(
          matchId,
          gameDev.address,
          participants,
          scores,
          0,
          1000,
          fakeSchemaId,
          "0x1234"
        )
      ).to.be.revertedWith("OracleCoreV2: Validation failed");
    });

    it("Should fail with mismatched participants and scores", async function () {
      const participants = [gameDev.address];
      const scores = [1, 2]; // More scores than participants

      await expect(
        oracleCore.connect(gameDev).submitResultV2(
          matchId,
          gameDev.address,
          participants,
          scores,
          0,
          1000,
          ethers.ZeroHash,
          "0x"
        )
      ).to.be.revertedWith("OracleCoreV2: Participants/scores length mismatch");
    });
  });

  describe("Backward Compatibility", function () {
    it("Should submit legacy result without schema", async function () {
      const resultData = '{"winner": "TeamA", "score": "16-14"}';

      await expect(
        oracleCore.connect(gameDev).submitResult(matchId, resultData)
      ).to.emit(oracleCore, "ResultSubmittedV2");

      // Should be able to query with legacy method
      const [data, hash, isFinalized] = await oracleCore.getResult(matchId);
      expect(data).to.equal(resultData);
      expect(isFinalized).to.be.false;

      // Should also work with new method
      const result = await oracleCore.getResultV2(matchId);
      expect(result.schemaId).to.equal(ethers.ZeroHash);
      expect(ethers.toUtf8String(result.customData)).to.equal(resultData);
    });
  });

  describe("Finalization with Schema Data", function () {
    beforeEach(async function () {
      const fpsSchemaId = await schemaTemplates.SCHEMA_FPS_PVP();
      const participants = [ethers.Wallet.createRandom().address, ethers.Wallet.createRandom().address];
      const scores = [16, 10];
      const customData = await schemaTemplates.encodeFPSData(20, 8, 5, 10, 2800, 0);

      await oracleCore.connect(gameDev).submitResultV2(
        matchId,
        gameDev.address,
        participants,
        scores,
        0,
        2000,
        fpsSchemaId,
        customData
      );
    });

    it("Should finalize result and preserve custom data", async function () {
      // Fast forward past dispute window
      await time.increase(16 * 60);

      await expect(
        oracleCore.finalizeResult(matchId)
      ).to.emit(oracleCore, "ResultFinalized");

      const result = await oracleCore.getResultV2(matchId);
      expect(result.isFinalized).to.be.true;
      expect(result.customData).to.not.equal("0x");

      // Verify custom data is intact
      const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
        ["uint256", "uint256", "uint256", "uint256", "uint256", "uint8"],
        result.customData
      );

      expect(decoded[0]).to.equal(20n); // kills
      expect(decoded[3]).to.equal(10n); // headshots
    });
  });

  describe("Custom Data Querying", function () {
    it("Should retrieve custom data separately", async function () {
      const mobaSchemaId = await schemaTemplates.SCHEMA_MOBA();
      const participants = [gameDev.address, consumer.address];
      const scores = [1, 0];
      const customData = await schemaTemplates.encodeMOBAData(15, 3, 10, 12500, 25000, 42, true);

      await oracleCore.connect(gameDev).submitResultV2(
        matchId,
        gameDev.address,
        participants,
        scores,
        0,
        1800,
        mobaSchemaId,
        customData
      );

      const [schemaId, data] = await oracleCore.getCustomData(matchId);
      expect(schemaId).to.equal(mobaSchemaId);
      expect(data).to.equal(customData);
    });

    it("Should retrieve participants and scores", async function () {
      const player1 = ethers.Wallet.createRandom().address;
      const player2 = ethers.Wallet.createRandom().address;
      const participants = [player1, player2];
      const scores = [25, 20];

      await oracleCore.connect(gameDev).submitResultV2(
        matchId,
        gameDev.address,
        participants,
        scores,
        0,
        3000,
        ethers.ZeroHash,
        "0x"
      );

      const [retrievedParticipants, retrievedScores, winnerIndex] =
        await oracleCore.getParticipantsAndScores(matchId);

      expect(retrievedParticipants[0]).to.equal(player1);
      expect(retrievedParticipants[1]).to.equal(player2);
      expect(retrievedScores[0]).to.equal(25);
      expect(retrievedScores[1]).to.equal(20);
      expect(winnerIndex).to.equal(0);
    });
  });

  describe("Validation Checks with Schema", function () {
    it("Should validate schema correctly", async function () {
      const fpsSchemaId = await schemaTemplates.SCHEMA_FPS_PVP();
      const participants = [gameDev.address];
      const scores = [1];
      const customData = await schemaTemplates.encodeFPSData(10, 5, 3, 4, 2000, 0);

      await oracleCore.connect(gameDev).submitResultV2(
        matchId,
        gameDev.address,
        participants,
        scores,
        0,
        1000,
        fpsSchemaId,
        customData
      );

      const validation = await oracleCore.getValidationChecks(matchId);
      expect(validation.schemaValid).to.be.true;
      expect(validation.authorizedSubmitter).to.be.true;
      expect(validation.participantsValid).to.be.true;
    });
  });
});
