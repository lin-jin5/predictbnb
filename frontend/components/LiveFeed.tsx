'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { DollarSign, Zap, Gamepad2, TrendingUp } from 'lucide-react';

interface Activity {
  id: string;
  type: 'earn' | 'query' | 'register' | 'withdraw';
  message: string;
  time: string;
  amount?: string;
  icon: React.ReactNode;
}

const generateMockActivities = (): Activity[] => {
  const developers = ['Developer Alpha', 'GameStudio X', 'Team Velocity', 'Esports Pro', 'IndieDev'];
  const games = ['CS:GO Finals', 'OnchainChess', 'Racing League', 'MOBA Championship', 'Battle Royale'];

  const activities: Activity[] = [];

  for (let i = 0; i < 5; i++) {
    const types: Activity['type'][] = ['earn', 'query', 'register', 'withdraw'];
    const type = types[Math.floor(Math.random() * types.length)];
    const dev = developers[Math.floor(Math.random() * developers.length)];
    const game = games[Math.floor(Math.random() * games.length)];
    const amount = Math.floor(Math.random() * 10000) + 100;
    const queries = Math.floor(Math.random() * 500) + 10;

    let message = '';
    let icon: React.ReactNode = null;

    switch (type) {
      case 'earn':
        message = `${dev} earned $${amount.toLocaleString()} from ${queries} queries`;
        icon = <DollarSign className="w-5 h-5 text-accent" />;
        break;
      case 'query':
        message = `${queries} queries to ${game}`;
        icon = <Zap className="w-5 h-5 text-primary" />;
        break;
      case 'register':
        message = `New game registered: "${game}"`;
        icon = <Gamepad2 className="w-5 h-5 text-secondary" />;
        break;
      case 'withdraw':
        message = `${dev} withdrew $${amount.toLocaleString()}`;
        icon = <TrendingUp className="w-5 h-5 text-warning" />;
        break;
    }

    activities.push({
      id: `${Date.now()}-${i}`,
      type,
      message,
      time: `${Math.floor(Math.random() * 60)}s ago`,
      amount: type === 'earn' || type === 'withdraw' ? `$${amount.toLocaleString()}` : undefined,
      icon,
    });
  }

  return activities;
};

export default function LiveFeed() {
  const [activities, setActivities] = useState<Activity[]>(generateMockActivities());

  useEffect(() => {
    const interval = setInterval(() => {
      const newActivity = generateMockActivities()[0];
      setActivities((prev) => [newActivity, ...prev.slice(0, 4)]);
    }, 5000); // New activity every 5 seconds

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="max-w-3xl mx-auto">
      <div className="card p-6">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-xl font-bold">Recent Activity</h3>
          <div className="flex items-center space-x-2">
            <div className="w-2 h-2 bg-accent rounded-full animate-pulse" />
            <span className="text-sm text-text-secondary">Live</span>
          </div>
        </div>

        <div className="space-y-3">
          <AnimatePresence mode="popLayout">
            {activities.map((activity) => (
              <motion.div
                key={activity.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                transition={{ duration: 0.3 }}
                className="flex items-center justify-between p-4 bg-dark-hover rounded-lg hover:bg-dark-card transition-colors border border-transparent hover:border-primary/30"
              >
                <div className="flex items-center space-x-3 flex-1">
                  <div className="flex-shrink-0">{activity.icon}</div>
                  <p className="text-sm text-text-secondary flex-1">
                    {activity.message}
                  </p>
                </div>
                <div className="flex items-center space-x-4">
                  {activity.amount && (
                    <span className="font-mono text-accent font-semibold">
                      {activity.amount}
                    </span>
                  )}
                  <span className="text-xs text-text-muted whitespace-nowrap">
                    {activity.time}
                  </span>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}
