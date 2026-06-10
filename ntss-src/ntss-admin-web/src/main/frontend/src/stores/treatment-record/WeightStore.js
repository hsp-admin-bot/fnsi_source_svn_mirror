/**
 * 治療記録 体重ストア
 */
import {
  sendRequestGetRecirculationRate,
  sendRequestGetTreatmentRecordWeight,
  sendRequestUpdateTreatmentRecordWeight
} from "@/apis/treatment-record";

import {
  sendRequestPutStateSavedAfterWeight
} from "@/apis/send-condition";

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 入力対象が前体重なのか、後体重なのかを、
     * 透析前・後体重入力モーダル内で判定するためのフラグ.
     */
    inputAfterWeight: false,
    /**
     * モーダルで表示する情報を格納するモデル.
     */
    weightModal: null,
    /**
     * 更新日時.
     */
    upDate: null,
    /**
     * 治療状況
     */
    rstDialysisState: null,
    /**
     * 治療終了日時
     */
    rstEndDate: null
  },
  mutations: {
    /**
     * 入力対象が前体重なのか、後体重なのかを設定する.
     * @param {*} state STATEオブジェクト
     * @param {Boolean} inputAfterWeight "true"の場合、後体重の入力
     */
    setInputAfterWeight(state, inputAfterWeight) {
      state.inputAfterWeight = inputAfterWeight;
    },
    /**
     * 体重モデル（モーダル用）を設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} weightModal 体重モデル（モーダル用）
     */
    setWeightModal(state, weightModal) {
      state.weightModal = weightModal;
    },
    /**
     * 更新日時を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} upDate 更新日時
     */
    setUpDate(state, upDate) {
      state.upDate = upDate;
    },
    /**
     * 治療状況を設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} rstDialysisState 治療状況
     */
    setRstDialysisState(state, rstDialysisState) {
      state.rstDialysisState = rstDialysisState;
    },
    /**
     * 治療終了日時を設定する.
     * @param {*} state STATEオブジェクト
     * @param {*} rstEndDate 治療終了日時
     */
    setRstEndDate(state, rstEndDate) {
      state.rstEndDate = rstEndDate;
    }
  },
  actions: {
    /**
     * モーダル表示に必要な情報を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} object inputAfterWeight："true"の場合、後体重の入力。weightModal：体重モデル（モーダル用）
     */
    setModalInfo({ commit }, { inputAfterWeight, weightModal }) {
      commit("setInputAfterWeight", inputAfterWeight);
      commit("setWeightModal", weightModal);
    },
    /**
     * 再循環率取得.
     * @param {*} commit COMMITオブジェクト
     * @param {*} ordNo オーダ番号
     */
    /* eslint-disable no-unused-vars */
    getRecirculationRate({ commit }, ordNo) {
      /* eslint-enable no-unused-vars */
      return sendRequestGetRecirculationRate(ordNo);
    },
    /**
     * 体重情報取得.
     * @param {*} commit COMMITオブジェクト
     * @param {*} ordNo オーダ番号
     */
    /* eslint-disable no-unused-vars */
    getTreatmentRecordWeight({ commit }, ordNo) {
      /* eslint-enable no-unused-vars */
      return sendRequestGetTreatmentRecordWeight(ordNo).then(response => {
        commit("setUpDate", response.data.up_date);
        commit("setRstDialysisState", response.data.rst_dialysis_state);
        commit("setRstEndDate", response.data.rst_end_date);
        return response;
      });
    },
    /**
     * 体重情報更新.
     * @param {*} commit COMMITオブジェクト
     * @param {*} payload オーダ番号、体重情報を含むオブジェクト
     */
    /* eslint-disable no-unused-vars */
    updateTreatmentRecordWeight({ commit, state }, payload) {
      /* eslint-enable no-unused-vars */
      const ordNo = payload.ordNo;
      const treatmentRecordWeight = payload.treatmentRecordWeight;
      return sendRequestUpdateTreatmentRecordWeight(
        ordNo,
        {
          ...treatmentRecordWeight,
          up_date: state.upDate
        }
      );
    },
    /**
     * 後体重測定済み状態にする
     * @param {*}} context vueコンテクスト
     * @param {Object} payload オーダー番号を含むオブジェクト
     * @param {Number} payload.ordNo オーダー番号
     */
    updateTreatmentRecordStateAfterWeight(context, payload) {
      const ordNo = payload.ordNo;
      return sendRequestPutStateSavedAfterWeight({ordNo: ordNo});
    }
  },
  getters: {
    /**
     * 入力対象が前体重なのか、後体重なのかを判定する.
     * @param {*} state STATEオブジェクト
     */
    isInputAfterWeight(state) {
      return state.inputAfterWeight;
    },
    /**
     * 体重モデル（モーダル用）を取得する.
     * @param {*} state STATEオブジェクト
     */
    getWeightModal(state) {
      return state.weightModal;
    },
    /**
     * 更新日時を取得する.
     * @param {*} state STATEオブジェクト
     */
    getUpDate(state) {
      return state.upDate;
    },
    /**
     * 治療状況を取得する.
     * @param {*}} state STATEオブジェクト
     */
    getRstDialysisState(state) {
      return state.rstDialysisState;
    },
    /**
     * 治療終了日時を取得する.
     * @param {*}} state STATEオブジェクト
     */
    getRstEndDate(state) {
      return state.rstEndDate;
    }
  }
};
