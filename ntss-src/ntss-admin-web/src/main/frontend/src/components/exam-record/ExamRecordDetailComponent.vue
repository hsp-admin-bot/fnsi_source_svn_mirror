/**
 * 検査結果一覧用メイン
 */
<template>
  <div class='main-content-area kendo-grid-style-page' style = "overflow-y: hidden;overflow-x:hidden;">
    <div class='exam-record-detail-head-content' id='examrecorddetailhead' style="position:relative;">
      <div style="width: 100%; height: 4.7em; font-size: 0.667em;">
        <common-searcharea :lineHeight="'3.8em'" :conditionList="conditionList" @show-popover='showPopover($event)'/>
      </div>
      <!--劉全航 start-->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <v-ons-button -->
      <!-- class="examRecord-style-select-button btn3-normal" -->
      <!-- style="min-width: 5em; margin-left: 0.5em;" -->
      <!-- v-bind:disabled="isDisabled" -->
      <!-- @click="createExamRecord"> -->
      <v-ons-button
        class="examRecord-style-select-button btn3-normal"
        style="min-width: 5em; margin-left: 0.5em;"
        v-bind:disabled="!isDisabled && !getItemAuthorized('ExamRecord', 'default_authority')"
        @click="createExamRecord">
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      新規登録
      </v-ons-button>
      <!-- del delete button 関 start -->
      <!-- <v-ons-button class="examRecord-style-select-button" style="margin-right: 1em; float:right;" v-bind:disabled="isSelectedPatId == null" @click="createExamRecord">新規作成</v-ons-button> -->
      <!-- del delete button 関 end -->
      <!--劉全航 end-->
      <v-ons-button class="examRecord-style-select-button btn3-normal" style="min-width: 4em; margin-left: 0.5em;" @click="createGraph">グラフ</v-ons-button>
    </div>
    <div class='exam-record-detail-main-content' style = "overflow-y:auto; overflow-x:auto; position:relative; top:5px;">
      <!-- チェックリスト一覧のグリッド -->
      <div id='examrecorddetailgrid'>
        <div
          class='exam-detail-list ntss-kendo-grid-legacy'
          ref='examrecorddetailgrid'
        ></div>
      </div>
    </div>

    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'exam-record-detail-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="handlePopoverPosthide"
    >
      <div style="margin:10px;">
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">検査日開始</label>
          </v-ons-col>
          <v-ons-col vertical-align='center' style="white-space: nowrap;">
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
            <!-- <input
              input-id='treatDateSt'
              name='treatDateSt'
              type='date'
              float
              model-event="change"
              class="ntss-input-date"
              style="padding-right: unset"
              v-model='localCondition.examDateSt'
              v-rules="'date_format:yyyy-MM-dd'" /> -->
            <date-input
              input-id="treatDateSt"
              name="treatDateSt"
              type="date"
              model-event="change"
              class="ntss-input-date"
              style="padding-right: unset"
              v-model="localCondition.examDateSt"
              v-rules="'date_format:yyyy-MM-dd'"
              @handleClearInput="localCondition.examDateSt = ''"
            />
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
            <common-calendar v-model="localCondition.examDateSt" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">検査日終了</label>
          </v-ons-col>
          <v-ons-col vertical-align='center' style="white-space: nowrap;">
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
            <!-- <input
              input-id='treatDateEd'
              name='treatDateEd'
              type='date'
              float
              model-event="change"
              class="ntss-input-date"
              style="padding-right: unset"
              v-model='localCondition.examDateEd'
              v-rules="'date_format:yyyy-MM-dd'" /> -->
            <date-input
              input-id="treatDateEd"
              name="treatDateEd"
              type="date"
              model-event="change"
              class="ntss-input-date"
              style="padding-right: unset"
              v-model="localCondition.examDateEd"
              v-rules="'date_format:yyyy-MM-dd'"
              @handleClearInput="localCondition.examDateEd = ''"
            />
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
            <common-calendar v-model="localCondition.examDateEd" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row v-show="hasValidationError('treatDateSt')">
          <td>
            <p v-show="hasValidationError('treatDateSt')" class="error-message">
              {{ getValidationError('treatDateSt') }}
            </p>
          </td>
        </v-ons-row>
        <v-ons-row v-show="hasValidationError('treatDateEd')">
          <td>
            <p v-show="hasValidationError('treatDateEd')" class="error-message">
              {{ getValidationError('treatDateEd') }}
            </p>
          </td>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">異常値のみ表示</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-switch input-id="switchTreatDate" v-model="localCondition.outRange"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">正常範囲列表示</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-switch input-id="switchNormalRange" v-model="localCondition.normalRange"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">単位列表示</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-switch input-id="switchUnit" v-model="localCondition.unitDisplay"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">検査セット</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-select input-id='examSetCd' v-model="localCondition.examSetCd">
              <option :value="defaultSelect"></option>
              <option v-for="(option, index) in getExamSetNameList" :key="index" :value="option.examSetCd">
                {{ option.examSetName }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">グラフセット</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-select input-id='examSetCd' v-model="localCondition.examGraphCd">
              <option :value="defaultSelect"></option>
              <template v-for='(option, index) in getExamSetNameList' :key="index">
                 <option v-if="option.graphSet == 1" :value="option.examSetCd">
                  {{ option.examSetName }}
                </option>
              </template>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='clear btn2-cancel' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='ok btn3-normal' :disabled="!canSave" @click='dialogOk'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
  // add #10359 編集権限の動作不正 dengshen start
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 dengshen end
  import {mapActions, mapGetters, mapMutations} from "@/compat/vue/vuex";
  import {EventBus} from "@/compat/vue/event-bus.js";
  import NextTransitionMixin from "@/components/NextTransitionMixin";
  import {deepCopy} from "@/functions/common/CommonFunctions";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import commonSearchArea from "@/components/common/CommonSearchArea";
  import PopoverMixin from "@/components/PopoverMixin";
  import { EXAM_RECORD } from "@/constants/defaultSettingConstants";
  import {calcTargetDate, DATE_FORMAT} from "@/functions/modals/default-setting/defaultSettingUtils";
  import {popoverPosthide, popoverPostShow, popoverPreShow} from "@/functions/common/CommonPopoverFunctions";
  import { makeDefaultCondition, findExamSet } from "@/functions/exam-record/ExamRecordFunctions";

  import dayjs from "@/compat/date/dayjs";
  import $$ from "@/compat/jquery";
  import kendo from "@progress/kendo-ui";

  // del #10359 編集権限の動作不正 dengshen start
  // //mod 編集権限の適用 劉全航 start
  // import {AUTHORITY_CODES} from "@/constants/userAuthority.js";
  // //mod 編集権限の適用 劉全航 end
  // del #10359 編集権限の動作不正 dengshen end
  import { getCurrentFunctionCd } from "@/router/routing-helper";
  import {DISP_ORDER_LEFT_PAST} from "@/constants/examRecordConstants";
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
  import DateInput from "@/components/common/DateInput.vue";
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
  import {messageFormat} from "@/functions/common/MessageFormat";
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
  // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
  import store from "@/stores";
import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getScopedElementById, getScopedWindow, nextLayoutFrame, resolveRefElement } from "@/functions/common/LayoutMeasureHelper";
import {
  getKendoGridSelectedCellIndex,
  getKendoGridSelectedDataItem,
  getKendoGridSelectedRowIndex,
  isKendoGridSelectionInLockedContent,
} from "@/compat/kendo/dom.js";

  // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
  import PrintMixin from "@/components/PrintMixin";

function createDataSource(options) {
  return new kendo.data.DataSource(options || {});
}

function getExamDetailGridElement(target) {
  if (!target) return null;
  if (target.jquery) return target[0] || null;
  if (target.element?.jquery) return target.element[0] || null;
  if (target.element instanceof Element) return target.element;
  if (target.$el instanceof Element) return target.$el;
  if (target instanceof Element) return target;
  return null;
}

