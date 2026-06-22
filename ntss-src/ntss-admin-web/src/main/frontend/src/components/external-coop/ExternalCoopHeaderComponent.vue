<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col class="condition-search-col w-492">
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col class="facility-picker-col backgroud-white w-492" v-if="isMasterUser">
          <kendo-dropdownlist
            ref="dropdown"
            v-model="toFacilityCd"
            :data-source="facilityList"
            data-text-field="facilityName"
            data-value-field="facilityCd"
            @change="callSearchByFacility($event)"
            filter="contains"
            class="facility-picker"
          />
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'external-coop-header-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow($event); addLineStyle($event)"
      @posthide="popoverPosthide"
    >
      <div style="margin:10px;" class="external-coop-popover">
        <v-ons-row class="condition-row">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;">
            <label>最大検索数</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" style="line-height: 2em; white-space: nowrap;">
            <v-ons-input
              input-id="id"
              type="number"
              v-model="condition.inProgress.limit"
              @keydown.enter="dialogOk"
              @change="inputNumber"
              @blur="handleBlur"
              @focus="handleFocus"
              @mousewheel.prevent="handleMouseWheel"
              style="width: 50%; min-width: 3em;"
            ></v-ons-input>
            <label> 件</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;">
            <label>電文種別</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" class="external-coop-filter-ms external-coop-ms-dropdown coop-cd-select external-coop-coopcd-ms">
            <kendo-multiselect
              class="browser-default-font"
              :data-source="coopCdsList"
              v-model="condition.inProgress.coopCd"
              data-text-field="text"
              data-value-field="value"
              style="min-width: 14em;"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;">
            <label>方向</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" style="white-space: nowrap;">
            <v-ons-checkbox
              input-id="directionSubmit"
              value="S"
              v-model="condition.inProgress.direction"
              style="vertical-align: baseline; width: 30px;"
            ></v-ons-checkbox>
            <label for="directionSubmit" class="popoverFilterLabel" style="margin-right: 20px;">送信</label>
            <v-ons-checkbox
              input-id="directionReceiving"
              value="R"
              v-model="condition.inProgress.direction"
              style="vertical-align: baseline; width: 30px;"
            ></v-ons-checkbox>
            <label for="directionReceiving" class="popoverFilterLabel">受信</label>
          </v-ons-col>
        </v-ons-row>
        <!-- 処理結果の開始 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;">
            <label>処理結果</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" class="external-coop-filter-ms external-coop-ms-dropdown">
            <kendo-multiselect
              class="browser-default-font"
              :data-source="anaResultList"
              v-model="condition.inProgress.anaResult"
              data-text-field="text"
              data-value-field="value"
              style="min-width: 14em;"
            />
          </v-ons-col>
        </v-ons-row>
        <!-- 処理結果の終了 -->

        <!-- 配信結果の開始 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;">
            <label>通信結果</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" class="browser-default-font external-coop-filter-ms external-coop-ms-dropdown">
            <kendo-multiselect
              class="browser-default-font"
              :data-source="coopResultList"
              v-model="condition.inProgress.coopResult"
              data-text-field="text"
              data-value-field="value"
              style="min-width: 14em;"
            />
          </v-ons-col>
        </v-ons-row>
        <!-- 配信結果の終了 -->
        <v-ons-row class="condition-row" style="margin-bottom: 5px;">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;">
            <label>処理期間</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" style="line-height: 2em; white-space: nowrap; display: flex;">
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <date-input
              :classes="'ntss-input-date input-area ntss-custom-input'"
              max="9999-12-31"
              v-model="condition.inProgress.date.from.date"
              @handleClearInput="condition.inProgress.date.from.date = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="condition.inProgress.date.from.date" class="calender" />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <time-input
              float
              type="time"
              style="width: auto;"
              v-model="condition.inProgress.date.from.time"
              @handleClearInput="condition.inProgress.date.from.time = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <div style="float:right; margin-right: 1px; margin-left: 10px;">
              <v-ons-button
                class="delete btn3-normal"
                @click="clearDateTime(condition.inProgress.date.from)"
              >クリア</v-ons-button>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;" class="date-line-chk tilde-text">
            <label>～</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" style="line-height: 2em; white-space: nowrap; display: flex;" class="date-line-chk">
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <date-input
              :classes="'ntss-input-date input-area ntss-custom-input'"
              float
              max="9999-12-31"
              v-model="condition.inProgress.date.to.date"
              @handleClearInput="condition.inProgress.date.to.date = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <!-- #9489 検索条件の動作が不正 2023-08-30 卓 start -->
            <common-calendar v-model="condition.inProgress.date.to.date" class="calender" />
            <!-- #9489 検索条件の動作が不正 2023-08-30 卓 end -->
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <time-input
              float
              style="width: auto;"
              v-model="condition.inProgress.date.to.time"
              @handleClearInput="condition.inProgress.date.to.time = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <div style="float:right; margin-right: 1px; margin-left: 8px;">
              <v-ons-button
                class="delete btn3-normal"
                @click="clearDateTime(condition.inProgress.date.to)"
              >クリア</v-ons-button>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row" style="margin-bottom: 5px;">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;">
            <label>通信期間</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" style="line-height: 2em; white-space: nowrap; display: flex;">
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <date-input
              :classes="'ntss-input-date input-area ntss-custom-input'"
              max="9999-12-31"
              v-model="condition.inProgress.regDate.from.date"
              @handleClearInput="condition.inProgress.regDate.from.date = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="condition.inProgress.regDate.from.date" class="calender" />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <time-input
              float
              style="width: auto;"
              v-model="condition.inProgress.regDate.from.time"
              @handleClearInput="condition.inProgress.regDate.from.time = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <div style="float:right; margin-right: 1px; margin-left: 10px;">
              <v-ons-button
                class="delete btn3-normal"
                @click="clearDateTime(condition.inProgress.regDate.from)"
              >クリア</v-ons-button>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;" class="tilde-text">
            <label>～</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" style="line-height: 2em; white-space: nowrap; display: flex;">
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <date-input
              :classes="'ntss-input-date input-area ntss-custom-input'"
              float
              max="9999-12-31"
              v-model="condition.inProgress.regDate.to.date"
              @handleClearInput="condition.inProgress.regDate.to.date = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="condition.inProgress.regDate.to.date" class="calender" />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <time-input
              float
              style="width: auto;"
              v-model="condition.inProgress.regDate.to.time"
              @handleClearInput="condition.inProgress.regDate.to.time = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <div style="float:right; margin-right: 1px; margin-left: 8px;">
              <v-ons-button
                class="delete btn3-normal"
                @click="clearDateTime(condition.inProgress.regDate.to)"
              >クリア</v-ons-button>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row" style="margin-bottom: 5px;">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;">
            <label>基準日</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" style="line-height: 2em; white-space: nowrap; display: flex;">
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <date-input
              :classes="'ntss-input-date input-area ntss-custom-input'"
              max="9999-12-31"
              v-model="condition.inProgress.baseDate.from.date"
              @handleClearInput="condition.inProgress.baseDate.from.date = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="condition.inProgress.baseDate.from.date" class="calender" />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <time-input
              float
              style="width: auto;"
              v-model="condition.inProgress.baseDate.from.time"
              @handleClearInput="condition.inProgress.baseDate.from.time = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <div style="float:right; margin-right: 1px; margin-left: 10px;">
              <v-ons-button
                class="delete btn3-normal"
                @click="clearDateTime(condition.inProgress.baseDate.from)"
              >クリア</v-ons-button>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;" class="tilde-text">
            <label>～</label>
          </v-ons-col>
          <v-ons-col vertical-align="center" style="line-height: 2em; white-space: nowrap; display: flex;">
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <date-input
              :classes="'ntss-input-date input-area ntss-custom-input'"
              float
              max="9999-12-31"
              v-model="condition.inProgress.baseDate.to.date"
              @handleClearInput="condition.inProgress.baseDate.to.date = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="condition.inProgress.baseDate.to.date" class="calender" />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
            <time-input
              float
              style="width: auto;"
              v-model="condition.inProgress.baseDate.to.time"
              @handleClearInput="condition.inProgress.baseDate.to.time = null"
            />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
            <div style="float:right; margin-right: 1px; margin-left: 8px;">
              <v-ons-button
                class="delete btn3-normal"
                @click="clearDateTime(condition.inProgress.baseDate.to)"
              >クリア</v-ons-button>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="16%" vertical-align="center" style="min-width: 6em;">
            <label>フリーワード</label>
          </v-ons-col>
          <v-ons-col vertical-align="center">
            <v-ons-input
              input-id="content"
              type="text"
              v-model="condition.inProgress.content"
              style="min-width: 14em;"
            ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
      </div>
      <div class="condition-row">
        <div style="float:left; margin-left: 10px;">
          <v-ons-button class="clear btn2-cancel" @click="dialogClear"
            >クリア</v-ons-button
          >
        </div>
        <div style="float:right; margin-right: 10px;">
          <v-ons-button class="ok btn3-normal" @click="dialogOk">OK</v-ons-button>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import { facilitySort as getFacility } from "@/functions/mst/MstGetters.js";
