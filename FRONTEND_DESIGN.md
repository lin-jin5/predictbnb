# PredictBNB - Frontend Design & Architecture

## 🎯 Design Philosophy

**Energy**: Bold, fast, gaming-focused, money-making vibe
**Audience**: Game developers hungry for revenue + Prediction market operators
**Key Message**: "Turn your game data into MILLIONS"

---

## 🏠 Website Structure

### 1. Landing Page (/)

**Hero Section** (Full viewport, animated gradient background)
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│        TURN YOUR GAME DATA INTO $72 MILLION/MONTH          │
│                                                             │
│     The Gaming Oracle Built for Esports & Prediction Markets│
│                                                             │
│   [Launch Dashboard]  [See Revenue Calculator]             │
│                                                             │
│   Live Stats Counter:                                       │
│   💰 $XX,XXX,XXX Earned by Developers                      │
│   ⚡ XX,XXX Queries Today                                   │
│   🎮 XXX Games Integrated                                   │
└─────────────────────────────────────────────────────────────┘
```

**Problem/Solution Section**
```
┌─────────────────────────────────────────────────────────────┐
│                    WHY PREDICTBNB?                          │
│                                                             │
│  ❌ Traditional Oracles:          ✅ PredictBNB:           │
│  • 24-48 hour resolution          • 15-minute resolution    │
│  • $0 for game developers         • $1.44 per query        │
│  • Generic data                   • Gaming-specific         │
│  • High gas fees                  • 99% gas savings         │
└─────────────────────────────────────────────────────────────┘
```

**Revenue Calculator (Interactive Widget)**
```
┌─────────────────────────────────────────────────────────────┐
│              💰 CALCULATE YOUR POTENTIAL REVENUE            │
│                                                             │
│  Your Game Type:  [Dropdown: Esports/Onchain/Mobile]       │
│  Daily Matches:   [Slider: 10 ──────●──── 10,000]         │
│  Queries/Match:   [Slider: 10 ──●────────── 1,000]        │
│                                                             │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                             │
│        YOUR MONTHLY REVENUE: $1,440,000                     │
│                                                             │
│  [Register Your Game] [View Full Breakdown]                │
└─────────────────────────────────────────────────────────────┘
```

**How It Works (3-Step Visual)**
```
┌─────────────────────────────────────────────────────────────┐
│                      HOW IT WORKS                           │
│                                                             │
│   1️⃣ REGISTER          2️⃣ SUBMIT            3️⃣ EARN        │
│   Your Game           Match Results          $1.44/Query    │
│   (0.1 BNB stake)     (Auto or Manual)      (80% revenue)  │
│                                                             │
│   [See Integration Guide]                                   │
└─────────────────────────────────────────────────────────────┘
```

**For Developers Section**
```
┌─────────────────────────────────────────────────────────────┐
│                  FOR GAME DEVELOPERS                         │
│                                                             │
│  🎮 ONCHAIN GAMES                                           │
│     Auto-submit results → Earn passive income               │
│     Example: 200 matches/day = $350,000/month              │
│                                                             │
│  🏆 ESPORTS TITLES                                          │
│     Manual or API integration                               │
│     Example: 5,000 matches/day = $60M/month                │
│                                                             │
│  📱 WEB2 GAMES                                              │
│     Simple SDK integration                                  │
│     Example: 1,000 matches/day = $4M/month                 │
│                                                             │
│  [Explore SDK] [View Templates] [Read Docs]                │
└─────────────────────────────────────────────────────────────┘
```

**For Prediction Markets Section**
```
┌─────────────────────────────────────────────────────────────┐
│                FOR PREDICTION MARKETS                        │
│                                                             │
│  ⚡ 96x FASTER than traditional oracles (15 min vs 48 hrs) │
│  💰 VOLUME DISCOUNTS: 5-15% bonus on deposits              │
│  🆓 FREE TIER: 50 queries/day for testing                  │
│  ⛽ GAS SAVINGS: 99% cheaper with prepaid balance           │
│                                                             │
│  Deposit 100 BNB → Get 115 BNB credit → 38,333 queries     │
│                                                             │
│  [Start Querying] [View Pricing] [Integration Docs]        │
└─────────────────────────────────────────────────────────────┘
```

**Live Game Feed**
```
┌─────────────────────────────────────────────────────────────┐
│                    LIVE MATCHES                             │
│                                                             │
│  🎮 CS:GO Tournament Finals        15 queries    LIVE       │
│  ⚔️ OnchainChess #12345            3 queries     Finalized  │
│  🏎️ Racing League R12              28 queries    LIVE       │
│  🎯 MOBA Championship              142 queries   Finalized  │
│                                                             │
│  [View All Matches]                                         │
└─────────────────────────────────────────────────────────────┘
```

**Trust Indicators**
```
┌─────────────────────────────────────────────────────────────┐
│                  BUILT FOR BNB CHAIN                        │
│                                                             │
│  ✅ OpenZeppelin Contracts    ✅ 99% Gas Savings            │
│  ✅ Fast 15-min Resolution    ✅ Ready for Audit            │
│  ✅ YZi Labs Hackathon       ✅ 11,500+ Lines Tested       │
└─────────────────────────────────────────────────────────────┘
```

**CTA Footer**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│      READY TO MONETIZE YOUR GAME DATA?                      │
│                                                             │
│           [Launch Dashboard] [Read Docs]                    │
│                                                             │
│   Built with ❤️ for Gaming | Powered by BNB Chain          │
└─────────────────────────────────────────────────────────────┘
```

