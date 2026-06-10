/**
 * 治療記録 装置設定ストア
 */
import {
  sendRequestGetTreatmentRecordSetting,
  sendRequestPostOrderReadSettingValue,
  sendRequestGetTreatmentRecordRstDeviceSetInfo
} from "@/apis/treatment-record";

export default {
  strict: true,
  namespaced: true,
  state: {
    rstDeviceSetInfo: null,
    sub_params: null,
  },
  mutations: {
    /**
     * 実績：装置設定情報設定.
     */
    setRstDeviceSetInfo(state, rstDeviceSetInfo) {
      state.rstDeviceSetInfo = rstDeviceSetInfo;
    },
    /**
     * 施設コードを設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} sub_params パラメーター
     */
    setSubParams(state, sub_params) {
      state.sub_params = sub_params;
    },
  },
  actions: {
    /**
     * 設定値読み込み履歴取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getTreatmentRecordSetting({ commit }, ordNo) {
      return sendRequestGetTreatmentRecordSetting(ordNo);
    },
    /**
     * 設定値読出し指示.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} param パラメータオブジェクト
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    postOrderReadSettingValue({ commit }, param) {
      return sendRequestPostOrderReadSettingValue(param);
    },
    /**
     * 実績：装置設定情報取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getTreatmentRecordRstDeviceSetInfo({ commit }, ordNo) {
      return sendRequestGetTreatmentRecordRstDeviceSetInfo(ordNo).then(response => {
        commit("setRstDeviceSetInfo", response.data.rst_device_set_info);
        return response;
      });
    },
    /**
     * オーダ番号を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} ordNo パラメーター
     */
    setSubParams({ commit }, sub_params) {
      commit("setSubParams", sub_params);
    },
  },
  getters: {
    /**
     * 実績：装置設定情報を取得する.
     * @param {*} state stateオブジェクト
     */
    getRstDeviceSetInfo(state) {
      return state.rstDeviceSetInfo;
    },
    /**
     * パラメーターを取得する.
     * @param {*} state STATEオブジェクト
     */
    getSubParams(state) {
      return state.sub_params;
    },
  }
};
