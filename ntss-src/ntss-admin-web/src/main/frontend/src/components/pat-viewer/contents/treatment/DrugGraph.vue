/** * 薬剤チャート */

<template>
  <!-- mod FNSI-グラフ３軸表示対応「グラフ共通」 周 start -->
  <!-- <highcharts :options="chartOptions" :ref="dispDataItem" /> -->
  <div class="chart-position">
    <div class="header-icon ion-ios-menu" @click="legendEnableChanged()">
    </div>
    <highcharts v-if="chartOptions.series" :options="chartOptions" :ref="dispDataItem" />
  </div>
  <!-- mod FNSI-グラフ３軸表示対応「グラフ共通」 周 end -->
</template>

<script>
import { Chart } from "@/compat/charts/highcharts";
import Highcharts from "@/compat/charts/highcharts";
import dayjs from "@/compat/date/dayjs";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import elementResizeDetectorMaker from "@/compat/resize/element-resize-detector";

import { generateDates } from "@/utils/util";
import graphDataMixins from "./graphDataMixins";
// add FNSI-長期の薬剤グラフの表示を改善「235」 周 start
// Load the xrange module.

const erd = elementResizeDetectorMaker({
  strategy: "scroll"
});

Highcharts.setOptions({
  lang: {
    shortWeekdays: ["日", "月", "火", "水", "木", "金", "土"],
    shortMonths: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
  },
  global: {
    useUTC: false
  }
});

// del FNSI-長期の薬剤グラフの表示を改善「235」 周 start
// const CHART_SERIES_COLORS = [
//   "red",
//   "lightgreen",
//   "orange",
//   "darkgreen",
//   "pink"
// ];
// del FNSI-長期の薬剤グラフの表示を改善「235」 周 end

