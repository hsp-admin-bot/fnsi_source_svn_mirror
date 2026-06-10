/**
 * ベッドマスタメンテナンスStore.
 */
import {
  sendRequestGetMstFacility
} from "@/apis/mst-user-maintenance";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 施設リスト
    facilityList: [],
    // 選択施設のシステム利用
    facilitySysUseSetting: null,
  },
  mutations: {
    // 施設情報を設定
    setFacilityList(state, facilityList) {
      state.facilityList = facilityList;
    },
    // 選択施設のシステム利用設定
    setFacilitySysUseSetting(state, facilitySysUseSetting) {
      state.facilitySysUseSetting = facilitySysUseSetting;
    },
  },
  actions: {
    /**
     * 施設データ一覧を取得
     */
    facilityList({ commit }) {
      commit("setFacilityList", []);
      return sendRequestGetMstFacility().then(response => {
        commit("setFacilityList", response.data);
      });
    },
    /**
     * 施設情報を設定
     */
    setFacilityList({ commit }, facilityList) {
      commit("setFacilityList", facilityList);
    },
    //選択施設のシステム利用設定を格納
    setFacilitySysUseSetting({ commit }, facilitySysUseSetting) {
      commit("setFacilitySysUseSetting", facilitySysUseSetting);
    },
  },
  getters: {
    getFacilityList(state) {
      return state.facilityList;
    },
    // 選択施設のシステム利用設定を取得
    getFacilitySysUseSetting(state) {
      return state.facilitySysUseSetting;
    },
  }
};
