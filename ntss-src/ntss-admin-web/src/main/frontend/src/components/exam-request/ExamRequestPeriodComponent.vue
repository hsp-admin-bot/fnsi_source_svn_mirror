/**
 * 検査依頼用（期間）メイン
 */
<template>
  <div class="main-content-area">
    <!-- 上部ボタン部 -->
    <div id="upper-buttons">

      <div class="ntss-button-group">
        <input
          id="show-period-display"
          type="radio"
          class="identification"
          name="periodType"
          :value="1"
          v-model="periodType"
        />
        <label for="show-period-display" class="label first-of-type_period">期間</label>
        <input
          id="show-day-display"
          type="radio"
          class="identification"
          name="periodType"
          :value="2"
          v-model="periodType"
        />
        <label for="show-day-display" class="label last-of-type">一日</label>
      </div>

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
      <!--
        #9101 再表示ボタン削除 にて、表示期間の×ボタンクリックでシステム日付が表示されてしまう異常を回避する為、
        上記common-calenderのパラメータから以下1行を削除(コメントアウト)します。
      -->
      <!--  @input="chkCalenDate('startDate')" -->
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
      <!--
        #9101 再表示ボタン削除 にて、表示期間の×ボタンクリックでシステム日付が表示されてしまう異常を回避する為、
        上記common-calenderのパラメータから以下1行を削除(コメントアウト)します。
      -->
      <!-- @input="chkCalenDate('endDate')" -->
      <div class="ntss-button-group">
        <input
          type="radio"
          class="identification"
          name="identification"
          value="1"
          v-model="chkDetailSimple"
          id="show-details-display"
          @click="setShowDetailsDisplay(true); reDisplayCheck();"
          checked="checked"
        >
        <label for="show-details-display" class="label first-of-type">詳細</label>
        <input
          type="radio"
          class="identification"
          name="identification"
          value="2"
          v-model="chkDetailSimple"
          id="show-simple-display"
          @click="setShowDetailsDisplay(false); reDisplayCheck();"
        >
        <label for="show-simple-display" class="label last-of-type">簡易</label>
      </div>
    </div>
    <!-- テーブルエリア -->
    <div class="scroll-table" :style="gridHeightStyle">
      <!-- 表示テーブル -->
      <table class="grid-record-list" style="width: max-content;">
        <thead>
          <tr>
            <th
              class="ntss-list-header-th-sticky col-sticky-check check-box manual-width"
              :style="gridHeaderInner"
            >
              <v-ons-checkbox
                v-model="allCheckFlg"
                @change="setAllCheck(false)"
                @click.stop
                :disabled="!getExamAuthorized()"
              />
            </th>
            <th
              class="ntss-list-header-th-sticky col-sticky-id manual-width"
              style="top: 0px;"
              :style="gridHeaderInner"
              :class="sortedClass('hosp_pat_id')"
              v-show="isShowHospPatId"
            ><span @click="showPopover($event, 'hosp_pat_id')">患者ID</span></th>
            <th
              class="ntss-list-header-th-sticky col-sticky-names manual-width"
              style="top: 0px;"
              :style="gridHeaderInner"
              :class="[!isShowHospPatId ? 'col-sticky-id' : 'col-sticky-name', sortedClass('pat_name')]"
            ><span @click="showPopover($event, 'pat_name')">患者名</span></th>
            <th
              class="ntss-list-header-th-sticky manual-width"
              style="top: 0px;"
              :style="gridHeaderInner"
              :class="[!isShowHospPatId ? 'col-sticky-blood-glucose-exams' : 'col-sticky-blood-glucose-exam', sortedClass('is_blood_suger_exam')]"
              v-show="isShowBloodGlucoseExam"
            ><span @click="showPopover($event, 'is_blood_suger_exam')">血糖検査</span></th>
            <template v-for="(data, index) in getExamDateList">
              <th
                v-if="index > (1 + (isShowHospPatId ? 1 : 0) + (isShowBloodGlucoseExam ? 1 : 0))"
                :key="index"
                :style="gridHeaderWidth(index, data.date)"
                :class="sortedClass('date', data)"
                class="ntss-list-header-th-sticky manual-width"
              ><span :class="getStyle(data.date)" @click="showPopover($event, 'date', index, data)">{{ data.dateFormat }}</span></th>
            </template>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(listDate, index) in sortedList"
            :key="index"
          >
            <!-- チェックボックス -->
            <td
              class="ntss-list-header-th-sticky col-sticky-check check-box"
              :class="listDate.headerflg ? 'col-check-header' : 'col-check-nonheader'"
            >
              <v-ons-checkbox
                v-if="listDate.headerflg"
                class="pat-list-item"
                :value="listDate.patId"
                v-model="examSetTargetList"
                @click="setOneCheck(listDate.patId)"
                :disabled="!getExamAuthorized()"
                :key="listDate.patId"
              />
            </td>
            <!-- 患者ID -->
            <td
              class="ntss-list-header-th-sticky col-sticky-id hosp-pat-id-body"
              :class="[
                isAndroid ? 'col-sticky-name-android' : '',
                listDate.headerflg ? 'col-check-header' : 'col-check-nonheader'
              ]"
              v-show="getIsShowHospPatId"
            >
              <label
                v-if="listDate.headerflg"
              >{{ getHospPatId(listDate.patId) }}</label>
            </td>
            <!-- 患者名行 -->
            <td
              v-if="listDate.headerflg"
              class="ntss-list-header-th-sticky col-sticky-names"
              :class="[
                isAndroid ? 'col-sticky-name-android' : '',
                !isShowHospPatId ? 'col-sticky-id' : 'col-sticky-name',
                listDate.i_class
              ]"
              @click="showDetailPage(listDate.patId)"
            >
              {{ getPatName(listDate.patId) }}
              <img
                :src="image_src_same"
                class="pat-name-same-icon"
                :style="listDate.img_display"
              >
            </td>
            <!-- 検査セット行 -->
            <!-- mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start-->
            <td
              v-if="!listDate.headerflg"
              class="ntss-list-header-th-sticky col-sticky-names"
              :class="[
                isAndroid ? 'col-sticky-name-android' : '',
                !isShowHospPatId ? 'col-sticky-id' : 'col-sticky-name'
              ]"
              @click="rowClear(listDate)"
            >
              {{
                isOtherFacility(listDate)
                  ? buildOtherFacilityText(listDate)
                  : (
                    showDelExam(listDate.examSetCd)
                    + showExamName(listDate.examSetCd)
                    + showRegOrderClass[listDate.regOrderClass]
                  )
              }}
              <span
                v-if="isOtherFacility(listDate)"
                :ref="'showDetail_' + listDate.examSetCd"
                :key="'detail_' + listDate.examSetCd"
                class="warning-icon"
                @click.stop="openOtherFacilityPopover(listDate)"
              >
                ❗
              </span>
            </td>
            <!-- mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end-->
            <td
              class="ntss-list-header-th-sticky"
              :class="[
                isAndroid ? 'col-sticky-name-android' : '',
                !isShowHospPatId ? 'col-sticky-blood-glucose-exams' : 'col-sticky-blood-glucose-exam',
                listDate.headerflg ? 'col-check-header' : 'col-check-nonheader'
              ]"
              v-show="getIsShowBloodGlucoseExam"
            >
              <img
                :src="publicAssetPath('img/exam-request/32-32_1b.png')"
                class="maru-symbol"
                v-if="listDate.headerflg && getBloodGlucoseExam(listDate.patId)"
              />
            </td>
            <!-- 日付列 -->
            <td
              v-for="(date, index) in getExamDateListNoShap"
              :key="index"
              :style="fontColor(listDate, date)"
              :class="addEditedColor(listDate, date)"
              @click="!unableEdit(listDate, date) && editSchedule(listDate, date)"
              style="position: relative;"
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
              v-for="(data, index2) in getExamPatternColumnList"
              :key="`second-${index2}`"
              :style="fontColor(listDate, data)"
              :class="addEditedColorPatternColumn(listDate, data)"
              @click="editPatternCell(listDate, data)"
              style="position: relative;"
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
        class="btn2-cancel common-style-ok-button"
        style="margin: 0 auto 0 0;"
        @click="clear"
        :disabled="!getExamAuthorized()"
      >キャンセル</v-ons-button>
      <div class="bottom-buttons-div">
        <label class="bottom-buttons-label examrequest-label">指示者</label>
        <kendo-dropdownlist
          v-model="selectDoctor"
          :data-source="doctorList"
          :data-text-field="'fullName'"
          :data-value-field="'user_id'"
          @open="addMaxContentStyle"
          style="width: 11.4em; height: 2em; margin-right: 5px;"
          :disabled="!getExamAuthorized()"
          class="input-style-required"
        />
        <v-ons-button
          class="btn1-execute common-style-ok-button"
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
    <!-- 患者IDカラムを表示する -->
    <v-ons-popover
      cancelable
      v-model:visible="popoverHeader.popoverVisible"
      :target="popoverHeader.popoverTarget"
      direction="down"
      :class="[fontSizeSet, 'exam-request-period-header-popover']"
    >
      <div class="popover-content-div">
        <div v-show="popoverHeader.field !== 'date'" style="padding: 1em;">
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
        <div>
          <v-ons-row v-show="popoverHeader.field === 'date'" class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button class="btn4-alert button" :disabled="!getExamAuthorized()" @click="popoverHeader.popoverVisible = false; colListClear(popoverHeader.dateCell.index, popoverHeader.dateCell.data)">一括中止</v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button class="btn3-normal button" @click="popoverHeader.popoverVisible = false; sortBy(popoverHeader.field, popoverHeader.dateCell.data)">ソート</v-ons-button>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
    </v-ons-popover>
    <v-ons-popover
      v-if="otherFacilityDetailVisible"
      cancelable
      v-model:visible="otherFacilityDetailVisible"
      :target="otherFacilityDetailTarget"
      :direction="popoverDisplayDirection(otherFacilityDetailTarget, otherFacilityDetailVisible)"
      :class="[fontSizeSet, 'vons-popover']"
      mask-color="rgba(0, 0, 0, 0)"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="other-facility-detail-div">
        <set-detail class-name="セット情報" :detail="otherFacilityDetailList"/>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import { publicAssetPath } from "@/compat/assets/public-path";
