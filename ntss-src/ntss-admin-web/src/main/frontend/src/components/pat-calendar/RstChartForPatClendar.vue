/** * 装置プログラムーチャート */

<template>
  <highcharts :options="chartOptions" :ref="dispDataItem" />
</template>

<script>

import { Chart } from "highcharts-vue";
import Highcharts from "highcharts";
import Boost from "highcharts/modules/boost";
import moment from "moment";
import { mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";

Boost(Highcharts);

Highcharts.setOptions({
  lang: {
    shortWeekdays: ["日", "月", "火", "水", "木", "金", "土"],
    shortMonths: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
  },
  global: {
    useUTC: false
  }
});

const CHART_SERIES_COLORS = ["#7cb5ec", "#434348", "#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354", "#2b908f", "#f45b5b", "#91e8e1"];

export default {
  components: {
    highcharts: Chart
  },

  data() {
    return {
      isMounted: false,
      chartOptions: {
        chart: {
          height: 150,
          margin: [0, -1, 20, 0],
          events: {
            load() {
              // 初期ロード時にスクロールバー有無によってチャートがちゃんと描画されてないことがあるため
              // 描画された直後、3秒待機をして強制的リサイズをする
              setTimeout(() => {
                EventBus.$emit('reflowPatViewerCharts', this);
              }, 3000);
            }
          }
        },
        title: {
          text: ""
        },
        credits: {
          enabled: false
        },
        xAxis: {
          min: this.xAxisMin,
          max: this.xAxisMax,
          title: {
            enabled: false
          },
          type: "datetime",
          labels: {
            enabled: true,
            formatter() {
              const date = moment(this.value);
              return date.format("HH:mm");
            }
          },

          // 目盛り配置の計算(highchartの自動計算を使用しない)
          tickPositioner() {
            let tickAmount = 12;
            const ticks = [];
            // 目盛りを均等に配置する
            for (let i = 1; i < tickAmount; i++) {
              const val = this.min + ((this.max - this.min) / tickAmount) * i;
              ticks.push(val);
            }

            return [this.min, ...ticks, this.max];
          }
        },
        yAxis: [],
        legend: {
          backgroundColor: "rgba(255, 255, 255, 0.75)",
          floating: true,
          layout: "vertical",
          align: "left",
          verticalAlign: "top",
          x: 40,
          enabled: false,
          y: -10,
          shadow: true
        },
        navigation: {
          buttonOptions: {
            enabled: false
          }
        },
        series: this.seriesData,
        tooltip: {
          // 例: 1970年1月1日(木) 00:00
          xDateFormat: "%Y年%b月%e(%a) %H:%M",
          // プロット点をフォーカスアウト後に100ミリ待機してツールチップを非表示
          hideDelay: 100,
          // plotOptions.series.stickyTrackingと一緒
          snap: 0,
          // 患者カレンダー ダ-イア-イザ-ー入口圧/差圧警報点(上/下限)画面に表示がありません。 林峻峰 start
          useHTML: true
          // 患者カレンダー ダ-イア-イザ-ー入口圧/差圧警報点(上/下限)画面に表示がありません。 林峻峰 end
        }
      }
    }
  },
  props: {
    /**
     * @description チャートデータ
     *    例:
     *    [
     *      {
     *        "項目名1": [
     *          [検査日時, 結果値],
     *          [検査日時, 結果値]
     *        ],
     *        "項目名2": [
     *          [検査日時, 結果値],
     *          [検査日時, 結果値]
     *        ],
     *      }
     *    ]
     */
    chartData: {
      type: Array,
      default() {
        return [];
      }
    },

    yAxis: {
      type: Array,
      default() {
        return [];
      }
    },

    /**
     * @description x軸の下限値(ミリ秒)
     */
    xAxisMin: {
      type: Number,
      default: undefined
    },

    /**
     * @description x軸の上限値(ミリ秒)
     */
    xAxisMax: {
      type: Number,
      default: undefined
    },

    dispDataItem: {
      type: String,
      default: undefined
    }
  },

  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      splittedWidth: "getSplittedWidth"
    }),
    yAxisPositions() {
      if (!this.isMounted) return;
      if (!this.$refs[this.dispDataItem]) return;
      const chart = this.$refs[this.dispDataItem].chart;
      const len = chart.yAxis.length;
      const tmpTick = [];
      for (let i = 0; i < len; i++) {
        tmpTick.push({
          tickArr: chart.yAxis[i].tickPositions
        });
      }
      return tmpTick;
    }
  },

  created() {
    this.init();
  },

  mounted() {
    this.isMounted = true;
  },

  watch: {
    windowHeight() {
      this.resizeChart();
    },
    splittedWidth() {
      this.resizeChart();
    }
  },

  methods: {
    init() {
      this.chartOptions.series = this.seriesData();
      this.chartOptions.yAxis = this.yAxis;
      this.chartOptions.xAxis.tickPositions = this.tickPositioner();
    },
    resizeChart() {
      const chart = this.$refs[this.dispDataItem]?.chart;
      chart?.reflow();
    },
    legendEnableChanged() {
      this.$refs[this.dispDataItem].chart.legend.update({
        enabled: !this.$refs[this.dispDataItem].chart.legend.display
      });
    },
    seriesData() {
      const seriesArr = [];
      // 凡例用ID格納(同じ項目は同じ凡例を使用)
      const legendIdArr = [];
      // シリーズ線の色(同じ項目は同じ色をつける)
      const seriesColors = {};

      // 各ordMainレコードが1つのシリーズとして処理する
      this.chartData.forEach(item => {
        // 各レコードの項目を処理していく
        const isLegendIdExists = legendIdArr.find(i => {
          return i === item.name;
        });

        if (!isLegendIdExists) {
          // legendIdArrの要素数はCHART_SERIES_COLORSの要素番号として
          /* modify by chamaojia 2023-09-25 [9624] カラー設定の変更  --start */
          // seriesColors[item.name] = CHART_SERIES_COLORS[legendIdArr.length];
          seriesColors[item.name] = item.color;
          /* modify by chamaojia 2023-09-25 [9624] カラー設定の変更  --end */
          // IDが存在しない場合、そのIDを格納
          legendIdArr.push(item.name);
        }

        const series = {
          // IDが存在する場合、重複しないように定義はしない
          id: isLegendIdExists ? undefined : item.no,
          // 凡例名
          name: item.name,
          yAxis: item.yAxis,
          // IDが存在する場合、そのIDを使用
          linkedTo: isLegendIdExists ? item.name : undefined,
          // シリーズ線の色
          color: seriesColors[item.name],
          // プロットデータ
          data: item.data.map(i => {
            // 各項目のx値をISO8601日付からミリ秒形式に変換
            const x = moment(i[1]).valueOf();
            const y = i[2];
            return [x, y];
          }),
          /* add by chamaojia 2023-09-25 [9624] アイコンコンテンツ設定の追加  --start */
          marker: item.marker ? item.marker : {},
          /* add by chamaojia 2023-09-25 [9624] アイコンコンテンツ設定の追加  --end */
          animation: false
        };
        seriesArr.push(series);
      });

      // データがない時にシリーズが空になって目盛りが描画されない
      // そのためにシリーズに何か入れないといけない
      return seriesArr[0] === undefined ? [{ showInLegend: false }] : seriesArr;
    },
    tickPositioner() {
      let tickAmount = 3; // 目盛りの数 デフォルト: 3
      const ticks = [];
      // 目盛りを均等に配置する
      for (let i = 1; i < tickAmount; i++) {
        const val = this.xAxisMin + ((this.xAxisMax - this.xAxisMin) / tickAmount) * i;
        ticks.push(val);
      }
      return [this.xAxisMin, ...ticks, this.xAxisMax];
    },
  }
};
</script>
