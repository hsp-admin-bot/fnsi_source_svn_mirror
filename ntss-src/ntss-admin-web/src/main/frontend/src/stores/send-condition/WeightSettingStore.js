/**
 * 体重計設定内容取得
 */

import { sendRequestGetWheelChairList } from "@/apis/send-condition";
import {
  sendRequestGetMstWeightScale,
  sendRequestGetMstWeightByNo
} from "@/apis/mst-weight-maintenance";
import { deepCopy } from "@/functions/common/CommonFunctions";

// 初期値の体重測定設定
const defaultWeightScaleInfo = {
  weightScaleCd: null,
  facilityCd: null,
  icCard: 0,
  patIdDigit: 12,
  defaultScreenClass: 0,
  examPeriod: 0,
  wheelChairPeriod: 0,
  tareUnitClass: 0,
  waterUnitClass: 0,
  isDoubleCheck: "0",
  doubleCheckTolerance: 0,
  isDuringDialysisView: "0",
  previousWeightSourceClass: 0
};
const defaultWeight = {
  audioSetting: {
    pat_ok: "0",
    receive_weight: "0",
    send_ok: "0",
    send_ng: "0"
  },
  bedGroupCd: 0,
  checkContent: [],
  colorSetting: {},
  deviceClass: 0,
  facilityCd: null,
  isAutoSendAfter: "0",
  isAutoSendBefore: "0",
  isDefaultPrintAfter: "0",
  isDefaultPrintBefore: "0",
  isDel: "0",
  isDisp: "1",
  isHasCardReader: "0",
  portName: "",
  printSetting: { before: [], after: [], no_schedule: [], no_pat: [] },
  printerClass: 0,
  regDate: null,
  weightCd: null,
  upDate: null,
  waitAutoSendAfter: 0,
  waitAutoSendBefore: 0,
  weightNo: 0
};

