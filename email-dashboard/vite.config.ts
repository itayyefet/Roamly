import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// Dev server runs on a fixed port so it matches the redirect URI you
// register in Azure (http://localhost:5173).
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    strictPort: true,
  },
});
