/**
 * 一般撮影患者個別検査依頼
 */
<template>
  <div class="main-content-area">
    <rad-header-component class="request-header-component" style="font-size: .667em;"/>
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
    <div class="scroll-table" :style="gridHeightStyle" ref="radrequestrecorddetailgrid">
      <!-- 表示テーブル -->
      <table id="grid-header" class="grid-record-list grid-transpose" style="width: max-content;">
        <tbody>
          <tr class="thead">
          <td class="ntss-list-header-th-sticky manual-width col-sticky-first">
            <span>検査日</span>
          </td>
          <td
            v-for="(dateItem, index) in getRadDateListDetail"
            v-show="index > 1"
            :key="index"
            :style="gridHeaderWidth(index, dateItem.date)"
            @click="colListClear(index, dateItem)"
            class="ntss-list-header-th-sticky"
            :class="getStyle(dateItem.date)"
          ><span>{{ dateItem.dateFormat }}</span></td>
        </tr>
        <tr>
          <td
            class="ntss-list-header-th-sticky col-sticky-name manual-width"
            style="padding-left: 1em; padding-right: 1em; white-space: unset;"
          >治療予定</td>
          <td
            v-for="(dateItem, index) in getRadDateListDetail.slice(2)"
            :key="index"
            :style="fontColor(dateItem.date, true)"
          >
            <img v-if="hasScheduleTreatment(dateItem, selectedPatId)" :src="publicAssetPath('img/rad-request/32-32_2.png')" class="symbol-request-saved" style="width: 1em; margin-top: 2px;"/>
          </td>
        </tr>
        <tr
          v-for="(listDate, index) in radRequestDetailListInDisplayPeriod"
          :key="index"
        >
          <!-- 検査セット行 -->
          <!-- mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start-->
          <td
            v-if="!listDate.headerflg"
            class="ntss-list-header-th-sticky col-sticky-name manual-width"
            style="padding-left: 1em; padding-right: 1em; white-space: unset;"
          ><span @click="rowClear(listDate)">{{
            isOtherFacility(listDate)
              ? buildOtherFacilityText(listDate)
              : showRadName(listDate.radSetCd)
          }}</span></td>
          <!-- mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start-->
          <!-- 日付列 -->
          <td
            v-for="(dateTime, index) in getRadDateTimeListNoShap"
            :key="`first-${index}`"
            :style="fontColor(listDate, dateTime, false)"
            :class="addEditedColor(listDate, dateTime)"
            @click="editSchedule(listDate, dateTime)"
            class="examrequest-label rad-control-cell"
          >
            <!-- 患者名行 -->
            <template v-if="listDate.headerflg">
              {{ listDate.radDataDetail[dateTime] || "" }}
            </template>
            <!-- 患者名行以外 -->
            <img v-else v-bind="getImgAttributesForDate(listDate, dateTime)">
          </td>
          <!-- 自動展開列 -->
          <td
            v-for="(data, index) in getRadPatternDetailColumnList"
            :key="`second-${index}`"
            :style="fontColor(listDate)"
            :class="addEditedColorPatternColumn(listDate, data)"
            @click="editPatternCell(listDate, data)"
            class="examrequest-label rad-control-cell"
          >
            <!-- 患者名行以外 -->
            <img v-if="!listDate.headerflg" v-bind="getImgAttributesForPattern(listDate, data)">
          </td>
        </tr>
      
        </tbody>
      </table>
    </div>
    <!-- 下部ボタン部 -->
    <div id="bottom-buttons">
      <v-ons-button
        class="btn2-cancel common-style-cancel-button"
        @click="clear"
        :disabled="!getRadAuthorized()"
      >クリア</v-ons-button>
      <div class="bottom-buttons-div">
        <label class="bottom-buttons-label examrequest-label">指示者</label>
        <kendo-dropdownlist
          v-model="selectDoctor"
          :data-source="doctorList"
          :data-text-field="'fullName'"
          :data-value-field="'user_id'"
          @open="addMaxContentStyle"
          style="height: 2em; margin-right: 5px; width: 11.4em;"
          :disabled="!getRadAuthorized()"
          class="input-style-required"
        />
        <v-ons-button
          class="btn1-execute common-style-ok-button"
          @click="saveRecord"
          :disabled="!isChanged || !getRadAuthorized()"
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
import { getScopedElementsByClassName, queryScopedSelector, getScopedElementById, getScopedUserAgent, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import RadHeaderComponent from "@/components/rad-request/RadRequestHeaderComponent";
import {
  CANCEL,
  SAVED,
  ADD,
  ADD_WARNING,
  BACKGROUND_HEADER_PAST_DAY,
  BACKGROUND_HEADER_TODAY,
  BACKGROUND_COLUMN_PAST_DAY,
  FILLCOLOR_HAS_SCHEDULE,
  FILLCOLOR_HAS_NOT_SCHEDULE,
} from "@/constants/radRequestConstants";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  validateSelectDoctor,
  confirmCheckResult,
  executeUploadTemplete,
  checkAndCreateSaveRadData,
  hasTreatmentPatternOnWeek,
  hasScheduleTreatment,
  ColumnType,
  setShowDateToCondition,
  formatToYyyymmdd,
  formatToInputDate,
  getRadAuthorized,
  checkRadAuthorized,
  confirmIsOk,
  getDefaultSchExtEndDate,
  hasScheduleOnTargetDate,
} from "@/functions/exam-request/ExamRequestFunctions";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { EventBus } from "@/compat/vue/event-bus.js";
import DateInput from "@/components/common/DateInput";
import { sendRequestGetMstRadSetList } from "@/apis/rad-request";
import store from "@/stores";
import { getHolidayStyle } from "@/functions/common/CommonFunctions";
import messageDialog from "@/components/common/message-dialog/MessageDialog.vue";
import { setKendoPopupSurfaceStyles } from "@/functions/common/KendoFunctions";
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
    "rad-header-component": RadHeaderComponent,
    "common-calendar": commonCalender,
    "date-input": DateInput,
  },
  data() {
    return {
      gridHeight: 740,
      radHeaderHeight: 50,
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
      radRequesttable: null,
      ignoreWatchSelectedPatId: false,
      otherFacilityCache: {},
      // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
      getRadSetName: [],
      // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
      scrollQuerySelector: ".scroll-table",
      addClassTargetQuerySelector: ["table.grid-record-list"],
    };
  },
  computed: {
    ...mapGetters("rad-request/list", [
      "isStoredShowDate",
      "getStartToEndDate",
      "getNormalizedStartToEndDate",
      "getDeadlineCondition",
      "getRadDateList",
      "getRadDateListDetail",
      "getRadDateListNoShap",
      "getRadDateTimeListNoShap",
      "getRadRequestDetailList",
      "getEditRadRequestList",
      "getRadRequestListNoShap",
      "getSaveRadRequestList",
      "getRadSetNameList",
      "getSelectedPatId",
      "getRadPatternDetailColumnList",
      "getPatRadPatternList",
      "getSavePatRadPattern",
      "getSchExtEndDate",
      "getTreatBaseDate",
      "getCalendarCheckedDate",
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
      "isDispMenu",
      "getPatientShareMode",
      "getPatientShareFacilityCdMode",
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("exam-request/list", ["patMainList"]),

    // グリッドの高さをCSS変数を利用して書き換える
    gridHeightStyle() {
      return { "--height": `calc(${this.gridHeight}px - ${this.radHeaderHeight + 4}px)` };
    },
    gridHeaderWidth() {
      return (index, date) => {
        const result = {};
        if (index === 0) {
          result["display"] = "none";
        } else if (index === 1) {
          result["width"] = "11.5rem";
        } else {
          result["textAlign"] = "left";
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
      if (!this.getRadAuthorized()) return false;

      let rtn = false;

      // 編集データから検査セット行だけを抽出する
      const kensaObjList = this.getRadRequestListNoShap.filter(item => !item.headerflg);
      // 変更されたデータを確認する
      rtn = kensaObjList.some(kensaObj => {
        // 検査セットが登録されている日付を取得
        const radDataTimeKeys = Object.keys(kensaObj.radDataDetail);
        return radDataTimeKeys.some(key => kensaObj.radDataDetail[key] !== SAVED);
      });

      if (this.getSavePatRadPattern.length) {
        rtn = true;
      }

      return rtn;
    },
    // 表示期間内の放射線検査依頼データ
    radRequestDetailListInDisplayPeriod() {
      const { showStartDate: dateStart, showEndDate: dateEnd } = this.getNormalizedStartToEndDate;
      return this.getRadRequestDetailList.filter(radRequest => {
        // パターンがある行はそのまま出力
        let { patId, radSetCd } = radRequest;
        if (patId) patId = String(patId);
        if (radSetCd) radSetCd = String(radSetCd);
        const hasRadPattern = this.getPatRadPatternList.some(pattern => (
          patId && patId === String(pattern.patId)
          && radSetCd && radSetCd === String(pattern.orderRadSetCd)));
        if (hasRadPattern) return true;

        // 期間内のradDataがあれば出力
        const radDataKeys = Object.keys(radRequest.radData);
        return radDataKeys.some(key => (
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
    ...mapActions("rad-request/list", [
      "clearSearchedRadRequest",
      "searchRadRequest",
      "updateRecordList",
      "setRadDeadline",
      "setSelectedPatId",
      "updateStartToEndDate",
      "updateRadSetTargetList",
      "dayAllClearDetail",
      "updateEditScheduleStatusStore",
      "setIsDataChanged",
      "setSavePatRadPattern",
      "getMinSchExtEndDate",
      "modifyInputDate",
    ]),
    ...mapActions("exam-request/list", [
      "getPatMainList",
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    ...mapActions("pat-info", {
      selectPatToHeader: "selectPat",
      clearSelectedPatToHeader: "clearSelectedPat",
      setIsNullPat: "setIsNullPat",
    }),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    getRadAuthorized,
    hasScheduleTreatment,

    // ウインドウ変更時の高さ補正
    calculateGridHeight() {
      // 表示期間などの表示領域
      const upperButtons = getScopedElementById("upper-buttons", this.$el || null);
      const upBtnsHeight = upperButtons.offsetHeight;

      const radHeader = getScopedElementById("rad-header-item", this.$el || null);
      this.radHeaderHeight = radHeader.offsetHeight;

      // 下部ボタンの表示領域
      const bottomButtons = getScopedElementById("bottom-buttons", this.$el || null);
      const btmBtnsHeight = bottomButtons.offsetHeight;

      // 表示期間、表、下部ボタン全体の表示領域
      const mainId = getScopedElementById("main-id", this.$el || null);
      const mainIdHeight = mainId.offsetHeight;

      // 表エリアの高さ (15px引く)
      const gridHeightC = mainIdHeight - upBtnsHeight - btmBtnsHeight - 15;

      // ヘッダ部分の表示設定 (初期状態では非表示、高さ算出時に初めて表示する)
      const gridHeader = getScopedElementById("grid-header", this.$el || null);
      gridHeader.style.visibility = "visible";
      this.gridHeight = gridHeightC;

      // Android対策
      if (this.isAndroid && !this.addedTransitionEvent) {
        // CSSトランジションする要素(button--materialクラス)を取得
        const transitionButtons = getScopedElementsByClassName("button--material", this.$el || null);
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
    // 治療予定欄の表示内容を生成
    showScheduleTreatment(dateItem) {
      return hasScheduleTreatment(dateItem, this.selectedPatId)
        ? `<img src="${publicAssetPath("img/rad-request/32-32_2.png")}" class='symbol-request-saved' style='width: 1em; margin-top: 2px;'/>`
        : "";
    },
    // 日付部をクリックした際に一括中止
    async colListClear(index, data) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkRadAuthorized()) return;

      switch (data.columnType) {
        case ColumnType.Dummy:
          break;
        case ColumnType.Date: {
          const dateFormat = this.getRadDateListDetail[index].dateFormat;
          // title: "更新確認",
          // message: "{dateFormat}の予定を一括中止します、よろしいですか？",
          if (await confirmIsOk(DIALOG_MESSAGES[13000029], dateFormat)) {
            this.dayAllClearDetail({
              targetDateTime: this.getRadDateTimeListNoShap[index - 2],
              facilityCd: this.getFacilityCd,
            });
          }
          break;
        }
        case ColumnType.Pattern: {
          const dateFormat = this.getRadDateListDetail[index].dateFormat;
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
      if (!checkRadAuthorized()) return;
      if (this.isOtherFacility(celObj)) return;

      const { patId, regOrderClass, radSetCd, radDataDetail } = celObj;
      const targetName = this.showRadName(radSetCd);
      // title: "更新確認",
      // message: "本日以降の{targetName}の予定、自動展開データを一括中止します、よろしいですか？",
      if (!(await confirmIsOk(DIALOG_MESSAGES[13000031], targetName))) return;

      const targetObj = this.getEditRadRequestList.find(item => item.patId == patId);
      const tartgetDetail = targetObj.radItemSet[regOrderClass][radSetCd]["dataDetail"];

      // 検査セットが登録されている日時を取得
      const editedDateTime = [];
      const todayMoment = dayjs();
      Object.keys(radDataDetail).forEach(dateTime => {
        // 過去日の依頼は中止対象にしない
        const date = dateTime.split("_")[0];
        if (todayMoment.isAfter(date, "day")) return;

        switch (tartgetDetail[dateTime]) {
          case CANCEL:
            // 中止指示の場合は、そのまま
            break;
          case SAVED: {
            // 依頼ありの場合、中止指示にする
            targetObj.dataDetail[dateTime]--;
            tartgetDetail[dateTime] = CANCEL;
            editedDateTime.push(dateTime);
            break;
          }
          case ADD:
          case ADD_WARNING: {
            // 未保存の依頼があった場合、削除する
            targetObj.dataDetail[dateTime]--;
            delete tartgetDetail[dateTime];
            editedDateTime.push(dateTime);
            break;
          }
        }
      });
      // this.getEditRadRequestListの要素内の情報を更新したリアクションを起こさせる
      this.getEditRadRequestList.splice();

      // 検査パターンの一括中止処理
      const radPatternListCopy = [...this.getPatRadPatternList];
      const savePatRadPatternCopy = [...this.getSavePatRadPattern];
      radPatternListCopy.forEach(target => {
        if (
          target.status !== CANCEL
          && String(target.orderRadSetCd) === String(radSetCd)
          && String(target.patId) === String(patId)) {
          this.editPatternDetail(target, radPatternListCopy, savePatRadPatternCopy);
        }
      });
      // 保存用パターンリストをセット
      this.setSavePatRadPattern(savePatRadPatternCopy);

      // カウントの文字色設定
      this.updateEditScheduleStatusStore({
        targetDateList: [],
        targetDateTimeList: editedDateTime,
        radSetTargetList: [patId],
      });
    },
    // 保存処理
    async saveRecord() {
      if (!validateSelectDoctor(this.selectDoctor)) return;

      const saveData = checkAndCreateSaveRadData(this.selectDoctor);
      if (!(await confirmCheckResult(saveData))) return;

      this.executeUpload(saveData.request);
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    confirmResult() {
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
    // 保存実施
    async executeUpload(request) {
      const params = {
        request,
        isRadDetail: "1",
      };
      await executeUploadTemplete(
        this.updateRecordList(params),
        () => {
          // 再表示
          this.showCalendar();
        },
        "RadRequestDetailComponent.vue",
        "executeUpload",
        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
        this.messageDialogInfo
        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
        );
    },
    // カレンダークリック時の処理
    editSchedule(celObj, setDateTime) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkRadAuthorized()) return;
      if (this.isOtherFacility(celObj)) return;

      const setDate = setDateTime.split("_");
      if (!celObj.headerflg) {

        let targetObj = this.getEditRadRequestList.filter(function(item){
          if (item.patId == celObj.patId) return true;
        });

        // 日付定義がない場合は追加
        if (targetObj[0]["dataDetail"][setDateTime] === void 0) {
          targetObj[0]["dataDetail"][setDateTime] = 0;
        }

        // 締切フラグの設定
        let deadlineFlg = "0";
        if (this.getDeadlineCondition.deadlineFlg) {
          if (dayjs(getDeadlineDate(this.getDeadlineCondition)).isAfter(dayjs(setDateTime.split('_')[0]))) {
            deadlineFlg = "1";
          }
        }

        // クリックされたセルの状態によって、フラグを更新する
        switch(targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][setDateTime]) {
          case CANCEL:
            // 中止指示の場合は、中止指示をキャンセル
            targetObj[0]["dataDetail"][setDateTime] += 1;
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][setDateTime] = SAVED;
            break;
          case SAVED:
            // 処理対象が「結果あり」の時はメッセージを出力
            if (celObj.radStatusDetail[setDateTime] && celObj.radStatusDetail[setDateTime] === "1") {
              this.$ons.notification.confirm({
                // title: "結果あり予定の中止",
                title: DIALOG_MESSAGES[13000165].title,
                // message: "結果が存在する一般撮影検査予定を中止しようとしています。中止してよろしいですか？",
                message: messageFormat(DIALOG_MESSAGES[13000165].message),
                callback: answer => {
                  if (answer === 1) {
                    // 依頼ありの場合、中止指示にする
                    targetObj[0]["dataDetail"][setDateTime] -= 1;
                    targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][setDateTime] = CANCEL;
                  }
                }
              });
            } else {
              // 依頼ありの場合、中止指示にする
              targetObj[0]["dataDetail"][setDateTime] -= 1;
              targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][setDateTime] = CANCEL;
            }
            break;
          case ADD:
          case ADD_WARNING:
            // 未保存の依頼があった場合、削除する
            targetObj[0]["dataDetail"][setDateTime] -= 1;
            delete targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][setDateTime];
            break;
          default: {
            // 空白欄：依頼を追加する
            targetObj[0]["dataDetail"][setDateTime] += 1;
            const flg = hasScheduleOnTargetDate(celObj.patId, setDate[0]) ? ADD : ADD_WARNING;
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][setDateTime] = flg;
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["statusDetail"][setDateTime] = "0";
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["isLock"][setDateTime.split('_')[0]] = deadlineFlg;
            break;
          }
        }
        // this.getEditRadRequestListの要素内の情報を更新したリアクションを起こさせる
        this.getEditRadRequestList.splice();

        // カウントの文字色設定
        this.updateEditScheduleStatusStore({"targetDateList": [setDate[0]], "targetDateTimeList": [setDateTime], "radSetTargetList": [celObj.patId]});
      }
    },

    getImgAttributesForDate(celObj, setDateTime) {
      const imgAttrs = {
        src: "",
        class: "",
        style: "",
      };
      // 患者名行以外
      const { radStatusDetail, nowIsLock, radDataDetail, patId } = celObj;
      const setDate = setDateTime.split("_")[0];
      const setDateDetail = radDataDetail[setDateTime];
      const isLockFlg = radStatusDetail[setDateTime] === "1" || nowIsLock[setDate] === "1";
      switch (setDateDetail) {
        case CANCEL:
          // 予定有無を判別して画像を変える
          if (hasScheduleOnTargetDate(patId, setDate)) {
            Object.assign(imgAttrs, {
              src: publicAssetPath("img/rad-request/32-32_0.png"),
              class: "symbol-request-cancel td-img",
            });
          } else {
            Object.assign(imgAttrs, {
              src: publicAssetPath("img/rad-request/32-32_4.png"),
              class: "symbol-request-cancel td-img",
            });
          }
          break;
        case SAVED:
          // 予定有無を判別して画像を変える
          if (hasScheduleOnTargetDate(patId, setDate)) {
            Object.assign(imgAttrs, {
              src: publicAssetPath("img/rad-request/32-32_2.png"),
              class: "symbol-request-saved td-img",
              style: `background-color: ${isLockFlg ? FILLCOLOR_HAS_SCHEDULE : "inherit"};`,
            });
          } else {
            Object.assign(imgAttrs, {
              src: publicAssetPath("img/rad-request/32-32_3.png"),
              class: "symbol-request-saved td-img",
              style: `background-color: ${isLockFlg ? FILLCOLOR_HAS_NOT_SCHEDULE : "inherit"};`,
            });
          }
          break;
        case ADD:
          Object.assign(imgAttrs, {
            src: publicAssetPath("img/rad-request/32-32_2.png"),
            class: "symbol-request-unsaved td-img",
            style: `background-color: ${isLockFlg ? FILLCOLOR_HAS_SCHEDULE : "inherit"};`,
          });
          break;
        case ADD_WARNING:
          Object.assign(imgAttrs, {
            src: publicAssetPath("img/rad-request/32-32_3.png"),
            class: "symbol-request-noplan td-img",
            style: `background-color: ${isLockFlg ? FILLCOLOR_HAS_NOT_SCHEDULE : "inherit"};`,
          });
          break;
      }
      return imgAttrs;
    },

    getImgAttributesForPattern(celObj, setData) {
      const imgAttrs = {
        src: "",
        class: "",
        style: "",
      };
      let { radSetCd } = celObj;
      if (radSetCd) radSetCd = String(radSetCd);
      let { radPattern, radWeek, radTime } = setData;
      if (radPattern) radPattern = String(radPattern);
      if (radWeek) radWeek = String(radWeek);
      if (radTime) radTime = String(radTime);
      const targetRadPattern = radSetCd && radPattern && radWeek && radTime
        && this.getPatRadPatternList.filter(item => (
          radSetCd === String(item.orderRadSetCd)
          && radPattern === String(item.radPattern)
          && radWeek === String(item.radWeek)
          && radTime === String(item.strRadTime))).pop();
      if (targetRadPattern) {
        // 様々な状況のアイコン変化を補足する
        switch (targetRadPattern.status) {
          case CANCEL:
            // 予定有無を判別して画像を変える
            if (hasTreatmentPatternOnWeek(targetRadPattern)) {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/rad-request/32-32_0.png"),
                class: "symbol-request-cancel td-img",
              });
            } else {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/rad-request/32-32_4.png"),
                class: "symbol-request-cancel td-img",
              });
            }
            break;
          case SAVED:
            // 予定有無を判別して画像を変える
            if (hasTreatmentPatternOnWeek(targetRadPattern)) {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/rad-request/32-32_2.png"),
                class: "symbol-request-saved td-img",
              });
            } else {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/rad-request/32-32_3.png"),
                class: "symbol-request-saved td-img",
              });
            }
            break;
          case ADD:
            // 予定有無を判別して画像を変える
            if (hasTreatmentPatternOnWeek(targetRadPattern)) {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/rad-request/32-32_2.png"),
                class: "symbol-request-unsaved td-img",
              });
            } else {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/rad-request/32-32_3.png"),
                class: "symbol-request-unsaved td-img",
              });
            }
            break;
        }
      }
      return imgAttrs;
    },
    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
    showRadName(cd) {
      const radSet = this.getRadSetName.find(item => cd == item.radSetCd);
      return radSet ? radSet.radSetName : "";
    },
    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
    fontColor(celObj, setDateTime, isGMT) {
      if (typeof celObj !== "object" || celObj === null) {
        isGMT = setDateTime;
        setDateTime = celObj;
        celObj = null;
      }
      const rtn = {};
      if (isGMT) {
        setDateTime = formatToYyyymmdd(setDateTime);
      }
      if (celObj?.facilityCd && this.isOtherFacility(celObj)) {
        rtn["background-color"] = "#9c9c9c";
        return rtn;
      }
      const dateCurrent = formatToYyyymmdd();
      if (setDateTime && setDateTime < dateCurrent) {
        rtn["background-color"] = BACKGROUND_COLUMN_PAST_DAY;
      }
      if (this.getCalendarCheckedDate != null) {
        this.changeScroll();
      }
      return rtn;
    },
    // 編集されているセルを示す緑色をセルに付与する
    addEditedColor(celObj, setDateTime) {
      if (!celObj.headerflg && this.isOtherFacility(celObj)) {
        return ["other-facility-disabled"];
      }
      return this.chkCellEdit(celObj.radDataDetail[setDateTime]);
    },
    // 編集されているセルを示す緑色をセルに付与する（パターン列）
    addEditedColorPatternColumn(celObj, setData) {
      let classNames = [];

      // 患者別画面には患者名行は存在しないはずなので処理不要
      if (celObj.headerflg) return classNames;

      let { patId, radSetCd } = celObj;
      if (patId) patId = String(patId);
      if (radSetCd) radSetCd = String(radSetCd);
      let { radPattern, radWeek, radTime } = setData;
      if (radPattern) radPattern = String(radPattern);
      if (radWeek) radWeek = String(radWeek);
      const targetRadPattern = this.getPatRadPatternList.filter(item => (
        patId && patId === String(item.patId)
        && radSetCd && radSetCd === String(item.orderRadSetCd)
        && radPattern && radPattern === String(item.radPattern)
        && radWeek && radWeek === String(item.radWeek)
        && radTime && radTime === item.strRadTime)).pop();
      if (targetRadPattern) {
        classNames = this.chkCellEdit(targetRadPattern.status);
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
        this.exeClear();
      }
    },
    // クリア処理
    exeClear() {
      this.showCalendar();
    },
    // データを取得してカレンダーに表示する
    showCalendar() {
      // 共通ローダー:表示開始
      this.startLoadingScreen();
      this.selectedPatId = this.selectedPat?.pat_personal_main.pat_id || null;

      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      store.dispatch("report/getMstReport", {
        funcCd: "02202",
        printFlag: this.selectedPatId ? 1 : null,
        selectedPatId: this.patInfoSelectedPatId
      });
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end

      // 依頼データの取得
      this.searchRadRequest({
        patIdList: this.patIdList,
        startDate: "",
        patientShareMode: (
          this.getIsOtherFacility === false
          || (this.getOtherFacilityCd !== null && this.getOtherFacilityCd !== this.getFacilityCd)
        ) ? 1 : this.getPatientShareMode,
      }).then(() => {
        // 共通ローダー:表示終了
        this.finishLoadingScreen();
      }).catch(error => {
        getErrorMessage("RadRequestDetailComponent.vue", "showCalendar", error);
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
        getErrorMessage("RadRequestDetailComponent.vue", "updateMaxDate", error);
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
      if (!checkRadAuthorized()) return;

      // 患者別画面には患者名行は存在しないはずなので処理不要
      if (celObj.headerflg) return;
      const cellFacility = celObj.facilityCd;
      if (cellFacility && cellFacility !== this.getFacilityCd) {
        return;
      }

      const savePatRadPatternCopy = [...this.getSavePatRadPattern];
      let { radSetCd } = celObj;
      if (radSetCd) radSetCd = String(radSetCd);
      let { radPattern, radWeek, radTime } = setData;
      if (radPattern) radPattern = String(radPattern);
      if (radWeek) radWeek = String(radWeek);
      if (radTime) radTime = String(radTime);
      // 処理を実行する検査パターンをフィルタリング
      const targetList = this.getPatRadPatternList.filter(item => (
        radSetCd && radSetCd === String(item.orderRadSetCd)
        && radPattern && radPattern === String(item.radPattern)
        && radWeek && radWeek === String(item.radWeek)
        && radTime && radTime === String(item.strRadTime)
        && item.facilityCd === this.getFacilityCd));
      // フィルタリングされた検査パターンの中から中止されているものを取得
      const cancelLength = targetList.filter(item => item.status === CANCEL).length;
      const unified = (cancelLength === 0 || cancelLength === targetList.length);
      // 中止切り替え処理
      targetList.forEach(target => {
        // 処理対象の整合性チェック(中止された後に同間隔同曜日の異なる時刻のパターンが追加された場合を考慮)
        // 対象の中にキャンセルとキャンセルでないパターンが含まれている場合、すべてキャンセルにする
        if (unified || target.status !== CANCEL) {
          this.editPatternDetail(target, targetList, savePatRadPatternCopy);
        }
      });
      // 保存用パターンリストをセット
      this.setSavePatRadPattern(savePatRadPatternCopy);
    },

    // 検査パターンヘッダークリック時の処理
    editPatternHeader(setData) {
      const radPatternListCopy = [...this.getPatRadPatternList];
      const savePatRadPatternCopy = [...this.getSavePatRadPattern];
      let { radPattern, radWeek, radTime } = setData;
      if (radPattern) radPattern = String(radPattern);
      if (radWeek) radWeek = String(radWeek);
      if (radTime) radTime = String(radTime);
      radPatternListCopy.forEach(target => {
        if (
          target.status !== CANCEL
          && radPattern && radPattern === String(target.radPattern)
          && radWeek && radWeek === String(target.radWeek)
          && radTime && radTime === String(target.strRadTime)
          && target.facilityCd === this.getFacilityCd) {
          this.editPatternDetail(target, radPatternListCopy, savePatRadPatternCopy);
        }
      });
      // 保存用パターンリストをセット
      this.setSavePatRadPattern(savePatRadPatternCopy);
    },

    // 検査パターン編集処理
    editPatternDetail(target, radPatternListCopy, savePatRadPatternCopy) {
      switch(target.status) {
        case CANCEL: {

          // 保存済でキャンセルされたパターンをリストから検索
          const wasSaved =
            radPatternListCopy.some(item => {
              return item.status === CANCEL && item.radPatternCd &&
                      item.radPatternCd.toString() === target.radPatternCd.toString()
            })
          if (wasSaved) {
            // 保存用のパターンリストからキャンセルされたパターンを検索
            const wasSavedIndex =
              savePatRadPatternCopy.findIndex(item => {
                  return item.status === CANCEL && item.radPatternCd &&
                      item.radPatternCd.toString() === target.radPatternCd.toString()
              })
            // ステータスをSAVEDにして削除フラグを0にする
            target.status = SAVED;
            target.isDel = 0;
            // 保存用のパターンリストから対象を削除
            if (wasSavedIndex >= 0) savePatRadPatternCopy.splice(wasSavedIndex, 1);
            break;
          }
          // 新規追加でキャンセルされたパターンをリストから検索
          const wasAdd =
            radPatternListCopy.some(item => {
              return item.status === CANCEL &&
                      item.patId.toString() === target.patId.toString() &&
                      item.orderRadSetCd.toString() === target.orderRadSetCd.toString() &&
                      item.regOrderClass.toString() === target.regOrderClass.toString() &&
                      item.strRadTime === target.strRadTime &&
                      item.radPattern.toString() === target.radPattern.toString() &&
                      item.radWeek.toString() === target.radWeek.toString()
            })
          if (wasAdd) {
            // ステータスをADDにする
            target.status = ADD;
            // 保存用のパターンリストに対象を追加
            savePatRadPatternCopy.push(target);
            break;
          }
          break;
        }
        case SAVED: {
          // ステータスをCANCELににて削除フラグをたてる
          target.status = CANCEL;
          target.isDel = 1;
          // 保存用のパターンリストに追加する
          savePatRadPatternCopy.push(target);
          break;
        }
        case ADD: {

          // 保存用のパターンリストから新規追加のパターンを削除する
          const saveSpliceIndex =
            savePatRadPatternCopy.findIndex(item => {
              return item.status === ADD &&
                      item.patId.toString() === target.patId.toString() &&
                      item.orderRadSetCd.toString() === target.orderRadSetCd.toString() &&
                      item.regOrderClass.toString() === target.regOrderClass.toString() &&
                      item.strRadTime === target.strRadTime &&
                      item.radPattern === target.radPattern &&
                      item.radWeek === target.radWeek
            })
          if (saveSpliceIndex >= 0) savePatRadPatternCopy.splice(saveSpliceIndex, 1);

          // 表示用のパターンリストから新規追加のパターンを削除する
          const radListSpliceIndex =
            this.getPatRadPatternList.findIndex(item => {
                return item.status === ADD &&
                  item.patId.toString() === target.patId.toString() &&
                  item.orderRadSetCd.toString() === target.orderRadSetCd.toString() &&
                  item.regOrderClass.toString() === target.regOrderClass.toString() &&
                  item.strRadTime === target.strRadTime &&
                  item.radPattern === target.radPattern &&
                  item.radWeek === target.radWeek
            })
          if (radListSpliceIndex >= 0) this.getPatRadPatternList.splice(radListSpliceIndex, 1);

          break;
        }
      }
    },
    changeScroll() {
      this.$nextTick(() => {
        const elements = Array.from((queryScopedSelector(".grid-record-list", this.$el || null) || { getElementsByTagName: () => [] }).getElementsByTagName("th"));
        const target = elements.find(element => (
          dayjs(element.outerText).format("YYYY/MM/DD").indexOf(this.getCalendarCheckedDate) !== -1));
        if (target) {
          this.radRequesttable.scrollTop = target.offsetTop - 50;
        }
      });
    },

    /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date);
    },

    isOtherFacility(listDate) {
      return !!listDate?.facilityCd && listDate.facilityCd != this.getFacilityCd;
    },
    loadOtherFacilityExamSet(facilityCd, patId) {
      if (!facilityCd || Object.prototype.hasOwnProperty.call(this.otherFacilityCache, facilityCd)) return;
      this.otherFacilityCache = {
        ...this.otherFacilityCache,
        [facilityCd]: null,
      };
      const selectedPatId = this.patInfoSelectedPatId ?? patId;
      sendRequestGetMstRadSetList(facilityCd, selectedPatId).then(response => {
        const radSetName = response.data.filter(item => item.isDisp === "1");
        this.otherFacilityCache = {
          ...this.otherFacilityCache,
          [facilityCd]: { radSetName },
        };
      }).catch(() => {
        const { [facilityCd]: _removed, ...rest } = this.otherFacilityCache;
        this.otherFacilityCache = rest;
      });
    },
    buildOtherFacilityText(row) {
      const facilityCd = row.facilityCd;
      this.loadOtherFacilityExamSet(facilityCd, row.patId);
      const cache = this.otherFacilityCache[facilityCd];
      if (!cache || !cache.radSetName) return "";
      const rad = cache.radSetName.find(item => item.radSetCd == row.radSetCd);
      return rad ? rad.radSetName : "";
    },

    async refresh() {
      if (await this.controller.confirmAllowDiscardChangesForRefresh()) {
        // キャンセルされなかった場合
        this.exeClear();
      }
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
          throw new Error("[RadRequestDetailComponent.vue]setSelectedPatHeader(): 患者選択失敗");
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
        this.updateRadSetTargetList(this.patIdList);

        // データを取得してカレンダーに表示する
        this.showCalendar();
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
    // 端末判別
    const ua = getScopedUserAgent(this.$el);
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
    
    // 休日マスタの休日を取得
    this.fetchHolidays(this.getFacilityCd);
    
    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
    sendRequestGetMstRadSetList(this.getFacilityCd, this.patInfoSelectedPatId).then(response => {
      response.data.forEach(item => {
        if (item.isDisp === "1") {
          this.getRadSetName.push(item);
        }
      });
    });
    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end

    // 一覧画面のデータが残っている場合があるためクリアしておく
    this.clearSearchedRadRequest();

    // 予実リスト画面へ遷移の場合
    if (this.$route.params.condition && this.$route.params.condition.type == "in_photo") {
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
    this.updateRadSetTargetList(this.patIdList);

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

    // 締切設定を取得
    this.setRadDeadline({
      facilityCd: this.getFacilityCd,
      selectedPatId: this.patInfoSelectedPatId
    });

    this.updatePatMainList();
  },
  mounted() {
    this.$nextTick(() => {
      (getScopedWindow(this.$el) || window).setTimeout(() => {
        this.calculateGridHeight();
      });
    });
    this.radRequesttable = this.$refs.radrequestrecorddetailgrid;

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
tr {
  /* 設定しなくても表示に問題がない高さは自動で確保される */
  height: 31px;
}
td {
  border: solid 1px var(--ntss-list-border-color);
  text-align: center;
}
#upper-buttons {
  width: 100%;
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
  margin-right: 0;
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
.grid-record-list {
  border-collapse: collapse;
  width: calc(100vw - 11.5rem);
  background-color: var(--ntss-list-background-color);
}
.ntss-list-header-th-sticky {
  left: 0;
  top: unset;
  z-index: 3;
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
.col-sticky-first {
  z-index: 6;
  top: 0;
  min-width: 10em;
}
.col-sticky-name {
  z-index: 2;
  top: 0;
  left: unset;
  text-align: unset;
  min-width: 4em;
}
.ind-user-selector {
  margin-top: 0.5em;
  width: 15em;
}
.ind-user-selector .selectbox {
  width: 100%;
}
.grid-transpose tr {
  display: block;
  float: left;
  height: unset;
}
.grid-transpose th, .grid-transpose td {
  display: block;
  height: 48px;
  padding-top: 0;
  padding-bottom: 0;
  line-height: 48px;
}
.grid-transpose th {
  height: 49px;
  line-height: 48px;
  background-image: unset;
  width: 11.5rem;
}
.grid-transpose .thead {
  position: sticky;
  left: 0;
  z-index: 6;
}
.grid-transpose .tbody {
  width: 11.5rem;
  padding: 0 5px;
}
.rad-control-cell :deep(.td-img) {
  width: 1em;
  margin-top: 2px;
  /* 背景塗りつぶし用 */
  border-radius: 1em;
}
@media screen and (max-width: 360px) {
  .bottom-buttons-div {
    width: 18.0em;
    margin: 0px 0px 0px auto;
    display: flex;
    align-items: center;
    margin-right: 0px;
  }
  .common-style-cancel-button {
    width: 60px;
  }
  .common-style-ok-button {
    width: 60px;
  }
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
