/**
 * 一般撮影検査依頼用メイン
 */
<template>
  <div id="main-id" class="main-content-area">
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
      <!--
        #9101 再表示ボタン削除 にて、表示期間の×ボタンクリックでシステム日付が表示されてしまう異常を回避する為、
        上記common-calenderのパラメータから以下1行を削除(コメントアウト)します。
      -->
      <!-- @input="chkCalenDate('startDate')" -->
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
        <v-ons-switch
          v-show="getIsAndroidOrIOS"
          v-model="isShowLastRadDate"
        />
      </div>
    </div>
    <!-- テーブルエリア -->
    <div class="scroll-table" :style="gridHeightStyle">
      <table id="grid-header" class="grid-record-list" style="width: max-content;">
        <thead>
          <tr>
            <th
              class="ntss-list-header-th-sticky col-sticky-check check-box"
              style="left: 0;"
              :style="gridHeaderInner"
            >
              <v-ons-checkbox
                v-model="allCheckFlg"
                @change="setAllCheck(false)"
                @click.stop
                :disabled="!getRadAuthorized()"
              />
            </th>
            <th
              ref="hospPatIdHeader"
              class="ntss-list-header-th-sticky col-sticky-id manual-width"
              style="top: 0px;"
              :style="gridHeaderInner"
              :class="sortedClass('hosp_pat_id')"
              v-show="isShowHospPatId"
            ><span @click="showPopover($event, 'hosp_pat_id')">患者ID</span></th>
            <th
              ref="patNameHeader"
              class="ntss-list-header-th-sticky manual-width"
              :class="[!isShowHospPatId ? 'col-sticky-id' : 'col-sticky-name', sortedClass('pat_name')]"
              :style="gridHeaderInner"
            ><span @click="showPopover($event, 'pat_name')">患者名</span></th>
            <th
              v-for="(data, index) in getRadDateList"
              :key="index"
              v-show="isShowHospPatId ? (index > 2) : (index > 1)"
              :style="gridHeaderWidth(index, data)"
              class="ntss-list-header-th-sticky manual-width"
              :class="[
                isLastRadDateHeader(data) && (isShowHospPatId ? 'col-sticky-names' : 'col-sticky-namess'),
                sortedClass('date', data)
              ]"
            ><span :class="getStyle(data.date)" @click="!isLastRadDateHeader(data) && showPopover($event, 'date', index, data)">{{ data.dateFormat }}</span></th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(listDate, index) in sortedList"
            :key="index"
          >
            <!-- mod #12121応対について 患者ID列の罫線の表示に関する修正 fang start -->
            <!-- チェックボックス -->
            <td
              v-if="listDate.headerSpan > 0"
              :rowspan="listDate.headerSpan"
              class="ntss-list-header-th-sticky-checkbox col-sticky-check check-box"
            >
              <v-ons-checkbox
                v-if="listDate.headerflg"
                class="pat-list-item"
                :value="listDate.patId"
                v-model="radSetTargetList"
                @click="setOneCheck(listDate.patId)"
                :disabled="!getRadAuthorized()"
                :key="listDate.patId"
              />
            </td>
            <!-- 患者ID -->
            <td
              v-if="listDate.headerSpan > 0"
              :rowspan="listDate.headerSpan"
              class="ntss-list-header-th-sticky-checkbox col-sticky-id hosp-pat-id-body"
              v-show="getIsShowHospPatId"
            >
              <label
                v-if="listDate.headerflg"
              >{{ getHospPatId(listDate.patId) }}</label>
            </td>
            <!-- mod #12121応対について 患者ID列の罫線の表示に関する修正 fang end -->
            <!-- 患者名行 -->
            <td
              v-if="listDate.headerflg"
              class="ntss-list-header-th-sticky clean_boder"
              :class="[
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
              class="ntss-list-header-th-sticky"
              :class="[
                !isShowHospPatId ? 'col-sticky-id' : 'col-sticky-name'
              ]"
              style="padding-left: 2em; white-space: unset;"
              @click="rowClear(listDate)"
            >
              {{
                isOtherFacility(listDate)
                  ? buildOtherFacilityText(listDate)
                  : showRadName(listDate.radSetCd)
              }}
              <span
                v-if="isOtherFacility(listDate)"
                :ref="'showDetail_' + listDate.radSetCd"
                :key="'detail_' + listDate.radSetCd"
                class="warning-icon"
                @click.stop="openOtherFacilityPopover(listDate)"
              >
                ❗
              </span>
            </td>
            <!-- mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start-->
            <!-- 前回検査日列 -->
            <td
              class="ntss-list-header-th-sticky examrequest-label"
              :class="isShowHospPatId ? 'col-sticky-names' : 'col-sticky-namess'"
              style="z-index: 2;"
              v-show="!getIsAndroidOrIOS || getIsShowLastRadDate"
              :style="fontColorRadDateColumn(listDate)"
            >{{ listDate.lastRadDate }}</td>
            <!-- 日付列 -->
            <td
              v-for="(date, index) in getRadDateListNoShap"
              :key="`first-${index}`"
              :style="fontColor(listDate, date)"
              :class="addEditedColor(listDate, date)"
              @click="!unableEdit(listDate, date) && editSchedule(listDate, date)"
              style="position: relative;"
              class="examrequest-label rad-control-cell"
            >
              <!-- 患者名行 -->
              <template v-if="listDate.headerflg">
                {{ listDate.radData[date] || "" }}
              </template>
              <!-- 患者名行以外 -->
              <template v-else>
                <img v-bind="getImgAttributesForDate(listDate, date)">
                <div v-if="listDate.radData[date] > 0 && getSetRowCellNumberForDate(listDate, date) > 1" class="td-rad-count">
                  {{ getSetRowCellNumberForDate(listDate, date) }}
                </div>
              </template>
            </td>
            <!-- 自動展開列 -->
            <td
              v-for="(data, index) in getRadPatternColumnList"
              :key="`second-${index}`"
              :style="fontColorPatternColumn(listDate)"
              :class="addEditedColorPatternColumn(listDate, data)"
              @click="editPatternCell(listDate, data)"
              style="position: relative;"
              class="examrequest-label rad-control-cell"
            >
              <!-- 患者名行 -->
              <div v-if="listDate.headerflg" :style="getPatRowCellStyle(listDate, data)">
                {{ getPatRowCellNumber(listDate, data) }}
              </div>
              <!-- 患者名行以外 -->
              <template v-else>
                <img v-bind="getImgAttributesForPattern(listDate, data)">
                <div v-if="getSetRowCellNumberForPattern(listDate, data) > 1" class="td-rad-count">
                  {{ getSetRowCellNumberForPattern(listDate, data) }}
                </div>
              </template>
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
          :disabled="!getRadAuthorized()"
          style="height: 2em; margin-right: 5px; width: 11.4em;"
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
    <!-- 患者IDカラムを表示する -->
    <v-ons-popover
      :class="[fontSizeSet, 'pat-id-popover']"
      cancelable
      v-model:visible="popoverHeader.popoverVisible"
      :target="popoverHeader.popoverTarget"
      direction="down"
    >
      <div class="popover-content-div">
        <div v-show="['hosp_pat_id', 'pat_name'].includes(popoverHeader.field)" style="padding: 1em;">
          <div class="d-flex align-items-center">
            <label for="isShowHospPatId">患者ID</label>
            <v-ons-switch
              input-id="isShowHospPatId"
              v-model="isShowHospPatId"
              @change="popoverHeader.popoverVisible = false"
            />
          </div>
        </div>
        <div>
          <v-ons-row v-show="popoverHeader.field === 'date'" class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button class="btn4-alert button" :disabled="!getRadAuthorized()" @click="popoverHeader.popoverVisible = false; colListClear(popoverHeader.dateCell.index, popoverHeader.dateCell.data)">一括中止</v-ons-button>
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
        <rad-detail
          class-name="付帯情報名称"
          :detail="otherFacilityDetailList"
        />
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import { publicAssetPath } from "@/compat/assets/public-path";
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
  FILLCOLOR_HAS_SCHEDULE,
  FILLCOLOR_HAS_NOT_SCHEDULE,
} from "@/constants/radRequestConstants";
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import PopoverMixin from "@/components/PopoverMixin";
import { RAD_REQUEST } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils"
import {
  validateSelectDoctor,
  confirmCheckResult,
  executeUploadTemplete,
  checkAndCreateSaveRadData,
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
  getRadAuthorized,
  checkRadAuthorized,
  confirmIsOk,
  getDefaultSchExtEndDate,
  hasScheduleOnTargetDate,
  sortList
} from "@/functions/exam-request/ExamRequestFunctions";
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import DateInput from "@/components/common/DateInput";
import { EventBus } from "@/compat/vue/event-bus.js";
import { sendRequestGetMstRadSetList } from "@/apis/rad-request";
import { getHolidayStyle } from "@/functions/common/CommonFunctions";
import { updateSort, getSortedClass } from "@/functions/SortFunctions";
import messageDialog from "@/components/common/message-dialog/MessageDialog.vue";
import nameDuplicationImg from "../../assets/name_duplication.png";
import { setKendoPopupSurfaceStyles } from "@/functions/common/KendoFunctions";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getScopedElementById, getScopedElementsByClassName, getScopedUserAgent, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";
import radDetail from "@/components/rad-request/RadRequestSetDetail";