export default {
  strict: !import.meta.env.PROD,
  namespaced: true,
  state: {
    wheelChairList: [], // 車いすマスタ一式設定
    weightScaleConfigInfo: defaultWeightScaleInfo, // 体重測定マスタ設定
    weightConfigInfo: defaultWeight, // 体重計マスタ設定
    weightConfigDefaultInfo: defaultWeight // 体重計マスタ（体重計番号ゼロ）用設定
  },
  getters: {
    // 車いす一覧情報を取得
    getWheelChairList: state => state.wheelChairList,
    getWeightScaleConfigInfo: state => state.weightScaleConfigInfo,
    getWeightConfigInfo: state => state.weightConfigInfo,
    /**
     * 音声設定JSON取得
     */
    getWeightAudioSetting: state => {
      if (
        state.weightConfigInfo === undefined ||
        state.weightConfigInfo === null
      ) {
        return null;
      } else if (typeof state.weightConfigInfo.audioSetting === "string") {
        return JSON.parse(state.weightConfigInfo.audioSetting);
      } else {
        return state.weightConfigInfo.audioSetting;
      }
    },
    /**
     * チェック項目設定JSON取得
     */
    getWeightCheckSetting: state => {
      if (
        state.weightConfigInfo === undefined ||
        state.weightConfigInfo === null ||
        state.weightConfigInfo.weightCd === null
      ) {
        // 体重計未設定
        if (
          state.weightConfigDefaultInfo === undefined ||
          state.weightConfigDefaultInfo === null ||
          state.weightConfigDefaultInfo.weightCd === null
        ) {
          // 体重計番号ゼロも未設定
          return [];
        } else if (
          typeof state.weightConfigDefaultInfo.checkContent === "string"
        ) {
          // 体重計番号ゼロの設定を返す
          return JSON.parse(state.weightConfigDefaultInfo.checkContent);
        } else {
          // 体重計番号ゼロの設定を返す
          return state.weightConfigDefaultInfo.checkContent;
        }
      } else if (typeof state.weightConfigInfo.checkContent === "string") {
        // 体重計設定を返す
        return JSON.parse(state.weightConfigInfo.checkContent);
      } else {
        // 体重計設定を返す
        return state.weightConfigInfo.checkContent;
      }
    },
    /** 色設定JSON取得 */
    getWeightColorSetting: state => {
      if (
        state.weightConfigInfo === undefined ||
        state.weightConfigInfo === null
      ) {
        return {};
      } else if (typeof state.weightConfigInfo.colorSetting === "string") {
        return JSON.parse(state.weightConfigInfo.colorSetting);
      } else {
        return state.weightConfigInfo.colorSetting;
      }
    },
    /** 印刷設定JSON取得 */
    getWeightPrintSetting: state => {
      if (
        state.weightConfigInfo === undefined ||
        state.weightConfigInfo === null ||
        state.weightConfigInfo.weightCd === null
      ) {
        // 体重計未設定
        if (
          state.weightConfigDefaultInfo === undefined ||
          state.weightConfigDefaultInfo === null ||
          state.weightConfigDefaultInfo.weightCd === null
        ) {
          // 体重計番号ゼロも未設定
          return [];
        } else if (
          typeof state.weightConfigDefaultInfo.printSetting === "string"
        ) {
          // 体重計番号ゼロの設定を返す
          return JSON.parse(state.weightConfigDefaultInfo.printSetting);
        } else {
          // 体重計番号ゼロの設定を返す
          return state.weightConfigDefaultInfo.printSetting;
        }
      } else if (typeof state.weightConfigInfo.printSetting === "string") {
        // 体重計設定を返す
        return JSON.parse(state.weightConfigInfo.printSetting);
      } else {
        // 体重計設定を返す
        return state.weightConfigInfo.printSetting;
      }
    }
  },
  actions: {
    // 車いす取得
    fetchWheelChairList({ commit }, facilityCd) {
      sendRequestGetWheelChairList({ facilityCd: facilityCd }).then(
        response => {
          commit("setWheelChairList", response.data);
        }
      );
    },
    // 体重測定設定情報取得
    fetchWeightScaleSetting(context, facilityCd) {
      // 施設コードを指定して体重測定設定情報を取得
      return sendRequestGetMstWeightScale({
        facilityCd: facilityCd
      });
    },
    fetchDefaultWeightSetting(context, facilityCd) {
      return sendRequestGetMstWeightByNo({
        facilityCd: facilityCd,
        weightNo: 0
      });
    },
    setWeightScaleSetting({ commit }, weightScaleSetting) {
      commit("setWeightScaleSetting", weightScaleSetting);
    },
    clearWeightScaleSetting({ commit }) {
      commit("setWeightScaleSetting", null);
    },
    /**
     * 選択体重計マスタ情報を記録
     * @param {*} weightConfigInfo
     */
    setWeightConfigInfo({ commit }, weightConfigInfo) {
      commit("setWeightConfigInfo", weightConfigInfo);
    },
    clearWeightConfigInfo({ commit }) {
      commit("setWeightConfigInfo", null);
    },
    setDefaultWeightConfigInfo({ commit }, weightConfigInfo) {
      commit("setWeightDefaultConfigInfo", weightConfigInfo);
    }
  },
  mutations: {
    setWheelChairList(state, list) {
      state.wheelChairList = list;
    },
    setWeightScaleSetting(state, weightScaleSetting) {
      if (weightScaleSetting === null) {
        state.weightScaleConfigInfo = deepCopy(defaultWeightScaleInfo);
      } else {
        state.weightScaleConfigInfo = deepCopy(weightScaleSetting);
      }
    },
    setWeightConfigInfo(state, weightConfigInfo) {
      if (weightConfigInfo === null) {
        state.weightConfigInfo = deepCopy(defaultWeight);
      } else {
        state.weightConfigInfo = deepCopy(weightConfigInfo);
      }
    },
    setWeightDefaultConfigInfo(state, weightConfigInfo) {
      if (weightConfigInfo === null) {
        state.weightConfigDefaultInfo = deepCopy(defaultWeight);
      } else {
        state.weightConfigDefaultInfo = deepCopy(weightConfigInfo);
      }
    }
  }
};
