/**
 * マスタメンテナンスデータページ  MainContent
 * 感染症マスタ
 * インプラントマスタ
 * 重症度マスタ
 * 搬送区分マスタ
 * 透析困難マスタ
 * 診療科マスタ
 * 病棟マスタ
 * 保険マスタ
 * 加算・管理料マスタ
 */
<template>
  <div class='main-content-area master-maintenance-page' :class="{
    'master-mst-monitor-graph': masterPhysicalName === 'mst_monitor_graph',
    'master-mst-vital-graph': masterPhysicalName === 'mst_vital_graph',
  }">
    <div class='ntss-list' ref="ntssList" :style="ntssListStyles">
      <div class="k-grid-toolbar kendo-grid-toolbar-style print-grid-style" :style="heightStyles">
        <div id="grid-header" class='header-btn-area right'>
          <!-- mod 画面デザイン 對應 王 start-->
          <!-- <v-ons-button modifier="outline" class="toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord && isAddButton" @click="addRow()">追加</v-ons-button>-->
          <!-- <v-ons-button modifier="outline" v-show="isMstExamItem" class="toolbar-btn" style="float: left; margin-left: 1px;" @click="showRecalculationModal">再計算</v-ons-button>-->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord && isAddButton" @click="addRow()">追加</v-ons-button>
          <v-ons-button modifier="outline" v-show="isMstExamItem" class="btn3-normal toolbar-btn" style="float: left; margin-left: 1px;" @click="showRecalculationModal">再計算</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- mod 画面デザイン 對應 王 end-->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔s start -->
          <!-- <kendo-dropdownlist ref="dropDownList" v-if="isMasterUser"
              v-model="facilitylistValue"
              :data-source="facilities"
              :data-text-field="'facilityName'"
              :data-value-field="'facilityCd'"
              :filter="'contains'"
              @open="onOpenFacility"
              @change="onChangeFacility"
              style="width: 13em;">
          </kendo-dropdownlist> -->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔s end -->
          <!-- mod 画面デザイン 對應 王 start-->
          <!-- <v-ons-button modifier="outline" class="toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowAddRecord" @click="importCsv()">CSV取込</v-ons-button>-->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowAddRecord && isCsvButton" @click="importCsv()">CSV取込</v-ons-button>
          <!-- mod 画面デザイン 對應 王 end-->
          <v-ons-button class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort && isToRankButton" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <div id="grid" ref="gridEl" :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'master-record-direct-jq-grid']"></div>
      </div>
      <div id="grid-footer">
        <!-- add スクロールの位置を維持 楊 start -->
        <!-- <v-ons-row width="100%"  v-show="!isSortMode" > -->
        <!-- mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start -->
        <!-- <v-ons-row width="100%" :style="{ visibility:this.isSortMode ?  'visible' : 'visible' }" > -->
        <v-ons-row width="100%" :style="{ visibility:this.isSortMode ?  'hidden' : 'visible' }" >
        <!-- mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end -->
        <!-- add スクロールの位置を維持 楊 end -->
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
<!--            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord()">保存</v-ons-button>-->
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecordPopUpModel()">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
      <!-- 指示者設定モーダル -->
      <v-ons-modal v-if="isModalVisible" :visible="isModalVisible" :class="modalFontSize">
        <ind-user-setting @hide-modal="isModalVisible = false" :title="title"/>
      </v-ons-modal>

    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/compat/vue/event-bus.js";
import dayjs from "@/compat/date/dayjs";

