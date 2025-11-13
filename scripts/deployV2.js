const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("🚀 Deploying Gaming Oracle Infrastructure V2 with Schema Support...\n");

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", hre.ethers.formatEther(balance), "BNB\n");

  // Deploy GameRegistry
  console.log("📝 Deploying GameRegistry...");
  const GameRegistry = await hre.ethers.getContractFactory("GameRegistry");
  const gameRegistry = await GameRegistry.deploy();
  await gameRegistry.waitForDeployment();
  const gameRegistryAddress = await gameRegistry.getAddress();
  console.log("✅ GameRegistry deployed to:", gameRegistryAddress);

  // Deploy GameSchemaRegistry
  console.log("\n📝 Deploying GameSchemaRegistry...");
  const GameSchemaRegistry = await hre.ethers.getContractFactory("GameSchemaRegistry");
  const schemaRegistry = await GameSchemaRegistry.deploy();
  await schemaRegistry.waitForDeployment();
  const schemaRegistryAddress = await schemaRegistry.getAddress();
  console.log("✅ GameSchemaRegistry deployed to:", schemaRegistryAddress);

  // Deploy SchemaTemplates
  console.log("\n📝 Deploying SchemaTemplates...");
  const SchemaTemplates = await hre.ethers.getContractFactory("SchemaTemplates");
  const schemaTemplates = await SchemaTemplates.deploy(schemaRegistryAddress);
  await schemaTemplates.waitForDeployment();
  const schemaTemplatesAddress = await schemaTemplates.getAddress();
  console.log("✅ SchemaTemplates deployed to:", schemaTemplatesAddress);

  // Get template schema IDs
  console.log("\n📋 Retrieving Template Schema IDs...");
  const templateIds = {
    FPS_PVP: await schemaTemplates.SCHEMA_FPS_PVP(),
    RACING: await schemaTemplates.SCHEMA_RACING(),
    CARD_GAME: await schemaTemplates.SCHEMA_CARD_GAME(),
    SPORTS: await schemaTemplates.SCHEMA_SPORTS(),
    BATTLE_ROYALE: await schemaTemplates.SCHEMA_BATTLE_ROYALE(),
    MOBA: await schemaTemplates.SCHEMA_MOBA(),
    TURN_BASED: await schemaTemplates.SCHEMA_TURN_BASED(),
    PUZZLE: await schemaTemplates.SCHEMA_PUZZLE()
  };
  console.log("✅ Retrieved 8 template schemas");

  // Deploy OracleCoreV2
  console.log("\n📝 Deploying OracleCoreV2...");
  const OracleCoreV2 = await hre.ethers.getContractFactory("OracleCoreV2");
  const oracleCore = await OracleCoreV2.deploy(gameRegistryAddress, schemaRegistryAddress);
  await oracleCore.waitForDeployment();
  const oracleCoreAddress = await oracleCore.getAddress();
  console.log("✅ OracleCoreV2 deployed to:", oracleCoreAddress);

  // Deploy FeeManager
  console.log("\n📝 Deploying FeeManager...");
  const FeeManager = await hre.ethers.getContractFactory("FeeManager");
  const feeManager = await FeeManager.deploy(gameRegistryAddress, oracleCoreAddress);
  await feeManager.waitForDeployment();
  const feeManagerAddress = await feeManager.getAddress();
  console.log("✅ FeeManager deployed to:", feeManagerAddress);

  // Transfer GameRegistry ownership to OracleCore
  console.log("\n🔐 Transferring GameRegistry ownership to OracleCoreV2...");
  await gameRegistry.transferOwnership(oracleCoreAddress);
  console.log("✅ Ownership transferred");

  // Save deployment addresses
  const deploymentInfo = {
    network: hre.network.name,
    chainId: (await hre.ethers.provider.getNetwork()).chainId.toString(),
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    version: "2.0.0",
    contracts: {
      GameRegistry: gameRegistryAddress,
      GameSchemaRegistry: schemaRegistryAddress,
      SchemaTemplates: schemaTemplatesAddress,
      OracleCoreV2: oracleCoreAddress,
      FeeManager: feeManagerAddress
    },
    templateSchemas: templateIds,
    constants: {
      REGISTRATION_STAKE: "0.1 BNB",
      DISPUTE_STAKE: "0.2 BNB",
      DISPUTE_WINDOW: "15 minutes",
      BASE_QUERY_FEE: "0.0005 BNB",
      MONTHLY_SUBSCRIPTION: "1 BNB",
      FREE_DAILY_QUERIES: 100
    },
    features: [
      "Schema-based custom game data",
      "8 pre-built template schemas",
      "Backward compatible with V1",
      "Flexible participant/score tracking",
      "Enhanced validation",
      "Onchain game support ready"
    ]
  };

  // Create deployments directory
  const deploymentsDir = path.join(__dirname, "..", "deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }

  // Save deployment info
  const filename = `deployment-v2-${hre.network.name}-${Date.now()}.json`;
  const filepath = path.join(deploymentsDir, filename);
  fs.writeFileSync(filepath, JSON.stringify(deploymentInfo, null, 2));

  console.log("\n📄 Deployment info saved to:", filepath);

  console.log("\n" + "=".repeat(80));
  console.log("🎉 DEPLOYMENT COMPLETE!");
  console.log("=".repeat(80));
  console.log("\nCore Contracts:");
  console.log("-------------------");
  console.log("GameRegistry:          ", gameRegistryAddress);
  console.log("GameSchemaRegistry:    ", schemaRegistryAddress);
  console.log("SchemaTemplates:       ", schemaTemplatesAddress);
  console.log("OracleCoreV2:          ", oracleCoreAddress);
  console.log("FeeManager:            ", feeManagerAddress);

  console.log("\n📚 Template Schemas:");
  console.log("-------------------");
  console.log("FPS PvP:        ", templateIds.FPS_PVP.slice(0, 10) + "...");
  console.log("Racing:         ", templateIds.RACING.slice(0, 10) + "...");
  console.log("Card Game:      ", templateIds.CARD_GAME.slice(0, 10) + "...");
  console.log("Sports:         ", templateIds.SPORTS.slice(0, 10) + "...");
  console.log("Battle Royale:  ", templateIds.BATTLE_ROYALE.slice(0, 10) + "...");
  console.log("MOBA:           ", templateIds.MOBA.slice(0, 10) + "...");
  console.log("Turn-Based:     ", templateIds.TURN_BASED.slice(0, 10) + "...");
  console.log("Puzzle:         ", templateIds.PUZZLE.slice(0, 10) + "...");

  console.log("\n📚 Next Steps:");
  console.log("1. Verify contracts on BSCScan:");
  console.log(`   npx hardhat verify --network ${hre.network.name} ${gameRegistryAddress}`);
  console.log(`   npx hardhat verify --network ${hre.network.name} ${schemaRegistryAddress}`);
  console.log(`   npx hardhat verify --network ${hre.network.name} ${schemaTemplatesAddress} ${schemaRegistryAddress}`);
  console.log(`   npx hardhat verify --network ${hre.network.name} ${oracleCoreAddress} ${gameRegistryAddress} ${schemaRegistryAddress}`);
  console.log(`   npx hardhat verify --network ${hre.network.name} ${feeManagerAddress} ${gameRegistryAddress} ${oracleCoreAddress}`);

  console.log("\n2. Integration Examples:");
  console.log("   - Register game with schema:");
  console.log(`     schemaRegistry.setGameSchema(gameAddress, templateIds.FPS_PVP)`);
  console.log("   - Submit result with custom data:");
  console.log(`     oracleCore.submitResultV2(..., schemaId, customData)`);

  console.log("\n3. Test the deployment:");
  console.log("   - Run schema integration tests");
  console.log("   - Deploy example onchain game");
  console.log("   - Create prediction market using schemas");

  console.log("\n" + "=".repeat(80) + "\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