---

### 2. Dashboard (/dashboard)

**Game Developer Dashboard**
```
┌─────────────────────────────────────────────────────────────┐
│  DEVELOPER DASHBOARD                          [Your Wallet] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  💰 REVENUE OVERVIEW                                        │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Total Earned:     $1,440,000                      │    │
│  │  Pending Withdrawal: $14,400                       │    │
│  │  Total Queries:    1,000,000                       │    │
│  │  Avg Per Query:    $1.44                           │    │
│  │                                                     │    │
│  │  [Withdraw Revenue]                                │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  📊 QUERY TRENDS (Chart showing last 30 days)              │
│  [Interactive Line Chart: Queries vs Revenue]              │
│                                                             │
│  🎮 YOUR GAMES                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Game Name        Status    Queries   Revenue      │    │
│  │  ──────────────────────────────────────────────    │    │
│  │  CS:GO Finals     Active    500,000   $720,000    │    │
│  │  OnchainChess     Active    100,000   $144,000    │    │
│  │  Racing League    Active    400,000   $576,000    │    │
│  │                                                     │    │
│  │  [+ Register New Game]                             │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  📋 RECENT MATCHES                                          │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Match ID          Time      Queries   Status      │    │
│  │  ──────────────────────────────────────────────    │    │
│  │  #CS-123           2m ago    142       Finalized   │    │
│  │  #Chess-456        5m ago    3         Finalized   │    │
│  │  #Race-789         10m ago   28        Live        │    │
│  │                                                     │    │
│  │  [View All Matches]                                │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  🛠️ QUICK ACTIONS                                          │
│  [Submit Result] [Schedule Match] [Batch Submit]           │
└─────────────────────────────────────────────────────────────┘
```

**Prediction Market Dashboard**
```
┌─────────────────────────────────────────────────────────────┐
│  PREDICTION MARKET DASHBOARD              [Your Wallet]     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  💳 BALANCE OVERVIEW                                        │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Prepaid Balance:   115.5 BNB ($69,300)            │    │
│  │  Total Deposited:   100 BNB                        │    │
│  │  Bonus Received:    15 BNB (15% bonus!)            │    │
│  │  Queries Remaining: ~38,500                        │    │
│  │                                                     │    │
│  │  [Deposit More] [Withdraw Balance]                 │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  📊 USAGE STATS                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Total Queries:     12,500                         │    │
│  │  Free Queries Today: 23/50                         │    │
│  │  Avg Cost:          $1.57 (with bonus)             │    │
│  │  Total Spent:       $22,500                        │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  🔍 QUERY HISTORY                                           │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Game          Match ID       Time      Cost       │    │
│  │  ──────────────────────────────────────────────    │    │
│  │  CS:GO         #CS-123        2m ago    FREE       │    │
│  │  Chess         #Chess-456     5m ago    FREE       │    │
│  │  Racing        #Race-789      10m ago   $1.57      │    │
│  │                                                     │    │
│  │  [Export History]                                  │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  🛠️ QUICK ACTIONS                                          │
│  [Query Match] [Batch Query] [Browse Games]                │
└─────────────────────────────────────────────────────────────┘
```

---

### 3. Games Marketplace (/games)

