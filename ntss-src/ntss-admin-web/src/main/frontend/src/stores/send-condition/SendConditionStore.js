//@ts-check
/**
 * 条件送信用ストア
 */
import {
  checkCalibrationByCd,
  sendRequestPostSendCondition,
  sendRequestPostSaveWeightAndChair,
  sendRequestPostSaveWheelChair,
  sendRequestPostSendAfterWeight,
  sendRequestGetOrderMain,
  sendRequestGetNoOrderMain,
  sendRequestPutIndWater,
  sendRequestPutIndTare,
  sendRequestGetLastRstWeight,
  sendRequestGetLastRstWeightPat,
  sendRequestGetWeightByTreatDate,
  sendRequestGetWheelChair,
  sendRequestGetPersonalWheelChairList,
  sendRequestPostNoSendCondition,
  sendRequestPostSaveMeasure,
  sendRequestGetHistory,
  sendRequestGetNoPatOrder,
  sendRequestLastScale,
  sendRequestLastScaleNoSchedule,
  // add FNSI-分類不一致判断の追加 徐 start
  getChkIndCondInfoData,
  getWeightByTreatDateAndOrdClass,
  // add FNSI-分類不一致判断の追加 徐 end
  // @ts-ignore
} from "@/apis/send-condition";
import {
  sendRequestPostPrintSheet,
  sendRequestWeightAppOk,
  // @ts-ignore
} from "@/apis/weight-state";
// @ts-ignore
import { sendRequestGetSingleHistory } from "@/apis/measure-history";
import {
  weightScaleClass,
  weightScaleMode,
  weightScaleState,
  machineSendable,
  dialysisState,
  // @ts-ignore
} from "@/constants/weightDefine";
// @ts-ignore
import { deepCopy } from "@/functions/common/CommonFunctions";
// @ts-ignore
import { dateFormat } from "@/functions/common/DateTimeUtils";
import {
  tareG2Kg,
  offWaterG2Kg,
  weightScaleClassByDialysisState,
  // @ts-ignore
} from "@/functions/common/WeightFunctions";
// @ts-ignore
import { deviceModeConstant } from "@/constants/weightDefine";
import _ from "underscore";
import BigNumber from "bignumber.js";
import moment from "moment";

// 子モジュール
// @ts-ignore
import SendConditionMessageStore from "@/stores/send-condition/SendConditionMessageStore";
// @ts-ignore
import WeightSettingStore from "@/stores/send-condition/WeightSettingStore";
// @ts-ignore
import SendConditionAudioStore from "@/stores/send-condition/SendConditionAudioStore";

/**
 * undefined を nullにする
 */
function undef2DefVal(obj, defaultValue = null) {
  if (obj !== undefined) {
    return obj;
  }
  return defaultValue;
}

/**
 * 風袋・除水補正のJSONから重量の合計値を返す
 */
function tareOrOffWaterWeightTotal(jsonObj) {
  return (
    Number(undef2DefVal(jsonObj.weight_1)) +
    Number(undef2DefVal(jsonObj.weight_2)) +
    Number(undef2DefVal(jsonObj.weight_3)) +
    Number(undef2DefVal(jsonObj.weight_4)) +
    Number(undef2DefVal(jsonObj.weight_5))
  );
}

// 風袋・除水補正用変更チェック
function isChangeTareOrOffWaterJson(oldData, newData) {
  return (
    undef2DefVal(oldData.name_1) !== undef2DefVal(newData.name_1) ||
    undef2DefVal(oldData.name_2) !== undef2DefVal(newData.name_2) ||
    undef2DefVal(oldData.name_3) !== undef2DefVal(newData.name_3) ||
    undef2DefVal(oldData.name_4) !== undef2DefVal(newData.name_4) ||
    undef2DefVal(oldData.name_5) !== undef2DefVal(newData.name_5) ||
    Number(undef2DefVal(oldData.weight_1)) !==
      Number(undef2DefVal(newData.weight_1)) ||
    Number(undef2DefVal(oldData.weight_2)) !==
      Number(undef2DefVal(newData.weight_2)) ||
    Number(undef2DefVal(oldData.weight_3)) !==
      Number(undef2DefVal(newData.weight_3)) ||
    Number(undef2DefVal(oldData.weight_4)) !==
      Number(undef2DefVal(newData.weight_4)) ||
    Number(undef2DefVal(oldData.weight_5)) !==
      Number(undef2DefVal(newData.weight_5))
  );
}

const defaultTareAndOffWater = {
  name_1: "",
  name_2: "",
  name_3: "",
  name_4: "",
  name_5: "",
  weight_1: 0,
  weight_2: 0,
  weight_3: 0,
  weight_4: 0,
  weight_5: 0,
};
const unknownWheelChairName = "未登録車いす";

