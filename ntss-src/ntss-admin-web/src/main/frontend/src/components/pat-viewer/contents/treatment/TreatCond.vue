/** * 治療条件 */
<template>
  <base-content
    :func-name="funcName"
    :disp-data-list="treatCondDataList"
    @onTitleClick="onTitleClick"
    @onSubTitleClick="onSubTitleClick"
    @onCellClick="onCellClick"
  />
</template>

<script>
/**
 * Vue関連
 */
import { mapActions, mapGetters, mapMutations } from "vuex";

/**
 * ベースコンポーネント
 * @summary このコンポーネントへ表示する情報を渡す
 */
import baseContent from "@/components/pat-viewer/contents/base/BaseContent";

/**
 * 日付操作
 */
import moment from "moment";

/**
 * 共通操作
 */
import { deepCopy } from "@/functions/common/CommonFunctions";

import { encodeEditableRecord } from "@/functions/PatInfoFunctions";

/**
 * コンポーネント共通操作
 */
import BaseComponent from "@/components/pat-viewer/contents/base/BaseComponent";

import _ from "underscore";
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  dateFormat,
} from "@/functions/common/DateTimeUtils.js";
//add FNSI-No.IES145 権限対応  吉 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
//add FNSI-No.IES145 権限対応  吉 end

// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
import MakeStructionColorMixin from "./MakeStructionColorMixin";
// add FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import {IND_COND_ID} from "@/constants/IndCondInfoConstants";
import MODAL_TITLE from "@/components/common/ModalTitleContrast.js";
import {PAT_UNIQUE_COL_PHYSICAL_INFO_ORDER_CLASS} from "@/constants/PatInfo";

