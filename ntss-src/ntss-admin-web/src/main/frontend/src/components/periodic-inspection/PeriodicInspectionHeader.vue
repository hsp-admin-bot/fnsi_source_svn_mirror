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
      :visible.sync="popoverVisible"
      target="#periodic-inspection-condition-list"
      direction="down"
      :cover-target="false"
      :class="fontSizeSet"
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
            <v-ons-col vertical-align="top">
              <date-input
                id="start-date"
                v-model="localCondition.startDate"
                :classes="'input-area ntss-input-date ntss-custom-input'"
                style="width: 75%;"
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
            <v-ons-col vertical-align="top">
              <date-input
                id="end-date"
                v-model="localCondition.endDate"
                :classes="'input-area ntss-input-date ntss-custom-input'"
                style="width: 75%;"
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
            <v-ons-col width="50%" vertical-align="top">
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
import { mapGetters, mapActions, mapMutations } from "vuex";
import moment from "moment";
import { EventBus } from "@/eventBus";
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
    sessionStorage.setItem('machineInspection', JSON.stringify(responseMachineTypeList.data));
    sessionStorage.setItem('bedGroupList', JSON.stringify(responseBedGroupList.data));
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
  beforeDestroy() {
    EventBus.$off("searchByParam");
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
      // eslint-disable-next-line vue/no-side-effects-in-computed-properties
      this.bedGroupList = JSON.parse(sessionStorage.getItem('bedGroupList')) || [];
      // eslint-disable-next-line vue/no-side-effects-in-computed-properties
      this.machineInspection = JSON.parse(sessionStorage.getItem('machineInspection')) || [];
      // add #11285 機能帳票の印刷情報対応② 高 end
      const selectedMachine = this.machineInspection.filter(machineInspection => (
        machineTypeList.includes(machineInspection.machineTypeCd)
      ));
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
      sessionStorage.setItem('bedGroupListPeriodic', JSON.stringify(conditionList.find(item => item.name === "ベッドグループ").text));
      sessionStorage.setItem('machineInspectionPeriodic', JSON.stringify(conditionList.find(item => item.name === "型式").text));
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
        // title: "装置未選択",
        // message: "装置を選択してください。",
        alertByKey("00200121");
        return;
      }

      this.setParamsCalendar({
        date: moment().format("YYYY-MM-DD"),
        // ここで存在しないレイアウトグループコードを指定することで
        // 予定日選択画面でレイアウトグループが未選択の状態になる
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
      // 表示期間に対応する点検結果リストと
      // 型式、ベッドグループに対応する装置リストを検索する
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
        : moment(date).format("YYYYMMDD");
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
        condition.machineTypeList = machineTypeListDefault;
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
        const dayViewMoment = moment(this.$route.params.fromFacilityCalendar.date);
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
.input-area {
  width: 75%;
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
ons-popover >>> .date-time {
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
</style>