```
┌─────────────────────────────────────────────────────────────┐
│  GAME MARKETPLACE                       [Search: ______]    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Filters: [All Games] [Esports] [Onchain] [Web2]          │
│          [Most Queried] [New] [Schema Type]                │
│                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐       │
│  │  🎮 CS:GO Finals    │  │  ⚔️ OnchainChess     │       │
│  │                     │  │                      │       │
│  │  Schema: FPS-PvP    │  │  Schema: Turn-Based  │       │
│  │  Queries: 500,000   │  │  Queries: 100,000    │       │
│  │  Reputation: ⭐⭐⭐⭐⭐ │  │  Reputation: ⭐⭐⭐⭐⭐  │       │
│  │  Cost: $1.57/query  │  │  Cost: $1.57/query   │       │
│  │                     │  │                      │       │
│  │  [View Details]     │  │  [View Details]      │       │
│  └──────────────────────┘  └──────────────────────┘       │
│                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐       │
│  │  🏎️ Racing League   │  │  🎯 MOBA Championship│       │
│  │  ...                │  │  ...                 │       │
│  └──────────────────────┘  └──────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

### 4. Documentation (/docs)

**Landing**
```
┌─────────────────────────────────────────────────────────────┐
│  DOCUMENTATION                                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📚 Getting Started                                         │
│     → Quick Start Guide                                     │
│     → Integration in 5 Minutes                              │
│     → SDK Installation                                      │
│                                                             │
│  🎮 For Game Developers                                     │
│     → Register Your Game                                    │
│     → Submit Results (Manual)                               │
│     → Submit Results (Onchain)                              │
│     → Submit Results (SDK)                                  │
│     → Batch Operations                                      │
│     → Schema Templates                                      │
│                                                             │
│  📊 For Prediction Markets                                  │
│     → Deposit Balance                                       │
│     → Query Results                                         │
│     → Volume Discounts                                      │
│     → Integration Examples                                  │
│                                                             │
│  🔧 SDK Reference                                           │
│     → JavaScript/TypeScript                                 │
│     → Python                                                │
│     → Go                                                    │
│                                                             │
│  📖 Smart Contracts                                         │
│     → Contract Addresses                                    │
│     → ABI Reference                                         │
│     → Events                                                │
│                                                             │
│  💡 Examples                                                │
│     → Onchain Game Integration                              │
│     → Esports Tournament                                    │
│     → Prediction Market                                     │
└─────────────────────────────────────────────────────────────┘
```

---

### 5. Analytics Page (/analytics)

**Public Analytics Dashboard**
```
┌─────────────────────────────────────────────────────────────┐
│  NETWORK ANALYTICS                                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📊 PROTOCOL METRICS (Last 30 Days)                         │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Total Queries:        10,000,000                  │    │
│  │  Total Volume:         $18,000,000                 │    │
│  │  Developer Earnings:   $14,400,000                 │    │
│  │  Active Games:         127                         │    │
│  │  Active Markets:       45                          │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  📈 GROWTH CHARTS                                           │
│  [Interactive Charts: Daily Queries, Volume, Games]        │
│                                                             │
│  🏆 TOP GAMES (By Query Volume)                            │
│  ┌────────────────────────────────────────────────────┐    │
│  │  1. CS:GO Finals        5,000,000 queries          │    │
│  │  2. LoL Championship    3,000,000 queries          │    │
│  │  3. OnchainChess        1,000,000 queries          │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  💰 TOP EARNERS (This Month)                               │
│  ┌────────────────────────────────────────────────────┐    │
│  │  1. Developer A         $7,200,000                 │    │
│  │  2. Developer B         $4,320,000                 │    │
│  │  3. Developer C         $1,440,000                 │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 Design System

### Color Palette (Gaming Energy Theme)

**Primary Colors:**
```
Primary:    #00D9FF (Electric Blue)
Secondary:  #FF00FF (Neon Magenta)
Accent:     #00FF88 (Money Green)
Warning:    #FFD700 (Gold)
```

**Backgrounds:**
```
Dark:       #0A0E27 (Deep Space Blue)
Card:       #1A1F3A (Dark Blue Card)
Hover:      #252B4D (Lighter Blue)
```

**Text:**
```
Primary:    #FFFFFF (White)
Secondary:  #B8BFCF (Light Gray)
Muted:      #6B7280 (Muted Gray)
```

### Typography

```
Headings:  'Inter', 'SF Pro Display', sans-serif (Bold, 700)
Body:      'Inter', sans-serif (Regular, 400)
Code:      'Fira Code', 'Courier New', monospace
Numbers:   'Space Mono', monospace (for $$ amounts)
```

### Components

