/** * アクションチャート */

<template>
  <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start -->
  <!-- <div class="column-style"> -->
  <div class="column-style" v-if="compReset == true">
  <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end -->
    <v-ons-row v-for="(component, index) in componentData" :key="index">
      <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start -->
      <!--<div
        :is="component.name"
        :key="index"
        :ref="index"
        :value="component.fields.value"
        :medicine-type="component.fields.medicineType"
        @input="e => (component.fields.value = e)"
      />-->
      <!-- //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start -->
      <!-- <div
        :is="component.name"
        :key="index"
        :ref="index"
        :value="component.fields.value"
        :velue="component.fields.velue"
        :medicine-type="component.fields.medicineType"
        @input="e => (component.fields.value = e)"
      /> -->
      <!-- #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start -->
      <!-- <div
        :is="component.name"
        :key="index"
        :ref="index"
        :value="component.fields.value"
        :velue="component.fields.velue"
        :medicine-type="component.fields.medicineType"
        :is-indication="component.fields.isIndication"
        @input="e => (component.fields.value = e)"
      />-->
      <div
        :is="component.name"
        :key="index"
        :ref="index"
        :value="component.fields.value"
        :velue="component.fields.velue"
        :medicine-type="component.fields.medicineType"
        :is-indication="component.fields.isIndication"
        @input="e => (component.fields.value = e)"
        v-show="component.isShow !== false"
      />
      <!-- #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end -->
      <!-- //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end -->
      <!-- mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end -->
      <!-- IndTreatCondBase.vueのイベント発火引数を設定 -->
    </v-ons-row>
  </div>
</template>

<script>
import _ from "underscore";
import { ApiHelper } from "@/apis/AxiosHelper";
// mod FNSI-【1006】最新の改修対象一覧の483対応 韓 start
//import { mapGetters } from "vuex";
//mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
//import { mapGetters, mapMutations } from "vuex";
import { mapGetters, mapMutations, mapActions } from "vuex";
//mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
// mod FNSI-【1006】最新の改修対象一覧の483対応 韓 end
import { EventBus } from "@/eventBus.js";
import { dateFormat, fitTermCheckForUpdate } from "@/functions/common/DateTimeUtils";
import IndTreatCondTime from "@/components/indication/IndTreatCondEditTime";
import IndTreatCondVa from "@/components/indication/IndTreatCondVa";
// add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
import IndTreatCondDW from "@/components/indication/IndTreatCondDW";
// add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
import IndTreatCondTargetWeight from "@/components/indication/IndTreatCondTargetWeight";
import IndTreatCondFilterLimit from "@/components/indication/IndTreatCondFilterLimit";
import IndTreatCondDialyzer from "@/components/indication/IndTreatCondDialyzer";
import IndTreatCondSeparatoryColumn from "@/components/indication/IndTreatCondSeparatoryColumn";
import IndTreatCondFirstPass from "@/components/indication/IndTreatCondFirstPass";
import IndTreatCondSecondPass from "@/components/indication/IndTreatCondSecondPass";
import IndTreatCondNeedleSelection from "@/components/indication/IndTreatCondNeedleSelection";
import IndTreatCondNeedleA from "@/components/indication/IndTreatCondNeedleA";
import IndTreatCondNeedleV from "@/components/indication/IndTreatCondNeedleV";
import IndTreatCondNeedleSN from "@/components/indication/IndTreatCondNeedleSN";
import IndTreatCondTube from "@/components/indication/IndTreatCondTube";
import IndTreatCondBloodFlowRate from "@/components/indication/IndTreatCondBloodFlowRate";
import IndTreatCondDialysate from "@/components/indication/IndTreatCondDialysate";
import IndTreatCondDialysateAmount from "@/components/indication/IndTreatCondDialysateAmount";
import IndTreatCondDialysateFlowRate from "@/components/indication/IndTreatCondDialysateFlowRate";
import IndTreatCondDialysateTemperature from "@/components/indication/IndTreatCondDialysateTemperature";
import IndTreatCondIv from "@/components/indication/IndTreatCondIv";
import IndTreatCondIvAmount from "@/components/indication/IndTreatCondIvAmount";
import IndTreatCondIvSelection from "@/components/indication/IndTreatCondIvSelection";
import IndTreatCondIvCount from "@/components/indication/IndTreatCondIvCount";
import IndTreatCondIvTemperature from "@/components/indication/IndTreatCondIvTemperature";
import IndTreatCondIvFlowRate from "@/components/indication/IndTreatCondIvFlowRate";
import IndTreatCondAntiCoagulant from "@/components/indication/IndTreatCondAntiCoagulant";
import IndTreatCondAntiCoagulantOneshotAmount from "@/components/indication/IndTreatCondAntiCoagulantOneshotAmount";
import IndTreatCondAntiCoagulantFlowRate from "@/components/indication/IndTreatCondAntiCoagulantFlowRate";
import IndTreatCondAntiCoagulantAmountTotal from "@/components/indication/IndTreatCondAntiCoagulantAmountTotal";
import IndTreatCondIpSelection from "@/components/indication/IndTreatCondIpSelection";
import IndTreatCondIpStart from "@/components/indication/IndTreatCondIpStart";
import IndTreatCondIpOneshotAmount from "@/components/indication/IndTreatCondIpOneshotAmount";
import IndTreatCondIpFlowRate from "@/components/indication/IndTreatCondIpFlowRate";
import IndTreatCondIpFlowRateLimit from "@/components/indication/IndTreatCondIpFlowRateLimit";
import IndTreatCondIpOneshotSelection from "@/components/indication/IndTreatCondIpOneshotSelection";
import IndTreatCondIpAutoOff from "@/components/indication/IndTreatCondIpAutoOff";
import IndTreatCondIpAutoOffTiming from "@/components/indication/IndTreatCondIpAutoOffTiming";
import IndTreatCondIpMonitorOff from "@/components/indication/IndTreatCondIpMonitorOff";
import IndTreatCondIpMonitorOffTiming from "@/components/indication/IndTreatCondIpMonitorOffTiming";
// add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import { REPLENISHER_QDQS_SETTING } from "@/constants/facilitySetting";
// mod FNSI-【1006】最新の改修対象一覧の412対応 韓 start
// import { getDeviceSetInfoPat } from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions.js";
import { getDeviceSetInfoPat,getDeviceSetInfoOrd } from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions.js";
// mod FNSI-【1006】最新の改修対象一覧の412対応 韓 end
import { valueInfoOpe } from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
// add FNSI-【1006】最新の改修対象一覧の483対応 韓 end
// add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
import { LIQUID_AMOUNT_TEXT,LIQUID_SPEED_TEXT } from "@/constants/PatViewerConstants.js";
// add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
// add FNSI-外部連携APIの修正 徐 start
import moment from "moment";
// add FNSI-外部連携APIの修正 徐 end
// add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
//del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
// import { deepCopy } from "@/functions/common/CommonFunctions";
//del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
// add FNSI-【1006】最新の改修対象一覧の679対応 韓 end
// add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
//add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
import { DEVICEMODE } from "@/constants/mstTreatmentDefine.js";
//add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
//mod FNSI redmine 5161劉祥霖 start
import { deepCopy } from "@/functions/common/CommonFunctions";
import { KEY_NAME_PAT_VIEWER } from "@/constants/defaultSettingConstants";
//mod FNSI redmine 5161劉祥霖 end
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end
// #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
import {ANTICOAGULANT_AUTO_SETTING, ANTICOAGULANT_DEFAULT_SETTING} from "@/constants/facilitySetting";
// #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
// del #11004 連携イベント発生部分不正 piao start
// import { sendRequestGetCoopIniSchModifySendClass } from "@/apis/treatment-record";
// del #11004 連携イベント発生部分不正 piao end
//add #10150 piao start
import {CODES} from "@/constants/TreatmentRecord";
import {accSub} from "../../functions/common/NumberFunctions";
//add #10150 piao end
import { normalizeValue } from "@/functions/common/CommonFunctions";

