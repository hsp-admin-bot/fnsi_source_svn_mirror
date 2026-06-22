<template>
  <div class="main-content-area">
    <div class="highchart-area">
      <highcharts
        v-if="graphSettings"
        ref="highcharts"
        :options="chartOptions"
        :key="`graph${keyGraph}`"
      />
      <div class="sumary-table">
        <div
          v-for="(row, rowIndex) in sumaryAreaMap"
          :key="`row-${rowIndex}`"
          :style="sumaryRowStyle(rowIndex)"
        >
          <div
            v-for="(col, colIndex) in row"
            :ref="`area${col}`"
            :key="`col-${col}`"
            :style="sumaryColStyle(colIndex)"
            valign="bottom"
            :class="areaSelectedClass(col)"
          >
            <div
              class="statistical-information"
              v-if="statisticalInformation && graphType === 'blank'"
            >
              <label class="area-number">{{ col }}</label>
              <label class="area-title">{{ getAreaInfo(col).title }}</label>
              <ul class="area-content">
                <li
                  v-for="(content, idxContent) in getAreaInfo(col).content"
                  :key="`content-${idxContent}`"
                >{{ content }}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
      <!-- popover level 1 -->
      <v-ons-popover
        cancelable
        v-model:visible="duplicatePlotListVisible"
        :target="duplicatePlotListTarget"
        :direction="duplicatePlotListDirection"
        :cover-target="false"
        :class="[fontSizeSet,'popover-area split-graph-popover']"
        :key="`duplicatePlotList${popoverKey}`"
        @preshow="popoverPreShowOther"
        @postshow="calMenuDirection(); popoverPostShowOther($event, 'splitGraph')"
        @posthide="removeCloneTooltip(); popoverPosthideOther($event, 'splitGraph')"
      >
        <div class="pop-area custom-pop-area">
          <!-- ポップオーバータブ -->
          <v-ons-row
            class="condition-row popover-tab"
          >
            <v-ons-col class="custom-ons-col custom-identify">
              <div class="custom-ntss-btn ntss-button-group">
                <input
                  type="radio"
                  class="identification"
                  name="popover-tab-button"
                  id="input-tooltip"
                  @click="switchTab(1);"
                  :checked="currentTab === 1 ? 'checked': ''"
                />
                <label for="input-tooltip" class="label first-of-type tab-label">検査値</label>
                <input
                  type="radio"
                  class="identification"
                  name="popover-tab-button"
                  id="input-menu"
                  @click="switchTab(2);"
                  :checked="currentTab === 2 ? 'checked': ''"
                />
                <label
                  for="input-menu"
                  class="label last-of-type tab-label"
                >{{graphType === GRAPH_TYPE.DISTRIBUTION ? '画面遷移' : '検査情報'}}</label>
              </div>
            </v-ons-col>
          </v-ons-row>
          <div class="pop-main-area">
            <!-- ツールチップ -->
            <div v-if="currentTab === 1" class="tooltip-tab">
              <p
                v-html="spanText"
              ></p>
            </div>
            <!-- 分布グラフに対して患者の一覧とか経過グラフに対してオーダーの一覧とか -->
            <div v-if="currentTab === 2" class="menu-tab">
              <v-ons-row class="condition-row">
                <v-ons-col width="70%" vertical-align="center">
                  <v-ons-input
                    v-model="keySearch"
                    name="search"
                    type="text"
                    float
                  ></v-ons-input>
                </v-ons-col>
                <v-ons-col width="30%" vertical-align="center">
                  <v-ons-button
                    class="btn3-normal"
                    @click="onPopoverFilter"
                  >抽出</v-ons-button>
                </v-ons-col>
              </v-ons-row>
              <div class="pat-list-content">
                <table id="master-list" class="ntss-list">
                  <thead>
                    <tr>
                      <th class="ntss-list-header-th-sticky" v-if="graphType === GRAPH_TYPE.DISTRIBUTION">患者名</th>
                      <th class="ntss-list-header-th-sticky" v-else>検査日</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="(item, index) in filterDuplicatePlotList"
                      :key="`plot-${index}`"
                      class="ntss-list-body-tr"
                      @click="showMenu($event, item)"
                    >
                      <td
                        v-if="graphType === GRAPH_TYPE.DISTRIBUTION"
                        class="ntss-list-body-td"
                        :class="patInOutClass(item.patId)"
                      >
                        {{ item.name }}
                        <img class='same-icon' v-show="patIsSame(item.patId) === '1'" :src="image_src_same" />
                      </td>
                      <td
                        v-else
                        class="ntss-list-body-td"
                      >{{ shortDateFormat(item.date) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </v-ons-popover>
      <!-- 2レベルのポップオーバー -->
      <v-ons-popover
        cancelable
        v-model:visible="menuVisible"
        :target="menuTarget"
        :direction="menuDirection"
        :cover-target="false"
        :class="[fontSizeSet,'popover-area split-graph-popover']"
        :key="`menu${menuKey}`"
        @preshow="popoverPreShow"
        @postshow="popoverPostShow"
        @posthide="removeCloneTooltip(); popoverPosthide($event);"
      >
        <!-- 1レベルのポップオーバーを表示している場合、メニューリストを表示する -->
        <div v-if="duplicatePlotListVisible" class="pop-menu-area">
          <div class="pop-menu">
            <table class="menu-list">
              <tbody>
                <template v-for="(menu, index) in menuList" :key="`menu-${index}`">
                  <tr
                    :class="{
                      'menu-body-tr': true,
                      'non-display': hideMenuButton(menu.cd)
                    }"
                  >
                    <v-ons-button
                      class="btn-Split-graph-menu btn3-normal"
                      :style="{ 'justify-content': menu.cd !== 3 ? 'left' : 'center' }"
                      :title="menu.title"
                      @click="goToPage(menu)"
                    >
                      <img class="icon" :src="menu.icon" v-if="menu.cd !== 3"/>
                      {{ menu.name }}
                    </v-ons-button>
                  </tr>
                </template>
              </tbody>
            </table>
          </div>
        </div>
        <!-- 1レベルのポップオーバーを表示していない場合 -->
        <div v-else class="pop-area custom-pop-area">
          <!-- ポップオーバータブ -->
          <v-ons-row
            class="condition-row popover-tab"
          >
            <v-ons-col class="custom-ons-col custom-identify">
              <div class="custom-ntss-btn ntss-button-group">
                <input
                  type="radio"
                  class="identification"
                  :class="currentTab === 1?'identification' + currentTab:''"
                  name="popover-tab-button"
                  id="input-tooltip"
                  @click="switchTab(1);"
                  :checked="currentTab === 1 ? 'checked': ''"
                />
                <label for="input-tooltip" class="label first-of-type tab-label">検査値</label>
                <input
                  type="radio"
                  class="identification"
                   :class="currentTab === 2?'identification' + currentTab:'identification2Not'"
                  name="popover-tab-button"
                  id="input-menu"
                  @click="switchTab(2);"
                  :checked="currentTab === 2 ? 'checked': ''"
                />
                <label for="input-menu" class="label last-of-type tab-label">画面遷移</label>
              </div>
            </v-ons-col>
          </v-ons-row>
          <div class="pop-main-area">
            <!-- ツールチップ -->
            <div v-if="currentTab === 1" class="tooltip-tab">
              <p v-html="spanText"></p>
            </div>
            <!-- メニュー -->
            <div v-if="currentTab === 2" class="menu-tab">
              <div class="pop-menu">
                <table class="menu-list">
                  <tbody>
                    <template v-for="(menu, index) in menuList" :key="`menu-${index}`">
                      <tr
                        :class="{
                          'menu-body-tr': true,
                          'non-display': hideMenuButton(menu.cd)
                        }"
                      >
                        <v-ons-button
                          class="btn-Split-graph-menu btn3-normal"
                          :style="{ 'justify-content': menu.cd !== 3 ? 'left' : 'center' }"
                          :title="menu.title"
                          @click="goToPage(menu)"
                        >
                          <img class="icon" :src="menu.icon" v-if="menu.cd !== 3"/>
                          {{ menu.name }}
                        </v-ons-button>
                      </tr>
                    </template>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </v-ons-popover>
      <div id="bottom-info">
        <label>{{ patientFooterInfo }}</label>
      </div>
    </div>
  </div>
</template>

