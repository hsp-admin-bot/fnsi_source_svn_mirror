/** * バイタルチャート */

<template>
  <!-- mod FNSI-グラフ３軸表示対応「グラフ共通」 周 start -->
  <!-- <highcharts :options="chartOptions" :ref="dispDataItem" /> -->
  <div class="chart-position" :ref="`${dispDataItem}-${xAxisMin}`">
    <!-- mod 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 start -->
    <!-- <div class="header-icon ion-navicon" @click="legendEnableChanged()"> -->
    <div class="header-icon ion-ios-menu" @click="legendEnableChanged()" v-if="showLegend">
      <!-- mod 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 start -->
    </div>
    <highcharts v-show="chartOptions.series && shouldRenderChart" :options="chartOptions" :ref="dispDataItem" />
  </div>
  <!-- mod FNSI-グラフ３軸表示対応「グラフ共通」 周 end -->
</template>

<script>
import { Chart } from "@/compat/charts/highcharts";
import Highcharts from "@/compat/charts/highcharts";
import { Boost } from "@/compat/charts/highcharts";
import dayjs from "@/compat/date/dayjs";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";

import { generateDates } from "@/utils/util";
import graphDataMixins from "./graphDataMixins";
import elementResizeDetectorMaker from "@/compat/resize/element-resize-detector";
const erd = elementResizeDetectorMaker({
  strategy: "scroll"
});

