/**
 * ユーザメニューの共通設定タブおよび個人設定タブ系ストア
 */
import { sendRequestGetPersonalTabDefine } from "@/apis/facility.js";
import {
  sendRequestGetPersonalSettingsDefine,
  sendRequestGetPersonalSettings,
  sendRequestUpdatePersonalSettings
} from "@/apis/personal-setting.js";

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 選択したタブ定義コード
     */
    tabDefineCd: null,

    // add bug 5482 修正 chen start
    personalSettingsTmp: null,

    comFixedPhraseList: []
    // add bug 5482 修正 chen end
  },
  mutations: {
    /**
     * 選択したタブ定義コードをStoreに格納します.
     * @param {*} state stateオブジェクト
     * @param {*} cd タブ定義コード
     */
    setSelectedTabDefineCd(state, cd) {
      state.tabDefineCd = cd;
    },

    // add bug 5482 修正 chen start
    setPersonalSettingsTmp(state, personalSettingsTmp) {
      state.personalSettingsTmp = personalSettingsTmp;
    },

    setComFixedPhraseList(state, comFixedPhraseList) {
      state.comFixedPhraseList = comFixedPhraseList;
    }
    // add bug 5482 修正 chen end
  },
  actions: {
    /**
     * 個人設定タブ定義取得.
     * @param {*} commit COMMITオブジェクト
     * @param {string} facilityCd 施設コード
     */
    getPersonalTabDefine({ commit }, facilityCd) {
      return sendRequestGetPersonalTabDefine(facilityCd);
    },
    /**
     * 指定のタブ定義コードの設定項目情報を取得
     * @param {*} commit commitオブジェクト
     * @param {*} tabDefineCd タブ定義コード
     */
    getPersonalSettingsDefine({ commit }, tabDefineCd) {
      return sendRequestGetPersonalSettingsDefine(tabDefineCd);
    },
    /**
     * 指定のタブ定義コードの個人設定値を取得.
     * @param {*} commit commitオブジェクト
     * @param {*} tabDefineCd タブ定義コード
     */
    getPersonalSettings({ commit }, tabDefineCd) {
      return sendRequestGetPersonalSettings(tabDefineCd);
    },
    /**
     * 指定のタブ定義コードの個人設定値を更新.
     * @param {*} commit commitオブジェクト
     * @param {*} param 更新する個人設定値(personal_settingsのJSON)
     */
    updatePersonalSettings({ commit }, param) {
      return sendRequestUpdatePersonalSettings(param);
    },
    /**
     * 選択したタブ定義コードをStoreに格納.
     * @param {*} state stateオブジェクト
     * @param {*} cd タブ定義コード
     */
    setSelectedTabDefineCd({ commit }, cd) {
      commit("setSelectedTabDefineCd", cd);
    },

    // add bug 5482 修正 chen start
    setPersonalSettingsTmp({ commit }, personalSettingsTmp) {
      commit("setPersonalSettingsTmp", personalSettingsTmp);
    },

    setComFixedPhraseList({ commit }, comFixedPhraseList) {
      commit("setComFixedPhraseList", comFixedPhraseList);
    }
    // add bug 5482 修正 chen end
  },
  getters: {
    /**
     * 選択したタブ定義コード取得.
     * @param {*} state stateオブジェクト
     */
    getSelectedTabDefineCd(state) {
      return state.tabDefineCd;
    },

    // add bug 5482 修正 chen start
    getPersonalSettingsTmp(state) {
      return state.personalSettingsTmp;
    },

    getComFixedPhraseList(state) {
      return state.comFixedPhraseList;
    }
    // add bug 5482 修正 chen end
  }
};