function getExamDetailGridWidget(target) {
  if (!target) return null;
  if (target.dataSource && target.element) return target;
  const element = getExamDetailGridElement(target);
  return element ? $$(element).data("kendoGrid") : null;
}

function findKendoGridContent(target) {
  return getExamDetailGridElement(target)?.querySelector?.(".k-grid-content") || null;
}

function findKendoGridHeader(target) {
  return getExamDetailGridElement(target)?.querySelector?.(".k-grid-header") || null;
}

function findKendoGridHeaderWrap(target) {
  return getExamDetailGridElement(target)?.querySelector?.(".k-grid-header-wrap") || null;
}

function findKendoGridLockedContent(target) {
  return getExamDetailGridElement(target)?.querySelector?.(".k-grid-content-locked") || null;
}

function findKendoGridLockedRows(target) {
  const element = getExamDetailGridElement(target);
  return Array.from(element?.querySelectorAll?.(".k-grid-content-locked tbody tr") || []);
}

function findKendoGridBodyRows(target) {
  const element = getExamDetailGridElement(target);
  return Array.from(element?.querySelectorAll?.(".k-grid-content tbody tr") || []);
}

function findKendoGridHeaderCells(target) {
  const element = getExamDetailGridElement(target);
  return Array.from(element?.querySelectorAll?.(".k-grid-header-wrap th[data-field], .k-grid-header-wrap .k-table-th[data-field]") || []);
}

function getKendoGridDataItem(target, row) {
  return getExamDetailGridWidget(target)?.dataItem?.(row) || null;
}

function getKendoGridDataItems(target) {
  const widget = getExamDetailGridWidget(target);
  const data = widget?.dataSource?.view?.() || widget?.dataSource?.data?.() || [];
  return typeof data.toJSON === "function" ? data.toJSON() : Array.from(data || []);
}

function syncKendoGridLockedContentScroll(target, options = {}) {
  const content = findKendoGridContent(target);
  const lockedContent = findKendoGridLockedContent(target);
  if (!content || !lockedContent) return;
  lockedContent.scrollTop = content.scrollTop;
  if (options.touch) {
    try {
      content.dispatchEvent(new Event("scroll", { bubbles: true }));
    } catch (_error) {
      try { $$(content).trigger("scroll"); } catch (_innerError) { /* noop */ }
    }
  }
}

