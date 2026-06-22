/** * 検査依頼ページ用ヘッダ */
<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <!-- mod FNSI-redmine4434 徐 start -->
        <!-- <v-ons-col> -->
        <v-ons-col style="display:flex;align-items:center">
        <!-- mod FNSI-redmine4434 徐 end -->
          <div class="filter-area"></div>
          <!-- 検査セット一覧 -->
          <div class="exam-set-list">
            <!-- mod  FNSI-権限 姜 start -->
            <!-- mod 画面スタイル(ボタン)対応 徐 start -->
            <!-- <v-ons-button
              class="exam-set-list-item"
              :class="this.selectedSurveyList.length <= 0 || !hasTreatmentRecordAuthority ? 'disabled': ''"
              @click="createInterval"
            >予定作成</v-ons-button>
            <v-ons-button
              class="exam-set-list-item"
              :class="this.selectedSurveyList.length <= 0 || !hasTreatmentRecordAuthority ? 'disabled': ''"
              @click="createResult"
            >結果登録</v-ons-button> -->
            <v-ons-button
              class="exam-set-list-item btn3-normal"
              :class="this.selectedSurveyList.length <= 0 || !hasTreatmentRecordAuthority ? 'disabled': ''"
              @click="createInterval"
            >予定作成</v-ons-button>
            <v-ons-button
              class="exam-set-list-item btn3-normal"
              :class="!hasTreatmentRecordAuthority ? 'disabled': ''"
              @click="createResult"
            >結果登録</v-ons-button>
            <!-- mod 画面スタイル(ボタン)対応 徐 end -->
            <!-- mod  FNSI-権限 姜 end -->
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
      :class="[fontSizeSet, 'water-quality-survey-header']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div style="margin:10px;">
        <div style="overflow: auto; max-height: 60vh;">
          <!--mod FNSI-画面部品デザイン じょはく start-->
          <!--<v-ons-row class="condition-row">-->
          <v-ons-row class="condition-row fab-font-color">
            <!--mod FNSI-画面部品デザイン じょはく end-->
            <v-ons-col width="40%" vertical-align="top" style="margin-right: 0.5em;">
              <label style="font-size:1.6em;">表示期間</label>
            </v-ons-col>
            <v-ons-col vertical-align="top">
              <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
              <!-- <input
                v-model="inProgress.fromDate"
                float
                class="ntss-input-date ntss-custom-input"
                type="date"
                v-rules="'required|date_format:yyyy-MM-dd'"
              /> -->
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input
                v-model="inProgress.fromDate"
                float
                class="ntss-input-date ntss-custom-input"
                type="date"
                v-rules="'required|date_format:yyyy-MM-dd'"
                max="9999-12-31"
                id="startDate"
                @keyup="showMsg(1)"
              /> -->
              <date-input
                v-model="inProgress.fromDate"
                float
                :classes="'ntss-input-date ntss-custom-input'"
                id="startDate"
                @keyup="showMsg(1)"
                :default-date="getDefaultDate('fromDate')"
                isRequired
              />
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
              <common-calendar v-model="inProgress.fromDate" />
              <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
              <br/><span class="error-message" v-if="showStartError">{{ this.msgDiaLog }}</span>
              <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
            </v-ons-col>
          </v-ons-row>
          <!--mod FNSI-画面部品デザイン じょはく start-->
          <!--<v-ons-row class="condition-row">-->
          <v-ons-row class="condition-row fab-font-color">
            <!--mod FNSI-画面部品デザイン じょはく end-->
            <v-ons-col width="40%" vertical-align="top" class="pop-title" style="margin-right: 0.5em;" />
            <v-ons-col vertical-align="top">
              <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
              <!-- <input
                v-model="inProgress.toDate"
                float
                class="ntss-input-date ntss-custom-input"
                type="date"
                v-rules="'required|date_format:yyyy-MM-dd'"
              /> -->
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
              <!-- <input
                v-model="inProgress.toDate"
                float
                class="ntss-input-date ntss-custom-input"
                type="date"
                v-rules="'required|date_format:yyyy-MM-dd'"
                id="endDate"
                max="9999-12-31"
                @keyup="showMsg(2)"
              /> -->
              <date-input
                v-model="inProgress.toDate"
                float
                :classes="'ntss-input-date ntss-custom-input'"
                id="endDate"
                @keyup="showMsg(2)"
                :default-date="getDefaultDate('toDate')"
                isRequired
              />
              <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
              <common-calendar v-model="inProgress.toDate" />
              <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
              <br/><span class="error-message" v-if="showEndError">{{ this.msgDiaLog }}</span>
              <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
            </v-ons-col>
          </v-ons-row>
          <!--mod FNSI-画面部品デザイン じょはく start-->
          <!--<v-ons-row class="condition-row">-->
          <v-ons-row class="condition-row fab-font-color">
            <!--mod FNSI-画面部品デザイン じょはく end-->
            <v-ons-col width="40%" vertical-align="top" style="margin-right: 0.5em;">
              <!-- mod FNSI-redmine4807 徐 start -->
              <!-- <label style="font-size:1.6em;">調査種別</label> -->
              <label style="font-size:1.6em;">検査種別</label>
              <!-- mod FNSI-redmine4807 徐 end -->
            </v-ons-col>
            <v-ons-col vertical-align="top">
              <kendo-multiselect
                v-model="inProgress.surveyTypeCd"
                :data-source="mstSurveyType"
                data-text-field="surveyTypeName"
                data-value-field="surveyTypeCd"
                placeholder="すべて"
                class="multi-select-condition"
              />
            </v-ons-col>
          </v-ons-row>
          <!--mod FNSI-画面部品デザイン じょはく start-->
          <!--<v-ons-row class="condition-row">-->
          <v-ons-row class="condition-row fab-font-color">
            <!--mod FNSI-画面部品デザイン じょはく end-->
            <v-ons-col width="40%" vertical-align="top" style="margin-right: 0.5em;">
              <label style="font-size:1.6em;">ベッドグループ</label>
            </v-ons-col>
            <v-ons-col vertical-align="top">
              <v-ons-select input-id="bedGroupCd" v-model="inProgress.bedGroupCd">
                <option
                  v-for="option in getListBedGroup"
                  :key="option.length"
                  :value="option.roomBedGroupCd"
                >{{ option.roomBedGroupName }}</option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>
          <!--mod FNSI-画面部品デザイン じょはく start-->
          <!--<v-ons-row class="condition-row">-->
          <v-ons-row class="condition-row fab-font-color">
            <!--mod FNSI-画面部品デザイン じょはく end-->
            <v-ons-col width="40%" vertical-align="top" style="margin-right: 0.5em;">
              <label style="font-size:1.6em;">装置名列表示</label>
            </v-ons-col>
            <v-ons-col vertical-align="top">
              <v-ons-switch input-id="isDispMachineName" v-model="inProgress.isDispMachineName"></v-ons-switch>
            </v-ons-col>
          </v-ons-row>
          <!--mod FNSI-画面部品デザイン じょはく start-->
          <!--<v-ons-row class="condition-row">-->
          <v-ons-row class="condition-row fab-font-color">
            <!--mod FNSI-画面部品デザイン じょはく end-->
            <v-ons-col width="40%" vertical-align="top" style="margin-right: 0.5em;">
              <!-- mod FNSI-redmine4807 徐 start -->
              <!-- <label style="font-size:1.6em;">調査種別列表示</label> -->
              <label style="font-size:1.6em;">検査種別列表示</label>
              <!-- mod FNSI-redmine4807 徐 end -->
            </v-ons-col>
            <v-ons-col vertical-align="top">
              <v-ons-switch input-id="isDispSurveyType" v-model="inProgress.isDispSurveyType"></v-ons-switch>
            </v-ons-col>
          </v-ons-row>
        </div>
        <div class="condition-row" style="height:30px;">
          <div style="float:left;">
            <!-- mod 画面スタイル(ボタン)対応 徐 start -->
            <!-- <v-ons-button class="clear" @click="dialogClear">クリア</v-ons-button> -->
            <v-ons-button class="button registration-btn btn2-cancel" @click="dialogClear">クリア</v-ons-button>
            <!-- mod 画面スタイル(ボタン)対応 徐 end -->
          </div>
          <div style="float:right;">
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <!-- <v-ons-button class="ok" @click="dialogOk">OK</v-ons-button> -->
            <!-- mod 画面スタイル(ボタン)対応 徐 start -->
            <!-- <v-ons-button class="ok" :disabled="showStartError || showEndError" @click="dialogOk">OK</v-ons-button> -->
            <v-ons-button class="button registration-btn btn3-normal" :disabled="showStartError || showEndError" @click="dialogOk">OK</v-ons-button>
            <!-- mod 画面スタイル(ボタン)対応 徐 end -->
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";
import { WATER_QUALITY_SURVEY } from "@/constants/defaultSettingConstants";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils"
// add  FNSI-権限 姜 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add  FNSI-権限 姜 end
// add FNSI-横展開 日付のチェックの追加 徐 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-横展開 日付のチェックの追加 徐 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getScopedDocument, getScopedElementById, getScopedSessionStorage } from "@/functions/common/LayoutMeasureHelper";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/19 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/19 ×を常に表示するように修正 張博 end
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
import store from "@/stores";
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
export default {
    // add  FNSI-権限 姜 start
  mixins: [PopoverMixin ,ComponentGuardMixin],
  // add  FNSI-権限 姜 end
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 end
  },
  data() {
    const defaultCondition = {
      fromDate: this.getFormatStartDate(),
      toDate: this.getFormatEndDate(),
      surveyTypeCd: [],
      bedGroupCd: null,
      isDispMachineName: true,
      isDispSurveyType: true
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      localCondition: {
        ...defaultCondition
      },
      // 入力中の検索条件
      inProgress: {
        ...defaultCondition
      },
      // カレンダーで選択した日付のリスト
      selectedCalendarInProgress: [],
      selectedCalendarInUsed: [],
      isSearch: false,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      // add FNSI-横展開 日付のチェックの追加 徐 start
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showStartError: false,
      showEndError: false,
      // add FNSI-横展開 日付のチェックの追加 徐 end
      // 権限を有無する
      hasTreatmentRecordAuthority: false
      // add  FNSI-権限 姜 end
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("water-quality-survey/list", [
      "getCondition",
      "getDefaultCondition",
      "displayConditionFlag",
      "mstSurveyType",
      "mntWaterSurvey",
      "selectedSurveyList",
      "getSelectedList",
      "getListBedGroup"
    ]),
    ...mapGetters("facility-calendar", [
      "getWaterQualityDayView",
    ]),
    ...mapGetters("account-edit", {
      defaultSetting: "getDefaultSetting"
    }),
    // add FutreNetWeb+SI課題管理No6831 趙 start
    ...mapGetters("bread-crumb", {
      keepHistories: "getKeepHistory"
    }),
    // add FutreNetWeb+SI課題管理No6831 趙 end
    defaultSelect: () => {
      return -1;
    },

    // 表示領域の幅をCSS変数を利用して書き換える
    areaWidthStyle() {
      // モバイル端末とで幅を分ける
      const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
      if (ua.match(/Android/) || ua.match(/iPhone|iPad/)) {
        return { width: "6rem" };
      } else {
        return { width: "15rem" };
      }
    }

  },
  methods: {
    ...mapActions("multi-modal", ["showMultiCalendar", "showWaterResultModal"]),
    ...mapActions("multi-calendar", ["setDisplaySelectedDateList"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("water-quality-survey/list", [
      "setCondition",
      "setDefaultCondition",
      "setListBedGroup",
      "setItemDateFromCalendar",
      "setMstSurveyType"
    ]),
    ...mapActions("water-quality-survey/result", [
      "setResultModalVisible",
      "setSurveyRecord",
      "setSelectTabId",
      "setControlDisp"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    getOwnerDocument() {
      return getScopedDocument(this.$el || null);
    },
    getHeaderElementById(id) {
      return getScopedElementById(id, this.$el || null) || this.getOwnerDocument()?.getElementById?.(id) || null;
    },
    // 表示期間のデフォルト設定取得
    getDefaultDate(dataField) {
      const defaultCondition = this.getDefaultCondition;
      if (defaultCondition && defaultCondition[dataField]) {
        return defaultCondition[dataField];
      }
      return dataField === "toDate" ? this.getFormatEndDate() : this.getFormatStartDate();
    },
    getFormatStartDate() {
      const currentDate = new Date();
      const prev = new Date(
        new Date().setFullYear(currentDate.getFullYear() - 1));
      return dayjs(prev).format("YYYY-MM-DD");
    },

    // add  FNSI-権限 姜 start
    getTreatmentRecordAuthority() {
      return this.hasAuthorityByCd(AUTHORITY_CODES.DEV_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.DEV_EDIT);
    },
    // add  FNSI-権限 姜 end
    getFormatEndDate() {
      const currentDate = new Date();
      const next = new Date(
        new Date().setFullYear(currentDate.getFullYear() + 1));
      return dayjs(next).format("YYYY-MM-DD");
    },

    getSurveyTypeName(cd) {
      const findItem = this.mstSurveyType.find(r => r.surveyTypeCd == cd);

      if (!findItem) return "";

      return findItem.surveyTypeName;
    },

    getRoomBedGroupName(cd) {
      const findItem = this.getListBedGroup.find(r => r.roomBedGroupCd === cd);
      if (!findItem) return "";

      return findItem.roomBedGroupName;
    },

    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.setCondition(this.localCondition);
      this.localCondition = JSON.parse(JSON.stringify(this.getCondition));
      this.inProgress = deepCopy(this.localCondition);

      this.selectedCalendarInProgress = this.selectedCalendarInUsed;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    createInterval() {
      if (this.selectedSurveyList.length > 0) {
        this.setDisplaySelectedDateList(this.selectedCalendarInProgress);
        this.showMultiCalendar("水質検査予定作成");
      }
    },
    createResult() {
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      // add #9558 機能帳票で正しく変数が引き渡されていない 杜 start
      store.dispatch("report/getMstReport", {funcCd: "03201",printFlag: 1});
      EventBus.$emit("isCheckResultSon");
      // add #9558 機能帳票で正しく変数が引き渡されていない 杜 end
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
      this.setSelectTabId(0);
      this.setControlDisp({
        isDispPlan: false,
        isDispResult: false,
        isDispDel: false,
        isToggleShowObject: true
      });
      EventBus.$emit("addBulkResult", this.selectedSurveyList.length > 0 ? 1 : 2);
    },
    // -----------------------------------------
    // 検査セット条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検査セット条件をクリア
      // add FNSI-横展開 日付のチェックの追加 徐 start
      this.showStartError = false;
      this.showEndError = false;
      // add FNSI-横展開 日付のチェックの追加 徐 end
      this.popoverVisible = false;
      this.localCondition = JSON.parse(JSON.stringify(this.getDefaultCondition));
      this.setConditionList();
      EventBus.$emit("filter", true);
    },
    // -----------------------------------------
    // 検査セット条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      // 画面を閉じる
      this.popoverVisible = false;
      this.isSearch = true;
      // 変更がある場合は検査セット設定を更新する
      if (
        this.inProgress.fromDate === "" ||
        dayjs(this.inProgress.fromDate).isAfter(dayjs(this.inProgress.toDate))) {
        this.inProgress.fromDate = this.getCondition.fromDate;
      }
      if (
        this.inProgress.toDate === "" ||
        dayjs(this.inProgress.toDate).isBefore(dayjs(this.inProgress.fromDate))) {
        this.inProgress.toDate = this.getCondition.toDate;
      }
      this.localCondition = deepCopy(this.inProgress);
      this.$nextTick(() => {
        this.setConditionList();
        EventBus.$emit("filter", true)
      });
    },
    formatDate(date) {
      return dayjs(date).format("YYYY/MM/DD");
    },
    internalServerError(error) {
      console.log(error);
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // this.$ons.notification.alert("システムエラーが発生しました。", {
      //   title: "エラー"
      // });
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
        title: DIALOG_MESSAGES['00200002'].title
      });
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
    },
    getFormatStartDateFromCalendar(paramDate) {
      const currentDate = new Date(paramDate);
      const prev = new Date(
        currentDate.setFullYear(currentDate.getFullYear() - 1));
      return dayjs(prev).format("YYYY-MM-DD");
    },

    getFormatEndDateFromCalendar(paramDate) {
      const currentDate = new Date(paramDate);
      const next = new Date(
        currentDate.setFullYear(currentDate.getFullYear() + 1));
      return dayjs(next).format("YYYY-MM-DD");
    },
    // add FNSI-横展開 日付のチェックの追加 徐 start
    showMsg(e) {
      if (e === 1) {
        const startDateInput = this.getHeaderElementById("startDate");
        if (this.inProgress.fromDate && startDateInput?.validationMessage) {
          this.showStartError = true;
        } else {
          this.showStartError = false;
        }
      }
      if (e === 2) {
        const endDateInput = this.getHeaderElementById("endDate");
        if (this.inProgress.toDate && endDateInput?.validationMessage) {
          this.showEndError = true;
        } else {
          this.showEndError = false;
        }
      }
    },
    // add FNSI-横展開 日付のチェックの追加 徐 end
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.localCondition;
      // 表示期間
      if (condObj.fromDate != '' && condObj.toDate != '') {
        condList.push({ name:"表示期間", text:this.formatDate(condObj.fromDate) + " ~ " + this.formatDate(condObj.toDate) });
      }
      // 検査種別
      if (condObj.surveyTypeCd.length > 0) {
        const validCdList = condObj.surveyTypeCd.filter(cd => this.mstSurveyType.some(r => r.surveyTypeCd == cd));
        const text = validCdList.length > 0 ? validCdList.map(cd => this.getSurveyTypeName(cd)).join("、") : "すべて";
        condObj.surveyTypeCd = validCdList;
        condList.push({ name:"検査種別", text });
      } else {
        condList.push({ name:"検査種別", text:"すべて" });
      }
      // ベッドグループ
      if (condObj.bedGroupCd !== null) {
        let strBed = this.getRoomBedGroupName(condObj.bedGroupCd);
        if(strBed === "") {
          condObj.bedGroupCd = null;
          condList.push({ name:"ベッドグループ", text:"すべて" });
        }
        else {
          condList.push({ name:"ベッドグループ", text:strBed });
        }
      }
      // add FNSI-redmine4297 徐 start
      else {
        condList.push({ name:"ベッドグループ", text:"すべて" });
      }
      // add #11285 機能帳票の印刷情報対応② 高 start
      getScopedSessionStorage(this.$el || this).setItem('roomBedGroupNameWater', JSON.stringify(condList.find(item => item.name === "ベッドグループ").text));
      // add #11285 機能帳票の印刷情報対応② 高 end
      // add FNSI-redmine4297 徐 end
      // 装置名列表示
      if (condObj.isDispSurveyType) {
        condList.push({ text:"装置名列表示" });
      }
      // 調査種別列表示
      if (condObj.isDispMachineName) {
        // mod FNSI-redmine4807 徐 start
        // condList.push({ text:"調査種別列表示" });
        condList.push({ text:"検査種別列表示" });
        // mod FNSI-redmine4807 徐 end
      }
      this.conditionList = condList;
      this.setCondition(condObj);
      // add FNSI-redmine3996 徐 start
      var startDate = dayjs(condObj.fromDate).format("YYYYMMDD");
      var endDate = dayjs(condObj.toDate).format("YYYYMMDD");
      setTimeout(() => {
        var water = this.getOwnerDocument()?.getElementById?.("water");
        if (water !== null && water !== undefined) {
          var nowDate = new Date();
          var today = nowDate.getFullYear() + '';
          if (nowDate.getMonth() + 1 < 10) {
            today = today + '0' + (nowDate.getMonth() + 1);
          } else {
            today = today + (nowDate.getMonth() + 1);
          }
          if (nowDate.getDate() < 10) {
            today = today + '0' + nowDate.getDate();
          } else {
            today = today + nowDate.getDate();
          }
          var setDay = today;
          const water = this.getOwnerDocument()?.getElementById?.("water");
          if (today > startDate && today >= endDate) {
            if (water) water.scrollLeft = 9999999999;
          } else if (today <= startDate && today < endDate) {
            if (water) water.scrollLeft = 0;
          } else if (today > startDate && today < endDate) {
            if (water !== null && water !== undefined) {
              let row = water.childNodes[0].childNodes[1].childNodes[0].childNodes[0].childNodes[0].childNodes;
              var length = 0;
              for (var i = 0; i < row.length; i++) {
                var date = row[i].textContent.substring(0, 4) + row[i].textContent.substring(5, 7) + row[i].textContent.substring(8, 10);
                if (date >= setDay) {
                    break;
                }
                length = length + row[i].scrollWidth + 1;
              }
              water.scrollLeft = length;
            }
          }
        }
      }, 500);
      // add FNSI-redmine3996 徐 end
    }
  },
  async created() {
    // add  FNSI-権限 姜 start
    this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // add  FNSI-権限 姜 end
    if (this.getCondition == null) {
      // 初期表示時
      let startCondition = {
        fromDate: this.getFormatStartDate(),
        toDate: this.getFormatEndDate(),
        surveyTypeCd: [],
        bedGroupCd: null,
        isDispMachineName: true,
        isDispSurveyType: true
      };
      // サインインユーザのデフォルト設定を確認・設定
      const defaultWaterQualitySurvey = this.defaultSetting[WATER_QUALITY_SURVEY.KEY_NAME];
      if (defaultWaterQualitySurvey) {
        // 表示期間・開始日
        if (defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE] !== undefined && defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE] !== null) {
          startCondition.fromDate = calcTargetDate(defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_FROM_DATE])
        }
        // 表示期間・終了日
        if (defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE] !== undefined && defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE] !== null) {
          startCondition.toDate = calcTargetDate(defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_TO_DATE])
        }
        // 調査種別
        if (defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD] !== undefined) {
          startCondition.surveyTypeCd = defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_SURVEY_TYPE_CD]
        }
        // ベッドグループ
        if (defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD] !== undefined) {
          startCondition.bedGroupCd = defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_BED_GROUP_CD]
        }
        // 装置名列表示
        if (defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME] !== undefined) {
          startCondition.isDispMachineName = defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME]
        }
        // 調査種別列表示
        if (defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE] !== undefined) {
          startCondition.isDispSurveyType = defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE]
        }
      }
      // 抽出条件・初期抽出条件を設定
      this.setCondition(startCondition);
      this.setDefaultCondition(startCondition);
    }

    this.localCondition = this.getCondition;
    // mod FutreNetWeb+SI課題管理No6831 趙 start
    // if (dayjs(this.getWaterQualityDayView).format("YYYY-MM-DD") == "Invalid date") {
    //   if (this.localCondition.fromDate === "") {
    //     this.localCondition.fromDate = this.getFormatStartDate();
    //   }
    //   if (this.localCondition.toDate === "") {
    //     this.localCondition.toDate = this.getFormatEndDate();
    //   }
    // } else {
    //   this.setItemDateFromCalendar(this.getWaterQualityDayView);
    //   this.localCondition.fromDate = this.getFormatStartDateFromCalendar(
    //     dayjs(this.getWaterQualityDayView).format("YYYY-MM-DD")
    //   );
    //   this.localCondition.toDate = this.getFormatEndDateFromCalendar(
    //     dayjs(this.getWaterQualityDayView).format("YYYY-MM-DD")
    //   );
    if (this.keepHistories[0].routerName === "facility-calendar"){
      if (dayjs(this.getWaterQualityDayView).format("YYYY-MM-DD") == "Invalid date") {
        if (this.localCondition.fromDate === "") {
          this.localCondition.fromDate = this.getFormatStartDate();
        }
        if (this.localCondition.toDate === "") {
          this.localCondition.toDate = this.getFormatEndDate();
        }
      } else {
        this.setItemDateFromCalendar(this.getWaterQualityDayView);
        this.localCondition.fromDate = dayjs(this.getWaterQualityDayView).format("YYYY-MM-DD");
        this.localCondition.toDate = dayjs(this.getWaterQualityDayView).format("YYYY-MM-DD");
        this.localCondition.surveyTypeCd = [];
        this.localCondition.bedGroupCd = null;
        const defaultWaterQualitySurvey = this.defaultSetting[WATER_QUALITY_SURVEY.KEY_NAME];
        if (defaultWaterQualitySurvey) {
          // 装置名列表示
          if (defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME] !== undefined) {
            this.localCondition.isDispMachineName = defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_MACHINE_NAME]
          }
          // 調査種別列表示
          if (defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE] !== undefined) {
            this.localCondition.isDispSurveyType = defaultWaterQualitySurvey[WATER_QUALITY_SURVEY.KEY_NAME_IS_DISP_SURVEY_TYPE]
          }
        }
      }
    }
    // mod FutreNetWeb+SI課題管理No6831 趙 end
    // mod FutreNetWeb+SI課題管理No5753 趙 start
    // this.setConditionList();
    try {
      let responseBedGroup = await ApiHelper.get("/mstInfo/mstRoomBedGroup", {
        facilityCd: this.getFacilityCd
      });
      let responseMstSurveyType = await ApiHelper.get("mstInfo/mstWaterSurveyType");
      // 格納するリストベッドグループを設定する
      let bedGroupList = responseBedGroup.data;
      bedGroupList.unshift({
        roomBedGroupCd: null,
        roomBedGroupName: "すべて"
      });
      this.setListBedGroup(bedGroupList);
      this.setMstSurveyType(responseMstSurveyType.data);
    } catch (error) {
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
      getErrorMessage('WaterQualitySurveyHeaderComponent.vue','created',error);
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
      this.internalServerError(error);
    }
    this.setConditionList();
    // mod FutreNetWeb+SI課題管理No5753 趙 end
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<style scoped>
.mark-leftmost-header {
  overflow: hidden;
}
.overflow-nowrap {
  overflow-x: auto;
  white-space: nowrap;
}
.exam-set-list {
  margin: 4px;
}
.exam-set-list-item {
  font-size: 1.5em;
  line-height: 1.5em;
  width: 6rem;
  margin-right: 3px;
  height: 100%;
}
.week-checkbox:checked + span {
  background-color: #9acd32;
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
  margin-left: -5px;
  margin-right: 7px;
  font-size: 1.6em;
}
.disabled {
  pointer-events: none;
  opacity: 0.5;
}
.water-quality-survey-header :deep(.popover) {
  width: auto;
}
.water-quality-survey-header :deep(.popover__content) {
  max-height: 400px;
  width: 430px;
}
:deep(.k-legacy-multiselect .k-input-inner.k-input, .k-legacy-multiselect input.k-input){
  /*** #9846 start*/
  /***  width: 49px !important; */
  min-width: 49px !important;
  max-width: 78px !important;
  /*** #9846 end*/
}
:deep(.k-legacy-multiselect .k-chip-remove-action .k-icon::before),
:deep(.k-legacy-multiselect .k-chip-remove-action .k-svg-icon::before){
  font-size: 24px !important;
  font-weight: 300 !important;
  margin-top: 5.5px;
}
</style>