export default {
  strict: process.env.NODE_ENV !== "production",
  namespaced: true,
  modules: {
    audio: SendConditionAudioStore,
    message: SendConditionMessageStore,
    setting: WeightSettingStore,
  },
  state: {
    // 初期化完了
    // add FNSI-外部連携APIの修正 徐 start
    // isInitialized: true,
    isInitialized: false,
    // add FNSI-外部連携APIの修正 徐 start
    // 体重計モード
    inputPatId: null, // 入力院内患者ID
    // 条件送信メイン画面
    ordNo: null, // オーダーNo
    ordNo2: null, // オーダーNo2
    patId: null, // 患者ID
    isPrint: true, // 印刷チェックボックス
    isSimpleMode: true, // 現在簡易画面かどうか
    scaleClass: weightScaleClass.before,
    scaleMode: weightScaleMode.weight, // 選択中の測定モード
    isWheelchair: false, // 車いす表示フラグ
    isMessage: false, // 測定値
    messageSwitch: false,
    measuredValue: 0,
    measuring: false, // 測定中
    baseOrdWeightNo: null, // 体重測定記録番号
    // 体重値
    bodyWeightValue: 0,
    // 選択中の車いす情報
    selectWheelchair: {
      code: null,
      name: "",
      weight: null,
      gramWeight: null,
      calibrationCheck: true,
    },
    // 風袋・除水補正編集用
    editModalDataMode: 0,
    editModalData: [],
    oldTareInfo: null,
    oldOffWaterInfo: null,
    tareChangeFlg: false,
    offWaterChangeFlg: false,
    offWaterRegFlg: 0,
    // 風袋補正サンプルデータ[g]
    tareInfo: deepCopy(defaultTareAndOffWater),
    // 風袋補正合計値
    tareWeight: 0,
    // 除水補正サンプルデータ[g]
    offWaterInfo: deepCopy(defaultTareAndOffWater),
    patStatus: {
      // DW[患者情報(身体情報)から]
      indDryWeight: null,
    },
    // 除水補正合計値
    offWaterWeight: 0,
    // 目標体重[透析条件:3] fnw:6文字以内[整数3桁小数2桁（000.00～300.00）]
    // add FNSI-初期表示状態の修正  徐 start
    // indTargetWeight: 0.0,
    indTargetWeight: null,
    // add FNSI-初期表示状態の修正  徐 end
    // 除水量制限[透析条件:4] fnw:4文字以内[整数1桁小数2桁（0.00～9.99）]
    // indWaterRemovalLimit: 0.0,
    indWaterRemovalLimit: null,
    // add FNSI-初期表示状態の修正  徐 end
    // 前回後
    lastTimeWeight: null,
    // 後体重用
    // 前体重[実績から]
    beforeWeightValue: 0.0,
    // 除水積算[実績から]
    dewateringIntegration: 0.0,
    // 除水目標値
    waterRemovalTarget: 0,
    // 表示中患者の指示・実績情報
    viewPatIndRstData: {},
    viewPatIndRstData2: {},

    // 条件送信パラメータ
    sendConditionPayload: null,
    // 条件送信結果取得コード
    sendConditionResponseCd: [],
    // 前回測定記録有無
    isHasOrdWeightScale: false,
    // 測定履歴モーダル用一覧情報
    HistoryModalList: [],
    // 装置通信状態・条件確認状態
    machineState: [
      {
        isCommonComFormatProtocol: "0",
        isOfflineMachine: "0",
        isOfflineTreat: "0",
        isTreating: "0",
        isConnectError: "0",
        isPatVerified: "0",
        isUseTmpControl: "0",
      },
      {
        isCommonComFormatProtocol: "0",
        isOfflineMachine: "0",
        isOfflineTreat: "0",
        isTreating: "0",
        isConnectError: "0",
        isPatVerified: "0",
        isUseTmpControl: "0",
      },
    ],
    patDeviceSet: [null, null],
    isMachineStateErrorMsg: false,

    // 前回測定の測定値
    lastScaleValue: null,
    lastWheelChairCd: null,
    lastWheelChairValue: null,

    // 前回の測定モード
    // 0:体重, 1:体重車いす, 2:車いす
    lastScaleMode: null,

    // 患者車いすあり
    isUsePatWheelChair: false,
  },
  getters: {
    // 初期化済み
    getIsInitialized: (state) => state.isInitialized,
    // クール名取得
    getKurInfo: (state) => {
      if (state.scaleClass === weightScaleClass.after) {
        return [
          {
            code: state.viewPatIndRstData.rstKurCd,
            name: state.viewPatIndRstData.rstKurName,
          },
          {
            code: state.viewPatIndRstData2.rstKurCd,
            name: state.viewPatIndRstData2.rstKurName,
          },
        ];
      } else {
        return [
          {
            code: state.viewPatIndRstData.indKurCd,
            name: state.viewPatIndRstData.indKurName,
          },
          {
            code: state.viewPatIndRstData2.indKurCd,
            name: state.viewPatIndRstData2.indKurName,
          },
        ];
      }
    },
    // ベッド名取得
    getBedInfo: (state) => {
      if (state.scaleClass === weightScaleClass.after) {
        return [
          {
            code: state.viewPatIndRstData.rstBedCd,
            name: state.viewPatIndRstData.rstBedName,
          },
          {
            code: state.viewPatIndRstData2.rstBedCd,
            name: state.viewPatIndRstData2.rstBedName,
          },
        ];
      } else {
        return [
          {
            code: state.viewPatIndRstData.indBedCd,
            name: state.viewPatIndRstData.indBedName,
          },
          {
            code: state.viewPatIndRstData2.indBedCd,
            name: state.viewPatIndRstData2.indBedName,
          },
        ];
      }
    },
    // 治療モード取得
    getTreatmentMode: (state) => {
      if (state.scaleClass === weightScaleClass.after) {
        return [
          {
            deviceMode: state.viewPatIndRstData.rstDeviceMode,
            treatCd: state.viewPatIndRstData.rstTreatmentCd,
            treatName: state.viewPatIndRstData.rstTreatmentName,
          },
          {
            deviceMode: state.viewPatIndRstData2.rstDeviceMode,
            treatCd: state.viewPatIndRstData2.rstTreatmentCd,
            treatName: state.viewPatIndRstData2.rstTreatmentName,
          },
        ];
      } else {
        return [
          {
            deviceMode: state.viewPatIndRstData.indDeviceMode,
            treatCd: state.viewPatIndRstData.indTreatmentCd,
            treatName: state.viewPatIndRstData.indTreatmentName,
          },
          {
            deviceMode: state.viewPatIndRstData2.indDeviceMode,
            treatCd: state.viewPatIndRstData2.indTreatmentCd,
            treatName: state.viewPatIndRstData2.indTreatmentName,
          },
        ];
      }
    },
    getTreatDate: (state) => {
      return [
        state.viewPatIndRstData.treatDate,
        state.viewPatIndRstData2.treatDate,
      ];
    },
    getIndTreatStartTime: (state) => {
      return [
        state.viewPatIndRstData.indTreatStartTime,
        state.viewPatIndRstData2.indTreatStartTime,
      ];
    },
    getOrderIndCondInfo: (state) => {
      return [
        state.viewPatIndRstData.condInfo,
        state.viewPatIndRstData2.condInfo,
      ];
    },
    // 入力患者IDを取得
    getInputPatId: (state) => state.inputPatId,
    // 患者IDを取得
    getPatId: (state) => state.patId,
    // 指定オーダー番号を取得
    getSelectedOrdNo: (state) => {
      return { ordNo: state.ordNo, ordNo2: state.ordNo2 };
    },
    // 車いすフラグを取得
    getIsWheelchair: (state) => state.isWheelchair,
    // 測定値を取得
    getMeasuredValue: (state) => state.measuredValue,
    // 測定値を取得
    getMeasuredInfo: (state) => {
      if (
        !state.isHasOrdWeightScale &&
        state.scaleMode === weightScaleMode.wheelChair
      ) {
        // 体重＋車いすが未測定で車いす測定
        return {
          value: null,
          text: "未測定",
        };
      } else {
        // それ以外
        return {
          value: state.measuredValue,
          text:
            state.measuredValue === null ||
            // add FNSI-装置設定の小数点有効桁数の修正 徐 start
            // Number.isNaN(Number(state.measuredValue))
            //   ? "未測定"
            //   : `${state.measuredValue} kg`
            Number.isNaN(Number(state.measuredValue))
              ? "未測定"
              : `${Number(state.measuredValue).toFixed(2)} kg`,
          // add FNSI-装置設定の小数点有効桁数の修正 徐 end
        };
      }
    },
    // 選択車いす情報を取得
    getSelectWheelchair: (state) => state.selectWheelchair,
    // 選択車いすの表示用重量情報を取得
    getSelectWheelchairWeight: (state) =>
      state.selectWheelchair.weight === null ||
      // add FNSI-装置設定の小数点有効桁数の修正 徐 start
      // Number.isNaN(Number(state.selectWheelchair.weight))
      //   ? "未測定"
      //   : `${state.selectWheelchair.weight} kg`,
      Number.isNaN(Number(state.selectWheelchair.weight))
        ? "未測定"
        : `${Number(state.selectWheelchair.weight).toFixed(2)} kg`,
    // add FNSI-装置設定の小数点有効桁数の修正 徐 end
    // 風袋変更フラグを取得
    getTareChangeFlg: (state) => state.tareChangeFlg,
    // 風袋合計重量を取得
    getTareWeight: (state) => {
      // 風袋は合計値から 1g の位を切り捨てた kg の値
      return tareG2Kg(state.tareWeight);
    },
    // 体重値を取得
    getBodyWeightValue: (state) => state.bodyWeightValue,
    // 表示用体重値を取得
    getBodyWeightInfo: (state) => {
      let value = state.bodyWeightValue;
      let text =
        state.bodyWeightValue === null ||
        // add FNSI-装置設定の小数点有効桁数の修正 徐 start
        // Number.isNaN(Number(state.bodyWeightValue))
        //   ? "未確定"
        //   : `${state.bodyWeightValue} kg`;
        Number.isNaN(Number(state.bodyWeightValue))
          ? "未確定"
          : `${Number(state.bodyWeightValue).toFixed(2)} kg`;
      // add FNSI-装置設定の小数点有効桁数の修正 徐 end
      if (
        !state.isHasOrdWeightScale &&
        state.scaleMode === weightScaleMode.wheelChair
      ) {
        // 体重＋車いすが未測定で車いす測定
        value = null;
        text = "未確定";
      }
      return {
        value,
        text,
        isSuccess: !(
          state.bodyWeightValue === null ||
          Number.isNaN(Number(state.bodyWeightValue))
        ),
      };
    },
    getIsMeasuring: (state) => state.measuring,
    // 前体重値を取得
    // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
    // getBeforeWeightValue: state => state.beforeWeightValue,
    getBeforeWeightValue: (state) => {
      return {
        value: state.beforeWeightValue,
        text:
          state.beforeWeightValue === null ||
          Number.isNaN(Number(state.beforeWeightValue))
            ? ""
            : `${Number(state.beforeWeightValue).toFixed(2)} kg`,
      };
    },
    // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
    // 目標体重を取得
    getIndTargetWeight: (state) => {
      return {
        value: state.indTargetWeight,
        text:
          state.indTargetWeight === null ||
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // Number.isNaN(Number(state.indTargetWeight))
          //   ? "未設定"
          //   : `${state.indTargetWeight} kg`
          Number.isNaN(Number(state.indTargetWeight))
            ? "未設定"
            : `${Number(state.indTargetWeight).toFixed(2)} kg`,
        // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
      };
    },
    // DWを取得
    getIndDryWeight: (state) => {
      return {
        value: state.patStatus.indDryWeight,
        text:
          state.patStatus.indDryWeight === null ||
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // Number.isNaN(Number(state.patStatus.indDryWeight))
          //   ? "未設定"
          //   : `${state.patStatus.indDryWeight} kg`
          Number.isNaN(Number(state.patStatus.indDryWeight))
            ? "未設定"
            : `${Number(state.patStatus.indDryWeight).toFixed(2)} kg`,
        // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
      };
    },
    // I-HDF引き残し量を取得
    getPullLeaveAmount: (state) => {
      // mod #9576 #ies_7776 zhou start
      //if (state.viewPatIndRstData.rstWeightInfo === null) return 0;
      if (!state.viewPatIndRstData.rstWeightInfo) return 0;
      // mod #9576 #ies_7776 zhou end
      return {
        show:
          state.viewPatIndRstData.rstWeightInfo.ihdf_pll === null ||
          Number.isNaN(
            Number(state.viewPatIndRstData.rstWeightInfo.ihdf_pll)
          ) ||
          state.viewPatIndRstData.rstWeightInfo.ihdf_pll <= 0
            ? false
            : true,
        value:
          state.viewPatIndRstData.rstWeightInfo.ihdf_pll === null ||
          Number.isNaN(Number(state.viewPatIndRstData.rstWeightInfo.ihdf_pll))
            ? 0
            : Number(state.viewPatIndRstData.rstWeightInfo.ihdf_pll),
      };
    },
    // 前回後体重取得
    getLastTimeWeight: (state) => state.lastTimeWeight,
    // 除水積算を取得
    getDewateringIntegration: (state) => {
      return {
        value: state.dewateringIntegration,
        text:
          state.dewateringIntegration === null ||
          Number.isNaN(Number(state.dewateringIntegration))
            ? ""
            : `${Number(state.dewateringIntegration).toFixed(2)} kg`,
      };
    },
    // 除水補正変更フラグを取得
    getOffWaterChangeFlg: (state) => state.offWaterChangeFlg,
    // 除水補正値合計を取得
    getOffWaterWeight: (state) => {
      // 除水補正は合計値から 1g の位を切り上げた kg の値
      return offWaterG2Kg(state.offWaterWeight);
    },
    // 除水制限値を取得
    getIndWaterRemovalLimit: (state) => {
      return {
        value: state.indWaterRemovalLimit,
        text:
          state.indWaterRemovalLimit === null ||
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // Number.isNaN(Number(state.indWaterRemovalLimit))
          //   ? "未設定"
          //   : `${state.indWaterRemovalLimit} kg`
          Number.isNaN(Number(state.indWaterRemovalLimit))
            ? "未設定"
            : `${Number(state.indWaterRemovalLimit).toFixed(2)} kg`,
        // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
      };
    },
    // 測定モードを取得
    getScaleMode: (state) => state.scaleMode,
    // 印刷フラグを取得
    getIsPrint: (state) => state.isPrint,
    // 体重測定区分を取得
    getScaleClass: (state) => state.scaleClass,
    // 簡易表示フラグを取得
    getIsSimpleMode: (state) => state.isSimpleMode,
    // メッセージ表示フラグを取得
    getIsShowMessage: (state) => state.isMessage,
    // 風袋除水モーダルの表示モード取得
    getEditModalDataMode: (state) => state.editModalDataMode,
    // 風袋除水モーダルの編集値取得
    getEditModalData: (state) => state.editModalData,
    // 条件送信応答取得
    getSendConditionResponseCd: (state) => state.sendConditionResponseCd,
    // 目標除水量取得
    getWaterRemovalTarget: (state) => state.waterRemovalTarget,
    /**@returns {boolean} 記録からの継続かどうか。初回測定だとfalse*/
    getIsHasOrdWeightScale: (state) => state.isHasOrdWeightScale,
    // 測定履歴モーダル用一覧情報取得
    getHistoryModalList(state) {
      return state.HistoryModalList;
    },
    getMachineState: (state) => state.machineState,
    getMessageSwitch: (state) => state.messageSwitch,
    /** 装置状態から送信可能状態を取得 */
    getMachineStateError: (state) => {
      if (state.machineState[0].isOfflineMachine === "1") {
        // 1件目がオフライン装置/特殊浄化ならば送信可能（2件目は必ず特殊浄化なので）
        return machineSendable.sendable;
      }
      if (
        state.machineState[0].isConnectError === "1" ||
        state.machineState[1].isConnectError === "1" ||
        state.machineState[0].isTreating === "1" ||
        state.machineState[1].isTreating === "1"
      ) {
        return machineSendable.notSendable;
      } else if (
        state.machineState[0].isCommonComFormatProtocol !== "1" &&
        (state.machineState[0].isPatVerified === "1" ||
          state.machineState[1].isPatVerified === "1")
      ) {
        // 医器工でなく患者確認済み
        return machineSendable.patVerified;
      } else {
        return machineSendable.sendable;
      }
    },
    getPatDeviceSetWarnInfo: (state) => {
      let returnInfo = {
        isWarn: false,
        msg: "",
      };
      if (
        state.scaleClass === weightScaleClass.before &&
        state.viewPatIndRstData.indDeviceMode !==
          deviceModeConstant.PURIFICATION
      ) {
        // 前体重かつ特殊浄化以外
        if (
          (state.machineState[0].isUseTmpControl === "1" &&
            state.machineState[0].isOfflineMachine !== "1" &&
            state.machineState[0].isCommonComFormatProtocol !== "1") ||
          (state.machineState[1].isUseTmpControl === "1" &&
            state.machineState[1].isOfflineMachine !== "1" &&
            state.machineState[1].isCommonComFormatProtocol !== "1")
        ) {
          // オフラインでも共通プロトコルでもなく、TMP補液制御使用可能装置である
          if (
            state.patDeviceSet[0] &&
            state.patDeviceSet[0].war &&
            state.patDeviceSet[0].war.dev &&
            state.patDeviceSet[0].war.dev.A &&
            state.patDeviceSet[0].ope &&
            state.patDeviceSet[0].ope.dev &&
            state.patDeviceSet[0].ope.dev.A
          ) {
            const obj = state.patDeviceSet[0].war.dev.A;
            const fixedUpper = obj[132] !== null ? obj[132] : 500;
            const fixedLower = obj[133] !== null ? obj[133] : -100;
            const confUpper = obj[130] !== null ? obj[130] : 500;
            const confLower = obj[131] !== null ? obj[131] : -100;

            const devA = state.patDeviceSet[0].ope.dev.A;

            let isShowDialog = false;
            let msg = "";

            // 速度低下
            const valueDown = devA[472];
            // 速度復帰
            const valueRepair = devA[473];
            if (valueDown < valueRepair) {
              isShowDialog = true;
              msg += "TMP閾値 速度低下の値が速度復帰の値未満です。<br />";
            }

            if (valueDown > fixedUpper || valueDown < fixedLower) {
              isShowDialog = true;
              msg +=
                "TMP閾値 速度低下の値がTMP固定警報上下限の範囲外です。<br />";
            }
            if (valueDown > confUpper || valueDown < confLower) {
              isShowDialog = true;
              msg +=
                "TMP閾値 速度低下の値がTMP自動設定警報限界上下限の範囲外です。<br />";
            }
            if (valueRepair > fixedUpper || valueRepair < fixedLower) {
              isShowDialog = true;
              msg +=
                "TMP閾値 速度復帰の値がTMP固定警報上下限の範囲外です。<br />";
            }
            if (valueRepair > confUpper || valueRepair < confLower) {
              isShowDialog = true;
              msg +=
                "TMP閾値 速度復帰の値がTMP自動設定警報限界上下限の範囲外です。<br />";
            }
            returnInfo = {
              isWarn: isShowDialog,
              msg: msg + "装置設定を修正してください。",
            };
          }
        }
      }
      return returnInfo;
    },
    getIsCurrentDialysisStateEqualDialysisState: (state) => (status) => {
      if (state.viewPatIndRstData) {
        if (
          state.viewPatIndRstData.rstDialysisState === status ||
          (state.viewPatIndRstData2 &&
            state.viewPatIndRstData2.rstDialysisState === status)
        ) {
          return true;
        }
      }
      // add FNSI-特殊浄化の場合、除水量制限不要 徐 start
      if (state.viewPatIndRstData.indDeviceMode === status) {
        return true;
      }
      // add FNSI-特殊浄化の場合、除水量制限不要 徐 end
      return false;
    },
    // 前回測定の測定値
    getLastScaleValue: (state) => state.lastScaleValue,
    getLastWheelChairCd: (state) => state.lastWheelChairCd,
    getLastWheelChairValue: (state) => state.lastWheelChairValue,

    // 前回の測定モード
    getLastScaleMode: (state) => state.lastScaleMode,

    // 患者車いすの有無
    getIsUsePatWheelChair: (state) => state.isUsePatWheelChair,
  },
  actions: {
    setIsInitialized({ commit }, boolean) {
      commit("setIsInitialized", boolean);
    },
    /**
     * 選択中の院内患者IDセット
     * @param {Object} context
     * @param {String} id
     */
    setInputPatId({ commit }, id) {
      // 患者情報セット
      commit("setInputPatId", { inputPatId: id });
    },
    /**
     * 選択中の患者IDセット
     * @param {Object} context
     * @param {Number} id
     */
    setPatId({ commit }, id) {
      // 患者情報セット
      commit("setPatId", { patId: id });
    },
    /**
     * 選択中のオーダー番号セット
     * @param {Object} context
     * @param {Object} payload
     * @param {Number} payload.ordNo オーダー番号
     * @param {Number} payload.ordNo2 同時送信するオーダー番号（特殊浄化）
     */
    setSelectOrdNo({ commit }, payload) {
      // オーダー番号セット
      commit("setSelectOrdNo", {
        ordNo: payload.ordNo,
        ordNo2: payload.ordNo2,
      });
    },
    /**
     * 選択中の患者指示・実績情報セット
     */
    setViewPatIndRstData({ commit }, data) {
      // 患者情報セット
      commit("setViewPatIndRstData", { viewPatIndRstData: data });
    },
    // 測定中
    setMeasuring({ commit }, measuring) {
      commit("setMeasuring", measuring);
    },

    /**
     * 測定モード切替
     * [0:体重, 1:体重+車いす, 2:車いす]
     */
    setScaleMode({ state, dispatch, commit, getters }, segIndex) {
      // 測定モードセット
      commit("setScaleMode", { scaleMode: segIndex });

      // 車いす表示フラグ
      let isWheelchairView = false;
      if (segIndex > 0) {
        isWheelchairView = true;
      }
      commit("setViewWheelchair", { isWheelchair: isWheelchairView });
      //liyanze-z #9695 add start
      if(getters.getTreatmentMode&&getters.getTreatmentMode.length!=0&&getters.getTreatmentMode[0].deviceMode){
        //治療種別コード
        let tDeviceMode = getters.getTreatmentMode[0].deviceMode;
        const isInvalidMeasuredValue =
            state.measuredValue == null ||
            state.measuredValue === '' ||
            Number(state.measuredValue) === 0;
        //装置モード:特殊浄化("9") retWeight ≠ 0  
        if(tDeviceMode == deviceModeConstant.PURIFICATION&&isInvalidMeasuredValue){
          // 重置计算结果
          commit("setWeightValue", { bodyWeightValue: 0 });
          // 前後体重
          commit("message/setParamBeforeWeight", 0);
          commit("message/setParamAfterWeight", 0);
          commit("setViewMessage", { isMessage: false });
          commit("setMeasuring", false);
          return
        }
      }
      //liyanze-z #9695 add end

      // 体重値再計算[測定値-風袋(-車いす)]
      let weightVal = new BigNumber(state.measuredValue)
        .minus(getters.getTareWeight)
        .toNumber();
      // 車いす表示時
      if (segIndex > 0) {
        weightVal = new BigNumber(weightVal)
          .minus(state.selectWheelchair.weight)
          .toNumber();
      }
      if (isNaN(weightVal)) {
        // 正常に計算できていない場合はnull
        weightVal = null;
      }
      commit("setWeightValue", { bodyWeightValue: weightVal });
      if (
        state.scaleClass === weightScaleClass.before ||
        // #10833 2024.08.08 mod 判定式から治療中を除く TDC米沢 start
        // state.scaleClass === weightScaleClass.noSchedule ||
        // state.scaleClass === weightScaleClass.dialysis
        state.scaleClass === weightScaleClass.noSchedule
        // #10833 2024.08.08 mod 判定式から治療中を除く TDC米沢 end
      ) {
        // 前体重なら除水目標を計算
        commit("message/setParamBeforeWeight", weightVal);
        dispatch("calcRemovalWaterTarget").then(() => {
          dispatch("checkMeasureValue", {
            weightScaleClassCategory: weightScaleClass.before,
          });
        });
      } else if (state.scaleClass === weightScaleClass.after) {
        commit("message/setParamAfterWeight", weightVal);
        dispatch("checkMeasureValue", {
          weightScaleClassCategory: weightScaleClass.after,
        });
      }
    },

    /**
     * 簡易表示・詳細表示セット
     */
    setViewModeIsSimple({ commit }, isSimple) {
      commit("setSimpleMode", { isSimpleMode: isSimple });
    },

    /**
     * 簡易表示・詳細表示切替
     */
    switchViewMode({ state, commit }) {
      commit("setSimpleMode", { isSimpleMode: !state.isSimpleMode });
    },

    /**
     * 前体重・後体重切替
     */
    setBeforeMode({ state, commit }) {
      const setState = state.scaleClass === 0 ? 1 : 0;
      commit("setScaleClass", { scaleClass: setState });
    },

    /**
     * 車いす重量登録
     * @param {Object} context
     * @param {number} value 測定値(kg)
     */
    changeWheelChairWeightValue({ state, commit }, value) {
      commit("setSelectWheelChair", {
        selectWheelchair: {
          code: state.selectWheelchair.code,
          name: state.selectWheelchair.name,
          gramWeight: new BigNumber(value).times(1000),
          weight: value,
          calibrationCheck: state.selectWheelchair.calibrationCheck,
        },
      });
      /* modify by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --start */
      // 車椅子の保持値の設定
      commit("message/setParamWheelChair", value);
      /* modify by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --end */
    },

    /**
     * 測定値登録
     * @param {Object} context
     * @param {number} value 測定値
     */
    setMeasuredValue({ commit }, value) {
      commit("setMeasuredValue", { measuredValue: value });
      // rootに登録されたモジュールmessageのmutationをコミット
      commit("message/setParamMeasureValue", value);
    },

    /**
     * 体重値登録
     * @param {Object} context
     * @param {number} value 体重値
     */
    setWeightValue({ state, commit, getters }, value) {
      //liyanze-z #9695 add start
      if(getters.getTreatmentMode&&getters.getTreatmentMode.length!=0&&getters.getTreatmentMode[0].deviceMode){
        //治療種別コード
        let tDeviceMode = getters.getTreatmentMode[0].deviceMode;
        const isInvalidMeasuredValue =
            state.measuredValue == null ||
            state.measuredValue === '' ||
            Number(state.measuredValue) === 0;
        //装置モード:特殊浄化("9") retWeight ≠ 0  
        if(tDeviceMode == deviceModeConstant.PURIFICATION&&isInvalidMeasuredValue){
          // 重置计算结果
          commit("setWeightValue", { bodyWeightValue: 0 });
          // 前後体重
          commit("message/setParamBeforeWeight", 0);
          commit("message/setParamAfterWeight", 0);
          commit("setViewMessage", { isMessage: false });
          commit("setMeasuring", false);
          return
        }
      }
      //liyanze-z #9695 add end

      commit("setWeightValue", { bodyWeightValue: value });
      if (
        state.scaleClass === weightScaleClass.before ||
        state.scaleClass === weightScaleClass.noSchedule ||
        state.scaleClass === weightScaleClass.dialysis
      ) {
        // 前体重
        commit("message/setParamBeforeWeight", value);
      } else if (state.scaleClass === weightScaleClass.after) {
        // 後体重
        commit("message/setParamAfterWeight", value);
      }
    },
    /**
     * 体重値計算
     */
    calcWeightValue({ commit, state, getters, dispatch }) {
       //liyanze-z #9695 add start
      if(getters.getTreatmentMode&&getters.getTreatmentMode.length!=0&&getters.getTreatmentMode[0].deviceMode){
        //治療種別コード
        let tDeviceMode = getters.getTreatmentMode[0].deviceMode;
        const isInvalidMeasuredValue =
            state.measuredValue == null ||
            state.measuredValue === '' ||
            Number(state.measuredValue) === 0;
        //装置モード:特殊浄化("9") retWeight ≠ 0  
        if(tDeviceMode == deviceModeConstant.PURIFICATION&&isInvalidMeasuredValue){
          // 重置计算结果
          commit("setWeightValue", { bodyWeightValue: 0 });
          // 前後体重
          commit("message/setParamBeforeWeight", 0);
          commit("message/setParamAfterWeight", 0);
          commit("setViewMessage", { isMessage: false });
          commit("setMeasuring", false);
          return
        }
      }
      //liyanze-z #9695 add end
      let retWeight = new BigNumber(state.measuredValue)
        .minus(getters.getTareWeight)
        .toNumber();
      // 車いすありの場合
      if (getters.getIsWheelchair) {
        retWeight = new BigNumber(retWeight)
          .minus(getters.getSelectWheelchair.weight)
          .toNumber();
      }
      if (isNaN(retWeight)) {
        // 正常に計算できていない場合はnull
        retWeight = null;
      }
      commit("setWeightValue", { bodyWeightValue: retWeight });

      if (
        state.scaleClass === weightScaleClass.before ||
        // #10833 2024.08.08 mod 判定式から治療中を除く TDC米沢 start
        // state.scaleClass === weightScaleClass.noSchedule ||
        // state.scaleClass === weightScaleClass.dialysis
        state.scaleClass === weightScaleClass.noSchedule
        // #10833 2024.08.08 mod 判定式から治療中を除く TDC米沢 end
      ) {
        // 前体重
        commit("message/setParamBeforeWeight", retWeight);
        // 前体重なら除水目標を計算
        dispatch("calcRemovalWaterTarget").then(() => {
          dispatch("checkMeasureValue", {
            weightScaleClassCategory: weightScaleClass.before,
          });
        });
      } else if (state.scaleClass === weightScaleClass.after) {
        // 後体重
        commit("message/setParamAfterWeight", retWeight);
        dispatch("checkMeasureValue", {
          weightScaleClassCategory: weightScaleClass.after,
        });
        // add FNSI-後体重の場合、エラーメッセージを表示 徐 start
        // if (retWeight !== null && retWeight > 0) {
        //   // 後体重値があればメッセージ欄を表示
        //   commit("setViewMessage", { isMessage: true });
        // }
        // 後体重値があればメッセージ欄を表示
        commit("setViewMessage", { isMessage: true });
        // add FNSI-後体重の場合、エラーメッセージを表示 徐 end
      }
      commit("setMeasuring", false);
    },
    calcRemovalWaterTarget({ commit, getters }) {
      if (
        getters.getIndTargetWeight.value !== null &&
        getters.getIndWaterRemovalLimit.value !== null
      ) {
        let val = getters.getOffWaterWeight;
        val = new BigNumber(val)
          .plus(getters.getBodyWeightInfo.value)
          .toNumber();
        val = new BigNumber(val)
          .minus(getters.getIndTargetWeight.value)
          .toNumber();
        // 除水制限を超えている場合
        if (val > getters.getIndWaterRemovalLimit.value) {
          val = getters.getIndWaterRemovalLimit.value;
        } else if (val < 0) {
          // マイナスの場合
          val = 0;
        }
        if (isNaN(val)) {
          // 正常に計算できていない場合はnullとする
          val = null;
        }
        commit("setWaterRemovalTarget", { waterRemovalTarget: val });
        commit("message/setParamTargetOffWater", val);
        commit("setViewMessage", { isMessage: true });
      } else {
        commit("setWaterRemovalTarget", { waterRemovalTarget: null });
        commit("message/setParamTargetOffWater", null);
        commit("setViewMessage", { isMessage: true });
      }
    },
    /**
     * 実績から体重測定値計算
     */
    calcMeasuredValue({ commit, state, getters, dispatch }) {
      let retWeight = new BigNumber(getters.getBodyWeightValue)
        .plus(getters.getTareWeight)
        .toNumber();
      // 車いすありの場合
      if (
        getters.getIsWheelchair &&
        getters.getSelectWheelchair.weight !== null
      ) {
        retWeight = new BigNumber(retWeight)
          .plus(getters.getSelectWheelchair.weight)
          .toNumber();
      }
      if (isNaN(retWeight)) {
        // 正常に計算できていない場合はnullとする
        retWeight = null;
      }
      commit("setMeasuredValue", { measuredValue: retWeight });
      commit("message/setParamMeasureValue", retWeight);

      if (
        state.scaleClass === weightScaleClass.before ||
        // #10833 2024.08.08 mod 判定式から治療中を除く TDC米沢 start
        // state.scaleClass === weightScaleClass.noSchedule ||
        // state.scaleClass === weightScaleClass.dialysis
        state.scaleClass === weightScaleClass.noSchedule
        // #10833 2024.08.08 mod 判定式から治療中を除く TDC米沢 end
      ) {
        // 前体重なら除水目標を計算
        dispatch("calcRemovalWaterTarget").then(() => {
          dispatch("checkMeasureValue", {
            weightScaleClassCategory: weightScaleClass.before,
          });
        });
      } else if (state.scaleClass === weightScaleClass.after) {
        dispatch("checkMeasureValue", {
          weightScaleClassCategory: weightScaleClass.after,
        });
      }
    },
    // 測定値チェックを実行して測定値がゼロでなければ表示
    checkMeasureValue({ dispatch, state, commit }, param) {
      dispatch("message/checkMessageList", {
        category: param.weightScaleClassCategory,
      }).then(() => {
        if (Number(state.measuredValue) === 0) {
          // 測定値ゼロならばメッセージ非表示
          commit("message/setIsCheckView", false);
          commit("setMessageSwitch", false);
        } else {
          commit("message/setIsCheckView", true);
          commit("setMessageSwitch", true);
        }
      });
    },

    /**
     * 印刷設定
     */
    setPrintMode({ commit }, printMode) {
      commit("setPrint", { isPrint: printMode });
    },

    /**
     * 前回後体重取得
     * @param {Object} context
     * @param {Object} param
     * @param {Number} param.ordNo オーダ番号
     * @param {Number} param.patId 患者ＩＤ
     * @param {Number} param.previousWeightSourceClass (0:透析・特殊浄化を区別する 1:区別しない)
     */
    fetchLastRstWeight(context, param) {
      const payload = {
        ordNo: param.ordNo,
        patId: param.patId,
        previousWeightSourceClass: param.previousWeightSourceClass,
      };
      if (param.ordNo !== null) {
        return sendRequestGetLastRstWeight(payload);
      } else if (param.patId !== null) {
        return sendRequestGetLastRstWeightPat(payload);
      }
    },
    /**
     * 指定日の前回後体重を含む実績を取得
     * @param {Object} context
     * @param {Object} param
     * @param {Number} param.ordNo オーダ番号
     * @param {Number} param.patId 患者ID
     * @param {Number} param.previousWeightSourceClass (0:透析・特殊浄化を区別する 1:区別しない)
     * @param {String} param.treatDate 検索基準日
     */
    getWeightByTreatDate(context, param) {
      const payload = {
        ordNo: param.ordNo,
        patId: param.patId,
        previousWeightSourceClass: param.previousWeightSourceClass,
        treatDate: param.treatDate,
      };
      if (param.ordNo !== null) {
        //TODO オーダー番号＋検索基準日指定での実装
        return;
      } else if (param.patId !== null) {
        return sendRequestGetWeightByTreatDate(payload);
      }
    },

    /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする Start */

    getWeightByTreatDateAndOrdClass(context, param) {
      if (param.patId) {
        return getWeightByTreatDateAndOrdClass(param);
      }
      return null;
    },
    /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする End */
    /**
     * 前回後体重登録
     * @param {Object} context
     * @param {Number} weight 前回後体重
     */
    setLastTimeWeight({ commit, state, dispatch }, weight) {
      commit("setLastTimeWeight", { lastTimeWeight: weight });
      commit("message/setParamLastWeight", weight);

      if (
        state.scaleClass === weightScaleClass.before ||
        state.scaleClass === weightScaleClass.noSchedule
      ) {
        // 前体重
        dispatch("checkMeasureValue", {
          weightScaleClassCategory: weightScaleClass.before,
        });
      } else if (state.scaleClass === weightScaleClass.after) {
        // 後体重
        dispatch("checkMeasureValue", {
          weightScaleClassCategory: weightScaleClass.after,
        });
      }
    },
    /**
     * 患者IDからの車いす情報の取得
     */
    getWheelChairByPat({ commit }, param) {
      sendRequestGetPersonalWheelChairList({ patId: param.patId }).then((r) => {
        if (r.data.length === 0) {
          // 個人所有車いすなし
          commit("setSelectWheelChairUnknown");
        } else {
          // 個人所有車いすあり
          // 車いす重量はグラム単位で記録されているので、風袋と同様に1グラムを切り捨て
          const chair = r.data[0];
          commit("setSelectWheelChair", {
            selectWheelchair: {
              code: chair.wheelChairCd,
              name: chair.wheelChairName,
              gramWeight: chair.wheelChairWeight,
              weight: tareG2Kg(chair.wheelChairWeight),
              calibrationCheck: chair.calibrationCheck,
            },
          });
          commit("setViewWheelchair", { isWheelchair: true });
          commit("setScaleMode", { scaleMode: weightScaleMode.weightAndChair });
        }
      });
    },
    /**
     * 特定の車いすを設定
     * @param {Object} context
     * @param {Number} wheelChairCd
     */
    setSelectWheelChair({ commit, dispatch }, wheelChairCd) {
      if (wheelChairCd !== null) {
        sendRequestGetWheelChair({ wheelChairCd }).then((r) => {
          if (r.data !== null && r.data.wheelChairName !== undefined) {
            const chair = r.data;
            commit("setSelectWheelChair", {
              selectWheelchair: {
                code: chair.wheelChairCd,
                name: chair.wheelChairName,
                gramWeight: chair.wheelChairWeight,
                weight: tareG2Kg(chair.wheelChairWeight),
                calibrationCheck: chair.calibrationCheck,
              },
            });
          } else {
            commit("setSelectWheelChairUnknown");
          }
          // 体重値再計算
          dispatch("calcWeightValue");
        });
      } else {
        commit("setSelectWheelChairUnknown");
        // 体重値再計算
        dispatch("calcWeightValue");
      }
    },
    /**
     * 身体情報を取得して読み込む
     * 患者情報一覧から、新しいものからデータを取得する
     * データがnullの場合はデータが存在するまでさかのぼって使用する
     * @param {Object} context
     * @param {*} payload
     * @param {Array<Object>} payload.physicalInfoList
     * @param {String} payload.treatDate YYYYMMDD
     */
    loadPhysicalInfo({ commit, state }, payload) {
      const tDate = moment(payload.treatDate, "YYYYMMDD").add(1, "day");

      const physicalInfoList = payload.physicalInfoList
        .filter(
          // 治療日より未来の登録日を除外する
          (elm) => moment(elm.exam_date) < tDate
        )
        .sort(
          // 登録日が新しいもの順にソートする
          // @ts-ignore
          (a, b) => moment(b.exam_date) - moment(a.exam_date)
        );

      for (const physicalInfo of physicalInfoList) {
        // DW[患者情報(身体情報)から]
        if (
          physicalInfo !== null &&
          physicalInfo.dw !== undefined &&
          physicalInfo.dw !== null
        ) {
          // #10833(暫定) 2024.08.19 mod DWについて治療指示/実績のDWで更新された場合は身体情報で更新しないようにする TDC米沢 start
          // commit("setIndDryWeight", { indDryWeight: physicalInfo.dw });
          // commit("message/setParamDw", physicalInfo.dw);
          // 画面/印刷用情報のDWにord_main.ind_dw、またはord_main.rst_dwがセットされているか確認
          if (
            this.getters["send-condition/scale/message/getIsIndRstDW"] == false
          ) {
            // DWに身体情報のDWがセットされている場合

            // DW更新
            commit("setIndDryWeight", { indDryWeight: physicalInfo.dw });
            commit("message/setParamDw", physicalInfo.dw);
          }
          // #10833(暫定) 2024.08.19 mod DWについて治療指示/実績のDWで更新された場合は身体情報で更新しないようにする TDC米沢 end
          if (
            state.viewPatIndRstData &&
            state.viewPatIndRstData.condInfo &&
            state.viewPatIndRstData.condInfo["3"] &&
            (state.viewPatIndRstData.condInfo["3"].value === null ||
              // mod #9973 shiyw start
              // state.viewPatIndRstData.condInfo["3"].value === -1)
              state.viewPatIndRstData.condInfo["3"].value == "-1")
            // mod #9973 shiyw end
          ) {
            // 目標体重が -1 または null の場合（目標体重 = DWの設定の場合）
            commit("setIndTargetWeight", { indTargetWeight: physicalInfo.dw });
            commit("message/setParamTargetWeight", physicalInfo.dw);
          }

          // #10290 2024.03.07 del 前体重許容上下限値はそれぞれの最新値を使用する TDC米沢 start
          // // 前後体重許容上下限はDW設定と同じ時に設定されたものを使用する
          // // NOTE: if (physicalInfo.pre_scale_upper) では値が0の場合にfalseとなるため、=0 の場合は許容する
          // if (physicalInfo.pre_scale_upper || Number(physicalInfo.pre_scale_upper) === 0) {
          //   commit("message/setPatPreScaleUpper", physicalInfo.pre_scale_upper);
          // } else {
          //   commit("message/setPatPreScaleUpper", null);
          // }
          // if (physicalInfo.pre_scale_lower || Number(physicalInfo.pre_scale_lower) === 0) {
          //   commit("message/setPatPreScaleLower", physicalInfo.pre_scale_lower);
          // } else {
          //   commit("message/setPatPreScaleLower", null);
          // }
          // #10290 2024.03.07 del 前体重許容上下限値はそれぞれの最新値を使用する TDC米沢 end

          break;
        }
      }

      // #10290 2024.03.07 add 前体重許容上下限値はそれぞれの最新値を使用する TDC米沢 start
      // NOTE: if (physicalInfo.pre_scale_upper) では値が0の場合にfalseとなるため、=0 の場合は許容する
      var preScaleUpper = null;
      var preScaleLower = null;
      for (const physicalInfo of physicalInfoList) {
        // 前体重許容上下限値[患者情報(身体情報)から]
        if (physicalInfo) {
          // 身体情報あり

          // 前体重許容上限値取得判定
          if (
            preScaleUpper == null &&
            physicalInfo.pre_scale_upper != null &&
            Number(physicalInfo.pre_scale_upper) >= 0
          ) {
            // 前体重許容上限値が未取得で設定値がNULL以外で0以上の場合は取得
            preScaleUpper = physicalInfo.pre_scale_upper;
          }
          // 前体重許容下限値取得判定
          if (
            preScaleLower == null &&
            physicalInfo.pre_scale_lower != null &&
            Number(physicalInfo.pre_scale_lower) >= 0
          ) {
            // 前体重許容下限値が未取得で設定値がNULL以外で0以上の場合は取得
            preScaleLower = physicalInfo.pre_scale_lower;
          }

          // 前体重許容上下限値が取得できた場合
          if (preScaleUpper != null && preScaleLower != null) {
            // 繰り返し処理を抜ける
            break;
          }
        }
      }
      // 前体重許容上限値設定
      commit("message/setPatPreScaleUpper", preScaleUpper);
      // 前体重許容下限値設定
      commit("message/setPatPreScaleLower", preScaleLower);
      // #10290 2024.03.07 add 前体重許容上下限値はそれぞれの最新値を使用する TDC米沢 end

      // add FNSI-目標体重 = DWの設定の場合、DWをnull 徐 start
      if (
        physicalInfoList.length === 0 &&
        state.viewPatIndRstData &&
        state.viewPatIndRstData.condInfo &&
        state.viewPatIndRstData.condInfo["3"] &&
        (state.viewPatIndRstData.condInfo["3"].value === null ||
          state.viewPatIndRstData.condInfo["3"].value == "-1")
      ) {
        // mod #9973 shiyw,modify value === -1 to value == "-1"
        commit("setIndTargetWeight", { indTargetWeight: null });
      }
      // add FNSI-目標体重 = DWの設定の場合、DWをnull 徐 end
      for (const physicalInfo of physicalInfoList) {
        // 身長[患者情報(身体情報)から]
        if (
          physicalInfo !== null &&
          physicalInfo.height !== undefined &&
          physicalInfo.height !== null
        ) {
          commit("message/setPatHeight", physicalInfo.height);
          break;
        }
      }
    },
    /**
     * 校正切れチェック
     * @param {Object} context
     * @param {Object} param
     * @param {String} param.facilityCd 施設コード
     */
    async checkCalibration({ state, commit }, param) {
      // 校正切れチェック
      const checkCalibrationP = {
        wheelChairCd: state.selectWheelchair.code,
        facilityCd: param.facilityCd,
      };
      if (
        checkCalibrationP.wheelChairCd != null &&
        checkCalibrationP.facilityCd != null &&
        checkCalibrationP.facilityCd != ""
      ) {
        await checkCalibrationByCd(checkCalibrationP).then((r) => {
          if (r.data !== null) {
            commit("setSelectWheelChair", {
              selectWheelchair: {
                code: state.selectWheelchair.code,
                name: state.selectWheelchair.name,
                gramWeight: state.selectWheelchair.gramWeight,
                weight: state.selectWheelchair.weight,
                calibrationCheck: r.data,
              },
            });
          }
        });
      }
    },
    /**
     * 指定オーダ番号の指示・実績取得
     * @param {Object} context
     * @param {Object} param
     * @param {Number} param.ordNo オーダ番号
     * @param {Number} param.ordNo2 オーダ番号2
     * @param {String} param.facilityCd 施設コード
     * @param {boolean} param.isScaleBed スケールベッドから呼び出されたかどうか
     * @param {number} param.scaleBedMeasureValue スケールベッドから呼び出された場合の測定値
     */
    async fetchIndRstData({ state, commit, dispatch }, param) {
      const ordNo = param.ordNo;

      // 指定オーダ番号の指示・実績取得
      const response = await sendRequestGetOrderMain(ordNo);

      /**@type {String} 施設名称*/
      const facilityName = response.data.facilityName;

      // 取得した指示・実績取得をセット
      const resData = response.data.ord;

      // 患者割当車いす(個人所有・共用所有)
      const wheelChairMode = response.data.wheelChairMode;
      const patChair = response.data.wheelChair;
      // 次回透析予定
      const nextOrd = response.data.nextOrd;
      // 患者身体情報
      const physicalInfo = response.data.physicalInfo;
      // 装置状態
      const machineState = response.data.machineState;

      // メッセージ系をリセット
      commit("message/resetParams");

      if (resData === null) {
        return false;
      }

      // 患者ＩＤ
      commit("setPatId", { patId: resData.patId });
      // 施設名称
      commit("message/setFacilityName", facilityName);
      // 装置設定
      const deviceInfo = response.data.patDeviceSet;
      commit("setDeviceInfo", { info: deviceInfo, index: 0 });

      // *******************
      // 治療状況に応じた画面表示
      // *******************
      const wsc = weightScaleClassByDialysisState(
        Number(resData.rstDialysisState)
      );
      commit("setScaleClass", { scaleClass: wsc });

      // *******************
      // 測定履歴の取得
      // *******************
      const lastWeightResponse = await sendRequestLastScale({
        ordNo,
        scaleClass: state.scaleClass,
      });

      const weightScale = lastWeightResponse.data;

      // *******************
      // 指示・実績JSONを解析
      // *******************
      resData.condInfo = JSON.parse(resData.indCondInfo);
      resData.indScheduleUserInfo = JSON.parse(resData.indScheduleUserInfo);
      // 体重実績
      resData.rstWeightInfo = JSON.parse(resData.rstWeightInfo);

      // 除水補正情報
      resData.offWaterInfo = JSON.parse(resData.indOffWaterInfo);
      resData.oldOffWaterInfo = JSON.parse(resData.indOffWaterInfo);
      // 風袋情報
      resData.tareInfo = JSON.parse(resData.indTareInfo);
      resData.oldTareInfo = JSON.parse(resData.indTareInfo);

      // 後体重画面の場合
      if (state.scaleClass == weightScaleClass.after) {
        // 治療条件実績
        resData.condInfo = JSON.parse(resData.rstCondInfo);
        // 除水補正情報
        resData.offWaterInfo = JSON.parse(resData.rstOffWaterInfo);
        resData.oldOffWaterInfo = JSON.parse(resData.rstOffWaterInfo);
        // 風袋情報
        const tareData = JSON.parse(resData.rstTareInfo);
        resData.tareInfo = tareData.after;
        resData.oldTareInfo = tareData.after;
      }

      resData.offWaterWeight = tareOrOffWaterWeightTotal(resData.offWaterInfo);
      resData.tareWeight = tareOrOffWaterWeightTotal(resData.tareInfo);

      commit("setViewPatIndRstData", { viewPatIndRstData: resData });

      // *******************
      // 表示情報をセット
      // *******************

      // 風袋
      commit("setTareInfo", { tareInfo: resData.tareInfo });
      commit("setOldTareInfo", { oldTareInfo: resData.tareInfo });
      commit("setTareWeight", { tareWeight: resData.tareWeight });
      commit("message/setParamTare", resData.tareWeight);

      // 除水補正
      commit("setOffWaterInfo", { offWaterInfo: resData.offWaterInfo });
      commit("setOldOffWaterInfo", { oldOffWaterInfo: resData.offWaterInfo });
      commit("setOffWaterWeight", { offWaterWeight: resData.offWaterWeight });
      commit("message/setParamOffWater", resData.offWaterWeight);

      // 透析時間[透析条件:1] 分
      if (resData.condInfo && resData.condInfo["1"]) {
        const setData = resData.condInfo["1"].value;
        if (setData !== undefined) {
          commit("message/setDialysisTime", setData);
        }
      }

      // 目標体重[透析条件:3] fnw:6文字以内[整数3桁小数2桁（000.00～300.00）]
      if (resData.condInfo && resData.condInfo["3"]) {
        const setData = resData.condInfo["3"].value;
        if (setData !== undefined && setData >= 0) {
          commit("setIndTargetWeight", { indTargetWeight: setData });
          commit("message/setParamTargetWeight", setData);
        }
      }
      // 除水量制限[透析条件:4] fnw:4文字以内[整数1桁小数2桁（0.00～9.99）]
      if (resData.condInfo && resData.condInfo["4"]) {
        const setData = resData.condInfo["4"].value;
        if (setData !== undefined) {
          commit("setIndWaterRemovalLimit", { indWaterRemovalLimit: setData });
          commit("message/setParamLimitOffWater", setData);
        }
      }
      // I-HDF引き残し量
      // #11017 2024.08.22 mod I-HDF引き残し量はpull_leave_amountではなくrst_weight.info.ihdf_pllを使用する TDC米沢 start
      //commit("message/setParamBullLeaveAmount", resData.pullLeaveAmount);
      if (
        resData.rstWeightInfo !== null &&
        resData.rstWeightInfo.ihdf_pll !== undefined
      ) {
        commit(
          "message/setParamBullLeaveAmount",
          resData.rstWeightInfo.ihdf_pll
        );
      }
      // #11017 2024.08.22 mod I-HDF引き残し量はpull_leave_amountではなくrst_weight.info.ihdf_pllを使用する TDC米沢 end

      // 透析時間実績
      commit("message/setRstDialysisTime", {
        rstStartDate: resData.rstStartDate,
        rstEndDate: resData.rstEndDate,
      });

      dispatch("loadPhysicalInfo", {
        physicalInfoList: physicalInfo,
        treatDate: resData.treatDate,
      });

      // *******************
      // 中断情報や実績から情報を復元する
      // *******************

      commit("setViewWheelchair", { isWheelchair: false });
      commit("setSelectWheelChairUnknown");
      commit("setScaleMode", {
        scaleMode: weightScaleMode.weight,
      });
      commit("setIsHasOrdWeightScale", false);

      // 前回測定値をリセット
      commit("setLastScaleValue", null);
      commit("setLastWheelChairCd", null);
      commit("setLastWheelChairValue", null);

      // 前回の測定モードをリセット
      commit("setLastScaleMode", null);

      // 患者車いすの有無をリセット
      commit("setIsUsePatWheelChair", false);

      // #10833(暫定) 2024.08.19 add 治療指示DWがあればそれをセット TDC米沢 start
      let setData = resData.indDw;
      if (setData !== null && setData >= 0) {
        commit("setIndDryWeight", { indDryWeight: setData });
        commit("message/setParamDw", setData);
        // 身体情報のDWで上書きできないようにする
        commit("message/setIsIndRstDW", true);
      }
      // #10833(暫定) 2024.08.19 add 治療指示DWがあればそれをセット TDC米沢 end

      if (
        // #10833 2024.08.08 mod 判定式に透析中を追加 TDC米沢 start
        // state.scaleClass === weightScaleClass.after &&
        (state.scaleClass === weightScaleClass.after ||
          state.scaleClass === weightScaleClass.dialysis) &&
        // #10833 2024.08.08 mod 判定式に透析中を追加 TDC米沢 end
        resData.rstWeightInfo !== null
      ) {
        // 後体重測定時は前体重と除水積算をあらかじめ取得しておく
        // 前体重[実績から]
        let setData = resData.rstWeightInfo.weight_before;
        commit("setBeforeWeightValue", { beforeWeightValue: setData });
        commit("message/setParamBeforeWeight", setData);
        // #10833 2024.08.08 mod 目標除水量[実績から]を追加 TDC米沢 start
        // 目標除水量[実績から]
        setData = resData.rstWeightInfo.water_removal_target;
        commit("setWaterRemovalTarget", { waterRemovalTarget: setData });
        commit("message/setParamTargetOffWater", setData);
        // #10833 2024.08.08 mod 目標除水量[実績から]を追加 TDC米沢 end
        // 除水実績[実績から]
        setData = resData.rstWeightInfo.water_removal_rst;
        commit("setDewateringIntegration", { dewateringIntegration: setData });
        // #11017 2024.08.29 add 除水実績[実績から]を画面/印刷用パラメータにセット TDC米沢 start
        commit("message/setParamResultOffWater", setData);
        // #11017 2024.08.29 add 除水実績[実績から]を画面/印刷用パラメータにセット TDC米沢 end
      }

      // #10833(暫定) 2024.08.19 add 治療実績のDWがあればそれをセット TDC米沢 start
      setData = resData.rstDw;
      if (
        (state.scaleClass === weightScaleClass.after ||
          state.scaleClass === weightScaleClass.dialysis) &&
        setData !== null &&
        setData >= 0
      ) {
        commit("setIndDryWeight", { indDryWeight: setData });
        commit("message/setParamDw", setData);
        // 身体情報のDWで上書きできないようにする
        commit("message/setIsIndRstDW", true);
      }
      // #10833(暫定) 2024.08.19 add 治療実績のDWがあればそれをセット TDC米沢 end

      if (state.scaleClass === weightScaleClass.dialysis) {
        // *******************
        // 治療中 後体重の車いすモードを先に測定可能な状態にできる
        // *******************
        commit("setIsHasOrdWeightScale", true);

        // 車いす測定モードを開始
        commit("setScaleMode", {
          scaleMode: weightScaleMode.wheelChair,
        });

        if (
          weightScale.weightScaleNo !== null &&
          weightScale.patId === resData.patId &&
          weightScale.ordNo === resData.ordNo &&
          weightScale.wheelChairWeight !== null
        ) {
          // 前回測定あり 車いす重量の登録

          // 測定値を取得
          commit("setMeasuredValue", { measuredValue: weightScale.scaleValue });
          commit("message/setParamMeasureValue", weightScale.scaleValue);

          // 車いす測定モードを開始
          commit("setSelectWheelChair", {
            selectWheelchair: {
              code: weightScale.wheelChairCd,
              name: weightScale.wheelChairName,
              gramWeight: weightScale.wheelChairWeight,
              weight: tareG2Kg(weightScale.wheelChairWeight),
              calibrationCheck: true,
            },
          });
          dispatch(
            "changeWheelChairWeightValue",
            tareG2Kg(weightScale.wheelChairWeight)
          );
          commit("setViewWheelchair", { isWheelchair: true });

          // 前回測定情報をセット
          commit("setLastScaleValue", weightScale.scaleValue);
          commit("setLastWheelChairValue", weightScale.wheelChairWeight);
          commit("setLastScaleMode", weightScale.scaleMode);

            // 体重値その他算出
          dispatch("calcWeightValue");
        }
      } else {
        // *******************
        // 治療中以外 前回測定の状況によって動作が変わる
        // *******************

        if (
          weightScale.weightScaleNo !== null &&
          weightScale.patId === resData.patId &&
          weightScale.ordNo === resData.ordNo
        ) {
          // 前回測定あり
          commit("setIsHasOrdWeightScale", true);

          // #11987 2025.11.28 mod スケールベッドから呼び出した場合は、測定モードを独歩にする。 TDC渡辺 start
          // 前回測定が体重モードなら送信成否にかかわらず体重モードで起動
          //if (weightScale.scaleMode === weightScaleMode.weight) {
          if (weightScale.scaleMode === weightScaleMode.weight || param.isScaleBed) {
            if( param.isScaleBed){
              // 測定値を0セット
              weightScale.scaleValue = 0;
              // 車いす重量を0セット
              weightScale.wheelChairWeight =0;
            }

            // #11987 2025.11.28 mod スケールベッドから呼び出した場合は、測定モードを独歩にする。 TDC渡辺 end　

            // 測定値を取得
            commit("setMeasuredValue", {
              measuredValue: weightScale.scaleValue,
            });
            commit("message/setParamMeasureValue", weightScale.scaleValue);

            // 測定値を前回測定値としてセット
            commit("setLastScaleValue", weightScale.scaleValue);

            // 前回の測定モードをセット
            commit("setLastScaleMode", weightScale.scaleMode);
            // 体重値その他算出
            dispatch("calcWeightValue");
          } else if (weightScale.weightScaleStatus === weightScaleState.wait) {
            // 前回測定が保留なら未測定側のモードで起動
            if (weightScale.scaleMode === weightScaleMode.weightAndChair) {
              // 前回測定が体重＋車いすモード: 車いすモードで起動

              // 測定値を取得
              commit("setMeasuredValue", {
                measuredValue: weightScale.scaleValue,
              });
              commit("message/setParamMeasureValue", weightScale.scaleValue);

              // 車いす測定モードを開始
              commit("setSelectWheelChairUnknown");
              dispatch("changeWheelChairWeightValue", null);
              commit("setViewWheelchair", { isWheelchair: true });
              commit("setScaleMode", {
                scaleMode: weightScaleMode.wheelChair,
              });

              // 前回測定情報をセット
              commit("setLastScaleValue", weightScale.scaleValue);
              commit("setLastWheelChairValue", null);
              commit("setLastScaleMode", weightScale.scaleMode);

              // 体重値その他算出
              dispatch("calcWeightValue");
            } else if (weightScale.scaleMode === weightScaleMode.wheelChair) {
              // 前回測定が車いすモード: 体重＋車いすモードで起動

              // 車いす情報取得
              commit("setSelectWheelChair", {
                selectWheelchair: {
                  code: weightScale.wheelChairCd,
                  name: weightScale.wheelChairName,
                  gramWeight: weightScale.wheelChairWeight,
                  weight: tareG2Kg(weightScale.wheelChairWeight),
                  calibrationCheck: true,
                },
              });
              commit("setViewWheelchair", { isWheelchair: true });
              // 体重車いす測定モードを開始
              commit("setScaleMode", {
                scaleMode: weightScaleMode.weightAndChair,
              });

              // 前回測定情報をセット
              // commit("setLastScaleValue", 0);
              commit(
                "setLastScaleValue",
                // #12236 体重測定の動作不正 linjunfeng start
                // weightScale.scaleValue ? weightScale.scaleValue : 0
                weightScale.scaleValue
                // #12236 体重測定の動作不正 linjunfeng end
              );
              commit("setLastWheelChairCd", weightScale.wheelChairCd);
              commit("setLastWheelChairValue", weightScale.wheelChairWeight);
              commit("setLastScaleMode", weightScale.scaleMode);

              // 体重値その他算出
              dispatch("calcWeightValue");
            }
          } else if (
            weightScale.scaleMode === weightScaleMode.weightAndChair ||
            weightScale.scaleMode === weightScaleMode.wheelChair
          ) {
            // 前回測定が体重＋車いすor車いすモードで保留以外
            if (
              weightScale.weightScaleStatus === weightScaleState.sendSuccess
            ) {
              // 送信成功しているならば体重＋車いすで起動
              // 車いす情報取得
              commit("setSelectWheelChair", {
                selectWheelchair: {
                  code: weightScale.wheelChairCd,
                  name: weightScale.wheelChairName,
                  gramWeight: weightScale.wheelChairWeight,
                  weight: tareG2Kg(weightScale.wheelChairWeight),
                  calibrationCheck: true,
                },
              });

              // 測定値を取得
              commit("setMeasuredValue", {
                measuredValue: weightScale.scaleValue,
              });
              commit("message/setParamMeasureValue", weightScale.scaleValue);

              commit("setViewWheelchair", { isWheelchair: true });
              // 体重車いす測定モードを開始
              commit("setScaleMode", {
                scaleMode: weightScaleMode.weightAndChair,
              });

              // 前回測定情報をセット
              commit("setLastScaleValue", weightScale.scaleValue);
              commit("setLastWheelChairCd", weightScale.wheelChairCd);
              commit("setLastWheelChairValue", weightScale.wheelChairWeight);
              commit("setLastScaleMode", weightScale.scaleMode);

              // 体重値その他算出
              dispatch("calcWeightValue");
            } else {
              // 送信失敗しているならば前回と同じモードで起動

              if (weightScale.scaleMode === weightScaleMode.weightAndChair) {
                // 前回測定が体重＋車いすモード: 体重＋車いすモードで起動
                // 車いす情報取得
                commit("setSelectWheelChair", {
                  selectWheelchair: {
                    code: weightScale.wheelChairCd,
                    name: weightScale.wheelChairName,
                    gramWeight: weightScale.wheelChairWeight,
                    weight: tareG2Kg(weightScale.wheelChairWeight),
                    calibrationCheck: true,
                  },
                });

                // 測定値を取得
                commit("setMeasuredValue", {
                  measuredValue: weightScale.scaleValue,
                });
                commit("message/setParamMeasureValue", weightScale.scaleValue);

                commit("setViewWheelchair", { isWheelchair: true });
                // 体重車いす測定モードを開始
                commit("setScaleMode", {
                  scaleMode: weightScaleMode.weightAndChair,
                });

                // 前回測定情報をセット
                commit("setLastScaleValue", weightScale.scaleValue);
                commit("setLastWheelChairCd", weightScale.wheelChairCd);
                commit("setLastWheelChairValue", weightScale.wheelChairWeight);
                commit("setLastScaleMode", weightScale.scaleMode);

                // 体重値その他算出
                dispatch("calcWeightValue");
              } else if (weightScale.scaleMode === weightScaleMode.wheelChair) {
                // 前回測定が車いすモード: 車いすモードで起動

                // 測定値を取得
                commit("setMeasuredValue", {
                  measuredValue: weightScale.scaleValue,
                });
                commit("message/setParamMeasureValue", weightScale.scaleValue);

                // 車いす測定モードを開始
                commit("setSelectWheelChairUnknown");
                dispatch(
                  "changeWheelChairWeightValue",
                  tareG2Kg(weightScale.wheelChairWeight)
                );
                commit("setViewWheelchair", { isWheelchair: true });
                commit("setScaleMode", {
                  scaleMode: weightScaleMode.wheelChair,
                });
                // add #12236 車いすが測定済みの場合は「体重＋車いす」の測定モードで起動する事。 linjunfeng start
                if (weightScale.weightScaleStatus === weightScaleState.measured) {
                  commit("setScaleMode", {
                    scaleMode: weightScaleMode.weightAndChair,
                  });
                }
                // add #12236 車いすが測定済みの場合は「体重＋車いす」の測定モードで起動する事。 linjunfeng end
                // 前回測定情報をセット
                commit("setLastScaleValue", weightScale.scaleValue);
                commit("setLastWheelChairValue", weightScale.wheelChairWeight);
                commit("setLastScaleMode", weightScale.scaleMode);

                // 体重値その他算出
                dispatch("calcWeightValue");
              }
            }
          }
        } else if (
          weightScale.weightScaleNo !== null &&
          weightScale.patId === resData.patId &&
          weightScale.ordNo === null &&
          weightScale.scaleMode === weightScaleMode.weight
        ) {
          // 前回測定が体重モードでスケジュールなしの場合、体重モードで起動

          // 測定値を取得
          commit("setMeasuredValue", { measuredValue: weightScale.scaleValue });
          commit("message/setParamMeasureValue", weightScale.scaleValue);

          // 測定値を前回測定値としてセット
          commit("setLastScaleValue", weightScale.scaleValue);

          // 前回の測定モードをセット
          commit("setLastScaleMode", weightScale.scaleMode);

          // 体重値その他算出
          dispatch("calcWeightValue");
        } else if (
          weightScale.weightScaleNo !== null &&
          weightScale.patId === resData.patId &&
          weightScale.ordNo === null &&
          (weightScale.scaleMode === weightScaleMode.weightAndChair ||
            weightScale.scaleMode === weightScaleMode.wheelChair)
        ) {

          // 前回測定が体重＋車いすor車いすモードでスケジュールなしの場合、車いす重量の登録状態により移行モードが変動する
          commit("setIsHasOrdWeightScale", true);
          if (weightScale.wheelChairWeight !== null) {
            // 車いす重量登録済み: 体重＋車いすモードで起動

            // 車いす情報取得
            commit("setSelectWheelChair", {
              selectWheelchair: {
                code: weightScale.wheelChairCd,
                name: weightScale.wheelChairName,
                gramWeight: weightScale.wheelChairWeight,
                weight: tareG2Kg(weightScale.wheelChairWeight),
                calibrationCheck: true,
              },
            });

            // 測定値を取得
            commit("setMeasuredValue", {
              measuredValue: weightScale.scaleValue,
            });
            commit("message/setParamMeasureValue", weightScale.scaleValue);

            commit("setViewWheelchair", { isWheelchair: true });
            // 体重車いす測定モードを開始
            commit("setScaleMode", {
              scaleMode: weightScaleMode.weightAndChair,
            });

            // 前回測定情報をセット
            commit("setLastScaleValue", weightScale.scaleValue);
            commit("setLastWheelChairCd", weightScale.wheelChairCd);
            commit("setLastWheelChairValue", weightScale.wheelChairWeight);
            commit("setLastScaleMode", weightScale.scaleMode);

            // 体重値その他算出
            dispatch("calcWeightValue");

          } else {
            // 車いす重量未登録: 車いすモードで起動

            // 測定値を取得
            commit("setMeasuredValue", {
              measuredValue: weightScale.scaleValue,
            });
            commit("message/setParamMeasureValue", weightScale.scaleValue);

            // 車いす測定モードを開始
            commit("setSelectWheelChairUnknown");
            dispatch("changeWheelChairWeightValue", 0);
            commit("setViewWheelchair", { isWheelchair: true });
            commit("setScaleMode", {
              scaleMode: weightScaleMode.wheelChair,
            });

            // 前回測定情報をセット
            commit("setLastScaleValue", weightScale.scaleValue);
            commit("setLastWheelChairValue", 0);
            commit("setLastScaleMode", weightScale.scaleMode);

            // 体重値その他算出
            dispatch("calcWeightValue");
          }
        } else {
          // 前回測定がない場合
          // 普通に体重測定（1回目）
          if (patChair.length > 0 || wheelChairMode.isWheelChair === "1") {
            // 患者に車いす(個人所有・共用所有)がある
            if (patChair.length > 0) {
              const chair = patChair[0];
              commit("setSelectWheelChair", {
                selectWheelchair: {
                  code: chair.wheelChairCd,
                  name: chair.wheelChairName,
                  gramWeight: chair.wheelChairWeight,
                  weight: tareG2Kg(chair.wheelChairWeight),
                  calibrationCheck: true,
                },
              });
              commit("setViewWheelchair", { isWheelchair: true });
              commit("setScaleMode", {
                scaleMode: weightScaleMode.weightAndChair,
              });

              let scaleMode;
              if (state.scaleClass === weightScaleClass.after) {
                // 後体重測定
                // del #12236 体重測定の動作不正 linjunfeng start
                // 同一ord_noの前体重測定履歴を取得
                // const lastBeforeWeightResponse = await sendRequestLastScale({
                //   ordNo,
                //   scaleClass: weightScaleClass.before,
                // });
                // const beforeWeightScale = lastBeforeWeightResponse.data;

                // // 前体重測定時に選択した車椅子を適用
                // commit("setSelectWheelChair", {
                //   selectWheelchair: {
                //     code: beforeWeightScale.wheelChairCd,
                //     name: beforeWeightScale.wheelChairName,
                //     gramWeight: beforeWeightScale.wheelChairWeight,
                //     weight: tareG2Kg(beforeWeightScale.wheelChairWeight),
                //     calibrationCheck: true,
                //   },
                // });
                // del #12236 体重測定の動作不正 linjunfeng end
                scaleMode = wheelChairMode.chairMeasureModeAfter;
              } else {
                // 前体重測定
                scaleMode = wheelChairMode.chairMeasureModeBefore;
              }
              if (scaleMode === "1") {
                // 体重＋車いす→車いすのときは前回測定値に個人車いすを登録
                commit("setLastWheelChairCd", chair.wheelChairCd);
                commit("setLastWheelChairValue", chair.wheelChairWeight);
                commit("setLastScaleMode", weightScaleMode.weightAndChair);
                commit("setIsUsePatWheelChair", true);
              }
            } else {
              // 未登録車いす
              commit("setSelectWheelChairUnknown");
              commit("setViewWheelchair", { isWheelchair: true });
              let scaleMode;
              if (state.scaleClass === weightScaleClass.after) {
                // 後体重測定
                scaleMode = wheelChairMode.chairMeasureModeAfter;
              } else {
                // 前体重測定
                scaleMode = wheelChairMode.chairMeasureModeBefore;
              }
              if (scaleMode === "2") {
                // 車いすを先に測定
                commit("setScaleMode", {
                  scaleMode: weightScaleMode.wheelChair,
                });
                // add #12236 体重測定の動作不正 linjunfeng start
                commit("setMeasuredValue", {measuredValue: null});
                // add #12236 体重測定の動作不正 linjunfeng end
              } else {
                // 体重＋車いすを先に測定
                commit("setScaleMode", {
                  scaleMode: weightScaleMode.weightAndChair,
                });
              }
            }
          }
          // add #12236 透析中車いす測定データが、後体重測定時の車いすデータとして認識させること。 linjunfeng start
          if (!weightScale && state.scaleClass === weightScaleClass.after && resData.rstDialysisState == dialysisState.afterDialysis) {
            const lastBeforeWeightResponse = await sendRequestLastScale({
              ordNo,
              scaleClass: weightScaleClass.dialysis,
            });
            const lastBeforeWeight = lastBeforeWeightResponse.data;
            if (lastBeforeWeight) {
              commit("setSelectWheelChairUnknown");
              commit("setViewWheelchair", { isWheelchair: true });
              if (!lastBeforeWeight.wheelChairCd && !lastBeforeWeight.wheelChairWeight && patChair.length > 0) {
                const chair = patChair[0];
                commit("setSelectWheelChair", {
                  selectWheelchair: {
                    code: chair.wheelChairCd,
                    name: chair.wheelChairName,
                    gramWeight: chair.wheelChairWeight,
                    weight: tareG2Kg(chair.wheelChairWeight),
                    calibrationCheck: true,
                  },
                });
              } else {
                commit("setSelectWheelChair", {
                  selectWheelchair: {
                    code: lastBeforeWeight.wheelChairCd,
                    name: lastBeforeWeight.wheelChairName ?? unknownWheelChairName,
                    gramWeight: lastBeforeWeight.wheelChairWeight,
                    weight: tareG2Kg(lastBeforeWeight.wheelChairWeight),
                    calibrationCheck: true,
                  },
                });
              }
              commit("setLastWheelChairCd", lastBeforeWeight.wheelChairCd);
              commit("setLastWheelChairValue", lastBeforeWeight.wheelChairWeight);
              commit("setLastScaleMode", weightScaleMode.weightAndChair);
              commit("setScaleMode", {
                scaleMode: weightScaleMode.weightAndChair,
              });
            }
          }
          // add #12236 透析中車いす測定データが、後体重測定時の車いすデータとして認識させること。 linjunfeng end
          }

          // 体重値その他算出
          dispatch("calcWeightValue");
      }

      // ***********************************
      // * 次回透析予定
      // ***********************************
      if (nextOrd !== null) {
        const nextDate = nextOrd.treatDate;
        const year = nextDate.substring(0, 4);
        const month = nextDate.substring(4, 6);
        const day = nextDate.substring(6);
        commit("message/setParamNextDateMMDD", `${month}/${day}`);
        commit("message/setParamNextDateYYYYMMDD", `${year}/${month}/${day}`);
        const nextStartTime = nextOrd.indTreatStartTime;
        if (nextStartTime) {
          const h = nextStartTime.substring(0, 2);
          const m = nextStartTime.substring(2, 4);
          commit(
            "message/setNextSchedule",
            new Date(`${year}/${month}/${day} ${h}:${m}`)
          );
        } else {
          commit(
            "message/setNextSchedule",
            new Date(`${year}/${month}/${day}`)
          );
        }
      }
      // 装置状態の記録
      commit("setMachineState", { index: 0, machineState });

      // エラーメッセージ準備
      // del FNSI-分類不一致判断の追加 徐 start
      //commit("message/setLocalMessage", []);
      //await dispatch("showErrorMessage", { isList: true });
      // del FNSI-分類不一致判断の追加 徐 end
      if (wsc === weightScaleClass.dialysis) {
        // 治療中の場合
        dispatch("setErrorMessage", {
          // mod FNSI-体重測定・条件送信message修正 鄭 start
          //message: "治療中です（条件送信不可）",
          message: "治療中です（条件送信不可，前体重、後体重測定不可）",
          // mod FNSI-体重測定・条件送信message修正 鄭 end
          isError: true,
          iwWarn: false,
        });
        dispatch("showErrorMessage", { isList: false });
      } else if (wsc === weightScaleClass.pastDialysis) {
        // 実績確定後
        dispatch("setErrorMessage", {
          message: "後体重確認済みです（後体重送信不可）",
          isError: true,
          iwWarn: false,
        });
        dispatch("showErrorMessage", { isList: false });
      } else {
        // 装置状態系エラーメッセージの表示
        dispatch("setMachineStateMessage", 0);
      }

      // ordNo2読み込み
      // add FNSI-msgの修正 徐 start
      // dispatch("fetchIndRstDataSecondOrd", { ordNo: param.ordNo2 });
      await dispatch("fetchIndRstDataSecondOrd", { ordNo: param.ordNo2 });
      // add FNSI-msgの修正 徐 end

      // 校正切れチェック
      await dispatch("checkCalibration", { facilityCd: param.facilityCd });
      return true;
    },

    /**
     * 指定オーダ番号2の指示・実績取得
     * @param {Object} context
     * @param {Object} param
     * @param {Number} param.ordNo オーダ番号
     */
    async fetchIndRstDataSecondOrd({ commit, state, dispatch }, param) {
      const ordNo = param.ordNo;

      if (ordNo === null) {
        // 指示2は無し
        commit("setViewPatIndRstData2", { viewPatIndRstData: {} });
        // 装置状態の記録
        commit("setMachineState", { index: 1, machineState: null });
        // 装置設定
        commit("setDeviceInfo", { index: 1, info: null });
        return;
      }

      // 指定オーダ番号の指示・実績取得(基本的に特殊浄化)
      const response = await sendRequestGetOrderMain(ordNo);

      // 取得した指示・実績取得をセット
      const resData = response.data.ord;
      // 装置状態
      const machineState = response.data.machineState;
      // 装置設定
      const deviceInfo = response.data.patDeviceSet;
      commit("setDeviceInfo", { info: deviceInfo, index: 1 });

      // *******************
      // 指示・実績JSONを解析
      // *******************
      resData.condInfo = JSON.parse(resData.indCondInfo);
      resData.indScheduleUserInfo = JSON.parse(resData.indScheduleUserInfo);
      // 体重実績
      resData.rstWeightInfo = JSON.parse(resData.rstWeightInfo);

      // 除水補正情報
      resData.offWaterInfo = JSON.parse(resData.indOffWaterInfo);
      resData.oldOffWaterInfo = JSON.parse(resData.indOffWaterInfo);
      // 風袋情報
      resData.tareInfo = JSON.parse(resData.indTareInfo);
      resData.oldTareInfo = JSON.parse(resData.indTareInfo);

      // 後体重画面の場合
      if (state.scaleClass == weightScaleClass.after) {
        // 治療条件実績
        resData.condInfo = JSON.parse(resData.rstCondInfo);
        // 除水補正情報
        resData.offWaterInfo = JSON.parse(resData.rstOffWaterInfo);
        resData.oldOffWaterInfo = JSON.parse(resData.rstOffWaterInfo);
        // 風袋情報
        const data = JSON.parse(resData.rstTareInfo);
        resData.tareInfo = data.after;
        resData.oldTareInfo = data.after;
      }

      resData.offWaterWeight = tareOrOffWaterWeightTotal(resData.offWaterInfo);
      resData.tareWeight = tareOrOffWaterWeightTotal(resData.tareInfo);

      // 画面に表示する治療名称やクールベッドを取得してセットする
      commit("setViewPatIndRstData2", { viewPatIndRstData: resData });
      // 装置状態の記録
      commit("setMachineState", { index: 1, machineState });
      // 装置状態系エラーメッセージの表示
      dispatch("setMachineStateMessage", 1);
    },

    /**
     * 指定患者の指示・実績取得(スケジュールなし)
     * @param {Object} context
     * @param {Object} param
     * @param {Number} param.patId 患者ID番号
     * @param {String} param.facilityCd 施設コード
     */
    async fetchNoSchedulePatData({ state, commit, dispatch }, param) {
      const patId = param.patId;

      // 指定患者の指示・実績取得
      const response = await sendRequestGetNoOrderMain(patId);

      // 施設名称取得
      const facilityName = response.data.facilityName;

      // 取得した指示・実績取得をセット
      const resData = response.data.ord;
      // 患者割当車いす(個人所有・共用所有)
      const wheelChairMode = response.data.wheelChairMode;
      const patChair = response.data.wheelChair;
      // 次回透析予定
      const nextOrd = response.data.nextOrd;
      // 患者身体情報
      const physicalInfo = response.data.physicalInfo;

      const machineState = response.data.machineState;

      // メッセージ系をリセット
      commit("message/resetParams");
      // 施設名称
      commit("message/setFacilityName", facilityName);
      // 装置設定
      const deviceInfo = response.data.patDeviceSet;
      commit("setDeviceInfo", { info: deviceInfo, index: 0 });

      // *******************
      // 治療状況に応じた画面表示
      // *******************
      // 前体重
      commit("setScaleClass", { scaleClass: weightScaleClass.noSchedule });

      // *******************
      // 測定履歴の取得
      // *******************
      const lastWeightResponse = await sendRequestLastScaleNoSchedule({
        patId,
      });

      const weightScale = lastWeightResponse.data;

      // *******************
      // 指示・実績JSONを解析
      // *******************

      // 除水補正情報
      resData.offWaterInfo = JSON.parse(resData.indOffWaterInfo);
      resData.oldOffWaterInfo = JSON.parse(resData.indOffWaterInfo);
      // 風袋情報
      resData.tareInfo = JSON.parse(resData.indTareInfo);
      resData.oldTareInfo = JSON.parse(resData.indTareInfo);

      resData.offWaterWeight = tareOrOffWaterWeightTotal(resData.offWaterInfo);
      resData.tareWeight = tareOrOffWaterWeightTotal(resData.tareInfo);

      commit("setViewPatIndRstData", { viewPatIndRstData: resData });

      // *******************
      // 表示情報をセット
      // *******************

      // 風袋
      commit("setTareInfo", { tareInfo: resData.tareInfo });
      commit("setOldTareInfo", { oldTareInfo: resData.tareInfo });
      commit("setTareWeight", { tareWeight: resData.tareWeight });
      commit("message/setParamTare", resData.tareWeight);

      // 除水補正
      commit("setOffWaterInfo", { offWaterInfo: resData.offWaterInfo });
      commit("setOldOffWaterInfo", { oldOffWaterInfo: resData.offWaterInfo });
      commit("setOffWaterWeight", { offWaterWeight: resData.offWaterWeight });
      commit("message/setParamOffWater", resData.offWaterWeight);

      // 目標体重[透析条件:3] fnw:6文字以内[整数3桁小数2桁（000.00～300.00）]
      commit("setIndTargetWeight", { indTargetWeight: null });
      commit("message/setParamTargetWeight", null);
      // 除水量制限[透析条件:4] fnw:4文字以内[整数1桁小数2桁（0.00～9.99）]
      commit("setIndWaterRemovalLimit", { indWaterRemovalLimit: null });
      commit("message/setParamLimitOffWater", null);
      // I-HDF引き残し量
      commit("message/setParamBullLeaveAmount", null);

      dispatch("loadPhysicalInfo", {
        physicalInfoList: physicalInfo,
        treatDate: moment().format("YYYYMMDD"),
      });

      // *******************
      // 中断情報や実績から情報を復元する
      // *******************

      // 前回測定値をリセット
      commit("setLastScaleValue", null);
      commit("setLastWheelChairCd", null);
      commit("setLastWheelChairValue", null);

      // 前回の測定モードをリセット
      commit("setLastScaleMode", null);

      commit("setViewWheelchair", { isWheelchair: false });
      commit("setSelectWheelChairUnknown");
      commit("setScaleMode", {
        scaleMode: weightScaleMode.weight,
      });
      commit("setIsHasOrdWeightScale", false);

      // 患者車いすの有無をリセット
      commit("setIsUsePatWheelChair", false);

      if (weightScale.weightScaleNo !== null && weightScale.patId === patId) {
        // 前回測定あり
        commit("setIsHasOrdWeightScale", true);
        if (weightScale.scaleMode === weightScaleMode.weight) {
          // 前回測定が体重モードなら体重モードで起動

          // 測定値を取得
          commit("setMeasuredValue", { measuredValue: weightScale.scaleValue });
          commit("message/setParamMeasureValue", weightScale.scaleValue);

          // 測定値を前回測定値としてセット
          commit("setLastScaleValue", weightScale.scaleValue);

          // 前回の測定モードをセット
          commit("setLastScaleMode", weightScale.scaleMode);

          // 体重値その他算出
          dispatch("calcWeightValue");
        } else {
          // 前回測定が体重＋車いすモード: 体重＋車いすモードで起動 ※スケジュールなしは体重or体重＋車いすの2択

          // 車いす情報取得
          commit("setSelectWheelChair", {
            selectWheelchair: {
              code: weightScale.wheelChairCd,
              name: weightScale.wheelChairName,
              gramWeight: weightScale.wheelChairWeight,
              weight: tareG2Kg(weightScale.wheelChairWeight),
              calibrationCheck: true,
            },
          });

          // 測定値を取得
          commit("setMeasuredValue", { measuredValue: weightScale.scaleValue });
          commit("message/setParamMeasureValue", weightScale.scaleValue);

          commit("setViewWheelchair", { isWheelchair: true });
          // 体重車いす測定モードを開始
          commit("setScaleMode", {
            scaleMode: weightScaleMode.weightAndChair,
          });

          // 前回測定情報をセット
          commit("setLastScaleValue", weightScale.scaleValue);
          commit("setLastWheelChairCd", weightScale.wheelChairCd);
          commit("setLastWheelChairValue", weightScale.wheelChairWeight);
          commit("setLastScaleMode", weightScale.scaleMode);

          // 体重値その他算出
          dispatch("calcWeightValue");
        }
      } else {
        // 普通に体重測定（1回目）
        if (patChair.length > 0 || wheelChairMode.isWheelChair === "1") {
          // 患者に車いす(個人所有・共用所有)がある
          if (patChair.length > 0) {
            const chair = patChair[0];
            commit("setSelectWheelChair", {
              selectWheelchair: {
                code: chair.wheelChairCd,
                name: chair.wheelChairName,
                gramWeight: chair.wheelChairWeight,
                weight: tareG2Kg(chair.wheelChairWeight),
                calibrationCheck: true,
              },
            });
            commit("setViewWheelchair", { isWheelchair: true });
            commit("setScaleMode", {
              scaleMode: weightScaleMode.weightAndChair,
            });

            let scaleMode;
            if (state.scaleClass === weightScaleClass.after) {
              // 後体重測定
              scaleMode = wheelChairMode.chairMeasureModeAfter;
            } else {
              // 前体重測定
              scaleMode = wheelChairMode.chairMeasureModeBefore;
            }
            if (scaleMode === "1") {
              // 体重＋車いす→車いすのときは前回測定値に個人車いすを登録
              commit("setLastWheelChairCd", chair.wheelChairCd);
              commit("setLastWheelChairValue", chair.wheelChairWeight);
              commit("setLastScaleMode", weightScaleMode.weightAndChair);
              commit("setIsUsePatWheelChair", true);
            }
          } else {
            // 未登録車いす
            commit("setSelectWheelChairUnknown");
            commit("setViewWheelchair", { isWheelchair: true });
            // Note: スケジュールなし患者は常に前体重測定であり、車いすを先に測定することはできない
            // 体重＋車いすを先に測定
            commit("setScaleMode", {
              scaleMode: weightScaleMode.weightAndChair,
            });
          }
        }
        // 体重値その他算出
        dispatch("calcWeightValue");
      }

      // ***********************************
      // * 次回透析予定
      // ***********************************
      if (nextOrd !== null) {
        const nextDate = nextOrd.treatDate;
        const year = nextDate.substring(0, 4);
        const month = nextDate.substring(4, 6);
        const day = nextDate.substring(6);
        commit("message/setParamNextDateMMDD", `${month}/${day}`);
        commit("message/setParamNextDateYYYYMMDD", `${year}/${month}/${day}`);
      }
      // 装置状態の記録
      commit("setMachineState", { index: 0, machineState });
      // add FNSI-msgの修正 徐 start
      // ordNo2初期化
      // dispatch("fetchIndRstDataSecondOrd", { ordNo: null });
      await dispatch("fetchIndRstDataSecondOrd", { ordNo: null });
      // add FNSI-msgの修正 徐 end

      // 校正切れチェック
      await dispatch("checkCalibration", { facilityCd: param.facilityCd });
    },

    /**
     * 重量測定モード
     * @param {Object} context
     */
    // 10833 2024.09.13 add 測定値をチェック/印刷用パラメータに登録するためにstateを引数に追加 start
    //async startWeightScaleMode({ commit, dispatch }) {
    async startWeightScaleMode({ state, commit, dispatch }) {
      // 10833 2024.09.13 add 測定値をチェック/印刷用パラメータに登録するためにstateを引数に追加 end
      // 重量測定モードの初期情報取得
      const response = await sendRequestGetNoPatOrder();

      // 施設名称取得
      const facilityName = response.data.facilityName;

      // メッセージ系をリセット
      commit("message/resetParams");
      // 施設名称
      commit("message/setFacilityName", facilityName);

      // *******************
      // 治療状況に応じた画面表示
      // *******************
      // 重量測定
      commit("setScaleClass", { scaleClass: weightScaleClass.scale });

      commit("setViewPatIndRstData", { viewPatIndRstData: {} });

      // *******************
      // 表示情報をセット
      // *******************

      // 風袋
      commit("setTareInfo", { tareInfo: deepCopy(defaultTareAndOffWater) });
      commit("setOldTareInfo", {
        oldTareInfo: deepCopy(defaultTareAndOffWater),
      });
      commit("setTareWeight", { tareWeight: null });
      commit("message/setParamTare", deepCopy(defaultTareAndOffWater));

      // 除水補正
      commit("setOffWaterInfo", {
        offWaterInfo: deepCopy(defaultTareAndOffWater),
      });
      commit("setOldOffWaterInfo", {
        oldOffWaterInfo: deepCopy(defaultTareAndOffWater),
      });
      commit("setOffWaterWeight", { offWaterWeight: null });
      commit("message/setParamOffWater", deepCopy(defaultTareAndOffWater));

      // 目標体重[透析条件:3] fnw:6文字以内[整数3桁小数2桁（000.00～300.00）]
      commit("setIndTargetWeight", { indTargetWeight: null });
      commit("message/setParamTargetWeight", null);
      // 除水量制限[透析条件:4] fnw:4文字以内[整数1桁小数2桁（0.00～9.99）]
      commit("setIndWaterRemovalLimit", { indWaterRemovalLimit: null });
      commit("message/setParamLimitOffWater", null);
      // DW[患者情報(身体情報)から]
      commit("setIndDryWeight", { indDryWeight: null });
      commit("message/setParamDw", null);
      // 身長[患者情報(身体情報)から]
      commit("message/setPatHeight", null);
      // 前体重許容上限
      commit("message/setPatPreScaleUpper", null);
      // 前体重許容下限
      commit("message/setPatPreScaleLower", null);
      // I-HDF引き残し量
      commit("message/setParamBullLeaveAmount", null);

      // *******************
      // 中断情報や実績から情報を復元する
      // *******************

      commit("setViewWheelchair", { isWheelchair: false });
      commit("setSelectWheelChairUnknown");
      commit("setScaleMode", {
        scaleMode: weightScaleMode.weight,
      });
      commit("setIsHasOrdWeightScale", false);

      // 10833 2024.09.13 add 測定値をチェック/印刷用パラメータに画面表示用測定値を登録 start
      // 測定値を取得
      commit("message/setParamMeasureValue", state.measuredValue);
      // 10833 2024.09.13 add 測定値をチェック/印刷用パラメータに画面表示用測定値を登録 end

      dispatch("calcWeightValue");

      // ***********************************
      // * 次回透析予定
      // ***********************************
      commit("message/setParamNextDateMMDD", "予定なし");
      commit("message/setParamNextDateYYYYMMDD", "予定なし");

      // 装置状態の記録
      commit("setMachineState", { index: 0, machineState: null });
      // 装置設定
      commit("setDeviceInfo", { info: null, index: 0 });
      // add FNSI-msgの修正 徐 start
      // ordNo2初期化
      // dispatch("fetchIndRstDataSecondOrd", { ordNo: null });
      await dispatch("fetchIndRstDataSecondOrd", { ordNo: null });
      // // add FNSI-msgの修正 徐 end
    },
    /**
     * 条件送信
     * @param {Object} context
     * @param {Object} params JSON
     * @param {Number} params.ordIndex 0:指示1, 1:指示2
     * @param {String} params.facilityCd 施設コード
     * @param {Number} params.userId 作業者コード
     * @param {Object} params.weightInfo 選択中体重計
     * @param {Number} params.category 0:条件送信 1:体重＋車いす一時保存 2:車いす一時保存
     * @param {String} params.isPrint 印刷有無 "0" / "1"
     * @param {Boolean} params.isScaleBed スケールベッドかどうか
     */
    async sendCondition({ state, commit, getters, dispatch }, params) {
      let ordNo = null;
      let kurInfo = { code: null, name: null };
      let bedInfo = { code: null, name: null };
      let treatInfo = { deviceMode: null, treatCd: null, treatName: null };
      if (params.ordIndex === 0) {
        ordNo = state.ordNo;
        kurInfo = getters.getKurInfo[0];
        bedInfo = getters.getBedInfo[0];
        treatInfo = getters.getTreatmentMode[0];
      } else if (params.ordIndex === 1) {
        ordNo = state.ordNo2;
        kurInfo = getters.getKurInfo[1];
        bedInfo = getters.getBedInfo[1];
        treatInfo = getters.getTreatmentMode[1];
      }

      // 印刷用ベッド名称
      commit("message/setBedName", bedInfo.name);

      let printJson = {};
      if (params.isPrint === "1") {
        printJson = await dispatch("message/buildPrintData", {
          category: getters.getScaleClass,
          patId: state.patId,
          baseDate: moment().format("YYYYMMDD"),
        });
      }

      const payloadJson = {
        ordNo,
        kurCd: kurInfo.code,
        kurName: kurInfo.name,
        bedCd: bedInfo.code,
        bedName: bedInfo.name,
        patId: state.patId,
        facilityCd: params.facilityCd, //施設コード
        weightName:
          params.weightInfo.weightCd !== null
            ? params.weightInfo.weightName
            : null, // 体重計名
        tare: JSON.stringify(state.tareInfo), // 風袋
        offWater: JSON.stringify(state.offWaterInfo), // 除水補正
        scaleValue: state.measuredValue, // 測定値
        weightValue: state.bodyWeightValue, // 体重値
        targetOffWater: state.waterRemovalTarget, // 目標除水量
        targetWeight: state.indTargetWeight, // 目標体重
        userId: params.userId, // スタッフID
        weightCd: params.weightInfo.weightCd, // 体重計コード
        scaleClass: state.scaleClass, // 体重測定区分
        scaleMode: state.scaleMode, //体重測定モード
        measureDate: dateFormat.utc2Jst(new Date()), // 測定日時
        limitOffWater: state.indWaterRemovalLimit, // 除水制限
        wheelChairCd: state.isWheelchair ? state.selectWheelchair.code : null, // 車いすコード
        wheelChairName: state.isWheelchair ? state.selectWheelchair.name : null, // 車いす名称
        wheelChairWeight: state.isWheelchair
          ? state.selectWheelchair.gramWeight
          : null, // 車いす重量
        weightScaleNo: state.baseOrdWeightNo,
        treatmentCd: treatInfo.treatCd,
        treatmentName: treatInfo.treatName,
        deviceMode: treatInfo.deviceMode,
        isPrint: params.isPrint,
        printContent: JSON.stringify(printJson),
        dw: state.patStatus.indDryWeight,
        // add FNSI-分類不一致判断の追加 徐 start
        chkIndCondInfoFlg: state.chkIndCondInfoFlg,
        mstDelFlg: state.mstDelFlg,
        mstOverdueFlg: state.mstOverdueFlg,
        // add FNSI-分類不一致判断の追加 徐 end
        // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 start
        scaleBedBedCd: params.isScaleBed ? bedInfo.code : null,
        // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 end
      };

      if (params.category === weightScaleMode.weight) {
        // 条件送信
        return sendRequestPostSendCondition(payloadJson, {
          headers: {
            "Content-Type": "application/json",
          },
          responseType: "json",
        });
      } else if (params.category === weightScaleMode.weightAndChair) {
        // 体重＋車いす一時保存
        return sendRequestPostSaveWeightAndChair(payloadJson, {
          headers: {
            "Content-Type": "application/json",
          },
          responseType: "json",
        });
      } else if (params.category === weightScaleMode.wheelChair) {
        // 車いす一時保存
        return sendRequestPostSaveWheelChair(payloadJson, {
          headers: {
            "Content-Type": "application/json",
          },
          responseType: "json",
        });
      } else if (params.category === -1) {
        // 実績保存（ord_noあれば）と履歴のみ
        return sendRequestPostNoSendCondition(payloadJson, {
          headers: {
            "Content-Type": "application/json",
          },
          responseType: "json",
        });
      }
    },
    /**
     * 重量測定
     * @param {Object} context
     * @param {Object} params JSON
     * @param {String} params.facilityCd 施設コード
     * @param {Number} params.userId 作業者コード
     * @param {Object} params.weightInfo 選択中体重計
     * @param {Number} params.category 0:条件送信 1:体重＋車いす一時保存 2:車いす一時保存
     * @param {String} params.isPrint 印刷有無 "0" / "1"
     */
    async saveWeightScale({ state, commit, getters, dispatch }, params) {
      // 印刷用ベッド名称
      commit("message/setBedName", "");

      let printJson = {};
      if (params.isPrint === "1") {
        printJson = await dispatch("message/buildPrintData", {
          category: getters.getScaleClass,
          patId: null,
          baseDate: moment().format("YYYYMMDD"),
        });
      }

      const payloadJson = {
        ordNo: null,
        kurCd: null,
        kurName: null,
        bedCd: null,
        bedName: null,
        patId: null,
        facilityCd: params.facilityCd, //施設コード
        weightName:
          params.weightInfo.weightCd !== null
            ? params.weightInfo.weightName
            : null, // 体重計名
        tare: JSON.stringify(state.tareInfo), // 風袋
        offWater: JSON.stringify(state.offWaterInfo), // 除水補正
        scaleValue: state.measuredValue, // 測定値
        weightValue: null, // 体重値
        targetOffWater: null, // 目標除水量
        targetWeight: null, // 目標体重
        userId: params.userId, // スタッフID
        weightCd: params.weightInfo.weightCd, // 体重計コード
        scaleClass: state.scaleClass, // 体重測定区分
        scaleMode: state.scaleMode, //体重測定モード
        measureDate: dateFormat.utc2Jst(new Date()), // 測定日時
        limitOffWater: null, // 除水制限
        wheelChairCd: state.isWheelchair ? state.selectWheelchair.code : null, // 車いすコード
        wheelChairName: state.isWheelchair ? state.selectWheelchair.name : null, // 車いす名称
        wheelChairWeight: state.isWheelchair
          ? state.selectWheelchair.gramWeight
          : null, // 車いす重量
        weightScaleNo: state.baseOrdWeightNo,
        treatmentCd: null,
        treatmentName: null,
        deviceMode: null,
        isPrint: params.isPrint,
        printContent: JSON.stringify(printJson),
        dw: state.patStatus.indDryWeight,
        // add FNSI-分類不一致判断の追加 徐 start
        chkIndCondInfoFlg: state.chkIndCondInfoFlg,
        mstDelFlg: state.mstDelFlg,
        mstOverdueFlg: state.mstOverdueFlg,
        // add FNSI-分類不一致判断の追加 徐 end
      };
      // 重量保存
      return sendRequestPostSendCondition(payloadJson, {
        headers: {
          "Content-Type": "application/json",
        },
        responseType: "json",
      });
    },
    /**
     * 測定記録保存
     * @param {Object} context
     * @param {Object} params JSON
     * @param {String} params.facilityCd 施設コード
     * @param {Number} params.userId 作業者コード
     * @param {Object} params.weightInfo 選択中体重計
     * @param {Number} params.category 0:条件送信 1:体重＋車いす一時保存 2:車いす一時保存
     */
    saveMeasure({ state, commit, getters }, params) {
      const ordNo = state.ordNo;
      const kurInfo = getters.getKurInfo[0];
      const bedInfo = getters.getBedInfo[0];
      const treatInfo = getters.getTreatmentMode[0];

      // 印刷用ベッド名称
      commit("message/setBedName", bedInfo.name);

      const payloadJson = {
        ordNo,
        kurCd: kurInfo.code,
        kurName: kurInfo.name,
        bedCd: bedInfo.code,
        bedName: bedInfo.name,
        treatmentCd: treatInfo.treatCd,
        treatmentName: treatInfo.treatName,
        patId: state.patId,
        facilityCd: params.facilityCd, //施設コード
        weightName:
          params.weightInfo.weightCd !== null
            ? params.weightInfo.weightName
            : null, // 体重計名
        tare: JSON.stringify(state.tareInfo), // 風袋
        offWater: JSON.stringify(state.offWaterInfo), // 除水補正
        scaleValue:
          params.category === weightScaleMode.wheelChair
            ? state.selectWheelchair.weight
            : state.measuredValue, // 測定値
        weightValue: null, // 体重値
        targetOffWater: null, // 目標除水量
        targetWeight: null, // 目標体重
        userId: params.userId, // スタッフID
        weightCd: params.weightInfo.weightCd, // 体重計コード
        scaleClass: weightScaleClass.scale, // 体重測定区分:重量測定
        scaleMode: state.scaleMode, //体重測定モード
        measureDate: dateFormat.utc2Jst(new Date()), // 測定日時
        limitOffWater: null, // 除水制限
        wheelChairCd: state.isWheelchair ? state.selectWheelchair.code : null, // 車いすコード
        wheelChairName: state.isWheelchair ? state.selectWheelchair.name : null, // 車いす名称
        wheelChairWeight: state.isWheelchair
          ? state.selectWheelchair.gramWeight
          : null, // 車いす重量
        dw: state.patStatus.indDryWeight,
      };
      // 測定値保存
      return sendRequestPostSaveMeasure(payloadJson, {
        headers: {
          "Content-Type": "application/json",
        },
        responseType: "json",
      });
    },

    /**
     * 後体重送信
     * @param {Object} context
     * @param {Object} params JSON
     * @param {String} params.facilityCd 施設コード
     * @param {Number} params.userId 作業者コード
     * @param {Object} params.weightInfo 選択中体重計
     * @param {String} params.isPrint 印刷有無 "0" / "1"
     * @param {Number} params.ordIndex オーダ番号インデックス
     * @param {Number} params.category weightScaleMode
     * @param {Boolean} params.isScaleBed スケールベッドかどうか
     */
    async sendAfterWeight({ state, commit, getters, dispatch }, params) {
      let ordNo = null;
      let kurInfo = { code: null, name: null };
      let bedInfo = { code: null, name: null };
      let treatInfo = { deviceMode: null, treatCd: null, treatName: null };
      if (params.ordIndex === 0) {
        ordNo = state.ordNo;
        kurInfo = getters.getKurInfo[0];
        bedInfo = getters.getBedInfo[0];
        treatInfo = getters.getTreatmentMode[0];
      } else if (params.ordIndex === 1) {
        ordNo = state.ordNo2;
        kurInfo = getters.getKurInfo[1];
        bedInfo = getters.getBedInfo[1];
        treatInfo = getters.getTreatmentMode[1];
      }

      // 印刷用ベッド名称
      commit("message/setBedName", bedInfo.name);

      let printJson = {};
      if (params.isPrint === "1") {
        printJson = await dispatch("message/buildPrintData", {
          category: getters.getScaleClass,
          patId: state.patId,
          baseDate: moment().format("YYYYMMDD"),
        });
      }

      const payloadJson = {
        ordNo,
        kurCd: kurInfo.code,
        kurName: kurInfo.name,
        bedCd: bedInfo.code,
        bedName: bedInfo.name,
        patId: state.patId,
        facilityCd: params.facilityCd, //施設コード
        weightName:
          params.weightInfo.weightCd !== null
            ? params.weightInfo.weightName
            : null, // 体重計名称
        tareFlg: state.tareChangeFlg == true ? 1 : 0, // 風袋登録フラグ
        tare: JSON.stringify(state.tareInfo), // 風袋
        offWaterFlg: state.offWaterChangeFlg == true ? state.offWaterRegFlg : 0, // 除水補正フラグ
        offWater: JSON.stringify(state.offWaterInfo), // 除水補正
        scaleValue: state.measuredValue, // 測定値
        weightValue: state.bodyWeightValue, // 体重値
        targetOffWater: state.waterRemovalTarget, // 目標除水量
        targetWeight: state.indTargetWeight, // 目標体重
        userId: params.userId, // スタッフID
        weightCd: params.weightInfo.weightCd, // 体重計コード
        scaleClass: state.scaleClass, // 体重測定区分
        scaleMode: state.scaleMode, //体重測定モード
        measureDate: dateFormat.utc2Jst(new Date()), // 測定日時
        limitOffWater: state.indWaterRemovalLimit, // 除水制限
        wheelChairCd: state.isWheelchair ? state.selectWheelchair.code : null, // 車いすコード
        wheelChairName: state.isWheelchair ? state.selectWheelchair.name : null, // 車いす名称
        wheelChairWeight: state.isWheelchair
          ? state.selectWheelchair.gramWeight
          : null, // 車いす重量
        weightScaleNo: state.baseOrdWeightNo,
        treatmentCd: treatInfo.treatCd,
        treatmentName: treatInfo.treatName,
        deviceMode: treatInfo.deviceMode,
        isPrint: params.isPrint,
        printContent: JSON.stringify(printJson),
        dw: state.patStatus.indDryWeight,
        // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 start
        scaleBedBedCd: params.isScaleBed ? bedInfo.code : null,
        // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 end
      };

      if (params.category === weightScaleMode.weight) {
        // 後体重登録
        return sendRequestPostSendAfterWeight(payloadJson, {
          headers: {
            "Content-Type": "application/json",
          },
          responseType: "json",
        });
      } else if (params.category === weightScaleMode.weightAndChair) {
        // 体重＋車いす一時保存
        return sendRequestPostSaveWeightAndChair(payloadJson, {
          headers: {
            "Content-Type": "application/json",
          },
          responseType: "json",
        });
      } else if (params.category === weightScaleMode.wheelChair) {
        // 車いす一時保存
        return sendRequestPostSaveWheelChair(payloadJson, {
          headers: {
            "Content-Type": "application/json",
          },
          responseType: "json",
        });
      }
    },
    /**
     * 条件送信時に指示データが別の箇所で変更されているかどうかをチェックする
     * @param {any} context
     * @param {Number} ordIndex オーダ番号インデックス
     */
    async preSaveCheckDBChanged(
      { state, commit, getters, dispatch },
      ordIndex
    ) {
      if (state.patId === null) {
        // 患者未確定
        return true;
      }
      let ordNo = null;
      let kurInfo = { code: null, name: null };
      let bedInfo = { code: null, name: null };
      let treatInfo = { deviceMode: null, treatCd: null, treatName: null };
      let baseIndRstData = {};
      if (ordIndex === 0) {
        ordNo = state.ordNo;
        kurInfo = getters.getKurInfo[0];
        bedInfo = getters.getBedInfo[0];
        treatInfo = getters.getTreatmentMode[0];
        baseIndRstData = state.viewPatIndRstData;
      } else if (ordIndex === 1) {
        ordNo = state.ordNo2;
        kurInfo = getters.getKurInfo[1];
        bedInfo = getters.getBedInfo[1];
        treatInfo = getters.getTreatmentMode[1];
        baseIndRstData = state.viewPatIndRstData2;

        if (ordNo === null) {
          return true;
        }
      }

      // 指定オーダ番号の指示・実績取得
      let response = null;
      if (ordNo === null) {
        response = await sendRequestGetNoOrderMain(state.patId);
      } else {
        response = await sendRequestGetOrderMain(ordNo);
      }
      // 取得した指示・実績取得をセット
      const resData = response.data.ord;

      // 次回透析予定
      const nextOrd = response.data.nextOrd;
      // 患者身体情報
      const physicalInfo = response.data.physicalInfo;

      if (ordNo !== null) {
        // 患者ＩＤ
        if (state.patId !== resData.patId) {
          return false;
        }
      }

      // *******************
      // 治療状況
      // *******************
      if (baseIndRstData.rstDialysisState !== resData.rstDialysisState) {
        return false;
      }

      // *******************
      // 指示・実績JSONを解析
      // *******************
      resData.condInfo = JSON.parse(resData.indCondInfo);
      resData.indScheduleUserInfo = JSON.parse(resData.indScheduleUserInfo);
      // 体重実績
      resData.rstWeightInfo = JSON.parse(resData.rstWeightInfo);

      // 後体重画面の場合
      if (state.scaleClass == weightScaleClass.after) {
        // 治療条件実績
        resData.condInfo = JSON.parse(resData.rstCondInfo);
        if (
          resData.rstKurCd !== kurInfo.code ||
          resData.rstBedCd !== bedInfo.code ||
          resData.rstDeviceMode !== treatInfo.deviceMode ||
          resData.rstTreatmentCd !== treatInfo.treatCd
        ) {
          return false;
        }

        // 除水補正情報
        resData.offWaterInfo = JSON.parse(resData.rstOffWaterInfo);
        resData.oldOffWaterInfo = JSON.parse(resData.rstOffWaterInfo);

        if (
          isChangeTareOrOffWaterJson(
            baseIndRstData.offWaterInfo,
            resData.offWaterInfo
          )
        ) {
          return false;
        }
        // 風袋情報
        const data = JSON.parse(resData.rstTareInfo);
        resData.tareInfo = data.after;
        resData.oldTareInfo = data.after;

        if (
          isChangeTareOrOffWaterJson(baseIndRstData.tareInfo, resData.tareInfo)
        ) {
          return false;
        }
      } else {
        // 前体重
        if (
          resData.indKurCd !== kurInfo.code ||
          resData.indBedCd !== bedInfo.code ||
          resData.indDeviceMode !== treatInfo.deviceMode ||
          resData.indTreatmentCd !== treatInfo.treatCd
        ) {
          return false;
        }
        // 除水補正情報
        resData.offWaterInfo = JSON.parse(resData.indOffWaterInfo);
        resData.oldOffWaterInfo = JSON.parse(resData.indOffWaterInfo);
        // 風袋情報
        resData.tareInfo = JSON.parse(resData.indTareInfo);
        resData.oldTareInfo = JSON.parse(resData.indTareInfo);
        // add FNSI-msgの修正 徐 start
        // if (
        //   // isChangeTareOrOffWaterJson(state.offWaterInfo, resData.offWaterInfo)
        // ) {
        //   return false;
        // }
        // if (isChangeTareOrOffWaterJson(state.tareInfo, resData.tareInfo)) {
        //   return false;
        // }
        if (ordIndex === 0) {
          if (
            isChangeTareOrOffWaterJson(state.offWaterInfo, resData.offWaterInfo)
          ) {
            return false;
          }
          if (isChangeTareOrOffWaterJson(state.tareInfo, resData.tareInfo)) {
            return false;
          }
        } else {
          if (
            isChangeTareOrOffWaterJson(
              state.viewPatIndRstData2.offWaterInfo,
              resData.offWaterInfo
            )
          ) {
            return false;
          }
          if (
            isChangeTareOrOffWaterJson(
              state.viewPatIndRstData2.tareInfo,
              resData.tareInfo
            )
          ) {
            return false;
          }
        }
        // add FNSI-msgの修正 徐 end
      }

      if (baseIndRstData.condInfo && resData.condInfo) {
        // 透析時間[透析条件:1] 分
        if (
          baseIndRstData.condInfo["1"].value != resData.condInfo["1"].value // mod #9973 value Number→文字列  shiyw
        ) {
          return false;
        }

        // 目標体重[透析条件:3] fnw:6文字以内[整数3桁小数2桁（000.00～300.00）]
        if (
          _.has(baseIndRstData.condInfo, "3") &&
          baseIndRstData.condInfo["3"].value != resData.condInfo["3"].value // mod #9973 value Number→文字列  shiyw
        ) {
          return false;
        }
        // 除水量制限[透析条件:4] fnw:4文字以内[整数1桁小数2桁（0.00～9.99）]
        if (
          _.has(baseIndRstData.condInfo, "4") &&
          baseIndRstData.condInfo["4"].value != resData.condInfo["4"].value // mod #9973 value Number→文字列  shiyw
        ) {
          return false;
        }
        // I-HDF引き残し量
        if (baseIndRstData.pullLeaveAmount !== resData.pullLeaveAmount) {
          return false;
        }
      }

      /* modify by chamaojia 2024-12-20 [11387] 【たくしん会】前/後体重測定時に重量測定モードとなる　V1.0B --start */
      /**
       * modify content:
       *    comparison of conditions for adding 【indDw】 and 【rstDw】
       *    priority: rstDW > indDW > physical.dw
       *    （【state.patStatus.indDryWeight】the conditions for assignment, in reverse order）
       */
      // compare DW
      const indDW = resData.indDw;
      const rstDW = resData.rstDw;
      const indDryWeight = state.patStatus.indDryWeight;
      if (
          (state.scaleClass === weightScaleClass.after
              || state.scaleClass === weightScaleClass.dialysis
          )
          && rstDW !== null && rstDW >= 0
      ) {
        if (BigNumber(indDryWeight).isNaN()
            || BigNumber(rstDW).toFixed(2) !==
            BigNumber(indDryWeight).toFixed(2)) {
          return false;
        }
      } else if (indDW !== null && indDW >= 0) {
        if (BigNumber(indDryWeight).isNaN()
            || BigNumber(indDW).toFixed(2) !==
            BigNumber(indDryWeight).toFixed(2)) {
          return false;
        }
      } else {
        // 登録日が新しいもの順にソートする
        const tDate = moment(resData.treatDate, "YYYYMMDD").add(1, "day");
        const physicalInfoList = physicalInfo
            .filter((elm) => moment(elm.exam_date) < tDate)
            .sort(
                // @ts-ignore
                (a, b) => moment(b.exam_date) - moment(a.exam_date)
            );

        for (const physical of physicalInfoList) {
          // DW[患者情報(身体情報)から]
          if (
              physical !== null &&
              physical.dw !== undefined &&
              physical.dw !== null
          ) {
            if (
                BigNumber(physical.dw).isNaN() ||
                BigNumber(indDryWeight).isNaN() ||
                BigNumber(physical.dw).toFixed(2) !==
                BigNumber(indDryWeight).toFixed(2)
            ) {
              return false;
            }
            break;
          }
        }
      }
      /* modify by chamaojia 2024-12-20 [11387] 【たくしん会】前/後体重測定時に重量測定モードとなる　V1.0B --end */

      // *******************
      // 体重実績比較
      // *******************

      // 前体重[実績から]
      if (baseIndRstData.rstWeightInfo && resData.rstWeightInfo) {
        if (
          baseIndRstData.rstWeightInfo.weight_before !==
            resData.rstWeightInfo.weight_before ||
          baseIndRstData.rstWeightInfo.weight_after !==
            resData.rstWeightInfo.weight_after ||
          baseIndRstData.rstWeightInfo.add_total !==
            resData.rstWeightInfo.add_total ||
          baseIndRstData.rstWeightInfo.add_water_total !==
            resData.rstWeightInfo.add_water_total ||
          baseIndRstData.rstWeightInfo.water_removal_rst !==
            resData.rstWeightInfo.water_removal_rst ||
          baseIndRstData.rstWeightInfo.weight_before_date !==
            resData.rstWeightInfo.weight_before_date ||
          baseIndRstData.rstWeightInfo.weight_after_date !==
            resData.rstWeightInfo.weight_after_date ||
          baseIndRstData.rstWeightInfo.water_removal_target !==
            resData.rstWeightInfo.water_removal_target ||
          baseIndRstData.rstWeightInfo.weight_measure_after !==
            resData.rstWeightInfo.weight_measure_after ||
          baseIndRstData.rstWeightInfo.weight_measure_before !==
            resData.rstWeightInfo.weight_measure_before
        ) {
          return false;
        }
      }

      // ***********************************
      // * 次回透析予定
      // ***********************************
      if (ordIndex === 0 && nextOrd !== null) {
        const nextDate = nextOrd.treatDate;
        const year = nextDate.substring(0, 4);
        const month = nextDate.substring(4, 6);
        const day = nextDate.substring(6);
        commit("message/setParamNextDateMMDD", `${month}/${day}`);
        commit("message/setParamNextDateYYYYMMDD", `${year}/${month}/${day}`);
        const nextStartTime = nextOrd.indTreatStartTime;
        if (nextStartTime) {
          const h = nextStartTime.substring(0, 2);
          const m = nextStartTime.substring(2, 4);
          commit(
            "message/setNextSchedule",
            new Date(`${year}/${month}/${day} ${h}:${m}`)
          );
        } else {
          commit(
            "message/setNextSchedule",
            new Date(`${year}/${month}/${day}`)
          );
        }
      }
      if (ordIndex === 0) {
        // ordNo2読み込み
        return await dispatch("preSaveCheckDBChanged", 1);
      }

      return true;
    },
    /**
     * @param {any} context
     * @param {{ weightScaleNo: number; facilityCd: string; weightNo: number; }} params
     */
    sendPrintOrder(context, params) {
      if (params.weightScaleNo) {
        const printParam = {
          weightScaleNo: params.weightScaleNo,
          facilityCd: params.facilityCd,
          weightNo: params.weightNo,
        };
        return sendRequestPostPrintSheet(printParam);
      }
    },
    // add FNSI-田中衡機の追加 徐 star
    /**
     * @param {any} context
     * @param {{weightCd: number; facilityCd: string; weightNo: number; }} params
     */
    sendWeightAppOk(context, params) {
      if (params.weightNo) {
        const weightApp = {
          weightCd: params.weightCd,
          facilityCd: params.facilityCd,
          weightNo: params.weightNo,
        };
        return sendRequestWeightAppOk(weightApp);
      }
    },
    // add FNSI-田中衡機の追加 徐 end
    hideCheckMessage({ commit }) {
      commit("setViewMessage", { isMessage: false });
    },
    /**
     * 装置状態系メッセージのセット
     */
    setMachineStateMessage({ dispatch, state, getters }, index) {
      // del FNSI-後体重の場合、エラーメッセージを表示 徐 start
      // if (state.scaleClass === weightScaleClass.after) {
      //   // 後体重
      //   return;
      // }
      // del FNSI-後体重の場合、エラーメッセージを表示 徐 end
      // add #6650 2022-08-30 後体重測定時に治療を実施した装置が通信不良の場合、送信出来ませんのメッセージが表示される dou start
      if (state.scaleClass === weightScaleClass.after) {
        // 後体重
        return;
      }
      // add #6650 2022-08-30 後体重測定時に治療を実施した装置が通信不良の場合、送信出来ませんのメッセージが表示される dou end
      // if (state.machineState[index].isOfflineMachine === "1") {
      // add FNSI-通信種別がオフライン運用com_type = 0 徐 start
      if (state.machineState[index].comType == 0) {
        // add FNSI-通信種別がオフライン運用com_type = 0 徐 end
        // オフライン装置
        return;
      }
      if (
        getters.getTreatmentMode[index].deviceMode ===
        deviceModeConstant.PURIFICATION
      ) {
        // 特殊浄化
        return;
      }
      const resData =
        index === 0 ? state.viewPatIndRstData : state.viewPatIndRstData2;
      if (state.machineState[index]) {
        if (state.machineState[index].isConnectError === "1") {
          // 装置が通信不良
          dispatch("setErrorMessage", {
            message: `[${getters.getBedInfo[index].name}]の装置が通信不良なので送信できません`,
            isError: true,
            isWarn: false,
          });
          dispatch("showErrorMessage", { isList: false });
        } else if (state.machineState[index].isTreating === "1") {
          // 装置が治療中状態
          dispatch("setErrorMessage", {
            message: `[${getters.getBedInfo[index].name}]の装置が治療中状態なので送信できません`,
            isError: true,
            isWarn: false,
          });
          dispatch("showErrorMessage", { isList: false });
        } else if (
          state.machineState[index].isCommonComFormatProtocol !== "1" &&
          (state.machineState[index].isPatVerified === "1" ||
            resData.rstDialysisState === dialysisState.checkedSendCondition)
        ) {
          // 装置条件確認済み
          dispatch("setErrorMessage", {
            message: `透析装置にて条件送信確認済みです。不整合な状態を除き、透析装置で確認済みの場合は条件送信がされません。`,
            isError: false,
            isWarn: true,
          });
          if (!state.isMachineStateErrorMsg) {
            dispatch("showErrorMessage", { isList: true });
          }
        }
      }
    },
    /**
     * エラー設定用
     */
    setErrorMessage({ commit }, { message, isWarn, isError }) {
      commit("message/addLocalMessage", { message, isWarn, isError });
      commit("message/setIsLocalMessage", true);
    },
    /**
     * エラー表示用
     */
    showErrorMessage({ commit }, { isList }) {
      commit("setIsMachineStateErrorMsg", !isList);
      commit("message/setIsListMessage", isList);
    },

    /**
     * 風袋・除水補正編集モーダル用
     * @param {{state: any, commit: any}} context
     * @param {number} mode 1:風袋
     */
    setEditModalData({ state, commit }, mode) {
      // 編集対象データ[除水補正]
      let editData = state.offWaterInfo;

      // 編集対象データ[風袋]
      if (mode === 1) {
        editData = state.tareInfo;
      }
      commit("setEditModalDataMode", { editModalDataMode: mode });
      commit("setEditModalData", { editModalData: editData });
    },

    /**
     * 風袋・除水補正編集モーダル登録用
     */
    async setRegistEditModalData({ state, commit, dispatch, getters }, data) {
      // 合計値計算
      const totalWeight = tareOrOffWaterWeightTotal(data);
      // 編集登録データ[除水補正]
      if (state.editModalDataMode === 0) {
        commit("setOffWaterInfo", { offWaterInfo: data });
        commit("setOffWaterWeight", { offWaterWeight: totalWeight });
        commit("message/setParamOffWater", totalWeight);

        // 変更チェック
        const flg = isChangeTareOrOffWaterJson(
          state.oldOffWaterInfo,
          state.offWaterInfo
        );
        commit("setOffWaterChangeFlg", { offWaterChangeFlg: flg });
      }
      // 編集登録データ[風袋]
      else {
        commit("setTareInfo", { tareInfo: data });
        commit("setTareWeight", { tareWeight: totalWeight });
        commit("message/setParamTare", totalWeight);

        // 変更チェック
        const flg = isChangeTareOrOffWaterJson(
          state.oldTareInfo,
          state.tareInfo
        );
        commit("setTareChangeFlg", { tareChangeFlg: flg });
      }

      // 前体重測定の場合
      if (state.scaleClass === weightScaleClass.before) {
        // 除水補正
        if (state.editModalDataMode === 0) {
          // 登録情報作成
          const regData = {
            ordNo: getters.getSelectedOrdNo.ordNo,
            offWater: JSON.stringify(data),
          };
          // 指示風袋登録
          sendRequestPutIndWater(regData);

          if (getters.getSelectedOrdNo.ordNo2 !== null) {
            // 指示２も書き換える
            regData.ordNo = getters.getSelectedOrdNo.ordNo2;
            // 指示風袋登録
            sendRequestPutIndWater(regData);
          }
        }
        // 風袋
        else {
          // 登録情報作成
          const regData = {
            ordNo: getters.getSelectedOrdNo.ordNo,
            tare: JSON.stringify(data),
          };
          // 指示風袋登録
          sendRequestPutIndTare(regData);

          if (getters.getSelectedOrdNo.ordNo2 !== null) {
            // 指示２も書き換える
            regData.ordNo = getters.getSelectedOrdNo.ordNo2;
            // 指示風袋登録
            sendRequestPutIndTare(regData);
          }
        }
      }
      // 体重値再計算
      dispatch("calcWeightValue");
    },
    // 除水補正登録フラグセット
    setOffWaterRegFlg({ commit }, flg) {
      commit("setOffWaterRegFlg", { offWaterRegFlg: flg });
    },
    // add FutreNetWeb+SI課題管理No6705 趙 start
    setOffWaterChangeFlg({ commit }, flg) {
      commit("setOffWaterChangeFlg", { offWaterChangeFlg: flg });
    },
    // add FutreNetWeb+SI課題管理No6705 趙 end
    // 条件送信履歴から特定の行を取得
    fetchSendConditionResult(context, key) {
      return sendRequestGetSingleHistory(key);
    },

    /**
     * 条件送信成功時のキー蓄積
     */
    setSendConditionResponseCd({ commit }, key) {
      commit("setSendConditionResponseCd", key);
    },
    removeSendConditionResponseCd({ commit }, key) {
      commit("removeSendConditionResponseCd", key);
    },
    resetIsHasOrdWeightScale({ commit }) {
      commit("setIsHasOrdWeightScale", false);
    },
    setIsHasOrdWeightScale({ commit }, bool) {
      commit("setIsHasOrdWeightScale", bool);
    },
    /**
     * @param {{commit: Function}} context
     * @param {number} no
     */
    setBaseOrdWeightNo({ commit }, no) {
      commit("setBaseOrdWeightNo", no);
    },
    /**
     * 測定履歴一覧情報取得
     * facilityCd: 施設コード
     * patId: 患者ID
     */
    async fetchHistoryModalList({ state, commit }, info) {
      const params = info;
      // 測定履歴一覧情報取得
      const response = await sendRequestGetHistory(params);
      if (response.data[0] !== null) {
        // 取得データの変換
        const dataList = response.data.copyWithin(0, 0);
        const vesteddata = state.HistoryModalList.length;
        dataList.forEach((value, index, array) => {
          // no.
          array[index].ordNo = vesteddata > 0 ? vesteddata + index + 1 : index + 1;
          // 日付
          const str = array[index].treatDate;
          const arr = `${str.substr(0, 4)}/${str.substr(4, 2)}/${str.substr(
            6,
            2
          )}`.split("/");
          const dateFormatMoment = moment(
            new Date(Number(arr[0]), Number(arr[1]) - 1, Number(arr[2]))
          );
          array[index].treatDate = dateFormatMoment.format("YYYY/MM/DD");
          // 曜日情報
          if (array[index].treatWeek !== null) {
            const weeks = array[index].treatWeek;
            switch (weeks) {
              case 1:
                array[index].treatWeek = "月";
                break;
              case 2:
                array[index].treatWeek = "火";
                break;
              case 3:
                array[index].treatWeek = "水";
                break;
              case 4:
                array[index].treatWeek = "木";
                break;
              case 5:
                array[index].treatWeek = "金";
                break;
              case 6:
                array[index].treatWeek = "土";
                break;
              default:
                array[index].treatWeek = "日";
                break;
            }
          }
          // 目標体重
          if (array[index].rstCondInfo !== null) {
            const condInfo = JSON.parse(array[index].rstCondInfo);
            if (condInfo[3].value !== undefined) {
              array[index].targetWeight = condInfo[3].value;
            }
          }
          // 前体重-DW（DW差）
          // DW差/DW×100（DW増加率）
          if (
            array[index].weightBefore !== null &&
            array[index].rstDw !== null
          ) {
            const difDw = new BigNumber(array[index].weightBefore)
              .minus(array[index].rstDw)
              .toNumber();
            array[index].difDw = difDw;
            if (array[index].rstDw !== 0) {
              const rateDw = new BigNumber(difDw)
                .div(array[index].rstDw)
                .times(100)
                .toNumber();
              array[index].rateDw = isNaN(rateDw) ? "" : Math.floor(rateDw * 100) / 100;
            }
          }
        });
        // 取得した測定履歴一覧情報をセット
        if (dataList.length > 0) {
          const historylist = dataList;
          commit("setHistoryModalList", { HistoryModalList: historylist });
        }
      }
    },
    resetHistoryModalList({ commit }) {
      commit("resetHistoryModalList");
    },
    /**
     * 治療条件分類不一致判断
     * @param {Object} context
     * @param {Object} param
     * @param {Number} param.ordNo オーダ番号
     * @param {Number} param.ordNo2 オーダ番号2
     */
    // add FNSI-分類不一致判断の追加 徐 start
    chkIndCondInfoData(context, param) {
      let params = null;
      if (param.ordNo2 == null) {
        params = {
          ordNo: param.ordNo,
          ordNos: 0,
        };
      } else {
        params = {
          ordNo: param.ordNo,
          ordNos: param.ordNo2,
        };
      }
      return getChkIndCondInfoData(params);
    },
    setChkIndCondInfoFlg: ({ state }, param) => {
      state.chkIndCondInfoFlg = param;
    },
    setMstDelFlg: ({ state }, param) => {
      state.mstDelFlg = param;
    },
    setMstOverdueFlg: ({ state }, param) => {
      state.mstOverdueFlg = param;
    },
    // add FNSI-分類不一致判断の追加 徐 end

    /**
     * 前回測定の測定値をセット
     */
    setLastScaleValue({ commit }, lastScaleValue) {
      commit("setLastScaleValue", lastScaleValue);
    },

    /**
     * 前回測定の車いすコードをセット
     */
    setLastWheelChairCd({ commit }, lastWheelChairCd) {
      commit("setLastWheelChairCd", lastWheelChairCd);
    },

    /**
     * 前回測定の車いす重量をセット
     */
    setLastWheelChairValue({ commit }, lastWheelChairValue) {
      commit("setLastWheelChairValue", lastWheelChairValue);
    },

    /**
     * 前回の測定モードをセット
     */
    setLastScaleMode({ commit }, lastScaleMode) {
      commit("setLastScaleMode", lastScaleMode);
    },

    /**
     * 患者車いすの有無をセット
     */
    setIsUsePatWheelChair({ commit }, isUsePatWheelChair) {
      commit("setIsUsePatWheelChair", isUsePatWheelChair);
    },
  },
  mutations: {
    setIsInitialized: (state, boolean) => {
      state.isInitialized = boolean;
    },
    setSelectOrdNo: (state, param) => {
      state.ordNo = param.ordNo;
      state.ordNo2 = param.ordNo2;
    },
    setInputPatId: (state, payload) => {
      state.inputPatId = payload.inputPatId;
    },
    setPatId: (state, payload) => {
      state.patId = payload.patId;
    },
    setBaseOrdWeightNo: (state, no) => {
      state.baseOrdWeightNo = no;
    },
    setViewPatIndRstData: (state, payload) => {
      state.viewPatIndRstData = payload.viewPatIndRstData;
    },
    setViewPatIndRstData2: (state, payload) => {
      state.viewPatIndRstData2 = payload.viewPatIndRstData;
    },
    setScaleMode: (state, payload) => {
      state.scaleMode = payload.scaleMode;
    },
    setScaleClass: (state, payload) => {
      state.scaleClass = payload.scaleClass;
    },
    setSimpleMode: (state, payload) => {
      state.isSimpleMode = payload.isSimpleMode;
    },
    setMeasuredValue: (state, payload) => {
      state.measuredValue = payload.measuredValue;
    },
    setWeightValue: (state, payload) => {
      state.bodyWeightValue = payload.bodyWeightValue;
    },
    setViewWheelchair: (state, payload) => {
      state.isWheelchair = payload.isWheelchair;
    },
    setPrint: (state, payload) => {
      state.isPrint = payload.isPrint;
    },
    setMessageSwitch: (state, payload) => {
      state.messageSwitch = payload;
    },
    setViewMessage: (state, payload) => {
      state.isMessage = payload.isMessage;
    },
    setEditModalDataMode: (state, payload) => {
      state.editModalDataMode = payload.editModalDataMode;
    },
    setEditModalData: (state, payload) => {
      state.editModalData = payload.editModalData;
    },
    setOffWaterInfo: (state, payload) => {
      state.offWaterInfo = payload.offWaterInfo;
    },
    setOldOffWaterInfo: (state, payload) => {
      state.oldOffWaterInfo = payload.oldOffWaterInfo;
    },
    setOffWaterChangeFlg: (state, payload) => {
      state.offWaterChangeFlg = payload.offWaterChangeFlg;
    },
    setOffWaterRegFlg: (state, payload) => {
      state.offWaterRegFlg = payload.offWaterRegFlg;
    },
    setOffWaterWeight: (state, payload) => {
      state.offWaterWeight = payload.offWaterWeight;
    },
    setTareInfo: (state, payload) => {
      state.tareInfo = payload.tareInfo;
    },
    setOldTareInfo: (state, payload) => {
      state.oldTareInfo = payload.oldTareInfo;
    },
    setTareChangeFlg: (state, payload) => {
      state.tareChangeFlg = payload.tareChangeFlg;
    },
    setTareWeight: (state, payload) => {
      state.tareWeight = payload.tareWeight;
    },
    setIndTargetWeight: (state, payload) => {
      state.indTargetWeight = payload.indTargetWeight;
    },
    setIndWaterRemovalLimit: (state, payload) => {
      state.indWaterRemovalLimit = payload.indWaterRemovalLimit;
    },
    setIndDryWeight: (state, payload) => {
      state.patStatus.indDryWeight = payload.indDryWeight;
    },
    setLastTimeWeight: (state, payload) => {
      state.lastTimeWeight = payload.lastTimeWeight;
    },
    setBeforeWeightValue: (state, payload) => {
      state.beforeWeightValue = payload.beforeWeightValue;
    },
    setWaterRemovalTarget: (state, payload) => {
      state.waterRemovalTarget = payload.waterRemovalTarget;
    },
    setSelectWheelChair: (state, payload) => {
      state.selectWheelchair = payload.selectWheelchair;
    },
    setSelectWheelChairUnknown: (state) => {
      state.selectWheelchair = {
        code: null,
        name: unknownWheelChairName,
        gramWeight: null,
        weight: null,
        calibrationCheck: true,
      };
    },
    setDewateringIntegration: (state, payload) => {
      state.dewateringIntegration = payload.dewateringIntegration;
    },
    setSendConditionResponseCd: (state, cd) => {
      if (cd !== null) {
        state.sendConditionResponseCd.push(cd);
      }
    },
    removeSendConditionResponseCd: (state, cd) => {
      const newArray = state.sendConditionResponseCd.filter((e) => e !== cd);
      state.sendConditionResponseCd = newArray;
    },
    setIsHasOrdWeightScale: (state, bool) => {
      state.isHasOrdWeightScale = bool;
    },
    setMeasuring: (state, bool) => {
      state.measuring = bool;
    },
    /**
     * 装置状態の保存
     * @param {object} state
     * @param {object} payload
     * @param {number} payload.index 1,2
     * @param {object} payload.machineState
     */
    setMachineState: (state, payload) => {
      const baseJson = {
        isCommonComFormatProtocol: "0",
        isOffline: "0",
        isTreating: "0",
        isConnectError: "0",
        isPatVerified: "0",
        isUseTmpControl: "0",
      };
      if (payload && payload.index !== undefined && payload.index !== null) {
        if (payload.machineState) {
          state.machineState.splice(payload.index, 1, payload.machineState);
        } else {
          state.machineState.splice(payload.index, 1, deepCopy(baseJson));
        }
      } else {
        state.machineState = [deepCopy(baseJson), deepCopy(baseJson)];
      }
    },
    setDeviceInfo: (state, payload) => {
      if (payload && payload.index !== undefined && payload.index !== null) {
        if (payload.info && payload.info !== "") {
          if (typeof payload.info === "string") {
            payload.info = JSON.parse(payload.info);
          }
          state.patDeviceSet.splice(payload.index, 1, payload.info);
        } else {
          state.patDeviceSet.splice(payload.index, 1, null);
        }
      } else {
        state.patDeviceSet = [null, null];
      }
    },
    setHistoryModalList: (state, payload) => {
      payload.HistoryModalList.forEach((e) => {
        state.HistoryModalList.push(e);
      });
    },
    resetHistoryModalList: (state) => {
      state.HistoryModalList = [];
    },
    setIsMachineStateErrorMsg: (state, isHasErr) => {
      state.isMachineStateErrorMsg = isHasErr;
    },
    setLastScaleValue: (state, payload) => {
      state.lastScaleValue = payload;
    },
    setLastWheelChairCd: (state, payload) => {
      state.lastWheelChairCd = payload;
    },
    setLastWheelChairValue: (state, payload) => {
      state.lastWheelChairValue = payload;
    },
    setLastScaleMode: (state, payload) => {
      state.lastScaleMode = payload;
    },
    setIsUsePatWheelChair: (state, payload) => {
      state.isUsePatWheelChair = payload;
    },
  },
};