// 検査セット
import { sendRequestAllExamSetListByFacility } from "@/apis/exam-request";
// 検査項目
import { sendRequestGetDispExamItemListForFacilityCd } from "@/apis/exam-Record";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { mapGetters, mapActions, mapState } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
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
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import PopoverMixin from "@/components/PopoverMixin";
import { ApiHelper } from "@/apis/AxiosHelper";
import { EXAM_REQUEST } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils"
import {
  validateSelectDoctor,
  confirmCheckResult,
  executeUploadTemplete,
  checkAndCreateSaveExamData,
  getSchExtEndDateWithPatMainList,
  makeRequestHeaderKey,
  makeRequestSetKey,
  makePatternHeaderKey,
  makePatternSetKey,
  hasTreatmentPatternOnWeek,
  ColumnType,
  setShowDateToCondition,
  formatToYyyymmdd,
  formatToInputDate,
  getExamAuthorized,
  checkExamAuthorized,
  confirmIsOk,
  getDefaultSchExtEndDate,
  hasScheduleOnTargetDate,
  getExamCellImgAttributesByDate,
  sortList
} from "@/functions/exam-request/ExamRequestFunctions";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from "@/functions/common/MessageFormat";
import DateInput from "@/components/common/DateInput";
import { EventBus } from "@/compat/vue/event-bus.js";
import { getHolidayStyle } from "@/functions/common/CommonFunctions";
import { updateSort, getSortedClass } from "@/functions/SortFunctions";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import nameDuplicationImg from "../../assets/name_duplication.png";
import { setKendoPopupSurfaceStyles } from "@/functions/common/KendoFunctions";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";
import setDetail from "@/components/exam-request/ExamRequestPeriodSetDetail";

