import Vue from "vue";
import Vuex from "vuex";
import createPersistedState from "vuex-persistedstate";
import WindowSizeStore from "@/stores/WindowSizeStore";
import LoadingScreenStore from "@/stores/LoadingScreenStore";
import ApplicationStore from "@/stores/ApplicationStore";
import UserStore from "@/stores/UserStore";
import { CL_USER_STORES } from "@/stores/cl-user";
// add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
import { CL_MANAGE_VIEW_STORES } from "@/stores/cl-manage-view";
// add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
import { CL_FACILITY_STORES } from "@/stores/cl-facility";
import { CL_DETAIL_STORE } from "@/stores/cl-details";
import { ACCOUNT_EDIT_STORE } from "@/stores/modal";

Vue.use(Vuex);

const MODULES = {
  "loading-screen": LoadingScreenStore,
  app: ApplicationStore,
  user: UserStore,
  "window-size": WindowSizeStore
};

const STORES = [
  CL_USER_STORES,
  CL_FACILITY_STORES,
  CL_DETAIL_STORE,
  // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
  CL_MANAGE_VIEW_STORES,
  // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
  ACCOUNT_EDIT_STORE
];

STORES.forEach(store => {
  Object.keys(store).forEach(key => {
    MODULES[key] = store[key];
  });
});

const persistStorePaths = ["account-edit", "app", "user"];

export default new Vuex.Store({
  modules: MODULES,
  strict: process.env.NODE_ENV !== "production",
  plugins: [
    createPersistedState({
      storage: window.sessionStorage,
      paths: persistStorePaths
    })
  ]
});
