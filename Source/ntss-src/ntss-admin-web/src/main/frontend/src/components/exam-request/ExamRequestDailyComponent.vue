/**
 * 検査依頼一覧（一日）メイン
 */
<template>
  <div class="main-content-area">
    <!-- 上部 表示切替/検査予定日指定エリア -->
    <div id="upper-buttons">
      <div class="ntss-button-group">
        <input id="show-period-display" type="radio" class="identification" name="periodType" :value="1" v-model="periodType" />
        <label for="show-period-display" class="label first-of-type">期間</label>
        <input id="show-day-display" type="radio" class="identification" name="periodType" :value="2" v-model="periodType" />
        <label for="show-day-display" class="label last-of-type">一日</label>
      </div>
      <label class="upper-buttons-label examrequest-label" style="width: 5em;">検査予定日</label>
      <date-input
        class="examrequest-input-display-period start ntss-input-date"
        id="scheduledDate"
        name="scheduledDate"
        max="2099-12-31"
        v-model="scheduledDate"
        @blur="checkInputStartDate"
        data-validation-scope="condition"
        isRequired
      />
      <common-calendar
        v-model="scheduledDate"
        :disableDatesAfter="disableDatesAfter"
        @update:model-value="checkInputStartDate"
        @blur="checkInputStartDate"
        @todayButtonClick="checkInputStartDate"
      />
    </div>
    <!-- 一覧エリア -->
    <div class="scroll-table" :style="gridHeightStyle">
      <table class="grid-record-list">
        <thead>
          <tr>
            <th :class="getHospPatIdHeaderClass" :style="gridHeaderInner" v-show="isShowHospPatId">
              <span @click="showPopover($event, 'hosp_pat_id')">患者ID</span>
            </th>
            <th :class="[...getPatNameHeaderClass, 'col-sticky-names']" :style="getPatNameHeaderStyle">
              <span @click="showPopover($event, 'pat_name')">患者名</span>
            </th>
            <th :class="getBloodGlucoseHeaderClass" :style="getBloodGlucoseHeaderStyle" v-show="isShowBloodGlucoseExam">
              <span @click="showPopover($event, 'is_blood_suger_exam')">血糖検査</span>
            </th>
            <!-- 検査セットヘッダ -->
            <template v-for="(set, index) in examSetHeaderList" :key="`examset-${index}`">
              <th

                class="ntss-list-header-th-sticky manual-width"
                :style="{ width: '10rem' }"
                :class="sortedClass('exam_set', set)"
              >
                <span @click="showPopover($event, 'exam_set', index, set)">{{ showDelExam(set.examSetCd) + set.examSetName}}</span>
              </th>
            </template>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(listDate, index) in sortedList" :key="index">
            <!-- 患者ID行 -->
            <td :class="hospPatIdCellClass" v-show="getIsShowHospPatId">
              <label>{{ getHospPatId(listDate.patId) }}</label>
            </td>
            <!-- 患者名行 -->
            <td :class="[...patNameCellBaseClass, listDate.i_class, 'col-sticky-names']" :style="patNameLeftStyle" @click="showDetailPage(listDate.patId)">
              {{ getPatName(listDate.patId) }}
              <img :src="image_src_same" class="pat-name-same-icon" :style="listDate.img_display">
            </td>
            <!-- 血糖検査行 -->
            <td :class="bloodGlucoseCellClass" :style="bloodGlucoseLeftStyle" v-show="getIsShowBloodGlucoseExam">
              <img :src="publicAssetPath('img/exam-request/32-32_1b.png')" class="maru-symbol" v-if="getBloodGlucoseExam(listDate.patId)"/>
            </td>
            <!-- 各検査セット毎の行 -->
            <td
              v-for="(set, index) in examSetHeaderList"
              :key="`examset-${index}`"
              :class="['examrequest-label exam-control-cell', ...addEditedColorClass(listDate.patId, set.examSetCd, set.regOrderClass)]"
              @click="editSchedule(listDate, set)"
              style="position: relative;"
            >
              <img v-bind="getImgAttributesForPattern(listDate, set)" />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <!-- 下部 キャンセルボタン/指示者選択/保存ボタン エリア -->
    <div id="bottom-buttons">
      <v-ons-button class="btn2-cancel common-style-ok-button" style="margin: 0 auto 0 0;" @click="cancel" :disabled="!getExamAuthorized()">
        キャンセル
      </v-ons-button>
      <div class="bottom-buttons-div">
        <label class="bottom-buttons-label examrequest-label">指示者</label>
        <kendo-dropdownlist
          v-model="selectDoctor"
          :data-source="doctorList"
          :data-text-field="'fullName'"
          :data-value-field="'user_id'"
          @open="dropToContent"
          style="width: 11.4em; height: 2em; margin-right: 5px;"
          :disabled="!getExamAuthorized()"
          class="input-style-required"
        />
        <v-ons-button class="btn1-execute common-style-ok-button" @click="saveRecord" :disabled="!isChanged || !getExamAuthorized()">
          保存
        </v-ons-button>
      </div>
    </div>
    <!-- ヘッダクリック ポップアップ -->
    <v-ons-popover
      cancelable
      v-model:visible="popoverHeader.popoverVisible"
      :target="popoverHeader.popoverTarget"
      direction="down"
      :class="[fontSizeSet, 'exam-request-daily-header-popover']"
    >
      <div class="popover-content-div">
        <!-- 患者ID/血糖検査ヘッダ：表示/非表示処理 -->
        <div v-show="popoverHeader.field !== 'exam_set'" style="padding: 1em;">
          <div class="d-flex align-items-center header-columns">
            <label for="isShowHospPatId">患者ID</label>
            <v-ons-switch
              input-id="isShowHospPatId"
              v-model="isShowHospPatId"
              @change="popoverHeader.popoverVisible = false"
            />
          </div>
          <div class="d-flex align-items-center">
            <label for="isShowHospPatId">血糖検査</label>
            <v-ons-switch
              input-id="isShowBloodGlucoseExam"
              v-model="isShowBloodGlucoseExam"
              @change="popoverHeader.popoverVisible = false"
            />
          </div>
        </div>
        <!-- 検査セットヘッダ：[一括登録/中止]処理 -->
        <div>
          <!-- 一括登録ボタン -->
          <v-ons-row v-show="popoverHeader.field === 'exam_set'" class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button
                class="btn1-execute button"
                :disabled="!getExamAuthorized()"
                @click="popoverHeader.popoverVisible = false; colListRegister(popoverHeader.examSetCell.data)"
              >
                一括登録
              </v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <!-- 一括中止ボタン -->
          <v-ons-row v-show="popoverHeader.field === 'exam_set'" class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button
                class="btn1-execute button"
                :disabled="!getExamAuthorized()"
                @click="popoverHeader.popoverVisible = false; colListCancel(popoverHeader.examSetCell.data)"
              >
                一括中止
              </v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <!-- 共通：ソートボタン -->
          <v-ons-row class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button
                class="btn3-normal button"
                @click="popoverHeader.popoverVisible = false; sortBy(popoverHeader.field, popoverHeader.examSetCell.data)"
              >
                ソート
              </v-ons-button>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
    </v-ons-popover>
    <!-- NOTE : [スケジュール延長処理中] ダイアログ表示 -->
    <div v-if="messageDialogInfo.isDialogVisible">
      <message-dialog
        v-model:visible="messageDialogInfo.isDialogVisible"
        :message-cd="messageDialogInfo.messageCd"
        :type="messageDialogInfo.type"
        :string-params="messageDialogInfo.stringParams"
        :title="messageDialogInfo.title"
        @confirm="confirmResult"
      />
    </div>
  </div>
</template>

<script>
import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { publicAssetPath } from "@/compat/assets/public-path";

