/**
 * リリース情報モーダル用ストア
 */
import {
  sendRequestGetSySReleaseInfo,
  sendRequestGetReleaseDetail
} from "@/apis/sys-release-info.js";

export default {
  strict: true,
  namespaced: true,
  /**
   * state
   */
  state: {
    // リリース情報一覧
    releaseInfos: [],
    // リリース明細情報
    releaseDetail: null
  },
  /**
   * mutations
   */
  mutations: {
    // リリース一覧設定
    setReleaseInfos(state, releaseInfos) {
      state.releaseInfos = releaseInfos;
    },
    // リリース明細情報
    setReleaseDetail(state, releaseDetail){
      state.releaseDetail = releaseDetail;
    }
  },
  /**
   * actions
   */
  actions: {
    // 施設マスタ情報取得（全件)
    async getSystemReleaseInfosAll({ commit }) {
      return sendRequestGetSySReleaseInfo().then(response => {
        const releaseInfo = response.data;
        commit("setReleaseInfos", releaseInfo);
      });
    },

    // 施設マスタ情報取得（明細)
    async getReleaseDetail({ commit }, ctlNo) {
      return sendRequestGetReleaseDetail(ctlNo).then(response => {
        const detail = response.data;
        commit("setReleaseDetail", detail);
      });
    },

  },
  /**
   * Getter
   */
  getters: {
    // 同期対象マスタ一覧
    getReleaseInfosAll(state) {
      return state.releaseInfos;
    },
    // 対象マスタ明細
    getDetail(state) {
      return state.releaseDetail;
    }
  }
};