import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { createApp, markRaw } from "@/compat/vue/runtime";
import { ApiHelper } from "@/apis/AxiosHelper";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { mstVitalGraphDefine } from "@/constants/mstVitalGraph";
import { mstPatViewerLayout } from "@/constants/mstPatViewerLayout";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
// #11205 -ペンテスト2－4認可制御の不備  mst_holiday標準データは専用API  add 20260507 start
import { sendRequestFindMstHolidayNikkisoCorporateData } from "@/apis/master-maintenance";
// #11205 -ペンテスト2－4認可制御の不備  add 20260507 end
import {
  sendRequestFindRecordListByFacilityCd,
} from "@/apis/master-maintenance";
import {
  DEFAULT_PROCEDURE,
  DEFAULT_MEDICATE_TIMING,
} from "@/constants/facilitySetting";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { MST_DEFAULT_VALUE } from "@/constants/masterDefineDetail";
import { MainteClass } from "@/constants/mainteConstants";
import { SUB_CATEGORY_NO } from "@/constants/mstPatCalendarLayoutDefine";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { messageFormat } from "@/functions/common/MessageFormat";
import indUserSetting from "@/components/pat-info/ind-user-setting/IndUserSettingModal";
import BigNumber from "bignumber.js";
import { deleteDataProcessing } from "@/functions/mst/MasterMaintenanceFunctions";
import { syncKendoGridLockedRowHeights } from "@/utils/kendoGridLockedSync";

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
import { getScopedElementById, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import { bindGridEditorEnterToCloseCell } from "@/compat/kendo/grid-edit";
import {
  createJQueryValidator,
  destroyJQueryValidator,
} from "@/compat/kendo/kendo-jquery.js";

function createDirectDataSource(options) {
  return new kendo.data.DataSource(options);
}

function getDirectWidgetSelectedIndex(widget) {
  if (!widget) {
    return -1;
  }
  if (typeof widget.select === "function") {
    return widget.select();
  }
  return widget.selectedIndex ?? -1;
}

function getDirectWidgetDataAt(widget, index) {
  if (!widget) {
    return null;
  }
  if (typeof widget.dataItem === "function") {
    return widget.dataItem(index);
  }
  return widget.dataSource?.data?.()?.[index] || null;
}

function getDirectWidgetValue(widget) {
  const inputValue = widget?.element?.get?.(0)?.value;
  if (inputValue !== undefined && inputValue !== null && inputValue !== "") {
    const parsed = String(inputValue).replace(/,/g, "");
    try {
      if (BigNumber(parsed).isFinite()) {
        return BigNumber(parsed).toNumber();
      }
    } catch (_error) {
      // fall through
    }
  }
  return typeof widget?.value === "function" ? widget.value() : widget?.element?.val?.();
}

function setDirectWidgetValue(widget, value) {
  if (typeof widget?.value === "function") {
    widget.value(value);
  } else {
    widget?.element?.val?.(value);
  }
}

function mountDirectNumericTextBox(element, options) {
  const $element = $(element);
  $element.kendoNumericTextBox(options);
  return $element.data("kendoNumericTextBox");
}

function getDirectNumericTextElements(widget) {
  const elements = [];
  const add = (input) => {
    if (input && !elements.includes(input)) {
      elements.push(input);
    }
  };
  add(widget?.element?.get?.(0));
  add(widget?._text?.get?.(0));
  const wrapper = widget?.wrapper?.get?.(0);
  wrapper?.querySelectorAll?.("input.k-input-inner, input.k-input, input.text-input")?.forEach(add);
  return elements;
}

function getDirectNumericTextElement(widget) {
  return getDirectNumericTextElements(widget)[0] || null;
}

function toPlainNumericText(value) {
  if (value === null || value === undefined || value === "") {
    return "";
  }
  const normalized = String(value).replace(/,/g, "");
  try {
    return BigNumber(normalized).toFixed();
  } catch (_error) {
    return normalized;
  }
}

function stripNumericInputCommas(input) {
  if (!input || typeof input.value !== "string" || !input.value.includes(",")) {
    return;
  }
  const selectionStart = input.selectionStart;
  const selectionEnd = input.selectionEnd;
  const stripped = input.value.replace(/,/g, "");
  const removed = input.value.length - stripped.length;
  input.value = stripped;
  if (selectionStart !== null && selectionEnd !== null) {
    const nextPos = Math.max(0, selectionStart - removed);
    input.setSelectionRange(nextPos, nextPos);
  }
}


function syncDirectNumericTextBoxDisplay(widget, value) {
  const plainValue = toPlainNumericText(value);
  getDirectNumericTextElements(widget).forEach((textInput) => {
    textInput.setAttribute("inputmode", "decimal");
    const isFocused = textInput.ownerDocument?.activeElement === textInput;
    if (isFocused && textInput.value.replace(/,/g, "") === plainValue) {
      stripNumericInputCommas(textInput);
      return;
    }
    if (!isFocused) {
      textInput.value = plainValue;
    }
  });
}

function clampNumericEditorBounds(value, min, max, hasMin, hasMax) {
  if (hasMax && value > max) {
    return max;
  }
  if (hasMin && value < min) {
    return min;
  }
  return value;
}

function loopNumericEditorBounds(value, min, max, hasMin, hasMax) {
  if (!hasMin || !hasMax) {
    return clampNumericEditorBounds(value, min, max, hasMin, hasMax);
  }
  if (value > max) {
    return min;
  }
  if (value < min) {
    return max;
  }
  return value;
}

function resolveNumericEditorWheelDelta(event) {
  const originalEvent = event.originalEvent || event;
  if (originalEvent.wheelDelta) {
    return originalEvent.wheelDelta > 0 ? 1 : -1;
  }
  if (originalEvent.deltaY) {
    return originalEvent.deltaY < 0 ? 1 : -1;
  }
  if (originalEvent.detail) {
    return originalEvent.detail > 0 ? -1 : 1;
  }
  return 0;
}

function applyNumericEditorWheelStep(rawValue, delta, step, min, max, hasMin, hasMax, loop = false) {
  const current = rawValue !== "" && rawValue !== null && rawValue !== undefined && !isNaN(parseFloat(rawValue))
    ? parseFloat(rawValue)
    : (hasMin ? min : 0);
  if (loop && hasMin && hasMax) {
    if (delta > 0) {
      return current >= max ? min : current + step;
    }
    if (delta < 0) {
      return current <= min ? max : current - step;
    }
    return current;
  }
  let value = current;
  if (delta > 0) {
    value += step;
  } else if (delta < 0) {
    value -= step;
  }
  return clampNumericEditorBounds(value, min, max, hasMin, hasMax);
}

function bindMasterRecordNumericEditorWheel(widget, handler) {
  getDirectNumericTextElements(widget).forEach((input) => {
    if (input.__ntssMasterRecordWheelInstalled) {
      return;
    }
    input.__ntssMasterRecordWheelInstalled = true;
    let wheelHandled = false;
    const onWheel = (event) => {
      if (wheelHandled) {
        event.preventDefault();
        return;
      }
      wheelHandled = true;
      globalThis.setTimeout(() => {
        wheelHandled = false;
      }, 0);
      handler(event, input);
    };
    input.addEventListener("wheel", onWheel, { passive: false });
  });
}

function toUngroupedKendoNumberFormat(format, decimals) {
  const normalizedFormat = String(format || "");
  const match = normalizedFormat.match(/^n(\d*)$/i);
  if (!match) {
    return normalizedFormat;
  }
  const decimalPlaces = match[1] === "" ? Number(decimals || 0) : Number(match[1]);
  if (!Number.isFinite(decimalPlaces) || decimalPlaces <= 0) {
    return "0";
  }
  return `0.${"0".repeat(decimalPlaces)}`;
}

const MASTER_RECORD_DATE_FIELDS = new Set([
  "useStartDate",
  "useEndDate",
  "inHospAStartdate",
  "inHospBStartdate",
]);

/** 水質検査種別マスタ：整数部桁数・小数部桁数の入力範囲 */
const WATER_SURVEY_TYPE_DIGIT_MIN = 1;
const WATER_SURVEY_TYPE_DIGIT_MAX = 8;
/** 水質検査種別マスタ：小数部桁数変更時に連動する閾値・グラフ・初期値フィールド */
const WATER_SURVEY_THRESHOLD_FIELDS = [
  "upperThreshold",
  "lowerThreshold",
  "graphUpperLimit",
  "graphLowerLimit",
  "initialValue",
];
/** 水質検査種別マスタ：閾値・グラフ・結果初期値の丸め（四捨五入） */
const WATER_SURVEY_ROUND_MODE = BigNumber.ROUND_HALF_UP;

function parseWaterSurveyDigit(value, fallback = 0) {
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function toWaterSurveyBigNumber(value) {
  return BigNumber(String(value).replace(/,/g, ""));
}

/**
 * 閾値等を小数部桁数で四捨五入し、整数部桁数の上下限に収める。
 * 例: 整数部1・小数部2 → 上限9.99 のとき 9.99999 は 10.00 に丸まった後 9.99 になる。
 */
function roundAndClampWaterSurveyThresholdValue(rawValue, integerDigits, decimalDigits) {
  if (rawValue === null || rawValue === undefined || rawValue === "") {
    return rawValue;
  }
  const decimals = parseWaterSurveyDigit(decimalDigits, 0);
  const integers = parseWaterSurveyDigit(integerDigits, WATER_SURVEY_TYPE_DIGIT_MIN);
  let next = toWaterSurveyBigNumber(rawValue).decimalPlaces(decimals, WATER_SURVEY_ROUND_MODE);
  const max = BigNumber(10).pow(integers).minus(BigNumber(10).pow(-decimals));
  const min = BigNumber(10).pow(integers).negated().plus(BigNumber(10).pow(-decimals));
  if (next.isGreaterThan(max)) {
    next = max;
  } else if (next.isLessThan(min)) {
    next = min;
  }
  return next.toNumber();
}

/** 開発時のみ: useStartDate 等の k-dirty-cell 調査用。localStorage.setItem("masterRecordDirtyDebug", "0") で OFF */
const MASTER_RECORD_DIRTY_DEBUG_KEY = "masterRecordDirtyDebug";

function isMasterRecordDirtyDebugEnabled() {
  if (process.env.NODE_ENV === "production") {
    return false;
  }
  try {
    return globalThis.localStorage?.getItem(MASTER_RECORD_DIRTY_DEBUG_KEY) !== "0";
  } catch (_error) {
    return true;
  }
}

function formatMasterRecordDateYmd(value) {
  if (value == null || value === "") {
    return value;
  }
  const formatted = dayjs(value);
  return formatted.isValid() ? formatted.format("YYYYMMDD") : String(value);
}

function isMasterRecordFieldValueEqual(originalValue, currentValue, field) {
  if ((originalValue === "" && currentValue == null) || (originalValue == null && currentValue === "")) {
    return true;
  }
  if (MASTER_RECORD_DATE_FIELDS.has(field)) {
    const originalYmd = formatMasterRecordDateYmd(originalValue);
    const currentYmd = formatMasterRecordDateYmd(currentValue);
    if (originalYmd == null || originalYmd === "") {
      return currentYmd == null || currentYmd === "";
    }
    return originalYmd === currentYmd;
  }
  return originalValue == currentValue;
}

const {
  updated: masterMaintenanceUpdated,
  ...MasterRecordMaintenanceMixin
} = MasterMaintenanceMixin;
void masterMaintenanceUpdated;

export default {
  mixins: [NextTransitionMixin, MasterRecordMaintenanceMixin],
  components: {
    "master-csv": MasterCsvComponent,
    "ind-user-setting": indUserSetting,
  },
  data() {
    return {
      // add 9664 by kangjie 20231208 start
      title:"治療方法を更新します",
      isModalVisible: false,
      // add 9664 by kangjie 20231208 end
      recordList: [],
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null
        }
      ],
      condition: {
        recordName: "",
        includeDeleted: false
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      mstSynchroApiParams: {
        mstTable: "mst_m_notice",
        deviceEdgeNo: -1,
        deviceName: "すべて"
      },
      mstHolidayNkkData: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      __masterRecordSortApplying: false,
      /** セル編集保存中は masterRecords watcher による DataSource 全件更新を抑止 */
      __masterRecordInlineEdit: false,
      masterRecordRowVisualRafIds: null,
      __masterRecordFullVisualRaf: null,
      /** ユーザーが手入力で変更した sortRank の code 一覧（反映後の採番差分と区別） */
      masterRecordSortEditedCodes: null,
      masterRecordRestoreScrollPending: false,
      validationTooltipPlacementTimers: [],
      validationTooltipPlacementRafId: null,
      validationTooltipPlacementIntervalId: null,
      validationTooltipObserver: null,
      //自画面の名称
      selfScreenName: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      // 選択中の施設コード
      facilitylistValue: "",
      // 選択中施設の在宅機能有無
      facilityHemoDialysis: false,
      //変更前の施設
      prevFacilityCd: "",
      waterSurveyPointValueFalg: false,
      mstMonitorGraphItem: [],
      mstMonitorInitial: [],
      errorMessage: "",
      errorNameMstAlerm: [],
      oldLocalDataSource: [],

      resizeObserver: null,
      dataSourceItems: {},
      // add start #9301
      defaultMedicateTimingDataCd: null,
      defaultProcedureCd: null,
      // add end #9301
      // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
      sysMonitorItemList: [],
      // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    };
  },
  computed: {
    // add 9664 by kangjie 20231211 start
    ...mapGetters("pat-info",
      ["isIndUserSetting",
      "indUserId"]),
    modalFontSize() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    },
    // add 9664 by kangjie 20231211 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", {
      getAdvancedSettings :"getAdvancedSettings",
      systemUseSetting: "getSystemUseSetting"
    }),
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
    ...mapGetters("master-maintenance", {
      getScrollTopPosition: "getScrollTopPosition",
      getScrollLeftPosition: "getScrollLeftPosition"
    }),
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    ...mapGetters("master-maintenance", {
      // add マスタ一覧 1･施設切替を可能とする 孔s start
      getFacilitySwitch: "getFacilitySwitch",
      // add マスタ一覧 1･施設切替を可能とする 孔s end
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      getLogicalMasterName: "getLogicalMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified",
      masterRecordListRevision: "getMasterRecordListRevision",
      comparisonRecordModel: "getComparisonRecordModel",
      getFacilityList: "getFacilityList"
    }),
    // しばらくは使いませんでした
    // facilities() {
    //   // storeからデータを取得
    //   return this.getFacilityList;
    // },
    isMasterUser: {
      get() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
      },
      set() {}
    },
    masterRecords() {
      // storeからデータを取得
      //add FNSI-改修内容テンプレートマスタ、カテゴリマスタにデータがない場合、サブカテゴリマスタのテンプレートとカテゴリ項目に表示されたCDを空白に修正必要 任 start
      this.columns.forEach(column => {
          if(column.field==='categoryCd'&&column.values!==null){
            if(column.values.length===0){
              this.getFilteredMasterRecordList.data.forEach(item => {
                item.categoryCd = null;
              });
            }
          }else if(column.field==='templateCd'&&column.values!==null){
            if(column.values.length===0){
              this.getFilteredMasterRecordList.data.forEach(item => {
                item.templateCd = null;
              });
            }
           }
          // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
          // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
          // if (column.locked && (column.dataType === "string" || column.dataType === "textarea") && column.field === "name") {
          //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width
          // }
          // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
          // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
      })
      if(this.masterPhysicalName == "mst_holiday") {
        if (!this.getFilteredMasterRecordList.data){
          return this.getFilteredMasterRecordList;
        }
        let mstHolidayNkks = this.mstHolidayNkkData.filter(e=>e.class == "0");
        let mstHolidays = this.getFilteredMasterRecordList.data.filter(e=>e.class == "0");
        if (mstHolidayNkks.length> 0){
          let strMstHoliday = mstHolidays.map(e=> String(e.year));
          let that = this;
          let strMasterRecord = this.getMasterRecordList.data.map(e=> String(e.year));
          mstHolidayNkks.filter(e=>e.class == "0").forEach( e => {
            if(!strMstHoliday.includes(String(e.year)) && !strMasterRecord.includes(String(e.year))) {
             that.addRow(e.year, e.code);
            }
          })
        }
        let mstHolidayLists =  this.getFilteredMasterRecordList;
        const compare = (a, b) => {
          if(a.year && b.year){
            return a.year - b.year;
          }else{
            return 1;
          }
        }
        mstHolidays.sort(compare);
        mstHolidayLists.data = mstHolidays.filter(e=>e.class == "0");
        return mstHolidayLists;
      } else {
        // add FNSI-改修内容テンプレートマスタ、カテゴリマスタにデータがない場合、サブカテゴリマスタのテンプレートとカテゴリ項目に表示されたCDを空白に修正必要 任 end
        return this.getFilteredMasterRecordList
      }
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isAddButton() {
      let addMasterName = ["sys_medicine","mst_take_medicine","mst_vital_graph"]
      return addMasterName.indexOf(this.masterPhysicalName) < 0 ;
    },
    isToRankButton() {
      let addMasterName = ["mst_holiday"]
      return addMasterName.indexOf(this.masterPhysicalName) < 0 ;
    },
    isCsvButton() {
      let addMasterName = ["mst_holiday", "mst_prescription_set"]
      return addMasterName.indexOf(this.masterPhysicalName) < 0 ;
    },
    isMstExamItem() {
      return this.masterPhysicalName == "mst_exam_item";
    },
    isChanged() {
      if (this.getStateUserAccountInfo === null) {
        return false;
      }
      const data = this.getMasterRecordList?.data;
      if (data === undefined) {
        return false;
      }
      // edit / revert 後に isRecordModified を確実に再評価させる
      void this.masterRecordListRevision;
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return true;
      }
      return !!this.isRecordModified;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    // add 9664 by kangjie 20231211 start
    isIndUserSetting() {
      if (this.isIndUserSetting) {
        // execute save
        this.saveRecord();
      }
    },
    // add 9664 by kangjie 20231211 end
    windowHeight() {
      this.calculateColumnsWidth();
      this.storeMasterRecordGridScrollForLayout();
      this.calculateGridHeight();
      this.resizeDirectGrid();
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.storeMasterRecordGridScrollForLayout();
      this.calculateGridHeight();
      this.resizeDirectGrid();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.storeMasterRecordGridScrollForLayout();
      this.calculateGridHeight();
      this.resizeDirectGrid();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.storeMasterRecordGridScrollForLayout();
      this.calculateGridHeight();
      this.resizeDirectGrid();
    },
    isSortMode() {
      // isSortMode 変更後、mixin の disableColumns()/editableColumns() が
      // this.columns の hidden・editable を書き換えるため $nextTick で Kendo に同期する。
      // Skill 7: 全列ループは locked 列の再レイアウトを引き起こすため禁止。
      // 表示/非表示は並び順関連の 3 列のみ操作する。
      // editable はすべての列の内部オブジェクトに反映（hide/show は呼ばない）。
      const SORT_TOGGLE_FIELDS = ['dummy', 'sortRank', 'sortInputTime'];
      this.$nextTick(() => {
        const grid = this.getKendoGrid();
        if (!grid) return;
        this.columns.forEach(col => {
          if (!col.field) return;
          // 1. 表示 / 非表示は並び順列のみ
          if (SORT_TOGGLE_FIELDS.includes(col.field)) {
            if (col.hidden) {
              grid.hideColumn(col.field);
            } else {
              grid.showColumn(col.field);
            }
          }
          // 2. editable を Kendo 内部列オブジェクトに直接反映（全列）
          const kendoCol = grid.columns.find(kc => kc.field === col.field);
          if (kendoCol) {
            kendoCol.editable = col.editable;
          }
        });
        if (!this.__masterRecordSortApplying) {
          this.syncMasterRecordSortColumnLayout();
        }
        requestAnimationFrame(() => {
          requestAnimationFrame(() => this.refreshMasterRecordSortRankVisuals());
        });
      });
    },
    columns(val) {
      this.$nextTick(() => {
        if (val.length > 1) {
          this.initKendoGrid();
          this.setLoadingScreenVisible(false);
        }
      });
    },
    masterRecords() {
      if (this.__masterRecordSortApplying || this.__masterRecordInlineEdit) {
        return;
      }
      // Vue2 と同様に常に DataSource を更新する。
      this.dataSourceItems = this.generatedGridData();
      this.$nextTick(() => {
        const grid = this.getKendoGrid();
        if (!grid?.dataSource || !grid.table?.[0]) return;
        // 追加行の場合はスクロール位置を保存しない（dataBound で最下部にスクロール）
        if (!this.__pendingScrollToBottom && !this.masterRecordKeepScrollAfterSave) {
          // setGridScrollPosition と同じ要素から読み取って一致させる
          const scrollable = this.getGridScrollContainer();
          this._scrollToRestoreAfterDataBound = {
            top: scrollable?.scrollTop || 0,
            left: scrollable?.scrollLeft || 0,
          };
        }
        this.setGridDataSource(this.dataSourceItems);
      });
    }
  },
  unmounted() {
    if (this.masterRecordRowVisualRafIds) {
      this.masterRecordRowVisualRafIds.forEach(id => cancelAnimationFrame(id));
      this.masterRecordRowVisualRafIds.clear();
    }
    if (this.__masterRecordFullVisualRaf != null) {
      cancelAnimationFrame(this.__masterRecordFullVisualRaf);
      this.__masterRecordFullVisualRaf = null;
    }
    this._calendarApp?.unmount();
    this._calendarApp = null;
    try { this._directGridWidget?.destroy(); } catch (_e) {}
    this._directGridWidget = null;
    destroyJQueryValidator(this.$refs.ntssList);
    this.kendoValidator = null;
    this.teardownValidationTooltipPlacement();
  },
  methods: {
    // --- Kendo Grid 初期化 ---
    getKendoGrid() {
      return this._directGridWidget || null;
    },
    getGridSearchRoot() {
      const widget = this.getKendoGrid();
      return (
        widget?.wrapper?.[0]
        || widget?.element?.[0]
        || this.getMasterRecordGridElement()
        || null
      );
    },
    getKendoGridDataSourceItems() {
      const collection = this.getKendoGrid()?.dataSource?.data?.();
      return collection ? Array.from(collection) : [];
    },
    findActiveGridEditCell(root) {
      const grid = this.getKendoGrid();
      const lockedCell = grid?.lockedTable?.find?.(".k-edit-cell")?.[0];
      if (lockedCell) {
        return lockedCell;
      }
      const mainCell = grid?.table?.find?.(".k-edit-cell")?.[0];
      if (mainCell) {
        return mainCell;
      }
      const searchRoot = root || this.getGridSearchRoot();
      return (
        searchRoot?.querySelector?.(".k-grid-content-locked .k-edit-cell")
        || searchRoot?.querySelector?.(".k-grid-content .k-edit-cell")
        || searchRoot?.querySelector?.(".k-edit-cell")
        || null
      );
    },
    findGridScrollContentForEditCell(root, editCell) {
      const lockedContent = editCell?.closest?.(".k-grid-content-locked");
      if (lockedContent) {
        return lockedContent;
      }
      const scrollContent = editCell?.closest?.(".k-grid-content");
      if (scrollContent) {
        return scrollContent;
      }
      return (
        root?.querySelector?.(".k-grid-content-locked")
        || root?.querySelector?.(".k-grid-content")
        || null
      );
    },
    findVisibleValidationTooltip(editCell) {
      if (!editCell) {
        return null;
      }
      const candidates = editCell.querySelectorAll(
        ".k-invalid-msg, .k-tooltip-error, .k-validator-tooltip, .k-tooltip.k-tooltip-validation"
      );
      for (const element of candidates) {
        if (element?.classList?.contains?.("k-hidden")) {
          continue;
        }
        const text = element.textContent?.trim?.() || "";
        const hasMessage = text.length > 0 || element.querySelector?.(".k-tooltip-content");
        if (hasMessage || element.classList.contains("k-tooltip-error")) {
          return element;
        }
      }
      return null;
    },
    resetValidationTooltipCalloutDirection(editCell) {
      editCell?.querySelectorAll?.(".k-callout")?.forEach?.((callout) => {
        callout.classList.remove("k-callout-s", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-n");
      });
    },
    setValidationTooltipCalloutDirection(tooltip, above) {
      const callout = tooltip?.querySelector?.(".k-callout");
      if (!callout) {
        return;
      }
      if (above) {
        callout.classList.remove("k-callout-n", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-s");
      } else {
        callout.classList.remove("k-callout-s", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-n");
      }
    },
    isLastDataSourceEditRow(editRow) {
      if (!editRow) {
        return false;
      }
      const grid = this.getKendoGrid();
      const dataItem = grid?.dataItem?.(editRow);
      const items = this.getKendoGridDataSourceItems();
      if (!items.length) {
        return false;
      }
      const lastItem = items[items.length - 1];
      if (dataItem && lastItem) {
        return dataItem === lastItem || dataItem.uid === lastItem.uid;
      }
      const rowUid = editRow.getAttribute("data-uid");
      return !!rowUid && lastItem?.uid === rowUid;
    },
    isLastVisibleTbodyRow(editRow) {
      const tbody = editRow?.closest?.("tbody");
      if (!tbody) {
        return false;
      }
      const dataRows = tbody.querySelectorAll(":scope > tr[data-uid]");
      if (!dataRows.length) {
        return false;
      }
      return dataRows[dataRows.length - 1] === editRow;
    },
    isEditRowInVisibleBottomBand(editCell, content) {
      const editRow = editCell?.closest?.("tr");
      if (!editRow || !content) {
        return false;
      }
      const contentRect = content.getBoundingClientRect();
      const rowRect = editRow.getBoundingClientRect();
      const rowBottomGap = contentRect.bottom - rowRect.bottom;
      if (rowBottomGap < 52) {
        return true;
      }
      const tbody = editRow.closest("tbody");
      if (!tbody) {
        return false;
      }
      const dataRows = Array.from(tbody.querySelectorAll(":scope > tr[data-uid]"));
      const rowIndex = dataRows.indexOf(editRow);
      if (rowIndex < 0) {
        return false;
      }
      return rowIndex >= dataRows.length - 2;
    },
    shouldPlaceValidationTooltipAbove(editCell, content, anchor, tooltip) {
      const editRow = editCell?.closest?.("tr");
      const anchorRect = anchor.getBoundingClientRect();
      const contentRect = content.getBoundingClientRect();
      const tooltipRect = tooltip.getBoundingClientRect();
      const rowRect = editRow?.getBoundingClientRect?.() || anchorRect;
      const tooltipHeight = Math.max(
        tooltip.offsetHeight || 0,
        tooltip.scrollHeight || 0,
        tooltipRect.height || 0,
        36
      );
      const spaceBelow = contentRect.bottom - anchorRect.bottom;
      const rowBottomGap = contentRect.bottom - rowRect.bottom;
      const overflowsBelow =
        tooltipRect.height > 0 && tooltipRect.bottom > contentRect.bottom - 2;
      const projectedOverflow =
        anchorRect.bottom + tooltipHeight + 4 > contentRect.bottom;
      return (
        overflowsBelow
        || projectedOverflow
        || spaceBelow < tooltipHeight + 4
        || rowBottomGap < tooltipHeight + 8
        || this.isEditRowInVisibleBottomBand(editCell, content)
        || this.isLastDataSourceEditRow(editRow)
        || this.isLastVisibleTbodyRow(editRow)
      );
    },
    applyValidationTooltipPlacement() {
      const root = this.getGridSearchRoot();
      if (!root) {
        return;
      }
      const editCell = this.findActiveGridEditCell(root);
      const content = this.findGridScrollContentForEditCell(root, editCell);
      if (!content || !editCell) {
        return;
      }
      const tooltip = this.findVisibleValidationTooltip(editCell);
      if (!tooltip) {
        return;
      }
      root.querySelectorAll(".ntss-validation-above").forEach((element) => {
        if (element !== editCell) {
          element.classList.remove("ntss-validation-above");
          this.resetValidationTooltipCalloutDirection(element);
        }
      });
      const anchor =
        editCell.querySelector(".k-input.k-textbox, .k-picker, .k-input")
        || editCell.querySelector(
          "input, textarea, select, .k-input-inner, .k-textbox"
        )
        || editCell;
      const needsAbove = this.shouldPlaceValidationTooltipAbove(
        editCell,
        content,
        anchor,
        tooltip
      );
      if (needsAbove) {
        editCell.classList.add("ntss-validation-above");
      } else {
        editCell.classList.remove("ntss-validation-above");
      }
      this.setValidationTooltipCalloutDirection(tooltip, needsAbove);
    },
    stopValidationTooltipPlacementWatch() {
      const ownerWindow = this.getGridSearchRoot()?.ownerDocument?.defaultView || window;
      if (this.validationTooltipPlacementIntervalId) {
        ownerWindow.clearInterval?.(this.validationTooltipPlacementIntervalId);
        this.validationTooltipPlacementIntervalId = null;
      }
    },
    startValidationTooltipPlacementWatch() {
      this.stopValidationTooltipPlacementWatch();
      const ownerWindow = this.getGridSearchRoot()?.ownerDocument?.defaultView || window;
      let attempts = 0;
      const tick = () => {
        attempts += 1;
        this.applyValidationTooltipPlacement();
        const root = this.getGridSearchRoot();
        const editCell = this.findActiveGridEditCell(root);
        const tooltip = this.findVisibleValidationTooltip(editCell);
        if (!tooltip || attempts >= 5) {
          this.stopValidationTooltipPlacementWatch();
        }
      };
      tick();
      this.validationTooltipPlacementIntervalId = ownerWindow.setInterval?.(tick, 100);
    },
    clearValidationTooltipPlacementTimers() {
      const ownerWindow = this.getGridSearchRoot()?.ownerDocument?.defaultView || window;
      this.validationTooltipPlacementTimers.forEach((timerId) => {
        ownerWindow.clearTimeout?.(timerId);
      });
      this.validationTooltipPlacementTimers = [];
      if (this.validationTooltipPlacementRafId) {
        ownerWindow.cancelAnimationFrame?.(this.validationTooltipPlacementRafId);
        this.validationTooltipPlacementRafId = null;
      }
    },
    scheduleValidationTooltipPlacement() {
      this.clearValidationTooltipPlacementTimers();
      const ownerWindow = this.getGridSearchRoot()?.ownerDocument?.defaultView || window;
      const run = () => this.applyValidationTooltipPlacement();
      run();
      this.$nextTick(run);
      this.validationTooltipPlacementRafId = ownerWindow.requestAnimationFrame?.(() => {
        this.validationTooltipPlacementRafId = ownerWindow.requestAnimationFrame?.(() => {
          this.validationTooltipPlacementRafId = null;
          run();
        }) || null;
      }) || null;
      const timerId = ownerWindow.setTimeout?.(run, 80);
      if (timerId) {
        this.validationTooltipPlacementTimers.push(timerId);
      }
      this.startValidationTooltipPlacementWatch();
    },
    installValidationTooltipPlacementObserver() {
      this.teardownValidationTooltipPlacementObserver();
      const root = this.getGridSearchRoot();
      const scrollAreas = [
        root?.querySelector?.(".k-grid-content"),
        root?.querySelector?.(".k-grid-content-locked"),
        root,
      ].filter(Boolean);
      if (!scrollAreas.length || typeof MutationObserver === "undefined") {
        return;
      }
      const ownerWindow = scrollAreas[0].ownerDocument?.defaultView || window;
      const onMutation = () => {
        if (this.validationTooltipPlacementRafId) {
          ownerWindow.cancelAnimationFrame?.(this.validationTooltipPlacementRafId);
        }
        this.validationTooltipPlacementRafId = ownerWindow.requestAnimationFrame?.(() => {
          this.validationTooltipPlacementRafId = null;
          this.applyValidationTooltipPlacement();
        }) || null;
      };
      this.validationTooltipObserver = new MutationObserver(onMutation);
      scrollAreas.forEach((scrollArea) => {
        this.validationTooltipObserver.observe(scrollArea, {
          childList: true,
          subtree: true,
        });
      });
    },
    teardownValidationTooltipPlacementObserver() {
      this.validationTooltipObserver?.disconnect?.();
      this.validationTooltipObserver = null;
    },
    clearMasterRecordValidationTooltipPlacementState() {
      this.getGridSearchRoot()?.querySelectorAll?.(".ntss-validation-above")?.forEach?.((element) => {
        element.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(element);
      });
    },
    teardownValidationTooltipPlacement() {
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      this.teardownValidationTooltipPlacementObserver();
      this.clearMasterRecordValidationTooltipPlacementState();
    },
    // MasterMaintenanceMixin の getGridRef() / getGridWidget() を上書き
    // （mixin は this.$refs.grid を期待しているが、jQuery 命令式では gridEl を使うため）
    getGridRef() {
      return this.$refs.gridEl || null;
    },
    getGridWidget() {
      return this.getKendoGrid();
    },
    buildColumns() {
      return this.columns.map(column => {
        const base = {
          field:    column.field,
          title:    column.title == null || column.title === '' ? ' ' : column.title,
          hidden:   column.hidden,
          locked:   column.locked,
          editable: column.editable,
          width:    column.width,
          format:   column.format,
          values:   column.values,
        };
        if (column.field === '$modalType') {
          return { ...base, attributes: { class: 'btn3-kendo-normal' },
                   command: { text: '詳細', click: event => this.showMasterEditModal(event) } };
        }
        if (column.title === '在宅') {
          return { ...base, hidden: !this.facilityHemoDialysis };
        }
        if (column.dataType === 'date') {
          return { ...base, editor: (container, opts) => this.eachModelCalendar(container, opts) };
        }
        if (column.field === 'leftDataIndex' || column.field === 'rightDataIndex') {
          return {
            ...base,
            template: (dataItem) => this.formatMonitorGraphItemLabel(dataItem?.[column.field]),
            editor: (container, opts) => this.comboEditor(container, opts),
          };
        }
        if (column.dataType === 'color') {
          return { ...base, template: column.colorTemplate,
                   editor: (container, opts) => this.colorEditor(container, opts) };
        }
        if (column.dataType === 'textarea') {
          return { ...base, editor: (container, opts) => this.textareaEditor(container, opts) };
        }
        if (column.dataType === 'number') {
          return { ...base, template: (dataItem) => this.formatValue(dataItem, column),
                   editor: (container, opts) => this.numericEditor(container, opts) };
        }
        if (column.field === 'mainteContent3') {
          return { ...base, template: column.textTemplate,
                   editor: (container, opts) => this.stringEditor(container, opts) };
        }
        return { ...base, template: column.textTemplate };
      });
    },
    initKendoGrid() {
      const el = this.$refs.gridEl;
      if (!el) return;
      if (this._directGridWidget) {
        this.applyMasterRecordColumnsContract();
        this.setGridDataSource(this.dataSourceItems);
        this.scheduleMasterRecordGridLayoutContract();
        this.$nextTick(() => {
          this.installValidationTooltipPlacementObserver();
        });
        return;
      }
      $(el).kendoGrid({
        dataSource:  this.dataSourceItems,
        editable:    true,
        selectable:  true,
        reorderable: false,
        height:      this.kendoGridHeight,
        scrollable:  true,
        columns:     this.buildColumns(),
        beforeEdit:  (e) => this.modifyEditStart(e),
        edit:        (e) => this.addInputAssist(e),
        cellClose:   (e) => this.masterRecordCellClose(e),
        save:        (e) => this.onEditSave(e),
        dataBound: (e) => {
          this.onDataBoundKendoGrid(e);
          this.scheduleMasterRecordGridLayoutContract();
          if (this.__pendingScrollToBottom) {
            // 追加行: 横スクロール0・縦スクロール最下部
            this.__pendingScrollToBottom = false;
            this.masterRecordKeepScrollAfterSave = false;
            this.masterRecordSavedScrollPosition = null;
            this._scrollToRestoreAfterDataBound = null;
            this.scrollPosition.left = 0;
            const scrollToAddedRowBottom = () => {
              const content = this.getGridScrollContainer();
              const top = content ? Math.max(0, content.scrollHeight - content.clientHeight) : 0;
              this.applyMasterRecordGridScrollToWidget(top, 0, e.sender);
            };
            this.$nextTick(() => {
              scrollToAddedRowBottom();
              requestAnimationFrame(scrollToAddedRowBottom);
            });
          } else if (this.masterRecordSavedScrollPosition || this._scrollToRestoreAfterDataBound) {
            // その他: 保存したスクロール位置を復元
            const pos = this.masterRecordSavedScrollPosition || this._scrollToRestoreAfterDataBound;
            if (!this.masterRecordSavedScrollPosition) {
              this._scrollToRestoreAfterDataBound = null;
            }
            this.restoreMasterRecordSavedGridScrollPosition(e.sender, pos);
          }
          if (!this.__pendingScrollToBottom && !this.__masterRecordInlineEdit) {
            this.scheduleMasterRecordFullVisualRefresh();
          }
          this.installValidationTooltipPlacementObserver();
          this.scheduleValidationTooltipPlacement();
        },
      });
      // widget を markRaw で保存（Vue の Proxy 対象から除外してパフォーマンス問題を防ぐ）
      this._directGridWidget = markRaw($(el).data('kendoGrid'));
      // kendo-validator を命令式で初期化（v-kendo-validator ディレクティブの代替）
      const ntssList = this.$refs.ntssList;
      if (ntssList) {
        destroyJQueryValidator(ntssList);
        this.kendoValidator = createJQueryValidator(ntssList, this.kendoValidatorSetup);
      }
      // Grid DOM 生成後にレイアウトを再計算（ロック列コンテナ幅を正しく適用）
      this.$nextTick(() => {
        this.installMasterRecordGridScrollListener();
        this.calculateColumnsWidth();
        this.calculateGridHeight();
        this.scheduleMasterRecordGridLayoutContract();
      });
    },
    installMasterRecordGridScrollListener() {
      const content = this.getGridScrollContainer();
      if (!content || content.__masterRecordScrollBound) {
        return;
      }
      content.__masterRecordScrollBound = true;
      content.addEventListener("scroll", () => {
        const pos = this.readMasterRecordCurrentGridScrollPosition();
        this.scrollPosition.top = pos.top || 0;
        this.scrollPosition.left = pos.left || 0;
        if (!this.masterRecordKeepScrollAfterSave) {
          clearTimeout(this.masterRecordSavedScrollClearTimer);
          this.masterRecordSavedScrollClearTimer = null;
          this._scrollToRestoreAfterDataBound = null;
        }
      }, { passive: true });
    },
    applyMasterRecordColumnsContract() {
      const grid = this.getKendoGrid();
      if (!grid) {
        return;
      }
      const nextColumns = this.buildColumns();
      const currentSignature = (grid.columns || []).map(col => `${col.field || ""}:${col.hidden ? 1 : 0}:${col.locked ? 1 : 0}:${col.width || ""}`).join("|");
      const nextSignature = nextColumns.map(col => `${col.field || ""}:${col.hidden ? 1 : 0}:${col.locked ? 1 : 0}:${col.width || ""}`).join("|");
      if (currentSignature !== nextSignature) {
        grid.setOptions({ columns: nextColumns });
        this.restoreMasterRecordSavedGridScrollPosition(grid);
        return;
      }
      nextColumns.forEach(column => {
        const gridColumn = grid.columns.find(col => col.field === column.field);
        if (gridColumn) {
          gridColumn.editable = column.editable;
          gridColumn.values = column.values;
          gridColumn.hidden = column.hidden;
          if (column.field === "leftDataIndex" || column.field === "rightDataIndex") {
            gridColumn.template = column.template;
          }
        }
      });
    },
    applyMasterRecordGridStyleContract() {
      const root = this.getGridRootEl?.() || this.$refs.gridEl;
      if (!root) {
        return;
      }
      root.classList.add(
        "ntss-kendo-grid-legacy",
        "k-widget",
        "k-grid",
        "k-editable",
        "k-display-block",
        "master-record-direct-jq-grid"
      );
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(`${selector} tr`).forEach((tr, index) => {
          tr.classList.add("k-master-row");
          tr.classList.toggle("k-alt", index % 2 === 1);
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(td => {
        td.classList.add("k-td", "k-table-td");
      });
      this.calculateGridWidth();
      this._repairLockedLayout();
    },
    scheduleMasterRecordGridLayoutContract() {
      if (this._masterRecordLayoutRafId != null) {
        cancelAnimationFrame(this._masterRecordLayoutRafId);
      }
        this._masterRecordLayoutRafId = requestAnimationFrame(() => {
          this.calculateGridWidth();
          this.applyMasterRecordGridStyleContract();
          this._masterRecordLayoutRafId = requestAnimationFrame(() => {
            this._masterRecordLayoutRafId = null;
            this.calculateGridWidth();
            this.applyMasterRecordGridStyleContract();
            this.refreshMasterRecordEditedVisualState();
            if (this.masterRecordKeepScrollAfterSave) {
              this.restoreMasterRecordSavedGridScrollPosition();
            }
          });
        });
    },
    applyMasterRecordLockedWidthContract(lockedWidthStyle) {
      if (!lockedWidthStyle) return;
      // Vue2/Kendo2019 wrapper では locked header/content が grid 直下にあり、width 指定だけで固定列幅が保持されていた。
      // Vue3/Kendo2026 jq 版では locked content が k-grid-container 配下の flex item になり、width だけでは小窓で shrink する。
      // HTML を Vue2 へ戻さず、Vue2 と同じ「固定列領域は dummy 10px + locked 列幅を保持する」布局契約だけを補う。
      [this.getGridLockedHeaderEl(), this.getGridLockedContentEl()].forEach(container => {
        if (!container) return;
        container.style.width = lockedWidthStyle;
        container.style.minWidth = lockedWidthStyle;
        container.style.maxWidth = lockedWidthStyle;
        container.style.flex = `0 0 ${lockedWidthStyle}`;
        container.style.flexBasis = lockedWidthStyle;
        container.style.flexShrink = '0';
        const table = container.querySelector?.('table');
        if (table) {
          table.style.width = lockedWidthStyle;
          table.style.minWidth = lockedWidthStyle;
        }
      });
    },
    // direct jq では Vue2 wrapper が内部で行っていた locked/non-locked の最終同期だけを軽量補正する。
    _repairLockedLayout() {
      const el = this.$refs.gridEl;
      if (!el) return;
      const gridContentEl = this.getGridContentEl();
      const gridLockedContentEl = this.getGridLockedContentEl();
      if (gridContentEl && gridLockedContentEl && !this.androidFlg && !this.iosFlg) {
        const height = gridContentEl.clientHeight || gridContentEl.offsetHeight;
        if (height > 0) {
          gridLockedContentEl.style.height = `${height}px`;
          gridLockedContentEl.style.maxHeight = `${height}px`;
        }
        gridLockedContentEl.scrollTop = gridContentEl.scrollTop;
      }
      const lockedWidthStyle = this.getGridLockedHeaderEl()?.style?.width
        || this.getGridLockedContentEl()?.style?.width;
      this.applyMasterRecordLockedWidthContract(lockedWidthStyle);
      if (gridContentEl) {
        try {
          gridContentEl.dispatchEvent(new Event('scroll', { bubbles: true }));
        } catch (_error) {
          $(gridContentEl).trigger('scroll');
        }
      }
      const gridRoot = this.getGridRootEl() || this.$refs.gridEl;
      if (gridRoot) {
        const forceRowSync = !!gridRoot.querySelector?.(".master-record-textarea-editor");
        syncKendoGridLockedRowHeights(gridRoot, { force: forceRowSync });
      }
    },
    calculateGridWidth() {
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
    },
    /** 並び順列 show/hide 後に locked 領域幅を再計算（hideColumn だけでは列幅が残る） */
    syncMasterRecordSortColumnLayout() {
      const grid = this.getKendoGrid();
      if (!grid) {
        return;
      }
      this.storeMasterRecordGridScrollForLayout();
      const scrollTop = this._layoutScrollTop ?? 0;
      const scrollLeft = this._layoutScrollLeft ?? 0;
      try {
        grid.resize(true);
      } catch (_error) { /* noop */ }
      this.calculateGridWidth();
      this._repairLockedLayout();
      this.applyMasterRecordGridScrollToWidget(scrollTop, scrollLeft, grid);
    },
    storeMasterRecordGridScrollForLayout() {
      const pending = this.masterRecordKeepScrollAfterSave
        ? (this.masterRecordSavedScrollPosition || this._scrollToRestoreAfterDataBound)
        : null;
      if (pending) {
        this._layoutScrollTop = pending.top || 0;
        this._layoutScrollLeft = pending.left || 0;
      } else {
        const pos = this.readMasterRecordCurrentGridScrollPosition();
        this._layoutScrollTop = pos.top || 0;
        this._layoutScrollLeft = pos.left || 0;
      }
      this.scrollPosition.top = this._layoutScrollTop;
      this.scrollPosition.left = this._layoutScrollLeft;
    },
    restoreMasterRecordGridScrollForLayout() {
      const top = this._layoutScrollTop ?? this.scrollPosition.top ?? 0;
      const left = this._layoutScrollLeft ?? this.scrollPosition.left ?? 0;
      this.applyMasterRecordGridScrollToWidget(top, left);
    },
    resizeDirectGrid() {
      const grid = this.getKendoGrid();
      if (!grid) return;
      this.storeMasterRecordGridScrollForLayout();
      const scrollTop = this._layoutScrollTop ?? 0;
      const scrollLeft = this._layoutScrollLeft ?? 0;
      try {
        try {
          grid.closeCell?.();
        } catch (_closeError) {
          // 編集中でなくても closeCell は失敗し得る。resize は継続する。
        }
        const height = Number(this.kendoGridHeight) || 0;
        const root = this.getGridRootEl?.() || this.$refs.gridEl;
        if (height > 0) {
          root?.style && (root.style.height = `${height}px`);
          root?.style && (root.style.maxHeight = `${height}px`);
          root?.style && (root.style.overflow = "hidden");
          grid.wrapper?.height?.(height);
          grid.element?.height?.(height);
        }
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
        this.applyMasterRecordGridScrollToWidget(scrollTop, scrollLeft, grid);
        // resize で tbody が再描画されると master-edited-row 等の手動配色が消える。
        this.refreshMasterRecordEditedVisualState();
        this.$nextTick(() => {
          this.restoreMasterRecordGridScrollForLayout();
          this.refreshMasterRecordEditedVisualState();
          requestAnimationFrame(() => {
            this.restoreMasterRecordGridScrollForLayout();
            this.refreshMasterRecordEditedVisualState();
          });
        });
      } catch (_error) { /* noop */ }
    },
    getDirectGridVisibleLockedWidthPx() {
      const root = this.getGridRootEl?.() || this.$refs.gridEl;
      const fontSize = parseFloat(getComputedStyle(root || document.body).fontSize || "16") || 16;
      return (this.columns || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) return sum;
        const width = `${column.width || ""}`.trim();
        if (width.endsWith("em")) return sum + parseFloat(width) * fontSize;
        if (width.endsWith("px")) return sum + parseFloat(width);
        const numeric = parseFloat(width);
        return sum + (Number.isFinite(numeric) ? numeric : 0);
      }, 0);
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootEl?.() || this.$refs.gridEl;
      const width = this.getDirectGridVisibleLockedWidthPx();
      if (!root || !width) return;
      const px = `${Math.ceil(width)}px`;
      root.querySelectorAll(".k-grid-header-locked,.k-grid-content-locked,.k-grid-header-locked > table,.k-grid-content-locked > table").forEach(element => {
        element.style.width = px;
        element.style.minWidth = px;
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getGridContentEl();
      const lockedContent = this.getGridLockedContentEl();
      if (!content || !lockedContent) return;
      lockedContent.style.height = `${content.clientHeight}px`;
      lockedContent.style.maxHeight = `${content.clientHeight}px`;
    },
    // MasterMaintenanceMixin の setGridDataSource をオーバーライド。
    // ① setDataSource() はスクロール位置をリセットするため dataSource.data() 方式を採用。
    // ② dataSource.data() は pageSize が設定された DataSource では先頭ページのみ返すことがある。
    //    そのため、常に this.masterRecords.data（Vuex の完全データ）を直接渡す。
    setGridDataSource(_dataSource) {
      const grid = this.getKendoGrid();
      if (!grid?.dataSource) return;
      try {
        const raw = Array.isArray(this.masterRecords?.data)
          ? this.masterRecords.data
          : [];
        grid.dataSource.data(raw);
      } catch (_e) {}
    },
    // mixin の getGridScrollPosition は仮想スクロール前提で
    //   scrollable.lastChild.scrollTop (= table の 0) を ?? で取って常に 0 を返すバグがある。
    // 普通スクロールの場合、scrollable.scrollTop（= .k-grid-content の scrollTop）が正しい値。
    getGridScrollPosition() {
      const scrollable = this.getGridScrollContainer();
      return {
        top:  scrollable?.scrollTop  || 0,
        left: scrollable?.scrollLeft || 0,
      };
    },
    setGridScrollPosition(position = {}) {
      const top = position.top || 0;
      const left = position.left || 0;
      this.applyMasterRecordGridScrollToWidget(top, left);
      const content = this.getGridScrollContainer();
      if (content) {
        try {
          content.dispatchEvent(new Event('scroll', { bubbles: true }));
        } catch (_error) {
          $(content).trigger('scroll');
        }
      }
    },
    readMasterRecordCurrentGridScrollPosition() {
      const grid = this.getKendoGrid();
      const content = grid?.content?.[0] || this.getGridContentEl?.() || null;
      const scrollable = this.getGridScrollContainer();
      const virtualScrollbar = grid?.virtualScrollable?.verticalScrollbar?.[0] || null;
      const topValues = [virtualScrollbar?.scrollTop, content?.scrollTop, scrollable?.scrollTop]
        .map(value => Number(value))
        .filter(value => Number.isFinite(value));
      const leftValues = [content?.scrollLeft, scrollable?.scrollLeft]
        .map(value => Number(value))
        .filter(value => Number.isFinite(value));
      return {
        top: topValues.length ? Math.max(...topValues) : 0,
        left: leftValues.length ? Math.max(...leftValues) : 0,
      };
    },
    saveMasterRecordGridScrollPosition() {
      const position = this.readMasterRecordCurrentGridScrollPosition();
      this.scrollPosition.top = position.top || 0;
      this.scrollPosition.left = position.left || 0;
      this.masterRecordSavedScrollPosition = {
        top: this.scrollPosition.top,
        left: this.scrollPosition.left,
      };
      this._scrollToRestoreAfterDataBound = { ...this.masterRecordSavedScrollPosition };
      this.masterRecordKeepScrollAfterSave = true;
      this.setScrollTopPosition(this.scrollPosition.top);
      this.setScrollLeftPosition(this.scrollPosition.left);
    },
    restoreMasterRecordSavedGridScrollPosition(widget = null, position = null) {
      const pos = position || this.masterRecordSavedScrollPosition || this._scrollToRestoreAfterDataBound;
      if (!pos) {
        return;
      }
      clearTimeout(this.masterRecordSavedScrollClearTimer);
      this.masterRecordSavedScrollClearTimer = null;
      const restore = () => this.applyMasterRecordGridScrollToWidget(pos.top || 0, pos.left || 0, widget);
      restore();
      this.$nextTick(() => {
        restore();
        requestAnimationFrame(restore);
      });
      this.masterRecordSavedScrollClearTimer = setTimeout(() => {
        this.masterRecordKeepScrollAfterSave = false;
        this.masterRecordSavedScrollPosition = null;
        this._scrollToRestoreAfterDataBound = null;
        this.masterRecordSavedScrollClearTimer = null;
      }, 3000);
    },
    rollbackMasterRecordSavedGridScroll() {
      if (!this.masterRecordKeepScrollAfterSave && !this.masterRecordSavedScrollPosition) {
        return;
      }
      this.restoreMasterRecordSavedGridScrollPosition();
    },
    // --- ここまで Kendo Grid 初期化 ---
    getGridContentElement() {
      return this.getGridContentEl?.() || null;
    },
    getMasterRecordScopeRoot() {
      return this.$el || this.$refs.gridEl || null;
    },
    getMasterRecordGridElement() {
      return this.$refs.gridEl || this.getMasterRecordScopeRoot()?.querySelector?.('#grid') || getScopedElementById("grid", this.getMasterRecordScopeRoot());
    },
    getMasterRecordGridHeaderWrap() {
      const root = this.getGridRootEl?.() || this.$refs.gridEl;
      return root?.querySelector?.(".k-grid-header-wrap") || null;
    },
    getMasterRecordEditorRoot(container = null) {
      return container?.[0] || container?.get?.(0) || this.getMasterRecordGridElement() || this.getMasterRecordScopeRoot() || null;
    },
    getMasterRecordEditorElement(selector, container = null) {
      const editorRoot = this.getMasterRecordEditorRoot(container);
      return editorRoot?.querySelector?.(selector)
        || this.getMasterRecordGridElement()?.querySelector?.(selector)
        || queryScopedSelector(selector, this.getMasterRecordGridElement() || this.getMasterRecordScopeRoot())
        || null;
    },
    getMasterRecordResizeTargetEl(container = null) {
      return this.getMasterRecordEditorRoot(container)?.querySelector?.('.resize-obs-target')
        || this.getMasterRecordGridElement()?.querySelector?.('.resize-obs-target')
        || queryScopedSelector('.resize-obs-target', this.getMasterRecordGridElement() || this.getMasterRecordScopeRoot())
        || null;
    },
    getMasterRecordDirtyCells() {
      return queryScopedSelectorAll('.k-dirty', this.getMasterRecordGridElement() || this.getMasterRecordScopeRoot());
    },
    handleAddValidateArrow() {
      MasterMaintenanceMixin.methods.handleAddValidateArrow.call(this);
      this.scheduleValidationTooltipPlacement();
    },
    addInputAssist(ev) {
      MasterMaintenanceMixin.methods.addInputAssist.call(this, ev);
      this.$nextTick(() => {
        this.scheduleValidationTooltipPlacement();
      });
    },
    masterRecordCellClose(ev) {
      this.clearMasterRecordValidationTooltipPlacementState();
      MasterMaintenanceMixin.methods.editEnd.call(this, ev);
    },
    // add 9664 by kangjie 20231211 start
    ...mapMutations("pat-info", ["setSelectedPat", "setIsPatInfoVisible", "setIndUserList", "setIsIndUserSetting", "setIndUserId", "setIsPatInfoChaned"]),
    // add 9664 by kangjie 20231211 end
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
    ...mapMutations("master-maintenance", ["setScrollTopPosition", "setScrollLeftPosition", "bumpMasterRecordListRevision"]),
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end

    // #8519 【デグレ】編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    paintMasterRecordGridVisuals() {
      // グリッドが表示されていなかったら処理終了
      const gridHeader = this.getGridHeaderEl();
      if (!gridHeader || gridHeader.textContent === " ") {
        return;
      }
      gridHeader?.classList?.add("master-grid-header");
      // グリッドにレコードがなければ処理終了
      if (!this.getGridTableEl()?.tBodies) {
        return;
      }
      // 固定列、可変列、データソースの取得
      const tbodyc = this.getGridBodyRows();
      const gridData = this.getGridDataSource();
      if (this.getGridLockedTableEl()?.tBodies != undefined) {
        let lockTbodyc = (this.getGridLockedTbodyEl()?.children || []);

        // 列の行数は固定・可変で同一なため可変列の行数を使用
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          const currentLockTrc = lockTbodyc[rwCount].children;

          // 並び順の色変更（手入力で変更した行のみ）
          const rowRecord = gridData._view?.[rwCount];
          if (rowRecord && this.isMasterRecordSortRankEdited(rowRecord)) {
            this.applyMasterRecordSortRankVisual(currentLockTrc);
          } else {
            this.clearMasterRecordSortRankVisual(currentLockTrc);
          }
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc, currentLockTrc);
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc);
          // モーダルからの編集も色を変更する
          if (this.isEdited(gridData._view[rwCount].code)) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
          // データ参照エラーコンボの背景色を変更
          if (this.masterPhysicalName !== "mst_medicine") {
            this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          }
        }
      }
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        this.paintMasterRecordGridVisuals();
      });
    },
    /** resize / 列幅再計算後に編集行の緑背景を即時復元する（MstBed と同方針） */
    refreshMasterRecordEditedVisualState() {
      if (this.__masterRecordSortApplying || this.__masterRecordInlineEdit) {
        return;
      }
      this.paintMasterRecordGridVisuals();
    },
    // #8519 【デグレ】編集した項目のバッググラウンドが黄緑にならない 訾浩 end
    ...mapActions("multi-modal", ["showMasterEdit", "showMstExamItemRecManagementModal"]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel",
      "getDeviceEdgeNoList",
      "mstSyncDeviceEdge",
      "findRecordListByFacilityCd"
     ,"updateIndCondInfo",
      "findFacilitySettingInfo",
      "getMasterDeviceEdgeNoListByFacilityCd"
    ]),
    ...mapActions("treatment-record/common", ["sendNextPatInfo",]),
    ...mapActions("master-maintenance", {
      facilityList: "facilityList"
    }),
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    ...mapActions("pat-viewer", ["getMstMedicineIncludeDeleted", "getMstMedicineMixIncludeDeleted", "getMstProcedure", "getMstMedicateTiming"]),
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    init() {
      if (this.dataSourceItems && typeof this.dataSourceItems.data === 'function') {
        this.dataSourceItems.data([...this.masterRecords.data])
      }
    },
    // add start #9301
    async getDefaultCd () {
      const defaultMedicateTimingData = await this.findFacilitySettingInfo({
        facilityCd: this.getFacilitySwitch,
        settingNo: DEFAULT_MEDICATE_TIMING
      });
      this.defaultMedicateTimingDataCd = defaultMedicateTimingData?.data || null;
      const defaultProcedureData = await this.findFacilitySettingInfo({
        facilityCd: this.getFacilitySwitch,
        settingNo: DEFAULT_PROCEDURE
      });
      this.defaultProcedureCd = defaultProcedureData?.data || null;
    },
    // add end #9301
    /**
     * DBのYYYYMMDD形式をKendo日付列表示用のDateに変換する.
     * @param {*} value 日付値
     * @returns {Date|*} 変換後のDate、または変換不要時は元の値
     */
    yyyymmddToDate(value) {
      if (value == null || value === "") {
        return value;
      }
      if (value instanceof Date) {
        return value;
      }
      const str = String(value);
      const fromYyyymmdd = dayjs(str, "YYYYMMDD", true);
      if (fromYyyymmdd.isValid()) {
        return fromYyyymmdd.toDate();
      }
      const fromIsoDate = dayjs(str, "YYYY-MM-DD", true);
      if (fromIsoDate.isValid()) {
        return fromIsoDate.toDate();
      }
      const fromIsoDateTime = str.match(/^(\d{4})-(\d{2})-(\d{2})T/);
      if (fromIsoDateTime) {
        return new Date(
          Number(fromIsoDateTime[1]),
          Number(fromIsoDateTime[2]) - 1,
          Number(fromIsoDateTime[3])
        );
      }
      return value;
    },
    /**
     * 使用開始日・使用終了日をグリッド表示用に変換する.
     * @param {Array} data マスタレコード一覧
     */
    convertUseTermDatesForGrid(data) {
      if (!Array.isArray(data)) {
        return;
      }
      const dateFields = ["useStartDate", "useEndDate"];
      if (this.masterPhysicalName === "mst_treatment" || this.masterPhysicalName === "mst_procedure") {
        dateFields.push("inHospAStartdate", "inHospBStartdate");
      }
      data.forEach(row => {
        dateFields.forEach(field => {
          if (row[field] != null && row[field] !== "") {
            row[field] = this.yyyymmddToDate(row[field]);
          }
        });
      });
    },
    // グリッドのデータ再表示
    gridDataRefresh() {
      this.dataSourceItems = this.generatedGridData();
      this.setGridDataSource(this.dataSourceItems);
    },
    getMasterRecordGridPageSize() {
      const rowHeight = this.getGridRootEl?.()?.querySelector?.('.k-grid-content tr')?.clientHeight || 40;
      const gridHeight = Number(this.kendoGridHeight) || this.$refs.gridEl?.offsetHeight || 900;
      return Math.max(1, Math.ceil(gridHeight / rowHeight) + 5);
    },
    generatedGridData(source = this.masterRecords) {
      const data = Array.isArray(source?.data) ? source.data : [];
      const schema = source?.schema || {};
      return markRaw(createDirectDataSource({
        //6661:スクロールバー異常 - pageSize は設定しない（Vue2 と同じ動作）
        data,
        schema,
      }));
    },
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
        // 選択した施設を元にベッド一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
          // 選択した施設を元にベッド一覧の取得
          this.findList();
        })
        .catch(error => {
          if (error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MasterRecordComponent.vue', 'facilityList', '指定されたマスタが見つかりません。');
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          else{
            getErrorMessage('MasterRecordComponent.vue', 'facilityList', error);
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        });
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
    onChangeFacility(e) {
      if(this.prevFacilityCd != e.sender._old) {
        // 選択施設の拡張設定を取得
        var newFacilityAdvancedSettings = {};
        let selectedIndex = getDirectWidgetSelectedIndex(e.sender);
        try {
          const selectedFacility = getDirectWidgetDataAt(e.sender, selectedIndex);
          if (selectedFacility?.advancedSettings) {
            newFacilityAdvancedSettings = JSON.parse(selectedFacility.advancedSettings);
          }
        } catch(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MasterRecordComponent.vue', 'onChangeFacility' , error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          newFacilityAdvancedSettings = {};
        }

        if (!newFacilityAdvancedSettings.func_advcds) {
          newFacilityAdvancedSettings.func_advcds = [];
        }

        const enableHomeDialysis = newFacilityAdvancedSettings.func_advcds.some(
          setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
        );

        if (this.isChanged){
          // 編集時は未保存確認メッセージを出力する
          const newFacilityCd = e.sender._old;
          e.preventDefault();
          this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                // 選択した施設を元に装置一覧の取得
                this.facilitylistValue = newFacilityCd;
                // 選択施設の在宅機能有無を取得
                this.facilityHemoDialysis = enableHomeDialysis;
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilitylistValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に装置一覧の取得
          this.facilitylistValue = e.sender._old;
          // 選択施設の在宅機能有無を取得
          this.facilityHemoDialysis = enableHomeDialysis;
          this.findList();
        }
      }
    },
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-synchro", ["startMstSynchro"]),
    eachModelCalendar(container, data) {
      console.log('data',data);
      
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        let moveOutFlg = false;
        container.mouseenter(() => moveOutFlg = false);
        container.mouseleave(() => moveOutFlg = true);
        // デスクトップ、iOSの場合は、処理で補正したHTML5のカレンダーを表示
        let nowData;
        let hasInitValue = true;
        const editedData = data.model[data.field];
        let nowDtatString;
        if (editedData) {
          nowData = new Date(editedData);
        } else {
          nowData = new Date();
          hasInitValue = false;
        }
        nowDtatString = nowData.getFullYear() + "-" + ('0' + (nowData.getMonth() + 1)).slice(-2) + "-" + ('0' + nowData.getDate()).slice(-2);
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
        if (!editedData) {
          nowDtatString = "";
        }
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
        $(
          `<span style="position:relative"><input type="date" style="width:8em" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:75%;top:-1px;color: #212529;z-index:9999999" ></span></span>`).appendTo(container);
        const getEditorElement = (selector) => this.getMasterRecordEditorElement(selector, container);
        const displayedDummyEditor = getEditorElement("#displayedDummyEditor");
        const hiddenDateInputEditor = getEditorElement("#hiddenDateInputEditor");
        const clearButton = getEditorElement("#clear");
        // フォーカスアウトで編集データを反映するイベントを発火
        displayedDummyEditor?.addEventListener("blur", function(ev) {
          if (!moveOutFlg) {
            return;
          }

          let resultData;
          const dayData = new Date(ev.target.value);
          // 初期と編集後の値が空欄の場合、更新レコードとして判断しない
          if (ev.target.value === "" && !hasInitValue) {
            resultData = "";
            nowDtatString = "";
            hasInitValue = true;
          } else {
            resultData = dayData.getFullYear() + "-" + ('0' + (dayData.getMonth() + 1)).slice(-2) + "-" + ('0' + dayData.getDate()).slice(-2);
          }
          // 変更前の値と比較し、同じ値の場合は処理しない。又は、初期値がない場合、必ず処理する。
          if (!hasInitValue || nowDtatString != resultData) {
            hiddenDateInputEditor.value = resultData;
            // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
            $(hiddenDateInputEditor).trigger('change');
          }
        });

        const editorDocument = this.getMasterRecordEditorRoot(container)?.ownerDocument || this.$el?.ownerDocument || document;
        const commonCalenderMountNode = editorDocument.createElement("span");
        container.append(commonCalenderMountNode);
        // 前回のカレンダーアプリを破棄（メモリリーク防止）
        this._calendarApp?.unmount();
        this._calendarApp = null;
        const commonCalenderApp = createApp(commonCalender, {
          onInput: value => {
            hiddenDateInputEditor.value = value;
            // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
            $(hiddenDateInputEditor).trigger('change');
            this.getKendoGrid()?.closeCell?.();
          }
        });
        this._calendarApp = commonCalenderApp;
        let commonCalenderPicker = commonCalenderApp.mount(commonCalenderMountNode);
        console.log('commonCalenderPicker',commonCalenderPicker);
        commonCalenderPicker.setSilently(nowDtatString);
        //  #5590 2023/05/15 iPadでSafariを使うと、数字に×が被る。修正 張博 start
        const userAgent = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
        if (userAgent.indexOf("Intel Mac OS") > -1) {
           displayedDummyEditor?.addEventListener("change", (ev) => {
           hiddenDateInputEditor.value = ev.target.value;
           $(hiddenDateInputEditor).trigger('change');
        });
        }else{
          displayedDummyEditor?.addEventListener("change", (ev) => {
              commonCalenderPicker.setSilently(ev.target.value);
        });
        }
        //  #5590 2023/05/15 iPadでSafariを使うと、数字に×が被る。修正 張博 end
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
        // let clear = `<span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:relative;right:65px;bottom:1px;color: #212529;z-index:9999999" ></span>`
        // container.append(clear);
        clearButton?.addEventListener("mousedown", function(ev) {
          hiddenDateInputEditor.value = null;
          $(hiddenDateInputEditor).trigger('change');
        });
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
        //  #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 start
        clearButton?.addEventListener("touchstart", function(ev) {
          hiddenDateInputEditor.value = null;
          $(hiddenDateInputEditor).trigger('change');
        });
        //  #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 end
      }
    },
    comboEditor(container, data) {
      if (this.masterPhysicalName !== "mst_monitor_graph") {
        return;
      }
      const that = this;
      const $container = $(container);
      const $input = $(`<input name="${data.field}" />`).appendTo($container);
      const resolveDropdownEditCell = () => {
        const grid = that.getKendoGrid();
        const editField = grid?.editable?.options?.fields?.field
          || grid?.editable?.options?.field;
        if (editField && editField !== data.field) {
          return $();
        }
        if ($container.is("td, .k-table-td")) {
          return $container;
        }
        const $fromContainer = $container.closest("td, .k-table-td");
        if ($fromContainer.length) {
          return $fromContainer;
        }
        return $(grid?.editable?.element).closest("td, .k-table-td");
      };
      let selectionCommitted = false;
      const finishSelection = (selectedValue) => {
        if (selectionCommitted || selectedValue === null || selectedValue === undefined) {
          return;
        }
        selectionCommitted = true;
        that.applyMonitorGraphDataIndexLimits(data, selectedValue);
        const storeRows = that.getMasterRecordList?.data;
        if (Array.isArray(storeRows)) {
          const storeRow = storeRows.find(row => String(row.code) === String(data.model.code));
          if (storeRow) {
            storeRow[data.field] = selectedValue;
          }
        }
        const dropdown = $input.data("kendoDropDownList");
        const displayText = that.getMonitorGraphItemDisplayText(selectedValue);
        if (that.isMasterRecordAddedRow(data.model)) {
          data.model[data.field] = selectedValue;
          that.markMasterRecordModelFieldDirty(data.model, data.field);
          if (dropdown?.destroy) {
            dropdown.destroy();
          }
          const $cell = resolveDropdownEditCell();
          if ($cell.length) {
            $cell
              .attr("data-field", data.field)
              .removeClass("k-edit-cell k-invalid master-deleted-combo");
            $cell[0].querySelectorAll?.(
              ".k-invalid-msg, .k-tooltip-validation, .k-tooltip-error"
            )?.forEach?.(node => node.remove());
            $cell.empty();
            that.markMasterRecordGridCellDirty($cell[0], data.field);
            if (displayText) {
              $cell[0].appendChild($cell[0].ownerDocument.createTextNode(displayText));
            }
          }
          const grid = that.getKendoGrid();
          if (grid?.editable) {
            grid.editable = null;
          }
          $cell.closest("tr").removeClass("k-grid-edit-row");
          that.scheduleMasterRecordDropdownEditorCommit(data.model, data.field, selectedValue);
          return;
        }
        if (typeof data.model.set === "function") {
          data.model.set(data.field, selectedValue);
        } else {
          data.model[data.field] = selectedValue;
        }
        that.getKendoGrid()?.closeCell?.();
        that.scheduleMasterRecordDropdownEditorCommit(data.model, data.field, selectedValue);
      };
      $input.kendoDropDownList({
        dataSource: that.mstMonitorGraphItem,
        dataTextField: "text",
        dataValueField: "value",
        valuePrimitive: true,
        value: data.model[data.field],
        filter: "contains",
        select(e) {
          finishSelection(e.dataItem?.value);
        },
        change(e) {
          if (typeof e.sender.value === "function") {
            finishSelection(e.sender.value());
          }
        },
      });
      $input.data("kendoDropDownList")?.wrapper?.css("width", "100%");
    },
    getMonitorGraphItemDisplayText(value) {
      if (value === null || value === undefined || value === "") {
        return "";
      }
      const match = this.mstMonitorGraphItem.find(item => String(item.value) === String(value));
      return match ? String(match.text) : String(value);
    },
    applyMonitorGraphDataIndexLimits(data, selectedValue) {
      const sysMonitorItemObj = this.sysMonitorItemList.find(item => item.moni_data_no == selectedValue);
      const setData = (key, min, max) => {
        if (data.model[key] > max) {
          data.model[key] = max;
        }
        if (data.model[key] < min) {
          data.model[key] = min;
        }
      };
      if (sysMonitorItemObj) {
        const decimals = sysMonitorItemObj.decimal_figure;
        const min = sysMonitorItemObj.lower / Math.pow(10, decimals);
        const max = sysMonitorItemObj.upper / Math.pow(10, decimals);
        if (data.field === "leftDataIndex") {
          setData("leftGraphLowerLimit", min, max);
          setData("leftGraphUpperLimit", min, max);
        }
        if (data.field === "rightDataIndex") {
          setData("rightGraphLowerLimit", min, max);
          setData("rightGraphUpperLimit", min, max);
        }
      } else {
        const masterField = this.getMasterRecordList.schema.model.fields;
        if (data.field === "leftDataIndex") {
          setData("leftGraphUpperLimit", masterField.leftGraphLowerLimit.validation.min, masterField.leftGraphLowerLimit.validation.max);
          setData("leftGraphLowerLimit", masterField.leftGraphUpperLimit.validation.min, masterField.leftGraphUpperLimit.validation.max);
        }
        if (data.field === "rightDataIndex") {
          setData("rightGraphLowerLimit", masterField.rightGraphLowerLimit.validation.min, masterField.rightGraphLowerLimit.validation.max);
          setData("rightGraphUpperLimit", masterField.rightGraphUpperLimit.validation.min, masterField.rightGraphUpperLimit.validation.max);
        }
      }
    },
    formatMonitorGraphItemLabel(value) {
      const text = this.getMonitorGraphItemDisplayText(value);
      return text ? this.$sanitize(text) : "";
    },
    isMasterRecordAddedRow(model) {
      if (!model) {
        return false;
      }
      if (Number(model.operation) === 1 || model.isAddRow === true) {
        return true;
      }
      const storeRow = this.getMasterRecordList?.data?.find(
        row => row && String(row.code) === String(model.code)
      );
      return !!storeRow && Number(storeRow.operation) === 1;
    },
    applyMasterRecordDropdownCellLabel(model, field, value) {
      const displayText = this.getMonitorGraphItemDisplayText(
        value !== null && value !== undefined
          ? value
          : (typeof model?.get === "function" ? model.get(field) : model?.[field])
      );
      const $cell = this.findMasterRecordGridCellElement(model, field);
      if (!$cell?.length) {
        return;
      }
      const el = $cell[0];
      $cell.removeClass("k-edit-cell k-invalid master-deleted-combo");
      const marker = el.querySelector(".k-dirty");
      if (String($cell.text() || "").trim() === String(displayText || "").trim()) {
        return;
      }
      Array.from(el.childNodes).forEach(node => {
        if (node !== marker) {
          el.removeChild(node);
        }
      });
      if (displayText) {
        el.appendChild(el.ownerDocument.createTextNode(displayText));
      }
    },
    getMasterRecordLeafColumnIndex(field, locked) {
      const grid = this.getKendoGrid();
      if (!grid || !field) {
        return -1;
      }
      let index = 0;
      for (const col of grid.columns || []) {
        if (!col?.field || col.hidden) {
          continue;
        }
        if (!!col.locked !== !!locked) {
          continue;
        }
        if (col.field === field) {
          return index;
        }
        index += 1;
      }
      return -1;
    },
    findMasterRecordGridCellElement(model, field) {
      const grid = this.getKendoGrid();
      if (!grid || !model || !field) {
        return $();
      }
      const $editable = grid.editable?.element;
      const editField = grid.editable?.options?.fields?.field || grid.editable?.options?.field;
      if ($editable?.length && editField === field) {
        const $editCell = $editable.closest("td");
        if ($editCell.length) {
          return $editCell;
        }
      }
      const uid = typeof model.uid === "function" ? model.uid() : model.uid;
      const root = $(grid.wrapper || grid.element || this.getMasterRecordGridElement() || []);
      if (uid) {
        const $byAttr = root.find(`tr[data-uid="${uid}"] td[data-field="${field}"]`);
        if ($byAttr.length) {
          return $byAttr;
        }
      }
      const column = (grid.columns || []).find(col => col.field === field);
      const isLocked = !!column?.locked;
      const cellIndex = this.getMasterRecordLeafColumnIndex(field, isLocked);
      if (cellIndex < 0) {
        return $();
      }
      const findInTable = ($table) => {
        if (!$table?.length) {
          return $();
        }
        if (uid) {
          const $row = $table.find(`tr[data-uid="${uid}"]`);
          const $cell = $row.children().eq(cellIndex);
          if ($cell.length) {
            return $cell;
          }
        }
        let $found = $();
        $table.find("tr").each(function() {
          const item = grid.dataItem(this);
          if (item && String(item.code) === String(model.code)) {
            $found = $(this).children().eq(cellIndex);
            return false;
          }
        });
        return $found;
      };
      const $cell = isLocked ? findInTable(grid.lockedTable) : findInTable(grid.tbody);
      if ($cell.length) {
        return $cell;
      }
      const $fallback = findInTable(grid.tbody);
      return $fallback.length ? $fallback : findInTable(grid.lockedTable);
    },
    colorEditor(container, data) {
      // const dummyField = $("<input/>")
      //   .attr("name", data.field)
      //   .css("display", "none")
      //   .appendTo(container);

      // const colorPicker = $("<input/>")
      //   .appendTo(container)
      //   .mountColorPicker({
      //     value: data.model[data.field],
      //     palette: "basic",
      //     tileSize: {
      //       width: 32,
      //       height: 24
      //     },
      //     change: (e) => {
      //       // コンソールにエラーが出るためにnextTickで遅らせている
      //       this.$nextTick(() => {
      //         dummyField.val(e.value).trigger("change");
      //       });
      //     }
      //   });

      // // パレットを開く
      // colorPicker.open();
      const dummyField = $(`<input type="color" data-bind="value:${data.field}" style="inline-size: 50px !important;" />`).appendTo(container);
      this.$nextTick(() => {
        const colorInput = dummyField[0];
        const ownerWindow = colorInput?.ownerDocument?.defaultView || window;
        ownerWindow.requestAnimationFrame(() => {
          colorInput?.focus?.({ preventScroll: true });
          try {
            colorInput?.showPicker?.();
          } catch (_error) {
            colorInput?.click?.();
          }
        });
      });
    },
    /**
     * @description textarea(改行可能なテキストボックス)用のkendo editor
     */
    textareaEditor(container, data) {
      if (this.masterPhysicalName == "mst_mainte_detail" && (!data.model.isCmt || data.model.isCmt == "0")) {
        return;
      }
      const $textarea = $(
        `<textarea name="${data.field}" class="k-valid k-textarea resize-obs-target master-record-textarea-editor" style="font-size: 1.0em; width:100%; height:6.8em; min-height:6.8em; overflow-y:auto; resize:vertical; max-height:65vh; box-sizing:border-box;"/>`
      ).appendTo(container);
      const textareaEl = $textarea[0];
      if (!textareaEl) {
        return;
      }
      if (this.resizeObserver != null) {
        this.resizeObserver.disconnect();
      }
      // 手動リサイズ時のみ locked 列と行高を同期（入力による自動伸長は行わない）
      this.resizeObserver = new ResizeObserver(() => {
        this.scheduleMasterRecordGridLayoutContract();
      });
      this.resizeObserver.observe(textareaEl);
      // セル編集開始直後は locked / body 行高がずれるため、スクロール前に同期する
      this.$nextTick(() => {
        this.scheduleMasterRecordGridLayoutContract();
      });
    },
    numericEditor(container, options) {
      // ダイアライザマスタ変更  杜 start
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
      // const format = options.format.slice(3, options.format.length - 1);
      let format = options.format.slice(3, options.format.length - 1);
      // const decimals = format.slice(1);
      let decimals = format.slice(1);
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
      let parameter = { format, decimals, round: false };
      // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
      // let strinput= '<input data-bind="value:' + options.field + '"/> ';
      let strinput= '<input id="myInputNumber" style="text-align:right" data-bind="value:' + options.field + '"/> ';
      // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
      const masterField = this.getMasterRecordList.schema.model.fields[options.field];
      // 負担率の入力制限不正 (保険マスタ) start
      // mod 治療記録バイタルグラフマスタ 3、サイズ下上限「0-10」 start
      // if (this.masterPhysicalName == "mst_insurance" || this.masterPhysicalName == "mst_medicate_timing") {
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
      // if (this.masterPhysicalName == "mst_insurance" || this.masterPhysicalName == "mst_medicate_timing" || this.masterPhysicalName == "mst_vital_graph" || this.masterPhysicalName == "mst_monitor_graph") {
      if (this.masterPhysicalName == "mst_insurance" || this.masterPhysicalName == "mst_medicate_timing" || this.masterPhysicalName == "mst_vital_graph") {
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
      // mod 治療記録バイタルグラフマスタ 3、サイズ下上限「0-10」 end
        parameter = { format, decimals, round: false,  min: masterField.validation.min, max: masterField.validation.max};
      // 負担率の入力制限不正 (保険マスタ) end
      // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
      }else if (this.masterPhysicalName == "mst_monitor_graph") {
        const dataIndexObj = {
          leftGraphUpperLimit: {
            dataIndex: options.model.leftDataIndex
          },
          leftGraphLowerLimit: {
            dataIndex: options.model.leftDataIndex
          },
          rightGraphUpperLimit: {
            dataIndex: options.model.rightDataIndex
          },
          rightGraphLowerLimit: {
            dataIndex: options.model.rightDataIndex
          },
        };
        let min = masterField.validation.min;
        let max = masterField.validation.max;
        if (dataIndexObj[options.field]?.dataIndex) {
          const sysMonitorItemObj = this.sysMonitorItemList.find(item => item.moni_data_no == dataIndexObj[options.field].dataIndex);
          if (sysMonitorItemObj) {
            decimals = sysMonitorItemObj.decimal_figure;
            min = sysMonitorItemObj.lower /  Math.pow(10, decimals);
            max = sysMonitorItemObj.upper /  Math.pow(10, decimals);
            format = "n" + decimals;
          }
        }
        parameter = { format, decimals, round: false,  min, max, step: Math.pow(10,-decimals)};
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
      }else if (this.masterPhysicalName == "mst_dialyzer") {
        parameter = { format, decimals, round: false, min: masterField.validation.min, max: masterField.validation.max, step :Math.pow(10,-decimals),};
        if (masterField.validation.required) {
          // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
          //strinput = '<input data-bind="value:' + options.field + '"required="true" validationMessage ="'+masterField.validation.validationMessage+'" /> ';
          strinput = '<input id="myInputNumber" style="text-align:right" data-bind="value:' + options.field + '"required="true" validationMessage ="'+masterField.validation.validationMessage+'" /> ';
          // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
        }
      }else if (this.masterPhysicalName == "sys_medicine" || this.masterPhysicalName == "mst_medicine_group"){
        if(masterField.validation.maxlength) {
            let maxlength = masterField.validation.maxlength;
            masterField.validation.max = Math.pow(10,maxlength-decimals) - Math.pow(10,-decimals);
            masterField.validation.min = (Math.pow(10,maxlength-decimals) - Math.pow(10,-decimals)) *-1;
        }
        parameter = { format, decimals, round: false, min: masterField.validation.min, max: masterField.validation.max, step :Math.pow(10,-decimals),};
      }
      // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s start
      else if (this.masterPhysicalName == "mst_water_survey_type") {
        if( options.field=="decimalDigits" || options.field=="integerDigits") {
            // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt Start
            parameter = {
              format,
              decimals,
              round: false,
              min: WATER_SURVEY_TYPE_DIGIT_MIN,
              max: WATER_SURVEY_TYPE_DIGIT_MAX,
              step: 1,
              change: (e) => this.numericalCollation(
                e,
                options,
                WATER_SURVEY_TYPE_DIGIT_MAX,
                WATER_SURVEY_TYPE_DIGIT_MIN
              )
            };
            // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt End
        }
        if (options.field=="upperThreshold" || options.field=="lowerThreshold" ||
          options.field=="graphUpperLimit" || options.field=="graphLowerLimit" ||
          options.field=="initialValue"
        ) {
          const bounds = this.getWaterSurveyThresholdBounds(
            options.model.integerDigits,
            options.model.decimalDigits
          );
          const formatTemp = "n" + bounds.decimalDigits;
          parameter = {
            format: formatTemp,
            decimals: bounds.decimalDigits,
            round: false,
            step: Math.pow(10, -bounds.decimalDigits).toFixed(bounds.decimalDigits),
            min: bounds.min,
            max: bounds.max,
          };
        }
      } else if (this.masterPhysicalName === "mst_medicine_support") {
        parameter = { format, decimals, round: false, step :Math.pow(10,-decimals)};
      }
      // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s end

      // add #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
      let parameterDecimals = parameter.decimals ? Number(parameter.decimals) : 1
      let parameterStep = parameter.step ? BigNumber(parameter.step).toNumber() : 1
      let parameterFormat = parameter.format;
      let parameterRound = parameter.round;
      let parameterMin = parameter.min !== undefined && parameter.min !== null
        ? BigNumber(parameter.min).toNumber()
        : 0;
      let parameterMax = parameter.max !== undefined && parameter.max !== null
        ? BigNumber(parameter.max).toNumber()
        : 999999;
      const hasParameterMin = parameter.min !== undefined && parameter.min !== null;
      const hasParameterMax = parameter.max !== undefined && parameter.max !== null;
      const parameterEditorFormat = toUngroupedKendoNumberFormat(parameterFormat, parameterDecimals);
      const isWaterSurveyThresholdEditor = this.isWaterSurveyThresholdField(options.field);
      const isWaterSurveyDigitEditor = this.masterPhysicalName === "mst_water_survey_type"
        && (options.field === "integerDigits" || options.field === "decimalDigits");

      const normalizeNumericEditorValue = (rawValue) => {
        let value = rawValue;
        if (value === null || value === undefined || value === "") {
          return value;
        }
        if (this.masterPhysicalName == "mst_monitor_graph") {
          value = this.roundValue(value, parameter.decimals, BigNumber.ROUND_HALF_UP);
        } else if (this.masterPhysicalName == "mst_water_survey_type") {
          if (this.isWaterSurveyThresholdField(options.field)) {
            return roundAndClampWaterSurveyThresholdValue(
              value,
              options.model.integerDigits,
              options.model.decimalDigits
            );
          }
          value = this.roundValue(value, parameter.decimals, WATER_SURVEY_ROUND_MODE);
        }
        if ("mst_medicate_timing" == this.masterPhysicalName && "alertTime" == options.field && value === null) {
          value = 0;
        }
        if (!isWaterSurveyThresholdEditor) {
          if (value > parameterMax) {
            value = parameterMax;
          } else if (value < parameterMin) {
            value = parameterMin;
          }
        }
        return value;
      };

      // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Add by Zt Start
      let changeEvent = parameter.change
          ? parameter.change : (e) => {
            const gridElement = this.getMasterRecordGridElement();
            if (gridElement) {
              gridElement.onmousewheel = () => {
                return true
              }
            }
          }
      // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Add by Zt End

      const numericTextBox = mountDirectNumericTextBox($(strinput).appendTo(container)[0], {
        decimals: parameterDecimals,
        step: parameterStep,
        ...(isWaterSurveyDigitEditor ? {
          ignoreFieldValidationBounds: true,
          loopBounds: {
            min: WATER_SURVEY_TYPE_DIGIT_MIN,
            max: WATER_SURVEY_TYPE_DIGIT_MAX
          }
        } : {}),
        ...(!isWaterSurveyDigitEditor && hasParameterMin ? { min: parameterMin } : {}),
        ...(!isWaterSurveyDigitEditor && hasParameterMax ? { max: parameterMax } : {}),
        // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
        format: parameterEditorFormat,
        // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
        round: parameterRound,
        ...(isWaterSurveyThresholdEditor ? { padDecimalPlaces: false } : {}),
        spin: () => {
          let value = getDirectWidgetValue(numericTextBox);

          if (!isWaterSurveyDigitEditor) {
            value = clampNumericEditorBounds(
              value,
              parameterMin,
              parameterMax,
              hasParameterMin,
              hasParameterMax
            );
          }

          // 指数表記を通常表記に変換
          value = BigNumber(value).toFixed();
          // model は Grid save 時に更新する（spin 中に書くと onEditSave で old==new となり保存不可になる）
          setDirectWidgetValue(numericTextBox, value);
          numericTextBox.element.val(value);
          syncDirectNumericTextBoxDisplay(numericTextBox, value);

          const gridElement = this.getMasterRecordGridElement();
          if (gridElement) {
            gridElement.onmousewheel = () => {
              return true
            }
          }
        },
        // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt
        change: (e) => {
          if (parameter.change) {
            changeEvent(e);
            const modelValue = options.model[options.field];
            if (modelValue !== null && modelValue !== undefined && modelValue !== "") {
              setDirectWidgetValue(numericTextBox, modelValue);
              numericTextBox.element.val(modelValue);
              syncDirectNumericTextBoxDisplay(numericTextBox, modelValue);
            } else if (isWaterSurveyDigitEditor && e.sender?._value !== null && e.sender?._value !== undefined && e.sender?._value !== "") {
              options.model[options.field] = e.sender._value;
              setDirectWidgetValue(numericTextBox, e.sender._value);
              numericTextBox.element.val(e.sender._value);
              syncDirectNumericTextBoxDisplay(numericTextBox, e.sender._value);
            }
            return;
          }
          const normalizedValue = normalizeNumericEditorValue(e.sender._value);
          if (!isWaterSurveyThresholdEditor) {
            options.model[options.field] = normalizedValue;
          }
          if (normalizedValue !== null && normalizedValue !== undefined && normalizedValue !== "") {
            setDirectWidgetValue(numericTextBox, normalizedValue);
            if (!isWaterSurveyThresholdEditor) {
              numericTextBox.element.val(normalizedValue);
              syncDirectNumericTextBoxDisplay(numericTextBox, normalizedValue);
            } else {
              syncDirectNumericTextBoxDisplay(numericTextBox, normalizedValue);
            }
          }
          const gridElement = this.getMasterRecordGridElement();
          if (gridElement) {
            gridElement.onmousewheel = () => {
              return true
            }
          }
        }
      });
      this.$nextTick(() => {
        const gridElement = this.getMasterRecordGridElement();
        if (gridElement) {
          gridElement.onmousewheel = () => {
            return false
          }
        }
        if (!isWaterSurveyThresholdEditor && !isWaterSurveyDigitEditor) {
          numericTextBox.element.attr("type", "number");
          if (hasParameterMin) {
            numericTextBox.element.attr("min", parameterMin);
          }
          if (hasParameterMax) {
            numericTextBox.element.attr("max", parameterMax);
          }
          numericTextBox.element.attr("step", parameterStep);
          getDirectNumericTextElements(numericTextBox).forEach((input) => {
            if (hasParameterMin) {
              input.setAttribute("min", String(parameterMin));
            }
            if (hasParameterMax) {
              input.setAttribute("max", String(parameterMax));
            }
            input.setAttribute("step", String(parameterStep));
          });
        } else if (isWaterSurveyDigitEditor) {
          numericTextBox.element.attr("step", parameterStep);
          getDirectNumericTextElements(numericTextBox).forEach((input) => {
            input.setAttribute("step", String(parameterStep));
            input.removeAttribute("min");
            input.removeAttribute("max");
          });
        }
        if (!isWaterSurveyThresholdEditor) {
          syncDirectNumericTextBoxDisplay(numericTextBox, getDirectWidgetValue(numericTextBox));
        }
        if (!isWaterSurveyDigitEditor) {
          bindMasterRecordNumericEditorWheel(numericTextBox, (event, input) => {
            event.preventDefault();
            event.stopPropagation();
            const delta = resolveNumericEditorWheelDelta(event);
            if (!delta) {
              return;
            }
            const nextValue = applyNumericEditorWheelStep(
              input.value,
              delta,
              parameterStep,
              parameterMin,
              parameterMax,
              hasParameterMin,
              hasParameterMax,
              false
            );
            const formattedValue = Number(
              BigNumber(nextValue).toFixed(this.getDecimalPointLength(parameterStep))
            );
            setDirectWidgetValue(numericTextBox, formattedValue);
            input.value = String(formattedValue);
            syncDirectNumericTextBoxDisplay(numericTextBox, formattedValue);
            numericTextBox.trigger("change");
          });
        }
        numericTextBox.element.on("blur", () => {
          const gridElement = this.getMasterRecordGridElement();
          if (gridElement) {
            gridElement.onmousewheel = () => {
              return true
            }
          }
          numericTextBox?.trigger("change")
          const normalizedValue = normalizeNumericEditorValue(getDirectWidgetValue(numericTextBox));
          if (!isWaterSurveyThresholdEditor) {
            options.model[options.field] = normalizedValue;
          }
          if (normalizedValue !== null && normalizedValue !== undefined && normalizedValue !== "") {
            setDirectWidgetValue(numericTextBox, normalizedValue);
            if (isWaterSurveyThresholdEditor) {
              return;
            }
            numericTextBox.element.val(normalizedValue);
            syncDirectNumericTextBoxDisplay(numericTextBox, normalizedValue);
            const input = numericTextBox.element?.get?.(0);
            if (input && input.ownerDocument?.activeElement !== input) {
              input.value = String(normalizedValue);
            }
          }
        })
        numericTextBox.element.on("focusin paste", (event) => {
          // kendoNumericTextBoxの仕様で極度に小さい値or大きい値のペーストは無効となり元の値がevent.target.valueに設定される
          // paste時、元の値が極度に小さい値or大きい値の場合、UIが指数表記となる
          // pasteのタイミングではまだ値がevent.target.valueに反映されていないため、setTimeoutを使って非同期的に値を取得することで指数表記になる事象を回避
          setTimeout(() => {
            const value = event.target.value;
            if (value !== "") {
              event.target.value = BigNumber(String(value).replace(/,/g, "")).toFixed();
            }
            stripNumericInputCommas(event.target);
          }, 0);
        });
        bindGridEditorEnterToCloseCell(this.getKendoGrid(), container);
      })
      // add #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
     // ダイアライザマスタ変更  杜 end
    },
    /**
     * 指定された小数点以下の桁数に丸めた値を返す
     * @param {*} value 数値
     * @param {*} decimals 小数部桁数
     * @param {*} roundingMode BigNumberの丸めモード
     */
    roundValue(value, decimals, roundingMode) {
      if (value == null) {
        return null;
      }
      const places = Number(decimals) || 0;
      return BigNumber(value).decimalPlaces(places, roundingMode).toNumber();
    },
    isWaterSurveyThresholdField(field) {
      return this.masterPhysicalName === "mst_water_survey_type"
        && WATER_SURVEY_THRESHOLD_FIELDS.includes(field);
    },
    getWaterSurveyThresholdBounds(integerDigits, decimalDigits) {
      const decimals = parseWaterSurveyDigit(decimalDigits, 0);
      const integers = parseWaterSurveyDigit(integerDigits, WATER_SURVEY_TYPE_DIGIT_MIN);
      const max = BigNumber(10).pow(integers).minus(BigNumber(10).pow(-decimals)).toNumber();
      const min = BigNumber(10).pow(integers).negated().plus(BigNumber(10).pow(-decimals)).toNumber();
      return { min, max, decimalDigits: decimals, integerDigits: integers };
    },
    syncWaterSurveyThresholdsAfterDigitChange(model) {
      if (this.masterPhysicalName !== "mst_water_survey_type" || !model) {
        return false;
      }
      let changed = false;
      WATER_SURVEY_THRESHOLD_FIELDS.forEach((field) => {
        const rawValue = model[field];
        if (rawValue === null || rawValue === undefined || rawValue === "") {
          return;
        }
        const nextValue = roundAndClampWaterSurveyThresholdValue(
          rawValue,
          model.integerDigits,
          model.decimalDigits
        );
        if (!isMasterRecordFieldValueEqual(rawValue, nextValue, field)) {
          model[field] = nextValue;
          this.markMasterRecordModelFieldDirty(model, field);
          changed = true;
        }
      });
      return changed;
    },
    /** 小数部/整数部桁数変更後：閾値等を丸めて store へ反映し表示を更新する */
    commitWaterSurveyThresholdsAfterDigitChange(model, options = {}) {
      if (this.masterPhysicalName !== "mst_water_survey_type" || !model) {
        return false;
      }
      const { deferVisual = false } = options;
      const changed = this.syncWaterSurveyThresholdsAfterDigitChange(model);
      if (!changed) {
        return false;
      }
      this.__masterRecordInlineEdit = true;
      this.edit({ editRecord: model, isSortMode: this.isSortMode });
      this.$nextTick(() => {
        this.__masterRecordInlineEdit = false;
        const run = () => this.scheduleMasterRecordRowVisualRefresh(model, { deferUntilCellClose: deferVisual });
        if (deferVisual) {
          requestAnimationFrame(run);
        } else {
          run();
        }
        const grid = this.getKendoGrid();
        grid?.refresh?.();
      });
      return true;
    },
    formatWaterSurveyThresholdDisplay(value, decimalDigits) {
      if (value === null || value === undefined || value === "") {
        return "";
      }
      const decimals = Number(decimalDigits) || 0;
      return BigNumber(String(value).replace(/,/g, "")).decimalPlaces(decimals, WATER_SURVEY_ROUND_MODE).toFixed();
    },
    // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
    getDecimalPointLength(number){
      var numbers = BigNumber(number).toFixed().split('.');
      return (numbers[1]) ? numbers[1].length : 0;
    },
    // add #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
    // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s start
    numericalCollation(e, options, parameterMax, parameterMin){
      // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt Start
      // if(!options.model[options.field]&&options.model[options.field]===null){
      //   return
      // }

      // 数値範囲内かどうかの確認
      let value = e.sender._value;
      if (value === null || value === undefined || value === "") {
        options.model[options.field] = parameterMin;
      } else if (value > parameterMax) {
        options.model[options.field] = parameterMax;
      } else if (value < parameterMin) {
        options.model[options.field] = parameterMin;
      } else {
        options.model[options.field] = value;
      }
      // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt Start

      if (options.field === "decimalDigits" || options.field === "integerDigits") {
        this.commitWaterSurveyThresholdsAfterDigitChange(options.model, { deferVisual: true });
      }
    },
    // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s end
    // マスタ一覧のデータを取得
    findList() {
      let isDeleteData = []
      let masterPhysicalName = this.masterPhysicalName;
      const facilitySwitch = {
        // facilityCd: this.getFacilityCd
        facilityCd: this.getFacilitySwitch
      };
      // apiをコールして値を取得
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message:
              //   "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              title: DIALOG_MESSAGES[12000001].title,
              message: messageFormat(DIALOG_MESSAGES[12000001].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              callback: () => {
                this.cancel();
              }
            });
          }

          // add NO-7325 cuifc start
          if (this.masterPhysicalName === "mst_treatment") {
            this.createOldLocalDataSource(response.data.localDataSource.data);
          }
          // add NO-7325 cuifc end

          // add 治療記録モニタグラフマスタ 項目不正 start
          if (this.masterPhysicalName === "mst_monitor_graph") {
            for (let i = 0; i < response.data.columns.length; i++) {
              if (response.data.columns[i].field === "leftDataIndex" || response.data.columns[i].field === "rightDataIndex") {
                response.data.columns[i].values = this.mstMonitorGraphItem
              }
            }
            for (let i = 0; i < response.data.localDataSource.data.length; i++) {
              if (response.data.localDataSource.data[i].leftIsMstMonitor === 1) {
                response.data.localDataSource.data[i].leftDataIndex = "MST" + response.data.localDataSource.data[i].leftDataIndex;
              }
              if (response.data.localDataSource.data[i].rightIsMstMonitor === 1) {
                response.data.localDataSource.data[i].rightDataIndex = "MST" + response.data.localDataSource.data[i].rightDataIndex;
              }
            }
          }
          // add 治療記録モニタグラフマスタ 項目不正 end

          // add redmine 5702 溶解装置のトレンドグラフ 宋qy start
          if (this.masterPhysicalName === "mst_trend_graph_template" || this.masterPhysicalName === "mst_trend_graph_monitor_set") {
            for (let i = 0; i < response.data.localDataSource.data.length; i++) {
              if (response.data.localDataSource.data[i].model === "003" && response.data.localDataSource.data[i].comFormatCd === "I") {
                response.data.localDataSource.data[i].model = "006";
              } else if (response.data.localDataSource.data[i].model === "003" && response.data.localDataSource.data[i].comFormatCd === "J") {
                response.data.localDataSource.data[i].model = "007";
              }
            }
          }
          // add redmine 5702 溶解装置のトレンドグラフ 宋qy end

          // 使用開始日・使用終了日: API(YYYYMMDD)をKendo日付列表示用に変換
          if (
            this.masterPhysicalName === "mst_equipment"
            || this.masterPhysicalName === "mst_dialyzer"
            || this.masterPhysicalName === "mst_medicine"
            || this.masterPhysicalName === "mst_treatment"
            || this.masterPhysicalName === "mst_procedure"
          ) {
            this.convertUseTermDatesForGrid(response.data.localDataSource.data);
          }

          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          // add FNSI-修正 マスタ削除の対応 Du start
          if(masterPhysicalName == "mst_medicine" || masterPhysicalName == "mst_equipment")
            toFunction.filter(column => column.field === "classCd")
            .forEach(column => {
             column.textTemplate = (dataItem) => {
                let columnValues = column.values.map(e=>String(e.value));
                let deleteData = []
                if (isDeleteData.length > 0) {
                  deleteData = isDeleteData.map(e=>String(e));
                }
                let value = dataItem[`${column.field}`];
                if (!value) value = "";
                if(value && !columnValues.includes(value) && !deleteData.includes(value)){
                  isDeleteData.push(value)
                }
                let isvalue = column.values.filter(e=>String(e.value) == value);
                value = isvalue.length > 0 ? this.$sanitize(isvalue[0].text) : "";
                return value;
              }
            });
          // add FNSI-修正 マスタ削除の対応 Du end
          this.columns = toFunction;
          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && (column.dataType === "string" || column.dataType === "textarea") && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 16 : column.width * 16;
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
          });

          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            locked: true,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            let columnsData = this.columns;
            this.calculateGridHeight();
            this.calculateGridWidth();
            // add FNSI-修正 マスタ削除の対応 Du start
            if(isDeleteData.length > 0) {
              ApiHelper.get(masterPhysicalName == "mst_medicine" ? `/mstInfo/mstMedicineClassIncludeDeleted` : `/mstInfo/mstEquipmentClassIncludeDeleted`, facilitySwitch)
              .then(responsesData=> {
                isDeleteData.forEach(e=>{
                  let data = responsesData.data.filter(item => String(item.classCd) == e);
                  // #9863 MasterRecordComponent.vue:1174 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'classCd') 横展開2 linjunfeng start
                  // columnsData.filter(a=>a.field == "classCd")[0].values.push({value:parseInt(data[0].classCd),text:MASTER_DELETE_DISPLAY.DELETED + data[0].className,isDisp:true})
                  columnsData.filter(a=>a.field == "classCd")[0].values.push({value:parseInt(data[0]?.classCd),text:MASTER_DELETE_DISPLAY.DELETED + data[0]?.className,isDisp:true})
                  // #9863 MasterRecordComponent.vue:1174 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'classCd') 横展開2 linjunfeng end
                })
              });
              this.columns = columnsData;
            }
            // add FNSI-修正 マスタ削除の対応 Du end
            /* add スクロールの位置を維持 楊 start */
            const restoreAfterFindList = () => {
              if (this.masterRecordKeepScrollAfterSave && this.masterRecordSavedScrollPosition) {
                const saved = { ...this.masterRecordSavedScrollPosition };
                this.applyMasterRecordGridScrollToWidget(saved.top || 0, saved.left || 0);
                this.setScrollTopPosition(saved.top || 0);
                this.setScrollLeftPosition(saved.left || 0);
                return;
              }
              const savedTop = this.getScrollTopPosition;
              const savedLeft = this.getScrollLeftPosition;
              this.applyMasterRecordGridScrollToWidget(savedTop || 0, savedLeft || 0);
            };
            restoreAfterFindList();
            this.$nextTick(() => {
              restoreAfterFindList();
              requestAnimationFrame(restoreAfterFindList);
            });
            /* add スクロールの位置を維持 楊 end */

            // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
            // ストアからスクロール位置を取得してデータ表示域に設定
            // Vue2 は this.$refs.grid.$el.lastChild を使用。Vue3 では同一要素を返す getGridScrollHostEl() で代替。
            const gridScrollHost = this.getGridScrollHostEl();
            if (gridScrollHost && !(this.masterRecordKeepScrollAfterSave && this.masterRecordSavedScrollPosition)) {
              gridScrollHost.scrollTop = this.getScrollTopPosition;
              gridScrollHost.scrollLeft = this.getScrollLeftPosition;
            }
            // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          this.resetMasterRecordSortEditedCodes();
          // 色カラムのテンプレート生成
          this.columns.filter(column => column.dataType === "color")
            .forEach(column => {
              column.colorTemplate = (dataItem) => {
                const value = dataItem[`${column.field}`];
                return `<div style='background-color: ${value}; width: 4em;'>&nbsp;</div>`;
              }
            });

          // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s start
          if(this.masterPhysicalName === "mst_water_survey_type"){
            this.columns.filter(column => (
              column.field=="upperThreshold" || column.field=="lowerThreshold" ||
              column.field=="graphUpperLimit" || column.field=="graphLowerLimit" ||
              column.field=="initialValue"))
              .forEach(column => {
                column.format = "";
              });
          }
          // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s end

          // add 治療記録バイタルグラフマスタ 1、6つの初期データを固定表示するようにしました。 と削除できません。 start
          if (this.masterPhysicalName == "mst_vital_graph") {
            if (response.data.localDataSource.data.length === 0) {
              mstVitalGraphDefine.map(item =>{
                return {
                  code: 0,
                  name: item.vvitalGraphName,
                  vitalLineColor: item.vitalLineColor,
                  vitalLineSize: item.vitalLineSize,
                  vitalLineTypeValue: item.vitalLineTypeValue,
                  vitalPointColor: item.vitalPointColor,
                  vitalPointSize: item.vitalPointSize,
                  vitalPointTypeValue: item.vitalPointTypeValue,
                  isDel: "",
                  isDisp: "1",
                  sortRank: item.sortRank,
                  sortInputTime: 0,
                  isAddRow: true,
                  edited: true
                };
              }).forEach(element => {
                this.edit({ editRecord: element, isSortMode: this.isSortMode });
              });
            }
            this.columns.filter(column => (column.field=="name" || column.field=="isDisp"))
            .forEach(column => {
              const temp = response.data.localDataSource.data.filter(item => item.isDisp == "1").sort((a,b) => a.code-b.code);
              const maxCode = temp.length>mstVitalGraphDefine.length ? temp[mstVitalGraphDefine.length-1].code : temp[temp.length-1].code;
              column.editable = (e)=>{return e.code > maxCode};
            });
          }
          // add 治療記録バイタルグラフマスタ 1、6つの初期データを固定表示するようにしました。 と削除できません。 end
          this.dataSourceItems = this.generatedGridData();
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
          // 共通定型文マスタ：「保存」ボタン⇒非活性、編集場所のスタイル⇒未編集 林峻峰 start
          // this.getMasterRecordListOld = deepCopy(this.getMasterRecordList.data.filter((item)=>{
          //   return item.isDisp === "1"
          // }))
          // this.getMasterRecordListOld.forEach((item)=>{
          //   if (item.occupations) {
          //     item.occupations = item.occupations.replace(/\s/g, '')
          //   }
          // })
          // 共通定型文マスタ：「保存」ボタン⇒非活性、編集場所のスタイル⇒未編集 林峻峰 end
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MasterRecordComponent.vue', 'findRecordListByFacilityCd' , error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
        });
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    readMasterRecordGridScrollFromGridWidget(grid) {
      if (!grid?.content?.[0]) {
        return { top: 0, left: 0 };
      }
      const virtualScrollbar = grid.virtualScrollable?.verticalScrollbar?.[0];
      const c = grid.content[0];
      const top = virtualScrollbar?.scrollTop ?? c.lastChild?.scrollTop ?? c.scrollTop;
      const left =
        typeof grid._scrollLeft !== "undefined" && grid._scrollLeft !== null
          ? grid._scrollLeft
          : c.scrollLeft;
      return { top, left };
    },
    applyMasterRecordGridScrollToWidget(top, left, widgetOverride) {
      const grid = widgetOverride || this.getKendoGrid();
      if (!grid) {
        return;
      }
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      if (grid.virtualScrollable?._scrollTo) {
        grid.virtualScrollable._scrollTo(top);
      }
      if (grid.virtualScrollable?.verticalScrollbar?.[0]) {
        grid.virtualScrollable.verticalScrollbar[0].scrollTop = top;
      }
      if (grid.content?.[0]) {
        grid.content[0].scrollTop = top;
        grid.content[0].scrollLeft = left;
      }
      if (grid.lockedContent?.[0]) {
        grid.lockedContent[0].scrollTop = top;
      }
      const headerWrap = this.getMasterRecordGridHeaderWrap();
      if (headerWrap) {
        headerWrap.scrollLeft = left;
      }
      if (typeof grid._scrollLeft !== "undefined") {
        grid._scrollLeft = left;
      }
      if (grid.scrollables && typeof grid.scrollables.each === "function") {
        grid.scrollables.each((i, el) => {
          if (!grid.content?.[0] || el !== grid.content[0]) {
            if (el && typeof el.scrollLeft === "number") {
              el.scrollLeft = left;
            }
          }
        });
      }
    },
    restoreMasterRecordGridScroll() {
      const top = this.scrollPosition.top || 0;
      const left = this.scrollPosition.left || 0;
      const run = () => this.applyMasterRecordGridScrollToWidget(top, left);
      this.masterRecordRestoreScrollPending = true;
      requestAnimationFrame(run);
      this.$nextTick(run);
      [0, 32, 80].forEach(ms => setTimeout(run, ms));
    },
    syncMasterGridEditedRowState() {
      if (this.__masterRecordSortApplying || this.__masterRecordInlineEdit) {
        return;
      }
      this.scheduleMasterRecordFullVisualRefresh();
    },
    /** dataBound / syncMasterGridEditedRowState からの全行背景色更新を rAF で1回にまとめる */
    scheduleMasterRecordFullVisualRefresh() {
      if (this.__masterRecordFullVisualRaf != null) {
        cancelAnimationFrame(this.__masterRecordFullVisualRaf);
      }
      this.__masterRecordFullVisualRaf = requestAnimationFrame(() => {
        this.__masterRecordFullVisualRaf = null;
        if (this.__masterRecordInlineEdit || this.__masterRecordSortApplying) {
          return;
        }
        this.paintMasterRecordGridVisuals();
      });
    },
    clearMasterRecordGridAutoSort() {
      const ds = this.getKendoGrid()?.dataSource;
      if (!ds?.sort) {
        return;
      }
      try {
        ds.sort([]);
      } catch (_error) {
        // noop
      }
    },
    //Mixin内のメソッドを実行 ソートボタンクリック
    // toRankEditBtnClick() {
    //   MasterMaintenanceMixin.methods.toRankEditBtnClick.call(this);
    //   this.$nextTick(() => {
    //     this.clearMasterRecordGridAutoSort();
    //     requestAnimationFrame(() => {
    //       requestAnimationFrame(() => this.refreshMasterRecordSortRankVisuals());
    //     });
    //   });
    // },
    sortBtnClick() {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      this.cacheGridScrollPosition(this.scrollPosition);
      EventBus.$emit('onCloseMasterEditModal', this.onCloseMasterEditModal);

      const tempData = deepCopy(this.getMasterRecordList.data);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      EventBus.$emit('setSortMode', this.isSortMode);
      this.$nextTick(() => this.syncMasterRecordSortColumnLayout());
    },
    onDataBoundKendoGrid(ev) {
      if (this.__masterRecordSortApplying) {
        return;
      }
      if (!this.masterRecordRestoreScrollPending) {
        MasterMaintenanceMixin.methods.onDataBoundKendoGrid.call(this, ev);
        return;
      }
      MasterMaintenanceMixin.methods.onDataBoundKendoGrid.call(this, ev);
      this.masterRecordRestoreScrollPending = false;
      this.$nextTick(() => {
        requestAnimationFrame(() => {
          const top = this.scrollPosition.top || 0;
          const left = this.scrollPosition.left || 0;
          this.applyMasterRecordGridScrollToWidget(top, left, ev.sender);
        });
      });
    },
    getMasterRecordRowsByUid(uid) {
      if (!uid) {
        return { row: null, lockedRow: null };
      }
      const root = this.getMasterRecordGridElement();
      return {
        row: root?.querySelector?.(`.k-grid-content tr[data-uid="${uid}"], .k-virtual-scrollable-wrap tr[data-uid="${uid}"]`) || null,
        lockedRow: root?.querySelector?.(`.k-grid-content-locked tr[data-uid="${uid}"]`) || null,
      };
    },
    // Vue3 升级初期に追加していた組件レベルの changeSortColor / 補助メソッド群
    // (changeSortColorByRow, getDirectSortColorCellByField, getDirectSortColorRowFromCells,
    //  isDirectSortColorLockedRow, getDirectSortColorVisibleColumnsForRow) は
    // requestAnimationFrame と Kendo cellClose の k-dirty-cell 付与順が競合し、
    // sortRank セルが黄色にならないケースがあった。
    //
    // 現在は MasterRecordVirtualScrollableComponent.vue と同じく
    // `td.k-dirty-cell[data-field="sortRank"]` を直接 CSS で黄色にする方式を採用
    // (本ファイル末尾 <style scoped> を参照)。
    // editBackgroundColor / applyMasterRecordRowVisual から呼ばれる
    // `this.changeSortColor(currentLockTrc)` は MasterMaintenanceMixin.js 側の
    // mixin 実装にフォールバックし、Vue2 と同等の master-sort-edited class 付与経路も
    // 二重防御として残る。
    resetMasterRecordSortEditedCodes() {
      this.masterRecordSortEditedCodes = new Set();
    },
    markMasterRecordSortRankEdited(record, edited = true) {
      if (record?.code == null || record?.code === "") {
        return;
      }
      if (!this.masterRecordSortEditedCodes) {
        this.resetMasterRecordSortEditedCodes();
      }
      const code = String(record.code);
      if (edited) {
        this.masterRecordSortEditedCodes.add(code);
      } else {
        this.masterRecordSortEditedCodes.delete(code);
      }
    },
    isMasterRecordSortRankEdited(record) {
      if (!record) {
        return false;
      }
      const dirtyFields = this.getMasterRecordRemainingDirtyFields(record);
      if (dirtyFields.includes("sortRank")) {
        return true;
      }
      if (record.code == null || record.code === "") {
        return false;
      }
      return !!this.masterRecordSortEditedCodes?.has(String(record.code));
    },
    clearMasterRecordSortRankVisual(currentLockTrc) {
      const sortIdx = this.getColumnIndex("sortRank");
      const dummyIdx = this.getColumnIndex("dummy");
      if (sortIdx >= 0 && currentLockTrc[sortIdx]) {
        currentLockTrc[sortIdx].classList.remove("master-sort-edited");
      }
      if (dummyIdx > -1 && currentLockTrc[dummyIdx]) {
        currentLockTrc[dummyIdx].classList.remove("master-sort-edited");
      }
    },
    applyMasterRecordSortRankVisual(currentLockTrc) {
      this.changeSortColor(currentLockTrc);
      const sortIdx = this.getColumnIndex("sortRank");
      const dummyIdx = this.getColumnIndex("dummy");
      if (sortIdx >= 0 && currentLockTrc[sortIdx]) {
        currentLockTrc[sortIdx].classList.add("master-sort-edited");
      }
      if (dummyIdx > -1 && currentLockTrc[dummyIdx]) {
        currentLockTrc[dummyIdx].classList.add("master-sort-edited");
      }
    },
    /** 並び順列の show/hide や dataBound 後に、変更済み sortRank の黄色を復元する */
    refreshMasterRecordSortRankVisuals() {
      const data = this.getMasterRecordList?.data;
      if (!Array.isArray(data)) {
        return;
      }
      const grid = this.getKendoGrid();
      data.forEach(record => {
        if (!this.isMasterRecordSortRankEdited(record)) {
          return;
        }
        let lockedRow = this.getMasterRecordRowsByUid(record.uid).lockedRow;
        if (!lockedRow && grid && record.code != null) {
          const root = this.getMasterRecordGridElement();
          lockedRow = root?.querySelector?.(
            `.k-grid-content-locked tr[data-uid="${record.uid}"]`
          ) || null;
          if (!lockedRow && root) {
            lockedRow = Array.from(root.querySelectorAll(".k-grid-content-locked tr")).find(tr => {
              const item = grid.dataItem?.(tr);
              return item && String(item.code) === String(record.code);
            }) || null;
          }
        }
        const currentLockTrc = lockedRow?.children;
        if (currentLockTrc?.length) {
          this.applyMasterRecordSortRankVisual(currentLockTrc);
        }
      });
    },
    clearMasterRecordRowVisualState(record, { clearDirty = false, preserveSortVisual = false } = {}) {
      const sortVisualFields = new Set(["sortRank", "dummy"]);
      const rowVisualClasses = ["master-edited-row", "master-deleted-row"];
      const cellVisualClasses = ["master-edited-cell", "master-edited-row", "master-deleted-row"];
      const rows = this.getMasterRecordRowsByUid(record?.uid);
      [rows.row, rows.lockedRow].filter(Boolean).forEach(row => {
        row.classList.remove(...rowVisualClasses);
        Array.from(row.children || []).forEach(cell => {
          const field = cell.getAttribute?.("data-field");
          const isSortVisualCell = sortVisualFields.has(field);
          if (preserveSortVisual && isSortVisualCell) {
            return;
          }
          if (isSortVisualCell) {
            cell.classList.remove("master-sort-edited");
            if (clearDirty) {
              cell.classList.remove("k-dirty-cell");
              cell.querySelectorAll(".k-dirty").forEach(marker => marker.remove());
            }
            return;
          }
          cell.classList.remove(...cellVisualClasses, "master-sort-edited", "master-deleted-combo");
          if (clearDirty) {
            cell.classList.remove("k-dirty-cell");
            cell.querySelectorAll(".k-dirty").forEach(marker => marker.remove());
          }
        });
      });
    },
    applyMasterRecordRowVisual(record, { preserveSortVisual = false } = {}) {
      const rows = this.getMasterRecordRowsByUid(record?.uid);
      const row = rows.row;
      if (!row) {
        return;
      }
      const currentTrc = row.children || [];
      const currentLockTrc = rows.lockedRow?.children || [];
      const remainingDirty = this.getMasterRecordRemainingDirtyFields(record);
      const sortRankEdited = this.isMasterRecordSortRankEdited(record);
      const operation = Number(record?.operation || 0);
      const isUneditedAddRow = operation === 1 && record?.edited !== true;
      const hasNonSortDirty = !isUneditedAddRow && remainingDirty.some(key => key !== "sortRank");
      const operationIsEdited = operation > 1;
      const rowIsEdited = hasNonSortDirty
        || operationIsEdited
        || !!record?.edited
        || this.isEdited(record?.code);
      const shouldPreserveSortVisual = preserveSortVisual || sortRankEdited;

      this.clearMasterRecordRowVisualState(record, {
        clearDirty: !rowIsEdited && !sortRankEdited,
        preserveSortVisual: shouldPreserveSortVisual,
      });

      if (sortRankEdited) {
        this.applyMasterRecordSortRankVisual(currentLockTrc);
      } else if (rowIsEdited) {
        this.changeSortColor(currentLockTrc);
      }
      const edited = rowIsEdited && (
        this.changeEditColor(currentTrc, currentLockTrc)
        || operationIsEdited
        || !!record?.edited
        || this.isEdited(record?.code)
      );
      const deleted = this.isDeleteRow(currentTrc);
      this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
      if (this.masterPhysicalName !== "mst_medicine") {
        this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
      }
    },
    scheduleMasterRecordRowVisualRefresh(record, options = {}) {
      if (!record) {
        return;
      }
      const { deferUntilCellClose = false, preserveSortVisual = false } = options;
      const key = record.uid || record.code || "__unknown__";
      if (!this.masterRecordRowVisualRafIds) {
        this.masterRecordRowVisualRafIds = new Map();
      }
      const pendingId = this.masterRecordRowVisualRafIds.get(key);
      if (pendingId != null) {
        cancelAnimationFrame(pendingId);
      }
      const run = () => {
        this.masterRecordRowVisualRafIds.delete(key);
        this.applyMasterRecordRowVisual(record, { preserveSortVisual });
      };
      const scheduleRun = () => {
        if (deferUntilCellClose) {
          // Kendo cellClose → k-dirty-cell 付与後に実行（並び順黄色・原値復帰）
          requestAnimationFrame(() => requestAnimationFrame(run));
          return;
        }
        const rafId = requestAnimationFrame(run);
        this.masterRecordRowVisualRafIds.set(key, rafId);
      };
      if (deferUntilCellClose) {
        this.$nextTick(scheduleRun);
      } else {
        scheduleRun();
      }
    },
    scheduleMasterRecordDropdownEditorCommit(model, field, value) {
      if (!model || !field) {
        return;
      }
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      const runFallbackCommit = () => {
        // 追加行(operation=1)は closeCell だけでは cell に反映されないため fallback を実行する
        if (!model || Number(model.operation) > 1) {
          return;
        }
        const event = {
          model,
          sender: this.getKendoGrid?.(),
          values: { [field]: value }
        };
        const revertedToOriginal = this.finalizeMasterRecordFieldIfRevertedToOriginal(event, field, value);
        this.applyMasterRecordDropdownCellLabel(model, field, value);
        if (revertedToOriginal) {
          this.scheduleMasterRecordRowVisualRefresh(model, { deferUntilCellClose: true });
          return;
        }
        if (model[field] != value) {
          this.onEditSave(event);
        } else {
          this.onSave(event);
          this.scheduleMasterRecordRowVisualRefresh(model, { deferUntilCellClose: true });
        }
      };
      this.$nextTick(() => {
        if (typeof ownerWindow.requestAnimationFrame === "function") {
          ownerWindow.requestAnimationFrame(runFallbackCommit);
        } else {
          ownerWindow.setTimeout(runFallbackCommit, 0);
        }
      });
    },
    /**
     * セル編集保存時は全グリッド refresh / editBackgroundColor を避け、
     * 変更行のみ背景色を更新する（mst-graph-setting の onDirectGridSave と同方針）。
     */
    onSave(ev) {
      const currentScrollPosition = this.getGridScrollPosition();
      this.scrollLeft = currentScrollPosition.left ?? ev.sender?._scrollLeft ?? 0;
      this.scrollTop = currentScrollPosition.top ?? 0;
      this.editFlg = true;
      this.editingFlg = false;
      this.applyKendoSaveValuesToModel(ev);
      this.syncMasterRecordAddedRowEditedState(ev.model);
      this.__masterRecordInlineEdit = true;
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      this.$nextTick(() => {
        this.__masterRecordInlineEdit = false;
      });
    },
    findMasterRecordOriginalRow(model) {
      const originalList = JSON.parse(this.comparisonRecordModel || "[]");
      if (!Array.isArray(originalList) || !model) {
        return null;
      }
      return originalList.find(row => String(row.code) === String(model.code)) || null;
    },
    /** 表示中レコードの並び順（code 列）が comparisonRecordModel と一致するか */
    isMasterRecordSortOrderSameAsOriginal() {
      let comparisonList;
      try {
        comparisonList = JSON.parse(this.comparisonRecordModel || "[]");
      } catch {
        return false;
      }
      if (!Array.isArray(comparisonList)) {
        return false;
      }
      const currentData = this.getMasterRecordList?.data;
      if (!Array.isArray(currentData)) {
        return false;
      }
      const compareSortOrder = (a, b) => {
        const rankDiff = (Number(a.sortRank) || 0) - (Number(b.sortRank) || 0);
        if (rankDiff !== 0) {
          return rankDiff;
        }
        return (Number(a.sortInputTime) || 0) - (Number(b.sortInputTime) || 0);
      };
      const visibleOriginal = comparisonList.filter(row => row.isDisp === "1");
      const visibleCurrent = currentData.filter(row => row.isDisp === "1");
      if (visibleOriginal.length !== visibleCurrent.length) {
        return false;
      }
      const originalOrder = [...visibleOriginal].sort(compareSortOrder).map(row => String(row.code));
      const currentOrder = [...visibleCurrent].sort(compareSortOrder).map(row => String(row.code));
      return originalOrder.length === currentOrder.length
        && originalOrder.every((code, index) => code === currentOrder[index]);
    },
    getMasterRecordRemainingDirtyFields(model) {
      const dirtyFields = model?.dirtyFields;
      if (!dirtyFields || typeof dirtyFields !== "object") {
        return [];
      }
      return Object.keys(dirtyFields).filter(key => key !== "dirty" && dirtyFields[key]);
    },
    getMasterRecordAddRowFieldDefaultValue(field) {
      const schemaField = this.getMasterRecordList?.schema?.model?.fields?.[field];
      if (schemaField && Object.prototype.hasOwnProperty.call(schemaField, "defaultValue")) {
        return schemaField.defaultValue;
      }
      if (schemaField?.type === "string" || schemaField?.type === "textarea") {
        return "";
      }
      if (schemaField?.type === "number") {
        return 0;
      }
      if (schemaField?.type === "color") {
        return "#000000";
      }
      return null;
    },
    normalizeMasterRecordAddRowCompareValue(value, field) {
      if (value == null) {
        return "";
      }
      if (MASTER_RECORD_DATE_FIELDS.has(field)) {
        return formatMasterRecordDateYmd(value) || "";
      }
      return String(value);
    },
    isMasterRecordAddedRowDeleteEdited(record) {
      return String(record?.isDisp) === "0" || String(record?.isDel) === "1";
    },
    isMasterRecordAddedRowBusinessField(field) {
      const ignoredFields = new Set([
        "uid",
        "code",
        "operation",
        "edited",
        "dirty",
        "dirtyFields",
        "parent",
        "sortRank",
        "dummy",
        "skipSearch",
        "sortInputTime",
        "upDate",
        "isAddRow",
        "isDisp",
        "isDel",
      ]);
      if (!field || field.startsWith("_") || ignoredFields.has(field)) {
        return false;
      }
      return (this.columns || []).some(column => {
        return column?.field === field && column.hidden !== true;
      });
    },
    isMasterRecordAddedRowEffectivelyEdited(record) {
      if (!record) {
        return false;
      }
      if (this.isMasterRecordAddedRowDeleteEdited(record)) {
        return true;
      }
      return this.getMasterRecordRemainingDirtyFields(record)
        .filter(field => this.isMasterRecordAddedRowBusinessField(field))
        .some(field => {
          const value = this.normalizeMasterRecordAddRowCompareValue(record[field], field).trim();
          const defaultValue = this.normalizeMasterRecordAddRowCompareValue(
            this.getMasterRecordAddRowFieldDefaultValue(field),
            field
          ).trim();
          return value !== defaultValue;
        });
    },
    clearMasterRecordModelDirtyState(model) {
      if (!model) {
        return;
      }
      if (typeof model.set === "function") {
        model.set("dirty", false);
      } else {
        model.dirty = false;
      }
      if (model.dirtyFields && typeof model.dirtyFields === "object") {
        Object.keys(model.dirtyFields).forEach(key => delete model.dirtyFields[key]);
      }
    },
    syncMasterRecordAddedRowEditedState(model) {
      if (!this.isMasterRecordAddedRow(model)) {
        return;
      }
      model.edited = this.isMasterRecordAddedRowEffectivelyEdited(model);
      if (!model.edited) {
        this.clearMasterRecordModelDirtyState(model);
      }
    },
    markMasterRecordModelFieldDirty(model, field) {
      if (!model || !field) {
        return;
      }
      if (!model.dirtyFields || typeof model.dirtyFields !== "object") {
        model.dirtyFields = {};
      }
      model.dirtyFields[field] = true;
      model.dirty = true;
    },
    markMasterRecordGridCellDirty(cell, field) {
      const el = cell?.[0] || cell;
      if (!el?.classList) {
        return;
      }
      if (field) {
        el.setAttribute("data-field", field);
      }
      el.classList.add("k-dirty-cell");
      if (el.querySelector(".k-dirty")) {
        return;
      }
      const marker = el.ownerDocument?.createElement?.("span");
      if (!marker) {
        return;
      }
      marker.className = "k-dirty";
      el.insertBefore(marker, el.firstChild || null);
    },
    clearMasterRecordDirtyCellByField(model, field) {
      if (!model?.uid || !field) {
        return;
      }
      const root = this.getMasterRecordGridElement();
      if (!root) {
        return;
      }
      const selector = `tr[data-uid="${model.uid}"] td[data-field="${field}"]`;
      root.querySelectorAll(selector).forEach(cell => {
        cell.classList.remove("k-dirty-cell", "master-edited-cell", "master-edited-row");
        cell.querySelectorAll(".k-dirty").forEach(marker => marker.remove());
      });
    },
    syncMasterRecordStoreRowWithoutOperation(model) {
      const data = this.getMasterRecordList?.data;
      if (!Array.isArray(data) || !model) {
        return;
      }
      const code = model.code;
      data.forEach(row => {
        if (String(row.code) !== String(code)) {
          return;
        }
        delete row.operation;
        row.edited = false;
      });
      delete model.operation;
      model.edited = false;
    },
    /**
     * 編集終了時に初期値へ戻っている場合、Kendo dirty 表示と store の operation を解除する。
     * @returns {boolean} 初期値へ戻した場合 true
     */
    finalizeMasterRecordFieldIfRevertedToOriginal(e, field, newValue) {
      const model = e?.model;
      if (!model || !field || model.operation === 1) {
        return false;
      }
      if (typeof model.isNew === "function" && model.isNew()) {
        return false;
      }
      const originalRow = this.findMasterRecordOriginalRow(model);
      if (!originalRow) {
        return false;
      }
      if (!isMasterRecordFieldValueEqual(originalRow[field], newValue, field)) {
        return false;
      }
      // 並び順は数値が原値でも、反映後に行位置が変わっている場合は編集扱いを維持する
      if (field === "sortRank" && !this.isMasterRecordSortOrderSameAsOriginal()) {
        return false;
      }

      if (model.dirtyFields) {
        delete model.dirtyFields[field];
      }
      this.clearMasterRecordDirtyCellByField(model, field);

      const remainingDirtyFields = this.getMasterRecordRemainingDirtyFields(model);
      const nonSortDirtyFields = remainingDirtyFields.filter(key => key !== "sortRank");
      if (nonSortDirtyFields.length > 0) {
        this.bumpMasterRecordListRevision();
        return true;
      }

      if (typeof model.set === "function") {
        model.set("dirty", false);
      } else {
        model.dirty = false;
      }
      if (model.dirtyFields) {
        Object.keys(model.dirtyFields).forEach(key => delete model.dirtyFields[key]);
      }
      if (model.operation != null && model.operation !== 1) {
        delete model.operation;
      }
      model.edited = false;
      this.syncMasterRecordStoreRowWithoutOperation(model);
      this.bumpMasterRecordListRevision();
      return true;
    },
    /**
     * 開発時のみ: 使用開始日などの dirty 状態を Console に出力する。
     * OFF: localStorage.setItem("masterRecordDirtyDebug", "0")
     * ON:  localStorage.removeItem("masterRecordDirtyDebug")
     */
    logMasterRecordDirtyDebug(e, field, oldValue, newValue, phase = "beforeSave") {
      if (!isMasterRecordDirtyDebugEnabled()) {
        return;
      }
      if (!field || !MASTER_RECORD_DATE_FIELDS.has(field)) {
        return;
      }
      const model = e?.model;
      const originalList = JSON.parse(this.comparisonRecordModel || "[]");
      const originalRow = originalList.find(row => String(row.code) === String(model?.code));
      const originalValue = originalRow?.[field];
      const newYmd = formatMasterRecordDateYmd(newValue);
      const originalYmd = formatMasterRecordDateYmd(originalValue);
      const oldYmd = formatMasterRecordDateYmd(oldValue);
      const modelValue = typeof model?.get === "function" ? model.get(field) : model?.[field];
      const gridEl = this.getMasterRecordGridElement();
      const rowSelector = model?.uid ? `tr[data-uid="${model.uid}"]` : null;
      const dirtyCell = rowSelector
        ? gridEl?.querySelector?.(`${rowSelector} td.k-dirty-cell[data-field="${field}"]`)
        : null;
      const dirtyMarker = dirtyCell?.querySelector?.(".k-dirty");

      console.groupCollapsed(
        `[MasterRecord dirty] ${phase} | ${field} | code=${model?.code ?? "?"}`
      );
      console.table({
        phase,
        field,
        code: model?.code,
        master: this.masterPhysicalName,
        oldValue,
        newValue,
        modelValue,
        originalValue,
        oldYmd,
        newYmd,
        originalYmd,
        sameAsOriginalByYmd: newYmd === originalYmd,
        oldEqualsNew: oldValue == newValue,
        modelDirty: model?.dirty,
        dirtyFieldFlag: model?.dirtyFields?.[field],
        operation: model?.operation,
        willCallOnSave: oldValue != newValue,
        hasDirtyCellClass: !!dirtyCell,
        hasDirtyMarker: !!dirtyMarker,
      });
      console.log("dirtyFields", model?.dirtyFields ? { ...model.dirtyFields } : model?.dirtyFields);
      if (oldValue instanceof Date && newValue instanceof Date) {
        console.log("timestamp diff (new - old):", newValue.getTime() - oldValue.getTime());
      }
      if (originalValue != null && newValue != null) {
        const originalDate = dayjs(originalValue);
        const newDate = dayjs(newValue);
        if (originalDate.isValid() && newDate.isValid()) {
          console.log(
            "timestamp diff (new - original):",
            newDate.valueOf() - originalDate.valueOf()
          );
        }
      }
      console.log("disable debug: localStorage.setItem('masterRecordDirtyDebug', '0'); location.reload()");
      console.log("enable debug:  localStorage.removeItem('masterRecordDirtyDebug'); location.reload()");
      console.groupEnd();
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    onEditSave(e) {
      let field = Object.keys(e.values)[0];
      if(this.masterPhysicalName == "mst_monitor_graph") {
        if (field === "leftDataIndex") {
          for (let i = 0; i < this.mstMonitorInitial.length; i++) {
            if (this.mstMonitorInitial[i].moniDataNo === e.values.leftDataIndex) {
              e.model.leftGraphLowerLimit = this.mstMonitorInitial[i].lower;
              e.model.leftGraphUpperLimit = this.mstMonitorInitial[i].upper;
            }
          }
        }
        if (field === "rightDataIndex") {
          for (let i = 0; i < this.mstMonitorInitial.length; i++) {
            if (this.mstMonitorInitial[i].moniDataNo === e.values.rightDataIndex) {
              e.model.rightGraphLowerLimit = this.mstMonitorInitial[i].lower;
              e.model.rightGraphUpperLimit = this.mstMonitorInitial[i].upper;
            }
          }
        }
      }
      if (this.masterPhysicalName == "mst_mainte_detail") {
        if (e.values.isCmt)  e.model.iniText = null;
        // redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy start
        if (e.values.mainteClass) e.model.mainteContent3 = null;
        // redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy end
        if (e.values.mainteClass == "1") e.model.ansPattern = "0";
        if (e.values.mainteClass == "2") e.model.ansPattern = "1" ;
      }
      if (this.masterPhysicalName == "mst_water_survey_type" && WATER_SURVEY_THRESHOLD_FIELDS.includes(field)) {
        e.values[field] = roundAndClampWaterSurveyThresholdValue(
          e.values[field],
          e.model.integerDigits,
          e.model.decimalDigits
        );
      }
      if (this.masterPhysicalName === "mst_water_survey_type"
        && (field === "decimalDigits" || field === "integerDigits")) {
        if (e.values[field] !== undefined && e.values[field] !== null && e.values[field] !== "") {
          e.model[field] = e.values[field];
        }
        this.commitWaterSurveyThresholdsAfterDigitChange(e.model, { deferVisual: true });
      }
      
      // 値変更時のみonSaveを実行
      // onSaveを無条件で実行すると値変更しなくても行色が編集状態となる
      const oldValue = e.model[field];
      const newValue = e.values[field];
      this.logMasterRecordDirtyDebug(e, field, oldValue, newValue, "beforeSave");

      if (oldValue != newValue) {
        const skipStaleAddRowDropdownSave =
          this.masterPhysicalName === "mst_monitor_graph"
          && this.isMasterRecordAddedRow(e.model)
          && (field === "leftDataIndex" || field === "rightDataIndex")
          && (newValue === 0 || newValue === null || newValue === "")
          && oldValue !== null
          && oldValue !== ""
          && oldValue !== 0;
        if (!skipStaleAddRowDropdownSave) {
          this.onSave(e);
        }
      }
      const revertedToOriginal = this.finalizeMasterRecordFieldIfRevertedToOriginal(e, field, newValue);
      if (field === "sortRank") {
        if (revertedToOriginal) {
          this.markMasterRecordSortRankEdited(e.model, false);
        } else if (oldValue != newValue || this.isMasterRecordSortRankEdited(e.model)) {
          this.markMasterRecordSortRankEdited(e.model, true);
        }
      }
      if (revertedToOriginal || oldValue != newValue) {
        const preserveSortVisual = field !== "sortRank" && this.isMasterRecordSortRankEdited(e.model);
        const deferAddRowDropdownVisual =
          this.masterPhysicalName === "mst_monitor_graph"
          && this.isMasterRecordAddedRow(e.model)
          && (field === "leftDataIndex" || field === "rightDataIndex");
        this.scheduleMasterRecordRowVisualRefresh(e.model, {
          deferUntilCellClose: revertedToOriginal || deferAddRowDropdownVisual,
          preserveSortVisual,
        });
      }
      if (isMasterRecordDirtyDebugEnabled()) {
        const debugPhase = revertedToOriginal
          ? "afterRevert"
          : (oldValue != newValue ? "afterSave" : "afterSkipOnSave");
        requestAnimationFrame(() => {
          this.logMasterRecordDirtyDebug(e, field, oldValue, newValue, debugPhase);
        });
      }
    },
    //日常・定期点検項目マスタ 列の関連
    modifyEditStart (e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      if (this.masterPhysicalName == "mst_mainte_detail") {
        if (e.model.mainteClass == "1")  e.sender.columns[9].values = this.columns[9].values.filter(e => e.value == "0");
         if (e.model.mainteClass == "2")  e.sender.columns[9].values = this.columns[9].values.filter(e => e.value != "0");
      }
      // add FNSI-修正 マスタ削除の対応 Du start
      if (this.masterPhysicalName == "mst_medicine" || this.masterPhysicalName == "mst_equipment") {
        e.sender.columns.filter(e=>e.field == "classCd")[0].values = this.columns.filter(e=>e.field == "classCd")[0].values.filter(e=>!e.isDisp);
      }
      // add FNSI-修正 マスタ削除の対応 Du end
      // add 医療材料セットマスタ 編集の時、スクロール位置を取得 start 鞠
      if (this.masterPhysicalName == "mst_equipment") {
        const grid = this.getGridContentElement();
        this.scrollPosition.left = grid?.scrollLeft || 0;
      }
      // add 医療材料セットマスタ 編集の時、スクロール位置を取得 end 鞠
      this.editStart(e)
    },
    /**
     * add NO-7325 cuifc
     * 外部連携インタフェースを要求するか否かを判断する
     * */
    sendSetUpdateFlag() {
      this.getUpdateRecordList.forEach((recordData) => {
        if (recordData.operation === 2) {
          for (const oldRecordData of this.oldLocalDataSource) {
            let tcsJson = recordData.treatmentConditionSetting;
            let code = recordData.code;
            let deviceMode = recordData.deviceMode;
            let oldtcsJson = oldRecordData.treatmentConditionSetting;
            let oldCode = oldRecordData.code;
            let oldDeviceMode = oldRecordData.deviceMode;
            //治療方法マスタの中の装置モードの項目を変更した場合,isSendJournalApiFlag値は1
            if (code === oldCode && (tcsJson !== oldtcsJson || deviceMode !== oldDeviceMode)) {
              recordData.isSendJournalApiFlag = 1;
              break;
            } else {
              recordData.isSendJournalApiFlag = 0;
            }
          }
        }
      });
    },
    /**
     * add NO-7325 cuifc
     * OldLocalDataSourceの作成
    */
    createOldLocalDataSource(dataSourceList) {
      this.oldLocalDataSource = [];
      dataSourceList.forEach((dataSource) => {
        const dataSourceJson = {
          code: dataSource.code,
          deviceMode: dataSource.deviceMode,
          name: dataSource.name,
          treatmentConditionSetting: dataSource.treatmentConditionSetting
        };
        this.oldLocalDataSource.push(dataSourceJson);
      });
    },
    // add 9664 by kangjie 20231208 start
    /**
     * @description 指示者設定確認
     */
    async checkIndUserSetting() {
      this.setIsIndUserSetting(false);
      this.setIndUserId(null);
      // 指示者情報を取得
      const response = await ApiHelper.get(
        `/facilities/${this.getStateUserAccountInfo.facilityCd}/personal-user/job/doctor`).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatInfoCardList.vue', 'checkIndUserSetting', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw error;
      });
      if (0 !== response.data.length) {
        // 指示者リストを作成
        const indUserList = [];
        response.data.forEach(user => {
          indUserList.push({
            name: `${user.user_last_name} ${user.user_first_name}`,
            userId: user.user_id
          });
        });
        this.setIndUserList(indUserList);
        return true;
      } else {
        return false;
      }
    },
    async saveRecordPopUpModel(){
      // 保存ボタン押下時のスクロール位置を保持し、保存後の再取得で復元する。
      this.saveMasterRecordGridScrollPosition();

      if (this.masterPhysicalName === 'mst_treatment') {
        const editRecord = this.getUpdateRecordList.filter(item => (item.operation === 2))
        const checkResult = await this.checkIndUserSetting().catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MasterRecordComponent.vue', 'confirmSelectDoctorNo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          throw error;
        });
        if (checkResult && editRecord.length >0) {
          this.isModalVisible = true;
        } else {
          this.saveRecord ();
        }
      } else {
        this.saveRecord ();
      }
    },
    // add 9664 by kangjie 20231208 end
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        this.scheduleValidationTooltipPlacement();
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.rollbackMasterRecordSavedGridScroll();
        return;
      }
      /* add 内部#6279 by zhangruixue 2023-06-15 --start */
      if (this.masterPhysicalName === "mst_treatment_set"){
        const editRecord = this.getUpdateRecordList.filter(item => (item.operation === 1 && item.edited))
        let treatmentCdEmptyFlg = false;
        for(let item of editRecord) {
          if(!item.treatmentCd){
            treatmentCdEmptyFlg = true;
            break;
          }
        }
        if (treatmentCdEmptyFlg) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES['22010001'].title,
            message: messageFormat(DIALOG_MESSAGES['22010001'].message, '治療方法')
          });
          this.setLoadingScreenVisible(false);
          this.rollbackMasterRecordSavedGridScroll();
          return;
        }
      }
      /* mod 内部#6279 by zhangruixue 2023-06-15 --start */
      // 患者経過総合ビューアレイアウトマスタ
      // バイタル・モニタグラフ　入室～退室の親子化の解除
      if (this.masterPhysicalName === "mst_pat_viewer_layout") {
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          //add 内部#6589 【試験T】【結合テスト】3日・7日・14日 checkon，disp_period_class 显示Null zhaoqi 20230626 start
          let dispPeriodClass = this.getMasterRecordList.data[i].dispPeriodClass;
          if(dispPeriodClass === ''){
            this.getMasterRecordList.data[i].dispPeriodClass = '0';
          }
          //add 内部#6589 【試験T】【結合テスト】3日・7日・14日 checkon，disp_period_class 显示Null zhaoqi 20230626 end
          let dispItemInfo = JSON.parse(this.getMasterRecordList.data[i].dispItemInfo);
          let convertDispItemInfo = [];
           // 6376【設計T】【結合試験仕様書作成】【患者経過総合ビューアレイアウトマスタ】 新规追加一条 点击保存 保存失败 start zhao
          if (dispItemInfo) {
           // 6376【設計T】【結合試験仕様書作成】【患者経過総合ビューアレイアウトマスタ】 新规追加一条 点击保存 保存失败 end zhao
            for (let j = 0; j < dispItemInfo.length; j++) {
              if (dispItemInfo[j].categoryNo === 1) {
                let treateCategoryItem = [];
                for (let k = 0; k < dispItemInfo[j].categoryItem.length; k++) {
                  if (dispItemInfo[j].categoryItem[k].subCategoryNo >= 58 && dispItemInfo[j].categoryItem[k].subCategoryNo <= 61 && dispItemInfo[j].categoryItem[k].vitalChild !== undefined) {
                    let vitalCategoryItem_1 = dispItemInfo[j].categoryItem[k];
                    let vitalCategoryItem_2 = dispItemInfo[j].categoryItem[k].vitalChild[0];
                    let vitalCategoryItem_3 = dispItemInfo[j].categoryItem[k].vitalChild[1];
                    if (vitalCategoryItem_1 !== undefined && vitalCategoryItem_1.isDisp) {
                      delete vitalCategoryItem_1.isDisp;
                      delete vitalCategoryItem_1.isDispflag;
                      vitalCategoryItem_1.subCategoryItem.forEach((subCategoryItem) => {
                        delete subCategoryItem.isDisp;
                        delete subCategoryItem.isDispflag;
                      });
                      delete vitalCategoryItem_1.vitalChild;
                      treateCategoryItem.push(vitalCategoryItem_1);
                    }
                    if (vitalCategoryItem_2 !== undefined && vitalCategoryItem_2.isDisp) {
                      delete vitalCategoryItem_2.isDisp;
                      delete vitalCategoryItem_2.isDispflag;
                      vitalCategoryItem_2.subCategoryItem.forEach((subCategoryItem) => {
                        delete subCategoryItem.isDisp;
                        delete subCategoryItem.isDispflag;
                      });
                      treateCategoryItem.push(vitalCategoryItem_2);
                    }
                    if (vitalCategoryItem_3 !== undefined && vitalCategoryItem_3.isDisp) {
                      delete vitalCategoryItem_3.isDisp;
                      delete vitalCategoryItem_3.isDispflag;
                      vitalCategoryItem_3.subCategoryItem.forEach((subCategoryItem) => {
                        delete subCategoryItem.isDisp;
                        delete subCategoryItem.isDispflag;
                      });
                      treateCategoryItem.push(vitalCategoryItem_3);
                    }
                  } else {
                    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                    dispItemInfo[j].categoryItem[k].subCategoryItem.forEach((subCategoryItem) => {
                      delete subCategoryItem.isDispflag;
                    });
                    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                    treateCategoryItem.push(dispItemInfo[j].categoryItem[k]);
                  }
                }
                let treateDispItemInfo = dispItemInfo[j];
                treateDispItemInfo.categoryItem = treateCategoryItem;
                convertDispItemInfo.push(treateDispItemInfo);
              } else {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                for (let k = 0; k < dispItemInfo[j].categoryItem.length; k++) {
                  dispItemInfo[j].categoryItem[k].subCategoryItem.forEach((subCategoryItem) => {
                    delete subCategoryItem.isDispflag;
                  });
                }
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                convertDispItemInfo.push(dispItemInfo[j]);
              }
            }
           // 6376【設計T】【結合試験仕様書作成】【患者経過総合ビューアレイアウトマスタ】 新规追加一条 点击保存 保存失败 start zhao
          }
           // 6376【設計T】【結合試験仕様書作成】【患者経過総合ビューアレイアウトマスタ】 新规追加一条 点击保存 保存失败 end zhao
          this.getMasterRecordList.data[i].dispItemInfo = JSON.stringify(convertDispItemInfo);
        }
      }
      
      // 患者カレンダーレイアウトマスタ
      // バイタル・モニタグラフ　入室～退室の親子化の解除
      const vitalMonitorSubCategoryNo1 = [
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1
      ];      
      if (this.masterPhysicalName === "mst_pat_calendar_layout") {
        this.getMasterRecordList.data.forEach(record => {
          // 表示区分
          record.dispClass = record.dispClass ? record.dispClass : "0";
          
          if (!record.dispItemInfo) return;
          const dispItemInfo = JSON.parse(record.dispItemInfo);
        
          const convertDispItemInfo = dispItemInfo.map(info => {
            // 治療情報以外はそのまま
            if (info.categoryNo !== 2) return info;
        
            const treateCategoryItem = [];
            
            info.categoryItem.forEach(categoryItem => {
              const isVitalTarget =
                vitalMonitorSubCategoryNo1.includes(categoryItem.subCategoryNo) &&
                categoryItem.vitalChild !== undefined;
        
              if (isVitalTarget) {
                const items = this.buildCategoryItemsVitalMonitor(categoryItem);
                if (items.length) {
                  treateCategoryItem.push(...items);
                  return; // 次の categoryItem
                }
              }
              // else 相当
              categoryItem.subCategoryItem.forEach(sub => {
                delete sub.isDispflag;
              });
              treateCategoryItem.push(categoryItem);
              
            });
        
            return {
              ...info,
              categoryItem: treateCategoryItem
            };
          });

          record.dispItemInfo = JSON.stringify(convertDispItemInfo);
        });
      }
      
      if (this.masterPhysicalName === "mst_dialyzer") {
        let flag = false;
        // add #7224 尿素クリアランスについて 付 start
        let flagureaClearance = false
        // add #7224 尿素クリアランスについて 付 end
        let message = "";
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          if (this.getMasterRecordList.data[i].ufrWarningMax < this.getMasterRecordList.data[i].ufrWarningMin) {
            flag = true;
            if (message === "") {
              message += this.getMasterRecordList.data[i].name;
            } else {
              message += "<br>" + this.getMasterRecordList.data[i].name;
            }
          }
          // add #7224 尿素クリアランスについて 付 start
          if (this.getMasterRecordList.data[i].ureaClearance > this.getMasterRecordList.data[i].bloodamt) {
            flagureaClearance = true;
            if (message === "") {
              // mod #7224 尿素クリアランスについて 徐博 start
              // message += '尿素クリアランス（' + (this.getMasterRecordList.data[i].ureaClearance).toFixed(1) + '）＞血流量（' + (this.getMasterRecordList.data[i].bloodamt).toFixed(1) + '）になっています。';
              message += '尿素クリアランス（' + (this.getMasterRecordList.data[i].ureaClearance).toFixed(0) + '）＞血流量（' + (this.getMasterRecordList.data[i].bloodamt).toFixed(0) + '）になっています。';
              // mod #7224 尿素クリアランスについて 徐博 end
            } else {
              // mod #7224 尿素クリアランスについて 徐博 start
              // message += "<br>" + '尿素クリアランス（' + (this.getMasterRecordList.data[i].ureaClearance).toFixed(1) + '）＞血流量（' + (this.getMasterRecordList.data[i].bloodamt).toFixed(1) + '）になっています。';
              message += "<br>" + '尿素クリアランス（' + (this.getMasterRecordList.data[i].ureaClearance).toFixed(0) + '）＞血流量（' + (this.getMasterRecordList.data[i].bloodamt).toFixed(0) + '）になっています。';
              // mod #7224 尿素クリアランスについて 徐博 end
            }
          }
          // add #7224 尿素クリアランスについて 付 end
        }
        // add #7224 尿素クリアランスについて 付 start
        if (flagureaClearance) {
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES["00300006"].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: message
          });
          return
        }
        // add #7224 尿素クリアランスについて 付 end
        if (flag) {
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES[12000081].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: message + DIALOG_MESSAGES[12000081].message
          });
          return;
        }
      }
      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      let isSysMedicine = false;
      if (this.masterPhysicalName == "sys_medicine") isSysMedicine = true;
      records.data = records.data.filter(
        r => !(r.operation === 1 && (!r.edited || !(r.isAddRow && (r.isDisp == '1'|| isSysMedicine))))
      );
      // データの削除特殊処理
      await deleteDataProcessing(this.getFacilitySwitch, this.masterPhysicalName, records.data);
      if (this.masterPhysicalName == "mst_holiday"){
        let deleteData =  records.data.filter(e=> e.isDisp == "0" && e.operation == 2 && e.class =="0").map(a=>a.code);
        let recoveryData =  records.data.filter(e=> e.isDisp == "1" && e.operation == 2 && e.class =="0").map(a=>a.code);
        if(deleteData)
        records.data.forEach(e=>{
          deleteData.forEach(item => {
            if (e.isDisp == "1" && e.code == item+1) {
              e.isDisp ="0";
              e.operation = 2;
            }
          });
          recoveryData.forEach(item => {
            if (e.isDisp == "0" && e.code == item+1) {
              e.isDisp ="1";
              e.operation = 2;
            }
          });
        })
      }
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();
      let message = "";
      if (validateMessage.length !== 0) {
        message = "以下の列に未入力項目が存在します。" + validateMessage  +"</br>";
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          message + "以下の列の選択を見直してください。" + validateComboMessage +"</br>";
      }

      // add 治療記録モニタグラフマスタ 項目不正 start
      // mod 9184 治療記録モニタグラフマスタにて1項目のグラフが生成できない 関 start
      // if (this.masterPhysicalName == "mst_monitor_graph") {
      if (this.masterPhysicalName == "mst_monitor_graph" && message === "") {
        // mod 9184 治療記録モニタグラフマスタにて1項目のグラフが生成できない 関 end
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          if (this.getMasterRecordList.data[i].leftDataIndex.slice(0, 3) === "MST") {
            this.getMasterRecordList.data[i].leftIsMstMonitor = 1;
            this.getMasterRecordList.data[i].leftDataIndex = this.getMasterRecordList.data[i].leftDataIndex.slice(3);
          } else {
            this.getMasterRecordList.data[i].leftIsMstMonitor = 0;
          }
          if (this.getMasterRecordList.data[i].rightDataIndex.slice(0, 3) === "MST") {
            this.getMasterRecordList.data[i].rightIsMstMonitor = 1;
            this.getMasterRecordList.data[i].rightDataIndex = this.getMasterRecordList.data[i].rightDataIndex.slice(3);
          } else {
            this.getMasterRecordList.data[i].rightIsMstMonitor = 0;
          }
        }
      }
      // add 治療記録モニタグラフマスタ 項目不正 end

      // 水質検査箇所マスタ 水質調査種別  変更不可
      if (this.masterPhysicalName == "mst_water_survey_point") {
        await this.validateWaterSurveyPointValue();
        if(this.waterSurveyPointValueFalg)
          // add 全マスタメッセージ調整 王 start
          // message = message + "結果が登録されている</br> 箇所の種別変更はできません。";
          message = message + DIALOG_MESSAGES[12000050].message;
          // add 全マスタメッセージ調整 王 end
      }

      // add #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng start
      const mstObj = {
        mst_pat_event_data_template: "inputParams", // 患者イベントテンプレートマスタ
        mst_medicine_mix: "mixInfo", // 調製薬剤マスタ
        mst_facility_calendar_layout: "dispItemInfo", // 施設カレンダーレイアウトマスタ
        mst_pat_list_layout: "dispItemInfo", // データリストレイアウトマスタ
        mst_trend_graph_monitor_set: "seriesInfo", // 治療状況透析液調製装置トレンドレイアウトマスタ
        mst_trend_graph_template: "seriesInfo", // 治療状況透析液調製装置グラフレイアウトマスタ
        mst_destination_group: "destinationTarget", // 送信先グループマスタ
        mst_exam_set: "iteminfo", // 検査セットマスタ
        mst_equipment_set: "setInfo", // 医療材料セットマスタ
        mst_medicine_set: "setInfo", // 薬剤セットマスタ
      };
      const mstName = Object.keys(mstObj);
      // add #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng end
      // #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng start
      // if(this.masterPhysicalName === 'mst_medicine_mix'){
      if(mstName.includes(this.masterPhysicalName)){
      // #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng emd
        this.getMasterRecordList.data.forEach(
          item => {
            // #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng start
            // if(item.mixInfo == null){
              // item.mixInfo = "[]";
            // }
            const key = mstObj[this.masterPhysicalName];
            if(item[key] == null || item[key] === ""){
              if (this.masterPhysicalName === 'mst_destination_group') {
                item[key] = "{\"users\":[]}";
              } else if (this.masterPhysicalName === 'mst_pat_list_layout') {
                item[key] = "[]";
                item.occupations = "[]";
              } else {
                item[key] = "[]";
              }
            }
            // #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng end
          }
        )
      }

      // 検査項目マスタ
      if (this.masterPhysicalName == "mst_exam_item") {
        let examItemFalg = true;
        this.getMasterRecordList.data.forEach(item1 => {
          if(item1.isDisp === "1"){
            this.getMasterRecordList.data.forEach(item2 => {
              if (item1.defaultCalcExamItemCd != "0" &&
                  item1.code != item2.code &&
                  item1.defaultCalcExamItemCd == item2.defaultCalcExamItemCd &&
                  item2.dialysisProgressFlag != "0" && item2.dialysisProgressFlag != "" &&
                  item2.isDisp === "1") {
                if (item1.dialysisProgressFlag == "1" && item2.dialysisProgressFlag != "2") examItemFalg = false;
                if (item1.dialysisProgressFlag == "2" && item2.dialysisProgressFlag != "1") examItemFalg = false;
                if (item1.dialysisProgressFlag == "3" && item2.dialysisProgressFlag != "0") examItemFalg = false;
              }
            })
          }
        })
        if(!examItemFalg){
          // メッセージ組み立て
          const title = DIALOG_MESSAGES[12000012].title;
          let message = `
              ${
                !examItemFalg
                  // add 全マスタメッセージ調整 王 start
                  // ? "同じな検査項目の透析前、透析後は重複です。<br>"
                  ? DIALOG_MESSAGES[12000012].message + "<br>"
                  // add 全マスタメッセージ調整 王 end
                  : ""
              }`;
          // ダイアログ表示
          this.$ons.notification.alert({
            title: title,
            message: message
          });
          this.setLoadingScreenVisible(false);
          this.rollbackMasterRecordSavedGridScroll();
          return;
        }
      }

      // add 休日マスタ 障害対応No217 追加重複の情報（年）チェック start
      if (this.masterPhysicalName == "mst_holiday") {
        const yearList = this.getMasterRecordList.data
          .filter(f => f.isDisp === "1")
          .map(item => {
            return item.year + item.class
          });
        if (yearList.length > 1) {
          let repeatCount = 0;
          yearList.sort().sort((a, b) => {
            if (a == b) {
              repeatCount++;
            }
          })
          if (repeatCount > 0) {
            // add 全マスタメッセージ調整 王 start
            // message = message + "重複の情報（年）があります。</br> 恢復したい場合は重複の情報（年）をご削除ください。";
            message = message + DIALOG_MESSAGES[12000049].message;
            // add 全マスタメッセージ調整 王 end
          }
        }
      }
      const scrollContent = this.getKendoGrid()?.content?.[0];
      if (scrollContent) {
        scrollContent.scrollTop  = this.getScrollTopPosition;
        scrollContent.scrollLeft = this.getScrollLeftPosition;
      }
      // add 休日マスタ 障害対応No217 追加重複の情報（年）チェック end

      if ((this.masterPhysicalName === "mst_treatment" || this.masterPhysicalName === "mst_comsv_setting")&& this.getUpdateRecordList.filter(item => (item.operation === 2)).length != 0) {
        let mstMachineList = [];
        await Promise.all([
          ApiHelper.get(`/master_maintenance/mst_machine/data/${this.getFacilitySwitch}`).then(response => {
            if(response.data) {
              mstMachineList = response.data.localDataSource.data
            }
          })
        ])
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MasterRecordComponent.vue', 'created', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });

        await Promise.all([ ApiHelper.get(`master_maintenance/mnt_machine_state/${this.getFacilitySwitch}`)]).then(async response => {
            const result = response[0].data.filter(e => e.facilityCd == this.getFacilitySwitch)
            result.forEach(async item => {
              let itemData = mstMachineList.filter(e=> e.machineTypeCd == item.machineTypeCd && e.machineSerial == item.machineSerial && e.facilityCd == item.facilityCd);

              const params = {
                ordNo: item.nextOrdNo, //オーダー番号
                // #9863 MasterRecordComponent.vue:1830 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'code') 横展開2 linjunfeng start
                // machineNo: itemData[0].code, //装置マスタ.装置番号
                // deviceEdgeNo: itemData[0].deviceEdgeNo, //デバイスエッジ番号
                machineNo: itemData[0]?.code, //装置マスタ.装置番号
                deviceEdgeNo: itemData[0]?.deviceEdgeNo, //デバイスエッジ番号
                 // #9863 MasterRecordComponent.vue:1830 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'code') 横展開2 linjunfeng end
                facilityCd: this.getFacilitySwitch //施設コード
              };
              // await this.sendNextPatInfo(params);
            })
        })
        .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MasterRecordComponent.vue', 'created', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
        });
      }
      // add redmine 4652 治療方法変更に伴う指示変更が不正 孔 start
      if (this.masterPhysicalName === "mst_treatment") {
        const editRecord = this.getUpdateRecordList
          .filter(item => (item.operation === 1 && item.edited) || item.operation === 2)

        /* add 内部#6279 by zhangruixue 2023-06-15 --start */
        let deviceModeEmptyFlg = false;
        for(let item of editRecord) {
          if(!item.deviceMode){
            deviceModeEmptyFlg = true;
            break;
          }
        }
        if (deviceModeEmptyFlg) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES['22010001'].title,
            message: messageFormat(DIALOG_MESSAGES['22010001'].message, '装置モード')
          });
          this.setLoadingScreenVisible(false);
          this.rollbackMasterRecordSavedGridScroll();
          return;
        }
        /* mod 内部#6279 by zhangruixue 2023-06-15 --start */
        //   // add #6797 2023/01/10 利用開始日A、Bが未登録の状態でも登録できてしまう dou start
           if (editRecord && editRecord.length > 0) {
          //mod 6797 利用開始日A、Bが未登録の状態でも登録できてしまう start zhao
          // add #6797 2023/01/10 利用開始日A、Bが未登録の状態でも登録できてしまう dou start
          let errorlist = editRecord.filter(x =>
          //mod 6797 利用開始日A、Bが未登録の状態でも登録できてしまう end zhao
            (x.inHospAStartdate == null
              && (!!x.inHospitalCdA1
                || !!x.inHospitalCdA2
                || !!x.inHospitalCdA3
                || !!x.inHospitalCdA4))
            || (x.inHospBStartdate == null
              && (!!x.inHospitalCdB1
                || !!x.inHospitalCdB2
                || !!x.inHospitalCdB3
                || !!x.inHospitalCdB4))
          )
          //mod 6797 利用開始日A、Bが未登録の状態でも登録できてしまう start zhao
          let hospFlg = false;
          errorlist.forEach(it1 => {
            if(it1.isDisp === "1"){
              hospFlg = true;
            }
          });
          // if (errorlist.length > 0) {
          if (errorlist.length > 0 && hospFlg) {
          //mod 6797 利用開始日A、Bが未登録の状態でも登録できてしまう end zhao
            message = message + DIALOG_MESSAGES[12000084].message;
          }
          // add #6797 2023/01/10 利用開始日A、Bが未登録の状態でも登録できてしまう dou end
          // 現在のユーザー権限
          const userAuthorityCds = await ApiHelper.get("/user-authority/login/list");
          const ind_edit = userAuthorityCds.data.includes(AUTHORITY_CODES.IND_EDIT);
          const ind_pedit = userAuthorityCds.data.includes(AUTHORITY_CODES.IND_PEDIT);
          if (!(ind_edit || ind_pedit)) {
            message = message + DIALOG_MESSAGES[12000063].message;
          }
        }
      }
      // add redmine 4652 治療方法変更に伴う指示変更が不正 孔 end

      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.rollbackMasterRecordSavedGridScroll();
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000049].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        this.waterSurveyPointValueFalg = false;
        return;
      }

      // add FNSI-分類変更のメッセージ表示 李 start
      let classiFicationFlg = false;
      this.getMasterRecordList.data.forEach(
        item => {
          if (item.operation !== 1) {
            // 医療材料の分類が変更された
            if(item.dirtyFields && item.dirtyFields.classCd) {
              classiFicationFlg = true;
            } else if(item.dirtyFields && item.dirtyFields.classType){// 薬剤の分類が変更された
              classiFicationFlg = true;
            } else if (item.classiFicationFlg) {
              classiFicationFlg = true;
            }
          }
      });

      // add 分類区分/分類 修正 王 start
      if (
        this.masterPhysicalName === 'mst_medicine_class' ||
        this.masterPhysicalName === 'mst_equipment_class' ||
        this.masterPhysicalName === 'mst_equipment' ||
        this.masterPhysicalName === 'mst_medicine' ||
        this.masterPhysicalName === 'mst_medicine_mix'){
        let tempData = null;
        await ApiHelper.get(
          `/master_maintenance/${this.masterPhysicalName}/data/${this.facilitylistValue}`).then(response => {
          tempData = response.data.localDataSource.data
        });
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          for (let j = 0; j < tempData.length; j++) {
            if (tempData[j].code === this.getMasterRecordList.data[i].code){
              // mod IES_6711 【試験T】【結合テスター】調製薬マスター：「並び順表示」修正後保存できない zhou start
              //if (this.getMasterRecordList.data[i].classType !== undefined ){
              if (this.getMasterRecordList.data[i].classType !== undefined && this.getMasterRecordList.data[i].classType !== null){
              // mod IES_6711 【試験T】【結合テスター】調製薬マスター：「並び順表示」修正後保存できない zhou end
                console.log("j" ,j,tempData[j].classType)
                if(tempData[j].classType.toString() == this.getMasterRecordList.data[i].classType){
                  classiFicationFlg = false;
                } else {
                  classiFicationFlg = true;
                  i = this.getMasterRecordList.data.length;
                  break;
                }
              }
              // mod IES_6711 【試験T】【結合テスター】調製薬マスター：「並び順表示」修正後保存できない zhou start
              //if (this.getMasterRecordList.data[i].classCd !== undefined){
              if (this.getMasterRecordList.data[i].classCd !== undefined && this.getMasterRecordList.data[i].classCd !== null){
                // mod IES_6711 【試験T】【結合テスター】調製薬マスター：「並び順表示」修正後保存できない zhou end
                if(tempData[j].classCd.toString() == this.getMasterRecordList.data[i].classCd){
                  classiFicationFlg = false;
                } else {
                  classiFicationFlg = true;
                  i = this.getMasterRecordList.data.length;
                  break;
                }
              }
            }
          }
        }
      }
      // add 分類区分/分類 修正 王 end

      // add redmine 5702 溶解装置のトレンドグラフ 宋qy start
      if (this.masterPhysicalName === "mst_trend_graph_template" || this.masterPhysicalName === "mst_trend_graph_monitor_set") {
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          if (this.getMasterRecordList.data[i].model === "001" || this.getMasterRecordList.data[i].model === "002") {
            this.getMasterRecordList.data[i].comFormatCd = "";
          } else if (this.getMasterRecordList.data[i].model === "003") {
            this.getMasterRecordList.data[i].comFormatCd = "D";
          } else if (this.getMasterRecordList.data[i].model === "006") {
            this.getMasterRecordList.data[i].model = "003";
            this.getMasterRecordList.data[i].comFormatCd = "I";
          } else if (this.getMasterRecordList.data[i].model === "007") {
            this.getMasterRecordList.data[i].model = "003";
            this.getMasterRecordList.data[i].comFormatCd = "J";
          }
        }
      }
      // add redmine 5702 溶解装置のトレンドグラフ 宋qy end

      // 画面上で医療材料の分類が変更された場合
      if (classiFicationFlg) {
        await this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000051].title,
          // add 全マスタメッセージ調整 王 start
          // message: "分類が変更されました。透析指示に影響がないことを確認してください"
          message: DIALOG_MESSAGES[12000051].message
          // add 全マスタメッセージ調整 王 end
        });
        this.updateRecordList();
      } else {
        // 更新処理呼び出す
        this.updateRecordList();
      }
      // add FNSI-分類変更のメッセージ表示 李 end
    },

    // 水質検査箇所マスタ 水質調査種別  変更不可 start Du
    async validateWaterSurveyPointValue() {
      let surveyTypeCdList =[];
      this.getMasterRecordList.data.forEach(element =>{
        JSON.parse(this.comparisonRecordModel).forEach(item =>{
          if (element.code == item.code && element.surveyTypeCd != item.surveyTypeCd)
            surveyTypeCdList.push(item);
        });
      });
      if(surveyTypeCdList.length <= 0) {
        return
      }
      let str = surveyTypeCdList.map(
        record => record.code
      );
      let startDateStr = new Date().getFullYear()-1 +"-"+new Date().getMonth()+"-"+new Date().getDate()
      let endDateStr = new Date().getFullYear()+1 +"-"+new Date().getMonth()+"-"+new Date().getDate()
      let startDate = dayjs(startDateStr).format("YYYYMMDD");
      let endDate = dayjs(endDateStr).format("YYYYMMDD");
      let url = `waterSurvey/filter`;
      let postParams = {
        startDate,
        endDate,
        listSurveytypeCd: [],
        listBedGroupCd: []
      };
      try {
        this.setLoadingScreenVisible(true);
        const response = await ApiHelper.post(url, postParams);
        response.data.forEach(e =>{
           JSON.parse(e.surveyData).forEach(item =>{
              if (str.includes(item.point_cd) && item.text != "0") {
                this.waterSurveyPointValueFalg = true;
                return
              }
           });
        })
        this.setLoadingScreenVisible(false);
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('MasterRecordComponent.vue', 'validateWaterSurveyPointValue' , error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        this.setLoadingScreenVisible(false);
      }
      // 水質検査箇所マスタ 水質調査種別  変更不可 start Du
    },
    // mod FNSI-分類変更のメッセージ表示 李 start
    updateRecordList() {
      /* add スクロールの位置を維持 楊 start */
      // this.setLastScroll();
      /* add スクロールの位置を維持 楊 end */
      // 調製薬剤マスタ画面の分類が変更されない場合
      if (this.masterPhysicalName === "mst_medicine_mix" || this.masterPhysicalName === "mst_medicine") {
        for (let i = 0; i < this.getUpdateRecordList.length; i++) {
          delete this.getUpdateRecordList[i].classiFicationFlg;
        }
      }

      /* mod EOL対応内部#6937 by zhangruixue 2023-07-07 --start */
      if (this.masterPhysicalName === "mst_infection") {
        for (let i = 0; i < this.getUpdateRecordList.length; i++) {
          delete this.getUpdateRecordList[i].port;
        }
      }
      /* mod #6937 by zhangruixue 2023-07-07 --end */

      // apiをコールして値を保存
      this.updateRecordListByFacilityCd({facilityCd: this.facilitylistValue, request: this.getUpdateRecordList})
        .then(async response => {
          this.updateResponse = response.data;
          // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
          if (this.masterPhysicalName === "mst_treatment") {
            this.sendSetUpdateFlag();
            // this.masterSynchroIndCondInfo(this.getUpdateRecordList, this.comparisonRecordModel)
            // add #7327 治療方法マスタ操作時の動作がおかしい 付 start
            // mod #7327 削除の時エーラメッセージを処理する 徐博 start
            const editRecord = this.getUpdateRecordList.filter(item => (item.operation === 1 && item.edited) || item.operation === 2)
            const comparisonRecord = JSON.parse(this.comparisonRecordModel)
            editRecord.forEach(item => {
              // add 9664 by kangjie 20231211 start
              item.selectedDoctorNo = this.indUserId;
              // add 9664 by kangjie 20231211 end
              const oldItem = comparisonRecord.find(t => t.code === item.code);
              if(oldItem){
                item.oldTreatmentConditionSetting = oldItem.treatmentConditionSetting;
              item.oldDeviceMode = oldItem.deviceMode;
                }
            });
            ApiHelper.put(
              `/mst_treatment/updateOrdMainForTreatment/${this.facilitylistValue}`,
              editRecord
            )
            let count = 0
            for (const item of editRecord) {
              if (item.isDisp === "0") {
                count += 1
              }
            }
            if (count !== editRecord.length  && this.getUpdateRecordList.length === this.oldLocalDataSource.length) {
              // mod #7327 治療方法マスタ操作時の動作がおかしい 付 start
              // let changetips = null
              let msg = ''
              // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --start /
              let cdList = []
              for(let i =0;i<editRecord.length;i++){
                cdList.push(editRecord[i].code);
              }
              const resp = await ApiHelper.post(`/mst_treatment/getOrdMainByCds`,cdList)
              // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --end /
              // del 9664 by kangjie 20231214 start
              // for (let i = 0; i < editRecord.length; i++) {
              //   // changetips = await ApiHelper.get(`/mst_treatment/getOrdMainByCd/${editRecord[i].code}`)
              //   // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --start /
              //   if (resp.data && resp.data[editRecord[i].code]> 0) {
              //     // mod #7327 治療方法マスタ操作時の動作がおかしい 王永吉 start
              //     // msg += this.oldLocalDataSource.find(item => item.code === editRecord[i].code).name + 'を' + '<br/>'
              //     // msg += editRecord[i].name + 'に変更しました。' + '<br/>'
              //     msg +=　'治療方法：' + editRecord[i].name + 'を変更しました。' + '<br/>'
              //     // mod #7327 治療方法マスタ操作時の動作がおかしい 王永吉 end
              //     if(i === editRecord.length-1){
              //       this.setLoadingScreenVisible(false);
              //     }
              //     // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --end /
              //   }
              //   // changetips = null
              // }
              // this.$ons.notification.alert({
              //   // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              //   // title: "更新完了",
              //   // message: msg + '指示内容を再確認してください。'
              //   title: DIALOG_MESSAGES[12000106].title,
              //   message: messageFormat(DIALOG_MESSAGES[12000106].message, msg),
              //   // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              // });
              // del 9664 by kangjie 20231214 end
              // mod #7327 治療方法マスタ操作時の動作がおかしい 付 end
            // 内部 治療法マスタ:新規モード保存後はメ~セ~ジの内容が不正です start
            } else {
              this.setLoadingScreenVisible(false);
              this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "更新完了",
                // message: "マスタ更新が完了しました。"
                title: DIALOG_MESSAGES[12000004].title,
                message: messageFormat(DIALOG_MESSAGES[12000004].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              // 内部 治療法マスタ:新規モード保存後はメ~セ~ジの内容が不正です end
            }
            // mod #7327 削除の時エーラメッセージを処理する 徐博 end
            // add #7327 治療方法マスタ操作時の動作がおかしい 付 end
          } else {
            if (this.masterPhysicalName === "mst_exam_item") {
              // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
              this.setLoadingScreenVisible(true);
              // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
              this.masterSynchroOrder();
            } else if (this.masterPhysicalName === "mst_alarm_notification") {
              const facilityCds = this.getMasterRecordList.data
                .map(currentVal => currentVal.destinationFacilityCd)
                .filter((currentVal, index, self) => {
                  return self.indexOf(currentVal) === index;
                });
              this.synchroMstAlermToDeviceEdge(facilityCds, 0);
            } else {
              this.setLoadingScreenVisible(false);
              this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "更新完了",
                // message: "マスタ更新が完了しました。"
                title: DIALOG_MESSAGES[12000004].title,
                message: messageFormat(DIALOG_MESSAGES[12000004].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
          }
          // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
          this.findList();
        })
        .catch(error => {
          this.setLoadingScreenVisible(false);
          this.rollbackMasterRecordSavedGridScroll();
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MasterRecordComponent.vue', 'updateRecordListByFacilityCd' , error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        })
    },
    // mod FNSI-分類変更のメッセージ表示 李 end
    // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
    masterSynchroIndCondInfo(updateRecordList, comparisonRecordModel) {
      const editRecord = updateRecordList
        .filter(item => (item.operation === 1 && item.edited) || item.operation === 2)

      const comparisonRecord = JSON.parse(comparisonRecordModel)

      editRecord.forEach(item => {
        const oldItem = comparisonRecord.find(t => t.code === item.code)
        if (oldItem) item.oldDeviceMode = oldItem.deviceMode
      })

      ApiHelper.put(
        `/mst_treatment/updateOrdMainForTreatment/${this.facilitylistValue}`,
        editRecord
      )
    },
    // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
    // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
    formatValue(dataItem, column) {
      if (this.masterPhysicalName == "mst_monitor_graph" && ["leftGraphUpperLimit", "leftGraphLowerLimit", "rightGraphUpperLimit", "rightGraphLowerLimit"].includes(column.field)) {
        const dataIndexObj = {
          leftGraphUpperLimit: {
            dataIndex: dataItem.leftDataIndex
          },
          leftGraphLowerLimit: {
            dataIndex: dataItem.leftDataIndex
          },
          rightGraphUpperLimit: {
            dataIndex: dataItem.rightDataIndex
          },
          rightGraphLowerLimit: {
            dataIndex: dataItem.rightDataIndex
          },
        };
        if (dataIndexObj[column.field]?.dataIndex) {
          const sysMonitorItemObj = this.sysMonitorItemList.find(item => item.moni_data_no == dataIndexObj[column.field].dataIndex);
          if (!sysMonitorItemObj) {
            return dataItem[column.field] ?? "";
          }
          const decimals = sysMonitorItemObj.decimal_figure;
          return dataItem[column.field] != null ? Number(dataItem[column.field]).toFixed(decimals) : "";
        }
      }
      if (this.isWaterSurveyThresholdField(column.field)) {
        const thresholdValue = dataItem[column.field];
        if (thresholdValue === null || thresholdValue === undefined || thresholdValue === "") {
          return "";
        }
        const decimalDigits = dataItem.decimalDigits && dataItem.decimalDigits > 0 ? dataItem.decimalDigits : 0;
        const normalized = roundAndClampWaterSurveyThresholdValue(
          thresholdValue,
          dataItem.integerDigits,
          decimalDigits
        );
        return this.formatWaterSurveyThresholdDisplay(normalized, decimalDigits);
      }
      // #11241 11047残バグ：数値入力欄がnullと表示する linjunfeng start
      // return dataItem[column.field];
      let value = dataItem[column.field] ?? "";
      if (value !== "") {
        value = BigNumber(value).toFixed(); // 指数表記を通常表記に変換
      }
      return value;
      // #11241 11047残バグ：数値入力欄がnullと表示する linjunfeng end
    },
    // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
    // マスタ同期（警報通知マスタ）
    synchroMstAlermToDeviceEdge(facilityCds, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = `${this.getLogicalMasterName}同期`;
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, this.getLogicalMasterName);
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      if (facilityCds.length <= idx) {
        return;
      }
      const facilityCd = facilityCds[idx];

      // マスタ同期
      this.setLoadingScreenVisible(true);
      this.startMstSynchro({
        mstTable: this.mstSynchroApiParams.mstTable,
        facilityCd: facilityCd,
        deviceEdgeNo: this.mstSynchroApiParams.deviceEdgeNo
      })
        .then(() => {
          if (facilityCds.length === idx + 1) {
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            if (this.errorNameMstAlerm.length > 0){
              let name = "";
              this.errorNameMstAlerm.forEach(e => {
                name = name + e.text + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            } else {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "マスタ同期が完了しました。"
                message: messageFormat(DIALOG_MESSAGES['00100009'].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            this.errorNameMstAlerm = [];
          } else {
            // 次の施設
            this.synchroMstAlermToDeviceEdge(facilityCds, idx + 1);
          }
        })
        .catch(error => {
          getErrorMessage('MasterRecordComponent.vue', 'synchroMstAlermToDeviceEdge' , error);
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            for (const edge of error.response.data.failedDeviceEdgeList) {
              this.errorNameMstAlerm.push(edge.deviceName);
            }
            if (facilityCds.length === idx + 1) {
              let name = "";
              this.errorNameMstAlerm.forEach(e => {
                name = name + e + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              //共通ローダー：表示終了
              this.setLoadingScreenVisible(false);
              //共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                 // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   "<div style='max-height: 60vh; overflow-y: auto;'>" + name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。</div>"
                //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
                // message: messageFormat(`${DIALOG_MESSAGES[12000320].message}</div>`, `<div style='max-height: 60vh; overflow-y: auto;'>${name}}`),
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              this.errorNameMstAlerm = [];
            } else {
              // 次の施設
              this.synchroMstAlermToDeviceEdge(facilityCds, idx + 1);
            }
          }
        });
    },
    // マスタ同期（検査項目マスタ）
    masterSynchroOrder() {
      // ADD 検査項目マスタ-別施設のデバイスエッジとの同期ができなかったと表示される cuifc
      let facilityCdStr = this.getFacilitySwitch
      this.getMasterDeviceEdgeNoListByFacilityCd(facilityCdStr).then(res => {
        let array = res.data;
        if (array && array.length > 0) {
          array =  array.sort((a,b) => {
            if (a.deviceEdgeNo < b.deviceEdgeNo) return -1;
            if (a.deviceEdgeNo > b.deviceEdgeNo) return 1;
            return 0;
          })
          this.synchroMstToDeviceEdge(array, 0);
        }
      })
    },
    showRecalculationModal() {
      this.findList();
      this.showMstExamItemRecManagementModal();
    },
    // 指定したデバイスエッジとのマスタ同期
    synchroMstToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = `${this.getLogicalMasterName}同期`;
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, this.getLogicalMasterName);
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      const infos = list;
      if (infos.length <= idx) {
        return;
      }
      const info = infos[idx];
      let name = "デバイスエッジ：" + this.errorMessage + "</br></br>";

      // マスタ同期
      this.mstSyncDeviceEdge({
        facilityCd: null,
        deviceEdgeNo: info.deviceEdgeNo
      })
        .then(() => {
          if (infos.length === idx + 1) {
            name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            if (this.errorMessage === "") {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "マスタ同期が完了しました。
                message: messageFormat(DIALOG_MESSAGES['00100009'].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            } else {
              // 共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            this.errorMessage = "";
          } else {
            // 次のデバイスエッジ
            this.synchroMstToDeviceEdge(list, idx + 1);
          }
        })
        .catch(error => {
          if (this.errorMessage === "") {
            this.errorMessage += "</br>" + info.deviceName + "</br>";
          } else {
            this.errorMessage += info.deviceName + "</br>";
          }
          this.synchroMstToDeviceEdge(list, idx + 1);
          if (infos.length === idx + 1) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MasterRecordComponent.vue', 'synchroMstToDeviceEdge' , error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.setLoadingScreenVisible(false);
            if (error.response.status === 400) {
              name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
              // 共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              this.errorMessage = "";
              this.setLoadingScreenVisible(false);
            }
          }
        });
    },
    addRow(holidayNkkYear, holidayNkkCode) {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        this.scheduleValidationTooltipPlacement();
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          // modify start #9301
          if (['medicateTimingCd', 'procedureCd'].includes(k)) {
            d[k] = null;
          } else {
            d[k] = "";
          }
          // modify end #9301
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else if (fields[k].type === "color") {
          d[k] = "#000000";
        } else if (fields[k].type === "textarea") {
          d[k] = "";
        } else {
          d[k] = null;
        }
        d["isAddRow"] = true;
        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
        /* mod EOL対応内部 #6927 by ztc 2023-07-08 --start */
        if (k === "facilityCd") {
          d[k] = this.facilitylistValue;
        }
        /* mod EOL対応内部 #6927 by ztc 2023-07-08--end */
      });
		  // add #7003-ダイアライザマスタ・医療材料マスタの新規登録時の使用開始日と使用終了日の初期値に当日の日付が設定される 徐博 start
      if (this.masterPhysicalName === "mst_dialyzer") {
        d.useStartDate = ""
        d.useEndDate = ""
      }
      // add #7003-ダイアライザマスタ・医療材料マスタの新規登録時の使用開始日と使用終了日の初期値に当日の日付が設定される 徐博 end
      // add #7300-マスタ新規追加時に利用開始日/使用開始日/使用終了日にデフォルト値が入る 徐博 start
      if (this.masterPhysicalName === "mst_equipment") {
        d.useStartDate = ""
        d.useEndDate = ""
      }
      if (this.masterPhysicalName === "mst_treatment") {
        d.inHospAStartdate = ""
        d.inHospBStartdate = ""
      }
      if (this.masterPhysicalName === "mst_procedure") {
        d.inHospAStartdate = ""
        d.inHospBStartdate = ""
      }
      // add #7300-マスタ新規追加時に利用開始日/使用開始日/使用終了日にデフォルト値が入る 徐博 end
      if (this.masterPhysicalName === "mst_pat_viewer_layout") {
        d.dispItemInfo = JSON.stringify(mstPatViewerLayout);
      }
      if (this.masterPhysicalName == "mst_holiday") {
        d.class = "0";
      }
      if(holidayNkkYear && holidayNkkCode){
        d.year = holidayNkkYear;
        d.code = holidayNkkCode;
      }
      if (this.masterPhysicalName == "mst_medicine_mix") {
        d.classCd = -1;
        d.medicineSetNum = 1;
      }

      if (this.masterPhysicalName === "mst_water_survey_type") {
        d.initialString = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_water_survey_type));
      }
      if (this.masterPhysicalName === "mst_mainte_category") {
        d.detail = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_mainte_category));
        d.mainteClass = MainteClass.Daily;
      }
      if (this.masterPhysicalName === "mst_mainte_layout") {
        d.detailInfo1 = JSON.stringify([]);
        d.layoutClass = MainteClass.Daily;
      }
      if (this.masterPhysicalName === "mst_pat_calendar_layout") {
        d.dispItemInfo = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_pat_calendar_layout));
      }
      if (this.masterPhysicalName == "mst_addition") {
        // 加算マスタ の 算定回数上限 の defaultValue が null または undefined の場合は
        // 初期値を null として、詳細画面での初期値は空欄となるようにする
        if (fields.additionLimit?.defaultValue == null) {
          d.additionLimit = null;
        }
      }
      if (this.masterPhysicalName === "mst_url_link_register") {
        d.urlInfo = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_url_link_register.urlInfo));
      }      
      if (this.masterPhysicalName === "mst_menu_group") {
        d.iconInfo = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_menu_group.iconInfo));
      }

      // 追加行用フラグを立てる。実際の DataSource 更新と最下部スクロールは
      // masterRecords watch + dataBound に一任する（二重更新を避ける）
      this.scrollPosition.left = 0;
      this.__pendingScrollToBottom = true;
      this.edit({ editRecord: d, isSortMode: this.isSortMode, isHolidayNkk:holidayNkkYear ? true : undefined});
      this.scheduleMasterRecordRowVisualRefresh(d);
      // add 医療材料セットマスタ 追加の時、スクロール位置を取得 start 鞠
      if (this.masterPhysicalName == "mst_equipment") {
        const grid = this.getGridContentElement();
        this.scrollPosition.left = grid?.scrollLeft || 0;
      }
      // add 医療材料セットマスタ 追加の時、スクロール位置を取得 end 鞠
    },
    loadGridData(){
      // add #8541 ベッドグループ・透析室マスタ画面にて、虫眼鏡に抽出条件を入力後、検索すると、【透析室・ベッドグループ名】列が隠される。 付 start
      // delete start #9590
      // if (this.masterPhysicalName !== 'mst_room_bed_group') {
      //   // add マスタ障害対応 No43 孔 start
      //   EventBus.$emit("clearHeaderSearch");
      //   // add マスタ障害対応 No43 孔 start
      //   this.setCondition(this.condition);
      // }
      // delete end #9590
      // add #8541 ベッドグループ・透析室マスタ画面にて、虫眼鏡に抽出条件を入力後、検索すると、【透析室・ベッドグループ名】列が隠される。 付 start
      this.findList();
    },
    getMstMonitorData() {
      /* ===== 2024-07-04 #9312 Mod Start ===== */

      // ApiHelper.get("/mstInfo/mstPatViewerLayout/monitorItem", {
      //   facilityCd: this.getFacilitySwitch,
      //   /* add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --start */
      //   // クエリー条件を追加し、モニタータイプのみをクエリーする
      //   vitalMonitorClass: "2"
      //   /* add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --end */
      // }).then(response => {

      const mstAddMonitorRequestParam = {
        facility_cd: this.getFacilitySwitch,
        vital_monitor_class: ""
      }

      Promise.all([
        // this api return this particular result for this element.
        ApiHelper.get("/treatment-record/particularSMItems/treatment-graph"),
        ApiHelper.get("/mstInfo/mstAddMonitorByClass", mstAddMonitorRequestParam),
      ]).then(response => {
//         let selectVitalMonitorItemList = response;
//         //selectVitalMonitorItemListのフィルタ条件を削除します xiemj add start
//         // selectVitalMonitorItemList.data = selectVitalMonitorItemList.data.filter(item => (item.vitalMonitorClass == 2))
//         //selectVitalMonitorItemListのフィルタ条件を削除します xiemj add end
//         for (let i = 0; i < selectVitalMonitorItemList.data.length; i++) {
//           if (selectVitalMonitorItemList.data[i].tableType === 2) {
//             selectVitalMonitorItemList.data[i].moniDataNo = "MST" + selectVitalMonitorItemList.data[i].moniDataNo;
//             selectVitalMonitorItemList.data[i].upper = 0;
//             selectVitalMonitorItemList.data[i].lower = 0;
//           }
//         }
//         this.mstMonitorInitial = selectVitalMonitorItemList.data;
//         let dataSource = [{
//           value: "",
//           text: ""
//         }];
//         // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
//         const DISPLAYLIST=['31','0','A1','D1','Z11','Z21','Z232','Z364','I1','J1']
//         // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
//         selectVitalMonitorItemList.data.forEach((item) => {
// // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
//           if(!DISPLAYLIST.includes(item.moniDataNo)){
//             dataSource.push({
//               value: item.moniDataNo,
//               text: item.vitalMonitorItemName
//             })
//           }
// // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
//         })

        // 透析：モニタ項目
        const sysMonitorItem = response[0].data ? response[0].data : [];
        // 施設固有：バイタル・モニタ個別項目
        const mstAddMonitor = response[1].data ? response[1].data : [];
        // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
        this.sysMonitorItemList = sysMonitorItem;
        // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
        let monitorItemList = sysMonitorItem.filter( s => s.is_disp === '1')
          .map( item => {
            return {
              value: item.moni_data_no,
              text: item.moni_data_name
              // text: item.moni_data_short_name
            }
          });

        mstAddMonitor.forEach(
          mst => {
            if (mst.is_disp === '1') {
              monitorItemList.push({
                value: "MST" + mst.vital_monitor_item_cd,
                text: mst.vital_monitor_item_name
              })
            }
          }
        );

        this.mstMonitorGraphItem = monitorItemList;
      });
    },
    // redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy start
    stringEditor(container, data) {
      if (this.masterPhysicalName == "mst_mainte_detail" && (!data.model.mainteClass || data.model.mainteClass == "1")) {
        return;
      } else {
        // $(`<input type="text" name="${data.field}" class="k-input k-textbox k-valid"/>`).appendTo(container);
      }
    },
    // redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy end
    
    /**
     * 患者カレンダーレイアウトマスタで
     * categoryItem + vitalChild を表示状態に応じて正規化し、治療情報のcategoryItem 用の配列を返す
     */
    buildCategoryItemsVitalMonitor(categoryItem) {
      const result = [];
    
      const targets = [
        categoryItem,
        ...(categoryItem.vitalChild ?? [])
      ];
    
      targets.forEach((item, index) => {
        // 中項目のisDispがOFF、かつ、subCategoryItem が 1件も無い場合は追加しない
        if (!item.isDisp && (!Array.isArray(item.subCategoryItem) || item.subCategoryItem.length === 0)) {
          return;
        }

        delete item.isDispflag;
  
        item.subCategoryItem?.forEach(sub => {
          delete sub.isDisp;
          delete sub.isDispflag;
        });
  
        // 先頭（N-1）のみ vitalChild を削除
        if (index === 0) {
          delete item.vitalChild;
        }
  
        result.push(item);

      });
    
      return result;
    }
  },
  async created() {
    this.facilityHemoDialysis = this.getAdvancedSettings.func_advcds.some(
      setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
    );
    this.setLoadingScreenVisible(true);
    // apiをコールして施設一覧を取得

    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // this.findFacilityList();
    if (this.getFacilitySwitch !== "") {
      this.facilitylistValue = this.getFacilitySwitch;
    }
    // add start #9301
    if (this.masterPhysicalName === 'mst_medicine_mix') {
      this.getDefaultCd();
    }
    // add end #9301
    // #11205 -ペンテスト2－4認可制御の不備  sendRequestFindRecordListByFacilityCd(mst_holiday,nkknkk)廃止→専用API  mod 20260507 start
    if (
      this.masterPhysicalName == "mst_holiday" &&
      this.getFacilitySwitch != "nkknkk"
    ) {
      let responseData = "";
      await sendRequestFindMstHolidayNikkisoCorporateData().then(
        response => {
          responseData = response.data.localDataSource.data;
        }
      );
      this.mstHolidayNkkData = responseData;
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 end
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    this.calculateColumnsWidth();

    // add 治療記録モニタグラフマスタ 項目不正 start
    if (this.masterPhysicalName === "mst_monitor_graph") {
      this.getMstMonitorData();
      if (this.mstMonitorGraphItem.length === 0) {
        setTimeout(() => {
          this.loadGridData();
        },1500)
      } else {
        this.loadGridData();
      }
    } else {
      this.loadGridData();
    }
    // add 治療記録モニタグラフマスタ 項目不正 end

    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    if (this.masterPhysicalName === "mst_treatment_set") {
      // #11375 治療方法セットマスタの投与薬剤の薬剤選択が開かない。 linjunfeng start
      // this.getMstMedicineIncludeDeleted({ facilityCd: this.facilityCd });
      // this.getMstMedicineMixIncludeDeleted({ facilityCd: this.facilityCd });
      // this.getMstProcedure({ facilityCd: this.facilityCd });
      // this.getMstMedicateTiming({ facilityCd: this.facilityCd });
      this.getMstMedicineIncludeDeleted({ facilityCd: this.getFacilitySwitch });
      this.getMstMedicineMixIncludeDeleted({ facilityCd: this.getFacilitySwitch });
      this.getMstProcedure({ facilityCd: this.getFacilitySwitch });
      this.getMstMedicateTiming({ facilityCd: this.getFacilitySwitch });
      // #11375 治療方法セットマスタの投与薬剤の薬剤選択が開かない。 linjunfeng end
    }
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // add #8541 ベッドグループ・透析室マスタ画面にて、虫眼鏡に抽出条件を入力後、検索すると、【透析室・ベッドグループ名】列が隠される。 付 start
    await this.setCondition(this.condition)
    // add #8541 ベッドグループ・透析室マスタ画面にて、虫眼鏡に抽出条件を入力後、検索すると、【透析室・ベッドグループ名】列が隠される。 付 end
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$route.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    // EventBus.$on("refresh", this.refresh);

  },
  updated() {
    if (this.masterRecordRestoreScrollPending) {
      this.$nextTick(() => this.restoreMasterRecordGridScroll());
    }
  },

  mounted() {
    this.$nextTick(() => {
      if (this.columns.length > 1) {
        this.initKendoGrid();
      } else {
        this.calculateColumnsWidth();
        this.calculateGridHeight();
        this.calculateGridWidth();
      }
    });
    EventBus.$on("refresh", this.refresh);
  },
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    if (this.resizeObserver != null) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }
    if (this._masterRecordLayoutRafId != null) {
      cancelAnimationFrame(this._masterRecordLayoutRafId);
      this._masterRecordLayoutRafId = null;
    }
    clearTimeout(this.masterRecordSavedScrollClearTimer);
    this.masterRecordSavedScrollClearTimer = null;
    try { this._directGridWidget?.destroy?.(); } catch (_error) {}
    this._directGridWidget = null;
    destroyJQueryValidator(this.$refs.ntssList);
    this.kendoValidator = null;
    this.teardownValidationTooltipPlacement();
    this.setMasterRecordList([])
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
  overflow: auto;
}
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
.toolbar-btn {
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.csv-btn {
  margin-right: 1em;
}
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}
.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation
  .k-callout) {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}