export default {
props: {
  // NOTE: コンソールエラー対策
  historyKey: null
},
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
	// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
    "date-input": DateInput,
	// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  },
  mixins: [NextTransitionMixin, PopoverMixin, PrintMixin],
  // #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
  // beforeRouteLeave(to, from, next) {
  async beforeRouteLeave(to, from, next) {
  // #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
    this.isRouteLeaving = true;
    if(to.fullPath.indexOf("exam-record") > -1){
      // 遷移先が検査結果系画面：初期化しない
    }else{
      // 遷移先が検査結果系画面以外：listを初期化
      this.storeReset();
    }
    // #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
    // next();
    try {
      if (to.name != "signin" && !!this.isPatInfoChaned) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              this.setIsPatInfoChaned(false);
              next();
            } else {
              this.isRouteLeaving = false;
            }
          }
        });
      } else {
        next();
      }
    } catch (error) {
      getErrorMessage('ExamRecordDetailComponent.vue', 'beforeRouteLeave', error);
      next();
    }
    // #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      // 抽出条件
      localCondition: {
        examDateSt: "",
        examDateEd: "",
        outRange: false,
        normalRange: false,
        unitDisplay: false,
        examSetCd: -1,
        examGraphCd: -1,
	      examPatId: "",
        examPatSex: "",
      },
      sendOrdNo: null,
      debugmode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      selectItems:[],
      androidFlg: false,
      iosFlg: false,
      firstRender: true,
      scrollPosition: {
        top: 0,
        left: 0
      },
      directGridWidget: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
      isRouteLeaving: false,
      //mod 編集権限の適用 劉全航 end
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      selfScreenName: "",
      setScrollPosition: null,
      scrollQuerySelector: ".k-grid-content", // スクロールコンテナ
      addClassTargetQuerySelector: [".k-grid-header-wrap table, .k-grid-content table"], // scroll-rightmostクラスを付与する対象のクエリセレクタ
      isLoadingTriggered: false
    };
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      sidebarWidth: "getSidebarWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
      getPatientShareMode: "getPatientShareMode"
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("exam-record/list", [
      "getCondition",
      "getDetailCondition",
      "getExamRecordDetailColumn",
      "getExamDetailDataSource",
      "getExamSetNameList",
      "getExamDefaultSex",
      "getExamResultDispOrder",
    ]),
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 start
    ...mapGetters("exam-record/modal", [
      "getIsOpenFlag"
    ]),
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 end
    ...mapGetters("pat-info", ["selectedPatId","selectedPatSex"]),
    ...mapGetters("split-graph", ["getExamRecordDate"]),
    ...mapGetters("loading-screen", ["getLoadingScreenVisible"]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
    ...mapGetters("pat-info", [
      "isPatInfoChaned",
      "getIsOtherFacility",
      "getOtherFacilityCd"
    ]),
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
    examDetailDataSource() {
      // mod #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 start
      let dataObj = this.getExamDetailDataSource
      if (dataObj != null) {
        dataObj = this.replaceObjData(dataObj, "NaN", "")
      }
      // storeからデータを取得
      return createDataSource({
        // data: this.getExamDetailDataSource
        data: dataObj
      });
      // mod #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 end
    },
    examRecordDetailGridColumns() {
      return this.getExamRecordDetailColumn;
    },
    defaultSelect: () => -1,
    treatDate() {
      return this.getDetailCondition.treatDate.replace(/-/g, "/");
    },
    isSelectedPatId(){
      return this.selectedPatId;
    },
    /**
     * OKボタンがクリックできるかどうか.
     */
    canSave() {
      return this.validationErrors.length === 0 && !!this.selectedPatId;
    },

    isDisabled(){
      // mod #10359 編集権限の動作不正 dengshen start
      // if(this.isAuthorized === true & this.isSelectedPatId !== null){
      if(this.isSelectedPatId !== null){
      // mod #10359 編集権限の動作不正 dengshen end
        return false;
      }else{
        return true;
      }
    },
  },
  methods: {
    getExamRecordGridRef() {
      return this.$refs.examrecorddetailgrid || null;
    },
    getExamRecordGridWidget() {
      return this.directGridWidget || getExamDetailGridWidget(this.getExamRecordGridRef());
    },
    getExamRecordGridColumns() {
      return this.getExamRecordGridWidget()?.columns || [];
    },
    clearExamRecordGridSelection() {
      return this.getExamRecordGridWidget()?.clearSelection?.();
    },
    resizeExamRecordGridColumn(column, width) {
      return this.getExamRecordGridWidget()?.resizeColumn?.(column, width);
    },
    isExamRecordResultField(field) {
      return /^M.+Cd$/.test(String(field || ""));
    },
    findExamRecordDetailColumnByField(field, columns = this.examRecordDetailGridColumns || []) {
      if (!field) {
        return null;
      }
      for (const column of columns) {
        if (column.field === field) {
          return column;
        }
        if (Array.isArray(column.columns)) {
          const child = this.findExamRecordDetailColumnByField(field, column.columns);
          if (child) {
            return child;
          }
        }
      }
      return null;
    },
    getSelectedGridCellElement(sender) {
      let selected = null;
      try {
        selected = sender?.select?.();
      } catch (_error) {
        selected = null;
      }
      const element = selected?.[0] || selected?.get?.(0) || selected;
      return element?.matches?.("td,th") ? element : element?.closest?.("td,th") || null;
    },
    getFieldFromColumnsByIndex(columns, index) {
      const safeIndex = Number(index);
      if (!Number.isInteger(safeIndex) || safeIndex < 0) {
        return null;
      }
      return columns?.[safeIndex]?.field || null;
    },
    getSelectedExamRecordField(sender) {
      const selectedCell = this.getSelectedGridCellElement(sender);
      const cellField = selectedCell?.getAttribute?.("data-field");
      if (this.isExamRecordResultField(cellField)) {
        return cellField;
      }

      const columns = sender?.columns || [];
      const kendoCellIndex = getKendoGridSelectedCellIndex(sender);
      const columnField = this.getFieldFromColumnsByIndex(columns, kendoCellIndex);
      if (this.isExamRecordResultField(columnField)) {
        return columnField;
      }

      const nativeCellIndex = selectedCell?.cellIndex;
      const nonLockedColumns = columns.filter(column => !column.locked);
      const nonLockedField = this.getFieldFromColumnsByIndex(nonLockedColumns, nativeCellIndex);
      if (this.isExamRecordResultField(nonLockedField)) {
        return nonLockedField;
      }

      const visibleNonLockedColumns = nonLockedColumns.filter(column => !column.hidden);
      const visibleNonLockedField = this.getFieldFromColumnsByIndex(visibleNonLockedColumns, nativeCellIndex);
      if (this.isExamRecordResultField(visibleNonLockedField)) {
        return visibleNonLockedField;
      }

      const headerField = findKendoGridHeaderCells(sender)[kendoCellIndex]?.getAttribute?.("data-field");
      return this.isExamRecordResultField(headerField) ? headerField : null;
    },
    normalizeDirectGridColumn(column = {}) {
      const normalized = {
        headerTemplate: column.headerTemplate,
        title: column.title,
        width: column.width,
        field: column.field,
        hidden: !!column.hidden,
        locked: !!column.locked,
        lockable: column.lockable,
        attributes: column.attributes,
        headerAttributes: column.headerAttributes,
      };
      if (column.isOtherFacility != null) {
        normalized.isOtherFacility = column.isOtherFacility;
      }
      if (Array.isArray(column.columns)) {
        normalized.columns = column.columns.map(child => this.normalizeDirectGridColumn(child));
      }
      return normalized;
    },
    buildDirectGridColumns() {
      return (this.examRecordDetailGridColumns || []).map(column => this.normalizeDirectGridColumn(column));
    },
    getDirectGridColumnSignature() {
      return JSON.stringify((this.examRecordDetailGridColumns || []).map(column => ({
        field: column.field,
        title: column.title,
        width: column.width,
        hidden: !!column.hidden,
        locked: !!column.locked,
        isOtherFacility: !!column.isOtherFacility,
        attributes: column.attributes,
        headerAttributes: column.headerAttributes,
        childCount: Array.isArray(column.columns) ? column.columns.length : 0,
      })));
    },
    installDirectGridFacade() {
      const root = this.getExamRecordGridRef();
      if (!root) return;
      root.kendoWidget = () => this.getExamRecordGridWidget();
      root.gridWidget = () => this.getExamRecordGridWidget();
      root.gridColumns = () => this.getExamRecordGridColumns();
      root.clearGridSelection = () => this.clearExamRecordGridSelection();
      root.resizeGridColumn = (column, width) => this.resizeExamRecordGridColumn(column, width);
      root.rebuildGrid = ({ preserveScroll = true } = {}) => this.refreshExamRecordGrid(preserveScroll);
    },
    applyDirectGridColumnsContract() {
      const widget = this.getExamRecordGridWidget();
      if (!widget) return;
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridColumnSignature !== nextSignature) {
        widget.setOptions({ columns: this.buildDirectGridColumns() });
        this.directGridColumnSignature = nextSignature;
      }
    },
    initDirectGridIfReady() {
      const root = this.getExamRecordGridRef();
      if (!root || !Array.isArray(this.examRecordDetailGridColumns) || this.examRecordDetailGridColumns.length === 0) {
        return;
      }
      const existing = $$(root).data("kendoGrid");
      if (existing) {
        this.directGridWidget = existing;
        this.installDirectGridFacade();
        this.applyDirectGridColumnsContract();
        this.refreshExamRecordGrid(true);
        return;
      }
      $$(root).kendoGrid({
        dataSource: this.examDetailDataSource,
        columns: this.buildDirectGridColumns(),
        editable: false,
        reorderable: false,
        resizable: true,
        selectable: "cell",
        height: this.kendoGridHeight,
        scrollable: true,
        dataBound: event => {
          this.applyDirectGridStyleContract();
          this.dataBound();
          this.setFontColor(event);
          this.resizeSelectRows();
        },
        change: event => this.onClickChange(event),
      });
      this.directGridWidget = $$(root).data("kendoGrid") || null;
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
      this.installDirectGridFacade();
      this.scheduleDirectGridLayoutContract();
    },
    applyDirectGridStyleContract() {
      const root = this.getExamRecordGridRef();
      if (!root) return;
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-display-block");
      root.querySelectorAll("th, .k-table-th").forEach(th => th.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(selector).forEach(tbody => {
          Array.from(tbody.children || []).forEach((tr, index) => {
            tr.classList.add("k-master-row");
            tr.classList.toggle("k-alt", index % 2 === 1);
          });
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        const widget = this.getExamRecordGridWidget();
        if (widget) {
          widget.setOptions({ height: this.kendoGridHeight });
          widget.resize?.(true);
        }
        this.applyDirectGridStyleContract();
        if (widget) {
          this.setFontColor({ sender: widget });
        }
      });
    },
    destroyDirectGrid() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
        this.directGridLayoutRafId = null;
      }
      const root = this.getExamRecordGridRef();
      const widget = this.getExamRecordGridWidget();
      widget?.destroy?.();
      if (root) {
        root.innerHTML = "";
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = "";
    },
    refreshExamRecordGrid(preserveScroll = true) {
      if (this.isRouteLeaving) return null;
      const root = this.getExamRecordGridRef();
      if (!root) return null;
      const position = preserveScroll ? { ...this.scrollPosition } : { top: 0, left: 0 };
      const widget = this.getExamRecordGridWidget();
      if (!widget) {
        this.initDirectGridIfReady();
        return null;
      }
      this.applyDirectGridColumnsContract();
      widget.setDataSource(this.examDetailDataSource);
      this.scheduleDirectGridLayoutContract();
      this.$nextTick(() => {
        if (preserveScroll) {
          this.restoreScrollPosition(position);
        }
      });
      return widget;
    },
    ...mapActions("multi-modal", [
      "showExamRecordModal",
      "showExamRecordGraphModal"
    ]),
    ...mapActions("exam-record/list", [
      "storeReset",
      "setDetailCondition",
      "resetStatusDetailGridColumn",
      "setExamRecordDetailColumn",
      "sendDetailCondition",
      "resetExamDetailDataSource",
      "setExamDetailSelectData",
      "setDetailSelectItems",
      "examSelectDefaultSex",
      "examSetNameList",
      "setSortNameList",
      "resultDispOrderSetting",
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
    ]),
    ...mapActions("exam-record/modal", ["setExamModalDataSource"]),
    ...mapActions("split-graph", ["setExamRecordDate"]),
    // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 start
    ...mapMutations("exam-record/modal", ["setModalState", "setIsOpenFlag"]),
    // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 end
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    handlePopoverPosthide(event) {
      if (this.popoverVisible) {
        // 背景クリックで閉じられる場合
        this.setStoredCondition();
      }
      this.popoverPosthide(event);
    },
    // add #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 start
    replaceObjData(obj, val, replace) {
      if (typeof obj === "object") {
        if (Array.isArray(obj)) {
          for (let i = 0; i < obj.length; i++) {
            obj[i] = this.replaceObjData(obj[i], val, replace);
          }
        } else {
          for (let key in obj) {
            obj[key] = this.replaceObjData(obj[key], val, replace);
          }
        }
        return obj
      } else {
        return obj === val ? replace : obj;
      }
    },
    // add #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 end
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
    getselectedExamSetName(examSetCd){
      var name = "";
      if (examSetCd != -1) {
        this.getExamSetNameList.forEach(everySet => {
          if (everySet.examSetCd == examSetCd) {
            name = everySet.examSetName;
          }
        });
      }
      return name;
    },
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
    requestrReportParams(param) {
      // 機能コード判定
      // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 start
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3) && !this.getIsOpenFlag) {
        // add #11285 機能帳票の印刷情報対応② 高 start
        var expressCondCd="";
        if (null != this.getStorSimlpSearchQurey.rstDialysisState && this.getStorSimlpSearchQurey.rstDialysisState.length > 0) {
          if (this.getStorSimlpSearchQurey.rstDialysisState.length == 2) {
            expressCondCd = "予定・実績";
          } else {
            if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
              expressCondCd = "予定";
            } else {
              expressCondCd = "実績";
            }
          }
        }
        let kurNames = null;
        if(this.getStorSimlpSearchQurey.kurNames && this.getStorSimlpSearchQurey.kurNames.length > 0) {
          kurNames = this.getStorSimlpSearchQurey.kurNames.join("・");
        } else {
          kurNames = "すべて";
        }
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        // add #11285 機能帳票の印刷情報対応② 高 end
        // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 end
        // 機能一致
        var patFalg;
        if (this.selectedPatId === null) {
          patFalg = this.searchedPatList.map(({ pat_id }) => pat_id);
        } else {
          patFalg = null;
        }
        // 印刷パラメータを応答
        const params = {
          patId: this.selectedPatId,
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patIds: patFalg,
          facilityCd: this.getFacilityCd,
          //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
          //date: dayjs(this.localCondition.examDateSt).format("YYYY/MM/DD"),
          //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
          //fromDate: dayjs(this.localCondition.examDateSt).format("YYYY/MM/DD"),
          //toDate: dayjs(this.localCondition.examDateEd).format("YYYY/MM/DD"),
          date: this.localCondition.examDateSt != null ? dayjs(this.localCondition.examDateSt).format("YYYYMMDD") : (this.localCondition.examDateEd != null ? dayjs(this.localCondition.examDateEd).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          fromDate: this.localCondition.examDateSt != null ? dayjs(this.localCondition.examDateSt).format("YYYYMMDD") : (this.localCondition.examDateEd != null ? dayjs(this.localCondition.examDateEd).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          toDate: this.localCondition.examDateEd != null ? dayjs(this.localCondition.examDateEd).format("YYYYMMDD") : (this.localCondition.examDateSt != null ? dayjs(this.localCondition.examDateSt).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe start
          //dialysisDate: dayjs(new Date()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: this.localCondition.examDateSt != null ? dayjs(this.localCondition.examDateSt).format("YYYYMMDD") : (this.localCondition.examDateEd != null ? dayjs(this.localCondition.examDateEd).format("YYYYMMDD") : dayjs(new Date()).format("YYYYMMDD")),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"01801",
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
          selectExamSetCd: this.localCondition.examSetCd,
          selectedExamSetName: this.getselectedExamSetName(this.localCondition.examSetCd),
          selectExamGraphCd: this.localCondition.examGraphCd,
          selectedExamGraphName: this.getselectedExamSetName(this.localCondition.examGraphCd),
          // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
          // add #11285 機能帳票の印刷情報対応② 高 start
          treatDate:this.getStorSimlpSearchQurey.treatDate,
          bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
          freeWord:this.getStorSimlpSearchQurey.freeWord,
          expressCondCdStr:expressCondCd,
          kurNames:kurNames,
          patGroups:patGroups,
          // add #11285 機能帳票の印刷情報対応② 高 end
        };
        EventBus.$emit("sendReportParams", params);
      }
    },
    // -----------------------------------------
    // グリッドヘッダ押下イベント
    // -----------------------------------------
    dataBound() {
      // データ形式(data_type)が1:数値のもののみクリック時イベントを発火
      let self = this;
      // モーダル表示
      $$("th[role='columnheader']", resolveRefElement(this, "examrecorddetailgrid") || this.$el).off("click").on("click", function(e) {
        const field = $$(this).data("field") || this.getAttribute("data-field");
        const column = self.findExamRecordDetailColumnByField(field);
        if (column?.isOtherFacility) {
          e.preventDefault();
          e.stopPropagation();
          return false;
        }
        e.preventDefault();
        self.onClick(e);
      });
      // ポップアップ表示
      $$("th[data-field=examItemName]", resolveRefElement(this, "examrecorddetailgrid") || this.$el).off("click");
      $$("th[data-field=normalValue]", resolveRefElement(this, "examrecorddetailgrid") || this.$el).off("click");
    },
    // グリッドクリック時
    onClickChange(event) {
      if (event.sender) {
          const selectedCell = this.getSelectedGridCellElement(event.sender);
          const isBodyCell = selectedCell?.matches?.("td") &&
            selectedCell.closest?.("tbody");
          if (!isBodyCell) {
            event.preventDefault?.();
            return;
          }

          const selectedField = this.getSelectedExamRecordField(event.sender);
          const selectedColumn = this.findExamRecordDetailColumnByField(selectedField);
          if (selectedColumn?.isOtherFacility) {
            this.clearExamRecordGridSelection();
            event.preventDefault?.();
            return;
          }
          this.setFontColor(event);
          const selRowData = getKendoGridSelectedDataItem(event.sender);
          let selRowIndex = "";
          if (!selRowData) {
            return;
          }

          if (isKendoGridSelectionInLockedContent(event.sender)) {
            // 固定列：グラフ用行選択のトグル
            selRowIndex = getKendoGridSelectedRowIndex(event.sender, { locked: true });
            if (selRowIndex == -1) {
              return;
            }
            const examItemCd = String(selRowData.examItemCd);
            const selectedIndex = this.selectItems.indexOf(examItemCd);
            if (selectedIndex >= 0) {
              this.selectItems.splice(selectedIndex, 1);
            } else if (this.selectItems.length < 5) {
              this.selectItems.push(examItemCd);
            }
            this.syncGraphSelectionHighlight();
            this.setDetailSelectItems(deepCopy(this.selectItems));
            // セル選択(k-selected)は行ハイライトと別管理のため、トグル後に解除
            this.clearExamRecordGridSelection();

          } else {
            //可変行押下のケース：
            selRowIndex = getKendoGridSelectedRowIndex(event.sender, { locked: false });
            if(selRowIndex == -1){
              return;
            }
            const field = this.getSelectedExamRecordField(event.sender);
            if (field) {
              this.setModalState(1);
              this.setExamModalDataSource({field:field,facilityCd:this.getFacilityCd,patId:this.selectedPatId,selectedPatId:this.selectedPatId,patSex:this.selectedPatSex,defaultSex:this.getExamDefaultSex}).then(() => {
                // 表示
                this.showExamRecordModal();
                // 選択解除
                this.clearExamRecordGridSelection();
              });
            }
          }
      }
    },

    /** グラフ選択行の背景を selectItems と同期（全行クリア後に再付与） */
    syncGraphSelectionHighlight() {
      const root = resolveRefElement(this, "examrecorddetailgrid");
      if (!root) {
        return;
      }
      root.querySelectorAll(".kendo-grid-style-selected").forEach(td => {
        td.classList.remove("kendo-grid-style-selected");
      });
      const gridData = getKendoGridDataItems(this.$refs.examrecorddetailgrid);
      if (!gridData?.length || !this.selectItems.length) {
        return;
      }
      const mainRows = root.querySelector(".k-grid-content table")?.tBodies?.[0]?.rows;
      const lockedRows = root.querySelector(".k-grid-content-locked table")?.tBodies?.[0]?.rows;
      const applyRowHighlight = row => {
        if (!row) {
          return;
        }
        [...row.cells].forEach(td => td?.classList?.add("kendo-grid-style-selected"));
      };
      gridData.forEach((dataRow, index) => {
        if (this.selectItems.includes(String(dataRow.examItemCd))) {
          applyRowHighlight(mainRows?.[index]);
          applyRowHighlight(lockedRows?.[index]);
        }
      });
    },
    // 画面リサイズ・dataBound 後にグラフ選択行の見た目を復元
    resizeSelectRows() {
      this.syncGraphSelectionHighlight();
    },

    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.popoverTarget = event;

      // 検索条件にstoreの情報をセット
      this.setStoredCondition();
      // 表示
      this.popoverVisible = true;
    },
    setStoredCondition() {
      const condition = this.getDetailCondition;
      this.localCondition.examDateSt = condition.examDateSt;
      this.localCondition.examDateEd = condition.examDateEd;
      this.localCondition.normalRange = condition.normalRange;
      this.localCondition.outRange = condition.outRange;
      this.localCondition.unitDisplay = condition.unitDisplay;
      this.localCondition.examSetCd = condition.examSetCd;
      // add #9465 #8368のソース巻き戻り 関 start
      this.localCondition.examGraphCd = condition.examGraphCd;
      // add #9465 #8368のソース巻き戻り 関 end
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.setDefaultCondition();
      this.dialogOk();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      // 検査日が変更された場合
      const chgFlg = (
        (this.localCondition.examDateSt != this.getDetailCondition.examDateSt)
        || (this.localCondition.examDateEd != this.getDetailCondition.examDateEd)
        || (this.localCondition.examSetCd != this.getDetailCondition.examSetCd)
        || (this.localCondition.outRange != this.getDetailCondition.outRange));

      // 抽出条件登録
      this.setDetailCondition(this.localCondition);
      this.setConditionList();

      // 検索条件の内容で画面を更新
      this.setFilterCondition(chgFlg);
      let allItem = [];
      if (this.localCondition.examGraphCd != -1) {
        this.getExamSetNameList.forEach(everySet => {
          if (everySet.examSetCd == this.localCondition.examGraphCd) {
            this.selectItems = [];
            allItem = JSON.parse(everySet.examItemInfo);
            allItem.forEach(everyItem => {
              this.selectItems.push((String)(everyItem.exam_item_cd));
            });
          }
        });
        // #8368対応時のメモ：
        // setFilterCondition の呼び出しによる検索後の状態にDOMの更新が行われた後に
        // update から resizeSelectRows が呼ばれて
        // 選択行の見た目にするCSSクラスをtBodies内の要素に設定する処理が行われるので、
        // ここではその処理は不要
        this.setDetailSelectItems(deepCopy(this.selectItems));
      }
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const wh = this.windowHeight;
      const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      const fmh =
        (this.isDispMenu === 1
          ? getFooterMenuClientHeight(this.$el || null)
          : 0) + 5;
      const buttonArea = getScopedElementById("examrecorddetailhead", this.$el || this)?.clientHeight || 0;
      this.kendoGridToolbarHeight = wh - hh - fmh - 10;
      this.kendoGridToolbarHeight =
      this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;

      this.kendoGridHeight = this.kendoGridToolbarHeight - buttonArea;
    },
    setHeaderStyle() {
      // ヘッダーにスタイル適用
      resolveRefElement(this, "examrecorddetailgrid")?.firstElementChild?.classList?.add(
        "master-grid-header");
    },
    // 抽出条件変更イベント
    setFilterCondition(chgflg) {
      // 抽出条件が変更された場合
      if (chgflg) {
        // スケジュール取得
        this.dataLoad();
      } else {
        this.filteredExamRecord();
      }
      // 選択項目のリセット
      this.selectItems = [];
      this.setDetailSelectItems(deepCopy(this.selectItems));
    },

    // 検索条件が変更されたら表示内容を更新
    filteredExamRecord() {
      // 治療日列の表示/非表示
      let colsetting = deepCopy(this.getExamRecordDetailColumn);
      colsetting[4].hidden = !this.localCondition.normalRange;
      colsetting[5].hidden = !this.localCondition.unitDisplay;
      this.setExamRecordDetailColumn(colsetting);
      this.$nextTick(() => {
        this.refreshExamRecordGrid(true);
      });
    },

    // データ更新
    setExamRecord() {
      if (this.selfScreenName === this.$route.name) {
        this.dataLoad();
      }
    },
    async dataLoad() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      const examDateOrder = this.getExamResultDispOrder === DISP_ORDER_LEFT_PAST ? "asc" : "desc";
      // 表示データ設定
      await this.setExamDetailSelectData({
        facilityCd: this.getFacilityCd,
        examDateOrder: examDateOrder,
        patientShareMode:
          this.getIsOtherFacility === false ||
          (this.getOtherFacilityCd !== null &&
            this.getOtherFacilityCd !== this.getFacilityCd)
            ? 1
            : this.getPatientShareMode,
        selectedPatId: this.selectedPatId,
      });
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
      // レコード列表示制御
      this.filteredExamRecord();
      this.$nextTick(() => {
        this.refreshExamRecordGrid(true);
      });
      if (this.firstRender) {
        this.$nextTick(() => {
          this.scrollFromRight();
        });
        this.firstRender = false;
      }

      this.$nextTick(() => {
        const gridRoot = resolveRefElement(this, "examrecorddetailgrid");
        const gridContent = findKendoGridContent(gridRoot);
        if (!gridContent) {
          return;
        }
        this.setScrollPosition = () => {
          this.scrollPosition = {
            top: gridContent.scrollTop,
            left: gridContent.scrollLeft
          };
        };
        gridContent.addEventListener("scroll", this.setScrollPosition);
      });
    },
    // 検査データの文字色を設定
    scrollFromRight() {
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      if(this.getCondition.examDate != "" && this.getCondition.examDate != null && this.getCondition.examDate != undefined){
        var scrollleftWidth = 0;
        const gridRoot = resolveRefElement(this, "examrecorddetailgrid");
        const headerWrap = findKendoGridHeaderWrap(gridRoot);
        const gridContent = findKendoGridContent(gridRoot);
        const headers = headerWrap?.getElementsByTagName("th") || [];
        for(let colIndex = 0; colIndex < headers.length; colIndex++){
          if(headers[colIndex].outerText.indexOf(this.getCondition.examDate) != -1){
            scrollleftWidth = headers[colIndex].offsetLeft;
            break;
          }
        }
        this.scrollPosition.left = scrollleftWidth;
        if (gridContent) {
          gridContent.scrollLeft = scrollleftWidth;
        }
      }
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
      // スクロール位置を最新データに合わせる
      let lastColumnId;
      if(this.getExamResultDispOrder === DISP_ORDER_LEFT_PAST){
        const numberOfColumns = this.getExamRecordGridColumns().length;
        lastColumnId = this.getExamRecordGridColumns()[numberOfColumns - 1]?.headerAttributes?.id;
      } else {
        lastColumnId = this.getExamRecordGridColumns()[6]?.headerAttributes?.id;
      }
      const lastColumnElement = getScopedElementById(lastColumnId, this.$el || this);
      if (lastColumnElement) lastColumnElement.scrollIntoView();
    },
    setFontColor(e){
      const lockrows = findKendoGridBodyRows(e.sender);
      lockrows.forEach((row) => {
        const dataItem = getKendoGridDataItem(e.sender, row);
        const dataColumns = e.sender.columns;
        // mod FNSI-Fix Bug 関 start
        // for (let i = 5; i < dataColumns.length; i++) {
        for (let i = 6; i < dataColumns.length; i++) {
        // mod FNSI-Fix Bug 関 end
          const value = dataColumns[i];
          if (dataItem[value.field+"Class"] == "H") {
            // mod FNSI-Fix Bug 関 start
            // row.children[i-2].style.color = "red";
            if(row.children[i-3]){
              row.children[i-3].style.color = "var(--kendo-grid-style-high-class-color)";
            }
            // mod FNSI-Fix Bug 関 end
          } else if (dataItem[value.field+"Class"] == "L") {
            // mod FNSI-Fix Bug 関 start
            // row.children[i-2].style.color = "blue";
            if(row.children[i-3]){
              row.children[i-3].style.color = "var(--kendo-grid-style-low-class-color)";
            }
            // mod FNSI-Fix Bug 関 end
          }
        }
      });
      // 高さの調整処理もdata-boundに連動して実施(kendo-gridのlockedオプション使用時に高さがずれる件の対応)
      this.$nextTick(() => {
        const gridRoot = resolveRefElement(this, "examrecorddetailgrid");
        const header = findKendoGridHeader(gridRoot);
        const scrolObj = findKendoGridContent(gridRoot);
        const lockedPane = findKendoGridLockedContent(gridRoot);
        if (!header || !scrolObj || !lockedPane) {
          return;
        }
        const headerHeight = header.offsetHeight + 2;
        let lockRowHeight = this.kendoGridHeight - headerHeight;
        if (!this.androidFlg && !this.iosFlg && (scrolObj.scrollWidth > scrolObj.clientWidth)) {
          lockRowHeight -= 17;
        }
        lockedPane.style.height = lockRowHeight + "px";
      });
      const gridRoot = resolveRefElement(this, "examrecorddetailgrid");
      syncKendoGridLockedContentScroll(gridRoot, { touch: true });
    },
    // グリッドクリック時
    onClick(event) {
      if ($$(event.currentTarget).data("field")) {
        this.setModalState(1);
        const field = $$(event.currentTarget).data("field")

        this.setExamModalDataSource({field:field,facilityCd:this.getFacilityCd,patId:this.selectedPatId,selectedPatId:this.selectedPatId,patSex:this.selectedPatSex,defaultSex:this.getExamDefaultSex}).then(() => {
          // 表示
          this.showExamRecordModal();
          // 選択解除
          this.clearExamRecordGridSelection();
        });
      }
    },
    // 新規作成
    createExamRecord() {
      this.setModalState(0);
      this.setExamModalDataSource({field:null,facilityCd:this.getFacilityCd,patId:this.selectedPatId,selectedPatId:this.selectedPatId,patSex:this.selectedPatSex,defaultSex:this.getExamDefaultSex}).then(() => {
        // 表示
        this.showExamRecordModal();
      });
      this.search()
    },
    // グラフ作成
    createGraph() {
      // selectItemsが空の場合はグラフ表示しない
      if (this.selectItems.length >= 0) {
        this.showExamRecordGraphModal();
      }
    },
    restoreScrollPosition(position = this.scrollPosition) {
      const gridContent = findKendoGridContent(resolveRefElement(this, "examrecorddetailgrid"));
      if (!gridContent) {
        return;
      }
      gridContent.scrollTop = position.top || 0;
      gridContent.scrollLeft = position.left || 0;
      syncKendoGridLockedContentScroll(resolveRefElement(this, "examrecorddetailgrid"), { touch: true });
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      const condObj = this.localCondition;
      const examSet = findExamSet(condObj.examSetCd, this.getExamSetNameList);
      const makeInfo = (visible, text, name) => ({ visible, listItem: { name, text } });
      const isValidDate = value => value !== "" && value != null;
      const cnvDateFmt = (value) => {
        if (isValidDate(value)) {
          return value.replace(/-/g, "/");
        } else {
          return value;
        }
      };
      this.conditionList = [
        makeInfo(isValidDate(condObj.examDateSt), cnvDateFmt(condObj.examDateSt), "検査日開始"),
        makeInfo(isValidDate(condObj.examDateEd), cnvDateFmt(condObj.examDateEd), "検査日終了"),
        makeInfo(condObj.outRange, "異常値のみ表示"),
        makeInfo(condObj.normalRange, "正常範囲列表示"),
        makeInfo(condObj.unitDisplay, "単位列表示"),
        makeInfo(examSet, examSet && examSet.examSetName, "検査セット"),
      ].reduce((condList, info) => {
        if (info.visible) {
          condList.push(info.listItem);
        }
        return condList;
      }, []);
    },
    // -----------------------------------------
    // 個人設定で登録した初期値をStoreに登録する
    // -----------------------------------------
    setDefaultCondition() {
      // 画面側初期値の登録
      const initialDefault = makeDefaultCondition();
      this.localCondition.examDateSt = initialDefault.examDateSt;
      this.localCondition.examDateEd = initialDefault.examDateEd;
      this.localCondition.outRange = initialDefault.outRange;
      this.localCondition.normalRange = initialDefault.normalRange;
      if (this.androidFlg || this.iosFlg) {
        this.localCondition.normalRange = false;
      }
      this.localCondition.unitDisplay = initialDefault.unitDisplay;
      this.localCondition.examSetCd = initialDefault.examSetCd;
      this.localCondition.examGraphCd = initialDefault.examGraphCd;
      // デフォルト設定の反映
      const defaultCondition = this.getDefaultSetting[EXAM_RECORD.KEY_NAME];
      if (defaultCondition) {
        // デフォルト設定が存在する場合は適用
        if (defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_START_DATE] != null) {
          this.localCondition.examDateSt = calcTargetDate(defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_START_DATE]);
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_END_DATE] != null) {
          this.localCondition.examDateEd = calcTargetDate(defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_END_DATE]);
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_OUT_RANGE] != null) {
          this.localCondition.outRange = defaultCondition[EXAM_RECORD.KEY_NAME_OUT_RANGE];
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_NORMAL_RANGE] != null) {
          // 正常範囲列表示はデフォルト設定があれば端末にかかわらず反映
          this.localCondition.normalRange = defaultCondition[EXAM_RECORD.KEY_NAME_NORMAL_RANGE];
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY] != null) {
          this.localCondition.unitDisplay = defaultCondition[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY];
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_SET_CD] != null) {
          this.localCondition.examSetCd = defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_SET_CD];
        }
      }
    },
    initCondition() {
      // デフォルト設定の反映
      this.setDefaultCondition();
      // 以前に保存した検索条件が存在する場合は反映する
      if (this.getDetailCondition.examDateSt != null) {
        this.localCondition.examDateSt = this.getDetailCondition.examDateSt;
      }
      if (this.getDetailCondition.examDateEd != null) {
        this.localCondition.examDateEd = this.getDetailCondition.examDateEd;
      }
      if (this.getDetailCondition.outRange != null) {
        this.localCondition.outRange = this.getDetailCondition.outRange;
      }
      if (this.getDetailCondition.normalRange != null) {
        this.localCondition.normalRange = this.getDetailCondition.normalRange;
      }
      if (this.getDetailCondition.unitDisplay != null) {
        this.localCondition.unitDisplay = this.getDetailCondition.unitDisplay;
      }
      if (this.getDetailCondition.examSetCd != null) {
        this.localCondition.examSetCd = this.getDetailCondition.examSetCd;
      }
      // 選択中の患者に関する項目を設定する
      this.localCondition.examPatId = this.selectedPatId;
      this.localCondition.examPatSex = this.selectedPatSex;

      if (this.getExamRecordDate) {
        // 9分割グラフから検査結果に遷移した場合
        this.localCondition.examDateSt = dayjs(this.getExamRecordDate).subtract(1, "months").format("YYYY-MM-DD");
        this.localCondition.examDateEd = dayjs(this.getExamRecordDate).add(1, "months").format("YYYY-MM-DD");
        this.setExamRecordDate(null);
      }

      if (this.hasParamsInResult()) {
        // 予実リストによる遷移時
        this.setConditionWithParams();
      }

      // 検索条件を保存しなおして表示に反映する
      this.setDetailCondition(this.localCondition);
      this.setConditionList();
    },
    hasParamsInResult() {
      return this.$route.params.condition && this.$route.params.condition.type === "in_result";
    },
    setConditionWithParams() {
      // 予実リストから渡された情報を表示条件に反映
      // #9329対応時の仕様メモ：
      // 選択したデータの検査日を表示条件の開始日終了日に設定する。検査セットは未指定状態にする。異常値のみ表示もOFFとする。
      this.localCondition.examDateSt
        = this.localCondition.examDateEd
        = dayjs(this.$route.params.condition.treatDate, "YYYY/MM/DD").format(DATE_FORMAT);
      this.localCondition.examSetCd = -1;
      this.localCondition.outRange = false;
    },
    triggerLoad() {
      if (this.isLoadingTriggered) return;
      this.isLoadingTriggered = true;

      this.setLoadingScreenMessage("処理中・・・");
      this.dataLoad();

      this.$nextTick(() => {
        this.isLoadingTriggered = false;
      });
    },
  },
  watch: {
    getExamRecordDetailColumn: {
      handler() {
        this.$nextTick(() => {
          this.refreshExamRecordGrid(true);
        });
      },
      deep: true
    },
    getExamDetailDataSource: {
      handler() {
        this.$nextTick(() => {
          this.refreshExamRecordGrid(true);
        });
      },
      deep: true
    },
    // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
    'localCondition.examPatId':{
      handler(newValue) {
        if(newValue == null){
          store.dispatch("report/getMstReport", {funcCd: "01802",printFlag: null, selectedPatId: this.selectedPatId});
        }else {
          store.dispatch("report/getMstReport", {funcCd: "01802",printFlag: 1, selectedPatId: this.selectedPatId});
        }
      }
  },
    // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
    windowHeight() {
      // // iosPWA時の画面幅変更時:
      // // app.vueのhandleResizeWindow実行後にcalculateGridHeightを実行するため、200ミリ秒待つ
      // const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      // if(this.iosFlg && ownerWindow.matchMedia('(display-mode: standalone)').matches){
      //   ownerWindow.setTimeout(() => {
      //     this.calculateGridHeight();
      //   }, 200);
      // }else{
      //   this.calculateGridHeight();
      // }

      //#9846 start
      // resize時はstore更新直後だとheader/footer/buttonAreaのlayoutが未確定のため、
      // nextTick + nextLayoutFrame後に計測し、Kendo Gridへも反映する
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      const runAfterLayout = () => {
        this.$nextTick(() => {
          nextLayoutFrame(this.$el || this).then(() => {
            this.calculateGridHeight();
            this.scheduleDirectGridLayoutContract();
          });
        });
      };
      // iosPWA時の画面幅変更時:
      // app.vueのhandleResizeWindow実行後にcalculateGridHeightを実行するため、200ミリ秒待つ
      if (this.iosFlg && ownerWindow.matchMedia('(display-mode: standalone)').matches) {
        ownerWindow.setTimeout(runAfterLayout, 200);
      } else {
        runAfterLayout();
      }
      //#9846 start
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      // 印刷中はスキップ
      if (this.isPrint) return;

      // 各項目の幅を自動調整する機能を呼び出すためにcolumnサイズを変更する（変更前と同じ値で呼び出す）
      const firstColumn = this.getExamRecordGridColumns()[0];
      let setWidth = parseInt(firstColumn?.width, 10);
      this.resizeExamRecordGridColumn(firstColumn, setWidth);
      this.calculateGridHeight();
      setTimeout(() => {
        this.restoreScrollPosition();
      }, 50);
    },
    sidebarWidth(){
      $$(getScopedWindow(this.$el || this)).trigger('resize');
    },
    async selectedPatId() {
      // 再表示条件：選択したpatIdがnullではなく、また今表示しているidでもない場合
      if (this.selectedPatId !== null && this.selectedPatId !== this.localCondition.examPatId) {
        this.localCondition.examPatId = this.selectedPatId;
        this.localCondition.examPatSex = this.selectedPatSex;
        // 抽出条件セット
        this.setDetailCondition(this.localCondition);
        // ここは表示対象ではない項目のみの変更のため setConditionList は不要

        // データ取得
        await this.dataLoad();
        this.$nextTick(() => {
          this.calculateGridHeight();
          // ヘッダーにスタイル適用
          this.setHeaderStyle();
        });
      }
    },
    async "$route.params.condition"() {
      if (this.hasParamsInResult()) {
        // 予実リストでの画面遷移を伴わない検査予定選択時
        this.setConditionWithParams();
        // 抽出条件セット
        this.setDetailCondition(deepCopy(this.localCondition));

        if (this.selectedPatId) {
          // データ取得
          await this.dataLoad();
          this.$nextTick(() => {
            this.calculateGridHeight();
            // ヘッダーにスタイル適用
            this.setHeaderStyle();
          });
        }
        this.setConditionList();
      }
    },
    getLoadingScreenVisible() {
      if (!this.getLoadingScreenVisible && !this.firstRender) {
        this.$nextTick(() => {
          this.restoreScrollPosition();
        });
      }
    },
    getPatientShareMode() {
      this.triggerLoad();
    },
    getOtherFacilityCd() {
      this.triggerLoad();
    }
  },
  created() {
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 start
    this.setIsOpenFlag(false);
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 end
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    EventBus.$on("filterList", this.setFilterCondition);
    EventBus.$on("detailUpdate", this.setExamRecord);
    /*add FNSI-改修内容6326 任 start*/
    EventBus.$on("flashData",this.filteredExamRecord);
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    EventBus.$on("requestReportParams", this.requestrReportParams);
    /*add FNSI-改修内容6326 任 end*/
    // 一覧ヘッダ名をリセット
    this.resetStatusDetailGridColumn();
    this.resetExamDetailDataSource();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // del #10359 編集権限の動作不正 dengshen start
    // //mod 編集権限の適用 劉全航 start
    // this.isAuthorized = this.getStateUserAccountInfo
    // .userSettings
    // .authorized_authorities
    // .includes(AUTHORITY_CODES.RST_EXAM_EDIT);
    // //mod 編集権限の適用 劉全航 end
    // del #10359 編集権限の動作不正 dengshen end
  },
  async mounted() {
    // パンくずリストのrefreshイベントをcreatedでリッスンすると検知しない
    EventBus.$on("refresh", this.setExamRecord);
   
    this.setLoadingScreenVisible(true);

    // 端末判別
    const ua = (getScopedWindow(this.$el || this)?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }

    // 初期性別未設定判定フラグセット
    if (this.getExamDefaultSex == null) {
      await this.examSelectDefaultSex({
        facilityCd: this.getFacilityCd,
        selectedPatId: this.selectedPatId
      });
    }
    if (this.getExamSetNameList == null) {
      // 検査セットデータ生成処理：
      await this.examSetNameList({
        facilityCd: this.getFacilityCd,
        selectedPatId: this.selectedPatId
      });
      // 検査セットソート順データセット処理
      await this.setSortNameList({
        facilityCd: this.getFacilityCd,
        selectedPatId: this.selectedPatId
      });
    }
    // 検査結果画面表示順設定セット
    if (this.getExamResultDispOrder == null) {
      await this.resultDispOrderSetting({
        facilityCd: this.getFacilityCd,
        selectedPatId: this.selectedPatId
      });
    }

    // 検索条件の初期設定
    this.initCondition();

    // 選択条件リセット
    this.selectItems = [];
    this.setDetailSelectItems(deepCopy(this.selectItems));
    
    // 休日マスタの休日を取得
    this.fetchHolidays(this.getFacilityCd);

    if (this.selectedPatId) {
      // データ取得:patidがある場合のみ
      this.dataLoad();
      this.$nextTick(() => {
        this.calculateGridHeight();
        // ヘッダーにスタイル適用
        this.setHeaderStyle();
      });
    }

    this.setLoadingScreenVisible(false);
  },
  updated() {
    if (this.isRouteLeaving) return;
    this.$nextTick(() => {
      // ヘッダーにスタイル適用
      this.setHeaderStyle();
      setTimeout(() => {
        this.resizeSelectRows();
        this.scheduleDirectGridLayoutContract();
      },10)
    });
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    this.clearHolidays(); // storeの休日マスタをクリア
    EventBus.$off("filterList", this.setFilterCondition);
    EventBus.$off("detailUpdate", this.setExamRecord);
    /*add FNSI-改修内容6807 劉智博 start*/
    EventBus.$off("flashData", this.filteredExamRecord);
    /*add FNSI-改修内容6807 劉智博 end*/
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // EventBus.$off("requestReportParams");
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    // EventBus.$off("refresh");
    EventBus.$off("refresh", this.setExamRecord);
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    const gridContent = findKendoGridContent(resolveRefElement(this, "examrecorddetailgrid"));
    gridContent && gridContent.removeEventListener("scroll", this.setScrollPosition);
    this.destroyDirectGrid();
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  // add 性能改善メモリ不足 shan end
};

