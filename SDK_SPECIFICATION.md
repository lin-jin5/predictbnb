# PredictBNB SDK Specification

## 🎯 Why SDK is Needed

**You're right**: Onchain games CAN submit directly to contracts.

**But we still need an SDK for:**
1. **Web2/Offchain Games** - 90% of games are still Web2 (League of Legends, CS:GO, Fortnite, etc.)
2. **Prediction Markets** - Need easy integration to query data
3. **Developer Experience** - Even Web3 devs benefit from abstraction
4. **Backend Services** - Tournament organizers, analytics platforms, etc.

---

## 📦 SDK Packages

### 1. JavaScript/TypeScript SDK (`@predictbnb/sdk`)
**Target**: Web2 game backends, Web3 dApps, prediction markets

### 2. Python SDK (`predictbnb-python`)
**Target**: Game servers, ML models, analytics

### 3. Go SDK (`predictbnb-go`)
**Target**: High-performance game servers

---

## 🔧 JavaScript/TypeScript SDK

### Installation

```bash
npm install @predictbnb/sdk ethers
# or
yarn add @predictbnb/sdk ethers
```

### Core Architecture

```typescript
@predictbnb/sdk/
├── src/
│   ├── index.ts                  # Main export
│   ├── client.ts                 # PredictBNBClient class
│   ├── developer/
│   │   ├── GameDeveloper.ts      # Game developer functions
│   │   ├── types.ts              # Developer types
│   │   └── utils.ts              # Helper functions
│   ├── consumer/
│   │   ├── PredictionMarket.ts   # Market consumer functions
│   │   ├── types.ts              # Consumer types
│   │   └── utils.ts              # Helper functions
│   ├── contracts/
│   │   ├── abis/                 # Contract ABIs
│   │   ├── addresses.ts          # Contract addresses
│   │   └── types.ts              # Generated types
│   ├── schemas/
│   │   ├── templates.ts          # Schema templates
│   │   ├── encoder.ts            # ABI encoding helpers
│   │   └── types.ts              # Schema types
│   └── utils/
│       ├── errors.ts             # Custom errors
│       ├── validation.ts         # Input validation
│       └── helpers.ts            # Utility functions
└── examples/
    ├── game-developer.ts
    ├── prediction-market.ts
    └── onchain-game.ts
```

---

## 📝 SDK API Reference

### Initialization

```typescript
import { PredictBNB } from '@predictbnb/sdk';
import { ethers } from 'ethers';

// For Web2 backends (using private key)
const client = new PredictBNB({
  network: 'bnb-testnet', // or 'bnb-mainnet'
  privateKey: process.env.PRIVATE_KEY, // For backend services
});

// For Web3 frontends (using wallet)
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();
const client = new PredictBNB({
  network: 'bnb-mainnet',
  signer: signer,
});

// Read-only mode (no transactions)
const client = new PredictBNB({
  network: 'bnb-mainnet',
  mode: 'readonly',
});
```

---

### For Game Developers

#### Register Game

```typescript
// Register a new game
const txResponse = await client.developer.registerGame({
  gameId: 'csgo-competitive',
  name: 'CS:GO Competitive',
  gameType: 'FPS',
  stake: '0.1', // BNB amount
});

await txResponse.wait();
console.log('Game registered!');
```

#### Schedule Match

```typescript
// Schedule a match
const matchId = await client.developer.scheduleMatch({
  gameId: 'csgo-competitive',
  matchId: 'match-12345',
  scheduledTime: Date.now() + 3600000, // 1 hour from now
  metadata: {
    team1: 'Team Liquid',
    team2: 'Natus Vincere',
    tournament: 'IEM Katowice',
    map: 'de_dust2',
  },
});

console.log('Match scheduled:', matchId);
```

#### Submit Result (Simple)

```typescript
// Submit match result (V1 - Simple JSON)
await client.developer.submitResult({
  matchId: 'match-12345',
  resultData: {
    winner: 'Team Liquid',
    score: '16-14',
    mvp: 's1mple',
    duration: 3245, // seconds
  },
});
```

#### Submit Result (Schema-Based)

```typescript
// Submit match result (V2 - With schema)
await client.developer.submitResultV2({
  matchId: 'match-12345',
  participants: ['0x123...', '0x456...'], // Player addresses
  scores: [16, 14],
  winnerIndex: 0,
  duration: 3245,
  schema: 'FPS_PVP', // Use template
  customData: {
    kills: 245,
    deaths: 198,
    assists: 142,
    headshots: 89,
    damageDealt: 125000,
    mvpPlayerId: 0,
  },
});
```

