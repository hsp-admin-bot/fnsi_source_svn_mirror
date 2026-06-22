/** * 患者処方箋画面 */
<template>
  <div
    class="main-content-area custom-main-content-area"
    v-if="isSelectedPatId"
  >
    <div class="main-area">
      <div class="header-icon" v-show="isHideMainList">
        <ons-icon
          class="
            ons-icon
            ion-navicon
            ons-icon--ion
            pat-prescription-openclose-icon
          "
          icon="ion-ios-menu"
          @click="onCloseMainList(false)"
        ></ons-icon>
      </div>
      <div class="history-area" v-show="!isHideMainList">
        <div class="header-area add-button-area">
          <div class="header-icon">
            <ons-icon
              class="
                ons-icon
                ion-navicon
                ons-icon--ion
                pat-prescription-openclose-icon
              "
              icon="ion-ios-menu"
              @click="onCloseMainList()"
            ></ons-icon>
          </div>
          <div class="header-button">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="btn3-normal" -->
            <!--   @click="showRegisterComponent('newType')" -->
            <!--   :disabled="isEditDisabled" -->
            <!--   >新規登録</v-ons-button -->
            <!-- > -->
            <v-ons-button
              class="btn3-normal"
              @click="showRegisterComponent('newType')"
              :disabled="isEditDisabled || !getItemAuthorized('PatPrescription', 'default_authority')"
              >新規登録</v-ons-button
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </div>
        </div>
        <div class="header-area">
          <!-- mod 画面部品デザイン定義 張 start -->
          <!-- <common-searcharea style="height: 7em; font-size: .667em;" :lineHeight="'7em'" :conditionList="conditionList" @show-popover='showPopover($event)'/> -->
          <common-searcharea
            style="
              height: 7em;
              font-size: 0.667em;
              width: 100%;
            "
            :lineHeight="'7em'"
            :conditionList="conditionList"
            @show-popover="showPopover($event)"
          />
          <!-- mod 画面部品デザイン定義 張 end -->
        </div>

        <v-ons-popover
          cancelable
          v-model:visible="popoverVisible"
          :target="popoverTarget"
          :direction="popoverDirection"
          :cover-target="false"
          :class="[fontSizeSet, 'popover-area']"
          @preshow="popoverPreShow"
          @postshow="popoverPostShow"
          @posthide="popoverPosthide"
        >
          <div style="margin: 10px">
            <v-ons-row class="condition-row">
              <v-ons-col width="30%" vertical-align="center">
                <label>交付日</label>
              </v-ons-col>
              <v-ons-col width="60%" vertical-align="center">
                <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
                <!-- <v-ons-input
                  type="date"
                  v-model="inputModel.startDate"
                  class="input unstyled-date"
                ></v-ons-input> -->
                <date-input
                  v-model="inputModel.startDate"
                  @handleClearInput="inputModel.startDate = null"
                  class="input unstyled-date ntss-input-date"
                  style="width:100%"
                />
                <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              </v-ons-col>
              <v-ons-col width="10%" class="calendar">
                <common-calendar v-model="inputModel.startDate" />
              </v-ons-col>
            </v-ons-row>
            <v-ons-row class="condition-row">
              <v-ons-col width="30%">
                <label style="float: right; padding-right: 15px">~</label>
              </v-ons-col>
              <v-ons-col width="60%" vertical-align="center">
                <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
                <!-- <v-ons-input
                  type="date"
                  v-model="inputModel.endDate"
                  class="input unstyled-date"
                ></v-ons-input> -->
                <date-input
                  v-model="inputModel.endDate"
                  @handleClearInput="inputModel.endDate = null"
                  style="width:100%"
                  class="input unstyled-date ntss-input-date"
                />
                <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
              </v-ons-col>
              <v-ons-col width="10%" class="calendar">
                <common-calendar v-model="inputModel.endDate" />
              </v-ons-col>
            </v-ons-row>
            <v-ons-row class="condition-row">
              <v-ons-col width="25%">
                <!-- mod #10184 処方画面文言修正 宮崎 start -->
                <label>処方区分</label>
                <!-- mod #10184 処方画面文言修正 宮崎 end -->
              </v-ons-col>
              <v-ons-col
                width="25%"
                vertical-align="center"
                v-for="(filterItemHos, $index) in filterListHos"
                :key="$index"
              >
                <v-ons-radio
                  :input-id="'checkbox-' + $index"
                  :value="filterItemHos.code"
                  v-model="inputModel.checkHos"
                  modifier="round"
                  class="popover-content-radio radio-button radio-button--round"
                ></v-ons-radio>
                <label @click="clickTextCheckHos(filterItemHos.code)">{{
                  filterItemHos.label
                }}</label>
              </v-ons-col>
            </v-ons-row>
            <v-ons-row class="condition-row">
              <v-ons-col width="25%">
                <label>交付状況</label>
              </v-ons-col>
              <v-ons-col
                width="25%"
                vertical-align="center"
                v-for="(filterItemIss, $index) in filterListIss"
                :key="$index"
              >
                <v-ons-radio
                  :input-id="'checkbox-' + $index"
                  :value="filterItemIss.code"
                  v-model="inputModel.checkIss"
                  modifier="round"
                  class="popover-content-radio radio-button radio-button--round"
                ></v-ons-radio>
                <label @click="clickTextCheckIss(filterItemIss.code)">{{
                  filterItemIss.label
                }}</label>
              </v-ons-col>
            </v-ons-row>
            <div class="condition-row" style="height: 30px; margin-bottom: 5px">
              <div style="float: left">
                <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 start-->
                <!-- <v-ons-button class="clear" @click="dialogClear">クリア</v-ons-button> -->
                <v-ons-button class="clear btn2-cancel" @click="dialogClear"
                  >クリア</v-ons-button
                >
                <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 end-->
              </div>
              <div style="float: right">
                <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 start-->
                <!-- <v-ons-button class="ok" @click="dialogOk">OK</v-ons-button> -->
                <v-ons-button class="ok btn3-normal" @click="dialogOk"
                  >OK</v-ons-button
                >
                <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 end-->
              </div>
            </div>
          </div>
        </v-ons-popover>
        <div class="detail-area">
          <table
            id="history"
            class="table-area list"
            :style="heightStyles"
            ref="scrollTable"
          >
            <!-- mod no 3889 画面のデザイン不正 張 start -->
            <!-- <div>
              <thead>
                <th class="ntss-list-header-th-sticky list-event color-shadow" scope="col">交付日</th>
                <th class="ntss-list-header-th-sticky list-event color-shadow" scope="col">内外</th>
                <th class="ntss-list-header-th-sticky list-event color-shadow" scope="col">交付</th>
              </thead> -->
            <thead>
              <tr>
                <th class="color-header">交付日</th>
                <!-- mod #10184 処方画面文言修正 宮崎 start -->
                <th class="color-header">処方区分</th>
                <!-- mod #10184 処方画面文言修正 宮崎 end -->
                <th class="color-header">交付</th>
              </tr>
            </thead>
            <tbody>
              <tr
                class="hover"
                v-for="(item, index) in inputModel.history"
                :key="index"
                @click="selectHistory(index)"
                :class="classRowSetting(index, item.active)"
              >
                <!-- mod no 3889 画面のデザイン不正 張 start -->
                <!-- mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou start -->
                <!-- <td class="ntss-list-body-td ntss-pat-event-label list-event"> -->
                <!-- <td :class="item.isOtherFacility ? 'ntss-list-body-td ntss-pat-event-label list-event bgc_yellow'
                                                : 'ntss-list-body-td ntss-pat-event-label list-event'"> -->
                <td
                  :class="
                    item.isOtherFacility
                      ? 'table-area-label bgc_yellow'
                      : 'table-area-label '
                  "
                >
                  <!-- mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou end -->
                  <!-- mod FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start -->
                  <!-- <label>{{item.issueDate}}</label> -->
                  <!-- mod no 3889 画面のデザイン不正 張 end -->
                  <div class="row-block">
                    <label>{{ item.issueDate }}</label>
                  </div>
                  <div class="row-block" v-if="sharedFlag">
                    <label style="word-wrap: break-word">{{
                      item.facilityName
                    }}</label>
                  </div>
                  <!-- mod FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end -->
                </td>
                <!-- mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou start -->
                <!-- <td class="ntss-list-body-td ntss-pat-event-label list-score"> -->
                <!-- <td :class="item.isOtherFacility ? 'ntss-list-body-td ntss-pat-event-label list-score bgc_yellow'
                                : 'ntss-list-body-td ntss-pat-event-label list-score'"> -->
                <td
                  :class="
                    item.isOtherFacility
                      ? 'table-area-label list-score bgc_yellow'
                      : 'table-area-label list-score'
                  "
                >
                  <!-- mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou end -->
                  <label>{{
                    item.prescriptionType == 1 ? "院外" : "院内"
                  }}</label>
                </td>
                <!-- mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou start -->
                <!-- <td class="ntss-list-body-td ntss-pat-event-label list-score"> -->
                <!-- <td :class="item.isOtherFacility ? 'ntss-list-body-td ntss-pat-event-label list-score bgc_yellow'
                                : 'ntss-list-body-td ntss-pat-event-label list-score'"> -->
                <td
                  :class="
                    item.isOtherFacility
                      ? 'table-area-label list-score bgc_yellow'
                      : 'table-area-label list-score'
                  "
                >
                  <!-- mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou end -->
                  <label>{{ item.issueState == 0 ? "未" : "済" }}</label>
                </td>
              </tr>
            </tbody>
            <!-- mod no 3889 画面のデザイン不正 張 end -->
          </table>
        </div>
      </div>
      <!-- mod 日機装FNSI 劉全航 start -->
      <!-- <div class="content-area" v-if="viewMode"> -->
      <div class="content-area" v-if="viewMode" :style="contentHeight">
        <!-- mod 日機装FNSI 劉全航 end -->
        <!--mod FNSI-処方削除ボタンのアクションが不正 劉全航 start -->
        <!-- <component
          :is="'pat-prescription-detail'"
          ref="detail"
          :props-is-hide-main-list="isHideMainList"
        /> -->
        <component
          :is="'pat-prescription-detail'"
          ref="detail"
          :props-is-hide-main-list="isHideMainList"
          @openPatPrescription="openPatHistory"
        />
        <!--mod FNSI-処方削除ボタンのアクションが不正 劉全航 end -->
      </div>
    </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// mod FNSI-改修内容 基本は他施設の場合には、画面項目編集不可 dou start