</script>
<style>
@media print {
  /** 検査結果 tableレイアウト崩れ回避 */
  body:has(#examrecorddetailgrid) #main-id {
    display: inline-block;
  }
}
</style>
<style scoped>
.exam-record-detail-main-content :deep(.master-grid-header) {
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
.exam-record-detail-main-content :deep(th.k-first) {
  background-color: #333333;
  background-image: none;
}
.exam-record-detail-main-content :deep(th.k-first ~ th) {
  background-color: #333333;
  background-image: none;
}
.exam-record-detail-head-content {
  overflow-y: hidden;
  margin-top: 5px;
  flex: 0;
  background-color: var(--ntss-base-background-color);
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
}
.exam-record-detail-main-content {
  overflow-y: hidden;
  flex: 1;
  background-color: var(--ntss-base-background-color);
}
.exam-record-detail-footer-content {
  margin-top: 5px;
  margin-right: 5px;
  flex: 0;
  background-color: var(--ntss-base-background-color);
}
.exam-record-detail-popover :deep(.popover) {
  width: 31em;
}

/* スマホスタイル */
@media screen and (max-width: 480px) {
  .exam-detail-list {
    font-size : 10px;
    word-wrap: break-word;
    white-space: normal;
  }
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}

:deep(.k-grid th),
:deep(.k-grid td) {
    padding: 0.25rem 0.75rem !important;
    height: 2em!important;
}

/* :deep(.k-grid .k-table-th),
:deep(.k-grid .k-table-td) {
    padding: 0.25rem 0.75rem !important;
    height: 2em;
} */

:deep(.kendo-grid-style-page .k-grid-header-wrap th) {
    
    height: 2em!important;
}

:deep(.kendo-grid-style-page .k-grid tr) {
    height: 2em!important;
}

#examrecorddetailgrid :deep(.k-grid-header-wrap .k-grid-header-table tr){
  padding: 1px 3px 3px 3px;
  height: 2em!important;
}
#examrecorddetailgrid :deep(.k-grid-header-wrap .k-grid-header-table .k-table-th){
  border-color:#fff;
}
#examrecorddetailgrid :deep(.k-grid .k-header .k-link) {
  white-space: normal !important;
  overflow: visible !important;
  text-overflow: unset !important;
}

