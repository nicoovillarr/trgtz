import { defineConfig, envField } from "astro/config";

import tailwind from "@astrojs/tailwind";
import react from "@astrojs/react";
import icon from "astro-icon";

import vercelStatic from "@astrojs/vercel/static";

// https://astro.build/config
export default defineConfig({
  integrations: [tailwind(), react(), icon()],
  output: "static",
  adapter: vercelStatic({
    webAnalytics: {
      enabled: true,
    },
  })
});