export default {
  components: {
    "base-content": baseContent
  },
  // mod FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
  // //mod FNSI-No.IES145 権限対応  吉 start
  // // mixins: [BaseComponent],
  // mixins: [BaseComponent,ComponentGuardMixin],
  // //mod FNSI-No.IES145 権限対応  吉 end
  mixins: [BaseComponent, ComponentGuardMixin, MakeStructionColorMixin],
  // mod FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end

  props: {
    /**
     * 一覧に表示する治療情報の行番号
     * @summary 何回目の治療予定かどうかの番号(表示に使用すデータの行番号となる)
     */
    rowIndex: {
      type: Number,
      default: null,
      required: false
    },

    /**
     * 患者経過総合ビューアレイアウトマスタ選択コード
     */
    selectedLayoutCd: {
      type: Number,
      default: -1,
      required: false
    }
  },

  data() {
    return {
      /**
       * 表示するデータのリスト
       * @summary 親コンポーネントに渡す情報
       * fields -> デフォルト値
       * groupCd -> クリックした際に一緒に表示するグループコード
       */
      treatCondDataList: [],
      componentNames: [
        // 治療時間
        {
          name: "ind-treat-time",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 0,
          cd: 1
        },
        // VA
        {
          name: "ind-treat-va",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 1,
          cd: 2
        },
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
        // DW
        {
          name: "ind-treat-dw",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 2,
          cd: 39
        },
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
        // 目標体重
        {
          name: "ind-treat-target-weight",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 2,
          cd: 3
        },
        // 除水量制限
        {
          name: "ind-treat-filter-limit",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 2,
          cd: 4
        },
        // ダイアライザ
        {
          name: "ind-treat-dialyzer",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 3,
          cd: 5
        },
        // 吸着カラム
        {
          name: "ind-treat-separatory-column",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 3,
          cd: 6
        },
        // 1次膜
        {
          name: "ind-treat-first-pass",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 4,
          cd: 7
        },
        // 2次膜
        {
          name: "ind-treat-second-pass",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 4,
          cd: 8
        },
        // シングルニードル使用
        {
          name: "ind-treat-needle-selection",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 5,
          cd: 12
        },
        // 穿刺針A針
        {
          name: "ind-treat-needle-a",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 5,
          cd: 9
        },
        // 穿刺針V針
        {
          name: "ind-treat-needle-v",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 5,
          cd: 10
        },
        // 穿刺針SN
        {
          name: "ind-treat-needle-sn",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 5,
          cd: 11
        },
        // 血液回路
        {
          name: "ind-treat-tube",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 6,
          cd: 13
        },
        // 血流量
        {
          name: "ind-treat-blood-flow",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 7,
          cd: 14
        },
        // 透析液
        {
          name: "ind-treat-dialysate",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 8,
          cd: 15
        },
        // 透析液流量
        {
          name: "ind-treat-dialysate-flow-rate",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 8,
          cd: 16
        },
        // 透析液使用数
        {
          name: "ind-treat-dialysate-amount",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          },
          groupCd: 8,
          cd: 17
        },
        // 透析液温度
        {
          name: "ind-treat-dialysate-temperature",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 8,
          cd: 18
        },
        // 補液
        {
          name: "ind-treat-iv",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 19
        },
        // 補液量
        {
          name: "ind-treat-iv-amount",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 20
        },
        // 補液選択
        {
          name: "ind-treat-iv-selection",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 21
        },
        // 補液使用数
        {
          name: "ind-treat-iv-count",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 22
        },
        // 補液温度
        {
          name: "ind-treat-iv-temperature",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 23
        },
        // 補液速度
        {
          name: "ind-treat-iv-flow-rate",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 24
        },
        // 抗凝固剤
        {
          name: "ind-treat-anti-coagulant",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 25
        },
        // 抗凝固剤ワンショット量
        {
          name: "ind-treat-anti-coagulant-amount",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 26
        },
        // 抗凝固剤持続速度
        {
          name: "ind-treat-anti-coagulant-flow-rate",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 27
        },
        // 抗凝固剤持続総量
        {
          name: "ind-treat-anti-coagulant-amount-total",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 28
        },
        // IP使用選択
        {
          name: "ind-treat-ip-selection",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 29
        },
        // IPスタート
        {
          name: "ind-treat-ip-start",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 30
        },
        // IP速度
        {
          name: "ind-treat-ip-flow-rate",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 32
        },
        // IP速度最大値量
        {
          name: "ind-treat-ip-flow-rate-limit",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 33
        },
        // IPワンショットスタート
        {
          name: "ind-treat-ip-oneshot-selection",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 34
        },
        // IPワンショット量
        {
          name: "ind-treat-ip-amount",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 31
        },
        // IP電源自動切り
        {
          name: "ind-treat-ip-auto-off",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 35
        },
        // IP電源自動切り時間
        {
          name: "ind-treat-ip-auto-off-timing",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 36
        },
        // IP電源OKモニタ切り
        {
          name: "ind-treat-ip-monitor-off",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 37
        },
        // IP電源OKモニタ切り時間
        {
          name: "ind-treat-ip-monitor-off-timing",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 38
        }
      ],
      dwComponent:
        // 特別：DW
        {
          name: "ind-dw",
          fields: {
            value: null,
            medicineType: null
          },
          groupCd: -1,
          cd: -1
        },
      //add FNSI-No.IES145 権限対応  吉 start
      authorityCds:[
        AUTHORITY_CODES.IND_PEDIT,
        AUTHORITY_CODES.IND_EDIT,
      ],
      flagAuthority:false,
      //add FNSI-No.IES145 権限対応  吉 end
    };
  },

  computed: {
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 start
    //...mapGetters("pat-viewer", ["getMstTreatmentData", "getSelectedLayout"]),
    ...mapGetters("pat-viewer", ["getMstTreatmentData", "getSelectedLayout", "getTreatmentDataTmp", "getPhysicalInfo",
      "getDateList", "getSelectedPeriod", "getDataListKeepTreatCond", "getPatIdKeep", "getPatIdKeepChgFlg"]),
    ...mapGetters("pat-info", { patId: "selectedPatId" }),
    // mod 1006-398 指示の切り替わりポイントを赤くする 陳 end
    ...mapGetters("pat-viewer-modal", ["getDefaultSettingIndConditionData"]),
    ...mapGetters("pat-info", ["selectedPat"]),
    /**
     * 項目列の縦文字タイトル
     * @summary 親コンポーネントに渡す情報
     */
    funcName() {
      let name = "治療条件";
      if (
        this.treatCondDataList.length &&
        this.treatCondDataList[0].itemName === "治療条件"

      ) {
        name = null;
      }

      return name;
    },

    /**
     * 指示コメント(IndEditBase)に渡すデータ(雛形)
     */
    faultSettingIndConditionData() {
      return this.getDefaultSettingIndConditionData;
    }
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  async created() {
    this.flagAuthority = this.getTreatmentRecordAuthority();
    // 表示用に治療条件情報を加工
    this.startLoadingScreen();
    this.convertTreatCondData({
      listIndex: this.rowIndex,
      selectLayoutCd: this.selectedLayoutCd
    }).then(treatCondDataListLet => {
      // 指示の切り替わりポイント処理を呼び出す
      this.makeStructionColor(treatCondDataListLet, 3);

      this.treatCondDataList = treatCondDataListLet;

      // 「目標体重」にDWを表示
      this.createTargetWeightDWInfo();
    }).finally(() => {
      this.finishLoadingScreen();
    });
  },

  methods: {
    ...mapActions("pat-viewer", [
      "convertTreatCondData",
      "getMstRecordInState",
      "setPatIdKeep", "setDateList",  "setDataListKeepTreatCond", "setPatIdKeepChgFlg"
    ]),
    ...mapActions("pat-viewer-modal", ["showIndModal", "showDwModal"]),
    ...mapActions("pat-viewer-treat-cond", ["initTreatCondData"]),
    ...mapActions("multi-modal", ["showPhysicalInfoAddEdit"]),
    ...mapMutations("pat-viewer-treat-cond", ["setDeviceMode","setAntiCoagulantAmountDisable","setAntiCoagulantFlowRateDisable"
      // add #10150 piao Start
      ,"setIvUnit"
      ,"setIvDecPoint"
      // add #10150 piao end
      //mod 8204 安寧 start
      ,"setIsUseFlagVA" //VA使用フラグを設定
      ,"setIsUseFlagDialyzer"//ダイアライザ使用フラグを設定
      ,"setIsUseFlagColumn"//吸着カラム使用フラグを設定
      ,"setIsUseFlagFirstPass" //1次膜使用フラグを設定
      ,"setIsUseFlagSecondPass"//2次膜使用フラグを設定
      ,"setIsUseFlagTube" //血液回路使用フラグを設定
      ,"setIsUseFlagBloodFlow"//血流量使用フラグを設定
      ,"setIsUseFlagWeight"//体重使用フラグを設定
      ,"setIsUseFlagFilterLimit" //除水量制限使用フラグを設定
      ,"setIsUseFlagNeedleSelection"//シングルニードル使用フラグを設定
      ,"setIsUseFlagNeedleA"//穿刺針(A)使用フラグを設定
      ,"setIsUseFlagNeedleV"//穿刺針(V)使用フラグを設定
      ,"setIsUseFlagNeedleNeedleSN"//穿刺針(SN)使用フラグを設定
      ,"setIsUseFlagDialysate"//透析液使用フラグを設定
      ,"setIsUseFlagDialysateFlowRate"//透析液流量使用フラグを設定
      ,"setIsUseFlagDialysateAmount"//透析液使用数使用フラグを設定
      ,"setIsUseFlagDialysateTemperature"//透析液温度使用フラグを設定
      ,"setIsUseFlagIv"//補液使用フラグを設定
      ,"setIsUseFlagIvAmount"//補液量使用フラグを設定
      ,"setIsUseFlagIvSelection"//補液選択使用フラグを設定
      ,"setIsUseFlagIvCount"//補液使用数使用フラグを設定
      ,"setIsUseFlagIvTemperature"//補液温度使用フラグを設定
      ,"setIsUseFlagIvFlowRate"//補液速度使用フラグを設定
      ,"setIsUseFlagAntiCoaguLant"//抗凝固剤使用フラグを設定
      ,"setIsUseFlagAntiCoagulantOneshotAmount"//抗凝固剤ワンショット量使用フラグを設定
      ,"setIsUseFlagAntiCoagulantFlowRate"//抗凝固剤持続速度使用フラグを設定
      ,"setIsUseFlagAntiCoagulantAmountTotal"//抗凝固剤持続総量使用フラグを設定
      ,"setIsUseFlagIpSelection"//IP使用選択使用フラグを設定
      ,"setIsUseFlagIpStart"//IPスタート使用フラグを設定
      ,"setIsUseFlagIpOneshotAmount"//IPワンショット量使用フラグを設定
      ,"setIsUseFlagIpFlowRate"//IP速度使用フラグを設定
      ,"setIsUseFlagIpFlowRateLimit"//IP速度最大値使用フラグを設定
      ,"setIsUseFlagIpOneshotSelection"//IPワンショットスタート使用フラグを設定
      ,"setIsUseFlagIpAutoOff"//IP電源自動切り使用フラグを設定
      ,"setIsUseFlagIpAutoOffTiming"//IP電源自動切り時間使用フラグを設定
      ,"setIsUseFlagIpMonitorOff"//IP電源OKモニタ切り使用フラグを設定
      ,"setIsUseFlagIpMonitorOffTiming"//IP電源OKモニタ切り時間使用フラグを設定
     ]),//穿刺針使用フラグを設定
       //mod 8204 安寧 end
    ...mapMutations("pat-info", ["setSelectedPhysicalInfoData"]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),

    /**
     * 「治療条件」タイトルクリック時処理
     * @summary 治療条件編集モーダル表示
     */
    onTitleClick() {
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // すべて過去日
      // if (this.getIsPastDate) {
      //   // 操作不可メッセージの表示
      //   this.showDisProcMessage();
      //   return;
      // }
      // 一覧上に治療予定がない場合は処理終了
      // if (!this.isTreatPlan) {
      // return;
      // }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
      // 基準日から治療予定のある直近日を取得
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // const treatDate = this.getRecentBaseDate() || this.baseDate;
      const treatDate = this.getRecentBaseDate();
      if (!treatDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      //直近日の治療条件を取得
      let componentInfo;
      let treatCondData = [];
      let groupCd = "";
      let gCd="";
      for(var i=0;i<this.componentNames.length;i++) {
        groupCd = this.componentNames[i].groupCd;
        if (gCd === groupCd) {
          continue;
        } else {
          gCd = groupCd;
        }
        componentInfo = this.setDefaultData(this.componentNames[i].cd, treatDate);

        for (var j=0;j<componentInfo.length;j++){
         if (componentInfo[j].cd === 39) {
           // DWは対象外
            continue;
          }
         treatCondData.push(componentInfo[j]);
        }

      }

      // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end
      // 治療条件編集モーダルを表示する
      this.showTreatCondModal(
        // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 start
        // this.baseDate,
        treatDate,
        // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 end
        null,
        "治療条件",
        // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 start
        //deepCopy(this.componentNames),
        deepCopy(treatCondData),
        // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 end
        // add FNSI-障害票一覧_患者経過総合ビューアの№12 周 start
        // false
        true,
        // add FNSI-障害票一覧_患者経過総合ビューアの№12 周 end
        //add #10266  start
        //一括編集 2
        "2"
        //add #10266  end
      );
    },

    /**
     * 「治療条件」サブタイトルクリック時処理
     * @summary 治療条件編集モーダル表示
     * @param event ターゲット
     * @param rowInfo 行情報
     * @param itemInfo「治療条件」項目情報
     * @param itemIndex 「治療条件」項目番号
     */
    onSubTitleClick(event, rowInfo, itemInfo, itemIndex) {
      // DWはクリック不可
      if (rowInfo.itemNo === -1) {
        // DWモーダルを表示
        const currentTreatDate = this.getRecentBaseDate() || this.baseDate;
        this.showPhysicalInfoModal(currentTreatDate);

        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // すべて過去日
      // if (this.getIsPastDate) {
        //   // 操作不可メッセージの表示
        //   this.showDisProcMessage();
        //   return;
      // }
      // 一覧上に治療予定がなければなにもしない
      // if (!this.isTreatPlan) {
      //   return;
      // }
      // 基準日から治療予定のある直近日を取得
      // const treatDate = this.getRecentBaseDate() || this.baseDate;
      const treatDate = this.getRecentBaseDate();
      if (!treatDate) {
        return;
      }
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // 直近日の治療条件を取得
      const treatInfo = rowInfo.data.find(
        ({ ordNo }) => ordNo === this.ordMainData[treatDate].ordNo
      );
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      const itemNo = treatInfo ? treatInfo.itemNo : itemIndex;
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 start
      // 表示するコンポーネント情報
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng start
      // let componentInfo = this.setDefaultData(treatInfo.itemNo, treatDate);
      let componentInfo = this.setDefaultData(itemNo, treatDate);
      // #10196 患者経過総合ビューア指示変更関係_最新版[質問sheet]  開始日表示が不正です。 linjunfeng end
      //mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.87(外結)対応 韓 start
      // if (rowInfo.data[0].rstDialysisState === '0' && (rowInfo.itemNo === 3 || rowInfo.itemNo ===4)) {
      if (rowInfo.itemNo === 3 || rowInfo.itemNo ===4) {
      //mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.87(外結)対応 韓 end
        componentInfo = deepCopy(componentInfo).filter(item => {
          return item.cd !== 39;
        });
      }
      // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 end
      // ヘッダータイトル
      const headerTitle = this.getHeaderTitle(componentInfo[0].groupCd);
      // 治療条件編集モーダルを表示する
      this.showTreatCondModal(
        treatDate,
        null,
        headerTitle,
        componentInfo,
        true,
        //add #10266  start
        //一括編集 2
        "2"
        //add #10266  end
      );
    },

    /**
     * 「治療条件」データセルクリック時処理
     * @summary 治療条件編集モーダル表示
     * @param event ターゲット
     * @param cellInfo クリックしたセル情報
     * @param itemName クリックしたセルの項目名
     * @param itemuInfo クリックした治療予定の「治療条件」情報
     * @param itemIndex 行番号
     */
    onCellClick(event, cellInfo, itemName, itemInfo, itemIndex, isIndClick) {
      // クリックしたセルの行に治療情報がない場合は、処理終了
      if (null === cellInfo.ordNo) {
        return;
      }

      /* modify by chamaojia 2023-10-30 [9973] 指示と実際のdisabledは区別する --start */
      // 治療方法による治療条件設定で無効される場合、処理終了
      // if (cellInfo.isDisabled) {
      //   return;
      // }
      if (isIndClick && cellInfo.isDisabled1) {
        return;
      }
      if (!isIndClick && cellInfo.isDisabled2) {
        return;
      }
      /* modify by chamaojia 2023-10-30 [9973] 指示と実際のdisabledは区別する --end */

      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --start */
      // if (cellInfo.isNotClickable) {
      if (isIndClick && cellInfo.isNotClickable) {
        // 画面遷移しない
        return;
      }
      /* upd by chamaojia 2026-03-31 [12462] 患者情報共有->患者経過総合ビューア --end */

      // モーダル物理情報を表示する
      // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 start
      // if (cellInfo.itemNo === -1) {
      if (cellInfo.itemNo === -1 && cellInfo.rstDialysisState === '0') {
      // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 end
        const cellTreatDate = moment(cellInfo.treatDate, "YYYYMMDD").format(
          "YYYY-MM-DD"
        );
        this.showPhysicalInfoModal(cellTreatDate);
        return;
      }

      // 指示項目がクリックされた場合、以下の処理を実行する
      if (isIndClick) {
        // 治療条件編集モーダルに設定する治療開始日
        const treatDate = moment(cellInfo.treatDate, "YYYYMMDD").format(
          "YYYY-MM-DD"
        );
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
        const itemNo = (cellInfo.itemNo === -1) ? 39 : cellInfo.itemNo;
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
        // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 start
        // 表示するコンポーネント情報
        //const componentInfo = this.setDefaultData(cellInfo.itemNo, treatDate);
        let componentInfo = this.setDefaultData(itemNo, treatDate);
        // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 end
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
        if (cellInfo.rstDialysisState === '0' && (itemNo === 3 || itemNo ===4)) {
          componentInfo = deepCopy(componentInfo).filter(item => {
            return item.cd !== 39;
          });
        }
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
        // ヘッダータイトル
        const headerTitle = this.getHeaderTitle(componentInfo[0].groupCd);
        // 治療条件編集モーダルを表示する
        this.showTreatCondModal(
          treatDate,
          cellInfo.ordNo,
          headerTitle,
          componentInfo,
          true,
          //add #10266  start
          null
          //add #10266  end
        );
      } else {
        // 実績が存在しない場合処理終了
        if (!cellInfo.value2 && cellInfo.value2 !== 0) {
          return;
        }

        //#9836  利用者マスタの治療記録編集権限をOFFの状態でコンソールエラー/ボタンを押下しても画面の反応がなくなる 2023-10-12 卓 start
        //add FNSI-No.IES145 権限対応  吉 start
        // if("DW" == itemName) {
        //   this.authorityCds=[ AUTHORITY_CODES.IND_PEDIT, AUTHORITY_CODES.IND_EDIT, AUTHORITY_CODES.PAT_EDIT]
        // }
        // this.flagAuthority = this.getTreatmentRecordAuthority();
        // if(!this.flagAuthority){
        //   this.$ons.notification.alert({
        //     // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        //     // title: "",
        //     // message: "権限不足"
        //     title: DIALOG_MESSAGES['00200116'].title,
        //     message: messageFormat(DIALOG_MESSAGES['00200116'].mesage)
        //     // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        //   });
        //   return;
        // }
        //add FNSI-No.IES145 権限対応  吉 end
        //#9836  利用者マスタの治療記録編集権限をOFFの状態でコンソールエラー/ボタンを押下しても画面の反応がなくなる 2023-10-12 卓 end

        // 「治療記録」-「治療条件」に画面遷移する
        this.setRouter(cellInfo.ordNo, [
          "treatment-record",
          "treatment-record-condition"
        ]);
      }
    },

    /**
     * 治療条件モーダル表示
     * @param treatDate 治療日(開始日) ※オーダー番号が格納されている場合、終了日も格納
     * @param ordNo オーダー番号
     * @param headerTitle 編集モーダルヘッダー
     * @param compnentInfo 編集する一覧情報
     * @param isInitStore 治療条件のストアをデフォルトデータで初期化するかフラグ
     * //add #10266  start
     * @param update_flag  2:一括編集  その他の値（2以外）：個別編集
     * //add #10266  end
     */
    showTreatCondModal(
      treatDate,
      ordNo,
      headerTitle,
      componentInfo,
      isInitStore,
      //add #10266  start
      update_flag
      //add #10266  end
    ) {
      // 治療条件ストアを初期化
      this.initTreatCondData({
        indCondInfo: isInitStore
          ? ((this.ordMainData[moment(treatDate).format("YYYYMMDD")] && this.ordMainData[moment(treatDate).format("YYYYMMDD")].indCondInfo) ? JSON.parse(
            this.ordMainData[moment(treatDate).format("YYYYMMDD")].indCondInfo
          ) : null)
          : null
      });
      // 治療方法装置モードをストアに格納
      const treatment =
        isInitStore &&
        this.getMstTreatmentData.find(
          ({ treatmentCd }) =>
            treatmentCd ===
            ((this.ordMainData[moment(treatDate).format("YYYYMMDD")] && this.ordMainData[moment(treatDate).format("YYYYMMDD")]
              .indTreatmentCd) ? this.ordMainData[moment(treatDate).format("YYYYMMDD")]
              .indTreatmentCd : null)
        );
      const deviceMode = treatment && treatment.deviceMode;
      this.setDeviceMode(deviceMode);

      // add #10150 piao start
      const ordMainData = this.ordMainData[moment(treatDate).format("YYYYMMDD")] ? this.ordMainData[moment(treatDate).format("YYYYMMDD")] : null;
      if(ordMainData){
        const rstDialysisState = ordMainData.rstDialysisState;
        const dataObject  = ordMainData.indCondInfo ? JSON.parse(ordMainData.indCondInfo) : null;
        if(rstDialysisState === "0"){
          if((deviceMode === 7 || deviceMode === 8 || deviceMode === 10 ) && dataObject && dataObject[15].value !== null){
            ApiHelper.get("/mstInfo/mstMedicine/getByCd", {medicineCd:dataObject[15].value, medicineType:dataObject[15].medicine_type}).then((res) => {
              if (res && res.data) {
                this.setIvUnit(res.data.unitSecond);
                this.setIvDecPoint(res.data.unitDecimalPointSecond);
              }
            });
          }
        }
      }
      // add #10150 piao end

      // 患者経過総合ビューアの治療条件モーダル表示条件設定
      // #9840 MOD zhou.tao Start
      // #10150 piao start
      // this.setTreatDataUsable(ordNo);
      this.setTreatDataUsable(ordNo, treatDate);
      // #10150 piao end
      // #9840 MOD zhou.tao End

      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      //抗凝固剤ワンショット量 ind-treat-anti-coagulant-amount
      const antiCoagulantAmountDisable = this.treatCondDataList.find(
        ({ itemNo }) => itemNo === 26
      );

      // 抗凝固剤ワンショット量出来ないの場合
      // mod 【障害票一覧_患者経過総合ビューア.xlsx】No54(内結)対応 韓 start-->
      //if (antiCoagulantAmountDisable) {
      if (!antiCoagulantAmountDisable) {
      // mod 【障害票一覧_患者経過総合ビューア.xlsx】No54(内結)対応 韓 end-->
        this.setAntiCoagulantAmountDisable(true);
        this.setAntiCoagulantFlowRateDisable(true);
      }
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      // add 【障害票一覧_患者経過総合ビューア.xlsx】No54(内結)対応 韓 start-->
      const antiCoagulantFlowRateDisable = this.treatCondDataList.find(
        ({ itemNo }) => itemNo === 27
      );
      // 抗凝固剤持続速度が画面表示していない場合は計算ボタン非活性
      if (!antiCoagulantFlowRateDisable) {
        this.setAntiCoagulantFlowRateDisable(true);
      }
      // add 【障害票一覧_患者経過総合ビューア.xlsx】No54(内結)対応 韓 end-->
      // IndEditBaseにわたす情報
      const settingData = deepCopy(this.faultSettingIndConditionData);
      // ヘッダータイトルの設定
      settingData.headerTitle = MODAL_TITLE[headerTitle];
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // 治療日のフォーマット調整
      treatDate = moment(treatDate).format("YYYY-MM-DD");
      // 治療開始日
      settingData.startDate = treatDate;
      // 治療終了日
      settingData.endDate = ordNo ? treatDate : "";
      // オーダー番号の格納
      settingData.ordNo = ordNo;

      //add #10266 start
      settingData.update_flag = update_flag;
      //add #10266 end

      if (ordNo) {
        // 開始日操作不可
        settingData.startDateEdit = true;
        // 終了日操作不可
        settingData.endDateEdit = true;
        // 全曜日選択をfalse
        settingData.allWeek = false;
        // 選択された曜日以外をfalseへ変更
        for (let i = 0; i < 7; i++) {
          settingData[this.changeWeekStr(i)] =
            i !== moment(treatDate, "YYYYMMDD").day() ? false : true;
        }
      }
      // 子コンポーネント(IndActionChart)にわたす情報
      const settingChildData = new Object();
      // 表示するコンポーネントの格納
      settingChildData.componentNames = componentInfo.filter(({ cd }) =>
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
        // this.checkExistInLayout(cd)
        this.checkExistInLayout(cd) || [26, 27, 28].includes(cd)
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
      );
      // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
      let cdArr = componentInfo.map(item => this.checkExistInLayout(item.cd)?.itemNo).filter(item => item !== undefined);
      settingChildData.componentNames.forEach((item)=>{
        if ([26, 27, 28].includes(item.cd)) {
          item.isShow = cdArr.includes(item.cd) ? true : false;
        }
      });
      // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end

     // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
     // 初期値を反映するため、オーダー番号を格納する。
     settingData.ordNo = (this.ordMainData[moment(treatDate).format("YYYYMMDD")] && this.ordMainData[moment(treatDate).format("YYYYMMDD")].ordNo) ? this.ordMainData[moment(treatDate).format("YYYYMMDD")].ordNo : null;
     // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
     settingData.orderMainData = this.ordMainData[moment(treatDate).format("YYYYMMDD")];
     // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
     // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end
      // DW分岐
      if (componentInfo[0] && componentInfo[0].cd === -1) {
        // DW
        // モーダル表示
        this.showDwModal({
          dispComponentId: "ind-rst-dw",
          settingIndData: settingData,
          settingIndChildData: settingChildData
        });
      } else {
        // 指示
        // モーダル表示
        this.showIndModal({
          dispComponentId: "ind-action-chart",
          settingIndData: settingData,
          settingIndChildData: settingChildData
        });
      }
    },

    /**
     * モーダル物理情報を表示する
     * @param treatDate 治療日
     */
    async showPhysicalInfoModal(treatDate) {
      /* #10443 DEL Addition only allowed START */
      // const response = await ApiHelper.get(`/patInfo/getPatInfoById/${this.patId}`).catch(
      //   () => {
      //     throw new Error(
      //       "[PatInfoFunctions.js]getPatById(): APIエラー  404以外ならJavaのログ確認してください"
      //     );
      //   }
      // );
      // if (!response.data) {
      //
      // } else {
      //   const physical_info = JSON.parse(response.data[0].physical_info);
      //   //add #9929  DWの内外が一致しません ljg start
      //   const dwList =physical_info.filter(json => json.dw !== null
      //         && moment(json.exam_date).format("YYYYMMDD") <= moment(treatDate).format("YYYYMMDD")
      //         )
      //   if (dwList.length == 0) {
      //   //add #9929  DWの内外が一致しません ljg end
      //     const physicalInfoData = encodeEditableRecord({
      //     ctl_no: 0,
      //     exam_date: null,
      //     exam_day: moment(treatDate).format("YYYYMMDD"),
      //     exam_time: null,
      //     order_class: null,
      //     height: null,
      //     ctr_weight: null,
      //     breast_dia: null,
      //     chest_dia: null,
      //     ctr: null,
      //     dw: null,
      //     pre_scale_upper: null,
      //     pre_scale_lower: null,
      //     target_weight: null,
      //     indicator_cd: null,
      //     indicator_start_date: null,
      //     memo: null,
      //     facility_cd: null
      //     });
      //     this.setSelectedPhysicalInfoData({
      //       addEditC: "1",
      //       isLatestDW: false,
      //       physicalInfo: physicalInfoData,
      //       jsonArray: []
      //     });
      //   }
      //   else {
      //         const physicalInfo = _.max(dwList, el => {
      //         return this.formatterDay(el) + this.formatterTime(el);
      //         });
      //         let exam_time = null;
      //         if (physicalInfo.exam_date.length > 10) {
      //           exam_time = dateFormat.format(new Date(physicalInfo.exam_date), "hh:mm");
      //         }
      //         let target_weight = null;
      //         //mod bug 張　 start
      //         // if (physicalInfo.target_weight === null || physicalInfo.target_weight === undefined) {
      //         if (physicalInfo.target_weight != null || physicalInfo.target_weight != undefined) {
      //         //   target_weight = {
      //         //     initValue: null,
      //         //     editValue: null
      //         //   };
      //         // } else {
      //         //mod bug 張　 end
      //           target_weight = physicalInfo.target_weight;
      //         }
      //         const physicalInfoData = encodeEditableRecord({
      //         ctl_no: physicalInfo.ctl_no,
      //         exam_date: physicalInfo.exam_day,
      //         exam_day: dateFormat.format(new Date(physicalInfo.exam_date), "yyyyMMdd"),
      //         exam_time: exam_time,
      //         order_class: physicalInfo.order_class,
      //         height: physicalInfo.height,
      //         ctr_weight: physicalInfo.ctr_weight,
      //         breast_dia: physicalInfo.breast_dia,
      //         chest_dia: physicalInfo.chest_dia,
      //         ctr: physicalInfo.ctr,
      //         dw: physicalInfo.dw,
      //         pre_scale_upper: physicalInfo.pre_scale_upper,
      //         pre_scale_lower: physicalInfo.pre_scale_lower,
      //         target_weight: target_weight,
      //         indicator_cd: physicalInfo.indicator_cd,
      //         indicator_start_date: physicalInfo.indicator_start_date,
      //         memo: physicalInfo.memo,
      //         facility_cd: physicalInfo.facility_cd
      //       });
      //       this.setSelectedPhysicalInfoData({
      //         addEditC: "2",
      //         isLatestDW: false,
      //         physicalInfo: physicalInfoData,
      //         jsonArray: []
      //       });
      //   }
      //
      // }
      /* #10443 DEL Addition only allowed END*/

      const physicalInfoData = encodeEditableRecord({
        ctl_no: 0,
        exam_date: null,
        exam_day: moment(treatDate).format("YYYYMMDD"),
        exam_time: null,
        order_class: PAT_UNIQUE_COL_PHYSICAL_INFO_ORDER_CLASS[0].value,
        height: null,
        ctr_weight: null,
        breast_dia: null,
        chest_dia: null,
        ctr: null,
        dw: null,
        pre_scale_upper: null,
        pre_scale_lower: null,
        target_weight: null,
        indicator_cd: null,
        indicator_start_date: null,
        memo: null,
        facility_cd: null
      });
      this.setSelectedPhysicalInfoData({
        addEditC: "1",
        isLatestDW: false,
        physicalInfo: physicalInfoData,
        jsonArray: []
      });
      this.showPhysicalInfoAddEdit();
    },
    //add #9929  時間のフォーマットです ljg start
    /**
     * @description 日付フォーマット
     * @param {Object} json
     * @returns {String}
     */
     formatterDay(json) {
      return moment(json.exam_date, "YYYY-MM-DDTHH:mm:ss.SSSZ").format(
        "YYYYMMDD"
      );
    },
    /**
     * @description 時間フォーマット
     * @param {Object} json
     * @returns {String}
     */
     formatterTime(json) {
      return moment(json.exam_date, "YYYY-MM-DDTHH:mm:ss.SSSZ").format("HHmm");
    },
   //add #9929  時間のフォーマットです ljg end
    /**
     * 治療条件編集モーダルに渡すデフォルト値の設定
     * @param index クリックした行番号
     * @param targetDate 対象日付
     */
    setDefaultData(index, targetDate) {
      let treatCondData = [];
      if (index === -1) {
        // dw
        treatCondData.push(this.dwComponent);
        // 対象日付がなければ、デフォルトデータがnullのものを返す
        if (null === targetDate) {
          return treatCondData;
        }
        targetDate = moment(targetDate).format("YYYYMMDD");

        treatCondData[0].fields = this.ordMainData[targetDate].indDw;

      } else {
        // componentNamesからgroupCdが一致するものを抽出する
        treatCondData = deepCopy(this.componentNames).filter(item => {
          return item.groupCd === this.getTreatCondGroup(index);
        });
        // 対象日付がなければ、デフォルトデータがnullのものを返す
        if (null === targetDate) {
          return treatCondData;
        }

        targetDate = moment(targetDate).format("YYYYMMDD");

        // ストアに格納されている治療情報から「治療条件」カラムのデータを取得
        const dataObject = (this.ordMainData[targetDate] && this.ordMainData[targetDate].indCondInfo) ? JSON.parse(this.ordMainData[targetDate].indCondInfo) : null;

        // mod FNSI-小数点の修正 楊 start
        // 治療状況
        const rstDialysisState = (this.ordMainData[targetDate] && this.ordMainData[targetDate].rstDialysisState) ? this.ordMainData[targetDate].rstDialysisState : null;
        // mod FNSI-小数点の修正 楊 end

        // 取得したcomponentNamesのfieldsにデフォルト値を格納していく
        for (const index in treatCondData) {
          // 「治療条件」カラムデータのデフォルト値を設定する項目コードを取得
          const cd = treatCondData[index].cd;
          // 対象項目のデータをデフォルト値として設定
          const value = _.propertyOf(dataObject)([cd, "value"]);
          const medicine_type = _.propertyOf(dataObject)([cd.toString(), "medicine_type"]);

          // mod FNSI-小数点の修正 楊 start
          // const initValue = value && Number(value);
          /* modify by chamaojia 2023-04-23 [8204] 変数タイプ定義エラー修正 --start */
          // const initValue = value;
          let initValue = value;
          /* modify by chamaojia 2023-04-23 [8204] 変数タイプ定義エラー修正 --end */
          // mod FNSI-小数点の修正 楊 end
          const initMdicineType = (null !== medicine_type && undefined != medicine_type) ? Number(medicine_type) : null;
            // (null !== medicine_type && undefined != medicine_type) ? String(medicine_type) : null;
          // mod FNSI-小数点の修正 楊 start
          // treatCondData[index].fields = {
          //   value: initValue,
          //   medicineType: initMdicineType
          // };
          //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add zhou start
          // del #10196 数値IFのスタイル全不正 linjunfeng start
          // if (cd === 17 && value != null) {
          //   initValue = parseFloat(value);
          // }
          // del #10196 数値IFのスタイル全不正 linjunfeng end
          //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add zhou end
          if (cd === 17 || cd === 22 || cd === 26 ||cd === 27 || cd === 28 ) {
            treatCondData[index].fields = {
              rstDialysisState: rstDialysisState,
              value: initValue,
              velue: initValue,
              medicineType: initMdicineType,
              //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
              isIndication: true
              //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
            };
          } else {
            treatCondData[index].fields = {
              value: initValue,
              velue: initValue,
              medicineType: initMdicineType,
              //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
              isIndication: true
              //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
            };
          }
          // mod FNSI-小数点の修正 楊 end
          // add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.42(外結)対応 韓 start
          if (cd === 39) {
            let dw = (this.ordMainData[targetDate] && this.ordMainData[targetDate].indDw) ? this.ordMainData[targetDate].indDw : null;
            if (dw === null || dw === undefined) {
              // indDwが取得できないならば身体情報から治療日最直近のDWを取得
              const tDate = moment(targetDate, "YYYYMMDD").add(1, "day");
              for (const physicalInfo of this.getPhysicalInfo) {
                if (
                  physicalInfo &&
                  physicalInfo.exam_date &&
                  moment(physicalInfo.exam_date) < tDate
                ) {
                  // 治療日より未来の登録日を除外する
                  if (
                    physicalInfo.dw !== undefined &&
                    physicalInfo.dw !== null
                  ) {
                    dw = physicalInfo.dw;
                    break;
                  }
                }
              }
            }
            treatCondData[index].fields.value = dw;
          }
          //add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.42(外結)対応 韓 end
        }
      }
      return treatCondData;
    },

    /**
     * グループコード取得
     * @summary クリックした行番号からグループ分けする
     * @param index クリックした治療条件項目番号
     */
    getTreatCondGroup(index) {
      let groupCd = 0;
      switch (index) {
        case 1:
          /**
           * 1->治療時間
           */
          groupCd = 0;
          break;

        case 2:
          /**
           * 2->VA
           */
          groupCd = 1;
          break;

        case 3:
        case 4:
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
        case 39:
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
          /**
           * 3->目標体重、4->除水量制限、39->DW
           */
          groupCd = 2;
          break;

        case 5:
        case 6:
          /**
           * 5->ダイアライザ、6->吸着カラム
           */
          groupCd = 3;
          break;

        case 7:
        case 8:
          /**
           * 7->1次膜、8->2次膜
           */
          groupCd = 4;
          break;

        case 9:
        case 10:
        case 11:
        case 12:
          /**
           * 9->穿刺針(A針)、10->穿刺針(V針)、11->穿刺針(SN)、12->シングルニードル使用
           */
          groupCd = 5;
          break;

        case 13:
          /**
           * 13->血液回路
           */
          groupCd = 6;
          break;

        case 14:
          /**
           * 14->血流量
           */
          groupCd = 7;
          break;

        case 15:
        case 16:
        case 17:
        case 18:
          /**
           *  15->透析液、16->透析液流量、17->透析液使用数、18->透析液温度
           */
          groupCd = 8;
          break;
        case 19:
        case 20:
        case 21:
        case 22:
        case 23:
        case 24:
          /**
           * 19->補液、20->補液量、21->補液選択、22->補液使用数、
           * 23->補液温度、24->補液速度
           */
          groupCd = 9;
          break;

        case 25:
        case 26:
        case 27:
        case 28:
        case 29:
        case 30:
        case 31:
        case 32:
        case 33:
        case 34:
        case 35:
        case 36:
        case 37:
        case 38:
          /**
           * 25->抗凝固剤、26->抗凝固剤ワンショット量、27->抗凝固剤時速速度
           * 28->抗凝固剤持続総量、29->IP使用選択、30->IPスタート
           * 31->IPワンショット量、32->IP速度、33->IP速度最大値
           * 34->IPワンショットスタート、35->IP電源自動切、36->IP電源自動切時間
           * 37->IP電源OKモニタ切、38->IP電源OKモニタ切時間
           */
          groupCd = 10;
          break;

        case -1:
          groupCd = -1;
          break;
        default:
          break;
      }
      return groupCd;
    },

    /**
     * 編集モーダルヘッダータイトル取得
     * @param cd グループコード
     */
    getHeaderTitle(cd) {
      switch (cd) {
        case 0:
          return "治療時間編集";
        case 1:
          return "VA編集";
        case 2:
          // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 start
          // return "目標体重/除水量制限編集";
          return "DW/目標体重/除水量制限編集";
          // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 end
        case 3:
          return "ダイアライザ/吸着カラム編集";
        case 4:
          return "1次膜/2次膜編集";
        case 5:
          return "穿刺針情報編集";
        case 6:
          return "血液回路編集";
        case 7:
          return "血流量編集";
        case 8:
          return "透析液情報編集";
        case 9:
          return "補液情報編集";
        case 10:
          return "抗凝固剤情報編集";
        case -1:
          return "DW編集";
        default:
          break;
      }
    },

    /**
     * 「目標体重」行にDWの最新情報を表示する
     */
    createTargetWeightDWInfo() {
      const targetWeight = this.treatCondDataList.find(
        ({ itemNo }) => itemNo === 3
      );

      // 「目標体重」行にDWの最新情報を表示する
      if (targetWeight) {
        targetWeight.itemName = "目標体重";
      }
    },

    /**
     * @description 患者経過総合ビューアの一覧画面で選択中レイアウトに治療条件の存在をチェック
     * @param {Number} treatCondNo 治療条件キー
     */
    checkExistInLayout(treatCondNo) {
      const treatContents = this.getSelectedLayout.find(
        ({ component }) => component === "treatment-contents"
      );
      const treatCond =
        treatContents &&
        treatContents.categoryItem.find(
          ({ component }) => component === "treat-cond"
        );
      // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
      const cd = treatCondNo === 39 ? -1 : treatCondNo;
      // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
      const isTreatExists =
        treatCond &&
        // treatCond.subCategoryItem.find(({ itemNo }) => itemNo === cd);
        treatCond.subCategoryItem.find(({ itemNo }) => itemNo == cd);

      return isTreatExists;
    },

    //add FNSI-No.IES145 権限対応  吉 start
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    //add FNSI-No.IES145 権限対応  吉 end

    /* Add by Zhou.tao #9840 since 2023-10-26 Start */
    /**
     * @description 患者経過総合ビューアの治療条件モーダル表示条件設定
     * @param {Number} ordNo オーダー番号
     * @author Tao.zhou
     */
    // #10150 piao start
    // setTreatDataUsable(ordNo) {
    setTreatDataUsable(ordNo, treatDate) {
    // #10150 piao end
      // 治療情報集合の一時変数
      let ordInfoArr = [];

      // 単一治療情報抽出
      if (ordNo) {
        for (const ordInfoKey in this.ordMainData) {
          if (this.ordMainData[ordInfoKey]) {
            if (ordNo === this.ordMainData[ordInfoKey].ordNo) {
              ordInfoArr.push(this.ordMainData[ordInfoKey])
              break;
            }
          }
        }
      } else {
        // #10150 piao start
        // ordInfoArr = this.ordMainData;
        if (this.ordMainData) {
          for (let key in this.ordMainData) {
            if(key >= treatDate){
              ordInfoArr[key] = this.ordMainData[key];
            }
          }
        }
        // #10150 piao end
      }

      // 使用フラグ設定
      let isNoUseVA = false, isUseFlagDialyzer = false, isUseFlagColumn = false, isUseFlagFirstPass = false, isUseFlagSecondPass = false
        , isUseFlagTube = false, isUseFlagBloodFlow = false, isUseFlagWeight = false, isUseFlagFilterLimit = false, isUseFlagNeedleSelection = false
        // , isUseFlagNeedleA = false, isUseFlagNeedleV = false, isUseFlagNeedleNeedleSN = false
        , isUseFlagDialyses = false, isUseFlagDialysesFlowRate = false
        , isUseFlagDialysesAmount = false, isUseFlagDialysesTemperature = false, isUseFlagIv = false, isUseFlagIvAmount = false, isUseFlagIvSelection = false
        , isUseFlagIvCount = false, isUseFlagIvTemperature = false, isUseFlagIvFlowRate = false, isUseFlagAntiCoaguLant = false, isUseFlagAntiCoagulantOneshotAmount = false
        , isUseFlagAntiCoagulantFlowRate = false, isUseFlagAntiCoagulantAmountTotal = false, isUseFlagIpSelection = false, isUseFlagIpStart = false, isUseFlagIpOneshotAmount = false
        , isUseFlagIpFlowRate = false, isUseFlagIpFlowRateLimit = false, isUseFlagIpOneshotSelection = false, isUseFlagIpAutoOff = false, isUseFlagIpAutoOffTiming = false
        , isUseFlagIpMonitorOff = false, isUseFlagIpMonitorOffTiming = false;

      if (ordInfoArr) {
        // add 10150 piao start
        let count = 1;
        let flgHasIv = false;
        // add 10150 piao end
        for (let treatDate in ordInfoArr) {

          if (ordInfoArr[treatDate] && ordInfoArr[treatDate].indCondInfo) {

            let tempOrdIndInfo = JSON.parse(ordInfoArr[treatDate].indCondInfo);
            // add 10150 piao start
            if(count == 1){
              flgHasIv = tempOrdIndInfo.hasOwnProperty(IND_COND_ID.REPLENISHER);
              count = count + 1;
            }
            // add 10150 piao end
            isNoUseVA = isNoUseVA || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.VA);
            isUseFlagDialyzer = isUseFlagDialyzer || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.DIALYZER);
            isUseFlagColumn = isUseFlagColumn || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.ADSORPTIONCOLUMN);
            isUseFlagFirstPass = isUseFlagFirstPass || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.FILM1);
            isUseFlagSecondPass = isUseFlagSecondPass || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.FILM2);
            isUseFlagTube = isUseFlagTube || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.BLOODCIRCUIT);
            isUseFlagBloodFlow = isUseFlagBloodFlow || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.BLOODFLOW);
            isUseFlagWeight = isUseFlagWeight || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.WEIGHT);
            isUseFlagFilterLimit = isUseFlagFilterLimit || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.OFFWATER);
            isUseFlagNeedleSelection = isUseFlagNeedleSelection || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.SINGLENEEDLE);
            // isUseFlagNeedleA = isUseFlagNeedleA || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.NEEDLE_A);
            // isUseFlagNeedleV = isUseFlagNeedleV || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.NEEDLE_V);
            // isUseFlagNeedleNeedleSN = isUseFlagNeedleNeedleSN || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.NEEDLE_SN);
            isUseFlagDialyses = isUseFlagDialyses || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.DIALYSISFLUID);
            isUseFlagDialysesFlowRate = isUseFlagDialysesFlowRate || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.DIALYSISFLUID_FLOW);
            isUseFlagDialysesAmount = isUseFlagDialysesAmount || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.DIALYSISFLUID_AMOUNT);
            isUseFlagDialysesTemperature = isUseFlagDialysesTemperature
              || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.DIALYSISFLUID_TEMPERATURE);
            // add 10150 piao start
            if(flgHasIv){
              isUseFlagIv = isUseFlagIv || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.REPLENISHER);
              isUseFlagIvAmount = isUseFlagIvAmount || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.REPLENISHER_AMOUNT);
              isUseFlagIvSelection = isUseFlagIvSelection || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.REPLENISHER_SELECT);
              isUseFlagIvCount = isUseFlagIvCount || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.REPLENISHER_NUM);
              isUseFlagIvTemperature = isUseFlagIvTemperature || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.REPLENISHER_TEMPERATURE);
              isUseFlagIvFlowRate = isUseFlagIvFlowRate || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.REPLENISHER_SPEED);
            }
            // add 10150 piao end
            isUseFlagAntiCoaguLant = isUseFlagAntiCoaguLant || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.ANTICOAGULANT);
            isUseFlagAntiCoagulantOneshotAmount = isUseFlagAntiCoagulantOneshotAmount
              || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.ANTICOAGULANT_ONESHOT);
            isUseFlagAntiCoagulantFlowRate = isUseFlagAntiCoagulantFlowRate
              || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.ANTICOAGULANT_SPEED);
            isUseFlagAntiCoagulantAmountTotal = isUseFlagAntiCoagulantAmountTotal
              || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.ANTICOAGULANT_AMOUNT);
            isUseFlagIpSelection = isUseFlagIpSelection || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.IP_USE);
            isUseFlagIpStart = isUseFlagIpStart || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.IP_START);
            isUseFlagIpOneshotAmount = isUseFlagIpOneshotAmount || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.IP_ONESHOT);
            isUseFlagIpFlowRate = isUseFlagIpFlowRate || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.IP_SPEED);
            isUseFlagIpFlowRateLimit = isUseFlagIpFlowRateLimit || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.IP_SPEED_MAX);
            isUseFlagIpOneshotSelection = isUseFlagIpOneshotSelection || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.AUTOONESHOT);
            isUseFlagIpAutoOff = isUseFlagIpAutoOff || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.IP_AUTOOFF);
            isUseFlagIpAutoOffTiming = isUseFlagIpAutoOffTiming || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.IP_AUTOOFF_TIME);
            isUseFlagIpMonitorOff = isUseFlagIpMonitorOff || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.IP_MONITOROFF);
            isUseFlagIpMonitorOffTiming = isUseFlagIpMonitorOffTiming || tempOrdIndInfo.hasOwnProperty(IND_COND_ID.IP_MONITOROFF_TIME);
          }
        }
      }

      /* 使用フラグを設定 */
      this.setIsUseFlagVA(!isNoUseVA); //VA使用フラグを設定
      this.setIsUseFlagDialyzer(!isUseFlagDialyzer);//ダイアライザ使用フラグを設定
      this.setIsUseFlagColumn(!isUseFlagColumn);//吸着カラム使用フラグを設定
      this.setIsUseFlagFirstPass(!isUseFlagFirstPass); //1次膜使用フラグを設定
      this.setIsUseFlagSecondPass(!isUseFlagSecondPass);//2次膜使用フラグを設定
      this.setIsUseFlagTube(!isUseFlagTube); //血液回路使用フラグを設定
      this.setIsUseFlagBloodFlow(!isUseFlagBloodFlow);//血流量使用フラグを設定
      this.setIsUseFlagWeight(!isUseFlagWeight);//体重使用フラグを設定
      this.setIsUseFlagFilterLimit(!isUseFlagFilterLimit) //除水量制限使用フラグを設定
      this.setIsUseFlagNeedleSelection(!isUseFlagNeedleSelection) //シングルニードル使用フラグを設定
      // this.setIsUseFlagNeedleA(!isUseFlagNeedleA) //穿刺針(A)使用フラグを設定
      // this.setIsUseFlagNeedleV(!isUseFlagNeedleV) //穿刺針(V)使用フラグを設定
      // this.setIsUseFlagNeedleNeedleSN(!isUseFlagNeedleNeedleSN) //穿刺針(SN)使用フラグを設定
      this.setIsUseFlagDialysate(!isUseFlagDialyses) //透析液使用フラグを設定
      this.setIsUseFlagDialysateFlowRate(!isUseFlagDialysesFlowRate) //透析液流量使用フラグを設定
      this.setIsUseFlagDialysateAmount(!isUseFlagDialysesAmount) //透析液使用数使用フラグを設定
      this.setIsUseFlagDialysateTemperature(!isUseFlagDialysesTemperature) //透析液温度使用フラグを設定
      this.setIsUseFlagIv(!isUseFlagIv) //補液使用フラグを設定
      this.setIsUseFlagIvAmount(!isUseFlagIvAmount) //補液量使用フラグを設定
      this.setIsUseFlagIvSelection(!isUseFlagIvSelection) //補液選択使用フラグを設定
      this.setIsUseFlagIvCount(!isUseFlagIvCount) //補液使用数使用フラグを設定
      this.setIsUseFlagIvTemperature(!isUseFlagIvTemperature) //補液温度使用フラグを設定
      this.setIsUseFlagIvFlowRate(!isUseFlagIvFlowRate) //補液速度使用フラグを設定
      this.setIsUseFlagAntiCoaguLant(!isUseFlagAntiCoaguLant) //抗凝固剤使用フラグを設定
      this.setIsUseFlagAntiCoagulantOneshotAmount(!isUseFlagAntiCoagulantOneshotAmount) //抗凝固剤ワンショット量使用フラグを設定
      this.setIsUseFlagAntiCoagulantFlowRate(!isUseFlagAntiCoagulantFlowRate) //抗凝固剤持続速度使用フラグを設定
      this.setIsUseFlagAntiCoagulantAmountTotal(!isUseFlagAntiCoagulantAmountTotal) //抗凝固剤持続総量使用フラグを設定
      this.setIsUseFlagIpSelection(!isUseFlagIpSelection) //IP使用選択使用フラグを設定
      this.setIsUseFlagIpStart(!isUseFlagIpStart) //IPスタート使用フラグを設定
      this.setIsUseFlagIpOneshotAmount(!isUseFlagIpOneshotAmount) //IPワンショット量使用フラグを設定
      this.setIsUseFlagIpFlowRate(!isUseFlagIpFlowRate) //IP速度使用フラグを設定
      this.setIsUseFlagIpFlowRateLimit(!isUseFlagIpFlowRateLimit) //IP速度最大値使用フラグを設定
      this.setIsUseFlagIpOneshotSelection(!isUseFlagIpOneshotSelection) //IPワンショットスタート使用フラグを設定
      this.setIsUseFlagIpAutoOff(!isUseFlagIpAutoOff) //IP電源自動切り使用フラグを設定
      this.setIsUseFlagIpAutoOffTiming(!isUseFlagIpAutoOffTiming) //IP電源自動切り時間使用フラグを設定
      this.setIsUseFlagIpMonitorOff(!isUseFlagIpMonitorOff) //IP電源OKモニタ切り使用フラグを設定
      this.setIsUseFlagIpMonitorOffTiming(!isUseFlagIpMonitorOffTiming) //IP電源OKモニタ切り時間使用フラグを設定
    },
    /* Add by Zhou.tao #9840 since 2023-10-26 End */
  }
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../../css/style.scss";
</style>
