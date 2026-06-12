/**
 * 申込一覧ストア
 */
import { sendRequestFetchFacilities } from "@/apis/operation-viewer";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 検索条件のセレクトボックス候補
    candidates: {
      // 重複なし部署符号
      departmentCds: [],
      // 重複なし都道府県名
      prefectures: []
    },
    condition: {
      startDate: "",
      endDate: "",
      departmentCd: "すべて",
      prefecturesCd: "すべて",
      freeWord: "",
      subscriptionStatusList: ["0", "1"],
      myAccepted: false
    },
    filterApplication: false
  },
  mutations: {
    // -----------------------------------------
    // 抽出条件の部署符号及び都道府県の選択肢リストの設定
    // -----------------------------------------
    setCandidates(state, candidates) {
      state.candidates.departmentCds = candidates.departmentCds;
      state.candidates.prefectures = candidates.prefectures;
    },
    // 抽出条件を設定する。
    setCondition(state, condition) {
      state.condition = condition;
    },
    // 申し込みをフィルターする。
    setFilterApplication(state, filterApplication) {
      state.filterApplication = filterApplication;
    }
  },
  actions: {
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    setFilterApplication({ commit }, filterApplication) {
      commit("setFilterApplication", filterApplication);
    },
    // -----------------------------------------
    // ユーザーIDに紐づく施設一覧取得
    // -----------------------------------------
    fetchFacilities({ commit }, userId) {
      return sendRequestFetchFacilities(userId).then(response => {
        const departmentCds = response.data.departmentCds;
        const prefectures = response.data.prefectures;
        commit("setCandidates", { departmentCds, prefectures });
      });
    }
  },
  getters: {
    getCandidates: state => {
      return state.candidates;
    },
    getCondition: state => {
      return state.condition;
    }
  }
};