Boost(Highcharts);
// add bug 6602 修正 chen start
import { BrokenAxis } from "@/compat/charts/highcharts";
BrokenAxis(Highcharts);
// add bug 6602 修正 chen end

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
  mixins: [ graphDataMixins ],

  data() {
    return {
      isMounted: false,
      isRendered: false,
      chartId: null,
      chartOptions: {
        plotOptions: {
          line: {
            pointPlacement: "on",
            connectNulls: true
          }
        },
        chart: {
          height: 150,
          margin: [0, -1, 16, 0],
          events: {
            load() {
              var xAxis = this.xAxis[0];
              if(this.series.some(item => item.userOptions.type === "scatter") && xAxis.userOptions.type !== 'datetime') {
                xAxis.setExtremes(0.5, this.xAxis[0].categories.length - 0.5);
              }
              // 初期化時にscatter系列の表示状態を制御
              const chart = this;
              setTimeout(() => {
                chart.series?.forEach(series => {
                  if (series.name && series.name.endsWith('_範囲外')) {
                    const mainSeriesName = series.name.replace('_範囲外', '');
                    const mainSeries = chart.series.find(s => s.name === mainSeriesName);
                    if (mainSeries && !mainSeries.visible) {
                      series.hide();
                    }
                  }
                });
                EventBus.$emit('chartRendered', {
                  chartId: this.userOptions.chartId || 'unknown',
                  timestamp: Date.now()
                });
              }, 200);
            },
            render() {
              if (!this.hasSentRenderEvent) {
                this.hasSentRenderEvent = true;
                setTimeout(() => {
                  EventBus.$emit('chartRenderComplete', {
                    chartId: this.userOptions.chartId || 'unknown',
                    chartType: this.userOptions.chart?.type || 'line',
                    timestamp: Date.now()
                  });
                }, 100);
              }
            }
            // add #9713 グラフの描画が遅い/共通ローダーが消えるのが早い wangchao 20260520 end
          }
        },
        title: {
          text: ""
        },
        credits: {
          enabled: false
        },
        xAxis: {
          tickmarkPlacement: 'on',
          tickLength: 3,
          displayPeriod: this.displayPeriod,
          title: {
            enabled: false
          },
          breaks: this.breaks ? this.breaks : [],
          // Highcharts v12: 中間の縦グリッドを表示（ラベル間隔は v9 同様に自動）
          gridLineWidth: 1,
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
          // 目盛り配置の計算(highchartの自動計算を使用しない)
        },
        yAxis: this.yAxis,
        legend: {
          backgroundColor: "rgba(255, 255, 255, 0.75)",
          floating: true,
          layout: "vertical",
          align: "left",
          verticalAlign: "middle",
          // mod FNSI-グラフ３軸表示対応「グラフ共通」 周 start
          // x: -10,
          x: 0,
          enabled: true,
          // mod FNSI-グラフ３軸表示対応「グラフ共通」 周 end
          y: 0,
          shadow: true
        },
        // add FNSI-グラフ３軸表示対応「グラフ共通」 周 start
        navigation: {
          buttonOptions: {
            enabled: false
          }
        },
        // add FNSI-グラフ３軸表示対応「グラフ共通」 周 end
        series: null,
        tooltip: {
          shared: false,
          useHTML: true,
          formatter: function() {
            const getExamClassText = (examClass) => {
              switch(examClass) {
                case "1": return "(前)";
                case "2": return "(後)";
                case "3": return "(他)";
                default: return "";
              }
            };

            // scatter系列の特別処理
            if (this.series && this.series.type === 'scatter') {
              const point = this.point;

              const chart = this.series.chart;

              // 時間情報を取得
              let headerEle;
              let targetX = point.x;
              let targetDate = point.date;

              if (targetDate) {
                // 長期間表示の場合
                headerEle = `<span>${dayjs(targetDate).format("YYYY/MM/DD(ddd)")}</span>`;
              } else {
                // 短期間表示の場合
                headerEle = `<span>${dayjs(targetX).format("YYYY/MM/DD(ddd) HH:mm")}</span>`;
              }

              let tooltipContent = headerEle;

              // まず現在のscatter点の情報を表示
              const currentExamClassText = getExamClassText(point.examClass);
              let currentValue = point.originalY;
              if (point.seriesName === '体温' && currentValue !== null) {
                currentValue = parseFloat(currentValue).toFixed(1);
              }
              const currentValueWithClass = currentExamClassText ? `${currentValue}${currentExamClassText}` : currentValue;
              tooltipContent += `<br><span style='color:${point.seriesColor}'>●</span>${point.seriesName}_範囲外: <b>${currentValueWithClass}</b>`;

              // 他の系列から同じ時間点のデータを取得（現在のscatter点に対応する主系列は除外）
              chart.userOptions.xAxis.type !== 'datetime' && chart.series.forEach(series => {
                if (series.type !== 'scatter' && series.visible && series.name !== point.seriesName) {
                  let sameTimePoints = [];

                  // データ点を検索
                  series.data.forEach(dataPoint => {
                    if (!dataPoint || dataPoint.y === null || dataPoint.y === undefined) return;

                    let isMatch = false;
                    if (targetDate) {
                      // 長期間表示：dateで比較
                      isMatch = dataPoint.date === targetDate;
                    } else {
                      // 短期間表示：x値で比較
                      const timeDiff = Math.abs(dataPoint.x - targetX);
                      isMatch = timeDiff < 300000; // 5分の許容範囲
                    }

                    if (isMatch) {
                      sameTimePoints.push(dataPoint);
                    }
                  });

                  if (sameTimePoints.length > 0) {
                    if (sameTimePoints.length === 1) {
                      const dataPoint = sameTimePoints[0];
                      const examClassText = getExamClassText(dataPoint.examClass);

                      // 元の値を取得（体温の場合は小数点1桁まで表示）
                      let originalValue = dataPoint.originalY || dataPoint.y0 || dataPoint.y;
                      if (series.name === '体温' && originalValue !== null) {
                        originalValue = parseFloat(originalValue).toFixed(1);
                      }

                      const valueWithClass = examClassText ? `${originalValue}${examClassText}` : originalValue;

                      tooltipContent += `<br><span style='color:${series.color}'>●</span>${series.name}${dataPoint.isTransformed ? '_範囲外' : ''}: <b>${valueWithClass}</b>`;
                    } else {
                      // 同じ時間に複数の値がある場合
                      const valuesWithClass = sameTimePoints.map((dataPoint) => {
                        const examClassText = getExamClassText(dataPoint.examClass);
                        let originalValue = dataPoint.originalY || dataPoint.y0 || dataPoint.y;
                        if (series.name === '体温' && originalValue !== null) {
                          originalValue = parseFloat(originalValue).toFixed(1);
                        }
                        const value = examClassText ? `${originalValue}${examClassText}` : originalValue;
                        return `<b style="margin-right: 4px;">${value}</b>`;
                      });

                      const hasTransformedPoint = sameTimePoints.some((sameTimePoint) => sameTimePoint.isTransformed);
                      tooltipContent += `<br><span style='color:${series.color}'>●</span>${series.name}${hasTransformedPoint ? '_範囲外' : ''}: ${valuesWithClass.join('')}`;
                    }
                  }
                }
              });

              return tooltipContent;
            }

            // 非scatter系列の既存処理
            if (this?.points?.length) {
              const pointDate = this.points[0].point.date || this.points[0].point.category;
              let headerEle = `<span>${dayjs(pointDate).format("YYYY/MM/DD(ddd)")}</span>`;
              this.points.forEach((item) => {
                const point = item.point;
                const seriesName = point.series.name;
                const sameXPoints = point.series.data.filter(point => {
                  return point && point.date === pointDate && point.y !== null && point.y !== undefined;
                });

                if (sameXPoints.length === 1) {
                  const examClassText = getExamClassText(point.examClass);
                  const displayValue = seriesName === '体温' ? Highcharts.numberFormat(point.y0, 1) : point.y0;
                  const valueWithClass = examClassText ? `${displayValue}${examClassText}` : displayValue;
                  headerEle += `<br><span style='color:${point.color}'>●</span>${seriesName}: <b>${valueWithClass}</b>`;
                } else {
                  const valuesWithClass = sameXPoints.map((point, index) => {
                    const examClassText = getExamClassText(point.examClass);
                    const displayValue = seriesName === '体温' ? Highcharts.numberFormat(point.y0, 1) : point.y0;
                    const value = examClassText ? `${displayValue}${examClassText}` : displayValue;
                    return `<b style="margin-right: 4px;">${value}</b>`;
                  });
                  headerEle += `<br><span style='color:${point.color}'>●</span>${seriesName}: ${valuesWithClass.join('')}`;
                }
              })

              return headerEle;
            } else {
              const currentX = this.x;
              const sameXPoints = this.series.data.filter(point => {
                return point && point.x === currentX && point.y !== null && point.y !== undefined;
              });

              var s = dayjs(this.x).format("YYYY/MM/DD(ddd) HH:mm");

              if (sameXPoints.length === 1) {
                const examClassText = getExamClassText(this.point.examClass);
                if (this.series.name=="体温"){
                  const displayValue = Highcharts.numberFormat(this.point.y0, 1);
                  const valueWithClass = examClassText ? `${displayValue}${examClassText}` : displayValue;
                  s += `<br /><span style='color:${this.color}'>●</span>` + this.series.name + '：' + '<b>'+valueWithClass+'</b>';
                }else{
                  const valueWithClass = examClassText ? `${this.point.y0}${examClassText}` : this.point.y0;
                  s += `<br /><span style='color:${this.color}'>●</span>` + this.series.name + '：' + '<b>'+valueWithClass+'</b>';
                }
              } else {
                const valuesWithClass = sameXPoints.map((point, index) => {
                  const examClassText = getExamClassText(point.examClass);
                  let displayValue;
                  if (this.series.name === "体温") {
                    displayValue = Highcharts.numberFormat(point.y0, 1);
                  } else {
                    displayValue = point.y0;
                  }
                  const value = examClassText ? `${displayValue}${examClassText}` : displayValue;
                  return `<b style="margin-right: 4px;">${value}</b>`;
                });
                s += `<br /><span style='color:${this.color}'>●</span>` + this.series.name + '：' + valuesWithClass.join('');
              }
              return s;
            }
          },
          // 例: 1970年1月1日(木) 00:00
          // xDateFormat: "%Y年%b月%e(%a) %H:%M",
          // プロット点をフォーカスアウト後に100ミリ待機してツールチップを非表示
          hideDelay: 100,
          // plotOptions.series.stickyTrackingと一緒
          snap: 0
        }
      },
      shouldRenderChart: false,
      observer: null
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

    // add bug 6602 修正 chen start
    /**
     * @description x軸の上
     * breaks(
     *   from: ミリ秒
     *   to:   ミリ秒
     * )
     */
    breaks: {
      type: Array,
      default: () => []
    },
    // add bug 6602 修正 chen end

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
    },
    // mod 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 start
    /**
     * @description 表示種類
     */
    chartType:{
      type: String,
      default: undefined
    },
    /**
     * @description 表示
     */
    showLegend:{
      type: Boolean,
      default: true
    }
  },
  // mod 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 end
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      splittedWidth: "getSplittedWidth"
    }),
    ...mapGetters("pat-viewer", ["getTickPositions"]),
    yAxisPositions() {
      if (!this.isMounted) return;
      if (!this.$refs[this.dispDataItem]) return;
      const chart = this.$refs[this.dispDataItem].chart;
      // mod #10077 by zhangruixue 2023-11-24 --start
      const len = chart?.yAxis.length;
      // mod #10077 by zhangruixue 2023-11-24 --end
      const tmpTick = [];
      for (let i = 0; i < len; i++) {
        tmpTick.push({
          tickArr: chart.yAxis[i].tickPositions
        });
      }
      return tmpTick;
    },
    isLongPeriod() {
      return ["4", "5", "6", "7"].includes(this.displayPeriod);
    }
  },

  created() {
    this.init();
    this.chartId = `${this.dispDataItem}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    this.chartOptions.chartId = this.chartId;
  },

  mounted() {
    this.isMounted = true;
    this.observer = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.shouldRenderChart = true;
          observer.unobserve(entry.target);
          this.$nextTick(() => {
            const tickPositions = this.chartOptions.xAxis?.tickPositions;
            this.syncChartAxis(tickPositions);
          });
          const resizeHost = this.getResizeHostElement();
          if (resizeHost) {
            erd.listenTo(resizeHost, () => {
              if (this.$refs[this.dispDataItem]) {
                this.$refs[this.dispDataItem]?.chart?.reflow();
              }
            });
          }
          setTimeout(() => {
            this.notifyChartRendered();
          }, 1000);
        }
      });
    });
    this.observer.observe(this.$refs[`${this.dispDataItem}-${this.xAxisMin}`]);
  },

  watch: {
    async yAxisPositions(value) {
      if (!value) return;
      const tickPos = this.getTickPositions;
      tickPos[this.dispDataItem] = value.reverse();
      await this.setTickPositions(tickPos);
    },
    windowHeight() {
      this.resizeChart();
    },
    splittedWidth() {
      this.resizeChart();
    }
  },

  methods: {
    getResizeHostElement() {
      return this.$el?.parentElement || null;
    },
    ...mapActions("pat-viewer", [
      "setTickPositions",
    ]),
    init() {
      // add 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 start
      if (this.chartType) {
        this.chartOptions.chart.type = this.chartType
      }
      if (!this.showLegend) {
        this.chartOptions.legend.enabled = this.showLegend
      }
      // add 5930 バイタル・モニタグラフ入室～退室のマスタおよび画面表示不正 張 end

      this.applyPatViewerChartBottomLayout(this.chartOptions);
      this.chartOptions.yAxis = this.buildYAxisWithGrid(this.yAxis);
      this.chartOptions.xAxis.breaks = this.breaks || [];

      let tickPositions = [];
      if (this.isLongPeriod) {
        this.chartOptions.xAxis.plotLines = this.caculatePlotLines();
        this.chartOptions.xAxis.categories = generateDates(this.xAxisMin, this.xAxisMax, this.displayPeriod !== "4");
        this.chartOptions.xAxis.max = this.chartOptions.xAxis.categories.length;
        this.chartOptions.tooltip.shared = true;
        tickPositions = this.caculateTickPositions();
        this.chartOptions.xAxis.tickPositions = tickPositions;
        this.chartOptions.xAxis.className = "highcharts-x-axis";
      } else {
        this.chartOptions.xAxis.type = "datetime";
        this.chartOptions.xAxis.min = this.xAxisMin;
        this.chartOptions.xAxis.max = this.xAxisMax;
        this.chartOptions.tooltip.xDateFormat = "%Y年%b月%e(%a) %H:%M";
        tickPositions = this.tickPositioner();
        this.chartOptions.xAxis.tickPositions = tickPositions;
      }
      this.chartOptions.series = this.seriesData(this.xAxisMin, this.xAxisMax);

      this.syncChartAxis(tickPositions);

      this.chartOptions.chart.events = {
        ...this.chartOptions.chart.events,
        render: () => {
          if (!this.isRendered) {
            this.isRendered = true;
            this.$nextTick(() => {
              EventBus.$emit('chartRendered', {
                chartId: this.chartId,
                componentId: this.dispDataItem,
                timestamp: Date.now(),
                chartType: this.chartOptions.chart.type
              });
            });
          }
        }
      };
    },

    /**
     * X軸の目盛り・縦グリッド・plotLines を Highcharts v12 で確実に反映する
     */
    syncChartAxis(tickPositions) {
      this.$nextTick(() => {
        const chart = this.$refs[this.dispDataItem]?.chart;
        if (!chart) {
          return;
        }
        this.syncPatViewerChartAxis(chart, {
          tickPositions,
          breaks: this.breaks || [],
          plotLines: this.chartOptions.xAxis.plotLines || [],
          isDatetime: !this.isLongPeriod,
          xAxisMin: this.xAxisMin,
          xAxisMax: this.xAxisMax
        });
      });
    },
    notifyChartRendered() {
      if (this.$refs[this.dispDataItem]?.chart) {
        EventBus.$emit('chartRendered', {
          chartId: this.chartId,
          componentId: this.dispDataItem,
          timestamp: Date.now(),
          chartType: this.chartOptions.chart.type,
          isManual: true
        });
      }
    },
    // add #9713 グラフの描画が遅い/共通ローダーが消えるのが早い wangchao 20260520 end
    tickPositioner() {
      let tickAmount = 0;
      const ticks = [];

      // 表示期間によって目盛りの数を設定
      let maxD = dayjs(this.xAxisMax).startOf('day');
      let minD = dayjs(this.xAxisMin).startOf('day');
      let days = maxD.diff(minD, 'days');
      switch (this.displayPeriod + "") {
        case "1":
          tickAmount = days === 0 ? 4 : days * 4;
          break;
        case "2":
          tickAmount = days === 0 ? 3 : days * 3;
          break;
        case "3":
          tickAmount = days === 0 ? 2 : days * 2;
          break;
      }

      // 目盛りを均等に配置する
      for (let i = 1; i < tickAmount; i++) {
        const val = this.xAxisMin + ((this.xAxisMax - this.xAxisMin) / tickAmount) * i;
        ticks.push(val);
      }
      return [this.xAxisMin, ...ticks, this.xAxisMax];
    },
    resizeChart() {
      const chart = this.$refs[this.dispDataItem]?.chart;
      chart?.reflow();
    },
    // add FNSI-グラフ３軸表示対応「グラフ共通」 周 start
    legendEnableChanged() {
      this.$refs[this.dispDataItem].chart.legend.update({
        enabled: !this.$refs[this.dispDataItem].chart.legend.display
      });
    },
    // add FNSI-グラフ３軸表示対応「グラフ共通」 周 end
    seriesData(min, max) {
      const dateArr = generateDates(min, max, this.displayPeriod !== "4");
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
          seriesColors[item.name] = CHART_SERIES_COLORS[legendIdArr.length];
          // IDが存在しない場合、そのIDを格納
          legendIdArr.push(item.name);
        }

        let transformedData = [];
        const outOfRangePoints = [];

        // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
        if (this.isLongPeriod) {
          const dataMap = item.data.reduce((map, entry) => {
            const dateKey = dayjs(entry[0]).format("YYYYMMDD_HHmmss");
            if (!map[dateKey]) {
              map[dateKey] = [];
            }
            map[dateKey].push(entry);
            return map;
          }, {});

          const flatData = dateArr.flatMap((date, index) => {
            const entries = Object.entries(dataMap)
              .filter(([key]) => key.startsWith(date))
              .flatMap(([_, values]) => values);

            if (entries.length === 0) {
              return [{ x: index, y0: null, y: null, date: date }];
            }
            return entries.map((entry, subIndex) => ({
              x: index + subIndex * 0.3,
              y0: Number(entry[1]),
              originalY: Number(entry[1]),
              examClass: entry[2] || entry.examClass,
              date: date
            }));
          });

          // 処理各データ点，検査是否超出範囲
          flatData.forEach(point => {
            if (point.y0 === null || point.y0 === undefined) {
              transformedData.push({ ...point, y: null, isTransformed: false });
              return;
            }

            const isOutOfRange = point.y0 > item.yAxisMax || point.y0 < item.yAxisMin;

            if (isOutOfRange) {
              // 範囲外の点：主折線で境界値表示し、scatter系列に追加
              let displayY;
              if (point.y0 > item.yAxisMax) {
                displayY = item.yAxisMax;
              } else if (point.y0 < item.yAxisMin) {
                displayY = item.yAxisMin;
              }

              // scatter系列用の点を追加
              outOfRangePoints.push({
                x: point.x,
                y: displayY,
                originalY: point.y0,
                date: point.date,
                examClass: point.examClass,
                seriesName: item.name,
                seriesColor: item.color,
                yAxis: item.yAxis,
                isUpArrow: point.y0 > item.yAxisMax
              });

              // 主系列では原始値を保持（折れ線の連続性を確保）
              transformedData.push({
                ...point,
                y: point.y0,
                isTransformed: true
              });
            } else {
              // 正常範囲内の点
              transformedData.push({
                ...point,
                y: point.y0,
                isTransformed: false
              });
            }
          });
          // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end
        } else {
          const flatData = item.data.map(i => {
            const x = dayjs(i[0]).valueOf();
            const y = i[1];
            return {
              x: x,
              y0: y,
              originalY: y,
              examClass: i[2] || i.examClass,
            };
          });

          // 処理各データ点，検査是否超出範囲
          flatData.forEach(point => {
            if (point.y0 === null || point.y0 === undefined) {
              transformedData.push({ ...point, y: null, isTransformed: false });
              return;
            }

            const isOutOfRange = point.y0 > item.yAxisMax || point.y0 < item.yAxisMin;

            if (isOutOfRange) {
              // 範囲外の点：主折線で境界値表示し、scatter系列に追加
              let displayY;
              if (point.y0 > item.yAxisMax) {
                displayY = item.yAxisMax;
              } else if (point.y0 < item.yAxisMin) {
                displayY = item.yAxisMin;
              }

              // scatter系列用の点を追加
              const scatterPoint = {
                x: point.x,
                y: displayY,
                originalY: point.y0,
                examClass: point.examClass,
                seriesName: item.name,
                seriesColor: item.color,
                yAxis: item.yAxis,
                isUpArrow: point.y0 > item.yAxisMax
              };

              // datetime軸の場合、x値が有効な時間戳であることを確認
              if (!this.isLongPeriod && (typeof scatterPoint.x !== 'number' || isNaN(scatterPoint.x))) {
                console.warn('Invalid x value for datetime axis:', scatterPoint.x, 'skipping point');
                // 無効なデータポイントはスキップして処理を続行
              } else {
                outOfRangePoints.push(scatterPoint);
              }

              // 主系列では原始値を保持（折れ線の連続性を確保）
              transformedData.push({
                ...point,
                y: point.y0,
                isTransformed: true
              });
            } else {
              // 正常範囲内の点
              transformedData.push({
                ...point,
                y: point.y0,
                isTransformed: false
              });
            }
          });
        }

        transformedData.sort((a, b) => (a.x ?? 0) - (b.x ?? 0));
        outOfRangePoints.sort((a, b) => (a.x ?? 0) - (b.x ?? 0));

        // 主系列を追加
        const series = {
          // IDが存在する場合、重複しないように定義はしない
          id: isLegendIdExists ? undefined : item.no,
          // 凡例名
          name: item.name,
          yAxis: item.yAxis,
          // IDが存在する場合、そのIDを使用
          linkedTo: isLegendIdExists ? item.name : undefined,
          tooltip: {
            // shared: true,
            headerFormat: "<span>{point.key}</span><br/>",
            pointFormatter: function() {
              const point = this;
              let valueText = point.originalY || point.y0;
              let suffixText = "";

              // 検査区分のテキスト処理
              if (point.examClass) {
                const examClassText = point.examClass === "1" ? "(前)" :
                                    point.examClass === "2" ? "(後)" :
                                    point.examClass === "3" ? "(他)" : "";
                if (examClassText) {
                  valueText = `${valueText}${examClassText}`;
                }
              }

              return `<span style='color:${point.color}'>●</span> ${point.series.name}${point.isTransformed ? '_範囲外' : ''}: <b>${valueText}</b><br/>`;
            }
          },
          // シリーズ線の色
          color: item.color,
          marker: item.marker ? item.marker : {},
          // プロットデータ
          turboThreshold: 999999,
          data: transformedData,
          point: {
            events: {
              mouseOver: function() {
                const chart = this.series.chart;
                const seriesName = this.series.name;
                const scatterSeries = chart.series.find(s =>
                  s.name === `${seriesName}_範囲外`
                );

                this.setState('hover');

                if (scatterSeries && scatterSeries.visible) {
                  const newData = scatterSeries.data.map(point => ({
                    ...point.options,
                    marker: {
                      ...point.options.marker,
                      radius: 10,
                    }
                  }));
                  scatterSeries.setData(newData, true);
                }
              },
              mouseOut: function() {
                const chart = this.series.chart;
                const seriesName = this.series.name;
                const scatterSeries = chart.series.find(s =>
                  s.name === `${seriesName}_範囲外`
                );

                this.setState('');

                if (scatterSeries && scatterSeries.visible) {
                  const newData = scatterSeries.data.map(point => ({
                    ...point.options,
                    marker: {
                      ...point.options.marker,
                      radius: 0
                    }
                  }));
                  scatterSeries.setData(newData, true);
                }
              }
            }
          },
          events: {
            legendItemClick: function(e) {
              // 凡例クリック時に関連するscatter系列を制御
              const chart = this.chart;
              const seriesName = this.name;
              const willBeVisible = !this.visible;

              setTimeout(() => {
                // 関連するscatter系列を検索
                const scatterSeries = chart.series.find(s =>
                  s.name === `${seriesName}_範囲外`
                );

                if (scatterSeries) {
                  if (willBeVisible) {
                    scatterSeries.show();
                  } else {
                    scatterSeries.hide();
                  }
                }
              }, 100);
            }
          }
        };
        seriesArr.push(series);

        // 範囲外の点を独立したscatter系列として追加
        if (outOfRangePoints.length > 0) {
          const scatterConfig = {
            type: "scatter",
            name: `${item.name}_範囲外`,
            color: item.color,
            yAxis: item.yAxis,
            zIndex: 10,
            showInLegend: false, // 凡例に表示しない
            linkedTo: item.name, // 主系列と関連付け
            enableMouseTracking: true
          };

          // datetime軸の場合の特別設定
          if (!this.isLongPeriod) {
            scatterConfig.findNearestPointBy = 'x'; // datetime軸ではx軸優先
            scatterConfig.stickyTracking = true; // datetime軸でのマウス追跡改善
            scatterConfig.relativeXValue = false; // 絶対時間値を使用
            scatterConfig.pointInterval = null; // 自動間隔を無効化
            scatterConfig.pointStart = null; // 自動開始点を無効化
          }

          seriesArr.push({
            ...scatterConfig,
            marker: {
              symbol: 'circle',
              radius: 0, // マーカーを非表示にしてUnicode文字のみ表示
              fillColor: 'transparent',
              lineColor: 'transparent',
              lineWidth: 0,
              states: {
                hover: {
                  enabled: true,
                  fillColor: item.color,
                  lineColor: item.color,
                  lineWidth: 2,
                  radius: 6
                }
              }
            },

            dataLabels: {
              enabled: true,
              allowOverlap: true,
              formatter: function() {
                // 各ポイントの矢印方向を判定して文字を返す
                return this.point.isUpArrow ? '↑' : '↓';
              },
              style: {
                color: item.color, // 主系列と同じ色を使用
                fontSize: '18px',
                fontWeight: 'bold',
                textOutline: 'none'
              },
              states: {
                hover: {
                  style: {
                    color: item.color,
                    fontSize: '20px', // hover時に少し大きく
                    fontWeight: 'bold',
                    textOutline: '1px contrast'
                  }
                }
              },
              align: 'center', // 水平方向の中央揃え
              verticalAlign: 'middle', // 垂直方向の中央揃え
              x: 0, // 水平オフセット
              y: 0, // 垂直オフセット（0で正確に点位置に配置）
              useHTML: false
            },
            turboThreshold: 999999,
            data: outOfRangePoints,
            point: {
              events: {
                mouseOver: function() {
                  const chart = this.series.chart;
                  const lineName = this.series.name.replace('_範囲外', '');
                  const lineSeries = chart.series.find(s =>
                    s.name === lineName && (s.type === 'line' || !s.type)
                  );

                  // 設置line系列為hover狀態
                  if (lineSeries && lineSeries.visible) {
                    lineSeries.setState('hover');
                  }

                  // 同時激活當前scatter點的視覺效果
                  this.setState('hover');
                },
                mouseOut: function() {
                  const chart = this.series.chart;
                  const lineName = this.series.name.replace('_範囲外', '');
                  const lineSeries = chart.series.find(s =>
                    s.name === lineName && (s.type === 'line' || !s.type)
                  );

                  this.setState('');

                  if (lineSeries && lineSeries.visible) {
                    lineSeries.setState('');
                  }
                }
              }
            }
          });
        }
      });

      this.chartOptions.legend.enabled = false;
      return seriesArr[0] === undefined ? [{ data: dateArr.fill(null) }] : seriesArr;
    },
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
:deep(.highcharts-axis.highcharts-xaxis .highcharts-tick) {
  stroke: #ccd6eb;
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
