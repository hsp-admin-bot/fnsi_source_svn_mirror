/**
 * 治療記録 モニタストア
 */
import {
  sendRequestGetTreatmentRecordMonitor,
  sendRequestGetMonitorGraphDefine,
  sendRequestGetSysMonitorItem,
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
  sendRequestGetMstAddMonitorAll,
  //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
  sendRequestGetMstAddMonitor
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
     * モニタ取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    getTreatmentRecordMonitor({ commit }, payload) {
      const ordNo = payload && typeof payload === "object" ? payload.ordNo : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetTreatmentRecordMonitor(ordNo, selectedPatId);
    },
    /**
     * モニタグラフ設定取得.
     *
     * @param {*} commit commitオブジェクト
     */
    // TODO: 局所的なeslintの設定を削除する
    getMonitorGraphDefine({ commit }, payload) {
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      return sendRequestGetMonitorGraphDefine(selectedPatId);
    },
    /**
     * モニタ項目取得.
     * @param {*} commit commitオブジェクト
     * @param {*} param 検索条件(moniDataType,vitalMonitorClass)
     * @returns モニタ項目のリスト
     */
    getSysMonitorItem({ commit }, param) {
      return sendRequestGetSysMonitorItem(param, param?.selectedPatId);
    },
    /**
     * 個別モニタ項目取得.
     * @param {String} vitalMonitorClass バイタルモニタ区分
     * @returns 個別モニタ項目のリスト
     */
    getMstAddMonitor({ commit }, { vitalMonitorClass, facilityCd }) {
      return sendRequestGetMstAddMonitor(vitalMonitorClass, facilityCd);
      //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
    },
    /**
     * モニタ項目取得.
     * @returns モニタ項目のリスト
     */
    getMstAddMonitorAll({ commit }, facilityCd) {
      return sendRequestGetMstAddMonitorAll(facilityCd);
      //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
    }
  }
};
