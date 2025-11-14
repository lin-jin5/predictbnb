# PredictBNB - Gaming Oracle Infrastructure

> **A decentralized gaming oracle for on-chain prediction markets on BNB Chain**

PredictBNB is a specialized oracle network for gaming results that enables game developers to monetize their data while providing prediction markets with fast, verified game outcomes.

## 🎯 Problem Statement

Current prediction market oracles (like UMA's Optimistic Oracle) face challenges:

- **Slow resolution**: 24-48 hours for UMA OO vs our **15-30 minutes**
- **Generic infrastructure**: Not optimized for gaming data
- **No developer incentives**: Game devs don't benefit from being data providers
- **High vulnerability**: Low-liquidity markets are easily manipulated

## 💡 Our Solution

PredictBNB creates a **domain-specific oracle for gaming** with:

1. ⚡ **Fast Finality**: 15-30 minute dispute window (vs 24-48h for UMA)
2. 🎮 **Gaming-Specific**: Built for esports and competitive gaming from day one
3. 💰 **Developer Monetization**: Game devs earn fees as their data is consumed
4. 🔒 **Stake-Based Security**: Developers stake tokens, slashed for fraud
5. 🆓 **Adoption-Friendly**: Free tier (50 queries/day) + prepaid balance with volume bonuses (5-15%)

## 🏗️ Architecture

```
┌─────────────────────┐
│  Game Developer     │
│  (Data Provider)    │
│  - Stakes 0.1 BNB   │
│  - Submits results  │
│  - Earns 80% fees   │
└──────────┬──────────┘
           │
           ▼
┌──────────────────────────────┐
│     GameRegistry.sol         │
│  - Register games            │
│  - Schedule matches          │
│  - Track reputation          │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│      OracleCore.sol          │
│  - Submit results            │
│  - 15-min dispute window     │
│  - Stake/slash mechanism     │
│  - Finalize results          │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│      FeeManager.sol          │
│  - Prepaid balance system    │
│  - Volume bonuses (5-15%)    │
│  - Usage-based distribution  │
│  - Free tier (50/day)        │
│  - Per-query: 0.003 BNB      │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│   Prediction Markets         │
│  (ExamplePredictionMarket)   │
│  - Create markets            │
│  - Accept bets               │
│  - Resolve with oracle       │
│  - Distribute winnings       │
└──────────────────────────────┘
```

## 🔑 Key Features

### For Game Developers
- ✅ Register games with 0.1 BNB stake
- ✅ Schedule matches with metadata
- ✅ Submit results from verified endpoints
- ✅ **Earn 80% of fees per query** (usage-based revenue!)
- ✅ More popular data = more revenue (fair distribution)
- ✅ Build reputation score (0-1000)
- ✅ Withdraw earnings anytime

### For Prediction Markets
- ✅ Access verified gaming data
- ✅ **Free tier: 50 queries/day** (1,500/month for testing)
- ✅ **Prepaid balance**: Deposit funds once, query many times
- ✅ **Volume bonuses**: 10+ BNB = 5%, 50+ BNB = 10%, 100+ BNB = 15%
- ✅ Per-query cost: 0.003 BNB ($1.80), effective $1.57-$1.80 with bonus
- ✅ **Gas efficient**: One deposit, no per-query gas fees
- ✅ Withdraw unused balance anytime
- ✅ Fast resolution: 15-30 minutes
- ✅ Batch queries for additional efficiency

### For Disputers
- ✅ Challenge suspicious results
- ✅ Stake 0.2 BNB to dispute
- ✅ Earn 150% back if dispute succeeds
- ✅ Automated validation checks
- ✅ Protect market integrity

## 📊 Token Economics

### Revenue Split (Per Query)
```
Each Query: 0.003 BNB ($1.80 @ $600/BNB)
├── 80% (0.0024 BNB = $1.44) → Game Developer (whose match was queried)
├── 15% (0.00045 BNB = $0.27) → Protocol Treasury
└── 5% (0.00015 BNB = $0.09) → Disputer Pool
```

**KEY FEATURE**: Game developers earn per query to THEIR games - popular games earn more!

### Prepaid Balance with Volume Bonuses

Users deposit funds once and get bonus credits for larger deposits:

| Deposit Amount | Bonus | Total Credit | Effective Cost/Query | Queries Enabled |
|----------------|-------|--------------|---------------------|-----------------|
| **1-9.99 BNB** | 0% | Deposit | $1.80 | 333-3,333 |
| **10-49.99 BNB** | **5%** | Deposit × 1.05 | **$1.71** | 3,500-17,499 |
| **50-99.99 BNB** | **10%** | Deposit × 1.10 | **$1.64** | 18,333-36,666 |
| **100+ BNB** | **15%** | Deposit × 1.15 | **$1.57** | 38,333+ |

**Example**: Deposit 100 BNB ($60,000) → Receive 115 BNB credit → 38,333 queries @ $1.57 each

### Benefits of Prepaid Model

✅ **Gas Efficient**: One deposit for thousands of queries (97% gas savings!)
✅ **Volume Discounts**: Save 5-15% on larger deposits
✅ **No Lock-in**: Withdraw unused balance anytime
✅ **Fair to Developers**: Popular games earn more (usage-based)
✅ **Free Tier**: 50 queries/day for testing

### Developer Revenue Potential (Usage-Based)

**Game developers earn $1.44 per query to THEIR game** - fair, transparent, scalable:

| Game Type | Monthly Queries | Monthly Revenue (@ $1.44/query) |
|-----------|-----------------|-------------------------------|
| **Niche/New Game** | 10,000 | **$14,400** 💰 |
| **Growing Game** | 100,000 | **$144,000** 💰 |
| **Popular Game** | 1,000,000 | **$1,440,000** 💰💰 |
| **Major Esports Title** | 10,000,000 | **$14,400,000** 💰💰💰 |
| **Top 3 Esports** | 50,000,000 | **$72,000,000** 💰💰💰 |

**Why this model is perfect:**
- ✅ Fair: Popular games earn more (as they should!)
- ✅ Motivating: Build better games → More queries → More revenue
- ✅ Passive: Onchain games auto-earn without any action
- ✅ Scalable: Revenue grows automatically with success
- ✅ Predictable: Simple formula: Queries × $1.44 = Monthly Revenue

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/uzochukwuV/predictbnb.git
cd predictbnb

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Add your private key to .env
```

### Compile Contracts

```bash
npm run compile
```

### Run Tests

```bash
npm test
```

### Deploy to BNB Testnet

```bash
# Configure .env with your private key and BSCScan API key
npm run deploy:testnet
```

### Run Demo

```bash
npm run demo
```

## 📝 Smart Contracts

### GameRegistry.sol
Manages game registration and match scheduling.

**Key Functions:**
- `registerGame(gameId, name, gameType)` - Register a new game (0.1 BNB stake)
- `scheduleMatch(gameId, matchId, time, metadata)` - Schedule a match
- `deactivateGame(gameId)` - Deactivate and withdraw stake (7 day cooldown)

### OracleCore.sol
Handles result submission, disputes, and finalization.

**Key Functions:**
- `submitResult(matchId, resultData)` - Submit game result
- `disputeResult(matchId, reason)` - Challenge a result (0.2 BNB stake)
- `finalizeResult(matchId)` - Finalize after dispute window
- `resolveDispute(matchId, valid)` - Owner resolves dispute

### FeeManager.sol
Manages prepaid balances and usage-based revenue distribution to game developers.

**Key Functions for Consumers:**
- `registerConsumer()` - Register as data consumer
- `depositBalance()` - Deposit funds with automatic volume bonus (5-15%)
- `withdrawBalance(amount)` - Withdraw unused balance
- `queryResult(matchId)` - Query result (deducts from balance after free tier)
- `batchQueryResults(matchIds)` - Batch query for efficiency
- `getConsumerBalance(address)` - Check remaining balance
- `calculateDepositBonus(amount)` - Preview bonus before deposit

**Key Functions for Game Developers:**
- `withdrawRevenue()` - Withdraw earned fees ($1.44 per query to your game)
- `getDeveloperRevenue(address)` - Check earnings and query count

### ExamplePredictionMarket.sol
Demo prediction market contract.

**Key Functions:**
- `createMarket(matchId, description)` - Create betting market
- `placeBet(marketId, outcome)` - Place bet on outcome
- `resolveMarket(marketId)` - Resolve with oracle data
- `claimWinnings(marketId)` - Claim winnings

## 🎮 Integration Guide

### For Game Developers

```solidity
// 1. Register your game
await gameRegistry.registerGame(
  "your-game-id",
  "Your Game Name",
  GameType.MOBA, // or FPS, Sports, etc.
  { value: ethers.parseEther("0.1") }
);

// 2. Schedule matches
const matchId = await gameRegistry.scheduleMatch(
  "your-game-id",
  "match-123",
  futureTimestamp,
  JSON.stringify({ team1: "TSM", team2: "C9" })
);

// 3. Submit results after match
await oracleCore.submitResult(
  matchId,
  JSON.stringify({ winner: "TSM", score: "2-1" })
);

// 4. Withdraw earnings
await feeManager.withdrawRevenue();
```

### For Prediction Markets

```solidity
// 1. Register as consumer
await feeManager.registerConsumer();

// 2. Deposit balance with volume bonus
await feeManager.depositBalance({ value: ethers.parseEther("50") });
// Depositing 50 BNB gets you 55 BNB credit (10% bonus!)
// This enables 18,333 queries @ $1.64 each

// 3. Check your balance
const balance = await feeManager.getConsumerBalance(yourAddress);
const freeQueries = await feeManager.getRemainingFreeQueries(yourAddress);

// 4. Query results (automatically deducts from balance)
const [resultData, resultHash, isFinalized] = await feeManager.queryResult(matchId);
// No payment needed per query! Deducted from prepaid balance
// Game developer earns $1.44 immediately

// 5. Use result data to resolve markets
const result = JSON.parse(resultData);
// Resolve betting market based on result

// 6. (Optional) Withdraw unused balance later
await feeManager.withdrawBalance(ethers.parseEther("10"));
```

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
npm test

# Run with gas reporting
npm run test:verbose

# Run specific test file
npx hardhat test test/GameRegistry.test.js
```

Test coverage:
- ✅ GameRegistry: Registration, scheduling, stake management
- ✅ OracleCore: Result submission, disputes, finalization
- ✅ FeeManager: Query fees, subscriptions, revenue distribution
- ✅ Integration: Complete end-to-end flows

## 🌐 Deployment

### BNB Testnet

```bash
npm run deploy:testnet
```

### BNB Mainnet

```bash
npm run deploy:mainnet
```

Deployment creates a JSON file in `deployments/` with all contract addresses.

## 🔐 Security Features

1. **Stake-Based Security**: Developers stake 0.1 BNB, slashed for fraud
2. **Reputation System**: Track developer reliability (0-1000 score)
3. **Fast Disputes**: 15-min window for challenges
4. **Automated Validation**: Check timing, authorization, data integrity
5. **ReentrancyGuard**: Protect all financial functions
6. **Ownable**: Admin functions for emergency situations

## 📈 Advantages Over UMA OO

| Feature | PredictBNB V3 | UMA Optimistic Oracle |
|---------|---------------|----------------------|
| **Resolution Time** | 15-30 minutes | 24-48 hours |
| **Domain Focus** | Gaming-specific | General purpose |
| **Developer Revenue** | 80% per query ($1.44) - usage based! | No direct monetization |
| **Free Tier** | 50 queries/day (1,500/month) | Pay per query |
| **Pricing Model** | Prepaid with volume bonuses (5-15%) | Pay per query |
| **Query Cost** | $1.57-$1.80 (with bonuses) | $0.50-$1.00 |
| **Gas Efficiency** | 97% savings (prepaid model) | Per-transaction gas |
| **Validation** | Gaming-specific checks | Generic |
| **Revenue Distribution** | Fair - popular games earn more | N/A |
| **Speed Advantage** | 96x faster | Baseline |

## 🛠️ Tech Stack

- **Smart Contracts**: Solidity 0.8.20
- **Development**: Hardhat
- **Testing**: Chai, Hardhat Network Helpers
- **Network**: BNB Chain (BSC Testnet & Mainnet)
- **Security**: OpenZeppelin Contracts

## 🗺️ Roadmap

### Phase 1: Core Infrastructure ✅ COMPLETE
- ✅ Smart contract development
- ✅ Testing suite
- ✅ Deployment scripts
- ✅ Schema registry system for flexible game data
- ✅ Batch operations for 60% gas savings
- ✅ Prepaid balance model (V3) with usage-based revenue distribution

### Phase 2: Integration & Partnerships (Current)
- 🔄 Integrate with 3-5 games (esports focus)
- 🔄 Partner with existing prediction market
- 🔄 Launch on BNB Testnet
- 🔄 Developer dashboard UI

### Phase 3: Production Launch
- ⏳ Security audit
- ⏳ Mainnet deployment
- ⏳ Marketing & developer onboarding
- ⏳ Analytics dashboard

### Phase 4: Advanced Features
- ⏳ Automated dispute bots
- ⏳ Cross-chain expansion
- ⏳ AI-assisted validation
- ⏳ Governance token

## 🎨 For YZi Labs Hackathon Judges

### How We Address YZi Labs Priorities:

1. **Domain-Specific Oracles** ✅
   - Gaming is underserved by generic oracles
   - Fast resolution critical for gaming markets
   - Built-in validation for gaming data

2. **Protocols/Infrastructure** ✅
   - We're infrastructure, not just another market UI
   - Composable: Multiple markets can use our data
   - Developer monetization creates supply-side incentive

3. **Speed Advantage** ✅
   - 15-30 min vs UMA's 24-48 hours
   - Critical for live gaming events
   - Better UX for bettors

4. **Incentive Innovation** ✅
   - Game devs earn ongoing revenue
   - Disputers earn rewards for honesty
   - Free tier drives adoption

5. **BNB Chain Fit** ✅
   - Low gas fees for micro-betting
   - Fast finality for quick resolution
   - Growing gaming ecosystem

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 🤝 Contributing

Contributions welcome! Please read our contributing guidelines and submit PRs.

## 📞 Contact

- **Project Lead**: [Your Name]
- **GitHub**: [@uzochukwuV/predictbnb](https://github.com/uzochukwuV/predictbnb)
- **Twitter**: [@YourTwitter]

## 🙏 Acknowledgments

- YZi Labs for the hackathon opportunity
- BNB Chain for infrastructure
- OpenZeppelin for secure contract templates
- The prediction markets community

---

**Built with ❤️ for YZi Labs Hackathon**

*Making gaming prediction markets faster, fairer, and more profitable for everyone.*
