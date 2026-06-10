/**
 * 一般撮影検査依頼ページ用ヘッダ
 */
<template>
  <v-card>
    <div class="header-item rad-header-item" id="rad-header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea
            :conditionList="conditionList"
            :isRequestCond="true"
            @show-popover="showPopover"
          />
        </v-ons-col>
        <v-ons-col class="list-rad-name">
          <div class="zoom-items d-flex flex-row">
            <div style="margin-top: 2px;">
              <img
                :src="image_src_full_screen"
                style="margin: 5px;"
                class="ntss-fab-icon"
                height="30px"
                width="30px"
                @click="showPopoverZoom"
              />
            </div>
            <div class="filter-area"></div>
            <!-- 検査セット一覧 -->
            <div class="rad-set-list">
              <div class="rad-set-list-frame">
                <div
                  v-for="set in getRadSetNameList"
                  :key="set.radSetCd"
                  style="border: solid gray 1px;"
                >
                  <div class="rad-set-item">
                    <label class="rad-set-label">
                      <div v-if="showRadioButtonFlg">
                        <v-ons-checkbox
                          type="checkbox"
                          class="rad-set-list-item"
                          :value="set.radSetCd"
                          v-model="selectedValueList"
                          :disabled="!getRadAuthorized()"
                        />
                      </div>
                      <span
                        class="rad-set-check-item-span title"
                        :class="{ 'rad-set-check-item-span-detail': !showRadioButtonFlg }"
                      >{{ set.radSetName }}</span>
                    </label>
                    <v-ons-button
                      style="width: 3em; margin-left: auto; font-size: 0.6em; background: #4291B9; color: #ffffff; border-bottom: solid 2px #4974a0; height: 2.2em;"
                      @click="addScheduleByAddButton(set.radSetCd)"
                      :disabled="!getRadAuthorized()"
                    >追加</v-ons-button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      v-if="zoomPopoverVisible"
      :visible.sync="zoomPopoverVisible"
      :target="zoomPopoverTarget"
      :class="[fontSizeSet, radSetListPop]"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div>
        <div class="rad-set-list-frame" style="margin: 10px; max-height: 400px; overflow-x: auto; flex-wrap: nowrap;">
          <div
            v-for="(set) in getRadSetNameList"
            :key="set.radSetCd"
            style="border: solid gray 1px; margin-bottom: 2px; border-radius: 4px;"
          >
            <div class="rad-set-item">
              <label class="rad-set-label">
                <div v-if="showRadioButtonFlg">
                  <v-ons-checkbox
                    type="checkbox"
                    class="rad-set-list-item"
                    :value="set.radSetCd"
                    v-model="selectedValueList"
                    :disabled="!getRadAuthorized()"
                    aria-readonly=""
                  />
                </div>
                <span
                  class="rad-set-list-item-span title"
                  :class="{ 'rad-set-list-item-span-detail': !showRadioButtonFlg }"
                >{{ set.radSetName }}</span>
              </label>
              <v-ons-button
                class="button btn3-normal common-style-ok-button"
                @click="addScheduleByAddButton(set.radSetCd)"
                style="margin-left: auto; min-width: 100px;"
                :disabled="!getRadAuthorized()"
              >追加</v-ons-button>
            </div>
          </div>
        </div>
      </div>
    </v-ons-popover>
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'exam-request-header']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div style="margin:10px;">
        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label>検査間隔</label>
          </v-ons-col>
          <v-ons-col width="70%" vertical-align="center">
            <v-ons-select
              v-model="condition.inProgress.setInterval"
              @change="changeInterval"
            >
              <option
                v-for="item in setIntervalList"
                :key="item.value"
                :value="item.value"
              >{{ item.name }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label>時刻</label>
          </v-ons-col>
          <v-ons-col vertical-align="center">
            <!-- mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、紹介状、処方、患者イベントのデータが正常に表示されない djy start -->
            <time-input
              float
              v-model="condition.inProgress.setTime"
              @handleClearInput="condition.inProgress.setTime = ''"
              style="width: auto;"
            />
            <!-- mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、紹介状、処方、患者イベントのデータが正常に表示されない djy end -->
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label>曜日</label>
          </v-ons-col>
          <v-ons-col width="70%" vertical-align="center">
            <div v-for="(week, index) in indWeeks" :key="index">
              <input
                v-model="condition.inProgress.selectedDayOfWeek"
                :disabled="!inProgressIntervalState.isWeekRepeat"
                :value="week.value"
                :id="'radWeekCheck-' + index"
                class="week-checkbox"
                type="radio"
                style="display: none;"
                name="radWeekCheck"
              />
              <label
                :for="'radWeekCheck-' + index"
                onclick="null"
                style="cursor: pointer;"
                class="week-button"
                :class="!inProgressIntervalState.isWeekRepeat ? 'span-disabled' : ''"
              >{{ week.text }}</label>
            </div>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label style="font-size: 1.6em;">指示期間</label>
          </v-ons-col>
          <v-ons-col width="70%" vertical-align="center" style="white-space: nowrap;">
            <!-- 検査間隔 ≠ 年間複数日 -->
            <span v-if="!inProgressIntervalState.isMultiDays">
              <input
                type="date"
                style="width: auto;"
                class="ntss-input-date ntss-custom-input"
                @blur="checkInputDate('startDate')"
                :max="maxDate"
                v-model="condition.inProgress.startDate"
              />
              <common-calendar
                v-model="condition.inProgress.startDate"
                :disableDatesAfter="disableDatesAfter"
              />
            </span>
            <!-- 検査間隔 = 年間複数日 -->
            <span v-else>
              <v-ons-button
                class="btn3-normal"
                style="width: 8em;"
                @click="showCalendar"
              >年間カレンダー</v-ons-button>
            </span>
          </v-ons-col>
        </v-ons-row>
        <!-- 検査間隔が「指定日1回分」の時は表示しない -->
        <v-ons-row
          v-if="!inProgressIntervalState.isDateOnce"
          class="condition-row"
        >
          <v-ons-col width="30%" vertical-align="center">
            <!-- 検査間隔 ≠ 年間複数日 -->
            <span v-if="!inProgressIntervalState.isMultiDays">
              <label style="font-size:1.6em;float:right;">～</label>
            </span>
          </v-ons-col>
          <v-ons-col width="70%" vertical-align="center" style="white-space: nowrap;">
            <!-- 検査間隔 ≠ 年間複数日 -->
            <span v-if="!inProgressIntervalState.isMultiDays">
              <date-input
                style="width: auto;"
                class="ntss-input-date ntss-custom-input"
                @blur="checkInputDate('endDate')"
                enabledBlank
                :max="maxDate"
                v-model="condition.inProgress.endDate"
                @handleClearInput="condition.inProgress.endDate = ''"
              />
              <common-calendar
                v-model="condition.inProgress.endDate"
                :disableDatesAfter="disableDatesAfter"
              />
            </span>
          </v-ons-col>
        </v-ons-row>

        <div class="condition-row" style="height: 30px; margin-bottom: 5px;">
          <div style="float: left;">
            <v-ons-button
              class="common-style-cancel-button btn2-cancel"
              @click="dialogClear"
            >クリア</v-ons-button>
          </div>
          <div style="float: right;">
            <v-ons-button
              class="common-style-ok-button btn3-normal"
              @click="dialogOk"
              :disabled="!setConditionValidate"
            >OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import moment from "moment";
import { EventBus } from "@/eventBus";
import { mapGetters, mapActions } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  CANCEL,
  SAVED,
  ADD,
  ADD_WARNING,
  SetIntervalList,
  IndWeeks,
  IntervalValues,
} from "@/constants/radRequestConstants";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import PopoverMixin from "@/components/PopoverMixin";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import { HISTORY_KEY_RAD_REQUEST_DETAIL } from "@/router/rad-request/HistoryKeyConstants";
import { messageFormat } from "@/functions/common/MessageFormat";
import TimeInput from "@/components/common/TimeInput";
import DateInput from "@/components/common/DateInput";
import {
  formatToYyyymmdd,
  formatToInputDate,
  getRadAuthorized,
  checkRadAuthorized,
  getDefaultSchExtEndDate,
  checkIntervalState,
  checkSchDate,
  extractTargetDate,
  extractTargetDateJoined,
  extractTargetDateBiweekly,
} from "@/functions/exam-request/ExamRequestFunctions";