<script>
import { Chart } from "@/compat/charts/highcharts";
import { getClosestMainContentAreaElement, getMainContentAreaElement, getScopedDocument, getScopedWindow, getScopedElementById, getScopedElementsByClassName, queryScopedSelector, appendScopedChild } from "@/functions/common/LayoutMeasureHelper";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import {
  getExamInRange,
  simpleDateFormat,
  periods,
  simpleSort,
  formatGraphSettings,
  DecimalFormat,
  settingErrorMessage
} from "@/components/split-graph/SplitGraphFunctions.js";
import {
  sendRequestGetProgressGraph,
  sendRequestGetDistributionGraph,
  // mod bug 7940 修正 chen start
  // sendRequestUpdatePatientGroup,
  sendRequestUpdatePatientGroupByGroup,
  // mod bug 7940 修正 chen end
  getGraphSettings
} from "@/apis/split-graph";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
// del #10359 編集権限の動作不正 dengshen start
// import {
//   FUNC_EXAM_RECORD,
//   FUNC_PAT_VIEWER,
//   FUNC_TREATMENT_RECORD
// } from "@/constants/function-code.js";
// del #10359 編集権限の動作不正 dengshen end
import PopoverMixin from "@/components/PopoverMixin";
// add 画面印刷プレビューと印刷の実現 陳 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add 画面印刷プレビューと印刷の実現 陳 end
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { popoverPreShowOther, popoverPostShowOther, popoverPosthideOther } from "@/functions/common/CommonPopoverFunctionsOther";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import nameDuplicationImg from "../../assets/name_duplication.png";
import { publicAssetPath } from "@/compat/assets/public-path";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
export default {
  name: "SplitGraphComponent",
  components: {
    highcharts: Chart
  },
  mixins: [NextTransitionMixin, PatHeaderControlMixin,PopoverMixin],
  data() {
    return {
      resizeTimer: null,
      keyGraph: 0,
      popoverKey: 0,
      menuKey: 0,
      searchFlag: false,
      graphType: "line",
      chartHeight: 300,
      transparentColor: "rgba(201, 76, 76, 0)",
      ntssBorder: "thin solid var(--ntss-border-color)",
      ntssBaseBackground: "var(--ntss-base-background-color)",
      ntssBaseColor: "var(--ntss-base-color)",
      DIRECTION: {
        UP: "up",
        RIGHT: "right",
        DOWN: "down",
        LEFT: "left"
      },
      chart: null,
      // ツールチップ
      cloneTooltip: null,
      spanText: "",
      // 患者の一覧をコンテキストメニューで表示する。
      duplicatePlotListVisible: false,
      duplicatePlotListTarget: null,
      duplicatePlotListDirection: "down",
      duplicatePlotList: [],
      keySearch: "",
      filterDuplicatePlotList: [],
      nearRightSide: false,
      // コンテキストメニュー
      menuVisible: false,
      menuTarget: null,
      menuDirection: "right",
      menuList: [
        {
          cd: 0,
          name: "検査結果",
          title: "検査結果画面に遷移します",
          icon: publicAssetPath("img/exam-record/exam-record.png")
        }, {
          cd: 1,
          name: "患者経過総合ビューア",
          title: "患者経過総合ビューア画面に遷移します",
          icon: publicAssetPath("img/pat-viewer/pat-viewer.png")
        }, {
          cd: 2,
          name: "治療記録",
          title: "治療記録画面に遷移します",
          icon: publicAssetPath("img/treatment-record/treatment-record.png")
        }, {
          cd: 3,
          name: "経過に切替",
          title: "経過に切替えます",
          icon: null
        }
      ],
      // 集計情報ポップオーバー
      statisticalElementHeight: 0,
      statisticalElementWidth: 0,
      heightRatioArray: [],
      widthRatioArray: [],
      statisticalInformation: [],
      sumaryAreaMap: [
        [7, 4, 1],
        [8, 5, 2],
        [9, 6, 3]
      ],
      GRAPH_TYPE: {
        PROGRESS: "line",
        DISTRIBUTION: "scatter",
        BLANK: "blank"
      },
      SYMBOL: {
        UPPER: "↑↑",
        UP: "↑",
        LOW: "↓",
        LOWER: "↓↓"
      },
      // グラフ設定
      graphSettings: null,
      // 選択したプロット
      selectedPlot: {
        patInfo: null,
        graphType: null,
        exam: null
      },
      // 選択したエリア
      selectedAreaList: [],
      // 集計表示ONの場合の空のグラフデータ
      BLANK_GRAPH_DATA: [
        {
          name: "",
          type: "scatter",
          data: []
        }
      ],
      // 集計表示ON/OFF時のための分布グラフ・経過グラフのプロットデータ(series)キャッシュ
      graphDataCache: {
        distribution: [],
        progress: []
      },
      // チャートオプション
      chartOptions: {
        chart: {
          type: "scatter",
          height: 300,
          reflow: true,
          events: {
            click: this.onSelectArea,
            redraw: this.redrawGraph,
            load: this.redrawGraph,
            render() {
              const chart = this;
              requestAnimationFrame(() => {
                chart.container
                  .querySelectorAll('.highcharts-tick')
                  .forEach(el => {
                    el.setAttribute('stroke', '#ccd6eb');
                  });
              });
            }
          }
        },
        // プロットオプション
        plotOptions: {
          series: {
            point: {
              events: {
                click: this.onSelectPlot,
                mouseOver: this.customDefaultTooltip
              }
            },
            events: {
              legendItemClick: function() {
                return false;
              }
            }
          }
        },
        credits: {
          enabled: false
        },
        title: false,
        subtitle: false,
        xAxis: {},
        yAxis: {},
        legend: {
          enabled: false,
          itemStyle: {
            fontSize: "1em"
          }
        },
        // FNSI-グラフの操作モーダルを削除 周 add start
        navigation: {
          buttonOptions: {
            enabled: false
          }
        },
        // FNSI-グラフの操作モーダルを削除 周 add end
        series: [
          {
            name: "",
            data: []
          }
        ],
        tooltip: {
          headerFormat: "",
          pointFormat: ""
        }
      },
      examDataLength: 0,
      updatePatientErrorArray: [],
      fontSize: [0.8, 1, 1.1, 1.3],
      currentTab: 1,
      updateSuccessFlag: false,
      // 同姓同名アイコン
      image_src_same: nameDuplicationImg
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth",
      sidebarWidth: "getSidebarWidth"
    }),
    ...mapGetters("split-graph", {
      searchCondition: "getCondition",
      selectedPatient: "getSelectedPatient",
      getGraphType: "getGraphType",
      sumaryArea: "sumaryArea",
      //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
      getSelPat: "getSelPat"
      //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
      getUseFunctions: "getUseFunctions",
      getPatientShareMode: "getPatientShareMode",
      getPatientShareFacilityCdMode: "getPatientShareFacilityCdMode"
    }),
    // mod 機能帳票パラメータ確認 陳 start
    ...mapGetters("pat-info", [
      "searchedPatList",
      "selectedPatId",
      "getIsOtherFacility",
      "getOtherFacilityCd"
    ]),
    // mod 機能帳票パラメータ確認 陳 end

    /**
     * グラフエリア下部にグラフの表示情報を表示する。
     */
    patientFooterInfo() {
      let text = "";
      if (this.graphType === this.GRAPH_TYPE.PROGRESS && this.selectedPatient) {
        // ■「経過」選択時
        let hostPatId = "";
        if (this.selectedPatient.pat_id) {
          let pat = this.searchedPatList.find(
            pat => pat.pat_id === this.selectedPatient.pat_id);
          if (pat) {
            hostPatId = pat.hosp_pat_id;
          }
        }
        //mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou start
        //text = `${hostPatId}\t${this.selectedPatient.pat_last_name} ${this.selectedPatient.pat_first_name}\t`;
        text = `${hostPatId}\t${this.selectedPatient.pat_last_name == null ? "" :this.selectedPatient.pat_last_name} ${this.selectedPatient.pat_first_name == null ? "" : this.selectedPatient.pat_first_name }\t`;
        //mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end
        if (this.searchCondition) {
          text +=
            this.searchCondition.startDate &&
            this.searchCondition.startDate !== ""
              ? simpleDateFormat(this.searchCondition.startDate)
              : "指定なし";
          text += " ～ ";
          text +=
            this.searchCondition.endDate && this.searchCondition.endDate !== ""
              ? simpleDateFormat(this.searchCondition.endDate)
              : "指定なし";
        } else {
          text += "期間指定なし";
        }
      } else if (this.graphType === this.GRAPH_TYPE.DISTRIBUTION) {
        // ■「分布」選択時
        const tmpExamDataLength = this.searchedPatList.length > 0 ? this.examDataLength : 0;
        text = `対象患者：${this.searchedPatList.length}名 検査データあり：${
          tmpExamDataLength
        }名 検査データなし：${this.searchedPatList.length -
          tmpExamDataLength}名`;
      }
      return text;
    }
  },

  watch: {
    sidebarWidth() {
      this.handleResizeGraph();
    },

    async getFontSize() {
      await this.init();
      this.updatePointColor();
    },

    async getGraphType() {
      this.graphType = this.getGraphType;
      this.menuList[3].name =
        this.graphType === this.GRAPH_TYPE.PROGRESS
          ? "分布に切替"
          : "経過に切替";
      await this.init();
      this.updatePointColor();
    },

    /**
     * 集計情報の表示／非表示
     * true: 集計ON
     * false: 集計OFF
     */
    async sumaryArea() {
      this.graphType = this.sumaryArea
        ? this.GRAPH_TYPE.BLANK
        : this.getGraphType;
      // 集計表示ON/OFF時はプロットデータをリロードしない
      await this.init(false);
      this.updatePointColor();
    },

    // 選択患者に対して取得する。
    async selectedPatient() {
      // 経過グラフの選択時（経過グラフで集計表示ON時も含む）
      if (this.graphType === this.GRAPH_TYPE.PROGRESS ||
          this.getGraphType === this.GRAPH_TYPE.PROGRESS) {
        await this.init();
      }
      this.updatePointColor();
    },

    graphType() {
      const sumaryDiv = this.getScopedSelectorSafe("div.sumary-table");
      if (this.graphType === this.GRAPH_TYPE.BLANK) {
        sumaryDiv.style.zIndex = 2020;
      } else {
        sumaryDiv.style.zIndex = -2020;
      }
    },

    getPatientShareMode() {
      this.init();
    },

    getPatientShareFacilityCdMode() {
      this.init();
    }
  },
  methods: {
    getScopedOwnerDocument() {
      return getScopedDocument(this.$el || null);
    },
    getScopedElementByIdSafe(id) {
      return getScopedElementById(id, this.$el || null) || this.getScopedOwnerDocument()?.getElementById?.(id) || null;
    },
    getScopedClassElementSafe(className) {
      return getScopedElementsByClassName(className, this.$el || null)[0] || this.getScopedOwnerDocument()?.getElementsByClassName?.(className)?.[0] || null;
    },
    getScopedClassElementsSafe(className) {
      const scoped = getScopedElementsByClassName(className, this.$el || null);
      return scoped.length ? scoped : Array.from(this.getScopedOwnerDocument()?.getElementsByClassName?.(className) || []);
    },
    getScopedSelectorSafe(selector) {
      return queryScopedSelector(selector, this.$el || null) || this.getScopedOwnerDocument()?.querySelector?.(selector) || null;
    },
    ...mapActions("split-graph", [
      "setSelectedPlot",
      "setExamRecordDate",
      "setValidGraphSettingStatus"
    ]),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("treatment-record/common", {
      setTreatmentRecordOrdNo: "setOrdNo"
    }),
    // add FNSI-FutreNetWeb+SI課題管理No.4091 李 start
    ...mapActions("pat-viewer", ["setTreatBaseDate"]),
    // add FNSI-FutreNetWeb+SI課題管理No.4091 李 end
    ...mapActions("account-edit", [
      "setPatientShareMode",
      "setPatientShareFacilityCdMode"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    popoverPreShowOther,
    popoverPostShowOther,
    popoverPosthideOther,
    
    /** 画面印刷前の処理 */
    handleBeforePrint() {
      const main = document.querySelector(".main-content-area");
      const highchartArea = document.querySelector(".highchart-area");
      const highchartsContainer = document.querySelector(".highcharts-container");
      const bottom = document.querySelector("#bottom-info");
 
      // width退避＆固定
      main.dataset.originalWidth = main.style.width || "";
      main.style.setProperty("width", "1024px", "important");
      
      // overflow制御
      main.style.setProperty("overflow", "visible", "important");
      highchartArea.style.setProperty("overflow", "visible", "important");
      // グラフ再描画
      this.handleResizeGraph();
      // グラフ高さ確定後にmargin設定
      bottom.style.marginTop = highchartsContainer.offsetHeight + "px";
    },
    /** 画面印刷後の処理 */
    handleAfterPrint() {
      const main = document.querySelector(".main-content-area");
      const highchartArea = document.querySelector(".highchart-area");
      const bottom = document.querySelector("#bottom-info");
 
      // width復元
      main.style.width = main.dataset.originalWidth || "";
      delete main.dataset.originalWidth; 
      // overflow削除（important含めて消える）
      main.style.removeProperty("overflow");
      highchartArea.style.removeProperty("overflow");
      // marginクリア
      bottom.style.marginTop = "";
    
      // グラフ戻す
      this.handleResizeGraph();      
    },
    /** グラフ、集計テーブルresize */
    handleResizeGraph() {
      //#9846 start
      // if (this.$refs.highcharts && this.$refs.highcharts.chart) {
      //   this.$refs.highcharts.chart.setSize(null);
      // }
      if (this.$refs.highcharts?.chart) {
        this.$refs.highcharts.chart.reflow();
      }
      //#9846 end
      setTimeout(() => {
        this.redrawGraph();
      }, 500);
    },
    // add 画面印刷プレビューと印刷の実現 陳 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
        var patFalg;
        //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
        // if (this.selectedPatId === null){
        //  patFalg = this.searchedPatList.map(({ pat_id }) => pat_id);
        if (this.getSelPat !== null){
          patFalg = this.getSelPat.map(({ pat_id }) => pat_id);
        //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
        } else{
          patFalg = null;
        }
        //mod 7233 デフォルト帳票について 姜 start
        // 印刷パラメータを応答
        // const params = {
        //  patIds: patFalg,
        //  //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
        //  // patId: this.selectedPatId,
        //  patId: this.selectedPatient.pat_id,
        //  //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
        //  functionCd: param,
        //  date: this.searchCondition.startDate,
        //  fromDate: this.searchCondition.startDate,
        //  toDate: this.searchCondition.endDate
        //};
        var params;
        // 印刷パラメータを応答
        if (this.selectedPatient === null || this.selectedPatient === undefined) {
          params = {
            patIds: patFalg,
            // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
            //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
            // patId: this.selectedPatId,
            //patId: null,
            //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
            // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
            functionCd: param,
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
            // date: this.searchCondition.startDate,
            // fromDate: this.searchCondition.startDate,
            // toDate: this.searchCondition.endDate
            date: this.searchCondition.startDate != null ? this.searchCondition.startDate : (this.searchCondition.endDate != null ? this.searchCondition.endDate : dayjs(Date.now()).format("YYYYMMDD")),
            fromDate: this.searchCondition.startDate != null ? this.searchCondition.startDate : (this.searchCondition.endDate != null ? this.searchCondition.endDate : dayjs(Date.now()).format("YYYYMMDD")),
            toDate: this.searchCondition.endDate != null ? this.searchCondition.endDate : (this.searchCondition.startDate != null ? this.searchCondition.startDate : dayjs(Date.now()).format("YYYYMMDD")),
            // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe start
            //dialysisDate: dayjs(Date.now()).format("YYYYMMDD"),
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
            //dialysisDate: this.searchCondition.startDate != null ? this.searchCondition.startDate : (this.searchCondition.endDate != null ? this.searchCondition.endDate : dayjs(Date.now()).format("YYYYMMDD")),
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
            // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe end
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          };
        } else {
          // add #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe start
          var curDate = new Date();
          // add #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe end
          params = {
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
            //patIds: patFalg,
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
            //dialysisDate: dayjs(Date.now()).format("YYYYMMDD"),
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
            //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
            // patId: this.selectedPatId,
            patId: this.selectedPatient.pat_id,
            //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
            functionCd: param,
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe start
            // date: this.searchCondition.startDate,
            // fromDate: this.searchCondition.startDate,
            // toDate: this.searchCondition.endDate
            date: dayjs(Date.now()).format("YYYY/MM/DD"),
            fromDate: dayjs(Date.now()).format("YYYY/MM/DD"),
            toDate: dayjs(new Date(curDate.setMonth(curDate.getMonth() + 1))).format("YYYY/MM/DD"),
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe end
          };
        }
        //mod 7233 デフォルト帳票について 姜 end
        EventBus.$emit("sendReportParams", params);
      }
    },
    // add 画面印刷プレビューと印刷の実現 陳 end
    onResize() {
      this.duplicatePlotListVisible = false;
      this.menuVisible = false;
      //#9846 start
      // if (this.graphType === this.GRAPH_TYPE.BLANK) {
      //   this.handleResizeGraph();
      // } else {
      //   this.chartOptions.series = [];
      //   (getScopedWindow(this.$el) || window).clearTimeout(this.resizeTimer);
      //   this.resizeTimer = (getScopedWindow(this.$el) || window).setTimeout(async () => {
      //     await this.init();
      //     this.updatePointColor();
      //   }, 500);
      // }
      this.handleResizeGraph();
      //#9846 end
    },
    /**
     * グラフ設定一覧取得用アクション
     */
    async getSettings() {
      await getGraphSettings(this.facilityCd, this.selectedPatId)
        .then(response => {
          if (response.data && response.status === 200) {
            this.graphSettings = response.data;
            formatGraphSettings(this.graphSettings);
          } else {
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES['00100020'].title,
              // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // message: "データがありません",
              message: messageFormat(DIALOG_MESSAGES['00100020'].message),
              // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        })
        .catch(e => {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES['00100020'].title,
            // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // message: "データがありません",
            message: messageFormat(DIALOG_MESSAGES['00100020'].message),
            // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('SplitGraphComponent.vue','getSettings',"データがありません",e);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        });
      // 設定不備の条件
      this.settingValidation();
      if (this.graphSettings) {
        this.setValidGraphSettingStatus(true);
        // Y軸の範囲が表示されない場合
        let fullHeight = Math.abs(
          this.graphSettings.limitUpperY - this.graphSettings.limitLowerY);
        let height1 =
          Math.abs(
            this.graphSettings.limitUpperY -
              this.graphSettings.limitUpperThresholdY) / fullHeight;
        let height2 =
          Math.abs(
            this.graphSettings.limitUpperThresholdY -
              this.graphSettings.limitLowerThresholdY) / fullHeight;
        let height3 =
          Math.abs(
            this.graphSettings.limitLowerThresholdY -
              this.graphSettings.limitLowerY) / fullHeight;
        this.heightRatioArray = [height1, height2, height3];

        // X軸の範囲が表示されない場合
        let fullWidth = Math.abs(
          this.graphSettings.limitUpperX - this.graphSettings.limitLowerX);
        let width1 =
          Math.abs(
            this.graphSettings.limitLowerThresholdX -
              this.graphSettings.limitLowerX) / fullWidth;
        let width2 =
          Math.abs(
            this.graphSettings.limitUpperThresholdX -
              this.graphSettings.limitLowerThresholdX) / fullWidth;
        let width3 =
          Math.abs(
            this.graphSettings.limitUpperX -
              this.graphSettings.limitUpperThresholdX) / fullWidth;
        this.widthRatioArray = [width1, width2, width3];
      }
    },
    /**
     * 設定不備の条件
     */
    settingValidation() {
      let errorStatus = settingErrorMessage(this.graphSettings);
      if (errorStatus) {
        this.graphSettings = null;
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['70000038'].title,
          message: errorStatus
        });
        this.setValidGraphSettingStatus(false);
      }
    },
    /**
     * 初期処理
     * @param {boolean} isDataReloadRequired グラフデータのロード true:あり / false: なし（キャッシュ）
     */
    async init(isDataReloadRequired = true) {
      this.chartOptions.series = isDataReloadRequired ? await this.seriesData() : this.seriesDataCache();
      this.chartOptions.xAxis = this.xAxisData();
      this.chartOptions.xAxis.gridLineWidth = 1;
      this.chartOptions.yAxis = this.yAxisData();
      this.chartOptions.legend = this.legendData();
      this.chartOptions.tooltip = this.tooltipData();
      this.chartOptions.plotOptions.series = {
        ...this.chartOptions.plotOptions.series,
        ...(this.plotOptionsData()?.series || {})
      };

      if ((this.chartOptions?.series || []).length > 0) {
        this.keyGraph++;
      }
    },
    /**
     * 分布グラフ・経過グラフのプロットデータを返す
     * 集計表示ON時は空のプロットデータを返す
     * 取得したグラフデータを集計表示ON/OFF時に使用するためキャッシュする
     */
    async seriesData() {
      // 検索患者リストが１件以上の場合
      if (this.searchedPatList && this.searchedPatList.length > 0) {
        // グラフ表示 | 集計表示 | グラフタイプ | グラフデータの取得契機 | グラフデータの取得と集計処理
        // =======================================================================================
        // 分布グラフ | OFF     | DISTRIBUTION| 患者検索              | 分布グラフ※1
        // 経過グラフ | OFF     | PROGRESS    | 患者検索＋ヘッダ患者選択| 分布グラフ＋経過グラフ※1
        // 分布グラフ | ON      | BLANK       | 患者検索              | 分布グラフ※1 ※2
        // 経過グラフ | ON      | BLANK       | 患者検索＋ヘッダ患者選択| 分布グラフ＋経過グラフ※1 ※2
        // =======================================================================================
        // ※1　グラフ表示＋集計表示毎に必要なグラフデータの取得とキャッシュ
        // ※2　集計表示ON/OFF時はグラフデータ・キャッシュから集計値を表示する

        // 分布グラフのプロットデータを取得してキャッシュする（分布グラフ／経過グラフで共通）
        this.graphDataCache.distribution = await this.distributionGraphSeries();
        // 分布グラフ／経過グラフ／集計表示ON 毎にグラフデータを取得してキャッシュする
        switch(this.graphType) {
          case this.GRAPH_TYPE.DISTRIBUTION:
            return this.graphDataCache.distribution;
          case this.GRAPH_TYPE.PROGRESS:
            this.graphDataCache.progress = await this.progressGraphSeries();
            //mod 63449分割グラフの経過画面から治療記録に遷移し、パンくずリストで９分割グラフ画面に戻ると経過ではなく分布画面が表示される zhao
            return this.graphDataCache.distribution, this.graphDataCache.progress;
          case this.GRAPH_TYPE.BLANK:
            if (this.getGraphType === this.GRAPH_TYPE.PROGRESS) {
              this.graphDataCache.progress = await this.progressGraphSeries();
            }
            break;
        }
      } // 検索患者リストが０件の場合
       else {
        // 空のグラフデータをキャッシュする
        // ※検索患者リストが０件の場合でもプロットデータを更新する（集計表示ON/OFF時の集計値の計算が必要）
        // ※経過グラフで検索患者リストが０件の場合はないので分布グラフデータのみ取得する
        this.graphDataCache.distribution = await this.distributionGraphSeries();
      }
      // 集計表示ONまたは検索患者リストが０件の場合は空のグラフデータを返す
      return this.BLANK_GRAPH_DATA;
    },
    /**
     * 分布グラフ・経過グラフのプロットデータキャッシュを返す
     * 集計表示は空のプロットデータキャッシュを返す
     */
    seriesDataCache() {
      switch(this.graphType) {
        case this.GRAPH_TYPE.DISTRIBUTION:
          return this.graphDataCache.distribution;
        case this.GRAPH_TYPE.PROGRESS:
          return this.graphDataCache.distribution, this.graphDataCache.progress;
        case this.GRAPH_TYPE.BLANK:
        default:
          // 集計表示では空のグラフデータを返す
          return this.BLANK_GRAPH_DATA;
      }
    },
    /**
     * xAxisデータを処理する。
     */
    xAxisData() {
      if (!this.graphSettings) return;
      return {
        title: {
          text:
          //mod 10878 P-Ca9分割グラフ設定マスタで検査マスタ指定が検索で選択できない zhao start
          //   this.graphSettings && this.graphSettings.unitNameX
          //     ? `${this.graphSettings.unitNameX} [${this.graphSettings.unitX}]`
          //     : "",
            this.graphSettings && this.graphSettings.unitNameX && this.graphSettings.unitX
              ? `${this.graphSettings.unitNameX} [${this.graphSettings.unitX}]`
              : this.graphSettings && this.graphSettings.unitNameX ? `${this.graphSettings.unitNameX}` : "",
          //mod 10878 P-Ca9分割グラフ設定マスタで検査マスタ指定が検索で選択できない zhao end
          style: {
            color: this.ntssBaseColor,
            fontSize: "1em"
          }
        },
        min: this.graphSettings.limitLowerX,
        max: this.graphSettings.limitUpperX,
        tickPositions: [
          this.graphSettings.limitLowerX,
          this.graphSettings.limitLowerThresholdX,
          this.graphSettings.limitUpperThresholdX,
          this.graphSettings.limitUpperX
        ],
        labels: {
          style: {
            color: this.ntssBaseColor,
            fontSize: "1em"
          },
          formatter: function() {
            var label = this.axis.defaultLabelFormatter.call(this);
            if (this.value % 1 != 0 && this.value.toString().split(".")[1])
              return DecimalFormat(this.value);
            else return `${label}.0`;
          }
        }
      };
    },
    /**
     * yAxisデータを処理する。
     */
    yAxisData() {
      if (!this.graphSettings) return;
      return {
        title: {
          text:
          //mod 10878 P-Ca9分割グラフ設定マスタで検査マスタ指定が検索で選択できない zhao start
            // this.graphSettings && this.graphSettings.unitNameY
            //   ? `${this.graphSettings.unitNameY} [${this.graphSettings.unitY}]`
            //   : "",
            this.graphSettings && this.graphSettings.unitNameY && this.graphSettings.unitY
              ? `${this.graphSettings.unitNameY} [${this.graphSettings.unitY}]`
              : this.graphSettings && this.graphSettings.unitNameY ? `${this.graphSettings.unitNameY}` : "",
          //mod 10878 P-Ca9分割グラフ設定マスタで検査マスタ指定が検索で選択できない zhao end
          style: {
            color: this.ntssBaseColor,
            fontSize: "1em"
          }
        },
        min: this.graphSettings.limitLowerY,
        max: this.graphSettings.limitUpperY + 1 / 1000,
        tickPositions: [
          this.graphSettings.limitLowerY,
          this.graphSettings.limitLowerThresholdY,
          this.graphSettings.limitUpperThresholdY,
          this.graphSettings.limitUpperY,
          this.graphSettings.limitUpperY + 1 / 1000
        ],
        labels: {
          style: {
            color: this.ntssBaseColor,
            fontSize: "1em"
          },
          formatter: function() {
            var label = this.axis.defaultLabelFormatter.call(this);
            if (this.value % 1 != 0 && this.value.toString().split(".")[1])
              return DecimalFormat(this.value);
            else return `${label}.0`;
          }
        }
      };
    },
    /**
     * グラフの凡例情報を設定する。
     */
    legendData() {
      if (this.graphType === this.GRAPH_TYPE.PROGRESS) {
        return {
          enabled: true,
          layout: "vertical",
          align: "left",
          verticalAlign: "top",
          floating: true,
          borderWidth: 1,
          itemStyle: {
            fontSize: "1em !important"
          }
        };
      } else {
        return { enabled: false };
      }
    },
    /**
     * ツールチップデータを処理する。
     */
    tooltipData() {
      let format = "";
      if (this.graphType === this.GRAPH_TYPE.PROGRESS) {
        format = `
          {point.date}<br>
          {point.xAxisName}：{point.overX}{point.unitX} {point.xStatus}<br>
          {point.yAxisName}：{point.overY}{point.unitY} {point.yStatus}
        `;
      } else {
        format = `
          ID：{point.hostPatId}<br>
          {point.name}<br>
          {point.date}<br>
          {point.xAxisName}：{point.overX}{point.unitX} {point.xStatus}<br>
          {point.yAxisName}：{point.overY}{point.unitY} {point.yStatus}
        `;
      }
      return {
        useHTML: true,
        borderWidth: 0,
        shadow: false,
        headerFormat: "",
        pointFormat: format,
        backgroundColor: this.transparentColor,
        style: {
          color: this.ntssBaseColor,
          fontSize: "1em"
        },
        positioner: this.positioner
      };
    },
    /**
     * プロットオプションデータを処理する。
     */
    plotOptionsData() {
      if (!this.graphSettings) return;
      return {
        series: {
          cursor: "pointer",
          marker: {
            states: {
              select: {
                fillColor: this.graphSettings.plotSelectedColor,
                lineWidth: 0
              }
            },
            radius: this.graphSettings.plotSize
          },
          states: {
            inactive: {
              opacity: 1
            }
          },
          stickyTracking: false,
          lineWidth:
            this.graphType === this.GRAPH_TYPE.PROGRESS
              ? this.graphSettings.seriesLineWidth
              : 0,
          animation: {
            complete: this.updatePointColor
          }
        }
      };
    },
    /**
     * エリアを選択する時、データを処理する。
     */
    onSelectArea() {
      if (this.graphType != this.GRAPH_TYPE.DISTRIBUTION) {
        // 他のグラフタイプを選択するのは防ぐ
        return;
      }
      let area = this.getArea(event.xAxis[0].value, event.yAxis[0].value);

      // 対象エリアに対象患者グループマスタが割り当てられていない場合はメッセージを表示して処理を中断
      if (
        !(
        this.graphSettings[`patientGroupArea${area}`] !== null &&
        this.graphSettings[`patientGroupArea${area}`] !== "" &&
        this.graphSettings[`patientGroupArea${area}`].toString() !== "0")) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['70000037'].title,
          message: messageFormat(DIALOG_MESSAGES['70000037'].message, area),
        });
        return;
      }

      if (this.selectedAreaList.includes(area)) {
        this.selectedAreaList = this.selectedAreaList.filter(
          item => item !== area);
      } else {
        this.selectedAreaList.push(area);
      }
    },
    /**
     * 画面に合わせてグラフのサイズを計算します
     */
    redrawGraph() {
      const main = getClosestMainContentAreaElement(this.$el) || getMainContentAreaElement(this.$el);
      const rect = this.getScopedSelectorSafe("rect.highcharts-background");
      const areaWrapper = this.getScopedSelectorSafe("rect.highcharts-plot-background");
      const bottomInfo = this.getScopedElementByIdSafe("bottom-info");
      if (main && rect) {
        const newHeight = main.offsetHeight - 12 - bottomInfo.offsetHeight;
        this.chartHeight = newHeight < 300 ? 300 : newHeight;
        this.chartOptions.chart.height = this.chartHeight;
        //#9846 start
        if (this.$refs.highcharts?.chart) {
          this.$refs.highcharts.chart.setSize(undefined, this.chartHeight, false);
        }
        //#9846 end
        rect.style.fill = "unset";
        rect.style.opacity = "0";
        // チャートのサイズを使用して、合計情報テーブルに適用します
        const xAxis = this.getScopedSelectorSafe(".highcharts-axis-line");
        this.statisticalElementWidth = xAxis
          ? xAxis.getBoundingClientRect().width
          : 0;
        const yAxis = this.getScopedSelectorSafe(".highcharts-grid-line");
        this.statisticalElementHeight = yAxis
          ? yAxis.getBoundingClientRect().height
          : 0;
        const sumary = this.getScopedSelectorSafe(".sumary-table");
        sumary.style.top = `${areaWrapper.attributes.y.value}px`;
        sumary.style.left = `${areaWrapper.attributes.x.value}px`;
        sumary.style.width = `${areaWrapper.attributes.width.value}px`;
        sumary.style.height = `${areaWrapper.attributes.height.value}px`;
        const highchartLegend = this.getScopedSelectorSafe(".highcharts-legend");
        if (highchartLegend && highchartLegend.attributes.transform) {
          highchartLegend.attributes.transform.value = `translate(${areaWrapper.attributes.x.value},${areaWrapper.attributes.y.value})`;
        }
      }
    },
    // チャートシリーズ
    /**
     * 折れ線は、検査日の時間軸でプロットを繋げる。
     * プロット対象となる検査結果の最新の検査日を基準として、
     * 1～6月、7～12月の期間ごと(最大4期間)に、
     * プロットおよび線の色を各設定色にする。
     * それより古い期間は、隣接する末尾期間と同等とする。
     */
    async progressGraphSeries() {
      if (!this.selectedPatient) return;
      let retData = [];
      const params = {
        patId: this.selectedPatient.pat_id,
        body: {
          regOrderClass: this.categoryList(this.graphSettings.examCategory),
          examItemX: this.graphSettings.examItemCdX.toString(),
          examItemY: this.graphSettings.examItemCdY.toString(),
          resultExamDateFrom:
            this.searchCondition.startDate === ""
              ? null
              : this.searchCondition.startDate,
          resultExamDateTo:
            this.searchCondition.endDate === ""
              ? null
              : this.searchCondition.endDate,
          facilityCd: this.facilityCd,
          patientShareMode:
            this.getIsOtherFacility === false ||
            (this.getOtherFacilityCd !== null &&
              this.getOtherFacilityCd !== this.facilityCd)
              ? "1"
              : this.getPatientShareMode.toString()
        }
      };
      let examPoints = [];
      await sendRequestGetProgressGraph(params, this.selectedPatient.pat_id)
        .then(response => {
          if (response.status === 200 && response.data) {
            examPoints = [...response.data];
          }
        })
        .catch(e => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('SplitGraphComponent.vue','progressGraphSeries',e);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        });
      let sortedData = simpleSort(examPoints, "date");
      let dateRange = periods(sortedData);
      let sortIndex = 100;
      dateRange.forEach((range, index) => {
        let isEndRange = false;
        let duration = {
          name: this.legendName(range),
          data: this.progressGraphData(sortedData, range),
          color: this.graphSettings[`lineProgress${index + 1}Color`],
          lineWidth : this.graphSettings.seriesLineWidth,
          marker: {
            symbol: "default",
            fillColor: this.graphSettings[`plotProgress${index + 1}Color`],
            radius: this.graphSettings.plotSize
          },
          // 現在から過去への順序で並べ替え
          legendIndex: sortIndex++
        };
        // 現在の期間の最初のプロットと過去の隣接期間の最後のプロットをリンクするには
        let beforeRangeIndex = index - 1;
        while (beforeRangeIndex > -1) {
          let bfData = retData[beforeRangeIndex].data;
          const bfDataLength = bfData.length;
          if (
            bfData &&
            bfDataLength > 0 &&
            duration.data &&
            duration.data.length > 0) {
            let clonePlot = { ...bfData[bfDataLength - 1] };
            clonePlot.linkedPoint = true;
            duration.data.unshift(clonePlot);
            break;
          }
          beforeRangeIndex--;
        }
        //
        retData.push(duration);
      });
      return retData;
    },
    /**
     * yyyy/mm/dd〜yyyy/mm/dd は yyyy/mm〜mm に変更されます
     */
    legendName(range) {
      let startDate = dayjs(range.start, "YYYY/MM/DD");
      let endDate = dayjs(range.end, "YYYY/MM/DD");
      // 凡例4期目は2年以上遡るデータも含めて表示するため、全て年・月ともに表示
      return `${startDate.format("YYYY")}/${startDate.format(
        "M")}～${endDate.format("YYYY")}/${endDate.format("M")}`;
    },
    /**
     * 散布シリーズ
     */
    async distributionGraphSeries() {
      return [
        {
          name: "",
          type: this.GRAPH_TYPE.DISTRIBUTION,
          color: this.graphSettings.plotColor,
          marker: {
            radius: this.graphSettings.plotSize
          },
          data: await this.distributionGraphData()
        }
      ];
    },

    // 一連のチャートのデータ
    /**
     * ラインデータ
     */
    progressGraphData(examPoints, range) {
      let data = getExamInRange(examPoints, range.start, range.end);
      this.updatePlotOutsideColor(this.cookingData(data));
      return data;
    },
    /**
     * カテゴリーの一覧を取得する。
     */
    categoryList(id) {
      let ret = [];
      switch (id) {
        case "0":
          ret = ["1"];
          break;
        case "1":
          ret = ["2"];
          break;
        case "2":
          ret = ["0"];
          break;
        case "3":
          ret = ["1", "2"];
          break;
        case "4":
          ret = ["0", "1"];
          break;
        case "5":
          ret = ["0", "2"];
          break;
      }
      return JSON.stringify(ret);
    },
    /**
     * 散布データ
     */
    async distributionGraphData() {
      let data = [];
      if (!this.searchedPatList || this.searchedPatList.length === 0) {
        this.statisticalInformation = this.getSumaryAreaData([]);
        this.examDataLength = 0;
        return [];
      }
      const params = {
        regOrderClass: this.categoryList(this.graphSettings.examCategory),
        examItemX: this.graphSettings.examItemCdX.toString(),
        examItemY: this.graphSettings.examItemCdY.toString(),
        resultExamDateFrom:
          this.searchCondition.startDate === ""
            ? null
            : this.searchCondition.startDate,
        resultExamDateTo:
          this.searchCondition.endDate === ""
            ? null
            : this.searchCondition.endDate,
        facilityCd: this.facilityCd,
        patList: JSON.stringify(this.searchedPatList.map(pat => pat.pat_id)),
        patientShareMode:
          this.getIsOtherFacility === false ||
          (this.getOtherFacilityCd !== null &&
            this.getOtherFacilityCd !== this.facilityCd)
            ? "1"
            : this.getPatientShareMode.toString()
      };
      await sendRequestGetDistributionGraph(params, this.selectedPatId)
        .then(response => {
          if (
            response.status === 200 &&
            response.data &&
            response.data.length > 0) {
            data = [...response.data];
            this.updatePlotOutsideColor(this.cookingData(data));
            EventBus.$emit("setPatList", data.map(pat => pat.patId));
            // mod FNSI-選択している患者での表示とする 楊 start
          } else if (response.status === 200 &&
            response.data) {
            EventBus.$emit("setPatList", data.map(pat => pat.patId));
          }
          // mod FNSI-選択している患者での表示とする 楊 end
        })
        .catch(e => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('SplitGraphComponent.vue','distributionGraphData',e);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        });
      this.statisticalInformation = this.getSumaryAreaData(data);
      this.examDataLength = data.length;
      // add #10977 インジェクション対応 linjunfeng start
      for(let item of data) {
        if (item.name == null) {
          continue;
        }
        if (item.name.length > 28) {
          item.name = item.name.substring(0, 28).replace(/</g, '&lt;').replace(/>/g, '&gt;') + "...";
        }
      }
      // add #10977 インジェクション対応 linjunfeng end
      this.updatePointColor();
      return data;
    },
    /**
     * エリア処理
     */
    getArea(x, y) {
      let areaX = 0;
      let areaY = 0;
      if (x > this.graphSettings.limitUpperThresholdX) {
        areaX = 2;
        if (this.widthRatioArray[2] === 0) areaX = 1;
      }
      if (x <= this.graphSettings.limitUpperThresholdX) {
        areaX = 1;
        if (this.widthRatioArray[1] === 0) areaX = 2;
      }
      if (x < this.graphSettings.limitLowerThresholdX) {
        areaX = 0;
      }
      if (y > this.graphSettings.limitUpperThresholdY) {
        areaY = 0;
        if (this.heightRatioArray[0] === 0) areaY = 1;
      }
      if (y <= this.graphSettings.limitUpperThresholdY) {
        areaY = 1;
        if (this.heightRatioArray[1] === 0) areaY = 0;
      }
      if (y < this.graphSettings.limitLowerThresholdY) {
        areaY = 2;
      }
      return this.sumaryAreaMap[areaY][areaX];
    },
    /**
     * グラフ設定
     */
    cookingData(data) {
      if (data && data.length > 0) {
        data.forEach(plot => {
          plot.name = this.getPatName(plot.patId);
          plot.date = simpleDateFormat(plot.date);
          plot.xAxisName = this.graphSettings.unitNameX;
          plot.yAxisName = this.graphSettings.unitNameY;
          plot.x = parseFloat(plot.x);
          plot.y = parseFloat(plot.y);
          plot.overX = plot.x;
          plot.overY = plot.y;
          // 範囲ステータス
          // X軸
          plot.xStatus = "";
          plot.yStatus = "";
          // add FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 start
          var flgX = true;
          var flgY = true;
          // add FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 end
          // 検査値 < グラフ下限値
          if (plot.x < this.graphSettings.limitLowerX) {

            plot.x = this.graphSettings.limitLowerX;
            plot.xStatus = this.SYMBOL.LOWER;
            // add FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 start
            flgX = false;
            // add FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 end
          }
          // グラフ下限値 <= 検査値 < グラフ閾値下限
          // mod FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 start
          // if (
          //   this.graphSettings.limitLowerX <= plot.x &&
          //   plot.x < this.graphSettings.limitLowerThresholdX
          // ) {

          //   plot.xStatus = this.SYMBOL.LOW;
          // }
          if(flgX){
            if (
            this.graphSettings.limitLowerX <= plot.x &&
            plot.x < this.graphSettings.limitLowerThresholdX) {

              plot.xStatus = this.SYMBOL.LOW;
            }
          }
          // mod FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 end
          // グラフ閾値上限 < 検査値 <= グラフ上限値
          if (
            this.graphSettings.limitUpperThresholdX < plot.x &&
            plot.x <= this.graphSettings.limitUpperX) {
            plot.xStatus = this.SYMBOL.UP;
          }
          // グラフ上限値 < 検査値
          if (this.graphSettings.limitUpperX < plot.x) {
            plot.x = this.graphSettings.limitUpperX;
            plot.xStatus = this.SYMBOL.UPPER;
          }
          // Y軸
          // 検査値 < グラフ下限値
          if (plot.y < this.graphSettings.limitLowerY) {
            plot.y = this.graphSettings.limitLowerY;
            plot.yStatus = this.SYMBOL.LOWER;
            // add FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 start
            flgY = false;
            // add FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 end
          }
          // グラフ下限値 <= 検査値 < グラフ閾値下限
          // mod FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 start
          // if (
          //   this.graphSettings.limitLowerY <= plot.y &&
          //   plot.y < this.graphSettings.limitLowerThresholdY
          // ) {
          //   plot.yStatus = this.SYMBOL.LOW;
          // }
          if(flgY){
            if (
            this.graphSettings.limitLowerY <= plot.y &&
            plot.y < this.graphSettings.limitLowerThresholdY) {
              plot.yStatus = this.SYMBOL.LOW;
            }
          }
          // mod FNSI-改修内容P-Ca9分割図	バグ	Y軸のエリア外で↓↓の表現にならない 赵 end
          // グラフ閾値上限 < 検査値 <= グラフ上限値
          if (
            this.graphSettings.limitUpperThresholdY < plot.y &&
            plot.y <= this.graphSettings.limitUpperY) {
            plot.yStatus = this.SYMBOL.UP;
          }
          // グラフ上限値 < 検査値
          if (this.graphSettings.limitUpperY < plot.y) {
            plot.y = this.graphSettings.limitUpperY;
            plot.yStatus = this.SYMBOL.UPPER;
          }
          // プロット エリア
          plot.areaIndex = this.getArea(plot.x, plot.y);
          // 単位
          plot.unitX = this.graphSettings.unitX;
          plot.unitY = this.graphSettings.unitY;
          // 院内の患者ID
          plot.hostPatId = "";
          if (plot.patId) {
            let pat = this.searchedPatList.find(
              pat => pat.pat_id.toString() === plot.patId);
            if (pat) {
              plot.hostPatId = pat.hosp_pat_id;
            }
          }
        });
      }
      return data;
    },

    updatePlotOutsideColor(data) {
      if (data && data.length > 0) {
        let outsidePlotList = data.filter(
          plot => plot.overX != plot.x || plot.overY != plot.y);
        outsidePlotList.forEach(outSideplot => {
          let duplicatePlotList = data.filter(
            plot => plot.x === outSideplot.x && plot.y === outSideplot.y);
          duplicatePlotList.forEach(dupPlot => {
            dupPlot.color = this.graphSettings.plotOutsideColor;
            dupPlot.marker =
              this.graphType === this.GRAPH_TYPE.PROGRESS
                ? {
                    fillColor: this.graphSettings.plotOutsideColor
                  }
                : null;
          });
        });
      }
    },

    /**
     * 患者IDに一致する患者名を取得する。
     */
    getPatName(id) {
      let pat = null;
      if (id) {
        pat = this.searchedPatList.find(
          pat => pat.pat_id.toString() === id.toString());
      }
      //mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou start
      //return pat ? `${pat.pat_last_name} ${pat.pat_first_name}` : "";
      return pat ? `${pat.pat_last_name == null ? "" : pat.pat_last_name} ${pat.pat_first_name == null ? "" : pat.pat_first_name}` : "";
      //mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end
    },

    /**
     * svgパスを要素として使用できないため、ポップオーバーを表示する要素を作成します
     */
    onSelectPlot(event) {
      // 表エリアに縦スクロールが発生していた場合、スクロールしていた分だけeventから取得できる高さがズレます
      let scrollTop = 0;
      let caObj = this.getScopedClassElementsSafe ? this.getScopedClassElementsSafe("highchart-area") : getScopedElementsByClassName("highchart-area", this.$el || null);
      if (caObj.length > 0) {
        scrollTop = caObj[0].scrollTop;
      }
      let _this = this;

      if (event.target.classList.contains("highcharts-tracker-line")) {
        return;
      }
      this.keySearch = "";
      let ls = [];
      this.$refs.highcharts.chart.series.forEach(series => {
        if (series.points) {
          ls = ls.concat(series.points);
        }
      });
      this.duplicatePlotList = ls.filter(
        plot =>
          plot.x === event.point.x &&
          plot.y === event.point.y &&
          !plot.linkedPoint);
      this.filterDuplicatePlotList = this.duplicatePlotList.slice();
      let virtualPoint = this.getScopedElementByIdSafe("virtualPoint");
      if (!virtualPoint) {
        const appendTarget = getClosestMainContentAreaElement(this.$el)
          || getMainContentAreaElement(this.$el)
          || this.getScopedOwnerDocument?.()?.body
          || this.$el?.ownerDocument?.body
          || null;
        const ownerDocument = appendTarget?.ownerDocument || this.getScopedOwnerDocument?.() || this.$el?.ownerDocument || document;
        virtualPoint = ownerDocument.createElement("label");
        virtualPoint.id = "virtualPoint";
        appendScopedChild(appendTarget || ownerDocument.body, virtualPoint);
      }
      this.duplicatePlotListVisible = null;
      this.menuVisible = null;

      virtualPoint.style.position = "absolute";
      virtualPoint.style.top = `${event.offsetY - scrollTop}px`;
      virtualPoint.style.left = `${event.offsetX}px`;
      virtualPoint.onclick = function() {
        if (_this.duplicatePlotList.length > 1) {
          // プロット(患者)が重複している場合
          // また、患者の一覧をコンテキストメニューで表示する。
          // 一覧に表示されている患者をクリックすることで、画面切替コンテキストメニューを表示する。
          _this.showDuplicatePlotList(this);
        } else {
          // プロット(患者)が重複していない場合：
          // プロットの内容をツールチップ表示する。
          // また、画面切替コンテキストメニューを表示する。
          _this.showMenu(this, event.point);
        }
      };
      if (this.windowHeight - event.y < 220) {
        this.duplicatePlotListDirection = this.DIRECTION.UP;
        this.menuDirection = this.DIRECTION.UP;
      } else {
        this.duplicatePlotListDirection = this.DIRECTION.DOWN;
        this.menuDirection = this.DIRECTION.DOWN;
      }
      virtualPoint.click();
    },
    /**
     * ツールチップデフォルト設定
     */
    customDefaultTooltip(event) {
      let highchartTooltip = null;
      let highchartTooltipLabel = null;
      const ownerWindow = getScopedWindow(this.$el) || window;
      let posInterval = ownerWindow.setInterval(() => {
        highchartTooltip = this.getScopedSelectorSafe("div.highcharts-label.highcharts-tooltip");
        highchartTooltipLabel = this.getScopedSelectorSafe("div.highcharts-label.highcharts-tooltip>span");
        if (highchartTooltip && highchartTooltipLabel) {
          let ls = [];
          if (this.$refs.highcharts && this.$refs.highcharts.chart) {
            this.$refs.highcharts.chart.series.forEach(series => {
              if (series.points) {
                ls = ls.concat(series.points);
              }
            });
          }
          let sameList = ls.filter(
            plot =>
              plot.x === event.target.x &&
              plot.y === event.target.y &&
              !plot.linkedPoint);
          let _this = this;
          this.spanText = "";
          // プロット(患者)が重複している場合
          // 重複しているプロットの内容を1つの表示枠でツールチップ表示する。(順序は患者リストの昇順とする。)
          if (this.graphType === this.GRAPH_TYPE.DISTRIBUTION) {
            sameList.forEach((point, index) => {
              _this.spanText += `ID：${point.hostPatId}<br>
              ${point.name}<br>
              ${point.date}<br>
              ${point.xAxisName}：${point.overX}mg/dL ${point.xStatus}<br>
              ${point.yAxisName}：${point.overY}mg/dL ${point.yStatus}<br>`;
              if (index !== sameList.length - 1) {
                _this.spanText += "<br>";
              }
            });
          } else {
            sameList.forEach(point => {
              _this.spanText += `
                  ${point.date}<br>
                  ${point.xAxisName}：${point.overX}mg/dL ${point.xStatus}<br>
                  ${point.yAxisName}：${point.overY}mg/dL ${point.yStatus}<br>`;
            });
          }
          if (sameList.length > 1) {
            highchartTooltip.style.visibility = "hidden";
            highchartTooltipLabel.innerHTML = _this.spanText;
            setTimeout(() => {
              if (
                Math.abs(highchartTooltip.offsetTop - event.target.plotY) > 5) {
                highchartTooltip.style.top = `${event.target.plotY -
                  highchartTooltipLabel.offsetHeight -
                  8}px`;
              }
              highchartTooltip.style.visibility = "visible";
            }, 100);
          }
          highchartTooltipLabel.style.padding = "8px";
          highchartTooltipLabel.style.color = this.ntssBaseColor;
          highchartTooltipLabel.style.backgroundColor = this.ntssBaseBackground;
          highchartTooltipLabel.style.border = this.ntssBorder;
          ownerWindow.clearInterval(posInterval);
        }
      }, 100);
    },
    /**
     * ポジション設定
     */
    positioner(labelWidth, labelHeight, point) {
      if (this.$refs.highcharts) {
        let chart = this.$refs.highcharts.chart;
        let topSideLimit = labelHeight - 16;
        let rightSideLimit =
          chart.chartWidth - 2 * labelWidth - chart.marginRight;
        return {
          x:
            point.plotX < rightSideLimit
              ? point.plotX + labelWidth / 2 + 8
              : point.plotX - labelWidth / 2 + 8,
          y:
            point.plotY > topSideLimit ? point.plotY - labelHeight : point.plotY
        };
      }
    },
    /**
     * プロット(患者)が重複している場合
     */
    showDuplicatePlotList(event) {
      this.duplicatePlotListTarget = event;
      this.duplicatePlotListVisible = true;
      this.popoverKey += 1;
    },
    /**
     * メニューを表示
     */
    showMenu(event, data) {
      if (this.duplicatePlotListVisible) {
        const alignLeft = event.offsetLeft ? event.offsetLeft : event.screenX;
        if (this.windowWidth - alignLeft < 220 || this.nearRightSide) {
          this.menuDirection = this.DIRECTION.LEFT;
        } else {
          this.menuDirection = this.DIRECTION.RIGHT;
        }
      }
      if (this.graphType === this.GRAPH_TYPE.DISTRIBUTION) {
        this.selectedPlot.patInfo = data;
        this.selectedPlot.exam = null;
      } else {
        this.selectedPlot.patInfo = null;
        this.selectedPlot.exam = data;
      }
      this.menuTarget = event;
      this.menuVisible = true;
      this.menuKey += 1;
    },
    /**
     * 別のページに移動
     */
    async goToPage(menu) {
      this.duplicatePlotListVisible = false;
      this.menuVisible = false;
      const patId = this.selectedPlot.patInfo
        ? this.selectedPlot.patInfo.patId
        : this.selectedPatient.pat_id;
      const examDate = this.selectedPlot.exam
        ? this.selectedPlot.exam.date
        : this.selectedPlot.patInfo.date;
      switch (menu.cd) {
        case 0:
          // 検査結果
          // 選択患者の検査結果画面を表示する。
          // ・抽出期間
          // 表示対象患者の検査日の前後2ヶ月

          this.selectPat(patId).then(() => {
            this.setExamRecordDate(examDate);
            //mod FNSI-FutreNetWeb+SI課題管理No.6336 ljx start
            // 検査結果画面へ遷移
            // mode 9272 by kangjie 20231121 start
            this.$router.push({
              name: "exam-record"
            });
            // mode 9272 by kangjie 20231121 start
            //mod FNSI-FutreNetWeb+SI課題管理No.6336 ljx end
            this.$router.push({
              name: "exam-record-detail"
            });
          });
          break;
        case 1:
          // 患者経過総合ビューア
          // 選択患者の患者経過総合ビューア画面を表示する。
          // ・表示対象日
          // 表示対象患者を本日日付で表示
          // 治療日を設定し、患者経過総合ビューア画面に遷移
          // mod FNSI-FutreNetWeb+SI課題管理No.6333 ljx start
          this.selectPat(patId).then(() => {
            this.setTreatBaseDate(examDate);
            this.$router.push({
              name: "pat-viewer"
            });
          });
          // this.setSelectedPatHeader(patId).then(() => {
          //   this.$nextTick(() => {
          //     this.$router.push({
          //       name: "pat-viewer"
          //     });
          //   });
          // });
          // mod FNSI-FutreNetWeb+SI課題管理No.6333 ljx end
          break;
        case 2:
          // 治療記録
          // 選択患者の治療記録画面を表示する。
          await this.initOrdNoList(patId);
          break;
        case 3:
          // 経過(or分布)に切替
          // グラフを「経過」(or「分布」)表示に切り替える。
          // ・「分布」から「経過」切替時、初期選択患者はクリックで選択した患者とする。
          this.selectedPlot.graphType =
            this.graphType === this.GRAPH_TYPE.PROGRESS
              ? this.GRAPH_TYPE.DISTRIBUTION
              : this.GRAPH_TYPE.PROGRESS;
          EventBus.$emit("setHeaderInfo", this.selectedPlot);
          break;
      }
    },
    /**
     * 各エリアの情報を入手
     */
    getAreaInfo(index) {
      if (
        this.statisticalInformation &&
        this.statisticalInformation[index - 1]) {
        return this.statisticalInformation[index - 1];
      }
      return {
        title: "0%(0名/0)",
        content: []
      };
    },
    /**
     * データリストをフィルターする。
     */
    onPopoverFilter() {
      if (this.menuVisible) {
        this.menuVisible = false;
      }
      this.filterDuplicatePlotList = this.duplicatePlotList.filter(
        this.isInclude);
    },
    /**
     * 項目保存チェック
     * trueの値はあります。
     */
    isInclude(item) {
      if (this.graphType === this.GRAPH_TYPE.DISTRIBUTION) {
        return item.name.includes(this.keySearch);
      } else {
        return this.shortDateFormat(item.date).includes(this.keySearch);
      }
    },
    /**
     * ポイント色を更新する。
     */
    updatePointColor() {
      if (this.$refs.highcharts && this.$refs.highcharts.chart) {
        const chart = this.$refs.highcharts.chart;
        if (this.graphType === this.GRAPH_TYPE.DISTRIBUTION &&
          chart.series[0] &&
          chart.series[0].points.length > 0) {
          let activePlot = null;
          if (this.selectedPatient) {
            // 選択患者のプロット
            activePlot = chart.series[0].points.find(p => Number(p.patId) === this.selectedPatient.pat_id);
          }
          if (activePlot) {
            // 選択患者のプロット座標と同じ座標のすべてのプロット
            // ※複数のプロットが同じ座標になる場合がある
            const dupList = chart.series[0].points.filter(p => p.x === activePlot.x && p.y === activePlot.y);
            // プロットの色（選択患者）に変更する
            dupList.forEach(dp => {
              // このポイントを選択して、他のポイントは選択解除する
              // https://api.highcharts.com/class-reference/Highcharts.Point#select
              dp.select(true, false);
            });
          } // 選択患者が未選択の場合と選択患者のプロットがない場合は全てのポイントの選択状態を解除する
          else {
            // このポイントと選択した他のポイントを選択解除する
            chart.series[0].points[0].select(false, false);
          }
        }
      }
    },

    validateBeforeUpdate() {
      // エリア未選択の場合、メッセージを表示し、患者グループを更新しない。
      if (!this.selectedAreaList || this.selectedAreaList.length === 0) {
        this.$ons.notification.alert({
          // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "",
          // message: "エリアが選択されていません",
          title: DIALOG_MESSAGES['00100021'].title,
          message: messageFormat(DIALOG_MESSAGES['00100021'].message),
          // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      let areaObjectList = this.getAreaObjectList();
      let areaHasGroup = this.getAreaHasGroup(areaObjectList);
      this.updatePatientGroupConfirmation(areaHasGroup);
    },

    // 選択エリア取得
    getAreaObjectList() {
      let validAreaList = [];
      this.selectedAreaList.forEach(area => {
        let areaPoints = this.$refs.highcharts.chart.series[0].points.filter(
          p => p.areaIndex === area);
        validAreaList.push({
          patArea: area,
          patList: JSON.stringify(areaPoints.map(p => parseInt(p.patId))),
          patGroupCd: this.graphSettings[`patientGroupArea${area}`]
        });
      });
      return validAreaList;
    },

    // 患者グループ取得
    getAreaHasGroup(areas) {
      let hasGroupList = [];
      areas.forEach(area => {
        if (
          this.graphSettings[`patientGroupArea${area.patArea}`] !== null &&
          this.graphSettings[`patientGroupArea${area.patArea}`] !== "" &&
          this.graphSettings[`patientGroupArea${area.patArea}`].toString() !== "0") {
          hasGroupList.push(area);
        }
      });
      return hasGroupList;
    },

    /**
     * 患者グループ更新実施時、確認メッセージを表示する。
     * (「はい」「いいえ」の選択式)
     */
    updatePatientGroupConfirmation(areas) {
      // 患者グループ更新実施時、確認メッセージを表示する。
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "",
        title: DIALOG_MESSAGES[13000130].title,
        // message: `患者グループを更新します<br>
        //   よろしいですか？`,
        message: messageFormat(DIALOG_MESSAGES[13000130].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            if (areas.length > 0) {
              let params = {
                facilityCd: this.facilityCd,
                body: areas
              };
              this.onUpdate(params);
            } else {
              this.showUpdateErrorMessage();
            }
          }
        }
      });
    },

    onUpdate(params) {
      // mod bug 7940 修正 chen start
      let groupIdList = [];
      for (let i = 1; i < 10; i++) {
        groupIdList.push(this.graphSettings[`patientGroupArea${i}`]);
      }
      params.groupIdList = groupIdList;
      // sendRequestUpdatePatientGroup(params)
      sendRequestUpdatePatientGroupByGroup(params)
      // mod bug 7940 修正 chen end
        .then(response => {
          if (response.status === 200) {
            this.updateSuccessFlag = true;
            this.showUpdateErrorMessage();
          }
        })
        .catch(e => {
          let response = e.response;
          if (response && response.status === 400) {
            let errorStatus =
              "選択エリアの患者グループが削除されているため更新できません。";
            let errorData = response.data;
            if (errorData.length > 0) {
              errorStatus += "<br>対象エリア：";
              errorData.forEach((err, index) => {
                if (index !== 0) {
                  errorStatus += "、";
                }
                errorStatus += `エリア${err.patGroupArea}`;
                if (err.patGroupName) {
                  errorStatus += `（患者グループ名：${err.patGroupName}）`;
                }
              });
            }
            this.updatePatientErrorArray.push(errorStatus);
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
            getErrorMessage('SplitGraphComponent.vue','onUpdate',errorStatus);
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          }
          this.showUpdateErrorMessage();
        });
    },
    /**
     * 選択されたエリアは以下の条件を満たす場合に関して、
     * ・本エリアに一つのプロットでもない。
     * ・本エリアに患者グループを設定しない。
     * aとbを含む1つのメッセージとして表示します。
     */
    showUpdateErrorMessage() {
      if (this.updatePatientErrorArray.length > 0) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['70000039'].title,
          message: this.updatePatientErrorArray.join("<br>"),
          callback: () => {
            if (this.updateSuccessFlag) {
              this.$ons.notification.alert({
                // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "",
                // message: "患者グループを更新しました。",
                title: DIALOG_MESSAGES[12000235].title,
                message: messageFormat(DIALOG_MESSAGES[12000235].message),
                // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                // #11308 P-Caグラフで患者グループ更新時にコンソールエラー(TypeError)発生 linjunfeng start
                // callback: this.updateSuccessFlag = false
                callback: () => {
                  this.updateSuccessFlag = false
                }
                // #11308 P-Caグラフで患者グループ更新時にコンソールエラー(TypeError)発生 linjunfeng end
              });
            }
            this.updatePatientErrorArray = []
          }
        });
      } else {
        if (this.updateSuccessFlag) {
          this.$ons.notification.alert({
            // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "",
            // message: "患者グループを更新しました。",
            title: DIALOG_MESSAGES[12000235].title,
            message: messageFormat(DIALOG_MESSAGES[12000235].message),
            // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              // #11308 P-Caグラフで患者グループ更新時にコンソールエラー(TypeError)発生 linjunfeng start
              // callback: this.updateSuccessFlag = false
              callback: () => {
                this.updateSuccessFlag = false
              }
              // #11308 P-Caグラフで患者グループ更新時にコンソールエラー(TypeError)発生 linjunfeng end
          });
        }
      }
    },
    /**
     * 集計エリアのエリアXのツールチップに表示する説明文
     */
    getSumaryAreaData(ls) {
      let ret = [];
      for (let i = 0; i < 9; i++) {
        let pointInArea = ls.filter(point => point.areaIndex === i + 1);
        let percent =
          ls.length > 0
            ? DecimalFormat((pointInArea.length / ls.length) * 100)
            : 0;
        let object = {
          title: `${percent}%(${pointInArea.length}名/${ls.length})`,
          content: (this.graphSettings?.[`distributionGraphTooltip${i + 1}`] || "").split("\n")
        };
        ret.push(object);
      }
      return ret;
    },
    /**
     * 分布グラフで選択されたエリアをオレンジ（active）に設定する
     * 分布グラフと経過グラフの集計画面でも選択されたエリアをオレンジに設定する
     */
    areaSelectedClass(area) {
      return this.selectedAreaList.includes(area) &&
        (this.graphType === this.GRAPH_TYPE.DISTRIBUTION || this.graphType === this.GRAPH_TYPE.BLANK)
        ? "active"
        : "";
    },
    /**
     * YYYY/MM/DD => M/D
     */
    shortDateFormat(date) {
      var check = dayjs(date, "YYYY/MM/DD");
      return `${check.format("M")}/${check.format("D")}`;
    },
    /**
     * これらのボタンをクリックすると画面が移動します。
     * ユーザーに移動先の画面を見ることができる権限がないと移動しても画面をみることができない、ということになってしまいます。
     * これを防ぐために最初から移動できない画面のボタンを消しておこうというものです。
     * DBではmst_user.user_setting.use_functionsの中身で判定してください。
     */
    hideMenuButton(btnCd) {
      // del #10359、#10331 編集権限について、対応する。 dengshen start
      // switch (btnCd) {
      //   case 0:
      //     return !this.getUseFunctions.includes(FUNC_EXAM_RECORD);
      //   case 1:
      //     return !this.getUseFunctions.includes(FUNC_PAT_VIEWER);
      //   case 2:
      //     return !this.getUseFunctions.includes(FUNC_TREATMENT_RECORD);
      // }
      // del #10359、#10331 編集権限について、対応する。 dengshen end
      return false;
    },
    /**
     * クローンツールチップ削除
     */
    removeCloneTooltip() {
      if (
        (!this.duplicatePlotListVisible && this.menuVisible) ||
        !this.menuVisible) {
        this.currentTab = 1;
      }
    },

    async initOrdNoList(patId) {
              this.setSelectedPatHeader(patId).then(() => {
        this.$nextTick(() => {
          this.$router.push({
            name: "treatment-record"
          });
        });
        });
    },
    /**
     * 上から下へ
     * 7,4,1のアリア は 1行, インデックス 0
     * 8,5,2のアリア は 2行, インデックス 1
     * 9,6,3のアリア は 3行, インデックス 2
     */
    sumaryRowStyle(rowIndex) {
      if (this.heightRatioArray[rowIndex] === 0) {
        return {
          display: "none"
        };
      }
      return {
        width: "100%",
        height: `${Math.floor(
          this.statisticalElementHeight * this.heightRatioArray[rowIndex])}px`
      };
    },
    /**
     * 左から右へ
     * 7,8,9のアリア 1列 , インデックス 0
     * 4,5,6のアリア 2列 , インデックス 1
     * 1,2,3のアリア 3列 , インデックス 2
     */
    sumaryColStyle(colIndex) {
      if (this.widthRatioArray[colIndex] === 0) {
        return {
          display: "none"
        };
      }
      return {
        width: `${Math.floor(
          this.statisticalElementWidth * this.widthRatioArray[colIndex])}px`,
        height: "100%",
        float: "left"
      };
    },
    /**
     * 右のメニューを表示しない場合
     */
    calMenuDirection() {
      // メニューの幅が300px, ポップオーバーの複製の半分が150px
      this.nearRightSide =
        this.windowWidth - this.duplicatePlotListTarget.offsetLeft < 450;
    },
    getSeriesData() {
      let arrayData = [];
      this.chartOptions.series.forEach(seri => {
        if (seri.data && seri.data.length > 0) {
          arrayData = arrayData.concat(seri.data);
        }
      });
      return arrayData;
    },
    switchTab(tabNumber) {
      if (this.currentTab !== tabNumber) {
        this.currentTab = tabNumber;
        if (this.duplicatePlotListVisible && tabNumber === 1) {
          this.menuVisible = false;
        }
      }
    },
    async onSearchExam() {
      await this.init();
      this.updatePointColor();
    },
    // 患者名入外色設定
    patInOutClass(patId) {
      const patObj = this.searchedPatList.filter(function(item) {
        if (item.pat_id == patId) return true;
      });
      if (patObj.length !== 0) {
        return patObj[0].in_out_class === 1 ? "in_class" : "";
      } else {
        return "";
      }
    },
    // 同姓同名アイコンの表示設定
    patIsSame(patId) {
      const patObj = this.searchedPatList.filter(function(item) {
        if (item.pat_id == patId) return true;
      });
      if (patObj.length !== 0) {
        return patObj[0].is_same;
      } else {
        return "";
      }
    }
  },

  async created() {
    await this.getSettings();
    this.keyGraph++;
    if (this.graphSettings) {
      this.graphType = this.getGraphType;
      this.statisticalInformation = this.getSumaryAreaData([]);
      EventBus.$off("searchExam", this.onSearchExam);
      EventBus.$on("searchExam", this.onSearchExam);
      EventBus.$off("updatePatientGroup", this.validateBeforeUpdate);
      EventBus.$on("updatePatientGroup", this.validateBeforeUpdate);
      await this.init();
      this.updatePointColor();
    }
    // add 画面印刷プレビューと印刷の実現 陳 start
    // 印刷パラメータ要求
    // add 性能改善メモリ不足 shan start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 陳 end
  },
  mounted() {
    (getScopedWindow(this.$el) || window).addEventListener("resize", this.onResize);
    // 画面印刷時のイベント追加
    EventBus.$on("print-start", this.handleBeforePrint);
    EventBus.$on("print-end", this.handleAfterPrint);
  },
  beforeUnmount() {
    (getScopedWindow(this.$el) || window).removeEventListener("resize", this.onResize);
    EventBus.$off("searchExam", this.onSearchExam);
    EventBus.$off("updatePatientGroup", this.validateBeforeUpdate);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("print-start", this.handleBeforePrint);
    EventBus.$off("print-end", this.handleAfterPrint);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>
<style scoped>
#bottom-info {
  width: 100%;
  flex-wrap: wrap;
  justify-content: space-around;
  text-align: right;
  color: var(--ntss-base-color);
  min-width: max-content;
}
#search-wrapper {
  display: grid;
}
#search-wrapper #select-exec {
  margin-left: 2em;
}
.custom-pop-area {
  padding: 8px;
}
.custom-pop-area .ntss-list {
  position: unset !important;
  font-size: unset !important;
}
.pop-area {
  overflow-y: auto;
  overflow-x: hidden;
}
.text-center {
  text-align: center;
}
.sumary-table {
  position: absolute;
  z-index: -1;
}
.statistical-information {
  width: 100%;
  height: 100%;
  position: relative;
  font-size: 1.5em;
  border: 0.5px solid var(--highcharts-grid-line-stroke);
}
.sumary-table div.active {
  background: #ffa500;
}
/* 選択されたエリア（#ffa500）の文字色 */
.sumary-table div.active > div.statistical-information {
  color: #050505;
}
/* 選択されていないエリアの文字色 */
.sumary-table div:not(.active) > div.statistical-information {
  color: var(--ntss-base-color);
}
.area-number {
  position: absolute;
  top: 8px;
  right: 8px;
}
.area-title {
  position: absolute;
  top: 8px;
  left: 8px;
}
.area-content {
  margin: 0;
  padding: 8px;
  padding-top: 0px;
  list-style: none;
  position: absolute;
  left: 0;
  bottom: 0;
  word-break: break-all;
  overflow: auto;
  /**-#9846 add start */
  /* max-height: calc(100% - 40px);*/
  max-height: calc(100% - 52px);
  /**-#9846 add end */
  width: calc(100% - 16px);
}
.pop-menu {
  padding: 4px;
  overflow-x: auto;
}
.menu-list {
  border-collapse: collapse;
  width: 100%;
  padding: 8px;
}
.menu-body-tr:nth-child(3) ons-button {
  margin-bottom: 8px;
}
.menu-body-tr:last-child ons-button {
  margin-top: 8px;
}
.menu-body-tr:last-child {
  border-top: thin dashed var(--ntss-base-color);
  margin-top: 8px;
}
.menu-body-td {
  padding: 4px;
  border: thin solid var(--ntss-border-color);
  height: 24px;
}
.switch-layout-button {
  padding: 4px 0;
  font-size: 1.5em;
  margin: 0;
}
.non-display {
  display: none;
}
.pat-list-content {
  max-height: 40vh !important;
  overflow-y: auto;
  overflow-x: hidden;
}
.highchart-area {
  height: 100%;
  min-width: 300px;
  overflow-y: auto;
  position: relative;
}
.popover-tab {
  margin: 0 !important;
}
.popover-tab ons-col {
  text-align: center;
  padding: 8px;
}
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: 100%;
  display: flex;
  justify-content: center;
}
.label {
  display: block;
  float: left;
  width: 30%;
  height: 30px;
  padding-left: 5px;
  padding-right: 5px;
  background-color: #87cefa;
  color: #ffffff;
  text-align: center;
  line-height: 30px;
  cursor: pointer;
}
.tab-label {
  width: 50% !important;
}
.first-of-type {
  border-radius: 10px 0 0 10px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
}
.tooltip-tab {
  /* 患者リスト + 週出欄 + マージン */
  max-height: calc(40vh + 2em + 15px);
}
/* mod FNSI-4458 文字サイズ：特大の際の遷移先表示の不正 liumx start */
.split-graph-popover :deep(.popover) {
  width: auto;
}
.split-graph-popover :deep(.popover__content) {
  width: 16em;
}
/* mod FNSI-4458 文字サイズ：特大の際の遷移先表示の不正 liumx end */
.btn-Split-graph-menu .icon {
  height: 1.5em;
  width: 1.5em;
  margin: 0 5px 0 5px;
}
.in_class {
  color: #A356A3;
}
.same-icon{
  position: relative;
  top: 0.25em;
  height: 20px;
}
@media print {
  .highchart-area :deep(.highcharts-container),
   #bottom-info {
    position: absolute !important;
  }
}


