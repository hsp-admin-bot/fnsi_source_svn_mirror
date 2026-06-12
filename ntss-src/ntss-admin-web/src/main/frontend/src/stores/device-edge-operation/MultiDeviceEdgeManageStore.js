// @ts-check
/**
 * 複数施設DE更新モーダル用ストア
 */

import {
  sendRequestDeviceEdgeUpdate,
  sendRequestDeviceEdgePlanCancel
  // @ts-ignore
} from "@/apis/device-edge-manage";
import {
  DEVICE_EDGE_MANAGE_TARGET,
  DEVICE_EDGE_MANAGE_CLASS,
  DEVICE_EDGE_MANAGE_APP_TYPE
  // @ts-ignore
} from "@/constants/deviceEdgeManageDefine";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 検索条件
    conditionToEdgeListEx: {
      // 部署符号
      departmentCd: "",
      // 都道府県
      prefName: "",
      // 施設名
      facilityName: "",
      // デバイスエッジ名
      deviceEdgeName: "",
      // 通信状態
      deviceEdgeStatus: null,
      // 予約状態
      planStatus: null
    }
  },
  mutations: {
    // -----------------------------------------
    // デバイスエッジ一括管理用抽出条件クリア
    // -----------------------------------------
    setConditionInUsed(state, condition) {
      state.conditionToEdgeListEx.departmentCd = condition.departmentCd;
      state.conditionToEdgeListEx.prefName = condition.prefName;
      state.conditionToEdgeListEx.facilityName = condition.facilityName;
      state.conditionToEdgeListEx.deviceEdgeName = condition.deviceEdgeName;
      state.conditionToEdgeListEx.deviceEdgeStatus = condition.deviceEdgeStatus;
      state.conditionToEdgeListEx.planStatus = condition.planStatus;
    },
    // -----------------------------------------
    // デバイスエッジ一括管理用抽出条件クリア
    // -----------------------------------------
    clearConditionInUsed(state) {
      state.conditionToEdgeListEx.departmentCd = "-";
      state.conditionToEdgeListEx.prefName = "-";
      state.conditionToEdgeListEx.facilityName = "";
      state.conditionToEdgeListEx.deviceEdgeName = "";
      state.conditionToEdgeListEx.deviceEdgeStatus = null;
      state.conditionToEdgeListEx.planStatus = null;
    }
  },
  actions: {
    // -----------------------------------------
    // デバイスエッジ一括管理用抽出条件クリア
    // -----------------------------------------
    clearCondToEdgeListEx({ commit }) {
      commit("clearConditionInUsed");
    },
    // -----------------------------------------
    // デバイスエッジ一括管理用抽出条件設定
    // -----------------------------------------
    commitCondToEdgeListEx({ commit }, condition) {
      commit("setConditionInUsed", condition);
    },
    /**
     *
     * 全更新予約指示
     * @param {Object} context
     * @param {Object} payload
     */
    orderDeviceEdgeUpdatePlanAll(context, payload) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: payload.deviceEdgeNo,
        targetFacilityCd: payload.facilityCd,
        bucket: payload.uploadBucket,
        fileName: payload.fileName,
        appType: DEVICE_EDGE_MANAGE_APP_TYPE.ALL,
        planDate: payload.planDate ? payload.planDate : null,
        manageParam: {
          facilityCd: payload.facilityCd,
          deviceEdgeNo: payload.deviceEdgeNo,
          orderClass: DEVICE_EDGE_MANAGE_CLASS.UPDATE,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.UPDATER,
          manageInfo: ""
        }
      };
      return sendRequestDeviceEdgeUpdate(deviceEdgeManageRequest);
    },
    /**
     *
     * 全更新予約キャンセル指示
     * @param {Object} context
     * @param {Object} payload
     */
    orderDeviceEdgePlanCancel(context, payload) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: payload.deviceEdgeNo,
        targetFacilityCd: payload.facilityCd,
        bucket: "",
        fileName: "",
        manageParam: {
          facilityCd: payload.facilityCd,
          deviceEdgeNo: payload.deviceEdgeNo,
          orderClass: DEVICE_EDGE_MANAGE_CLASS.PLAN_CANCEL,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.UPDATER,
          manageInfo: ""
        }
      };
      return sendRequestDeviceEdgePlanCancel(deviceEdgeManageRequest);
    }
  },
  getters: {
    getCondToEdgeListEx(state) {
      return state.conditionToEdgeListEx;
    }
  }
};