#### Batch Submit

```typescript
// Batch submit multiple results (gas savings!)
await client.developer.batchSubmitResults([
  {
    matchId: 'match-001',
    participants: [...],
    scores: [16, 12],
    // ...
  },
  {
    matchId: 'match-002',
    participants: [...],
    scores: [14, 16],
    // ...
  },
  // ... up to 50 matches
]);
```

#### Check Revenue

```typescript
// Get developer revenue stats
const revenue = await client.developer.getRevenue();

console.log({
  totalEarned: revenue.totalEarned.toString(), // in BNB
  totalEarnedUSD: revenue.totalEarnedUSD, // converted to USD
  pendingWithdrawal: revenue.pendingWithdrawal.toString(),
  queryCount: revenue.queryCount,
  avgPerQuery: revenue.avgPerQuery, // should be ~$1.44
});
```

#### Withdraw Revenue

```typescript
// Withdraw earned revenue
const tx = await client.developer.withdrawRevenue();
await tx.wait();

console.log('Revenue withdrawn!');
```

---

### For Prediction Markets

#### Register as Consumer

```typescript
// Register as data consumer
await client.consumer.register();
```

#### Deposit Balance

```typescript
// Deposit funds with automatic volume bonus
const tx = await client.consumer.depositBalance('50'); // 50 BNB

await tx.wait();

// Check bonus received
const bonus = await client.consumer.calculateBonus('50');
console.log(`Depositing 50 BNB gets you ${bonus} BNB bonus!`);
// Output: "Depositing 50 BNB gets you 5 BNB bonus!"
```

#### Check Balance

```typescript
// Get current balance
const balance = await client.consumer.getBalance();

console.log({
  balance: balance.balance.toString(), // in BNB
  balanceUSD: balance.balanceUSD,
  totalDeposited: balance.totalDeposited.toString(),
  queriesRemaining: balance.queriesRemaining, // approximate
  freeQueriesRemaining: balance.freeQueriesRemaining,
});
```

#### Query Result

```typescript
// Query a match result
const result = await client.consumer.queryResult('match-12345');

console.log({
  resultData: result.resultData, // JSON string
  resultHash: result.resultHash,
  isFinalized: result.isFinalized,
  cost: result.cost, // 0 if free tier, else 0.003 BNB
});

// Parse result data
const matchData = JSON.parse(result.resultData);
console.log('Winner:', matchData.winner);
```

#### Batch Query

```typescript
// Query multiple matches at once
const results = await client.consumer.batchQueryResults([
  'match-001',
  'match-002',
  'match-003',
]);

results.forEach((result, index) => {
  const data = JSON.parse(result.resultData);
  console.log(`Match ${index + 1} winner:`, data.winner);
});
```

#### Withdraw Balance

```typescript
// Withdraw unused balance
const tx = await client.consumer.withdrawBalance('10'); // 10 BNB
await tx.wait();
```

---

### Utilities

#### Encoding Helpers

```typescript
// Encode custom data for schema submission
import { SchemaEncoder } from '@predictbnb/sdk';

// FPS schema
const customData = SchemaEncoder.encodeFPS({
  kills: 245,
  deaths: 198,
  assists: 142,
  headshots: 89,
  damageDealt: 125000,
  mvpPlayerId: 0,
});

// MOBA schema
const customData = SchemaEncoder.encodeMOBA({
  kills: 28,
  deaths: 5,
  assists: 42,
  goldEarned: 28500,
  damageDealt: 145000,
  damageTaken: 85000,
  towerKills: 8,
  baronKills: 2,
  dragonKills: 3,
});

// Racing schema
const customData = SchemaEncoder.encodeRacing({
  lapTimes: [92500, 91200, 90800],
  bestLap: 90800,
  avgSpeed: 185,
  topSpeed: 245,
  pitStops: 2,
  position: 1,
});
```

#### Event Listeners

```typescript
// Listen to events
client.on('ResultSubmitted', (event) => {
  console.log('New result:', event.matchId);
});

client.on('RevenueEarned', (event) => {
  console.log('Earned:', event.amount);
});

client.on('BalanceDeposited', (event) => {
  console.log('Deposited:', event.amount, 'Bonus:', event.bonus);
});
```

---

## 🐍 Python SDK

### Installation

```bash
pip install predictbnb
```

### Usage

