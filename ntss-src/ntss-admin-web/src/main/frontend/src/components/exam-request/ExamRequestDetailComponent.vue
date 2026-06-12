/**
 * 患者個別検査依頼
 */
<template>
  <div class="main-content-area">
    <exam-header-component class="request-header-component" style="font-size: .667em;"/>
    <!-- 上部ボタン部 -->
    <div id="upper-buttons">
      <label
        class="upper-buttons-label examrequest-label"
        style="width: 5em;"
      >表示期間</label>
      <date-input
        class="examrequest-input-display-period start ntss-input-date"
        id="startDate"
        name="startDate"
        max="2099-12-31"
        v-model="condition.startDate"
        @blur="checkInputStartDate"
        @handleClearInput="clearInputStartDate"
        data-validation-scope="condition"
        enabledBlank
      />
      <common-calendar
        v-model="condition.startDate"
        :disableDatesAfter="disableDatesAfter"
        @blur="checkInputStartDate"
        @todayButtonClick="checkInputStartDate"
      />
      <label
        class="upper-buttons-label examrequest-label"
        style="width: 2.5em;"
      >～</label>
      <date-input
        class="examrequest-input-display-period end ntss-input-date"
        id="endDate"
        name="endDate"
        max="2099-12-31"
        v-model="condition.endDate"
        @blur="checkInputEndDate"
        @handleClearInput="clearInputEndDate"
        data-validation-scope="condition"
        enabledBlank
      />
      <common-calendar
        v-model="condition.endDate"
        :disableDatesAfter="disableDatesAfter"
        @blur="checkInputEndDate"
        @todayButtonClick="checkInputEndDate"
      />
    </div>
    <!-- テーブルエリア -->
    <div class="scroll-table" :style="gridHeightStyle" ref="examrequestrecorddetailgrid">
      <!-- 表示テーブル -->
      <table class="grid-record-list" style="width: max-content;">
        <tbody>
          <tr class="thead">
          <th
            v-for="(dateItem, index) in getExamDateListDetail"
            :key="index"
            :style="gridHeaderWidth(index, dateItem.date)"
            @click="colListClear(index, dateItem)"
            class="ntss-list-header-th-sticky"
            :class="[
              index === 1 ? ['col-sticky-first', 'manual-width'] : [],
              getStyle(dateItem.date)
            ]"
          >{{ dateItem.dateFormat }}<span
            v-if="index === 1"
            class="blood-glucose-wrapper"
          >
            <label class="label-blood-glucose">血糖検査</label>
            <v-ons-checkbox
              v-model="isBloodGlucoseExam"
              class="chk-blood-glucose"
              @click.stop.prevent
            />
          </span></th>
        </tr>
        <tr>
          <td
            class="ntss-list-header-th-sticky col-sticky-name manual-width"
            style="padding-left: 1em; padding-right: 1em; white-space: unset;"
          >治療予定</td>
          <td
            v-for="(dateItem, index) in getExamDateListDetail.slice(2)"
            :key="index"
            :style="fontColor(dateItem.date)"
            class="examrequest-label exam-control-cell"
          >
            <!-- 治療予定欄の表示内容を生成 -->
            <img v-if="hasScheduleTreatment(dateItem, selectedPatId)" :src="publicAssetPath('img/exam-request/32-32_2.png')" class="symbol-request-saved td-img"/>
          </td>
        </tr>
        <tr
          v-for="(listDate, index) in examRequestDetailListInDisplayPeriod"
          :key="index"
        >
          <!-- 検査セット行 -->
          <!-- mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start-->
          <td v-if="!listDate.headerflg"
            class="ntss-list-header-th-sticky col-sticky-name manual-width"
            style="padding-left: 1em; padding-right: 1em; white-space: unset;"
          >
            <span @click="rowClear(listDate)">{{
              isOtherFacility(listDate)
                ? buildOtherFacilityText(listDate)
                : (
                  showDelExam(listDate.examSetCd)
                  + showExamName(listDate.examSetCd)
                  + showRegOrderClass[listDate.regOrderClass]
                )
            }}</span>
          </td>
          <!-- mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end-->
          <!-- 日付列 -->
          <td
            v-for="(date, index) in getExamDateListNoShap"
            :key="index"
            :style="fontColor(listDate, date)"
            :class="addEditedColor(listDate, date)"
            @click="editSchedule(listDate, date)"
            class="examrequest-label exam-control-cell"
          >
            <!-- 患者名行 -->
            <template v-if="listDate.headerflg">
              {{ listDate.examData[date] || "" }}
            </template>
            <!-- 患者名行以外 -->
            <img v-else v-bind="getImgAttributesForDate(listDate, date)">
          </td>
          <!-- 自動展開列 -->
          <td
            v-for="(data, index) in getExamPatternColumnList"
            :key="`second-${index}`"
            :style="fontColorPatternColumn(listDate)"
            :class="addEditedColorPatternColumn(listDate, data)"
            @click="editPatternCell(listDate, data)"
            class="examrequest-label exam-control-cell"
          >
            <!-- 患者名行 -->
            <div v-if="listDate.headerflg" :style="getPatRowCellStyle(listDate, data)">
              {{ getPatRowCellNumber(listDate, data) }}
            </div>
            <!-- 患者名行以外 -->
            <img v-else v-bind="getImgAttributesForPattern(listDate, data)">
          </td>
        </tr>
      
        </tbody>
      </table>
    </div>
    <!-- 下部ボタン部 -->
    <div id="bottom-buttons">
      <v-ons-button
        class="btn2-cancel"
        style="width: 7em; margin: 0 auto 0 0;"
        :disabled="!getExamAuthorized()"
        @click="clear"
      >クリア</v-ons-button>
      <div class="bottom-buttons-div">
        <label class="bottom-buttons-label examrequest-label">指示者</label>
        <kendo-dropdownlist
          v-model="selectDoctor"
          :data-source="doctorList"
          :data-text-field="'fullName'"
          :data-value-field="'user_id'"
          @open="addMaxContentStyle"
          :disabled="!getExamAuthorized()"
          style="width: 11.4em; height: 2em; margin-right: 5px;"
          class="input-style-required"
        />
        <v-ons-button
          class="btn1-execute"
          style="width: 5em;"
          @click="saveRecord"
          :disabled="!isChanged || !getExamAuthorized()"
        >保存</v-ons-button>
      </div>
    </div>
    <!--    add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start-->
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
    <!--    add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end-->
  </div>
</template>

