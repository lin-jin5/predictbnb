# PredictBNB - Prepaid Balance Model (V3)

## Overview

**The prepaid balance model is the ultimate evolution of PredictBNB's fee structure**, designed to:

1. ✅ **Reward data providers based on actual usage** - Game developers earn per query, not per subscription
2. ✅ **Gas efficient** - One deposit, unlimited queries without per-transaction gas fees
3. ✅ **Volume incentives** - Larger deposits get bonus credits (5-15%)
4. ✅ **Flexible budgeting** - No monthly commitments, pay as you go
5. ✅ **Fair distribution** - Popular games earn more, unpopular games earn less

---

## How It Works

### For Prediction Markets (Data Consumers)

**Step 1: Register**
```solidity
feeManager.registerConsumer();
```

**Step 2: Deposit Funds with Volume Bonus**
```solidity
// Deposit 50 BNB, receive 55 BNB credit (10% bonus)
feeManager.depositBalance{value: 50 ether}();
```

**Step 3: Query Results**
```solidity
// Queries automatically deduct from your balance
(resultData, resultHash, isFinalized) = feeManager.queryResult(matchId);
// Cost: 0.003 BNB deducted from balance (after 50 free queries/day)
```

**Step 4: Withdraw Unused Balance (Optional)**
```solidity
// Get refund of unused balance
feeManager.withdrawBalance(amount);
```

---

## Volume Discount Tiers

Larger deposits receive bonus credits to incentivize commitment:

| Deposit Amount | Bonus | Total Credit | Effective Discount | Queries Enabled |
|----------------|-------|--------------|-------------------|-----------------|
| 1-9.99 BNB | 0% | Deposit amount | $0 | 333-3,333 queries |
| **10-49.99 BNB** | **5%** | Deposit × 1.05 | **~4.8%** | 3,500-17,499 queries |
| **50-99.99 BNB** | **10%** | Deposit × 1.10 | **~9.1%** | 18,333-36,666 queries |
| **100+ BNB** | **15%** | Deposit × 1.15 | **~13%** | 38,333+ queries |

### Examples:

**Small Prediction Market:**
- Deposit: 10 BNB ($6,000)
- Bonus: 0.5 BNB ($300)
- Total Credit: 10.5 BNB
- Queries: 3,500 queries @ $1.80 each
- Effective Cost: $1.71 per query (5% savings)

**Medium Prediction Market:**
- Deposit: 50 BNB ($30,000)
- Bonus: 5 BNB ($3,000)
- Total Credit: 55 BNB
- Queries: 18,333 queries @ $1.80 each
- Effective Cost: $1.64 per query (10% savings)

**Large Prediction Market:**
- Deposit: 100 BNB ($60,000)
- Bonus: 15 BNB ($9,000)
- Total Credit: 115 BNB
- Queries: 38,333 queries @ $1.80 each
- Effective Cost: $1.57 per query (15% savings)

---

## Data Provider Revenue (Usage-Based)

**KEY INNOVATION**: Game developers earn based on how much their data is actually used, not subscriptions.

### Revenue Distribution Per Query

```
Each Query: 0.003 BNB ($1.80)
├── 80% (0.0024 BNB = $1.44) → Game Developer (whose match was queried)
├── 15% (0.00045 BNB = $0.27) → Protocol Treasury
└── 5% (0.00015 BNB = $0.09) → Disputer Pool
```

### Example Scenarios:

**Popular Esports Game (High Usage)**
- Monthly Queries: 5,000,000
- Game Developer Revenue: 5M × $1.44 = **$7,200,000/month** 💰💰💰
- **Why**: High-quality, popular data gets rewarded heavily

**Mid-Tier Game (Moderate Usage)**
- Monthly Queries: 500,000
- Game Developer Revenue: 500k × $1.44 = **$720,000/month** 💰💰
- **Why**: Decent following = decent revenue

**Niche Game (Low Usage)**
- Monthly Queries: 10,000
- Game Developer Revenue: 10k × $1.44 = **$14,400/month** 💰
- **Why**: Small audience = proportional revenue

**Unpopular/New Game (Very Low Usage)**
- Monthly Queries: 1,000
- Game Developer Revenue: 1k × $1.44 = **$1,440/month**
- **Why**: Fair - developers only earn when data is actually valuable

---

## Why This Model is Superior

### Problem with Subscription Model (V2):

❌ **Unfair to game developers**: A game with 1M queries and a game with 10 queries both got equal share of subscription revenue
❌ **No usage incentive**: Popular games subsidized unpopular games
❌ **Hard to predict revenue**: Developers didn't know how much they'd earn
❌ **All-or-nothing**: Users paid for unlimited queries even if they needed 100

### Solution with Prepaid Balance Model (V3):

✅ **Fair to game developers**: Revenue directly tied to how valuable your data is
✅ **Usage incentive**: Make better games → More queries → More revenue
✅ **Predictable revenue**: $1.44 per query, simple calculation
✅ **Flexible for users**: Deposit what you need, withdraw the rest
✅ **Volume discounts**: Encourages larger commitments without subscription lock-in
✅ **Gas efficient**: One deposit for thousands of queries

