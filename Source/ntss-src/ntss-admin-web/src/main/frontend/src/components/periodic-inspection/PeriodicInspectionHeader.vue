<template>
  <v-card>
    <div class="header-item">
      <v-ons-row class="mark-leftmost-header">
        <v-ons-col class="condition-search-col">
          <common-searcharea
            id="periodic-inspection-condition-list"
            :conditionList="conditionList"
            @show-popover="showPopover"
          />
        </v-ons-col>
        <v-ons-col class="state-area">
          <v-ons-button
            class="btn3-normal search-button"
            @click="showCalender"
            :disabled="!hasDevEditAuthority"
          >予定登録</v-ons-button>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      target="#periodic-inspection-condition-list"
      direction="down"
      :cover-target="false"
      :class="[fontSizeSet, 'periodic-inspection-header-popover']"
      style="width: 400px;"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="pop-area">
        <div class="pop-main-area">
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="top" class="pop-title">
              <label>表示期間</label>
            </v-ons-col>
            <v-ons-col vertical-align="top" class="periodic-inspection-date-col">
              <date-input
                id="start-date"
                v-model="localCondition.startDate"
                :classes="'ntss-input-date input-area ntss-custom-input'"
                max="9999-12-31"
                @handleClearInput="localCondition.startDate = ''"
              />
              <common-calendar
                v-model="localCondition.startDate"
                class="calender"
              />
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="top" class="pop-title" />
            <v-ons-col vertical-align="top" class="periodic-inspection-date-col">
              <date-input
                id="end-date"
                v-model="localCondition.endDate"
                :classes="'ntss-input-date input-area ntss-custom-input'"
                max="9999-12-31"
                @handleClearInput="localCondition.endDate = ''"
              />
              <common-calendar
                v-model="localCondition.endDate"
                class="calender"
              />
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="top" class="pop-title">
              <label>型式</label>
            </v-ons-col>
            <v-ons-col
              width="50%"
              vertical-align="top"
              class="periodic-inspection-machine-type-ms"
            >
              <kendo-multiselect
                :data-source="machineInspection"
                :data-text-field="'machineType'"
                :data-value-field="'machineTypeCd'"
                :filter="'contains'"
                v-model="localCondition.machineTypeList"
              />
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col vertical-align="top" class="pop-title">
              <label>ベッドグループ</label>
            </v-ons-col>
            <v-ons-col width="50%" vertical-align="top">
              <v-ons-select input-id="bedGroupCd" v-model="localCondition.bedGroupCd">
                <option
                  v-for="option in bedGroupList"
                  :key="`${option.roomBedGroupCd}`"
                  :value="option.roomBedGroupCd"
                >{{ option.roomBedGroupName }}</option>
              </v-ons-select>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
      <div class="condition-row condition-button-area">
        <div class="clear-button">
          <v-ons-button
            class="btn2-cancel clear"
            @click="dialogClear"
          >クリア</v-ons-button>
        </div>
        <div class="ok-button">
          <v-ons-button
            class="btn3-normal ok"
            @click="dialogOk"
          >OK</v-ons-button>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { sendRequestGetResultByDateSpan } from "@/apis/periodic-inspection";
import { deepCopy } from "@/functions/common/CommonFunctions";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import { InvalidLayoutGroupCd } from "@/constants/mainteConstants";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import PopoverMixin from "@/components/PopoverMixin";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import { PERIODIC_INSPECTION } from "@/constants/defaultSettingConstants";
import { alertByKey } from "@/functions/common/OnsenFunctions";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";
import DateInput from "@/components/common/DateInput";
import { makeDefaultCondition } from "@/functions/PeriodicInspectionFunction";
import { getScopedSessionStorage } from "@/functions/common/LayoutMeasureHelper";

