/**
 * 予実リスト.
 */
import {
  sendRequestGetIndicationResultList,
  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
  sendRequestGetPatientEventResultList,
  sendRequestGetObtainedInspectionItems,
  sendRequestGetInspectionResultList,
  sendRequestGetGenPhotoInsResultList,
  sendRequestGetPrescriptionResultList
  // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
} from "@/apis/indication-result";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 表示形式
    dispPattern: 1,

    /**
     * 実績情報更新日時
     */
    resultUpdate: null
  },
  mutations: {
    setDispPattern(state, dispPattern) {
      state.dispPattern = dispPattern;
    },

    /**
     * 実績情報更新日時を設定する.
     * @param {*}} state STATEオブジェクト
     * @param {*} isChange 実績情報更新日時
     */
    setResultUpdate(state, resultUpdate) {
      state.resultUpdate = resultUpdate;
    },

    setIndicationResult(state, value) {
      state.indicationResult = value;
    }
  },
  actions: {
    /**
     * 指定された患者IDから予実リストを取得する.
     * @param {*} commit commitオブジェクト
     * @param {*} patId 患者ID
     * @param {*} condition 検索条件（治療開始日と治療終了日）
     */
    getIndicationResultList({ commit }, { patId, condition }) {
      return sendRequestGetIndicationResultList(patId, condition);
    },
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
    /**
     * 患者イベント情報を取得する.
     * @param {*} commit commitオブジェクト
     * @param {*} condition 検索条件（患者ID、施設コード、治療開始日、治療終了日）
     */
    getPatientEventResultList({ commit }, { condition }) {
      return sendRequestGetPatientEventResultList(condition);
    },

    /**
     * 検査セットIDで、チェック項目数取得
     * @param {*} commit commitオブジェクト
     * @param {*} condition 検索条件 検査セットID
     */
    getObtainedInspectionItems({ commit }, { condition }) {
      return sendRequestGetObtainedInspectionItems(condition);
    },

    /**
     * 検査結果情報を取得する.
     * @param {*} commit commitオブジェクト
     * @param {*} condition 検索条件（患者ID、施設コード、治療開始日、治療終了日）
     */
    getInspectionResultList({ commit }, { condition }) {
      return sendRequestGetInspectionResultList(condition);
    },

    /**
     * 一般撮影検査予定情報を取得する.
     * @param {*} commit commitオブジェクト
     * @param {*} condition 検索条件（患者ID、施設コード、治療開始日、治療終了日）
     */
    getGenPhotoInsResultList({ commit }, { condition }) {
      return sendRequestGetGenPhotoInsResultList(condition);
    },

    /**
     * 処方情報を取得する.
     * @param {*} commit commitオブジェクト
     * @param {*} condition 検索条件（患者ID、施設コード、治療開始日、治療終了日）
     */
    getPrescriptionResultList({ commit }, { condition }) {
      return sendRequestGetPrescriptionResultList(condition);
    },
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end


    setDispPattern({ commit }, dispPattern) {
      commit("setDispPattern", dispPattern);
    },
    /**
     * 実績情報更新日時を設定する.
     * @param {*} commit COMMITオブジェクト
     * @param {*} resultUpdate 実績情報更新日時
     */
    setResultUpdate({commit}, resultUpdate) {
      commit("setResultUpdate", resultUpdate);
    }
  },
  getters: {
    getDispPattern(state) {
      return state.dispPattern;
    },
    /**
     * 実績更新日時を取得する.
     * @param {*} state STATEオブジェクト
     * @returns 実績情報更新日時
     */
    getResultUpdate(state) {
      return state.resultUpdate;
    }
  }
};
