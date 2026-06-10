/**
 * 測定履歴モーダルPage
 */
 <template>
  <modal-base @onClose="closeMeasureHistoryModal">
    <div slot="header">
      <component :is="header"></component>
    </div>
    <div slot="body" style="overflow-y: hidden;">
      <div id="send-condition-weight-chart-area" style="height: 250px;">
        <!-- 体重履歴チャート表示予定領域 -->
        <highcharts :options="createChartData()" ref="highcharts"></highcharts>
      </div>
      <!-- 測定履歴一覧のグリッド -->
      <div id="historygrid" :style="{ 'height':kendoGridHeight + 'px' }">
        <table class="send-condition-pat-modal-list" id="localgrid">
          <thead>
            <tr>
              <th
                v-for="column in columns"
                :key="column.key"
                class="ntss-list-header-th-sticky"
                :style="{ 'min-width':column.width + 'em' }"
              >{{ column.colName }}</th>
            </tr>
          </thead>
          <tr
            v-for="(HistoryList, idx) in getHistoryModalList"
            :key="idx"
            style="height: 1.1rem;"
          >
            <td
              v-for="column in columns"
              class="ntss-list-body-td"
              :key="column.className"
              style="text-align: left;"
            >{{ column.text(HistoryList) }}</td>
          </tr>
          <tr style="height: 1.1rem;"></tr>
        </table>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
        <!-- <v-ons-button class="button denial-btn" @click="closeMeasureHistoryModal">キャンセル</v-ons-button> -->
        <v-ons-button class="btn2-cancel denial-btn" @click="closeMeasureHistoryModal">キャンセル</v-ons-button>
        <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
      </div>
    </div>
  </modal-base>
</template>

<script>
import Vue from "vue";
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "vuex";
import VueHighcharts from "vue-highcharts";
import Highcharts from "highcharts";
import Boost from "highcharts/modules/boost";
import moment from "moment";
// jQureyを宣言（'$'はvue.jsで使用されているため、'$$'で宣言）
const $$ = require("jquery");
import { deepCopy } from "@/functions/common/CommonFunctions";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

Vue.use(VueHighcharts);
Boost(Highcharts);

// グラフデータのsampleテンプレート
const CHART_OPTIONS_TEMPLATE = {
  chart: {
    height: 250,
    type: "line",
    marginRight: 27,
    marginLeft: 32,
    reflow: true
  },
  credits: {
    enabled: false
  },
  title: false,
  xAxis: {
    type: "datetime",
    dateTimeLabelFormats: {
      // don't display the dummy year
      minute: "%Y/%m/%d<br/>%H:%M",
      hour: "%Y/%m/%d<br/>%H:%M",
      day: "%Y<br/>%m/%d",
      week: "%Y<br/>%m/%d",
      month: "%Y/%m",
      year: "%Y"
    },
    tickInterval: 1000 * 60 * 60 * 24 * 7
  },
  yAxis: [
    {
      // 左y軸(体重値用)
      title: false,
      // min: 20,
      // max: 150,
      alignTicks: false,
      tickInterval: 30,
      labels: {
        align: "left",
        x: -28,
        style: {
          textOverflow: "none"
        }
      }
    },
    {
      // 右y軸(差用)
      title: false,
      // min: 0,
      // max: 30,
      alignTicks: false,
      tickInterval: 3,
      opposite: true, // 右側のy軸とする
      allowDecimals: true,
      labels: {
        align: "right",
        x: 25
      }
    }
  ],
  legend: {
    // グラフの凡例
    layout: "horizontal", // 横方向に並べる
    align: "left", // グラフの左に表示（左右中央）
    verticalAlign: "top", // グラフの上に表示（上下中央）
    floating: false, // 凡例をプロット外部に表示
    x: 10,
    y: -20
  },
  navigation: {
    // 右上のメニュー（表示しない）
    buttonOptions: {
      enabled: false
    }
  },
  plotOptions: {
    // 点の設定
    series: {
      marker: {
        enabled: true // データプロット(●、▲、■)を表示
      }
    }
  },
  series: [
    {
      name: "前体重",
      color: "#99FFFF",
      data: [],
      pointStart: null,
      pointInterval: 24 * 3600 * 1000,
      yAxis: 0
    },
    {
      name: "後体重",
      color: "#7b9ad0",
      data: [],
      pointStart: null,
      pointInterval: 24 * 3600 * 1000,
      yAxis: 0
    },
    {
      name: "目標体重",
      color: "#FF9933",
      data: [],
      pointStart: null,
      pointInterval: 24 * 3600 * 1000,
      yAxis: 0
    },
    {
      name: "DW",
      color: "#FF3333",
      data: [],
      pointStart: null,
      pointInterval: 24 * 3600 * 1000,
      yAxis: 0
    },
    {
      name: "前体重―前回後体重",
      color: "#99FF33",
      data: [],
      pointStart: null,
      pointInterval: 24 * 3600 * 1000,
      yAxis: 1
    },
    {
      name: "DW差",
      color: "#000033",
      data: [],
      pointStart: null,
      pointInterval: 24 * 3600 * 1000,
      yAxis: 1
      // },
      // {
      //   name: "DW増加率",
      //   color: "#6666FF",
      //   data: [],
      //   pointStart: null,
      //   pointInterval: 24 * 3600 * 1000,
      //   yAxis: 2
    }
  ]
};