export default {
  components: {
    highcharts: Chart
  },
  mixins: [ graphDataMixins ],
  data() {
    return {
      isMounted: false,
      // del FNSI-長期の薬剤グラフの表示を改善「235」 周 start
      // seriesColors: [],
      // del FNSI-長期の薬剤グラフの表示を改善「235」 周 end
      chartOptions: {
        plotOptions: {
          series: {
            borderWidth: 0,
            pointPlacement: "between",
            minPointLength: 3,
            threshold: null,
            softThreshold: false,
            pointPadding: 0.1,
            groupPadding: 0.2,
          }
        },
        chart: {
          type: "column",
          // 隠しシリーズを無視
          ignoreHiddenSeries: false,
          height: 150,
          margin: [0, -1, 16, 0],
          events: {
            load() {
              var xAxis = this.xAxis[0];
              if (this.series.some(item => item.userOptions.type === "xrange")) {
                xAxis.setExtremes(0.5, this.xAxis[0].categories.length - 0.5);
                this.options.plotOptions.line.pointPlacement = "on";
              } else if(this.series.some(item => item.userOptions.type === "column")) {
                xAxis.setExtremes(0, this.xAxis[0].categories.length - 1);
              }
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
          min: 0,
          max: this.categories?.length ? (this.categories.length - 1) : undefined,
          tickmarkPlacement: 'on',
          className: "highcharts-x-axis",
          tickLength: 3,
          displayPeriod: this.displayPeriod,
          caculateTickPositions: this.caculateTickPositions,
          gridLineWidth: 1,
          title: {
            enabled: false
          },
          plotLines: null,
          labels: {
            y: 12,
            style: {
              fontSize: "11px"
            },
            formatter() {
              const date = dayjs(this.value);
              const isLongPeriod = ["4", "5", "6", "7"].includes(
                this.axis.userOptions.displayPeriod
              );
              if (isLongPeriod) {
                return date.format("MM/DD");
              } else {
                return date.format("HH:mm");
              }
            }
          },
          categories: null,
        },
        yAxis: this.yAxis,
        legend: {
          backgroundColor: "rgba(255, 255, 255, 0.75)",
          floating: true,
          layout: "vertical",
          align: "left",
          verticalAlign: "middle",
          x: 0,
          enabled: true,
          y: 0,
          shadow: true
        },
        navigation: {
          buttonOptions: {
            enabled: false
          }
        },
        series: null,
        tooltip: {
          useHTML: true,
          hideDelay: 100,
          snap: 0
        }
      }
    };
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
      // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 start
      // type: Object,
      // default() {
      //   return {};
      // }
      type: Array,
      default() {
        return [];
      }
      // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 end
    },

    /**
     * @description y軸の目盛り
     *    例:
     *    ['mm', '°C],
     */
    // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 start
    // yAxisValues: {
    //   type: Object,
    //   default: undefined
    // },
    yAxis: {
      type: Array,
      default() {
        return [];
      }
    },
    // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 end

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

    /**
     * @description 表示期間
     */
    displayPeriod: {
      type: String,
      default: "0"
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
    ...mapGetters("pat-viewer", ["getTickPositions"]),
    yAxisPositions() {
      if (!this.isMounted) return;
      if (!this.$refs?.[this.dispDataItem]?.chart) return;
      const chart = this.$refs[this.dispDataItem].chart;
      const len = chart.yAxis.length;
      const tmpTick = [];
      for (let i = 0; i < len; i++) {
        // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 start
        // const y = this.seriesColors.find(k => {
        //   return k.index === i;
        // });
        // tmpTick.push({
        //   tickArr: chart.yAxis[i].tickPositions,
        //   color: y ? y.color : ''
        // });
        tmpTick.push({
          tickArr: chart.yAxis[i].tickPositions
        });
        // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 end
      }
      return tmpTick;
    }
  },

  mounted() {
    this.isMounted = true;
    this.$nextTick(() => {
      const chart = this.$refs[this.dispDataItem]?.chart;
      if (chart) {
        this.syncPatViewerChartAxis(chart, {
          tickPositions: this.chartOptions.xAxis.tickPositions,
          plotLines: this.chartOptions.xAxis.plotLines || []
        });
      }
    });
    // 親コンポネントリサイズ時にグラフのサイズを合わせて
    const resizeHost = this.getResizeHostElement();
    if (resizeHost) {
      erd.listenTo(resizeHost, () => {
        if (this.$refs[this.dispDataItem]) {
          this.$refs[this.dispDataItem]?.chart?.reflow();
        }
      });
    }
  },

  watch: {
    async yAxisPositions(value) {
      if (!value) return;
      const tickPos = this.getTickPositions;
      // mod FNSI-グラフ３軸表示対応「グラフ共通」 周 start
      // tickPos[this.dispDataItem] = value;
      tickPos[this.dispDataItem] = value.reverse();
      // mod FNSI-グラフ３軸表示対応「グラフ共通」 周 end
      await this.setTickPositions(tickPos);
    },
    windowHeight() {
      this.resizeChart();
    },
    splittedWidth() {
      this.resizeChart();
    }
  },

  created() {
    this.init();
  },

  beforeUnmount() {
    const resizeHost = this.getResizeHostElement();
    if (resizeHost) {
      erd.uninstall(resizeHost);
    }
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
    const chartRef = this.$refs[this.dispDataItem];
    if (chartRef?.chart) {
      if (typeof chartRef.chart.destroy === 'function') {
        chartRef.chart.destroy();
      }
      chartRef.chart = null;
    }

    this.chartOptions = null;
    this.shouldRenderChart = false;
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    getResizeHostElement() {
      return this.$el?.parentElement || null;
    },
    ...mapActions("pat-viewer", [
      "setTickPositions",
    ]),
    init() {
      this.applyPatViewerChartBottomLayout(this.chartOptions);
      this.chartOptions.yAxis = this.buildYAxisWithGrid(this.yAxis);
      this.chartOptions.xAxis.plotLines = this.caculatePlotLines();
      this.chartOptions.xAxis.categories = generateDates(this.xAxisMin, this.xAxisMax, this.displayPeriod !== "4");
      this.chartOptions.xAxis.tickPositions = this.caculateTickPositions();
      this.chartOptions.series = this.seriesData(this.xAxisMin, this.xAxisMax);
      this.$nextTick(() => {
        const chart = this.$refs[this.dispDataItem]?.chart;
        if (!chart) {
          return;
        }
        this.syncPatViewerChartAxis(chart, {
          tickPositions: this.chartOptions.xAxis.tickPositions,
          plotLines: this.chartOptions.xAxis.plotLines || []
        });
      });
    },
    resizeChart() {
      if (!this.$refs?.[this.dispDataItem]?.chart) return;
      const chart = this.$refs[this.dispDataItem].chart;
      chart.reflow();
    },
    // add FNSI-グラフ３軸表示対応「グラフ共通」 周 start
    legendEnableChanged() {
      this.$refs[this.dispDataItem].chart.legend.update({
        enabled: !this.$refs[this.dispDataItem].chart.legend.display
      });
    },
    seriesData(min, max) {
      const dateArr = generateDates(min, max, this.displayPeriod !== "4");
      const mergeData = (arr) => {
        let dates = [];
        arr.forEach(item => {
          let [start, end, count] = item;
          let currentDate = start;
          while (currentDate <= end) {
            dates.push({ date: currentDate, count: Number(count) });
            currentDate = dayjs(currentDate).add(1, "days").format("YYYYMMDD");
          }
        });

        dates.sort((a, b) => a.date - b.date);
        let mergedDates = [];
        dates.forEach(item => {
          let lastItem = mergedDates[mergedDates.length - 1];
          if (lastItem && lastItem.date === item.date) {
            lastItem.count += item.count;
          } else {
            mergedDates.push({ ...item });
          }
        });
        let result = [];
        mergedDates.forEach(item => {
          let lastItem = result[result.length - 1];
          if (lastItem && Number(lastItem.end) + 1 === Number(item.date) && lastItem.count === item.count) {
            lastItem.end = item.date;
          } else {
            result.push({ start: item.date, end: item.date, count: item.count });
          }
        });

        result = result.map(item => [item.start, item.end, item.count.toString()]);
        return result;
      };
      const seriesArr = [];
      // 凡例用ID格納(同じ項目は同じ凡例を使用)
      const legendIdArr = [];
      // 各ordMainレコードが1つのシリーズとして処理する
      const chartData = this.chartData.filter((item, index, self) => {
        if (item.type !== "xrange") return true;
        return !self.some((otherItem, otherIndex) =>
          otherItem.type === "xrange" && otherItem.name === item.name && otherIndex < index
        );
      });
      chartData?.forEach(item => {
        // 各レコードの項目を処理していく
        const isLegendIdExists = legendIdArr.find(i => {
          return i === item.name;
        });

        if (!isLegendIdExists) {
          // IDが存在しない場合、そのIDを格納
          legendIdArr.push(item.name);
        }
        switch(item.type) {
          case "column": {
            const dataMap = item.data.reduce((map, entry) => {
              const dateKey = dayjs(entry[0]).format("YYYYMMDD");
              map[dateKey] = entry;
              return map;
            }, {});
            const data = dateArr.map((i, index) => {
              if (index === 0 && chartData.some(item => item.type === "xrange")) {
                index = 0.5;
              }
              const res = dataMap[i];
              return res ? {
                x: index,
                y: res[1]
              } : {
                x: index,
                y: null
              };
            })
            let pointRange = 1;
            let zIndex = 1;
            let dataType = "日";
            switch (item.dateType) {
              case 'day':
                zIndex = 5;
                dataType = "日"
                break;
              case 'week':
                pointRange = 7;
                zIndex = 4;
                dataType = "1週"
                break;
              case 'twoWeek':
                pointRange = 14;
                zIndex = 3;
                dataType = "2週"
                break;
              case 'month':
                pointRange = 31;
                zIndex = 2;
                dataType = "1ヶ月"
                break;
              case 'threeMonth':
                pointRange = 93;
                zIndex = 1;
                dataType = "3ヶ月"
                break;
              default:
                break;
            }
            seriesArr.push({
              type: "column",
              dateType: dataType,
              name: item.name,
              color: item.color,
              yAxis: item.yAxis,
              pointRange: pointRange,
              zIndex: zIndex,
              id: isLegendIdExists ? undefined : item.no,
              linkedTo: isLegendIdExists ? item.name : undefined,
              tooltip: {
                shared: true,
                formatter() {
                  let headerEle = `<span>${dayjs(this.x).format("YYYY年M月D日(dd)")}</span>`;
                  this.points.forEach(point => {
                    headerEle += `<br><span style='color:${point.color}'>●</span>${point.series.name}(${point.series.userOptions.dateType}): <b>${point.point.y}</b>`;
                  });
                  return headerEle;
                },
              },
              turboThreshold: 999999,
              data: data
            });
          }
            break;

          case "xrange": {
            seriesArr.push({
              type: "xrange",
              name: item.name,
              color: item.color,
              yAxis: item.yAxis,
              grouping: false,
              id: isLegendIdExists ? undefined : item.no,
              linkedTo: isLegendIdExists ? item.name : undefined,
              pointWidth: 8,
              colorByPoint: false,
              turboThreshold: 999999,
              dateArr: dateArr,
              opacity: 0.8,
              tooltip: {
                headerFormat: "",
                pointFormatter() {
                  return `
                    <span>${this.options.startDate} - ${this.options.endDate}</span></br>
                    <span style='color:${this.color}'>●</span>${this.series.name}: <b>${this.options.y}</b>
                  `;
                }
              },
              data: mergeData(item.data).map(i => {
                const x = dateArr.findIndex((date) => date === i[0]);
                if (x === -1) return;
                const x2 = dateArr.findIndex((date) => date === i[1]) > -1 ? dateArr.findIndex((date) => date === i[1]) + 1.5 : dateArr.length + 2;
                const y = Number(i[2]);
                return {
                  x: x - 0.5,
                  x2: x2 - 0.5,
                  startDate: dayjs(i[0]).format('YYYY年M月D日(dd)'),
                  endDate: dayjs(i?.[1]).format('YYYY年M月D日(dd)'),
                  y: y
                };
              })
            });
          }
            break;
        }

      });
      this.chartOptions.legend.enabled = false;
      return seriesArr[0] === undefined ? [{ data: dateArr.fill(null) }] : seriesArr;
    },
    // mod FNSI-長期の薬剤グラフの表示を改善「235」 周 end
  }
};
</script>
/* add FNSI-グラフ３軸表示対応「グラフ共通」 周 start */
<style scoped>
.header-icon {
  position: absolute;
  z-index: 1;
  margin-top: 8px;
  margin-left: 8px;
  width: 30px;
  height: 30px;
  background-color: var(--ntss-base-background-color);
  text-align: center;
  line-height: 30px;
  font-size: 20pt;
  /* add FNSI-4400 グラフの要素凡例表示非表示アイコンの透過 liumx start */
  opacity: 0.2;
  /* add FNSI-4400 グラフの要素凡例表示非表示アイコンの透過 liumx end */
}
:deep(.highcharts-x-axis .highcharts-grid-line),
:deep(.highcharts-yaxis-grid .highcharts-grid-line) {
  stroke: #e6e6e6;
  stroke-width: 1px;
}
:deep(.highcharts-xaxis-labels text) {
  font-size: 11px;
}
:deep(.highcharts-legend-item text) {
  fill: #333333 !important;
}
.chart-position {
  position: sticky;
  z-index: 0;
}
</style>
/* add FNSI-グラフ３軸表示対応「グラフ共通」 周 end */
