/**
 * 治療記録 バイタルストア
 */
import {
  sendRequestGetTreatmentRecordVitalMonitor,
  sendRequestGetTreatmentRecordResult,
  sendRequestUpdateTreatmentRecordVitalForMniMonitor,
  sendRequestGetVitalGraphDefine
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
    /**
     * バイタルモニタ取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} facilityCd 施設番号
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    getTreatmentRecordVitalMonitor({ commit }, { facilityCd, ordNo, selectedPatId }) {
      return sendRequestGetTreatmentRecordVitalMonitor(facilityCd, ordNo, selectedPatId);
    },
    /**
     * 実績情報取得
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     * @return オーダ番号に該当する実績情報
     */
    getTreatmentRecordResult({commit}, payload) {
      const ordNo = payload && typeof payload === "object" ? payload.ordNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetTreatmentRecordResult(ordNo, selectedPatId);
    },
    /**
     * バイタル更新.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} state stateオブジェクト
     * @param {*} ordNo オーダ番号
     * @param {*} payload バイタル情報
     */
    // TODO: 局所的なeslintの設定を削除する
    updateTreatmentRecordVitalForMniMonitor({ commit, state }, { ordNo, payload }) {
      return sendRequestUpdateTreatmentRecordVitalForMniMonitor(
        ordNo,
        {
          vital_data: payload
        }
      );
    },
    //add FNSI-改修内容 グラフ様式修正 房 start
    /**
     * バイタルグラフ設定取得.
     *
     * @param {*} commit commitオブジェクト
     */
    getVitalGraphDefine({ commit }, payload) {
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetVitalGraphDefine(facilityCd, selectedPatId);
    },
    //add FNSI-改修内容 グラフ様式修正 房 end
  }
};
