/**
 * 条件送信チェックとレシート印刷用ストア
 */
import {
  weightScaleClass,
  operateLegendData,
  checkContent,
} from "@/constants/weightDefine";
import BigEval from "@/functions/BigEvalEx";
import BigNumber from "bignumber.js";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { tareG2Kg, offWaterG2Kg } from "@/functions/common/WeightFunctions";
import moment from "moment";
import { sendRequestGetExam } from "@/apis/send-condition";

// #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import { IS_BEFORE_WEIGHT_TOLERANCE_RANGE_CHECK } from "@/constants/facilitySetting";
// #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 end

const defaultParams = [
  {
    code: "[dw]", // DW
    value: null,
  },
  {
    code: "[tw]", // 目標体重
    value: null,
  },
  {
    code: "[mv]", // 測定値
    value: null,
  },
  {
    code: "[bw]", // 前体重
    value: null,
  },
  {
    code: "[aw]", // 後体重
    value: null,
  },
  {
    code: "[lw]", // 前回後体重
    value: null,
  },
  {
    code: "[twat]", // 目標除水量
    value: null,
  },
  {
    code: "[lwat]", // 除水制限値
    value: null,
  },
  {
    code: "[tare]", // 風袋
    value: null,
  },
  {
    code: "[wat]", // 除水補正
    value: null,
  },
  {
    code: "[rwat]", // 除水実績
    value: null,
  },
  {
    code: "[nd1]", // 次回透析予定１
    value: "予定なし",
  },
  {
    code: "[nd2]", // 次回透析予定２
    value: "予定なし",
  },
  {
    code: "[bmi]", // BMI
    value: null,
  },
  {
    code: "[pg]", // I-HDF引き残し量
    value: null,
  },
  /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --start */
  {
    code: "[wc]", // 車椅子
    value: null,
  },
  /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --end */
  // #10290 2024.03.01 add 測定チェック項目[bwmx/bwmn]を追加 TDC米沢 start
  {
    code: "[bwmx]", // 前体重許容上限
    value: null,
  },
  {
    code: "[bwmn]", // 前体重許容下限
    value: null,
  },
  // #10290 2024.03.01 add 測定チェック項目[bwmx/bwmn]を追加 TDC米沢 end
];

const printItemCd = {
  blankRow: 0, // （空行）
  now: 1, // 現在日時
  bedName: 2, // ベッド番号(ベッド名称)
  hospPatId: 3, // 患者ID（院内）
  patName: 4, // 患者名
  dialysisTime: 5, // 透析時間
  dw: 6, // DW
  targetWeight: 7, // 目標体重
  measuredValue: 8, // 測定値
  beforeWeight: 9, // 前体重
  afterWeight: 10, // 後体重
  lastWeight: 11, // 前回後体重
  beforeParDw: 12, // 前体重/DW
  afterParDw: 13, // 後体重/DW
  weightIncDec: 14, // 体重増減
  weightDiff: 15, // 体重前後差
  targetOffWater: 16, // 除水目標値
  limitOffWater: 17, // 除水制限値
  remain: 18, // 引き残し
  tare: 19, // 風袋
  offWater: 20, // 除水補正値
  diffByDw: 21, // DWから
  diffByDwRate: 22, // DWからの割合
  diffByTw: 23, // 目標体重からの差
  diffByTwRate: 24, // 目標体重からの割合
  diffByLast: 25, // 前回からの差
  diffByLastRate: 26, // 前回からの割合
  bmi: 27, // BMI
  freeText: 28, // フリーテキスト
  line: 29, // 罫線
  nw7: 30, // NW-7
  jan13: 31, // JAN13
  schedule: 32, // 次回予定日
  facility: 33, // 施設名称
  cut: 34, // 用紙カット
};

const printItemSource = {
  master: 0, // マスタから
  exam: 1, // 検査結果から
  check: 2, // チェック項目から
};

const printItemType = {
  text: 0,
  line: 1,
  nw7: 2,
  jan13: 3,
  cut: 4,
};

