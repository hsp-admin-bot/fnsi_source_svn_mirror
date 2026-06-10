/**
 * 治療記録 医療材料情報ストア
 */
import {
  sendRequestGetTreatmentRecordEquipInfo,
  sendRequestUpdateTreatmentRecordEquipInfo
} from "@/apis/treatment-record";

export default {
  strict: true,
  namespaced: true,
  state: {
    /**
     * 更新日時.
     */
    upDate: null
  },
  mutations: {
    /**
     * 更新日時を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} upDate 更新日時
     */
    setUpDate(state, upDate) {
      state.upDate = upDate;
    }
  },
  actions: {
    // -----------------------------------------
    // 医療材料情報報取得
    // -----------------------------------------
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getTreatmentRecordEquipInfo({ commit }, ordNo) {
      return sendRequestGetTreatmentRecordEquipInfo(ordNo).then(response => {
        commit("setUpDate", response.data.up_date);
        return response;
      });
    },
    // -----------------------------------------
    // 医療材料情報報更新
    // -----------------------------------------
    putTreatmentRecordEquipInfo({ commit, state }, payload) {
      return sendRequestUpdateTreatmentRecordEquipInfo(
        payload.ordNo,
        {
          ...payload.treatmentRecordEquipInfo,
          up_date: state.upDate
        }
      );
    }
  }
};
