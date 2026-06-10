/**
 * 治療状況リスト（透析液調製装置トレンドグラフ画面） MainContent
 */
<template>
  <div class="trend-main" id="trend-main">
    <div>
      <div slot="main" id="graph-component">
        <div id="name-box">
          <label class="machine-name">装置名：{{ machineName }}</label>
        </div>
        <v-ons-list class="trend-graph-accordion" :style="getCardHeaderWidthStyle">
          <div class="display-info auto-event" @click="showInfoPopover($event)">
            <img class="img-icon none-event" :src="imageSrcInfoIcon" />
          </div>
          <v-ons-list-item
            expandable
            :expanded.sync="isExpandedGraph"
            id="graph-sub"
            style="overflow-x: hidden;"
          >
            <label>トレンドグラフ</label>
            <v-ons-popover
              id="popGraphGrid"
              cancelable
              :class="fontSizeSet"
              :visible.sync="popoverVisible"
              :target="popoverTarget"
              :direction="popoverDirection"
              animation="none"
              @preshow="popoverPreShow"
              @postshow="popoverPostShow"
              @posthide="popoverPosthide"
            >
              <div class="graph-item-grid" style="max-height: 60vh; overflow: auto;">
                <table class="trend-graph-list" id="graphItemGrid">
                  <thead>
                    <tr>
                      <th
                        v-for="column in graphColumns"
                        :key="column.key"
                        class="ntss-list-header-th-sticky"
                        :style="{ 'min-width': column.width + 'em' }"
                        style="text-align: center"
                      >
                        <span>{{ column.colName }}</span>
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="(series, idx) in graphItemList"
                      :key="idx"
                      :class="'ntss-list-body-tr'"
                      style="height: 1.1rem"
                    >
                      <td
                        v-for="column in graphColumns"
                        :class="[
                          'ntss-list-body-tr',
                          column.key == 'moniName' ? 'ntss-list-graphItem' : '',
                        ]"
                        :key="column.className"
                        style="text-align: right; padding: 4px"
                      >{{ column.text(series) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </v-ons-popover>
            <!-- add FNSI-redmine#3963 付 start -->
            <graph-sub />
            <!-- <graph-sub :style="'width:' + cWidth + 'px'" /> -->
            <!-- add FNSI-redmine#3963 付 end -->
          </v-ons-list-item>
          <v-ons-list-item
            expandable
            :expanded.sync="isExpandedMonitorSet"
            style="overflow-x: hidden;"
          >
            <label>モニタ一覧</label>
            <div class="expandable-content" id="popContent"></div>
          </v-ons-list-item>
        </v-ons-list>
        <div
          class="graph-item-grid"
          id="list-grid-box"
          v-show="isExpandedMonitorSet"
        >
          <table class="trend-graph-list" id="monitor-list">
            <thead>
              <tr>
                <th
                  v-for="column in monitorColumns"
                  :key="column.key"
                  class="ntss-list-header-th-sticky trend-graph-monitor-th"
                  :style="{ 'min-width': column.width + 'em' }"
                  style="text-align: center"
                >
                  <span>{{ column.colName }}</span>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(monitorItem, idx) in monitorItemList"
                :key="idx"
                :class="'ntss-list-body-tr'"
                style="height: 1.1rem"
              >
                <td
                  v-for="column in monitorColumns"
                  class="ntss-list-body-td"
                  :key="column.className"
                  :style="{ 'text-align': column.style }"
                >{{ column.text(monitorItem) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PopoverMixin from "@/components/PopoverMixin";
import TrendGraphComponent from "@/components/trend-graph/subComponent/TrendGraphComponent";
import moment from "moment";
import { EventBus } from "@/eventBus.js";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// mod FNSI-改修内容5708、5759修正 xuty start
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import { STATUS_AUTO_SETTING } from "@/constants/facilitySetting";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
// mod FNSI-改修内容5708、5759修正 xuty end
import PrintMixin from "@/components/PrintMixin";

export default {
  props: {},
  mixins: [NextTransitionMixin, PopoverMixin, PrintMixin],
  components: {
    "graph-sub": TrendGraphComponent
  },
  computed: {
    ...mapGetters("trend-graph", [
      "getConditionInfo",
      "getMachineInfo",
      "getMonitorDataList",
      "getSelectedTemplate",
      "getSelectedMonitorSet",
      "getSysMonitorItems"
    ]),
    // mod FNSI-改修内容5708、5759修正 xuty start
    ...mapGetters("user", ["getFacilityCd"]),
    // mod FNSI-改修内容5708、5759修正 xuty end
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("window-size", {
      // 分割された画面の幅取得
      splittedWidth: "getSplittedWidth"
    }),
    /**
     * 装置名称取得
     */
    machineName() {
      if (this.getMachineInfo) {
        return this.getMachineInfo.machineName;
      }
      return null;
    },
    graphItemList() {
      if (!this.getSelectedTemplate) {
        return [];
      }
      const monitorItemWithUnit = this.getSelectedTemplate;
      let seriesInfo = monitorItemWithUnit.seriesInfo;
      for (let series of seriesInfo) {
        for (const sysItem of this.getSysMonitorItems) {
          if (monitorItemWithUnit.model === sysItem.model && series.moni_cd === sysItem.code
          //add FNSI redmine トレンドグラフの項目はマスタと不一致バッグ 5702再修正 劉祥霖　start
          &&monitorItemWithUnit.comFormatCd===sysItem.type
          //add FNSI redmine トレンドグラフの項目はマスタと不一致バッグ 5702再修正 劉祥霖　end
          ) {
            series.moni_name = sysItem.nameWithUnit;
            break;
          }
        }
      }
      return seriesInfo;
    },
    // -----------------------------------------
    // モニター一覧表示データ取得
    // -----------------------------------------
    monitorItemSetName() {
      if (this.getSelectedMonitorSet) {
        return this.getSelectedMonitorSet.monitorSetName;
      }
      return null;
    },
    monitorItemList() {
      return this.getMonitorDataList;
    },
    /**
     *  グラフ表示項目一覧表列定義
     */
    graphColumns() {
      return [
        {
          key: "moniName",
          colName: "表示項目",
          className: "moniNameBody",
          width: 7,
          text: src => src.moni_name
        },
        {
          key: "newest",
          colName: "最新測定値",
          className: "newestBody",
          width: 0,
          text: this.newestValue
        },
        {
          key: "target",
          colName: "目標値",
          className: "targetBody",
          width: 0,
          text: src => src.target_value
        },
        {
          key: "max",
          colName: "上限値",
          className: "maxBody",
          width: 0,
          text: src => src.upper_value
        },
        {
          key: "min",
          colName: "下限値",
          className: "minBody",
          width: 0,
          text: src => src.lower_value
        }
      ];
    },
    /**
     *  モニター一覧表列定義
     */
    monitorColumns() {
      let columns = [
        {
          key: "occurDate",
          colName: "日時",
          className: "occurDateBody",
          width: 5,
          style: "left",
          text: src => moment(src.occurDate).format("YYYY/MM/DD HH:mm:ss")
        }
      ];
      if (this.getSelectedMonitorSet) {
        const monitorItemWithUnit = this.getSelectedMonitorSet;

        for (let series of monitorItemWithUnit.seriesInfo) {
          for (const sysItem of this.getSysMonitorItems) {
            let ab = sysItem.type;
            if(ab != null) {
              ab = "0";
            }
            if (monitorItemWithUnit.model === sysItem.model && series.code === sysItem.code) {
              //mod FNSI redmine 5702 劉祥霖　表示項目不正再修正　start
              if (monitorItemWithUnit.model === sysItem.model && series.code === sysItem.code&&monitorItemWithUnit.comFormatCd===sysItem.type){
              // add FNSI-改修内容5702修正 xuty start
              // if ((monitorItemWithUnit.monitorSetName === "DAD" && sysItem.type == null)
              //   || (monitorItemWithUnit.monitorSetName === "DRY-A" && sysItem.type === "I")
              //   || (monitorItemWithUnit.monitorSetName === "DRY-B" && sysItem.type === "J")
              //   || (monitorItemWithUnit.monitorSetName !== "DRY-A" && monitorItemWithUnit.monitorSetName !== "DRY-B" && monitorItemWithUnit.monitorSetName !== "DAD")) {
              // add FNSI-改修内容5702修正 xuty end
              //mod FNSI redmine 5702 劉祥霖　表示項目不正再修正　start
              series.style = sysItem.strItem;
              series.name = sysItem.name;
              if (sysItem.unit) {
                series.name += "\n[" + sysItem.unit + "]";
              }
              series.convItem = sysItem.convItem;
              break;
              // add FNSI-改修内容5702修正 xuty start
              }
              // add FNSI-改修内容5702修正 xuty end
            }
          }
          columns.push({
            key: `monitor${series.code}`,
            colName: series.name,
            className: `monitor${series.code}Body`,
            width: 3,
            style: series.style,
            text: src => {
              const monitorData = src.monitorData;
              const cd = String(series.code);
              // mod #8115 2022/11/23 透析液調製装置トレンドグラフが表示しない dou start
              // if (monitorData[cd] !== undefined && monitorData[cd] !== null) {
              if (!!monitorData && monitorData[cd] !== undefined && monitorData[cd] !== null) {
              // mod #8115 2022/11/23 透析液調製装置トレンドグラフが表示しない dou end
                if (series.convItem) {
                  // 変換表がある場合は変換する
                  let convItem = {};
                  if (typeof series.convItem === "string") {
                    convItem = JSON.parse(series.convItem);
                  } else {
                    convItem = series.convItem;
                  }
                  return convItem[monitorData[cd]];
                }
                // モニタデータをそのまま返す
                return monitorData[cd];
              }
              return null;
            }
          });
        }
      }
      return columns;
    },
    getCardHeaderWidthStyle() {
      if (this.pageViewWidth) {
        return { "width": `${this.pageViewWidth}px` };
      }
      return null;
    }
  },
  data() {
    return {
      imageSrcInfoIcon: require("../../assets/info_icon_1.png"),
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "right",
      isExpandedItems: false,
      isExpandedGraph: false,
      isExpandedMonitorSet: false,
      // Android判定フラグ
      isAndroid: false,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      isIOS: false,
      selfScreenName: "",
      pageViewWidth: 0,
      // add FNSI-redmine#3963 付 start
      // cWidth: 0,
      // add FNSI-redmine#3963 付 end
      // mod FNSI-改修内容5708、5759修正 xuty start
      scrollPositionTop: 0,
      scrollPositionLeft: 0,
      timerId: [],
      refreshInterval: 0,
      // mod FNSI-改修内容5708、5759修正 xuty end
      printTargetClass: ["expandable-content"],
      scrollQuerySelector: ".trend-main", // スクロールコンテナ
      addClassTargetQuerySelector: ["table.trend-graph-list"], // scroll-rightmostクラスを付与する対象のクエリセレクタ
    };
  },
  methods: {
    ...mapActions("trend-graph", [
      "setTrendGraphList",
      "fetchTrendGraphList",
      "fetchSysMonitorItem"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * 初期化処理
     */
    init() {
      this.isExpandedGraph = true;
      this.isExpandedMonitorSet = true;
      this.setPageViewWidth();

      // モニタ項目
      this.fetchSysMonitorItem();
    },
    // mod FNSI-改修内容5708、5759修正 xuty start
    async refreshVal(parama) {
      let data = await getMstFacilitySettingValue(this.getFacilityCd, STATUS_AUTO_SETTING);
      if (data.status == 200) {
        if (data.data) {
          this.refreshInterval = data.data * 1000;
        } else {
          this.refreshInterval = 20000;
        }
      } else if (data.status == 400) {
        getErrorMessage('StatusListMainComponent.vue','startPolling',error);
        this.refreshInterval = 20000;
      }
      if (parama != undefined) {
        parama();
      }
    },
    startPolling() {
      this.endPolling();
      this.timerId.push(setInterval(this.statusUpdate, this.refreshInterval));
    },
    endPolling() {
      if (this.timerId) {
        for (let i = 0; i < this.timerId.length; i++) {
            clearInterval(this.timerId[i]);
        }
      }
    },
    statusUpdate() {
      const grid = document.querySelector(".trend-main");
      this.scrollPositionTop = grid ? grid.scrollTop : 0;
      this.scrollPositionLeft = grid ? grid.scrollLeft : 0;
      this.refresh();
      setTimeout(() => {
        this.setScrollPosition();
      }, 500);
    },
    setScrollPosition() {
      const grid = document.querySelector(".trend-main");
      grid.scrollTop = this.scrollPositionTop;
      grid.scrollLeft = this.scrollPositionLeft;
    },
    // mod FNSI-改修内容5708、5759修正 xuty end
    newestValue(src) {
      const cd = String(src.moni_cd);
      const monitor = this.getMonitorDataList;
      //upd DRO［透析液調製装置トレンドグラーフ］画面の最新測定値の表示が不正である 修正 20230703 ztc start
      // for (let index = monitor.length - 1; index >= 0; index--) {
      for (let index = 0; index < monitor.length; index++) {
        //upd DRO［透析液調製装置トレンドグラーフ］画面の最新測定値の表示が不正である 修正 20230703 ztc end
        const elem = monitor[index].monitorData;
        // mod #8115 2022/11/23 透析液調製装置トレンドグラフが表示しない dou start
        // if (elem[cd] !== undefined && elem[cd] !== null) {
        if (!!elem && elem[cd] !== undefined && elem[cd] !== null) {
        // mod #8115 2022/11/23 透析液調製装置トレンドグラフが表示しない dou end
          return elem[cd];
        }
      }
      return null;
    },
    refresh() {
      if (
        this.selfScreenName === this.$router.currentRoute.name &&
        document.getElementsByTagName("ons-alert-dialog").length === 0
      ) {
        // データリロード
        this.fetchTrendGraphList(this.getConditionInfo).then(res => {
          this.setTrendGraphList(res.data.monitorInfo);
        });
      }
    },
    showInfoPopover(event) {
      this.popoverTarget = event;
      event.preventDefault();
      this.popoverVisible = true;
      this.$nextTick(() => {
        this.setPopoverMaxWidth();
      });
    },
    /** ポップオーバーの横幅が画面に収まるように設定する */
    setPopoverMaxWidth() {
      if (!this.popoverVisible) {
        return;
      }
      const popover = document.querySelector("#popGraphGrid .popover--left");
      if (!popover) {
        return;
      }
      const popoverMaxWidth = this.splittedWidth - popover.offsetLeft;
      document.querySelector("#popGraphGrid .popover--left__content").style.maxWidth = `${popoverMaxWidth}px`;
    },
    setPageViewWidth() {
      const viewEl = document.getElementById("trend-main");
      if (!viewEl) {
        this.pageViewWidth = 0;
      }
      this.pageViewWidth = viewEl.firstElementChild.offsetWidth;
    }
  },
  watch: {
    splittedWidth() {
      this.setPopoverMaxWidth();
      this.setPageViewWidth();
    }
  },
  created() {
    // v-bindや{{}}などView要素への変数の依存性注入などがされたあとに実行される処理
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh", this.refresh);
    // add FNSI-redmine#3963 付 start
    // this.cWidth = document.body.clientWidth;
    // add FNSI-redmine#3963 付 end
  },
  mounted() {
    this.init();
    // mod FNSI-改修内容5708、5759修正 xuty start
    this.refreshVal(this.startPolling);
    // mod FNSI-改修内容5708、5759修正 xuty end
  },
  updated() {
    this.setPageViewWidth();
  },
  beforeDestroy() {
    // イベントリスナーの削除など、画面終了時の後片付けが完了した際に実行される処理
    EventBus.$off("refresh", this.refresh);

    // mod FNSI-改修内容5708、5759修正 xuty start
    // polling用setIntervalのクリア
    this.endPolling();
    // mod FNSI-改修内容5708、5759修正 xuty end
  }
};
</script>

<style scoped>
.trend-graph-accordion {
  position: sticky;
  left: 0px;
}
.trend-graph-accordion label {
  font-size: inherit !important;
}
.trend-graph-list {
  margin: 0;
  width: 100%;
}
#graphItemGrid {
  width: 100%;
}
#list-grid-box {
  z-index: 2;
  margin-top: 0px;
}
table#monitor-list.trend-graph-list thead tr th.ntss-list-header-th-sticky {
  position: -webkit-sticky;
  position: sticky;
  top: 0;
  z-index: 1;
}
.chart-area {
  margin: 0 0 5px;
  display: flex;
  align-content: flex-start;
  flex-direction: column;
}
.trend-main {
  flex: 1;
  height: 100%;
  overflow: auto;
}
.machine-name {
  margin-left: 15px;
  color: var(--ntss-base-color);
  position: sticky;
  left: 15px;
}
.monitor-set-name {
  margin-left: 15px;
  font-size: 1.5em;
  color: var(--ntss-base-color);
}
img.img-icon {
  display: block;
  cursor: pointer;
  width: 20px;
  height: 20px;
  margin-left: 2em;
  padding-top: 10px;
}
.popover__content ons-button.auto-event {
  margin-right: 10px;
}
#popGraphGrid >>> .popover--left__content {
  width: 100%;
}
.display-info {
  position: relative;
  width: 60px;
  height: 0px;
  left: 7em;
  z-index: 100;
}
#name-box {
  margin-bottom: 5px;
}
.graph-item-grid {
  margin: 5px;
}
.ntss-list-graphItem {
  text-align: left !important;
}
#popContent {
  padding: 5px;
}
#graph-component {
  width: fit-content;
}

@media print {
  /** グラフ */
  div >>> .trend-graph-accordion {
    width: 1024px !important;
  }
  
  /** スクロールコンテナ */
  .trend-main {
    overflow: hidden !important;
    height: auto !important;
    width: 1024px !important; /* グラフのレイアウト崩れ防止のため固定幅 */
  }
}
@media print and (orientation: landscape) {
  ons-list > ons-list-item:nth-of-type(2) {
    page-break-before: always !important;
    break-before: page !important;
  }
}
</style>
