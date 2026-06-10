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
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="fontSizeSet"
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
          <v-ons-col vertical-align="center" class="coop-cd-select">
            <kendo-multiselect
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
          <v-ons-col vertical-align="center">
            <kendo-multiselect
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
          <v-ons-col vertical-align="center">
            <kendo-multiselect
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
              class="ntss-input-date input-area ntss-custom-input"
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
import moment from "moment";
import { EventBus } from "@/eventBus.js";
import { mapGetters, mapActions, mapMutations } from "vuex";
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
      if (jumpChangeCoopState.baseDate || jumpChangeCoopState.ctlNo || jumpChangeCoopState.ordNo || jumpChangeCoopState.coopCd ){
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
        ? `${moment(fromDate).format("YYYY/MM/DD")} ${startTime}`
        : null;
      const endDateTime = toDate
        ? `${moment(toDate).format("YYYY/MM/DD")} ${endTime}`
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
          return "透析注射連携";
        case "pre_ord":
          return "処方情報連携";
        case "staff_mst":
          return "スタッフマスタ連携";
        case "vit_cop":
          return "バイタル連携";
        case "karte_ord":
          return "カルテ記載連携";
        default:
          return "";
      }
    },
    showPopover(event) {
      this.condition.inProgress = deepCopy(this.condition.inUsed);
      this.popoverTarget = event;
      this.popoverVisible = true;
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
            const widget = this.$refs.dropdown.kendoWidget();
            if (widget) {
              widget.value(this.previousFacilityCd);
            }
          });
          return;
        }
      }
      // add NKK権限のユーザーでログインして、【連携】画面、施設プルダウン変換する時、施設コードはログインユーザーの施設コードで変わらない xugj zhaoqi start
      let fac = event.sender._old;
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

      const inUsed = this.condition.inUsed;
      const toDateTimeParameter = (dateTime, defaultTime) => dateTime.date
        ? `${moment(dateTime.date).format("YYYY/MM/DD")} ${dateTime.time ? dateTime.time : defaultTime}`
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
      EventBus.$emit("generateDataSource");

      this.setLoadingScreenVisible(false);
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
        inUsed.date.from.date = moment(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.date.to.date == null && inUsed.date.to.time != null) {
        inUsed.date.to.date = moment(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.date.from.date != null && inUsed.date.from.time == null) {
        inUsed.date.from.time = moment().startOf('day').format("HH:mm");
      }
      if (inUsed.date.to.date != null && inUsed.date.to.time == null) {
        inUsed.date.to.time = moment().endOf('day').format("HH:mm");
      }
      // 通信期間
      if (inUsed.regDate.from.date == null && inUsed.regDate.from.time != null) {
        inUsed.regDate.from.date = moment(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.regDate.to.date == null && inUsed.regDate.to.time != null) {
        inUsed.regDate.to.date = moment(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.regDate.from.date != null && inUsed.regDate.from.time == null) {
        inUsed.regDate.from.time = moment().startOf('day').format("HH:mm");
      }
      if (inUsed.regDate.to.date != null && inUsed.regDate.to.time == null) {
        inUsed.regDate.to.time = moment().endOf('day').format("HH:mm");
      }
      // 基準日
      if (inUsed.baseDate.from.date == null && inUsed.baseDate.from.time != null) {
        inUsed.baseDate.from.date = moment(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.baseDate.to.date == null && inUsed.baseDate.to.time != null) {
        inUsed.baseDate.to.date = moment(new Date()).format("YYYY/MM/DD");
      }
      if (inUsed.baseDate.from.date != null && inUsed.baseDate.from.time == null) {
        inUsed.baseDate.from.time = moment().startOf('day').format("HH:mm");
      }
      if (inUsed.baseDate.to.date != null && inUsed.baseDate.to.time == null) {
        inUsed.baseDate.to.time = moment().endOf('day').format("HH:mm");
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
      const lineObj = event.popover.getElementsByClassName("date-line-chk");
      if (lineObj.length > 1) {
        let objStyle = "";
        if (lineObj[0].offsetTop < lineObj[1].offsetTop) {
          // 折り返しが発生している為、右寄せを解除する
          objStyle = "unset";
        }
        const tildeObj = event.popover.getElementsByClassName("tilde-text");
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
    EventBus.$off("hasChangesUpdated");
    EventBus.$on("hasChangesUpdated", (value) => this.hasChangesFromMain = value);

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
  beforeDestroy() {
    // add 9583 by kangjie 20240403 start 通知一覧の連携エラー通知の遷移不正
    this.clearJumpCoopCondition();
    // add 9583 by kangjie 20240403 end 通知一覧の連携エラー通知の遷移不正
    EventBus.$off("callSearch", this.callSearch);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    EventBus.$off("hasChangesUpdated");
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
  flex: 0 0 50%
}
.facility-picker-col {
  flex: 0 0 40%
}
.facility-picker-col >>> .facility-picker {
  border-radius: 10px;
  width: 100%;
  height:calc(100% - 8px);
  margin: 4px 10px;
  font-size: 1.5em;
}
.facility-picker-col >>> .k-dropdown-wrap {
  align-items: center;
}
.backgroud-white >>> .k-dropdown-wrap {
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
ons-popover >>> .popover--top {
  max-width: 550px;
  width: 97%;
}
ons-popover >>> .date-time {
  margin-bottom: 5px;
}
.coop-cd-select >>> .k-multiselect-wrap {
  max-height: 114px;
  overflow-y: auto;
}
ons-input >>> .text-input,
ons-select >>> .select-input {
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
