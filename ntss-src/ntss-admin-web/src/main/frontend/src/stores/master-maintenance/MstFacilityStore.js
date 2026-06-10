/**
 * 施設マスタStore.
 */
import { sendRequestGetMstFacilityHash } from "@/apis/mst-facility-hash";

export default {
  strict: true,
  namespaced: true,
  state: {
    // マスタレコード(ハッシュ)
    masterHashRecordList: []
  },
  mutations: {
    setMasterHashRecordList(state, masterHashRecordList) {
      state.masterHashRecordList = masterHashRecordList;
    }
  },
  actions: {
    // -----------------------------------------
    // データ一覧を取得(mst_facility_hash)
    // -----------------------------------------
    findHashRecordList({ commit }) {
      // データのカラム数により前のデータ内容が残る場合があるため領域を初期化
      // APIからの読込だけではデータが残る場合があるため事前に初期化
      // 対応方法については検討の余地あり (#2482)
      commit("setMasterHashRecordList", []);
      return sendRequestGetMstFacilityHash().then(
        response => {
          commit("setMasterHashRecordList", response.data);
          return Promise.resolve(response);
        }
      );
    },
    // -----------------------------------------
    // データ一覧を更新
    // -----------------------------------------
    /* eslint-disable no-unused-vars */
    setMasterHashRecordList({ commit }, masterHashRecordList) {
      commit("setMasterHashRecordList", masterHashRecordList);
    }
  },
  getters: {
    getMasterHashRecordList(state) {
      return state.masterHashRecordList;
    }
  }
};
