import { deepCopy, propertyOf } from "@/functions/common/CommonFunctions";

const initState = {
  /**
   * 治療時間
   */
  treatTime: null,

  /**
   * シングルニードル使用
   */
  isSingleNeedle: 0,

  /**
   * 透析液
   */
  dialysate: {},

  /**
   * 透析液-単位
   */
  dialysateUnit: null,

  // add FNSI-【8630】単位が表示されない対応 曲 start
  /**
   * 透析液-単位 変更フラグ
   */
  dialysateUnitChangeFlag: false,
  // add FNSI-【8630】単位が表示されない対応 曲 start

  /**
   * 透析液-選択
   */
  dialysateDisabled: true,

  /**
   * 透析液-使用数小数点桁数
   */
  dialysateDecPoint: null,

  /**
   * 補液
   */
  iv: {},

  /**
   *  補液-選択
   */
  ivDisabled: true,

  /**
   * 補液-単位
   */
  ivUnit: null,

  // add FNSI-【8630】単位が表示されない対応 曲 start
  /**
   * 補液-単位 変更フラグ
   */
  ivUnitChangeFlag: false,
  // add FNSI-【8630】単位が表示されない対応 曲 end

  /**
   * 補液-使用数小数点桁数
   */
  ivDecPoint: null,

  /**
   * 抗凝固剤
   */
  antiCoagulant: {},

  /**
   * 抗凝固剤-単位
   */
  antiCoagulantUnit: null,

  // add FNSI-【8630】単位が表示されない対応 曲 start
  /**
   * 抗凝固剤-単位 変更フラグ
   */
  antiCoagulantUnitChangeFlag: false,
  // add FNSI-【8630】単位が表示されない対応 曲 end

  /**
   * 抗凝固剤-使用数小数点桁数
   */
  antiCoagulantDecPoint: null,

  /**
   * 抗凝固剤-選択
   */
  antiCoagulantDisabled: true,

  /**
   * 抗凝固剤-持続速度
   */
  antiCoagulantFlowRate: null,

  /**
   * 抗凝固剤-持続速度単位
   */
  antiCoagulantFlowRateUnit: null,

  // add FNSI-【8630】単位が表示されない対応 曲 start
  /**
   * 抗凝固剤-持続速度単位 変更フラグ
   */
  antiCoagulantFlowRateUnitChangeFlag: false,
  // add FNSI-【8630】単位が表示されない対応 曲 end

  /**
   * 抗凝固剤-ワンショット量
   */
  antiCoagulantOneshotAmount: null,

  /**
   * 抗凝固剤-持続総量単位
   */
  antiCoagulantAmountTotalUnit: null,

  // add FNSI-【8630】単位が表示されない対応 曲 start
  /**
   * 抗凝固剤-持続総量単位 変更フラグ
   */
  antiCoagulantAmountTotalUnitChangeFlag: false,
  // add FNSI-【8630】単位が表示されない対応 曲 end

  // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start
  /**
   * 抗凝固剤-持続総量Check
   */
  checkDisabled: false,
  // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end

  /**
   * IP使用選択
   */
  isIpUse: false,

  /**
   * IP電源自動切選択
   */
  isIpAutoOff: false,

  /**
   * IP電源自動切り時間
   */
  ipAutoOffTiming: null,

  /**
   * IP電源OKモニタ切選択
   */
  isIpMonitorOff: false,

  /**
   * 治療方法装置モード
   */
  deviceMode: null,

  // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
  /**
   * OHDFコメント表示フラグ
   */
  ohdfCommentIsShow: false,

  /**
   * OHDFコメント表示内容
   */
  ohdfDisplayString: null,
  // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end

  // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
  /**
   * 血流量
   */
  bloodFlowRate: null,

  /**
   * 補液量コメント表示フラグ
   */
  liquidAmountCommentIsShow: false,

  /**
   * 補液量コメント表示内容
   */
  liquidAmountDisplayString: null,

  /**
   * 補液量コメント表示内容
   */
  liquidAmount: null,

  /**
   * 補液速度コメント表示フラグ
   */
  liquidSpeedCommentIsShow: false,

  /**
   * 補液速度コメント表示内容
   */
  liquidSpeedDisplayString: null,

  /**
   * 補液速度
   */
  liquidSpeed: null,

  /**
   * 補液選択
   */
  liquidSelection: null,

  /**
   * 補液開始遅延時間
   */
  liquidDelayTiming: null,

  /**
   * 補液計算優先項目
   */
  liquidCalPriority: null,

  /**
   * OHDF/OHF 補液比率(前補液)
   */
  liquidRateBefore: null,

  /**
   * OHDF/OHF 補液比率(後補液)
   */
  liquidRateAfter: null,

  /**
   * IHDF 補液量
   */
  ihdfLiquidTotal: null,

  /**
   * IHDF 補液速度
   */
  ihdfLiquidSpeed: null,
  // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
  //add 8204 安寧 start
  //VA使用フラグを設定
  isNoUseVA : false,
  //ダイアライザ使用フラグを設定
  isNoUseDialyzer : false,
  //吸着カラム使用フラグを設定
  isNoUseColumn : false,
  //1次膜使用フラグを設定
  isNoUseFirstPass : false,
  //2次膜使用フラグを設定
  isNoUseSecondPass : false,
  //血液回路使用フラグを設定
  isNoUseTube : false,
  //血流量使用フラグを設定
  isNoUseBloodFlow : false,
  //目標体重使用フラグを設定
  isNoUseWeight : false,
  //除水量制限使用フラグを設定
  isNoUseFilterLimit : false,
  //シングルニードル使用フラグを設定
  isNoUseNeedleSelection : false,
  //穿刺針(A)使用フラグを設定
  isNoUseNeedleA : false,
  //穿刺針(V)使用フラグを設定
  isNoUseNeedleV : false,
  //穿刺針(SN)使用フラグを設定
  isNoUseNeedleNeedleSN : false,
  //透析液使用フラグを設定
  isNoUseDialysate : false,
  //透析液流量使用フラグを設定
  isNoUseDialysateFlowRate : false,
  //透析液使用数使用フラグを設定
  isNoUseDialysateAmount : false,
  //透析液温度使用フラグを設定
  isNoUseDialysateTemperature : false,
  //補液使用フラグを設定
  isNoUseIv : false,
  //補液量使用フラグを設定
  isNoUseIvAmount : false,
  //補液選択使用フラグを設定
  isNoUseIvSelection : false,
  //補液使用数使用フラグを設定
  isNoUseIvCount : false,
  //補液温度使用フラグを設定
  isNoUseIvTemperature : false,
  //補液速度使用フラグを設定
  isNoUseIvFlowRate : false,
  //抗凝固剤使用フラグを設定
  isNoUseAntiCoaguLant : false,
  //抗凝固剤ワンショット量使用フラグを設定
  isNoUseAntiCoagulantOneshotAmount : false,
  //抗凝固剤持続速度使用フラグを設定
  isNoUseAntiCoagulantFlowRate : false,
  //抗凝固剤持続総量使用フラグを設定
  isNoUseAntiCoagulantAmountTotal : false,
  //IP使用選択使用フラグを設定
  isNoUseIpSelection : false,
  //IPスタート使用フラグを設定
  isNoUseIpStart : false,
  //IPワンショット量使用フラグを設定
  isNoUseIpOneshotAmount : false,
  //IP速度使用フラグを設定
  isNoUseIpFlowRate : false,
  //IP速度最大値使用フラグを設定
  isNoUseIpFlowRateLimit : false,
  //IPワンショットスタート使用フラグを設定
  isNoUseIpOneshotSelection : false,
  //IP電源自動切り使用フラグを設定
  isNoUseIpAutoOff : false,
  //IP電源自動切り時間使用フラグを設定
  isNoUseIpAutoOffTiming : false,
  //IP電源OKモニタ切り使用フラグを設定
  isNoUseIpMonitorOff : false,
  //IP電源OKモニタ切り時間使用フラグを設定
  isNoUseIpMonitorOffTiming : false,
  //add 8204 安寧 end
  //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
  antiCoagulantAmountDisable: false,
  antiCoagulantFlowRateDisable: false,
  //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
  // add #10937 20260428 Ji start
  needleInitMap: {
    A: null,
    V: null,
    SN:null,
  },
  pressDwSwitchButton: false,
  // add #10937 20260428 Ji end
};