**Buttons:**
```css
.btn-primary {
  background: linear-gradient(135deg, #00D9FF 0%, #FF00FF 100%);
  padding: 16px 32px;
  border-radius: 12px;
  font-weight: 700;
  box-shadow: 0 8px 24px rgba(0, 217, 255, 0.3);
  transition: transform 0.2s, box-shadow 0.2s;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 32px rgba(0, 217, 255, 0.5);
}
```

**Cards:**
```css
.card {
  background: #1A1F3A;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  padding: 24px;
  backdrop-filter: blur(10px);
}
```

**Revenue Numbers:**
```css
.revenue {
  font-family: 'Space Mono', monospace;
  font-size: 48px;
  font-weight: 700;
  background: linear-gradient(135deg, #00FF88 0%, #00D9FF 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: pulse 2s ease-in-out infinite;
}
```

---

## 🔥 High-Energy Elements

### 1. Animated Stats Counter
```jsx
// Real-time counter animating upwards
<CountUp
  start={0}
  end={72000000}
  duration={3}
  separator=","
  prefix="$"
  suffix="/month"
/>
```

### 2. Live Activity Feed
```jsx
// Shows recent queries in real-time
🔥 Developer X just earned $144 from 100 queries!
⚡ New game registered: "OnchainPoker"
💰 $1,440 withdrawn by Developer Y
```

### 3. Particle Background
```jsx
// Animated particles on hero section
<Particles
  params={{
    particles: {
      color: { value: "#00D9FF" },
      move: { speed: 1 }
    }
  }}
/>
```

### 4. Glow Effects
```css
.glow {
  box-shadow:
    0 0 10px rgba(0, 217, 255, 0.5),
    0 0 20px rgba(0, 217, 255, 0.3),
    0 0 30px rgba(0, 217, 255, 0.1);
}
```

---

## 📱 Mobile Responsive

All components stack vertically on mobile with touch-optimized interactions:
- Swipeable cards
- Bottom navigation
- Simplified dashboard layouts
- Touch-friendly buttons (min 44px height)

---

## 🚀 Tech Stack Recommendation

### Frontend Framework
```
React + Next.js 14 (App Router)
- Server-side rendering for SEO
- API routes for backend
- Image optimization
- Fast page loads
```

### UI Libraries
```
- Tailwind CSS (styling)
- Framer Motion (animations)
- Recharts (charts/graphs)
- React Query (data fetching)
- Zustand (state management)
```

### Web3 Integration
```
- ethers.js or viem
- wagmi (React hooks for Ethereum)
- RainbowKit (wallet connection)
- PredictBNB SDK (custom)
```

### Backend
```
- Next.js API routes
- PostgreSQL (user data, analytics)
- Redis (caching)
- The Graph (blockchain indexing)
```

---

## 🎯 Key Features Priority

### MVP (Must Have - Week 1-2)
1. ✅ Landing page with calculator
2. ✅ Wallet connection (RainbowKit)
3. ✅ Developer dashboard (register game, view revenue)
4. ✅ Market dashboard (deposit, query, balance)
5. ✅ Basic documentation

### V1.1 (Should Have - Week 3-4)
1. ✅ Games marketplace
2. ✅ Analytics dashboard
3. ✅ Live activity feed
4. ✅ SDK documentation
5. ✅ Search & filters

### V1.2 (Nice to Have - Week 5-6)
1. ✅ Advanced charts/analytics
2. ✅ Email notifications
3. ✅ Mobile app (React Native)
4. ✅ Admin panel
5. ✅ Multilingual support

---

## 🎨 Marketing Copy Examples

### Hero Headlines (Rotate/AB Test)
1. "Turn Your Game Data Into $72 Million Per Month"
2. "The Gaming Oracle That Pays Developers"
3. "15-Minute Oracle Resolution. 99% Gas Savings. Millions in Revenue."
4. "Stop Giving Away Free Data. Start Earning $1.44 Per Query."
5. "96x Faster Than UMA. Infinitely More Profitable."

### CTAs (Buttons)
- "Start Earning Today" (Developer focus)
- "Calculate My Revenue" (Interactive)
- "Launch Dashboard" (General)
- "Get 15% Bonus" (Market focus)
- "Integrate in 5 Minutes" (Developer focus)

### Social Proof
- "Join 127+ games earning millions"
- "Trusted by top esports platforms"
- "10M+ queries processed"
- "$14M+ paid to developers"

---

This design creates a **high-energy, revenue-focused experience** that immediately shows value to both game developers (MONEY!) and prediction markets (SPEED + SAVINGS!).

Would you like me to create the SDK specification next?
