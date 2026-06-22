import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const chromedriver = require("chromedriver");

export default {
  src_folders: ["tests/e2e/specs"],
  custom_assertions_path: ["tests/e2e/custom-assertions"],
  output_folder: "tests/e2e/reports",
  webdriver: {
    start_process: true,
    server_path: chromedriver.path,
    port: 9515
  },
  test_settings: {
    default: {
      launch_url: "http://localhost:8000/ntss-admin-web/",
      desiredCapabilities: {
        browserName: "chrome",
        "goog:chromeOptions": {
          args: ["headless=new", "disable-gpu", "window-size=1440,900"]
        }
      }
    }
  }
};