export default {
  mixins: [ComponentGuardMixin, PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
    "date-input": DateInput,
  },
  data() {
    return {
      authorityCds: [AUTHORITY_CODES.DEV_PEDIT, AUTHORITY_CODES.DEV_EDIT],
      hasDevEditAuthority: false,
      bedGroupList: [],
      machineInspection: [],
      localCondition: makeDefaultCondition(),
      popoverVisible: false,
    };
  },
  async created() {
    this.resetReadyToSearchByParamState();
    // 共通ローダー:表示開始
    this.startLoadingScreen();

    this.hasDevEditAuthority = this.hasAuthority();

    const [
      // 型式リストを取得する
      responseMachineTypeList,
      responseBedGroupList,
    ] = await Promise.all([
      ApiHelper.get("mente-main/getMachineTypeList"),
      ApiHelper.get("mente-main/getBedGroupList"),
    ]).catch(error => {
      getErrorMessage("PeriodicInspectionHeader.vue", "created", error);
    });
    this.machineInspection = responseMachineTypeList.data;
    this.bedGroupList = responseBedGroupList.data;
    this.bedGroupList.unshift({
      roomBedGroupCd: null,
      roomBedGroupName: "すべて",
    });
    // add #11285 機能帳票の印刷情報対応② 高 start
    getScopedSessionStorage(this.$el || this).setItem('machineInspection', JSON.stringify(responseMachineTypeList.data));
    getScopedSessionStorage(this.$el || this).setItem('bedGroupList', JSON.stringify(responseBedGroupList.data));
    // add #11285 機能帳票の印刷情報対応② 高 end
    // 検索条件の初期設定を行う前にリストのDOMに反映されるのを待つ
    await this.$nextTick();

    // 検索条件の初期設定
    this.initCondition();

    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);

    EventBus.$on("searchByParam", this.search);
    this.onReadyToSearchByParam();

    // 共通ローダー:表示終了
    this.finishLoadingScreen();
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
  beforeUnmount() {
    EventBus.$off("searchByParam", this.search);
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);

    Object.assign(this.$data, this.$options.data());
  },
  computed: {
    ...mapGetters("periodic-inspection", [
      "getListDataMaster",
      "getSelectedCondition",
    ]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),

    // 共通検索エリア部品に表示するデータのリスト
    conditionList() {
      const conditionList = [];
      const condition = this.getSelectedCondition;
      if (!condition) return conditionList;
      const {
        startDate,
        endDate,
        machineTypeList,
        bedGroupCd,
      } = condition;

      // 表示期間
      if (startDate || endDate) {
        const dateParts = [];
        if (startDate) {
          dateParts.push(startDate);
        }
        dateParts.push("～");
        if (endDate) {
          dateParts.push(endDate);
        }
        conditionList.push({
          name: "表示期間",
          text: dateParts.join("").replace(/-/g, "/"),
        });
      }
      // 型式
      // add #11285 機能帳票の印刷情報対応② 高 start
      this.bedGroupList = JSON.parse(getScopedSessionStorage(this.$el || this).getItem('bedGroupList')) || [];
      this.machineInspection = JSON.parse(getScopedSessionStorage(this.$el || this).getItem('machineInspection')) || [];
      // add #11285 機能帳票の印刷情報対応② 高 end
      const selectedMachine = this.machineInspection.filter(machineInspection => (
        machineTypeList.includes(machineInspection.machineTypeCd)));
      conditionList.push({
        name: "型式",
        text: selectedMachine.length
          ? selectedMachine.map(type => type.machineType).join("、")
          : "すべて",
      });
      // ベッドグループ
      const bedGroupName = bedGroupCd
        ? this.bedGroupList.find(r => r.roomBedGroupCd === bedGroupCd)?.roomBedGroupName
        : "すべて";
      if (bedGroupName != null) {
        conditionList.push({
          name: "ベッドグループ",
          text: bedGroupName,
        });
      }
      // add #11285 機能帳票の印刷情報対応② 高 start
      getScopedSessionStorage(this.$el || this).setItem('bedGroupListPeriodic', JSON.stringify(conditionList.find(item => item.name === "ベッドグループ").text));
      getScopedSessionStorage(this.$el || this).setItem('machineInspectionPeriodic', JSON.stringify(conditionList.find(item => item.name === "型式").text));
      // add #11285 機能帳票の印刷情報対応② 高 end

      return conditionList;
    },
  },
  methods: {
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    ...mapActions("multi-modal", ["showPeriodicCalendar"]),
    ...mapActions("periodic-inspection", [
      "resetReadyToSearchByParamState",
      "onReadyToSearchByParam",
      "setSearchedList",
    ]),
    ...mapMutations("periodic-inspection", [
      "setMachineSelected",
      "setParamsCalendar",
      "setSelectedCondition",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
        // 印刷パラメータを応答
        const { startDate, endDate } = this.getSelectedCondition;
        const dateParam = {
          fromDate: startDate,
          toDate: endDate,
        };
        EventBus.$emit("setDateParams", dateParam);
      }
    },
    showCalender() {
      const listMachineSelect = this.getListDataMaster.filter(
        item => item.machine.selected
      ).map(item => item.machine.machineNo);
      if (!listMachineSelect.length) {
        alertByKey("00200121");
        return;
      }

      this.setParamsCalendar({
        date: dayjs().format("YYYY-MM-DD"),
        layoutGroupCd: InvalidLayoutGroupCd,
        isModify: false,
      });
      this.setMachineSelected(listMachineSelect);
      this.showPeriodicCalendar();
    },
    showPopover() {
      // ポップアップ内の入力内容を現在の検索条件で初期化する
      Object.assign(this.localCondition, deepCopy(this.getSelectedCondition));

      this.popoverVisible = true;
    },
    dialogClear() {
      // デフォルト設定の反映
      this.setDefaultCondition();
    },
    dialogOk() {
      // 吹き出しを閉じる
      this.popoverVisible = false;

      // 検索条件をstore設定
      this.setSelectedCondition(this.localCondition);

      this.search();
    },
    /**
     * @description 検索実行
     */
    async search() {
      if (!this.getSelectedCondition) return;
      this.startLoadingScreen();
      const {
        startDate,
        endDate,
        machineTypeList,
        bedGroupCd,
      } = this.getSelectedCondition;
      const selectedCondition = {
        startDate: this.formattedDate(startDate),
        endDate: this.formattedDate(endDate),
        machineTypeList: this.formattedMachineTypeList(machineTypeList),
        bedGroupCd,
      };
      const [resultRes] = await Promise.all([
        sendRequestGetResultByDateSpan(startDate || "", endDate || ""),
        this.setSearchedList(selectedCondition),
      ]);
      EventBus.$emit("dialogOk", resultRes.data);
      this.finishLoadingScreen();
    },
    formattedDate(date) {
      return date === null || date === ""
        ? null
        : dayjs(date).format("YYYYMMDD");
    },
    formattedMachineTypeList(list) {
      if (!list.length) {
        // 空配列の場合はすべてのリストを返す
        return this.machineInspection.map(item => item.machineTypeCd);
      }
      return list;
    },
    setDefaultCondition() {
      const condition = this.localCondition;
      // システムデフォルト値を設定
      Object.assign(condition, makeDefaultCondition());

      // サインインユーザのデフォルト設定を取得
      const defaults = this.getDefaultSetting[PERIODIC_INSPECTION.KEY_NAME];
      if (!defaults) return;

      // 表示期間・開始日
      const defaultFromDate = defaults[PERIODIC_INSPECTION.KEY_NAME_FROM_DATE];
      if (defaultFromDate != null) {
        condition.startDate = calcTargetDate(defaultFromDate);
      }
      // 表示期間・終了日
      const defaultToDate = defaults[PERIODIC_INSPECTION.KEY_NAME_TO_DATE];
      if (defaultToDate != null) {
        condition.endDate = calcTargetDate(defaultToDate);
      }
      // 型式
      const machineTypeListDefault = defaults[PERIODIC_INSPECTION.KEY_NAME_MACHINE_TYPE_LIST];
      if (machineTypeListDefault != null) {
        const validMachineTypeCds = this.machineInspection.map(m => m.machineTypeCd);
        condition.machineTypeList = machineTypeListDefault.filter(value => validMachineTypeCds.includes(value));
      }
      // ベッドグループ
      const bedGroupCdDefault = defaults[PERIODIC_INSPECTION.KEY_NAME_BED_GROUP_CD];
      if (bedGroupCdDefault !== undefined) {
        if (this.bedGroupList.some(item => +item.roomBedGroupCd === +bedGroupCdDefault)) {
          condition.bedGroupCd = bedGroupCdDefault;
        }
      }
    },
    initCondition() {
      const condition = this.localCondition;
      if (this.getSelectedCondition) {
        // 条件保存済みの場合
        Object.assign(condition, deepCopy(this.getSelectedCondition));
      } else {
        // デフォルト設定の反映
        this.setDefaultCondition();
      }

      if (this.$route.params.fromFacilityCalendar) {
        // 施設カレンダーから日付が渡された場合
        const dayViewMoment = dayjs(this.$route.params.fromFacilityCalendar.date);
        if (dayViewMoment.isValid()) {
          condition.endDate = condition.startDate = dayViewMoment.format("YYYY-MM-DD");
        }
        condition.machineTypeList.splice(0);
        condition.bedGroupCd = null;
      }

      // 検索条件をstore設定
      this.setSelectedCondition(condition);
    },
  },
};
</script>