#examrecorddetailgrid :deep(.k-grid .k-column-title) {
  white-space: normal !important;
  display: inline-block;
}

:deep(.k-grid-header){
  background-image: linear-gradient(hsla(0, 0%, 100%, .3), transparent 50%, transparent 0, rgba(0, 0, 0, .1));
  background-color: var(--ntss-list-header-background-color);
}
:deep(.k-grid-header-wrap){
  border-right:1px solid #fff;
}
:deep(.k-grid-header-locked .k-grid-header-table){
  height:stretch;
}
:deep(.k-grid .k-grid-content-locked ){
  border-color: rgba(33, 37, 41, .125)!important;
}
#examrecorddetailgrid :deep(.k-grid-content ){
  background-color: transparent!important;
}

/* セル選択(k-selected)時は見た目を変えない（グラフ行選択 .kendo-grid-style-selected のみハイライト） */
#examrecorddetailgrid :deep(td.k-selected:not(.kendo-grid-style-selected)),
#examrecorddetailgrid :deep(td.k-state-selected:not(.kendo-grid-style-selected)),
#examrecorddetailgrid :deep(.k-table-td.k-selected:not(.kendo-grid-style-selected)),
#examrecorddetailgrid :deep(.k-table-td.k-state-selected:not(.kendo-grid-style-selected)),
#examrecorddetailgrid :deep(tr.k-selected > td:not(.kendo-grid-style-selected)),
#examrecorddetailgrid :deep(tr.k-state-selected > td:not(.kendo-grid-style-selected)),
#examrecorddetailgrid :deep(.k-table-row.k-selected > .k-table-td:not(.kendo-grid-style-selected)),
#examrecorddetailgrid :deep(.k-table-row.k-state-selected > .k-table-td:not(.kendo-grid-style-selected)) {
  /* background-color: unset !important;
  background-image: none !important; */
  box-shadow: none !important;
  outline: none !important;
  /* !important なし — 基準値外(H/L)の inline color を優先 */
  color: inherit;
}

