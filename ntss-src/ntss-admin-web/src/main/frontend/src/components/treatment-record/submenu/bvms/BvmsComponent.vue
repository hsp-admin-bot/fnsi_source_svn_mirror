<template>
  <submenu-base>
    <template #header>
      <div>
       <!-- mod FNSI-8360 ljx start -->
<!--      <div class="btn-area">
        <v-ons-button
          class="button registration-btn"
          :disabled="isReadOnly"
          @click="onClickBvmsGraphCommentCreate"
          v-if="selectedChartType === 1 && isReflowChart"
        >再循環率参照</v-ons-button>
        <div>
          &lt;!&ndash; mod FNSI修正 画面スタイル(ボタン)対応 房 start &ndash;&gt;
          <v-ons-button :disabled="isReadOnly || !isShared" class="button registration-btn btn-dropdown btn3-normal">グラフ切替</v-ons-button>
          &lt;!&ndash; mod FNSI修正 画面スタイル(ボタン)対応 房 end &ndash;&gt;
          <v-ons-select :disabled="isReadOnly || !isShared" v-model="selectedChartType" data-non-authorize="true" id="type-selection">
            <option
              v-for="item in Object.values(graphDefine)"
              :key="item.cd"
              :value="item.cd"
              id="type-option"
            >{{ item.name }}</option>
          </v-ons-select>
        </div>
      </div>-->
      <div class="btn-area">
        <v-ons-button
          class="button registration-btn btn3-normal"
          :disabled="isReadOnly"
          @click="onClickBvmsGraphCommentCreate"
          v-if="selectedChartType === 1 && isReflowChart"
        >再循環率参照</v-ons-button>
        <v-ons-select v-model="selectedChartType" :disabled="isReadOnly || !isShared" data-non-authorize="true" >
          <option
            v-for="item in Object.values(graphDefine)"
            :key="item.cd"
            :value="item.cd"
            id="type-option"
          >{{ item.name }}</option>
        </v-ons-select>
      </div>
      <!-- mod FNSI-8360 ljx end -->
      </div>
    </template>
    <template #main>
      <div :style="{ width: '100%' }" id="bvms-component">
      <div class="chart-area" :style="heightStyles">
        <div class="chart-selection-area">
          <v-ons-select
            v-show="
              currentGraphDefine &&
                currentGraphDefine.setting &&
                currentGraphDefine.setting.series &&
                currentGraphDefine.setting.series.length > 0 &&
                currentGraphSettingList &&
                currentGraphSettingList.length > 0
            "
            v-model="selectedChartSetting"
            data-non-authorize="true"
            class="chart-type-selection"
          >
            <option
              v-for="item in currentGraphSettingList"
              :key="item.cd"
              :value="item.cd"
            >{{ item.name }}</option>
          </v-ons-select>
          <input
            id="fileInput"
            accept=".csv"
            ref="file"
            type="file"
            style="display:none"
            v-on:change="changeFile"
          />
          <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
          <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <v-ons-button
            class="button registration-btn btn3-normal"
            style="float: right;"
            :disabled="isReadOnly || !isShared || !getItemAuthorized('TreatmentRecord', 'default_authority')"
            @click="$refs.file.click()"
          >ファイル読み込み</v-ons-button>
          <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
        </div>
        <div
          v-show="
            currentGraphDefine &&
              currentGraphDefine.setting &&
              currentGraphDefine.setting.series &&
              currentGraphDefine.setting.series.length > 0
          "
        >
          <div>
            <chart-component
              ref="mainChart"
              :width-component="currentWidthScreen"
              :graph-define="currentGraphDefine"
              :graph-setting="currentGraphSetting"
            />
          </div>
        </div>
        <div class="chart-selection-area">
          <v-ons-select
            v-show="
              currentGraphSubchartDefine &&
                currentGraphSubchartDefine.setting &&
                currentGraphSubchartDefine.setting.series &&
                currentGraphSubchartDefine.setting.series.length > 0 &&
                currentGraphSubSettingList &&
                currentGraphSubSettingList.length > 0
            "
            v-model="selectedSubChartSetting"
            data-non-authorize="true"
            class="chart-type-selection"
          >
            <option
              v-for="item in currentGraphSubSettingList"
              :key="item.cd"
              :value="item.cd"
            >{{ item.name }}</option>
          </v-ons-select>
        </div>
        <div
          v-show="
            currentGraphSubchartDefine &&
              currentGraphSubchartDefine.setting &&
              currentGraphSubchartDefine.setting.series &&
              currentGraphSubchartDefine.setting.series.length > 0
          "
        >
          <div>
            <chart-component
              ref="subChart"
              :width-component="currentWidthScreen"
              :graph-define="currentGraphSubchartDefine"
              :graph-setting="currentGraphSubchartSetting"
            />
          </div>
        </div>
      </div>
      </div>
    </template>
  </submenu-base>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import { CODES } from "@/constants/TreatmentRecord";