export default {
  mixins: [PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    "time-input": TimeInput,
    "date-input": DateInput,
  },
  data() {
    const defaultCondition = {
      // 検査間隔
      setInterval: IntervalValues.SelectDateOnce,
      // 選択曜日
      selectedDayOfWeek: null,
      // 日付範囲
      startDate: "",
      endDate: "",
      // 時刻指定
      setTime: "",
    };
    return {
      image_src_full_screen: require("../../assets/status-map-full-screen.png"),
      showRadioButtonFlg: false,
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      zoomPopoverVisible: false,
      zoomPopoverTarget: null,
      zoomPopoverDirection: "left",
      defaultCondition: defaultCondition,
      condition: {
        // 入力中の検索条件
        inProgress: { ...defaultCondition },
        // 実際に検索に使用される条件
        inUsed: { ...defaultCondition },
      },
      // カレンダーで選択した日付のリスト
      selectedCalendarInProgress: [],
      selectedCalendarInUsed: [],
      // 一時退避データ
      tmpCondition: null,
      minDate: "",
      // 検査間隔の選択肢
      setIntervalList: SetIntervalList,
      // 曜日の選択肢
      indWeeks: IndWeeks,
      radSetListPop: "rad-set-list-pop",
      selectedValueList: [],
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("rad-request/list", [
      "getStartToEndDate",
      "getOrdMainTreatDateList",
      "getRadDateListNoLimit",
      "getRadDateTimeListNoLimit",
      "getEditRadRequestList",
      "getRadSetNameList",
      "getRadSetTargetList",
      "getSavePatRadPattern",
      "getLastRadDateList",
      "getPatExtInfoList",
      "getRadPatternColumnList",
      "getRadPatternDetailColumnList",
      "getPatRadPatternList",
      "getCheckPatId",
      "getDeadlineCondition",
      "getCommonConditionList",
      "getSelectedCalendar",
      "getOutsideSchExtPatList",
      "getSchExtEndDate",
    ]),
    ...mapGetters("multi-calendar", [
      "getDisplaySelectedDateList",
      "getDsplayState",
    ]),
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),

    inProgressIntervalState() {
      return checkIntervalState(this.condition.inProgress.setInterval);
    },
    // 検査セット条件チェック
    setConditionValidate() {
      let rtn = true;
      const inProgress = this.condition.inProgress;
      // 必須：曜日
      if (
        this.inProgressIntervalState.isWeekRepeat
        && inProgress.selectedDayOfWeek === null
      ) {
        rtn = false;
      }
      // 必須：指示期間(開始)
      if (!inProgress.startDate) {
        rtn = false;
      }
      return rtn;
    },
    maxDate() {
      return this.getSchExtEndDate || getDefaultSchExtEndDate();
    },
    disableDatesAfter() {
      return formatToYyyymmdd(this.maxDate);
    },
    // 共通検索エリア部品に表示するデータのリストを作成
    conditionList() {
      const condList = [];
      const condObj = this.getCommonConditionList;
      if (!condObj) return condList;

      const {
        setInterval,
        setTime,
        selectedDayOfWeek,
        startDate,
        endDate,
      } = condObj;
      // 検査間隔
      if (setInterval != null) {
        const text = this.setIntervalList.find(
          item => item.value === setInterval
        )?.name || "";
        condList.push({ name: "検査間隔", text });
      }
      // 時刻
      if (setTime) {
        condList.push({ name: "時刻", text: setTime });
      }
      // 曜日
      if (selectedDayOfWeek != null) {
        const text = this.indWeeks.find(
          item => item.value === selectedDayOfWeek
        )?.text || "";
        condList.push({ name: "曜日", text });
      }
      // 指示期間
      let dateText = startDate.replace(/-/g, "/");
      if (!checkIntervalState(setInterval).isDateOnce) {
        dateText += `～${endDate.replace(/-/g, "/")}`;
      }
      if (dateText !== "") {
        condList.push({ name: "指示期間", text: dateText });
      }

      return condList;
    },
  },
  methods: {
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    goBack() {
      this.$emit("goBack");
      this.$forceUpdate();
    },
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
    ...mapActions("rad-request/list", [
      "searchRadSetNameList",
      "setRadSetNameList",
      "updateEditScheduleStatusStore",
      "getPatInfoList",
      "setPatExtInfoList",
      "setPatRadPatternList",
      "setRadPatternColumnList",
      "setRadPatternDetailColumnList",
      "updateRadSetTargetList",
      "setCommonConditionList",
      "setSelectedCalendar",
      "setOutsideSchExtPatList",
    ]),
    ...mapActions("multi-modal", ["showMultiCalendar"]),
    ...mapActions("multi-calendar", ["setDisplaySelectedDateList"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", ["executeWithLoadingScreen"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    getRadAuthorized,

    showConfirmationDialog() {
      this.$ons.notification.alert({
        // title: "指定条件エラー",
        // message: "指定した条件に該当する日が存在しません。条件を見直してください。",
        title: DIALOG_MESSAGES["00200023"].title,
        message: messageFormat(DIALOG_MESSAGES["00200023"].message),
        class: "alert-dialog-long-content",
      });
    },
    // 指示期間開始日と終了日が逆転時アラート
    showAfterStartDateDialog() {
      this.$ons.notification.alert({
        // title: "指定期間エラー",
        // message: "開始日、終了日の指定が不正です。<br>開始日または終了日を修正してください。",
        title: DIALOG_MESSAGES["00200024"].title,
        message: messageFormat(DIALOG_MESSAGES["00200024"].message),
        class: "alert-dialog-long-content",
      });
    },
    // スケジュール期間外アラート表示
    showOutsideSchDialog(patIdList) {
      // let message = "以下の患者はスケジュール作成期間外のため検査予定が作成できません。";
      let message = messageFormat(DIALOG_MESSAGES[12000103].message);
      patIdList.forEach(patId => {
        const patName = this.getPatName(patId);
        message += "<br>" + (patName ? `${patName}様` : "");
      });
      this.$ons.notification.alert({
        // title: "スケジュール作成期間外",
        title: DIALOG_MESSAGES[12000103].title,
        message,
        class: "alert-dialog-long-content",
      });
    },
    // 患者名取得
    getPatName(patId) {
      let rtnName = "";
      const obj = this.searchedPatList.find(item => item.pat_id == patId);
      if (obj) {
        let { pat_last_name, pat_first_name } = obj;
        if (pat_last_name == null) pat_last_name = "";
        if (pat_first_name == null) pat_first_name = "";
        rtnName = `${pat_last_name} ${pat_first_name}`;
      }
      return rtnName;
    },
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) !== getCurrentFunctionCd().substring(0, 3)) return;

      // 機能一致
      // 印刷パラメータを応答
      // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 杜天成 start
      const { startDate, endDate } = this.condition.inUsed;
      const fromDate = moment(startDate).format("YYYY/MM/DD");
      const toDate = endDate ? moment(endDate).format("YYYY/MM/DD") : fromDate;
      // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 杜天成 end
      // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成　start
      const patId = this.$route.path === "/rad-request/" ? null : this.selectedPatId;
      // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成　end
      // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
      // const reportParams = {
      //   facilityCd: this.getFacilityCd,
      //   // mod #9558 機能帳票でパラメータが正しく渡されていない 杜天成 start
      //   // patId: this.selectedPatId,
      //   patId,
      //   // mod #9558 機能帳票でパラメータが正しく渡されていない 杜天成 end
      //   patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
      //   date: fromDate,
      //   fromDate,
      //   toDate,
      //   functionCd: "02201",
      // };
      // EventBus.$emit("sendReportParams", reportParams);
      if (patId == null) {
        // 一般撮影検査依頼(一覧)
        const reportParams = {
          functionCd: "02201",
          facilityCd: this.getFacilityCd,
          patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          date: fromDate,
          fromDate,
          toDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: fromDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
        };
        EventBus.$emit("sendReportParams", reportParams);
      } else {
        // 一般撮影検査依頼(個別)
        const reportParams = {
          functionCd: "02201",
          facilityCd: this.getFacilityCd,
          patId,
          date: fromDate,
          fromDate,
          toDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: fromDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
        };
        EventBus.$emit("sendReportParams", reportParams);
      }
      // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
    },
    showPopoverZoom(event) {
      this.zoomPopoverTarget = event.target;
      this.zoomPopoverVisible = true;
      this.radSetListPop = (this.$route.name === "rad-request")
        ? "rad-set-list-pop"
        : "rad-set-list-pop-detail";
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkRadAuthorized()) return;

      this.condition.inProgress = JSON.parse(JSON.stringify(this.condition.inUsed));
      // 指示期間の最大日が変わっている可能性があるので補正をかけなおしておく
      this.checkInputDate("startDate");
      this.checkInputDate("endDate");
      this.selectedCalendarInProgress = this.selectedCalendarInUsed;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 検査セット条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検査セット条件をクリア
      Object.assign(this.condition.inProgress, {
        setInterval: IntervalValues.SelectDateOnce,
        selectedDayOfWeek: null,
        startDate: this.minDate,
        endDate: "",
        setTime: "",
      });
      this.selectedCalendarInProgress = [];
    },
    // -----------------------------------------
    // 検査セット条件OKボタンクリックイベント
    // -----------------------------------------
    async dialogOk() {
      const inProgress = this.condition.inProgress;
      // 指定日1回分 の場合は指示期間の終了日をクリアする
      if (inProgress.endDate && this.inProgressIntervalState.isDateOnce) {
        inProgress.endDate = "";
      }
      // 年間複数日 でない場合は年間カレンダーでの選択結果をクリアする
      if (
        this.selectedCalendarInProgress.length
        && !this.inProgressIntervalState.isMultiDays
      ) {
        this.selectedCalendarInProgress = [];
      }

      // 指示期間開始日と終了日が逆転していないこと
      if (inProgress.startDate && inProgress.endDate) {
        const startDate = moment(inProgress.startDate);
        const endDate = moment(inProgress.endDate);
        if (endDate.isBefore(startDate)) {
          this.showAfterStartDateDialog();
          return;
        }
      }

      if (inProgress.endDate || this.inProgressIntervalState.isWeekRepeat) {
        const targetDateList = await this.getTargetDateList(inProgress, true);
        if (!targetDateList.length) {
          this.showConfirmationDialog();
          return;
        }
      }

      // 画面を閉じる
      this.popoverVisible = false;
      // 変更がある場合は検査セット設定を更新する
      const inProgressStr = JSON.stringify(inProgress);
      if (
        JSON.stringify(this.condition.inUsed) !== inProgressStr
        || this.selectedCalendarInUsed != this.selectedCalendarInProgress
      ) {
        this.condition.inUsed = JSON.parse(inProgressStr);
        this.selectedCalendarInUsed = this.selectedCalendarInProgress;
      }
    },
    // 検査間隔で「年間複数日」が選択された場合にカレンダーを表示
    changeInterval() {
      const inProgress = this.condition.inProgress;
      if (this.inProgressIntervalState.isDateOnce) {
        inProgress.selectedDayOfWeek = null;
      } else if (this.inProgressIntervalState.isMultiDays) {
        // 設定データを退避してポップアップを閉じる
        inProgress.selectedDayOfWeek = null;
        this.showCalendar();
      }
    },
    // 年間カレンダーを表示
    showCalendar() {
      // 設定データを退避してポップアップを閉じる
      this.tmpCondition = JSON.parse(JSON.stringify(this.condition.inProgress));
      this.popoverVisible = false;
      // カレンダーに選択日付を適用して表示
      this.setDisplaySelectedDateList(this.selectedCalendarInProgress);
      this.showMultiCalendar();
    },
    async getTargetDateList(
      conditionInUsed = { ...this.condition.inUsed },
      isPopoverCheck = false
    ) {
      let targetDateList = [];
      this.setOutsideSchExtPatList([]);
      let patInfoList = null;
      if (!isPopoverCheck) {
        patInfoList = await this.getPatInfoList(this.getRadSetTargetList);
      }
      // 検査間隔に応じて対象日付を取得する処理を実施
      switch (conditionInUsed.setInterval) {
        case IntervalValues.SelectDateOnce: {
          // 指定日1回分
          const startDate = conditionInUsed.startDate.replace(/-/g, "");
          if (!patInfoList) {
            targetDateList = [startDate];
            break;
          }
          checkSchDate(patInfoList, startDate);
          if (!this.getOutsideSchExtPatList.length) {
            targetDateList = [startDate];
          } else {
            targetDateList = [];
          }
          break;
        }
        case IntervalValues.FirstWeek:
          // 月1：第1週
          targetDateList = extractTargetDate(conditionInUsed, 0, patInfoList);
          break;
        case IntervalValues.SecondWeek:
          // 月1：第2週
          targetDateList = extractTargetDate(conditionInUsed, 7, patInfoList);
          break;
        case IntervalValues.ThirdWeek:
          // 月1：第3週
          targetDateList = extractTargetDate(conditionInUsed, 14, patInfoList);
          break;
        case IntervalValues.FourthWeek:
          // 月1：第4週
          targetDateList = extractTargetDate(conditionInUsed, 21, patInfoList);
          break;
        case IntervalValues.FirstAndThirdWeek: {
          // 月2：第1週、第3週
          targetDateList = extractTargetDateJoined(conditionInUsed, [0, 14], patInfoList);
          break;
        }
        case IntervalValues.SecondAndFourthWeek: {
          // 月2：第2週、第4週
          targetDateList = extractTargetDateJoined(conditionInUsed, [7, 21], patInfoList);
          break;
        }
        case IntervalValues.MultiDaysOfYear: {
          // 年間複数日
          if (isPopoverCheck) {
            this.selectedCalendarInProgress.forEach(dt => {
              targetDateList.push(formatToYyyymmdd(dt));
            });
          } else {
            if (!this.selectedCalendarInUsed.length) {
              this.selectedCalendarInUsed = this.getDisplaySelectedDateList;
            }
            this.selectedCalendarInUsed.forEach(dt => {
              targetDateList.push(formatToYyyymmdd(dt));
            });
          }
          if (!patInfoList) {
            break;
          }
          const lastDate = Math.max(...targetDateList);
          checkSchDate(patInfoList, lastDate);
          if (this.getOutsideSchExtPatList.length) {
            targetDateList = [];
          }
          break;
        }
        case IntervalValues.EveryOtherWeek:
          // 隔週
          targetDateList = extractTargetDateBiweekly(conditionInUsed, patInfoList);
          break;
        default:
          break;
      }
      return targetDateList;
    },
    // 検査セット追加ボタン押下時処理
    async addScheduleByAddButton(radSetCd) {
      // RadSetTargetListを現在チェックされている患者リストに更新する
      this.refreshRadSetTargetList();
      if (!this.getRadSetTargetList.length) {
        // 適用対象がいない場合
        // title: "チェックエラー",
        // message: "患者を選択してください。"
        const { title, message } = DIALOG_MESSAGES[50000007];
        this.$ons.notification.alert({
          title,
          message,
          class: "alert-dialog-long-content",
        });
        return;
      }
      await this.addSchedule(radSetCd);
      
      // 検査セット追加イベント発火
      EventBus.$emit("addSchedule");
    },
    // 検査セット追加
    async addSchedule(radSetCd) {
      // 共通ローダー表示
      await this.executeWithLoadingScreen(async () => {
        const targetDateList = await this.getTargetDateList();

        // スケジュール延長最終日の設定によりスケジュール作成期間外の患者が存在する場合アラート表示
        if (this.getOutsideSchExtPatList.length) {
          this.showOutsideSchDialog(this.getOutsideSchExtPatList);
          return;
        }

        // 対象日付がない場合は処理を実施しない
        if (!targetDateList.length) return;

        const condition = this.condition.inUsed;
        // 検査依頼をカレンダーに追加
        this.setRequestSchedule(condition, radSetCd, targetDateList);

        // 無期限データでない（＝期間終了日が入力されている）、もしくは
        // 指定日1回分 か 年間複数日 の場合は検査セットパターンに登録しない
        if (
          condition.endDate
          || !checkIntervalState(condition.setInterval).isWeekRepeat
        ) return;

        // reg_rad_date には、最初の対象日（初回の検査日時）を格納
        const strRadTime = condition.setTime || "00:00";
        const targetDate = targetDateList[0];
        const regRadDate = targetDate
          ? moment(`${targetDate} ${strRadTime}`, "YYYYMMDD HH:mm").toDate()
          : null;
        const radFromDate = moment(condition.startDate).toDate();
        const radToDate = moment("2099/12/31").toDate();

        // セット対象の患者ID毎に登録データを作成
        this.getRadSetTargetList.forEach(targetId => {
          const addPtObj = {
            patId: targetId,
            regRadDate,
            // 一般撮影検査依頼には検査区分の指定はないため、常に 0 を設定する
            regOrderClass: "0",
            radPattern: condition.setInterval,
            radWeek: condition.selectedDayOfWeek,
            radFrom: radFromDate,
            radTo: radToDate,
            orderRadSetCd: radSetCd,
            strRadTime,
            status: ADD,
            isDel: 0,
          };
          // 同じパターンが登録予定リストに存在するか確認
          const addFlg = this.getSavePatRadPattern.some(patternObj => (
            JSON.stringify(patternObj) === JSON.stringify(addPtObj)
          ));
          // 同じパターンがDB保存済みであるか確認
          const savedFlg = this.getPatRadPatternList.some(item => (
            item.status === SAVED
            && String(item.patId) === String(addPtObj.patId)
            && String(item.orderRadSetCd) === String(addPtObj.orderRadSetCd)
            && String(item.regOrderClass) === String(addPtObj.regOrderClass)
            && item.strRadTime === addPtObj.strRadTime
            && item.radPattern === addPtObj.radPattern
            && item.radWeek === addPtObj.radWeek
          ));
          if (!addFlg && !savedFlg) {
            this.getSavePatRadPattern.push(addPtObj);
            this.setPatRadPatternList([...this.getPatRadPatternList, addPtObj]);
          }
        });

        // 自動展開列表示用データの登録
        // 列の存在チェック
        const addPtCol = {
          radPattern: condition.setInterval,
          radWeek: condition.selectedDayOfWeek,
        };
        const isExist = this.getRadPatternColumnList.some(item => (
          item.radPattern === addPtCol.radPattern
          && item.radWeek === addPtCol.radWeek
        ));
        if (!isExist) {
          this.setRadPatternColumnList([...this.getRadPatternColumnList, addPtCol]);
        }

        // 自動展開列表示用データの登録(患者個別用)
        // 列の存在チェック
        const addPtDtlCol = {
          radPattern: String(condition.setInterval),
          radWeek: String(condition.selectedDayOfWeek),
          radTime: strRadTime,
        };
        const isDtlExist = this.getRadPatternDetailColumnList.some(itemDetail => (
          itemDetail.radPattern === addPtDtlCol.radPattern
          && itemDetail.radWeek === addPtDtlCol.radWeek
          && itemDetail.radTime === addPtDtlCol.radTime
        ));
        if (!isDtlExist) {
          this.setRadPatternDetailColumnList([...this.getRadPatternDetailColumnList, addPtDtlCol]);
        }
      });
    },
    // 検査セットに応じて検査依頼をカレンダーに追加
    setRequestSchedule(condition, radSetCd, targetDateList) {
      // 検査セット名を取得
      const radSetName = this.getRadSetNameList.find(item => item.radSetCd == radSetCd).radSetName;

      // 無期限の場合は追加対象患者の最大スケジュール延長最終日までの日付に絞る
      const endlessRepeat = (
        checkIntervalState(condition.setInterval).isWeekRepeat
        && !condition.endDate
      );
      if (endlessRepeat) {
        const maxSchExtEndDate = "" + Math.max(...(
          Object.values(this.getPatExtInfoList).map(info => info.schExtEndDate)
        ));
        targetDateList = targetDateList.filter(targetDate => targetDate <= maxSchExtEndDate);
      }
      // 日付データに追加する
      targetDateList.forEach(targetDate => {
        if (!this.getRadDateListNoLimit.includes(targetDate)) {
          this.getRadDateListNoLimit.push(targetDate);
        }
      });
      // 追加後、ソートする
      this.getRadDateListNoLimit.sort();

      // 日時データに追加する
      const targetDateTimeList = [];
      const targetTime = condition.setTime == "" ? "00:00" : condition.setTime;
      targetDateList.forEach(targetDate => {
        const targetDateTime = `${targetDate}_${targetTime}`;
        if (!this.getRadDateTimeListNoLimit.includes(targetDateTime)) {
          this.getRadDateTimeListNoLimit.push(targetDateTime);
          targetDateTimeList.push(targetDateTime);
        }
      });
      // 追加後、ソートする
      this.getRadDateTimeListNoLimit.sort();

      // 対象患者でループ
      this.getRadSetTargetList.forEach(targetId => {
        // 該当患者のデータセットを取得
        const targetObj = this.getEditRadRequestList.find(item => item.patId == targetId);
        if (!targetObj) return;

        const targetDateListForPat = [];
        if (endlessRepeat) {
          // 対象患者のスケジュール延長最終日を取得
          const max = this.getPatExtInfoList[targetId]?.schExtEndDate || null;
          // 対象日付のリストを作成
          targetDateListForPat.push(...targetDateList.filter(targetDate => max >= targetDate));
        } else {
          // 無期限でない場合は選択日付をそのまま使う
          targetDateListForPat.push(...targetDateList);
        }

        // 対象日付に対して処理を実施
        targetDateListForPat.forEach(targetDate => {
          // 追加する日付に透析予定があるか確認
          const treatDateObj = this.getOrdMainTreatDateList.find(item => item.pat_id === targetObj.patId);
          const flg = (
            treatDateObj == null
            || !treatDateObj.treat_date.includes(targetDate)
          ) ? ADD_WARNING : ADD;

          // 一般撮影検査依頼には検査区分の指定はないため、常に 0 を設定する
          this.addCalendar(targetObj, "0", radSetCd, radSetName, targetDate, flg, targetTime);
        });
      });
      // this.getEditRadRequestListの要素内の情報を更新したリアクションを起こさせる
      this.getEditRadRequestList.splice();

      // 編集状態を更新
      this.updateEditScheduleStatusStore({
        targetDateList,
        targetDateTimeList,
        radSetTargetList: this.getRadSetTargetList,
      });
    },
    // 追加処理
    addCalendar(targetObj, regOrderClass, radSetCd, radSetName, addDate, flg, radTime) {
      const { data, dataDetail, radItemSet } = targetObj;

      const addDateTime = addDate + "_" + radTime;

      // 締切フラグの設定
      const deadlineFlg = (
        this.getDeadlineCondition.deadlineFlg
        && moment(getDeadlineDate(this.getDeadlineCondition)).isAfter(addDate)
      ) ? "1" : "0";

      if (dataDetail[addDateTime] == null) {
        dataDetail[addDateTime] = 0;
      }

      const radItemSetWithOrderClass = radItemSet[regOrderClass];
      if (!radItemSetWithOrderClass[radSetCd]) {
        radItemSetWithOrderClass[radSetCd] = {
          name: radSetName,
          data: {},
          dataDetail: {},
          time: {},
          lastDate: "",
          status: {},
          statusDetail: {},
          isLock: {},
	  // add #12462 患者情報共有 Ji start
          facilityCd: {}
	  // add #12462 患者情報共有 Ji end
        };
      }
      if (data[addDate] == null) {
        data[addDate] = 0;
      }

      // フラグ追加/変更
      const radItemSetWithSetCd = radItemSetWithOrderClass[radSetCd];
      const detailStatus = radItemSetWithSetCd.dataDetail[addDateTime];
      // 日時単位のフラグ追加/変更
      switch (detailStatus) {
        case CANCEL:
          // 中止 → 予定あり に戻してカウントを加算する
          radItemSetWithSetCd.dataDetail[addDateTime] = SAVED;
          // 件数加算処理
          dataDetail[addDateTime]++;
          data[addDate]++;
          break;
        case SAVED:
        case ADD:
        case ADD_WARNING:
          // 既に予定がある場合は何もしない
          break;
        default: {
          // 予定がなければ追加する
          radItemSetWithSetCd.dataDetail[addDateTime] = flg;
          radItemSetWithSetCd.statusDetail[addDateTime] = "0";
          // 件数加算処理
          dataDetail[addDateTime]++;
          data[addDate]++;
          break;
        }
      }

      // 日付単位のフラグ追加/変更
      // dataDetailでキーの日付が一致する値を ADD_WARNING＞ADD＞SAVED の優先度で選択する
      const getTotalState = (dataDetail) => {
        let totalState = SAVED;
        Object.entries(dataDetail).forEach(
          ([detailKey, detailValue]) => {
            if (totalState === ADD_WARNING) return;
            if (!detailKey.startsWith(addDate)) return;
            if (detailValue !== ADD && detailValue !== ADD_WARNING) return;
            if (totalState === ADD && detailValue !== ADD_WARNING) return;
            totalState = detailValue;
          }
        );
        return totalState;
      };
      switch (radItemSetWithSetCd.data[addDate]) {
        case CANCEL: {
          // 整合性保持のために、キャンセルされた日付に追加される場合は
          // 同日のキャンセルされた予定を元に戻す
          // キャンセルから元に戻した日時単位データの件数を取得
          let detailCount = 0;
          Object.entries(radItemSetWithSetCd.dataDetail).forEach(
            ([detailKey, detailValue]) => {
              if (detailKey.startsWith(addDate) && detailValue === CANCEL) {
                radItemSetWithSetCd.dataDetail[detailKey] = SAVED;
                detailCount++;
              }
            }
          );

          // 同日の日時単位データに合わせてフラグを再設定する
          radItemSetWithSetCd.data[addDate] = getTotalState(radItemSetWithSetCd.dataDetail);
          // キャンセルから元に戻した日時単位データの件数を加算
          // （追加分の件数は日時単位データの追加時に加算済み）
          data[addDate] += detailCount;
          break;
        }
        case SAVED:
        case ADD:
        case ADD_WARNING: {
          // 既に予定がある場合は同日の日時単位データに合わせてフラグを再設定する
          // （追加分の件数は日時単位データの追加時に加算済み）
          radItemSetWithSetCd.data[addDate] = getTotalState(radItemSetWithSetCd.dataDetail);
          break;
        }
        default: {
          // 予定がなければ追加する
          // （追加分の件数は日時単位データの追加時に加算済み）
          radItemSetWithSetCd.data[addDate] = flg;
          radItemSetWithSetCd.status[addDate] = "0";
          radItemSetWithSetCd.isLock[addDate] = deadlineFlg;
          break;
        }
      }

      // 時刻の追加
      Object.values(radItemSetWithOrderClass).forEach(itemWithSetCd => {
        if (itemWithSetCd.time[addDate]) {
          itemWithSetCd.time[addDate] = radTime;
        }
      });
      radItemSetWithSetCd.time[addDate] = radTime;
      // add #12462 患者情報共有 Ji start
      radItemSetWithSetCd.facilityCd[addDate] = this.getFacilityCd;
      // add #12462 患者情報共有 Ji end

      // 前回検査日の追加
      this.getLastRadDateList.forEach(item => {
        if (item.radSetCd == radSetCd && item.patId == targetObj.patId) {
          radItemSetWithSetCd.lastDate = item.regRadDate;
        }
      });
    },
    // RadSetTargetListを登録対象の患者に更新する
    refreshRadSetTargetList() {
      const patIdList = [];
      if (this.$parent.historyKey === HISTORY_KEY_RAD_REQUEST_DETAIL) {
        // 一般撮影検査依頼詳細画面では現在開いている患者を対象にする
        if (this.selectedPatId) {
          patIdList.push(this.selectedPatId);
        }
      } else {
        // 一般撮影検査依頼一覧画面では現在チェックされている患者を対象にする
        // 患者のチェックボックス取得
        const patCheckbox = Array.from(document.getElementsByClassName("pat-list-item"));
        patCheckbox.forEach(checkbox => {
          if (checkbox.checked) {
            patIdList.push(checkbox.value);
          }
        });
      }
      this.updateRadSetTargetList(patIdList);
    },

    // メインコンポーネント側で患者をチェックした際に放射線検査予定を登録する処理
    async registRadRequestBySelectPat() {
      // 追加対象患者が選択されていない場合は処理しない
      if (!this.getRadSetTargetList.length) return;

      const checkboxValue = document.getElementsByClassName("rad-set-list-item");
      for (let count = 0; count < checkboxValue.length; count++) {
        if (checkboxValue[count].checked) {
          await this.addSchedule(this.getRadSetNameList[count].radSetCd);
        }
        // スケジュール作成期間外の患者が存在する場合は処理終了
        if (this.getOutsideSchExtPatList.length) break;
      }
      
      // 検査セット追加イベント発火
      EventBus.$emit("addSchedule");
    },
    // 指示期間フォーカスアウト時のチェック処理
    checkInputDate(targetName) {
      const inProgress = this.condition.inProgress;
      const inputValue = inProgress[targetName];
      // 未入力なら処理しない
      if (!inputValue) return;

      const inputDate = moment(inputValue, "YYYY-MM-DD", true);
      if (!inputDate.isValid()) {
        // 無効な日付なら空白にする
        inProgress[targetName] = "";
      } else if (inputDate.isAfter(this.maxDate)) {
        // 入力された日付が最大値より後の日付の場合、最大値にする
        inProgress[targetName] = this.maxDate;
      }
    },
    // add 10121 検査セットのラジオボタンのチェックをした際に患者に検査セットが追加されていない 関  start
    emptyRadSet() {
      this.selectedValueList = [];
    },
    // add 10121 検査セットのラジオボタンのチェックをした際に患者に検査セットが追加されていない 関  end
  },
  watch: {
    // 複数日付選択カレンダー表示状態
    getDsplayState() {
      if (this.getDsplayState) return;
      // 年間カレンダーを閉じた場合
      // カレンダーでの選択内容を反映して依頼条件ポップアップを表示する
      const inProgress = JSON.parse(JSON.stringify(this.tmpCondition));
      const dateList = this.getDisplaySelectedDateList;
      if (dateList.length) {
        // 選択された日付から指示範囲を設定する
        inProgress.startDate = formatToInputDate(dateList[0]);
        inProgress.endDate = formatToInputDate(dateList[dateList.length - 1]);
      } else {
        // 選択された日付がない場合は指示範囲をクリアする
        inProgress.startDate = "";
        inProgress.endDate = "";
      }
      this.condition.inProgress = inProgress;
      this.selectedCalendarInProgress = dateList;
      this.popoverVisible = true;
    },
    // 患者ID取得
    async getCheckPatId(value) {
      if (value == null || !value.length) return;
      await this.updateRadSetTargetList(value);
      await this.registRadRequestBySelectPat();
    },
    "condition.inUsed": function() {
      // 検索エリアに検索条件を表示
      this.setCommonConditionList(this.condition.inUsed);
      this.setSelectedCalendar(this.selectedCalendarInUsed);
    },
  },
  async created() {
    await this.executeWithLoadingScreen(async () => {
      // 検査セットのデータ取得とstoreへの登録
      const nameList = await this.searchRadSetNameList(this.getFacilityCd);
      // 検査セットソート順データ取得
      const sort = await ApiHelper.get("/mstInfo/mst_rad_set/mstSelector/", {
        facilityCd: this.getFacilityCd
      }).catch(error => {
        getErrorMessage("RadRequestHeaderComponent.vue", "created", error);
        throw error;
      });
      // 検査セット ソート処理
      const sortList = sort.data.orderSettings ? sort.data.orderSettings.items : [];
      const sortNameList = [];
      for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
        for (let itemkey = 0; itemkey < nameList.length; itemkey++) {
          if (sortList[sortkey].code === nameList[itemkey].radSetCd) {
            sortNameList.splice(sortkey, 0, nameList[itemkey]);
          }
        }
      }
      await this.setRadSetNameList(sortNameList);

      // 本日の日付をセット
      this.condition.inUsed.startDate = this.minDate = moment().format("YYYY-MM-DD");
      this.$nextTick(() => {
        if (this.getCommonConditionList) {
          // Storeに保存された依頼条件情報がある場合はその内容から入力値を復元する
          Object.assign(this.condition.inUsed, this.getCommonConditionList);
          this.selectedCalendarInUsed = this.getSelectedCalendar;
        } else {
          // Storeに保存された依頼条件情報がない場合はデフォルト値をStoreに保存する
          this.setCommonConditionList(this.condition.inUsed);
          this.selectedCalendarInUsed = [];
          this.setSelectedCalendar(this.selectedCalendarInUsed);
        }
      });

      this.showRadioButtonFlg = (this.$route.name === "rad-request");

      EventBus.$on("goBack", this.goBack);
      // add 10121 検査セットのラジオボタンのチェックをした際に患者に検査セットが追加されていない 関  start
      EventBus.$on("emptyRadSet", this.emptyRadSet);
      // add 10121 検査セットのラジオボタンのチェックをした際に患者に検査セットが追加されていない 関  end
      // 印刷パラメータ要求
      EventBus.$on("requestReportParams", this.requestrReportParams);
    });
  },
  beforeDestroy() {
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("goBack", this.goBack);
    EventBus.$off("emptyRadSet", this.emptyRadSet);

    Object.assign(this.$data, this.$options.data());
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
};
</script>

