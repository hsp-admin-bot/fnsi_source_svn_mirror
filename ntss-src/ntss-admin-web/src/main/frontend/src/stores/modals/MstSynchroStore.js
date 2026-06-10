/**
 * マスタ同期画面用ストア
 */
import {
  sendRequestGetMstFacilityList,
  sendRequestGetMstDeviceEdgeList,
  sendRequestStartMstSynchro,
  sendRequestStartMstSynchroProc
} from "@/apis/mst-synchro.js";

/**
 * デバイスエッジ一覧の選択肢[すべて]の定義
 */
const allDeviceEdge = { deviceEdgeNo: -1, deviceName: "すべて" };

export default {
  strict: true,
  namespaced: true,
  /**
   * state
   */
  state: {
    // 同期対象マスタ一覧(現状は静的)
    mstSynchroList: [
      { code: "mst_machine", name: "装置マスタ" },
      { code: "mst_m_notice", name: "緊急発報マスタ" }
    ],
    // 施設一覧
    facilityList: [{ facilityCd: null, facilityName: null }],
    // 選択施設のデバイスエッジ一覧
    deviceEdgeList: [allDeviceEdge]
  },
  /**
   * mutations
   */
  mutations: {
    // 施設一覧設定
    setFacilityList(state, facilityList) {
      state.facilityList = facilityList;
    },
    // デバイスエッジ一覧設定
    setDeviceEdgeList(state, deviceEdgeList) {
      state.deviceEdgeList = deviceEdgeList;
    }
  },
  /**
   * actions
   */
  actions: {
    // 施設マスタ情報取得
    async getMstFacilityList({ commit }) {
      return sendRequestGetMstFacilityList().then(response => {
        const facilityList = response.data.facilityList;
        commit("setFacilityList", facilityList);
      });
    },
    // 選択施設のデバイスエッジ情報取得
    async getMstDeviceEdgeList({ commit }, facilityCd) {
      return sendRequestGetMstDeviceEdgeList(facilityCd).then(response => {
        const deviceEdgeList = response.data.deviceEdgeList;
        deviceEdgeList.unshift(allDeviceEdge);
        commit("setDeviceEdgeList", deviceEdgeList);
      });
    },
    // 同期開始要求
    async startMstSynchro(context, request) {
      return sendRequestStartMstSynchro(request);
    },
    // 同期開始要求(マスタ同期(隠し画面))
    async startMstSynchroProc(context, request) {
      return sendRequestStartMstSynchroProc(request);
    }
  },
  /**
   * Getter
   */
  getters: {
    // 同期対象マスタ一覧
    getMstSynchroList(state) {
      return state.mstSynchroList;
    },
    // 施設一覧
    getFacilityList(state) {
      return state.facilityList;
    },
    // デバイスエッジ一覧
    getDeviceEdgeList(state) {
      return state.deviceEdgeList;
    }
  }
};
