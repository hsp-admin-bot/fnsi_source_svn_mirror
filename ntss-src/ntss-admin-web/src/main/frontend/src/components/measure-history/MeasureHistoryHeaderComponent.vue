/**
 * 体重測定履歴ページ用ヘッダ
 */
<template>
  <v-card>
    <div class="header-item" :class="{ 'weight-mode-header-content': isWeightMode }">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'measure-history-header-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div style="margin:10px;">
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>測定日</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <div class="flex-align-center">
              <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
              <!-- <input
                class="ntss-input-date w-100 ntss-control-size"
                id="measureDate"
                type="date"
                v-model="editingCondition.measureDate"
                @keydown="onTimeKeyDown($event)"
              /> -->
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
              <!-- <input
                class="ntss-input-date w-100 ntss-control-size"
                id="measureDate"
                type="date"
                max="9999-12-31"
                v-rules="'date_format:yyyy-MM-dd'"
                v-model="editingCondition.measureDate"
                @keydown="onTimeKeyDown($event)"
                @keyup="showMsg()"
              /> -->
              <date-input
                class="ntss-input-date w-100 ntss-control-size"
                id="measureDate"
                v-model="editingCondition.measureDate"
                @handleClearInput="editingCondition.measureDate = null"
                @keyup="showMsg()"
              />
              <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
              <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
              <common-calendar v-model="editingCondition.measureDate" />
            </div>
          </v-ons-col>
        </v-ons-row>
        <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
        <v-ons-row class="condition-row" v-if="showError">
          <span class="error-message">{{ this.msgDiaLog }}</span>
        </v-ons-row>
        <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>クール</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select input-id="kurCd" v-model="editingCondition.kurCd">
              <option value="-1">すべて</option>
              <option
                v-for="option in getMstKurSelector"
                :key="option.length"
                :value="option.code"
              >{{ option.name }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>ベッドグループ</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select input-id="bedGroupCd" v-model="editingCondition.bedGroupCd">
              <option :value="defaultSelect">すべて</option>
              <option
                v-for="(option) in getMstBedGroupList"
                :key="option.length"
                :value="option.roomBedGroupCd"
              >{{ option.roomBedGroupName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>フリーワード</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-input input-id="freeWord" type="text" float v-model="editingCondition.freeWord"></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="center">
            <label>条件送信結果</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="center">
            <v-ons-select input-id="weightScaleStatus" v-model="editingCondition.weightScaleStatus">
              <option value="-1">すべて</option>
              <option
                id="selectctlno"
                v-for="option in getWeightScaleStatusList"
                :key="option.length"
                :value="option.no"
              >{{ option.statusName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row" style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <v-ons-button class="clear btn2-cancel" @click="dialogClear">クリア</v-ons-button>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </div>
          <div style="float:right;">
            <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
            <!-- <v-ons-button class="ok" @click="dialogOk">OK</v-ons-button> -->
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <v-ons-button class="ok btn3-normal" :disabled="showError" @click="dialogOk">OK</v-ons-button>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
            <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";
import { KEY_NAME_MEASURE_HISTORY } from "@/constants/defaultSettingConstants";
// add FNSI-横展開 日付のチェックの追加 徐 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-横展開 日付のチェックの追加 徐 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
//#5590 2023/04/20 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
import { getScopedElementById, getScopedSessionStorage } from "@/functions/common/LayoutMeasureHelper";
//#5590 2023/04/20 ×を常に表示するように修正 張博 end

export default {
  mixins: [PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      // add FNSI-横展開 日付のチェックの追加 徐 start
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showError: false,
      // add FNSI-横展開 日付のチェックの追加 徐 end
      // 条件送信結果一覧
      statuslist: [
        { no: -1, statusName: "すべて" },
        { no: 0, statusName: "測定済み" },
        { no: 1, statusName: "条件送信指示中" },
        { no: 2, statusName: "待機" },
        { no: 3, statusName: "条件送信成功" },
        { no: 4, statusName: "条件送信失敗" }
      ],
      condition: {
        measureDate: "",
        clearflag: false,
        kurCd: -1,
        bedGroupCd: -1,
        freeWord: "",
        weightScaleStatus: -1
      },
      editingCondition: {
        measureDate: "",
        clearflag: false,
        kurCd: -1,
        bedGroupCd: -1,
        freeWord: "",
        weightScaleStatus: -1
      },
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("measure-history/list", [
      "getMstKurSelector",
      "getMstBedGroupList",
      "getWeightScaleStatusList",
      "getCondition"
    ]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    ...mapGetters("send-condition/weight", [
      "getWeightMode"
    ]),
    defaultSelect: () => 0,
    /**
     * 体重計モードかどうかを返却します
     * getWeightModeが存在し、かつisWeightModeがtrueならtrueを返却
     * (!!によって結果を厳密なboolean型に変換して返却)
     */
    isWeightMode() {
      return !!(this.getWeightMode && this.getWeightMode.isWeightMode);
    },
  },
  methods: {
    ...mapActions("measure-history/list", [
      "fetchKurBedGroup",
      "conditionSet",
      "setFilterSignal"
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    findKurSelectorByCode(kurCd) {
      return (this.getMstKurSelector || []).find(
        selector => `${selector.code}` === `${kurCd}`
      );
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.editingCondition = deepCopy(this.condition);
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      // add FNSI-横展開 日付のチェックの追加 徐 start
      this.showError = false;
      const measureDateElement = getScopedElementById("measureDate", this.$el || this);
      if (measureDateElement) {
        measureDateElement.value = "";
      }
      // add FNSI-横展開 日付のチェックの追加 徐 end
      this.condition.measureDate = "";
      this.condition.clearflag = true;
      this.condition.kurCd = -1;
      this.condition.bedGroupCd = -1;
      this.condition.freeWord = "";
      this.condition.weightScaleStatus = -1;
      this.editingCondition = deepCopy(this.condition);
      // 抽出条件セット
      this.conditionSet(deepCopy(this.condition));
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      // 画面を閉じる
      this.popoverVisible = false;
      // 抽出条件セット
      this.condition = deepCopy(this.editingCondition);
      this.condition.clearflag = false;
      this.conditionSet(deepCopy(this.condition));
      this.search();
    },
    // add FNSI-横展開 日付のチェックの追加 徐 start
    showMsg() {
      const measureDateElement = getScopedElementById("measureDate", this.$el || this);
      if (this.editingCondition.measureDate && measureDateElement?.validationMessage) {
        this.showError = true;
      } else {
        this.showError = false;
      }
    },
    // add FNSI-横展開 日付のチェックの追加 徐 end
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      // 検索条件の内容で画面を更新
      this.setFilterSignal(true).then(() => {
        EventBus.$emit("filterMeasureHistoryList", deepCopy(this.condition));
      });
      this.setConditionList();
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.condition;
      // 測定日
      if (condObj.measureDate != "" && condObj.measureDate != null) {
        condList.push({ name:"測定日", text:condObj.measureDate.replace(/-/g, "/") });
      }
      // クール
      if (`${condObj.kurCd}` !== "-1") {
        const kur = this.findKurSelectorByCode(condObj.kurCd);
        if (kur) {
          condList.push({ name:"クール", text: kur.name });
        } else {
          condList.push({ name:"クール", text: "すべて" });
          this.condition.kurCd = -1;  // NOTE: クールマスタに存在しないコードだった場合、デフォルト値を設定
        }
      }
      // add FNSI-redmine4254、4282 徐 start
      else if (condObj.kurCd == -1) {
        condList.push({ name:"クール", text:"すべて" });
      }
      // add FNSI-redmine4254、4282 徐 end

      // ベッドグループ
      if (condObj.bedGroupCd !== 0) {
        const bedGroup = this.getMstBedGroupList.find(bg => bg.roomBedGroupCd === condObj.bedGroupCd);
        if(bedGroup) {
          condList.push({ name:"ベッドグループ", text:bedGroup.roomBedGroupName });
        }
        else {
          condList.push({ name:"ベッドグループ", text:"すべて" });
          this.condition.bedGroupCd = 0;
        }
      }
      // add FNSI-redmine4254、4282 徐 start
      else if (condObj.bedGroupCd === 0) {
        condList.push({ name:"ベッドグループ", text:"すべて" });
      }
      // add FNSI-redmine4254、4282 徐 end
      // フリーワード
      if (condObj.freeWord != "") {
        condList.push({ name:"フリーワード", text:condObj.freeWord });
      }
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
      const scopedSessionStorage = getScopedSessionStorage(this.$el);
      scopedSessionStorage.setItem('roomBedGroupNameStatusList', JSON.stringify(condList.find(item => item.name === "ベッドグループ").text));
      scopedSessionStorage.setItem('kurGroupNameStatusList', JSON.stringify(condList.find(item => item.name === "クール").text));
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
      // 条件送信結果
      if (condObj.weightScaleStatus > -1) {
        condList.push({ name:"条件送信結果", text:this.getWeightScaleStatusList[condObj.weightScaleStatus].statusName });
      }
      // add FNSI-redmine4254、4282 徐 start
      else if (condObj.weightScaleStatus == -1) {
        condList.push({ name:"条件送信結果", text:"すべて" });
      }
      // add FNSI-redmine4254、4282 徐 end
      this.conditionList = condList;
    }
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  async created() {
    // クール一覧情報取得
    // ベッドグループ情報取得
    await this.fetchKurBedGroup();
    this.condition = this.getCondition;
    // 初回は kurCd、bedGroupCd、freeWord、weightScaleStatus が存在しない
    if (typeof this.condition.kurCd === "undefined") {
      // 初期値を設定する
      this.condition.kurCd = -1;
      this.condition.bedGroupCd = -1;
      this.condition.freeWord = "";
      this.condition.weightScaleStatus = -1;
      // デフォルト設定がある場合は適用
      const defaultCondition = deepCopy(this.getDefaultSetting[KEY_NAME_MEASURE_HISTORY.KEY_NAME]);
      if (!(!defaultCondition || Object.keys(defaultCondition).length === 0)) {
        if (defaultCondition[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD] !== null) {
          this.condition.kurCd = defaultCondition[KEY_NAME_MEASURE_HISTORY.KEY_NAME_KUR_CD];
        }
        if (defaultCondition[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD] !== null) {
          this.condition.bedGroupCd = defaultCondition[KEY_NAME_MEASURE_HISTORY.KEY_NAME_BED_GROUP_CD];
        }
        if (defaultCondition[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD] !== null) {
          this.condition.freeWord = defaultCondition[KEY_NAME_MEASURE_HISTORY.KEY_NAME_FREEWORD];
        }
        if (defaultCondition[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS] !== null) {
          this.condition.weightScaleStatus = defaultCondition[KEY_NAME_MEASURE_HISTORY.KEY_NAME_WEIGHT_SCALE_STATUS];
        }
      }

      // 画面遷移パラメータ取得
      const queryParameters = this.getQueryParameters();

      if (queryParameters.DATE) {
        // 表示項目
        this.condition.measureDate = queryParameters.DATE;
      }

      if (!this.isWeightMode) {
        // 体重計モード以外の時、パラメータを初期化
        this.setQueryParameters({});
      }
    }
    this.conditionSet(deepCopy(this.condition));
    // 設定を適用
    this.setConditionList();
    EventBus.$emit("filterMeasureHistoryList", deepCopy(this.condition));
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
};
</script>
<style scoped>
ons-popover :deep(.popover) {
  min-width: 380px;
}

.measure-history-header-popover :deep(.popover) {
  min-width: 380px;
}
</style>
