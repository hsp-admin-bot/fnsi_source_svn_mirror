/**
 * 職種マスタメンテナンスStore.
 */

export default {
  strict: true,
  namespaced: true,
  state: {
    // 権限編集フラグ
    isEditAuthority: false,
    // デフォルトメニュー設定
    isMenuSettings: false,
    // デフォルト表示設定
    isDefaultDispSettings: false,
    // デフォルト通知設定
    isDefaultNotificationSettings: false
  },
  mutations: {
    // 権限編集フラグを設定
    setIsEditAuthority(state, isEditAuthority) {
      state.isEditAuthority = isEditAuthority;
    },
    // デフォルトメニュー設定
    setIsMenuSettings(state, isMenuSettings) {
      state.isMenuSettings = isMenuSettings;
    },
    // デフォルト表示設定
    setIsDefaultDispSettings(state, isDefaultDispSettings) {
      state.isDefaultDispSettings = isDefaultDispSettings;
    },
    // デフォルト通知設定
    setIsDefaultNotificationSettings(state, isDefaultNotificationSettings) {
      state.isDefaultNotificationSettings = isDefaultNotificationSettings;
    }
  },
  actions: {
    /**
     * 施設情報を設定
     */
    setIsEditAuthority({ commit }, isEditAuthority) {
      commit("setIsEditAuthority", isEditAuthority);
    },
    /**
     * デフォルトメニュー設定
     */
    setIsMenuSettings({ commit }, isMenuSettings) {
      commit("setIsMenuSettings", isMenuSettings);
    },
    /**
     * デフォルト表示設定
     */
    setIsDefaultDispSettings({ commit }, isDefaultDispSettings) {
      commit("setIsDefaultDispSettings", isDefaultDispSettings);
    },
    /**
     * デフォルト通知設定
     */
    setIsDefaultNotificationSettings({ commit }, isDefaultNotificationSettings) {
      commit("setIsDefaultNotificationSettings", isDefaultNotificationSettings);
    }
  },
  getters: {
    getIsEditAuthority(state) {
      return state.isEditAuthority;
    },
    getIsMenuSettings(state) {
      return state.isMenuSettings;
    },
    getIsDefaultDispSettings(state) {
      return state.isDefaultDispSettings;
    },
    getIsDefaultNotificationSettings(state) {
      return state.isDefaultNotificationSettings;
    }
  }
};
