/**
 * 体重計状態取得
 */

import { sendRequestGetWeightState } from "@/apis/weight-state";

export default {
  strict: !import.meta.env.PROD,
  namespaced: true,
  state: {
    weightState: {
      weightCd: -1,
      isConnect: "0",
      scaleValue: null,
      barcodeValue: "",
      cardReadValue: {},
      cardWriteValue: {},
      writeResult: 0,
      regDate: null,
      upDate: null
    }
  },
  getters: {
    /**
     * 体重計状態取得
     */
    getWeightState: state => state.weightState,
    /**
     * 体重接続状態取得
     */
    getWeightIsConnect: state => state.weightState.isConnect,
    /**
     * 体重測定値取得
     */
    getWeightScaleValue: state => state.scaleValue,
    /**
     * バーコード読み取り値取得
     */
    getWeightBarcodeValue: state => state.barcodeValue,
    /**
     * カード読み取り値取得
     */
    getWeightCardReadValue: state => state.cardReadValue,
    /**
     * カード書き込み結果取得
     */
    getWeightCardWriteResult: state => state.writeResult
  },
  actions: {
    fetchWeightState(context, weightCd) {
      if (weightCd !== null) {
        return sendRequestGetWeightState(weightCd);
      }
    },
    setWeightState({ commit }, weightState) {
      commit("setWeightState", weightState);
    }
  },
  mutations: {
    setWeightState(state, weightState) {
      state.weightState = weightState;
    }
  }
};