export default {
  // TODO: vue/no-unused-components
  /* eslint-disable */
  components: {
    "ind-treat-time": IndTreatCondTime,
    "ind-treat-va": IndTreatCondVa,
    // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
    "ind-treat-dw": IndTreatCondDW,
    // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
    "ind-treat-target-weight": IndTreatCondTargetWeight,
    "ind-treat-filter-limit": IndTreatCondFilterLimit,
    "ind-treat-dialyzer": IndTreatCondDialyzer,
    "ind-treat-separatory-column": IndTreatCondSeparatoryColumn,
    "ind-treat-first-pass": IndTreatCondFirstPass,
    "ind-treat-second-pass": IndTreatCondSecondPass,
    "ind-treat-needle-selection": IndTreatCondNeedleSelection,
    "ind-treat-needle-a": IndTreatCondNeedleA,
    "ind-treat-needle-v": IndTreatCondNeedleV,
    "ind-treat-needle-sn": IndTreatCondNeedleSN,
    "ind-treat-tube": IndTreatCondTube,
    "ind-treat-blood-flow": IndTreatCondBloodFlowRate,
    "ind-treat-dialysate": IndTreatCondDialysate,
    "ind-treat-dialysate-amount": IndTreatCondDialysateAmount,
    "ind-treat-dialysate-flow-rate": IndTreatCondDialysateFlowRate,
    "ind-treat-dialysate-temperature": IndTreatCondDialysateTemperature,
    "ind-treat-iv": IndTreatCondIv,
    "ind-treat-iv-amount": IndTreatCondIvAmount,
    "ind-treat-iv-selection": IndTreatCondIvSelection,
    "ind-treat-iv-count": IndTreatCondIvCount,
    "ind-treat-iv-temperature": IndTreatCondIvTemperature,
    "ind-treat-iv-flow-rate": IndTreatCondIvFlowRate,
    "ind-treat-anti-coagulant": IndTreatCondAntiCoagulant,
    "ind-treat-anti-coagulant-amount": IndTreatCondAntiCoagulantOneshotAmount,
    "ind-treat-anti-coagulant-flow-rate": IndTreatCondAntiCoagulantFlowRate,
    "ind-treat-anti-coagulant-amount-total": IndTreatCondAntiCoagulantAmountTotal,
    "ind-treat-ip-selection": IndTreatCondIpSelection,
    "ind-treat-ip-start": IndTreatCondIpStart,
    "ind-treat-ip-amount": IndTreatCondIpOneshotAmount,
    "ind-treat-ip-flow-rate": IndTreatCondIpFlowRate,
    "ind-treat-ip-flow-rate-limit": IndTreatCondIpFlowRateLimit,
    "ind-treat-ip-oneshot-selection": IndTreatCondIpOneshotSelection,
    "ind-treat-ip-auto-off": IndTreatCondIpAutoOff,
    "ind-treat-ip-auto-off-timing": IndTreatCondIpAutoOffTiming,
    "ind-treat-ip-monitor-off": IndTreatCondIpMonitorOff,
    "ind-treat-ip-monitor-off-timing": IndTreatCondIpMonitorOffTiming
  },
  /* eslint-enable */
  //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
  /**
  props: {
    componentNames: {
      type: Array,
      default: () => [
        {
          name: "ind-treat-time",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-va",
          fields: {
            value: null,
            medicineType: null
          }
        },
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
        {
          name: "ind-treat-dw",
          fields: {
            value: null,
            medicineType: null
          }
        },
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
        {
          name: "ind-treat-target-weight",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-filter-limit",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-dialyzer",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-separatory-column",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-first-pass",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-second-pass",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-needle-selection",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-needle-a",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-needle-v",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-needle-sn",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-tube",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-blood-flow",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-dialysate",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-dialysate-amount",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-dialysate-flow-rate",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-dialysate-temperature",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-iv",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-iv-amount",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-iv-selection",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-iv-count",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-iv-temperature",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-iv-flow-rate",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-anti-coagulant",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-anti-coagulant-amount",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-anti-coagulant-flow-rate",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-anti-coagulant-amount-total",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-selection",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-start",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-amount",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-flow-rate",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-flow-rate-limit",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-oneshot-selection",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-auto-off",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-auto-off-timing",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-monitor-off",
          fields: {
            value: null,
            medicineType: null
          }
        },
        {
          name: "ind-treat-ip-monitor-off-timing",
          fields: {
            value: null,
            medicineType: null
          }
        }
      ]
    }
  },
  */
  props: {
    componentNames: {
      type: Array,
      default: () => [
        {
          name: "ind-treat-time",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 0,
          cd: 1
        },
        {
          name: "ind-treat-va",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 1,
          cd: 2
        },
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 start
        {
          name: "ind-treat-dw",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 2,
          cd: 39
        },
        // add FNSI-【1006】最新の改修対象一覧の411対応 韓 end
        {
          name: "ind-treat-target-weight",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 2,
          cd: 3
        },
        {
          name: "ind-treat-filter-limit",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 2,
          cd: 4
        },
        {
          name: "ind-treat-dialyzer",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 3,
          cd: 5
        },
        {
          name: "ind-treat-separatory-column",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 3,
          cd: 6
        },
        {
          name: "ind-treat-first-pass",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 4,
          cd: 7
        },
        {
          name: "ind-treat-second-pass",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 4,
          cd: 8
        },
        {
          name: "ind-treat-needle-selection",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 5,
          cd: 12
        },
        {
          name: "ind-treat-needle-a",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 5,
          cd: 9
        },
        {
          name: "ind-treat-needle-v",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 5,
          cd: 10
        },
        {
          name: "ind-treat-needle-sn",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 5,
          cd: 11
        },
        {
          name: "ind-treat-tube",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 6,
          cd: 13
        },
        {
          name: "ind-treat-blood-flow",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 7,
          cd: 14
        },
        {
          name: "ind-treat-dialysate",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 8,
          cd: 15
        },
        {
          name: "ind-treat-dialysate-amount",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 8,
          cd: 17
        },
        {
          name: "ind-treat-dialysate-flow-rate",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 8,
          cd: 16
        },
        {
          name: "ind-treat-dialysate-temperature",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 8,
          cd: 18
        },
        {
          name: "ind-treat-iv",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 19
        },
        {
          name: "ind-treat-iv-amount",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 20
        },
        {
          name: "ind-treat-iv-selection",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 21
        },
        {
          name: "ind-treat-iv-count",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 22
        },
        {
          name: "ind-treat-iv-temperature",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 23
        },
        {
          name: "ind-treat-iv-flow-rate",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 9,
          cd: 24
        },
        {
          name: "ind-treat-anti-coagulant",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 25
        },
        {
          name: "ind-treat-anti-coagulant-amount",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 26
        },
        {
          name: "ind-treat-anti-coagulant-flow-rate",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 27
        },
        {
          name: "ind-treat-anti-coagulant-amount-total",
          fields: {
            // mod FNSI-小数点の修正 楊 start
            rstDialysisState: null,
            // mod FNSI-小数点の修正 楊 end
            value: null,
            velue: null,
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
            velue: null,
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
            velue: null,
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
            velue: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 32
        },
        // IP速度最大値
        {
          name: "ind-treat-ip-flow-rate-limit",
          fields: {
            value: null,
            velue: null,
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
            velue: null,
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
            velue: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 31
        },
        {
          name: "ind-treat-ip-auto-off",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 35
        },
        {
          name: "ind-treat-ip-auto-off-timing",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 36
        },
        {
          name: "ind-treat-ip-monitor-off",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 37
        },
        {
          name: "ind-treat-ip-monitor-off-timing",
          fields: {
            value: null,
            velue: null,
            medicineType: null
          },
          groupCd: 10,
          cd: 38
        }
      ]
    }
  },
//mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
  data() {
    return {
      //add #10150 piao start
      newIndTreatCondIvMode: null,
      oldIndTreatCondIvMode: null,
      //add #10150 piao end
      // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
      itemDisplayFlg: false,
      answerFlg: "",
      accountItemCd: 0,
      itemStructData: null,
      // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
      componentData: this.componentNames,
	  oldcomponentData: [],
      oldOrdMainList: [],
      // del #11004 連携イベント発生部分不正 piao start
      // objModSendClass: "",
      // valModSendClass: 0,
      // del #11004 連携イベント発生部分不正 piao end
      //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
      compReset : true,
      //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
      //add FNSI redmine 5161 劉祥霖 start
      //抗凝固剤持続総量表示非表示
      asTotalAmountIsShow:true,
      //IPワンショット量表示非表示
      IPOneShotAmountIsShow:true,
      //IP速度表示非表示
      IPSpeedIsShow:true,
      //抗凝固剤持続総量非表示する場合を変更判定あるフラッグ
      asTotalAmountChange:false,
      //IPワンショット量非表示する場合を変更判定あるフラッグ
      IPOneShotAmountChange:false,
      //IP速度非表示する場合を変更判定あるフラッグ
      IPSpeedChange:false,
      //選択されたレイアウト
      selectedLayout:null,
      //add FNSI redmine 5161 劉祥霖 end
      //mod #10150 piao start
      // //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start
      // treatmentConditionSettingSource:[],
      // //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
      isUsedCtlNos:[],
      ivOnlineDeviceModeList: [CODES.DEVICE_MODE.HD_HO.cd, CODES.DEVICE_MODE.ECUM_HO.cd, CODES.DEVICE_MODE.OHDF.cd, CODES.DEVICE_MODE.OHF.cd,CODES.DEVICE_MODE.IHDF.cd],
      //mod #10150 piao end
      // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
      facilitySettingAnticoagulantAutoValue: 0,
      facilitySettingAnticoagulantDefaultValue: 0,
      antiCoagulantAmountIsShow: true,
      antiCoagulantFlowRateIsShow: true,
      // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
    };
  },

  computed: {
    // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
    ...mapGetters("pat-viewer-treat-cond", {antiCoagulantQuantity: "getAntiCoagulantQuantity"}),
    ...mapGetters("pat-viewer-treat-cond", {checkDisabled: "getCheckDisabled"}),
    // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
    // add #10150 piao start
    ...mapGetters("pat-viewer-treat-cond", {getIsUseFlagIv: "getIsUseFlagIv", deviceMode: "getDeviceMode"}),
    // add #10150 piao end
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    // mod FNSI-連携イベントの登録適正化 楊 start
    //mod FNSI-redmine4498 房 start
    ...mapGetters("pat-info", ["selectedPat", "selectedPatId"]),
    //mod FNSI-redmine4498 房 end
    // mod FNSI-連携イベントの登録適正化 楊 end
    ...mapGetters("pat-viewer", { ordNoList : "getOrdNoList" }),
    // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
    ...mapGetters("pat-viewer", ["getTreatmentData"]),
    // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end
    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
    ...mapGetters("pat-viewer-treat-cond", {treatTime: "getTreatTime"}),
    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
     ...mapGetters("pat-viewer", ["getMstTreatmentData"]),
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
    //mod FNSI redmine 5161劉祥霖 start
    ...mapGetters("pat-viewer", ["getDispLayoutItemListData","getSelectedCondition"]),
    ...mapGetters("account-edit", {getDefaultSetting: "getDefaultSetting"}),
    //mod 6646 ng  抗凝固剤持続総量を登録できない 張 start
    // ...mapGetters("pat-viewer-treat-cond", ["isIpUse","isIpAutoOff"])
    ...mapGetters("pat-viewer-treat-cond", ["isIpUse","isIpAutoOff","getIpAutoOffTiming","getAntiCoagulantOneshotAmount","getAntiCoagulantFlowRate"]),
    //mod 6646 ng  抗凝固剤持続総量を登録できない 張 end
    //mod FNSI redmine 5161劉祥霖 end
  },

  watch: {
    compReset(value) {
      if (value) {
        this.$nextTick(() => {
           // リセット時、親に対してリセット検知のフラグを立てる
           this.$parent.$parent.isIndActionChartReset = true;
        });
      }
    },
  },

  methods: {
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
    ...mapMutations("pat-viewer-treat-cond", [
      "setOhdfCommentIsShow",
      "setOhdfDisplayString",
    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
      "setLiquidAmountCommentIsShow",
      "setLiquidAmountDisplayString",
      "setLiquidSpeedCommentIsShow",
      "setLiquidSpeedDisplayString",
      "setLiquidDelayTiming",
      "setLiquidCalPriority",
      "setLiquidRateBefore",
      "setLiquidRateAfter",
      "setIhdfLiquidTotal",
      "setIhdfLiquidSpeed",
    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
      "setAntiCoagulantUnit",
      "setAntiCoagulantFlowRateUnit",
      "setAntiCoagulantAmountTotalUnit",
      "setDialysateUnit",
      "setIvUnit",
      "setDeviceMode"
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
      // add #10150 piao Start
      ,"setIvDecPoint"
      // add #10150 piao end
      // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
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
      ,"setIpUse" //IP使用を設定
      ,"setIpAutoOff"//IP電源自動切りを設定
      ,"setIpMonitorOff"//IP電源OKモニタ切りを設定
      ,"setIsSingleNeedle"
      // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
    ]),
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end
    //mod FNSI-5525 劉全航 start
    ...mapActions("treatment-record/common",
      [
        "getMstMachineByOrdNoRst",
        "sendNextPatInfoViewer",
        "sendRequestChangeTreatTime"
      ]),
      //mod FNSI-5525 劉全航 end

    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
    ...mapActions("pat-viewer-treat-cond", ["initTreatCondData"]),

    // del #11004 連携イベント発生部分不正 piao start
    // async getSchModifySendClass() {
    //   let retVal = 0;
    //   const prmfacilityCd = this.facilityCd;
    //   this.objModSendClass = sendRequestGetCoopIniSchModifySendClass(prmfacilityCd);
    //
    //   try {
    //     const response = await this.objModSendClass;
    //     this.valModSendClass = response.data;
    //     retVal = response.data;
    //   } catch (error) {
    //     this.valModSendClass = 0;
    //     retVal = 0;
    //   }
    //   return retVal;
    // },
    // del #11004 連携イベント発生部分不正 piao end

    // mod #10150 piao start
    // async resetComponentIndData(structData,treatmentConditionSettingSource)
    async resetComponentIndData(structData){
    // mod #10150 piao end
      await this.getIndTreatCondIvMode(structData);
      if (this.isEdit()) {
        if(this.newIndTreatCondIvMode === this.oldIndTreatCondIvMode){
          this.$parent.$parent.messageDialogInfo.messageCd = 70000028;
          /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
          this.$parent.$parent.messageDialogInfo.type = "9";
          /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          //add 9664補液及び透析液仕様修正します yangqingzhe start 
          this.$parent.$parent.messageDialogInfo.title = DIALOG_MESSAGES[70000028].title
          //add 9664補液及び透析液仕様修正します yangqingzhe end
          return;
        } else {
          if(this.oldIndTreatCondIvMode !== "noIv"){
            this.$parent.$parent.messageDialogInfo.messageCd = 13000169;
            this.$parent.$parent.messageDialogInfo.type = "1";
            this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
            this.$parent.$parent.messageDialogInfo.title = DIALOG_MESSAGES[13000169].title
          }else{
            this.$parent.$parent.messageDialogInfo.messageCd = 70000028;
            /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
            this.$parent.$parent.messageDialogInfo.type = "9";
            /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
            this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
            //add 9664補液及び透析液仕様修正します yangqingzhe start 
            this.$parent.$parent.messageDialogInfo.title = DIALOG_MESSAGES[70000028].title
            //add 9664補液及び透析液仕様修正します yangqingzhe end
            return;
          }
        }
      }
      this.getComponentData(structData,2);
      return;
    },
    //add #10150 piao start
    async getIndTreatCondIvMode(structData) {
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = structData.facilityCd;
      // 患者情報
      paramJson.pat_id = structData.patId;
      // 治療開始日時
      paramJson.start_date = structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = structData.indEndDate;
      // クール
      paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 曜日パターン
      paramJson.weeks = JSON.stringify(structData.indWeeks);
      await ApiHelper.post("mainData/getFutureOrdMainConditionInfo", paramJson)
        .then(response => {
          this.newIndTreatCondIvMode = response.data.indTreatCondIvMode;
          this.isUsedCtlNos = response.data.isUsedCtlNos
        })
        .catch(error => {
          getErrorMessage('IndActionChart.vue', 'getIndTreatCondIvMode', error);
          throw error;
        });
      return;
    },
    //add #10150 piao end
      async getComponentData(structData,answer) {
      // 変更項目
      let indInfo = {};
      if (answer === 1) {
        return;
      } else if (answer === 3) {
        const treatCondItems = this.$refs;
        Object.keys(treatCondItems).forEach(key => {
          if (treatCondItems[key][0] && (treatCondItems[key][0].checkEditCount())) {
            indInfo = {
              ...indInfo,
              ...treatCondItems[key][0].createRequestData(structData)
            };
          }
        });
      }
      //add #10150 piao start
      this.oldIndTreatCondIvMode = this.newIndTreatCondIvMode;
      //add #10150 piao end
      let indWeeks = [
        {
          text: "全",
          done: true,
          value: 0
        },
        {
          text: "月",
          done: true,
          value: 1
        },
        {
          text: "火",
          done: true,
          value: 2
        },
        {
          text: "水",
          done: true,
          value: 3
        },
        {
          text: "木",
          done: true,
          value: 4
        },
        {
          text: "金",
          done: true,
          value: 5
        },
        {
          text: "土",
          done: true,
          value: 6
        },
        {
          text: "日",
          done: true,
          value: 7
        }
      ];
      const paramJson = {};
        // 施設情報
        paramJson.facility_cd = structData.facilityCd;
        // 患者情報
        paramJson.pat_id = structData.patId;
        // 治療開始日時
        paramJson.start_date = structData.indStartDate;
        // 治療終了日時
        paramJson.end_date = "";
        // クール
        paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
        // 治療方法
        paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
        // 曜日パターン
        paramJson.weeks = JSON.stringify(indWeeks);

        // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
        const response = await ApiHelper.post(
          "/mainData/getOrdMainDataInfo",
          paramJson
        ).catch(error => {
          getErrorMessage('IndActionChart.vue', 'resetComponentData', error);
          throw error;
        });
      let ordMainData = response.data;

    if(ordMainData && ordMainData.length > 0) {
      ordMainData = ordMainData[0];
    } else {
      // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
      this.setIsUseFlagVA (true) //VA使用フラグを設定
      this.setIsUseFlagDialyzer(true) //ダイアライザ使用フラグを設定
      this.setIsUseFlagColumn(true) //吸着カラム使用フラグを設定
      this.setIsUseFlagFirstPass (true) //1次膜使用フラグを設定
      this.setIsUseFlagSecondPass(true) //2次膜使用フラグを設定
      this.setIsUseFlagTube (true) //血液回路使用フラグを設定
      this.setIsUseFlagBloodFlow(true) //血流量使用フラグを設定
      this.setIsUseFlagWeight(true) //体重使用フラグを設定
      this.setIsUseFlagFilterLimit (true) //除水量制限使用フラグを設定
      this.setIsUseFlagNeedleSelection(true) //シングルニードル使用フラグを設定
      this.setIsUseFlagNeedleA(true) //穿刺針(A)使用フラグを設定
      this.setIsUseFlagNeedleV(true) //穿刺針(V)使用フラグを設定
      this.setIsUseFlagNeedleNeedleSN(true) //穿刺針(SN)使用フラグを設定
      this.setIsUseFlagDialysate(true) //透析液使用フラグを設定
      this.setIsUseFlagDialysateFlowRate(true) //透析液流量使用フラグを設定
      this.setIsUseFlagDialysateAmount(true) //透析液使用数使用フラグを設定
      this.setIsUseFlagDialysateTemperature(true) //透析液温度使用フラグを設定
      this.setIsUseFlagIv(true) //補液使用フラグを設定
      this.setIsUseFlagIvAmount(true) //補液量使用フラグを設定
      this.setIsUseFlagIvSelection(true) //補液選択使用フラグを設定
      this.setIsUseFlagIvCount(true) //補液使用数使用フラグを設定
      this.setIsUseFlagIvTemperature(true) //補液温度使用フラグを設定
      this.setIsUseFlagIvFlowRate(true) //補液速度使用フラグを設定
      this.setIsUseFlagAntiCoaguLant(true) //抗凝固剤使用フラグを設定
      this.setIsUseFlagAntiCoagulantOneshotAmount(true) //抗凝固剤ワンショット量使用フラグを設定
      this.setIsUseFlagAntiCoagulantFlowRate(true) //抗凝固剤持続速度使用フラグを設定
      this.setIsUseFlagAntiCoagulantAmountTotal(true) //抗凝固剤持続総量使用フラグを設定
      this.setIsUseFlagIpSelection(true) //IP使用選択使用フラグを設定
      this.setIsUseFlagIpStart(true) //IPスタート使用フラグを設定
      this.setIsUseFlagIpOneshotAmount(true) //IPワンショット量使用フラグを設定
      this.setIsUseFlagIpFlowRate(true) //IP速度使用フラグを設定
      this.setIsUseFlagIpFlowRateLimit(true) //IP速度最大値使用フラグを設定
      this.setIsUseFlagIpOneshotSelection(true) //IPワンショットスタート使用フラグを設定
      this.setIsUseFlagIpAutoOff(true) //IP電源自動切り使用フラグを設定
      this.setIsUseFlagIpAutoOffTiming(true) //IP電源自動切り時間使用フラグを設定
      this.setIsUseFlagIpMonitorOff(true) //IP電源OKモニタ切り使用フラグを設定
      this.setIsUseFlagIpMonitorOffTiming(true) //IP電源OKモニタ切り時間使用フラグを設定
      // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
        // add #10150 piao start
        this.compReset = false;
        this.$nextTick(() => {
          this.compReset = true;
        });
        // add #10150 piao end
      return;
    }

      const rstDialysisState = ordMainData.rstDialysisState;
      const dataObject  = ordMainData ? JSON.parse(ordMainData.indCondInfo) : null;

      // 治療条件のストアを初期化
      this.initTreatCondData({ indCondInfo: dataObject });

      for (const index in this.componentNames) {
        //mod FNSI-5639 劉全航 start
        if(this.componentNames[index].fields.value != this.componentNames[index].fields.velue && answer == 3){
          // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
          if (this.componentNames[index].cd === 12 && indInfo[this.componentNames[index].cd]) {
            this.setIsSingleNeedle(indInfo[this.componentNames[index].cd].value == "1"); // mod #9973 value Number→文字列  shiyw
          }
          //透析液使用数のunitを設定する
          if (this.componentNames[index].cd === 17 && indInfo[this.componentNames[index].cd]) {
            this.setDialysateUnit(indInfo[this.componentNames[index].cd].unit);
          }
          //抗凝固剤ワンショット量のunitを設定する
          if (this.componentNames[index].cd === 26 && indInfo[this.componentNames[index].cd]) {
            this.setAntiCoagulantUnit(indInfo[this.componentNames[index].cd].unit);
          }
          //抗凝固剤持続速度のunitを設定する
          if (this.componentNames[index].cd === 27 && indInfo[this.componentNames[index].cd]) {
            this.setAntiCoagulantFlowRateUnit(indInfo[this.componentNames[index].cd].unit);
          }
          //抗凝固剤持続総量のunitを設定する
          if (this.componentNames[index].cd === 28 && indInfo[this.componentNames[index].cd]) {
            this.setAntiCoagulantAmountTotalUnit(indInfo[this.componentNames[index].cd].unit);
          }
          // //IP使用選択を設定する
          if (this.componentNames[index].cd === 29 && indInfo[this.componentNames[index].cd]) {
            this.setIpUse(indInfo[this.componentNames[index].cd].value == "1");// mod #9973 value Number→文字列  shiyw
          }
          // IP電源自動切りを設定する
          if (this.componentNames[index].cd === 35 && indInfo[this.componentNames[index].cd]) {
            this.setIpAutoOff(indInfo[this.componentNames[index].cd].value == "1");// mod #9973 value Number→文字列  shiyw
          }
          // IP電源OKモニタ切りを設定する
          if (this.componentNames[index].cd === 37 && indInfo[this.componentNames[index].cd]) {
            this.setIpMonitorOff(indInfo[this.componentNames[index].cd].value == "1");// mod #9973 value Number→文字列  shiyw
          }
          // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
          // del 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
          //continue;
          // del 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
        }
        // add #10150 piao start
        this.compReset = false;
        // add #10150 piao end
        //mod FNSI-5639 劉全航 end
        const cd = this.componentNames[index].cd;
        // 対象項目のデータをデフォルト値として設定
        let value = _.propertyOf(dataObject)([cd, "value"]);
        let medicine_type = _.propertyOf(dataObject)([cd.toString(), "medicine_type"]);
        //mod FNSI-5639 劉全航 start
        //let velue = null;
        let velue = value;
        //mod FNSI-5639 劉全航 end

        if (answer === 3 && indInfo[cd]) {
            velue = indInfo[cd].value;
            medicine_type = indInfo[cd].medicine_type;
        }
        // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
        if (cd === 17 && value) {
          value = parseFloat(value);
          velue = parseFloat(velue);
        }
        // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
        // (null !== medicine_type && undefined != medicine_type) ? String(medicine_type) : null;
        const initMdicineType = (null !== medicine_type && undefined != medicine_type) ? Number(medicine_type) : null;
        if (cd === 17 || cd === 22 || cd === 26 ||cd === 27 || cd === 28 ) {
          this.componentData[index].fields = {
            rstDialysisState: rstDialysisState,
            value: value,
            velue: velue,
            medicineType: initMdicineType,
            //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
            isIndication: true
            //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
          };
        } else {
          this.componentData[index].fields = {
            value: value,
            velue: velue,
            medicineType: initMdicineType,
            //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
            isIndication: true
            //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
          };
        }
        if (cd === 39) {
          let dw = this.ordMainData[0].indDw;
          if (dw === null || dw === undefined) {
            // indDwが取得できないならば身体情報から治療日最直近のDWを取得
            const tDate = moment(ordMainData[0].indStartDate, "YYYYMMDD").add(1, "day");
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
          this.componentData[index].fields.value = dw;
        }

        this.oldcomponentData = JSON.parse(JSON.stringify(this.componentData))

        // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
        //IP使用選択を設定する
        const treatCondItems = this.$refs;
        //IP使用選択
        // mode 2023/06/23 kang start ies_6503
        // if (cd === 29){
        if (cd === 29 && treatCondItems[28] !== undefined){
          // mode 2023/06/23 kang end ies_6503
          this.setIpUse(treatCondItems[28][0].inputValue === 1);
          // IP電源自動切り
          // mode 2023/06/23 kang start ies_6503
          //}else if (cd === 35){
        }else if (cd === 35 && treatCondItems[34]!==undefined){
          // mode 2023/06/23 kang end ies_6503
          this.setIpAutoOff(treatCondItems[34][0].inputValue === 1);
          // IP電源OKモニタ切りを設定する
          // mode 2023/06/23 kang start ies_6503
          //}else if (cd === 37){
        }else if (cd === 37 && treatCondItems[36]!==undefined){
          // mode 2023/06/23 kang end ies_6503
            this.setIpMonitorOff(treatCondItems[36][0].inputValue === 1);
        }
        // add 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
      }
      // add #10150 piao start
      if(rstDialysisState === "0"){
        if(this.newIndTreatCondIvMode === "onLine" && dataObject && dataObject[15].value !== null){
          await ApiHelper.get("/mstInfo/mstMedicine/getByCd", {medicineCd:dataObject[15].value, medicineType:dataObject[15].medicine_type}).then((res) => {
            if (res && res.data) {
              this.setIvUnit(res.data.unitSecond);
              this.setIvDecPoint(res.data.unitDecimalPointSecond);
            }
          });
        }
        if(this.newIndTreatCondIvMode === "offLine" && dataObject && dataObject[19].value !== null){
          await ApiHelper.get("/mstInfo/mstMedicine/getByCd", {medicineCd:dataObject[19].value, medicineType:dataObject[19].medicine_type}).then((res) => {
            if (res && res.data) {
              this.setIvUnit(res.data.unitSecond);
              this.setIvDecPoint(res.data.unitDecimalPointSecond);
            }
          });
        }
      }
      // add #10150 piao end
      // del #10150 piao start
      // 変更対象治療方法取得
      // let selectedTreatItem =[];
      // for (let i = 0;i <= structData.selectedTreat.length;i++) {
      //   // 装置モードをマスタから取得
      //   let mstRecord = this.getMstTreatmentData.find(mstData => {
      //     return mstData.treatmentCd === structData.selectedTreat[i];
      //    });
      //   if (mstRecord) {
      //     selectedTreatItem.push(mstRecord.deviceMode);
      //   }
      // }
      // del #10150 piao end
      await this.$parent.$parent.getDeviceSetInfoInd();
      this.$parent.$parent.showOhdfComment();
      // mod #10150 piao start
      // if (selectedTreatItem.length > 0) {
      //   this.setDeviceMode(selectedTreatItem[0]);
      // }
      if(ordMainData.indTreatmentCd){
        let mstRecord = this.getMstTreatmentData.find(mstData => {
          return mstData.treatmentCd === ordMainData.indTreatmentCd;
        });
        this.setDeviceMode(mstRecord.deviceMode);
      }
      // mod #10150 piao end
      // add 8204 周安寧 start
      //del #10150 piao start
      // let treatmentlist = this.treatmentConditionSettingSource;
      // if (structData.indStartDate) {
      //   treatmentlist = treatmentlist.filter(item => (item.treatDate >= structData.indStartDate.replace(/-/g, '')));
      // }
      // if (structData.indEndDate) {
      //   treatmentlist = treatmentlist.filter(item => (item.treatDate <= structData.indEndDate.replace(/-/g, '')));
      // }
      // if (structData.selectedTreat.length >0){
      //   treatmentlist = treatmentlist.filter(item => (structData.selectedTreat.includes(item.treatmentCd)))
      // }
      // if (structData.selectedKur.length >0){
      //   treatmentlist = treatmentlist.filter(item => (structData.selectedKur.includes(item.indKurCd)))
      // }
      // let weekList = [];
      // structData.indWeeks.forEach(eleItem => {
      //   if (eleItem.done === true) {
      //     weekList.push(parseInt(eleItem.value));
      //   }
      // });
      // if (weekList.length >0){
      //   treatmentlist = treatmentlist.filter(item => (weekList.includes(item.treatWeek)))
      // }
      //del #10150 piao end
      let isNoUse = true;
      //穿刺針使用フラグ
      let isNoUseSingleNeedle = true;
      //IP設定使用フラグ
      let isNoUseIPConflg = true;
      //抗凝固剤使用フラグ
      let isNoUseAntiCoaguLant = true;
      //透析液使用フラグ
      let isNoUseDialySisFluid = true;
      //体重使用フラグ
      let isNoUseWeight = true;
      //VA使用フラグ
      let isNoUseVA = true;
      //ダイアライザ使用フラグ
      let isNoUseDialyzer = true;
      //吸着カラム使用フラグ
      let isNoUseColumn = true;
      //1次膜使用フラグ
      let isNoUseFirstPass = true;
      //2次膜使用フラグ
      let isNoUseSecondPass = true;
      //血液回路使用フラグ
      let isNoUseTube = true;
      //血流量使用フラグ
      let isNoUseBloodFlow = true;
      //mod #10150 piao start
      if(this.isUsedCtlNos != null){
      this.isUsedCtlNos.forEach(item => {
        if(item == 2){isNoUseVA = false;} // VA
        if(item == 3){isNoUseWeight = false;} // 目標体重
        if(item == 4){isNoUseWeight = false;} // 除水量制限
        if(item == 5){isNoUseDialyzer = false;} // ダイアライザ
        if(item == 6){isNoUseColumn = false;} // 吸着カラム
        if(item == 7){isNoUseFirstPass = false;} // 1次膜
        if(item == 8){isNoUseSecondPass = false;} // 2次膜
        if(item == 9){isNoUseSingleNeedle = false;} // 穿刺針(A針)
        if(item == 10){isNoUseSingleNeedle = false;} // 穿刺針(V針)
        if(item == 11){isNoUseSingleNeedle = false;} // 穿刺針(SN)
        if(item == 12){isNoUseSingleNeedle = false;} // シングルニードル使用
        if(item == 13){isNoUseTube = false;} // 血液回路
        if(item == 14){isNoUseBloodFlow = false;} // 血流量
        if(item == 15){isNoUseDialySisFluid = false;} // 透析液
        if(item == 16){isNoUseDialySisFluid = false;} // 透析液流量
        if(item == 17){isNoUseDialySisFluid = false;} // 透析液量
        if(item == 18){isNoUseDialySisFluid = false;} // 透析液温度
        if(this.newIndTreatCondIvMode === "noIv"){
          if(item == 19){isNoUse = true;} // 補液
          if(item == 20){isNoUse = true;} // 補液量
          if(item == 21){isNoUse = true;} // 補液選択
          if(item == 22){isNoUse = true;} // 補液使用数
          if(item == 23){isNoUse = true;} // 補液温度
          if(item == 24){isNoUse = true;} // 補液速度
        }else {
          if(item == 19){isNoUse = false;} // 補液
          if(item == 20){isNoUse = false;} // 補液量
          if(item == 21){isNoUse = false;} // 補液選択
          if(item == 22){isNoUse = false;} // 補液使用数
          if(item == 23){isNoUse = false;} // 補液温度
          if(item == 24){isNoUse = false;} // 補液速度
        }
        if(item == 25){isNoUseAntiCoaguLant = false;} // 抗凝固剤
        if(item == 26){isNoUseAntiCoaguLant = false;} // 抗凝固剤ワンショット量
        if(item == 27){isNoUseAntiCoaguLant = false;} // 抗凝固剤持続速度
        if(item == 28){isNoUseAntiCoaguLant = false;} // 抗凝固剤持続総量
        if(item == 29){isNoUseIPConflg = false;} // IP使用選択
        if(item == 30){isNoUseIPConflg = false;} // IPスタート
        if(item == 31){isNoUseIPConflg = false;} // IPワンショット量
        if(item == 32){isNoUseIPConflg = false;} // IP速度
        if(item == 33){isNoUseIPConflg = false;} // IP速度最大値
        if(item == 34){isNoUseIPConflg = false;} // IPワンショットスタート
        if(item == 35){isNoUseIPConflg = false;} // IP電源自動切り
        if(item == 36){isNoUseIPConflg = false;} // IP電源自動切り時間
        if(item == 37){isNoUseIPConflg = false;} // IP電源OKモニタ切り
        if(item == 38){isNoUseIPConflg = false;} // IP電源OKモニタ切り時間
      });}
      // treatmentlist.forEach(everyItem => {
      //   //VA使用
      //   const base = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 1);
      //   if (base[0].items[0].is_use === "1") {
      //     isNoUseVA = false;
      //   }
      //   //ダイアライザ
      //   if (base[0].items[1].is_use === "1") {
      //     isNoUseDialyzer = false;
      //   }
      //   //吸着カラム
      //   if (base[0].items[2].is_use === "1") {
      //     isNoUseColumn = false;
      //   }
      //   //1次膜
      //   if (base[0].items[3].is_use === "1") {
      //     isNoUseFirstPass = false;
      //   }
      //   //2次膜
      //   if (base[0].items[4].is_use === "1") {
      //     isNoUseSecondPass = false;
      //   }
      //   //血液回路
      //   if (base[0].items[5].is_use === "1") {
      //     isNoUseTube = false;
      //   }
      //   //血流量
      //   if (base[0].items[6].is_use === "1") {
      //     isNoUseBloodFlow = false;
      //   }
      //   //体重
      //   const weight = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 2);
      //   if (weight[0].items[0].is_use === "1") {
      //     isNoUseWeight = false;
      //   }
      //   //透析液
      //   const dialySisFluid = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 3);
      //   if (dialySisFluid[0].items[0].is_use === "1") {
      //     isNoUseDialySisFluid = false;
      //   }
      //   const items = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 4);
      //   if (items[0].items[0].is_use === "1") {
      //     isNoUse = false;
      //   }
      //   //抗凝固剤
      //   const antiCoaguLant = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 5);
      //   if (antiCoaguLant[0].items[0].is_use === "1") {
      //     isNoUseAntiCoaguLant = false;
      //   }
      //   //IP設定
      //   const iPConflg = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 6);
      //   if (iPConflg[0].items[0].is_use === "1") {
      //     isNoUseIPConflg = false;
      //   }
      //   //穿刺針
      //   const singleNeedle = JSON.parse(everyItem.treatmentConditionSetting).filter(e => e.category_no === 7);
      //   if (singleNeedle[0].items[0].is_use === "1") {
      //     isNoUseSingleNeedle = false;
      //   }
      // })
      //mod #10150 piao end
      this.setIsUseFlagVA(isNoUseVA); //VA使用フラグを設定
      this.setIsUseFlagDialyzer(isNoUseDialyzer);//ダイアライザ使用フラグを設定
      this.setIsUseFlagColumn(isNoUseColumn);//吸着カラム使用フラグを設定
      this.setIsUseFlagFirstPass(isNoUseFirstPass); //1次膜使用フラグを設定
      this.setIsUseFlagSecondPass(isNoUseSecondPass);//2次膜使用フラグを設定
      this.setIsUseFlagTube(isNoUseTube); //血液回路使用フラグを設定
      this.setIsUseFlagBloodFlow(isNoUseBloodFlow);//血流量使用フラグを設定
      this.setIsUseFlagWeight(isNoUseWeight);//体重使用フラグを設定
      this.setIsUseFlagFilterLimit (isNoUseWeight) //除水量制限使用フラグを設定
      this.setIsUseFlagNeedleSelection(isNoUseSingleNeedle) //シングルニードル使用フラグを設定
      //del #10150 piao start
      // this.setIsUseFlagNeedleA(isNoUseSingleNeedle) //穿刺針(A)使用フラグを設定
      // this.setIsUseFlagNeedleV(isNoUseSingleNeedle) //穿刺針(V)使用フラグを設定
      // this.setIsUseFlagNeedleNeedleSN(isNoUseSingleNeedle) //穿刺針(SN)使用フラグを設定
      //del #10150 piao end
      this.setIsUseFlagDialysate(isNoUseDialySisFluid) //透析液使用フラグを設定
      this.setIsUseFlagDialysateFlowRate(isNoUseDialySisFluid) //透析液流量使用フラグを設定
      this.setIsUseFlagDialysateAmount(isNoUseDialySisFluid) //透析液使用数使用フラグを設定
      this.setIsUseFlagDialysateTemperature(isNoUseDialySisFluid) //透析液温度使用フラグを設定
      this.setIsUseFlagIv(isNoUse) //補液使用フラグを設定
      this.setIsUseFlagIvAmount(isNoUse) //補液量使用フラグを設定
      this.setIsUseFlagIvSelection(isNoUse) //補液選択使用フラグを設定
      this.setIsUseFlagIvCount(isNoUse) //補液使用数使用フラグを設定
      this.setIsUseFlagIvTemperature(isNoUse) //補液温度使用フラグを設定
      this.setIsUseFlagIvFlowRate(isNoUse) //補液速度使用フラグを設定
      this.setIsUseFlagAntiCoaguLant(isNoUseAntiCoaguLant) //抗凝固剤使用フラグを設定
      this.setIsUseFlagAntiCoagulantOneshotAmount(isNoUseAntiCoaguLant) //抗凝固剤ワンショット量使用フラグを設定
      this.setIsUseFlagAntiCoagulantFlowRate(isNoUseAntiCoaguLant) //抗凝固剤持続速度使用フラグを設定
      this.setIsUseFlagAntiCoagulantAmountTotal(isNoUseAntiCoaguLant) //抗凝固剤持続総量使用フラグを設定
      this.setIsUseFlagIpSelection(isNoUseIPConflg) //IP使用選択使用フラグを設定
      this.setIsUseFlagIpStart(isNoUseIPConflg) //IPスタート使用フラグを設定
      this.setIsUseFlagIpOneshotAmount(isNoUseIPConflg) //IPワンショット量使用フラグを設定
      this.setIsUseFlagIpFlowRate(isNoUseIPConflg) //IP速度使用フラグを設定
      this.setIsUseFlagIpFlowRateLimit(isNoUseIPConflg) //IP速度最大値使用フラグを設定
      this.setIsUseFlagIpOneshotSelection(isNoUseIPConflg) //IPワンショットスタート使用フラグを設定
      this.setIsUseFlagIpAutoOff(isNoUseIPConflg) //IP電源自動切り使用フラグを設定
      this.setIsUseFlagIpAutoOffTiming(isNoUseIPConflg) //IP電源自動切り時間使用フラグを設定
      this.setIsUseFlagIpMonitorOff(isNoUseIPConflg) //IP電源OKモニタ切り使用フラグを設定
      this.setIsUseFlagIpMonitorOffTiming(isNoUseIPConflg) //IP電源OKモニタ切り時間使用フラグを設定
      if (answer == 3){
          for (const index in this.componentNames) {
        if(this.componentNames[index].fields.value != this.componentNames[index].fields.velue){

          switch (this.componentNames[index].name) {
            case "ind-treat-va":
              this.setIsUseFlagVA(false); //VA使用フラグを設定
              break;
            case "ind-treat-target-weight":
              this.setIsUseFlagWeight(false) //体重使用フラグを設定
              break;
            case "ind-treat-filter-limit":
              this.setIsUseFlagFilterLimit (false) //除水量制限使用フラグを設定
              break;
            case "ind-treat-dialyzer":
              this.setIsUseFlagDialyzer(false) //ダイアライザ使用フラグを設定
              break;
            case "ind-treat-separatory-column":
              this.setIsUseFlagColumn(false) //吸着カラム使用フラグを設定
              break;
            case "ind-treat-first-pass":
              this.setIsUseFlagFirstPass(false) //1次膜使用フラグを設定
              break;
            case "ind-treat-second-pass":
              this.setIsUseFlagSecondPass(false) //2次膜使用フラグを設定
              break;
            case "ind-treat-needle-selection":
              this.setIsUseFlagNeedleSelection(false) //シングルニードル使用フラグを設定
              break;
            case "ind-treat-needle-a":
              this.setIsUseFlagNeedleA(false) //穿刺針(A)使用フラグを設定
              break;
            case "ind-treat-needle-v":
              this.setIsUseFlagNeedleV(false) //穿刺針(V)使用フラグを設定
              break;
            case "ind-treat-needle-sn":
              this.setIsUseFlagNeedleNeedleSN(false) //穿刺針(SN)使用フラグを設定
              break;
            case "ind-treat-tube":
              this.setIsUseFlagTube(false) //血液回路使用フラグを設定
              break;
            case "ind-treat-blood-flow":
              this.setIsUseFlagBloodFlow(false) //血流量使用フラグを設定
              break;
            case "ind-treat-dialysate":
              this.setIsUseFlagDialysate(false) //透析液使用フラグを設定
              break;
            case "ind-treat-dialysate-flow-rate":
              this.setIsUseFlagDialysateFlowRate(false) //透析液流量使用フラグを設定
              break;
            case "ind-treat-dialysate-amount":
              this.setIsUseFlagDialysateAmount(false) //透析液使用数使用フラグを設定
              break;
            case "ind-treat-dialysate-temperature":
              this.setIsUseFlagDialysateTemperature(false) //透析液温度使用フラグを設定
              break;
            case "ind-treat-iv":
              //del 余分なlogを削除する 周安寧 start
              //console.log("補液使用フラグ" + false)
              //del 余分なlogを削除する 周安寧 end
              this.setIsUseFlagIv(false) //補液使用フラグを設定
              break;
            case "ind-treat-iv-amount":
              this.setIsUseFlagIvAmount(false) //補液量使用フラグを設定
              break;
            case "ind-treat-iv-selection":
              this.setIsUseFlagIvSelection(false) //補液選択使用フラグを設定
              break;
            case "ind-treat-iv-count":
              this.setIsUseFlagIvCount(false) //補液使用数使用フラグを設定
              break;
            case "ind-treat-iv-temperature":
              this.setIsUseFlagIvTemperature(false) //補液温度使用フラグを設定
              break;
            case "ind-treat-iv-flow-rate":
              this.setIsUseFlagIvFlowRate(false) //補液速度使用フラグを設定
              break;
            case "ind-treat-anti-coagulant":
              this.setIsUseFlagAntiCoaguLant(false) //抗凝固剤使用フラグを設定
              break;
            case "ind-treat-anti-coagulant-amount":
              this.setIsUseFlagAntiCoagulantOneshotAmount(false) //抗凝固剤ワンショット量使用フラグを設定
              break;
            case "ind-treat-anti-coagulant-flow-rate":
              this.setIsUseFlagAntiCoagulantFlowRate(false) //抗凝固剤持続速度使用フラグを設定
              break;
            case "ind-treat-anti-coagulant-amount-total":
              this.setIsUseFlagAntiCoagulantAmountTotal(false) //抗凝固剤持続総量使用フラグを設定
              break;
            case "ind-treat-ip-selection":
              this.setIsUseFlagIpSelection(false) //IP使用選択使用フラグを設定
              break;
            case "ind-treat-ip-start":
              this.setIsUseFlagIpStart(false) //IPスタート使用フラグを設定
              break;
            case "ind-treat-ip-amount":
              this.setIsUseFlagIpOneshotAmount(false) //IPワンショット量使用フラグを設定
              break;
            case "ind-treat-ip-flow-rate":
              this.setIsUseFlagIpFlowRate(false) //IP速度使用フラグを設定
              break;
            case "ind-treat-ip-flow-rate-limit":
              this.setIsUseFlagIpFlowRateLimit(false) //IP速度最大値使用フラグを設定
              break;
            case "ind-treat-ip-oneshot-selection":
              this.setIsUseFlagIpOneshotSelection(false) //IPワンショットスタート使用フラグを設定
              break;
            case "ind-treat-ip-auto-off":
              this.setIsUseFlagIpAutoOff(false) //IP電源自動切り使用フラグを設定
              break;
            case "ind-treat-ip-auto-off-timing":
              this.setIsUseFlagIpAutoOffTiming(false) //IP電源自動切り時間使用フラグを設定
              break;
            case "ind-treat-ip-monitor-off":
              this.setIsUseFlagIpMonitorOff(false) //IP電源OKモニタ切り使用フラグを設定
              break;
            case "ind-treat-ip-monitor-off-timing":
              this.setIsUseFlagIpMonitorOffTiming(false) //IP電源OKモニタ切り時間使用フラグを設定
              break;
            default:
              break;
          }
        }
      }
    }
    // add 8204 デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
    // mod 8204 デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
      // this.compReset = false;
      //   this.$nextTick(() => {
      //     this.compReset = true;
      //   });
      // mod 8204 デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
      //if (answer === 2){
      // mod 8204 デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
        this.compReset = false;
        this.$nextTick(() => {
           this.compReset = true;
        });
       // mod 8204 デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 start
      //}
      // mod 8204 デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
      // mod 8204 デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう 周安寧 end
    },
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end

    // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
    /**
     * 指示情報
     */
    ordMainData() {
      return this.getTreatmentData[0];
    },
    // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end

    async updateIndInfo(structData) {
      console.log("IndActionChart.vue async updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      const treatCondItems = this.$refs;
      // del FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
      // let indInfo = {};
      // del FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
      // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
      // 表示項目
      let indInfoShow = {};
      // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end

      // 変更箇所がなければ、これ以降の処理を終了してメッセージ表示
      // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 start
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start

      if (this.checkIsEdit(0,structData)) {
        console.log("IndActionChart.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // if (this.checkEdit(0)){
      //   if (this.settingIndData.headerTitle !== "治療条件") {
      //     return;
      //   }
      // }
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
      // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 end

      Object.keys(treatCondItems).forEach(key => {
        // del FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
        // if (treatCondItems[key][0] && treatCondItems[key][0].checkEditCount()) {
        //   indInfo = {
        //     ...indInfo,
        //     ...treatCondItems[key][0].createRequestData(structData)
        //   };
        // }
        // del FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
        // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
        //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
        //mod FNSI-改修内容 redmine 4880 4882  劉祥霖 start
        if (treatCondItems[key][0] && (!structData.editOnly||treatCondItems[key][0].checkEditCount())) {
        //mod FNSI-改修内容 redmine 4880 4882 劉祥霖 end
        //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
          indInfoShow = {
            ...indInfoShow,
            ...treatCondItems[key][0].createRequestData(structData)
          }
          //add FNSI-redmine4498 房 start
          //del 6590 次患者情報（コメントデータ）が更新されない 張 start
          // if (this.componentNames[0].name == "ind-treat-needle-selection") {
          //del 6590 次患者情報（コメントデータ）が更新されない 張 end
          //del 5749 6590 抗凝固剤を未登録→登録しても次患者情報が送信されない張 start
            // ApiHelper.put(
            //   `/patInfo/updatePhysicalInfoById/${this.selectedPatId}`,
            //   {
            //     needle_flag: true
            //   }
            // ).catch(error => {
            //   getErrorMessage('PhysicalInfoAddEdit.vue', 'saveRecord', "身体情報更新失敗");
            //   if (error.response.data == '22020006') {
            //     throw new Error("身体情報更新失敗");
            //   }
            //   throw new Error("身体情報更新失敗");
            // });
            //del 5749 6590 抗凝固剤を未登録→登録しても次患者情報が送信されない張 end
          // }
          //add FNSI-redmine4498 房 end
        //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
        }
        //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
        // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
      });

      // del FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
      // let sendConditionInfo = {};
      // Object.keys(treatCondItems).forEach(key => {
      //   if (treatCondItems[key][0] && treatCondItems[key][0].checkEditCount()) {
      //     sendConditionInfo = {
      //       ...sendConditionInfo,
      //       ...treatCondItems[key][0].createAddData()
      //     };
      //   }
      // });
      // del FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
      // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
      // 変更箇所がなければ、これ以降の処理を終了してメッセージ表示
      // mod FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
      // if (this.itemCheckDisabled(indInfoShow)) {
      if (await this.itemCheckDisabled(indInfoShow, structData)) {
        // mod FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
        this.itemStructData = structData;
        //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
        console.log("IndActionChart.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
        //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
      } else {
        // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
        //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
        // if (this.settingIndData.headerTitle === "治療条件"){
        //     this.$parent.$parent.messageDialogInfo.messageCd = 70000028;
        //     this.$parent.$parent.messageDialogInfo.type = "8";
        //     this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        //   return;
        // }
        //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
        // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end
        this.answerFlg = "0";
        this.updateInfo(structData);
      }
      console.log("IndActionChart.vue updateIndInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    // 非表示にした項目が「自動計算」項目以外の戻り関数
    reflectIndInfo1() {
      if (this.itemDisplayFlg) {

        // mod FNSI-性能を最適化する 李 start
        this.$nextTick(() => {
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
          //this.$parent.$parent.messageDialogInfo.messageCd = "00400002";
          this.$parent.$parent.messageDialogInfo.messageCd = 10400002;
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          this.$parent.$parent.messageDialogInfo.type = "2";
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          this.itemDisplayFlg = false;
        });

        // setTimeout(() => {
        //   //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
        //   //this.$parent.$parent.messageDialogInfo.messageCd = "00400002";
        //   this.$parent.$parent.messageDialogInfo.messageCd = 10400002;
        //   //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
        //   this.$parent.$parent.messageDialogInfo.type = "2";
        //   this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        //   this.itemDisplayFlg = false;
        // }, 200);
        // mod FNSI-性能を最適化する 李 end
      } else {
        this.answerFlg = "0";
        this.updateInfo(this.itemStructData);
      }
    },

    // 非表示にした項目が「自動計算」項目の戻り関数
    //mod FNSI redmine 5161劉祥霖 start
    reflectIndInfo2(answer,messageCd) {
      this.answerFlg = this.answerFlg + answer;
      if(messageCd==10400003){
        if(this.IPOneShotAmountChange==true){
          this.$parent.$parent.messageDialogInfo.messageCd = 10400004;
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
          // this.$parent.$parent.messageDialogInfo.type = "2";
          this.$parent.$parent.messageDialogInfo.type = "1";
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          return;
        }else if(this.IPSpeedChange==true){
          this.$parent.$parent.messageDialogInfo.messageCd = 10400005;
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
          // this.$parent.$parent.messageDialogInfo.type = "2";
          this.$parent.$parent.messageDialogInfo.type = "1";
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          return;
        }else{
          this.updateInfo(this.itemStructData);
        }
      }else if(messageCd==10400004){
        if(this.IPSpeedChange==true){
          this.$parent.$parent.messageDialogInfo.messageCd = 10400005;
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
          // this.$parent.$parent.messageDialogInfo.type = "2";
          this.$parent.$parent.messageDialogInfo.type = "1";
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          return;
        }else{
          this.updateInfo(this.itemStructData);
        }
      }else if(messageCd=="10400005"){
        this.updateInfo(this.itemStructData);
      }else{
        this.updateInfo(this.itemStructData);
      }
    },
    //mod FNSI redmine 5161劉祥霖 end
    // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
    //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
    // async saveIndCondInfo(structData,answer){
    //   this.answerFlg = "0";
    //   this.updateInfo(structData,answer);
    // },
    //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
    // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end

    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
    //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
    // async saveIndCondInfo2(structData){
    //   if (this.settingIndData.headerTitle === "治療条件"){
    //     setTimeout(() => {
    //     this.$parent.$parent.messageDialogInfo.messageCd = 70000028;
    //     this.$parent.$parent.messageDialogInfo.type = "8";
    //     this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
    //     }, 200);
    //     return;
    //     }
    //   this.answerFlg = "0";
    //   this.updateInfo(structData);
    // },
    //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
    // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 start
    //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
    async updateInfo(structData) {
      console.log("IndActionChart.vue updateInfo this.startLoadingScreen();");
      this.startLoadingScreen();
    //async updateInfo(structData,answer) {
    //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
    // mod FNSI-【1006】最新の改修対象一覧の679対応 韓 end
      const treatCondItems = this.$refs;
      // 変更項目
      let indInfo = {};

      //add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 start
      let isHaveNeedleA = false;
      let isHaveNeedleV = false;
      let isHaveNeedleSN = false;
      let isHaveNeedleSelected = false;
      let isUsed = false;
      //add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 end

      Object.keys(treatCondItems).forEach(key => {
        // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
        //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
        // if (this.settingIndData.headerTitle === "治療条件"){
        //   if (treatCondItems[key][0]) {
        //     // 現表示を維持する
        //     indInfo = {
        //       ...indInfo,
        //       ...treatCondItems[key][0].createRequestData(structData)
        //     };
        //   }
        // }else {
        //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
        // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end
        //mod FNSI-改修内容 redmine 4880 4882 劉祥霖 start
        //mod 6646 ng  抗凝固剤持続総量を登録できない 張 start
        // if (treatCondItems[key][0] && (!structData.editOnly||treatCondItems[key][0].checkEditCount())) {
          /* modify by chamaojia 2023-04-13 [8537] 指定項目の判定条件の追加  --start */
        // if (treatCondItems[key][0] && (!structData.editOnly||treatCondItems[key][0].checkEditCount()||this.checkDisabled)) {
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
        const coagulantAmountTotalisHidden = this.componentNames.find(item=> item.cd === 28 && item.isShow === false);
        const coagulantAmountAndRateIsHidden = this.componentNames.find(item=> [26, 27].includes(item.cd) && item.isShow === false);
        let coagulantAmountTotalHiddenFlg = coagulantAmountTotalisHidden && this.facilitySettingAnticoagulantAutoValue === 1 && (("246".indexOf(this.answerFlg) > -1) || this.answerFlg==="26")
        // if (treatCondItems[key][0] && (!structData.editOnly||treatCondItems[key][0].checkEditCount()||(treatCondItems[key][0].treatItemCd === "28" && this.checkDisabled))) {
        // if (treatCondItems[key][0] && (!structData.editOnly||treatCondItems[key][0].checkEditCount()||(treatCondItems[key][0].treatItemCd === "28" && this.checkDisabled) || (["28"].includes(treatCondItems[key][0].treatItemCd) && coagulantAmountTotalHiddenFlg) )) {
        // #10196 切り替え補液,補液使用数小桁未更新です linjunfeng start
        // if (treatCondItems[key][0] && ((structData&&!structData.editOnly)||treatCondItems[key][0].checkEditCount()||(treatCondItems[key][0].treatItemCd === "28" && this.checkDisabled) || (["28"].includes(treatCondItems[key][0].treatItemCd) && coagulantAmountTotalHiddenFlg) || (["26", "27"].includes(treatCondItems[key][0].treatItemCd) && coagulantAmountAndRateIsHidden && this.facilitySettingAnticoagulantDefaultValue === 1)  )) {
        // if (treatCondItems[key][0] && ((structData&&!structData.editOnly)||(treatCondItems[key][0]?.displayInputValue.initValue != treatCondItems[key][0]?.displayInputValue.editValue)||(treatCondItems[key][0].treatItemCd === "28" && this.checkDisabled) || (["28"].includes(treatCondItems[key][0].treatItemCd) && coagulantAmountTotalHiddenFlg) || (["26", "27"].includes(treatCondItems[key][0].treatItemCd) && coagulantAmountAndRateIsHidden && this.facilitySettingAnticoagulantDefaultValue === 1))) {
        // mod #10150 shiyw 2024-09-09 start
        // 治療条件中の透析液、補液を一括変更し、かつ変更前後の小数位が異なる場合、変更前後が小数位だけ変化し、すなわち値が等しい（例えば2.00＝＝＝2）場合、透析液使用数（17）、補液使用数（22）、ワショー量（26）、持続速度（27）、持続総量（28）は一括変更すべきではない
        let amountFlg = true;
        if (structData?.editOnly && ["17", "22", "26", "27", "28"].includes(treatCondItems[key][0]?.treatItemCd) && parseFloat(treatCondItems[key][0]?.displayInputValue.initValue) == parseFloat(treatCondItems[key][0]?.displayInputValue.editValue)) {
          amountFlg = false;
        }
        if (treatCondItems[key][0]
          // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
          // && amountFlg
          && (amountFlg ||(treatCondItems[key][0].treatItemCd === "28" && this.checkDisabled))
          // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end
          && (
            (structData&&!structData.editOnly)
            ||(treatCondItems[key][0]?.displayInputValue.initValue != treatCondItems[key][0]?.displayInputValue.editValue)
            ||(treatCondItems[key][0].treatItemCd === "28" && this.checkDisabled)
            || (["28"].includes(treatCondItems[key][0].treatItemCd) && coagulantAmountTotalHiddenFlg)
            || (["26", "27"].includes(treatCondItems[key][0].treatItemCd) && coagulantAmountAndRateIsHidden && this.facilitySettingAnticoagulantDefaultValue === 1)
          )
        ) {
        // mod #10150 shiyw 2024-09-09 start
        // #10196 切り替え補液,補液使用数小桁未更新です linjunfeng end
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
        /* modify by chamaojia 2023-04-13 [8537] 指定項目の判定条件の追加  --end */
          //mod 6646 ng  抗凝固剤持続総量を登録できない 張 end
        //mod FNSI-改修内容 redmine 4880 4882 劉祥霖 end
            indInfo = {
              ...indInfo,
              ...treatCondItems[key][0].createRequestData(structData)
            };
            // add #7880 帳票：ラベルが正しく表示されない 日本指摘対応 商 start
            if (treatCondItems[key][0].treatItemCd === "17" ||
                treatCondItems[key][0].treatItemCd === "22" ||
                treatCondItems[key][0].treatItemCd === "28") {
              let decPoint = treatCondItems[key][0].decPoint
              if (decPoint > 0) {
                let value = treatCondItems[key][0].value
                // mod #7194 2022/11/25 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 dou start
                // indInfo[treatCondItems[key][0].treatItemCd].value = value.toFixed(decPoint)
                if (value) {
                  //modify by liuzhibo 2022-11-28[5482]患者経過総合ビューアのデータ変更及び登録を伴う操作がすべてフリーズするの修正 -- start /
                  //indInfo[treatCondItems[key][0].treatItemCd].value = value.toFixed(decPoint)
                  indInfo[treatCondItems[key][0].treatItemCd].value = parseFloat(value).toFixed(decPoint)
                  //modify by liuzhibo 2022-11-28[5482]患者経過総合ビューアのデータ変更及び登録を伴う操作がすべてフリーズするの修正 -- end /
                }
                // add #IES_6483 dou start
                indInfo[treatCondItems[key][0].treatItemCd].decPoint = decPoint;
                // add #IES_6483 dou end
                // mod #7194 2022/11/25 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 dou end
              }
            }
            // add #7880 帳票：ラベルが正しく表示されない 日本指摘対応 商 end
          }
        //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
        //}
        //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
        //add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 start
        /* modify by chamaojia 2023-10-27 [9973] 判定条件が欠落している、エラー  --start */
        if (treatCondItems[key][0] && treatCondItems[key][0].checkEditCount()) {
          if (treatCondItems[key][0].treatItemCd === "9") {
            isHaveNeedleA = true;
          }
          if (treatCondItems[key][0].treatItemCd === "10") {
            isHaveNeedleV = true;
          }
          if (treatCondItems[key][0].treatItemCd === "11") {
            isHaveNeedleSN = true;
          }
          if (treatCondItems[key][0].treatItemCd === "12") {
            isHaveNeedleSelected = true;
            if (treatCondItems[key][0].inputValue === 0) {
              isUsed = true;
            }
          }
        }
        /* modify by chamaojia 2023-10-27 [9973] 判定条件が欠落している、エラー  --end */
        //add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 end
      });
      //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 start
      let indCondInfo = {};
      //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 end
      //add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 start
      if (this.settingIndData.headerTitle === "治療条件" || this.settingIndData.headerTitle === "穿刺針情報編集") {
        let ordMainData = this.ordMainData();
        ordMainData = ordMainData[moment(structData.indStartDate).format("YYYYMMDD")];
        // mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 start
        // const indCondInfo = ordMainData ? JSON.parse(ordMainData.indCondInfo) : null;
        indCondInfo = ordMainData ? JSON.parse(ordMainData.indCondInfo) : null;
        // mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 end
        if (isHaveNeedleSelected) {
          /* modify by chamaojia 2023-10-27 [9973] ノードがなくても補充が必要 --start */
          if (isUsed) {
            // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zkm start
            //if (!isHaveNeedleA && indCondInfo[9].value !=null) {
            //   if (!isHaveNeedleA && indCondInfo[9] && indCondInfo[9].value !=null) {
            // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zkm end
            if (!isHaveNeedleA) {
              indInfo = {
                ...indInfo,
                ...this.createNullRequestData("9", indCondInfo[9] && indCondInfo[9].value ? indCondInfo[9].value : null,structData)
              };
            }
            // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zkm start
            //if (!isHaveNeedleV && indCondInfo[10].value !=null) {
            //   if (!isHaveNeedleV && indCondInfo[10] && indCondInfo[10].value !=null) {
            // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zkm end
            if (!isHaveNeedleV) {
              indInfo = {
                ...indInfo,
                ...this.createNullRequestData("10",indCondInfo[10] && indCondInfo[10].value ? indCondInfo[10].value : null,structData)
              };
            }
          } else {
            // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zkm start
            //if (!isHaveNeedleSN && indCondInfo[11].value !=null) {
            //   if (!isHaveNeedleSN && indCondInfo[11] && indCondInfo[11].value !=null) {
            // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zkm end
            if (!isHaveNeedleSN) {
              indInfo = {
                ...indInfo,
                ...this.createNullRequestData("11",indCondInfo[11] && indCondInfo[11].value ? indCondInfo[11].value : null,structData)
              };
            }
          }
          /* modify by chamaojia 2023-10-27 [9973] ノードがなくても補充が必要 --end */
        }
      }
      //add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 start

      // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
      //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
      // if (this.settingIndData.headerTitle === "治療条件") {
      //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
        //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 start
        // let ordMainData = this.ordMainData();
        // ordMainData = ordMainData[moment(structData.indStartDate).format("YYYYMMDD")];
        // const indCondInfo = ordMainData ? JSON.parse(ordMainData.indCondInfo) : null;
        //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 end
        //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
        // if (indCondInfo) {
        //   let indInfoTmp = {};
          //if (!answer || answer === 2) {
            // 指示値を入力していない場合 或いは 表示内容を更新対象の内容に切り替える。
            // for (let i = 1;i <= this.componentNames.length;i++) {
            //   if (indCondInfo[i]) {
            //     const ind = {
            //       [String(i)]: {
            //       value : indCondInfo[i].value,
            //       value_name_1 : null,
            //       unit : null,
            //       medicine_type : (null != indCondInfo[i].medicine_type && undefined != indCondInfo[i].medicine_type) ? indCondInfo[i].medicine_type : null,
            //       ind_user_id : structData.indUser,
            //       ind_user_last_name : null,
            //       ind_user_first_name : null,
            //       upd_user_id : structData.updUser,
            //       upd_user_last_name : null,
            //       upd_user_first_name : null,
            //       input_class : null,
            //       is_editable : null,
            //       cop_order_no : 1,
            //       isAmountchg : true,
            //       init_value : indCondInfo[i].value,
            //       }
            //     };
            //     indInfoTmp = {
            //       ...indInfoTmp,
            //       ...ind
            //     };
            //   }
            // }
            // indInfo = deepCopy(indInfoTmp);
          // }else if (answer === 3) {
          //   for (let i = 1;i <= this.componentNames.length;i++) {
          //     let tmpValue = null;
          //     let tmpInitValue = null;
          //     let tmpmedicineType = null;
          //     let tempisAmountchg = true;
          //     if (!indCondInfo[i] && !indInfo[i]) {
          //       continue;
          //     }
          //     if (indCondInfo[i]) {
          //       tmpValue = indCondInfo[i].value;
          //       tmpInitValue = indCondInfo[i].value;
          //       tmpmedicineType = indCondInfo[i].medicine_type;
          //     }
          //     if (indInfo[i]) {
          //       if (indInfo[i].value !== indInfo[i].init_value) {
          //         tmpValue = indInfo[i].value;
          //         tmpInitValue = indInfo[i].init_value;
          //         tmpmedicineType = indInfo[i].medicine_type;
          //         tempisAmountchg = false;
          //       }
          //     }
          //     const ind = {
          //       [String(i)]: {
          //       value : tmpValue,
          //       value_name_1 : null,
          //       unit : null,
          //       medicine_type : (null != tmpmedicineType && undefined != tmpmedicineType) ? tmpmedicineType : null,
          //       ind_user_id : structData.indUser,
          //       ind_user_last_name : null,
          //       ind_user_first_name : null,
          //       upd_user_id : structData.updUser,
          //       upd_user_last_name : null,
          //       upd_user_first_name : null,
          //       input_class : null,
          //       is_editable : null,
          //       cop_order_no : 1,
          //       isAmountchg : tempisAmountchg,
          //       init_value : tmpInitValue,
          //       }
          //     };
          //     indInfoTmp = {
          //       ...indInfoTmp,
          //       ...ind
          //     };
          //   }
          //   indInfo = deepCopy(indInfoTmp);
          // }
      //   } else {
      //     return;
      //   }
      // }
      //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
      // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end

      // 条件送信用データ
      let sendConditionInfo = {};
      Object.keys(treatCondItems).forEach(key => {
        //mod FNSI-改修内容 redmine 4880 4882 劉祥霖 start
        if (treatCondItems[key][0] && (!structData.editOnly||treatCondItems[key][0].checkEditCount())) {
        //mod FNSI-改修内容 redmine 4880 4882 劉祥霖 end
          sendConditionInfo = {
            ...sendConditionInfo,
            ...treatCondItems[key][0].createAddData()
          };
        }
      });
      // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
      // これ以降の処理を終了してメッセージ表示
      if (this.hasIP(indInfo)) {
        if (this.validateIP(indInfo)) {
          // IP電源自動切り時間 > IP電源OKモニタ切時間場合
          console.log("IndActionChart.vue updateInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
      }

      // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
      if (!this.checkDisabled && this.hasAntiCoagulantAmountTotal(indInfo)) {
        let ordMainData = this.ordMainData();
        ordMainData = ordMainData[moment(structData.indStartDate).format("YYYYMMDD")];
        var ordMainCondInfo = ordMainData ? JSON.parse(ordMainData.indCondInfo) : null;
        if (this.validateAntiCoagulantAmountTotal(indInfo, ordMainCondInfo)) {
          await this.$ons.notification.alert({
            title: DIALOG_MESSAGES[10400014].title,
            message: messageFormat(DIALOG_MESSAGES[10400014].message),
          });
        }
      }
      // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end

      // 使用期限のチェック
      if (!await this.chkInExpiryDate(structData.indStartDate, structData.indEndDate, indInfo)) {
        console.log("IndActionChart.vue updateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
      const indInfoObjectKey = Object.keys(indInfo);
      if (this.facilitySettingAnticoagulantDefaultValue === 1) {
        if (!this.asTotalAmountIsShow && indInfoObjectKey.includes("25")) {
          this.answerFlg += "2";
        }
        if (!this.antiCoagulantAmountIsShow && indInfoObjectKey.includes("25")) {
          this.answerFlg += "8";
        }
        if (!this.antiCoagulantFlowRateIsShow && indInfoObjectKey.includes("25")) {
          this.answerFlg += "9";
        }
        if (this.answerFlg != "0") {
          this.answerFlg = this.answerFlg.replace('0', '')
        }
      }

      // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
      const sendJson = {
        // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
        // OK/Cancel(OK:"1", Cancel:"0")
        answer_Flg: this.answerFlg,
        quantity_before: this.antiCoagulantQuantity.before,
        quantity_after: this.antiCoagulantQuantity.after,
        // 表示計算項目コード
        accountItem_Cd: this.accountItemCd,
        // チェックボックス
        checkBox_Flg: this.checkDisabled,
        // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
        // 施設コード
        facility_cd: this.facilityCd,
        // 患者ID
        pat_id: structData.patId,
        // 治療開始日
        ind_start_date: structData.indStartDate,
        // 治療終了日
        ind_end_date: structData.indEndDate,
        // 曜日パターン
        week_pattern: JSON.stringify(structData.indWeeks),
        // 変更対象クールコード
        ind_kur_cd: JSON.stringify(structData.selectedKur),
        // 変更対象治療方法コード
        ind_treatment_cd: JSON.stringify(structData.selectedTreat),
        // 変更対象データ
        ind_cond_info: JSON.stringify(indInfo),
        // 終了日存在フラグ
        is_deadline: structData.isDeadline,
        // add 10150_9664 by kangjie 20240628 start
        // noIv、onLine、offLine
        ind_treat_cond_iv_mode: this.newIndTreatCondIvMode,
        // add 10150_9664 by kangjie 20240628 end
        // 条件送信用追加データ
        send_condition_info: JSON.stringify(sendConditionInfo),
        // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
        // 実績更新フラグ
        is_rst_update: false,
        // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
        //mod FNSI-6782 劉全航 start
        header_title: this.settingIndData.headerTitle,
        user_id: this.getStateUserAccountInfo.userId,
        //mod FNSI-6782 劉全航 end
        //add #10266 start
        update_flag: this.settingIndData.update_flag
        //add #10266 end
      };

      // 古いリスト
      const startDate = structData.indStartDate.replace(/-/g, '');
      const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      const searchData = await ApiHelper.get(
        `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('IndActionChart.vue', 'updateInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        console.log("IndActionChart.vue updateInfo throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });
      this.oldOrdMainList = searchData.data;
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
      let weekList = [];
      structData.indWeeks.forEach(eleItem => {
        if (eleItem.done === true) {
          weekList.push(parseInt(eleItem.value));
        }
      });

      if (this.oldOrdMainList) {
        // 実績があるフラグ
        let rstState = "0";
        try {
        this.oldOrdMainList.forEach(item => {
          const isSelectedTreat = structData.selectedTreat.length > 0 ? structData.selectedTreat.includes(parseInt(item.indTreatmentCd)) : true;
          const isSelectedKur = structData.selectedKur.length > 0 ? structData.selectedKur.includes(parseInt(item.indKurCd)) : true;
          const isTreatWeek = weekList.length > 0 ? weekList.includes(parseInt(item.treatWeek)) : true;
          if(item.rstDialysisState !=="0" && isSelectedTreat && isSelectedKur && isTreatWeek) {
            rstState = item.rstDialysisState;
            throw new Error("Exit Loop");
          }
        });
        }catch (e){
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('IndActionChart.vue', 'updateInfo', e);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        }
        if (rstState !=="0") {
          if (await this.showUpdateCheckDialog(rstState)) {
            sendJson.is_rst_update = true;
          }
        }
      }
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
      const response = await ApiHelper.post(
        "/mainData/updateOrdMainInfo/",
        sendJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('IndActionChart.vue', 'updateInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        console.log("IndActionChart.vue updateInfo throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });
      // add 10553 連携イベント発生部分不正 関  start
      let returnFlg = false;
      // add 10553 連携イベント発生部分不正 関  end
      // mod FNSI-連携イベントの登録適正化 楊 start
      if (200 === response.status) {
        //mod FNSI-6590 劉全航 start
        this.oldOrdMainList.forEach(async ordMain => {
          if(ordMain.rstDialysisState !== "0") {
            const tempOrdNo = ordMain.ordNo;
            // 装置マスタの取得
            this.getMstMachineByOrdNoRst(tempOrdNo).then(machineRes => {
              let mstMachine = machineRes.data;
              if (mstMachine.length > 0){
                ApiHelper.get(
                  `/master_maintenance/mst_comsv_setting/data/${structData.facilityCd}`
                ).then((response) =>
                  {
                    let diviceEgeList = response.data.localDataSource.data;
                    let diviceEge = diviceEgeList.find(o =>{
                      return o.deviceEdgeNo == mstMachine[0].deviceEdgeNo;
                    });
                    let npatItem = JSON.parse(diviceEge.lcdNpat).npat_item;
                    let codeList = npatItem.map(o=>{
                      return o.code;
                    });
                    let vaFlag = false;
                    if(codeList.includes(9) && indInfo[2]){
                      vaFlag = indInfo[2].init_value != indInfo[2].value;
                    }
                    let treatTimeFlag = false;
                    if(codeList.includes(12) && indInfo[1]){
                      treatTimeFlag = indInfo[1].init_value != indInfo[1].value;
                    }
                    let dialayzerFlag = false;
                    if(codeList.includes(14) && indInfo[5]){
                      dialayzerFlag = indInfo[5].init_value != indInfo[5].value;
                    }
                    let aNeedleFlag = false;
                    if(codeList.includes(15) && indInfo[9]){
                      aNeedleFlag = indInfo[9].init_value != indInfo[9].value;
                    }
                    let vNeedleFlag = false;
                    if(codeList.includes(16) && indInfo[10]){
                      vNeedleFlag = indInfo[10].init_value != indInfo[10].value;
                    }
                    let anticoagulant = false;
                    if(codeList.includes(17) && indInfo[25]){
                      anticoagulant = indInfo[25].init_value != indInfo[25].value;
                    }
                    let flag1 = false;
                    //抗凝固剤ワンショット量
                    if(codeList.includes(18) && indInfo[26]){
                      flag1 = indInfo[26].init_value != indInfo[26].value;
                    }
                    let flag2 = false;
                    //抗凝固剤持続注入量
                    if(codeList.includes(19) && indInfo[27]){
                      flag2 = indInfo[27].init_value != indInfo[27].value;
                    }
                    //抗凝固剤持続総量
                    let flag3 = false;
                    if(codeList.includes(20) && indInfo[28]){
                      flag3 = indInfo[28].init_value != indInfo[28].value;
                    }
                    if(vaFlag || treatTimeFlag ||dialayzerFlag||aNeedleFlag||vNeedleFlag||anticoagulant|| flag1 || flag2 || flag3){
                      const params = {
                        ordNo: tempOrdNo, //オーダー番号
                        machineNo: mstMachine[0].machineNo, //装置マスタ.装置番号
                        deviceEdgeNo: mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
                        facilityCd: this.facilityCd //施設コード
                      };
                      this.sendNextPatInfoViewer(params);
                    }
                  }
                ).catch(error => {
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
                  getErrorMessage('IndActionChart.vue', 'updateInfo', '送信失敗しました。');
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
                  console.log("IndActionChart.vue updateInfo throw error ")
                  this.finishLoadingScreen();
                  throw error;
                });
              }
              //add FNSI-7870 ljx start
              const paramsTreatTime = {
                ordNo: tempOrdNo, //オーダー番号
                machineNo: mstMachine[0].machineNo, //装置マスタ.装置番号
                deviceEdgeNo: mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
                facilityCd: this.facilityCd //施設コード
              };
              if(indInfo[1]){
                if(indInfo[1].init_value != indInfo[1].value){
                  this.sendRequestChangeTreatTime(paramsTreatTime);
                }

              }
              //add FNSI-7870 ljx end
            });
          }
        });
        //mod FNSI-6590 劉全航 end

      }

      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      // mod 10553 連携イベント発生部分不正 関  start
      // if (200 === response.status && undefined !== response.data.msglist && 0 < response.data.msglist.length) {
      if (200 === response.status && undefined !== response.data.msglist && 0 < response.data.msglist.length && !returnFlg) {
        // mod 10553 連携イベント発生部分不正 関  end
        let msgList = response.data.msglist;
        let messages = "";
        msgList.length && msgList.forEach(item => {
          messages = messages + this.messageInfo(item) + "<br>";
        })
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 start-->
        // this.$ons.notification.alert({
        //   title: "",
        //   message: messages,
        //   callback: answer => {
        //   if (answer == 0) {
        //     //OK
        //      // モーダルを閉じる
        //      //this.$parent.$parent.$emit("hide-modal");
        //   }
        // }
        // });
        this.$parent.$parent.messageDialogInfo.messageCd = 12000000;
        //mod #10154_#10183 zhao start
        //this.$parent.$parent.messageDialogInfo.title = "注意";
        this.$parent.$parent.messageDialogInfo.title = "指示組合せ注意";
        //mod #10154_#10183 zhao end
        this.$parent.$parent.messageDialogInfo.type = "1";
        this.$parent.$parent.messageDialogInfo.stringParams = [messages];
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        console.log("IndActionChart.vue updateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        // mod 10553 連携イベント発生部分不正 関  start
        // return;
        returnFlg = true;
        // mod 10553 連携イベント発生部分不正 関  end
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 end-->
      }
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      // mod FNSI-連携イベントの登録適正化 楊 end
      // mod 10553 連携イベント発生部分不正 関  start
      // if (200 === response.status && undefined !== response.data.msgCd) {
      if (200 === response.status && undefined !== response.data.msgCd && !returnFlg) {
        // mod 10553 連携イベント発生部分不正 関  end
        // add FNSI-FutreNetWeb+SI課題管理No.4704 李 start
        // mod #8178 条件送信後に治療条件を変更した際のメッセージ不正 dou start
        // if (response.data.msgCd == '22020003') this.$parent.$parent.messageDialogInfo.title = '変更確認';
        // mod 11169 治療時間を長時間として指示変更した場合に、ダミースケジュールの衝突があると、不正な治療時間で更新してしまう。 関 start
        // if ([22020003, 22020007, 22020008].includes(response.data.msgCd)) {
        //   this.$parent.$parent.messageDialogInfo.title = '変更確認';
        // }
        this.$parent.$parent.messageDialogInfo.title = DIALOG_MESSAGES[response.data.msgCd].title;
        // mod 11169 治療時間を長時間として指示変更した場合に、ダミースケジュールの衝突があると、不正な治療時間で更新してしまう。 関 end
        // mod #8178 条件送信後に治療条件を変更した際のメッセージ不正 dou end
        // add FNSI-FutreNetWeb+SI課題管理No.4704 李 end
        this.$parent.$parent.messageDialogInfo.messageCd = response.data.msgCd;
        this.$parent.$parent.messageDialogInfo.type = "1";
        this.$parent.$parent.messageDialogInfo.stringParams = [""];
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        // 処理終了
        console.log("IndActionChart.vue updateInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        // mod 10553 連携イベント発生部分不正 関  start
        // return;
        returnFlg = true;
        // mod 10553 連携イベント発生部分不正 関  end
      }

      // ビューア画面の治療時間モーダルより治療時間を修正し保存した時
      // mod FNSI-連携イベントの登録適正化 楊 start
      // const params = {
      //   facility_cd: this.facilityCd,
      //   coop_cd: "ind_dial",
      //   coop_cd_index: "",
      //   crud: "U",
      //   direction: "S",
      //   ana_result:"0",
      //   coop_result:"0",
      //   pat_id : structData.patId,
      //   ord_no : this.settingIndData.ordNo,
      //   user_id: this.getStateUserAccountInfo.userId
      // };
      // if (this.settingIndData.ordNo) {
      //    createJournal(params);
      // } else {
      //   if (this.oldOrdMainList) {
      //     this.oldOrdMainList.forEach(item => {
      //       const isSelectedTreat = structData.selectedTreat.includes(item.indTreatmentCd);
      //       const isSelectedKur = structData.selectedKur.includes(item.indKurCd);
      //       if (structData.selectedKur.length > 0) {
      //         if (isSelectedKur) {
      //            createJournal({...params, ord_no: item.ordNo});
      //         }
      //       } else {
      //         if (structData.selectedTreat.length > 0) {
      //           if (isSelectedTreat) {
      //             createJournal({...params, ord_no: item.ordNo});
      //           }
      //         } else {
      //           createJournal({...params, ord_no: item.ordNo});
      //         }
      //       }
      //     });
      //   }
      // }
      // mod FNSI-連携イベントの登録適正化 楊 end
      //del #10553 治療条件変更連携送信不正 関 start
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
      // if (200 === response.status) {
      //   // del #11004 連携イベント発生部分不正 piao start
      //   // this.valModSendClass = await this.getSchModifySendClass();
      //   // del #11004 連携イベント発生部分不正 piao end

      //   let JournalList = [];
      //   if (this.oldOrdMainList) {
      //     let opeCd = "";
      //     switch (this.settingIndData.headerTitle) {
      //       case "治療条件":
      //         opeCd = "004010";
      //         break;
      //       case "治療時間編集":
      //         opeCd = "004011";
      //         break;
      //       case "VA編集":
      //         opeCd = "004012";
      //         break;
      //       case "身体情報":
      //         opeCd = "004013";
      //         break;
      //       case "DW/目標体重/除水量制限編集":
      //         opeCd = "004014";
      //         break;
      //       case "ダイアライザ/吸着カラム編集":
      //         opeCd = "004015";
      //         break;
      //       case "1次膜/2次膜編集":
      //         opeCd = "004016";
      //         break;
      //       case "穿刺針情報編集":
      //         opeCd = "004017";
      //         break;
      //       case "血液回路編集":
      //         opeCd = "004018";
      //         break;
      //       case "血流量編集":
      //         opeCd = "004019";
      //         break;
      //       case "透析液情報編集":
      //         opeCd = "004020";
      //         break;
      //       case "補液情報編集":
      //         opeCd = "004021";
      //         break;
      //       case "抗凝固剤情報編集":
      //         opeCd = "004022";
      //         break;
      //       case "目標体重編集":
      //         opeCd = "013004";
      //         break;
      //       case "除水量制限編集":
      //         opeCd = "013005";
      //         break;
      //       default:
      //         break;
      //     }
      //     for (let i = 0; i < this.oldOrdMainList.length; i++) {
      //       const item = this.oldOrdMainList[i];
      //       // mod #10553 連携イベント発生部分不正 piao start
      //       // if (item.indKurCd && (0 !== item.indKurCd)) {
      //       if (item.indKurCd && (0 !== item.indKurCd) && (item.rstDialysisState === "0" || this.settingIndData.update_flag != "2")) {
      //       // mod #10553 連携イベント発生部分不正 piao end
      //         // del #11004 連携イベント発生部分不正 piao start
      //         // if ( this.valModSendClass == 2 ) {
      //         //   // 削除
      //         //   JournalList.push({
      //         //     ope_cd: opeCd,
      //         //     crud: "D",
      //         //     facility_cd: structData.facilityCd,
      //         //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //         //     pat_id: structData.patId,
      //         //     ord_no: item.ordNo,
      //         //     base_date: item.treatDate,
      //         //     user_id: this.getStateUserAccountInfo.userId
      //         //   });
      //         //   // 追加
      //         //   JournalList.push({
      //         //     ope_cd: opeCd,
      //         //     crud: "C",
      //         //     facility_cd: structData.facilityCd,
      //         //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //         //     pat_id: structData.patId,
      //         //     ord_no: item.ordNo,
      //         //     base_date: item.treatDate,
      //         //     user_id: this.getStateUserAccountInfo.userId
      //         //   });
      //         // }
      //         // else {
      //         // del #11004 連携イベント発生部分不正 piao end
      //           // 変更対象クールが未登録ではない、治療方法編集
      //           JournalList.push({
      //             ope_cd: opeCd,
      //             crud: "U",
      //             facility_cd: structData.facilityCd,
      //             hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //             pat_id: structData.patId,
      //             ord_no: item.ordNo,
      //             base_date: item.treatDate,
      //             user_id: this.getStateUserAccountInfo.userId
      //           });
      //         // del #11004 連携イベント発生部分不正 piao start
      //         // }
      //         // del #11004 連携イベント発生部分不正 piao end
      //       }
      //     }
      //     // createJournalList(JournalList);
      //   }
      // }
      //del #10553 治療条件変更連携送信不正 関 end
      // add 10553 連携イベント発生部分不正 関  start
      if (returnFlg) {
        return;
      }
      // add 10553 連携イベント発生部分不正 関  end
      // add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
      EventBus.$emit("isRefresh");
      console.log("IndActionChart.vue updateInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
      // モーダルを閉じる
      this.$parent.$parent.$emit("hide-modal");
    },

    //add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 start
    /**
     * @description リクエスト用NULLデータ作成
     */
    createNullRequestData(cd,init_value,structData) {
      const indInfo = {
        [cd]: {
          value: null,
          value_name_1: null,
          unit: null,
          medicine_type: null,
          ind_user_id: structData.indUser,
          ind_user_last_name: null,
          ind_user_first_name: null,
          upd_user_id: structData.updUser,
          upd_user_last_name: null,
          upd_user_first_name: null,
          input_class: null,
          is_editable: null,
          cop_order_no: 1,
          isAmountchg: false,
          init_value: init_value
        }
      };
      return indInfo;
    },
    //add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.56(外結)対応 韓 end

        //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
    /**
     * 定義ファイルから対応するメッセージコードの文字列を取得
     * @param {object} メッセージコード
     */
    messageInfo(messageCd) {
      // 定義ファイルから対応するメッセージコードの文字列を取得
      const message = DIALOG_MESSAGES[messageCd].message;
      if (message === undefined) {
        return "メッセージが定義されていません。";
      }
      // パラメータ文字列を置換
      let replacedMessage = message;

      // 改行文字列をbrタグに置換
      replacedMessage = replacedMessage.replace(/\n/g, "<br>");
      return replacedMessage;
    },
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
    // 条件送信以降の場合、実績の変更をするか確認する。
    async showUpdateCheckDialog(rstState) {
        let rtn = false;
        // rst_dialisys_stateが3,4,5,6の場合
        //8178 mod 条件送信後に治療条件を変更した際のメッセージ不正 張 end
        // let msg = "治療中または治療終了した治療の治療条件を変更しました。<br>" +
        // "この変更では透析装置送信されません、手動で設定してください。<br>" +
        // "実績データへの反映をしますか？"
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        let msg = messageFormat(DIALOG_MESSAGES[13000045].message);
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        if (rstState === "1") {
          // rst_dialisys_stateが1の場合
        //   msg = "条件送信済み治療の治療条件を変更しました。<br>" +
        // "この変更では透析装置送信されません、改めて条件送信をするか手動で設定してください。<br>" +
        // "実績データへの反映をしますか？"
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          msg = messageFormat(DIALOG_MESSAGES[13000046].message);
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        }
        if (rstState === "2") {
          // rst_dialisys_stateが2の場合
        //   msg = "条件送信済み治療の治療条件を変更しました。<br>" +
        // "この変更では透析装置送信されません、確認ボタンを解除して条件送信をするか手動で設定してください。<br>" +
        // "実績データへの反映をしますか？"
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          msg = messageFormat(DIALOG_MESSAGES[13000047].message);
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        }
        if (rstState === "3") {
          // rst_dialisys_stateが3の場合
          // mod #8178 条件送信後に治療条件を変更した際のメッセージ不正 dou start
          // msg = "治療中の患者の指示が変更されました。指示を確認して、必要があれば処置してください。"
          // msg = "治療中または治療終了した治療の治療条件を変更しました。<br>" +
          //   "この変更では透析装置送信されません、手動で設定してください。<br>" +
          //   "実績データへの反映をしますか？"
          // mod #8178 条件送信後に治療条件を変更した際のメッセージ不正 dou end
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          msg = messageFormat(DIALOG_MESSAGES[13000045].message);
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        }
        if (rstState === "4") {
          // rst_dialisys_stateが4の場合
          // mod #8178 条件送信後に治療条件を変更した際のメッセージ不正 dou start
          // msg = "治療を終了した患者の指示が変更されました。指示を確認して、必要があれば処置してください。"
          // msg = "治療中または治療終了した治療の治療条件を変更しました。<br>" +
          //   "この変更では透析装置送信されません、手動で設定してください。<br>" +
          //   "実績データへの反映をしますか？"
          // mod #8178 条件送信後に治療条件を変更した際のメッセージ不正 dou end
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          msg = messageFormat(DIALOG_MESSAGES[13000045].message);
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        }
          // rst_dialisys_stateが1,2の場合
          //mod #10266 start
          if (this.settingIndData.update_flag != "2" && (rstState != "5"||rstState != "6")) {
          // if (rstState != "5"||rstState != "6") {
          //mod #10266 end
            await this.$ons.notification.confirm({
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
              // title: "実績への反映確認",
              title: DIALOG_MESSAGES[13000045].title,
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
              message: msg,
              callback: answer => {
                if (answer === 1) {
                  rtn = true;
                }
              }
            });
              }
      //8178 mod 条件送信後に治療条件を変更した際のメッセージ不正 張 end
        return rtn;
    },
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end

    // 使用期限のチェック
    async chkInExpiryDate(indStartDate, indEndDate, indInfo) {
      let msg = "";
      const keyList = Object.keys(indInfo);
      keyList.forEach(key => {
        switch (Number(key)) {
          case 5: {
            // ダイアライザ
            const tmpDialyzerObj = this.$store.getters["pat-viewer/getMstDialyzerData"].filter(dialyzer => dialyzer.dialyzerCd == indInfo[key].value); // mod #9973 value Number→文字列  shiyw
            if (tmpDialyzerObj.length === 0) {
              break;
            }
            const dialyzerObj = tmpDialyzerObj[0];
            if (!fitTermCheckForUpdate(dialyzerObj.useStartDate, dialyzerObj.useEndDate, indStartDate, indEndDate)) {
              msg += "</br>" + dialyzerObj.modelNumber + "："
                  + dateFormat.normalDateWithCheck(dialyzerObj.useStartDate)
                  + "～" + dateFormat.normalDateWithCheck(dialyzerObj.useEndDate);
            }
            break;
          }
          case 6:
          case 7:
          case 8:
          case 9:
          case 10:
          case 11:
          case 13: {
            // 吸着カラム/1次膜/2次膜/穿刺針(A/V/SN)/血液回路
            if (!indInfo[key].value) {
              // シングルニードル使用の有無を変更した場合に該当
              break;
            }
            const tmpEquipmentObj = this.$store.getters["pat-viewer/getMstEquipmentData"].filter(equipment => equipment.equipmentCd == indInfo[key].value);// mod #9973 value Number→文字列  shiyw
            if (tmpEquipmentObj.length === 0) {
              break;
            }
            const equipmentObj = tmpEquipmentObj[0];
            if (!fitTermCheckForUpdate(equipmentObj.useStartDate, equipmentObj.useEndDate, indStartDate, indEndDate)) {
              msg += "</br>" + equipmentObj.equipmentName + "："
                  + dateFormat.normalDateWithCheck(equipmentObj.useStartDate)
                  + "～" + dateFormat.normalDateWithCheck(equipmentObj.useEndDate);
            }
            break;
          }
          case 15:
          case 19:
          case 25: {
            // 薬剤/調製薬剤項目
            // mod #9973 shiyw start
            //if (indInfo[key].medicine_type === "1") {
            if (indInfo[key].medicine_type == 1) {
              // mod #9973 shiyw end
              // 薬剤の場合
              const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineData"].filter(medi => medi.medicineCd == indInfo[key].value); // mod #9973 value Number→文字列  shiyw
              if (tmpMediObj.length === 0) {
                break;
              }
              const mediObj = tmpMediObj[0];
              if (!fitTermCheckForUpdate(mediObj.useStartDate, mediObj.useEndDate, indStartDate, indEndDate)) {
                msg += "</br>" + mediObj.medicineName + "："
                    + dateFormat.normalDateWithCheck(mediObj.useStartDate)
                    + "～" + dateFormat.normalDateWithCheck(mediObj.useEndDate);
              }
              // mod #9973 shiyw start
              //} else if (indInfo[key].medicine_type === "2") {
            } else if (indInfo[key].medicine_type == 2) {
              // mod #9973 shiyw end
              // 調製薬剤の場合
              const tmpMediObj = this.$store.getters["pat-viewer/getMstMedicineMixTabooAllergyData"].filter(medi => medi.medicineMixCd == indInfo[key].value); // mod #9973 value Number→文字列  shiyw
              if (tmpMediObj.length === 0) {
                break;
              }
              const mediObj = tmpMediObj[0];
              if (!fitTermCheckForUpdate(mediObj.maxUseStartDate, mediObj.minUseEndDate, indStartDate, indEndDate)) {
                msg += "</br>" + mediObj.medicineMixName + "："
                    + dateFormat.normalDateWithCheck(mediObj.maxUseStartDate)
                    + "～" + dateFormat.normalDateWithCheck(mediObj.minUseEndDate);
              }
            }
            break;
          }
        }
      });
      if (msg) {
        let rtn = false;
        const parentObj = this.$parent.$parent;
        // 処理中スクリーンを一旦解除
        this.$parent.$parent.isUpdating = false;
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000049].title,
          // message: "指示期間に使用期間外となる治療条件が含まれています。" + msg + "</br>登録してよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000049].message,msg),
           // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              // 処理を続行するので処理中スクリーンを復帰
              parentObj.isUpdating = true;
              rtn = true;
            } else {
              // 処理を中止するので保存ボタン無効を解除
              parentObj.updateDisable = false;
            }
          }
        });
        return rtn;
      } else {
        // チェック対象項目なし / 期限切れ項目なしの場合
        return true;
      }
    },

    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
    isEdit() {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応#9809 20260210 huanshuai start
      let newcom = JSON.parse(JSON.stringify(this.componentData))
      let isChange = false
      newcom.forEach((ele,index)=>{
        if(ele.fields.value == null && ele.fields.velue == -1 && (this.oldcomponentData[index].fields.value == -1)){
          ele.fields.value = "-1"
        }
        else if(ele.fields.value == -1 && ele.fields.velue == null){
          ele.fields.value = null
        }
        if(normalizeValue(ele.fields.value) !== normalizeValue(this.oldcomponentData[index].fields.value)){
          isChange = true;
        }
      })
      return isChange;
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応#9809 20260210 huanshuai end
      
      // const treatCondItems = this.$refs;
      // let editCount = 0;
      // Object.keys(treatCondItems).forEach(key => {
      //   if (treatCondItems[key][0]) {
      //     // 変更箇所数格納
      //     editCount += treatCondItems[key][0].checkEditCount();
      //   }
      // });
      // if (0 === editCount) {
      //   // mod #12249 治療条件変更の高速化 zkm start
      //   if (this.componentData.filter(item => [20, 24].includes(item.cd) && item.fields.value !== item.fields.velue).length > 0) {
      //     return true;
      //   }
      //   // mod #12249 治療条件変更の高速化 zkm end
      //   return false;
      // }
      // return true;
    },

    /**
     * 変更チェック
     * @description 治療条件の編集内容に応じてメッセージを表示
     * @param num 0->保存ボタンクリック時 1->キャンセルボタンクリック時
     * @return showMessage trueを返した場合、呼び出し元で処理を終了する
     */
    //mod FNSI-改修内容 redmine 4880 4882 劉祥霖 start
    checkIsEdit(num,structData) {
      const treatCondItems = this.$refs;
      let editCount = 0;
      //add 6646 ng  抗凝固剤持続総量を登録できない 張 start
        let same=false;
        // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
        // if(this.componentNames[0].name == "ind-treat-anti-coagulant"){
      if(this.componentNames[0].name == "ind-treat-anti-coagulant" && !this.checkDisabled){
        // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end
        let total=null;
            if (!this.isIpAutoOff) {
            total = (this.getAntiCoagulantFlowRate * this.treatTime) / 60;
            } else {
            total =
                this.getAntiCoagulantFlowRate *
                ((this.treatTime - this.getIpAutoOffTiming) / 60);
            }
            total = isNaN(total) ? null : total;
            // #9302 抗凝固剤持続総量を非表示にした患者経過総合ビューアレイアウトを使用した状態で治療条件の抗凝固剤を編集すると共通ローダが終わらない linjunfeng start
            // if (this.componentNames.find(item => {return item.cd==28}).fields.value == total) {
            if (this.componentNames.find(item => {return item.cd==28})?.fields.value == total) {
            // #9302 抗凝固剤持続総量を非表示にした患者経過総合ビューアレイアウトを使用した状態で治療条件の抗凝固剤を編集すると共通ローダが終わらない linjunfeng end
              same=true
            }
      }
      //add 6646 ng  抗凝固剤持続総量を登録できない 張 end
      Object.keys(treatCondItems).forEach(key => {
        if (treatCondItems[key][0]) {
          // 変更箇所数格納
          //mod 6646 ng  抗凝固剤持続総量を登録できない 張 start
          // if(!structData.editOnly||treatCondItems[key][0].checkEditCount()){
             if(!structData.editOnly||treatCondItems[key][0].checkEditCount()||(this.checkDisabled&&!same)){
          //mod 6646 ng  抗凝固剤持続総量を登録できない 張 end
            editCount++;
          }
        }
      });
      // メッセージ表示、表示切替
      let showMessage = false;
      // メッセージコード
      let messageCd = null;
      // メッセージタイプ
      let messageType = null;
      // 初期値と変更値に相違無し
      if (0 === editCount) {
        // 保存時チェックの場合メッセージ表示
        if (0 === num) {
          // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
          //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
          // if (this.settingIndData.headerTitle === "治療条件") {
          //   return true;
          // }
          //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
          // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end
          showMessage = true;
          messageCd = 20010003;
          messageType = "1";
        }
      } else {
        // キャンセルチェックの場合メッセージ表示
        if (1 === num) {
          showMessage = true;
          messageCd = 20010001;
          messageType = "2";
        }
      }
      this.$parent.$parent.messageDialogInfo.messageCd = messageCd;
      this.$parent.$parent.messageDialogInfo.type = messageType;
      this.$parent.$parent.messageDialogInfo.isDialogVisible = showMessage;
      return showMessage;
    },
    //mod FNSI-改修内容 redmine 4880 4882 劉祥霖 end
    /**
     * 変更チェック
     * @description 治療条件の編集内容に応じてメッセージを表示
     * @param num 0->保存ボタンクリック時 1->キャンセルボタンクリック時
     * @return showMessage trueを返した場合、呼び出し元で処理を終了する
     */
    checkEdit(num) {
      const treatCondItems = this.$refs;
      let editCount = 0;
      Object.keys(treatCondItems).forEach(key => {
        if (treatCondItems[key][0]) {
          editCount += treatCondItems[key][0].checkEditCount();
        }
      });
      // メッセージ表示、表示切替
      let showMessage = false;
      // メッセージコード
      let messageCd = null;
      // メッセージタイプ
      let messageType = null;
      // 初期値と変更値に相違無し
      if (0 === editCount) {
        // 保存時チェックの場合メッセージ表示
        if (0 === num) {
          // add FNSI-【1006】最新の改修対象一覧の679対応 韓 start
          //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
          // if (this.settingIndData.headerTitle === "治療条件") {
          //   return true;
          // }
          //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
          // add FNSI-【1006】最新の改修対象一覧の679対応 韓 end
          showMessage = true;
          messageCd = 20010003;
          messageType = "1";
        }
      } else {
        // キャンセルチェックの場合メッセージ表示
        if (1 === num) {
          showMessage = true;
          messageCd = 20010001;
          messageType = "2";
        }
      }
      this.$parent.$parent.messageDialogInfo.messageCd = messageCd;
      this.$parent.$parent.messageDialogInfo.type = messageType;
      this.$parent.$parent.messageDialogInfo.isDialogVisible = showMessage;
      return showMessage;
    },
    // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
    /**
     * 非表示項目チェック
     * @description 非表示にした項目に応じてメッセージを表示
     * @param indInfoShow 表示項目
     * @param structData 補液情報
     * @return showMessage trueを返した場合、呼び出し元で処理を終了する
     */
    // mod FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
    // itemCheckDisabled(indInfoShow) {
    async itemCheckDisabled(indInfoShow, structData) {
      //add FNSI redmine 5161 劉祥霖 start
      //画面に非表示項目を取得
      this.selectedLayout = this.getDispLayoutItemListData.find(item => {
        return item.dispPeriodClass === "0";
      });
      if(this.getDispLayoutItemListData && this.getSelectedCondition && this.getSelectedCondition.setSelectedLayoutCd){
        this.selectedLayout = this.getDispLayoutItemListData.find(ele => {
          return this.getSelectedCondition.setSelectedLayoutCd === ele.layoutCd;});
      }else {
        const defaultCondition = deepCopy(this.getDefaultSetting[KEY_NAME_PAT_VIEWER.KEY_NAME]);
        if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
          const selectedLayoutCd = defaultCondition[KEY_NAME_PAT_VIEWER.KEY_NAME_SELECTED_LAYOUT_CD];
          this.selectedLayout = this.getDispLayoutItemListData.find(item => {
            return item.layoutCd === selectedLayoutCd;
          });
        }
      }
      // add FutreNetWeb+SI課題管理No7219 趙 start
      if(this.selectedLayout !== undefined && this.selectedLayout !== null) {
      // add FutreNetWeb+SI課題管理No7219 趙 end
        const treatCond = this.selectedLayout.dispItemInfo.find(item => item.component == 'treatment-contents').categoryItem.find(item => item.component == 'treat-cond');
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
        if (treatCond.subCategoryItem.find(item => item.itemNo == '26') == undefined) {
          this.antiCoagulantAmountIsShow = false;
        }
        if (treatCond.subCategoryItem.find(item => item.itemNo == '27') == undefined) {
          this.antiCoagulantFlowRateIsShow = false;
        }
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
        if (treatCond.subCategoryItem.find(item => item.itemNo == '28') == undefined) {
          this.asTotalAmountIsShow = false;
        }
        if (treatCond.subCategoryItem.find(item => item.itemNo == '31') == undefined) {
          this.IPOneShotAmountIsShow = false;
        }
        if (treatCond.subCategoryItem.find(item => item.itemNo == '32') == undefined) {
          this.IPSpeedIsShow = false;
        }
      }
      //add FNSI redmine 5161 劉祥霖 end

      // 血流量項目数
      let deviceItemCont = 0;
      // mod FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
      // 透析液項目数
      let dialysateItemCont = 0;
      // 補液項目数
      let ivItemCont = 0;
      // 抗凝固剤項目数
      let coagulantItemCont = 0;
      // 計算項目
      this.accountItemCd = 0;
      this.answerFlg = "";
      // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
      //let itemName = '';
      let itemName = [];
      structData["treatOptions"].forEach(eleItem => {
        let mstDevRecord = this.getMstTreatmentData.find(mstData => {
          return mstData.treatmentCd === eleItem.value;
         });
        if (mstDevRecord) {
          itemName.push(mstDevRecord.deviceMode);
        }
      });

      // 変更対象治療方法取得
      let selectedTreatItem =[];
      for (let i = 0;i <= structData.selectedTreat.length;i++) {
        // 装置モードをマスタから取得
        let mstRecord = this.getMstTreatmentData.find(mstData => {
          return mstData.treatmentCd === structData.selectedTreat[i];
         });
        if (mstRecord) {
          selectedTreatItem.push(mstRecord.deviceMode);
        }
      }

      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
      // 血流量
      let itemMsgCd_14 = '';
      // 透析温度
      let itemMsgCd_18 = '';
      // 補液量
      let itemMsgCd_20 = '';
      // 補液速度
      let itemMsgCd_24 = '';
      // 血流量
      let itemNumber_14 = null;
      // 透析温度
      let itemNumber_18 = null;
      // 補液量
      let itemNumber_20 = null;
      // 補液選択
      let itemNumber_21 = null;
      // 補液速度
      let itemNumber_24 = null;
      // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end

      Object.keys(indInfoShow).forEach(key => {
        switch (Number(key)) {
          // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
          case 14:
            deviceItemCont++;
            itemMsgCd_14 = "Key_14_HDF";
            itemNumber_14 = indInfoShow[key].value;
            break;
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
          // del FNSI-FutreNetWeb+SI課題管理の3816対応 韓 start
          // case 15:
          // case 16:
          // case 17:
          // del FNSI-FutreNetWeb+SI課題管理の3816対応 韓 end
          case 18:
            /**
             *  15->透析液、16->透析液流量、17->透析液使用数、18->透析液温度
             */
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
            itemMsgCd_18 = "Key_18_HDF";
            itemNumber_18 = indInfoShow[key].value;
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
            dialysateItemCont++;
            break;
          case 19:
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
            ivItemCont++;
            break;
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
          case 20:
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
            //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
            //itemName = structData.treatOptions[0].text;
            //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
            itemNumber_20 = indInfoShow[key].value;
            // 治療法：HDF、HF、AFBFの場合
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
            //if ('HDF' === itemName || 'HF' === itemName || 'AFBF' === itemName) {
            if ((selectedTreatItem.length > 0 &&
            (selectedTreatItem.includes(DEVICEMODE.HDF) || selectedTreatItem.includes(DEVICEMODE.HF) || selectedTreatItem.includes(DEVICEMODE.AFBF))) ||
            (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.HDF) || itemName.includes(DEVICEMODE.HF) || itemName.includes(DEVICEMODE.AFBF)))) {
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
              // 補液量の設定値が30.0を超える時、上限を超えている旨のメッセージを通知
              if (itemNumber_20 > 30.0) {
                itemMsgCd_20 = "Key_20_HDF";
              } else {
                itemMsgCd_20 = '';
              }
              // 治療法：OHDF、OHFの場合
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
            //} else if ('OHDF' === itemName || 'OHF' === itemName) {
            } else if ((selectedTreatItem.length > 0 &&
            (selectedTreatItem.includes(DEVICEMODE.OHDF) || selectedTreatItem.includes(DEVICEMODE.OHF))) ||
            (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.OHDF) || itemName.includes(DEVICEMODE.OHF)))) {
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
              itemMsgCd_20 = "Key_20_OHDF";
            } else {
              itemMsgCd_20 = '';
            }
            ivItemCont++;
            break;
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
          case 21:
            itemNumber_24 = this.componentData[5].fields.value
            //add FNSI-5532 劉全航 start
            if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.OHDF)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.OHDF)))) {
              itemMsgCd_24 = "Key_24_OHDF";
            } else if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.OHF)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.OHF)))) {
              itemMsgCd_24 = "Key_24_OHF";
            } else if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.HDF)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.HDF)))) {
              itemMsgCd_24 = "Key_24_HDF";
            } else if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.HF)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.HF)))) {
              itemMsgCd_24 = "Key_24_HF";
            } else if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.HD)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.HD)))) {
              itemMsgCd_24 = "Key_24_HD";
            } else {
              itemMsgCd_24 = '';
            }
            //add FNSI-5532 劉全航 end
            itemNumber_21 = indInfoShow[key].value;
            ivItemCont++;
            break;
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
          case 22:
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
            ivItemCont++;
            break;
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
          case 23:
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
            ivItemCont++;
            break;
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
          case 24:
            /**
             * 19->補液、20->補液量、21->補液選択、22->補液使用数、
             * 23->補液温度、24->補液速度
             */
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
            //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
            // itemName = structData.treatOptions[0].text;
            //del FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
            itemNumber_24 = indInfoShow[key].value;
            // 治療法：HDF、HF、OHDF、OHFの場合
            // mod FNSI-【1006】最新の改修対象一覧の412対応 韓 start
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
            //if('OHDF' === itemName) {
            if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.OHDF)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.OHDF)))) {
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
            // mod FNSI-【1006】最新の改修対象一覧の412対応 韓 end
              itemMsgCd_24 = "Key_24_OHDF";
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
            //} else if( 'OHF' === itemName) {
            } else if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.OHF)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.OHF)))) {
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
              itemMsgCd_24 = "Key_24_OHF";
            // mod FNSI-【5532】障害票一覧_患者経過総合ビューア.xlsx 高 start
            } else if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.HDF)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.HDF)))) {
              itemMsgCd_24 = "Key_24_HDF";
            } else if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.HF)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.HF)))) {
              itemMsgCd_24 = "Key_24_HF";
            } else if ((selectedTreatItem.length > 0 &&
              selectedTreatItem.includes(DEVICEMODE.HD)) ||
              (selectedTreatItem.length === 0 && (itemName.includes(DEVICEMODE.HD)))) {
              itemMsgCd_24 = "Key_24_HD";
            } else {
              itemMsgCd_24 = '';
            }
            // mod FNSI-【5532】障害票一覧_患者経過総合ビューア.xlsx 高 end
            // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
            ivItemCont++;
            break;
          //5161 start
          //治療時間が変化する場合
          case 1:
            if(this.asTotalAmountIsShow==false){
              this.asTotalAmountChange=true;
            }
            break;
          //抗凝固剤持続速度が変化する場合
          case 27:
            if(this.asTotalAmountIsShow==false){
              this.asTotalAmountChange=true;
            }
            if(this.IPSpeedIsShow==false&&this.isIpUse){
            this. IPSpeedChange=true;
            }
            break;
          //IP電源自動切り時間が変化する場合
          case 36:
            if(this.asTotalAmountIsShow==false&&this.isIpAutoOff&&this.isIpUse){
              this.asTotalAmountChange=true;
            }
            break;
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
          case 25:
            if (this.facilitySettingAnticoagulantAutoValue === 1) {
              if(this.IPOneShotAmountIsShow==false&&this.isIpUse){
                this.IPOneShotAmountChange=true;
              }
              if(this.asTotalAmountIsShow==false){
                this.asTotalAmountChange=true;
              }
              if(this.IPSpeedIsShow==false&&this.isIpUse){
              this. IPSpeedChange=true;
              }
            }
            break;
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          case 26:
            if(this.IPOneShotAmountIsShow==false&&this.isIpUse){
              this. IPOneShotAmountChange=true;
            }
            break;
          case 28:
            // /**
            //  * 28->抗凝固剤持続総量
            //  */
            // // 抗凝固剤持続総量表示の場合
            // this.accountItemCd = 1;
            // break;
          case 31:
            // /**
            //  * 31->IPワンショット量
            //  */
            // // 抗凝固剤持続総量非表示の場合
            // if (this.accountItemCd === 0) {
            //   this.accountItemCd = 2;
            //   // 抗凝固剤持続総量とIPワンショット量表示の場合
            // } else if (this.accountItemCd === 1) {
            //   this.accountItemCd = 4;
            // }
            // break;
          case 32:
            // /**
            //  * 32->IP速度
            //  */
            // // 抗凝固剤持続総量とIPワンショット量非表示の場合
            // if (this.accountItemCd === 0) {
            //   this.accountItemCd = 3;
            //   // 抗凝固剤持続総量表示、IPワンショット量非表示の場合
            // } else if (this.accountItemCd === 1) {
            //   this.accountItemCd = 5;
            //   // 抗凝固剤持続総量非表示、IPワンショット量表示の場合
            // } else if (this.accountItemCd === 2) {
            //   this.accountItemCd = 6;
            //   // 抗凝固剤持続総量とIPワンショット量表示の場合
            // } else if (this.accountItemCd === 4) {
            //   this.accountItemCd = 7;
            // }
            // break;
          //mod FNSI redmine 5161劉祥霖 end
          case 25:

          case 29:
          case 30:
          case 33:
          case 34:
          // del #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
          // case 35:
          // del #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          case 37:
          case 38:
            /**
             * 25->抗凝固剤、26->抗凝固剤ワンショット量、27->抗凝固剤時速速度
             * 29->IP使用選択、30->IPスタート、33->IP速度最大値
             * 34->IPワンショットスタート、35->IP電源自動切、36->IP電源自動切時間
             * 37->IP電源OKモニタ切、38->IP電源OKモニタ切時間
             */
            coagulantItemCont++;
            break;
          // add #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
          case 35:
            if(this.asTotalAmountIsShow==false){
              this.asTotalAmountChange=true;
            }
            coagulantItemCont++;
            break;
          // del #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          default:
            break;
        }
      });

      // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
      // 血流量
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
      //if (itemMsgCd_14 !== '') {
      if (itemMsgCd_14 !== '' && this.$parent.$parent.itemMsgCd14Flg) {
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
        itemMsgCd_14 = await this.getItemMsgCd(structData, itemNumber_14, null, itemMsgCd_14);
        if ('Key_14_HDF' === itemMsgCd_14) {
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
          //this.$parent.$parent.messageDialogInfo.messageCd = "00400011";
          //this.$parent.$parent.messageDialogInfo.type = "1";
          this.$parent.$parent.messageDialogInfo.title = "血流量上限チェック"
          this.$parent.$parent.messageDialogInfo.messageCd = 10400011;
          this.$parent.$parent.messageDialogInfo.type = "2";
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          return true;
        }
      }
      // 透析液温度
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
      //if (itemMsgCd_18 !== '') {
      if (itemMsgCd_18 !== '' && this.$parent.$parent.itemMsgCd18Flg) {
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
        itemMsgCd_18 = await this.getItemMsgCd(structData, itemNumber_18, null, itemMsgCd_18);
        if ('Key_18_HDF' === itemMsgCd_18) {
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
          //this.$parent.$parent.messageDialogInfo.messageCd = "00400012";
          //this.$parent.$parent.messageDialogInfo.type = "1";
          this.$parent.$parent.messageDialogInfo.messageCd = 10400012;
          // mod FNSI-FutreNetWeb+SI課題管理No.5528 李 start
          // this.$parent.$parent.messageDialogInfo.title = "透析液温度上限チェック"
          this.$parent.$parent.messageDialogInfo.title = "透析液温度の確認"
          // mod FNSI-FutreNetWeb+SI課題管理No.5528 李 end
          this.$parent.$parent.messageDialogInfo.type = "2";
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          return true;
        }
      }
      // 補液量
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
      //if (itemMsgCd_20 !== '') {
      if (itemMsgCd_20 !== '' && this.$parent.$parent.itemMsgCd20Flg) {
        this.$parent.$parent.messageDialogInfo.title = "補液量上限チェック"
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
        if ('Key_20_HDF' === itemMsgCd_20) {
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
          //this.$parent.$parent.messageDialogInfo.messageCd = "00400008";
          //this.$parent.$parent.messageDialogInfo.type = "1";
          this.$parent.$parent.messageDialogInfo.messageCd = 10400008;
          this.$parent.$parent.messageDialogInfo.type = "2";
          //mod FNSI-5532 劉全航 start
          let stringParams = structData.initTreatOptions[0].text;
          let length = structData.initTreatOptions.length;
          if(length > 1){
            for(let i = 1; i < length; i ++){
              stringParams = stringParams.concat("、", structData.initTreatOptions[i].text);
            }
          }
          this.$parent.$parent.messageDialogInfo.stringParams = [stringParams];
          //mod FNSI-5532 劉全航 end
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          return true;
        } else if ('Key_20_OHDF' === itemMsgCd_20) {
          itemMsgCd_20 = await this.getItemMsgCd(structData, itemNumber_20, null, itemMsgCd_20);
          if ('Key_20_OHDF' === itemMsgCd_20) {
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
            //this.$parent.$parent.messageDialogInfo.messageCd = "00400009";
            //this.$parent.$parent.messageDialogInfo.type = "1";
            this.$parent.$parent.messageDialogInfo.messageCd = 10400009;
            this.$parent.$parent.messageDialogInfo.type = "2";
            //mod FNSI-5532 劉全航 start
            let stringParams = structData.initTreatOptions[0].text;
            let length = structData.initTreatOptions.length;
            if(length > 1){
              for(let i = 1; i < length; i ++){
                stringParams = stringParams.concat("、", structData.initTreatOptions[i].text);
              }
            }
            this.$parent.$parent.messageDialogInfo.stringParams = [stringParams];
            //mod FNSI-5532 劉全航 end
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
            this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
            return true;
          }
        }
      }
      // 補液速度
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
      //if (itemMsgCd_24 !== '' && itemNumber_21 !== null) {
      // add FNSI-FutreNetWeb+SI課題管理No.4642 李 start
      const treatCondItems = this.$refs;
      let chooseValueList = '';
      let chooseValue = '';
      if (treatCondItems[2] && treatCondItems[2][0]) {
        chooseValueList = treatCondItems[2][0].createRequestData(structData);
      }
      if (chooseValueList && chooseValueList[21]) {
        chooseValue = chooseValueList[21].value;
      }
      // add FNSI-FutreNetWeb+SI課題管理No.4642 李 end

      // mod FNSI-FutreNetWeb+SI課題管理No.4642 李 start
      // if (itemMsgCd_24 !== '' && itemNumber_21 !== null && this.$parent.$parent.itemMsgCd24Flg) {
      if (itemMsgCd_24 !== '' && chooseValue !== null && this.$parent.$parent.itemMsgCd24Flg) {
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
        itemMsgCd_24 = await this.getItemMsgCd(structData, itemNumber_24, chooseValue, itemMsgCd_24);
        if ('Key_24_SPEED' === itemMsgCd_24) {
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
          //this.$parent.$parent.messageDialogInfo.messageCd = "00400010";
          //this.$parent.$parent.messageDialogInfo.type = "1";
          // add FNSI-FutreNetWeb+SI課題管理No.5528 李 start
          // upd No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc start
          // this.$parent.$parent.messageDialogInfo.title = "補液速度の確認"
          this.$parent.$parent.messageDialogInfo.title = "補液速度上限チェック"
          // upd No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc end
          // add FNSI-FutreNetWeb+SI課題管理No.5528 李 end
          this.$parent.$parent.messageDialogInfo.messageCd = 10400010;
          this.$parent.$parent.messageDialogInfo.type = "2";
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          return true;
        }
      }
      // mod FNSI-FutreNetWeb+SI課題管理No.4642 李 end
      // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
      // メッセージ表示、表示切替
      let showMessage = false;
      // メッセージコード
      let messageCd = null;
      // メッセージタイプ
      let messageType = null;

      // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
      // 血流量以外の場合
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.34,35(外結)対応 韓 start
      //del FNSI redmine 5161劉祥霖 start
      // if (this.settingIndData.headerTitle === "抗凝固剤情報編集") {
      //   // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
      //   // 透析液項目
      //   // if (dialysateItemCont > 0 && dialysateItemCont < 4) {
      //   //   showMessage = true;
      //   //   messageCd = "00400001";
      //   //   messageType = "1";
      //   //   // 補液
      //   // } else if (ivItemCont > 0 && ivItemCont < 6) {
      //   //   showMessage = true;
      //   //   messageCd = "00400001";
      //   //   messageType = "1";
      //   //   // 抗凝固剤
      //   // } else if (dialysateItemCont === 0 && ivItemCont === 0 &&
      //   //           (this.accountItemCd >= 0 || coagulantItemCont >= 0)) {
      //     // 計算項目を非表示にした場合
      //     if (this.accountItemCd >= 0 && this.accountItemCd < 7) {
      //       showMessage = true;
      //       //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
      //       //messageCd = "00400002";
      //       messageCd = 10400002;
      //       //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end
      //       messageType = "2";
      //       this.itemDisplayFlg = true;
      //     }
      //del FNSI redmine 5161劉祥霖 end
      //add FNSI redmine 5161劉祥霖 start
      if (this.settingIndData.headerTitle === "治療条件"||this.settingIndData.headerTitle === "治療条件編集"||this.settingIndData.headerTitle === "抗凝固剤情報編集") {
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
        // if (this.asTotalAmountChange==true) {
        if (this.asTotalAmountChange==true && this.facilitySettingAnticoagulantAutoValue === 1) {
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          showMessage = true;
          messageCd = 10400003;
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
          // messageType = "2";
          messageType = "1";
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          this.itemDisplayFlg = true;
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
        // }else if (this.IPOneShotAmountChange==true) {
        }else if (this.IPOneShotAmountChange==true && this.facilitySettingAnticoagulantAutoValue === 1) {
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          showMessage = true;
          messageCd = 10400004;
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
          // messageType = "2";
          messageType = "1";
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          this.itemDisplayFlg = true;
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
        // }else if (this.IPOneShotAmountChange==true) {
        }else if (this.IPOneShotAmountChange==true && this.facilitySettingAnticoagulantAutoValue === 1) {
        // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          showMessage = true;
          messageCd = 10400005;
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
          // messageType = "2";
          messageType = "1";
          // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
          this.itemDisplayFlg = true;
        }
      }


      //add FNSI redmine 5161劉祥霖 end
          // 項目を非表示にした場合
          // if (coagulantItemCont < 11) {
          //   showMessage = true;
          //   messageCd = "00400001";
          //   messageType = "1";
          // }
        //}

        if (messageCd !== null) {
          this.$parent.$parent.messageDialogInfo.messageCd = messageCd;
          this.$parent.$parent.messageDialogInfo.type = messageType;
          this.$parent.$parent.messageDialogInfo.isDialogVisible = showMessage;
          return true;
        // del FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
        // } else {
        //   return false;
        // del FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
        }else{
          return false;
        }
      // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start
      //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.34,35(外結)対応 韓 end

      // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
    },
    // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
    // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 start

    // mod FNSI-【1006】最新の改修対象一覧の412対応 韓 start
    // async getItemMsgCd(structData, itemNumber, itemNumber_21, itemMsgCd) {
    //   const searchData = await ApiHelper.get(
    //     `/mainData/getByPatIdAndOrdNo/${structData.patId}`
    //   ).catch(error => {
    //     throw error;
    //   });

    //   const ordTreatCondition = searchData.data.map(t => {
    //     return {
    //       receive_date: t.receive_date,
    //       treat_condition: JSON.parse(t.treat_condition),
    //       treat_class: t.treat_class
    //     };
    //   });

    //   if (ordTreatCondition.length === 0) {
    //     return '';
    //   }

    //   let itemValue = '';
    //   let healthmonFacilityConn = ordTreatCondition[0].treat_condition;
    //   let itemName_14_Max = null;
    //   let itemName_18_Max = null;
    //   let itemName_20_Max = null;
    //   let itemHDF_24_Max = null;
    //   let itemHF_24_Max = null;
    //   let itemOHDF_24_Max = null;
    //   let itemOHF_24_Max = null;

    //   for (var key in healthmonFacilityConn) {
    //     // 後補液 補液速度操作範囲上限（HDF）
    //     if (key === '31' && itemNumber_21 === 0) {
    //       itemHDF_24_Max = healthmonFacilityConn[key];
    //       // 後補液 補液速度操作範囲上限（HF）
    //     } else if (key === '32' && itemNumber_21 === 0) {
    //       itemHF_24_Max = healthmonFacilityConn[key];
    //       // 後補液 補液速度操作範囲上限（OHDF）
    //     } else if (key === '34' && itemNumber_21 === 0) {
    //       itemOHDF_24_Max = healthmonFacilityConn[key];
    //       // 後補液 補液速度操作範囲上限（OHF）
    //     } else if (key === '35' && itemNumber_21 === 0) {
    //       itemOHF_24_Max = healthmonFacilityConn[key];
    //       // 血流量操作範囲上限
    //     }  else if (key === '179') {
    //       itemName_14_Max = healthmonFacilityConn[key];
    //       // 装置設定→操作範囲→血流量操作範囲の設定値を超える時
    //       if (itemNumber > itemName_14_Max) {
    //         return "Key_14_HDF";
    //       }
    //       // 透析液温度操作範囲上限
    //     } else if (key === '182') {
    //       itemName_18_Max = healthmonFacilityConn[key];
    //       // 装置設定→操作範囲→透析液温度操作範囲の設定値を超える時
    //       if (itemNumber > itemName_18_Max) {
    //         return "Key_18_HDF";
    //       }
    //       // 前補液 補液速度操作範囲上限（HDF）
    //     } else if (key === '185' && itemNumber_21 === 1) {
    //       itemHDF_24_Max = healthmonFacilityConn[key];
    //       // 前補液 補液速度操作範囲上限（HF）
    //     } else if (key === '186' && itemNumber_21 === 1) {
    //       itemHF_24_Max = healthmonFacilityConn[key];
    //       // 補液量設定値制限（OHDF・OHF用）
    //     } else if (key === '383' && itemNumber_21 === null) {
    //       itemName_20_Max = healthmonFacilityConn[key];
    //       // OHDF/OHF補液計算優先項目選択
    //     } else if (key === '389') {
    //       itemValue = healthmonFacilityConn[key];
    //       // 補液比率と濾過率から算出を以外の場合
    //       if (itemValue !== 2 && itemValue !== 3) {
    //         // 補液未選択
    //         if (itemNumber_21 === null) {
    //           // 装置設定→操作範囲→補液量設定値制限の設定値を超える時
    //           if ("Key_20_OHDF" === itemMsgCd) {
    //             if (itemNumber > itemName_20_Max) {
    //               return "Key_20_OHDF";
    //             }
    //           }
    //         } else {
    //           // 装置設定→操作範囲→補液速度の設定値を超える時
    //           if ("Key_24_HDF" === itemMsgCd && itemNumber > itemHDF_24_Max) {
    //             return "Key_24_HDF";
    //           } else if ("Key_24_HF" === itemMsgCd && itemNumber > itemHF_24_Max) {
    //             return "Key_24_HDF";
    //           } else if ("Key_24_OHDF" === itemMsgCd && itemNumber > itemOHDF_24_Max) {
    //             return "Key_24_HDF";
    //           } else if ("Key_24_OHF" === itemMsgCd && itemNumber > itemOHF_24_Max) {
    //             return "Key_24_HDF";
    //           }
    //         }
    //       } else {
    //         // 装置設定→操作範囲→補液計算優先項目にて「補液比率」、「濾過率から算出」が設定されている場合
    //         // 装置設定→操作範囲→補液速度の設定値を超える時
    //         if ("Key_24_HDF" === itemMsgCd && itemNumber > itemHDF_24_Max) {
    //           return "Key_24_HDF";
    //         } else if ("Key_24_HF" === itemMsgCd && itemNumber > itemHF_24_Max) {
    //           return "Key_24_HDF";
    //         }
    //       }
    //       // 前補液 補液速度操作範囲上限（OHDF）
    //     } else if (key === '396') {
    //       itemOHDF_24_Max = healthmonFacilityConn[key];
    //       // 補液比率と濾過率から算出を以外の場合
    //       if (itemValue !== 2 && itemValue !== 3) {
    //         if (itemNumber > itemOHDF_24_Max) {
    //           return "Key_24_HDF";
    //         }
    //       }
    //       // 前補液 補液速度操作範囲上限（OHF）
    //     } else if (key === '397') {
    //       itemOHF_24_Max = healthmonFacilityConn[key];
    //       // 補液比率と濾過率から算出を以外の場合
    //       if (itemValue !== 2 && itemValue !== 3) {
    //         if (itemNumber > itemOHF_24_Max) {
    //           return "Key_24_HDF";
    //         }
    //       }
    //     }
    //   }

    //   return '';
    // },

    async getItemMsgCd(structData, itemNumber, itemNumber_21, itemMsgCd) {
      const deviceSetInfo = await getDeviceSetInfoPat(structData.patId).catch(
          error => {
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('IndActionChart.vue', 'getItemMsgCd', error);
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            throw new Error(error);
          }
        );

      if (!deviceSetInfo) {
        return '';
      }

      let itemValue = '';
      const healthmonFacilityConn = Object.assign(deviceSetInfo.ope.dev.A,deviceSetInfo.ope.dev.B);
      let itemName_14_Max = null;
      let itemName_18_Max = null;
      let itemName_20_Max = null;
      let itemOHDF_24_Max = null;
      let itemOHF_24_Max = null;
      for (var key in healthmonFacilityConn) {
        //del 5532 操作範囲＞補液速度が反映されない 張 start
        // add FNSI-FutreNetWeb+SI課題管理No.5528 李 start
        // // OHDFかつ、前補液の場合
        // if (key === '396' && '1' == itemNumber_21 && 'Key_24_OHDF' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }

        // // OHDFかつ、後補液の場合
        // if (key === '34' && '0' == itemNumber_21 && 'Key_24_OHDF' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }

        // // HDFかつ、前補液の場合
        // if (key === '185' && '1' == itemNumber_21 && 'Key_24_HDF' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }

        // // HDFかつ、後補液の場合
        // if (key === '31' && '0' == itemNumber_21 && 'Key_24_HDF' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }

        // // HFかつ、前補液の場合
        // if (key === '186' && '1' == itemNumber_21 && 'Key_24_HF' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }

        // // HFかつ、後補液の場合
        // if (key === '32' && '0' == itemNumber_21 && 'Key_24_HF' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }

        // // HD+補液かつ、前補液の場合
        // if (key === '30' && '1' == itemNumber_21 && 'Key_24_HD' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }

        // // HD+補液かつ、後補液の場合
        // if (key === '33' && '0' == itemNumber_21 && 'Key_24_HD' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }

        // // OHFかつ、前補液の場合
        // if (key === '397' && '1' == itemNumber_21 && 'Key_24_OHF' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }

        // // OHFかつ、後補液の場合
        // if (key === '35' && '0' == itemNumber_21 && 'Key_24_OHF' == itemMsgCd) {
        //   itemOHDF_24_Max = healthmonFacilityConn[key];
        //   if (itemNumber > itemOHDF_24_Max) {
        //     return "Key_24_SPEED";
        //   }
        // }
        // add FNSI-FutreNetWeb+SI課題管理No.5528 李 end
        //del 5532 操作範囲＞補液速度が反映されない 張 end

        // mod FNSI-FutreNetWeb+SI課題管理No.4642 李 start
        // if (key === '34' && itemNumber_21 === 0) {
        if (key === '34' && itemNumber_21 == '0' && 'Key_24_OHDF' === itemMsgCd) {// mod #9973 value Number→文字列  shiyw
        // mod FNSI-FutreNetWeb+SI課題管理No.4642 李 end
          itemOHDF_24_Max = healthmonFacilityConn[key];
          if (itemNumber > itemOHDF_24_Max) {
            //mod 5532 操作範囲＞補液速度が反映されない 張 start
            // return "Key_24_HDF";
            return "Key_24_SPEED";
            //mod 5532 操作範囲＞補液速度が反映されない 張 end
          }

        // 後補液 補液速度操作範囲上限（OHF）
        // mod FNSI-FutreNetWeb+SI課題管理No.4642 李 start
        // } else if (key === '35' && itemNumber_21 === 0) {
        } else if (key === '35' && itemNumber_21 == '0' && 'Key_24_OHF' === itemMsgCd) {// mod #9973 value Number→文字列  shiyw
        // mod FNSI-FutreNetWeb+SI課題管理No.4642 李 end
          itemOHF_24_Max = healthmonFacilityConn[key];
          if (itemNumber > itemOHF_24_Max) {
            //mod 5532 操作範囲＞補液速度が反映されない 張 start
            // return "Key_24_HDF";
            return "Key_24_SPEED";
            //mod 5532 操作範囲＞補液速度が反映されない 張 end
          }

          // 血流量操作範囲上限
        } else if (key === '179' && 'Key_14_HDF' === itemMsgCd) {
          itemName_14_Max = healthmonFacilityConn[key];
          // 装置設定→操作範囲→血流量操作範囲の設定値を超える時
          if (itemNumber > itemName_14_Max) {
            return "Key_14_HDF";
          }
          // 透析液温度操作範囲上限
        } else if (key === '182' && 'Key_18_HDF' === itemMsgCd) {
          itemName_18_Max = healthmonFacilityConn[key];
          // 装置設定→操作範囲→透析液温度操作範囲の設定値を超える時
          if (itemNumber > itemName_18_Max) {
            return "Key_18_HDF";
          }
        // add FNSI-FutreNetWeb+SI課題管理No.5528 李 start
        // 透析液温度操作範囲下限
        } else if (key === '183' && 'Key_18_HDF' === itemMsgCd) {
          itemName_18_Max = healthmonFacilityConn[key];
          if (itemNumber < itemName_18_Max) {
            return "Key_18_HDF";
          }
        // add FNSI-FutreNetWeb+SI課題管理No.5528 李 end
        } else if (key === '383' && itemNumber_21 === null) {
          itemName_20_Max = healthmonFacilityConn[key];
          // OHDF/OHF補液計算優先項目選択
        } else if (key === '389') {
          itemValue = healthmonFacilityConn[key];
          // 補液比率と濾過率から算出を以外の場合
          if (itemValue !== '2' && itemValue !== '3') {
            // 補液未選択
            if (itemNumber_21 === null) {
              // 装置設定→操作範囲→補液量設定値制限の設定値を超える時
              if ("Key_20_OHDF" === itemMsgCd) {
                if (itemNumber > itemName_20_Max) {
                  return "Key_20_OHDF";
                }
              }
            } else {
              if (itemValue === '1') {
                // 補液量設定算出の場合
                if ("Key_24_OHDF" === itemMsgCd && itemOHDF_24_Max && itemNumber > itemOHDF_24_Max) {
                  return "Key_24_HDF";
                } else if ("Key_24_OHF" === itemMsgCd && itemOHF_24_Max && itemNumber > itemOHF_24_Max) {
                  return "Key_24_HDF";
                }
              }
            }
          }
        // mod FNSI-FutreNetWeb+SI課題管理No.4642 李 start
        // } else if (key === '396') {
            // upd No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc start
        } else if (key === '396' && 'Key_24_OHDF' === itemMsgCd && itemNumber_21 == '1' ) {// mod #9973 value Number→文字列  shiyw
          // upd No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc end
          itemOHDF_24_Max = healthmonFacilityConn[key];
          // 補液量設定算出の場合
          // if (itemValue === '1') {
          // upd No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc start
          if (itemNumber > itemOHDF_24_Max) {
            //mod 5532 操作範囲＞補液速度が反映されない 張 start
            // return "Key_24_HDF";
            return "Key_24_SPEED";
            //mod 5532 操作範囲＞補液速度が反映されない 張 end
          }
          // upd No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc end
          // 前補液 補液速度操作範囲上限（OHF）
        // } else if (key === '397') {
        } else if (key === '397' && 'Key_24_OHF' === itemMsgCd && itemNumber_21 == '1') {// mod #9973 value Number→文字列  shiyw
          // mod FNSI-FutreNetWeb+SI課題管理No.4642 李 end
          itemOHF_24_Max = healthmonFacilityConn[key];
          // 補液量設定算出の場合
          // upd No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc start
          // if (itemValue === '1') {
          if (itemNumber > itemOHF_24_Max) {
            //mod 5532 操作範囲＞補液速度が反映されない 張 start
            // return "Key_24_HDF";
            return "Key_24_SPEED";
            //mod 5532 操作範囲＞補液速度が反映されない 張 end
          }
          // }
          // upd No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc end
        }
        //add FNSI-5532 劉全航 start
        // HFかつ、前補液の場合
        else if (key === '186' && '1' == itemNumber_21 && 'Key_24_HF' == itemMsgCd) {// mod #9973 value Number→文字列  shiyw
          itemOHDF_24_Max = healthmonFacilityConn[key];
          if (itemNumber > itemOHDF_24_Max) {
            return "Key_24_SPEED";
          }
          // HFかつ、後補液の場合
        }else if (key === '32' && '0' == itemNumber_21 && 'Key_24_HF' == itemMsgCd) {// mod #9973 value Number→文字列  shiyw
          itemOHDF_24_Max = healthmonFacilityConn[key];
          if (itemNumber > itemOHDF_24_Max) {
            return "Key_24_SPEED";
          }
        }
        // add No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc end
        if (key === '185' && '1' == itemNumber_21 && 'Key_24_HDF' == itemMsgCd) {// mod #9973 value Number→文字列  shiyw
          if (itemNumber > healthmonFacilityConn[key]) {
            return "Key_24_SPEED";
          }
        }
        if (key === '31' && '0' == itemNumber_21 && 'Key_24_HDF' == itemMsgCd) {// mod #9973 value Number→文字列  shiyw
          if (itemNumber > healthmonFacilityConn[key]) {
            return "Key_24_SPEED";
          }
        }
        // add No.8812 補液速度が補液速度上限を超えた時のメッセージNG 20230609 ztc end
        //add FNSI-5532 劉全航 end
      }
      return '';
    },
    // mod FNSI-【1006】最新の改修対象一覧の412対応 韓 end

    // add FNSI-改修内容 補液量、補液速度、血流量、透析温度のチェックを追加 穆 end
    validateIP(indInfo) {
      const statusAutoOff = indInfo["35"].value;
      const statusMonitorOff = indInfo["37"].value;
      if (statusAutoOff == '1' && statusMonitorOff == '1') {// mod #9973 value Number→文字列  shiyw
        // 両方「1: 入り」なら

        // IP電源自動切り時間
        const ipAutoOffTiming = indInfo["36"].value;
        // IP電源OKモニタ切時間
        const ipMonitorOffTiming = indInfo["38"].value;
        if (ipAutoOffTiming > ipMonitorOffTiming) {
          this.$parent.$parent.messageDialogInfo.messageCd = 50000002;
          this.$parent.$parent.messageDialogInfo.type = "1";
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          this.$parent.$parent.messageDialogInfo.stringParams = [
            "「IP電源OKモニタ切り時間」",
            "「IP電源自動切り時間」"
          ];
          return true;
        }
      }
      return false;
    },

    hasIP(indInfo) {
      const IP35 = _.has(indInfo, "35");
      const IP36 = _.has(indInfo, "36");
      const IP37 = _.has(indInfo, "37");
      const IP38 = _.has(indInfo, "38");
      return IP35 && IP36 && IP37 && IP38;
    },

    // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
    hasAntiCoagulantAmountTotal(indInfo) {
      const IP1 = _.has(indInfo, "1");
      // add 12183 特定の治療方法で治療時間を変更すると処理中のままになる zkm start
      const IP29 = _.has(indInfo, "29");
      // add 12183 特定の治療方法で治療時間を変更すると処理中のままになる zkm end
      const IP35 = _.has(indInfo, "35");
      const IP36 = _.has(indInfo, "36");
      // mod 12183 特定の治療方法で治療時間を変更すると処理中のままになる zkm start
      // return IP35 || IP36 || IP1;
      return IP35 || IP36 || IP1 || IP29;
      // mod 12183 特定の治療方法で治療時間を変更すると処理中のままになる zkm end
    },

    validateAntiCoagulantAmountTotal(indInfo, indCondInfo) {
      // add 12183 特定の治療方法で治療時間を変更すると処理中のままになる zkm start
      if (!_.has(indInfo, "29") && !_.has(indCondInfo, "29")) {
        return false;
      }
      // add 12183 特定の治療方法で治療時間を変更すると処理中のままになる zkm end
      const statusAutoOff = _.has(indInfo, "35") ? indInfo["35"].value : indCondInfo["35"].value;
      // add 11943 抗凝固剤治療指示のバグ修正 追加 zkm start
      const statusIpUseOff = _.has(indInfo, "29") ? indInfo["29"].value : indCondInfo["29"].value;
      // add 11943 抗凝固剤治療指示のバグ修正 追加 zkm end
      // 「1: 入り」なら
      // mod 11943 抗凝固剤治療指示のバグ修正 追加 zkm start
      // if (statusAutoOff === '1') {
      if (statusAutoOff === '1' && statusIpUseOff === '1') {
        // mod 11943 抗凝固剤治療指示のバグ修正 追加 zkm end
        const treatTime = _.has(indInfo, "1") ? indInfo["1"].value : indCondInfo["1"].value;
        // IP電源自動切り時間
        const ipAutoOffTiming = _.has(indInfo, "36") ? indInfo["36"].value : indCondInfo["36"].value;
        return accSub(treatTime, ipAutoOffTiming) <= 0;
      }
      return false;
    },
    // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end

// add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
    // 装置設定の内容取得
    async getDeviceSetInfoPatOrd(settingData) {
      // 患者情報と指示の装置設定値を取得
      const [devInfoPat, devInfoOrd] = await Promise.all([
        getDeviceSetInfoPat(settingData.patId),
        getDeviceSetInfoOrd(settingData.ordNo)
      ]).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('IndActionChart.vue', 'getDeviceSetInfoPatOrd', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw new Error(error);
      });
      if (
        devInfoPat === "" ||
        devInfoPat === null ||
        devInfoOrd === "" ||
        devInfoOrd === null
      ) {
        throw new Error("装置設定がnullです");
      }

      // 2つの装置設定値を1つのオブジェクトに
      const devInfoPatOrd = { ...devInfoPat, ...devInfoOrd };

        // 装置設定の「DP=Qｄ＋Qs(補液速度加算)」の内容(使用する。/使用しない。)
        let displayString = "";
        if (devInfoPatOrd.ope.dev.A[369] === "1") {
          displayString = valueInfoOpe.dev.A[369].formLabel + "を" + valueInfoOpe.dev.A[369].options[0].displayString;
        } else {
          displayString = valueInfoOpe.dev.A[369].formLabel + "を" + valueInfoOpe.dev.A[369].options[1].displayString;
        }
        this.setOhdfDisplayString(displayString);

        // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
        // OHDF/OHF補液計算優先項目選択
        const val_389 = devInfoPatOrd.ope.dev.A[389];
        const displayStringLiquidAmount = LIQUID_AMOUNT_TEXT[parseInt(val_389)];
        const displayStringLiquidSpeed = LIQUID_SPEED_TEXT[parseInt(val_389)];
        // 補液速度のメッセージ表示設定
        this.setLiquidAmountDisplayString(displayStringLiquidAmount);
        this.setLiquidAmountCommentIsShow(true);
        // 補液量のメッセージ表示設定
        this.setLiquidSpeedDisplayString(displayStringLiquidSpeed);
        this.setLiquidSpeedCommentIsShow(true);
        // OHDF/OHF補液計算優先項目設定
        this.setLiquidCalPriority(val_389);
        // 補液速度と補液量を算出するため、補液開始遅延時間設定
        this.setLiquidDelayTiming(Number(devInfoPatOrd.ope.dev.A[398]));
        // 補液速度と補液量を算出するため、OHDF/OHF 補液比率(前補液)設定
        this.setLiquidRateBefore(Number(devInfoPatOrd.ope.dev.A[379]));
        // 補液速度と補液量を算出するため、OHDF/OHF 補液比率(後補液)設定
        this.setLiquidRateAfter(Number(devInfoPatOrd.ope.dev.B[39]));

        // 算出した補液量
        let ihdfLiquidTotal = 0;
        // "203": I-HDF 補液開始時間
        const ihdfLiquidStartTime = Number(devInfoPatOrd.ihdf.dev.A[203]);
        // "202": I-HDF 補液周期
        const ihdfLiquidCycle = Number(devInfoPatOrd.ihdf.dev.A[202]);
        // "205": I-HDF 総補液量上限
        const ihdfLiquidMax = Number(devInfoPatOrd.ihdf.dev.A[205]);
        // (((予定毎の治療時間-補液開始時間)/補液周期)小数点以下切り捨て)=補液回数
        let ihdfLiquidCnt = parseInt((this.treatTime - ihdfLiquidStartTime) / ihdfLiquidCycle);
        // "432": I-HDFプログラム使用選択:[使用しない:0,使用する:1]
        if (devInfoPatOrd.ihdf.dev.A[432] === '0') {
          // "200": I-HDF 補液量設定
          const ihdfLiquidAmout = Number(devInfoPatOrd.ihdf.dev.A[200]);
          ihdfLiquidTotal = ihdfLiquidAmout * ihdfLiquidCnt;
        } else {
          //画面上に補液量最大回数は16
          ihdfLiquidCnt = ihdfLiquidCnt < 16 ? ihdfLiquidCnt : 16;
          for (var i=435; i<(ihdfLiquidCnt + 435); i++) {
            ihdfLiquidTotal += Number(devInfoPatOrd.ihdf.dev.A[i]);
          }
        }
        ihdfLiquidTotal = ihdfLiquidTotal / 1000;
        ihdfLiquidTotal = ihdfLiquidTotal > ihdfLiquidMax ? ihdfLiquidMax : ihdfLiquidTotal;
        // 算出した補液量の合計
        // mod #10150 装置プログラムのI-HDF設定を変更する場合、補液量(小数点以下１桁、切り捨て)、補液速度 L/min -> L/hに転換する(小数点以下２桁、切り上げ) zkm start
        this.setIhdfLiquidTotal((Math.trunc(ihdfLiquidTotal * 10) / 10).toFixed(1));
        // "201": I-HDF 補液速度,
        // this.setIhdfLiquidSpeed(Number(devInfoPatOrd.ihdf.dev.A[201]) / 1000);
        var ihdfLiquidSpeed = (Number(devInfoPatOrd.ihdf.dev.A[201]) / 1000) * 60;
        this.setIhdfLiquidSpeed((Math.ceil(ihdfLiquidSpeed * 100) /100).toFixed(2));
        // mod #10150 装置プログラムのI-HDF設定を変更する場合、補液量(小数点以下１桁、切り捨て)、補液速度 L/min -> L/hに転換する(小数点以下２桁、切り上げ) zkm end
        // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end

    },

    // 装置設定の内容の表示設定
    reflectCommentShow(structData) {
        this.setOhdfCommentIsShow(false);
        if (structData.selectedTreat.length ===1){
          let selectedTreat = structData["treatOptions"].find(element => element.value === structData.selectedTreat[0]);
          if (selectedTreat.text === "OHDF" && this.$parent.$parent.supplyLiquidSpeedFlg){
            this.setOhdfCommentIsShow(true);
           }
        }
    },

    /**
     * 表示設定フラグ取得
     */
    async getSupplyLiquidSpeedSettingValue() {
      getMstFacilitySettingValue(this.facilityCd, REPLENISHER_QDQS_SETTING)
        .then(response => {
          this.$parent.$parent.supplyLiquidSpeedFlg = response.data === 1;
        });

    }
  },

  async created() {
    this.oldcomponentData = JSON.parse(JSON.stringify(this.componentNames))
    // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng start
    getMstFacilitySettingValue(this.facilityCd, ANTICOAGULANT_AUTO_SETTING)
      .then(response => {
        this.facilitySettingAnticoagulantAutoValue= response.data;
      });
    getMstFacilitySettingValue(this.facilityCd, ANTICOAGULANT_DEFAULT_SETTING)
      .then(response => {
        this.facilitySettingAnticoagulantDefaultValue= response.data;
      });
    // #10247 施設設定マスタの設定にかかわらず、総量計算がされず、動作が正しくない linjunfeng end
    await this.getSupplyLiquidSpeedSettingValue();
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
    this.$parent.$parent.isIndActionChart = true;
    // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end

    switch (this.settingIndData.headerTitle) {
      case "治療条件":
      case "治療条件編集":
      case "VA編集":
      case "DW/目標体重/除水量制限編集":
      case "ダイアライザ/吸着カラム編集":
      case "1次膜/2次膜編集":
      case "穿刺針情報編集":
      case "血液回路編集":
      case "血流量編集":
      case "透析液情報編集":
      case "補液情報編集":
      case "抗凝固剤情報編集":
      case "目標体重編集":
      case "除水量制限編集":
        //FNSI-修正 #5525 横展開対応、xugj add start
        this.$parent.$parent.isSendNextPatInfoFlg = true;
        //FNSI-修正 #5525 横展開対応、xugj add end
        break;
      default:
        break;
    }

    //FNSI-修正 #5658 治療方法に変えた際のメッセージ修正、xugj add start
    switch (this.settingIndData.headerTitle) {
      case "治療条件":
      case "治療条件編集":
        //add 8485 2023-03-25透析治療で治療時間を10時間より大きい数値を入力しても注意喚起メッセージが表示されない 張 start
      case "治療時間編集":
        //add 8485 2023-03-25透析治療で治療時間を10時間より大きい数値を入力しても注意喚起メッセージが表示されない 張 end
        this.$parent.$parent.isTreatTimeSettingFlg = true;
        break;
      default:
        break;
    }
    //FNSI-修正 #5658 治療方法に変えた際のメッセージ修正、xugj add end
    // add #10150 piao Start
    if(this.getIsUseFlagIv){
      this.newIndTreatCondIvMode = "noIv";
    }else if(this.ivOnlineDeviceModeList.includes(this.deviceMode)){
      this.newIndTreatCondIvMode = "onLine";
    }else {
      this.newIndTreatCondIvMode = "offLine";
    }
    this.oldIndTreatCondIvMode = this.newIndTreatCondIvMode;
    // add #10150 piao end
  }
// add FNSI-【1006】最新の改修対象一覧の483対応 韓 end
};
</script>

<style scoped>
.column-style {
  border: 1px solid var(--ntss-border-color);
  width: 100%;
  box-sizing: border-box;
}

.column-style >>> .custom-div-show-selected-item{
  width: 100%;
  max-width: 400px;
}

.column-style >>> .action-condition-column {
  flex: 0 0 calc(12em);
  max-width: 100%;
  width: 100%;
}

@media screen and (max-width: 660px) {
  .column-style >>> .action-condition-column {
    flex: none;
    max-width: 100%;
    width: -webkit-fill-available;
  }

  .column-style >>> .action-condition-data-column {
    padding-left: 0;
  }
}

</style>