export default {
  components: {
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    "message-dialog": messageDialog,
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
    "common-calendar": commonCalender,
    "date-input": DateInput,
    "rad-detail": radDetail,
  },
  props: {
    controller: null,
    // NOTE: コンソールエラー対策
    historyKey: null
  },
  mixins: [NextTransitionMixin, IndUserSelectMixin, PopoverMixin],
  data() {
    return {
      patSimpleSearch: [],
      gridHeight: 740,
      // 同姓同名アイコン
      image_src_same: nameDuplicationImg,
      headerHeight: 31,
      // 検査セット対象患者リスト
      radSetTargetList: [],
      // 患者ID
      checkPatId: null,
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
      // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
      getRadSetName: [],
      // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: "1",
        stringParams: [""]
      },
      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
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
      // 画面表示用のリスト
      sortedList: [],
      scrollQuerySelector: ".scroll-table",
      addClassTargetQuerySelector: ["table.grid-record-list"],
      // 固定列ヘッダーの幅変更を監視するResizeObserver
      stickyColumnResizeObservers: [],
      otherFacilityCache: {},
      otherFacilityDetailVisible: false,
      otherFacilityDetailList: [],
      otherFacilityDetailTarget: null,
    };
  },
  computed: {
    ...mapGetters("rad-request/list", [
      "isStoredShowDate",
      "getStartToEndDate",
      "getNormalizedStartToEndDate",
      "getDeadlineCondition",
      "getRadDateList",
      "getRadDateListNoShap",
      "getRadRequestList",
      "getEditRadRequestList",
      "getRadRequestListNoShap",
      "getSaveRadRequestList",
      "getRadSetNameList",
      "getIsShowHospPatId",
      "getIsShowLastRadDate",
      "getRadPatternColumnList",
      "getPatRadPatternList",
      "getSavePatRadPattern",
      "getSchExtEndDate",
      "getIsAndroidOrIOS"
    ]),
    ...mapGetters("pat-info", [
      "searchedPatList",
      "getIsOtherFacility",
      "getOtherFacilityCd",
      "selectedPatId",
    ]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getSplittedWidth",
    }),
    ...mapGetters("exam-request/list", ["patMainList"]),
    ...mapGetters("account-edit", [
      "getFontSize",
      "getDefaultSetting",
      "isDispMenu",
      "getPatientShareMode",
      "getPatientShareFacilityCdMode",
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapState("rad-request/list", ["showDetailsDisplay"]),

    // グリッドの高さをCSS変数を利用して書き換える
    gridHeightStyle() {
      return { "--height": `${this.gridHeight}px` };
    },
    gridHeaderWidth() {
      return (index, data) => {
        const result = {};
        if (index === 0) {
          result["width"] = "2rem";
        } else if (index === 1) {
          result["width"] = "10rem";
        } else if (index === 2 && this.isLastRadDateHeader(data) && !this.isShowHospPatId) {
          result["width"] = "5rem";
          result["textAlign"] = "center";
          result["z-index"] = 3;
        } else if (index === 2 && this.isShowHospPatId) {
          result["width"] = "10rem";
          result["z-index"] = 3;
        } else if (index === 3 && this.isLastRadDateHeader(data) && this.isShowHospPatId) {
          result["width"] = "5rem";
          result["textAlign"] = "center";
          result["z-index"] = 3;
        } else {
          result["textAlign"] = "center";
        }
        if (data.date !== "") {
          const dateMoment = dayjs(data.date);
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
    // テーブルヘッダー内部のCSS
    gridHeaderInner() {
      // 上下部品のpaddingを引く
      const headerHeight = this.headerHeight - 9;
      return { "z-index": 3, "height": `${headerHeight}px` };
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
        const radDataKeys = Object.keys(kensaObj.radData);
        return radDataKeys.some(key => kensaObj.radData[key] !== SAVED);
      });

      if (this.getSavePatRadPattern.length) {
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
    isShowLastRadDate: {
      get: function() {
        return this.getIsShowLastRadDate;
      },
      set: function(value) {
        this.setIsShowLastRadDate(value);
      }
    },
    // 表示期間内の放射線検査依頼データ
    // - this.getRadRequestListNoShapで放射線検査依頼リスト(画面表示用)(整形なし：ヘッダ＋詳細行)を取得 ※generateSortedListで簡易モードの場合はヘッダのみ抽出
    radRequestListInDisplayPeriod() {
      const { showStartDate: dateStart, showEndDate: dateEnd } = this.getNormalizedStartToEndDate;
      const resFilter = this.getRadRequestListNoShap.filter(radRequest => {
        // ヘッダはそのまま出力
        if (radRequest.headerflg) return true;

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
      resFilter.forEach(radRequest => {
        const pat = this.patSimpleSearch[radRequest.patId];
        if (pat == null) return;
        radRequest.i_class = pat.in_out_class == 1 ? "pat-name-in-hospital" : "";
        radRequest.img_display = pat.is_same == 1 ? "" : "display: none;";
        // ソートに必要な項目をセット
        const searchPat = this.searchedPatList.find(item => item.pat_id === radRequest.patId);
        radRequest.hosp_pat_id = searchPat.hosp_pat_id;
        radRequest.pat_name_sort = searchPat.pat_name_sort;
      });
      // del #12121応対について 患者ID列の罫線の表示に関する修正 fang start
      // this.$nextTick(() => {
      //   const headerTd = Array.from(document.getElementsByClassName("col-check-header"));
      //   const noheaderTd = Array.from(document.getElementsByClassName("col-check-nonheader"));
      //   const rows = [];
      //   noheaderTd.forEach(tdItem => {
      //     rows.push(tdItem.parentElement.rowIndex);
      //   });
      //   headerTd.forEach(tdItem => {
      //     const row = tdItem.parentElement.rowIndex + 1;
      //     if (rows.indexOf(row) > -1) {
      //       tdItem.style.borderTop = "solid 1px var(--ntss-list-border-color)";
      //       tdItem.style.borderBottom = "hidden";
      //     } else {
      //       tdItem.style.borderTop = "solid 1px var(--ntss-list-border-color)";
      //       tdItem.style.borderBottom = "none";
      //     }
      //   });
      //   noheaderTd.forEach(tdItem => {
      //     const row = tdItem.parentElement.rowIndex + 1;
      //     if (rows.indexOf(row) > -1) {
      //       tdItem.style.borderTop = "hidden";
      //       tdItem.style.borderBottom = "hidden";
      //     } else {
      //       tdItem.style.borderTop = "hidden";
      //       tdItem.style.borderBottom = "none";
      //     }
      //   });
      // });
      // del #12121応対について 患者ID列の罫線の表示に関する修正 fang end
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
      this.getRadRequestListNoShap.forEach(item => {
        const { headerflg, patId, radSetCd, regOrderClass, radData } = item;
        // 患者行データの場合は処理対象外
        if (headerflg) return;
        Object.keys(radData).forEach(setDate => {
          const status = radData[setDate];
          // 編集状態でない場合は処理対象外
          if (!EditedStatusList.includes(status)) return;
          // 検査セット行のキー
          const setKey = makeRequestSetKey(patId, radSetCd, regOrderClass, setDate);
          // 患者行のキー
          const headerKey = makeRequestHeaderKey(patId, setDate);
          // 編集状態色表示フラグを設定
          [setKey, headerKey].forEach(setToMap);
        });
      });

      // パターンの編集状態を集計
      this.getPatRadPatternList.forEach(item => {
        const { patId, orderRadSetCd, regOrderClass, radPattern, radWeek, status } = item;
        // 編集状態でない場合は処理対象外
        if (!EditedStatusList.includes(status)) return;
        // 検査セット行のキー
        const setKey = makePatternSetKey(patId, orderRadSetCd, regOrderClass, radPattern, radWeek);
        // 患者行のキー
        const headerKey = makePatternHeaderKey(patId, radPattern, radWeek);
        // 編集状態色表示フラグを設定
        [setKey, headerKey].forEach(setToMap);
      });

      return map;
    },
    disableDatesAfter() {
      return formatToYyyymmdd(this.getSchExtEndDate || getDefaultSchExtEndDate(), "YYYY-MM-DD");
    },
  },
  methods: {
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
      "setShowDetailsDisplay",
      "setSelectedPatId",
      "updateStartToEndDate",
      "updateRadSetTargetList",
      "dayAllClear",
      "updateEditScheduleStatusStore",
      "setIsShowHospPatId",
      "setIsShowLastRadDate",
      "setAndroidOrIOS",
      "setIsDataChanged",
      "setSavePatRadPattern",
      "setCheckedPatId",
      "getMinSchExtEndDate",
      "modifyInputDate",
      "setCalendarCheckedDate",
    ]),
    ...mapActions("exam-request/list", [
      "getPatMainList",
    ]),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    getRadAuthorized,
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

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
    // ウインドウ変更時の高さ補正
    calculateGridHeight() {
      // 表示期間などの表示領域
      const upperButtons = getScopedElementById("upper-buttons", this.$el || null);
      const upBtnsHeight = upperButtons?.offsetHeight || 0;

      // 下部ボタンの表示領域
      const bottomButtons = getScopedElementById("bottom-buttons", this.$el || null);
      const btmBtnsHeight = bottomButtons?.offsetHeight || 0;

      // 表示期間、表、下部ボタン全体の表示領域
      const mainId = getScopedElementById("main-id", this.$el || null);
      const mainIdHeight = mainId?.offsetHeight || 0;

      // 表エリアの高さ (15px引く)
      const gridHeightC = mainIdHeight - upBtnsHeight - btmBtnsHeight - 15;

      // テーブルヘッダの高さ算出
      const tableHtml = getScopedElementsByClassName("grid-record-list", this.$el || null)[0];
      if (tableHtml) {
        // テーブルのHTMLが存在する場合
        this.headerHeight = tableHtml.firstElementChild.offsetHeight;
      }

      // ヘッダ部分の表示設定 (初期状態では非表示、高さ算出時に初めて表示する)
      const gridHeader = getScopedElementById("grid-header", this.$el || null);
      if (gridHeader) {
        gridHeader.style.visibility = "visible";
      }
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
          if (event.propertyName === "font-size") {
            // トランジション要素ごとに発火するので、１回に絞る
            const upBtnsHeight = upperButtons.offsetHeight;
            const btmBtnsHeight = bottomButtons.offsetHeight;
            const mainIdHeight = mainId.offsetHeight;
            const gridHeightC = mainIdHeight - upBtnsHeight - btmBtnsHeight - 15;
            this.gridHeight = gridHeightC;
          }
        });
        this.addedTransitionEvent = true;
      }
    },
    // チェックボックスを再描画
    reDisplayCheck() {
      const tmpChkList = Array.from(this.radSetTargetList);
      this.radSetTargetList = [];
      this.$nextTick(() => {
        this.radSetTargetList = tmpChkList;
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
      this.$router.push({ name: "rad-request-detail" });
    },
    // 日付部をクリックした際に一括中止
    async colListClear(index, data) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkRadAuthorized()) return;

      switch (data.columnType) {
        case ColumnType.Dummy:
          break;
        case ColumnType.Date: {
          const dateFormat = this.getRadDateList[index].dateFormat;
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
          const dateFormat = this.getRadDateList[index].dateFormat;
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

      const { patId, regOrderClass, radSetCd, radData } = celObj;
      const targetName = this.showRadName(radSetCd);
      // title: "更新確認",
      // message: "本日以降の{targetName}の予定、自動展開データを一括中止します、よろしいですか？",
      if (!(await confirmIsOk(DIALOG_MESSAGES[13000031], targetName))) return;

      const targetObj = this.getEditRadRequestList.find(item => item.patId == patId);
      const targetRow = targetObj.radItemSet[regOrderClass][radSetCd];
      const tartgetData = targetRow.data;
      const tartgetDetail = targetRow.dataDetail;

      // 検査セットが登録されている日付ごとに処理する
      const editedDate = [];
      const todayMoment = dayjs();
      Object.keys(radData).forEach(date => {
        // 過去日の依頼は中止対象にしない
        if (todayMoment.isAfter(date, "day")) return;

        switch (tartgetData[date]) {
          case CANCEL:
            // 中止指示の場合は、そのまま
            break;
          case SAVED: {
            // 詳細データから対象日付の保存済データ件数を取得し、保存済データを中止指示にする
            const detailCount = Object.keys(tartgetDetail).filter(dateTime => {
              if (
                dateTime.startsWith(date)
                && tartgetDetail[dateTime] === SAVED) {
                tartgetDetail[dateTime] = CANCEL;
                return true;
              }
              return false;
            }).length;

            // 依頼ありの場合、中止指示にする
            targetObj.data[date] -= detailCount;
            tartgetData[date] = CANCEL;
            editedDate.push(date);
            break;
          }
          case ADD:
          case ADD_WARNING: {
            // 詳細データから対象日付の追加データ件数を取得し、追加データを詳細データから削除
            const detailAddCount = Object.keys(tartgetDetail).filter(dateTime => {
              if (
                dateTime.startsWith(date)
                && (
                  tartgetDetail[dateTime] === ADD
                  || tartgetDetail[dateTime] === ADD_WARNING)) {
                delete tartgetDetail[dateTime];
                return true;
              }
              return false;
            }).length;

            // 詳細データから対象日付の保存済データ件数を取得し、保存済データを中止指示にする
            const detailSavedCount = Object.keys(tartgetDetail).filter(dateTime => {
              if (
                dateTime.startsWith(date)
                && tartgetDetail[dateTime] === SAVED) {
                tartgetDetail[dateTime] = CANCEL;
                return true;
              }
              return false;
            }).length;

            // 未保存の依頼があった場合、削除する
            targetObj.data[date] -= detailAddCount + detailSavedCount;
            if (detailSavedCount > 0) {
              tartgetData[date] = CANCEL;
            } else {
              delete tartgetData[date];
            }
            editedDate.push(date);
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

      const editedDateTime = [];
      editedDate.forEach(date => {
        editedDateTime.push(`${date}_00:00`);
      });

      // カウントの文字色設定
      this.updateEditScheduleStatusStore({
        targetDateList: editedDate,
        targetDateTimeList: editedDateTime,
        radSetTargetList: [patId],
      });
    },
    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
    showRadName(cd) {
      const radSet = this.getRadSetName.find(item => cd == item.radSetCd);
      return radSet ? radSet.radSetName : "";
    },
    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
    // 保存処理
    async saveRecord() {
      if (!validateSelectDoctor(this.selectDoctor)) return;

      const saveData = checkAndCreateSaveRadData(this.selectDoctor);
      if (!(await confirmCheckResult(saveData))) return;

      this.executeUpload(saveData.request);
    },
    // 保存実施
    async executeUpload(request) {
      const params = {
        request,
        isRadDetail: "0",
      };
      await executeUploadTemplete(
        this.updateRecordList(params),
        () => {
          // 再表示
          this.showCalendar();
        },
        "RadRequestComponent.vue",
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
      if (!checkRadAuthorized()) return;
      if (this.isOtherFacility(celObj)) return;

      let targetObj = this.getEditRadRequestList.filter(function(item){
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
        switch(targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["data"][setDate]) {
          case CANCEL: {
            let detailCount = 0;
            Object.keys(targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"])
              .forEach(detailKey => {
                // del FutreNetWeb+SI課題管理No6043 趙 start
                // if (detailKey.match(new RegExp(setDate)) &&
                //     targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][detailKey] === CANCEL) {
                // del FutreNetWeb+SI課題管理No6043 趙 end
                if (detailKey.match(new RegExp(setDate))) {
                  detailCount++;
                }
                targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][detailKey] = SAVED;
                // }
              });
            // 中止指示の場合は、中止指示をキャンセル
            targetObj[0]["data"][setDate] += detailCount;
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["data"][setDate] = SAVED;
            break;
          }
          case SAVED: {
            // 処理対象が「結果あり」の時はメッセージを出力
            if (celObj.radStatus[setDate] && celObj.radStatus[setDate] === "1") {
              this.$ons.notification.confirm({
                // title: "結果あり予定の中止",
                title: DIALOG_MESSAGES[13000165].title,
                // message: "結果が存在する一般撮影検査予定を中止しようとしています。中止してよろしいですか？",
                message: messageFormat(DIALOG_MESSAGES[13000165].message),
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
          }
          case ADD:
          case ADD_WARNING: {
            // 詳細データから対象日付の追加データ件数を取得し、追加データを詳細データから削除
            const detailAddCount = Object.keys(targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"])
              .filter(detailKey => {
                if (detailKey.match(new RegExp(setDate))) {
                  if (targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][detailKey] === ADD ||
                      targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][detailKey] === ADD_WARNING) {
                    delete targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][detailKey]
                    return true;
                  }
                }
                return false;
              }).length;
            // 詳細データから対象日付の保存済データ件数を取得
            const detailSavedCount = Object.keys(targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"])
              .filter(detailKey => {
                if (detailKey.match(new RegExp(setDate))) {
                  return targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][detailKey] === SAVED;
                }
                return false;
              }).length;

            // 未保存の依頼があった場合、削除する
            targetObj[0]["data"][setDate] -= detailAddCount + detailSavedCount;
            if (detailSavedCount > 0) {
              targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["data"][setDate] = CANCEL;
            } else {
              delete targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["data"][setDate];
            }
            break;
          }
          default: {
            // 空白欄：依頼を追加する
            targetObj[0]["data"][setDate] += 1;
            const flg = hasScheduleOnTargetDate(celObj.patId, setDate) ? ADD : ADD_WARNING;
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["data"][setDate] = flg;
            //FutreNetWeb+SI課題管理 no.6040 劉全航 start
            // targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][setDate + "_00:00"] = flg
            let setTime = "00:00";
            if (celObj.radTime[setDate]) {
              setTime = celObj.radTime[setDate];
            }
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][setDate + "_" + setTime] = flg
            //FutreNetWeb+SI課題管理 no.6040 劉全航 end
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["status"][setDate] = "0";
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["isLock"][setDate] = deadlineFlg;
            break;
          }
        }
      } else {
        // ヘッダーをクリックした場合の処理
        Object.keys(targetObj[0].radItemSet).forEach(regOrderClassKey => {
          Object.keys(targetObj[0].radItemSet[regOrderClassKey]).forEach(radSetCdKey => {
            const radItem = targetObj[0].radItemSet[regOrderClassKey][radSetCdKey];
            const cellFacility = radItem.facilityCd && radItem.facilityCd[setDate];
            if (cellFacility && cellFacility !== this.getFacilityCd) {
              return;
            }
            // クリックされたセルの状態によって、フラグを更新する
            switch(targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["data"][setDate]) {
              case SAVED: {
                const detailCount = Object.keys(targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"])
                  .filter(detailKey => {
                    if (detailKey.match(new RegExp(setDate))) {
                      if (targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"][detailKey] === SAVED) {
                        targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"][detailKey] = CANCEL;
                        return true;
                      }
                    }
                    return false;
                  }).length;
                // 依頼ありの場合、中止指示にする
                targetObj[0]["data"][setDate] -= detailCount;
                targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["data"][setDate] = CANCEL;
                break;
              }
              case ADD:
              case ADD_WARNING: {

                const detailAddCount = Object.keys(targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"])
                  .filter(detailKey => {
                    if (detailKey.match(new RegExp(setDate))) {
                      if (targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"][detailKey] === ADD ||
                          targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"][detailKey] === ADD_WARNING) {
                        delete targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"][detailKey]
                        return true;
                      }
                    }
                    return false;
                  }).length;

                const detailSavedCount = Object.keys(targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"])
                  .filter(detailKey => {
                    if (detailKey.match(new RegExp(setDate))) {
                      if (targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"][detailKey] === SAVED) {
                        targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["dataDetail"][detailKey] = CANCEL;
                        return true;
                      }
                    }
                    return false;
                  }).length;

                // 未保存の依頼があった場合、削除する
                targetObj[0]["data"][setDate] -= detailAddCount + detailSavedCount;
                if (detailSavedCount > 0) {
                  targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["data"][setDate] = CANCEL;
                } else {
                  delete targetObj[0].radItemSet[regOrderClassKey][radSetCdKey]["data"][setDate];
                }
              }
            }
          })
        })

      }

      // this.getEditRadRequestListの要素内の情報を更新したリアクションを起こさせる
      this.getEditRadRequestList.splice();

      // カウントの文字色設定
      this.updateEditScheduleStatusStore({"targetDateList": [setDate], "targetDateTimeList": [setDate + "_" + "00:00"], "radSetTargetList": [celObj.patId]});
    },
    exeChangeToCancel(targetObj, celObj, setDate) {
      let detailCount = 0;
      Object.keys(targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"])
        .forEach(detailKey => {
          if (detailKey.match(new RegExp(setDate)) &&
              targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][detailKey] === SAVED) {
            detailCount++;
            targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["dataDetail"][detailKey] = CANCEL;
          }
        });
      // 依頼ありの場合、中止指示にする
      targetObj[0]["data"][setDate] -= detailCount;
      targetObj[0].radItemSet[celObj.regOrderClass][celObj.radSetCd]["data"][setDate] = CANCEL;
    },

    // withCancel: true => CANCELデータを含める、false/undefined => CANCELデータを含めない
    getPatRadPatternFiltered(celObj, setData, withCancel) {
      let { patId } = celObj;
      if (patId) patId = String(patId);
      const { radPattern, radWeek } = setData;
      return (patId && radPattern && radWeek)
        ? this.getPatRadPatternList.filter(item => (
          (withCancel || item.status !== CANCEL)
          && patId === String(item.patId)
          && radPattern === item.radPattern
          && radWeek === item.radWeek
          && item.facilityCd === this.getFacilityCd))
        : [];
    },
    getPatRowCellStyle(celObj, setData) {
      const patRadPatternFiltered = this.getPatRadPatternFiltered(celObj, setData);
      if (!patRadPatternFiltered.length) return;

      // 予定有無を判別して文字色を変える
      const targetRadPattern = patRadPatternFiltered.pop();
      const fontColor = hasTreatmentPatternOnWeek(targetRadPattern)
        ? FONTCOLOR_HAS_SCHEDULE
        : FONTCOLOR_HAS_NOT_SCHEDULE;
      return {
        "font-weight": "bold",
        color: fontColor,
      };
    },
    getPatRowCellNumber(celObj, setData) {
      const patRadPatternFiltered = this.getPatRadPatternFiltered(celObj, setData);
      if (!patRadPatternFiltered.length) return;

      return patRadPatternFiltered.length;
    },

    getImgAttributesForDate(celObj, setDate) {
      const imgAttrs = {
        src: "",
        class: "",
        style: "",
      };
      const { radData, radStatus, nowIsLock, patId } = celObj;
      const setDateData = radData[setDate];
      const isLockFlg = radStatus[setDate] === "1" || nowIsLock[setDate] === "1";
      switch (setDateData) {
        case CANCEL:
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
          if (hasScheduleOnTargetDate(patId, setDate)) {
            Object.assign(imgAttrs, {
              src: publicAssetPath("img/rad-request/32-32_2.png"),
              class: "symbol-request-saved td-img",
              style: `background-color: ${isLockFlg ? FILLCOLOR_HAS_SCHEDULE + "!important" : FILLCOLOR_DEFAULT}`,
            });
          } else {
            Object.assign(imgAttrs, {
              src: publicAssetPath("img/rad-request/32-32_3.png"),
              class: "symbol-request-saved td-img",
              style: `background-color: ${isLockFlg ? FILLCOLOR_HAS_NOT_SCHEDULE + "!important" : FILLCOLOR_DEFAULT}`,
            });
          }
          break;
        case ADD:
          Object.assign(imgAttrs, {
            src: publicAssetPath("img/rad-request/32-32_2.png"),
            class: "symbol-request-unsaved td-img",
            style: `background-color: ${isLockFlg ? FILLCOLOR_HAS_SCHEDULE + "!important" : FILLCOLOR_DEFAULT}`,
          });
          break;
        case ADD_WARNING:
          Object.assign(imgAttrs, {
            src: publicAssetPath("img/rad-request/32-32_3.png"),
            class: "symbol-request-noplan td-img",
            style: `background-color: ${isLockFlg ? FILLCOLOR_HAS_NOT_SCHEDULE + "!important" : FILLCOLOR_DEFAULT}`,
          });
          break;
      }
      return imgAttrs;
    },
    getSetRowCellNumberForDate(celObj, setDate) {
      const { radDataDetail } = celObj;
      // 日付が一致し、CANCELでない依頼データの件数
      const detailCount = Object.keys(radDataDetail).filter(detailKey => (
        detailKey.startsWith(setDate)
        && radDataDetail[detailKey] !== CANCEL)).length;
      return detailCount;
    },

    getPatRadSetPatternFiltered(celObj, setData) {
      let { patId, radSetCd } = celObj;
      if (patId) patId = String(patId);
      if (radSetCd) radSetCd = String(radSetCd);
      const { radPattern, radWeek } = setData;
      return (patId && radSetCd && radPattern && radWeek)
        ? this.getPatRadPatternList.filter(item => (
          patId === String(item.patId)
          && radSetCd === String(item.orderRadSetCd)
          && radPattern === item.radPattern
          && radWeek === item.radWeek))
        : [];
    },
    getImgAttributesForPattern(celObj, setData) {
      const imgAttrs = {
        src: "",
        class: "",
        style: "",
      };
      const targetRadPattern = this.getPatRadSetPatternFiltered(celObj, setData).pop();
      if (targetRadPattern) {
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
                style: `background-color: ${FILLCOLOR_DEFAULT};`,
              });
            } else {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/rad-request/32-32_3.png"),
                class: "symbol-request-saved td-img",
                style: `background-color: ${FILLCOLOR_DEFAULT};`,
              });
            }
            break;
          case ADD:
            // 予定有無を判別して画像を変える
            if (hasTreatmentPatternOnWeek(targetRadPattern)) {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/rad-request/32-32_2.png"),
                class: "symbol-request-unsaved td-img",
                style: `background-color: ${FILLCOLOR_DEFAULT};`,
              });
            } else {
              Object.assign(imgAttrs, {
                src: publicAssetPath("img/rad-request/32-32_3.png"),
                class: "symbol-request-unsaved td-img",
                style: `background-color: ${FILLCOLOR_DEFAULT};`,
              });
            }
            break;
        }
      }
      return imgAttrs;
    },
    getSetRowCellNumberForPattern(celObj, setData) {
      const patRadPatternFiltered = this.getPatRadSetPatternFiltered(celObj, setData);
      return patRadPatternFiltered.filter(item => item.status !== CANCEL).length;
    },

    // 文字色および背景色
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

      const { headerflg, patId, radSetCd, regOrderClass } = celObj;
      const classNames = [];
      const key = headerflg
        // 患者名行
        ? makeRequestHeaderKey(patId, setDate)
        // 患者名行以外
        : makeRequestSetKey(patId, radSetCd, regOrderClass, setDate);
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
      const { headerflg, patId, radSetCd, regOrderClass } = celObj;
      const { radPattern, radWeek } = setData;
      const classNames = [];
      const key = headerflg
        // 患者名行
        ? makePatternHeaderKey(patId, radPattern, radWeek)
        // 患者名行以外
        : makePatternSetKey(patId, radSetCd, regOrderClass, radPattern, radWeek);
      if (this.editColorMap[key]) {
        // 編集状態のパターンが存在する場合
        classNames.push("exam-edited-cell");
      }
      return classNames;
    },
    // 文字色および背景色（前回検査日）
    fontColorRadDateColumn(celObj) {
      const rtn = {};
      if (celObj.headerflg) {
        // 患者名行
        rtn["color"] = "#fff";
        rtn["text-align"] = "left";
      } else {
        rtn["background-color"] = BACKGROUND_ROW_PATNAME;
      }
      return rtn;
    },
    // 全チェックのチェックボックスの処理
    setAllCheck(isRefresh) {
      if (!isRefresh && this.allCheckFlg) {
        // チェックを外す
        this.radSetTargetList = [];
        this.allCheckFlg = false;
        this.setCheckedPatId(null);
      } else if (isRefresh && this.allCheckFlg) {
        this.radSetTargetList = this.allCheckPatIdList;
      } else if (isRefresh && !this.allCheckFlg) {
        this.radSetTargetList = [];
        this.allCheckFlg = false;
        this.setCheckedPatId(null);
      } else {
        // this.radSetTargetList には文字型のデータが入ってくる為変換する
        this.radSetTargetList = this.allCheckPatIdList;
        this.allCheckFlg = true;
        this.setCheckedPatId(this.allCheckPatIdList);
      }
    },
    // 放射線検査一覧で患者IDをチェックする
    setOneCheck(patId) {
      this.checkPatId = patId ? patId : null;
      // 患者のチェックボックスを取得しチェックが入れられたか外されたか判定
      const patCheckbox = getScopedElementsByClassName("pat-list-item", this.$el || null);
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
    chkCalenDate(str) {
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
          this.generateSortedList();
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
      this.radSetTargetList = [];
      this.updateRadSetTargetList(this.radSetTargetList);

      const patIdList = [];
      if (this.searchedPatListClone.length) {
        // 患者検索で表示されている患者のIDリストを取得
        patIdList.push(...this.searchedPatListClone.map(element => element.pat_id));
        // チェック判定用配列に文字列配列にして格納
        this.allCheckPatIdList = patIdList.map(String);
      }

      // 治療パターンの取得
      this.searchRadRequest({
        patIdList,
        startDate: "",
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
        getErrorMessage("RadRequestComponent.vue", "showCalendar", error);
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
    async refresh() {
      if (await this.controller.confirmAllowDiscardChangesForRefresh()) {
        // キャンセルされなかった場合
        this.exeClear();
        this.allCheckFlg = true;
        this.setAllCheck(true);
        EventBus.$emit("emptyRadSet");
      }
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
        getErrorMessage("RadRequestComponent.vue", "updateMaxDate", error);
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
      if (!checkRadAuthorized()) return;
      const cellFacility = celObj.facilityCd;
      if (cellFacility && cellFacility !== this.getFacilityCd) {
        return;
      }

      const savePatRadPatternCopy = [...this.getSavePatRadPattern];
      let { headerflg, patId, radSetCd } = celObj;
      if (patId) patId = String(patId);
      if (radSetCd) radSetCd = String(radSetCd);
      const { radPattern, radWeek } = setData;
      // 処理を実行する検査パターンをフィルタリング
      const targetList = this.getPatRadPatternList.filter(item => (
        patId && patId === String(item.patId)
        && (headerflg || (radSetCd && radSetCd === String(item.orderRadSetCd)))
        && radPattern && radPattern === item.radPattern
        && radWeek && radWeek === item.radWeek
        && item.facilityCd === this.getFacilityCd));
      // フィルタリングされた検査パターンの中から中止されているものを取得
      const cancelLength = targetList.filter(item => { return item.status === CANCEL}).length
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
      radPatternListCopy.forEach(target => {
        if (
          target.status !== CANCEL
          && setData.radPattern && setData.radPattern === target.radPattern
          && setData.radWeek && setData.radWeek === target.radWeek
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
                      item.radPattern === target.radPattern &&
                      item.radWeek === target.radWeek
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
        const { radPattern, radWeek } = data.setData;
        return `${radPattern}:${radWeek}`;
      }
    },
    /**
     * 表示データ生成
     * - ソート条件に従ってソート実施
     * - ソート後、簡易モードの場合はヘッダのみ抽出してリスト返却
     */
    generateSortedList() {
      const list = this.radRequestListInDisplayPeriod.slice();
      this.sortedList = sortList(list, this.sort, this.getPatRowCellNumber, this.getPatRadPatternFiltered);
      // add #12121応対について 患者ID列の罫線の表示に関する修正 fang start
      this.rowSpanSetting();
      // add #12121応対について 患者ID列の罫線の表示に関する修正 fang end
    },
    // add #12121応対について 患者ID列の罫線の表示に関する修正 fang start
    rowSpanSetting() {
      if (this.sortedList) {
        let spanNum = 1;
        for (let i = this.sortedList.length - 1; i >= 0; i--) {
          const detail = this.sortedList[i];
          if (detail.headerflg) {
            detail.headerSpan = spanNum;
            spanNum = 1;
          } else {
            spanNum++;
          }
        }
      }
    },
    // add #12121応対について 患者ID列の罫線の表示に関する修正 fang end

    isOtherFacility(listDate) {
      return !!listDate?.facilityCd && listDate.facilityCd != this.getFacilityCd;
    },
    loadOtherFacilityExamSet(facilityCd, patId) {
      if (!facilityCd || Object.prototype.hasOwnProperty.call(this.otherFacilityCache, facilityCd)) return;
      this.otherFacilityCache = {
        ...this.otherFacilityCache,
        [facilityCd]: null,
      };
      const selectedPatId = this.selectedPatId ?? patId;
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
    async openOtherFacilityPopover(listDate) {
      const facilityCd = listDate.facilityCd;
      const res = await ApiHelper.get(
        `master_maintenance/mst_rad_set/data/${facilityCd}`,
        {
          selectedPatId: this.selectedPatId
        }
      ).catch(error => {
        getErrorMessage(
          "RadRequestComponent.vue",
          "openOtherFacilityPopover",
          error
        );
        throw error;
      });
      const setDetail = res.data.localDataSource.data;
      const target = setDetail.find(item => String(item.code) === String(listDate.radSetCd));
      this.otherFacilityDetailList = target ? JSON.parse(target.radItemInfo || "[]") : [];
      this.$nextTick(() => {
        let ref = this.$refs[`showDetail_${listDate.radSetCd}`];
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

    /**
     * 固定列のleft値を、実際の列幅に合わせて再計算しcss変数へ反映する。
     * - 患者ID列が非表示の場合、患者ID列幅は0pxとして扱う。
     * - 列幅はユーザーが変更可能なため、ヘッダー要素の実測値を使用し計算を行う。
     */
    updateStickyColumnLeft() {
      if (!this.$el) return;

      // チェックボックス列
      const checkWidth = 44; // cssで指定されているwidth36px + padding左右計8px = 44

      // 患者ID列
      const patIdWidth = (this.isShowHospPatId && this.$refs.hospPatIdHeader)
        ? this.$refs.hospPatIdHeader.getBoundingClientRect().width
        : 0; // 患者ID列非表示の場合は0pxとする

      // 患者名列
      const patNameWidth = this.$refs.patNameHeader
        ? this.$refs.patNameHeader.getBoundingClientRect().width
        : 108; // cssで指定されているwidth100px + padding左右計8px = 108

      // 患者名列のleft値を算出 (チェックボックス列幅 + 患者ID列幅)
      const patNameLeft = checkWidth + patIdWidth;
      // 前回検査日列のleft値を算出 (チェックボックス列幅 + 患者ID列幅 + 患者名列幅)
      const lastRadDateLeft = patNameLeft + patNameWidth;

      // 算出したleft値をcss変数へ反映
      this.$el.style.setProperty("--sticky-pat-name-left", `${patNameLeft}px`);
      this.$el.style.setProperty("--sticky-last-rad-date-left", `${lastRadDateLeft}px`);
    },

    /**
     * 固定列ヘッダーの幅変更監視を開始する。
     */
    startStickyColumnResizeObservers() {
      // 二重監視防止
      this.stopStickyColumnResizeObservers();

      const targets = [
        this.$refs.hospPatIdHeader, // 患者ID列ヘッダー
        this.$refs.patNameHeader,   // 患者名列ヘッダー
      ].filter(Boolean);            // filter(Boolean)で患者ID列非表示時など存在しないrefは除外

      targets.forEach(target => {
        const observer = new ResizeObserver(() => {
          this.updateStickyColumnLeft();
        });
        observer.observe(target);
        this.stickyColumnResizeObservers.push(observer);
      });

      this.$nextTick(() => {
        // 監視開始直後にも一度left値を再計算し、css変数を初期化
        this.updateStickyColumnLeft();
      });
    },

    /**
     * 固定列ヘッダーの幅変更監視を停止し、ResizeObserverをすべて破棄する。
     */
    stopStickyColumnResizeObservers() {
      this.stickyColumnResizeObservers.forEach(observer => observer.disconnect());
      this.stickyColumnResizeObservers = [];
    },

    /**
     * 前回検査日列のヘッダーか判定する。
     */
    isLastRadDateHeader(data) {
      return data && data.dateFormat === "前回検査日";
    }
  },
  watch: {
    // 検索リストに表示されている患者
    searchedPatList() {
      // 編集中でなければ更新
      this.searchedPatListClone = JSON.parse(JSON.stringify(this.searchedPatList));
      this.showCalendar();
      if (this.searchedPatListClone.length) {
        this.radSetTargetList = this.allCheckPatIdList;
        this.allCheckFlg = true;
        this.updateRadSetTargetList(this.radSetTargetList);
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
    radSetTargetList() {
      // 全選択チェック
      this.allCheckFlg = !!(
        this.allCheckPatIdList.length
        && this.radSetTargetList.length === this.allCheckPatIdList.length);
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
    // 詳細/簡易モード変更
    showDetailsDisplay() {
      // 表示リスト生成
      this.generateSortedList();

      this.$nextTick(() => {
        // 固定列のleft値を実際の列幅をもとに再計算
        this.updateStickyColumnLeft();
      });
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
    "messageDialogInfo.isDialogVisible"(isShow) {
      this.isUpdating = isShow ? false : this.isUpdating;
    },
    // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
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
    getPatientShareMode() {
      this.showCalendar();
    },
    getPatientShareFacilityCdMode() {
      this.showCalendar();
    },
    /** 患者ID列の表示/非表示で固定列 left を再計算 */
    isShowHospPatId() {
      this.$nextTick(() => {
        this.updateStickyColumnLeft();
      });
    },
  },
  async created() {
    this.startLoadingScreen();

    // 患者別画面のデータが残っている場合があるためクリアしておく
    this.clearSearchedRadRequest();

    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
    sendRequestGetMstRadSetList(this.getFacilityCd, this.selectedPatId).then(response => {
      response.data.forEach(item => {
        if (item.isDisp === "1") {
          this.getRadSetName.push(item);
        }
      });
    });
    // add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end

    await this.getPatSame();
    this.setCalendarCheckedDate(null);

    // 端末判別
    const ua = getScopedUserAgent(this.$el);
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
    if (ua.match(/Mac/)) {
      this.isIOS = true;
    }
    if (this.isAndroid || this.isIOS) {
      this.setAndroidOrIOS(true);
    } else {
      this.setAndroidOrIOS(false);
    }

    // サインインユーザのデフォルト設定を確認・設定
    if (this.isStoredShowDate) {
      setShowDateToCondition(this.condition, this.getStartToEndDate);
      // 詳細/簡易モードをストアから復元
      this.chkDetailSimple = this.showDetailsDisplay ? "1" : "2";
    } else {
      // 検索期間なし → デフォルト設定を使用
      const defaultRadRequest = this.getDefaultSetting[RAD_REQUEST.KEY_NAME];
      if (defaultRadRequest) {
        // 表示期間・開始
        const defaultStartDate = defaultRadRequest[RAD_REQUEST.KEY_NAME_START_DATE];
        if (defaultStartDate != null) {
          this.condition.startDate = calcTargetDate(defaultStartDate);
        }
        // 表示期間・終了
        const defaultEndDate = defaultRadRequest[RAD_REQUEST.KEY_NAME_END_DATE];
        if (defaultEndDate != null) {
          this.condition.endDate = calcTargetDate(defaultEndDate);
        }
        // 詳細・簡易切り替え
        const defaultShowDetail = defaultRadRequest[RAD_REQUEST.KEY_NAME_IS_SHOW_DETAIL_DISPLAY];
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
        const defaultShowPatId = defaultRadRequest[RAD_REQUEST.KEY_NAME_IS_SHOW_HOSP_PAT_ID];
        if (defaultShowPatId !== undefined) {
          this.isShowHospPatId = defaultShowPatId;
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
    await this.setRadDeadline({
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
    this.setAllCheck(false);
    // 放射線検査一覧で患者IDをチェックする
    this.setOneCheck();

    // 休日マスタの休日を取得
    await this.fetchHolidays(this.getFacilityCd);

    this.finishLoadingScreen();
  },
  mounted() {
    this.$nextTick(() => {
      const ownerWindow = getScopedWindow(this.$el) || window;
      const setHeight = ownerWindow.setInterval(() => {
        if (getScopedElementById("bottom-buttons", this.$el || null)) {
          this.calculateGridHeight();
          ownerWindow.clearInterval(setHeight);
        }
      });

      // 固定列ヘッダーの幅変更監視を開始
      this.startStickyColumnResizeObservers();
    });

    EventBus.$on("refresh", this.refresh);
    EventBus.$on("addSchedule", this.generateSortedList);
  },
  beforeUnmount() {
    this.stopStickyColumnResizeObservers();
    this.clearHolidays(); // storeの休日マスタをクリア
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("addSchedule", this.generateSortedList);

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
/* #12121応対について 患者ID列の罫線の表示に関する修正 START */
td {
  text-align: center;
  box-shadow: 
    inset 0 0.5px 0 #cccccc,    
    inset 0 -0.5px 0 #cccccc,  
    inset 0.5px 0 0 #cccccc,   
    inset -0.5px 0 0 #cccccc !important;  
}

th {
  box-shadow: 
    inset 0 0.5px 0 #cccccc,    
    inset 0 -0.5px 0 #cccccc,  
    inset 0.5px 0 0 #cccccc,   
    inset -0.5px 0 0 #cccccc !important;  
}

tr td:last-child {
  border-right: none;
}
/* #12121応対について 患者ID列の罫線の表示に関する修正 END */

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
  margin-right: 0px;
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
.bottom-buttons-label {
  white-space: nowrap;
  width: 3.0em;
  text-align: right;
  margin-right: 0.25em;
}
.scroll-table {
  --height: 500px;
  height: var(--height);
  overflow: auto;
  margin-top: 5px;
  margin-bottom: 5px;
}
/* #12121応対について 患者ID列の罫線の表示に関する修正 START */
.grid-record-list {
  border-collapse: collapse;
  border-spacing: 0;
  width: calc(100vw - 10rem);
  background-color: var(--ntss-list-background-color);
}
.ntss-list-header-th-sticky {
  font-weight: none;
  z-index: 1;
  white-space: unset;
  border: none;
}
/* #12121応対について 患者ID列の罫線の表示に関する修正 END */
/* 詳細/簡易ボタン */
input[type="radio"] {
  /* ラジオボタンを非表示にする */
  display: none;
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: 15em;
  display: flex;
}

.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 30%; /* ボックスの横幅を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  margin: 15px 0px;
  white-space: nowrap;
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
/* #main-idスコープ内で使用するcss変数の定義 */
#main-id {
  /* 固定列のleft値を保持するcss変数 (javascriptで列幅実測値で再計算され上書きされる) */
  --sticky-pat-name-left: 44px;
  --sticky-last-rad-date-left: 152px;
}
.col-sticky-check {
  width: 36px;
  border-left: none;
  border-right: none;
  position: -webkit-sticky;
  position: sticky;
  left: 0;
}
.col-sticky-name {
  position: -webkit-sticky;
  position: sticky;
  text-align: unset;
  white-space: normal;
  word-break: break-all;
  left: var(--sticky-pat-name-left); /* 患者ID列の現在幅から算出したleft値 */
  border-left: none;
  border-right: none;
  box-shadow: 1px 0px 0px #ffffff inset;
  width: 100px;
}
.col-sticky-names {
  width: 100px;
  left: var(--sticky-last-rad-date-left); /* 患者ID列と患者名列の現在幅から算出したleft値 */
  box-shadow: 1px 0px 0px #ffffff inset,-1px 0px 0px #ffffff inset;
  color: #ffffff;
  border-left: none;
  border-right: none;
  position: sticky;
}
.col-sticky-namess {
  width: 100px;
  left: var(--sticky-last-rad-date-left); /* 患者名列の現在幅から算出したleft値 */
  box-shadow: 1px 0px 0px #ffffff inset;
  color: #ffffff;
  border-left: none;
  border-right: none;
  position: sticky;
}
.col-check-header {
  z-index: 1;
  border-top: solid 1px #cccccc !important;
  border-bottom: none;
}
.col-check-nonheader {
  border-top: none;
  border-bottom: none;
}
.ind-user-selector {
  margin-top: 0.5em;
  width: 15em;
}
.ind-user-selector .selectbox {
  width: 100%;
}
.col-sticky-id {
  border-left: none;
  border-right: none;
  left: 44px;
  width: 100px;
  text-align: unset;
  white-space: normal;
  word-break: break-all;
  position: sticky;
}
.rad-control-cell :deep(.td-img) {
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
.rad-control-cell :deep(.td-rad-count) {
  font-size: 0.9em;
  font-weight: bold;
  /* 背景塗りつぶし用 */
  position: absolute;
  transform: translate(-50%, -50%);
  top: 50%;
  left: 50%;
}
.pat-id-popover :deep(.popover--top) {
  max-width: 18em;
}
.pat-id-popover :deep(.popover--top > .popover__content) {
  font-size: 1.6em;
  height: auto;
  min-height: 0;
}
.pat-id-popover :deep(.popover--top > .popover__content label) {
  margin-right: 5px;
}
.pat-id-popover :deep(.popover-content-row) {
  margin-bottom: 10px;
}
.pat-id-popover :deep(.popover--top > .popover-content .popover--top),
.pat-id-popover :deep(.popover--top > .popover-content .popover--right),
.pat-id-popover :deep(.popover--top > .popover-content .popover--left),
.pat-id-popover :deep(.popover--top > .popover-content .popover--bottom) {
  width: initial;
}
.pat-id-popover :deep(.popover-content-header .popover__content) {
  width: 200px;
  min-height: auto;
}
.pat-id-popover :deep(.popover-content-div) {
  margin: 5px;
}
.p_left {
  padding-left: 30px;
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

.col-check-nonheader {
  z-index: 1;
}
.col-check-header {
  z-index: 1;
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
/* #12121対応 チェックボックス列の罫線の表示に関する修正 START */
.ntss-list-header-th-sticky-checkbox {
    color: #fff;
    background-color: var(--ntss-list-header-background-color);
    font-weight: unset;
    padding: 4px;
    z-index: 1;
    white-space: unset;
    vertical-align: top;
}

.ntss-list-header-th-sticky-checkbox.col-check-header::before {
    content: "";
    position: absolute;
    left: 0;
    top: -1px;
    width: 100%;
    height: 1px;
    background-color: #cccccc;
    pointer-events: none;
    z-index: 2;  
}

.ntss-list-header-th-sticky-checkbox.lable-check-box {
    position: sticky;
    top: 0;
    left: 0;
    z-index: 3;
    border-bottom: none;
}

.ntss-list-header-th-sticky-checkbox.col-check-nonheader {
    position: relative;
    z-index: 2;
    top: -1px;
    border-top: solid 5px #333333 !important;
    height: 32px;
}
/* #12121対応 チェックボックス列の罫線の表示に関する修正 END */
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
