/**
 * 稼働ビューア施設一覧用ストア
 */
import { sendRequestFetchFacilities } from "@/apis/operation-viewer";

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
      facilityName: "",
      // 緊急発報(チェックボックス)
      facilityEmergency: false,
      // 予防保守(チェックボックス)
      facilityProphylaxis: false,
      // 通信不良(チェックボックス)
      facilityDefect: false,
      // 全選択
      facilityAll: true,
      /**
       * 警報通知発生降順にソートの選択状態
       */
      isAlarmSort: true
    },
    // 検索条件のセレクトボックス候補
    candidates: {
      // 重複なし部署符号
      departmentCds: [],
      // 重複なし都道府県名
      prefectures: []
    },
    // 施設一覧
    facilities: [],
    // 緊急発報が1以上の施設件数
    emergencyCount: 0,
    // 予防保守が1件以上の施設件数
    prophylaxisCount: 0,
    // 通信不良が1件以上の施設件数
    defectCount: 0,
    // サービス対応件数
    serviceSupportCount: 0,
    // 強制サインアウトフラグ (0:自動サインアウトする、1:自動サインアウトしない)
    forceSignOutFlag: 0,
  },
  mutations: {
    // -----------------------------------------
    // 抽出条件設定
    // -----------------------------------------
    setCondition(state, condition) {
      // mod FNSI redmine #4243 修正 鄧シン start
      // state.condition.departmentCd = condition.departmentCd;
      // state.condition.prefName = condition.prefName;
      state.condition.departmentCd = condition.departmentCd == "すべて" ? "" : condition.departmentCd;
      state.condition.prefName = condition.prefName == "すべて" ? "" : condition.prefName;
      // mod FNSI redmine #4243 修正 鄧シン end
      state.condition.facilityName = condition.facilityName;
      state.condition.facilityEmergency = condition.facilityEmergency;
      state.condition.facilityProphylaxis = condition.facilityProphylaxis;
      state.condition.facilityDefect = condition.facilityDefect;
      state.condition.facilityAll = condition.facilityAll;
      state.condition.isAlarmSort = condition.isAlarmSort;
    },
    // -----------------------------------------
    // 抽出条件クリア
    // -----------------------------------------
    clearCondition(state) {
      // mod FNSI redmine #4243 修正 鄧シン start
      // state.condition.departmentCd = "-";
      // state.condition.prefName = "-";
      state.condition.departmentCd = "すべて";
      state.condition.prefName = "すべて";
      // mod FNSI redmine #4243 修正 鄧シン end
      state.condition.facilityName = "";
      state.condition.facilityEmergency = false;
      state.condition.facilityProphylaxis = false;
      state.condition.facilityDefect = false;
      state.condition.facilityAll = true;
      state.condition.isAlarmSort = true;
    },
    // -----------------------------------------
    // 施設一覧（検索結果）設定
    // ※与えられた結果を追加する
    // -----------------------------------------
    setFacilities(state, facilities) {
      facilities.forEach(e => {
        state.facilities.push(e);
      });
    },
    // -----------------------------------------
    // 抽出条件の部署符号及び都道府県の選択肢リストの設定
    // -----------------------------------------
    setCandidates(state, candidates) {
      state.candidates.departmentCds = candidates.departmentCds;
      state.candidates.prefectures = candidates.prefectures;
    },
    // -----------------------------------------
    // 施設一覧をクリア
    // -----------------------------------------
    clearFacilities(state) {
      state.facilities.splice(0, state.facilities.length);
    },
    // -----------------------------------------
    // 緊急発報件数が0以上の件数
    // -----------------------------------------
    setEmergencyCount(state, count) {
      state.emergencyCount = count;
    },
    // -----------------------------------------
    // 予防保守が1件以上のレコード件数
    // -----------------------------------------
    setProphylaxisCount(state, count) {
      state.prophylaxisCount = count;
    },
    // -----------------------------------------
    // 通信不良が1件以上のレコード件数
    // -----------------------------------------
    setDefectCount(state, count) {
      state.defectCount = count;
    },
    /**
     * サービス対応件数を設定する.
     *
     * @param {*} state stateオブジェクト
     * @param {Number} count サービス対応件数
     */
    setServiceSupportCount(state, count) {
      state.serviceSupportCount = count;
    },
    setForceSignOutFlag(state, forceSignOutFlag) {
      state.forceSignOutFlag = forceSignOutFlag;
    },
  },
  actions: {
    // -----------------------------------------
    // 施設一覧をクリア
    // -----------------------------------------
    clearFacilities({ commit }) {
      commit("clearFacilities");
    },
    // -----------------------------------------
    // ユーザーIDに紐づく施設一覧取得
    // -----------------------------------------
    fetchFacilities({ commit }, {userId, autoRefreshFlag}) {
      return sendRequestFetchFacilities(userId, autoRefreshFlag).then(response => {
        const facilities = response.data.facilities;
        commit("clearFacilities");
        commit("setFacilities", facilities);
        const departmentCds = response.data.departmentCds;
        const prefectures = response.data.prefectures;
        commit("setCandidates", { departmentCds, prefectures });
        // 取得した施設一覧より緊急発報件数及び予防保守件数、通信不良件数が1件以上の件数を算出する
        let emergencyCount = 0;
        let prophylaxisCount = 0;
        let defectCount = 0;
        let serviceSupportCount = 0;
        for (let idx = 0; idx < facilities.length; idx++) {
          if (facilities[idx].mNoticeCnt > 0) {
            emergencyCount += 1;
          }
          if (facilities[idx].preventiveCnt > 0) {
            prophylaxisCount += 1;
          }
          if (facilities[idx].comProblemCnt > 0) {
            defectCount += 1;
          }
          if (facilities[idx].serviceSupportCnt > 0) {
            serviceSupportCount += 1;
          }
        }
        // 施設一覧のheaderで使用出来るようにstateに登録
        commit("setEmergencyCount", emergencyCount);
        commit("setProphylaxisCount", prophylaxisCount);
        commit("setDefectCount", defectCount);
        commit("setServiceSupportCount", serviceSupportCount);
      });
    },
    // -----------------------------------------
    // 検索条件に対応する施設一覧取得
    // -----------------------------------------
    findFacilities({ commit }, condition) {
      commit("setCondition", condition);
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
    // -----------------------------------------
    // 強制サインアウトフラグ設定
    // -----------------------------------------
    setForceSignOutFlag({ commit }, forceSignOutFlag) {
      commit("setForceSignOutFlag", forceSignOutFlag);
    },
  },
  getters: {
    getFacilities(state) {
      return state.facilities;
    },
    getCondition(state) {
      return state.condition;
    },
    getCandidates(state) {
      return state.candidates;
    },
    getEmergencyCount(state) {
      return state.emergencyCount;
    },
    getProphylaxisCount(state) {
      return state.prophylaxisCount;
    },
    getDefectCount(state) {
      return state.defectCount;
    },
    /**
     * サービス対応件数を取得する.
     *
     * @param {*} state stateオブジェクト
     * @returns サービス対応件数
     */
    getServiceSupportCount(state) {
      return state.serviceSupportCount;
    },
    /**
     * 警報通知発生降順ソート有無
     *
     * @param {*} state stateオブジェクト
     * @returns {Boolean} true : 降順にソートする.
     *                    false : ソートなし.
     */
    isAlarmSort(state) {
      return state.condition.isAlarmSort;
    },
    getForceSignOutFlag: state => state.forceSignOutFlag,
  }
};
