//@ts-check

import {
  sendRequestDeviceEdgeStateAll,
  sendRequestDeviceEdgeState,
  sendRequestBaseBucket,
  sendRequestDeviceEdgeControl,
  sendRequestDeviceEdgeFileGather,
  sendRequestDeviceEdgeLogFileInfo,
  sendRequestDeviceEdgeLogFileDownload,
  sendRequestDeviceEdgeConfFileInfo,
  sendRequestDeviceEdgeConfFileUploadInfo,
  sendRequestFileUpload,
  sendRequestDeviceEdgeConfUpdate,
  sendRequestDeviceEdgeRestore,
  sendRequestDeviceEdgeUpdate
  // @ts-ignore
} from "@/apis/device-edge-manage";
// @ts-ignore
import {
  DEVICE_EDGE_MANAGE_TARGET,
  DEVICE_EDGE_MANAGE_APP_TYPE
} from "@/constants/deviceEdgeManageDefine";
// @ts-ignore
import { sendRequestFetchDetailGatheringDownload } from "@/apis/operation-viewer.js";
import { getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

/**
 * デバイスエッジアップデータ操作画面のStore
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    selectedDeviceEdge: null,
    // ダウンロード対象
    dlTarget: {
      fileData: {
        bucket: "",
        fileName: ""
      }
    },
    // ダウンロードファイルの中身
    downloadData: ""
  },
  getters: {
    getSelectedDeviceEdge: state => state.selectedDeviceEdge,

    getSelectedDeviceEdge2digitNo: state =>
      `${"00"}${state.selectedDeviceEdge.deviceEdgeNo}`.slice(-2),

    getDlTarget: state => state.dlTarget,

    getDownloadData: state => state.downloadData
  },
  actions: {
    setDeviceEdgeInfo({ commit }, deviceEdge) {
      commit("setDeviceEdgeInfo", deviceEdge);
    },
    setDlTargetInfo({ commit }, fileData) {
      commit("setDlTargetInfo", fileData);
    },
    /**
     * デバイスエッジ状態取得、主にバージョン情報のため
     */
    fetchDeviceEdgeState({ state }) {
      const request = {
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        targetFacilityCd: state.selectedDeviceEdge.facilityCd
      };
      return sendRequestDeviceEdgeState(request);
    },
    /**
     * 施設内全デバイスエッジ状態取得
     */
    fetchDeviceEdgeStateAll() {
      return sendRequestDeviceEdgeStateAll();
    },
    /**
     * バケット情報取得
     */
    fetchDeviceEdgeBaseBucket() {
      return sendRequestBaseBucket();
    },
    /**
     * デバイスエッジアプリ起動制御、またはOS再起動の命令を行う
     * @param {object} context
     * @param {number} orderClass
     */
    orderDeviceEdgeControl({ state }, orderClass) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        bucket: "",
        fileName: "",
        manageParam: {
          facilityCd: state.selectedDeviceEdge.facilityCd,
          deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
          orderClass: orderClass,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.UPDATER,
          manageInfo: ""
        }
      };

      return sendRequestDeviceEdgeControl(deviceEdgeManageRequest);
    },
    /**
     * 対象日付のログファイルが存在しているかどうかのチェック
     * 存在している場合はダウンロード用のパスを返す
     * @param {any} param0
     * @param {String} targetDateStr 対象日付YYYYMMDD
     */
    fetchLogFileInfo({ state }, targetDateStr) {
      const param = {
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        dateStr: targetDateStr
      };
      return sendRequestDeviceEdgeLogFileInfo(param);
    },
    /**
     * 対象デバイスエッジのアップロード済み設定ファイルで最新のものの情報を取得
     * @param {any} param0
     */
    fetchConfFileInfo({ state }) {
      const param = {
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo
      };
      return sendRequestDeviceEdgeConfFileInfo(param);
    },
    /**
     * ログや設定ファイルの収集指示を出す
     */
    async orderDeviceEdgeFileUpload({ state }, orderClass) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        bucket: "",
        fileName: "",
        manageParam: {
          facilityCd: state.selectedDeviceEdge.facilityCd,
          deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
          orderClass: orderClass,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.UPDATER,
          manageInfo: ""
        }
      };
      return sendRequestDeviceEdgeFileGather(deviceEdgeManageRequest);
    },
    /**
     * リストア指示を出す
     */
    async orderDeviceEdgeRestoreApp({ state }, orderClass) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        bucket: "",
        fileName: "",
        manageParam: {
          facilityCd: state.selectedDeviceEdge.facilityCd,
          deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
          orderClass: orderClass,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.UPDATER,
          manageInfo: ""
        }
      };
      return sendRequestDeviceEdgeRestore(deviceEdgeManageRequest);
    },
    /**
     * リストア指示を出す
     */
    async orderDeviceEdgeRestoreUpdater({ state }, orderClass) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        bucket: "",
        fileName: "",
        manageParam: {
          facilityCd: state.selectedDeviceEdge.facilityCd,
          deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
          orderClass: orderClass,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.APP,
          manageInfo: ""
        }
      };
      return sendRequestDeviceEdgeRestore(deviceEdgeManageRequest);
    },
    /**
     *
     * App更新指示
     * @param {Object} context
     * @param {Object} payload
     */
    async orderDeviceEdgeUpdateApp({ state }, payload) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        bucket: payload.uploadBucket,
        fileName: payload.fileName,
        appType: DEVICE_EDGE_MANAGE_APP_TYPE.APP,
        manageParam: {
          facilityCd: state.selectedDeviceEdge.facilityCd,
          deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
          orderClass: payload.orderClass,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.UPDATER,
          manageInfo: ""
        }
      };
      return sendRequestDeviceEdgeUpdate(deviceEdgeManageRequest);
    },
    /**
     *
     * Updater更新指示
     * @param {Object} context
     * @param {Object} payload
     */
    async orderDeviceEdgeUpdateUpdater({ state }, payload) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        bucket: payload.uploadBucket,
        fileName: payload.fileName,
        appType: DEVICE_EDGE_MANAGE_APP_TYPE.UPDATER,
        manageParam: {
          facilityCd: state.selectedDeviceEdge.facilityCd,
          deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
          orderClass: payload.orderClass,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.UPDATER,
          manageInfo: ""
        }
      };
      return sendRequestDeviceEdgeUpdate(deviceEdgeManageRequest);
    },
    /**
     *
     * 全更新指示（予約も含む）
     * @param {Object} context
     * @param {Object} payload
     */
    async orderDeviceEdgeUpdateAll({ state }, payload) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        bucket: payload.uploadBucket,
        fileName: payload.fileName,
        appType: DEVICE_EDGE_MANAGE_APP_TYPE.ALL,
        manageParam: {
          facilityCd: state.selectedDeviceEdge.facilityCd,
          deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
          orderClass: payload.orderClass,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.UPDATER,
          manageInfo: ""
        }
      };
      return sendRequestDeviceEdgeUpdate(deviceEdgeManageRequest);
    },
    async fetchConfUploadTarget({ state }) {
      // アップロード先情報を取得
      const param = {
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo
      };
      return sendRequestDeviceEdgeConfFileUploadInfo(param);
    },
    /**
     * ブラウザからconfファイルをアップロード
     * @param {Object} payload
     */
    async uploadConfFile(context, payload) {
      // ファイルアップロード
      const params = new FormData();
      params.append("file", payload.confFile);
      const scopedWindow = getScopedWindow();
      params.append("filePath", scopedWindow?.btoa ? scopedWindow.btoa(payload.filePath) : (typeof btoa === "function" ? btoa(payload.filePath) : payload.filePath));
      return sendRequestFileUpload(params);
    },
    /**
     *
     * conf更新指示
     * @param {Object} context
     * @param {Object} payload
     */
    async orderDeviceEdgeConfUpdate({ state }, payload) {
      const deviceEdgeManageRequest = {
        deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
        targetFacilityCd: state.selectedDeviceEdge.facilityCd,
        bucket: payload.uploadBucket,
        fileName: payload.fileName,
        manageParam: {
          facilityCd: state.selectedDeviceEdge.facilityCd,
          deviceEdgeNo: state.selectedDeviceEdge.deviceEdgeNo,
          orderClass: payload.orderClass,
          orderTargetClass: DEVICE_EDGE_MANAGE_TARGET.UPDATER,
          manageInfo: ""
        }
      };
      return sendRequestDeviceEdgeConfUpdate(deviceEdgeManageRequest);
    },
    /**
     * ダウンロードデータ設定
     */
    setDownloadData({ commit, dispatch }, request) {
      commit("setDlTargetInfo", request);
      dispatch("loading-screen/setLoadingScreenVisible", true);
      return sendRequestFetchDetailGatheringDownload(request)
        .then(response => {
          const downloadData = response.request.response;
          commit("setDownloadData", downloadData);
        })
        .finally(() =>
          dispatch("loading-screen/setLoadingScreenVisible", false)
        );
    },
    /**
     * ダウンロードログデータ設定
     */
    setDownloadLogData({ commit, dispatch }, request) {
      commit("setDlTargetInfo", request);
      dispatch("loading-screen/setLoadingScreenVisible", true);
      return sendRequestDeviceEdgeLogFileDownload(request)
        .then(response => {
          const downloadData = response.request.response;
          commit("setDownloadData", downloadData);
        })
        .finally(() =>
          dispatch("loading-screen/setLoadingScreenVisible", false)
        );
    }
  },
  mutations: {
    // デバイスエッジ情報
    setDeviceEdgeInfo(state, deviceEdge) {
      state.selectedDeviceEdge = deviceEdge;
    },
    // ダウンロード内容
    setDownloadData(state, downloadData) {
      state.downloadData = "";
      state.downloadData = downloadData;
    },
    // ダウンロード対象
    setDlTargetInfo(state, fileData) {
      state.dlTarget.fileData.bucket = fileData.bucket;
      state.dlTarget.fileData.fileName = fileData.filename;
    }
  }
};