<script>
import { publicAssetPath } from "@/compat/assets/public-path";
import store from "@/stores";
// 検査セット
import { sendRequestGetMstExamSetList, sendRequestAllExamSetListByFacility } from "@/apis/exam-request";
// 検査項目
import { sendRequestGetDispExamItemListForFacilityCd } from "@/apis/exam-Record";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
import ExamRequestHeaderComponent from "@/components/exam-request/ExamRequestPeriodHeaderComponent";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import {
  CANCEL,
  SAVED,
  ADD,
  ADD_WARNING,
  BACKGROUND_HEADER_PAST_DAY,
  BACKGROUND_HEADER_TODAY,
  BACKGROUND_COLUMN_PAST_DAY,
  BACKGROUND_ROW_PATNAME,
  FONTCOLOR_HAS_SCHEDULE,
  FONTCOLOR_HAS_NOT_SCHEDULE,
  FILLCOLOR_DEFAULT,
  RegOrderClassShortText,
} from "@/constants/examRequestConstants";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {
  validateSelectDoctor,
  confirmCheckResult,
  executeUploadTemplete,
  checkAndCreateSaveExamData,
  hasTreatmentPatternOnWeek,
  hasScheduleTreatment,
  ColumnType,
  setShowDateToCondition,
  formatToYyyymmdd,
  formatToInputDate,
  getExamAuthorized,
  checkExamAuthorized,
  confirmIsOk,
  getDefaultSchExtEndDate,
  getExamCellImgAttributesByDate,
  hasScheduleOnTargetDate,
} from "@/functions/exam-request/ExamRequestFunctions";
import DateInput from "@/components/common/DateInput";
import { getHolidayStyle } from "@/functions/common/CommonFunctions";
import messageDialog from "@/components/common/message-dialog/MessageDialog.vue";
import { setKendoPopupSurfaceStyles } from "@/functions/common/KendoFunctions";
import { getScopedElementById, getScopedElementsByClassName, queryScopedSelector, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";
import PrintMixin from "@/components/PrintMixin";

export default {
  props: {
    controller: null,
    // NOTE: コンソールエラー対策
    historyKey: null
  },
  mixins: [NextTransitionMixin, IndUserSelectMixin, PrintMixin],
  components: {
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    "message-dialog": messageDialog,
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
    "exam-header-component": ExamRequestHeaderComponent,
    "common-calendar": commonCalender,
    "date-input": DateInput,
  },
  data() {
    return {
      gridHeight: 740,
      examHeaderHeight: 60,
      // 検査区分の省略表示文字列
      showRegOrderClass: RegOrderClassShortText,
      // 表示期間
      condition: {
        // 日付範囲
        startDate: "",
        endDate: "",
      },
      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: "1",
        stringParams: [""]
      },
      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
      // 画面表示する患者
      selectedPatId: null,
      selectedPatName: "",
      // 指示者
      selectDoctor: null,
      doctorList: [],
      // モバイル端末フラグ
      isAndroid: false,
      isIOS: false,
      // イベントリスナー追加フラグ
      addedTransitionEvent: false,
      isRouteGamenFlg: false,
      examRequesttable: null,
      dispExamSet: [],
      delExamSetItem: [],
      dispExamSetItem: [],
      otherFacilityCache: {},
      ignoreWatchSelectedPatId: false,
      // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
      getExamSetName: [],
      // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
      scrollQuerySelector: ".scroll-table",
      addClassTargetQuerySelector: ["table.grid-record-list"],
    };
  },
  computed: {
    ...mapGetters("exam-request/list", [
      "isStoredShowDate",
      "getStartToEndDate",
      "getNormalizedStartToEndDate",
      "getDeadlineCondition",
      "getExamDateList",
      "getExamDateListNoShap",
      "getExamRequestDetailList",
      "getEditExamRequestList",
      "getExamRequestListNoShap",
      "getSelectedPatId",
      "getExamDateListDetail",
      "patMainList",
      "getExamPatternColumnList",
      "getPatExamPatternList",
      "getSavePatExamPattern",
      "getSchExtEndDate",
      "getTreatBaseDate",
      "getCalendarCheckedDate",
      "getIsShowHospPatId",
      "getIsShowBloodGlucoseExam",
      "getAllExamSetList",
    ]),
    ...mapGetters("pat-info", [
      "searchedPatList",
      "selectedPat",
      "inSelectPatAtPatHeaderCreated",
      "getIsOtherFacility",
      "getOtherFacilityCd",
    ]),
    ...mapGetters("pat-info", { patInfoSelectedPatId: "selectedPatId" }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getSplittedWidth",
    }),
    ...mapGetters("account-edit", [
      "getFontSize",
      "getDefaultSetting",
      "isDispMenu",
      "getPatientShareMode",
      "getPatientShareFacilityCdMode",
    ]),
    ...mapGetters("user", ["getFacilityCd"]),

    // グリッドの高さをCSS変数を利用して書き換える
    gridHeightStyle() {
      return { "--height": `calc(${this.gridHeight}px - ${this.examHeaderHeight + 4}px)` };
    },
    gridHeaderWidth() {
      return (index, date) => {
        const result = {};
        if (index === 0) {
          result["display"] = "none";
        }

        if (date !== "") {
          const dateMoment = dayjs(date);
          const dateCurrent = formatToYyyymmdd();
          if (dateMoment.isBefore(dateCurrent)) {
            result["background-color"] = BACKGROUND_HEADER_PAST_DAY;
          }
          if (dateMoment.isSame(dateCurrent)) {
            result["background-color"] = BACKGROUND_HEADER_TODAY;
          }
        }
        return result;
      }
    },
    // 変更フラグ
    isChanged() {
      // 編集可能な権限があるかどうかを判断する
      if (!this.getExamAuthorized()) return false;

      let rtn = false;

      // 編集データから検査セット行だけを抽出する
      const kensaObjList = this.getExamRequestListNoShap.filter(item => !item.headerflg);
      // 変更されたデータを確認する
      rtn = kensaObjList.some(kensaObj => {
        // 検査セットが登録されている日付を取得
        const examDataKeys = Object.keys(kensaObj.examData);
        return examDataKeys.some(key => kensaObj.examData[key] !== SAVED);
      });

      if (this.getSavePatExamPattern.length) {
        rtn = true;
      }

      return rtn;
    },
    isBloodGlucoseExam() {
      const pat = this.patMainList.find(p => p.patId === this.selectedPatId);
      return pat ? pat.isBloodGlucoseExam : false;
    },
    // 表示期間内の検査依頼データ
    examRequestDetailListInDisplayPeriod() {
      const { showStartDate: dateStart, showEndDate: dateEnd } = this.getNormalizedStartToEndDate;
      return this.getExamRequestDetailList.filter(examRequest => {
        // パターンがある行はそのまま出力
        let { patId, examSetCd, regOrderClass } = examRequest;
        if (patId) patId = String(patId);
        if (examSetCd) examSetCd = String(examSetCd);
        if (regOrderClass) regOrderClass = String(regOrderClass);
        const hasExamPattern = this.getPatExamPatternList.some(pattern => (
          patId && patId === String(pattern.patId)
          && examSetCd && examSetCd === String(pattern.orderExamSetCd)
          && regOrderClass && regOrderClass === String(pattern.regOrderClass)));
        if (hasExamPattern) return true;

        // 期間内のexamDataがあれば出力
        const examDataKeys = Object.keys(examRequest.examData);
        return examDataKeys.some(key => (
          (!dateStart || key >= dateStart)
          && (!dateEnd || key <= dateEnd)));
      });
    },
    disableDatesAfter() {
      return formatToYyyymmdd(this.getSchExtEndDate || getDefaultSchExtEndDate(), "YYYY-MM-DD");
    },
    patIdList() {
      return this.selectedPatId ? [this.selectedPatId] : [];
    },
  },
  methods: {
    publicAssetPath,
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
      "executeWithLoadingScreen",
    ]),
    ...mapActions("exam-request/list", [
      "clearSearchedExamRequest",
      "searchExamRequest",
      "updateRecordList",
      "setExamDeadline",
      "setSelectedPatId",
      "updateStartToEndDate",
      "updateExamSetTargetList",
      "dayAllClear",
      "updateEditScheduleStatusStore",
      "setIsDataChanged",
      "getPatMainList",
      "setSavePatExamPattern",
      "getMinSchExtEndDate",
      "modifyInputDate",
      "setAllExamSetList",
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    ...mapActions("pat-info", {
      selectPatToHeader: "selectPat",
      clearSelectedPatToHeader: "clearSelectedPat",
      setIsNullPat: "setIsNullPat"
    }),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    getExamAuthorized,
    hasScheduleTreatment,

    // ウインドウ変更時の高さ補正
    calculateGridHeight() {
      // 表示期間などの表示領域
      const upperButtons = getScopedElementById("upper-buttons", this.$el || this);
      const upBtnsHeight = upperButtons.offsetHeight;

      // 下部ボタンの表示領域
      const bottomButtons = getScopedElementById("bottom-buttons", this.$el || this);
      const btmBtnsHeight = bottomButtons.offsetHeight;

      const examHeader = getScopedElementById("header-item", this.$el || this);
      this.examHeaderHeight = examHeader.offsetHeight;

      // 表示期間、表、下部ボタン全体の表示領域
      const mainId = getScopedElementById("main-id", this.$el || this);
      const mainIdHeight = mainId.offsetHeight;

      // 表エリアの高さ (15px引く)
      const gridHeightC = mainIdHeight - upBtnsHeight - btmBtnsHeight - 15;

      this.gridHeight = gridHeightC;

      // Android対策
      if (this.isAndroid && !this.addedTransitionEvent) {
        // CSSトランジションする要素(button--materialクラス)を取得
        const transitionButtons = getScopedElementsByClassName("button--material", this.$el || this);
        const transitionButton = Array.from(transitionButtons).find(
          el => el.innerText.trim() === "再表示");
        if (!transitionButton) return;
        // トランジション終了を検知する
        transitionButton.addEventListener("transitionend", event => {
          if (event.propertyName == "font-size") {
            // トランジション要素ごとに発火するので、１回に絞る
            const upBtnsHeight = upperButtons.offsetHeight;
            const btmBtnsHeight = bottomButtons.offsetHeight;
            const mainIdHeight = mainId.offsetHeight;
            const gridHeightC = mainIdHeight - upBtnsHeight - btmBtnsHeight - 15;
            this.gridHeight = gridHeightC;
          }
        })
        this.addedTransitionEvent = true;
      }
    },
    // 日付部をクリックした際に一括中止
    async colListClear(index, data) {
      // 編集可能な権限があるかどうかを判断する
      if (data.columnType != ColumnType.Dummy && !checkExamAuthorized()) return;

      // 列の表示状態によるindexの補正を行う
      if (this.getIsShowHospPatId) {
        index++;
      }
      if (this.getIsShowBloodGlucoseExam) {
        index++;
      }
      switch (data.columnType) {
        case ColumnType.Dummy:
          break;
        case ColumnType.Date: {
          const dateFormat = this.getExamDateList[index].dateFormat;
          // title: "更新確認",
          // message: "{dateFormat}の予定を一括中止します、よろしいですか？",
          if (await confirmIsOk(DIALOG_MESSAGES[13000029], dateFormat)) {
            this.dayAllClear({
              targetDate: formatToYyyymmdd(data.date),
              facilityCd: this.getFacilityCd,
            });
          }
          break;
        }
        case ColumnType.Pattern: {
          const dateFormat = this.getExamDateList[index].dateFormat;
          // title: "更新確認",
          // message: "{dateFormat}の自動展開データを一括中止します、よろしいですか？",
          if (await confirmIsOk(DIALOG_MESSAGES[13000030], dateFormat)) {
            this.editPatternHeader(data.setData);
          }
          break;
        }
      }
    },
    // 検査セット行をクリックした際のクリア処理
    async rowClear(celObj) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkExamAuthorized()) return;
      if (this.isOtherFacility(celObj)) return;

      const { patId, regOrderClass, examSetCd, examData } = celObj;
      const targetName = this.showExamName(examSetCd) + this.showRegOrderClass[regOrderClass];
      // title: "更新確認",
      // message: "本日以降の{targetName}の予定、自動展開データを一括中止します、よろしいですか？",
      if (!(await confirmIsOk(DIALOG_MESSAGES[13000031], targetName))) return;

      const targetObj = this.getEditExamRequestList.find(item => item.patId == patId);
      const tartgetData = targetObj.examItemSet[regOrderClass][examSetCd].data;

      // 検査セットが登録されている日付ごとに処理する
      const editedDate = [];
      const todayMoment = dayjs();
      Object.keys(examData).forEach(date => {
        // 過去日の依頼は中止対象にしない
        if (todayMoment.isAfter(date, "day")) return;

        switch (tartgetData[date]) {
          case CANCEL:
            // 中止指示の場合は、そのまま
            break;
          case SAVED: {
            // 依頼ありの場合、中止指示にする
            targetObj.data[date]--;
            tartgetData[date] = CANCEL;
            editedDate.push(date);
            break;
          }
          case ADD:
          case ADD_WARNING: {
            // 未保存の依頼があった場合、削除する
            targetObj.data[date]--;
            delete tartgetData[date];
            editedDate.push(date);
            break;
          }
        }
      });
      // this.getEditExamRequestListの要素内の情報を更新したリアクションを起こさせる
      this.getEditExamRequestList.splice();

      // 検査パターンの一括中止処理
      const examPatternListCopy = [...this.getPatExamPatternList];
      const savePatExamPatternCopy = [...this.getSavePatExamPattern];
      examPatternListCopy.forEach(target => {
        if (
          target.status !== CANCEL
          && String(target.orderExamSetCd) === String(examSetCd)
          && String(target.patId) === String(patId)
          && String(target.regOrderClass) === String(regOrderClass)) {
          this.editPatternDetail(target, examPatternListCopy, savePatExamPatternCopy);
        }
      });
      // 保存用パターンリストをセット
      this.setSavePatExamPattern(savePatExamPatternCopy);

      // カウントの文字色設定
      this.updateEditScheduleStatusStore({
        targetDateList: editedDate,
        examSetTargetList: [patId],
      });
    },
    // 保存処理
    async saveRecord() {
      if (!validateSelectDoctor(this.selectDoctor)) return;

      // 保存用のデータ作成、チェック処理
      const saveData = checkAndCreateSaveExamData(this.selectDoctor);
      if (!(await confirmCheckResult(saveData))) return;

      this.executeUpload(saveData.request, "save");
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    confirmResult() {
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
    // 保存実施
    async executeUpload(request, type) {
      await executeUploadTemplete(
        this.updateRecordList(request),
        () => {
          // 再表示
          this.showCalendar(type);
        },
        "ExamRequestDetailComponent.vue",
        "executeUpload",
        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
        this.messageDialogInfo
        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
        );
    },
    // カレンダークリック時の処理
    editSchedule(celObj, setDate) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkExamAuthorized()) return;
      if (this.isOtherFacility(celObj)) return;

      let targetObj = this.getEditExamRequestList.filter(function(item){
          if (item.patId == celObj.patId) return true;
        });

      if (!celObj.headerflg) {

        // 日付定義がない場合は追加
        if (targetObj[0]["data"][setDate] === void 0) {
          targetObj[0]["data"][setDate] = 0;
        }

        // 締切フラグの設定
        let deadlineFlg = "0";
        if (this.getDeadlineCondition.deadlineFlg) {
          if (dayjs(getDeadlineDate(this.getDeadlineCondition)).isAfter(dayjs(setDate))) {
            deadlineFlg = "1";
          }
        }

        // クリックされたセルの状態によって、フラグを更新する
        switch(targetObj[0].examItemSet[celObj.regOrderClass][celObj.examSetCd]["data"][setDate]) {
          case CANCEL:
            // 中止指示の場合は、中止指示をキャンセル
            targetObj[0]["data"][setDate] += 1;
            targetObj[0].examItemSet[celObj.regOrderClass][celObj.examSetCd]["data"][setDate] = SAVED;
            break;
          case SAVED:
            // 処理対象が「結果あり」の時はメッセージを出力
            if (celObj.examStatus[setDate] && celObj.examStatus[setDate] === "1") {
              this.$ons.notification.confirm({
                // title: "結果あり予定の中止",
                title: DIALOG_MESSAGES[13000164].title,
                // message: 結果が存在する検査予定を中止しようとしています。中止してよろしいですか？",
                message: messageFormat(DIALOG_MESSAGES[13000164].message),
                callback: answer => {
                  if (answer === 1) {
                    // 依頼ありの場合、中止指示にする
                    targetObj[0]["data"][setDate] -= 1;
                    targetObj[0].examItemSet[celObj.regOrderClass][celObj.examSetCd]["data"][setDate] = CANCEL;
                  }
                }
              });
            } else {
              // 依頼ありの場合、中止指示にする
              targetObj[0]["data"][setDate] -= 1;
              targetObj[0].examItemSet[celObj.regOrderClass][celObj.examSetCd]["data"][setDate] = CANCEL;
            }

            break;
          case ADD:
          case ADD_WARNING:
            // 未保存の依頼があった場合、削除する
            targetObj[0]["data"][setDate] -= 1;
            delete targetObj[0].examItemSet[celObj.regOrderClass][celObj.examSetCd]["data"][setDate];
            break;
          default: {
            // 空白欄：依頼を追加する
            targetObj[0]["data"][setDate] += 1;
            const flg = hasScheduleOnTargetDate(celObj.patId, setDate) ? ADD : ADD_WARNING;
            targetObj[0].examItemSet[celObj.regOrderClass][celObj.examSetCd]["data"][setDate] = flg;
            targetObj[0].examItemSet[celObj.regOrderClass][celObj.examSetCd]["status"][setDate] = "0";
            targetObj[0].examItemSet[celObj.regOrderClass][celObj.examSetCd]["isLock"][setDate] = deadlineFlg;
            break;
          }
        }
      } else {
        Object.keys(targetObj[0].examItemSet).forEach(regOrderClassKey => {
          Object.keys(targetObj[0].examItemSet[regOrderClassKey]).forEach(examSetCdKey => {
            const examItem = targetObj[0].examItemSet[regOrderClassKey][examSetCdKey];
            const cellFacility = examItem.facilityCd && examItem.facilityCd[setDate];
            if (cellFacility && cellFacility !== this.getFacilityCd) {
              return;
            }
            // クリックされたセルの状態によって、フラグを更新する
            switch(examItem["data"][setDate]) {
              case SAVED: {
                // 依頼ありの場合、中止指示にする
                targetObj[0]["data"][setDate] -=  1;
                examItem["data"][setDate] = CANCEL;
                break;
              }
              case ADD:
              case ADD_WARNING: {
                // 未保存の依頼があった場合、削除する
                targetObj[0]["data"][setDate] -= 1;
                delete examItem["data"][setDate];
              }
            }
          })
        })
      }
      // this.getEditExamRequestListの要素内の情報を更新したリアクションを起こさせる
      this.getEditExamRequestList.splice();

      // カウントの文字色設定
      this.updateEditScheduleStatusStore({"targetDateList": [setDate], "examSetTargetList": [celObj.patId]});
    },

    getPatExamPatternFiltered(celObj, setData) {
      let { patId } = celObj;
      if (patId) patId = String(patId);
      const { examPattern, examWeek } = setData;
      return (patId && examPattern && examWeek && this.getPatExamPatternList)
        ? this.getPatExamPatternList.filter(item => (
          item.status !== CANCEL
          && patId === String(item.patId)
          && examPattern === item.examPattern
          && examWeek === item.examWeek
          && this.getFacilityCd === item.facilityCd))
        : [];
    },
    // 患者名行のパターン列の表示用データを生成：スタイル
    getPatRowCellStyle(celObj, setData) {
      const patExamPatternFiltered = this.getPatExamPatternFiltered(celObj, setData);
      if (!patExamPatternFiltered.length) return;

      // 予定有無を判別して文字色を変える
      const targetExamPattern = patExamPatternFiltered.pop();
      const fontColor = hasTreatmentPatternOnWeek(targetExamPattern)
        ? FONTCOLOR_HAS_SCHEDULE
        : FONTCOLOR_HAS_NOT_SCHEDULE;
      return {
        "font-weight": "bold",
        color: fontColor,
      };
    },
    // 患者名行のパターン列の表示用データを生成：件数
    getPatRowCellNumber(celObj, setData) {
      const patExamPatternFiltered = this.getPatExamPatternFiltered(celObj, setData);
      if (!patExamPatternFiltered.length) return;

      return patExamPatternFiltered.length;
    },

    // 患者名行以外の日付列の表示用データを生成
    getImgAttributesForDate: getExamCellImgAttributesByDate,
    // 患者名行以外のパターン列の表示用データを生成
    getImgAttributesForPattern(celObj, setData) {
      const imgAttrs = {
        src: "",
        class: "",
        style: "",
      };
      let { patId, examSetCd, regOrderClass } = celObj;
      if (patId) patId = String(patId);
      if (examSetCd) examSetCd = String(examSetCd);
      if (regOrderClass) regOrderClass = String(regOrderClass);
      const { examPattern, examWeek } = setData;
      const targetExamPattern = (
        patId && examSetCd && regOrderClass && examPattern && examWeek) && this.getPatExamPatternList.filter(item => (
        patId === String(item.patId)
        && examSetCd === String(item.orderExamSetCd)
        && regOrderClass === String(item.regOrderClass)
        && examPattern === item.examPattern
        && examWeek === item.examWeek)).pop();
      if (targetExamPattern) {
        // 様々な状況のアイコン変化を補足する
        switch (targetExamPattern.status) {
          case CANCEL:
            // 予定有無を判別して画像を変える
            if (hasTreatmentPatternOnWeek(targetExamPattern)) {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/exam-request/32-32_0.png"),
                class: "symbol-request-cancel td-img",
              });
            } else {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/exam-request/32-32_4.png"),
                class: "symbol-request-cancel td-img",
              });
            }
            break;
          case SAVED:
            // 予定有無を判別して画像を変える
            if (hasTreatmentPatternOnWeek(targetExamPattern)) {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/exam-request/32-32_2.png"),
                class: "symbol-request-saved td-img",
                style: `background-color: ${FILLCOLOR_DEFAULT};`,
              });
            } else {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/exam-request/32-32_3.png"),
                class: "symbol-request-saved td-img",
                style: `background-color: ${FILLCOLOR_DEFAULT};`,
              });
            }
            break;
          case ADD:
            // 予定有無を判別して画像を変える
            if (hasTreatmentPatternOnWeek(targetExamPattern)) {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/exam-request/32-32_2.png"),
                class: "symbol-request-unsaved td-img",
                style: `background-color: ${FILLCOLOR_DEFAULT};`,
              });
            } else {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/exam-request/32-32_3.png"),
                class: "symbol-request-unsaved td-img",
                style: `background-color: ${FILLCOLOR_DEFAULT};`,
              });
            }
            break;
        }
      }
      return imgAttrs;
    },

    fontColor(celObj, setDate = null) {
      if (setDate == null) {
        setDate = celObj;
        celObj = null;
      }
      const rtn = {};
      if (celObj?.facilityCd && this.isOtherFacility(celObj)) {
        rtn["background-color"] = "#9c9c9c";
        return rtn;
      }
      const dateCurrent = formatToYyyymmdd();
      if (setDate && dayjs(setDate).isBefore(dateCurrent)) {
        rtn["background-color"] = BACKGROUND_COLUMN_PAST_DAY;
      }
      if (this.getCalendarCheckedDate != null) {
        this.changeScroll();
      }
      return rtn;
    },
    // 編集されているセルを示す緑色をセルに付与する
    addEditedColor(celObj, setDate) {
      if (!celObj.headerflg && this.isOtherFacility(celObj)) {
        return ["other-facility-disabled"];
      }
      return this.chkCellEdit(celObj?.examData[setDate]);
    },
    // カウント文字の文字色（パターン列）
    fontColorPatternColumn(celObj) {
      const rtn = {};
      if (celObj.headerflg) {
        // 患者名行
        rtn["background-color"] = BACKGROUND_ROW_PATNAME;
      } else if (celObj.facilityCd && this.isOtherFacility(celObj)) {
        rtn["background-color"] = "#9c9c9c";
      }
      return rtn;
    },
    // 編集されているセルを示す緑色をセルに付与する（パターン列）
    addEditedColorPatternColumn(celObj, setData) {
      let classNames = [];

      // 患者別画面には患者名行は存在しないはずなので処理不要
      if (celObj.headerflg) return classNames;

      let { patId, examSetCd, regOrderClass } = celObj;
      if (patId) patId = String(patId);
      if (examSetCd) examSetCd = String(examSetCd);
      if (regOrderClass) regOrderClass = String(regOrderClass);
      let { examPattern, examWeek } = setData;
      if (examPattern) examPattern = String(examPattern);
      if (examWeek) examWeek = String(examWeek);
      const targetExamPattern = this.getPatExamPatternList.filter(item => (
        patId === String(item.patId)
        && examSetCd === String(item.orderExamSetCd)
        && regOrderClass === String(item.regOrderClass)
        && examPattern === String(item.examPattern)
        && examWeek === String(item.examWeek))).pop();
      if (targetExamPattern) {
        classNames = this.chkCellEdit(targetExamPattern.status);
      }
      return classNames;
    },
    // 編集状態の判定
    chkCellEdit(editFlg) {
      return [ADD, ADD_WARNING, CANCEL].includes(editFlg) ? ["exam-edited-cell"] : [];
    },
    // フォーカスアウト時のチェック処理：指示期間（開始)
    checkInputStartDate() {
      this.checkInputDateCore("startDate");
    },
    // フォーカスアウト時のチェック処理：指示期間（終了）
    checkInputEndDate() {
      this.checkInputDateCore("endDate");
    },
    checkInputDateCore(conditionName) {
      const condition = this.condition;
      const inputDate = condition[conditionName] ? dayjs(condition[conditionName]) : "";
      if (inputDate && (!inputDate.isValid() || inputDate.isAfter(this.getSchExtEndDate))) {
        // 入力された日付が存在しないか、最大値より未来の場合、最大値を表示する
        condition[conditionName] = this.getSchExtEndDate;
      } else if (!inputDate) {
        // 手で入力消去された場合、日付をクリア
        condition[conditionName] = "";
      }
      this.redisplay();
    },
    // クリアボタン処理：指示期間（開始)
    clearInputStartDate() {
      this.condition.startDate = "";
      this.redisplay();
    },
    // クリアボタン処理：指示期間（終了）
    clearInputEndDate() {
      this.condition.endDate = "";
      this.redisplay();
    },
    modifyConditionDate(conditionName) {
      this.modifyInputDate({ condition: this.condition, conditionName });
    },
    // 再表示処理
    redisplay() {
      const condition = this.condition;

      if (this.isRouteGamenFlg) {
        this.isRouteGamenFlg = false;
        const treatDate = this.getTreatBaseDate[0].treatDate.replaceAll("/", "-");
        condition.startDate = treatDate;
        condition.endDate = treatDate;
      }

      // 日付無指定の場合は無期限とする
      const startDate = condition.startDate ? condition.startDate.replace(/-/g, "") : "";
      const endDate = condition.endDate ? condition.endDate.replace(/-/g, "") : "";
      const dummyDate = formatToInputDate();
      condition.startDate = startDate ? formatToInputDate(startDate, "YYYYMMDD") : dummyDate;
      condition.endDate = endDate ? formatToInputDate(endDate, "YYYYMMDD") : dummyDate;
      this.$nextTick(() => {
        if (!startDate) {
          condition.startDate = "";
        }
        if (!endDate) {
          condition.endDate = "";
        }
        // 日付は前回と同じ範囲か
        if (
          startDate !== this.getStartToEndDate.showStartDate
          || endDate !== this.getStartToEndDate.showEndDate) {
          this.updateStartToEndDate({
            showStartDate: startDate,
            showEndDate: endDate,
          });
        }
      });
    },
    // クリアボタン処理
    async clear() {
      if (await this.controller.confirmAllowDiscardChangesForRefresh()) {
        // キャンセルされなかった場合
        this.exeClear("clear");
      }
    },
    // クリア処理
    exeClear(type) {
      this.showCalendar(type);
    },
    // データを取得してカレンダーに表示する
    showCalendar(type) {
      if (!type && this.isChanged) return;

      // 共通ローダー:表示開始
      this.startLoadingScreen();
      this.selectedPatId = this.selectedPat?.pat_personal_main.pat_id || null;

      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      store.dispatch("report/getMstReport", {
        funcCd: "02102",
        printFlag: this.selectedPatId ? 1 : null,
        selectedPatId: this.patInfoSelectedPatId
      });
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end

      // 依頼データの取得
      this.searchExamRequest({
        patIdList: this.patIdList,
        startDate: "",
        endDate: this.condition.endDate.replace(/-/g, "/"),
        patientShareMode: (
          this.getIsOtherFacility === false
          || (this.getOtherFacilityCd !== null && this.getOtherFacilityCd !== this.getFacilityCd)
        ) ? 1 : this.getPatientShareMode,
      }).then(() => {
        // 共通ローダー:表示終了
        this.finishLoadingScreen();
      }).catch(error => {
        getErrorMessage("ExamRequestDetailComponent.vue", "showCalendar", error);
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
    updatePatMainList() {
      this.getPatMainList(this.patIdList);
      // patMainListの更新と並行してgetSchExtEndDateの更新も行う
      this.updateMaxDate();
    },
    // 表示期間の日付入力の上限を設定
    async updateMaxDate() {
      await this.getMinSchExtEndDate({
        facilityCd: this.getFacilityCd,
        patIdList: this.patIdList,
      }).catch(error => {
        getErrorMessage("ExamRequestDetailComponent.vue", "updateMaxDate", error);
        throw error;
      });
      // 表示期間の入力状態を更新
      this.modifyConditionDate("startDate");
      this.modifyConditionDate("endDate");
      this.redisplay();
    },
    // dropDownを開いた時にデータに応じて表示枠を広げる
    addMaxContentStyle(event) {
      this.onIndUserDropdownOpen(event);
      this.$nextTick(() => {
        setKendoPopupSurfaceStyles(event, { width: "max-content", bottom: "0px" }, this.$el);
        this.onIndUserDropdownOpen(event);
      });
    },
    // 検査パターンセルクリック時の処理
    editPatternCell(celObj, setData) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkExamAuthorized()) return;

      const savePatExamPatternCopy = [...this.getSavePatExamPattern];
      let { patId, examSetCd, regOrderClass } = celObj;
      if (patId) patId = String(patId);
      if (examSetCd) examSetCd = String(examSetCd);
      if (regOrderClass) regOrderClass = String(regOrderClass);
      const { examPattern, examWeek } = setData;
      // 処理を実行する検査パターンをフィルタリング
      const targetList = this.getPatExamPatternList.filter(item => {
        if (celObj.facilityCd && celObj.facilityCd !== this.getFacilityCd) {
          return false;
        }
        if (!celObj.headerflg) {
          return patId === String(item.patId)
            && examSetCd === String(item.orderExamSetCd)
            && regOrderClass === String(item.regOrderClass)
            && examPattern === item.examPattern
            && examWeek === item.examWeek;
        }
        return item.status !== CANCEL
          && patId === String(item.patId)
          && examPattern === item.examPattern
          && examWeek === item.examWeek
          && this.getFacilityCd === item.facilityCd;
      });

      // フィルタリングされた検査パターンの中から中止されているものを取得
      const cancelLength = targetList.filter(item => item.status === CANCEL).length;
      const unified = (!cancelLength || cancelLength === targetList.length);
      // 中止切り替え処理
      targetList.forEach(target => {
        // 処理対象の整合性チェック(中止された後に同間隔同曜日の異なる時刻のパターンが追加された場合を考慮)
        // 対象の中にキャンセルとキャンセルでないパターンが含まれている場合、すべてキャンセルにする
        if (unified || target.status !== CANCEL) {
          this.editPatternDetail(target, targetList, savePatExamPatternCopy);
        }
      });
      // 保存用パターンリストをセット
      this.setSavePatExamPattern(savePatExamPatternCopy);
    },

    // 検査パターンヘッダークリック時の処理
    editPatternHeader(setData) {
      const examPatternListCopy = [...this.getPatExamPatternList];
      const savePatExamPatternCopy = [...this.getSavePatExamPattern];
      examPatternListCopy.forEach(target => {
        if (
          target.status !== CANCEL
          && setData.examPattern && setData.examPattern === target.examPattern
          && setData.examWeek && setData.examWeek === target.examWeek
          && target.facilityCd === this.getFacilityCd) {
          this.editPatternDetail(target, examPatternListCopy, savePatExamPatternCopy);
        }
      });
      // 保存用パターンリストをセット
      this.setSavePatExamPattern(savePatExamPatternCopy);
    },

    // 検査パターン編集処理
    editPatternDetail(target, examPatternListCopy, savePatExamPatternCopy) {
      switch(target.status) {
        case CANCEL: {

          // 保存済でキャンセルされたパターンをリストから検索
          const wasSaved =
            examPatternListCopy.some(item => {
              return item.status === CANCEL && item.examPatternCd &&
                      item.examPatternCd.toString() === target.examPatternCd.toString()
            })
          if (wasSaved) {
            // 保存用のパターンリストからキャンセルされたパターンを検索
            const wasSavedIndex =
              savePatExamPatternCopy.findIndex(item => {
                  return item.status === CANCEL && item.examPatternCd &&
                      item.examPatternCd.toString() === target.examPatternCd.toString()
              })
            // ステータスをSAVEDにして削除フラグを0にする
            target.status = SAVED;
            target.isDel = 0;
            // 保存用のパターンリストから対象を削除
            if (wasSavedIndex >= 0) savePatExamPatternCopy.splice(wasSavedIndex, 1);
            break;
          }
          // 新規追加でキャンセルされたパターンをリストから検索
          const wasAdd =
            examPatternListCopy.some(item => {
              return item.status === CANCEL &&
                      item.patId.toString() === target.patId.toString() &&
                      item.orderExamSetCd.toString() === target.orderExamSetCd.toString() &&
                      item.regOrderClass.toString() === target.regOrderClass.toString() &&
                      item.examPattern === target.examPattern &&
                      item.examWeek === target.examWeek
            })
          if (wasAdd) {
            // ステータスをADDにする
            target.status = ADD;
            // 保存用のパターンリストに対象を追加
            savePatExamPatternCopy.push(target);
            break;
          }
          break;
        }
        case SAVED: {
          // ステータスをCANCELににて削除フラグをたてる
          target.status = CANCEL;
          target.isDel = 1;
          // 保存用のパターンリストに追加する
          savePatExamPatternCopy.push(target);
          break;
        }
        case ADD: {

          // 保存用のパターンリストから新規追加のパターンを削除する
          const saveSpliceIndex =
            savePatExamPatternCopy.findIndex(item => {
              return item.status === ADD &&
                      item.patId.toString() === target.patId.toString() &&
                      item.orderExamSetCd.toString() === target.orderExamSetCd.toString() &&
                      item.regOrderClass.toString() === target.regOrderClass.toString() &&
                      item.examPattern === target.examPattern &&
                      item.examWeek === target.examWeek
            })
          if (saveSpliceIndex >= 0) savePatExamPatternCopy.splice(saveSpliceIndex, 1);

          // 表示用のパターンリストから新規追加のパターンを削除する
          const examListSpliceIndex =
            this.getPatExamPatternList.findIndex(item => {
                return item.status === ADD &&
                  item.patId.toString() === target.patId.toString() &&
                  item.orderExamSetCd.toString() === target.orderExamSetCd.toString() &&
                  item.regOrderClass.toString() === target.regOrderClass.toString() &&
                  item.examPattern === target.examPattern &&
                  item.examWeek === target.examWeek
            })
          if (examListSpliceIndex >= 0) this.getPatExamPatternList.splice(examListSpliceIndex, 1);

          break;
        }
      }
    },
    changeScroll() {
      this.$nextTick(() => {
        const elements = Array.from(queryScopedSelector(".grid-record-list", this.$el || this)?.getElementsByTagName("th") || []);
        const target = elements.find(element => (
          dayjs(element.outerText).format("YYYY/MM/DD").indexOf(this.getCalendarCheckedDate) !== -1));
        if (target) {
          this.examRequesttable.scrollTop = target.offsetTop - 42;
        }
      });
    },
    async refresh() {
      if (await this.controller.confirmAllowDiscardChangesForRefresh()) {
        // キャンセルされなかった場合
        this.exeClear("refresh");
      }
    },
    showDelExam(cd) {
      const setCd = Number(cd);
      if (this.dispExamSet.includes(setCd)) {
        return MASTER_DELETE_DISPLAY.DELETED;
      }else if (this.delExamSetItem.includes(setCd)) {
        return MASTER_DELETE_DISPLAY.INCLUDE_DELETED;
      }
      return "";
    },
    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
    showExamName(cd) {
      const setNameObj = this.getExamSetName.find(item => item.examSetCd == cd);
      if (setNameObj) {
        return setNameObj.examSetName;
      }
      return "";
    },
    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end

    isOtherFacility(listDate) {
      return !!listDate?.facilityCd && listDate.facilityCd != this.getFacilityCd;
    },
    loadOtherFacilityExamSet(facilityCd, patId) {
      if (!facilityCd || this.otherFacilityCache[facilityCd]) return;
      const selectedPatId = this.patInfoSelectedPatId ?? patId;
      sendRequestAllExamSetListByFacility(facilityCd, selectedPatId).then(response => {
        const dispExamSet = [];
        const getExamSetName = [];
        const delExamSetItem = [];
        response.data.forEach(item => {
          if (item.isDisp === "0") {
            dispExamSet.push(item.examSetCd);
          }
          getExamSetName.push(item);
          const setItems = JSON.parse(item.examItemInfo);
          setItems.forEach(setItem => {
            if (this.dispExamSetItem.includes(Number(setItem.exam_item_cd))) {
              delExamSetItem.push(item.examSetCd);
            }
          });
        });
        this.otherFacilityCache = {
          ...this.otherFacilityCache,
          [facilityCd]: {
            dispExamSet,
            getExamSetName,
            delExamSetItem,
          },
        };
      });
    },
    buildOtherFacilityText(row) {
      const facilityCd = row.facilityCd;
      this.loadOtherFacilityExamSet(facilityCd, row.patId);
      const cache = this.otherFacilityCache[facilityCd];
      if (!cache) return "";
      const setCd = Number(row.examSetCd);
      let delText = "";
      if (cache.dispExamSet.includes(setCd)) {
        delText = MASTER_DELETE_DISPLAY.DELETED;
      } else if (cache.delExamSetItem.includes(setCd)) {
        delText = MASTER_DELETE_DISPLAY.INCLUDE_DELETED;
      }
      const exam = cache.getExamSetName.find(item => item.examSetCd == row.examSetCd);
      const name = exam ? exam.examSetName : "";
      return delText + name + this.showRegOrderClass[row.regOrderClass];
    },

    /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date);
    },

    async setSelectedPatHeader(selectedPatId) {
      await this.executeWithLoadingScreen(async () => {
        try {
          await this.clearSelectedPatToHeader();
          if (selectedPatId === null) {
            // ？？？？患者
            await this.setIsNullPat(true);
          } else {
            await this.selectPatToHeader(selectedPatId);
          }
        } catch {
          throw new Error("[ExamRequestDetailComponent.vue]setSelectedPatHeader(): 患者選択失敗");
        }
      });
    },
  },
  watch: {
    async selectedPat() {
      if (this.ignoreWatchSelectedPatId) return;
      if (this.selectedPat == null) return;
      // PatHeaderのcreatedでのselectPatによるリアクション処理中で、表示中の患者と同じ場合は処理しない
      if (this.inSelectPatAtPatHeaderCreated && this.selectedPat.pat_personal_main.pat_id === this.selectedPatId) return;

      const result = await this.controller.confirmAllowDiscardChangesForRefresh();
      // ヘッダで患者情報表示→保存時に選択済患者がクリア→再設定されるので、選択済患者がnullの場合は処理しない
      // this.controller.confirmAllowDiscardChangesForRefresh()をawaitする間にクリアされるので再チェックが必要
      if (this.selectedPat == null) return;
      if (result) {
        // キャンセルされなかった場合
        const newPat = this.selectedPat.pat_personal_main;
        this.setSelectedPatId(newPat.pat_id);
        this.selectedPatId = newPat.pat_id;
        this.selectedPatName = `${newPat.pat_last_name || ""} ${newPat.pat_first_name || ""}`;

        // 処理対処患者を設定
        this.updateExamSetTargetList(this.patIdList);

        // データを取得してカレンダーに表示する
        this.showCalendar("created");
      } else {
        // キャンセルされた場合
        this.ignoreWatchSelectedPatId = true;
        await this.setSelectedPatHeader(this.getSelectedPatId);
        this.ignoreWatchSelectedPatId = false;
      }
      this.updatePatMainList();
    },
    // 表示範囲日付(ヘッダ側の検査セット処理に連動させる)
    getStartToEndDate() {
      const startDate = this.getStartToEndDate.showStartDate ? dayjs(this.getStartToEndDate.showStartDate, "YYYYMMDD").format("YYYY-MM-DD") : "";
      const endDate = this.getStartToEndDate.showEndDate ? dayjs(this.getStartToEndDate.showEndDate, "YYYYMMDD").format("YYYY-MM-DD") : "";
      if (this.condition.startDate !== startDate) {
        this.condition.startDate = startDate;
      }
      if (this.condition.endDate !== endDate) {
        this.condition.endDate = endDate;
      }
    },
    windowHeight() {
      this.calculateGridHeight();
    },
    windowWidth() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    isChanged() {
      this.setIsDataChanged(this.isChanged);
    },
    getTreatBaseDate() {
      this.isRouteGamenFlg = true;
      this.redisplay();
    },
    getPatientShareMode() {
      this.showCalendar();
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    "messageDialogInfo.isDialogVisible"(isShow) {
      this.isUpdating = isShow ? false : this.isUpdating;
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
  },
  created() {
    // 休日マスタの休日を取得
    this.fetchHolidays(this.getFacilityCd);
    
    // 一覧画面のデータが残っている場合があるためクリアしておく
    this.clearSearchedExamRequest();

    sendRequestGetDispExamItemListForFacilityCd(this.getFacilityCd, this.patInfoSelectedPatId).then(response => {
      this.dispExamSetItem = response.data;
    });
    sendRequestGetMstExamSetList(this.getFacilityCd, this.patInfoSelectedPatId).then(response => {
      response.data.forEach(item => {
        if (item.isDisp === "0") {
          this.dispExamSet.push(item.examSetCd);
        }
        // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
        if (item.isDisp === "1") {
          this.getExamSetName.push(item);
        }
        // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
        const setItems = JSON.parse(item.examItemInfo);
        setItems.forEach(setItem => {
          if (this.dispExamSetItem.includes(Number(setItem.exam_item_cd))) {
            this.delExamSetItem.push(item.examSetCd);
          }
        });
      });
    });

    // 端末判別
    const ua = getScopedWindow(this.$el || this)?.navigator?.userAgent || "";
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }

    // 予実リスト画面へ遷移の場合
    if (this.$route.params.condition && this.$route.params.condition.type == "in_schedule") {
      const treatDate = this.$route.params.condition.treatDate.replaceAll("/", "-");
      this.condition.startDate = treatDate;
      this.condition.endDate = treatDate;
    } else {
      if (this.isStoredShowDate) {
        setShowDateToCondition(this.condition, this.getStartToEndDate);
      } else {
        // 本日の日付をセット
        const setDate = dayjs();
        this.condition.startDate = setDate.format("YYYY-MM-DD");
        this.condition.endDate = setDate.add(3, "months").format("YYYY-MM-DD");
      }
    }

    // 画面遷移パラメータ取得
    const queryParameters = this.getQueryParameters();
    // 日付が指定されて画面遷移した場合、表示期間を指定日付で設定
    if (queryParameters.DATE && queryParameters.DATE !== null) {
      this.condition.startDate = queryParameters.DATE;
      this.condition.endDate = queryParameters.DATE;
    }
    // クエリパラメータをクリアする
    this.setQueryParameters({});

    this.updateStartToEndDate({
      showStartDate: this.condition.startDate.replace(/-/g, ""),
      showEndDate: this.condition.endDate.replace(/-/g, ""),
    });

    // 表示患者ID、名称を取得
    this.selectedPatId = this.getSelectedPatId;
    const patObj = this.searchedPatList.find(item => item.pat_id === this.selectedPatId);
    if (patObj) {
      this.selectedPatName = `${patObj.pat_last_name || ""} ${patObj.pat_first_name || ""}`;
    }

    // 処理対処患者を設定
    this.updateExamSetTargetList(this.patIdList);

    // データを取得してカレンダーに表示する
    this.showCalendar();
    // 指示者ドロップダウンの設定
    this.getIndUserList(
      AUTHORITY_CODES.IND_EXAM_EDIT,
      AUTHORITY_CODES.IND_EXAM_PEDIT).then(response => {
      this.doctorList = response.doctorList;
      this.$nextTick(() => {
        this.selectDoctor = response.iniSelectId;
      });
    });
    /**
     * NOTE: 
     * 保存処理でリクエストパラメータを生成する際に、getAllExamSetListで検査セットリストの情報を取得する。
     * 検査依頼一覧を経由すれば値は設定されるが、直接画面遷移した場合は空となるため、空であれば別途取得する
     * @see Function.checkAndCreateSaveExamData
     */
    if (this.getAllExamSetList.length == 0) {
      sendRequestAllExamSetListByFacility(this.getFacilityCd, this.patInfoSelectedPatId).then(({ data }) => this.setAllExamSetList(data));
    }
    // 締切設定を取得
    this.setExamDeadline({
      facilityCd: this.getFacilityCd,
      selectedPatId: this.patInfoSelectedPatId
    });

    this.updatePatMainList();
  },
  mounted() {
    this.$nextTick(() => {
      setTimeout(() => {
        this.calculateGridHeight();
      });
    });
    this.examRequesttable = this.$refs.examrequestrecorddetailgrid;

    EventBus.$on("refresh", this.refresh);
  },
  beforeUnmount() {
    this.clearHolidays(); // storeの休日マスタをクリア
    EventBus.$off("refresh", this.refresh);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style scoped>
#upper-buttons {
  width: 100%;
  margin-top: 3px;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
#bottom-buttons {
  width: 100%;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  justify-content: space-around;
}
.main-content-area {
  min-width: 200px;
}
.upper-buttons-label {
  white-space: nowrap;
  text-align: center;
}
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
.scroll-table {
  width: 100%;
  --height: 500px;
  height: var(--height);
  overflow: auto;
  margin-top: 6px;
  margin-bottom: 5px;
}
td {
  border: solid 1px var(--ntss-list-border-color);
  text-align: center;
}
.grid-record-list {
  border-collapse: collapse;
  width: calc(100vw - 10rem);
  background-color: var(--ntss-list-background-color);
}
.grid-record-list tr {
  display: block;
  float: left;
  height: unset;
}
.grid-record-list th, .grid-record-list td {
  display: block;
  height: 40px;
  padding-top: 0;
  padding-bottom: 0;
  line-height: 40px;
}
.grid-record-list th {
  height: 40px;
  line-height: 40px;
  background-image: unset;
  border-top: 1px solid var(--ntss-list-border-color);
}
.grid-record-list .thead {
  position: sticky;
  left: 0;
  z-index: 2;
}
.grid-record-list .tbody {
  width: 10rem;
  padding: 0 5px;
}
.ntss-list-header-th-sticky {
  left: 0;
  top: unset;
  z-index: 1;
  background-image: -webkit-linear-gradient(rgba(255, 255, 255, .3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, .1) 100%);
  background-image: linear-gradient(rgba(255, 255, 255, .3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, .1) 100%);
}
.label:hover {
  /* マウスオーバー時の背景色を指定する */
  background-color: #31a9ee;
}

.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 30%; /* ボックスの横幅を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  background-color: #87cefa; /* 背景色を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  margin: 15px 0px;
  white-space: nowrap;
}
.col-sticky-name,
.col-sticky-first {
  top: 0;
  left: unset;
  text-align: unset;
}
.col-sticky-name {
  z-index: 1;
  min-width: 4em;
}
.col-sticky-first {
  z-index: 2;
  background-image: -webkit-linear-gradient(rgba(255, 255, 255, .3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, .1) 100%) !important;
  background-image: linear-gradient(rgba(255, 255, 255, .3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, .1) 100%) !important;
  min-width: 10em;
}
.ind-user-selector {
  margin-top: 0.5em;
  width: 15em;
}
.ind-user-selector .selectbox {
  width: 100%;
}
.blood-glucose-wrapper,
.chk-blood-glucose {
  display: flex;
}
span.blood-glucose-wrapper {
  margin-top: 5px;
}
.chk-blood-glucose {
  margin-top: 5px
}
.label-blood-glucose {
  margin-right: 5px;
  line-height: 30px;
}
.exam-control-cell :deep(.td-img) {
  width: 1em;
  height: auto;
  margin-top: 2px;
  /* 背景塗りつぶし用 */
  border-radius: 1em;
  background-color: transparent !important;
}
/* 編集済みセルの背景色 */
.exam-edited-cell::after {
  content: '';
  position: relative;
  top: -100%;
  right: 0;
  bottom: 0;
  left: -1px;
  background-color: #aaffaa55;
  display: block;
  height: 100%;
  width: calc(100% + 2px);
}
.manual-width {
  resize: horizontal;
  overflow: hidden;
}
.other-facility-disabled {
  background-color: #9c9c9c;
  opacity: 0.6;
  pointer-events: none;
}
@media print {
  .ntss-list-header-th-sticky {
    position: sticky !important;
  }
  .scroll-table {
    overflow: hidden !important;
    height: auto !important;
  }
  table.grid-record-list {
    display: table;
  }
  table.scroll-rightmost {
    position: relative;
    float: right;
  }
  #bottom-buttons {
    display: none;
  }
}
</style>
