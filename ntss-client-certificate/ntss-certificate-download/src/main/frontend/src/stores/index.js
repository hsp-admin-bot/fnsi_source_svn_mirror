import Vue from "vue";
import Vuex from "vuex";
import createPersistedState from "vuex-persistedstate";
import WindowSizeStore from "@/stores/WindowSizeStore";
import LoadingScreenStore from "@/stores/LoadingScreenStore";
import ApplicationStore from "@/stores/ApplicationStore";
import UserStore from "@/stores/UserStore";
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
  CL_FACILITY_STORES,
  CL_DETAIL_STORE,
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