---

## Benefits for Each Stakeholder

### Game Developers (Data Providers)

1. **Direct Correlation**: More popular game = More revenue (as it should be!)
2. **Motivation**: Incentivized to provide high-quality, accurate data
3. **Scalability**: Revenue grows with usage without any action needed
4. **Predictable**: $1.44 per query × expected queries = easy math
5. **Passive Income**: Onchain games auto-submit and earn automatically

**Revenue Formula:**
```
Monthly Revenue = Monthly Queries × $1.44
```

**Examples:**
- 10,000 queries: $14,400/month
- 100,000 queries: $144,000/month
- 1,000,000 queries: $1,440,000/month
- 10,000,000 queries: $14,400,000/month

### Prediction Markets (Data Consumers)

1. **Pay for what you use**: Only charged for queries you make (after 50 free/day)
2. **Volume discounts**: Deposit more, save more (up to 15%)
3. **Gas efficiency**: One deposit, no per-query gas fees
4. **Flexibility**: No monthly commitment, withdraw unused funds
5. **Predictable costs**: $1.57-$1.80 per query depending on deposit size
6. **Free tier**: 50 queries/day for testing and small markets

### Protocol

1. **Sustainable revenue**: 15% of all query fees
2. **Aligned incentives**: Protocol grows as usage grows
3. **Simple economics**: Easy to explain and understand
4. **Scalable**: Revenue increases with network effect

---

## Free Tier

**All users get 50 free queries per day** to encourage adoption and testing.

- **Resets**: Every 24 hours
- **Purpose**: Testing, small markets, research, onboarding
- **After free tier**: Queries deduct from prepaid balance

**Monthly free queries**: 1,500 (50/day × 30 days)

---

## Gas Cost Comparison

### Traditional Pay-Per-Query (No Prepaid)
```
100 queries = 100 transactions × ~45,000 gas = 4,500,000 gas
Cost @ 5 gwei: 0.0225 BNB ($13.50) just in gas fees
```

### Prepaid Balance Model
```
1 deposit + 100 queries = 1 transaction + 0 gas per query
Deposit gas: ~120,000 gas
Cost @ 5 gwei: 0.0006 BNB ($0.36) in gas fees
Savings: $13.14 (97% gas savings!)
```

**For high-volume users, this is massive.**

---

## Economic Model Analysis

### Market Equilibrium

**Supply Side (Game Developers):**
- Incentivized to provide accurate data to avoid disputes
- Popular games earn millions, encouraging more quality games
- Onchain games get passive income stream

**Demand Side (Prediction Markets):**
- Free tier for testing
- Volume discounts encourage larger deposits
- Predictable per-query costs
- Gas efficient

**Protocol:**
- 15% fee provides sustainable revenue for operations
- Disputer pool (5%) ensures data quality

### Revenue Projections at Scale

**Conservative (Year 1):**
- Total monthly queries: 10M
- Monthly GMV: $18M (10M × $1.80)
- Game developer revenue: $14.4M (80%)
- Protocol treasury: $2.7M (15%)
- Disputer pool: $900k (5%)

**Moderate (Year 2):**
- Total monthly queries: 100M
- Monthly GMV: $180M
- Game developer revenue: $144M (80%)
- Protocol treasury: $27M (15%)
- Disputer pool: $9M (5%)

**Optimistic (Year 3+):**
- Total monthly queries: 1B
- Monthly GMV: $1.8B
- Game developer revenue: $1.44B (80%)
- Protocol treasury: $270M (15%)
- Disputer pool: $90M (5%)

---

## Implementation Details

### Smart Contract Functions

**For Consumers:**
```solidity
// Register
function registerConsumer() external

// Deposit with automatic bonus calculation
function depositBalance() external payable

// Withdraw unused balance
function withdrawBalance(uint256 _amount) external

// Query (deducts from balance)
function queryResult(bytes32 _matchId) external returns (...)

// Batch query (gas efficient)
function batchQueryResults(bytes32[] _matchIds) external returns (...)

// View functions
function getConsumerBalance(address _consumer) external view returns (uint256)
function getRemainingFreeQueries(address _consumer) external view returns (uint256)
function calculateDepositBonus(uint256 _amount) external pure returns (uint256)
```

**For Game Developers:**
```solidity
// Withdraw earned revenue
function withdrawRevenue() external

// View functions
function getDeveloperRevenue(address _developer) external view returns (...)
function getGameQueryCount(string _gameId) external view returns (uint256)
```

### Security Features

1. **ReentrancyGuard**: Protects all financial functions
2. **Balance checks**: Cannot query without sufficient balance
3. **Automatic distribution**: Revenue distributed per query, not manually
4. **Withdrawal controls**: Developers withdraw anytime, no lock-up
5. **Audit trail**: All events logged for transparency

---

## Migration from V2 to V3

**Changes:**
- ❌ Removed: Subscription tiers (Free, Premium, Enterprise)
- ❌ Removed: Monthly subscription fees
- ✅ Added: Prepaid balance system with deposits/withdrawals
- ✅ Added: Volume bonus tiers (5%, 10%, 15%)
- ✅ Improved: Revenue distribution based on actual usage
- ✅ Enhanced: Gas efficiency (no per-query transactions)