// import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import { ApiHelper } from "../../apis/AxiosHelper";
// mod FNSI-改修内容 基本は他施設の場合には、画面項目編集不可 dou end
import dayjs from "@/compat/date/dayjs";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import PatPrescriptionDetail from "@/components/pat-prescription/PatPrescriptionDetailComponent";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import { filterListHospital, filterListIssued } from "@/constants/filterList";
import { EventBus } from "@/compat/vue/event-bus.js";
import PopoverMixin from "@/components/PopoverMixin";
import { PAT_PRESCRIPTION } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";
import { deepCopy } from "@/functions/common/CommonFunctions";
//add 横展開管理台帳_日機装FNSI NO.1 劉全航 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//add 横展開管理台帳_日機装FNSI NO.1 劉全航 end
// add 画面印刷プレビューと印刷の実現 陳 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add 画面印刷プレビューと印刷の実現 陳 end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
// add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority.js";
// del #10359 編集権限の動作不正 dengshen end
// add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 end
//#5590 2023/04/19 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";

//#5590 2023/04/19 ×を常に表示するように修正 張博 end

export default {

  components: {
    "pat-prescription-detail": PatPrescriptionDetail,
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 end
  },
  mixins: [NextTransitionMixin, PatHeaderControlMixin, PopoverMixin],
  data() {
    return {
      // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 start
      isEditDisabled: false,
      // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 end
      // add FNSI-改修内容 他施設の場合、浅黄色背景にする dou start
      sharedFlag: false,
      // add FNSI-改修内容 他施設の場合、浅黄色背景にする dou end
      inputModel: {
        startDate: "",
        endDate: "",
        checkHos: "",
        checkIss: "",
        history: [],
      },
      /* modify by chamaojia 2022-11-18 [6876] 変数を使用しない削除  --start */
      // isAlert: false,
      /* modify by chamaojia 2022-11-18 [6876] 変数を使用しない削除  --end */
      inputModelInit: {
        startDate: "",
        endDate: "",
        checkHos: "",
        checkIss: "",
        history: [],
      },
      valueDefault: {
        starDateDefault: "",
        endDateDefault: "",
        checkHosDefault: "全て",
        checkIssDefault: "全て",
      },
      contentsAreaHeight: 200,
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      filterListHos: filterListHospital,
      filterListIss: filterListIssued,
      listDayOfWeek: {
        mon: "月",
        tue: "火",
        wed: "水",
        thu: "木",
        fri: "金",
        sat: "土",
        sun: "日",
      },
      arrayListDay: [],
      isHideMainList: false,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      scrollTable: null,
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
      changePatientId: null,
      errorDateMessage: DIALOG_MESSAGES["99999995"].message,
      newLogin: false,
      answer: null,
      count: 0
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      // add FNSI-改修内容 基本は他施設の場合には、画面項目編集不可 dou start
      getUserId: "getUserId",
      // add FNSI-改修内容 基本は他施設の場合には、画面項目編集不可 dou end
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
      defaultSetting: "getDefaultSetting",
      getPatientShareMode: "getPatientShareMode",
      getPatientShareFacilityCdMode: "getPatientShareFacilityCdMode",
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
    }),
    ...mapGetters("pat-prescription", [
      "getViewMode",
      "getIsEdit",
      "getIsChanged",
      "getListOrderPres",
      "getOrdPrescriptionNo",
      // add FutreNetWeb+SI課題管理No5520 趙 start
      "getStartDate",
      "getEndDate",
      // add FutreNetWeb+SI課題管理No5520 趙 end
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      "getTreatBaseDate",
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      "getInfoFromCalendar",
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
      "isInitialSearchCondition",
      //add FutreNetWeb+SI課題管理-NO.4295 劉全航 start
      "getSearchCondition",
      //add FutreNetWeb+SI課題管理-NO.4295 劉全航 end
    ]),
    ...mapGetters("pat-info", [
      "selectedPatId",
      "selectedPatName",
      "getIsOtherFacility",
      "getOtherFacilityCd",
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    //mod FNSI-5788 劉全航 start
    ...mapGetters("bread-crumb", ["getKeepHistory"]),
    //mod FNSI-5788 劉全航 end
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { height: `${this.contentsAreaHeight}px` };
    },
    viewMode() {
      return this.getViewMode;
    },
    isEdit() {
      return this.getIsEdit;
    },

    isSelectedPatId() {
      return !!this.selectedPatId;
    },
    isChanged() {
      return this.getIsChanged;
    },
    //mod 日機装FNSI 劉全航 start
    contentHeight() {
      const windowHeight = this.windowHeight;
      const headerHeight =
        getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      const footerHeight = getFooterMenuClientHeight(this.$el || null);
      return { height: `${windowHeight - headerHeight - footerHeight - 10}px` };
    },
    //mod 日機装FNSI 劉全航 end
  },
  methods: {
    // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 start
    getAuthority() {
      // mod #10359 編集権限の動作不正 dengshen start
      // const pEdit = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PRESCRIPTION_PEDIT);
      // const edit = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PRESCRIPTION_EDIT);
      // this.isEditDisabled = (pEdit == false && edit == false) || !this.isSelectedPatId;
      this.isEditDisabled = !this.isSelectedPatId;
      // mod #10359 編集権限の動作不正 dengshen end
    },
    // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    ...mapActions("pat-info", ["selectPat"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    ...mapActions("pat-prescription", [
      "setViewMode",
      "setIsEdit",
      "setOrdPrescriptionNo",
      "sendRequestGetOrderPrescription",
      "sendRequestGetOrderPrescriptionDetail",
      // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
      "sendRequestGetFacilityNameByCd",
      // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end
      "clearStateEdit",
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      "setInfoFromCalendar",
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
      //add FutreNetWeb+SI課題管理-NO.4295 劉全航 start
      "setSearchCondition",
      //add FutreNetWeb+SI課題管理-NO.4295 劉全航 end
      /* add by chamaojia 2022-11-18 [6876] レシピ詳細のリセット方法の追加  --start */
      "resetOrderPrescriptionDetail"
      /* add by chamaojia 2022-11-18 [6876] レシピ詳細のリセット方法の追加  --end */
    ]),
    // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
    ...mapMutations("pat-prescription", [
      "setOtherFacilityFlag",
      "setFacilityName",
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    getFacilityName() {
      this.inputModel.history.map(async (x) => {
        x.facilityName = await this.sendRequestGetFacilityNameByCd({
          facilityCd: this.getFacilityCd,
          selectedPatId: this.selectedPatId
        }).then((result) => result.data);
        return x;
      });
    },

    async getShared() {
      await ApiHelper.get(`/pat_event/getPublicFlag/` + this.getUserId, {
        selectedPatId: this.selectedPatId
      })
        .then((res) => {
          if (res.data.msg == 1) {
            this.sharedFlag = true;
          } else {
            this.sharedFlag = false;
          }
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage(
            "PatPrescriptionMainComponent.vue",
            "getShared",
            error
          );
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          throw error;
        });
    },
    // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end

    // add 画面印刷プレビューと印刷の実現 陳 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致

        // 印刷パラメータを応答
        // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
        // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
        // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
        // var selectHistory = this.inputModel.history.find(historyItem => historyItem.ordPrescriptionNo === this.getOrdPrescriptionNo);
        // const issueDateFrom = selectHistory != null ? selectHistory.issueDate.substring(0, 10) : "";
        const index = this.inputModel.history && this.inputModel.history.findIndex(history => history.ordPrescriptionNo === this.getOrdPrescriptionNo);
        var issueDateFrom = dayjs(Date.now()).format("YYYYMMDD");
        if(index > -1){
          issueDateFrom = dayjs(this.inputModel.history[index].issueDate).format("YYYYMMDD");
        }
        // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        // del 11155 機能帳票では正常だが帳票画面で出力されない項目がある sunsy start
        // var issueDateTo = "";
        // if(selectHistory != null){
        //   var dataFrom = new Date(issueDateFrom);
        //   issueDateTo = dayjs(new Date(dataFrom.setMonth(dataFrom.getMonth() + 1))).format("YYYYMMDD");
        // }
        // del 11155 機能帳票では正常だが帳票画面で出力されない項目がある sunsy start
        // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
        const param1 = {
          patId: this.selectedPatId,
          // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
          //date: dayjs(this.inputModel.startDate).format("YYYYMMDD"),
          date: issueDateFrom.replaceAll("/", ""),
          fromDate: issueDateFrom.replaceAll("/", ""),
          // mod 11155 機能帳票では正常だが帳票画面で出力されない項目がある sunsy start
          // toDate: issueDateTo,
          toDate: issueDateFrom.replaceAll("/", ""),
          // mod 11155 機能帳票では正常だが帳票画面で出力されない項目がある sunsy end
          // mod FutreNetWeb+SI課題管理No5520 趙 start
          // fromDate: dayjs(this.inputModel.startDate).format("YYYYMMDD"),
          // toDate: dayjs(this.inputModel.endDate).format("YYYYMMDD"),
          // mod #7233 デフォルト帳票について 日本指摘対応 商 start
          // fromDate: dayjs(this.getStartDate).format("YYYYMMDD"),
          // toDate: dayjs(this.getEndDate).format("YYYYMMDD"),
          // fromDate: dayjs(this.inputModel.startDate).format("YYYYMMDD"),
          // toDate: dayjs(this.inputModel.endDate).format("YYYYMMDD"),
          // mod #7233 デフォルト帳票について 日本指摘対応 商 end
          // mod FutreNetWeb+SI課題管理No5520 趙 end
          // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
          //add 5520院外処方箋プレビューが正しく表示されない 張 start
          ordPrescriptionNo: this.getOrdPrescriptionNo,
          facilityCd: this.getFacilityCd,
          //add 5520院外処方箋プレビューが正しく表示されない 張 end
          functionCd: "02901",
          // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: issueDateFrom.replaceAll("/", ""),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        };
        EventBus.$emit("sendReportParams", param1);
      }
    },
    // add 画面印刷プレビューと印刷の実現 陳 end

    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (this.isSelectedPatId) {
        const wh = this.windowHeight;
        const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
        const fmh =
          (this.isDispMenu === 1
            ? getFooterMenuClientHeight(this.$el || null)
            : 0) + 5;
        const headerAreas = getScopedElementsByClassName("header-area", this.$el || null);
        const ch1 =
          headerAreas[0]?.clientHeight || 0;
        const ch2 =
          headerAreas[1]?.clientHeight || 0;
        this.contentsAreaHeight = wh - hh - fmh - ch1 - ch2 - 16;
      }
    },

    //薬剤分類Popover
    showPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },

    // Popoverキャンセル
    dialogClear() {
      this.inputModel = deepCopy(this.inputModelInit);
    },

    // 処方箋履歴を検索
    async dialogOk() {
      this.setValueDefault();
      this.popoverVisible = false;
      await this.searchHistory();
      await this.selectHistory(0);
    },
    async openPatHistory() {
      await this.search(this.getOrdPrescriptionNo);
    },
    // 共通検索エリア部品に表示するデータを設定
    setValueDefault() {
      //add FutreNetWeb+SI課題管理-NO.4295 劉全航 start
      let condition = {
        startDate: this.inputModel.startDate,
        endDate: this.inputModel.endDate,
        checkHos: this.inputModel.checkHos,
        issued: this.inputModel.checkIss,
      };
      this.setSearchCondition(condition);
      //add FutreNetWeb+SI課題管理-NO.4295 劉全航 end
      this.valueDefault.starDateDefault = this.inputModel.startDate
        ? dayjs(this.inputModel.startDate).format("YYYY/MM/DD")
        : "";
      this.valueDefault.endDateDefault = this.inputModel.endDate
        ? dayjs(this.inputModel.endDate).format("YYYY/MM/DD")
        : "";
      switch (this.inputModel.checkHos) {
        case null:
        case "on":
          this.valueDefault.checkHosDefault = "全て";
          break;
        case "1":
          this.valueDefault.checkHosDefault = "院外";
          break;
        case "2":
          this.valueDefault.checkHosDefault = "院内";
          break;
      }
      switch (this.inputModel.checkIss) {
        case null:
        case "on":
          this.valueDefault.checkIssDefault = "全て";
          break;
        case "0":
          this.valueDefault.checkIssDefault = "未";
          break;
        case "1":
          this.valueDefault.checkIssDefault = "済";
          break;
      }
    },
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 start
    initValueDefault() {
      this.valueDefault.starDateDefault = this.inputModel.startDate
        ? dayjs(this.inputModel.startDate).format("YYYY/MM/DD")
        : "";
      this.valueDefault.endDateDefault = this.inputModel.endDate
        ? dayjs(this.inputModel.endDate).format("YYYY/MM/DD")
        : "";
      switch (this.inputModel.checkHos) {
        case null:
        case "on":
          this.valueDefault.checkHosDefault = "全て";
          break;
        case "1":
          this.valueDefault.checkHosDefault = "院外";
          break;
        case "2":
          this.valueDefault.checkHosDefault = "院内";
          break;
      }
      switch (this.inputModel.checkIss) {
        case null:
        case "on":
          this.valueDefault.checkIssDefault = "全て";
          break;
        case "0":
          this.valueDefault.checkIssDefault = "未";
          break;
        case "1":
          this.valueDefault.checkIssDefault = "済";
          break;
      }
    },
    //add FutreNetWeb+SI課題管理-NO.4295 劉全航 end
    convertDayOfWeek(rawData) {
      switch (rawData) {
        case 0:
          return this.listDayOfWeek.sun;
        case 1:
          return this.listDayOfWeek.mon;
        case 2:
          return this.listDayOfWeek.tue;
        case 3:
          return this.listDayOfWeek.wed;
        case 4:
          return this.listDayOfWeek.thu;
        case 5:
          return this.listDayOfWeek.fri;
        case 6:
          return this.listDayOfWeek.sat;
      }
    },

    // 処方箋履歴を検索機能
    async searchHistory(ordPrescriptionNo) {
      // 共通ローダー:表示開始
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      let patId = this.selectedPatId;
      // changePatientで設定された患者IDがある場合はそちらを使用する
      if (this.changePatientId) {
        patId = this.changePatientId;
        this.changePatientId = null;
      }
      const hasOrdPrescriptionNo = (typeof ordPrescriptionNo === "number") && (ordPrescriptionNo > 0);
      let data = {
        patId,
        // mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou start
        // facilityCd: this.getFacilityCd,
        facilityCd: this.sharedFlag ? null : this.getFacilityCd,
        // mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou end
        prescriptionType:
          this.inputModel.checkHos == "on" ? null : this.inputModel.checkHos,
        issueDateFrom: this.inputModel.startDate
          ? dayjs(this.inputModel.startDate, "YYYY-MM-DD").format("YYYY/MM/DD")
          : null,
        issueDateTo: this.inputModel.endDate
          ? dayjs(this.inputModel.endDate, "YYYY-MM-DD").format("YYYY/MM/DD")
          : null,
        issueState:
          this.inputModel.checkIss == "on" ? null : this.inputModel.checkIss,
        patientShareMode:
          this.getIsOtherFacility === false ||
          (this.getOtherFacilityCd !== null &&
            this.getOtherFacilityCd !== this.getFacilityCd)
            ? 1
            : this.getPatientShareMode,
      };
      if (hasOrdPrescriptionNo) {
        data.ordPrescriptionNo = ordPrescriptionNo;
      }
      //mod #12666 #12667 securify】SQLインジェクション(High) まとめ zrx start
      try {
        await this.sendRequestGetOrderPrescription(data);
      } catch (error) {
        getErrorMessage('PatPrescriptionMainComponent.vue','searchHistory',error);
        // カウント型ローディングの取りこぼし対策（400系でも必ず閉じる）
        this.resetLoadingScreenVisibleCount();
        this.setLoadingScreenVisible(false);
        this.internalServerError(error);
        return;
      }
      //mod #12666 #12667 securify】SQLインジェクション(High) まとめ zrx end
      this.inputModel.history = [...this.getListOrderPres.data].sort((dataA, dataB) => {
        // 第一ソートキー：交付日降順
        if (dataA.issueDate !== dataB.issueDate) {
          return dataA.issueDate > dataB.issueDate ? -1 : 1;
        }
        // 第二ソートキー：未交付＞交付済み
        if (dataA.issueState !== dataB.issueState) {
          return dataA.issueState === "0" ? -1 : 1;
        }
        // 第三ソートキー：院外＞院内
        if (dataA.prescriptionType !== dataB.prescriptionType) {
          return dataA.prescriptionType === "1" ? -1 : 1;
        }
        // 第四ソートキー：登録順降順
        return dataA.ordPrescriptionNo > dataB.ordPrescriptionNo ? -1 : 1;
      });
      this.inputModel.history = this.inputModel.history.map((data) => {
        const date = dayjs(data.issueDate);
        const dow = date.day();
        const dayName = this.convertDayOfWeek(dow);
        data.issueDate = `${data.issueDate} (${dayName})`;
        return {
          ...data,
          active: false,
        };
      });
      this.setConditionList();
      // add FNSI-改修内容 他施設の場合、浅黄色背景にする dou start
      this.inputModel.history = this.inputModel.history.map((x) => {
        if (x.facilityCd == this.getFacilityCd) {
          x.isOtherFacility = false;
        } else {
          x.isOtherFacility = true;
        }
        return x;
      });

      // 表示対象を選択したか
      let isSelected = false;

      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      let ordPrescriptionNoCondition = null;
      if (this.isRouteCreateFlg && this.$route.params.condition.ordPrescriptionNo) {
        this.isRouteCreateFlg = false;
        ordPrescriptionNoCondition = this.$route.params.condition.ordPrescriptionNo;
      } else if (this.isRouteGamenFlg) {
        this.isRouteGamenFlg = false;
        ordPrescriptionNoCondition = this.getTreatBaseDate[0].ordPrescriptionNo;
      }
      if (ordPrescriptionNoCondition) {
        // 患者イベントコードが指定されている場合
        const historyList = this.inputModel.history;
        const index = historyList && historyList.findIndex(history => history.ordPrescriptionNo === ordPrescriptionNoCondition);
        if (index > -1) {
          await this.selectHistory(index);
        }
      } else if (this.isRouteCreateFlg) {
        this.isRouteCreateFlg = false;
        const conditionList = this.$route.params.condition;
        const historyList = this.inputModel.history;
        const prescriptionDetail = conditionList.prescriptionDetail;
        for (let index = 0; index < historyList.length; index++) {
          // イベント開始日、カテゴリ名称、サブカテゴリ名称と同じの場合
          // 処方詳細
          const historyprescriptionDetail = JSON.parse(
            historyList[index].prescriptionDetail
          ).filter((itemt) => itemt.type == "1" && itemt.F1);

          if (
            // 交付日
            historyList[index].issueDate.substring(0, 10) ==
              conditionList.treatDate &&
            // 交付状態
            historyList[index].issueState ==
              (conditionList.issueState == "未交付" ? "0" : "1") &&
            // 処方種別
            historyList[index].prescriptionType ==
              (conditionList.prescriptionType == "院外" ? "1" : "2") &&
            // 数量
            prescriptionDetail.length == historyprescriptionDetail.length
          ) {
            let selectHistoryFlg = true;
            for (let i = 0; i < prescriptionDetail.length; i++) {
              if (
                prescriptionDetail[i].medicine_cd !=
                historyprescriptionDetail[i].medicine_cd
              ) {
                !selectHistoryFlg;
                break;
              }
            }
            if (selectHistoryFlg) await this.selectHistory(index);
          }
        }
      }
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

      // add FNSI-改修内容 他施設の場合、浅黄色背景にする dou end
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      if (this.$route.params.footer === undefined) {
        if (
          this.getInfoFromCalendar.checkedDate != null &&
          this.getInfoFromCalendar.checkedDate != undefined
        ) {
          // 患者カレンダーでクリックした処方区分のリスト上方を展開表示
          const historyList = this.inputModel.history;
          const index = historyList.findIndex(h => h.prescriptionType === this.getInfoFromCalendar.checkedInOroutFlg);
          if (index > -1) {
            await this.selectHistory(index);
          }
          // storeクリア
          this.setInfoFromCalendar({
            checkedDate: null,
            checkedInOroutFlg: null,
            inOroutFlg: null
          });
        }
      }
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end

      // 画面遷移パラメータ取得
      const queryParameters = this.getQueryParameters();

      // イベントコードが指定されて画面遷移した場合、リスト内から対象イベントを表示
      if (queryParameters.RPNO) {
        // リストからRPNOに合致するindexを抽出
        let targetIndex = -1;
        for (let i = 0; i < this.inputModel.history.length; i++) {
          if (
            this.inputModel.history[i].ordPrescriptionNo ==
            Number(queryParameters.RPNO)
          ) {
            targetIndex = i;
          }
        }
        await this.selectHistory(targetIndex > -1 ? targetIndex : 0);
        //mod FutreNetWeb+SI課題管理 no.5456 劉全航 start
        // } else if(this.inputModel.history.length>0){
        // this.selectHistory(0, this.inputModel.history[0]);
        //mod FutreNetWeb+SI課題管理 no.5456 劉全航 end
      }

      // クエリパラメータをクリアする
      this.setQueryParameters({});

      // 共通ローダー：表示終了
      this.setLoadingScreenVisible(false);
    },
    //add #12666 #12667 securify】SQLインジェクション(High) まとめ zrx start
    internalServerError(error) {
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
        title: DIALOG_MESSAGES['00200002'].title
      });
    },
    //add #12666 #12667 securify】SQLインジェクション(High) まとめ zrx end
    async showRegisterComponent(type) {
      this.newLogin = false;
      if (await this.confirmAllowDiscardChanges(type)) {
        // 処方未選択の状態にする
        await this.selectHistory(-1);
        // 処方箋詳細を表示
        await this.setViewMode(true);
      }
    },
    async confirmAllowDiscardChanges(type) {
      let selectedHistory;
      const lastHistory = this.getKeepHistory.slice(-1)[0];
      if(this.$router.history.pending !== null){
        selectedHistory = this.$router.history.pending.meta.historyKey;
      }
      this.count++
      let cancelled = false;
      // #6876 患者を切り替えると内容破棄確認モーダルが表示される 訾浩 start
      if (this.isChanged && this.answer === 1) {
        this.answer = null
        return true
      }
      if (this.count === 2) {
        return
      }
      // #6876 患者を切り替えると内容破棄確認モーダルが表示される 訾浩 end
      if (this.isChanged && (this.$router.history.pending === null || lastHistory !== selectedHistory)/*  && this.count === 1 */) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[12000014].title,
          message: DIALOG_MESSAGES[12000014].message,
          buttonLabels: ["Cancel", "OK"],
          callback: (answer) => {
            // #6876 患者を切り替えると内容破棄確認モーダルが表示される 訾浩 start
            this.answer = answer
            if (answer === 0) {
              cancelled = true;
              this.count = 0
            } else if (answer === 1 && type === 'newType') {
              this.count = 2
              this.answer = 1
            } else {
              this.count = 0
              this.answer = null
            }
            // #6876 患者を切り替えると内容破棄確認モーダルが表示される 訾浩 end
          },
        });
      }
      this.count = 0
      return !cancelled;
    },

    classRowSetting(index, value) {
      return {
        "item-row-hovered": !value,
        //  mod no 3889 画面のデザイン不正 張 start
        // "item-row-checked": value
        "selected-item": value,
        //  mod no 3889 画面のデザイン不正 張 end
      };
    },

    // 処方箋履歴項目を選択
    async selectHistory(index) {
      // this.count = 1
      // mod #6876 患者を切り替えると内容破棄確認モーダルが表示される 付 start
      // this.clearStateEdit();
      const confirmAllowDiscardChanges = await this.confirmAllowDiscardChanges();
      this.count = 0;
      if (confirmAllowDiscardChanges) {
        await this.selectPrescription(index);
      }
      // this.selectPrescription(index);
      // mod #6876 患者を切り替えると内容破棄確認モーダルが表示される 付 end
    },
    async selectPrescription(index) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      await this.setViewMode(false);
      const historyItem = ((index > -1) && (index < this.inputModel.history.length)) ? this.inputModel.history[index] : null;
      if (historyItem) {
        this.setOtherFacilityFlag(historyItem.isOtherFacility);
        this.setFacilityName(historyItem.facilityName);
        await this.sendRequestGetOrderPrescriptionDetail({
          ordPrescriptionNo: historyItem.ordPrescriptionNo,
          selectedPatId: this.selectedPatId
        });
        for (let i = 0; i < this.inputModel.history.length; i++) {
          this.inputModel.history[i].active = (i === index);
        }
        await this.setViewMode(true);
      } else {
        this.setOtherFacilityFlag(false);
        this.setFacilityName("");
        this.cancelDetail();
        this.resetOrderPrescriptionDetail();
      }
      // 共通ローダー：表示終了
      this.setLoadingScreenVisible(false);
    },

    // 患者を選択したとたんに検索する
    // 患者切り替え、更新の動作不正  6553   shan  start
    async search(ordPrescriptionNo) {
      if (this.$route.name.indexOf("pat-prescription") === 0) {
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);
        this.clearStateEdit();
        await this.selectHistoryNew(ordPrescriptionNo);
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
      }
    },

    async searchAlert(selectedPatId) {
      let cancelled = false;
      let patSelected = true;
      let changed = false;
      if (this.selectedPatId == null) {
        patSelected = false;
      } else {
        changed = this.isChanged;
        cancelled = !(await this.confirmAllowDiscardChanges());
      }
      if (!cancelled) {
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);
        this.selectPat(selectedPatId)
          .catch(() => {
            getErrorMessage(
              "PatList.vue",
              "setSelectedPat",
              "[PatList.vue]setSelectedPat(): 患者選択失敗"
            );
            throw new Error("[PatList.vue]setSelectedPat(): 患者選択失敗");
          })
          .then(async () => {
            if (patSelected) {
              this.clearStateEdit();
              await this.selectHistoryNew(-1);
            }
          })
          .finally(() => {
            if (changed) {
              this.newLogin = false;
            }
          });
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
      }
    },
    // 患者切り替え、更新の動作不正  6553   shan  end

    async selectHistoryNew(ordPrescriptionNo) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      await this.searchHistory(ordPrescriptionNo);
      await this.selectHistoryByNo(ordPrescriptionNo);
      this.calculateGridHeight();
      // 共通ローダー：表示終了
      this.setLoadingScreenVisible(false);
    },
    async selectHistoryByNo(ordPrescriptionNo) {
      let index = -1;
      if (ordPrescriptionNo === -1 || ordPrescriptionNo === 0) {
        // 無効な処方オーダー番号の場合はリストの先頭を選択する
        index = 0;
      } else {
        // 処方オーダー番号に対応するindexを検索
        // 存在しなければリストの先頭を選択する
        index = this.inputModel.history.findIndex(historyItem => historyItem.ordPrescriptionNo === ordPrescriptionNo);
        if (index < 0) index = 0;
      }
      await this.selectHistory(index);
    },

    // 詳細キャンセル
    cancelDetail() {
      for (let i = 0; i < this.inputModel.history.length; i++) {
        this.inputModel.history[i].active = false;
      }
    },

    //デフォルト日付
    getDate() {
      // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      // 予実リスト画面へ遷移(初期)の場合
      if (this.isRouteCreateFlg) {
        const treatDate = this.$route.params.condition.treatDate;
        this.valueDefault.starDateDefault = treatDate;
        this.valueDefault.endDateDefault = treatDate;
        this.inputModel.startDate = treatDate.replaceAll("/", "-");
        this.inputModel.endDate = treatDate.replaceAll("/", "-");
        // 予実リスト画面へ遷移(ジャンプしている)の場合
      } else if (this.isRouteGamenFlg) {
        const treatDate = this.getTreatBaseDate[0].treatDate;
        this.valueDefault.starDateDefault = treatDate;
        this.valueDefault.endDateDefault = treatDate;
        this.inputModel.startDate = treatDate.replaceAll("/", "-");
        this.inputModel.endDate = treatDate.replaceAll("/", "-");
        if (this.getTreatBaseDate[0].ordPrescriptionNo != null) {
          // 処方オーダー番号が指定されている場合
          // （処方画面で予実リストの処方を選択した場合）
          // #9329対応時の仕様メモ：
          // 選択したデータの交付日を開始日終了日に設定。内外、交付状況は全てにする。
          this.inputModel.checkHos = "on";
          this.inputModel.checkIss = "on";
        }
      } else {
        // サインイン後、デフォルト設定登録なし、初回表示の場合
        if (this.getSearchCondition.checkHos === "") {
          // 開始：3ヶ月前
          this.inputModel.startDate = dayjs().subtract(3, "months").format("YYYY-MM-DD");
          // 終了：2週間後
          this.inputModel.endDate = dayjs().add(14, "days").format("YYYY-MM-DD");
        } else {
          // サインイン後、初回表示以外はストアから検索条件を復元
          this.inputModel.startDate = this.getSearchCondition.startDate;
          this.inputModel.endDate = this.getSearchCondition.endDate;
          this.inputModel.checkHos = this.getSearchCondition.checkHos;
          this.inputModel.checkIss = this.getSearchCondition.issued;
        }
      }
      // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
    },

    clickTextCheckHos(value) {
      if (value == null) {
        this.inputModel.checkHos = "on";
      } else {
        this.inputModel.checkHos = value;
      }
    },

    clickTextCheckIss(value) {
      if (value == null) {
        this.inputModel.checkIss = "on";
      } else {
        this.inputModel.checkIss = value;
      }
    },

    async changePatient(patientId) {
      // 共通ローダー:表示開始
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      this.changePatientId = patientId;
      this.clearStateEdit();
      await this.selectHistoryNew(-1);
      // 共通ローダー：表示終了
      this.setLoadingScreenVisible(false);
    },
    onCloseMainList(status = true) {
      this.isHideMainList = status;
    },
    // 共通検索エリア部品に表示するデータのリストを作成
    setConditionList() {
      let condList = [];
      const condObj = this.valueDefault;
      // 交付日
      if (condObj.starDateDefault != "" || condObj.endDateDefault != "") {
        condList.push({
          name: "交付日",
          text: condObj.starDateDefault + "～" + condObj.endDateDefault,
        });
      }
      // 内外
      if (condObj.checkHosDefault != "") {
        condList.push({ name: "処方区分", text: condObj.checkHosDefault }); // mod #10184 処方画面文言修正 宮崎
      }
      // 交付状況
      if (condObj.checkIssDefault != "") {
        condList.push({ name: "交付状況", text: condObj.checkIssDefault });
      }
      this.conditionList = condList;
    },
    async init() {
      //this.clearStateEdit();
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // サインインユーザのデフォルト設定を確認・設定(この画面では設定保存をしないため、毎回実行される。)
      const defaultPatPrescription =
        this.defaultSetting[PAT_PRESCRIPTION.KEY_NAME];
      if (this.isInitialSearchCondition && defaultPatPrescription) {
        // ログイン後に記録された検索条件がない場合はデフォルト設定から検索条件を初期設定する
        // 交付日・開始
        if (
          defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_START_DATE] !==
            undefined &&
          defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_START_DATE] !== null
        ) {
          this.inputModel.startDate = calcTargetDate(
            defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_START_DATE]
          );
        }
        // 交付日・終了
        if (
          defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_END_DATE] !==
            undefined &&
          defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_END_DATE] !== null
        ) {
          this.inputModel.endDate = calcTargetDate(
            defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_END_DATE]
          );
        }
        // 内外
        if (
          defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS] !==
          undefined
        ) {
          this.inputModel.checkHos =
            defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_CHECK_HOS];
        }
        // 交付状況
        if (
          defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS] !==
          undefined
        ) {
          this.inputModel.checkIss =
            defaultPatPrescription[PAT_PRESCRIPTION.KEY_NAME_CHECK_ISS];
        }
      } else {
        this.inputModel.checkHos = "on";
        this.inputModel.checkIss = "on";
        this.getDate();
      }
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      // 患者カレンダーから遷移の場合
      if (this.$route.params.footer === undefined) {
        if (
          this.getInfoFromCalendar.checkedDate != null &&
          this.getInfoFromCalendar.checkedDate != undefined
        ) {
          this.inputModel.startDate = this.getInfoFromCalendar.checkedDate;
          this.inputModel.endDate = this.getInfoFromCalendar.checkedDate;
          this.inputModel.checkHos = this.getInfoFromCalendar.inOroutFlg; // 処方区分
          this.inputModel.checkIss = "on"; // 交付状況
        }
      }
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      if (
        this.$route.params.condition &&
        this.$route.params.condition.type == "prescription"
      ) {
        this.isRouteCreateFlg = true;
      }
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
      // 検索初期条件を保持
      this.inputModelInit = deepCopy(this.inputModel);
      // add FNSI-処方を追加 姜 start
      if (
        this.$route.params.condition !== undefined &&
        this.$route.params.condition !== null
      ) {
        if (
          this.$route.params.condition.treatDate !== undefined ||
          this.$route.params.condition.treatDate != null
        ) {
          this.inputModel.startDate = this.$route.params.condition.treatDate
            ? dayjs(this.$route.params.condition.treatDate).format(
                "YYYY-MM-DD")
            : "";
          this.inputModel.endDate = this.$route.params.condition.treatDate
            ? dayjs(this.$route.params.condition.treatDate).format(
                "YYYY-MM-DD")
            : "";
          if (this.$route.params.condition.ordPrescriptionNo != null) {
            // 処方オーダー番号が指定されている場合
            // （処方画面以外で予実リストの処方を選択して遷移してきた場合）
            // #9329対応時の仕様メモ：
            // 選択したデータの交付日を開始日終了日に設定。内外、交付状況は全てにする。
            this.inputModel.checkHos = "on";
            this.inputModel.checkIss = "on";
          }
        } else {
          this.inputModel.startDate = this.$route.params.condition.data[0]
            .treatDate
            ? dayjs(this.$route.params.condition.data[0].treatDate).format(
                "YYYY-MM-DD")
            : "";
          this.inputModel.endDate = this.$route.params.condition.data[
            this.$route.params.condition.data.length - 1
          ].treatDate
            ? dayjs(
                this.$route.params.condition.data[
                  this.$route.params.condition.data.length - 1
                ].treatDate
              ).format("YYYY-MM-DD")
            : "";
        }
      }
      // add FNSI-処方を追加 姜 end
      // 共通検索エリアに表示
      //add FutreNetWeb+SI課題管理-NO.4295 劉全航 start
      this.initValueDefault();
      //this.setValueDefault();
      //add FutreNetWeb+SI課題管理-NO.4295 劉全航 end
      // add FNSI-改修内容 基本は他施設の場合には、画面項目編集不可 dou start
      await this.getShared();
      // add FNSI-改修内容 基本は他施設の場合には、画面項目編集不可 dou end
      if (this.isSelectedPatId) {
        await this.searchHistory();
        if (
          this.inputModel.history
          && this.inputModel.history.length > 0
          && this.inputModel.history.findIndex(history => history.active) < 0
        ) {
          // まだ選択されていなければ先頭を選択する
          await this.selectHistory(0);
        } else {
          await this.setViewMode(false);
        }
      }
      // 共通ローダー：表示終了
      this.setLoadingScreenVisible(false);
      // add 性能改善メモリ不足 shan start
      EventBus.$off("search", this.search);
      EventBus.$off("searchAlertPatPre", this.searchAlert);
      EventBus.$off("cancel", this.cancelDetail);
      EventBus.$off("change-patient-prescription", this.changePatient);
      // add 性能改善メモリ不足 shan end
      EventBus.$on("search", this.search);
      EventBus.$on("searchAlertPatPre", this.searchAlert);
      EventBus.$on("cancel", this.cancelDetail);
      EventBus.$on("change-patient-prescription", this.changePatient);
    },
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start*/
    getTreatBaseDate() {
      this.isRouteGamenFlg = true;
      this.getDate();
      this.initValueDefault();
      this.searchHistory();
    },
    /*add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end*/
    // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 start
    isSelectedPatId() {
      this.getAuthority()
    },
    // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 end
    getPatientShareMode() {
      this.init();
    },
    getPatientShareFacilityCdMode() {
      this.init();
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    this.scrollTable = this.$refs.scrollTable;
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
  },
  async created() {
    // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 start
    this.getAuthority()
    // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 end
    // add 画面印刷プレビューと印刷の実現 陳 start
    // 印刷パラメータ要求
    // add 性能改善メモリ不足 shan start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 陳 end
    await this.init();
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("searchAlertPatPre", this.searchAlert);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("search", this.search);
    EventBus.$off("cancel", this.cancelDetail);
    EventBus.$off("change-patient-prescription", this.changePatient);
    
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  // add 性能改善メモリ不足 shan end
};
</script>

