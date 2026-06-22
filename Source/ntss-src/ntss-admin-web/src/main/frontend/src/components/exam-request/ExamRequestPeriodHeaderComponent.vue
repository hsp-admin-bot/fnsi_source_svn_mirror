/**
 * 検査依頼一覧（期間）ページ用ヘッダ
 */
<template>
  <v-card>
    <div class="header-item exam-request-header-item" id="header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea
            :conditionList="conditionList"
            :isRequestCond="true"
            @show-popover="showPopover"
          />
        </v-ons-col>
        <v-ons-col class="list-exam-name">
          <div class="zoom-items d-flex flex-row">
            <div>
              <img
                :src="image_src_full_screen"
                style="margin: 5px;"
                height="30px"
                width="30px"
                @click="showPopoverZoom"
              />
            </div>
            <div class="filter-area"></div>
            <!-- 検査セット一覧 -->
            <div class="exam-set-list">
              <div class="exam-set-list-frame">
                <div v-for="set in getExamSetNameList"
                  :key="set.examSetCd"
                  style="border: solid gray 1px;">
                  <div class="exam-set-item">
                    <label class="exam-set-label">
                      <div v-if="showRadioButtonFlg">
                        <v-ons-checkbox
                          type="checkbox"
                          class="exam-set-list-item"
                          :value="set.examSetCd"
                          v-model="selectedValueList"
                          :disabled="!getExamAuthorized()"
                        />
                      </div>
                      <span
                        class="title"
                        :class="{ 'title-detail': !showRadioButtonFlg }"
                      >{{ set.examSetName }}</span>
                    </label>
                    <v-ons-button
                      style="width: 3em; margin-left: auto; font-size: 0.6em; background: #4291B9; color: #ffffff; border-bottom: solid 2px #4974a0; height: 2.2em;"
                      @click="addScheduleByAddButton(set.examSetCd)"
                      :disabled="!getExamAuthorized()"
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
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'exam-request-header']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="fab-font-color" style="margin: 10px;">
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
            <label>曜日</label>
          </v-ons-col>
          <v-ons-col width="70%" vertical-align="center">
            <div v-for="(week, index) in indWeeks" :key="index">
              <input
                v-model="condition.inProgress.selectedDayOfWeek"
                :disabled="!inProgressIntervalState.isWeekRepeat"
                :value="week.value"
                :id="'examWeekCheck-' + index"
                class="week-checkbox"
                type="radio"
                style="display: none;"
                name="examWeekCheck"
              />
              <label
                :for="'examWeekCheck-' + index"
                onclick="null"
                style="cursor: pointer;"
                class="week-button"
                :class="!inProgressIntervalState.isWeekRepeat ? 'span-disabled' : ''"
              >{{ week.text }}</label>
            </div>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="10%" vertical-align="center">
            <v-ons-checkbox
              input-id="chkBeforeDialysis"
              v-model="condition.inProgress.chkBeforeDialysis"
            />
          </v-ons-col>
          <v-ons-col width="22%" vertical-align="center">
            <label for="chkBeforeDialysis" class="popoverFilterLabel">透析前</label>
          </v-ons-col>

          <v-ons-col width="10%" vertical-align="center">
            <v-ons-checkbox
              input-id="chkAfterDialysis"
              v-model="condition.inProgress.chkAfterDialysis"
            />
          </v-ons-col>
          <v-ons-col width="22%" vertical-align="center">
            <label for="chkAfterDialysis" class="popoverFilterLabel">透析後</label>
          </v-ons-col>

          <v-ons-col width="10%" vertical-align="center">
            <v-ons-checkbox
              input-id="chkOther"
              v-model="condition.inProgress.chkOther"
            />
          </v-ons-col>
          <v-ons-col width="22%" vertical-align="center">
            <label for="chkOther" class="popoverFilterLabel">その他</label>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label style="font-size: 1.6em;">指示期間</label>
          </v-ons-col>
          <v-ons-col width="70%" vertical-align="center" style="white-space: nowrap;">
            <!-- 検査間隔 ≠ 年間複数日 -->
            <span v-if="!inProgressIntervalState.isMultiDays">
              <date-input
                style="width: auto;"
                class="ntss-input-date ntss-custom-input"
                classes="date-input-unjust-size"
                @blur="checkInputDate('startDate')"
                :max="maxDate"
                v-model="condition.inProgress.startDate"
                isRequired
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
                class="ntss-input-date"
                @handleClearInput="condition.inProgress.endDate = ''"
                @blur="checkInputDate('endDate')"
                enabledBlank
                :max="maxDate"
                v-model="condition.inProgress.endDate"
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
              class="btn2-cancel common-style-cancel-button"
              @click="dialogClear"
            >クリア</v-ons-button>
          </div>
          <div style="float: right;">
            <v-ons-button
              class="btn3-normal common-style-ok-button"
              @click="dialogOk"
              :disabled="!setConditionValidate"
            >OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>

    <v-ons-popover
      cancelable
      v-if="zoomPopoverVisible"
      v-model:visible="zoomPopoverVisible"
      :target="zoomPopoverTarget"
      :class="[fontSizeSet, examSetListPop]"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div>
        <div
          class="exam-set-list-frame"
          style="margin: 10px; max-height: 400px; overflow-x: auto; flex-wrap: nowrap;"
        >
          <div
            v-for="set in getExamSetNameList"
            :key="set.examSetCd"
            style="border: solid gray 1px; margin-bottom: 2px; border-radius: 4px;"
          >
            <div class="exam-set-item">
              <label class="exam-set-label">
                <div v-if="showRadioButtonFlg">
                  <v-ons-checkbox
                    :disabled="!getExamAuthorized()"
                    type="checkbox"
                    class="exam-set-list-item"
                    :value="set.examSetCd"
                    v-model="selectedValueList"
                  />
                </div>
                <span
                  class="exam-list-zoom title"
                  :class="{ 'title-detail': !showRadioButtonFlg }"
                >{{ set.examSetName }}</span>
              </label>
              <v-ons-button
                :disabled="!getExamAuthorized()"
                class="btn3-normal common-style-ok-button"
                style="margin-left: auto; min-width: 100px;"
                @click="addScheduleByAddButton(set.examSetCd)"
              >追加</v-ons-button>
            </div>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { findAncestorWithAnyKey } from "@/functions/common/ComponentOwnerResolver";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import {
  CANCEL,
  SAVED,
  ADD,
  ADD_WARNING,
  SetIntervalList,
  IndWeeks,
  IntervalValues,
} from "@/constants/examRequestConstants";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import { getDeadlineDate } from "@/functions/common/DateTimeUtils";
import PopoverMixin from "@/components/PopoverMixin";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import { HISTORY_KEY_EXAM_REQUEST_DETAIL } from "@/router/exam-request/HistoryKeyConstants";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import DateInput from "@/components/common/DateInput";
import statusMapFullScreenImg from "../../assets/status-map-full-screen.png";
import { getLayoutRootElement, getScopedElementsByClassName, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

import {
  formatToYyyymmdd,
  formatToInputDate,
  getExamAuthorized,
  checkExamAuthorized,
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
    "date-input": DateInput,
  },
  data() {
    const defaultCondition = {
      // 検査間隔
      setInterval: IntervalValues.SelectDateOnce,
      // 選択曜日
      selectedDayOfWeek: null,
      // 検査タイミング
      chkBeforeDialysis: false,
      chkAfterDialysis: false,
      chkOther: false,
      // 日付範囲
      startDate: "",
      endDate: "",
    };
    return {
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
      image_src_full_screen: statusMapFullScreenImg,
      // 一時退避データ
      tmpCondition: null,
      minDate: "",
      // 検査間隔の選択肢
      setIntervalList: SetIntervalList,
      // 曜日の選択肢
      indWeeks: IndWeeks,
      examSetListPop: "exam-set-list-pop",
      selectedValueList: [],
    };
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("exam-request/list", [
      "getStartToEndDate",
      "getOrdMainTreatDateList",
      "getExamDateListNoLimit",
      "getEditExamRequestList",
      "getExamSetNameList",
      "getExamSetTargetList",
      "getSavePatExamPattern",
      "getPatExtInfoList",
      "getExamPatternColumnList",
      "getPatExamPatternList",
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

    // 表示領域の幅をCSS変数を利用して書き換える
    areaWidthStyle() {
      // モバイル端末とで幅を分ける
      const ua = getScopedWindow(this.$el || this)?.navigator?.userAgent || "";
      if (ua.match(/Android/) || ua.match(/iPhone|iPad/)) {
        return { "width": "6rem" };
      } else {
        return { "width": "15rem" };
      }
    },
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
        && inProgress.selectedDayOfWeek === null) {
        rtn = false;
      }
      // 必須：検査タイミング
      if (
        inProgress.chkBeforeDialysis === false
        && inProgress.chkAfterDialysis === false
        && inProgress.chkOther === false) {
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
        selectedDayOfWeek,
        chkBeforeDialysis,
        chkAfterDialysis,
        chkOther,
        startDate,
        endDate,
      } = condObj;
      // 検査間隔
      if (setInterval != null) {
        const text = this.setIntervalList.find(
          item => item.value === setInterval)?.name || "";
        condList.push({ name: "検査間隔", text });
      }
      // 曜日
      if (selectedDayOfWeek != null) {
        const text = this.indWeeks.find(
          item => item.value === selectedDayOfWeek)?.text || "";
        condList.push({ name: "曜日", text });
      }
      // 透析前
      if (chkBeforeDialysis) {
        condList.push({ text: "透析前" });
      }
      // 透析後
      if (chkAfterDialysis) {
        condList.push({ text: "透析後" });
      }
      // その他
      if (chkOther) {
        condList.push({ text: "その他" });
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
    ...mapActions("exam-request/list", [
      "searchExamSetNameList",
      "setExamSetNameList",
      "updateEditScheduleStatusStore",
      "getPatInfoList",
      "setPatExtInfoList",
      "setPatExamPatternList",
      "setExamPatternColumnList",
      "updateExamSetTargetList",
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
    getExamAuthorized,

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
    // add #11285 機能帳票の印刷情報対応② 高 start
    getExamSelectNameNew() {
      var examDialysis = "";
      if (this.condition.inUsed.chkBeforeDialysis &&
        this.condition.inUsed.chkAfterDialysis &&
        this.condition.inUsed.chkOther) {
        examDialysis = "すべて";
      } else {
        if (this.condition.inUsed.chkBeforeDialysis) {
          examDialysis += "透析前" + "・"
        }
        if (this.condition.inUsed.chkAfterDialysis) {
          examDialysis += "透析後" + "・"
        }
        if (this.condition.inUsed.chkOther) {
          examDialysis += "その他" + "・"
        }
        examDialysis = examDialysis.slice(0,-1);
      }

      return examDialysis;
    },
    // add #11285 機能帳票の印刷情報対応② 高 end
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) !== getCurrentFunctionCd().substring(0, 3)) return;

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

      // 機能一致
      // 印刷パラメータを応答
      // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 杜天成 start
      const { startDate, endDate } = this.condition.inUsed;
      const fromDate = dayjs(startDate).format("YYYY/MM/DD");
      const toDate = endDate ? dayjs(endDate).format("YYYY/MM/DD") : fromDate;
      // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 杜天成 end
      //add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
      const patId = this.$route.path === "/exam-request/" ? null : this.selectedPatId;
      //add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
      // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
      // const reportParams = {
      //   facilityCd: this.getFacilityCd,
      //   // mod #9558 機能帳票でパラメータが正しく渡されていない 杜天成 start
      //   patId,
      //   // mod #9558 機能帳票でパラメータが正しく渡されていない 杜天成 end
      //   patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
      //   date: fromDate,
      //   fromDate,
      //   toDate,
      //   functionCd: "02101",
      // };
      // EventBus.$emit("sendReportParams", reportParams);
      if (patId == null) {
        // 検査依頼(一覧)
        const reportParams = {
          functionCd: "02101",
          facilityCd: this.getFacilityCd,
          patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          date: fromDate,
          fromDate,
          toDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: fromDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // add #11285 機能帳票の印刷情報対応② 高 start
          inspectionKbn:this.getExamSelectNameNew(),
          treatDate:this.getStorSimlpSearchQurey.treatDate,
          bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
          freeWord:this.getStorSimlpSearchQurey.freeWord,
          expressCondCdStr:expressCondCd,
          kurNames:kurNames,
          patGroups:patGroups
          // add #11285 機能帳票の印刷情報対応② 高 end
        };
        EventBus.$emit("sendReportParams", reportParams);
      } else {
        // 検査依頼(個別)
        const reportParams = {
          functionCd: "02101",
          facilityCd: this.getFacilityCd,
          patId,
          date: fromDate,
          fromDate,
          toDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: fromDate,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // add #11285 機能帳票の印刷情報対応② 高 start
          inspectionKbn:this.getExamSelectNameNew(),
          treatDate:this.getStorSimlpSearchQurey.treatDate,
          bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
          freeWord:this.getStorSimlpSearchQurey.freeWord,
          expressCondCdStr:expressCondCd,
          kurNames:kurNames,
          patGroups:patGroups
          // add #11285 機能帳票の印刷情報対応② 高 end
        };
        EventBus.$emit("sendReportParams", reportParams);
      }
      // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
    },
    showPopoverZoom(event) {
      this.zoomPopoverTarget = event.target;
      this.zoomPopoverVisible = true;
      this.examSetListPop = (this.$route.name === "exam-request")
        ? "exam-set-list-pop"
        : "exam-set-list-pop-detail";
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      // 編集可能な権限があるかどうかを判断する
      if (!checkExamAuthorized()) return;

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
        chkBeforeDialysis: true,
        chkAfterDialysis: false,
        chkOther: false,
        startDate: this.minDate,
        endDate: "",
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
        && !this.inProgressIntervalState.isMultiDays) {
        this.selectedCalendarInProgress = [];
      }

      // 指示期間開始日と終了日が逆転していないこと
      if (inProgress.startDate && inProgress.endDate) {
        const startDate = dayjs(inProgress.startDate);
        const endDate = dayjs(inProgress.endDate);
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
        || this.selectedCalendarInUsed != this.selectedCalendarInProgress) {
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
      isPopoverCheck = false) {
      let targetDateList = [];
      this.setOutsideSchExtPatList([]);
      let patInfoList = null;
      if (!isPopoverCheck) {
        patInfoList = await this.getPatInfoList({
          patIdList: this.getExamSetTargetList,
          selectedPatId: this.selectedPatId
        });
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
    async addScheduleByAddButton(examSetCd) {
      // ExamSetTargetListを現在チェックされている患者リストに更新する
      this.refreshExamSetTargetList();
      if (!this.getExamSetTargetList.length) {
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
      await this.addSchedule(examSetCd);

      // 検査セット追加イベント発火
      EventBus.$emit("addSchedule");
    },
    // 検査セット追加
    async addSchedule(examSetCd) {
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
        this.setRequestSchedule(condition, examSetCd, targetDateList);

        // 無期限データでない（＝期間終了日が入力されている）、もしくは
        // 指定日1回分 か 年間複数日 の場合は検査セットパターンに登録しない
        if (
          condition.endDate
          || !checkIntervalState(condition.setInterval).isWeekRepeat) return;

        // 検査セットから検査依頼情報、ラベル情報を取得
        const examSet = this.getExamSetNameList.find(item => item.examSetCd == examSetCd);
        const examOrderInfo = examSet.examItemInfo;
        const orderLabelInfo = examSet.labelInfo;
        // reg_exam_date には、最初の対象日（初回の検査日時）を格納
        const targetDate = targetDateList[0];
        const regExamDate = targetDate ? dayjs(targetDate).toDate() : null;
        const examFromDate = dayjs(condition.startDate).toDate();
        const examToDate = dayjs("2099/12/31").toDate();

        // セット対象の患者ID毎に登録データを作成
        this.getExamSetTargetList.forEach(targetId => {
          const regOrderClassList = [];
          // 検査タイミング(前)
          if (condition.chkBeforeDialysis) {
            regOrderClassList.push("1");
          }
          // 検査タイミング(後)
          if (condition.chkAfterDialysis) {
            regOrderClassList.push("2");
          }
          // 検査タイミング(他)
          if (condition.chkOther) {
            regOrderClassList.push("0");
          }
          // 対象の検査タイミングごとに処理する
          regOrderClassList.forEach(regOrderClass => {
            const addPtObj = {
              patId: targetId,
              regExamDate,
              regOrderClass,
              examPattern: condition.setInterval,
              examWeek: condition.selectedDayOfWeek,
              examFrom: examFromDate,
              examTo: examToDate,
              orderExamSetCd: examSetCd,
              examOrderInfo,
              orderLabelInfo,
              status: ADD,
              isDel: 0,
              facilityCd: this.getFacilityCd,
            };
            // 同じパターンが登録予定リストに存在するか確認
            const addFlg = this.getSavePatExamPattern.some(patternObj => (
              JSON.stringify(patternObj) === JSON.stringify(addPtObj)));
            // 同じパターンがDB保存済みであるか確認
            const savedFlg = this.getPatExamPatternList.some(item => (
              item.status === SAVED
              && String(item.patId) === String(addPtObj.patId)
              && String(item.orderExamSetCd) === String(addPtObj.orderExamSetCd)
              && String(item.regOrderClass) === String(addPtObj.regOrderClass)
              && item.examPattern === addPtObj.examPattern
              && item.examWeek === addPtObj.examWeek));
            if (!addFlg && !savedFlg) {
              this.getSavePatExamPattern.push(addPtObj);
              this.setPatExamPatternList([...this.getPatExamPatternList, addPtObj]);
            }
          });
        });

        // 自動展開列表示用データの登録
        // 列の存在チェック
        const addPtCol = {
          examPattern: condition.setInterval,
          examWeek: condition.selectedDayOfWeek,
        }
        const isExist = this.getExamPatternColumnList.some(item => (
          item.examPattern === addPtCol.examPattern
          && item.examWeek === addPtCol.examWeek));
        if (!isExist) {
          this.setExamPatternColumnList([...this.getExamPatternColumnList, addPtCol]);
        }
      });
    },
    // 検査セットに応じて検査依頼をカレンダーに追加
    setRequestSchedule(condition, examSetCd, targetDateList) {
      // 検査セット名を取得
      const examSetName = this.getExamSetNameList.find(item => item.examSetCd == examSetCd).examSetName;

      // 無期限の場合は追加対象患者の最大スケジュール延長最終日までの日付に絞る
      const endlessRepeat = (
        checkIntervalState(condition.setInterval).isWeekRepeat
        && !condition.endDate);
      if (endlessRepeat) {
        const maxSchExtEndDate = "" + Math.max(...(
          Object.values(this.getPatExtInfoList).map(info => info.schExtEndDate)));
        targetDateList = targetDateList.filter(targetDate => targetDate <= maxSchExtEndDate);
      }
      // 日付データに追加する
      targetDateList.forEach(targetDate => {
        if (!this.getExamDateListNoLimit.includes(targetDate)) {
          this.getExamDateListNoLimit.push(targetDate);
        }
      });
      // 追加後、ソートする
      this.getExamDateListNoLimit.sort();

      // 対象患者でループ
      this.getExamSetTargetList.forEach(targetId => {
        // 該当患者のデータセットを取得
        const targetObj = this.getEditExamRequestList.find(item => item.patId == targetId);
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
            || !treatDateObj.treat_date.includes(targetDate)) ? ADD_WARNING : ADD;

          const regOrderClassList = [];
          // 検査タイミング(前)
          if (condition.chkBeforeDialysis) {
            regOrderClassList.push("1");
          }
          // 検査タイミング(後)
          if (condition.chkAfterDialysis) {
            regOrderClassList.push("2");
          }
          // 検査タイミング(他)
          if (condition.chkOther) {
            regOrderClassList.push("0");
          }
          // 対象の検査タイミングごとに処理する
          regOrderClassList.forEach(regOrderClass => {
            this.addCalendar(targetObj, regOrderClass, examSetCd, examSetName, targetDate, flg);
          });
        });
      });
      // this.getEditExamRequestListの要素内の情報を更新したリアクションを起こさせる
      this.getEditExamRequestList.splice();

      // カウント色用の集計処理
      this.updateEditScheduleStatusStore({
        targetDateList,
        examSetTargetList: this.getExamSetTargetList,
      });
    },
    // 追加処理
    addCalendar(targetObj, regOrderClass, examSetCd, examSetName, addDate, flg) {
      const { data, examItemSet } = targetObj;

      // 締切フラグの設定
      const deadlineFlg = (
        this.getDeadlineCondition.deadlineFlg
        && dayjs(getDeadlineDate(this.getDeadlineCondition)).isAfter(addDate)) ? "1": "0";

      const examItemSetWithOrderClass = examItemSet[regOrderClass];
      if (!examItemSetWithOrderClass[examSetCd]) {
        examItemSetWithOrderClass[examSetCd] = {
          name: examSetName,
          data:{},
          status: {},
          isLock: {},
          facilityCd: {},
        };
      }
      if (data[addDate] == null) {
        data[addDate] = 0;
      }
      // フラグ追加/変更
      const examItemSetWithSetCd = examItemSetWithOrderClass[examSetCd];
      switch (examItemSetWithSetCd.data[addDate]) {
        case CANCEL:
          // 中止 → 予定あり に戻してカウントを加算する
          examItemSetWithSetCd.data[addDate] = SAVED;
          // 件数加算処理
          data[addDate] += 1;
          break;
        case SAVED:
        case ADD:
        case ADD_WARNING:
          // 既に予定がある場合は何もしない
          break;
        default: {
          // 予定がなければ追加する
          examItemSetWithSetCd.data[addDate] = flg;
          examItemSetWithSetCd.status[addDate] = "0";
          examItemSetWithSetCd.isLock[addDate] = deadlineFlg;
          data[addDate] += 1;
          break;
        }
      }
      if (!examItemSetWithSetCd.facilityCd[addDate]) {
        examItemSetWithSetCd.facilityCd[addDate] = this.getFacilityCd;
      }
    },
    resolveHistoryOwner() {
      return findAncestorWithAnyKey(this, ["historyKey"], { maxDepth: 10 }) || this;
    },
    // ExamSetTargetListを登録対象の患者に更新する
    refreshExamSetTargetList() {
      const patIdList = [];
      if (this.resolveHistoryOwner().historyKey === HISTORY_KEY_EXAM_REQUEST_DETAIL) {
        // 検査依頼詳細画面では現在開いている患者を対象にする
        if (this.selectedPatId) {
          patIdList.push(this.selectedPatId);
        }
      } else {
        // 検査依頼一覧画面では現在チェックされている患者を対象にする
        // 患者のチェックボックス取得
        const patCheckbox = Array.from(getScopedElementsByClassName("pat-list-item", getLayoutRootElement(this.$el || this) || this.$el || this));
        patCheckbox.forEach(checkbox => {
          if (checkbox.checked) {
            patIdList.push(checkbox.value);
          }
        });
      }
      this.updateExamSetTargetList(patIdList);
    },

    // メインコンポーネント側で患者をチェックした際に検査予定を登録する処理
    async registExamRequestBySelectPat() {
      // 追加対象患者が選択されていない場合は処理しない
      if (!this.getExamSetTargetList.length) return;

      const checkboxValue = getScopedElementsByClassName("exam-set-list-item", this.$el || this);
      for (let count = 0; count < checkboxValue.length; count++) {
        if (checkboxValue[count]?.checked) {
          await this.addSchedule(this.getExamSetNameList[count].examSetCd);
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

      const inputDate = dayjs(inputValue, "YYYY-MM-DD", true);
      if (!inputDate.isValid()) {
        // 無効な日付なら空白にする
        inProgress[targetName] = "";
      } else if (inputDate.isAfter(this.maxDate)) {
        // 入力された日付が最大値より後の日付の場合、最大値にする
        inProgress[targetName] = this.maxDate;
      }
    },
    // add 10121 検査セットのラジオボタンのチェックをした際に患者に検査セットが追加されていない 関  start
    emptyExamSet() {
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
      await this.updateExamSetTargetList(value);
      await this.registExamRequestBySelectPat();
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
      const nameList = await this.searchExamSetNameList({
        facilityCd: this.getFacilityCd,
        selectedPatId: this.selectedPatId
      });
      // 検査セットソート順データ取得
      const sort = await ApiHelper.get("/mstInfo/mst_exam_set/mstSelector", {
        facilityCd: this.getFacilityCd,
        selectedPatId: this.selectedPatId
      }).catch(error => {
        getErrorMessage("ExamRequestHeaderComponent.vue", "created", error);
        throw error;
      });
      // 検査セット ソート処理
      if (sort.data) {
        const sortList = sort.data.orderSettings.items;
        const sortNameList = [];
        for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
          for (let itemkey = 0; itemkey < nameList.length; itemkey++) {
            if (sortList[sortkey].code === nameList[itemkey].examSetCd) {
              sortNameList.splice(sortkey, 0, nameList[itemkey]);
            }
          }
        }
        await this.setExamSetNameList(sortNameList);
      }

      // 本日の日付をセット
      this.condition.inUsed.startDate = this.minDate = dayjs().format("YYYY-MM-DD");
      this.$nextTick(() => {
        if (this.getCommonConditionList) {
          // Storeに保存された依頼条件情報がある場合はその内容から入力値を復元する
          Object.assign(this.condition.inUsed, this.getCommonConditionList);
          this.selectedCalendarInUsed = this.getSelectedCalendar;
        } else {
          // Storeに保存された依頼条件情報がない場合はデフォルト値をStoreに保存する
          this.condition.inUsed.chkBeforeDialysis = true;
          this.setCommonConditionList(this.condition.inUsed);
          this.selectedCalendarInUsed = [];
          this.setSelectedCalendar(this.selectedCalendarInUsed);
        }
      });

      this.showRadioButtonFlg = (this.$route.name === "exam-request");

      // 印刷パラメータ要求
      EventBus.$on("requestReportParams", this.requestrReportParams);
      // add 10121 検査セットのラジオボタンのチェックをした際に患者に検査セットが追加されていない 関  start
      EventBus.$on("emptyExamSet", this.emptyExamSet);
      // add 10121 検査セットのラジオボタンのチェックをした際に患者に検査セットが追加されていない 関  end
    });
  },
  beforeUnmount() {
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("emptyExamSet", this.emptyExamSet);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
};
</script>