<style scoped>
.search-button {
  width: auto;
  margin-left: 25px;
  background-image: linear-gradient(
    #b1cbd8 0%,
    #2055cc 30%,
    #3262af 50%,
    #0f77ab 100%
  );
}
.state-area {
  font-size: 1.5em;
  text-align: center;
  display: flex;
  align-items: center;
  height: 100%;
}
#state-area-lable {
  color: white;
}
.pop-area {
  max-height: 380px;
  overflow-y: auto;
  margin: 10px;
}
.pop-title {
  flex: 0 0 40%;
  margin-right: 0.5em;
}
.input-area.ntss-input-date {
  padding-right: 2px;
}

/* 表示期間：日付手入力 + カレンダーボタン（連携検索ポップと同様の横並び） */
.periodic-inspection-header-popover .periodic-inspection-date-col {
  display: flex;
  align-items: center;
  flex-wrap: nowrap;
  gap: 4px;
}
.periodic-inspection-header-popover .periodic-inspection-date-col .date-input {
  flex: 1 1 auto;
  min-width: 0;
  width: auto !important;
}
.periodic-inspection-header-popover .periodic-inspection-date-col .date-input :deep(input[type="date"]) {
  width: 100%;
  box-sizing: border-box;
}
.periodic-inspection-header-popover .periodic-inspection-date-col .input-area::-webkit-calendar-picker-indicator {
  display: none;
  -webkit-appearance: none;
}
.periodic-inspection-header-popover .periodic-inspection-date-col .ntss-custom-calendar-host {
  flex: 0 0 auto;
}
.periodic-inspection-header-popover .periodic-inspection-date-col :deep(.dp__main) {
  width: auto !important;
}
.condition-button-area {
  height: 30px;
  margin: 10px;
  text-align: center;
  background-image: none;
}
.clear-button {
  float: left;
}
.ok-button {
  float: right;
}
ons-popover {
  width: 450px;
}

