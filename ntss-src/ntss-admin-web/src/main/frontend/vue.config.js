import path from "node:path";
import fs from "node:fs";
import { fileURLToPath } from "node:url";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const base = "/ntss-admin-web/";
const fabServiceWorkerPath = path.resolve(__dirname, "src/FabServiceWorker.js");
const buildOutDir = path.resolve(__dirname, "../resources/public");

function cleanViteBuildOutputPlugin() {
  const generatedAssetsDir = path.resolve(buildOutDir, "assets");
  return {
    name: "ntss-clean-vite-build-output",
    apply: "build",
    buildStart() {
      if (!generatedAssetsDir.startsWith(buildOutDir + path.sep)) {
        throw new Error(`Refusing to clean outside build output: ${generatedAssetsDir}`);
      }
      fs.rmSync(generatedAssetsDir, { recursive: true, force: true });
      fs.mkdirSync(generatedAssetsDir, { recursive: true });
    }
  };
}

function fabServiceWorkerCompatPlugin() {
  return {
    name: "ntss-fab-service-worker-compat",
    configureServer(server) {
      server.middlewares.use(`${base}app-file.js`, (req, res) => {
        res.statusCode = 200;
        res.setHeader("Content-Type", "application/javascript");
        fs.createReadStream(fabServiceWorkerPath).pipe(res);
      });
    },
    generateBundle() {
      this.emitFile({
        type: "asset",
        fileName: "app-file.js",
        source: fs.readFileSync(fabServiceWorkerPath, "utf8")
      });
    }
  };
}

export default defineConfig(({ mode }) => ({
  plugins: [
    cleanViteBuildOutputPlugin(),
    vue({
      template: {
        // Vue2 public/img の静的URLを JS import に変換しない
        transformAssetUrls: false,
        compilerOptions: {
          // Onsen UI と Vue2 で通常要素として扱っていた legacy HTML タグはコンポーネント解決対象外にする
          isCustomElement: (tag) => tag.startsWith("ons-") || tag === "font" || tag === "v-ond-vol"
        }
      }
    }),
    fabServiceWorkerCompatPlugin()
  ],
  base,
  resolve: {
    alias: [
      { find: "@", replacement: path.resolve(__dirname, "src") },
      { find: /^vue$/, replacement: "vue/dist/vue.esm-bundler.js" }
    ],
    extensions: [".mjs", ".js", ".mts", ".ts", ".jsx", ".tsx", ".json", ".vue"]
  },
  server: {
    host: "0.0.0.0",
    port: 8000,
    proxy: {
      "/ntss-admin-web/api": {
        target: "http://localhost:8080",
        changeOrigin: true
      }
    },
    hmr: { overlay: false }
  },
  preview: {
    host: "0.0.0.0",
    port: 8000
  },
  define: {
    global: "globalThis",
    "process.env.NODE_ENV": JSON.stringify(mode === "production" ? "production" : "development"),
    "process.env.BASE_URL": JSON.stringify(base)
  },
  test: {
    globals: true,
    environment: "jsdom"
  },
  build: {
    outDir: buildOutDir,
    emptyOutDir: false,
    // Vue2 webpack config deletes prefetch; keep async chunks lazy instead of preloading them.
    modulePreload: false,
    sourcemap: false,
    chunkSizeWarningLimit: 16000,
    commonjsOptions: {
      transformMixedEsModules: true
    },
    rolldownOptions: {
      output: {
        codeSplitting: true
      },
      checks: {
        pluginTimings: false
      }
    }
  }
}));