import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { EventBus } from "@/compat/vue/event-bus.js";
import { sendRequestAllExamSetListByFacility } from "@/apis/exam-request";
import DateInput from "@/components/common/DateInput";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PopoverMixin from "@/components/PopoverMixin";
import PrintMixin from "@/components/PrintMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { EXAM_REQUEST } from "@/constants/defaultSettingConstants";
import {
  ADD,
  ADD_WARNING,
  CANCEL,
  FILLCOLOR_DEFAULT,
  FILLCOLOR_HAS_SCHEDULE,
  FILLCOLOR_HAS_NOT_SCHEDULE,
  SAVED
} from "@/constants/examRequestConstants";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import { messageFormat } from "@/functions/common/MessageFormat";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import {
  validateSelectDoctor,
  confirmCheckResult,
  executeUploadTemplete,
  getExamAuthorized,
  checkExamAuthorized,
  confirmIsOk,
  getDefaultSchExtEndDate,
  hasScheduleOnTargetDate,
  selectOrCreateExamRecord,
  getSchExtEndDateWithPatMainList,
  addLabelInfo,
  LockFlag,
  Operation,
  ExamSetClass,
  DeleteFlag,
  toCalDate,
  toSlashDate,
  toKeyDate,
} from "@/functions/exam-request/ExamRequestFunctions";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils"
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import nameDuplicationImg from "../../assets/name_duplication.png";
import { setKendoPopupSurfaceStyles } from "@/functions/common/KendoFunctions";
import { queryScopedSelector, queryScopedSelectorAll, getClosestMainContentAreaElement, getMainContentAreaElement, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

export default {
  mixins: [NextTransitionMixin, IndUserSelectMixin, PopoverMixin, PrintMixin],
  components: {
    "message-dialog": messageDialog,
    "common-calendar": commonCalender,
    "date-input": DateInput,
  },
  props: {
    controller: null,
    historyKey: null
  },
  data() {
    return {
      gridHeight: 740,
      headerHeight: 31,
      image_src_same: nameDuplicationImg, // 同姓同名アイコン
      resizeObservers: [],
      headerLeftPositions: [],
      scheduledDate: "", // 検査予定日
      // ソート条件
      sort: {
        key: "",
        isAsc: true
      },
      // 前回ソート条件
      prevSort: {
        key: "",
        isAsc: true
      },
      delExamSetCdList: [], // 【削除済み】の検査セットCDリスト
      allExamSetList: [], // 施設に紐づくすべての検査セット情報リスト
      editedCellMap: {}, // 編集されたセルの記録用
      searchedPatListClone: [], // 患者リストのクローン
      patStatusMap: [], // 患者毎の入外区分＋同姓同名の状態リスト
      localExamReqList: [], // 編集用ローカルデータ
      originalExamReqList: [], // 初期表示値（変更判定用）
      sortedList: [], // 画面表示用のリスト
      selectDoctor: null, // 選択中の指示者
      doctorList: [],
      isAndroid: false,
      isIOS: false,
      // ポップオーバー設定
      popoverHeader: {
        popoverVisible: false,
        popoverTarget: null,
        field : "", // クリックされたfield
        examSetCell: { index: 0, data: {} } // 検査セット列のデータ
      },
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: "1",
        stringParams: [""]
      },
      scrollQuerySelector: ".scroll-table",
      addClassTargetQuerySelector: ["table.grid-record-list"],
    };
  },
  /****************************************************************************/
  // computed
  /****************************************************************************/
  computed: {
    ...mapGetters("account-edit", ["getFontSize", "getDefaultSetting"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getSplittedWidth"
    }),
    ...mapGetters("exam-request/list", [
      "isStoredShowDate",
      "getIsShowHospPatId",
      "getIsShowBloodGlucoseExam",
      "getDeadlineCondition",
      "patMainList",
      "getSchExtEndDate",
      "getStartToEndDate",
    ]),
    ...mapGetters("exam-request/daily", [
      "getPeriodType",
      "getCondition",
      "getOrgPatExamMains",
      "getFilteredExamSetList",
      "getSimplifiedExamList",
      "getMstExamSetList",
    ]),
    /** グリッドの高さをCSS変数を利用して書き換える */
    gridHeightStyle() {
      return { "--height": `${this.gridHeight}px` };
    },
    /** テーブルヘッダー内部のCSS */
    gridHeaderInner() {
      const headerHeight = this.headerHeight - 9;
      return {
        top: '0px',
        zIndex: 2,
        height: `${headerHeight}px`
      };
    },
    /** 患者IDヘッダーのクラス */
    getHospPatIdHeaderClass() {
      return [
        'ntss-list-header-th-sticky',
        'col-sticky-id',
        'manual-width',
        this.sortedClass('hosp_pat_id')
      ];
    },
    /** 患者名列（共通）スタイル */
    patNameLeftStyle() {
      return {
        left: this.isShowHospPatId ? '110px' : '0px'
      };
    },
    /**  患者名ヘッダーのクラス */
    getPatNameHeaderClass() {
      return [
        'ntss-list-header-th-sticky',
        'manual-width',
        !this.isShowHospPatId ? 'col-sticky-id' : 'col-sticky-name',
        this.sortedClass('pat_name')
      ];
    },
    /**  患者名ヘッダーのスタイル */
    getPatNameHeaderStyle() {
      return {
        ...this.gridHeaderInner,
        ...this.patNameLeftStyle
      };
    },
    /** 血糖検査ヘッダーのクラス */
    getBloodGlucoseHeaderClass() {
      return [
        'ntss-list-header-th-sticky',
        'manual-width',
        !this.isShowHospPatId ? 'col-sticky-blood-glucose-exams' : 'col-sticky-blood-glucose-exam',
        this.sortedClass('is_blood_suger_exam')
      ];
    },
    /** 血糖検査ヘッダーのスタイル */
    getBloodGlucoseHeaderStyle() {
      return {
        ...this.gridHeaderInner,
        ...this.bloodGlucoseLeftStyle
      };
    },
    /** 血糖検査列（共通）スタイル */
    bloodGlucoseLeftStyle() {
      const patNameWidth = 118; // CSSで定義されている患者名列の幅
      const hospIdWidth = this.isShowHospPatId ? 110 : 0;
      const totalLeft = hospIdWidth + patNameWidth;
      return {
        left: `${totalLeft}px`
      };
    },
    /** 患者IDセルのクラス */
    hospPatIdCellClass() {
      return [
        'ntss-list-header-th-sticky',
        'col-sticky-id',
        'hosp-pat-id-body',
        'col-check-header',
        this.isAndroid ? 'col-sticky-name-android' : ''
      ];
    },
    /** 患者名セルのクラス */
    patNameCellBaseClass() {
      return [
        'ntss-list-header-th-sticky',
        this.isAndroid ? 'col-sticky-name-android' : '',
        !this.isShowHospPatId ? 'col-sticky-id' : 'col-sticky-name'
      ];
    },
    /** 血糖検査セルのクラス */
    bloodGlucoseCellClass() {
      return [
        'ntss-list-header-th-sticky',
        'col-check-header',
        this.isAndroid ? 'col-sticky-name-android' : '',
        !this.isShowHospPatId ? 'col-sticky-blood-glucose-exams' : 'col-sticky-blood-glucose-exam'
      ];
    },
    /** [期間/一日]切替区分 */
    periodType: {
      get() {
        return this.getPeriodType;
      },
      set(value) {
        this.setPeriodType(value);
      },
    },
    /** 指定日からの日付を無効 */
    disableDatesAfter() {
      return toKeyDate(this.getSchExtEndDate || getDefaultSchExtEndDate());
    },
    /** 患者ID表示有無のフラグ */
    isShowHospPatId: {
      get: function() {
        return this.getIsShowHospPatId;
      },
      set: function(value) {
        this.setIsShowHospPatId(value);
      }
    },
    /** 血糖検査表示有無のフラグ */
    isShowBloodGlucoseExam: {
      get: function() {
        return this.getIsShowBloodGlucoseExam;
      },
      set: function(value) {
        this.setIsShowBloodGlucoseExam(value);
      }
    },
    /** ヘッダ項目の検査セット名取得 */
    examSetHeaderList() {
      return this.getFilteredExamSetList;
    },
    /** 患者情報×検査依頼データ（NOTE : 指定日に存在しない場合、空の配列） */
    examReqListInDisplayDaily() {
      const simplifiedExamList = _.cloneDeep(this.getSimplifiedExamList);
      simplifiedExamList.forEach(examRequest => {
        const pat = this.patStatusMap[examRequest.patId];
        if (pat == null) return;
        examRequest.i_class = pat.in_out_class == 1 ? "pat-name-in-hospital" : ""; // NOTE: 入外区分が「入院」
        examRequest.img_display = pat.is_same == 1 ? "" : "display: none;"; // NOTE: 同姓同名
        // ソートに必要な項目をセット
        const searchPat = this.searchedPatListClone.find(item => item.pat_id === examRequest.patId);
        examRequest.hosp_pat_id = searchPat.hosp_pat_id;
        examRequest.pat_name_sort = searchPat.pat_name_sort;
        examRequest.is_blood_suger_exam = searchPat.is_blood_suger_exam;
      });
      return simplifiedExamList;
    },
    /** 変更フラグ */
    isChanged() {
      // 編集可能な権限があるかどうかを判断する
      if (!this.getExamAuthorized()) return false;
      return !_.isEqual(this.localExamReqList, this.originalExamReqList);
    },
    // 画面印刷時、content-containerに倍率調整用のscroll-adjustzoomクラスを付与するかのフラグ ※PrintMixin.jsのcomputedを上書き
    adjustZoom() {
      // 倍率調整実施
      return true;
    },
  },
  /****************************************************************************/
  // watch
  /****************************************************************************/
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    windowWidth() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    /** 患者ID列の表示/非表示監視 */
    isShowHospPatId() {
      this.$nextTick(() => {
        // 列幅の再計算
        this.updateLeftPosition();
      });
    },
    /** 血糖検査列の表示/非表示監視 */
    isShowBloodGlucoseExam() {
      this.$nextTick(() => {
        // 列幅の再計算
        this.updateLeftPosition();
      });
    },
    /** 患者検索リストに表示されている患者 */
    async searchedPatList() {
      this.searchedPatListClone = _.cloneDeep(this.searchedPatList);
      this.fetchAndRenderExamRequests();
      if (this.searchedPatListClone.length) {
        this.initPatScheduleContext();
      }
    },
    /** ヘッダの検索条件 */
    getCondition: {
      handler(newVal, oldVal) {
        if (oldVal && newVal.scheduledDate !== oldVal.scheduledDate) {
          this.scheduledDate = toCalDate(newVal.scheduledDate);
        }
        this.refresh();
        this.updateLeftPosition();
      },
      deep: true
    },
    isChanged() {
      this.setIsDataChanged(this.isChanged);
    },
    /** ソート条件更新 */
    sort: {
      handler(newVal) {
        if (newVal.key !== this.prevSort.key || newVal.isAsc !== this.prevSort.isAsc) {
          this.generateSortedList();
          this.prevSort = { ...newVal };
        }
      },
      deep: true
    },
    "messageDialogInfo.isDialogVisible"(isShow) {
      this.isUpdating = isShow ? false : this.isUpdating;
    },
  },
  /****************************************************************************/
  // methods
  /****************************************************************************/
  methods: {
    publicAssetPath,
    // 共通ローダー設定
    ...mapActions("loading-screen", ["startLoadingScreen", "finishLoadingScreen", "executeWithLoadingScreen"]),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("exam-request/list", [
      "setExamDeadline",
      "setShowDetailsDisplay",
      "setIsShowHospPatId",
      "setIsShowBloodGlucoseExam",
      "updateStartToEndDate",
      "setSelectedPatId",
      "getPatMainList",
      "getMinSchExtEndDate",
      "updateRecordListJournal",
      "setAllExamSetList",
      "setCalendarCheckedDate",
    ]),
    ...mapActions("exam-request/daily", [
      "clearExamRequestDaily",
      "setMstExamSetList",
      "searchExamRequestDaily",
      "setPeriodType",
      "setCondition",
      "setIsDataChanged",
    ]),
    getExamAuthorized,

    getExamRequestDocument() {
      return this.$el?.ownerDocument || document;
    },
    getExamRequestScopeRoot() {
      return this.$el || null;
    },
    getExamRequestSearchRoots() {
      return [this.getExamRequestScopeRoot(), this.getExamRequestMainContainer()].filter(Boolean);
    },
    getExamRequestScopedElement(selector, roots = this.getExamRequestSearchRoots()) {
      for (const root of roots) {
        const directElement = root?.querySelector?.(selector);
        if (directElement) {
          return directElement;
        }
        const scopedElement = queryScopedSelector(selector, root);
        if (scopedElement) {
          return scopedElement;
        }
      }
      return null;
    },
    getExamRequestTableScopeRoot() {
      return this.getExamRequestScopedElement('.scroll-table') || this.getExamRequestScopeRoot() || this.getExamRequestMainContainer() || null;
    },
    getUpperButtonsElement() {
      return this.getExamRequestScopedElement('#upper-buttons') || this.getExamRequestDocument().getElementById('upper-buttons') || null;
    },
    getBottomButtonsElement() {
      return this.getExamRequestScopedElement('#bottom-buttons') || this.getExamRequestDocument().getElementById('bottom-buttons') || null;
    },
    getGridRecordListElement() {
      return this.getExamRequestScopedElement('.grid-record-list', [this.getExamRequestTableScopeRoot(), ...this.getExamRequestSearchRoots()].filter(Boolean)) || this.getExamRequestDocument().getElementsByClassName('grid-record-list')[0] || null;
    },
    getStickyElement(selector) {
      const tableScope = this.getExamRequestTableScopeRoot();
      return this.getExamRequestScopedElement(selector, [tableScope, this.getGridRecordListElement(), ...this.getExamRequestSearchRoots()].filter(Boolean)) || this.getExamRequestDocument().querySelector(selector) || null;
    },
    getExamRequestMainContainer() {
      return this.$el?.closest?.('#main-id')
        || queryScopedSelector('#main-id', this.getExamRequestScopeRoot())
        || getClosestMainContentAreaElement(this.$el)
        || getMainContentAreaElement(this.$el)
        || this.getExamRequestScopeRoot();
    },
    /** ウインドウ変更時の高さ補正 */
    calculateGridHeight() {
      const scopeRoot = this.getExamRequestScopeRoot();
      // 表示期間などの表示領域
      const upperButtons = this.getUpperButtonsElement();
      const upBtnsHeight = Number(upperButtons?.offsetHeight || 0);
      // 下部ボタンの表示領域
      const bottomButtons = this.getBottomButtonsElement();
      const btmBtnsHeight = Number(bottomButtons?.offsetHeight || 0);
      // 表示期間、表、下部ボタン全体の表示領域
      const mainContainer = this.getExamRequestMainContainer();
      const mainIdHeight = Number(mainContainer?.offsetHeight || 0);
      // 表エリアの高さ (15px引く)
      this.gridHeight = Math.max(mainIdHeight - upBtnsHeight - btmBtnsHeight - 15, 0);
      // テーブルヘッダの高さ算出
      const tableHtml = this.getGridRecordListElement();
      if (tableHtml?.firstElementChild) {
        // テーブルのHTMLが存在する場合
        this.headerHeight = tableHtml.firstElementChild.offsetHeight;
      }
    },
    /** 院内の患者IDを取得する */
    getHospPatId(patId) {
      const pat = this.searchedPatListClone.find(p => p.pat_id === patId);
      return pat ? pat.hosp_pat_id : "";
    },
    /** 患者名取得 */
    getPatName(patId) {
      const obj = this.searchedPatListClone.find(item => item.pat_id == patId);
      if (!obj) return "";
      const { pat_last_name = "", pat_first_name = "" } = obj;
      return `${pat_last_name} ${pat_first_name}`;
    },
    /** 【削除済み】のプレフィックス付与処理 */
    showDelExam(cd) {
      const setCd = Number(cd);
      return this.delExamSetCdList.includes(setCd) ? MASTER_DELETE_DISPLAY.DELETED : "";
    },
    /** 血糖検査の有無取得 */
    getBloodGlucoseExam(patId) {
      const pat = this.patMainList.find(p => p.patId === patId);
      return pat ? pat.isBloodGlucoseExam : false;
    },
    /** 検査予定日 : フォーカスアウト時のチェック処理 */
    checkInputStartDate() {
      const inputDate = this.scheduledDate ? dayjs(this.scheduledDate) : "";
      if (inputDate && (!inputDate.isValid() || inputDate.isAfter(this.getSchExtEndDate))) {
        // 入力された日付が存在しないか、最大値より未来の場合、最大値を表示する
        this.scheduledDate = this.getSchExtEndDate;
      }
      const newDate = toKeyDate(this.scheduledDate);
      // Vue3 カレンダー選択直後にも update:model-value で本処理が呼ばれる。続くトリガーの blur と二重になるのを避ける。
      const cond = this.getCondition;
      const condDateKey =
        cond && cond.scheduledDate != null && cond.scheduledDate !== ""
          ? toKeyDate(cond.scheduledDate)
          : "";
      if (newDate && condDateKey && newDate === condDateKey) {
        return;
      }
      // 表示期間・開始日を更新
      this.updateStartToEndDate({
        showStartDate: newDate,
        showEndDate: this.getStartToEndDate.showEndDate, // NOTE: 変更していないが部品側に合わせて設定する
      });
      // ヘッダの検索条件を更新
      const newCondition = { ...this.getCondition, scheduledDate: newDate };
      this.setCondition(_.cloneDeep(newCondition));
    },
    /** 昇順/降順のclassを作成 */
    sortedClass(field, data) {
      const key = field === "exam_set" ? this.generateSortKey(data) : field;
      return getSortedClass(key, this.sort);
    },
    /** ソートキー設定 */
    sortBy(field, data) {
      const key = field === "exam_set" ? this.generateSortKey(data) : field;
      updateSort(key, this.sort);
    },
    /** 検査セットヘッダのソートキー生成 */
    generateSortKey(data) {
      const { examSetCd, regOrderClass } = data || {};
      return `exam_set-${examSetCd ?? ""}-${regOrderClass ?? ""}`;
    },
    /** 検査依頼データの取得と表示リストの生成 */
    fetchAndRenderExamRequests() {
      // 共通ローダー:表示開始
      this.startLoadingScreen();

      // scheduledDate が空なら呼ばない
      if (!this.scheduledDate) {
        this.finishLoadingScreen();
        return;
      }

      const patIdList = [];
      if (this.searchedPatListClone.length) {
        // 患者検索で表示されている患者のIDリストを取得
        patIdList.push(...this.searchedPatListClone.map(element => element.pat_id));
      }

      // 治療パターンの取得
      this.searchExamRequestDaily({
        patIdList,
        startDate: toSlashDate(this.scheduledDate),
        endDate: toSlashDate(dayjs(this.scheduledDate).add(1, 'days')),
      }).then(() => {
        const _examReqListInDisplayDaily = this.examReqListInDisplayDaily;
        this.localExamReqList = _.cloneDeep(_examReqListInDisplayDaily);
        this.originalExamReqList = _.cloneDeep(_examReqListInDisplayDaily);
        // 編集済みセルの記録を初期化
        this.editedCellMap = {};
        // 表示リスト生成
        this.generateSortedList();
        // 共通ローダー:表示終了
        this.finishLoadingScreen();
      }).catch(error => {
        getErrorMessage("ExamRequestDailyComponent.vue", "fetchAndRenderExamRequests", error);
        // 共通ローダー:表示終了
        this.finishLoadingScreen();
        if (error.response.status === 400) {
          this.$ons.notification.alert({
            // title: "取得失敗",
            title: DIALOG_MESSAGES["00300017"].title,
            message: error.response.data.errorMessage
          });
        }
      });
    },
    /** 患者のスケジュール関連情報を初期化 */
    async initPatScheduleContext() {
      // クローンされた患者リストからIDを取得
      const patIdList = this.searchedPatListClone.map(item => item.pat_id);
      // 患者基本情報（入外区分など）を取得
      this.getPatMainList(patIdList);
      // スケジュール延長最終日を取得
      await this.getMinSchExtEndDate({
        facilityCd: this.getFacilityCd,
        patIdList,
      }).catch(error => {
        getErrorMessage("ExamRequestDailyComponent.vue", "initPatScheduleContext", error);
        throw error;
      });
    },
    /** 表示データ生成 */
    generateSortedList() {
      const list = _.cloneDeep(this.localExamReqList);
      const sortKey = this.sort.key;
      const isAsc = this.sort.isAsc;

      if (!sortKey) {
        this.sortedList = list;
        return;
      }

      // 「exam_set-<examSetCd>-<regOrderClass>」形式のキー
      if (sortKey.startsWith("exam_set-")) {
        const [, examSetCd, regOrderClass] = sortKey.split("-");
        this.sortedList = list.sort((a, b) => {
          const hasA = a.examSets?.some(es =>
            String(es.examSetCd) === String(examSetCd) &&
            String(es.regOrderClass) === String(regOrderClass));
          const hasB = b.examSets?.some(es =>
            String(es.examSetCd) === String(examSetCd) &&
            String(es.regOrderClass) === String(regOrderClass));

          // 存在している方を「小さい」とみなす（昇順で先に表示）
          return sortableCompare(
            { exists: hasA ? 0 : 1 },
            { exists: hasB ? 0 : 1 },
            "exists",
            isAsc,
            {
              notUseSortKeyMap: true,
              orderAsNumberFields: ["exists"]
            });
        });
        return;
      }

      // 共通項目（患者ID・名前・血糖検査）など
      this.sortedList = list.sort((a, b) =>
        sortableCompare(a, b, sortKey, isAsc, {
          reverseFields: ["is_blood_suger_exam"],
          nullOrderRule: { [sortKey]: "normal" }
        }));
    },
    /** 患者に紐づく検査セットの状態表示処理 */
    getImgAttributesForPattern(celObj, setData) {
      const matchedExamSet = celObj.examSets.find(es =>
        String(es.examSetCd) === String(setData.examSetCd) &&
        es.regOrderClass === setData.regOrderClass);
      if (!matchedExamSet) return;

      const { reqKbn, examStatus, hasTreatment, isLock } = matchedExamSet;
      const isLocked = examStatus === "1" || isLock === "1";

      // 依頼変更可否に応じて、予定の有無で背景色を切り替える関数
      const getStyleColor = (hasTreatment, isLocked) => {
        if (!isLocked) return FILLCOLOR_DEFAULT;
        return hasTreatment ? `${FILLCOLOR_HAS_SCHEDULE}!important` : `${FILLCOLOR_HAS_NOT_SCHEDULE}!important`;
      };

      // 状態ごとの画像パスとクラスを定義
      const statusMap = {
        [CANCEL]: {
          src: hasTreatment ? publicAssetPath("img/exam-request/32-32_0.png") : publicAssetPath("img/exam-request/32-32_4.png"),
          class: "symbol-request-cancel td-img",
          style: ""
        },
        [SAVED]: {
          src: hasTreatment ? publicAssetPath("img/exam-request/32-32_2.png") : publicAssetPath("img/exam-request/32-32_3.png"),
          class: "symbol-request-saved td-img",
          style: `background-color: ${getStyleColor(hasTreatment, isLocked)};`
        },
        [ADD]: {
          src: publicAssetPath("img/exam-request/32-32_2.png"),
          class: "symbol-request-unsaved td-img",
          style: `background-color: ${getStyleColor(hasTreatment, isLocked)};`
        },
        [ADD_WARNING]: {
          src: publicAssetPath("img/exam-request/32-32_3.png"),
          class: "symbol-request-noplan td-img",
          style: `background-color: ${getStyleColor(hasTreatment, isLocked)};`
        }
      };

      return statusMap[reqKbn] || {
        src: "",
        class: "td-img",
        style: ""
      };
    },
    /** 検査セットセル ユニークキー生成 */
    makeCellKey(patId, examSetCd, regOrderClass) {
      return `${patId}_${examSetCd}_${regOrderClass}`;
    },
    /** 背景色クラス付与関数 */
    addEditedColorClass(patId, examSetCd, regOrderClass) {
      const key = this.makeCellKey(patId, examSetCd, regOrderClass);
      return this.editedCellMap[key] ? ['exam-edited-cell'] : [];
    },
    /** 患者名クリックでその患者の子画面に遷移 */
    async showDetailPage(patId) {
      this.setSelectedPatId(patId);
      await this.executeWithLoadingScreen(async () => {
        await this.selectPat(patId);
      });
      this.$router.push({ name: "exam-request-detail" });
    },
    /** 検査セットセルのクリックイベント */
    async editSchedule(celObj, setData) {
      if (!checkExamAuthorized()) return;

      const targetDate = toKeyDate(this.scheduledDate); // NOTE: YYYY-MM-DD形式で設定されている場合があるため、YYYYMMDD形式に変換
      const targetObj = this.localExamReqList.find(item => item.patId === celObj.patId);
      if (!targetObj) return;

      let examSet = this.findExamSet(targetObj, setData);
      // 該当セットが存在しない場合は新規追加
      if (!examSet) {
        examSet = this.createNewExamSet(celObj.patId, setData, targetDate);
        targetObj.examSets.push(examSet);
      }
      // 状態に応じた編集処理
      await this.updateExamSetStatus(targetObj, examSet, celObj.patId, targetDate);

      // 表示更新
      this.generateSortedList();
    },
    /** 対象患者の検査セット一覧から、該当するセットを検索して返す処理 */
    findExamSet(targetObj, setData) {
      return targetObj.examSets.find(es =>
        String(es.examSetCd) === String(setData.examSetCd) &&
        es.regOrderClass === setData.regOrderClass);
    },
    /** 指定された情報をもとに、新規検査セットオブジェクトを生成する処理 */
    createNewExamSet(patId, setData, targetDate) {
      const hasSchedule = hasScheduleOnTargetDate(patId, targetDate);
      const deadlineFlg = this.isBeforeDeadline(targetDate) ? "1" : "0";

      return {
        examSetCd: setData.examSetCd,
        examSetName: setData.examSetName,
        regOrderClass: setData.regOrderClass,
        reqKbn: "", // 後続でセット
        examStatus: "0",
        isLock: deadlineFlg,
        hasTreatment: hasSchedule,
        isNewlyAdded: true,
      };
    },
    /** 検査セットの状態（reqKbn）に応じて、編集・削除・確認ダイアログなどの処理を行う処理 */
    async updateExamSetStatus(targetObj, examSet, patId, targetDate, suppressConfirm = false) {
      const deadlineFlg = this.isBeforeDeadline(targetDate) ? "1" : "0";
      const key = this.makeCellKey(patId, examSet.examSetCd, examSet.regOrderClass);

      if (examSet.reqKbn === CANCEL) {
        examSet.reqKbn = SAVED;
        delete ((this.editedCellMap)[key]);
        return;
      }

      if (examSet.reqKbn === SAVED && examSet.examStatus === "1") {
        if (suppressConfirm) {
          examSet.reqKbn = CANCEL;
          ((this.editedCellMap)[key] = true);
        } else {
          const answer = await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000164].title,
            message: messageFormat(DIALOG_MESSAGES[13000164].message),
          });
          if (answer === 1) {
            examSet.reqKbn = CANCEL;
            ((this.editedCellMap)[key] = true);
          }
        }
        return;
      }

      if (examSet.reqKbn === SAVED) {
        examSet.reqKbn = CANCEL;
        ((this.editedCellMap)[key] = true);
        return;
      }

      if (examSet.reqKbn === ADD || examSet.reqKbn === ADD_WARNING) {
        const index = targetObj.examSets.findIndex(es =>
          String(es.examSetCd) === String(examSet.examSetCd) &&
          es.regOrderClass === examSet.regOrderClass);
        if (index !== -1) {
          targetObj.examSets.splice(index, 1);
          delete ((this.editedCellMap)[key]);
        }
        return;
      }

      // その他（未設定など）
      examSet.reqKbn = hasScheduleOnTargetDate(patId, targetDate) ? ADD : ADD_WARNING;
      examSet.examStatus = "0";
      examSet.isLock = deadlineFlg;
      ((this.editedCellMap)[key] = true);
    },
    /** 指定日が締切条件より前かどうかを判定する処理 */
    isBeforeDeadline(targetDate) {
      return this.getDeadlineCondition?.deadlineFlg &&
            dayjs(getDeadlineDate(this.getDeadlineCondition)).isAfter(dayjs(targetDate));
    },
    /** 指示者選択のスタイル調整 */
    dropToContent(event) {
      this.onIndUserDropdownOpen(event);
      this.$nextTick(() => {
        // NOTE: dropDownを開いた時にデータに応じて表示枠を広げる
        setKendoPopupSurfaceStyles(event, { width: "max-content", bottom: "0px" }, this.$el);
        this.onIndUserDropdownOpen(event);
      });
    },
    /** ポップアップ表示 */
    showPopover(event, field, index, data) {
      this.popoverHeader.popoverTarget = event;
      this.popoverHeader.popoverVisible = true;
      this.popoverHeader.field = field;
      // 検査セットヘッダクリック時
      if (field === "exam_set") {
        this.popoverHeader.examSetCell.index = index;
        this.popoverHeader.examSetCell.data = data;
      }
    },
    /** 一括登録ボタンクリック */
    async colListRegister(data) {
      if (!checkExamAuthorized()) return;

      const targetDate = toKeyDate(this.scheduledDate);

      this.localExamReqList.forEach(patient => {
        const targetObj = patient;
        let examSet = this.findExamSet(targetObj, data);

        if (!examSet) {
          examSet = this.createNewExamSet(patient.patId, data, targetDate);
          targetObj.examSets.push(examSet);
        }

        if (!examSet.reqKbn || examSet.reqKbn === CANCEL) {
          this.updateExamSetStatus(targetObj, examSet, patient.patId, targetDate);
        }
      });
      // 表示更新
      this.generateSortedList();
    },
    /** 一括中止ボタンクリック */
    async colListCancel(data) {
      if (!checkExamAuthorized()) return;

      const targetDate = toKeyDate(this.scheduledDate);

      // 事前チェック：SAVED + examStatus === "1" があるか
      const needsConfirm = this.localExamReqList.some(patient => {
        const examSet = this.findExamSet(patient, data);
        return examSet && examSet.reqKbn === SAVED && examSet.examStatus === "1";
      });

      if (needsConfirm) {
        const confirmed = await confirmIsOk(DIALOG_MESSAGES[13000164]);
        if (!confirmed) return;
      }

      this.localExamReqList.forEach(patient => {
        const targetObj = patient;
        const examSet = this.findExamSet(targetObj, data);

        if (!examSet) return;

        if ([ADD, ADD_WARNING, SAVED].includes(examSet.reqKbn)) {
          this.updateExamSetStatus(targetObj, examSet, patient.patId, targetDate, true);
        }
      });

      this.generateSortedList();
    },
    /** 保存ボタンクリック */
    async saveRecord() {
      if (!validateSelectDoctor(this.selectDoctor)) return;
      const saveData = this.createSaveExamDataFromLocalExamReqList();
      if (!(await confirmCheckResult(saveData))) return;
      const request = saveData.request;

      const requestJournal = [].concat(...["0", "1", "2"].map(
        aClass => request.filter(item => item.regOrderClass == aClass)));

      const params = {request, requestJournal};
      await executeUploadTemplete(
        this.updateRecordListJournal(params),
        () => this.fetchAndRenderExamRequests(), // 再表示
        "ExamRequestDailyComponent.vue",
        "saveRecord",
        this.messageDialogInfo);
    },
    /** リクエストパラメータ生成処理 */
    createSaveExamDataFromLocalExamReqList() {
      /* 結果オブジェクトの初期化処理 */
      const result = {
        rtnNoTreatDateFlg: false,
        rtnDeadlineOverFlg: false,
        request: []
      };

      /* コンテキスト情報の準備処理（日付・依頼リストなど） */
      const examDate = toKeyDate(this.scheduledDate);
      const deadlineDate = this.getDeadlineCondition.deadlineFlg
        ? dayjs(getDeadlineDate(this.getDeadlineCondition))
        : null;
      const mstExamSetList = this.getMstExamSetList;
      const patMainList = this.patMainList;
      const localExamReqList = this.localExamReqList;
      const indUserId = Number(this.selectDoctor);
      const orgPatExamMainsClone = _.cloneDeep(this.getOrgPatExamMains);

      /* 患者単位で検査セットを処理する */
      localExamReqList.forEach(pat => {
        const patId = pat.patId;

        pat.examSets.forEach(editExamSet => {
          const obj = {
            editExamSet,
            patId,
            examDate,
            deadlineDate,
            mstExamSetList,
            patMainList,
            indUserId,
            orgPatExamMainsClone,
            result
          };
          const record = this.processExamSet(obj);
          if (record) {
            const isDuplicate = result.request.some(r => {
              /**
               * NOTE:
               * selectOrCreateExamRecord により、「患者 × 検査日 × 検査区分（＋条件によって検査セット単位）」の
               * 単位で record は一意に決定されている。
               * ただし、処理は検査セット単位で回るため、同一 record に対して processExamSet が複数回実行される。
               * ここでは、同一 record に対応するリクエストをresult.request に二重に追加しないため、record の
               * 実質的な一意性を構成する以下の項目がすべて一致するかで重複判定を行っている。
               *   ・患者（patId）
               *   ・検査日（regExamDate）
               *   ・検査区分（regOrderClass）
               *   ・検査項目群（examOrderInfo）
               */
              const isSameBase = (
                r.examMainCd === record.examMainCd &&
                r.patId === record.patId &&
                r.regExamDate === record.regExamDate &&
                r.regOrderClass === record.regOrderClass &&
                r.examOrderInfo === record.examOrderInfo);
              return isSameBase;
            });
            if (!isDuplicate) {
              result.request.push(record);
            }
          }
        });
      });

      return result;
    },
    /** 検査セット単位の処理（追加・中止） */
    processExamSet(
      {editExamSet, patId, examDate, deadlineDate, mstExamSetList, patMainList, indUserId, orgPatExamMainsClone, result}) {
      const { examSetCd, regOrderClass, reqKbn } = editExamSet;
      const isCancelData = reqKbn === CANCEL;
      const isAddData = reqKbn === ADD || reqKbn === ADD_WARNING;
      if (!isCancelData && !isAddData) return null;

      /* 患者毎のスケジュール延長最終日をチェック */
      const schExtEndMinDateYyyymmdd = getSchExtEndDateWithPatMainList(patMainList, patId);
      const schExtEndMinDate = dayjs(schExtEndMinDateYyyymmdd, "YYYYMMDD");
      // NOTE: 検査予定日がスケジュール延長最終日より先の日付の追加は処理しない
      if (isAddData && schExtEndMinDate.isBefore(dayjs(examDate, "YYYYMMDD"))) return null;

      /* 既存レコード取得 or 新規レコードのデータ追加処理 */
      const isEcgExamSet = mstExamSetList.some(i =>
        i.examSetCd === Number(examSetCd) && i.examSetClass === ExamSetClass.Ecg);
      const kensaObj = { patId, examSetCd, regOrderClass };
      const record = selectOrCreateExamRecord(orgPatExamMainsClone, kensaObj, examDate, isCancelData, isEcgExamSet);

      /* レコード共通項目の設定処理（インライン化） */
      record.indUserId = indUserId;
      record.regExamDate = examDate;
      record.strExamDate = examDate;
      record.dataGenClass = "0";
      /* 締切確認が有効な場合 */
      if (deadlineDate && deadlineDate.isAfter(dayjs(examDate, "YYYYMMDD"))) {
        record.isLock = LockFlag.Locked;
        result.rtnDeadlineOverFlg = true;
      }

      if (isCancelData) {
        /* 中止処理（isDelフラグやoperationの設定） */
        this.handleCancel(record, examSetCd, editExamSet.examSetName, mstExamSetList);
      } else if (isAddData) {
        /* 追加処理（検査項目・ラベル情報の追加） */
        const examSetObj = mstExamSetList.find(item => item.examSetCd === Number(examSetCd));
        this.handleAdd(record, examSetObj, examSetCd);
        if (reqKbn === ADD_WARNING) {
          result.rtnNoTreatDateFlg = true;
        }
      }

      return record;
    },
    /** 中止処理（isDelフラグやoperationの設定） */
    handleCancel(record, examSetCd, examSetName, examSetNameList) {
      const examSetCdNum = Number(examSetCd);

      // orderExamSetInfo から対象の set_cd を除外
      const orderExamSetInfo = JSON.parse(record.orderExamSetInfo || "[]");
      const filteredSetInfo = orderExamSetInfo.filter(info => Number(info.set_cd) !== examSetCdNum);
      filteredSetInfo.sort((a, b) => a.set_cd - b.set_cd);
      record.orderExamSetInfo = JSON.stringify(filteredSetInfo);

      // examOrderInfo から対象の set_cd を除外
      const examOrderInfo = JSON.parse(record.examOrderInfo || "[]");
      const filteredOrderInfo = examOrderInfo.filter(info => Number(info.set_cd) !== examSetCdNum);
      filteredOrderInfo.sort((a, b) => {
        if (a.set_cd !== b.set_cd) {
          return a.set_cd - b.set_cd;
        }
        return a.item_cd - b.item_cd;
      });
      record.examOrderInfo = JSON.stringify(filteredOrderInfo);

      // orderLabelInfo を再構成
      const orderLabelInfo = [];
      filteredSetInfo.forEach(info => {
        const examSetObj = examSetNameList.find(item => Number(item.examSetCd) === Number(info.set_cd));
        if (!examSetObj) return;
        const labelInfo = JSON.parse(examSetObj.labelInfo || "[]");
        addLabelInfo(labelInfo, orderLabelInfo);
      });
      record.orderLabelInfo = JSON.stringify(orderLabelInfo);

      // isDel フラグの判定（残っているセットがゼロなら削除）
      if (filteredSetInfo.length === 0) {
        record.isDel = DeleteFlag.Delete;
      }

      // operation の更新
      if (record.operation !== Operation.Create) {
        record.operation = Operation.Update;
      }
    },
    /** 追加処理（検査項目・ラベル情報の追加） */
    handleAdd(record, examSetObj, examSetCd) {
      const examSetItemInfo = JSON.parse(examSetObj.examItemInfo);
      const examSetLabelInfo = JSON.parse(examSetObj.labelInfo);

      const orderExamSetInfo = JSON.parse(record.orderExamSetInfo || "[]");
      orderExamSetInfo.push({ set_cd: examSetCd, set_name: examSetObj.examSetName });
      orderExamSetInfo.sort((a, b) => a.set_cd - b.set_cd);
      record.orderExamSetInfo = JSON.stringify(orderExamSetInfo);

      const examOrderInfo = JSON.parse(record.examOrderInfo || "[]");
      examSetItemInfo.forEach(item => {
        examOrderInfo.push({
          set_cd: examSetCd,
          item_cd: item.exam_item_cd,
          item_name: item.exam_item_name
        });
      });
      examOrderInfo.sort((a, b) => {
        if (a.set_cd !== b.set_cd) {
          return a.set_cd - b.set_cd;
        }
        return a.item_cd - b.item_cd;
      });
      record.examOrderInfo = JSON.stringify(examOrderInfo);

      const orderLabelInfo = JSON.parse(record.orderLabelInfo || "[]");
      addLabelInfo(examSetLabelInfo, orderLabelInfo);
      record.orderLabelInfo = JSON.stringify(orderLabelInfo);

      record.operation = record.operation || Operation.Create;
    },
    /** リフレッシュ処理 */
    async refresh() {
      await this.exeCancel();
    },
    /** キャンセルボタンクリック */
    async cancel() {
      await this.exeCancel();
    },
    /** キャンセル処理 */
    async exeCancel() {
      if (await this.confirmDiscardIfChanged()) {
        this.searchedPatListClone = _.cloneDeep(this.searchedPatList);
        this.fetchAndRenderExamRequests();
      }
    },
    /** 編集破棄確認ダイアログの表示処理 */
    async confirmDiscardIfChanged() {
      if (!this.isChanged) return true;
      const isOk = await confirmIsOk(DIALOG_MESSAGES[13000004]);
      return isOk;
    },
    /** 列幅の再計算を行い、固定列の位置調整処理 */
    updateLeftPosition() {
      this.$nextTick(() => {
        setTimeout(() => {
          const tableScope = this.getExamRequestTableScopeRoot() || this.getExamRequestScopeRoot();
          const hospIdHeader = this.getStickyElement('.col-sticky-id');
          const hospIdVisible = this.isShowHospPatId;
          const hospIdWidth = hospIdVisible && hospIdHeader ? hospIdHeader.offsetWidth : 0;

          // 患者名列の left を更新
          // NOTE: 患者名列を特定させるclass を設定するため、col-sticky-names を設定（スタイルはなし）
          const patNameHeader = this.getStickyElement('.col-sticky-names');
          const patNameCells = queryScopedSelectorAll(".col-sticky-names", tableScope);
          if (patNameHeader) patNameHeader.style.left = `${hospIdWidth}px`;
          patNameCells.forEach(cell => cell.style.left = `${hospIdWidth}px`);

          // 血糖検査列の left を更新
          const bloodClass = !hospIdVisible ? ".col-sticky-blood-glucose-exams" : ".col-sticky-blood-glucose-exam";
          const bloodHeader = this.getStickyElement(bloodClass);
          const bloodCells = queryScopedSelectorAll(bloodClass, tableScope);
          const patNameWidth = patNameHeader?.offsetWidth || 0;
          const bloodLeft = hospIdWidth + patNameWidth;
          if (bloodHeader) bloodHeader.style.left = `${bloodLeft}px`;
          bloodCells.forEach(cell => cell.style.left = `${bloodLeft}px`);
        }, 50);
      });
    },
  },
  /****************************************************************************/
  // Lifecycle Hooks
  /****************************************************************************/
  async created() {
    // 共通ローダーの表示開始
    this.startLoadingScreen();

    /* 患者別画面のデータが残っている場合があるためクリアしておく */
    this.clearExamRequestDaily();

    /* 検査セットマスタ情報取得 */
    try {
      const [examSetRes, sortInfoRes] = await Promise.all([
        sendRequestAllExamSetListByFacility(this.getFacilityCd, this.selectedPatId),
        ApiHelper.get("/mstInfo/mst_exam_set/mstSelector", {
          facilityCd: this.getFacilityCd,
          selectedPatId: this.selectedPatId
        }),
      ]);

      const allExamSets = examSetRes.data;
      const sortItems = sortInfoRes.data?.orderSettings?.items ?? [];

      // 表示対象と全検査セットリストの構築
      this.delExamSetCdList = allExamSets.filter(item => item.isDisp === "0").map(item => item.examSetCd);
      this.allExamSetList = [...allExamSets];
      // NOTE: Function側でも利用できるようにstoreにも保存
      this.setAllExamSetList(this.allExamSetList);

      // ソート処理
      const sortCodes = sortItems.map(item => item.code);
      // ソート対象の検査セットを抽出
      const sorted = sortCodes.map(code => allExamSets.find(item => item.examSetCd === code)).filter(Boolean);
      // ソート情報に含まれていない検査セットを抽出
      const remaining = allExamSets.filter(item => !sortCodes.includes(item.examSetCd)).sort((a, b) => a.examSetCd - b.examSetCd);

      const finalExamSetList = sortCodes.length > 0
        ? [...sorted, ...remaining]
        : [...allExamSets].sort((a, b) => a.examSetCd - b.examSetCd);
      // 検査セットマスタ設定
      await this.setMstExamSetList(finalExamSetList);
    } catch (error) {
      console.error("検査セット取得エラー:", error);
    }

    /* 指示者ドロップダウンの設定 */
    await this.getIndUserList(
      AUTHORITY_CODES.IND_EXAM_EDIT,
      AUTHORITY_CODES.IND_EXAM_PEDIT).then(res => {
      this.doctorList = res.doctorList;
      this.$nextTick(() => {
        this.selectDoctor = res.iniSelectId;
      });
    });

    /* 患者毎の入外区分＋同姓同名の状態情報取得 */
    const _response = await ApiHelper.configPost("/patInfo/getPatSameAndInOutClass", { facilityCdList: [this.getFacilityCd] }, {
      params: {
        selectedPatId: this.selectedPatId
      }
    });
    this.patStatusMap = _response.data;

    // 締切設定を取得
    await this.setExamDeadline({
      facilityCd: this.getFacilityCd,
      selectedPatId: this.selectedPatId
    });
    /**
     * NOTE:
     * 検査依頼詳細にて、スクロール位置の調整で使用している
     * 「一覧 -> 詳細」という遷移時にはスクロール位置がTOP
     * にするため、検査依頼一覧で値をリセットする。
     */
    this.setCalendarCheckedDate(null);

    /* 端末判別 */
    const ua = (getScopedWindow(this.$el || this)?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.isAndroid = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.isIOS = true;
    }

    /* サイン後、初めて表示するか（ストアに値が設定されていない状態か） */
    if (!this.isStoredShowDate) {
      /* 個人設定＞デフォルト設定読み込み */
      const defaultExamRequest = this.getDefaultSetting[EXAM_REQUEST.KEY_NAME];
      const defaultScheduledDate = defaultExamRequest?.[EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE];
      // 表示期間・開始日を取得 NOTE: 表示期間の開始日があればそれを優先、なければ個人設定または本日
      const showStartDate = toCalDate(this.getStartToEndDate.showStartDate || calcTargetDate(defaultScheduledDate));
      // 検査予定日を設定
      this.scheduledDate = showStartDate
      /**
       * NOTE:
       * 「表示期間・終了」 および 「詳細・簡易切り替え」 を設定している理由について
       *   updateStartToEndDate()の処理内で、「isStoredShowDate=true」となる。
       *   そのため、期間に切り替えた際、デフォルト設置が読み込まれないため、こちらでも設定する
       */
      // 表示期間・終了
      const defaultEndDate = defaultExamRequest[EXAM_REQUEST.KEY_NAME_END_DATE];
      const showEndDate = this.getStartToEndDate.showEndDate || calcTargetDate(defaultEndDate) || toCalDate(dayjs().add(3, "months"));
      // 詳細・簡易切り替え
      const defaultShowDetail = defaultExamRequest[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY];
      if (defaultShowDetail == "2") this.setShowDetailsDisplay(false); // NOTE: 「簡易」であれば、storeのフラグを更新する
      // 患者ID表示
      const defaultShowPatId = defaultExamRequest[EXAM_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID];
      if (defaultShowPatId !== undefined) {
        this.isShowHospPatId = defaultShowPatId;
      }
      const defaultShowExam = defaultExamRequest[EXAM_REQUEST.KEY_NAME_IS_SHOW_BLOOD_GLUCOSE_EXAM];
      // 血糖検査表示
      if (defaultShowExam !== undefined) {
        this.isShowBloodGlucoseExam = defaultShowExam;
      }
      // 表示期間・開始日を更新
      this.updateStartToEndDate({
        showStartDate: toKeyDate(showStartDate),
        showEndDate
      });
    } else {
      // ストア から表示期間・開始日を取得
      this.scheduledDate = toCalDate(this.getStartToEndDate.showStartDate);
    }

    // 患者検索で取得した患者リストを設定
    this.searchedPatListClone = _.cloneDeep(this.searchedPatList);
    // 検査依頼データの取得と表示リストの生成
    this.fetchAndRenderExamRequests();
    // 患者のスケジュール関連情報を初期化
    this.initPatScheduleContext();

    // 共通ローダー:表示終了
    this.finishLoadingScreen();
  },
  mounted() {
    this.$nextTick(() => {
      const headers = queryScopedSelectorAll(".manual-width", this.getExamRequestScopeRoot());
      headers.forEach((el) => {
        const observer = new ResizeObserver(() => {
          this.updateLeftPosition(); // 幅変更時に再計算
        });
        observer.observe(el);
        this.resizeObservers.push(observer);
      });

      // 初期表示時にも一度計算
      this.updateLeftPosition();
      setTimeout(() => {
        this.calculateGridHeight();
      });
    });
    EventBus.$on("refresh", this.refresh);
  },
  beforeUpdate() {
    this.calculateGridHeight();
  },
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    // ResizeObserver の解除
    this.resizeObservers.forEach(observer => observer.disconnect());
    this.resizeObservers = [];
  },
};
</script>