export default {
  name: "measureHistoryModal",
  components: {
    VueHighcharts,
    "modal-base": ModalBase
  },
  data() {
    return {
      main: "",
      header: "",
      kendoGridHeight: 300,
      isRedrawing: false
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("send-condition/scale", ["getPatId"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
    }),
    ...mapGetters("send-condition/scale", ["getHistoryModalList"]),
    ...mapGetters("send-condition/scale/setting", ["getWeightScaleConfigInfo"]),
    columns() {
      return [
        {
          key: "ordNo",
          colName: "No.",
          className: "ordNoBody",
          width: 5,
          text: src => src.ordNo
        },
        {
          key: "treatDate",
          colName: "治療日",
          className: "treatDateBody",
          width: 7,
          text: src => src.treatDate
          // text: src => weightScaleStateMsg(src.weightScaleStatus)
        },
        {
          key: "treatWeek",
          colName: "曜日",
          className: "treatWeekBody",
          width: 7,
          text: src => src.treatWeek
        },
        {
          key: "weightBefore",
          colName: "前体重",
          className: "weightBeforeBody",
          width: 5,
          text: src => src.weightBefore
        },
        {
          key: "weightAfter",
          colName: "後体重",
          className: "weightAfterBody",
          width: 5,
          text: src => src.weightAfter
        },
        {
          key: "targetWeight",
          colName: "目標体重",
          className: "targetWeightBody",
          width: 5,
          text: src => src.targetWeight
        },
        {
          key: "rstDw",
          colName: "DW",
          className: "rstDwBody",
          width: 8,
          text: src => src.rstDw
        },
        {
          key: "difWeight",
          colName: "前体重-前回後体重",
          className: "difWeightBody",
          width: 5,
          text: src => src.difWeight
        },
        {
          key: "difDw",
          colName: "DW差",
          className: "difDwBody",
          width: 6,
          text: src => src.difDw
        },
        {
          key: "rateDw",
          colName: "DW増加率",
          className: "rateDwBody",
          width: 4,
          text: src => src.rateDw
        }
      ];
    },
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridHeight}px` };
    }
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    windowWidth() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
  },
  created() {
    // スクロールが最後尾に達した時に追加読み込みを行う
    $$(() => {
      $$("#historygrid").on("scroll", () => {
        const scrollAreaHeight = $$("#historygrid").innerHeight();
        const scrollHeight = $$("#historygrid").get(0).scrollHeight;
        const bottom = Math.floor(scrollHeight - scrollAreaHeight);
        if (this.isRedrawing !== true) {
          const scrollTop = $$("#historygrid").scrollTop();
          if (bottom <= scrollTop && bottom > 0) {
            // 最後尾
            // alert("scroll");
            this.isRedrawing = true;
            this.updateModalRecords();
          }
        }
      });
    });
  },
  mounted() {
    // 測定履歴グリッド作成
    this.dataLoad();
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  },
  destroyed() {
    this.resetHistoryModalList();
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("send-condition/scale", [
      "fetchHistoryModalList",
      "resetHistoryModalList"
    ]),
    /**
     * グラフ用データ生成
     */
    createChartData() {
      const data = deepCopy(CHART_OPTIONS_TEMPLATE);
      const allData = this.getHistoryModalList;
      if (allData.length > 0) {
        let limitDate = new Date(allData[0].treatDate);
        limitDate.setMonth(limitDate.getMonth() - 3);
        // console.log(allData);
        const historyData = allData
          .filter(e => {
            const baseDate = new Date(e.treatDate);
            return baseDate.getTime() >= limitDate.getTime();
          })
          .sort((a, b) => {
            const aDate = new Date(a.treatDate);
            const bDate = new Date(b.treatDate);
            if (aDate.getTime() < bDate.getTime()) return -1;
            if (aDate.getTime() > bDate.getTime()) return 1;
            return 0;
          });
        data.series[0].data = historyData
          .filter(e => e.weightBefore !== null && e.weightBefore !== undefined)
          .map(e => {
            const baseDate = new Date(e.treatDate);
            return [baseDate.getTime(), e.weightBefore];
          });
        data.series[1].data = historyData
          .filter(e => e.weightAfter !== null && e.weightAfter !== undefined)
          .map(e => {
            const baseDate = new Date(e.treatDate);
            return [baseDate.getTime(), e.weightAfter];
          });
        data.series[2].data = historyData
          .filter(e => e.targetWeight !== null && e.targetWeight !== undefined)
          .map(e => {
            const baseDate = new Date(e.treatDate);
            return [baseDate.getTime(), e.targetWeight];
          });
        data.series[3].data = historyData
          .filter(e => e.rstDw !== null && e.rstDw !== undefined)
          .map(e => {
            const baseDate = new Date(e.treatDate);
            return [baseDate.getTime(), e.rstDw];
          });
        data.series[4].data = historyData
          .filter(e => e.difWeight !== null && e.difWeight !== undefined)
          .map(e => {
            const baseDate = new Date(e.treatDate);
            return [baseDate.getTime(), e.difWeight];
          });
        data.series[5].data = historyData
          .filter(e => e.difDw !== null && e.difDw !== undefined)
          .map(e => {
            const baseDate = new Date(e.treatDate);
            return [baseDate.getTime(), e.difDw];
          });
        // data.series[6].data = historyData.map(e => {
        //   const baseDate = new Date(e.treatDate);
        //   return [baseDate.getTime(), e.rateDw];
        // });
        for (let index = 0; index < 6; index++) {
          data.series[index].data.unshift([limitDate.getTime(), null]);
        }
      }
      return data;
    },
    // モーダルの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const ah = document.getElementById("send-condition-weight-chart-area")
        .clientHeight;
      const mbh = Array.prototype.slice
        .call(document.getElementsByClassName("modal-body"))
        .shift().clientHeight;

      this.kendoGridHeight = mbh - ah - 3;
      console.log("this.kendoGridHeight: %o", mbh - ah - 3);
    },
    // キャンセルボタン
    closeMeasureHistoryModal() {
      // モーダルを非表示に
      this.hideModal();
    },
    dataLoad() {
      let lastAfterWeightInfo = this.getWeightScaleConfigInfo;
      let today = moment(new Date());
      const info = {
        FacilityCd: this.getFacilityCd,
        isClear: true,
        patId: this.getPatId,
        treatDate: today.format("YYYYMMDD"),
        previousWeightSourceClass: lastAfterWeightInfo.previousWeightSourceClass
      };
      this.fetchHistoryModalList(info);
    },
    updateModalRecords() {
      let lastAfterWeightInfo = this.getWeightScaleConfigInfo;
      let treatData = this.getHistoryModalList;
      let lastTreatData =
        treatData[this.getHistoryModalList.length - 1].treatDate;
      // let today = moment(new Date());
      const info = {
        FacilityCd: this.getFacilityCd,
        isClear: true,
        patId: this.getPatId,
        treatDate: moment(lastTreatData)
          .add("days", -1)
          .format("YYYYMMDD"),
        previousWeightSourceClass: lastAfterWeightInfo.previousWeightSourceClass
      };
      this.fetchHistoryModalList(info)
        .then(() => {
          this.isRedrawing = false;
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('MeasurementHistoryModal.vue', 'updateModalRecords', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    }
  }
};
</script>

<style scoped>
#localgrid {
  position: relative;
}
#historygrid {
  overflow-y: auto;
}
.checklist-modal-list tr:hover {
  background-color:  #f5f5f5;
}
@media print {
  #send-condition-weight-chart-area,#historygrid{
    height: auto !important;
  }

  .ntss-list-header-th-sticky{
    min-width: 0 !important;
  }

  .send-condition-pat-modal-list th,.send-condition-pat-modal-list td{
    white-space: normal;
    overflow-wrap: break-word;
  }

  #send-condition-weight-chart-area >>> .highcharts-container  {
    width: auto !important;
    height: auto !important;
  }

  #send-condition-weight-chart-area >>> .highcharts-root  {
    width: 100%;
    height: 100%;
  }
}
</style>
