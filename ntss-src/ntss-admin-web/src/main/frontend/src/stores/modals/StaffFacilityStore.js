/**
 * 担当施設選択画面用ストア
 */
import {
  sendRequestFetchStaffFacilities,
  sendRequestSetStaffFacilities
} from "@/apis/staff-facility.js";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 検索条件
    condition: {
      // 部署符号
      departmentCd: "",
      // 都道府県
      prefName: "",
      // 施設名
      facilityName: ""
    },
    // 検索条件のセレクトボックス候補
    candidates: {
      // 重複なし部署符号
      departmentCds: [],
      // 重複なし都道府県名
      prefectureNames: []
    },
    // 施設一覧
    staffFacilities: []
  },
  mutations: {
    // -----------------------------------------
    // 抽出条件設定
    // -----------------------------------------
    setCondition(state, condition) {
      state.condition.departmentCd = condition.departmentCd;
      state.condition.prefName = condition.prefName;
      state.condition.facilityName = condition.facilityName;
    },
    // -----------------------------------------
    // 抽出条件クリア
    // -----------------------------------------
    clearCondition(state) {
      state.condition.departmentCd = "-";
      state.condition.prefName = "-";
      state.condition.facilityName = "";
    },
    // -----------------------------------------
    // 担当施設（検索結果）設定
    // -----------------------------------------
    setStaffFacilities(state, staffFacilities) {
      state.staffFacilities = staffFacilities;
    },
    // -----------------------------------------
    // 抽出条件の部署符号及び都道府県の選択肢リストの設定
    // -----------------------------------------
    setCandidates(state, candidates) {
      state.candidates.departmentCds = candidates.departmentCds;
      state.candidates.prefectureNames = candidates.prefectureNames;
    }
  },
  actions: {
    // -----------------------------------------
    // ユーザーIDに紐づく担当施設選択用一覧取得
    // -----------------------------------------
    fetchStaffFacilities({ commit }, userId) {
      return sendRequestFetchStaffFacilities(userId).then(response => {
        const staffFacilities = response.data.staffFacilities;
        const departmentCds = Array.from(
          new Set(staffFacilities.map(e => e.departmentCd))
        );
        const prefectureNames = Array.from(
          new Set(staffFacilities.map(e => e.prefecturesName))
        );
        commit("setStaffFacilities", staffFacilities);
        commit("setCandidates", { departmentCds, prefectureNames });
      });
    },
    // -----------------------------------------
    // 抽出条件クリア
    // -----------------------------------------
    clearCondition({ commit }) {
      commit("clearCondition");
    },
    // -----------------------------------------
    // 抽出条件設定
    // -----------------------------------------
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    /**
     * チェックされた値で担当者施設を設定
     */
    setStaffFacilities(context, request) {
      const userId = request.userId;
      const params = request.body;
      return sendRequestSetStaffFacilities(userId, params);
    }
  },
  getters: {
    getCondition(state) {
      return state.condition;
    },
    getCandidates(state) {
      return state.candidates;
    },
    getStaffFacilities(state) {
      return state.staffFacilities;
    }
  }
};