<style scoped>
tr {
  height: 31px;
}
td {
  border: solid 1px #cccccc;
  text-align: center;
}
.main-content-area {
  min-width: 200px;
}
/* 上部のスタイル定義 */
#upper-buttons {
  width: 100%;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: auto;
  display: flex;
}
/* 期間/一日ボタン */
input[type="radio"] {
  /* ラジオボタンを非表示にする */
  display: none;
}
/* 期間/一日 切替ボタン */
.label:hover {
  /* マウスオーバー時の背景色を指定する */
  background-color: #31a9ee;
}
.label {
  display: block;
  float: left;
  width: 30%;
  height: 2em;
  padding-left: 5px;
  padding-right: 5px;
  background-color: #87cefa;
  color: #ffffff;
  text-align: center;
  line-height: 2em;
  cursor: pointer;
  margin: 15px 0px;
  white-space: nowrap;
}
.first-of-type {
  border-radius: 10px 0 0 10px;
  margin: 2px 0px 2px 1px;
  width: auto;
  padding: 0px 10px 0px 10px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
  margin: 2px 5px 2px 0px;
  width: auto;
  padding: 0px 10px 0px 10px;
}
.upper-buttons-label {
  margin-left: 8px;
  margin-right: 7px;
  white-space: nowrap;
  text-align: center;
}
/* 一覧エリアのスクロール */
.scroll-table {
  --height: 500px;
  height: var(--height);
  overflow: auto;
  margin-top: 5px;
  margin-bottom: 5px;
}
.grid-record-list {
  border-collapse: collapse;
  width: max-content;
  background-color: var(--ntss-list-background-color);
}
.ntss-list-header-th-sticky {
  z-index: 1;
  box-shadow: 0px 0px 0px #cccccc inset, -1px 1px 0px #cccccc inset !important;
  border: solid 0px var(--ntss-list-border-color) !important;
}
.col-sticky-id {
  z-index: 1;
  top: unset;
  text-align: unset;
  white-space: normal;
  word-break: break-all;
  width: 110px;
  left: 0px;
  border-left: none;
  border-right: none;
  box-shadow: 1px 0px 0px #ffffff inset, -1px 0px 0px #ffffff inset;
}
.manual-width {
  resize: horizontal;
  overflow-x: auto;
}
.col-sticky-name {
  z-index: 1;
  top: unset;
  text-align: unset;
  white-space: normal;
  word-wrap: break-word;
  border-left: none;
  border-right: none;
  border-bottom: hidden;
  box-shadow: -1px 0px 0px #ffffff inset;
  width: 100px;
}
.col-sticky-blood-glucose-exams {
  border-left: none;
  border-right: none;
  z-index: 1;
  box-shadow: -1px 0px 0px #ffffff inset;
  top: unset;
  text-align: unset;
  white-space: normal;
  word-wrap: break-word;
}
.col-sticky-blood-glucose-exam {
  z-index: 1;
  border-left: none;
  border-right: hidden !important;
  box-shadow: -1px 0px 0px #ffffff inset;
  top: unset;
  text-align: unset;
  white-space: normal;
  word-wrap: break-word;
  border-bottom: hidden !important;
}
.maru-symbol {
  width: 0.9em;
}
.exam-control-cell {
  position: relative;
  height: 31px;
  vertical-align: middle;
}
.exam-control-cell :deep(.td-img) {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 1.2em;
  height: auto;
  border-radius: 1em;
  background-color: transparent !important;
}
.col-sticky-name-android {
  left: 27px;
}
.col-check-header {
  border-top: solid 1px var(--ntss-list-border-color);
  border-bottom: none;
  top: unset;
  text-align: center
}
/* 編集済みセルの背景色 */
.exam-edited-cell::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  background-color: #aaffaa55;
  display: block;
}
/* 下部のスタイル定義 */
#bottom-buttons {
  width: 100%;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  justify-content: space-around;
}
/* 指示者選択/保存ボタン領域 */
.bottom-buttons-div {
  margin: 0px 0px 0px auto;
  display: flex;
  align-items: center;
}
.bottom-buttons-label {
  white-space: nowrap;
  width: 5em;
  text-align: right;
  margin-right: 0.5em;
}