.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation) {
  bottom: 38px;
  top: auto;
}
.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-last-child(2):nth-child(n + 2)
  .k-tooltip.k-tooltip-validation) {
  bottom: 38px;
  top: auto;
}
.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-last-child(2):nth-child(n + 2)
  .k-tooltip.k-tooltip-validation
  .k-callout) {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell) {
  position: relative;
  overflow: visible;
}
/* left は指定しない：input 直後への Kendo 挿入位置を維持し、セル基準 left:0 で左上にずれるのを防ぐ */
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-form-error:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-validator-tooltip:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)) {
  position: absolute;
  top: calc(100% + 2px);
  bottom: auto;
  z-index: 10;
  width: auto;
  min-width: 10em;
  max-width: min(24em, 90vw);
  margin: 0;
  white-space: normal;
  display: flex !important;
  align-items: flex-start;
  font-family: inherit !important;
  font-size: inherit !important;
  font-weight: normal !important;
  line-height: 1.4 !important;
  box-sizing: border-box;
  transform: none !important;
}

/* Editable の .k-tooltip-content は Kendo tooltip 既定の font-size を継承し、太く見えやすい */
.kendo-grid-toolbar-style :deep(.k-edit-cell .k-tooltip-content) {
  font-family: inherit !important;
  font-size: inherit !important;
  font-weight: normal !important;
  line-height: 1.4 !important;
}