```python
from predictbnb import PredictBNB, Network
import os

# Initialize
client = PredictBNB(
    network=Network.BNB_TESTNET,
    private_key=os.getenv('PRIVATE_KEY')
)

# Game Developer: Register game
tx_hash = client.developer.register_game(
    game_id='csgo-competitive',
    name='CS:GO Competitive',
    game_type='FPS',
    stake=0.1
)

# Wait for confirmation
client.wait_for_transaction(tx_hash)

# Game Developer: Submit result
client.developer.submit_result(
    match_id='match-12345',
    result_data={
        'winner': 'Team Liquid',
        'score': '16-14',
        'mvp': 's1mple'
    }
)

# Prediction Market: Query result
result = client.consumer.query_result('match-12345')
print(f"Winner: {result['resultData']['winner']}")

# Check revenue
revenue = client.developer.get_revenue()
print(f"Total earned: {revenue['totalEarned']} BNB")
print(f"Query count: {revenue['queryCount']}")
```

---

## 🔷 Go SDK

### Installation

```bash
go get github.com/predictbnb/predictbnb-go
```

### Usage

```go
package main

import (
    "github.com/predictbnb/predictbnb-go"
    "fmt"
)

func main() {
    // Initialize client
    client, err := predictbnb.NewClient(&predictbnb.Config{
        Network: predictbnb.BNBTestnet,
        PrivateKey: os.Getenv("PRIVATE_KEY"),
    })
    if err != nil {
        panic(err)
    }

    // Register game
    tx, err := client.Developer.RegisterGame(&predictbnb.GameParams{
        GameID: "csgo-competitive",
        Name: "CS:GO Competitive",
        GameType: "FPS",
        Stake: "0.1",
    })
    if err != nil {
        panic(err)
    }

    // Wait for transaction
    receipt, err := client.WaitForTransaction(tx.Hash())
    if err != nil {
        panic(err)
    }

    fmt.Println("Game registered!")

    // Submit result
    err = client.Developer.SubmitResult(&predictbnb.ResultParams{
        MatchID: "match-12345",
        ResultData: map[string]interface{}{
            "winner": "Team Liquid",
            "score": "16-14",
        },
    })

    // Query result
    result, err := client.Consumer.QueryResult("match-12345")
    fmt.Printf("Winner: %s\n", result.ResultData["winner"])
}
```

---

## 🔌 Integration Patterns

### Pattern 1: Web2 Game Server (Node.js Backend)

```typescript
// game-server.js
import { PredictBNB } from '@predictbnb/sdk';
import express from 'express';

const client = new PredictBNB({
  network: 'bnb-mainnet',
  privateKey: process.env.ORACLE_PRIVATE_KEY,
});

const app = express();

// When match ends, submit to oracle
app.post('/match/end', async (req, res) => {
  const { matchId, winner, stats } = req.body;

  try {
    // Submit to PredictBNB
    await client.developer.submitResultV2({
      matchId,
      participants: stats.players.map(p => p.address),
      scores: stats.scores,
      winnerIndex: stats.winnerIndex,
      schema: 'FPS_PVP',
      customData: stats.customData,
    });

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000);
```

### Pattern 2: Onchain Game (Direct Contract Calls)

```solidity
// OnchainGame.sol
import "@predictbnb/contracts/OracleCoreV2.sol";

contract MyOnchainGame {
    OracleCoreV2 public oracle;

    function endGame(uint256 gameId) external {
        // Game logic...

        // Submit to oracle directly
        oracle.submitResultV2(
            matchId,
            address(this),
            participants,
            scores,
            winnerIndex,
            gameDuration,
            schemaId,
            customData
        );

        // Developer earns $1.44 per future query automatically!
    }
}
```

### Pattern 3: Tournament Organizer (Batch Submit)

```typescript
// tournament-service.ts
import { PredictBNB } from '@predictbnb/sdk';

const client = new PredictBNB({
  network: 'bnb-mainnet',
  privateKey: process.env.TOURNAMENT_KEY,
});

// End of day: Submit all tournament matches in one transaction
async function submitDailyResults() {
  const matches = await database.getTodaysMatches();

  // Batch submit (60% gas savings!)
  await client.developer.batchSubmitResults(
    matches.map(match => ({
      matchId: match.id,
      participants: match.players,
      scores: match.scores,
      winnerIndex: match.winnerIndex,
      schema: 'FPS_PVP',
      customData: match.stats,
    }))
  );

  console.log(`Submitted ${matches.length} matches in one transaction!`);
}

// Run daily at midnight
cron.schedule('0 0 * * *', submitDailyResults);
```

### Pattern 4: Prediction Market (Frontend)