ons-popover :deep(.popover--top) {
  max-width: 18em;
}

/* ポップアップ */
.exam-request-daily-header-popover :deep(.popover--top) {
  width: 18em;
  min-width: 0;
  max-width: 18em;
}
ons-popover :deep(.popover--top > .popover__content) {
  font-size: 1.6em;
  height: auto;
  min-height: 0;
}

.exam-request-daily-header-popover :deep(.popover--top > .popover__content) {
  width: 100%;
  min-width: 0;
  max-width: 100%;
  box-sizing: border-box;
  font-size: 1.6em;
  height: auto;
  min-height: 0;
}
ons-popover :deep(.popover--top > .popover__content label) {
  width: 5em;
}

.exam-request-daily-header-popover :deep(.popover--top > .popover__content label) {
  width: 5em;
}
.popover-content :deep(.popover--top),
.popover-content :deep(.popover--right),
.popover-content :deep(.popover--left),
.popover-content :deep(.popover--bottom) {
  width: initial;
}
.popover-content-header :deep(.popover__content) {
  width: 200px;
  min-height: auto;
}
.popover-content-div {
  margin: 5px;
}
.header-columns {
  margin-bottom: 5px;
}
.popover-content-row {
  margin-bottom: 10px;
}
@media print {
  /** ヘッダ固定 */
  .ntss-list-header-th-sticky {
    position: sticky !important;
  }
  /** スクロールコンテナ */
  .scroll-table {
    overflow: hidden !important;
    height: auto !important;
  }
  /** 下部ボタン非表示 */
  #bottom-buttons {
    display: none;
  }
}
</style>