export default {
  props: {
    controller: null,
    // NOTE: コンソールエラー対策
    historyKey: null
  },
  components: {
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    "message-dialog": messageDialog,
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
    "common-calendar": commonCalender,
    "date-input": DateInput,
    "set-detail": setDetail,
  },
  mixins: [NextTransitionMixin, IndUserSelectMixin, PopoverMixin],
  data() {
    return {
      // 同姓同名アイコン
      image_src_same: nameDuplicationImg,
      gridHeight: 740,
      headerHeight: 31,
      // 検査区分の省略表示文字列
      showRegOrderClass: RegOrderClassShortText,
      // 検査セット対象患者リスト
      examSetTargetList: [],
      // チェック処理用
      allCheckFlg: false,
      // チェック処理用(表示患者リスト)
      allCheckPatIdList: [],
      // 表示期間
      condition: {
        // 日付範囲
        startDate: "",
        endDate: "",
      },
      // 詳細・簡易フラグ("1":詳細、"2":簡易)
      chkDetailSimple: "1",
      // 画面表示する患者のリスト
      searchedPatListClone: [],
      // 指示者
      selectDoctor: null,
      doctorList: [],
      // モバイル端末フラグ
      isAndroid: false,
      isIOS: false,
      // イベントリスナー追加フラグ
      addedTransitionEvent: false,
      // ポップオーバー設定
      popoverHeader: {
        popoverVisible: false,
        popoverTarget: null,
        field : "", // クリックされたfield 
        dateCell: { index: 0, data: {} } // 日付列のデータ
      },
      patSimpleSearch: [],
      dispExamSet: [],
      delExamSetItem: [],
      dispExamSetItem: [],
      // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
      getExamSetName: [],
      // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
      // ソート条件
      sort: {
        key: "",
        isAsc: true
      },
      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: "1",
        stringParams: [""]
      },
      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
      // 前回ソート条件
      prevSort: {
        key: "",
        isAsc: true
      },
      // 画面表示用のリスト
      sortedList: [],
      resizeObservers: [],
      otherFacilityDetailVisible: false,
      otherFacilityDetailList: [],
      otherFacilityDetailTarget: null,
      otherFacilityCache: {},
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
      "getExamRequestList",
      "getEditExamRequestList",
      "getExamRequestListNoShap",
      "getIsShowHospPatId",
      "getIsShowBloodGlucoseExam",
      "patMainList",
      "getExamPatternColumnList",
      "getPatExamPatternList",
      "getSavePatExamPattern",
      "getSchExtEndDate",
    ]),
    ...mapGetters("exam-request/daily", ["getPeriodType"]),
    ...mapGetters("pat-info", [
      "searchedPatList",
      "getIsOtherFacility",
      "getOtherFacilityCd",
      "selectedPatId",
    ]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getSplittedWidth"
    }),
    ...mapGetters("account-edit", [
      "getFontSize",
      "getDefaultSetting",
      "getPatientShareMode",
      "getPatientShareFacilityCdMode",
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", ["getUserId", "getUserName", "getDefaultSetting"]),
    ...mapState("exam-request/list", ["showDetailsDisplay"]),

    // グリッドの高さをCSS変数を利用して書き換える
    gridHeightStyle() {
      return { "--height": `${this.gridHeight}px` };
    },
    gridHeaderWidth() {
      return (index, date) => {
        const result = {};
        if (index === 0) {
          result["width"] = "1rem";
        } else if (index === 1) {
          result["width"] = "10rem";
        } else if (index === 2 && this.isShowHospPatId) {
          result["width"] = "10rem";
        } else if (index === 2 && !this.isShowHospPatId && this.isShowBloodGlucoseExam) {
          result["width"] = "5rem";
        } else if (index === 3 && this.isShowBloodGlucoseExam) {
          result["width"] = "5rem";
        }
        if (date !== "") {
          const dateMoment = dayjs(date);
          const dateCurrent = dayjs().format("YYYYMMDD");
          // const dateCurrent = dayjs();
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
    // テーブルヘッダー内部のCSS
    gridHeaderInner() {
      // 上下部品のpaddingを引く
      const headerHeight = this.headerHeight - 9;
      return { "z-index": 2, "height": `${headerHeight}px` };
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
    isShowHospPatId: {
      get: function() {
        return this.getIsShowHospPatId;
      },
      set: function(value) {
        this.setIsShowHospPatId(value);
      }
    },
    isShowBloodGlucoseExam: {
      get: function() {
        return this.getIsShowBloodGlucoseExam;
      },
      set: function(value) {
        this.setIsShowBloodGlucoseExam(value);
      }
    },
    // 表示期間内の検査依頼データ
    // - this.getExamRequestListNoShapで検査依頼リスト(画面表示用)(整形なし：ヘッダ＋詳細行)を取得 ※generateSortedListで簡易モードの場合はヘッダのみ抽出
    examRequestListInDisplayPeriod() {
      const { showStartDate: dateStart, showEndDate: dateEnd } = this.getNormalizedStartToEndDate;
      const resFilter =  this.getExamRequestListNoShap.filter(examRequest => {
        // ヘッダはそのまま出力
        if (examRequest.headerflg) return true;

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
      resFilter.forEach(examRequest => {
        const pat = this.patSimpleSearch[examRequest.patId];
        if (pat == null) return;
        examRequest.i_class = pat.in_out_class == 1 ? "pat-name-in-hospital" : "";
        examRequest.img_display = pat.is_same == 1 ? "" : "display: none;";
        // ソートに必要な項目をセット
        const searchPat = this.searchedPatList.find(item => item.pat_id === examRequest.patId);
        examRequest.hosp_pat_id = searchPat.hosp_pat_id;
        examRequest.pat_name_sort = searchPat.pat_name_sort;
        examRequest.is_blood_suger_exam = searchPat.is_blood_suger_exam;
      });
      return resFilter;
    },
    // セルの編集状態色表示用情報
    editColorMap() {
      const EditedStatusList = [ADD, ADD_WARNING, CANCEL];
      const map = {};
      const setToMap = key => {
        if (!map[key]) {
          map[key] = true;
        }
      };

      // 検査依頼の編集状態を集計
      this.getExamRequestListNoShap.forEach(item => {
        const { headerflg, patId, examSetCd, regOrderClass, examData } = item;
        // 患者行データの場合は処理対象外
        if (headerflg) return;
        Object.keys(examData).forEach(setDate => {
          const status = examData[setDate];
          // 編集状態でない場合は処理対象外
          if (!EditedStatusList.includes(status)) return;
          // 検査セット行のキー
          const setKey = makeRequestSetKey(patId, examSetCd, regOrderClass, setDate);
          // 患者行のキー
          const headerKey = makeRequestHeaderKey(patId, setDate);
          // 編集状態色表示フラグを設定
          [setKey, headerKey].forEach(setToMap);
        });
      });

      // パターンの編集状態を集計
      this.getPatExamPatternList.forEach(item => {
        const { patId, orderExamSetCd, regOrderClass, examPattern, examWeek, status } = item;
        // 編集状態でない場合は処理対象外
        if (!EditedStatusList.includes(status)) return;
        // 検査セット行のキー
        const setKey = makePatternSetKey(patId, orderExamSetCd, regOrderClass, examPattern, examWeek);
        // 患者行のキー
        const headerKey = makePatternHeaderKey(patId, examPattern, examWeek);
        // 編集状態色表示フラグを設定
        [setKey, headerKey].forEach(setToMap);
      });

      return map;
    },
    disableDatesAfter() {
      return formatToYyyymmdd(this.getSchExtEndDate || getDefaultSchExtEndDate(), "YYYY-MM-DD");
    },
    /* [期間/一日]切替区分 */
    periodType: {
      get() {
        return this.getPeriodType;
      },
      set(value) {
        this.setPeriodType(value); // ストアに反映
      },
    },
  },
  methods: {
    publicAssetPath,
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    getExamRequestElementById(id) {
      return getScopedElementById(id, this.$el || null);
    },
    getExamRequestElementsByClassName(className) {
      return getScopedElementsByClassName(className, this.$el || null);
    },
    queryExamRequestSelector(selector) {
      return queryScopedSelector(selector, this.$el || null);
    },
    queryExamRequestSelectorAll(selector) {
      return queryScopedSelectorAll(selector, this.$el || null);
    },

    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
      "executeWithLoadingScreen",
    ]),
    ...mapActions("exam-request/list", [
      "clearSearchedExamRequest",
      "searchExamRequest",
      "setExamDeadline",
      "setShowDetailsDisplay",
      "setSelectedPatId",
      "updateStartToEndDate",
      "updateExamSetTargetList",
      "dayAllClear",
      "updateEditScheduleStatusStore",
      "setIsShowHospPatId",
      "setIsShowBloodGlucoseExam",
      "setIsDataChanged",
      "getPatMainList",
      "setSavePatExamPattern",
      "setCheckedPatId",
      "getMinSchExtEndDate",
      "modifyInputDate",
      "setCalendarCheckedDate",
      "updateRecordListJournal",
      "setAllExamSetList",
    ]),
    ...mapActions("exam-request/daily", ["setPeriodType"]),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    getExamAuthorized,

    // ウインドウ変更時の高さ補正
    calculateGridHeight() {
      // 表示期間などの表示領域
      const upperButtons = this.getExamRequestElementById("upper-buttons");
      const upBtnsHeight = upperButtons?.offsetHeight || 0;

      // 下部ボタンの表示領域
      const bottomButtons = this.getExamRequestElementById("bottom-buttons");
      const btmBtnsHeight = bottomButtons?.offsetHeight || 0;

      // 表示期間、表、下部ボタン全体の表示領域
      const mainId = this.getExamRequestElementById("main-id");
      const mainIdHeight = mainId?.offsetHeight || 0;

      // 表エリアの高さ (15px引く)
      const gridHeightC = mainIdHeight - upBtnsHeight - btmBtnsHeight - 15;

      // テーブルヘッダの高さ算出
      const tableHtml = this.getExamRequestElementsByClassName("grid-record-list")[0];
      if (tableHtml) {
        // テーブルのHTMLが存在する場合
        this.headerHeight = tableHtml.firstElementChild.offsetHeight;
      }

      this.gridHeight = gridHeightC;

      // Android対策
      if (this.isAndroid && !this.addedTransitionEvent) {
        // CSSトランジションする要素(button--materialクラス)を取得
        const transitionButtons = this.getExamRequestElementsByClassName("button--material");
        const transitionButton = Array.from(transitionButtons).find(
          el => el.innerText.trim() === "再表示");
        if (!transitionButton) return;
        // トランジション終了を検知する
        transitionButton.addEventListener("transitionend", event => {
          if (event.propertyName === "font-size") {
            // トランジション要素ごとに発火するので、１回に絞る
            const upBtnsHeight = upperButtons?.offsetHeight || 0;
            const btmBtnsHeight = bottomButtons?.offsetHeight || 0;
            const mainIdHeight = mainId?.offsetHeight || 0;
            const gridHeightC = mainIdHeight - upBtnsHeight - btmBtnsHeight - 15;
            this.gridHeight = gridHeightC;
          }
        });
        this.addedTransitionEvent = true;
      }
    },
    // チェックボックスを再描画
    reDisplayCheck() {
      const tmpChkList = Array.from(this.examSetTargetList);
      this.examSetTargetList = [];
      this.$nextTick(() => {
        this.examSetTargetList = tmpChkList;
      });
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    confirmResult() {
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
    // 患者名クリックでその患者の子画面に遷移
    async showDetailPage(patId) {
      this.setSelectedPatId(patId);
      await this.executeWithLoadingScreen(async () => {
        await this.selectPat(patId);
      });
      this.$router.push({ name: "exam-request-detail" });
    },
    // 日付部をクリックした際に一括中止
    async colListClear(index, data) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkExamAuthorized()) return;

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
    async getPatSame() {
      const thisPatSimpleSearch = await ApiHelper.configPost("/patInfo/getPatSameAndInOutClass", {
        facilityCdList: [this.getFacilityCd],
      }, {
        params: {
          selectedPatId: this.selectedPatId
        }
      });
      this.patSimpleSearch = thisPatSimpleSearch.data;
    },
    // 保存処理
    async saveRecord() {
      if (!validateSelectDoctor(this.selectDoctor)) return;

      // 保存用のデータ作成、チェック処理
      const saveData = checkAndCreateSaveExamData(this.selectDoctor);
      if (!(await confirmCheckResult(saveData))) return;

      this.executeUpload(saveData.request);
    },
    // 保存実施
    async executeUpload(request) {
      const requestJournal = [].concat(...["0", "1", "2"].map(
        aClass => request.filter(item => item.regOrderClass == aClass)));
      const params = {
        request,
        requestJournal,
      };
      await executeUploadTemplete(
        this.updateRecordListJournal(params),
        () => {
          // 再表示
          this.showCalendar();
        },
        "ExamRequestComponent.vue",
        "executeUpload",
        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
        this.messageDialogInfo
        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
        );
    },
    // 患者名取得
    getPatName(patId) {
      let rtnName = "";
      const obj = this.searchedPatListClone.find(item => item.pat_id == patId);
      if (obj) {
        let { pat_last_name, pat_first_name } = obj;
        if (pat_last_name == null) pat_last_name = "";
        if (pat_first_name == null) pat_first_name = "";
        rtnName = `${pat_last_name} ${pat_first_name}`;
      }
      return rtnName;
    },
    // 日付が患者毎のスケジュール延長最終日を超える日付かを判定
    unableEdit(celObj, setDate) {
      if (this.isOtherFacility(celObj)) return true;
      const schExtEndDateYyyymmdd = getSchExtEndDateWithPatMainList(this.patMainList, celObj.patId);
      return schExtEndDateYyyymmdd < setDate;
    },
    // カレンダークリック時の処理
    editSchedule(celObj, setDate) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkExamAuthorized()) return;
      if (this.isOtherFacility(celObj)) return;

      let targetObj = this.getEditExamRequestList.filter(item => item.patId === celObj.patId);
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
                    this.exeChangeToCancel(targetObj, celObj, setDate);
                  }
                }
              });
            } else {
              // 依頼ありの場合、中止指示にする
              this.exeChangeToCancel(targetObj, celObj, setDate);
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
        // ヘッダーをクリックした場合の処理
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
    exeChangeToCancel(targetObj, celObj, setDate) {
      // 依頼ありの場合、中止指示にする
      targetObj[0]["data"][setDate] -= 1;
      targetObj[0].examItemSet[celObj.regOrderClass][celObj.examSetCd]["data"][setDate] = CANCEL;
    },

    // withCancel: true => CANCELデータを含める、false/undefined => CANCELデータを含めない
    getPatExamPatternFiltered(celObj, setData, withCancel) {
      let { patId } = celObj;
      if (patId) patId = String(patId);
      const { examPattern, examWeek } = setData;
      return (patId && examPattern && examWeek && this.getPatExamPatternList)
        ? this.getPatExamPatternList.filter(item => (
          (withCancel || item.status !== CANCEL)
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

      let count = 0;
      const selectedExamPattern = {};
      patExamPatternFiltered.forEach(obj => {
        const patternKey = `${obj.orderExamSetCd}+${obj.regOrderClass}`;
        if (!selectedExamPattern[patternKey]) {
          selectedExamPattern[patternKey] = true;
          count++;
        }
      });
      return count;
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
      let { patId, examSetCd, regOrderClass, ownPatId } = celObj;
      const matchPatId = ownPatId || patId;
      if (patId) patId = String(patId);
      if (ownPatId) ownPatId = String(ownPatId);
      if (examSetCd) examSetCd = String(examSetCd);
      if (regOrderClass) regOrderClass = String(regOrderClass);
      const { examPattern, examWeek } = setData;
      const targetExamPattern =
        matchPatId && examSetCd && regOrderClass && examPattern && examWeek &&
        this.getPatExamPatternList.find(item => {
          const targetPatId = item.ownPatId || item.patId;
          return (
            String(matchPatId) === String(targetPatId) &&
            examSetCd === String(item.orderExamSetCd) &&
            regOrderClass === String(item.regOrderClass) &&
            examPattern === item.examPattern &&
            examWeek === item.examWeek
          );
        });
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

    // カウント文字の文字色
    fontColor(celObj, setDate) {
      const rtn = { "font-weight": "bold" };
      if (celObj.headerflg) {
        // 患者名行
        const editStatus = celObj.editStatus[setDate];
        if (editStatus === ADD_WARNING) {
          rtn["color"] = FONTCOLOR_HAS_NOT_SCHEDULE;
        } else if (editStatus === ADD) {
          rtn["color"] = FONTCOLOR_HAS_SCHEDULE;
        } else if (editStatus === CANCEL || editStatus === SAVED) {
          // 予定有無を判別して色を変える
          if (hasScheduleOnTargetDate(celObj.patId, setDate)) {
            rtn["color"] = FONTCOLOR_HAS_SCHEDULE;
          } else {
            rtn["color"] = FONTCOLOR_HAS_NOT_SCHEDULE;
          }
        }
        rtn["background-color"] = BACKGROUND_ROW_PATNAME;
      } else {
        if (this.isOtherFacility(celObj)) {
          rtn["background-color"] = "#9c9c9c";
          return rtn;
        }
        // 患者名行以外
        const dateCurrent = formatToYyyymmdd();
        if (setDate < dateCurrent) {
          rtn["background-color"] = BACKGROUND_COLUMN_PAST_DAY;
        }
      }
      return rtn;
    },
    // 編集されているセルを示す緑色をセルに付与する
    addEditedColor(celObj, setDate) {
      if (!celObj.headerflg && this.isOtherFacility(celObj)) {
        return ["other-facility-disabled"];
      }
      // 患者毎のスケジュール延長最終日を超える日付はグレーアウトする
      if (this.unableEdit(celObj, setDate)) {
        return ["uneditable"];
      }

      const { headerflg, patId, examSetCd, regOrderClass } = celObj;
      const classNames = [];
      const key = headerflg
        // 患者名行
        ? makeRequestHeaderKey(patId, setDate)
        // 患者名行以外
        : makeRequestSetKey(patId, examSetCd, regOrderClass, setDate);
      if (this.editColorMap[key]) {
        classNames.push("exam-edited-cell");
      }
      return classNames;
    },
    // カウント文字の文字色（パターン列）
    fontColorPatternColumn(celObj) {
      const rtn = {};
      if (celObj.headerflg) {
        // 患者名行
        rtn["background-color"] = BACKGROUND_ROW_PATNAME;
      }
      return rtn;
    },
    // 編集されているセルを示す緑色をセルに付与する（パターン列）
    addEditedColorPatternColumn(celObj, setData) {
      const { headerflg, patId, examSetCd, regOrderClass } = celObj;
      const { examPattern, examWeek } = setData;
      const classNames = [];
      const key = headerflg
        // 患者名行
        ? makePatternHeaderKey(patId, examPattern, examWeek)
        // 患者名行以外
        : makePatternSetKey(patId, examSetCd, regOrderClass, examPattern, examWeek);
      if (this.editColorMap[key]) {
        // 編集状態のパターンが存在する場合
        classNames.push("exam-edited-cell");
      }
      return classNames;
    },
    // 文字色および背景色（前回検査日）
    fontColorExamDateColumn(celObj) {
      let rtn = {};
      if (celObj.headerflg) {
        // 患者名行
        rtn["background-color"] = BACKGROUND_ROW_PATNAME;
      }
      return rtn;
    },
    // 全チェックのチェックボックスの処理
    setAllCheck(isRefresh) {
      if (!isRefresh && this.allCheckFlg) {
        // チェックを外す
        this.examSetTargetList = [];
        this.allCheckFlg = false;
        this.setCheckedPatId(null);
      } else if (isRefresh && !this.allCheckFlg) {
        this.examSetTargetList = this.allCheckPatIdList;
      } else {
        // this.examSetTargetList には文字型のデータが入ってくる為変換する
        this.examSetTargetList = this.allCheckPatIdList;
        this.allCheckFlg = true;
        this.setCheckedPatId(this.allCheckPatIdList);
      }
    },
    // 検査依頼一覧で患者IDをチェックする
    setOneCheck(patId) {
      this.checkPatId = patId ? patId : null;
      // 患者のチェックボックスを取得しチェックが入れられたか外されたか判定
      const patCheckbox = this.getExamRequestElementsByClassName("pat-list-item");
      const isChecked = Array.from(patCheckbox).some(checkbox => (
        (patId === parseInt(checkbox.value)) && checkbox.checked));
      // 患者のチェックが外された際はスケジュール作成処理が行われないようcheckedPatIdを空にする
      this.setCheckedPatId(isChecked ? [this.checkPatId] : null);
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
    /* #9101 再表示ボタン削除 にて、表示期間の×ボタンクリックでシステム日付が表示されてしまう異常を回避する為、
      以下chkCalenDate()を削除(コメントアウト)します。 */
    /*
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    chkCalenDate(str){
      if (str == "startDate") {
        // 指示期間（開始）
        this.modifyConditionDate("startDate");
      } else if (str == "endDate") {
        // 指示期間（終了）
        this.modifyConditionDate("endDate");
      }
      this.redisplay();
    },
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    */
    modifyConditionDate(conditionName) {
      this.modifyInputDate({ condition: this.condition, conditionName });
    },
    // 再表示処理
    redisplay() {
      const condition = this.condition;

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
      this.searchedPatListClone = JSON.parse(JSON.stringify(this.searchedPatList));
      this.showCalendar();
      this.setCheckedPatId(null);
    },
    // データを取得してカレンダーに表示する
    showCalendar() {
      // 共通ローダー:表示開始
      this.startLoadingScreen();

      // 患者チェック状態を初期化
      this.examSetTargetList = [];
      this.updateExamSetTargetList(this.examSetTargetList);

      const patIdList = [];
      if (this.searchedPatListClone.length) {
        // 患者検索で表示されている患者のIDリストを取得
        patIdList.push(...this.searchedPatListClone.map(element => element.pat_id));
        // チェック判定用配列に文字列配列にして格納
        this.allCheckPatIdList = patIdList.map(String);
      }

      // 治療パターンの取得
      this.searchExamRequest({
        patIdList,
        startDate: "",
        endDate: this.condition.endDate.replace(/-/g, "/"),
        patientShareMode: (
          this.getIsOtherFacility === false
          || (this.getOtherFacilityCd !== null && this.getOtherFacilityCd !== this.getFacilityCd)
        ) ? 1 : this.getPatientShareMode,
      }).then(() => {
        // 表示リスト生成
        this.generateSortedList();
        // 共通ローダー:表示終了
        this.finishLoadingScreen();
      }).catch(error => {
        getErrorMessage("ExamRequestComponent.vue", "showCalendar", error);
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
    // dropDownを開いた時にデータに応じて表示枠を広げる
    addMaxContentStyle(event) {
      this.onIndUserDropdownOpen(event);
      this.$nextTick(() => {
        setKendoPopupSurfaceStyles(event, { width: "max-content", bottom: "0px" }, this.$el);
        this.onIndUserDropdownOpen(event);
      });
    },
    // 院内の患者IDを取得する。
    getHospPatId(patId) {
      const pat = this.searchedPatListClone.find(p => p.pat_id === patId);
      return pat ? pat.hosp_pat_id : "";
    },
    getBloodGlucoseExam(patId) {
      const pat = this.patMainList.find(p => p.patId === patId);
      return pat ? pat.isBloodGlucoseExam : false;
    },
    showPopover(event, field, index, data) {
      this.popoverHeader.popoverTarget = event;
      this.popoverHeader.popoverVisible = true;
      this.popoverHeader.field = field;
      // 日付ヘッダクリック時
      if (field === "date") {
        this.popoverHeader.dateCell.index = index;
        this.popoverHeader.dateCell.data = data;
      }
    },
    updatePatMainList() {
      const patIdList = this.searchedPatList.map(item => item.pat_id);
      this.getPatMainList(patIdList);
      // patMainListの更新と並行してgetSchExtEndDateの更新も行う
      this.updateMaxDate();
    },
    // 表示期間の日付入力の上限を設定
    async updateMaxDate() {
      const patIdList = this.searchedPatListClone
        ? this.searchedPatListClone.map(patInfo => patInfo.pat_id)
        : [];
      await this.getMinSchExtEndDate({
        facilityCd: this.getFacilityCd,
        patIdList,
      }).catch(error => {
        getErrorMessage("ExamRequestComponent.vue", "updateMaxDate", error);
        throw error;
      });
      // 表示期間の入力状態を更新
      this.modifyConditionDate("startDate");
      this.modifyConditionDate("endDate");
      this.redisplay();
    },
    // 検査パターンセルクリック時の処理
    editPatternCell(celObj, setData) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkExamAuthorized()) return;

      let savePatExamPatternCopy = [...this.getSavePatExamPattern];
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
      const cancelLength = targetList.filter(item => item.status === CANCEL).length
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
    async refresh() {
      if (await this.controller.confirmAllowDiscardChangesForRefresh()) {
        // キャンセルされなかった場合
        this.exeClear();
        this.allCheckFlg = false;
        this.setAllCheck(true);
        EventBus.$emit("emptyExamSet");
      }
    },
    showDelExam(cd) {
      const setCd = Number(cd);
      if (this.dispExamSet.includes(setCd)) {
        return MASTER_DELETE_DISPLAY.DELETED;
      } else if (this.delExamSetItem.includes(setCd)) {
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
    /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date);
    },
    // 昇順/降順のclassを作成
    sortedClass(field, data) {
      const key = field === "date" ? this.getSortKey(data) : field;
      return getSortedClass(key, this.sort);
    },
    // ソートするキーを設定する
    sortBy(field, data) {
      const key = field === "date" ? this.getSortKey(data) : field;   
      updateSort(key, this.sort);
    },
    getSortKey(data) {
      if (data.date !== "") {
        // 日付ヘッダ 
        return dayjs(data.date).format("YYYYMMDD");
      } else {
        // 検査パターン
        const { examPattern, examWeek } = data.setData;
        return `${examPattern}:${examWeek}`;
      }
    },
    /**
     * 表示データ生成
     * - ソート条件に従ってソート実施
     * - ソート後、簡易モードの場合はヘッダのみ抽出してリスト返却
     */
    generateSortedList() {
      const list = this.examRequestListInDisplayPeriod.slice();
      this.sortedList = sortList(list, this.sort, this.getPatRowCellNumber, this.getPatExamPatternFiltered);
    },
    loadOtherFacilityExamSet(facilityCd, patId) {
      if (!facilityCd || this.otherFacilityCache[facilityCd]) return;
      const selectedPatId = this.selectedPatId ?? patId;
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
    isOtherFacility(listDate) {
      return !!listDate?.facilityCd && listDate.facilityCd != this.getFacilityCd;
    },
    openOtherFacilityPopover(listDate) {
      this.otherFacilityDetailList = listDate.setInfo ?? [];
      this.$nextTick(() => {
        let ref = this.$refs[`showDetail_${listDate.examSetCd}`];
        if (Array.isArray(ref)) {
          ref = ref[0];
        }
        this.otherFacilityDetailTarget = ref;
        if (!this.otherFacilityDetailTarget) return;
        this.otherFacilityDetailVisible = true;
      });
    },
    popoverDisplayDirection(popoverTarget, visible) {
      if (!visible || !popoverTarget) return null;
      const elemPosition = popoverTarget.$el
        ? popoverTarget.$el.getBoundingClientRect()
        : popoverTarget.getBoundingClientRect();
      let direction = "right";

      if (this.windowHeight <= 420) {
        direction = elemPosition.right < this.windowWidth / 2 ? "right" : "left";
      } else if (this.windowWidth - elemPosition.right < 500) {
        direction = elemPosition.top < this.windowHeight / 2 ? "down" : "up";
      }
      return direction;
    },
    /** 列幅の再計算を行い、固定列の位置調整処理 */
    updateLeftPosition() {
      this.$nextTick(() => {
        setTimeout(() => {
          // チェックボックス列
          const checkBoxHeader = this.queryExamRequestSelector('.col-sticky-check');
          const checkBoxWidth = checkBoxHeader ? checkBoxHeader.offsetWidth : 0;
          // 患者ID列
          const hospIdHeader = this.queryExamRequestSelector('.col-sticky-id');
          const hospIdVisible = this.isShowHospPatId;
          const hospIdWidth = hospIdVisible && hospIdHeader ? hospIdHeader.offsetWidth : 0;
          // 患者名列の left を更新
          // NOTE: 患者名列を特定させるclass を設定するため、col-sticky-names を設定（スタイルはなし） 
          const patNameHeader = this.queryExamRequestSelector('.col-sticky-names');
          const patNameCells = this.queryExamRequestSelectorAll('.col-sticky-names');
          const patNameLeft = checkBoxWidth + hospIdWidth;
          if (patNameHeader) patNameHeader.style.left = `${patNameLeft}px`;
          patNameCells.forEach(cell => cell.style.left = `${patNameLeft}px`);
          // 血糖検査列の left を更新
          const bloodClass = !hospIdVisible ? '.col-sticky-blood-glucose-exams' : '.col-sticky-blood-glucose-exam';
          const bloodHeader = this.queryExamRequestSelector(bloodClass);
          const bloodCells = this.queryExamRequestSelectorAll(bloodClass);
          const patNameWidth = patNameHeader?.offsetWidth || 0;
          const bloodLeft = checkBoxWidth + hospIdWidth + patNameWidth;
          if (bloodHeader) bloodHeader.style.left = `${bloodLeft}px`;
          bloodCells.forEach(cell => cell.style.left = `${bloodLeft}px`);
        }, 50);
      });
    },
  },
  watch: {
    // 検索リストに表示されている患者
    async searchedPatList() {
      this.searchedPatListClone = JSON.parse(JSON.stringify(this.searchedPatList));
      this.showCalendar();
      if (this.searchedPatListClone.length) {
        this.examSetTargetList = this.allCheckPatIdList;
        this.allCheckFlg = true;
        this.updateExamSetTargetList(this.examSetTargetList);
        this.updatePatMainList();
      }
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
    // 検査セット対象更新
    examSetTargetList() {
      // 全選択チェック
      this.allCheckFlg = !!(
        this.allCheckPatIdList.length
        && this.examSetTargetList.length === this.allCheckPatIdList.length);
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
    getPatientShareMode() {
      this.showCalendar();
    },
    getPatientShareFacilityCdMode() {
      this.showCalendar();
    },
    isChanged() {
      this.setIsDataChanged(this.isChanged);
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    "messageDialogInfo.isDialogVisible"(isShow) {
      this.isUpdating = isShow ? false : this.isUpdating;
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
    // 詳細/簡易モード変更
    showDetailsDisplay() {
      // 表示リスト生成
      this.generateSortedList();
    },
    // ソート条件更新
    sort: {
      handler(newSort) {
        if (
          newSort.key !== this.prevSort.key ||
          newSort.isAsc !== this.prevSort.isAsc) {
          this.generateSortedList();
          this.prevSort = { ...newSort };
        }
      },
      deep: true
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
  },
  async created() {
    this.startLoadingScreen();

    // 患者別画面のデータが残っている場合があるためクリアしておく
    this.clearSearchedExamRequest();

    sendRequestGetDispExamItemListForFacilityCd(this.getFacilityCd, this.selectedPatId).then(response => {
      this.dispExamSetItem = response.data;
    });
    sendRequestAllExamSetListByFacility(this.getFacilityCd, this.selectedPatId).then(response => {
      response.data.forEach(item => {
        if (item.isDisp === "0") {
          this.dispExamSet.push(item.examSetCd);
        }
        this.getExamSetName.push(item);
        const setItems = JSON.parse(item.examItemInfo);
        setItems.forEach(setItem => {
          if (this.dispExamSetItem.includes(Number(setItem.exam_item_cd))) {
            this.delExamSetItem.push(item.examSetCd);
          }
        });
      });
      // NOTE: Function側でも利用できるようにstoreにも保存
      this.setAllExamSetList(this.getExamSetName);
    });

    await this.getPatSame();
    this.setCalendarCheckedDate(null);

    // 端末判別
    const ua = getScopedWindow(this.$el || this)?.navigator?.userAgent || "";
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }

    // サインインユーザのデフォルト設定を確認・設定
    if (this.isStoredShowDate) {
      setShowDateToCondition(this.condition, this.getStartToEndDate);
      // 詳細/簡易モードをストアから復元
      this.chkDetailSimple = this.showDetailsDisplay ? "1" : "2";
    } else {
      // 検索期間なし → デフォルト設定を使用
      const defaultExamRequest = this.getDefaultSetting[EXAM_REQUEST.KEY_NAME];
      if (defaultExamRequest) {
        // 表示期間・開始
        const defaultStartDate = defaultExamRequest[EXAM_REQUEST.KEY_NAME_START_DATE];
        if (defaultStartDate != null) {
          this.condition.startDate = calcTargetDate(defaultStartDate);
        }
        // 表示期間・終了
        const defaultEndDate = defaultExamRequest[EXAM_REQUEST.KEY_NAME_END_DATE];
        if (defaultEndDate != null) {
          this.condition.endDate = calcTargetDate(defaultEndDate);
        }
        // 詳細・簡易切り替え
        const defaultShowDetail = defaultExamRequest[EXAM_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY];
        if (defaultShowDetail !== undefined) {
          if (defaultShowDetail == "2") {
            // 簡易表示指定の場合は表示切替
            this.chkDetailSimple = defaultShowDetail;
            this.setShowDetailsDisplay(false);
            this.reDisplayCheck();
          } else {
            // 初期状態は詳細表示なので、何もしない
          }
        }
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
      } else {
        // 本日の日付をセット
        const setDate = dayjs();
        this.condition.startDate = setDate.format("YYYY-MM-DD");
        this.condition.endDate = setDate.add(3, "months").format("YYYY-MM-DD");
      }
    }
    if (this.$route.params.fromFacilityCalendar) {
      // 施設カレンダーから日付が渡された場合
      const dayViewMoment = dayjs(this.$route.params.fromFacilityCalendar.date);
      if (dayViewMoment.isValid()) {
        this.condition.endDate
          = this.condition.startDate
          = dayViewMoment.format("YYYY-MM-DD");
      }
    }
    this.updateStartToEndDate({
      showStartDate: this.condition.startDate.replace(/-/g, ""),
      showEndDate: this.condition.endDate.replace(/-/g, ""),
    });

    // 検索されている患者リストを取得する
    this.searchedPatListClone = JSON.parse(JSON.stringify(this.searchedPatList));

    // 締切設定を取得
    await this.setExamDeadline({
      facilityCd: this.getFacilityCd,
      selectedPatId: this.selectedPatId
    });

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

    this.updatePatMainList();

    // 全チェックのチェックボックスの処理
    await this.setAllCheck(false);
    // 検査依頼一覧で患者IDをチェックする
    this.setOneCheck();

    // 休日マスタの休日を取得
    await this.fetchHolidays(this.getFacilityCd);

    this.finishLoadingScreen();
  },
  mounted() {
    this.$nextTick(() => {
      const headers = this.queryExamRequestSelectorAll('.manual-width');
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
    EventBus.$on("addSchedule", this.generateSortedList);
  },
  beforeUpdate() {
    this.calculateGridHeight();
  },
  beforeUnmount() {
    this.clearHolidays(); // storeの休日マスタをクリア
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("addSchedule", this.generateSortedList);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    
    // ResizeObserver の解除
    this.resizeObservers.forEach(observer => observer.disconnect());
    this.resizeObservers = [];
  },
};
</script>

<style scoped>
ons-checkbox[disabled] {
  background-color: none !important;
}
tr {
  /* 設定しなくても表示に問題がない高さは自動で確保される */
  height: 31px;
}
td {
  border: solid 1px #cccccc;
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
.check-box {
  white-space: normal;
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
  --height: 500px;
  height: var(--height);
  overflow: auto;
  margin-top: 5px;
  margin-bottom: 5px;
}
.grid-record-list {
  border-collapse: collapse;
  width: calc(100vw - 10rem);
  background-color: var(--ntss-list-background-color);
}
.ntss-list-header-th-sticky {
  z-index: 1;
  box-shadow: 0px 0px 0px #cccccc inset, -1px 1px 0px #cccccc inset !important;
  border: solid 0px var(--ntss-list-border-color) !important;
}
/* 詳細/簡易ボタン */
input[type="radio"] {
  /* ラジオボタンを非表示にする */
  display: none;
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  display: flex;
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
.first-of-type_period {
  border-radius: 10px 0 0 10px;
  margin: 2px 0px 2px 1px;
  width: auto;
  padding: 0px 10px 0px 10px;
}
.first-of-type {
  border-radius: 10px 0 0 10px;
  margin: 2px 0px 2px 3em;
  width: auto;
  padding: 0px 10px 0px 10px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
  margin: 2px 5px 2px 0px;
  width: auto;
  padding: 0px 10px 0px 10px;
}
.col-sticky-check {
  border-left: none;
  border-right: none;
  width: 36px;
  z-index: 1;
  position: -webkit-sticky;
  position: sticky;
  left: 0;
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
.col-sticky-name-android {
  left: 27px;
}
.col-check-header {
  border-top: solid 1px var(--ntss-list-border-color);
  border-bottom: none;
  top: unset;
  text-align: center
}
.col-check-nonheader {
  border-top: none;
  border-bottom: none;
  top: unset;
}
.ind-user-selector {
  margin-top: 0.5em;
  width: 15em;
}
.ind-user-selector .selectbox {
  width: 100%;
}
.col-sticky-id {
  z-index: 1;
  top: unset;
  text-align: unset;
  white-space: normal;
  word-break: break-all;
  width: 110px;
  left: 44px;
  border-left: none;
  border-right: none;
  box-shadow: 1px 0px 0px #ffffff inset, -1px 0px 0px #ffffff inset;
}
.header-columns {
  margin-bottom: 5px;
}
.maru-symbol {
  width: 0.9em;
}
ons-popover :deep(.popover--top) {
  max-width: 18em;
}

.exam-request-period-header-popover :deep(.popover--top) {
  width: 18em;
  min-width: 0;
  max-width: 18em;
}
ons-popover :deep(.popover--top > .popover__content) {
  font-size: 1.6em;
  height: auto;
  min-height: 0;
}

.exam-request-period-header-popover :deep(.popover--top > .popover__content) {
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

.exam-request-period-header-popover :deep(.popover--top > .popover__content label) {
  width: 5em;
}
.popover-content-row {
  margin-bottom: 10px;
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
.exam-control-cell :deep(.td-img) {
  width: 1.2em;
  height: auto;
  position: absolute;
  transform: translate(-50%, -50%);
  top: 50%;
  left: 50%;
  -webkit-transform: translate(-50%, -50%);
  /* 背景塗りつぶし用 */
  border-radius: 1em;
  background-color: transparent !important;
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
.manual-width {
  resize: horizontal;
  overflow-x: auto;
}
.uneditable {
  background-color: #999999 !important;
}
.warning-icon {
  color: #ff4d4f;
  font-weight: bold;
  cursor: pointer;
}
.other-facility-detail-div {
  max-height: 600px;
  padding: 25px;
  overflow: auto;
  height: calc(100% - 50px);
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
  #bottom-buttons {
    display: none;
  }
}
</style>
