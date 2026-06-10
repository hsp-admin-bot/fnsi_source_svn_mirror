/**
 * デバイスエッジ用ストア
 */
import { sendRequestFindDeviceEdges } from "@/apis/device-edge-operation";

export default {
  strict: true,
  namespaced: true,
  state: {
    // デバイスエッジ一覧
    deviceEdges: [],
    // 検索条件（フィルタリング用）
    condition: {
      // 部署符号
      departmentCd: "",
      // 都道府県
      prefName: "",
      // 施設名
      facilityName: "",
      // 通信異常、デバイスエッジ異常(F1,F2)
      deviceEdgeEmergency: false,
      // 手動停止(F1)
      deviceEdgeDefect: false,
      // 全選択
      deviceEdgeAll: true,
      /**
       * 未接続発生順にソートの選択状態
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
    // 緊急発報が1以上の装置件数
    emergencyCount: 0,
    // 通信不良が1件以上の装置件数
    defectCount: 0,
  },
  mutations: {
    // -----------------------------------------
    // デバイスエッジリストの設定
    // -----------------------------------------
    setDeviceEdges(state, deviceEdges) {
      state.deviceEdges = deviceEdges;
    },
    // -----------------------------------------
    // デバイスエッジリストのクリア
    // -----------------------------------------
    clearDeviceEdges(state) {
      state.deviceEdges.splice(0, state.deviceEdges.length);
    },
    // -----------------------------------------
    // 抽出条件設定
    // -----------------------------------------
    setCondition(state, condition) {
      state.condition.departmentCd = condition.departmentCd;
      state.condition.prefName = condition.prefName;
      state.condition.facilityName = condition.facilityName;
      state.condition.deviceEdgeEmergency = condition.deviceEdgeEmergency;
      state.condition.deviceEdgeDefect = condition.deviceEdgeDefect;
      state.condition.deviceEdgeAll = condition.deviceEdgeAll;
      state.condition.isAlarmSort = condition.isAlarmSort;
    },
    // -----------------------------------------
    // 抽出条件クリア
    // -----------------------------------------
    clearCondition(state) {
      state.condition.departmentCd = "-";
      state.condition.prefName = "-";
      state.condition.facilityName = "";
      state.condition.deviceEdgeEmergency = false;
      state.condition.deviceEdgeDefect = false;
      state.condition.deviceEdgeAll = true;
      state.condition.isAlarmSort = true;
    },
    // -----------------------------------------
    // 緊急発報件数が0以上の件数
    // -----------------------------------------
    setEmergencyCount(state, count) {
      state.emergencyCount = count;
    },
    // -----------------------------------------
    // 通信不良が1件以上のレコード件数
    // -----------------------------------------
    setDefectCount(state, count) {
      state.defectCount = count;
    },
    // -----------------------------------------
    // 抽出条件の部署符号及び都道府県の選択肢リストの設定
    // -----------------------------------------
    setCandidates(state, candidates) {
      state.candidates.departmentCds = candidates.departmentCds;
      state.candidates.prefectures = candidates.prefectures;
    },
  },
  actions: {
    // デバイスエッジのクリア
    clearDeviceEdges({ commit }) {
      commit("clearDeviceEdges");
    },
    // -------------------------------------------------
    // 利用者IDが管理する施設のデバイスエッジ稼働一覧取得
    // -------------------------------------------------
    findDeviceEdges({ commit }, userId) {
      // store内のリストデータをクリア
      commit("clearDeviceEdges");
      return sendRequestFindDeviceEdges(userId).then(response => {
        const deviceEdges = response.data.deviceEdges;
        // 部署符号、都道府県のセレクト用のデータを登録
        const departmentCds = response.data.departmentCds;
        const prefectures = response.data.prefectures;
        commit("setCandidates", { departmentCds, prefectures });
        // storeにリストを登録
        commit("setDeviceEdges", deviceEdges);
        // 取得したデバイスエッジリストより死活監視ステータスがF1、F2、F3
        // の件数を算出する
        let emergencyCount = 0;
        let defectCount = 0;
        for (const device of deviceEdges) {
          if (
            device.aliveMoniStatus === "F1" ||
            device.aliveMoniStatus === "F2"
          ) {
            emergencyCount += 1;
          } else if (device.aliveMoniStatus === "F0") {
            defectCount += 1;
          }
        }
        // デバイスエッジ稼働監視のheaderで使用出来るようにstateに登録
        commit("setEmergencyCount", emergencyCount);
        commit("setDefectCount", defectCount);
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
  },
  getters: {
    getDeviceEdges(state) {
      return state.deviceEdges;
    },
    getCandidates(state) {
      return state.candidates;
    },
    getEmergencyCount(state) {
      return state.emergencyCount;
    },
    getDefectCount(state) {
      return state.defectCount;
    },
    getCondition(state) {
      return state.condition;
    },
    /**
     * 未接続発生順にソート有無
     *
     * @param {*} state stateオブジェクト
     * @returns {Boolean} true : ソートする.
     *                    false : ソートなし.
     */
    isAlarmSort(state) {
      return state.condition.isAlarmSort;
    },
  }
};
