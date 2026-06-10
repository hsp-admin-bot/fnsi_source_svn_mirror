export default {
  namespaced: true,
  strict: process.env.NODE_ENV !== "production",
  state: {
    isLockDevTool: true,
    pressedKeys: {}
  },
  getters: {
    isLockDevTool: state => state.isLockDevTool,
    pressedKeys: state => state.pressedKeys
  },
  actions: {
    lockDevTool({ commit }) {
      document.addEventListener("keydown", preventOpenDevTool);
      document.addEventListener("contextmenu", preventOpenDevTool);
      commit("setIsLockDevTool", true);
    },
    unlockDevTool({ commit }) {
      document.removeEventListener("keydown", preventOpenDevTool);
      document.removeEventListener("contextmenu", preventOpenDevTool);
      commit("setIsLockDevTool", false);
    },
    setPressedKey({ commit, state }, key) {
      const pressedKeys = { ...state.pressedKeys, [key]: true };
      commit("setPressedKeys", pressedKeys);
    },
    removePressedKey({ commit, state }, key) {
      const pressedKeys = { ...state.pressedKeys };
      delete pressedKeys[key];
      commit("setPressedKeys", pressedKeys);
    }
  },
  mutations: {
    setIsLockDevTool(state, isLockDevTool) {
      state.isLockDevTool = isLockDevTool;
    },
    setPressedKeys(state, pressedKeys) {
      state.pressedKeys = pressedKeys;
    }
  }
};

function preventOpenDevTool(ev) {
  //if ([123, 3].includes(ev.keyCode || ev.which)) ev.preventDefault();
  //#6694 ctrl ＋shift＋iによるデベロッパーツール起動をしないのことを追加。ljx　start
  if ([123, 3].includes(ev.keyCode || ev.which)||(ev.ctrlKey && ev.shiftKey && ev.keyCode === 73)) ev.preventDefault();
  //#6694 ctrl ＋shift＋iによるデベロッパーツール起動をしないのことを追加。ljx　end
}
