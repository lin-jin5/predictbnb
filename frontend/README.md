# PredictBNB Frontend

> High-energy gaming oracle frontend built with Next.js 15, inspired by reactive.network

## 🎨 Design System

### Color Palette
- **Primary**: #00D9FF (Electric Blue)
- **Secondary**: #FF00FF (Neon Magenta)
- **Accent**: #00FF88 (Money Green)
- **Warning**: #FFD700 (Gold)
- **Dark BG**: #0A0E27 (Deep Space Blue)

### Typography
- **Headings**: Inter (Bold, 700)
- **Body**: Inter (Regular, 400)
- **Numbers/Code**: Space Mono (Monospace)

## 🚀 Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Animations**: Framer Motion
- **Charts**: Recharts
- **Web3**: wagmi + RainbowKit + ethers.js
- **State**: Zustand
- **Icons**: Lucide React

## 📁 Project Structure

```
frontend/
├── app/
│   ├── layout.tsx          # Root layout with navbar
│   ├── page.tsx            # Landing page (COMPLETE)
│   ├── globals.css         # Global styles & gaming theme
│   ├── providers.tsx       # Web3 providers (wagmi/RainbowKit)
│   ├── dashboard/          # Dashboard (TODO)
│   ├── games/              # Games marketplace (TODO)
│   └── analytics/          # Analytics page (TODO)
├── components/
│   ├── Navbar.tsx          # Navigation with wallet connect
│   ├── CountUp.tsx         # Animated counter
│   ├── RevenueCalculator.tsx # Interactive calculator
│   └── LiveFeed.tsx        # Live activity feed
├── tailwind.config.ts      # Tailwind theme config
├── tsconfig.json           # TypeScript config
└── package.json            # Dependencies
```

## 🎯 Pages

### ✅ Landing Page (`/`)
**Status**: COMPLETE

**Sections**:
- Hero with animated background & live stats counters
- Interactive revenue calculator (drag sliders to see potential earnings)
- "How It Works" 3-step guide
- "Why PredictBNB?" feature grid
- Live activity feed (real-time earnings scrolling)
- CTA section

**Key Features**:
- Animated numbers with CountUp component
- Framer Motion animations
- Responsive design (mobile-first)
- Gaming theme with neon gradients

### ⏳ Dashboard (`/dashboard`)
**Status**: TODO

**For Game Developers**:
- Revenue overview (total earned, pending, query count)
- 30-day trend charts
- Your games list with stats
- Quick actions (submit result, batch submit, withdraw)

**For Prediction Markets**:
- Prepaid balance display
- Usage stats (free queries, total spent)
- Deposit calculator with bonus preview
- Query history

### ⏳ Games Marketplace (`/games`)
**Status**: TODO

- Browse all games (grid layout)
- Filter by type (Esports, Onchain, Web2)
- Search functionality
- Game cards showing:
  - Query volume
  - Reputation score
  - Schema type
  - Cost per query

### ⏳ Analytics (`/analytics`)
**Status**: TODO

- Public protocol metrics
- Total volume & developer earnings
- Growth charts (daily queries, volume trends)
- Leaderboards:
  - Top earning developers
  - Most queried games

## 🛠️ Installation

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local

# Add to .env.local:
# NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id
# NEXT_PUBLIC_CONTRACT_ADDRESS=deployed_contract_address

# Run development server
npm run dev

# Open http://localhost:3000
```

## 📦 Build & Deploy

```bash
# Build for production
npm run build

# Start production server
npm start

# Or deploy to Vercel (recommended)
# Connect your GitHub repo to Vercel
# Auto-deploys on push to main branch
```

## 🎨 Design Inspiration

Inspired by **reactive.network**:
- Clean, modern aesthetic
- Bold typography
- Strategic use of gradients
- Animated micro-interactions
- Dark theme with neon accents
- High contrast for readability

## 🔥 Key Components

### RevenueCalculator
Interactive widget where users can:
- Select game type (Esports, Onchain, Mobile, Web2)
- Adjust daily matches (slider 10-10,000)
- Adjust queries per match (slider 10-1,000)
- See real-time revenue calculations
- Monthly & yearly projections

### LiveFeed
Real-time activity stream showing:
- Developer earnings
- New queries
- Game registrations
- Withdrawals
Updates every 5 seconds with smooth animations

### CountUp
Animated number counter:
- Counts from 0 to target
- Configurable duration
- Supports decimals & separators
- Used for hero stats

### Navbar
Responsive navigation with:
- Logo with gradient effect
- Links to all pages
- RainbowKit wallet connect button
- Mobile hamburger menu

## 🌈 Gradient System

```css
/* Primary gradient (Blue to Magenta) */
background: linear-gradient(135deg, #00D9FF 0%, #FF00FF 100%);

/* Money gradient (Green to Blue) */
background: linear-gradient(135deg, #00FF88 0%, #00D9FF 100%);

/* Text gradient */
.gradient-text {
  background: linear-gradient(135deg, #00D9FF 0%, #FF00FF 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
```

## 🎭 Animations

- **Pulse**: Slow pulsing for background blobs
- **Float**: Up/down floating effect
- **Glow**: Pulsing glow effect for cards
- **Fade-in**: Framer Motion opacity & y-axis transitions
- **Scale**: Hover scale transformations

## 🔗 Integration with Smart Contracts

### Contract Addresses (Update these!)
```typescript
// contracts/addresses.ts
export const CONTRACTS = {
  gameRegistry: '0x...', // GameRegistry.sol
  oracleCore: '0x...',   // OracleCore.sol
  feeManager: '0x...',   // FeeManager.sol
};
```

### ABIs
Place contract ABIs in `contracts/abis/` directory:
- GameRegistry.json
- OracleCore.json
- FeeManager.json

## 📱 Responsive Breakpoints

```
sm: 640px   # Small devices
md: 768px   # Medium devices (tablets)
lg: 1024px  # Large devices (desktops)
xl: 1280px  # Extra large devices
2xl: 1536px # 2X Extra large devices
```

## 🚧 Next Steps

1. **Complete Dashboard Page**
   - Developer view with revenue charts
   - Market view with balance management
   - Role detection (dev vs market)

2. **Complete Games Marketplace**
   - Grid layout with game cards
   - Filters (by type, reputation, etc.)
   - Search functionality
   - Game detail modal

3. **Complete Analytics Page**
   - Protocol-wide metrics
   - Recharts integration
   - Leaderboards
   - Export functionality

4. **Add Smart Contract Integration**
   - Read contract state
   - Write transactions (register, submit, query)
   - Event listeners
   - Transaction toasts/notifications

5. **Add Error Handling & Loading States**
   - Loading skeletons
   - Error boundaries
   - Toast notifications
   - Transaction pending states

6. **Optimize Performance**
   - Image optimization
   - Code splitting
   - Lazy loading
   - Bundle size analysis

7. **Add Testing**
   - Unit tests (Jest)
   - Integration tests
   - E2E tests (Playwright)

## 💡 Future Enhancements

- Mobile app (React Native)
- Email notifications
- Multilingual support
- Dark/Light mode toggle
- Advanced analytics filters
- Admin dashboard
- API documentation page

## 🎯 Success Metrics

Track these in analytics:
- Wallet connections
- Game registrations
- Revenue calculator usage
- Page views & time on site
- Conversion rates (visitor → user)

---

**Built with ❤️ for PredictBNB**

*Making gaming prediction markets faster, fairer, and more profitable for everyone.*