#examrecorddetailgrid :deep(td.kendo-grid-style-selected),
#examrecorddetailgrid :deep(.k-table-td.kendo-grid-style-selected) {
  background-color: var(--master-maintenance-kgrid-selected-background-color) !important;
}

#examrecorddetailgrid :deep(th.k-header:has(.other-facility-header)),
#examrecorddetailgrid :deep(th.other-facility-header) {
  pointer-events: none;
  color: #999;
}

#examrecorddetailgrid :deep(.k-grid-content td.other-facility-cell) {
  pointer-events: none;
  background-color: #0000001a !important;
  color: #999 !important;
}

#examrecorddetailgrid :deep(.k-grid-content tr.k-alt td.other-facility-cell) {
  background-color: #ccc !important;
}


/* Vue2 Kendo locked layout contract.
   Kendo 2026 renders locked content inside flex containers; keep the locked area
   at the width Kendo/column definitions already calculated, as Kendo 2019 did. */
:deep(.k-grid-lockedcolumns .k-grid-header-locked),
:deep(.k-grid-lockedcolumns .k-grid-content-locked),
:deep(.k-grid-lockedcolumns .k-grid-footer-locked) {
  flex: 0 0 auto;
  flex-shrink: 0;
}


@media print {  
  /** スクロールコンテナ */
  .exam-record-detail-main-content :deep(.k-grid-header-wrap),
  .exam-record-detail-main-content :deep(.k-grid-content){
    overflow: hidden !important;
    height: auto !important;
  }
  
  /** 固定列調整 */
  .exam-record-detail-main-content :deep(.k-grid-content-locked){
    height: auto !important;
  }
  /** 固定列枠線 */
  .exam-record-detail-main-content :deep(.k-grid-header-locked::after){
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-header-background-color);
    pointer-events: none;
  }
  .exam-record-detail-main-content :deep(.k-grid-content-locked::after){
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-border-color);
    pointer-events: none;
  }
  /** ヘッダのズレ原因を除去 */
  .exam-record-detail-main-content :deep(.k-grid-header){
    padding-right: 0 !important;
  }
  /** gridの幅 */
  .exam-record-detail-main-content :deep(.k-grid){
    width: 100vw;
    height: auto !important;
  }
  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  /* 右端時固定列最前面表示*/
  .exam-record-detail-main-content:has(table.scroll-rightmost) :deep(.k-grid-content-locked),
  .exam-record-detail-main-content:has(table.scroll-rightmost) :deep(.k-grid-header-locked){
    z-index: 1;
  }
  .main-content-area:has(table.scroll-rightmost) {
    margin-left: -1px !important;
  }
  .exam-record-detail-main-content :deep(.k-grid-header-wrap:has(table.scroll-rightmost)),
  .exam-record-detail-main-content :deep(.k-grid-content:has(table.scroll-rightmost)){
    position: static;
  }
}

</style>
