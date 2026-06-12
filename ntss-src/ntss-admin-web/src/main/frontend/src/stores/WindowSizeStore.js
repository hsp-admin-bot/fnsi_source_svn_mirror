/**
 * Windowサイズ管理用Store
 */
import store from "@/stores";
import { getPatientSearchSidebarElement } from "@/functions/common/LayoutMeasureHelper";

// 分割画面の最大幅
const MAX_SPLIT_FRAME_WIDTH = 760;

export default {
  namespaced: true,
  state: {
    windowHeight: 0, // Window高
    windowWidth: 0, // Window幅
    currentDepth: 0, // ルーターの現在の階層
    splittableFrames: 1, // 画面分割可能数
    sidebarWidth: 0 // サイドバーエリアの幅
  },
  mutations: {
    setSize(state, { windowHeight, windowWidth }) {
      // Window高設定
      state.windowHeight = windowHeight;

      // Window幅設定
      state.windowWidth = windowWidth;

      //サイドバーのサイズ補正
      const sidebarObj = getPatientSearchSidebarElement();
      if (sidebarObj !== null && sidebarObj.style.position !== "absolute") {
        state.sidebarWidth = sidebarObj.offsetWidth;
      } else {
        state.sidebarWidth = 0;
      }
    },
    /**
     * Window幅より分割可能数決定
     */
    setSplittableFrames(state) {
      if (state.windowWidth - state.sidebarWidth < MAX_SPLIT_FRAME_WIDTH) {
        state.splittableFrames = 1;
      } else if (
        state.windowWidth - state.sidebarWidth >= MAX_SPLIT_FRAME_WIDTH &&
        state.windowWidth - state.sidebarWidth < MAX_SPLIT_FRAME_WIDTH * 2
      ) {
        state.splittableFrames = 2;
      } else if (
        state.windowWidth - state.sidebarWidth >= MAX_SPLIT_FRAME_WIDTH * 2 &&
        state.windowWidth - state.sidebarWidth < MAX_SPLIT_FRAME_WIDTH * 3
      ) {
        state.splittableFrames = 3;
      } else {
        state.splittableFrames = 4;
      }
    },
    /**
     * 分割可能数のクリア
     */
    resetSplittableFrames(state) {
      state.splittableFrames = 1;
    },
    // ルーターの現在の階層をクリア
    resetCurrentDepth(state) {
      state.currentDepth = 0;
    },
    // ルーターの現在の階層を設定
    setCurrentDepth(state, depth) {
      state.currentDepth = depth;
    }
  },
  actions: {
    // Window(高・幅)設定
    setSize({ commit }, { windowHeight, windowWidth }) {
      commit("setSize", {
        windowHeight: windowHeight,
        windowWidth: windowWidth
      });
      const isSplitFrame = store.getters["account-edit/getSplitFrame"];
      if (isSplitFrame) {
        commit("setSplittableFrames");
      } else {
        commit("resetSplittableFrames");
      }
    },
    /**
     * 分割可能数の設定
     */
    setSplittableFrames({ commit }) {
      commit("setSplittableFrames");
    },
    /**
     * 分割可能数のクリア
     */
    resetSplittableFrames({ commit }) {
      commit("resetSplittableFrames");
    },
    // ルーターの現在の階層をクリア
    resetCurrentDepth({ commit }) {
      commit("resetCurrentDepth");
    },
    // ルーターの現在の階層を設定
    setCurrentDepth({ commit }, depth) {
      commit("setCurrentDepth", depth);
    }
  },
  getters: {
    // 分割された画面の幅取得
    getSplittedWidth(state) {
      if (state.currentDepth === 0) {
        return state.windowWidth - state.sidebarWidth;
      }
      return Math.floor(
        (state.windowWidth - state.sidebarWidth) /
          (state.currentDepth <= state.splittableFrames
            ? state.currentDepth
            : state.splittableFrames)
      );
    },
    // 画面分割可能数取得
    getSplittableFrames(state) {
      return state.splittableFrames;
    },
    // Window高さ取得
    getWindowHeight(state) {
      return state.windowHeight;
    },
    // Window幅取得
    getWindowWidth(state) {
      return state.windowWidth;
    },
    // サイドバーサイズの取得
    getSidebarWidth(state){
      return state.sidebarWidth;
    },
    // ウインドウ幅からサイドバーを引いた枠の取得
    getMainWindowWidth(state){
      return state.windowWidth - state.sidebarWidth;
    }
  }
};