:deep(.highcharts-xaxis-labels text){
  font-family: "Lucida Grande", "Lucida Sans Unicode", Arial, Helvetica, sans-serif, "Segoe UI Emoji", "Segoe UI Symbol", sans-serif !important;
}
:deep(.highcharts-axis-labels text){
  font-family: "Lucida Grande", "Lucida Sans Unicode", Arial, Helvetica, sans-serif, "Segoe UI Emoji", "Segoe UI Symbol", sans-serif!important;
}
:deep(.highcharts-yaxis-labels text){
  font-family: "Lucida Grande", "Lucida Sans Unicode", Arial, Helvetica, sans-serif, "Segoe UI Emoji", "Segoe UI Symbol", sans-serif !important;
}
:deep(.highcharts-axis-labels text){
  font-family: "Lucida Grande", "Lucida Sans Unicode", Arial, Helvetica, sans-serif, "Segoe UI Emoji", "Segoe UI Symbol", sans-serif!important;
}

:deep(.highcharts-root){
  font-size: 0.8em!important;
}

:deep(.highcharts-legend-item text){
  color: #333333;
  cursor: pointer;
  font-size: 1em !important;
  font-weight: bold;
  fill: #333333;
  font-family: "Lucida Grande", "Lucida Sans Unicode", Arial, Helvetica, sans-serif!important;
}
:deep(.highcharts-tooltip span) {
  font-size: 14px !important;
  line-height: 24px;
  font-weight: normal;
  font-family: "Lucida Grande", "Lucida Sans Unicode", Arial, Helvetica, sans-serif!important;
}



</style>