/* JS ntss-validation-above：スクロール領域下端で tooltip をセル上に表示 */
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-invalid-msg.k-tooltip-error),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-error),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-validator-tooltip),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-invalid-msg.k-tooltip-error),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-error),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-validator-tooltip),
.master-record-direct-jq-grid :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell > .k-invalid-msg),
.master-record-direct-jq-grid :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell .k-tooltip.k-tooltip-error) {
  position: absolute !important;
  left: 0 !important;
  bottom: 39px !important;
  top: auto !important;
  /* margin-top: 0 !important; */
  overflow: visible !important;
  padding:9px 15px !important;
  align-items: center;
  margin: 0.5em;
}
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.master-record-direct-jq-grid :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell .k-callout.k-callout-n) {
  top: auto !important;
  bottom: calc(-12px) !important;
  border-bottom-color: transparent !important;
  border-block-start-color: #000000 !important;
}

.kendo-grid-toolbar-style :deep(.k-grid-content > .k-selectable) {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
}

/* 表データ位置は維持したまま、縦スクロールバーのみを右へ微調整する。 */
.kendo-grid-toolbar-style :deep(.k-grid-content) {
  margin-right: -2px;
  padding-right: 2px;
}

/* Vue2 direct jq 画面: 表頭 .k-link の cursor を default に（列ソート無しの誤表示防止） */
.kendo-grid-toolbar-style :deep(.k-grid-header th),
.kendo-grid-toolbar-style :deep(.k-grid-header .k-table-th),
.kendo-grid-toolbar-style :deep(.k-grid-header .k-link),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked th),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked .k-table-th),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked .k-link) {
  border-right-color: currentColor;
  cursor: default;
}

