import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "#00D9FF", // Electric Blue
        secondary: "#FF00FF", // Neon Magenta
        accent: "#00FF88", // Money Green
        warning: "#FFD700", // Gold
        dark: {
          DEFAULT: "#0A0E27", // Deep Space Blue
          card: "#1A1F3A", // Dark Blue Card
          hover: "#252B4D", // Lighter Blue
        },
        text: {
          primary: "#FFFFFF",
          secondary: "#B8BFCF",
          muted: "#6B7280",
        },
      },
      fontFamily: {
        sans: ["var(--font-inter)", "system-ui", "sans-serif"],
        mono: ["var(--font-space-mono)", "Courier New", "monospace"],
      },
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-conic":
          "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
        "gradient-primary": "linear-gradient(135deg, #00D9FF 0%, #FF00FF 100%)",
        "gradient-money": "linear-gradient(135deg, #00FF88 0%, #00D9FF 100%)",
      },
      animation: {
        "pulse-slow": "pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        "float": "float 3s ease-in-out infinite",
        "glow": "glow 2s ease-in-out infinite",
      },
      keyframes: {
        float: {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-20px)" },
        },
        glow: {
          "0%, 100%": { boxShadow: "0 0 20px rgba(0, 217, 255, 0.3)" },
          "50%": { boxShadow: "0 0 40px rgba(0, 217, 255, 0.6)" },
        },
      },
    },
  },
  plugins: [],
};
export default config;
