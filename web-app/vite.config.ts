import { defineConfig, loadEnv, type Plugin } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

function runtimeConfigPlugin(): Plugin {
  return {
    name: "runtime-config",
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        if (req.url !== "/config.js") return next();

        const env = loadEnv("development", process.cwd(), "VITE_");
        const config = {
          webServerUrl: env.VITE_WEB_SERVER_URL ?? "http://localhost:3000",
          apiUrl: env.VITE_API_URL ?? "api/v1",
        };

        res.setHeader("Content-Type", "application/javascript");
        res.end(`window.__CONFIG__ = ${JSON.stringify(config)};\n`);
      });
    },
  };
}

export default defineConfig({
  plugins: [react(), runtimeConfigPlugin()],
  server: {
    host: true,
    port: 5173,
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