.periodic-inspection-header-popover {
  width: 450px;
}
ons-popover :deep(.date-time) {
  margin-bottom: 3px;
}

.periodic-inspection-header-popover :deep(.date-time) {
  margin-bottom: 3px;
}
.condition-search-col {
  flex: 0 0 55%;
}
@media screen and (max-width: 420px) {
  .condition-search-col {
    flex: 0 0 40%;
  }
}
@media screen and (max-height: 400px) {
  .pop-area {
    max-height: 60vh;
  }
}

/* 型式 MultiSelect：入力枠は白、タグ内×は常時、右端一括クリア×はホバー/フォーカス時のみ */
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-legacy-multiselect.k-multiselect),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-widget.k-multiselect.k-legacy-multiselect) {
  background-color: #fff !important;
}

.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-chip-remove-action.k-select),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-multiselect-wrap > ul.k-reset > li.k-button > .k-select) {
  opacity: 1 !important;
  pointer-events: auto !important;
}

.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-legacy-multiselect .k-clear-value),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-widget.k-multiselect .k-clear-value) {
  opacity: 0 !important;
  pointer-events: none !important;
  transition: opacity 0.12s ease;
}

.periodic-inspection-header-popover .periodic-inspection-machine-type-ms:hover :deep(.k-legacy-multiselect .k-clear-value),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms:focus-within :deep(.k-legacy-multiselect .k-clear-value),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-legacy-multiselect.k-multiselect:hover .k-clear-value),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-legacy-multiselect.k-multiselect:focus-within .k-clear-value),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms:hover :deep(.k-widget.k-multiselect .k-clear-value),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms:focus-within :deep(.k-widget.k-multiselect .k-clear-value),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-widget.k-multiselect.k-legacy-multiselect:hover .k-clear-value),
.periodic-inspection-header-popover .periodic-inspection-machine-type-ms :deep(.k-widget.k-multiselect.k-legacy-multiselect:focus-within .k-clear-value) {
  opacity: 1 !important;
  pointer-events: auto !important;
}
</style>
