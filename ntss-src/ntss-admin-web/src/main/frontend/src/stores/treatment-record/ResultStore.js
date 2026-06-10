/**
 * 治療記録 実績情報ストア
 */
import {
  sendRequestGetmonistatus,
  sendRequestGetTreatmentRecordResult,
  sendRequestUpdateTreatmentRecordResult,
  sendRequestUpdateTreatmentRecordResultWithCondition,
  sendRequestUpdateMniMachineState,
  selectMedicalCareInfoByIdAndFacilityCd
} from "@/apis/treatment-record";

export default {
  strict: true,
  namespaced: true,
  state: {},
  actions: {
    // -----------------------------------------
    // 実績情報取得
    // -----------------------------------------
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getTreatmentRecordResult({ commit }, ordNo) {
      return sendRequestGetTreatmentRecordResult(ordNo);
    },
    //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
    getMedicalCareInfo({commit},payload){
      return selectMedicalCareInfoByIdAndFacilityCd(payload.facilityCd,payload.patId);
    },
    //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
    // -----------------------------------------
    // 実績情報更新
    // -----------------------------------------
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    updateTreatmentRecordResult({ commit }, payload) {
      const ordNo = payload.ordNo;
      const treatmentRecordResult = payload.treatmentRecordResult;
      return sendRequestUpdateTreatmentRecordResult(
        ordNo,
        treatmentRecordResult
      );
    },
    // -----------------------------------------
    // 実績情報更新
    // ※処理区分に応じて治療条件の更新を行う.
    // -----------------------------------------
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    updateTreatmentRecordResultWithCondition({ commit }, payload) {
      const ordNo = payload.ordNo;
      const treatmentRecordResult = payload.treatmentRecordResult;
      const processType = payload.processType;
      return sendRequestUpdateTreatmentRecordResultWithCondition(
        ordNo,
        treatmentRecordResult,
        processType
      );
    },
    //ベッド切替
    updateMniMachineState({ commit }, payload) {
      return sendRequestUpdateMniMachineState(
        payload.ordNo,
        payload.bedNo
      );
    },
    // -----------------------------------------
    // 死活監視ステータス取得
    // -----------------------------------------
    getmonistatus({ commit },deviceEdgeNo) {
      return sendRequestGetmonistatus(deviceEdgeNo);
    },
  }
};
