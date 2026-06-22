<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col vertical-align="center">
          <div class="ntss-button-group">
            <date-input
              id="input-search-date"
              v-model="dateInspection"
              isRequired
              class="ntss-custom-input input-time hide-arrow-calendar"
              @blur="applyDateInspection"
            />
            <common-calendar
              v-model="dateInspection"
              :disableDatesAfter="todayStr"
              @update:model-value="applyDateInspection"
              @todayButtonClick="applyDateInspection"
            />
            <span class="label">{{ dateString }}の日常点検</span>
          </div>
        </v-ons-col>
        <v-ons-col class="condition-search-col">
          <common-searcharea
            id="daily-inspection-condition-list"
            :conditionList="conditionList"
            @show-popover="showPopoverAdd"
          />
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisibleAdd"
      target="#daily-inspection-condition-list"
      direction="down"
      :cover-target="false"
      :class="[fontSizeSet, 'daily-inspection-popover']"
      style="width: auto;"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="pop-area">
        <div class="pop-main-area">
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>ベッドグループ</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-select input-id="bedGroupCd" v-model="localCondition.bedGroupCd">
                <option
                  v-for="option in bedGroupList"
                  :key="`${option.roomBedGroupCd}`"
                  :value="option.roomBedGroupCd"
                >{{ option.roomBedGroupName }}</option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row" style="flex-wrap: nowrap;">
            <v-ons-col width="40%" vertical-align="center" class="pop-title">
              <label>型式</label>
            </v-ons-col>
            <v-ons-col width="60%" vertical-align="center" class="daily-machine-type-select">
              <kendo-multiselect
                :data-source="getMachineTypeList"
                data-text-field="machineType"
                data-value-field="machineTypeCd"
                filter="contains"
                placeholder="すべて"
                v-model="localCondition.machineTypeList"
              />
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>未実施</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-switch v-model="localCondition.isNon"/>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>点検途中</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-switch v-model="localCondition.isUnfinished"/>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>不合格</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-switch v-model="localCondition.isUnpass"/>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>全件合格</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-switch v-model="localCondition.isPass"/>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center" class="pop-title">
              <label>フリーワード</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-input
                input-id="keyword"
                type="text"
                v-model="localCondition.keyword"
              />
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
      <div class="condition-row condition-button-area">
        <div class="clear-button">
          <v-ons-button
            class="btn2-cancel common-style-cancel-button"
            @click="dialogClear"
          >クリア</v-ons-button>
        </div>
        <div class="ok-button">
          <v-ons-button
            class="btn3-normal common-style-ok-button"
            @click="dialogOkAdd"
          >OK</v-ons-button>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import PopoverMixin from "@/components/PopoverMixin";
import { ApiHelper } from "@/apis/AxiosHelper";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { alertByKey } from "@/functions/common/OnsenFunctions";
import commonSearchArea from "@/components/common/CommonSearchArea";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import { DAILY_CHECK } from "@/constants/defaultSettingConstants";
import DateInput from "@/components/common/DateInput";

const DefaultCondition = Object.freeze({
  bedGroupCd: null,
  machineTypeList: [],
  isNon: true,
  isUnfinished: true,
  isUnpass: true,
  isPass: true,
  keyword: "",
});

