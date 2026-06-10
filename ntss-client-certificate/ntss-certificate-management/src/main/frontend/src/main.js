// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from "vue";
import App from "@/App";
import router from "@/router";
import store from "@/stores";
import VueOnsen from "vue-onsenui";
import VeeValidate, { Validator } from "vee-validate";
import customMessages from "@/validators/messages";
import alpha_num_symbol from "@/validators/alpha-num-symbol.js";
import KendoGridMixin from "@/components/KendoGridMixin";
import Notifications from "vue-notification";

// Font Awesome のメインファイルを import
import "@fortawesome/fontawesome-free-webfonts/css/fontawesome.css";
// 使用するカテゴリーのファイルを import
import "@fortawesome/fontawesome-free-webfonts/css/fa-brands.css";
import "@fortawesome/fontawesome-free-webfonts/css/fa-regular.css";
import "@fortawesome/fontawesome-free-webfonts/css/fa-solid.css";
import "onsenui/css/onsenui.css";
import "onsenui/css/onsenui-core.css";
import "onsenui/css/onsen-css-components.css";
import "@progress/kendo-ui";
import "@progress/kendo-theme-bootstrap/dist/all.css";
import { Grid, GridInstaller } from "@progress/kendo-grid-vue-wrapper";
import { LayoutInstaller } from "@progress/kendo-layout-vue-wrapper";
import { DropdownsInstaller } from "@progress/kendo-dropdowns-vue-wrapper";
import {
  DataSource,
  DataSourceInstaller
} from "@progress/kendo-datasource-vue-wrapper";
import { ValidatorInstaller } from "@progress/kendo-validator-vue-wrapper";
import { BarcodesInstaller } from "@progress/kendo-barcodes-vue-wrapper";
import { UploadInstaller } from "@progress/kendo-upload-vue-wrapper";
import VCalendar from "v-calendar";

Vue.config.productionTip = false;

Vue.use(VueOnsen);
Vue.use(GridInstaller);
Vue.use(DropdownsInstaller);
Vue.use(DataSourceInstaller);
Vue.use(LayoutInstaller);
Vue.use(BarcodesInstaller);
Vue.use(UploadInstaller);
Vue.use(Notifications);

// カスタマイズしたメッセージを読ませる
Vue.use(VeeValidate, customMessages);
Vue.use(ValidatorInstaller);
Validator.localize("ja", customMessages);

Validator.extend("alpha_num_symbol", alpha_num_symbol);

Vue.mixin(KendoGridMixin);
Vue.use(VCalendar, {
  componentPrefix: "vc"
});

Vue.config.productionTip = false;

new Vue({
  components: {
    Grid,
    DataSource,
    DataSourceInstaller
  },
  router,
  store,
  render: h => h(App)
}).$mount("#app");