export default {
  namespaced: true,
  strict: true,

  state: deepCopy(initState),

  getters: {
    /**
     * 治療時間を取得
     */
    getTreatTime(state) {
      return state.treatTime;
    },

    /**
     * シングルニードル使用を取得
     */
    getIsSingleNeedle(state) {
      return state.isSingleNeedle;
    },

    /**
     * 透析液コードを取得
     */
    getDialysateCd(state) {
      return state.dialysate ? Number(state.dialysate.value): null;
    },

    /**
     * 透析液選択を取得
     */
    getDialysateDisabled(state) {
      return state.dialysateDisabled;
    },

    /**
     * 透析液単位を取得
     */
    getDialysateUnit(state) {
      return state.dialysateUnit ? state.dialysateUnit: null;
    },

    // add FNSI-【8630】単位が表示されない対応 曲 start
    /**
     * 透析液単位変更フラグを取得
     */
    getDialysateUnitChangeFlag(state) {
      return state.dialysateUnitChangeFlag;
    },
    // add FNSI-【8630】単位が表示されない対応 曲 end

    /**
     * 透析液小数点桁数を取得
     */
    getDialysateDecPoint(state) {
      return state.dialysateDecPoint;
    },

    /**
     * 補液コードを取得
     */
    getIvCd(state) {
      return state.iv ? Number(state.iv.value): null;
    },

    /**
     *  補液選択を取得
     */
    getIvDisabled(state) {
      return state.ivDisabled;
    },

    /**
     * 補液単位を取得
     */
    getIvUnit(state) {
      return state.ivUnit ? state.ivUnit: null;
    },

    // add FNSI-【8630】単位が表示されない対応 曲 start
    /**
     * 補液単位変更フラグを取得
     */
    getIvUnitChangeFlag(state) {
      return state.ivUnitChangeFlag;
    },
    // add FNSI-【8630】単位が表示されない対応 曲 end

    /**
     * 補液小数点桁数を取得
     */
    getIvDecPoint(state) {
      return state.ivDecPoint;
    },

    /**
     * 抗凝固剤情報の全取得
     */
    getAntiCoagulant(state){
      return state.antiCoagulant;
    },

    /**
     * 抗凝固剤-薬剤タイプの取得
     */
    getAnticoagulantMediType(state){
      return state.antiCoagulant.medicine_type;
    },

    /**
     * 抗凝固剤選択を取得
     */
    getAntiCoagulantDisabled(state) {
      return state.antiCoagulantDisabled;
    },

    /**
     * 抗凝固剤-ワンショット単位を取得
     */
    getAntiCoagulantUnit(state) {
      return state.antiCoagulantUnit ? state.antiCoagulantUnit: null;
    },

    /**
     * 抗凝固剤-持続速度単位を取得
     */
    getAntiCoagulantFlowRateUnit(state) {
      return state.antiCoagulantFlowRateUnit;
    },

    /**
     * 抗凝固剤-持続総量単位を取得
     */
    getAntiCoagulantAmountTotalUnit(state) {
      return state.antiCoagulantAmountTotalUnit;
    },

    // add FNSI-【8630】単位が表示されない対応 曲 start
    /**
     * 抗凝固剤-ワンショット単位変更フラグを取得
     */
    getAntiCoagulantUnitChangeFlag(state) {
      return state.antiCoagulantUnitChangeFlag;
    },

    /**
     * 抗凝固剤-持続速度単位変更フラグを取得
     */
    getAntiCoagulantFlowRateUnitChangeFlag(state) {
      return state.antiCoagulantFlowRateUnitChangeFlag;
    },

    /**
     * 抗凝固剤-持続総量単位変更フラグを取得
     */
    getAntiCoagulantAmountTotalUnitChangeFlag(state) {
      return state.antiCoagulantAmountTotalUnitChangeFlag;
    },
    // add FNSI-【8630】単位が表示されない対応 曲 end

    /**
     * 抗凝固剤小数点桁数を取得
     */
    getAntiCoagulantDecPoint(state) {
      return state.antiCoagulantDecPoint;
    },

    /**
     * 抗凝固剤数量を取得
     */
    getAntiCoagulantQuantity(state) {

      // add FNSI-障害票一覧_王彦文(東京).xlsxのNo24(新規患者治療予定登録時エラー)。 韓 start
      if (state.antiCoagulant == null){
        return {
          before:null,
          after:null
        };
      }
      // add FNSI-障害票一覧_王彦文(東京).xlsxのNo24(新規患者治療予定登録時エラー)。 韓 end

      // 調整薬剤の場合
      // (薬剤マスタと調整薬剤マスタでは「基準数量」「換算数量」のカラム名が一致しない為、
      //  調整薬剤マスタのカラム名がstate.antiCoagulantオブジェクトにフィールドとして存在する場合は、
      //  調整薬剤が選択されていると判断し、調整薬剤マスタの値を返却する。)
      if (Object.hasOwn(state.antiCoagulant, 'medicineMixCd')
        && Object.hasOwn(state.antiCoagulant, 'amountUnit')
        && Object.hasOwn(state.antiCoagulant, 'amountMl')) {
          return {
            before: state.antiCoagulant.amountUnit,
            after: state.antiCoagulant.amountMl
          };
      }

      return {
        before: state.antiCoagulant.anticoagulantOriginalQuantity,
        after: state.antiCoagulant.afterAnticoagulantQuantity
      };
    },

    // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start
    /**
     * 抗凝固剤-持続総量Checkを取得
     */
    getCheckDisabled(state) {
      return state.checkDisabled;
    },
    // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end

    /**
     * 抗凝固剤持続速度を取得
     */
    getAntiCoagulantFlowRate(state) {
      return state.antiCoagulantFlowRate;
    },

    /**
     * 抗凝固剤ワンショット量を取得
     */
    getAntiCoagulantOneshotAmount(state) {
      return state.antiCoagulantOneshotAmount;
    },

    /**
     * @description IP使用フラグ
     * @returns {Boolean} 使用する: true, 使用しない: false
     */
    isIpUse(state) {
      return state.isIpUse;
    },

    /**
     * @description IP電源自動切りフラグ
     * @returns {Boolean} 入: true, 切: false
     */
    isIpAutoOff(state) {
      return state.isIpAutoOff;
    },

    /**
     * IP電源自動切り時間を取得
     */
    getIpAutoOffTiming(state) {
      return state.ipAutoOffTiming;
    },

    /**
     * @description IP電源OKモニタ切りフラグ
     * @returns {Boolean} 入: true, 切: false
     */
    isIpMonitorOff(state) {
      return state.isIpMonitorOff;
    },

    /**
     * 治療方法装置モードを取得
     */
    getDeviceMode(state) {
      return state.deviceMode;
    },
    //add 8204 安寧 start
    /**
     * VA使用フラグを取得
     */
    getIsUseFlagVA(state) {
      return state.isNoUseVA;
    },
    /**
     * ダイアライザ使用フラグを取得
     */
    getIsUseFlagDialyzer(state) {
      return state.isNoUseDialyzer;
    },
    /**
     * 吸着カラムフラグを取得
     */
    getIsUseFlagColumn(state) {
      return state.isNoUseColumn;
    },
    /**
     * 1次膜使用フラグを取得
     */
    getIsUseFlagFirstPass(state) {
      return state.isNoUseFirstPass;
    },
    /**
     * 2次膜使用フラグを取得
     */
    getIsUseFlagSecondPass(state) {
      return state.isNoUseSecondPass;
    },
    /**
     * 血液回路使用フラグを取得
     */
    getIsUseFlagTube(state) {
      return state.isNoUseTube;
    },
    /**
     * 血流量使用フラグを取得
     */
    getIsUseFlagBloodFlow(state) {
      return state.isNoUseBloodFlow;
    },
    /**
     * 体重使用フラグを取得
     */
    getIsUseFlagWeight(state) {
      return state.isNoUseWeight;
    },
    /**
     * 除水量制限使用フラグを取得
     */
    getIsUseFlagFilterLimit(state) {
      return state.isNoUseFilterLimit;
    },
    /**
     * シングルニードル使用フラグを取得
     */
    getIsUseFlagNeedleSelection(state) {
      return state.isNoUseNeedleSelection;
    },
     /**
     * 穿刺針(A)使用フラグを取得
     */
     getIsUseFlagNeedleA(state) {
      return state.isNoUseNeedleA;
    },
    /**
    * 穿刺針(V)使用フラグを取得
    */
    getIsUseFlagNeedleV(state) {
      return state.isNoUseNeedleV;
    },
    /**
    * 穿刺針(SN)使用フラグを取得
    */
    getIsUseFlagNeedleNeedleSN(state) {
      return state.isNoUseNeedleNeedleSN;
    },
    /**
    * 透析液使用フラグを取得
    */
    getIsUseFlagDialysate(state) {
      return state.isNoUseDialysate;
    },
    /**
    * 透析液流量使用フラグを取得
    */
    getIsUseFlagDialysateFlowRate(state) {
      return state.isNoUseDialysateFlowRate;
    },
    /**
    * 透析液使用数使用フラグを取得
    */
    getIsUseFlagDialysateAmount(state) {
      return state.isNoUseDialysateAmount;
    },
     /**
    * 透析液温度使用フラグを取得
    */
     getIsUseFlagDialysateTemperature(state) {
      return state.isNoUseDialysateTemperature;
    },
    /**
     * 補液使用フラグを取得
     */
    getIsUseFlagIv(state) {
      return state.isNoUseIv;
    },
    /**
    * 補液量使用フラグを取得
    */
    getIsUseFlagIvAmount(state) {
      return state.isNoUseIvAmount;
    },
    /**
    * 補液選択使用フラグを取得
    */
    getIsUseFlagIvSelection(state) {
      return state.isNoUseIvSelection;
    },
    /**
    * 補液使用数使用フラグを取得
    */
    getIsUseFlagIvCount(state) {
      return state.isNoUseIvCount;
    },
    /**
    * 補液温度使用フラグを取得
    */
    getIsUseFlagIvTemperature(state) {
      return state.isNoUseIvTemperature;
    },
    /**
    * 補液速度使用フラグを取得
    */
    getIsUseFlagIvFlowRate(state) {
      return state.isNoUseIvFlowRate;
    },
    /**
     * 抗凝固剤使用フラグを取得
     */
    getIsUseFlagAntiCoaguLant(state) {
      return state.isNoUseAntiCoaguLant;
    },
    /**
     * 抗凝固剤ワンショット量使用フラグを取得
     */
    getIsUseFlagAntiCoagulantOneshotAmount(state) {
      return state.isNoUseAntiCoagulantOneshotAmount;
    },
    /**
     * 抗凝固剤持続速度使用フラグを取得
     */
    getIsUseFlagAntiCoagulantFlowRate(state) {
      return state.isNoUseAntiCoagulantFlowRate;
    },
    /**
     * 抗凝固剤持続総量使用フラグを取得
     */
    getIsUseFlagAntiCoagulantAmountTotal(state) {
      return state.isNoUseAntiCoagulantAmountTotal;
    },
    /**
     * IP使用選択使用フラグを取得
     */
    getIsUseFlagIpSelection(state) {
      return state.isNoUseIpSelection;
    },
    /**
     * IPスタート使用フラグを取得
     */
    getIsUseFlagIpStart(state) {
      return state.isNoUseIpStart;
    },
    /**
     * IPワンショット量使用フラグを取得
     */
    getIsUseFlagIpOneshotAmount(state) {
      return state.isNoUseIpOneshotAmount;
    },
    /**
     * IP速度使用フラグを取得
     */
    getIsUseFlagIpFlowRate(state) {
      return state.isNoUseIpFlowRate;
    },
    /**
     * IP速度最大値使用フラグを取得
     */
    getIsUseFlagIpFlowRateLimit(state) {
      return state.isNoUseIpFlowRateLimit;
    },
    /**
     * IPワンショットスタート使用フラグを取得
     */
    getIsUseFlagIpOneshotSelection(state) {
      return state.isNoUseIpOneshotSelection;
    },
    /**
     * IP電源自動切り使用フラグを取得
     */
    getIsUseFlagIpAutoOff(state) {
      return state.isNoUseIpAutoOff;
    },
    /**
     * IP電源自動切り時間使用フラグを取得
     */
    getIsUseFlagIpAutoOffTiming(state) {
      return state.isNoUseIpAutoOffTiming;
    },
    /**
     * IP電源OKモニタ切り使用フラグを取得
     */
    getIsUseFlagIpMonitorOff(state) {
      return state.isNoUseIpMonitorOff;
    },
    /**
     * IP電源OKモニタ切り時間使用フラグを取得
     */
    getIsUseFlagIpMonitorOffTiming(state) {
      return state.isNoUseIpMonitorOffTiming;
    },
    //add 8204 安寧 end
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start

    /**
     * IPワンショット量
     */
    getAntiCoagulantAmountDisable(state) {
      return state.antiCoagulantAmountDisable;
    },
    /**
     * IP速度
     */
    getAntiCoagulantFlowRateDisable(state) {
      return state.antiCoagulantFlowRateDisable;
    },

    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
    /**
     * OHDFコメント表示フラグを取得
     */
    getOhdfCommentIsShow(state) {
      return state.ohdfCommentIsShow;
    },

    /**
     * OHDFコメント表示内容を取得
     */
    getOhdfDisplayString(state) {
      return state.ohdfDisplayString;
    },
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end

    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
    /**
     * 血流量を取得
     */
    getBloodFlowRate(state) {
      return state.bloodFlowRate;
    },

    /**
     * 補液量コメント表示フラグを取得
     */
    getLiquidAmountCommentIsShow(state) {
      return state.liquidAmountCommentIsShow;
    },

    /**
     * 補液量コメント表示内容を取得
     */
    getLiquidAmountDisplayString(state) {
      return state.liquidAmountDisplayString?.split('</br>');
    },

    /**
     * 補液量を取得
     */
    getLiquidAmount(state) {
      return state.liquidAmount;
    },

    /**
     * 補液速度コメント表示フラグを取得
     */
    getLiquidSpeedCommentIsShow(state) {
      return state.liquidSpeedCommentIsShow;
    },

    /**
     * 補液速度コメント表示内容を取得
     */
    getLiquidSpeedDisplayString(state) {
      return state.liquidSpeedDisplayString?.split('</br>');
    },

    /**
     * 補液速度を取得
     */
    getLiquidSpeed(state) {
      return state.liquidSpeed;
    },

    /**
     * 補液選択を取得
     */
    getLiquidSelection(state) {
      return state.liquidSelection;
    },

    /**
     * 補液開始遅延時間を取得
     */
    getLiquidDelayTiming(state) {
      return state.liquidDelayTiming;
    },

    /**
     * 補液計算優先項目を取得
     */
    getLiquidCalPriority(state) {
      return state.liquidCalPriority;
    },
    /**
     * OHDF/OHF 補液比率(前補液)を取得
     */
    getLiquidRateBefore(state) {
      return state.liquidRateBefore;
    },

    /**
     * OHDF/OHF 補液比率(後補液)を取得
     */
    getLiquidRateAfter(state) {
      return state.liquidRateAfter;
    },

    /**
     * IHDF 補液量を取得
     */
    getIhdfLiquidTotal(state) {
      return state.ihdfLiquidTotal;
    },
    /**
     * IHDF 補液速度を取得
     */
    getIhdfLiquidSpeed(state) {
      return state.ihdfLiquidSpeed;
    },
    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
    // add #10937 20260428 Ji start
    getNeedleInit(state) {
      return state.needleInitMap;
    },
    getPressDwSwitchButton(state) {
      return state.pressDwSwitchButton;
    },
    // add #10937 20260428 Ji end
  },

  mutations: {
    /**
     * 治療時間を設定
     */
    setTreatTime(state, data) {
      state.treatTime = data;
    },

    /**
     * シングルニードル使用を設定
     */
    setIsSingleNeedle(state, data) {
      state.isSingleNeedle = data;

      state.isNoUseNeedleA = data;
      state.isNoUseNeedleV = data;
      state.isNoUseNeedleNeedleSN = !data;
    },

    /**
     * 透析液選択を設定
     */
    setDialysateDisabled(state, data) {
      state.dialysateDisabled = data;
    },

    /**
     * 透析液を設定
     */
    setDialysate(state, data) {
      state.dialysate = data;
    },

    /**
     * 透析液単位を設定
     */
    setDialysateUnit(state, data) {
      state.dialysateUnit = data;
    },

    // add FNSI-【8630】単位が表示されない対応 曲 start
    /**
     * 透析液単位変更フラグを設定
     */
    setDialysateUnitChangeFlag(state, data) {
      state.dialysateUnitChangeFlag = data;
    },
    // add FNSI-【8630】単位が表示されない対応 曲 end

    /**
     * 透析液使用数小数点桁数を設定
     */
    setDialysateDecPoint(state,data){
      state.dialysateDecPoint = data;
    },

    /**
     * 補液を設定
     */
    setIv(state, data) {
      state.iv = data;
    },

    /**
     * 補液選択を設定
     */
    setIvDisabled(state, data) {
      state.ivDisabled = data;
    },

    /**
     * 補液単位を設定
     */
    setIvUnit(state, data) {
      state.ivUnit = data;
    },

    // add FNSI-【8630】単位が表示されない対応 曲 start
    /**
     * 補液単位変更フラグを設定
     */
    setIvUnitChangeFlag(state, data) {
      state.ivUnitChangeFlag = data;
    },
    // add FNSI-【8630】単位が表示されない対応 曲 end


    /**
     * 補液使用数小数点桁数を設定
     */
    setIvDecPoint(state,data){
      state.ivDecPoint = data;
    },

    /**
     * 抗凝固剤選択を設定
     */
    setAntiCoagulantDisabled(state, data) {
      state.antiCoagulantDisabled = data;
    },

    /**
     * 抗凝固剤を設定
     */
    setAntiCoagulant(state, data) {
      state.antiCoagulant = data;
    },

    /**
     * 抗凝固剤-ワンショット単位を設定
     */
    setAntiCoagulantUnit(state, data) {
      state.antiCoagulantUnit = data;
    },

    /**
     * 抗凝固剤-持続速度単位を設定
     */
    setAntiCoagulantFlowRateUnit(state, data) {
      state.antiCoagulantFlowRateUnit = data;
    },

    /**
     * 抗凝固剤-持続総量単位を設定
     */
    setAntiCoagulantAmountTotalUnit(state, data) {
      state.antiCoagulantAmountTotalUnit = data;
    },

    // add FNSI-【8630】単位が表示されない対応 曲 start
    /**
     * 抗凝固剤-ワンショット単位変更フラグを設定
     */
    setAntiCoagulantUnitChangeFlag(state, data) {
      state.antiCoagulantUnitChangeFlag = data;
    },

    /**
     * 抗凝固剤-持続速度単位変更フラグを設定
     */
    setAntiCoagulantFlowRateUnitChangeFlag(state, data) {
      state.antiCoagulantFlowRateUnitChangeFlag = data;
    },

    /**
     * 抗凝固剤-持続総量単位変更フラグを設定
     */
    setAntiCoagulantAmountTotalUnitChangeFlag(state, data) {
      state.antiCoagulantAmountTotalUnitChangeFlag = data;
    },
    // add FNSI-【8630】単位が表示されない対応 曲 end

    // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start
    /**
     * 抗凝固剤-持続総量Checkを設定
     */
    setCheckDisabled(state, data) {
      state.checkDisabled = data;
    },
    // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end

    /**
     * 補液使用数小数点桁数を設定
     */
    setAntiCoagulantDecPoint(state,data){
      state.antiCoagulantDecPoint = data;
    },

    /**
     * 抗凝固剤持続速度を設定
     */
    setAntiCoagulantFlowRate(state, data) {
      state.antiCoagulantFlowRate = data;
    },

    /**
     * 抗凝固剤ワンショット量を設定
     */
    setAntiCoagulantOneshotAmount(state, data) {
      state.antiCoagulantOneshotAmount = data;
    },

    /**
     * IP使用を設定
     */
    setIpUse(state, data) {
     //mod 8204 安寧 start
     //state.isIpUse = data;
      if (data == 1){
        state.isIpUse = true;
      } else if (data == 0){
        state.isIpUse = false;
      } else {
        state.isIpUse = data;
      }
      //mod 8204 安寧 end
    },

    /**
     * IP電源自動切を設定
     */
    setIpAutoOff(state, data) {
      state.isIpAutoOff = data;
    },

    /**
     * IP電源自動切り時間を設定
     */
    setIpAutoOffTiming(state, data) {
      state.ipAutoOffTiming = data;
    },

    /**
     * IP電源OKモニタ切を設定
     */
    setIpMonitorOff(state, data) {
      state.isIpMonitorOff = data;
    },

    /**
     * 治療方法装置モードを設定
     */
    setDeviceMode(state, data) {
      state.deviceMode = data;
    },
    //add 8204 安寧 start
    /**
     * VA使用フラグを設定
     */
    setIsUseFlagVA(state, data) {
      state.isNoUseVA = data;
    },
    /**
     * ダイアライザ使用フラグを設定
     */
    setIsUseFlagDialyzer(state, data) {
      state.isNoUseDialyzer = data;
    },
    /**
     * 吸着カラム使用フラグを設定
     */
    setIsUseFlagColumn(state, data) {
      state.isNoUseColumn = data;
    },
    /**
     * 1次膜使用フラグを設定
     */
    setIsUseFlagFirstPass(state, data) {
      state.isNoUseFirstPass = data;
    },
    /**
     * 2次膜使用フラグを設定
     */
    setIsUseFlagSecondPass(state, data) {
      state.isNoUseSecondPass = data;
    },
    /**
     * 血液回路使用フラグを設定
     */
    setIsUseFlagTube(state, data) {
      state.isNoUseTube = data;
    },
    /**
     * 血流量使用フラグを設定
     */
    setIsUseFlagBloodFlow(state, data) {
      state.isNoUseBloodFlow = data;
    },
    /**
     * 体重使用フラグを設定
     */
    setIsUseFlagWeight(state, data) {
      state.isNoUseWeight = data;
    },
    /**
     * 除水量制限使用フラグを設定
     */
    setIsUseFlagFilterLimit(state, data) {
      state.isNoUseFilterLimit = data;
    },
    /**
     * シングルニードル使用フラグを設定
     */
    setIsUseFlagNeedleSelection(state, data) {
      state.isNoUseNeedleSelection = data;

      // #9973 add by Zhou.tao
      state.isNoUseNeedleA = !data;
      state.isNoUseNeedleV = !data;
      state.isNoUseNeedleNeedleSN = data;
      // #9973 add by Zhou.tao
    },
    /**
     * 穿刺針(A)使用フラグを設定
     */
    setIsUseFlagNeedleA(state, data) {
      state.isNoUseNeedleA = data;
    },
    /**
     * 穿刺針(V)使用フラグを設定
     */
    setIsUseFlagNeedleV(state, data) {
      state.isNoUseNeedleV = data;
    },
    /**
     * 穿刺針(SN)使用フラグを設定
     */
    setIsUseFlagNeedleNeedleSN(state, data) {
      state.isNoUseNeedleNeedleSN = data;
    },
    /**
     * 透析液使用フラグを設定
     */
    setIsUseFlagDialysate(state, data) {
      state.isNoUseDialysate = data;
    },
    /**
     * 透析液流量使用フラグを設定
     */
    setIsUseFlagDialysateFlowRate(state, data) {
      state.isNoUseDialysateFlowRate = data;
    },
     /**
     * 透析液使用数使用フラグを設定
     */
     setIsUseFlagDialysateAmount(state, data) {
      state.isNoUseDialysateAmount = data;
    },
     /**
     * 透析液温度使用フラグを設定
     */
     setIsUseFlagDialysateTemperature(state, data) {
      state.isNoUseDialysateTemperature = data;
    },
    /**
     * 補液使用フラグを設定
     */
    setIsUseFlagIv(state, data) {
      state.isNoUseIv = data;
    },
    /**
     * 補液量使用フラグを設定
     */
    setIsUseFlagIvAmount(state, data) {
      state.isNoUseIvAmount = data;
    },
    /**
     * 補液選択使用フラグを設定
     */
    setIsUseFlagIvSelection(state, data) {
      state.isNoUseIvSelection = data;
    },
    /**
     * 補液使用数使用フラグを設定
     */
    setIsUseFlagIvCount(state, data) {
      state.isNoUseIvCount = data;
    },
    /**
     * 補液温度使用フラグを設定
     */
    setIsUseFlagIvTemperature(state, data) {
      state.isNoUseIvTemperature = data;
    },
    /**
     * 補液速度使用フラグを設定
     */
    setIsUseFlagIvFlowRate(state, data) {
      state.isNoUseIvFlowRate = data;
    },
    /**
     * 抗凝固剤使用フラグを設定
     */
    setIsUseFlagAntiCoaguLant(state, data) {
      state.isNoUseAntiCoaguLant = data;
    },
    /**
     * 抗凝固剤ワンショット量使用フラグを設定
     */
    setIsUseFlagAntiCoagulantOneshotAmount(state, data) {
      state.isNoUseAntiCoagulantOneshotAmount = data;
    },
    /**
     * 抗凝固剤持続速度使用フラグを設定
     */
    setIsUseFlagAntiCoagulantFlowRate(state, data) {
      state.isNoUseAntiCoagulantFlowRate = data;
    },
    /**
     * 抗凝固剤持続総量使用フラグを設定
     */
    setIsUseFlagAntiCoagulantAmountTotal(state, data) {
      state.isNoUseAntiCoagulantAmountTotal = data;
    },
    /**
     * IP使用選択使用フラグを設定
     */
    setIsUseFlagIpSelection(state, data) {
      state.isNoUseIpSelection = data;
    },
    /**
     * IPスタート使用フラグを設定
     */
    setIsUseFlagIpStart(state, data) {
      state.isNoUseIpStart = data;
    },
    /**
     * IPワンショット量使用フラグを設定
     */
    setIsUseFlagIpOneshotAmount(state, data) {
      state.isNoUseIpOneshotAmount = data;
    },
    /**
     * IP速度使用フラグを設定
     */
    setIsUseFlagIpFlowRate(state, data) {
      state.isNoUseIpFlowRate = data;
    },
    /**
     * IP速度最大値使用フラグを設定
     */
    setIsUseFlagIpFlowRateLimit(state, data) {
      state.isNoUseIpFlowRateLimit = data;
    },
    /**
     * IPワンショットスタート使用フラグを設定
     */
    setIsUseFlagIpOneshotSelection(state, data) {
      state.isNoUseIpOneshotSelection = data;
    },
    /**
     * IP電源自動切り使用フラグを設定
     */
    setIsUseFlagIpAutoOff(state, data) {
      state.isNoUseIpAutoOff = data;
    },
    /**
     * IP電源自動切り時間使用フラグを設定
     */
    setIsUseFlagIpAutoOffTiming(state, data) {
      state.isNoUseIpAutoOffTiming = data;
    },
    /**
     * IP電源OKモニタ切り使用フラグを設定
     */
    setIsUseFlagIpMonitorOff(state, data) {
      state.isNoUseIpMonitorOff = data;
    },
    /**
     * IP電源OKモニタ切り時間使用フラグを設定
     */
    setIsUseFlagIpMonitorOffTiming(state, data) {
      state.isNoUseIpMonitorOffTiming = data;
    },
    //add 8204 安寧 end
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      /**
     * IPワンショット量
     */
    setAntiCoagulantAmountDisable(state, data) {
      state.antiCoagulantAmountDisable = data;
    },
     /**
     * IP速度
     */
    setAntiCoagulantFlowRateDisable(state, data) {
      state.antiCoagulantFlowRateDisable = data;
    },
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
    /**
     * OHDFコメント表示フラグを設定
     */
    setOhdfCommentIsShow(state, data) {
      state.ohdfCommentIsShow = data;
    },

    /**
     * OHDFコメント表示内容を設定
     */
    setOhdfDisplayString(state, data) {
      state.ohdfDisplayString = data;
    },
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end

    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
    /**
     * 血流量を設定
     */
    setBloodFlowRate(state, data) {
      state.bloodFlowRate = data;
    },
    /**
     * 補液量コメント表示フラグを設定
     */
    setLiquidAmountCommentIsShow(state, data) {
      state.liquidAmountCommentIsShow = data;
    },

    /**
     * 補液量コメント表示内容を設定
     */
    setLiquidAmountDisplayString(state, data) {
      state.liquidAmountDisplayString = data;
    },

    /**
     * 補液量を設定
     */
    setLiquidAmount(state, data) {
      state.liquidAmount = data;
    },

    /**
     * 補液速度コメント表示フラグを設定
     */
    setLiquidSpeedCommentIsShow(state, data) {
      state.liquidSpeedCommentIsShow = data;
    },

    /**
     * 補液速度コメント表示内容を設定
     */
    setLiquidSpeedDisplayString(state, data) {
      state.liquidSpeedDisplayString = data;
    },

    /**
     * 補液速度を設定
     */
    setLiquidSpeed(state, data) {
      state.liquidSpeed = data;
    },

    /**
     * 補液選択を設定
     */
    setLiquidSelection(state, data) {
      state.liquidSelection = data;
    },

    /**
     * 補液開始遅延時間を設定
     */
    setLiquidDelayTiming(state, data) {
      state.liquidDelayTiming = data;
    },

    /**
     * 補液計算優先項目を設定
     */
    setLiquidCalPriority(state, data) {
      state.liquidCalPriority = data;
    },

    /**
     * OHDF/OHF 補液比率(前補液)を設定
     */
    setLiquidRateBefore(state, data) {
      state.liquidRateBefore = data;
    },

    /**
     * OHDF/OHF 補液比率(後補液)を設定
     */
    setLiquidRateAfter(state, data) {
      state.liquidRateAfter = data;
    },

    /**
     * IHDF 補液量を設定
     */
    setIhdfLiquidTotal(state, data) {
      state.ihdfLiquidTotal = data;
    },

    /**
     * IHDF 補液速度を設定
     */
    setIhdfLiquidSpeed(state, data) {
      state.ihdfLiquidSpeed = data;
    },
    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end

    /**
     * stateを初期化
     */
    clearTreatCondData(state) {
      const init = deepCopy(initState);
      for (const key in state) {
        // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
        if (key === 'deviceMode'){
          continue;
        }
        // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
        state[key] = init[key];
      }
    },
    // add #10937 20260428 Ji start
    setNeedleInit(state, { type, value }) {
      state.needleInitMap = {
        ...state.needleInitMap,
        [type]: value
      };
    },
    setPressDwSwitchButton(state, data) {
      state.pressDwSwitchButton = data;
    },
    // add #10937 20260428 Ji end
  },

  actions: {
    initTreatCondData({ commit }, { indCondInfo = null }) {
      commit("clearTreatCondData");
      //TODO:各単位系の保持jsonについては回答待ち:2020/03/03
      if (indCondInfo) {
        const condInfo = propertyOf(indCondInfo);
        commit("setTreatTime", Number(condInfo([1, "value"])));
        commit("setIsSingleNeedle", Number(condInfo([12, "value"])));
        // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 start
        // commit("setDialysateDisabled", !Number(condInfo([15, "value"])));
        commit("setDialysateDisabled", false);
        // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end
        commit("setDialysate", condInfo([15]));
        commit("setDialysateUnit", condInfo([17, "unit"]));
        // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 start
        // commit("setIvDisabled", !Number(condInfo([19, "value"])));
        commit("setIvDisabled", false);
        // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end
        commit("setIv", condInfo([19]));
        commit("setIvUnit", condInfo([22, "unit"]));
        // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 start
        // commit("setAntiCoagulantDisabled", !Number(condInfo([25, "value"])));
        commit("setAntiCoagulantDisabled", false);
        // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end
        commit("setAntiCoagulant", condInfo([25]));
        commit(
          "setAntiCoagulantOneshotAmount",
          Number(condInfo([26, "value"]))
        );
        commit("setAntiCoagulantFlowRate", Number(condInfo([27, "value"])));
        commit("setAntiCoagulantUnit", condInfo([26, "unit"]));
        commit("setAntiCoagulantFlowRateUnit", condInfo([27, "unit"]));
        commit("setAntiCoagulantAmountTotalUnit", condInfo([28, "unit"]));
        //mod   6646抗凝固剤持続総量を登録できない 張 start
        // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start
        // commit("setCheckDisabled", !Number(condInfo([28, "value"])));
        /* modify by chamaojia 2023-04-13 [8537] デフォルト値はfalseに設定されています  --start */
        commit("setCheckDisabled", false);
        // commit("setCheckDisabled", Number(condInfo([28, "value"])));
        /* modify by chamaojia 2023-04-13 [8537] デフォルト値はfalseに設定されています  --end */
        // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end
        //mod   6646抗凝固剤持続総量を登録できない 張 start
        commit("setIpUse", Number(condInfo([29, "value"])));
        commit("setIpAutoOff", Number(condInfo([35, "value"])));
        commit("setIpAutoOffTiming", Number(condInfo([36, "value"])));
        commit("setIpMonitorOff", Number(condInfo([37, "value"])));

        // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
        commit("setBloodFlowRate", Number(condInfo([14, "value"])));
        commit("setLiquidAmount", Number(condInfo([20, "value"])));
        commit("setLiquidSelection", condInfo([21, "value"]));
        commit("setLiquidSpeed", Number(condInfo([24, "value"])));
        // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end

      }
    }
  }
};