export default {
  mixins: [PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    "date-input": DateInput,
  },
  name: "DailyInspectionHeaderComponent",
  data() {
    return {
      dateInspection: "",
      popoverVisibleAdd: false,
      localCondition: deepCopy(DefaultCondition),
      bedGroupList: [],
    };
  },
  computed: {
    ...mapGetters("daily-check", [
      "getDailyDateSearch",
      "getCondition",
    ]),
    ...mapGetters("mst-layout", ["getMachineTypeList"]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),

    dateString() {
      return dayjs(this.getDailyDateSearch).format("(dd)");
    },
    /**
     * カスタムカレンダーの入力制限のための本日の日付文字列
     */
    todayStr() {
      return dayjs().format("YYYYMMDD");
    },
    // 共通検索エリア部品に表示するデータのリスト
    conditionList() {
      const conditionList = [];
      const condition = this.getCondition;
      if (!condition) return conditionList;
      const {
        bedGroupCd,
        machineTypeList,
        isNon,
        isUnfinished,
        isUnpass,
        isPass,
        keyword,
      } = condition;

      conditionList.push({
        name: "ベッドグループ",
        text: bedGroupCd != null
          ? this.getRoomBedGroupName(bedGroupCd)
          : "すべて",
      });
      conditionList.push({
        name: "型式",
        text: machineTypeList.length
          ? machineTypeList.map(cd => this.getMachineType(cd)).join("、")
          : "すべて",
      });
      if (isNon) {
        conditionList.push({ text: "未実施" });
      }
      if (isUnfinished) {
        conditionList.push({ text: "点検途中" });
      }
      if (isUnpass) {
        conditionList.push({ text: "不合格" });
      }
      if (isPass) {
        conditionList.push({ text: "全件合格" });
      }
      if (keyword) {
        conditionList.push({
          name: "フリーワード",
          text: keyword,
        });
      }

      return conditionList;
    },
  },
  watch: {
    conditionList() {
      this.setConditionForReportParams({
        bedCdListString: this.getConditionText("ベッドグループ"),
        machineTypeName: this.getConditionText("型式"),
      });
    },
  },
  methods: {
    ...mapActions("daily-check", [
      "setDailyDateSearch",
      "setCondition",
      "setConditionForReportParams",
    ]),
    ...mapActions("mst-layout", ["sendRequestGetMachineTypeList"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    showPopoverAdd() {
      // ポップアップ内の入力内容を現在の検索条件で初期化する
      Object.assign(this.localCondition, deepCopy(this.getCondition));

      this.popoverVisibleAdd = true;
    },
    applyDateInspection(nextDate) {
      if (typeof nextDate === "string" && nextDate) {
        this.dateInspection = nextDate;
      }
      // 日付未入力の場合は処理しない
      if (!this.dateInspection) return;

      const today = dayjs().format("YYYY-MM-DD");
      if (this.dateInspection > today) {
        // 未来日の場合はシステム日付に補正する
        this.dateInspection = today;

        // title: "チェックエラー",
        // message: "点検日に未来日を指定することはできません。"
        alertByKey("00200006");
      }

      // 直前の再検索時から日付が変化していない場合は再検索しない
      if (this.dateInspection === this.getDailyDateSearch) return;

      // 点検日を保存
      this.setDailyDateSearch(this.dateInspection);
      // 点検日を変更した際のログを残す
      this.logEventFun(this.getDailyDateSearch);
      // 再検索を行う
      this.search();
    },
    search() {
      // 日付未入力の場合は処理しない
      if (!this.getDailyDateSearch) return;

      EventBus.$emit("filterDailyCheckList");
    },
    getRoomBedGroupName(cd) {
      const findItem = this.bedGroupList.find(r => r.roomBedGroupCd === cd);
      return !findItem ? "" : findItem.roomBedGroupName;
    },
    getMachineType(cd) {
      const findItem = this.getMachineTypeList.find(r => r.machineTypeCd === cd);
      return !findItem ? "" : findItem.machineType;
    },
    getConditionText(name) {
      return this.conditionList.find(item => item.name === name)?.text || "";
    },
    dialogClear() {
      // デフォルト設定の反映
      this.setDefaultCondition();
      // 画面を閉じて検索を実行
      this.dialogOkAdd();
    },
    dialogOkAdd() {
      this.popoverVisibleAdd = false;

      // 検索条件登録
      this.setCondition(this.localCondition);

      // 検索条件を決定した際のログを残す
      const messages = this.conditionList.map(({ text }) => text);
      this.logEventFun(...messages);

      // 検索条件の内容で画面を更新
      EventBus.$emit("dialogOkAdd");
    },
    logEventFun(...messages) {
      const conditionMessage = messages.filter(message => message).join("、");
      if (conditionMessage) {
        const param = {
          message: `日常点検が[${conditionMessage}]で検索しました。`,
          functionName: "日常点検",
        };
        ApiHelper.put("/logs/event/conditionlog", param).catch(error => {
          getErrorMessage("DailyInspectionHeaderComponent.vue", "logEventFun", error);
        });
      }
    },
    setDefaultCondition() {
      const condition = this.localCondition;
      // システムデフォルト値を設定
      Object.assign(condition, deepCopy(DefaultCondition));

      // サインインユーザのデフォルト設定を取得
      const defaults = this.getDefaultSetting[DAILY_CHECK.KEY_NAME];
      if (!defaults) return;

      // デフォルト設定の反映
      // ベッドグループ
      const bedGroupCdDefault = defaults[DAILY_CHECK.KEY_NAME_BED_GROUP_CD];
      if (bedGroupCdDefault !== undefined) {
        if (this.bedGroupList.some(item => +item.roomBedGroupCd === +bedGroupCdDefault)) {
          condition.bedGroupCd = bedGroupCdDefault;
        }
      }
      // 型式
      const machineTypeListDefault = defaults[DAILY_CHECK.KEY_NAME_MACHINE_TYPE_LIST];
      if (machineTypeListDefault != null) {
        const validMachineTypeCds = this.getMachineTypeList.map(machineType => machineType.machineTypeCd);
        condition.machineTypeList = machineTypeListDefault.filter(value => validMachineTypeCds.includes(value));
      }
      // フリーワード
      const keywordDefault = defaults[DAILY_CHECK.KEY_NAME_KEYWORD];
      if (keywordDefault != null) {
        condition.keyword = keywordDefault;
      }
      // 未実施
      const isNonDefault = defaults[DAILY_CHECK.KEY_NAME_IS_NON];
      if (isNonDefault != null) {
        condition.isNon = isNonDefault;
      }
      // 点検途中
      const isUnfinishedDefault = defaults[DAILY_CHECK.KEY_NAME_IS_FAIL];
      if (isUnfinishedDefault != null) {
        condition.isUnfinished = isUnfinishedDefault;
      }
      // 不合格
      const isUnpassDefault = defaults[DAILY_CHECK.KEY_NAME_IS_UNPASS];
      if (isUnpassDefault != null) {
        condition.isUnpass = isUnpassDefault;
      }
      // 全件合格
      const isPassDefault = defaults[DAILY_CHECK.KEY_NAME_IS_PASS];
      if (isPassDefault != null) {
        condition.isPass = isPassDefault;
      }
    },
    initCondition() {
      const condition = this.localCondition;
      if (this.getCondition) {
        // 条件保存済みの場合
        Object.assign(condition, deepCopy(this.getCondition));
      } else {
        // デフォルト設定の反映
        this.setDefaultCondition();
      }

      // 点検日の入力値を初期化（初期化結果の入力値で初期検索のsearchが実行される）
      this.dateInspection = this.getDailyDateSearch;
      if (this.$route.params.fromFacilityCalendar) {
        // 施設カレンダーから日付が渡された場合
        const dayViewMoment = dayjs(this.$route.params.fromFacilityCalendar.date);
        if (dayViewMoment.isValid()) {
          this.dateInspection = dayViewMoment.format("YYYY-MM-DD");
        }
        condition.bedGroupCd = null;
        condition.machineTypeList = [];
        condition.keyword = "";
      }

      this.setDailyDateSearch(this.dateInspection);
      this.setCondition(condition);
    },
  },
  async created() {
    // 共通ローダー:表示開始
    this.startLoadingScreen();

    // マスタデータを取得
    const [responseBedGroupList] = await Promise.all([
      ApiHelper.get("mente-main/getBedGroupList"),
      this.sendRequestGetMachineTypeList(),
    ]).catch(error => {
      getErrorMessage("DailyInspectionHeaderComponent.vue", "created", error);
    });
    this.bedGroupList = responseBedGroupList.data;
    this.bedGroupList.unshift({
      roomBedGroupCd: null,
      roomBedGroupName: "すべて",
    });
    // 検索条件の初期設定を行う前にリストのDOMに反映されるのを待つ
    await this.$nextTick();

    // 検索条件の初期設定
    this.initCondition();

    // 画面開始時の検索を実行する
    // #10972対応時のメモ：
    // ここに到達するまでのAPI呼び出しをawaitしている間に
    // DailyInspectionListConponent側のcreatedの
    // EventBus.$on("filterDailyCheckList", this.applyConditionList)
    // が実行されているためすでに検索処理が実行可能な状態になっている
    this.search();

    // 共通ローダー:表示終了
    this.finishLoadingScreen();
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
  beforeUnmount() {
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.mark-leftmost-header {
  padding-left: 4px;
}
input[type="radio"] {
  display: none;
}
.ntss-button-group {
  width: 100%;
  font-size: 1.5em;
  display: inline-flex;
  align-items: center;
}
.label {
  width: 25%;
  height: 1.5rem;
  padding-left: 10px;
  padding-right: 5px;
  color: white;
  text-align: center;
  line-height: 1.5rem;
  margin: 15px 0px;
  white-space: nowrap;
  font-size: 1.5rem;
}
.first-of-type {
  border-radius: 10px 0 0 10px;
  margin-left: 5px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
  margin-right: 5px;
}
.input-time {
  width: -webkit-fill-available;
  font-size: 1em;
}
#popover {
  margin: 5px 10px 5px 10px;
  position: relative;
}
.hide-arrow-calendar {
  width: 110px;
}
.hide-arrow-calendar::-webkit-inner-spin-button,
.hide-arrow-calendar::-webkit-calendar-picker-indicator {
  display: none;
  -webkit-appearance: none;
}
.custom-ons-popover :deep(.popover-mask) {
  z-index: 3;
}
.custom-ons-popover :deep(.popover.popover--top) {
  z-index: 4;
  min-width: 400px;
}
.pop-title {
  flex: 0 0 40%;
}
.clear-button {
  float: left;
}
.condition-button-area {
  height: 30px;
  margin: 10px;
  text-align: center;
  background-image: none;
}
.ok-button {
  float: right;
}
.pop-area {
  margin: 10px;
}
.daily-inspection-popover :deep(.popover) {
  max-width: 380px;
}
.daily-machine-type-select :deep(.k-multiselect-wrap) {
  max-height: 10em;
  overflow-y: auto;
}

.daily-machine-type-select :deep(.k-input-values.k-multiselect-wrap),
.daily-machine-type-select :deep(.k-input-values) {
  max-height: 10em;
  overflow-y: auto;
}
@media screen and (max-width: 1280px) {
  .hide-arrow-calendar {
    min-width: 110px;
  }
}
</style>
