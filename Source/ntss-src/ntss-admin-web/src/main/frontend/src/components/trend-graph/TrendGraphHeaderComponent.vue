/**
 * 治療状況リスト（透析液調製装置トレンドグラフ）用ヘッダ
 */
<template>
  <div class="header-item">
    <v-ons-row class="mark-leftmost-header">
      <!-- mod FNSI-redmine#3968 付 start -->
      <!-- <v-ons-col width="40%" height="100%"> -->
      <v-ons-col width="40%" height="100%" class="headSearch">
        <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
      <!-- mod FNSI-redmine#3968 付 end -->
      </v-ons-col>
    </v-ons-row>
    <!-- 抽出ダイアログ[始] -->
    <v-ons-popover
      cancelable
      v-model:visible="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :class="[fontSizeSet, 'trend-graph-header-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div id="popover">
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="top">
            <label style="margin-right: 0.5em;">表示期間</label>
          </v-ons-col>
          <v-ons-col style="text-align: center;">
            <div class="flex-align-center">
              <!--#10715:日付IF修正Start（トレンドグラフ対応）-->
              <date-input
                :classes="'ntss-input-date input-area ntss-custom-input'"
                style="padding-right: 0px"
                id="treatstartDate"
                name="treatDate"
                type="date"
                model-event="change"
                v-model="trendCondition.startDate"
                v-rules="'required|date_format:yyyy-MM-dd'"
                @handleClearInput="trendCondition.startDate = null"
              />
              <!--#10715:日付IF修正End（トレンドグラフ対応）-->
              <common-calendar v-model="trendCondition.startDate" />
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="top" style="text-align: end;">
            <label style="margin-right: 0.5em;">～</label>
          </v-ons-col>
          <v-ons-col style="text-align: center;">
            <div class="flex-align-center">
              <!--#10715:日付IF修正Start（トレンドグラフ対応）-->
              <date-input
                :classes="'ntss-input-date input-area ntss-custom-input'"
                style="padding-right: 0px"
                id="treatendDate"
                name="treatDate"
                type="date"
                model-event="change"
                v-model="trendCondition.endDate"
                v-rules="'required|date_format:yyyy-MM-dd'"
                @handleClearInput="trendCondition.endDate = null"
              />
              <!--#10715:日付IF修正End（トレンドグラフ対応）-->
              <common-calendar v-model="trendCondition.endDate" />
            </div>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="top">
            <label style="margin-right: 0.5em;">グラフ表示項目</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="top">
            <v-ons-select style="width: 100%" v-model="trendCondition.selectedTemplateCd">
              <template v-if="templateList.length > 0">
                <option
                  v-for="(option,index) in templateList"
                  :key="index"
                  :value="option.templateCd"
                >{{ option.templateName }}</option>
              </template>
              <template v-else>
                <option value="0"></option>
              </template>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="condition-row">
          <v-ons-col width="40%" vertical-align="top">
            <label style="margin-right: 0.5em;">モニタ一覧項目</label>
          </v-ons-col>
          <v-ons-col width="60%" vertical-align="top">
            <v-ons-select style="width: 100%" v-model="trendCondition.selectedMonitorSetCd">
              <template v-if="templateList.length > 0">
                <option
                  v-for="(option,index) in monitorSetList"
                  :key="index"
                  :value="option.monitorSetCd"
                >{{ option.monitorSetName }}</option>
              </template>
              <template v-else>
                <option value="0"></option>
              </template>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <!-- mod FNSI-画面スタイル(ボタン)対応 付 start -->
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button class="clear btn2-cancel" @click="dialogClear">クリア</v-ons-button>
          </v-ons-col>
          <v-ons-col vertical-align="center"></v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button class="ok btn3-normal" @click="dialogOk" :disabled="!isChangeCondition.all">OK</v-ons-button>
          </v-ons-col>
          <!-- mod FNSI-画面スタイル(ボタン)対応 付 end -->
        </v-ons-row>
      </div>
    </v-ons-popover>
    <!-- 抽出ダイアログ[終] -->
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { deepCopy } from "@/functions/common/CommonFunctions";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
//#10715:日付IF修正Start（トレンドグラフ対応）
import DateInput from "@/components/common/DateInput.vue";
//#10715:日付IF修正End（トレンドグラフ対応）
export default {
  mixins: [PopoverMixin],
  components: {
    "common-calendar": commonCalender,
    //#10715:日付IF修正Start（トレンドグラフ対応）
    "common-searcharea": commonSearchArea,
    "date-input":DateInput,
    //#10715:日付IF修正End（トレンドグラフ対応）
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      axisScaleOption: [{ text: "時間", value: 0 }, { text: "日", value: 1 }],
      fixTrendCondition: {
        startDate: null,
        endDate: null,
        axisScaleIndex: 0,
        axisScaleName: "",
        xAxisInterval: 1,
        selectedTemplateCd: 0,
        selectedMonitorSetCd: 0
      },
      trendCondition: {
        startDate: null,
        endDate: null,
        axisScaleIndex: 0,
        axisScaleName: "",
        xAxisInterval: 1,
        selectedTemplateCd: 0,
        selectedMonitorSetCd: 0
      },
      templateList: [],
      monitorSetList: [],
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("trend-graph", ["getMachineInfo", "getConditionInfo"]),
    /**
     * 選択中表示期間取得
     */
    getTargetRange() {
      const startDate = this.fixTrendCondition.startDate;
      const endDate = this.fixTrendCondition.endDate;
      if (startDate === null && endDate === null) {
        return null;
      } else if (startDate === null) {
        return `～${endDate}`;
      } else if (endDate === null) {
        return `${startDate}～`;
      } else {
        return `${startDate}～${endDate}`;
      }
    },
    getAxisInterval() {
      return `目盛間隔：${this.fixTrendCondition.xAxisInterval} ${this.axisScaleOption[this.fixTrendCondition.axisScaleIndex].text}`;
    },
    /**
     * 選択中テンプレート名称取得
     */
    getSelectedGraphTemplate() {
      const selectedTemplate = this.templateList.find(
        v => v.templateCd == this.fixTrendCondition.selectedTemplateCd
      );
      return selectedTemplate === undefined
        ? null
        : selectedTemplate.templateName;
    },
    /**
     * 選択中モニタ一覧セット名称取得
     */
    getSelectedMonitorSetName() {
      const selectedMonitorSet = this.monitorSetList.find(
        v => v.monitorSetCd == this.fixTrendCondition.selectedMonitorSetCd
      );
      return selectedMonitorSet === undefined
        ? null
        : selectedMonitorSet.monitorSetName;
    },
    /**
     * 抽出条件の変更チェック
     */
    isChangeCondition() {
      const isChangeRange = !(
        this.trendCondition.startDate === this.fixTrendCondition.startDate &&
        this.trendCondition.endDate === this.fixTrendCondition.endDate
      );
      const isChangeGraph = !(
        this.trendCondition.axisScaleIndex ===
          this.fixTrendCondition.axisScaleIndex &&
        this.trendCondition.xAxisInterval ===
          this.fixTrendCondition.xAxisInterval
      );
      const isChangeTemplate = !(
        this.trendCondition.selectedTemplateCd ===
        this.fixTrendCondition.selectedTemplateCd
      );
      const isChangeMonitorSet = !(
        this.trendCondition.selectedMonitorSetCd ===
        this.fixTrendCondition.selectedMonitorSetCd
      );
      return {
        all:
          isChangeRange ||
          isChangeGraph ||
          isChangeTemplate ||
          isChangeMonitorSet,
        range: isChangeRange,
        graph: isChangeGraph,
        template: isChangeTemplate,
        monitorSet: isChangeMonitorSet
      };
    }
  },
  methods: {
    ...mapActions("trend-graph", [
      "setTrendCondition",
      "fetchTrendGraphMaster",
      "setMasterData",
      "fetchTrendGraphList",
      "setTrendGraphList"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    loadData() {
      if (
        !(this.getMachineInfo.model && this.getMachineInfo.model.length > 0)
      ) {
        return false;
      }
      // mod FNSI-改修内容5702修正 xuty start
      // this.fetchTrendGraphMaster(this.getMachineInfo.model)
      this.fetchTrendGraphMaster(this.getMachineInfo)
      // mod FNSI-改修内容5702修正 xuty end
        .then(res => {
          // モニター一覧セットマスタとテンプレートマスタを取得
          this.templateList = res.data.template;
          this.monitorSetList = res.data.monitorSet;
          this.setMasterData({
            template: this.templateList,
            monitorSet: this.monitorSetList
          }).then(() => {
            this.loadStateCondition();
            this.dialogOk();
          });
        })
        .catch(err => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('TrendGraphHeaderComponent.vue','loadData',err);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          // 検索失敗
          console.error(err);
        });
    },
    // -----------------------------------------
    // stateから取得したconditionを変数に設定する
    // -----------------------------------------
    loadStateCondition() {
      //#10715:日付IF修正Start（トレンドグラフ対応）
      const startDate = dayjs().startOf('month').add(-3, 'month').format("YYYY-MM-DD");
      const endDate = dayjs().format("YYYY-MM-DD");
      //#10715:日付IF修正End（トレンドグラフ対応）
      // 表示期間
      // 開始日
      //#10715:日付IF修正Start（トレンドグラフ対応）
      this.trendCondition.startDate = startDate;
      //#10715:日付IF修正End（トレンドグラフ対応）
      // 終了日
      //#10715:日付IF修正Start（トレンドグラフ対応）
      this.trendCondition.endDate = endDate;
      //#10715:日付IF修正End（トレンドグラフ対応）
      // 横軸目盛
      this.trendCondition.axisScaleIndex = this.getConditionInfo.axisScaleIndex;
      this.trendCondition.axisScaleName = this.getConditionInfo.axisScaleName;
      // 目盛間隔
      this.trendCondition.xAxisInterval = this.getConditionInfo.xAxisInterval;
      // グラフ表示項目
      this.trendCondition.selectedTemplateCd = this.getConditionInfo.selectedTemplateCd[
        this.getMachineInfo.model
      ];
      // 設定した項目が取得したリストにない場合はリストの1件目を設定
      if (
        this.templateList.find(
          v => v.templateCd == this.trendCondition.selectedTemplateCd
        ) === undefined
      ) {
        this.trendCondition.selectedTemplateCd =
          this.templateList.length > 0 ? this.templateList[0].templateCd : 0;
      }

      // モニタ一覧表示項目
      this.trendCondition.selectedMonitorSetCd = this.getConditionInfo.selectedMonitorSetCd[
        this.getMachineInfo.model
      ];
      // 設定した項目が取得したリストにない場合はリストの1件目を設定
      if (
        this.monitorSetList.find(
          v => v.monitorSetCd == this.trendCondition.selectedMonitorSetCd
        ) === undefined
      ) {
        this.trendCondition.selectedMonitorSetCd =
          this.monitorSetList.length > 0
            ? this.monitorSetList[0].monitorSetCd
            : 0;
      }
    },
    showPopover(event) {
      this.trendCondition = deepCopy(this.fixTrendCondition);
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    dialogOk() {
      this.popoverVisible = false;
      // 抽出条件の変更チェック
      const isChangeAll = this.isChangeCondition.all;
      const isChangeRange = this.isChangeCondition.range;

      if (isChangeAll) {
        // 抽出条件
        this.trendCondition.axisScaleName = this.axisScaleOption[
          this.trendCondition.axisScaleIndex
        ];
        this.fixTrendCondition = deepCopy(this.trendCondition);

        // 抽出条件セット
        this.setTrendCondition(this.fixTrendCondition).then(() => {
          if (isChangeRange) {
            // データリロード
            this.fetchTrendGraphList(this.fixTrendCondition).then(res => {
              this.setTrendGraphList(res.data.monitorInfo);
              // モニタ一覧の画面表示用データの配列の生成
              EventBus.$emit("createVisibleMonitorDataList");
            });
          }
        });
      }
      this.setConditionList();
    },
    /**
     * 抽出条件クリア
     */
    dialogClear() {
      //#10715:日付IF修正Start（トレンドグラフ対応）
      const startDate = dayjs().startOf('month').add('month', -3).format("YYYY-MM-DD");
      const endDate = dayjs().format("YYYY-MM-DD");
      //#10715:日付IF修正End（トレンドグラフ対応）
      this.trendCondition = {
        //#10715:日付IF修正Start（トレンドグラフ対応）
        startDate: startDate,
        endDate: endDate,
        //#10715:日付IF修正End（トレンドグラフ対応）
        axisScaleIndex: 0,
        axisScaleName: this.axisScaleOption[0],
        xAxisInterval: 1,
        selectedTemplateCd:
          this.templateList.length > 0 ? this.templateList[0].templateCd : 0,
        selectedMonitorSetCd:
          this.monitorSetList.length > 0
            ? this.monitorSetList[0].monitorSetCd
            : 0
      };
    },
    /**
     * 共通検索エリア部品に表示するデータのリストを作成
     */
    setConditionList() {
      let condList = [];
      // 表示期間
      if (this.getTargetRange !== null) {
        condList.push({ name:"表示期間", text:this.getTargetRange.replace(/-/g, "/") });
      }
      // グラフ表示項目
      if (this.getSelectedGraphTemplate !== null) {
        condList.push({ name:"グラフ表示項目", text:this.getSelectedGraphTemplate });
      }
      // モニタ一覧項目
      if (this.getSelectedMonitorSetName !== null) {
        condList.push({ name:"モニタ一覧項目", text:this.getSelectedMonitorSetName });
      }
      this.conditionList = condList;
    }
  },
  created() {
    // 情報取得
    this.loadData();
  },
};
</script>

<style scoped>
#popover {
  margin: 10px 10px 0px 10px;
  position: relative;
}
#popover label {
  font-size: 1.5em;
}
.trend-graph-header-popover :deep(.popover) {
  width: auto;
}
.trend-graph-header-popover :deep(.popover__content) {
  width: 21em;
}
/* add FNSI-redmine#3968 付 start */
.headSearch {
  max-height: 100%;
}
/* add FNSI-redmine#3968 付 end */
</style>