```typescript
// PredictionMarketApp.tsx
import { PredictBNB } from '@predictbnb/sdk';
import { useSigner } from 'wagmi';

function PredictionMarketApp() {
  const { data: signer } = useSigner();
  const client = new PredictBNB({ network: 'bnb-mainnet', signer });

  async function createMarket(matchId: string) {
    // Query the result
    const result = await client.consumer.queryResult(matchId);

    // Cost automatically deducted from prepaid balance
    // Game developer earned $1.44!

    // Use result to resolve prediction market
    const matchData = JSON.parse(result.resultData);
    await resolvePredictionMarket(matchData.winner);
  }

  return (
    <div>
      <button onClick={() => createMarket('match-123')}>
        Resolve Market
      </button>
    </div>
  );
}
```

---

## 📚 SDK Features

### Error Handling

```typescript
import { PredictBNBError, ErrorCode } from '@predictbnb/sdk';

try {
  await client.consumer.queryResult('match-123');
} catch (error) {
  if (error instanceof PredictBNBError) {
    switch (error.code) {
      case ErrorCode.INSUFFICIENT_BALANCE:
        console.error('Please deposit more funds!');
        break;
      case ErrorCode.RESULT_NOT_FINALIZED:
        console.error('Result still in dispute window');
        break;
      case ErrorCode.MATCH_NOT_FOUND:
        console.error('Match does not exist');
        break;
    }
  }
}
```

### Type Safety

```typescript
// Full TypeScript support
import type {
  GameResult,
  DeveloperRevenue,
  ConsumerBalance,
  MatchMetadata,
} from '@predictbnb/sdk';

const revenue: DeveloperRevenue = await client.developer.getRevenue();
// IDE autocomplete works perfectly!
```

### Caching

```typescript
// Built-in caching for read operations
const client = new PredictBNB({
  network: 'bnb-mainnet',
  cache: {
    enabled: true,
    ttl: 60, // seconds
  },
});

// First call: hits blockchain
const balance1 = await client.consumer.getBalance();

// Second call: from cache (instant!)
const balance2 = await client.consumer.getBalance();
```

---

## 🚀 SDK Benefits

### For Game Developers

✅ **No Web3 knowledge required** - Simple REST-like API
✅ **Works with any tech stack** - JS, Python, Go, more coming
✅ **Type-safe** - Full TypeScript support
✅ **Gas optimized** - Batch operations built-in
✅ **5-minute integration** - Copy-paste examples

### For Prediction Markets

✅ **Balance management simplified** - One function to deposit/withdraw
✅ **Automatic fee handling** - No need to calculate fees
✅ **Caching built-in** - Fast repeated queries
✅ **Event subscriptions** - Real-time updates

---

## 📦 Package Structure

```
@predictbnb/sdk/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   ├── client.ts
│   ├── developer/
│   ├── consumer/
│   ├── contracts/
│   ├── schemas/
│   └── utils/
├── examples/
│   ├── web2-game-server.ts
│   ├── onchain-game.sol
│   ├── prediction-market.ts
│   └── tournament-batch.ts
├── docs/
│   ├── getting-started.md
│   ├── api-reference.md
│   └── examples.md
└── tests/
    ├── developer.test.ts
    ├── consumer.test.ts
    └── integration.test.ts
```

---

## 🎯 Implementation Priority

### Phase 1: Core SDK (Week 1)
- ✅ JavaScript/TypeScript SDK
- ✅ Contract ABIs and types
- ✅ Developer functions (register, submit, withdraw)
- ✅ Consumer functions (deposit, query, withdraw)
- ✅ Schema encoders

### Phase 2: DX Improvements (Week 2)
- ✅ Error handling
- ✅ Type generation
- ✅ Caching layer
- ✅ Event subscriptions
- ✅ Comprehensive examples

### Phase 3: Additional Languages (Week 3-4)
- ✅ Python SDK
- ✅ Go SDK
- ✅ Documentation
- ✅ CI/CD for publishing

---

## 📖 Documentation Site

**docs.predictbnb.com**
- Getting Started
- API Reference (auto-generated from TypeScript)
- Code Examples (20+ examples)
- Migration Guides
- Best Practices
- FAQ

---

## ✅ Summary

**Yes, you need an SDK because:**

1. **Web2 Games** (90% of market) need easy integration
2. **Developer Experience** - Even Web3 devs want convenience
3. **Multiple Languages** - Support all major platforms
4. **Abstraction** - Hide complexity of contract interactions
5. **Type Safety** - Prevent integration errors
6. **Faster Adoption** - 5-minute integration vs hours

**SDK makes PredictBNB accessible to EVERYONE, not just blockchain experts.**

This is how you capture the entire gaming market! 🚀