export default {
  strict: process.env.NODE_ENV !== "production",
  namespaced: true,
  state: {
    // eval代替
    bigEval: new BigEval(),
    legends: operateLegendData.Legends,
    isListMessage: false,
    isLocalMessage: false,
    isCheckView: false,
    localMessageList: [],
    messageList: [],
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    purificationWarnmessageList: [],
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    checkConfig: null,
    printConfig: null,
    params: deepCopy(defaultParams),
    standardCheck: {
      // 身長（BMI計算用）
      patHeight: null,
      // 前体重測定上限（許容する目標体重からの差）
      preScaleUpper: null,
      // 前体重測定下限（許容する目標体重からの差）
      preScaleLower: null,
    },
    doubleCheck: {
      // 2回測定
      enable: false,
      // 許容値
      tolerance: 0,
      // 前回測定値（2回測定チェック有効時に使用）
      // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 start
      //pastMV: 0,
      pastMV: [],
      // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 end
      /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --start */
      // 車椅子の前回測定値
      // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 start
      //pastWC: 0,
      pastWC: [],
      // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 end
      /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --end */
    },
    printParam: {
      bedName: null, // ベッド名称
      hospPatId: null, //院内患者ID
      patName: null, //患者名
      facilityName: null, // 施設名称
      dialysisTime: null, // 透析時間
      rstStartDate: null, // 治療開始日時
      rstEndDate: null, // 治療終了日時
      nextSchedule: null, // 次回透析予定
    },

    // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start
    // 前体重許容範囲チェック実施有無
    isBeforeWeightToleranceRangeCheck: true,
    // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 end

    // #10833(暫定) 2024.08.19 add DWについて治療指示/実績のDWで更新された場合は身体情報で更新しないようにするためのフラグを追加 TDC米沢 start
    // 治療指示/実績DWの使用有無(身体情報のDWによる更新禁止)
    isIndRstDW: false,
    // #10833(暫定) 2024.08.19 add DWについて治療指示/実績のDWで更新された場合は身体情報で更新しないようにするためのフラグを追加 TDC米沢 start
  },
  getters: {
    // リスト項目表示するか否か
    getIsListMessage: (state) => state.isListMessage,
    getCheckMessageList: (state) => state.messageList,
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    getPurificationWarnmessageList: (state) => state.purificationWarnmessageList,
    getPurificationWarnmessageHasError: (state) => {
      const errMsg = state.purificationWarnmessageList.filter((msg) => {
        return !msg.isChecked;
      });
      return errMsg.length > 0;
    },
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    getIsCheckView: (state) => state.isCheckView,
    // ローカルメッセージ項目表示するか否か
    getIsLocalMessage: (state) => state.isLocalMessage,
    getLocalMessageList: (state) => state.localMessageList,
    // 警報あり
    getCheckMessageHasError: (state) => {
      const errMsg = state.messageList.filter((msg) => {
        return msg.isError;
      });
      return errMsg.length > 0;
    },
    // 注意項目あり
    getCheckMessageHasWarn: (state) => {
      const errMsg = state.messageList.filter((msg) => {
        return msg.isWarn && !msg.isChecked;
      });
      return errMsg.length > 0;
    },
    /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --start */
    // 体重の2回測定値チェック
    //  true ：2回測定チェックが有効で1回目測定の場合
    //  false：2回測定チェックが無効、または有効で2回目測定以降
    getCheckDoubleSettingByMv: (state) => {
      return (
        state.doubleCheck.enable &&
        // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 start
        //(state.doubleCheck.pastMV == null || state.doubleCheck.pastMV == 0)
        state.doubleCheck.pastMV.length === 0
        // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 end
      );
    },
    // 車椅子の2回測定値チェック
    //  true ：2回測定チェックが有効で1回目測定の場合
    //  false：2回測定チェックが無効、または有効で2回目測定以降
    getCheckDoubleSettingByWc: (state) => {
      return (
        state.doubleCheck.enable &&
        // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 start
        //(state.doubleCheck.pastWC == null || state.doubleCheck.pastWC === 0)
        state.doubleCheck.pastWC.length === 0
        // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 end
      );
    },
    /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --end */

    // #10833(暫定) 2024.08.19 add DWについて治療指示/実績のDWで更新されたかどうかを返すゲッターを追加 TDC米沢 start
    // 治療指示/実績DWの使用有無(身体情報のDWによる更新禁止)
    getIsIndRstDW: (state) => state.isIndRstDW,
    // #10833(暫定) 2024.08.19 add DWについて治療指示/実績のDWで更新されたかどうかを返すゲッターを追加 TDC米沢 end
  },
  actions: {
    // *****************************
    // * 測定値チェック系ACTION
    // *****************************
    initMessage({ commit }) {
      commit("resetMessage");
      commit("resetParams");
      commit("resetStandardCheck");
      commit("resetDoubleCheck");
      commit("resetPrintParam");
    },
    /**
     *
     * @param {String} param.category "0": 前体重, "1": 後体重
     */
    checkMessageList({ state, commit }, param) {
      commit("setBmiCalc", param.category);

      let msgList = [];
      // *****************************
      // * 測定値2回測定チェック
      // *****************************
      // #10463 2024.06.13 mod 前回測定値の配列化による修正、及び車椅子のみの場合の対応 TDC米沢 start
      // if (
      //   state.doubleCheck.enable &&
      //   state.doubleCheck.pastMV !== 0 &&
      //   state.doubleCheck.tolerance > 0
      // ) {
      //   // 値を取得
      //   const measureValue = state.params.find((param) => {
      //     return param.code === "[mv]";
      //   });
      //   // 測定重量値が存在することを確認
      //   if (measureValue !== null && Number(measureValue.value) > 0) {
      //     if (
      //       new BigNumber(measureValue.value)
      //         .minus(state.doubleCheck.pastMV)
      //         .abs() > state.doubleCheck.tolerance
      //     ) {
      //       // 測定値変動量が規定より大きい
      //       const msg = {
      //         /**
      //          * 表示内容
      //          */
      //         message: `測定値の変動が ${state.doubleCheck.tolerance} kg を超えています`,
      //         isWarnValue: false,
      //         isWarn: false,
      //         isError: true,
      //         isChecked: false,
      //         isDisp: true,
      //       };
      //       msgList.push(msg);
      //     }
      //   }
      // }
      // 2回測定チェックが有効で変動値が0以上である場合
      if (state.doubleCheck.enable && state.doubleCheck.tolerance > 0) {
        let doubleCheckErr = false;
        let measureValue = null;
        const doubleCheckPastValues = [];

        // 体重計、体重計+車椅子の場合
        if (0 < state.doubleCheck.pastMV.length) {
          // 今回測定値を取得
          measureValue = state.params.find((param) => {
            return param.code === "[mv]";
          });
          // 前回測定値を取得
          doubleCheckPastValues.push(...state.doubleCheck.pastMV);
        }
        // 車椅子のみの場合
        else if (0 < state.doubleCheck.pastWC.length) {
          // 今回測定値を取得
          measureValue = state.params.find((param) => {
            return param.code === "[wc]";
          });
          // 前回測定値を取得
          doubleCheckPastValues.push(...state.doubleCheck.pastWC);
        }

        // 今回測定値と前回測定値がある場合
        if (
          0 < doubleCheckPastValues.length &&
          measureValue !== null &&
          Number(measureValue.value) > 0
        ) {
          doubleCheckErr = true;

          // 今回測定値と前回測定値と比較
          for (const val of doubleCheckPastValues) {
            // 今回測定値と前回測定値の変動が指定値以下かどうか
            if (
              new BigNumber(measureValue.value).minus(val).abs() <=
              state.doubleCheck.tolerance
            ) {
              doubleCheckErr = false;
              break;
            }
          }

          // エラー判定
          if (doubleCheckErr) {
            // 測定値変動量が規定より大きい
            const msg = {
              /**
               * 表示内容
               */
              message: `測定値の変動が ${state.doubleCheck.tolerance} kg を超えています`,
              isWarnValue: false,
              isWarn: false,
              isError: true,
              isChecked: false,
              isDisp: true,
            };
            msgList.push(msg);
          }
        }
      }
      // #10463 2024.06.13 mod 前回測定値の配列化による修正、及び車椅子のみの場合の対応 TDC米沢 end
      // *****************************
      // * 前体重許容
      // *****************************
      // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start
      if (state.isBeforeWeightToleranceRangeCheck) {
        // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 end
        if (param.category == weightScaleClass.before) {
          // 値を取得
          const targetWeight = state.params.find((param) => {
            return param.code === "[tw]";
          });
          const beforeWeight = state.params.find((param) => {
            return param.code === "[bw]";
          });
          // 目標体重と前体重値が存在することを確認
          if (
            targetWeight !== null &&
            Number(targetWeight.value) > 0 &&
            beforeWeight !== null &&
            Number(beforeWeight.value) > 0
          ) {
            let isPreScaleError = false;
            if (
              state.standardCheck.preScaleUpper !== null &&
              Number(state.standardCheck.preScaleUpper) > 0 &&
              beforeWeight.value >
                new BigNumber(targetWeight.value)
                  .plus(state.standardCheck.preScaleUpper)
                  .toNumber()
            ) {
              // 前体重許容上限が設定済みで範囲外ならば表示フラグTrue
              isPreScaleError = true;
            } else if (
              state.standardCheck.preScaleLower !== null &&
              Number(state.standardCheck.preScaleLower) > 0 &&
              beforeWeight.value <
                new BigNumber(targetWeight.value)
                  .minus(state.standardCheck.preScaleLower)
                  .toNumber()
            ) {
              // 前体重許容下限が設定済みで範囲外ならば表示フラグTrue
              isPreScaleError = true;
            }

            if (isPreScaleError) {
              const msg = {
                /**
                 * 表示内容
                 */
                message: "前体重許容範囲外",
                isWarnValue: true,
                isWarn: false,
                isError: false,
                isChecked: false,
                isDisp: true,
              };
              msgList.push(msg);
            }
          }
        }
        // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start
      }
      // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 end
      // *****************************
      // * 設定に基づく測定値チェック
      // *****************************
      if (state.checkConfig !== null && state.checkConfig.length > 0) {
        // 設定項目をソート
        state.checkConfig.sort((a, b) => {
          return a.disp_order > b.disp_order ? 1 : -1;
        });
        // 前体重・後体重で使用するものだけを抽出
        let configList = state.checkConfig.filter((item) => {
          if (
            item.is_disp_before === true &&
            param.category == weightScaleClass.before
          ) {
            return true;
          } else if (
            item.is_disp_after === true &&
            param.category == weightScaleClass.after
          ) {
            return true;
          }
        });
        // 無効フラグの立っているものは除外
        configList = configList.filter((item) => item.is_disable != "1");
        for (const conf of configList) {
          const confBase = deepCopy(conf);
          let msg = {
            /**
             * 計算式
             */
            calc: confBase.calculate,
            /**
             * 表示条件
             */
            condition: {
              use: confBase.use_condition,
              left: confBase.condition_left,
              right: confBase.condition_right,
              ineq: confBase.condition_ineq,
              result: null,
            },
            /**
             * 計算結果
             */
            value: null,
            /**
             * 表示内容
             */
            message: "",
            /**
             * 正常範囲外フラグ
             */
            isWarnValue: false,
            /**
             * 警報フラグ
             */
            isWarn: false,
            /**
             * エラーフラグ
             */
            isError: false,
            /**
             * 警報チェックフラグ
             */
            isChecked: false,
            /**
             * 表示フラグ
             */
            isDisp: false,
          };
          // ***************************
          // 計算式に値を代入
          // ***************************
          for (const legend of operateLegendData.legends) {
            let repStr = legend.code;
            if (typeof repStr !== "undefined") {
              // 値を取得
              const status = state.params.find((param) => {
                return param.code === repStr;
              });
              const repStrEscape = repStr
                .replace("[", "\\[")
                .replace("]", "\\]");
              let replaceValue = "";
              if (status.value !== null) {
                replaceValue = status.value;
              }
              // 対象文字がある場合(計算式)
              if (msg.calc?.indexOf(repStr) > -1) {
                msg.calc = msg.calc.replace(
                  new RegExp(repStrEscape, "g"),
                  replaceValue
                );
              }
              // 対象文字がある場合(右辺)
              if (msg.condition.right?.indexOf(repStr) > -1) {
                // 値を取得
                msg.condition.right = msg.condition.right.replace(
                  new RegExp(repStrEscape, "g"),
                  replaceValue
                );
              }
              // 対象文字がある場合(左辺)
              if (msg.condition.left?.indexOf(repStr) > -1) {
                // 値を取得
                msg.condition.left = msg.condition.left.replace(
                  new RegExp(repStrEscape, "g"),
                  replaceValue
                );
              }
            }
          }
          // ***************************
          // 計算
          // ***************************
          // 印字時のデータタイプ [0:number 1:date 2:text]
          if (confBase.print_datatype === 0) {
            // 数値 空白削除
            msg.calc = msg.calc?.replace(/\s+/g, "");
            // 計算式の文字列を計算
            const calcAnswer = state.bigEval.exec(msg.calc);
            // 小数点桁数を表示
            if (typeof calcAnswer === "object" && confBase.decimal_point >= 0) {
              // 計算が成功している場合はBigNumberオブジェクトが返るが、失敗時は文字列
              const BN = BigNumber.clone({
                ROUNDING_MODE: BigNumber.ROUND_HALF_UP,
                DECIMAL_PLACES: confBase.decimal_point,
              });
              const ans = new BN(calcAnswer.toNumber(), 10);
              msg.value = ans.toFixed(confBase.decimal_point);
            } else {
              msg.value = "<計算失敗>";
            }
          } else {
            // 数値以外の場合
            if (msg.calc !== undefined && msg.calc !== null) {
              msg.value = msg.calc;
            } else {
              msg.value = "<情報なし>";
            }
          }
          // ***************************
          // 表示チェック
          // ***************************
          if (msg.condition.use === checkContent.use_condition.always) {
            msg.isDisp = true;
          } else {
            msg.condition.left = state.bigEval.exec(
              msg.condition.left.replace(/\s+/g, "")
            );
            msg.condition.right = state.bigEval.exec(
              msg.condition.right.replace(/\s+/g, "")
            );
            if (
              typeof msg.condition.left === "object" &&
              typeof msg.condition.right === "object"
            ) {
              // 計算が成功している場合はBigNumberオブジェクトが返るが、失敗時は文字列
              switch (msg.condition.ineq) {
                case checkContent.condition_ineq.less:
                  msg.condition.result =
                    msg.condition.left.toNumber() <
                    msg.condition.right.toNumber();
                  break;
                case checkContent.condition_ineq.lessEqual:
                  msg.condition.result =
                    msg.condition.left.toNumber() <=
                    msg.condition.right.toNumber();
                  break;
                case checkContent.condition_ineq.equal:
                  msg.condition.result =
                    msg.condition.left.toNumber() ==
                    msg.condition.right.toNumber();
                  break;
                case checkContent.condition_ineq.notEqual:
                  msg.condition.result =
                    msg.condition.left.toNumber() !=
                    msg.condition.right.toNumber();
                  break;
                case checkContent.condition_ineq.moreEqual:
                  msg.condition.result =
                    msg.condition.left.toNumber() >=
                    msg.condition.right.toNumber();
                  break;
                case checkContent.condition_ineq.more:
                  msg.condition.result =
                    msg.condition.left.toNumber() >
                    msg.condition.right.toNumber();
                  break;
                default:
                  msg.condition.result = null;
                  break;
              }
            } else {
              msg.condition.result = null;
            }

            if (msg.condition.use === checkContent.use_condition.isTrueView) {
              // チェックを満たす場合に表示 null のケースがあるので Trueと比較
              msg.isDisp = msg.condition.result === true;
            } else if (
              msg.condition.use === checkContent.use_condition.isFalseView
            ) {
              // チェックを満たさない場合に表示 null のケースがあるので Trueと比較
              msg.isDisp = msg.condition.result !== true;
            }
          }
          // ***************************
          // 異常値チェック
          // ***************************
          if (
            confBase.is_check_warn === true &&
            isNaN(Number(msg.value)) === false
          ) {
            if (typeof confBase.min_warn === "number") {
              // 最小値より小さい
              msg.isWarnValue =
                msg.isWarnValue || Number(msg.value) <= confBase.min_warn;
            }
            if (typeof confBase.max_warn === "number") {
              // 最大値より大きい
              msg.isWarnValue =
                msg.isWarnValue || Number(msg.value) >= confBase.max_warn;
            }
          }
          // ***************************
          // 条件送信可否チェック
          // ***************************
          switch (confBase.sendable) {
            case checkContent.sendable.checkWarn:
              if (msg.isWarnValue) {
                msg.isWarn = true;
                msg.isError = false;
                msg.isChecked = false;
              }
              break;
            case checkContent.sendable.checkError:
              if (msg.isWarnValue) {
                msg.isWarn = false;
                msg.isError = true;
              }
              break;
            case checkContent.sendable.viewWarn:
              if (msg.isDisp) {
                msg.isWarn = true;
                msg.isError = false;
                msg.isChecked = false;
              }
              break;
            case checkContent.sendable.viewError:
              if (msg.isDisp) {
                msg.isWarn = false;
                msg.isError = true;
              }
              break;
            case checkContent.sendable.ok:
              msg.isWarn = false;
              msg.isError = false;
              break;
            default:
              break;
          }
          msg.message = `${confBase.before_word}${msg.value}${confBase.after_word}`;
          msgList.push(msg);
        }
      }
      commit("setMessageList", msgList);
    },
    // **************************
    // * 設定値項目セット
    // **************************
    // チェック項目設定
    setCheckConfig({ commit }, chk) {
      commit("setCheckConfig", chk);
    },
    setDoubleCheckSetting({ commit }, payload) {
      commit("setDoubleCheckSetting", payload);
    },
    // チェック対象項目
    setParamDw({ commit }, dw) {
      commit("setParamsDw", dw);
    },
    setParamTargetWeight({ commit }, targetWeight) {
      commit("setParamTargetWeight", targetWeight);
    },
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    setPurificationWarnMessageList({ commit }, msgList) {
      commit("setPurificationWarnMessageList", msgList);
    },
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    setParamMeasureValue({ commit }, measureValue) {
      commit("setParamMeasureValue", measureValue);
    },
    setParamBeforeWeight({ commit }, beforeWeight) {
      commit("setParamBeforeWeight", beforeWeight);
    },
    setParamAfterWeight({ commit }, afterWeight) {
      commit("setParamAfterWeight", afterWeight);
    },
    setParamLastWeight({ commit }, lastWeight) {
      commit("setParamLastWeight", lastWeight);
    },
    setParamTargetOffWater({ commit }, targetOffWater) {
      commit("setParamTargetOffWater", targetOffWater);
    },
    setParamLimitOffWater({ commit }, limitOffWater) {
      commit("setParamLimitOffWater", limitOffWater);
    },
    setParamTare({ commit }, tare) {
      commit("setParamTare", tare);
    },
    setParamOffWater({ commit }, offWater) {
      commit("setParamOffWater", offWater);
    },
    setParamResultOffWater({ commit }, resultOffWater) {
      commit("setParamResultOffWater", resultOffWater);
    },
    setParamNextDateMMDD({ commit }, nextDateMMDD) {
      commit("setParamNextDateMMDD", nextDateMMDD);
    },
    setParamNextDateYYYYMMDD({ commit }, nextDateYYYYMMDD) {
      commit("setParamNextDateYYYYMMDD", nextDateYYYYMMDD);
    },
    setParamBmi({ commit }, bmi) {
      commit("setParamBmi", bmi);
    },
    setParamBullLeaveAmount({ commit }, pullLeaveAmount) {
      commit("setParamBullLeaveAmount", pullLeaveAmount);
    },
    // **************************
    // * 印刷項目セット
    // **************************
    // 印刷項目設定
    setPrintConfig({ commit }, print) {
      commit("setPrintConfig", print);
    },
    /**
     * 印刷内容構築
     * @param {Object} param
     * @param {String} param.category weightDefine.weightScaleClass
     * @param {number} param.patId 患者ID
     * @param {String} param.baseDate yyyymmdd
     * @returns {Object}
     * {
     *   row_size: 行数,
     *   row_1: {
     *      class: 種別（text: 0, line: 1, nw7: 2, jan13: 3, cut: 4）,
     *      font_size: フォントサイズ（小：0, 中:1, 大:2),
     *      value: 印刷内容
     *     },
     *  row_2: {...},
     *  ...
     * }
     */
    async buildPrintData({ state }, param) {
      let ret = {};
      let printConfig = {};
      switch (param.category) {
        case weightScaleClass.before:
          printConfig = state.printConfig.before;
          break;
        case weightScaleClass.after:
          printConfig = state.printConfig.after;
          break;
        case weightScaleClass.noSchedule:
          printConfig = state.printConfig.no_schedule;
          break;
        case weightScaleClass.scale:
          printConfig = state.printConfig.no_pat;
          break;
        default:
          break;
      }
      const buildNumberPrintData = (value, conf) => {
        // add 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
        var before_word = "";
        var after_word = "";
        if ("null" == `${conf.before_word}`) {
          before_word = "";
        } else {
          before_word = `${conf.before_word}`;
        }
        if ("null" == `${conf.after_word}`) {
          after_word = "";
        } else {
          after_word = `${conf.after_word}`;
        }
        // add 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
        if (isNaN(value)) {
          // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
          // return `${conf.before_word}<計算失敗>${
          //   conf.after_word
          // }`;
          return before_word + "<計算失敗>" + after_word;
          // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
        }
        const fmt = conf.data_format.split(".");
        const int = Number(fmt[0]);
        const digit = Number(fmt[1]);
        const BN = BigNumber.clone({
          ROUNDING_MODE: BigNumber.ROUND_HALF_UP,
          DECIMAL_PLACES: digit,
        });
        const ans = new BN(value, 10).toFixed(digit);
        if (digit > 0 && ans.split(".")[0].length < int) {
          // 小数点前の桁数を設定値分スペースうめ
          const v = (Array(int).fill(" ").join("") + ans.split(".")[0]).substr(
            -1 * int
          );
          // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
          // return `${conf.before_word}${v}.${ans.split(".")[1]}${
          //   conf.after_word
          // }`;
          return before_word + `${v}.${ans.split(".")[1]}` + after_word;
          // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
        } else if (digit == 0 && ans.length < int) {
          // 桁数を設定値分スペースうめ
          const v = (Array(int).fill(" ").join("") + ans).substr(-1 * int);
          // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
          // return `${conf.before_word}${v}${conf.after_word}`;
          return before_word + `${v}` + after_word;
          // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
        } else {
          // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
          // return `${conf.before_word}${ans}${conf.after_word}`;
          return before_word + `${ans}` + after_word;
          // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
        }
      };
      // *****************************
      // * 設定に基づく印刷項目作成
      // *****************************
      let rowSize = 0;
      if (printConfig !== null && printConfig.length > 0) {
        // 設定項目をソート
        printConfig.sort((a, b) => {
          return a.disp_order > b.disp_order ? 1 : -1;
        });

        let examResult = [];
        if (param.patId) {
          // 患者に紐づく検査結果を取得
          // 検査項目コードを取得
          let itemCdList = [];
          for (const conf of printConfig) {
            if (
              conf.item_source == printItemSource.exam &&
              conf.item_cd !== null &&
              conf.item_cd !== undefined
            ) {
              // FNSI-add redmine4656 徐 start
              let item = {
                item_cd: conf.item_cd,
                exam_class: conf.exam_class ? conf.exam_class : "1",
              };
              // itemCdList.push(conf.item_cd);
              itemCdList.push(item);
              // FNSI-add redmine4656 徐 end
            }
          }
          if (itemCdList.length > 0) {
            // 検査結果取得
            try {
              // FNSI-add redmine4656 徐 start
              // const examResponse = await sendRequestGetExam({
              //   patId: param.patId,
              //   baseDate: param.baseDate,
              //   itemCdList: itemCdList
              // });
              let pritParam = {
                patId: param.patId,
                baseDate: param.baseDate,
                itemCdList: itemCdList,
              };
              const examResponse = await sendRequestGetExam(pritParam);
              // FNSI-add redmine4656 徐 end

              examResult = examResponse.data;
            } catch (e) {
              console.error(e);
              examResult = [];
            }
          }
        }
        for (const conf of printConfig) {
          let row = {
            class: printItemType.text,
            font_size: 0,
            value: null,
          };
          // add 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
          let before_word = "";
          let after_word = "";
          if ("null" == `${conf.before_word}`) {
            before_word = "";
          } else {
            before_word = `${conf.before_word}`;
          }
          if ("null" == `${conf.after_word}`) {
            after_word = "";
          } else {
            after_word = `${conf.after_word}`;
          }
          // add 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
          if (conf.item_source == printItemSource.master) {
            // 印刷項目マスタから設定した印刷項目
            switch (conf.item_cd) {
              case printItemCd.blankRow: // （空行）
                row.value = "";
                break;
              case printItemCd.now: // 現在日時
                {
                  const value = moment().format(conf.data_format);
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}${value}${conf.after_word}`;
                  row.value = before_word + `${value}` + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                }
                break;
              case printItemCd.bedName: // ベッド番号(ベッド名称)
                {
                  const value = state.printParam.bedName;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}${value}${conf.after_word}`;
                  row.value = before_word + `${value}` + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                }
                break;
              case printItemCd.hospPatId: // 患者ID（院内）
                {
                  const value = state.printParam.hospPatId;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}${value}${conf.after_word}`;
                  row.value = before_word + `${value}` + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                }
                break;
              case printItemCd.patName: // 患者名
                {
                  const value = state.printParam.patName;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}${value}${conf.after_word}`;
                  row.value = before_word + `${value}` + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                }
                break;
              case printItemCd.dialysisTime: // 透析時間 hh:mm
                // 前体重：予定 後体重：実績
                if (
                  param.category != weightScaleClass.before &&
                  param.category != weightScaleClass.noSchedule &&
                  param.category != weightScaleClass.after
                ) {
                  // 前体重でも後体重でも予定なし（前体重）でもない
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}不明${conf.after_word}`;
                  row.value = before_word + "不明" + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                } else {
                  // 前体重か後体重かで変数の値が変わる
                  let v1 = null;
                  if (
                    param.category == weightScaleClass.before ||
                    param.category == weightScaleClass.noSchedule
                  ) {
                    v1 = state.printParam.dialysisTime;
                  } else if (param.category === weightScaleClass.after) {
                    if (
                      state.printParam.rstStartDate &&
                      state.printParam.rstEndDate
                    ) {
                      // 後体重で、治療完了日時まで両方設定済み
                      const diffMs =
                        state.printParam.rstEndDate.getTime() -
                        state.printParam.rstStartDate.getTime();
                      // 差のミリ秒を分に変換(端数切捨て)
                      v1 = Math.floor(diffMs / (1000 * 60));
                    } else {
                      v1 = state.printParam.dialysisTime;
                    }
                  }
                  // #10833 2024.08.08 mod 判定式修正 TDC米沢 start
                  // if (v1 == null || v1.value == null) {
                  if (v1 == null) {
                    // #10833 2024.08.08 mod 判定式修正 TDC米沢 end
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}不明${conf.after_word}`;
                    row.value = before_word + "不明" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const d = new Date(0, 0, 0, 0, v1, 0);
                    const v = moment(d).format(conf.data_format);
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}${v}${conf.after_word}`;
                    row.value = before_word + `${v}` + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                }
                break;
              case printItemCd.dw: // DW
                {
                  const dw = state.params.find((p) => p.code === "[dw]");
                  if (dw !== null && dw.value !== null) {
                    row.value = buildNumberPrintData(dw.value, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + `未設定` + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                }
                break;
              case printItemCd.targetWeight: // 目標体重
                {
                  const v = state.params.find((p) => p.code === "[tw]");
                  if (v !== null && v.value !== null) {
                    row.value = buildNumberPrintData(v.value, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + `未設定` + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                }
                break;
              case printItemCd.measuredValue: // 測定値
                {
                  const v = state.params.find((p) => p.code === "[mv]");
                  if (v !== null && v.value !== null) {
                    row.value = buildNumberPrintData(v.value, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                }
                break;
              case printItemCd.beforeWeight: // 前体重
                {
                  const v = state.params.find((p) => p.code === "[bw]");
                  if (v !== null && v.value !== null) {
                    row.value = buildNumberPrintData(v.value, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                }
                break;
              case printItemCd.afterWeight: // 後体重
                {
                  const v = state.params.find((p) => p.code === "[aw]");
                  if (v !== null && v.value !== null) {
                    row.value = buildNumberPrintData(v.value, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                }
                break;
              case printItemCd.lastWeight: // 前回後体重
                {
                  const v = state.params.find((p) => p.code === "[lw]");
                  if (v !== null && v.value !== null) {
                    row.value = buildNumberPrintData(v.value, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                }
                break;
              case printItemCd.beforeParDw: // 前体重/DW
                {
                  const v1 = state.params.find((p) => p.code === "[bw]");
                  const v2 = state.params.find((p) => p.code === "[dw]");
                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const vv = new BigNumber(v1.value).div(v2.value).toNumber();
                    row.value = buildNumberPrintData(vv, conf);
                  }
                }
                break;
              case printItemCd.afterParDw: // 後体重/DW
                {
                  const v1 = state.params.find((p) => p.code === "[aw]");
                  const v2 = state.params.find((p) => p.code === "[dw]");
                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const vv = new BigNumber(v1.value).div(v2.value).toNumber();
                    row.value = buildNumberPrintData(vv, conf);
                  }
                }
                break;
              case printItemCd.weightIncDec: // 体重増減 前体重 - 前回後体重
                {
                  const v1 = state.params.find((p) => p.code === "[bw]");
                  const v2 = state.params.find((p) => p.code === "[lw]");

                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const vv = new BigNumber(v1.value)
                      .minus(v2.value)
                      .toNumber();
                    row.value = buildNumberPrintData(vv, conf);
                  }
                }
                break;
              case printItemCd.weightDiff: // 体重前後差 前体重 - 後体重
                {
                  const v1 = state.params.find((p) => p.code === "[bw]");
                  const v2 = state.params.find((p) => p.code === "[aw]");

                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const vv = new BigNumber(v1.value)
                      .minus(v2.value)
                      .toNumber();
                    row.value = buildNumberPrintData(vv, conf);
                  }
                }
                break;
              case printItemCd.targetOffWater: // 除水目標値
                {
                  const v = state.params.find((p) => p.code === "[twat]");
                  if (v !== null && v.value !== null) {
                    row.value = buildNumberPrintData(v.value, conf);
                  } else {
                    row.value = "";
                  }
                }
                break;
              case printItemCd.limitOffWater: // 除水制限値
                {
                  const v = state.params.find((p) => p.code === "[lwat]");
                  if (v !== null && v.value !== null) {
                    row.value = buildNumberPrintData(v.value, conf);
                  } else {
                    row.value = "";
                  }
                }
                break;
              case printItemCd.remain: // 引き残し
                // 前: 前体重 - 目標体重 - 除水制限 + 除水補正値 >= 0 最小ゼロ
                // 後: 後体重 - 目標体重
                if (
                  param.category == weightScaleClass.before ||
                  param.category == weightScaleClass.noSchedule
                ) {
                  const v1 = state.params.find((p) => p.code === "[bw]");
                  const v2 = state.params.find((p) => p.code === "[tw]");
                  const v3 = state.params.find(
                    (param) => param.code === "[lwat]"
                  );
                  const v4 = state.params.find((p) => p.code === "[wat]");
                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (
                    v2 !== null &&
                    v2.value !== null &&
                    v3 !== null &&
                    v3.value !== null &&
                    v4 !== null &&
                    v4.value !== null
                  ) {
                    const bn = new BigNumber(v1.value)
                      .minus(v2.value)
                      .minus(v3.value)
                      .plus(v4.value)
                      .toNumber();
                    const n = bn < 0 ? 0 : bn;
                    row.value = buildNumberPrintData(n, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                } else if (param.category === weightScaleClass.after) {
                  const v1 = state.params.find((p) => p.code === "[aw]");
                  const v2 = state.params.find((p) => p.code === "[tw]");
                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 !== null && v2.value !== null) {
                    const n = new BigNumber(v1.value)
                      .minus(v2.value)
                      .toNumber();
                    row.value = buildNumberPrintData(n, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                } else {
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}未設定${conf.after_word}`;
                  row.value = before_word + "未設定" + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                }
                break;
              case printItemCd.tare: // 風袋
                {
                  const v = state.params.find((p) => p.code === "[tare]");
                  if (v !== null && v.value !== null) {
                    row.value = buildNumberPrintData(v.value, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                }
                break;
              case printItemCd.offWater: // 除水補正値
                {
                  const v = state.params.find((p) => p.code === "[wat]");
                  if (v !== null && v.value !== null) {
                    row.value = buildNumberPrintData(v.value, conf);
                  } else {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  }
                }
                break;
              case printItemCd.diffByDw: // DWから
                // 前体重 : 前体重 - DW
                // 後体重 : 後体重 - DW
                if (
                  param.category != weightScaleClass.before &&
                  param.category != weightScaleClass.noSchedule &&
                  param.category != weightScaleClass.after
                ) {
                  // 前体重でも後体重でも予定なし（前体重）でもない
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}未設定${conf.after_word}`;
                  row.value = before_word + "未設定" + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                } else {
                  // 前体重か後体重かで変数の値が変わる
                  let v1 = null;
                  if (
                    param.category == weightScaleClass.before ||
                    param.category == weightScaleClass.noSchedule
                  ) {
                    v1 = state.params.find((p) => p.code === "[bw]");
                  } else if (param.category == weightScaleClass.after) {
                    v1 = state.params.find((p) => p.code === "[aw]");
                  }
                  const v2 = state.params.find((p) => p.code === "[dw]");

                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const n = new BigNumber(v1.value)
                      .minus(v2.value)
                      .toNumber();
                    row.value = buildNumberPrintData(n, conf);
                  }
                }
                break;
              case printItemCd.diffByDwRate: // DWから
                // 体重値がゼロ以上ならば
                // 前体重 : 前体重 / (DW / 100)
                // 後体重 : 後体重 / (DW / 100)
                if (
                  param.category != weightScaleClass.before &&
                  param.category != weightScaleClass.noSchedule &&
                  param.category != weightScaleClass.after
                ) {
                  // 前体重でも後体重でも予定なし（前体重）でもない
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}未設定${conf.after_word}`;
                  row.value = before_word + "未設定" + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                } else {
                  // 前体重か後体重かで変数の値が変わる
                  let v1 = null;
                  if (
                    param.category == weightScaleClass.before ||
                    param.category == weightScaleClass.noSchedule
                  ) {
                    v1 = state.params.find((p) => p.code === "[bw]");
                  } else if (param.category == weightScaleClass.after) {
                    v1 = state.params.find((p) => p.code === "[aw]");
                  }
                  const v2 = state.params.find((p) => p.code === "[dw]");

                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const n = new BigNumber(v1.value)
                      .div(new BigNumber(v2.value).div(100))
                      .toNumber();
                    row.value = buildNumberPrintData(n, conf);
                  }
                }
                break;
              case printItemCd.diffByTw: // 目標体重から
                // 前体重 : 前体重 - 目標体重
                // 後体重 : 後体重 - 目標体重
                if (
                  param.category != weightScaleClass.before &&
                  param.category != weightScaleClass.noSchedule &&
                  param.category != weightScaleClass.after
                ) {
                  // 前体重でも後体重でも予定なし（前体重）でもない
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}未設定${conf.after_word}`;
                  row.value = before_word + "未設定" + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                } else {
                  // 前体重か後体重かで変数の値が変わる
                  let v1 = null;
                  if (
                    param.category == weightScaleClass.before ||
                    param.category == weightScaleClass.noSchedule
                  ) {
                    v1 = state.params.find((p) => p.code === "[bw]");
                  } else if (param.category == weightScaleClass.after) {
                    v1 = state.params.find((p) => p.code === "[aw]");
                  }
                  const v2 = state.params.find((p) => p.code === "[tw]");

                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const n = new BigNumber(v1.value)
                      .minus(v2.value)
                      .toNumber();
                    row.value = buildNumberPrintData(n, conf);
                  }
                }
                break;
              case printItemCd.diffByTwRate: // 目標体重から
                // 前体重 : 前体重 / (目標体重 / 100)
                // 後体重 : 後体重 / (目標体重 / 100)
                if (
                  param.category != weightScaleClass.before &&
                  param.category != weightScaleClass.noSchedule &&
                  param.category != weightScaleClass.after
                ) {
                  // 前体重でも後体重でも予定なし（前体重）でもない
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}未設定${conf.after_word}`;
                  row.value = before_word + "未設定" + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                } else {
                  // 前体重か後体重かで変数の値が変わる
                  let v1 = null;
                  if (
                    param.category == weightScaleClass.before ||
                    param.category == weightScaleClass.noSchedule
                  ) {
                    v1 = state.params.find((p) => p.code === "[bw]");
                  } else if (param.category == weightScaleClass.after) {
                    v1 = state.params.find((p) => p.code === "[aw]");
                  }
                  const v2 = state.params.find((p) => p.code === "[tw]");

                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未設定${conf.after_word}`;
                    row.value = before_word + "未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const n = new BigNumber(v1.value)
                      .div(new BigNumber(v2.value).div(100))
                      .toNumber();
                    row.value = buildNumberPrintData(n, conf);
                  }
                }
                break;
              case printItemCd.diffByLast: // 前回から
                // 前体重 : 前体重 - 前回後体重
                // 後体重 : 後体重 - 前体重
                if (
                  param.category != weightScaleClass.before &&
                  param.category != weightScaleClass.noSchedule &&
                  param.category != weightScaleClass.after
                ) {
                  // 前体重でも後体重でも予定なし（前体重）でもない
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}未設定${conf.after_word}`;
                  row.value = before_word + "未設定" + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                } else {
                  // 前体重か後体重かで変数の値が変わる
                  let v1 = null;
                  let v2 = null;
                  if (
                    param.category == weightScaleClass.before ||
                    param.category == weightScaleClass.noSchedule
                  ) {
                    v1 = state.params.find((p) => p.code === "[bw]");
                    v2 = state.params.find((p) => p.code === "[lw]");
                  } else if (param.category == weightScaleClass.after) {
                    v1 = state.params.find((p) => p.code === "[aw]");
                    v2 = state.params.find((p) => p.code === "[bw]");
                  }

                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const n = new BigNumber(v1.value)
                      .minus(v2.value)
                      .toNumber();
                    row.value = buildNumberPrintData(n, conf);
                  }
                }
                break;
              case printItemCd.diffByLastRate: // 前回から
                // 前体重 : 前体重 / (前回後体重 / 100)
                // 後体重 : 後体重 / (前体重 / 100)
                if (
                  param.category != weightScaleClass.before &&
                  param.category != weightScaleClass.noSchedule &&
                  param.category != weightScaleClass.after
                ) {
                  // 前体重でも後体重でも予定なし（前体重）でもない
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}未設定${conf.after_word}`;
                  row.value = before_word + "未設定" + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                } else {
                  // 前体重か後体重かで変数の値が変わる
                  let v1 = null;
                  let v2 = null;
                  if (
                    param.category == weightScaleClass.before ||
                    param.category == weightScaleClass.noSchedule
                  ) {
                    v1 = state.params.find((p) => p.code === "[bw]");
                    v2 = state.params.find((p) => p.code === "[lw]");
                  } else if (param.category == weightScaleClass.after) {
                    v1 = state.params.find((p) => p.code === "[aw]");
                    v2 = state.params.find((p) => p.code === "[bw]");
                  }

                  if (v1 === null || v1.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v2 === null || v2.value === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const n = new BigNumber(v1.value)
                      .div(new BigNumber(v2.value).div(100))
                      .toNumber();
                    row.value = buildNumberPrintData(n, conf);
                  }
                }
                break;
              case printItemCd.bmi: // BMI
                if (
                  param.category != weightScaleClass.before &&
                  param.category != weightScaleClass.noSchedule &&
                  param.category != weightScaleClass.after
                ) {
                  // 前体重でも後体重でも予定なし（前体重）でもない
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}未設定${conf.after_word}`;
                  row.value = before_word + "未設定" + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                } else {
                  // 前体重か後体重かで変数の値が変わる
                  let v1 = null;
                  if (
                    param.category == weightScaleClass.before ||
                    param.category == weightScaleClass.noSchedule
                  ) {
                    v1 = state.params.find((p) => p.code === "[bw]");
                  } else if (param.category == weightScaleClass.after) {
                    v1 = state.params.find((p) => p.code === "[aw]");
                  }
                  if (state.standardCheck.patHeight === null) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}身長未設定${
                    //   conf.after_word
                    // }`;
                    row.value = before_word + "身長未設定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else if (v1 === null || Number(v1.value) <= 0) {
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                    // row.value = `${conf.before_word}未測定${conf.after_word}`;
                    row.value = before_word + "未測定" + after_word;
                    // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                  } else {
                    const metre = new BigNumber(
                      state.standardCheck.patHeight
                    ).div(100);
                    const powMetre = metre.exponentiatedBy(2);
                    const n = new BigNumber(v1.value).div(powMetre).toNumber();
                    row.value = buildNumberPrintData(n, conf);
                  }
                }
                break;
              case printItemCd.freeText: // 任意の文字列
                {
                  row.value = conf.before_word;
                }
                break;
              case printItemCd.line: // 罫線
                // 設定された文字をループして長くして贈る
                {
                  row.class = printItemType.line;
                  row.value = Array(30)
                    .fill(conf.before_word)
                    .join("")
                    .substr(0, 30);
                }
                break;
              case printItemCd.nw7: // NW-7
                {
                  row.class = printItemType.nw7;
                  row.value = state.printParam.hospPatId;
                }
                break;
              case printItemCd.jan13: // JAN13
                {
                  row.class = printItemType.jan13;
                  row.value = state.printParam.hospPatId;
                }
                break;
              case printItemCd.schedule: // 次回予定日
                {
                  let value = "未設定";
                  if (state.printParam.nextSchedule) {
                    value = moment(state.printParam.nextSchedule).format(
                      conf.data_format
                    );
                  }
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}${value}${conf.after_word}`;
                  row.value = before_word + `${value}` + after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                }
                break;
              case printItemCd.facility: // 施設名称
                {
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                  // row.value = `${conf.before_word}${
                  //   state.printParam.facilityName
                  // }${conf.after_word}`;
                  row.value =
                    before_word +
                    `${state.printParam.facilityName}` +
                    after_word;
                  // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
                }
                break;
              case printItemCd.cut: // 用紙カット
                {
                  row.class = printItemType.cut;
                  row.value = null;
                }
                break;
              default:
                continue;
            }
          } else if (conf.item_source == printItemSource.check) {
            // 測定値チェックから設定した印刷項目
            // ***************************
            // 計算式に値を代入
            // ***************************
            let calc = conf.calculate;
            for (const legend of operateLegendData.legends) {
              let repStr = legend.code;
              if (typeof repStr !== "undefined") {
                // 値を取得
                const status = state.params.find(
                  (param) => param.code == repStr
                );
                const repStrEscape = repStr
                  .replace("[", "\\[")
                  .replace("]", "\\]");

                // 対象文字がある場合(計算式)
                if (calc.indexOf(repStr) > -1) {
                  calc = calc.replace(
                    new RegExp(repStrEscape, "g"),
                    status.value
                  );
                }
              }
            }
            // ***************************
            // 計算
            // ***************************
            // 印字時のデータタイプ [0:number 1:date 2:text]
            if (conf.data_type == 0) {
              // 数値 空白削除
              calc = calc.replace(/\s+/g, "");
              // 計算式の文字列を計算
              const calcAnswer = state.bigEval.exec(calc);
              // 小数点桁数を表示
              if (typeof calcAnswer === "object") {
                // 計算が成功している場合はBigNumberオブジェクトが返るが、失敗時は文字列
                const n = calcAnswer.toNumber();
                row.value = buildNumberPrintData(n, conf);
              } else {
                // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
                // row.value = `${conf.before_word}"計算失敗"${conf.after_word}`;
                row.value = before_word + "計算失敗" + after_word;
                // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
              }
            } else if (conf.data_type == 1) {
              // #11017 2024.08.22 mod データ日付ではない場合にそのまま出力する TDC米沢 start
              // // 日付の場合
              // const d = moment(calc).format(conf.data_format);
              let d = calc;
              if (moment(d).isValid()) {
                // 日付の場合
                d = moment(d).format(conf.data_format);
              }
              // #11017 2024.08.22 mod データ日付ではない場合にそのまま出力する TDC米沢 end
              // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
              // row.value = `${conf.before_word}${d}${conf.after_word}`;
              row.value = `${before_word}${d}${after_word}`;
              // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
            } else {
              // それ以外
              row.value = calc;
            }
          } else if (conf.item_source == printItemSource.exam) {
            // TODO: 検査結果が取得できないときFNWでどうだったか確認。いったん「未検査」とする
            let value = "未検査";
            let d = "";
            for (const exam of examResult) {
              if (exam.itemCd == conf.item_cd) {
                value = exam.result;
                d = moment(exam.resultExamDate).format(conf.data_format);
                break;
              }
            }
            if (conf.date_position == 0) {
              // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
              // row.value = `${d} ${conf.before_word}${value}${conf.after_word}`;
              row.value = `${d} ${before_word}${value}${after_word}`;
              // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
            } else {
              // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 start
              // row.value = `${conf.before_word}${value}${conf.after_word} ${d}`;
              row.value = `${before_word}${value}${after_word} ${d}`;
              // mod 10152 体重測定時に出力されるレシートに不要なｎｕｌｌが印字される　吉 end
            }
          } else {
            continue;
          }
          row.font_size = conf.font_size;

          rowSize += 1;

          ret[`row_${rowSize}`] = row;
        }
      }
      ret.row_size = rowSize;
      return ret;
    },
    setPatInfo({ commit }, patInfo) {
      commit("setPat", patInfo);
    },

    // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start
    // 前体重許容範囲チェック実施有無を取得
    setIsBeforeWeightToleranceRangeCheck({ commit }, facilityCd) {
      // 既定：チェック実施(true)
      commit("setIsBeforeWeightToleranceRangeCheck", true);
      return sendRequestGetMstFacilitySettingValue(
        facilityCd,
        IS_BEFORE_WEIGHT_TOLERANCE_RANGE_CHECK
      ).then((response) => {
        commit("setIsBeforeWeightToleranceRangeCheck", response.data == "1");
        return Promise.resolve(response.data);
      });
    },
    // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 end

    // #10463 2024.06.13 add 2回測定チェック用前回測定値をクリアする TDC米沢 start
    // 2回測定チェック用前回測定値を初期化
    clearDoubleCheckPastValues({ commit }) {
      commit("clearDoubleCheckPastValues");
    },
    // #10463 2024.06.13 add 2回測定チェック用前回測定値をクリアする TDC米沢 end
  },
  mutations: {
    setMessageList(state, msgList) {
      state.messageList = msgList;
    },
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    setPurificationWarnMessageList(state, msgList) {
      state.purificationWarnmessageList = msgList;
    },
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    addLocalMessage(state, msgInfo) {
      state.localMessageList.push(msgInfo);
    },
    setLocalMessage(state, msgInfo) {
      state.localMessageList = msgInfo;
    },
    setIsListMessage(state, val) {
      state.isListMessage = val;
    },
    setIsLocalMessage(state, val) {
      state.isLocalMessage = val;
    },
    setIsCheckView(state, val) {
      state.isCheckView = val;
    },
    // **************************
    // * 計算材料セット
    // **************************
    resetStandardCheck(state) {
      state.standardCheck = {
        // 身長（BMI計算用）
        patHeight: null,
        // 前体重測定上限（許容する目標体重からの差）
        preScaleUpper: null,
        // 前体重測定下限（許容する目標体重からの差）
        preScaleLower: null,
      };

      // #10290 2024.03.07 add 測定チェック項目[bwmx/bwmn]を設定 TDC米沢 start
      // 前体重許容上限値[bwmn]を設定
      state.params.find((p) => p.code === "[bwmx]").value = null;
      // 前体重許容上限値[bwmn]を設定
      state.params.find((p) => p.code === "[bwmx]").value = null;
      // #10290 2024.03.07 add 測定チェック項目[bwmx/bwmn]を設定 TDC米沢 end
    },
    setPatHeight(state, height) {
      state.standardCheck.patHeight = height;
    },
    setPatPreScaleUpper(state, value) {
      state.standardCheck.preScaleUpper = value;

      // #10290 2024.03.07 add 測定チェック項目[bwmx]を設定 TDC米沢 start
      // 前体重許容上限値[bwmn]を設定
      state.params.find((p) => p.code === "[bwmx]").value = value;
      // #10290 2024.03.07 add 測定チェック項目[bwmx]を設定 TDC米沢 end
    },
    setPatPreScaleLower(state, value) {
      state.standardCheck.preScaleLower = value;

      // #10290 2024.03.07 add 測定チェック項目[bwmn]を設定 TDC米沢 start
      // 前体重許容下限値[bwmn]を設定
      state.params.find((p) => p.code === "[bwmn]").value = value;
      // #10290 2024.03.07 add 測定チェック項目[bwmn]を設定 TDC米沢 end
    },
    // **************************
    // * 設定値項目セット
    // **************************
    setCheckConfig(state, chk) {
      state.checkConfig = chk;
    },
    setPrintConfig(state, print) {
      state.printConfig = print;
    },
    resetParams(state) {
      state.params = deepCopy(defaultParams);
    },
    resetMessage(state) {
      state.messageList = [];
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
      state.purificationWarnmessageList = [];
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
      state.localMessageList = [];
      state.isListMessage = true;
      state.isLocalMessage = false;
      state.isCheckView = false;

      // #10833(暫定) 2024.08.19 add DWに治療指示/実績のDWがセットされているかどうか判定用のフラグを初期化 TDC米沢 start
      // 治療指示/実績のDW使用有無(身体情報のDWによる更新禁止)
      state.isIndRstDW = false;
      // #10833(暫定) 2024.08.19 add DWに治療指示/実績のDWがセットされているかどうか判定用のフラグを初期化 TDC米沢 end
    },
    // DW
    setParamDw(state, dw) {
      const idx = state.params.findIndex((p) => p.code === "[dw]");
      // NOTE: storeの配列に値をセットするとリアクティブにならないが、
      // 配列内のオブジェクトのプロパティにセットする分には問題ない（ただしオブジェクトが最初から定義してあること）
      // また、この場合は直接使用せず計算材料となるだけのため、その点でも問題はない
      state.params[idx].value = dw;
    },
    // 目標体重
    setParamTargetWeight(state, targetWeight) {
      const idx = state.params.findIndex((p) => p.code === "[tw]");
      state.params[idx].value = targetWeight;
    },
    // 測定値
    setParamMeasureValue(state, measureValue) {
      const idx = state.params.findIndex((p) => p.code === "[mv]");
      // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 start
      //state.doubleCheck.pastMV = state.params[idx].value; // 前回測定値
      // 前回測定値
      const val = state.params[idx].value;
      if (val != null && val != 0) {
        state.doubleCheck.pastMV.push(val);
      }
      // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 end
      state.params[idx].value = measureValue;
    },
    /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --start */
    setParamWheelChair(state, value) {
      const idx = state.params.findIndex((p) => p.code === "[wc]");
      // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 start
      //state.doubleCheck.pastWC = state.params[idx].value;
      // 前回測定値
      const val = state.params[idx].value;
      if (val != null && val != 0) {
        state.doubleCheck.pastWC.push(val);
      }
      // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 end
      state.params[idx].value = value;
    },
    /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --end */
    // 前体重
    setParamBeforeWeight(state, beforeWeight) {
      const idx = state.params.findIndex((p) => p.code === "[bw]");
      state.params[idx].value = beforeWeight;
    },
    // 後体重
    setParamAfterWeight(state, afterWeight) {
      const idx = state.params.findIndex((p) => p.code === "[aw]");
      state.params[idx].value = afterWeight;
    },
    // 前回後体重
    setParamLastWeight(state, lastWeight) {
      const idx = state.params.findIndex((p) => p.code === "[lw]");
      state.params[idx].value = lastWeight;
    },
    // 目標除水量
    setParamTargetOffWater(state, targetOffWater) {
      const idx = state.params.findIndex((p) => p.code === "[twat]");
      state.params[idx].value = targetOffWater;
    },
    // 除水制限値
    setParamLimitOffWater(state, limitOffWater) {
      const idx = state.params.findIndex((p) => p.code === "[lwat]");
      state.params[idx].value = limitOffWater;
    },
    // 風袋合計
    setParamTare(state, tare) {
      // 風袋は合計値から 1g の位を切り捨てた kg の値
      const totalWeight = tareG2Kg(tare);

      const idx = state.params.findIndex((p) => p.code === "[tare]");
      state.params[idx].value = totalWeight;
    },
    // 除水補正合計
    setParamOffWater(state, offWater) {
      // 除水補正は合計値から 1g の位を切り上げた kg の値
      const totalWeight = offWaterG2Kg(offWater);

      const idx = state.params.findIndex((p) => p.code === "[wat]");
      state.params[idx].value = totalWeight;
    },
    setParamResultOffWater(state, resultOffWater) {
      const idx = state.params.findIndex((p) => p.code === "[rwat]");
      state.params[idx].value = resultOffWater;
    },
    setParamNextDateMMDD(state, nextDateMMDD) {
      const idx = state.params.findIndex((p) => p.code === "[nd1]");
      state.params[idx].value = nextDateMMDD;
    },
    setParamNextDateYYYYMMDD(state, nextDateYYYYMMDD) {
      const idx = state.params.findIndex((p) => p.code === "[nd2]");
      state.params[idx].value = nextDateYYYYMMDD;
    },
    setParamBmi(state, bmi) {
      const idx = state.params.findIndex((p) => p.code === "[bmi]");
      state.params[idx].value = bmi;
    },
    setBmiCalc(state, category) {
      // BMIを計算してセットする
      const idx = state.params.findIndex((p) => p.code === "[bmi]");
      const code = category === weightScaleClass.before ? "[bw]" : "[aw]";
      const weight = state.params.find((p) => p.code === code);
      if (
        state.standardCheck.patHeight !== null &&
        state.standardCheck.patHeight > 0 &&
        weight !== null &&
        Number(weight.value) > 0
      ) {
        const metre = new BigNumber(state.standardCheck.patHeight).div(100);
        const powMetre = metre.exponentiatedBy(2);
        state.params[idx].value = new BigNumber(weight.value)
          .div(powMetre)
          .toNumber();
      } else if (state.standardCheck.patHeight === null) {
        state.params[idx].value = "身長未設定";
      } else if (weight === null) {
        state.params[idx].value = "体重未測定";
      } else {
        state.params[idx].value = null;
      }
    },
    setParamBullLeaveAmount(state, pullLeaveAmount) {
      const idx = state.params.findIndex((p) => p.code === "[pg]");
      state.params[idx].value = pullLeaveAmount;
    },
    // **************************
    // * 2回測定チェック
    // **************************
    resetDoubleCheck(state) {
      state.doubleCheck = {
        // 2回測定
        enable: false,
        // 許容値
        tolerance: 0,
        // 前回測定値（2回測定チェック有効時に使用）
        // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 start
        //pastMV: 0,
        pastMV: [],
        // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 end
        /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --start */
        // 車椅子の前回測定値
        // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 start
        //pastWC: 0,
        pastWC: [],
        // #10463 2024.06.13 mod 前回測定値を配列で保持する TDC米沢 end
        /* add by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --end */
      };
    },
    setDoubleCheckSetting(state, payload) {
      state.doubleCheck.enable = payload.enable === "1";
      state.doubleCheck.tolerance = payload.tolerance;
    },

    // #10463 2024.06.13 add 2回測定チェック用前回測定値をクリアするメソッドを新規作成 TDC米沢 start
    // 2回測定チェック用前回測定値初期化
    clearDoubleCheckPastValues(state) {
      state.doubleCheck.pastMV = [];
      state.doubleCheck.pastWC = [];
    },
    // #10463 2024.06.13 add 2回測定チェック用前回測定値をクリアするメソッドを新規作成 TDC米沢 end

    // **************************
    // * 印刷でのみ使用する項目
    // **************************
    resetPrintParam(state) {
      state.printParam = {
        bedName: null, // ベッド名称
        hospPatId: null, //院内患者ID
        patName: null, //患者名
        facilityName: null, // 施設名称
        dialysisTime: null, // 透析時間
        rstStartDate: null, // 治療開始日時
        rstEndDate: null, // 治療終了日時
        nextSchedule: null, // 次回透析予定
      };
    },
    setBedName(state, bedName) {
      state.printParam.bedName = bedName;
    },
    setPat(state, payload) {
      state.printParam.hospPatId = payload.hospPatId; //院内患者ID
      state.printParam.patName = payload.patName; //患者名
    },
    setFacilityName(state, facilityName) {
      state.printParam.facilityName = facilityName; // 施設名称
    },
    setDialysisTime(state, dialysisTime) {
      state.printParam.dialysisTime = dialysisTime; // 透析時間(分)
    },
    setRstDialysisTime(state, payload) {
      if (payload.rstStartDate === null || payload.rstStartDate === "") {
        state.printParam.rstStartDate = null;
      } else if (typeof payload.rstStartDate === "object") {
        // 日付型
        state.printParam.rstStartDate = payload.rstStartDate; // 治療開始日時
      } else {
        // 文字型
        state.printParam.rstStartDate = new Date(payload.rstStartDate); // 治療開始日時
      }
      if (payload.rstEndDate === null || payload.rstEndDate === "") {
        state.printParam.rstEndDate = null;
      } else if (typeof payload.rstEndDate === "object") {
        // 日付型
        state.printParam.rstEndDate = payload.rstEndDate; // 治療終了日時
      } else {
        // 文字型
        state.printParam.rstEndDate = new Date(payload.rstEndDate); // 治療終了日時
      }
    },
    setNextSchedule(state, nextSchedule) {
      state.printParam.nextSchedule = nextSchedule; // 次回透析予定
    },

    // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start
    // 前体重許容範囲チェック実施有無
    setIsBeforeWeightToleranceRangeCheck(state, value) {
      state.isBeforeWeightToleranceRangeCheck = value;
    },
    // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start

    // #10833(暫定) 2024.08.19 mod DWについて治療指示/実績のDWで更新された場合は身体情報で更新しないようにするためのフラグを更新するセッターを追加 TDC米沢 start
    // 治療指示/実績DWの使用有無(身体情報のDWによる更新禁止)
    setIsIndRstDW(state, value) {
      state.isIndRstDW = value;
    },
    // #10833(暫定) 2024.08.19 mod DWについて治療指示/実績のDWで更新された場合は身体情報で更新しないようにするためのフラグを更新するセッターを追加 TDC米沢 end
  },
};