<style scoped>
.title {
  width: 80%;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  display: -moz-box;
  -moz-line-clamp: 2;
  -moz-box-orient: vertical;
  word-wrap: break-word;
  word-break: break-all;
  white-space: normal;
}
.mark-leftmost-header {
  overflow: hidden;
}
.rad-set-list {
  width: 100%;
  height: 3.5em;
  overflow-x: auto;
  overflow-y: auto;
  background-color: white;
  font-size: 1.5em;
}
.rad-set-list-frame {
  display: flex;
  flex-wrap: wrap;
  flex-direction: column;
}
.week-checkbox:checked + label {
  background-color: #9acd32;
  color: #050505;
}
.week-button {
  padding: 5px 10px;
  float: left;
  border: solid;
  border-color: #c0c0c0;
  border-width: 1px;
  font-size: 1.5em;
}

.zoom-items {
  background: #ffffff;
  max-width: 307px;
  border-radius: 10px;
  align-items: center;
  margin: 4px 2px 2px 2px;
  padding-right: 7px;
  border: solid 1px lightgray;
  height: calc(100% - 10px);
}

.rad-set-list-item-zoom {
  font-size: 2em;
  padding: 0;
  width: 60px;
  height: 45px;
}
.rad-set-list-item-span {
  font-size: 1.8em;
  display: table-cell;
  vertical-align: middle;
  flex: 1;
}

