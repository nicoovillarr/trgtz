/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      colors: {
        primary: "#003E4B",
        "primary-light": "#005D6E",
        "primary-dark": "#002B35",

        pinky: "#FF6584",
      },

      fontFamily: {
        "josefin-sans": ["JosefinSans", "sans-serif"],
        sans: ["Inter", "sans-serif"],
      },

      screens: {
        xs: "375px",
      },
    },
  },
  plugins: [],
};
