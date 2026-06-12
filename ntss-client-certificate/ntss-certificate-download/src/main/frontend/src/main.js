import { createApp } from "vue";
import App from "@/App.vue";
import router from "@/router";
import store from "@/stores";
import VueOnsenBridge from "@/compat/onsen/components.js";
import customMessages from "@/validators/messages";
import alphaNumSymbol from "@/validators/alpha-num-symbol.js";
import LegacyValidation, { Validator } from "@/compat/validation/plugin.js";
import LegacyNotifications from "@/compat/notification/index.js";
import { installKendoCompat } from "@/compat/kendo/index.js";
import VCalendar from "v-calendar";

import "@fortawesome/fontawesome-free/css/fontawesome.css";
import "@fortawesome/fontawesome-free/css/brands.css";
import "@fortawesome/fontawesome-free/css/regular.css";
import "@fortawesome/fontawesome-free/css/solid.css";
import "onsenui/css/onsenui.css";
import "onsenui/css/onsenui-core.css";
import "onsenui/css/onsen-css-components.css";
import "@progress/kendo-ui";
import "@progress/kendo-theme-bootstrap/dist/all.css";

const app = createApp(App);

app.use(VueOnsenBridge);
installKendoCompat(app);
app.use(LegacyNotifications);
app.use(LegacyValidation, customMessages);
app.use(VCalendar, { componentPrefix: "vc" });

Validator.localize("ja", customMessages);
Validator.extend("alpha_num_symbol", alphaNumSymbol);

app.use(router);
app.use(store);
app.mount("#app");
