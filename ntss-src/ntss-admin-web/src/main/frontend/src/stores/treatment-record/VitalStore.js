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
    /* eslint-disable no-unused-vars */
    getTreatmentRecordVitalMonitor({ commit }, { facilityCd, ordNo }) {
      return sendRequestGetTreatmentRecordVitalMonitor(facilityCd, ordNo);
    },
    /**
     * 実績情報取得
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     * @return オーダ番号に該当する実績情報
     */
    getTreatmentRecordResult({commit}, ordNo) {
      return sendRequestGetTreatmentRecordResult(ordNo);
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
    /* eslint-disable no-unused-vars */
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
    getVitalGraphDefine({ commit }, facilityCd) {
      return sendRequestGetVitalGraphDefine(facilityCd);
    },
    //add FNSI-改修内容 グラフ様式修正 房 end
  }
};