import { deepCopy, hasEqualValues } from "@/functions/common/CommonFunctions";
// modify 9583 by kangjie 20240403 start 通知一覧の連携エラー通知の遷移不正
// import { makeDefaultCondition } from "@/functions/external-coop/ExternalCoopFunctions";
import { makeDefaultCondition,makeFromToDateTime } from "@/functions/external-coop/ExternalCoopFunctions";
// modify 9583 by kangjie 20240403 end 通知一覧の連携エラー通知の遷移不正
import { ANA_RESULT_LIST, COOP_RESULT_LIST, COOP_CDS_LIST, DIRECTION_LIST, valuesToString } from "./GridColums";
import PopoverMixin from "@/components/PopoverMixin";
import CommonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
// #5590 2023/04/18 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
import TimeInput from "@/components/common/TimeInput.vue";
// #5590 2023/04/18 ×を常に表示するように修正 張博 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getOnsPopoverElement } from "@/functions/common/OnsenFunctions";
import { getKendoWidgetValue, setKendoWidgetValue } from "@/functions/common/KendoFunctions";
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
export default {
  mixins: [PopoverMixin],
  components: {
    "common-calendar": CommonCalender,
    "common-searcharea": commonSearchArea,
    // #5590 2023/04/18 ×を常に表示するように修正 張博 start
     DateInput,
     TimeInput
    //  #5590 2023/04/18 ×を常に表示するように修正 張博 end
  },
  data() {

    // modify 9583 by kangjie 20240403 start
    // const defaultCondition = makeDefaultCondition();
    // modify 9583 by kangjie 20240403 end
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      // modify 9583 by kangjie 20240403 start
      // condition: {
      //   inProgress: deepCopy(defaultCondition),
      //   inUsed: deepCopy(defaultCondition),
      // },
      condition:{},
      // modify 9583 by kangjie 20240403 end
      facilityList: [],
      toFacilityCd: "",
      previousFacilityCd: "", // 変更前選択施設コード
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      // mod #5589 2023/04/06 数値IFのスタイル全不正 張博 start
      min:0,
      max:9999,
      blurFlg: false,
      focusFlg: false,
      // mod #5589 2023/04/06 数値IFのスタイル全不正 張博 end
      hasChangesFromMain: false, // メインコンポーネントの編集状況
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("external-coop", [
      "getToFacilityCd",
      "getCondition",
      "getExternalCoopList"
      // add 9583 by kangjie 20240402 start 通知一覧の連携エラー通知の遷移不正
      ,"getJumpChangeCoopState"
      // add 9583 by kangjie 20240402 end 通知一覧の連携エラー通知の遷移不正
    ]),
    ...mapGetters("account-edit", {
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    isMasterUser() {
      return this.getStateUserAccountInfo.userType === 1;
    },
    // importした定数をtempleteで使用するためcomputedで取得できるようにする
    coopCdsList() { return COOP_CDS_LIST; },
    anaResultList() { return ANA_RESULT_LIST; },
    coopResultList() { return COOP_RESULT_LIST; },
  },
  methods: {
    getDropdownWidget() {
      return this.$refs.dropdown?.kendoWidget?.() || null;
    },
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
    ]),
    ...mapActions("external-coop", [
      "setToFacilityCd",
      "searchExternalCoopList",
      "sendRequestGetEdgeState",
      //add 6085 施設がIFエッジある施設であるかの判断 ljx start
      "sendRequestGetHasIfEdge",
      //add 6085 施設がIFエッジある施設であるかの判断 ljx end
      "setCondition",
      // add 9583 by kangjie 20240403 start 通知一覧の連携エラー通知の遷移不正
      "clearJumpCoopCondition",
      // add 9583 by kangjie 20240403 end 通知一覧の連携エラー通知の遷移不正
    ]),
    // add 6727 検索条件が正しく動作しない 関 start
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
    }),
    // add 6727 検索条件が正しく動作しない 関 end
    ...mapMutations("external-coop", ["setCloudInfo"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add 9583 by kangjie 20240403 start 通知一覧の連携エラー通知の遷移不正
    initCondition() {
      const jumpChangeCoopState = this.getJumpChangeCoopState;
      let defaultCondition = null;
      if (jumpChangeCoopState.baseDate || jumpChangeCoopState.ctlNo || jumpChangeCoopState.ordNo || jumpChangeCoopState.coopCd){
        defaultCondition = {
          limit: 100,
          coopCd: [jumpChangeCoopState.coopCd],
          direction: ["S", "R"],
          anaResult: [],
          coopResult: [],
          date: makeFromToDateTime(null, null, null, null),
          regDate: makeFromToDateTime(null, null, null, null),
          baseDate: makeFromToDateTime(jumpChangeCoopState.baseDate, null, jumpChangeCoopState.baseDate, null),
          content: jumpChangeCoopState.ctlNo? jumpChangeCoopState.ctlNo: jumpChangeCoopState.ordNo,
        };
      } else {
        defaultCondition = makeDefaultCondition();
      }
      this.condition = {
        inProgress: deepCopy(defaultCondition),
        inUsed: deepCopy(defaultCondition)
      };
    },
    // add 9583 by kangjie 20240403 end 通知一覧の連携エラー通知の遷移不正
    // mod #5589 2023/04/06 数値IFのスタイル全不正 張博 start
    inputNumber(e) {
      // 数値範囲内かどうかの確認
      if (this.min !== undefined && this.max !== undefined) {
        if (e.target.value > this.max) {
          e.target.value = this.min;
          this.blurFlg = true;
        } else if (e.target.value < this.min) {
          e.target.value = this.max;
          this.blurFlg = true;
        } else {
          this.blurFlg = false;
        }
      }
    },
    // mod #5589 2023/04/06 数値IFのスタイル全不正 張博 end
    // #5589 2023/04/17 数値IFのスタイル全不正 林峻峰 start
    handleBlur(event){
      if (event.target.value == this.max && this.blurFlg) {
        this.condition.inProgress.limit = this.min;
        this.blurFlg = false
      }else if (event.target.value == this.min && this.blurFlg) {
        this.condition.inProgress.limit = this.max;
        this.blurFlg = false
      }
      this.focusFlg=false;
    },
    handleMouseWheel(e) {
      if (!this.focusFlg) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
      }
      let value = parseFloat(e.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > this.max) {
        value = this.min;
      }
      if(value < this.min) {
        value = this.max;
      }
      this.condition.inProgress.limit = value
    },
    handleFocus(){
     this.focusFlg=true;
    },
    // #5589 2023/04/17 数値IFのスタイル全不正 林峻峰 end
    formatDateTime(fromDate, fromTime, toDate, toTime) {
      const startTime = fromTime ? fromTime : "00:00";
      const endTime = toTime ? toTime : "23:59";
      const startDateTime = fromDate
        ? `${dayjs(fromDate).format("YYYY/MM/DD")} ${startTime}`
        : null;
      const endDateTime = toDate
        ? `${dayjs(toDate).format("YYYY/MM/DD")} ${endTime}`
        : null;

      return {
        startDateTime,
        endDateTime
      };
    },
    showAnaResult(value) {
      switch (value) {
        case "0":
          return "未処理";
        case "1":
          return "処理中";
        case "9":
          return "処理完了";
        case "S":
          return "スキップ";
        case "E1":
          return "内部エラー";
        case "E2":
          return "外部エラー";
      // add 8298 稼働ビューアで検索条件に保留が選択できない 関 start
        case "H":
          return "保留";
      // add 8298 稼働ビューアで検索条件に保留が選択できない 関  end
        default:
          return "";
      }
    },
    showCoopResult(value) {
      switch (value) {
        case "0":
          return "未処理";
        case "1":
          return "処理中";
        case "8":
          return "応答待ち";
        case "9":
          return "処理完了";
        case "R":
          return "リトライ";
        case "S":
          return "スキップ";
        case "E1":
          return "内部エラー";
        case "E2":
          return "外部エラー";
        default:
          return "";
      }
    },
    showCoopCd(value) {
      switch (value) {
        case "ini_dial":
          return "浄化申し込み・初回指示";
        case "is_death":
          return "死亡退院";
        case "profile":
          return "患者プロファイル";
        case "ind_dial":
          return "透析予約";
        case "ord_dial":
          return "オーダ受け";
        case "accept":
          return "受付情報";
        case "rst_dial":
          return "透析実績";
        case "rep_dial":
          return "透析レポート";
        case "exam_rst":
          return "検査結果";
        case "exam_ord":
          return "検査オーダ";
        case "rad_ord":
          return "放射線検査オーダ";
        case "phy_ord":
          return "心電図検査オーダ";
        case "shot_ord":
          return "透析注射";
        case "pre_ord":
          return "処方情報";
        case "staff_mst":
          return "スタッフマスタ";
        case "vit_cop":
          return "バイタル";
        case "karte_ord":
          return "カルテ記載";
        case "iji_dial":
          return "医事会計";
        default:
          return "";
      }
    },
    showPopover(event) {
      this.condition.inProgress = deepCopy(this.condition.inUsed);
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    onHasChangesUpdated(value) {
      this.hasChangesFromMain = value;
    },
    dialogClear() {
      this.condition.inProgress = makeDefaultCondition();
    },
    clearDateTime(dateTime) {
      dateTime.date = null;
      dateTime.time = null;
    },
    async dialogOk() {
      this.popoverVisible = false;
      if (this.hasChangesFromMain) {
        // 内容破棄
        const ok = await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
        });
        if (!ok) {
          this.setLoadingScreenVisible(false);
          return;
        }
      }
      this.setLoadingScreenVisible(true);

      if (!hasEqualValues(this.condition.inProgress, this.condition.inUsed)) {
        this.condition.inUsed = deepCopy(this.condition.inProgress);
      }
      this.setConditionList();
      await this.callSearch();

      this.setLoadingScreenVisible(false);
    },
    async callSearchByFacility(event) {
      if (this.hasChangesFromMain) {
        // 内容破棄
        const ok = await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
        });
        if (!ok) {
          this.toFacilityCd = this.previousFacilityCd;
          this.$nextTick(() => {
            const widget = this.getDropdownWidget();
            if (widget) {
              setKendoWidgetValue(widget, this.previousFacilityCd);
            }
          });
          return;
        }
      }
      // add NKK権限のユーザーでログインして、【連携】画面、施設プルダウン変換する時、施設コードはログインユーザーの施設コードで変わらない xugj zhaoqi start
      let fac = getKendoWidgetValue(event.sender, event.sender?._old);
      this.toFacilityCd = fac;
      this.previousFacilityCd = fac;
      // add NKK権限のユーザーでログインして、【連携】画面、施設プルダウン変換する時、施設コードはログインユーザーの施設コードで変わらない xugj zhaoqi end

      this.setLoadingScreenVisible(true);

      //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start
      EventBus.$emit("IfEdgeConnStatus", this.toFacilityCd);
      //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end

      await this.sendRequestGetEdgeState({
        facilityCd: this.toFacilityCd,
      });
      await this.callSearch();
      //add 6085 施設がIFエッジある施設であるかの判断 ljx start
      await this.sendRequestGetHasIfEdge({
        facilityCd: this.toFacilityCd,
      });
      //add 6085 施設がIFエッジある施設であるかの判断 ljx end

      this.setLoadingScreenVisible(false);
    },
    async callSearch() {
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      try {

      const inUsed = this.condition.inUsed;
      const toDateTimeParameter = (dateTime, defaultTime) => dateTime.date
        ? `${dayjs(dateTime.date).format("YYYY/MM/DD")} ${dateTime.time ? dateTime.time : defaultTime}`
        : null;
      const formatDateTime = (fromToDateTime) => ({
        startDateTime: toDateTimeParameter(fromToDateTime.from, "00:00"),
        endDateTime: toDateTimeParameter(fromToDateTime.to, "23:59"),
      });
      const dateTime = formatDateTime(inUsed.date);
      const regDateTime = formatDateTime(inUsed.regDate);
      const baseDateTime = formatDateTime(inUsed.baseDate);
      // modify 9583 by kangjie 20240402 start 通知一覧の連携エラー通知の遷移不正
      // const blankToNull = (anArray) => anArray.length > 0 ? anArray : null;
      const blankToNull = (anArray) => anArray?.length > 0 ? anArray : null;
      // const payload = {
      let payload = {
        // modify 9583 by kangjie 20240402 end 通知一覧の連携エラー通知の遷移不正
        params: {
          isSearch: true,
          limit: inUsed.limit,
          coopCd: blankToNull(inUsed.coopCd),
          direction: blankToNull(inUsed.direction),
          anaResult: blankToNull(inUsed.anaResult),
          coopResult: blankToNull(inUsed.coopResult),
          content: inUsed.content,
          fromDate: dateTime.startDateTime,
          toDate: dateTime.endDateTime,
          fromRegDate: regDateTime.startDateTime,
          toRegDate: regDateTime.endDateTime,
          fromBaseDate: baseDateTime.startDateTime,
          toBaseDate: baseDateTime.endDateTime,
        },
        facilityCd: this.toFacilityCd,
      };
      // del #12216 通知から連携稼働ビューアに遷移すると抽出条件を変更しても条件に合った抽出が行われない zkm start
      // // modify 9583 by kangjie 20240402 start 通知一覧の連携エラー通知の遷移不正
      // let jumpChangeCoopState = this.getJumpChangeCoopState;
      // if ( jumpChangeCoopState.baseDate || jumpChangeCoopState.ctlNo || jumpChangeCoopState.ordNo || jumpChangeCoopState.coopCd ) {
      //   // display location data
      //   payload = {
      //     params: {
      //       isSearch: true,
      //       limit: inUsed.limit,
      //       coopCd: null,
      //       direction: blankToNull(inUsed.direction),
      //       anaResult: null,
      //       coopResult: null,
      //       content: jumpChangeCoopState.ctlNo?jumpChangeCoopState.ctlNo:jumpChangeCoopState.ordNo,
      //       fromBaseDate: baseDateTime.startDateTime,
      //       toBaseDate: baseDateTime.endDateTime,
      //       ctlNo: jumpChangeCoopState.ctlNo,
      //       ordNo: jumpChangeCoopState.ordNo
      //     },
      //     facilityCd: this.toFacilityCd,
      //   }
      // }
      // // modify 9583 by kangjie 20240402 end 通知一覧の連携エラー通知の遷移不正
      // del #12216 通知から連携稼働ビューアに遷移すると抽出条件を変更しても条件に合った抽出が行われない zkm end
      this.setCondition(deepCopy(inUsed));
      this.setToFacilityCd(this.toFacilityCd);
      await this.searchExternalCoopList(payload);
      this.checkCloudInfo(this.getExternalCoopList);
      await EventBus.$emit("generateDataSource");

      } finally {
      this.setLoadingScreenVisible(false);
      }
    },
    checkCloudInfo(list) {
      let pendingCase = 0;
      let errorCase = 0;
      let outRegDate = "";
      let outAnaDate = "";
      if (list) {
        list.forEach(e => {
          // 処理待ち件数 - エラー件数
          if (e.anaResult == "0") {
            // 処理待ち件数
            if (e.coopResult.includes(["0", "1", "9"])) {
              pendingCase++;
            } else if (e.coopResult == "E2") {
              // エラー件数
              errorCase++;
            }
          } else if (e.anaResult == "E1") {
            // エラー件数
            if (e.coopResult.includes(["0", "9"])) {
              errorCase++;
            }
          } else if (e.anaResult == "9") {
            // エラー件数
            if (e.coopResult == "E2") {
              errorCase++;
            }
          } else {
            // 処理待ち件数
            if (e.coopResult == "0") {
              pendingCase++;
            }
          }
          outRegDate = e.outRegDate;
          outAnaDate = e.outAnaDate;
          // 最終処理日時
          if (Date.parse(e.outRegdate) > Date.parse(outRegDate)) {
            outRegDate = e.outRegdate;
          }
          // 最終通信日時
          if (Date.parse(e.outAnaDate) > Date.parse(outAnaDate)) {
            outAnaDate = e.outAnaDate;
          }
        });
        this.setCloudInfo({
          aliveStatus: "OK",
          pendingCase,
          errorCase,
          outRegDate,
          outAnaDate
        });
      }
    },
    setInitCondition() {
      // この関数はcreated時に呼ばれるため、
      // this.condition.inUsed と this.condition.inProgress は
      // makeDefaultCondition で生成した内容になっている
      // this.getCondition で過去に保存した情報が取得できた場合のみ
      // その内容を this.condition.inUsed に上書きして
      // this.condition.inProgress も同じ内容に更新する
      // mod #12216 通知から連携稼働ビューアに遷移すると抽出条件を変更しても条件に合った抽出が行われない zkm start
      // if (this.getCondition) {
      const jumpChangeCoopState = this.getJumpChangeCoopState;
      if (this.getCondition && !(jumpChangeCoopState.baseDate || jumpChangeCoopState.ctlNo || jumpChangeCoopState.ordNo || jumpChangeCoopState.coopCd)) {
        // mod #12216 通知から連携稼働ビューアに遷移すると抽出条件を変更しても条件に合った抽出が行われない zkm end
        // #8368対応時のメモ：
        // 画面遷移時に保持対象とする項目は
        // 「最大検索数」「電文種別」「方向」「処理結果」「通信結果」のみとする
        this.condition.inUsed.limit = this.getCondition.limit;
        this.condition.inUsed.coopCd = [...this.getCondition.coopCd];
        this.condition.inUsed.direction = [...this.getCondition.direction];
        this.condition.inUsed.anaResult = [...this.getCondition.anaResult];
        this.condition.inUsed.coopResult = [...this.getCondition.coopResult];
        this.condition.inProgress = deepCopy(this.condition.inUsed);
      }
      this.setConditionList();
    },

    // 共通検索エリア部品に表示するデータのリストを作成
    setConditionList() {
      const conditionList = [];
      const addCondition = (name, text) =>  conditionList.push({ name, text });
      const inUsed = this.condition.inUsed;
      //#9489 検索条件の動作が不正 2023-08-30 卓 start
      // 处理期间
      if (inUsed.date.from.date == null && inUsed.date.from.time != null) {
        inUsed.date.from.date = dayjs(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.date.to.date == null && inUsed.date.to.time != null) {
        inUsed.date.to.date = dayjs(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.date.from.date != null && inUsed.date.from.time == null) {
        inUsed.date.from.time = dayjs().startOf('day').format("HH:mm");
      }
      if (inUsed.date.to.date != null && inUsed.date.to.time == null) {
        inUsed.date.to.time = dayjs().endOf('day').format("HH:mm");
      }
      // 通信期間
      if (inUsed.regDate.from.date == null && inUsed.regDate.from.time != null) {
        inUsed.regDate.from.date = dayjs(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.regDate.to.date == null && inUsed.regDate.to.time != null) {
        inUsed.regDate.to.date = dayjs(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.regDate.from.date != null && inUsed.regDate.from.time == null) {
        inUsed.regDate.from.time = dayjs().startOf('day').format("HH:mm");
      }
      if (inUsed.regDate.to.date != null && inUsed.regDate.to.time == null) {
        inUsed.regDate.to.time = dayjs().endOf('day').format("HH:mm");
      }
      // 基準日
      if (inUsed.baseDate.from.date == null && inUsed.baseDate.from.time != null) {
        inUsed.baseDate.from.date = dayjs(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.baseDate.to.date == null && inUsed.baseDate.to.time != null) {
        inUsed.baseDate.to.date = dayjs(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.baseDate.from.date != null && inUsed.baseDate.from.time == null) {
        inUsed.baseDate.from.time = dayjs().startOf('day').format("HH:mm");
      }
      if (inUsed.baseDate.to.date != null && inUsed.baseDate.to.time == null) {
        inUsed.baseDate.to.time = dayjs().endOf('day').format("HH:mm");
      }
      //#9489 検索条件の動作が不正 2023-08-30 卓 end

      // #8368対応時のメモ：
      // 現状最大検索数は"0"や""でも検索APIに渡されていて
      // SQL実行時にもゼロとして使用されるため、
      // それに合わせて検索条件として表示する
      // フリーワードも""でも検索APIにそのまま渡されるが、
      // SQL実行時には""であれば無条件と同等になるように使用されているので
      // それに合わせて""の場合は検索条件としては表示しない
      // 日時範囲の項目は日付がある場合のみ日付とともに時刻もAPIに送られ、
      // 時刻のみ入力されてもAPIには送られないので、それに沿った形で表示する
      // 最大検索数
      addCondition("最大検索数", `${inUsed.limit}`);
      // 電文種別
      if (inUsed.coopCd.length > 0) {
        addCondition("電文種別", valuesToString(inUsed.coopCd, COOP_CDS_LIST));
      }
      // 方向
      if (inUsed.direction.length > 0) {
        addCondition("方向", valuesToString(inUsed.direction, DIRECTION_LIST));
      }
      // 変換ステータス
      if (inUsed.anaResult?.length > 0) {
        addCondition("処理結果", valuesToString(inUsed.anaResult, ANA_RESULT_LIST));
      }
      // 通信ステータス
      if (inUsed.coopResult?.length > 0) {
        addCondition("通信結果", valuesToString(inUsed.coopResult, COOP_RESULT_LIST));
      }
      const hasValidDate = (fromToDateTime) => (fromToDateTime.from.date || fromToDateTime.to.date);
      const toDateTimeString = (dateTime) => dateTime.date == null ? "" : `${dateTime.date} ${dateTime.time == null ? "" : dateTime.time}`;
      const toDateTimeSpanString = (fromToDateTime) => `${toDateTimeString(fromToDateTime.from)} ~ ${toDateTimeString(fromToDateTime.to)}`;
      // 処理期間
      if (hasValidDate(inUsed.date)) {
        addCondition("処理期間", toDateTimeSpanString(inUsed.date));
      }
      // 通信期間
      if (hasValidDate(inUsed.regDate)) {
        addCondition("通信期間", toDateTimeSpanString(inUsed.regDate));
      }
      // 基準日
      if (hasValidDate(inUsed.baseDate)) {
        addCondition("基準日", toDateTimeSpanString(inUsed.baseDate));
      }
      // フリーワード
      if (inUsed.content != "") {
        addCondition("フリーワード", inUsed.content);
      }
      this.conditionList = conditionList;
    },

    //「～」の右寄せスタイル適用
    addLineStyle(event) {
      const popover = getOnsPopoverElement(event?.popover || event?.target);
      const lineObj = popover?.getElementsByClassName?.("date-line-chk") || [];
      if (lineObj.length > 1) {
        let objStyle = "";
        if (lineObj[0].offsetTop < lineObj[1].offsetTop) {
          // 折り返しが発生している為、右寄せを解除する
          objStyle = "unset";
        }
        const tildeObj = popover?.getElementsByClassName?.("tilde-text") || [];
        for (const obj of tildeObj) {
          obj.style.textAlign = objStyle;
        }
      }
    }
  },
  created() {
    // add 9583 by kangjie 20240411 start
    this.initCondition();
    // add 9583 by kangjie 20240411 end
    // add 性能改善メモリ不足 shan start
    EventBus.$off("callSearch", this.callSearch);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("callSearch", this.callSearch);
    EventBus.$off("hasChangesUpdated", this.onHasChangesUpdated);
    EventBus.$on("hasChangesUpdated", this.onHasChangesUpdated);

    this.setInitCondition();
  },
  async mounted() {
    this.setLoadingScreenMessage("処理中・・・");
    this.setLoadingScreenVisible(true);

    EventBus.$emit("addLeftmostHeaderMargin");

    // 施設選択リストの選択肢情報の取得と初期選択
    if (this.isMasterUser) {
      // 施設選択が表示される場合は選択肢となる施設リストを取得する
      this.facilityList = await getFacility();
      // facilityListの変更がdropdownlistに反映されてからtoFacilityCdの設定に進む
      await this.$nextTick();
    }
    this.toFacilityCd = this.getToFacilityCd ? this.getToFacilityCd : this.facilityCd;
    this.previousFacilityCd = this.toFacilityCd; // 初期値保持
    await this.callSearch();

    this.setLoadingScreenVisible(false);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    // add 9583 by kangjie 20240403 start 通知一覧の連携エラー通知の遷移不正
    this.clearJumpCoopCondition();
    // add 9583 by kangjie 20240403 end 通知一覧の連携エラー通知の遷移不正
    EventBus.$off("callSearch", this.callSearch);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    EventBus.$off("hasChangesUpdated", this.onHasChangesUpdated);
  }
  // add 性能改善メモリ不足 shan end
  // add 9583 by kangjie 20240411 start cache update ,reflush page
  ,watch: {
    getJumpChangeCoopState: {
        handler(newVal) {
            this.initCondition();
            this.dialogOk();
        },
        deep: true
    }
  }
  // add 9583 by kangjie 20240411 end cache update ,reflush page
};
</script>

<style scoped>
.condition-search-col {
  flex: 0 0 50%;
}
.facility-picker-col {
  flex: 0 0 40%;
}
.facility-picker-col :deep(.facility-picker) {
  border-radius: 10px;
  width: 100%;
  height:calc(100% - 8px);
  margin: 4px 10px;
  font-size: 1.5em;
}
.facility-picker-col :deep(.k-dropdown-wrap) {
  align-items: center;
}

.facility-picker-col :deep(.k-picker),
.facility-picker-col :deep(.k-input-inner) {
  align-items: center;
}
.backgroud-white :deep(.k-dropdown-wrap) {
  border-color: white;
  background-color: white;
}

.backgroud-white :deep(.k-picker),
.backgroud-white :deep(.k-input-inner) {
  border-color: white;
  background-color: white;
}
.isNotInstitution {
  border-radius: 10px;
  width: 100%;
  height: calc(100% - 15px);
  margin: 4px 10px;
  box-shadow: none !important;
}
.mark-leftmost-header {
  overflow: hidden;
}
.external-set-list {
  width: fit-content;
  height: 5.5em;
  overflow-x: auto;
  overflow-y: auto;
  background-color: white;
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
}
.popoverFilterLabel {
  margin-left: -5px;
  margin-right: 7px;
  white-space: nowrap;
}
.m-t {
  margin-top: 2px;
}
ons-popover :deep(.popover--top) {
  max-width: 550px;
  width: 97%;
}

.external-coop-header-popover :deep(.popover--top) {
  max-width: 550px;
  width: 97%;
}
ons-popover :deep(.date-time) {
  margin-bottom: 5px;
}

.external-coop-header-popover :deep(.date-time) {
  margin-bottom: 5px;
}
/* browser-default-font は select のみに限定（col 直下の * に当てるとタグ表示まで変わる） */
.external-coop-header-popover :deep(select.browser-default-font) {
  font-family: "Helvetica Neue", Helvetica, Arial, "Yu Gothic UI", Osaka, Meiryo, "PingFang SC", "Microsoft YaHei UI", "Microsoft YaHei", "Noto Sans CJK SC", sans-serif !important;
}
:global(.ntss-kendo-popup-owner-browser-default-font .k-list-item),
:global(.ntss-kendo-popup-owner-browser-default-font .k-list-item .k-list-item-text) {
  font-family: "Helvetica Neue", Helvetica, Arial, "Yu Gothic UI", Osaka, Meiryo, "PingFang SC", "Microsoft YaHei UI", "Microsoft YaHei", "Noto Sans CJK SC", sans-serif !important;
}

.coop-cd-select :deep(.k-multiselect-wrap) {
  max-height: 114px;
  overflow-y: auto;
}

.coop-cd-select :deep(.k-input-values.k-multiselect-wrap),
.coop-cd-select :deep(.k-input-values) {
  max-height: 114px;
  overflow-y: auto;
}

/* 連携検索ポップ内 MultiSelect: 入力枠は白（選んだ後に表示されるタグの字体は触らない） */
.external-coop-header-popover .external-coop-filter-ms :deep(.k-legacy-multiselect.k-multiselect),
.external-coop-header-popover .external-coop-filter-ms :deep(.k-widget.k-multiselect.k-legacy-multiselect) {
  background-color: #fff !important;
  min-height: 0 !important;
}

/* 検索ポップ内 MultiSelect: theme.css の :before 空行占位を抑え、chip/input を同一 flex 流で折り返す */
.external-coop-header-popover .external-coop-filter-ms :deep(.k-legacy-multiselect > .k-input-values.k-multiselect-wrap::before) {
  content: none !important;
  display: none !important;
  height: 0 !important;
  float: none !important;
}

.external-coop-header-popover .external-coop-filter-ms :deep(.k-input-values.k-multiselect-wrap) {
  display: flex !important;
  flex-wrap: wrap !important;
  align-items: center !important;
  align-content: flex-start !important;
  gap: 0 !important;
  min-height: 0 !important;
  height: auto !important;
}

.external-coop-header-popover .external-coop-filter-ms :deep(.k-chip-list.k-reset),
.external-coop-header-popover .external-coop-filter-ms :deep(.k-selection-multiple.k-reset),
.external-coop-header-popover .external-coop-filter-ms :deep(.k-multiselect-wrap > ul.k-reset) {
  display: contents !important;
}

.external-coop-header-popover .external-coop-filter-ms :deep(.k-chip.k-button),
.external-coop-header-popover .external-coop-filter-ms :deep(.k-multiselect-wrap > ul.k-reset > li.k-button) {
  flex: 0 0 auto !important;
}

.external-coop-header-popover .external-coop-filter-ms :deep(.k-input-inner.k-input),
.external-coop-header-popover .external-coop-filter-ms :deep(input.k-input) {
  flex: 0 1 20px !important;
  width: auto !important;
  min-width: 20px !important;
  max-width: 100% !important;
}

/* 連携検索ポップ内の全 MultiSelect：値（タグ）内の×は常に表示（電文種別含む） */
.external-coop-header-popover .external-coop-filter-ms :deep(.k-chip-remove-action.k-select),
.external-coop-header-popover .external-coop-filter-ms :deep(.k-multiselect-wrap > ul.k-reset > li.k-button > .k-select) {
  opacity: 1 !important;
  pointer-events: auto !important;
  transform: translateY(4px);
}

/* preshow 中（.popover が visibility:hidden）× だけ先に見えるのを防ぐ */
.external-coop-header-popover :deep(.popover[style*="visibility: hidden"] .external-coop-filter-ms .k-clear-value),
.external-coop-header-popover :deep(.popover[style*="visibility: hidden"] .external-coop-filter-ms .k-chip-remove-action) {
  visibility: hidden !important;
  opacity: 0 !important;
  pointer-events: none !important;
}

.external-coop-header-popover .external-coop-filter-ms :deep(.k-chip-remove-action .k-icon::before),
.external-coop-header-popover .external-coop-filter-ms :deep(.k-chip-remove-action .k-svg-icon::before),
.external-coop-header-popover .external-coop-filter-ms :deep(.k-multiselect-wrap > ul.k-reset > li.k-button > .k-select > .k-icon::before) {
  font-size: 22px !important;
  font-weight: normal !important;
  line-height: 1 !important;
}

/* 右端一括クリア（.k-clear-value）：処理結果・通信結果はホバー/フォーカス時のみ表示 */
.external-coop-header-popover .external-coop-filter-ms:not(.external-coop-coopcd-ms) :deep(.k-legacy-multiselect .k-clear-value),
.external-coop-header-popover .external-coop-filter-ms:not(.external-coop-coopcd-ms) :deep(.k-widget.k-multiselect .k-clear-value) {
  opacity: 0 !important;
  pointer-events: none !important;
  transition: opacity 0.12s ease;
}

.external-coop-header-popover .external-coop-filter-ms:not(.external-coop-coopcd-ms) :deep(.k-legacy-multiselect.k-multiselect:hover .k-clear-value),
.external-coop-header-popover .external-coop-filter-ms:not(.external-coop-coopcd-ms) :deep(.k-legacy-multiselect.k-multiselect:focus-within .k-clear-value),
.external-coop-header-popover .external-coop-filter-ms:not(.external-coop-coopcd-ms) :deep(.k-widget.k-multiselect.k-legacy-multiselect:hover .k-clear-value),
.external-coop-header-popover .external-coop-filter-ms:not(.external-coop-coopcd-ms) :deep(.k-widget.k-multiselect.k-legacy-multiselect:focus-within .k-clear-value) {
  opacity: 1 !important;
  pointer-events: auto !important;
}

/* 電文種別：右端一括クリア×もホバー/フォーカス時のみ表示（タグ×と同じ運用） */
.external-coop-header-popover .external-coop-coopcd-ms :deep(.k-legacy-multiselect .k-clear-value),
.external-coop-header-popover .external-coop-coopcd-ms :deep(.k-widget.k-multiselect .k-clear-value) {
  opacity: 0 !important;
  pointer-events: none !important;
  transition: opacity 0.12s ease;
}

.external-coop-header-popover .external-coop-coopcd-ms:hover :deep(.k-legacy-multiselect .k-clear-value),
.external-coop-header-popover .external-coop-coopcd-ms:focus-within :deep(.k-legacy-multiselect .k-clear-value),
.external-coop-header-popover .external-coop-coopcd-ms :deep(.k-legacy-multiselect.k-multiselect:hover .k-clear-value),
.external-coop-header-popover .external-coop-coopcd-ms :deep(.k-legacy-multiselect.k-multiselect:focus-within .k-clear-value),
.external-coop-header-popover .external-coop-coopcd-ms:hover :deep(.k-widget.k-multiselect .k-clear-value),
.external-coop-header-popover .external-coop-coopcd-ms:focus-within :deep(.k-widget.k-multiselect .k-clear-value),
.external-coop-header-popover .external-coop-coopcd-ms :deep(.k-widget.k-multiselect.k-legacy-multiselect:hover .k-clear-value),
.external-coop-header-popover .external-coop-coopcd-ms :deep(.k-widget.k-multiselect.k-legacy-multiselect:focus-within .k-clear-value) {
  opacity: 1 !important;
  pointer-events: auto !important;
}

.external-coop-header-popover .external-coop-filter-ms :deep(.k-clear-value > .k-icon::before),
.external-coop-header-popover .external-coop-filter-ms :deep(.k-clear-value > .k-svg-icon::before),
.external-coop-header-popover .external-coop-filter-ms :deep(.k-clear-value::before) {
  font-size: 22px !important;
  font-weight: normal !important;
  line-height: 1 !important;
}
ons-select :deep(.select-input) {
  padding-left: 4px;
}

ons-input :deep(.text-input) {
  padding-left: 4px;
}
.coopCd-style {
  padding-bottom: 10px;
}
.input-area::-webkit-calendar-picker-indicator {
  display: none;
}
.tilde-text {
  text-align: end;
  padding-right: 1em;
}
:deep(.k-legacy-multiselect > .k-input-values.k-multiselect-wrap),
:deep(.k-legacy-multiselect > .k-multiselect-wrap),
:deep(.k-legacy-multiselect .k-input-values.k-multiselect-wrap) {
  background: #fff !important;
}
@media screen and (max-width: 492px) {
  .w-492 {
    width: 45%;
  }
  .popoverFilterLabel {
    margin-left: 0px;
    margin-right: 0px;
    white-space: nowrap;
  }
}
</style>

<!-- MultiSelect のリストは body 側ポータルになるため global（collectLegacyPopupOwnerClasses で ntss-kendo-popup-owner-external-coop-ms-dropdown が付与される） -->
<style>
/* Kendo テーマが padding-inline に使う変数を潰す */
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown.k-animation-container {
  --kendo-list-md-item-padding-x: 0 !important;
  --kendo-list-sm-item-padding-x: 0 !important;
  --kendo-list-lg-item-padding-x: 0 !important;
}

.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-ul {
  font-family: "Helvetica Neue", Helvetica, Arial, "Yu Gothic UI", Osaka, Meiryo, "PingFang SC", "Microsoft YaHei UI", "Microsoft YaHei", "Noto Sans CJK SC", sans-serif !important;
}

/* 左側の余白を構造ごとゼロに（ポップアップ配下のみ） */
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown.k-animation-container,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-popup,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-container,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-scroller,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-content,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-ul,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown [role="listbox"],
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-child-noderender,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-virtual-content {
  padding-left: 0 !important;
  padding-inline-start: 0 !important;
  margin-left: 0 !important;
  margin-inline-start: 0 !important;
}

.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-content {
  padding: 0 !important;
  margin: 0 !important;
}

/* Kendo theme-core: .k-list:has(.k-list-item-icon) が全行に padding-inline-start を付ける → 左が空く */
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list.k-list-sm:has(.k-list-item-icon) li.k-list-item,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list.k-list-md:has(.k-list-item-icon) li.k-list-item,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list.k-list-lg:has(.k-list-item-icon) li.k-list-item,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list.k-list-sm:has(.k-list-item-icon) .k-list-group-item,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list.k-list-md:has(.k-list-item-icon) .k-list-group-item,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list.k-list-lg:has(.k-list-item-icon) .k-list-group-item {
  padding-inline-start: 0 !important;
}

/* サイズ修飾子付き .k-list-item の横パディングを確実に上書き */
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list.k-list-sm li.k-list-item,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list.k-list-md li.k-list-item,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list.k-list-lg li.k-list-item {
  padding-inline-start: 0 !important;
}

.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-popup {
  border: 1px solid #ced4da;
  border-radius: 2px;
  box-sizing: border-box;
}

.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-ul,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown [role="listbox"] {
  background-color: #fff;
}

/* ドロップダウン行：Kendo の font 一括を html body で上書き（字級はポップ内タグと同じ 0.8125rem） */
html body .ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-item,
html body .ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-item,
html body .ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown [role="option"] {
  box-sizing: border-box;
  font: 400 0.8125rem/1.45 "Helvetica Neue", Helvetica, Arial, "Yu Gothic UI", Osaka, Meiryo, "PingFang SC", "Microsoft YaHei UI", "Microsoft YaHei", "Noto Sans CJK SC", sans-serif !important;
  padding-block: 8px !important;
  padding-inline: 0 12px !important;
  margin: 0 !important;
  margin-inline: 0 !important;
  text-indent: 0 !important;
  gap: 0 !important;
  column-gap: 0 !important;
  row-gap: 0 !important;
  color: #212529 !important;
  background-color: #fff !important;
  border-radius: 0 !important;
}

html body .ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-item .k-list-item-text,
html body .ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-item .k-list-item-text,
html body .ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-item-content,
html body .ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-item-body {
  font: inherit !important;
  color: inherit !important;
  padding: 0 !important;
  padding-left: 0 !important;
  padding-inline-start: 0 !important;
  margin: 0 !important;
  margin-inline-start: 0 !important;
}

.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-item .k-checkbox,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-item .k-checkbox-wrap,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown [role="option"] .k-checkbox,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown [role="option"] .k-checkbox-wrap {
  margin-left: 0 !important;
  margin-inline-start: 0 !important;
  padding-left: 0 !important;
  padding-inline-start: 0 !important;
}

.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-item .k-list-item-icon-wrapper,
.ntss-kendo-multiselect-popup-legacy.ntss-kendo-popup-owner-external-coop-ms-dropdown .k-list-item .k-list-item-icon {
  margin-left: 0 !important;
  margin-inline-start: 0 !important;
  padding-left: 0 !important;
  padding-inline-start: 0 !important;
}

</style>