**Benefits:**
- Game developers earn based on popularity (fair!)
- Users save gas and get volume discounts
- No monthly commitments
- More flexible and scalable

---

## Competitive Advantage

| Feature | PredictBNB V3 | Chainlink | UMA | Web2 APIs |
|---------|---------------|-----------|-----|-----------|
| **Usage-Based Rewards** | ✅ Yes | ❌ No | ❌ No | ❌ No |
| **Volume Discounts** | ✅ 5-15% | ❌ No | ❌ No | ✅ Yes |
| **Gas Efficiency** | ✅ Prepaid | ❌ Per-query | ❌ Per-query | ✅ Offchain |
| **Developer Revenue** | ✅ 80% per query | ❌ None | ❌ Varies | ❌ None |
| **Free Tier** | ✅ 50/day | ❌ No | ❌ No | ✅ Limited |
| **Resolution Speed** | ✅ 15 min | ⚠️ Real-time | ❌ 24-48h | ✅ Real-time |
| **Trustless** | ✅ On-chain | ✅ On-chain | ✅ On-chain | ❌ Trust needed |

**PredictBNB V3 combines the best of all worlds**: Trustless + Fast + Usage-based rewards + Gas efficient + Volume discounts

---

## User Journey Examples

### Example 1: Small Prediction Market

**Day 1**: Register and test with free tier (50 queries)
**Day 7**: Ready to scale, deposit 10 BNB
- Receives 10.5 BNB credit (5% bonus)
- Can make 3,500 paid queries
- Effective cost: $1.71/query (5% savings)

**Month 1**: Makes 2,000 queries (500 below budget)
- Remaining balance: 1.5 BNB
- Options: Keep for next month or withdraw

**Result**: Flexible, predictable, gas efficient

### Example 2: Large Esports Platform

**Day 1**: Register, test with free tier
**Week 1**: Deposit 100 BNB
- Receives 115 BNB credit (15% bonus = $9,000 savings!)
- Can make 38,333 paid queries
- Effective cost: $1.57/query (13% savings)

**Month 1**: Makes 30,000 queries
- Remaining balance: 25 BNB (worth ~8,300 more queries)
- Rolls over to next month

**Month 2**: Makes 40,000 queries total
- Burns through remaining balance
- Deposits another 100 BNB with 15% bonus

**Result**: Huge gas savings, volume discounts, predictable budgeting

### Example 3: Onchain Game (Data Provider)

**Day 1**: Register game, submit results automatically
**Month 1**: 10,000 queries to their matches
- Revenue: $14,400 (10k × $1.44)
- Withdraw anytime

**Month 6**: Game grows, 100,000 queries
- Revenue: $144,000/month
- Passive income from data monetization

**Year 2**: Major title, 1M queries/month
- Revenue: $1,440,000/month
- Game studio funded by data revenue

**Result**: Fair, usage-based revenue that scales with success

---

## FAQ

**Q: What happens to my balance when I withdraw?**
A: You can withdraw unused balance anytime. Only the original deposit is withdrawable, not bonus credits.

**Q: Do bonuses expire?**
A: No, both deposits and bonuses stay in your balance indefinitely.

**Q: Can I get a refund if I change my mind?**
A: Yes, unused balance can be withdrawn anytime via `withdrawBalance()`.

**Q: How do game developers get paid?**
A: Automatically! Each query distributes 80% of the fee to the game developer immediately. Developers withdraw their earnings via `withdrawRevenue()` anytime.

**Q: What if a game gets no queries?**
A: They earn $0 - this is fair. Data that's not used shouldn't be rewarded.

**Q: What if a game is super popular?**
A: They earn proportionally! 1M queries = $1.44M/month. This incentivizes quality.

**Q: Can I top up my balance?**
A: Yes! Call `depositBalance()` multiple times. Each deposit gets the volume bonus.

**Q: Is there a minimum deposit?**
A: No minimum, but deposits under 10 BNB don't get volume bonuses.

**Q: What's the max deposit?**
A: No maximum! Deposits over 100 BNB get the max 15% bonus.

**Q: How does this compare to subscriptions?**
A: Much better:
- Pay for what you use (not unlimited when you need 100)
- Volume discounts (5-15%)
- No monthly commitment
- Withdraw unused funds
- Gas efficient

---

## Summary

**PredictBNB V3 Prepaid Balance Model is the perfect fee structure for a gaming oracle:**

✅ **Fair**: Game developers earn based on how valuable their data is
✅ **Efficient**: One deposit, thousands of queries, minimal gas
✅ **Flexible**: No subscriptions, withdraw anytime
✅ **Incentivized**: Volume discounts encourage larger deposits
✅ **Scalable**: Works for tiny projects and massive platforms
✅ **Transparent**: Easy to understand and predict costs

**This model creates a thriving marketplace where quality data providers thrive and users get the best rates.**

---

*Document Version: 3.0*
*Date: November 2025*
*Model: Prepaid Balance with Usage-Based Revenue Distribution*
