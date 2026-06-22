/**
 * アプリエントリ（Vue2 main.js と同等のグローバル登録を Vue3 / createApp で再構成）
 */
import { createApp } from "@/compat/vue/runtime";
import $ from "@/compat/jquery";
import "@/compat/kendo/theme.css";
import "@/compat/assets/fontawesome.css";
import PublicAssetsCompat from "@/compat/assets/public-path.js";

import { GridNoRecords as KendoVueGridNoRecords } from "@/compat/kendo/native-grid";
import Highcharts, { HighchartsVue } from "@/compat/charts/highcharts";
import VCalendar from "@/compat/calendar/v-calendar";

import App from "./App.vue";
import router from "./router";
import store from "./stores";
import "./registerServiceWorker";

import VueOnsenBridge from "@/compat/onsen/components";
import VTouch from "@/components/common/VTouch.vue";
import TouchKeyboard from "@/compat/keyboard/TouchKeyboard.vue";
import LayoutView from "@/views/LayoutView.vue";
import LayoutSplitView from "@/views/LayoutSplitView.vue";
import LayoutContentView from "@/views/LayoutContentView.vue";
import VCard from "@/components/common/VCard.vue";

import DirectivesPlugin from "@/directives/directive.js";
import NtssLogger from "@/ntssLogger.js";
import KendoGridMixin from "@/components/KendoGridMixin.js";
import KendoGrid from "@/compat/kendo/KendoGrid.vue";
import KendoGridColumn from "@/compat/kendo/KendoGridColumn.vue";
import KendoGridToolbar from "@/compat/kendo/KendoGridToolbar.vue";
import KendoDataSource from "@/compat/kendo/KendoDataSource.vue";
import KendoSchedulerView from "@/compat/kendo/KendoSchedulerView.vue";
import KendoTabStrip from "@/compat/kendo/KendoTabStrip.vue";
// Layout 系は Vue2 実装を再確認した結果、Kendo 側は TabStrip のみを実使用対象とする。
// ntss-layout / ntss-layout-split / ntss-layout-content は引き続きアプリ独自レイアウトを利用する。
import KendoUpload from "@/compat/kendo/KendoUpload.vue";
import KendoQrCode from "@/compat/kendo/KendoQrCode.vue";
import KendoDropDownList from "@/compat/kendo/KendoDropDownList.vue";
import KendoMultiSelect from "@/compat/kendo/KendoMultiSelect.vue";
import KendoScheduler from "@/compat/kendo/KendoScheduler.vue";
import { installKendoNativeWidgets } from "@/compat/kendo/native-widgets.js";
import { prepareKendoJQueryServices } from "@/compat/kendo/kendo-jquery-services.js";
import ValidationMixin from "@/compat/validation/validation-mixin";
import VeeValidateCompat from "@/compat/validation/plugin.js";
import Vue3TouchEventsCompat from "@/compat/touch/vue3-touch-events.js";

import SanitizeCompat, { sanitizeText } from "@/compat/sanitize";
import NotificationCompat from "@/compat/notification";
import GlobalOnsAlertDialog from "@/components/common/onsen/GlobalOnsAlertDialog";
import "@/compat/styles/legacy-font.css";
import FontSizeSetCompatMixin from "@/compat/styles/font-size-set-compat.js";

globalThis.$ = $;
globalThis.jQuery = $;
globalThis.global = globalThis;

if (typeof globalThis !== "undefined") {
  globalThis.$ = $;
  globalThis.jQuery = $;
}

async function bootstrap() {
  try {
    // Kendo jQuery は QRCode / Validator / DataSource の jQuery フォールバックとして利用する
    await prepareKendoJQueryServices();
    installKendoNativeWidgets();

    const app = createApp(App);

    app.config.globalProperties.$ = $;
    app.config.globalProperties.jQuery = $;
    app.config.globalProperties.$sanitize = sanitizeText;

    app.use(SanitizeCompat);
    app.use(PublicAssetsCompat);
    app.use(Vue3TouchEventsCompat);
    app.use(VeeValidateCompat);

    app.use(store);
    app.use(router);
    app.use(HighchartsVue?.default || HighchartsVue, { highcharts: Highcharts });
    app.use(VueOnsenBridge);
    app.use(DirectivesPlugin);
    app.use(NtssLogger);
    app.use(NotificationCompat);

    app.mixin(ValidationMixin);
    app.mixin(FontSizeSetCompatMixin);
    app.mixin(KendoGridMixin);

    app.component("ntss-layout", LayoutView);
    app.component("ntss-layout-split", LayoutSplitView);
    app.component("ntss-layout-content", LayoutContentView);
    app.component("v-card", VCard);
    app.component("grid-norecords", KendoVueGridNoRecords);
    app.component("kendo-grid", KendoGrid);
    app.component("kendo-grid-column", KendoGridColumn);
    app.component("kendo-grid-toolbar", KendoGridToolbar);
    app.component("kendo-datasource", KendoDataSource);
    app.component("kendo-scheduler-view", KendoSchedulerView);
    app.component("kendo-tabstrip", KendoTabStrip);
    app.component("kendo-upload", KendoUpload);
    app.component("ntss-upload", KendoUpload);
    app.component("kendo-qrcode", KendoQrCode);
    app.component("kendo-dropdownlist", KendoDropDownList);
    app.component("kendo-multiselect", KendoMultiSelect);
    app.component("kendo-scheduler", KendoScheduler);
    app.component("VTouch", VTouch);
    app.component("vue-touch-keyboard", TouchKeyboard);

    app.use(VCalendar, {
      componentPrefix: "vc"
    });

    const appInstance = app.mount("#app");
    const scopedDocument = appInstance?.$el?.ownerDocument || document;

    const globalOnsDialogRoot = scopedDocument.createElement("div");
    globalOnsDialogRoot.id = "ons-alert-dialog-global-root";
    scopedDocument.body.appendChild(globalOnsDialogRoot);
    const globalOnsDialogApp = createApp(GlobalOnsAlertDialog);
    globalOnsDialogApp.use(store);
    globalOnsDialogApp.use(VueOnsenBridge);
    globalOnsDialogApp.mount(globalOnsDialogRoot);
  } catch (error) {
    console.error("[bootstrap] failed to initialize app", error);
  }
}

bootstrap();
