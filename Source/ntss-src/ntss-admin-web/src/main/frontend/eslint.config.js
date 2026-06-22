import js from "@eslint/js";
import globals from "globals";
import vueParser from "vue-eslint-parser";
import vuePlugin from "eslint-plugin-vue";
import { defineConfig, globalIgnores } from "eslint/config";

export default defineConfig([
  globalIgnores([
    "dist/**",
    "public/**",
    "src/components/operation-viewer/machines/MachinesMainComponent.vue",
    "src/components/operation-viewer/motion-record-details/MotionRecordDetailsMainComponent.vue",
    "src/components/header-contents/BioMonitoringDetailHeaderItem.vue",
    "src/components/header-contents/BioMonitoringListHeaderItem.vue",
    "src/components/header-contents/PatientHeaderItem.vue",
    "src/components/header-contents/CommonPatientInformationHeaderitem.vue",
    "src/components/main-contents/sub-contents/**",
    "src/components/main-contents/BioMonitoringDetailMainItem.vue",
    "src/components/main-contents/BioMonitoringListMainItem.vue",
    "src/components/pat-viewer/**",
    "src/views/pat-viewer/**",
    "src/pages/BioMonitoringDetailPage.vue",
    "src/pages/BioMonitoringPage.vue",
    "src/stores/modules/pat-viewer/**",
    "src/stores/modules/common/**",
    "src/stores/modules/appItem.js",
    "src/stores/modules/listGraph.js",
    "src/customServiceWorker.js"
  ]),
  {
    files: ["**/*.{js,mjs,cjs,vue}"],
    languageOptions: {
      parser: vueParser,
      parserOptions: {
        ecmaVersion: "latest",
        sourceType: "module"
      },
      globals: {
        ...globals.browser,
        ...globals.node
      }
    },
    plugins: {
      vue: vuePlugin
    },
    rules: {
      ...js.configs.recommended.rules,
      ...vuePlugin.configs["flat/essential"].rules,
      "no-undef": "off",
      "no-unused-vars": "off",
      "no-irregular-whitespace": "off",
      "no-useless-assignment": "off",
      "no-case-declarations": "off",
      "vue/multi-word-component-names": "off"
    }
  }
]);
