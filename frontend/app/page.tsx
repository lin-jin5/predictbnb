'use client';

import { useState } from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import {
  Zap,
  DollarSign,
  TrendingUp,
  Shield,
  Clock,
  Users,
  ArrowRight,
  BarChart3,
  Gamepad2,
} from 'lucide-react';
import CountUp from '@/components/CountUp';
import RevenueCalculator from '@/components/RevenueCalculator';
import LiveFeed from '@/components/LiveFeed';

export default function HomePage() {
  return (
    <div className="pt-16">
      {/* Hero Section */}
      <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
        {/* Animated background */}
        <div className="absolute inset-0 -z-10">
          <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/20 rounded-full filter blur-3xl animate-pulse-slow" />
          <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-secondary/20 rounded-full filter blur-3xl animate-pulse-slow delay-1000" />
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <h1 className="text-5xl md:text-7xl font-bold mb-6 leading-tight">
              Turn Your Game Data Into
              <span className="block mt-2">
                <span className="gradient-text">
                  $72 MILLION
                </span>
                /MONTH
              </span>
            </h1>

            <p className="text-xl md:text-2xl text-text-secondary mb-12 max-w-3xl mx-auto">
              The Gaming Oracle Built for Esports & Prediction Markets
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center mb-16">
              <Link href="/dashboard" className="btn-primary inline-flex items-center justify-center">
                Launch Dashboard
                <ArrowRight className="ml-2 w-5 h-5" />
              </Link>
              <button className="btn-secondary inline-flex items-center justify-center">
                Calculate Revenue
                <DollarSign className="ml-2 w-5 h-5" />
              </button>
            </div>

            {/* Live Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-16">
              <div className="card-hover text-center p-8">
                <DollarSign className="w-12 h-12 text-accent mx-auto mb-4" />
                <div className="revenue-number text-4xl mb-2">
                  $<CountUp end={14400000} duration={3} />
                </div>
                <p className="text-text-secondary">Paid to Developers</p>
              </div>

              <div className="card-hover text-center p-8">
                <Zap className="w-12 h-12 text-primary mx-auto mb-4" />
                <div className="revenue-number text-4xl mb-2">
                  <CountUp end={10500000} duration={3} />
                </div>
                <p className="text-text-secondary">Queries Processed</p>
              </div>

              <div className="card-hover text-center p-8">
                <Gamepad2 className="w-12 h-12 text-secondary mx-auto mb-4" />
                <div className="revenue-number text-4xl mb-2">
                  <CountUp end={127} duration={2} />
                </div>
                <p className="text-text-secondary">Games Integrated</p>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Revenue Calculator Section */}
      <section className="py-24 bg-dark-card/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="section-title gradient-text">
              Calculate Your Potential Revenue
            </h2>
            <p className="text-xl text-text-secondary max-w-2xl mx-auto">
              See how much your game could earn with PredictBNB's usage-based model
            </p>
          </div>

          <RevenueCalculator />
        </div>
      </section>

      {/* How It Works */}
      <section className="py-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="section-title">How It Works</h2>
            <p className="text-xl text-text-secondary">
              Three simple steps to start earning
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ delay: 0 }}
              viewport={{ once: true }}
              className="card-hover text-center p-8"
            >
              <div className="w-16 h-16 bg-gradient-primary rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-6">
                1
              </div>
              <h3 className="text-2xl font-bold mb-4">Register Your Game</h3>
              <p className="text-text-secondary mb-4">
                Stake 0.1 BNB and register your game in seconds
              </p>
              <div className="text-sm text-accent font-mono">
                One-time setup
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              viewport={{ once: true }}
              className="card-hover text-center p-8"
            >
              <div className="w-16 h-16 bg-gradient-primary rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-6">
                2
              </div>
              <h3 className="text-2xl font-bold mb-4">Submit Results</h3>
              <p className="text-text-secondary mb-4">
                Auto-submit from onchain or use our SDK for Web2 games
              </p>
              <div className="text-sm text-accent font-mono">
                5-minute integration
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
              viewport={{ once: true }}
              className="card-hover text-center p-8"
            >
              <div className="w-16 h-16 bg-gradient-primary rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-6">
                3
              </div>
              <h3 className="text-2xl font-bold mb-4">Earn $1.44/Query</h3>
              <p className="text-text-secondary mb-4">
                Get paid automatically for every query to your game data
              </p>
              <div className="text-sm text-accent font-mono">
                Passive income
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Why PredictBNB */}
      <section className="py-24 bg-dark-card/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="section-title gradient-text">Why PredictBNB?</h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div className="card-hover p-6">
              <Clock className="w-12 h-12 text-primary mb-4" />
              <h3 className="text-xl font-bold mb-3">96x Faster</h3>
              <p className="text-text-secondary">
                15-minute resolution vs 24-48 hours for traditional oracles
              </p>
            </div>

            <div className="card-hover p-6">
              <DollarSign className="w-12 h-12 text-accent mb-4" />
              <h3 className="text-xl font-bold mb-3">Usage-Based Revenue</h3>
              <p className="text-text-secondary">
                Earn $1.44 per query to YOUR game. Popular games earn more!
              </p>
            </div>

            <div className="card-hover p-6">
              <TrendingUp className="w-12 h-12 text-secondary mb-4" />
              <h3 className="text-xl font-bold mb-3">99% Gas Savings</h3>
              <p className="text-text-secondary">
                Prepaid balance model eliminates per-query gas fees
              </p>
            </div>

            <div className="card-hover p-6">
              <Shield className="w-12 h-12 text-warning mb-4" />
              <h3 className="text-xl font-bold mb-3">Secure & Verified</h3>
              <p className="text-text-secondary">
                15-min dispute window with stake/slash mechanism
              </p>
            </div>

            <div className="card-hover p-6">
              <BarChart3 className="w-12 h-12 text-primary mb-4" />
              <h3 className="text-xl font-bold mb-3">Volume Bonuses</h3>
              <p className="text-text-secondary">
                Get 5-15% bonus credits on larger deposits
              </p>
            </div>

            <div className="card-hover p-6">
              <Users className="w-12 h-12 text-accent mb-4" />
              <h3 className="text-xl font-bold mb-3">Free Tier</h3>
              <p className="text-text-secondary">
                50 free queries/day for testing and small markets
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Live Activity Feed */}
      <section className="py-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="section-title">Live Activity</h2>
            <p className="text-xl text-text-secondary">
              See earnings in real-time
            </p>
          </div>

          <LiveFeed />
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-24 bg-gradient-primary relative overflow-hidden">
        <div className="absolute inset-0 bg-dark/50" />
        <div className="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-4xl md:text-5xl font-bold mb-6">
            Ready to Monetize Your Game Data?
          </h2>
          <p className="text-xl mb-8 opacity-90">
            Join 127+ games earning millions on PredictBNB
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/dashboard" className="bg-white text-dark font-bold py-4 px-8 rounded-xl hover:scale-105 transition-transform">
              Get Started
            </Link>
            <Link href="/analytics" className="bg-dark-card border-2 border-white text-white font-bold py-4 px-8 rounded-xl hover:scale-105 transition-transform">
              View Analytics
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