.rad-set-item {
  display: flex;
  align-items: center;
}

.filter-area {
  display: flex;
  margin-top: 2px;
}

.condition-search-col,
.list-rad-name {
  width: 50%;
}

/* 放射線検査依頼 */
.mark-leftmost-header {
  padding-right: 80px;
}

/* 患者個別放射線検査依頼 */
.main-content-area .mark-leftmost-header {
  padding-right: 0;
}

@media screen and (max-width: 640px) {
  /* 放射線検査依頼 */
  .condition-search-col {
    width: 45%;
  }
  .list-rad-name {
    width: 55%;
  }
  /* 患者個別放射線検査依頼 */
  .main-content-area .condition-search-col {
    width: 50%;
  }
  .main-content-area .condition-items-area {
    margin-left: inherit;
  }
  .main-content-area .list-rad-name {
    width: 50%;
  }
}

@media screen and (max-width: 480px) {
  .rad-set-list-frame {
    display: flex;
    flex-wrap: wrap;
    flex-direction: column;
  }
}

.rad-set-list-item {
  width: 1.5em;
  transform: scale(1);
  margin-left: 3px;
}

.rad-set-check-item-span {
  flex: 1;
}

.rad-set-label {
  display: flex;
  align-items: center;
}

.rad-set-check-item-span-detail,
.rad-set-list-item-span-detail {
  padding-left: 6px;
}

.rad-set-list-pop >>> .popover,
.rad-set-list-pop-detail >>> .popover {
  width: auto;
}
.rad-set-list-pop >>> .popover__content,
.rad-set-list-pop-detail >>> .popover__content {
  width: 450px;
}
@media screen and (max-width: 640px) {
  ons-popover >>> .popover__content {
    min-width: 17.0rem;
  }
}
@media (min-width: 640px) and (max-width: 800px) {
  .zoom-items {
    width: 220px;
  }
}
</style>
