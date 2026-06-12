/**
 * 治療記録 治療条件ストア
 */
import {
  sendRequestGetTreatmentRecordCondition,
  sendRequestUpdateTreatmentRecordCondition
} from "@/apis/treatment-record";

export default {
  strict: true,
  namespaced: true,
  state: {},
  actions: {
    // -----------------------------------------
    // 治療条件取得
    // -----------------------------------------
    // TODO: 局所的なeslintの設定を削除する
    getTreatmentRecordCondition({ commit }, payload) {
      const ordNo = payload && typeof payload === "object" ? payload.ordNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetTreatmentRecordCondition(ordNo, selectedPatId);
    },
    // -----------------------------------------
    // 治療条件更新
    // -----------------------------------------
    updateTreatmentRecordCondition({ commit }, payload) {
      const ordNo = payload.ordNo;
      const treatmentRecordCondition = payload.treatmentRecordCondition;
      return sendRequestUpdateTreatmentRecordCondition(
        ordNo,
        treatmentRecordCondition
      );
    }
  }
};
