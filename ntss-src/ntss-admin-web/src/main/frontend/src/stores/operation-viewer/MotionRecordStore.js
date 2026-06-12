/**
 * 装置記録一覧用ストア
 */
import {
  sendRequestUpdateAllCorrection,
  sendRequestFetchMotionRecords,
  sendRequestFindMotionRecords,
  sendRequestGetPartsRunning,
  sendRequestFetchGatheringStatus,
  sendRequestUpdateServiceSupportAll
} from "@/apis/operation-viewer";

import { sendRequestDataGathering } from "@/apis/data-gathering";

/**
 * データ収集ステータス：転送完了.
 */
const GATHERING_STATUS_TRANSFER_FINISHED = 2;
/**
 * 最大表示件数.
 */
const MAX_RECORD = 10000;

export default {
  strict: true,
  namespaced: true,
  state: {
    // ヘッダー情報
    headerInfo: {
      // 施設コード
      facilityCd: "",
      // 施設名
      facilityName: "",
      // 型式
      machineType: "",
      // 製造番号
      machineSerial: "",
      // ベッド名
      bedName: "",
      // 装置名
      machineName: "",
      // 工
      processState: "",
      // 通信フォーマット
      comFormatCd: "",
      // 通信種別
      comType: 0,
      // デバイスエッジ番号
      deviceEdgeNo: 0,
      // 型式コード
      machineTypeCd: "",
      // FTP収集
      isFtp: ""
    },
    // 型式コード
    machineTypeCd: "",
    // イベント発生日
    eventRegDate: "",
    // 装置記録一覧
    motionRecords: [],
    // 緊急発報、予防保守の更新結果
    isUpdate: false,
    // データ収集可否
    isGatheringOk: false,
    // 最大件数を超えたか
    isOverMaxRecode: false,
    // 部品の運転/交換時間の取得結果
    partsRunningResult: {
      // 通信種別
      comType: 0,
      // 通信フォーマット
      comFormatCd: "",
      // 運転/交換時間
      partsRunning: {
        dialyzeDevice: {
          0: "",
          1: "",
          2: "",
          3: "",
          4: "",
          5: "",
          6: "",
          7: "",
          8: "",
          9: "",
          10: "",
          11: "",
          12: "",
          13: "",
          14: "",
          15: "",
          16: "",
          17: "",
          18: "",
          19: "",
          20: "",
          21: "",
          22: "",
          23: "",
          24: "",
          25: "",
          26: "",
          27: "",
          28: "",
          29: "",
          30: "",
          31: "",
          32: "",
          33: "",
          34: "",
          35: ""
        },
        dab: {
          1: "",
          2: "",
          3: "",
          4: "",
          5: "",
          6: "",
          7: "",
          8: "",
          9: "",
          10: "",
          11: "",
          12: "",
          13: "",
          14: "",
          15: "",
          16: ""
        },
        dad: {
          1: "",
          2: "",
          3: "",
          4: "",
          5: "",
          6: "",
          7: "",
          8: "",
          9: ""
        },
        dro: {
          1: "",
          2: "",
          3: "",
          4: "",
          5: "",
          6: "",
          7: "",
          8: ""
        },
        dry: {
          1: "",
          2: ""
        },
        V4: {
          16: "",
          31: ""
        }
      }
    }
  },
  mutations: {
    // 装置記録一覧設定
    setMotionRecords(state, motionRecords) {
      motionRecords.forEach(e => {
        state.motionRecords.push(e);
      });
    },
    setEventRegDate(state, baseDate) {
      baseDate = baseDate.replace(/\//g, "");
      const eventRegDate = new Date(
        baseDate.slice(0, 4),
        baseDate.slice(4, 6) - 1,
        baseDate.slice(6)
      );
      eventRegDate.setDate(eventRegDate.getDate() - 1);
      state.eventRegDate = eventRegDate;
    },
    setIsGatheringOk(state, isGatheringOk) {
      state.isGatheringOk = isGatheringOk;
    },
    // 装置記録一覧クリア
    clearMotionRecords(state) {
      state.motionRecords.splice(0, state.motionRecords.length);
    },
    // 装置記録のヘッダ情報
    setHeaderInfo(state, headerInfo) {
      state.headerInfo.facilityCd = headerInfo.facilityCd;
      state.headerInfo.facilityName = headerInfo.facilityName;
      state.headerInfo.machineType = headerInfo.machineType;
      state.headerInfo.machineSerial = headerInfo.machineSerial;
      state.headerInfo.bedName = headerInfo.bedName;
      state.headerInfo.machineName = headerInfo.machineName;
      state.headerInfo.processState = headerInfo.processState;
      state.machineTypeCd = headerInfo.machineTypeCd;
      state.headerInfo.comFormatCd = headerInfo.comFormatCd;
      state.headerInfo.comType = headerInfo.comType;
      state.headerInfo.deviceEdgeNo = headerInfo.deviceEdgeNo;
      state.headerInfo.machineTypeCd = headerInfo.machineTypeCd;
      state.headerInfo.isFtp = headerInfo.isFtp;
    },
    // 更新結果を反映
    setIsUpdate(state, isUpdate) {
      state.isUpdate = isUpdate;
    },
    // 部品の運転/交換時間取得結果を反映
    setPartsRunningResult(state, result) {
      const comType = result.comType;
      const comFormatCd = result.comFormatCd;
      state.partsRunningResult.comType = comType;
      state.partsRunningResult.comFormatCd = comFormatCd;
      const partsRunning = result.partsRunning;
      if (comType === 1) {
        state.partsRunningResult.partsRunning.dialyzeDevice = partsRunning;
      } else if (comType === 2) {
        switch (comFormatCd) {
          case "A": {
            state.partsRunningResult.partsRunning.dab = partsRunning;
            break;
          }
          case "D": {
            state.partsRunningResult.partsRunning.dad = partsRunning;
            break;
          }
          case "I": {
            state.partsRunningResult.partsRunning.dry = partsRunning;
            break;
          }
          case "J": {
            state.partsRunningResult.partsRunning.dry = partsRunning;
            break;
          }
          case "R": {
            state.partsRunningResult.partsRunning.dro = partsRunning;
            break;
          }
          default:
            break;
        }
      } else if (comType === 3) {
        switch (comFormatCd) {
          case "V": {
            state.partsRunningResult.partsRunning.V4 = partsRunning;
            break;
          }
          default:
            break;
        }
      }
    }
  },
  actions: {
    /**
     * パラメータに該当する全てのサービス対応区分(未対応と1次対応済み)をサービス対応済みに更新する.
     *
     * @param {*} commit commitオブジェクト
     * @param {*} param リクエストパラメータ
     * @param {Boolean} 成功した場合trueを返却する.
     */
    updateServiceSupportAll({ commit }, param) {
      return sendRequestUpdateServiceSupportAll(param);
    },
    // 装置記録一覧クリア
    clearMotionRecords({ commit }) {
      commit("clearMotionRecords");
    },
    // 与えられた緊急発報、予防保守のどちらかの未対処を全て対処済に更新する
    updateAllCorrection(context, request) {
      return sendRequestUpdateAllCorrection(request);
    },
    // 初期表示時
    fetchMotionRecords({ commit, state }, info) {
      const params = info[0];
      if (params.isClear) {
        commit("clearMotionRecords");
      }
      return sendRequestFetchMotionRecords(params).then(response => {
        let motionRecords = response.data.motionRecords;
        // 最大件数を超えたか確認
        state.isOverMaxRecode = false;
        if (motionRecords.length > MAX_RECORD) {
          // 最大件数に収まるよう末尾のデータを削除
          motionRecords = motionRecords.slice(0, MAX_RECORD);
          state.isOverMaxRecode = true;
        }
        // 日付でソートする用のカラムを追加
        for (const record of motionRecords) {
          record.sortKey = `${record.eventRegDate}_${record.eventRegTime}`;
        }
        if (motionRecords.length > 0) {
          commit("setEventRegDate", motionRecords.slice(-1)[0].eventRegDate);
          commit("setMotionRecords", motionRecords);
        }
      });
    },
    // フィルタリング時
    findMotionRecords({ commit, state }, info) {
      const params = info[0];
      return new Promise((resolve, reject) => {
        sendRequestFindMotionRecords(params)
          .then(response => {
            let motionRecords = response.data.motionRecords;
            // 最大件数を超えたか確認
            state.isOverMaxRecode = false;
            if (motionRecords.length > MAX_RECORD) {
              // 最大件数に収まるよう末尾のデータを削除
              motionRecords = motionRecords.slice(0, MAX_RECORD);
              state.isOverMaxRecode = true;
            }
            // 日付でソートする用のカラムを追加
            for (const record of motionRecords) {
              record.sortKey = `${record.eventRegDate}_${
                record.eventRegTime
              }`;
            }
            response.data.motionRecords = motionRecords;
            resolve(response);
          })
          .catch(error => reject(error));
      }).then(response => {
        commit("clearMotionRecords");
        commit("setMotionRecords", response.data.motionRecords);
      });
    },
    // -----------------------------------------------------------
    // state更新(headerInfo)
    // -----------------------------------------------------------
    setHeaderInfo({ commit }, headerInfo) {
      // console.log("headerInfo: %o", headerInfo);
      commit("setHeaderInfo", headerInfo);
    },
    // 部品の運転/交換時間を取得
    getPartsRunning({ commit }, info) {
      return sendRequestGetPartsRunning(info).then(response => {
        commit("setPartsRunningResult", response.data);
      });
    },
    // -----------------------------------------------------------
    // データ収集RestAPIの呼び出し
    // -----------------------------------------------------------
    requestDataGathering({ commit }, request) {
      // データ収集実行ボタンを非活性にする
      commit("setIsGatheringOk", false);

      sendRequestDataGathering(request);
    },
    // -----------------------------------------------------------
    // データ収集ステータスの最新化
    // -----------------------------------------------------------
    refreshGatheringStatus({ commit }, param) {
      // データ収集実行ボタンを非活性にする
      commit("setIsGatheringOk", false);

      sendRequestFetchGatheringStatus(param.userId, param.facilityCd).then(
        response => {
          commit(
            "setIsGatheringOk",
            response.data.gatheringStatus === null ||
              response.data.gatheringStatus ===
                GATHERING_STATUS_TRANSFER_FINISHED
          );
        }
      );
    },
    // add bug #6942 修正 chen start
    setEventRegDate({ commit }, baseDate) {
      commit("setEventRegDate", baseDate);
    }
    // add bug #6942 修正 chen end
  },
  getters: {
    getMotionRecords(state) {
      return state.motionRecords;
    },
    getHeaderInfo(state) {
      return state.headerInfo;
    },
    getMachineTypeCd(state) {
      return state.machineTypeCd;
    },
    getPartsRunningResult(state) {
      return state.partsRunningResult;
    },
    isGatheringOk(state) {
      return state.isGatheringOk;
    },
    isOverMaxRecode(state) {
      return state.isOverMaxRecode;
    },
    getEventRegDate(state) {
      return state.eventRegDate;
    }
  }
};
