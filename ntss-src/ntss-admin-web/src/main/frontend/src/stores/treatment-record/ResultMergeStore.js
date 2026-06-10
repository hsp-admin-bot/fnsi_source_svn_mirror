/**
 * 治療記録 実績マージストア
 */
import {
  sendRequestGetResultMergeList,
  sendRequestUpdateResultMerge,
  sendRequestGetResultMergeListForSelect
} from "@/apis/treatment-record";

export default {
  strict: true,
  namespaced: true,
  //add FNSI修正486改修 房 start
  state:{
    searchParam: null,
    paramData: null,
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
    mergeOrderNo: null,
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end
  },
  mutations:{
    setSearchParam(state, param) {
      state.searchParam = param;
    },
    setParamData(state, param) {
      state.paramData = param;
    },
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
    setMergeOrderNo(state, param) {
      state.mergeOrderNo = param;
    }
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end
  },
  //add FNSI修正486改修 房 end
  actions: {
    /**
     * マージ対象実績情報リスト取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getTreatmentRecordResultMergeList({ commit }, ordNo) {
      return sendRequestGetResultMergeList(ordNo);
    },
    /**
     * マージ後実績情報更新.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     * @param {*} payload マージ後実績情報
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    updateTreatmentRecordResultMerge({ commit }, { ordNo, payload }) {
      return sendRequestUpdateResultMerge(ordNo, payload);
    },
    //add FNSI修正486改修 房 start
    setSearchParam({ commit }, param) {
      commit("setSearchParam", param);
    },
    setParamData({ commit }, param) {
      commit("setParamData", param);
    },
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
    setMergeOrderNo({ commit }, param) {
      commit("setMergeOrderNo", param);
    },
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end
    /**
     * マージ対象実績情報リスト取得.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} ordNo オーダ番号
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    getResultMergeList({ commit }, params) {
      return sendRequestGetResultMergeListForSelect(params.ord_no, params.start_date, params.end_date, params.is_unknown);
    },
  },
  getters: {
    getSearchParam(state) {
      return state.searchParam;
    },
    getParamData(state) {
      return state.paramData;
    },
    //add FNSI修正486改修 房 end
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
    getMergeOrderNo(state) {
      return state.mergeOrderNo;
    },
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end
  }
};