import { HISTORY_KEY_TREATMENT_RECORD_BVMS } from "@/router/treatment-record/HistoryKeyConstants.js";
import ChartComponent from "@/components/treatment-record/submenu/bvms/BvmsGraphComponent";
import { Graphs } from "@/models/treatment-record/bvms/Graphs";
import { EventBus } from "@/compat/vue/event-bus.js";

// add FNSI-権限関連-治療記録 孫灝 start
/**
 * コンポーネント単位ガードを行うMixin.
 */
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
// import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { getAuthorized } from "@/functions/common/CommonFunctions";
// add FNSI-権限関連-治療記録 孫灝 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { getLayoutRootElement, getScopedElementById, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
export default {
//#10359 del 編集権限の動作不正 2024-06-05 卓 start
  // mixins: [UserAuthorityMixin],
//#10359 del 編集権限の動作不正 2024-06-05 卓 end
  components: {
    "submenu-base": SubmenuBase,
    "chart-component": ChartComponent
  },
  data() {
    return {
      fileinput: "",
      currentWidthScreen: 0,
      selectedChartType: 1,
      isReflowChart: false,
      isUpload: false,
      selectedChartSetting: 1,
      selectedSubChartSetting: 1,
      chartScale: CODES.CHART_SCALE.TIME.cd,
      graphDefine: {},
      graphSubchartDefine: {},
      rstStartDate: null,
      rstEndDate: null,
      historyKey: HISTORY_KEY_TREATMENT_RECORD_BVMS,
      componentAreaHeight: 200,
      // add FNSI 治療記録権限の有無 -- 孫灝 start
      hasTreatmentRecordAuthority: false,
      // add FNSI 治療記録権限の有無 -- 孫灝 end
    };
  },
  computed: {
    ...mapGetters("window-size", { windowHeight: "getWindowHeight" }),
    ...mapGetters("treatment-record/common", ["getOrdNo", "getOrd"]),
    ...mapGetters("report", [
      "getMstReports",
      "getMstPrinters",
      "isPreview",
      "getDataKey"
    ]),
    // add FNSI-修正 共有設定 トウ start
    ...mapGetters("treatment-record/common", [
      "getOrd",
      "getSharedFacilityCd"
    ]),

    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add FNSI-修正 共有設定 トウ end
    heightStyles() {
      return { height: `${this.componentAreaHeight}px` };
    },
    currentGraphDefine() {
      return Object.values(this.graphDefine).find(
        e => e.cd === this.selectedChartType
      );
    },
    currentGraphSubchartDefine() {
      return Object.values(this.graphSubchartDefine).find(
        e => e.cd === this.selectedChartType
      );
    },
    currentGraphSetting() {
      return this.currentGraphDefine.graphSetting
        ? this.currentGraphDefine.graphSetting.find(
            e => e.cd === this.selectedChartSetting
          )
        : {};
    },
    currentGraphSubchartSetting() {
      return this.currentGraphSubchartDefine.graphSetting
        ? this.currentGraphSubchartDefine.graphSetting.find(
            e => e.cd === this.selectedSubChartSetting
          )
        : {};
    },
    currentGraphSettingList() {
      return this.currentGraphDefine.graphSetting;
    },
    currentGraphSubSettingList() {
      return this.currentGraphSubchartDefine.graphSetting;
    },

    isReadOnly() {
      // URLダイレクト対応 setOrd実施前に子画面遷移すると表示不可になる不具合の対応
      if (this.getOrd == undefined || this.getOrd == null) {
        return false;
      }
    },
    // add FNSI-修正 共有設定 トウ start
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    }
    // add FNSI-修正 共有設定 トウ end
  },
  methods: {
    ...mapActions("treatment-record/bvms", [
      "getDdmGraph",
      "getBvGraph",
      "getHtGraph",
      "getRrGraph",
      "getDdmGraphWithUploadFile",
      "getBvGraphWithUploadFile",
      "getHtGraphWithUploadFile",
      "getRrGraphWithUploadFile"
    ]),
    ...mapActions("report", ["setCreateReportParam"]),
    ...mapActions("multi-modal", ["showBvmsGraphCommentCreate"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    //#10359 add 編集権限の動作不正 2024-06-05 卓 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    //#10359 add 編集権限の動作不正 2024-06-05 卓 end
    adjustHeight() {
      const submenuMain = this.$el?.closest?.(".submenu-main") || getScopedElementsByClassName("submenu-main", getLayoutRootElement(this.$el || this) || this.$el || this)[0];
      const submenuMainHeight = submenuMain?.clientHeight || 0;
      this.componentAreaHeight = (submenuMainHeight - 10) / 2;
    },
    handleResizeWindow() {
      const bvmsComponent = this.$el?.id === "bvms-component" ? this.$el : getScopedElementById("bvms-component", this.$el || this);
      if (bvmsComponent) {
        this.currentWidthScreen = bvmsComponent.clientWidth;
      }
    },
    onClickBvmsGraphCommentCreate() {
      if(this.isReadOnly) {
        return;
      }
      this.showBvmsGraphCommentCreate();
    },
    initGraph() {
      let graphClass = new Graphs();
      this.graphDefine = {
        bVGraph: graphClass.getBVGraph(),
        renalReplacementTherapyGraph: graphClass.getRenalReplacementTherapyGraph(),
        htGraph: graphClass.getHtGraph(),
        recirculationRateGraph: graphClass.getRecirculationRateGraph()
      };
      this.graphSubchartDefine = {
        bVSubGraph: graphClass.getBVSubGraph(),
        renalReplacementTherapySubGraph: graphClass.getRenalReplacementTherapySubGraph(),
        htSubGraph: graphClass.getHtSubGraph(),
        recirculationRateSubGraph: graphClass.getRecirculationRateSubGraph()
      };
    },
    setReportParam() {
      this.setCreateReportParam({
        ...this.convertSettings(
          this.currentGraphSetting,
          this.currentGraphSubchartSetting
        ),
        selectedChart: this.selectedChartType
      });
    },
    changeFile(e) {
      this.setLoadingScreenVisible(true);
      var files = e.target.files || e.dataTransfer.files;
      if (!files.length) {
        this.setLoadingScreenVisible(false);
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // this.$ons.notification.alert("ファイルを選択してください。", {
        //   title: ""
        // });
        this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES[12000254].message), {
          title: DIALOG_MESSAGES[12000254].title
        });
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        return;
      }
      if (files[0].name.split(".").pop() != "csv" && files[0].name.split(".").pop() != "CSV") {
        this.setLoadingScreenVisible(false);
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // this.$ons.notification.alert("ファイルアップロードに失敗しました。", {
        //   title: ""
        // });
        this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES[12000255].message), {
          title: DIALOG_MESSAGES[12000255].title
        });
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        return;
      }
      this.fileinput = files[0];
      const reader = new FileReader();
      const vue = this;
      reader.onload = function() {
        const text = reader.result;
        const file2 = new Blob([text], {type: 'application/vnd.ms-excel'});
        vue.fileinput = file2;
        vue.isUpload = true;
        vue.setLoadingScreenVisible(false);
        vue.getDataGraphWithUploadFile();
      }
      reader.readAsText(this.fileinput);
    },
    getDataGraphWithUploadFile() {
      let graphClass = new Graphs();
      this.setReportParam();
      switch (this.selectedChartType) {
        case 1: // BvGraph
          this.getBvGraphWithUploadFile(
            this.convertSettings(
              this.currentGraphSetting,
              this.currentGraphSubchartSetting
            )
          ).then(response => {
            this.graphDefine.bVGraph = graphClass.getBVGraph(
              response.graphEvents,
              response.graphData
            );
            this.graphSubchartDefine.bVSubGraph = graphClass.getBVSubGraph(
              response.subGraphEvents,
              response.subGraphData
            );
            this.$nextTick(() => {
              this.reFlowChart();
            });
          });
          break;
        case 2: // RenalReplacementTherapyGraph
          this.getDdmGraphWithUploadFile(
            this.convertSettings(
              this.currentGraphSetting,
              this.currentGraphSubchartSetting
            )
          ).then(response => {
            this.graphDefine.renalReplacementTherapyGraph = graphClass.getRenalReplacementTherapyGraph(
              response.graphEvents,
              response.graphData
            );
            this.graphSubchartDefine.renalReplacementTherapySubGraph = graphClass.getRenalReplacementTherapySubGraph(
              response.subGraphEvents,
              response.subGraphData
            );
            this.$nextTick(() => {
              this.reFlowChart();
            });
          });
          break;
        case 3: // HtGraph
          this.getHtGraphWithUploadFile(
            this.convertSettings(
              this.currentGraphSetting,
              this.currentGraphSubchartSetting
            )
          ).then(response => {
            this.graphDefine.htGraph = graphClass.getHtGraph(
              response.graphEvents,
              response.graphData
            );
            this.graphSubchartDefine.htSubGraph = graphClass.getHtSubGraph(
              response.subGraphEvents,
              response.subGraphData
            );
            this.$nextTick(() => {
              this.reFlowChart();
            });
          });
          break;
        case 4: // RecirculationRateGraph
          this.getRrGraphWithUploadFile(
            this.convertSettings(
              this.currentGraphSetting,
              this.currentGraphSubchartSetting
            )
          ).then(response => {
            this.graphDefine.recirculationRateGraph = graphClass.getRecirculationRateGraph(
              response.graphEvents,
              response.graphData
            );
            this.graphSubchartDefine.recirculationRateSubGraph = graphClass.getRecirculationRateSubGraph(
              response.subGraphEvents,
              response.subGraphData
            );
            this.$nextTick(() => {
              this.reFlowChart();
            });
          });
          break;
      }
    },
    getDataGraph() {
      let graphClass = new Graphs();
      this.setReportParam();
      switch (this.selectedChartType) {
        case 1: // BVグラフ
          this.getBvGraph(
            this.convertSettings(
              this.currentGraphSetting,
              this.currentGraphSubchartSetting
            )
          ).then(response => {
            this.graphDefine.bVGraph = graphClass.getBVGraph(
              response.graphEvents,
              response.graphData
            );
            this.graphSubchartDefine.bVSubGraph = graphClass.getBVSubGraph(
              response.subGraphEvents,
              response.subGraphData
            );
            this.$nextTick(() => {
              this.reFlowChart();
            });
          });
          break;
        case 2: // 透析量モニタ（DDM）グラフ
          this.getDdmGraph(
            this.convertSettings(
              this.currentGraphSetting,
              this.currentGraphSubchartSetting
            )
          ).then(response => {
            this.graphDefine.renalReplacementTherapyGraph = graphClass.getRenalReplacementTherapyGraph(
              response.graphEvents,
              response.graphData
            );
            this.graphSubchartDefine.renalReplacementTherapySubGraph = graphClass.getRenalReplacementTherapySubGraph(
              response.subGraphEvents,
              response.subGraphData
            );
            this.$nextTick(() => {
              this.reFlowChart();
            });
          });
          break;
        case 3: // HTグラフ
          this.getHtGraph(
            this.convertSettings(
              this.currentGraphSetting,
              this.currentGraphSubchartSetting
            )
          ).then(response => {
            this.graphDefine.htGraph = graphClass.getHtGraph(
              response.graphEvents,
              response.graphData
            );
            this.graphSubchartDefine.htSubGraph = graphClass.getHtSubGraph(
              response.subGraphEvents,
              response.subGraphData
            );
            this.$nextTick(() => {
              this.reFlowChart();
            });
          });
          break;
        case 4: // 再循環率グラフ
          this.getRrGraph(
            this.convertSettings(
              this.currentGraphSetting,
              this.currentGraphSubchartSetting
            )
          ).then(response => {
            this.graphDefine.recirculationRateGraph = graphClass.getRecirculationRateGraph(
              response.graphEvents,
              response.graphData
            );
            this.graphSubchartDefine.recirculationRateSubGraph = graphClass.getRecirculationRateSubGraph(
              response.subGraphEvents,
              response.subGraphData
            );
            this.$nextTick(() => {
              this.reFlowChart();
            });
          });
          break;
      }
    },
    convertSettings(graphSetting, graphSubchartSetting) {
      let result = {};
      if (!graphSubchartSetting) {
        if (graphSetting.setting) {
          result.graphY1From = graphSetting.setting.yAxis[0].min;
          result.graphY1To = graphSetting.setting.yAxis[0].max;
        }
      } else {
        if (graphSetting.setting) {
          result.graph1Y1From = graphSetting.setting.yAxis[0].min;
          result.graph1Y1To = graphSetting.setting.yAxis[0].max;
        }
        if (graphSubchartSetting.setting) {
          result.graph2Y1From = graphSubchartSetting.setting.yAxis[0].min;
          result.graph2Y1To = graphSubchartSetting.setting.yAxis[0].max;
        }
      }
      result.ordNo = this.getOrdNo;
      result.selectedPatId = this.selectedPatId;
      result.files = this.fileinput;
      result.isUpload = this.isUpload;
      return result;
    },
    reFlowChart() {
      this.$refs.mainChart.createChartLayout();
      this.$refs.mainChart.createChartReflow();
      this.$refs.subChart.createChartLayout();
      this.$refs.subChart.createChartReflow();
      this.isReflowChart = true;
    },
    // add FNSI-修正 権限関連 孫灝 start
    //#10359 del 編集権限の動作不正 2024-06-05 卓 start
    // getTreatmentRecordAuthority() {
    //   return this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT);
    // }
    // add FNSI-修正 権限関連 孫灝 end
    //#10359 del 編集権限の動作不正 2024-06-05 卓 end
  },
  watch: {
    windowHeight() {
      this.adjustHeight();
    },
    selectedChartType() {
      this.selectedChartSetting = this.currentGraphDefine.graphSetting
        ? this.currentGraphDefine.graphSetting[0].cd
        : 1;
      this.selectedSubChartSetting = this.currentGraphSubchartDefine
        .graphSetting
        ? this.currentGraphSubchartDefine.graphSetting[0].cd
        : 1;
      this.isUpload ? this.getDataGraphWithUploadFile() : this.getDataGraph();
    },
    selectedChartSetting() {
      this.isUpload ? this.getDataGraphWithUploadFile() : this.getDataGraph();
    },
    selectedSubChartSetting() {
      this.isUpload ? this.getDataGraphWithUploadFile() : this.getDataGraph();
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.adjustHeight();
      this.handleResizeWindow();
      this.isUpload ? this.getDataGraphWithUploadFile() : this.getDataGraph();
    });
  },
  created() {
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("resize", this.handleResizeWindow, false);
    EventBus.$off("switchSidebar", this.handleResizeWindow);
    EventBus.$on("switchSidebar", this.handleResizeWindow);
    this.initGraph();
    // add FNSI-治療記錄の權限取得 孫灝 start
    // this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // add FNSI-治療記錄の權限取得 孫灝 end
  },
  updated() {
    this.$nextTick(() => {
      this.adjustHeight();
    });
  },
  beforeUnmount() {
    EventBus.$off("switchSidebar", this.handleResizeWindow);
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("resize", this.handleResizeWindow, false);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.btn-area {
  display: flex;
  float: right;
}
.btn-area > .registration-btn {
  margin-right: 10px;
}
.chart-selection-area {
  margin-top: 10px;
}
.chart-type-selection {
  border: solid 1px var(--treatment-record-select-border-color);
  position: relative;
  top: -9px;
  padding-right: 4px;
  padding-left: 4px;
  margin-bottom: 10px;
  margin-top: 15px;
}
#type-selection {
  position: relative;
  top: -2px;
  padding-right: 4px;
  padding-left: 4px;
  margin-bottom: 10px;
  width: 8em;
  z-index: 2;
  background-color: transparent !important;
  color: transparent !important;
  padding-bottom: 6%;
  height: 35px;
  border: none;
  opacity: 0;
}
#type-option {
  color: var(--ntss-list-body-color);
  background-color: var(--treatment-record-input-background-color);
}
.btn-dropdown {
  position: absolute;
  z-index: 1;
  width: 7em;
}
@media only screen and (max-width: 364px) {
  .btn-dropdown {
    margin-top: 46px;
    margin-left: -129px;
  }
}
</style>
