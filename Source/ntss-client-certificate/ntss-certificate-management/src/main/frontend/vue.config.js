import { fileURLToPath, URL } from "node:url";
import path from "node:path";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  base: "/ntss-certificate-management/",
  plugins: [
    vue({
      template: {
        transformAssetUrls: false,
        compilerOptions: {
          isCustomElement: tag => tag === "font"
        }
      }
    })
  ],
  resolve: {
    // Vue2/Webpack allowed extensionless .vue imports such as @/components/X.
    // Keep that source-level semantics in the build/public layer instead of editing page/router imports.
    extensions: [".mjs", ".js", ".mts", ".ts", ".jsx", ".tsx", ".json", ".vue"],
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
      "moment": fileURLToPath(new URL("./src/compat/date/moment.js", import.meta.url))
    }
  },
  server: {
    host: "0.0.0.0",
    port: 8000,
    proxy: {
      "/ntss-certificate-management/api": {
        target: "http://localhost:8080",
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: path.resolve(__dirname, "../resources/public"),
    // Vue2 webpack config deletes prefetch; keep async chunks lazy instead of preloading them.
    modulePreload: false,
    emptyOutDir: true
  },
  define: {
    "process.env.NODE_ENV": JSON.stringify(process.env.NODE_ENV || "development")
  }
});