.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table) {
  border-right-width: 0px;
}

.kendo-grid-toolbar-style :deep(.k-grid-header-locked) {
  border-right: 1px solid var(--ntss-list-border-color) !important;
  border-inline-end-color: var(--ntss-list-border-color) !important;
}

/* Kendo UI 2026 の locked grid は header/content が flex item になるため、
   Vue2 と同じ固定列幅契約を CSS でも補強する。実幅は JS 側で width/min-width/flex-basis に同期する。 */
.kendo-grid-toolbar-style :deep(.k-grid-header-locked),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  flex-shrink: 0;
}

.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  z-index: 1;
  border-inline-end-color: var(--ntss-border-color) !important;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}

.kendo-grid-toolbar-style :deep(.k-grid-content-locked > .k-selectable) {
  border-right-width: 0px;
}

@media print {
  .print-grid-style :deep(.k-grid) {
    border: none !important;
  }
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
:deep(.k-widget textarea:not(.master-record-textarea-editor)){
  height: 6.8em;
}
/* Grid 内 textarea 編集: 行高を固定し、複数行は内部スクロール（locked 列ずれ防止） */
.kendo-grid-toolbar-style :deep(textarea.master-record-textarea-editor) {
  height: 6.8em;
  min-height: 6.8em;
  overflow-y: auto;
  resize: vertical;
  box-sizing: border-box;
  display: block;
}
/* Vue2 Kendo Grid clipped normal list cells by column width.
   Vue3 direct jqGrid can leave generated td elements without that default,
   so restore the common display contract here instead of fixing each master. */
.kendo-grid-toolbar-style :deep(.k-grid-content td:not(.k-edit-cell)),
.kendo-grid-toolbar-style :deep(.k-grid-content .k-table-td:not(.k-edit-cell)),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked td:not(.k-edit-cell)),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked .k-table-td:not(.k-edit-cell)) {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
/* 並び順 (sortRank) の黄色は master-sort-edited のみ（手入力変更行を Set で管理）。
   k-dirty-cell ベースだと反映後の grid.refresh で全行が黄色になるため使わない。 */
.kendo-grid-toolbar-style :deep(.k-grid td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid td.master-sort-edited:hover),
.kendo-grid-toolbar-style :deep(.k-grid td.master-sort-edited.k-hover),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-td.master-sort-edited:hover),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-td.master-sort-edited.k-hover),
.kendo-grid-toolbar-style :deep(.k-grid tr.master-sort-edited > td),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.master-sort-edited > .k-table-td),
.kendo-grid-toolbar-style :deep(.k-grid tr:hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.k-hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.k-selected > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.k-selected:hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.k-selected.k-hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.k-state-selected > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.k-state-selected:hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.k-state-selected.k-hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr[aria-selected="true"] > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr[aria-selected="true"]:hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr[aria-selected="true"].k-hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.master-edited-row > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.master-edited-row:hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.master-edited-row.k-hover > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid tr.k-grid-edit-row > td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row:hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.k-hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.k-selected > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.k-selected:hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.k-selected.k-hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.k-state-selected > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.k-state-selected:hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.k-state-selected.k-hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row[aria-selected="true"] > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row[aria-selected="true"]:hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row[aria-selected="true"].k-hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.master-edited-row > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.master-edited-row:hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.master-edited-row.k-hover > .k-table-td.master-sort-edited),
.kendo-grid-toolbar-style :deep(.k-grid .k-table-row.k-grid-edit-row > .k-table-td.master-sort-edited) {
  color: #000000 !important;
  background: #ffff66 !important;
  background-color: #ffff66 !important;
}
.kendo-grid-toolbar-style :deep(td.master-sort-edited[data-field="sortRank"]) .k-dirty {
  border-width: 0;
}
:deep(input[type="date"].ntss-input-date),
:deep(.k-i-close){
  font-weight: 200 !important;
}
/* 治療記録モニタグラフマスタ / 治療記録バイタルグラフマスタ: theme.css の line-height: 2em !important を上書き */
.master-maintenance-page.master-mst-monitor-graph :deep(.ntss-kendo-grid-legacy td),
.master-maintenance-page.master-mst-monitor-graph :deep(.ntss-kendo-grid-legacy .k-table-td),
.master-maintenance-page.master-mst-vital-graph :deep(.ntss-kendo-grid-legacy td),
.master-maintenance-page.master-mst-vital-graph :deep(.ntss-kendo-grid-legacy .k-table-td) {
  line-height: 1.5em !important;
}

</style>