<style scoped>
.title{
  width: 90%;
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
  flex: 1;
}
.condition-items-area {
  height: 44%;
  font-size: 0.8em;
}
.mark-leftmost-header {
  overflow: hidden;
}
.overflow-nowrap {
  white-space: nowrap;
}
.exam-set-list {
  width: 100%;
  height: 3.5em;
  overflow-x: auto;
  overflow-y: auto;
  background-color: white;
  font-size: 1.5em;
}
.exam-set-list-frame {
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
.popoverFilterLabel {
  white-space: nowrap;
  margin-left: -5px;
  margin-right: 7px;
  font-size: 1.6em;
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

.exam-set-list-item-zoom {
  font-size: 2em;
  padding: 0;
  width: 60px;
  height: 45px;
}

.exam-list-zoom {
  font-size: 2em;
  display: table-cell;
  vertical-align: middle;
}

.exam-set-item {
  display: flex;
  align-items: center;
}

.exam-set-list-item {
  width: 0.9rem;
  transform: scale(1);
  margin-left: 3px;
}
.exam-set-list-item {
  width: 1.5em !important;
}

.exam-set-label {
  display: flex;
  align-items: center;
}

.title-detail {
  padding-left: 6px;
}

.exam-set-list-pop :deep(.popover),
.exam-set-list-pop-detail :deep(.popover) {
  width: auto;
}
.exam-set-list-pop :deep(.popover__content),
.exam-set-list-pop-detail :deep(.popover__content) {
  width: 450px;
}

.condition-search-col,
.list-exam-name {
  width: 50%;
}

.mark-leftmost-header {
  padding-right: 80px;
}

.main-content-area .mark-leftmost-header {
  padding-right: 0;
}

@media screen and (max-width: 640px) {
  .condition-search-col {
    width: 45%;
  }
  .list-exam-name {
    width: 55%
  }
}
ons-popover :deep(.popover__content) {
  min-width: 17.0rem;
  }

@media screen and (max-width: 640px) {
  .exam-request-header :deep(.popover__content) {
  min-width: 17.0rem;
  }
}
@media (min-width: 640px) and (max-width: 800px) {
  .zoom-items{
    width: 220px;
  }
}
</style>