<style scoped>
.history-area {
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  height: 100%;
  width: 285px;
  padding-left: 5px;
}
.header-area {
  display: flex;
  float: left;
  width: 100%;
  text-align: center;
}
.header-icon {
  width: 3em;
  display: flex;
  align-self: flex-start;
  position: relative;
  margin-top: 0px;

}
/** 子機能開閉ボタン */
.pat-prescription-openclose-icon {
  font-size: 2em;
  margin-right: 15px;
  margin-left: 5px;
  color: var(--pat-event-text-color);
}
.header-button {
  width: 100%;
}
.detail-area {
  display: flex;
  float: left;
  width: 100%;
  padding-top: 5px;
}
.content-area {
  height: 100%;
  width: 100%;
  overflow-x: auto;
  overflow-y: hidden;
}
/* mod no 3889 画面のデザイン不正 張 start */
.table-area {
  width: 100%;
  border-collapse: collapse;
  overflow-y: scroll;
}
.table-area tr {
  height: 30px;
}
.table-area tr th {
  text-align: left;
  width: 70%;
  border-right: 1px solid var(--ntss-list-border-color);
  font-weight: normal;
  position: sticky;
  top: 0;
  z-index: 1;
}

table.list {
  background-color: transparent;
  background-image: none;
}
table.list .list-score {
  text-align: center;
  white-space: nowrap;
  width: 100%;
}
.table-area-label {
  border: 1px solid var(--ntss-list-border-color);
}
.selected-item {
  outline: 3px solid #2ca06f;
  outline-offset: -3px;
}
/* table.list .list-event { */
table.list {
  text-align: center;
  /* del FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start */
  white-space: nowrap;
  /* del FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end */
  width: 100%;
  color: var(--ntss-base-color);
}
.button {
  padding: 0px 3px 0px 5px;
}
.item-row-hovered:hover {
  background-color: transparent;
}
/*del FNSI-画面部品デザイン じょはく start*/
/*.item-row-checked {
  outline: 3px solid #0000ff;
  outline-offset: -3px;
}*/
/*del FNSI-画面部品デザイン じょはく end*/
.title-label {
  padding: 5px;
  order: 2;
  margin: 0 auto;
}
.input {
  vertical-align: middle;
  background-color: white;
}
/* max-width: 15em; */
.input :deep(.text-input) {
  height: 2em;
  line-height: 2em;
}
.select {
  vertical-align: middle;
}
.popover-area :deep(.popover) {
  width: auto;
}
.popover-area :deep(.popover__content) {
  width: 19em;
  min-width: 300px;
}
.hover:hover {
  cursor: pointer;
}
.unstyled-date {
  -webkit-appearance: none;
}
.unstyled-date :deep(.text-input::-webkit-calendar-picker-indicator) {
  -webkit-appearance: none;
  display: none;
}
.calendar :deep(.ntss-btn-outset.calendar) {
  height: 2em;
  min-height: 2em;
  padding-top: 0;
  padding-bottom: 0;
}
.main-area {
  overflow: hidden;
  padding: 0px;
  display: flex;
}
.main-area > .header-icon {
  opacity: unset;
}

.main-area > .header-icon > .pat-prescription-openclose-icon {
  margin-left: 10px;
}

/* .color-shadow {
  box-shadow: 0 2px 2px 0 rgba(255,255,255,.2) inset,0 2px 20px 0 rgba(255,255,255,.5) inset,0 -2px 2px 0 rgba(0,0,0,.1);
} */
/* mod no 3889 画面のデザイン不正 張 end */
.add-button-area {
  display: flex;
}
/* add FNSI-改修内容 他施設の場合、浅黄色背景にする dou start */
.bgc_yellow {
  background-color: #fffe2a4d;
}
/* add FNSI-改修内容 他施設の場合、浅黄色背景にする dou end */
@media print {
  /** 履歴のスクロールバー非表示 */
  table.list{
    overflow: visible !important;
  }
}
.row-block {
  display: flex;
}

.cell {
  text-align: left;
  width: 100%;
}
</style>
