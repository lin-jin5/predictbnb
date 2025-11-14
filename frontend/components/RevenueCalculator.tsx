'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { DollarSign, TrendingUp } from 'lucide-react';
import Link from 'next/link';

const gameTypes = [
  { value: 'esports', label: 'Esports/Competitive', queriesPerMatch: 300 },
  { value: 'onchain', label: 'Onchain Game', queriesPerMatch: 50 },
  { value: 'mobile', label: 'Mobile Game', queriesPerMatch: 30 },
  { value: 'web2', label: 'Web2 Multiplayer', queriesPerMatch: 150 },
];

export default function RevenueCalculator() {
  const [gameType, setGameType] = useState(gameTypes[0]);
  const [dailyMatches, setDailyMatches] = useState(500);
  const [queriesPerMatch, setQueriesPerMatch] = useState(gameTypes[0].queriesPerMatch);

  const monthlyQueries = dailyMatches * queriesPerMatch * 30;
  const revenuePerQuery = 1.44; // $1.44 per query
  const monthlyRevenue = Math.round(monthlyQueries * revenuePerQuery);
  const yearlyRevenue = monthlyRevenue * 12;

  const handleGameTypeChange = (type: typeof gameTypes[0]) => {
    setGameType(type);
    setQueriesPerMatch(type.queriesPerMatch);
  };

  return (
    <div className="max-w-4xl mx-auto">
      <div className="card glow-box p-8 md:p-12">
        {/* Game Type Selection */}
        <div className="mb-8">
          <label className="block text-sm font-medium text-text-secondary mb-3">
            Your Game Type
          </label>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            {gameTypes.map((type) => (
              <button
                key={type.value}
                onClick={() => handleGameTypeChange(type)}
                className={`px-4 py-3 rounded-lg font-medium transition-all ${
                  gameType.value === type.value
                    ? 'bg-gradient-primary text-white'
                    : 'bg-dark-hover text-text-secondary hover:text-white border border-white/10'
                }`}
              >
                {type.label}
              </button>
            ))}
          </div>
        </div>

        {/* Daily Matches Slider */}
        <div className="mb-8">
          <div className="flex justify-between items-center mb-3">
            <label className="text-sm font-medium text-text-secondary">
              Daily Matches
            </label>
            <span className="text-xl font-mono text-primary">
              {dailyMatches.toLocaleString()}
            </span>
          </div>
          <input
            type="range"
            min="10"
            max="10000"
            step="10"
            value={dailyMatches}
            onChange={(e) => setDailyMatches(Number(e.target.value))}
            className="w-full h-2 bg-dark-hover rounded-lg appearance-none cursor-pointer slider"
          />
          <div className="flex justify-between text-xs text-text-muted mt-2">
            <span>10</span>
            <span>10,000</span>
          </div>
        </div>

        {/* Queries Per Match Slider */}
        <div className="mb-10">
          <div className="flex justify-between items-center mb-3">
            <label className="text-sm font-medium text-text-secondary">
              Queries Per Match (Average)
            </label>
            <span className="text-xl font-mono text-primary">
              {queriesPerMatch.toLocaleString()}
            </span>
          </div>
          <input
            type="range"
            min="10"
            max="1000"
            step="10"
            value={queriesPerMatch}
            onChange={(e) => setQueriesPerMatch(Number(e.target.value))}
            className="w-full h-2 bg-dark-hover rounded-lg appearance-none cursor-pointer slider"
          />
          <div className="flex justify-between text-xs text-text-muted mt-2">
            <span>10</span>
            <span>1,000</span>
          </div>
        </div>

        {/* Results */}
        <motion.div
          key={monthlyRevenue}
          initial={{ scale: 0.95, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.3 }}
          className="bg-dark-hover rounded-2xl p-8 border-2 border-primary/50"
        >
          <div className="text-center mb-6">
            <p className="text-sm text-text-secondary uppercase tracking-wider mb-2">
              Your Monthly Revenue
            </p>
            <div className="text-6xl md:text-7xl font-mono font-bold bg-gradient-money bg-clip-text text-transparent">
              ${monthlyRevenue.toLocaleString()}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-6 mb-8">
            <div className="text-center p-4 bg-dark-card rounded-xl">
              <p className="text-sm text-text-muted mb-1">Monthly Queries</p>
              <p className="text-2xl font-mono text-primary">
                {monthlyQueries.toLocaleString()}
              </p>
            </div>
            <div className="text-center p-4 bg-dark-card rounded-xl">
              <p className="text-sm text-text-muted mb-1">Yearly Revenue</p>
              <p className="text-2xl font-mono text-accent">
                ${yearlyRevenue.toLocaleString()}
              </p>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-4">
            <Link
              href="/dashboard"
              className="flex-1 bg-gradient-primary text-white font-bold py-4 px-6 rounded-xl text-center hover:scale-105 transition-transform flex items-center justify-center"
            >
              <DollarSign className="w-5 h-5 mr-2" />
              Register Your Game
            </Link>
            <Link
              href="/games"
              className="flex-1 bg-dark-card border-2 border-primary text-primary font-bold py-4 px-6 rounded-xl text-center hover:scale-105 transition-transform flex items-center justify-center"
            >
              <TrendingUp className="w-5 h-5 mr-2" />
              View Full Breakdown
            </Link>
          </div>
        </motion.div>

        {/* Fine Print */}
        <p className="text-xs text-text-muted text-center mt-6">
          * Based on $1.44 per query (80% of $1.80 fee). Actual revenue depends on query volume.
          Popular games earn more with our usage-based model!
        </p>
      </div>

      <style jsx>{`
        .slider::-webkit-slider-thumb {
          appearance: none;
          width: 20px;
          height: 20px;
          border-radius: 50%;
          background: linear-gradient(135deg, #00D9FF 0%, #FF00FF 100%);
          cursor: pointer;
          box-shadow: 0 0 10px rgba(0, 217, 255, 0.5);
        }

        .slider::-moz-range-thumb {
          width: 20px;
          height: 20px;
          border-radius: 50%;
          background: linear-gradient(135deg, #00D9FF 0%, #FF00FF 100%);
          cursor: pointer;
          border: none;
          box-shadow: 0 0 10px rgba(0, 217, 255, 0.5);
        }
      `}</style>
    </div>
  );
}
