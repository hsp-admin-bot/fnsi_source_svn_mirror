/** * 複合チャート */

<template>
  <div class="chart-position">
    <div class="header-icon ion-ios-menu" @click="legendEnableChanged()">
    </div>
    <highcharts v-if="chartOptions.series" :options="chartOptions" :ref="dispDataItem" />
  </div>
</template>

<script>
import { Chart } from "@/compat/charts/highcharts";
import Highcharts from "@/compat/charts/highcharts";
import dayjs from "@/compat/date/dayjs";
import { mapActions, mapGetters } from "@/compat/vue/vuex";

import { generateDates } from "@/utils/util";
import graphDataMixins from "./graphDataMixins";
// Load the xrange module.
import { Xrange } from '@/compat/charts/highcharts';
// Initialize xrange module.
import elementResizeDetectorMaker from "@/compat/resize/element-resize-detector";
import uniqBy from '@/compat/collections/lodash/uniqBy'
const erd = elementResizeDetectorMaker({
  strategy: "scroll"
});
Xrange(Highcharts);

Highcharts.setOptions({
  lang: {
    shortWeekdays: ["日", "月", "火", "水", "木", "金", "土"],
    shortMonths: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
  },
  global: {
    useUTC: false
  }
});

export default {
  components: {
    highcharts: Chart
  },
  mixins: [ graphDataMixins ],

  data() {
    return {
      isMounted: false,
      chartOptions: {
        plotOptions: {
          line: {
            pointPlacement: "on",
            findNearestPointBy: 'xy'
          },
          column: {
            minPointLength: 3,
            threshold: null,
            softThreshold: false,
            pointPadding: 0.1,
            groupPadding: 0.2,
            borderWidth: 0
          },
          series: {
            pointPlacement: "between",
            borderWidth: 0,
            connectNulls: true, // null値を接続し、折れ線を連続に保つ
          }
        },
        chart: {
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
              } else if(this.series.some(item => item.userOptions.type === "scatter")) {
                xAxis.setExtremes(0, this.xAxis[0].categories.length - 1);
              } else {
                xAxis.setExtremes(0, this.xAxis[0].categories.length);
              }

              // 初期化時にscatter系列の表示状態を制御
              const chart = this;
              setTimeout(() => {
                chart.series.forEach(series => {
                  if (series.name && series.name.endsWith('_範囲外')) {
                    const mainSeriesName = series.name.replace('_範囲外', '');
                    const mainSeries = chart.series.find(s => s.name === mainSeriesName);
                    if (mainSeries && !mainSeries.visible) {
                      series.hide();
                    }
                  }
                });
              }, 200);
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
          tickmarkPlacement: 'on',
          className: "highcharts-x-axis",
          tickLength: 3,
          displayPeriod: this.displayPeriod,
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
          shared: false,
          useHTML: true,
          enabled: true,
          formatter() {
            // カスタムtooltipが表示中の場合は何も表示しない
            if (this.series.chart.customTooltipVisible) {
              return false;
            }
            const type = this.series.userOptions.type;
            let headerEle;

            if (type === "xrange") {
              headerEle = `<span>${this.point.startDate} - ${this.point.endDate}</span>`;
              const displayValue = this.point.originalY !== undefined ? this.point.originalY : this.point.y;
              return `${headerEle}<br><span style='color:${this.color}'>●</span>${this.series.name}: <b>${displayValue}</b>`;
            } else {
              const pointDate = this.point.date || this.point.category;
              headerEle = `<span>${dayjs(pointDate).format("YYYY/MM/DD(ddd)")}</span>`;

              const currentDate = this.point.date;
              const sameXPoints = this.series.data.filter(point => {
                return point && point.date === currentDate && point.y !== null && point.y !== undefined;
              });

              const getExamClassText = (examClass) => {
                switch(examClass) {
                  case "1": return "(前)";
                  case "2": return "(後)";
                  case "0": return "(他)";
                  default: return "";
                }
              };

              if (sameXPoints.length === 1 || sameXPoints.length  === 0) {
                const examClassText = getExamClassText(this.point?.examClass);
                const valueWithClass = examClassText ? `${this.point.originalY ?? this.point.y}${examClassText}` : this.point.originalY ?? this.point.y;
                return `${headerEle}<br><span style='color:${this.color}'>●</span>${this.series.name}: <b>${valueWithClass}</b>`;
              } else {
                const valuesWithClass = sameXPoints.map((point, index) => {
                  const examClassText = getExamClassText(point.examClass);
                  const value = examClassText ? `${point.originalY ?? point.y}${examClassText}` : point.originalY ?? point.y;
                  return `<b style="margin-right: 4px;">${value}</b>`;
                });
                return `${headerEle}<br><span style='color:${this.color}'>●</span>${this.series.name}: ${valuesWithClass.join('')}`;
              }
            }
          },
          // xDateFormat: "%Y年%b月%e(%a)",
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
      type: Array,
      default() {
        return [];
      }
    },

    /**
     * @description y軸の目盛り
     *    例:
     *    ['mm', '°C],
     */
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
      // mod FNSI-グラフの縦軸表示を修正 周 start
      // if (!this.$refs[this.dispDataItem]) return;
      if (!this.$refs[this.dispDataItem] || !this.$refs[this.dispDataItem].chart) return;
      // mod FNSI-グラフの縦軸表示を修正 周 end
      const chart = this.$refs[this.dispDataItem].chart;
      const len = chart.yAxis.length;
      const tmpTick = [];
      // 縦軸ダミーデータ非表示「index: 0」
      for (let i = 1; i < len; i++) {
        tmpTick.push({
          tickArr: chart.yAxis[i].tickPositions
        });
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
      // カスタムtooltipをクリア
      if (chartRef.chart.customTooltipLabel) {
        chartRef.chart.customTooltipLabel.destroy();
        chartRef.chart.customTooltipLabel = null;
      }

      // カスタムtooltipフラグをリセット
      chartRef.chart.customTooltipVisible = false;

      if (typeof chartRef.chart.destroy === 'function') {
        chartRef.chart.destroy();
      }
      chartRef.chart = null;
    }

    this.chartOptions = null;
    this.shouldRenderChart = false;
    this.transformedLinePoints = [];
    // データの初期化
    Object.assign(this.$data, this.$options.data());
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

  created() {
    this.init();
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
      this.chartOptions.xAxis.categories = generateDates(this.xAxisMin, this.xAxisMax, this.displayPeriod !== "4");
      this.chartOptions.xAxis.tickPositions = this.caculateTickPositions();
      this.chartOptions.series = this.seriesData(this.xAxisMin, this.xAxisMax);

      // seriesデータ処理完了後、元のplotLinesを生成（時間軸表示用）
      const originalPlotLines = this.caculatePlotLines() || [];
      this.chartOptions.xAxis.plotLines = originalPlotLines;
      this.$nextTick(() => {
        const chart = this.$refs[this.dispDataItem]?.chart;
        if (!chart) {
          return;
        }
        this.syncPatViewerChartAxis(chart, {
          tickPositions: this.chartOptions.xAxis.tickPositions,
          plotLines: originalPlotLines
        });
      });
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
    getYAxisConfig(yAxisIndex) {
      const yAxisConfig = this.yAxis[yAxisIndex];

      if (yAxisConfig && yAxisConfig.tickPositioner) {
        const positions = yAxisConfig.tickPositioner();
        const originalMin = positions[0];
        const originalMax = positions[positions.length - 1];

        return {
          min: originalMin,
          max: originalMax
        };
      }
      return {
        min: yAxisConfig.min,
        max: yAxisConfig.max
      }
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
      const chartData = this.chartData.filter((item, index, self) => {
        if (item.type !== "xrange") return true;
        return !self.some((otherItem, otherIndex) =>
          otherItem.type === "xrange" && otherItem.name === item.name && otherIndex < index
        );
      });
      // 各ordMainレコードが1つのシリーズとして処理する
      chartData?.forEach(item => {
        // 各レコードの項目を処理していく
        const isLegendIdExists = legendIdArr.find(i => {
          return i === item.name;
        });
        if (!isLegendIdExists) {
          // IDが存在しない場合、そのIDを格納
          legendIdArr.push(item.name);
        }
        // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
        const dataMap = item.data.reduce((map, entry) => {
          const dateKey = dayjs(entry[0]).format("YYYYMMDD_HHmmss");
          if (!map[dateKey]) {
            map[dateKey] = [];
          }
          map[dateKey].push(entry);
          return map;
        }, {});
        let data = dateArr.flatMap((date, index) => {
          if (index === 0 && chartData.some(item => item.type === "xrange" || item.type === "custom")) {
            index = 0.5;
          }
          const entries = Object.entries(dataMap)
            .filter(([key]) => key.startsWith(date))
            .flatMap(([_, values]) => values);
          if (entries.length === 0) {
            return [{ x: index, y: null, date: date }];
          }
          return entries.map((entry) => ({
            x: index,
            y: Number(entry[1]),
            examClass: entry[2] || entry.examClass,
            date: date
          }));
        });
        const transformYValue = (value, yAxisIndex) => {
          if (!this.yAxis[yAxisIndex]) return value;

          const axisConfig = this.getYAxisConfig(yAxisIndex);
          const { min: originalMin, max: originalMax } = axisConfig;

          if (value > originalMax) {
            return originalMax;
          }

          if (value < originalMin) {
            return originalMin;
          }

          return value;
        };
        // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end
        switch(item.type) {
          case "column": {
            let pointRange = 1;
            let zIndex = 1;
            switch (item.dateType) {
              case 'day':
                zIndex = 5;
                break;
              case 'week':
                pointRange = 7;
                zIndex = 4;
                break;
              case 'twoWeek':
                pointRange = 14;
                zIndex = 3;
                break;
              case 'month':
                pointRange = 31;
                zIndex = 2;
                break;
              case 'threeMonth':
                pointRange = 93;
                zIndex = 1;
                break;
              default:
                break;
            }

            const transformedColumnData = data.map(point => {
              if (point.y === null || point.y === undefined) {
                return { ...point, originalY: point.y };
              }

              const axisConfig = this.getYAxisConfig(item.yAxis);
              const transformedY = transformYValue(point.y, item.yAxis);
              const isTransformed = point.y > axisConfig.max || point.y < axisConfig.min;

              return {
                ...point,
                y: transformedY,
                originalY: point.y,
                isTransformed: isTransformed
              };
            });

            seriesArr.push({
              type: "column",
              name: item.name,
              color: item.color,
              yAxis: item.yAxis,
              pointRange: pointRange,
              zIndex: zIndex,
              id: isLegendIdExists ? undefined : item.no,
              linkedTo: isLegendIdExists ? item.name : undefined,
              minPointLength: 3,
              threshold: null,
              tooltip: {
                pointFormat: "<span style='color:{point.color}'>●</span> {series.name}: <b>{point.originalY}</b><br/>"
              },
              turboThreshold: 999999,
              data: transformedColumnData
            });
          }
            break;

          case "line": {
            const transformedData = [];
            let outOfRangePoints = [];
            data.forEach(point => {
              if (point.y === null || point.y === undefined) {
                transformedData.push({ ...point, originalY: point.y });
                return;
              }

              const axisConfig = this.getYAxisConfig(item.yAxis);
              const isTransformed = point.y > axisConfig.max || point.y < axisConfig.min;



              if (isTransformed) {
                // 範囲外の点：折れ線で正常表示し、同時にscatter系列に追加
                let displayY = point.y;

                if (point.y > axisConfig.max) {
                  displayY = axisConfig.max;
                } else if (point.y < axisConfig.min) {
                  displayY = axisConfig.min;
                }

                // 矢印markerを表示するためにscatter系列に追加
                outOfRangePoints.push({
                  x: point.x,
                  y: displayY,
                  originalY: point.y,
                  date: point.date,
                  examClass: point.examClass,
                  seriesName: item.name,
                  seriesColor: item.color,
                  yAxis: item.yAxis,
                  // 矢印方向を判定するためのフラグ
                  isUpArrow: point.y > axisConfig.max
                });

                // 折れ線データで正常表示を保持（境界値へのマッピング値を使用）
                transformedData.push({
                  ...point,
                  y: point.y,
                  originalY: point.y,
                  isTransformed: true
                });
              } else {
                // 正常範囲内の点は折れ線内に保持
                transformedData.push({
                  ...point,
                  originalY: point.y,
                  isTransformed: false
                });
              }
            });
            seriesArr.push({
              type: "line",
              name: item.name,
              color: item.color,
              marker: item.marker ? item.marker : {},
              yAxis: item.yAxis,
              zIndex: 9,
              connectNulls: true, // null値を含め、折れ線の連続性を確保
              id: isLegendIdExists ? undefined : item.no,
              linkedTo: isLegendIdExists ? item.name : undefined,
              tooltip: {
                shared: true,
                headerFormat: "<span>{point.key}</span><br/>",
                pointFormatter: function() {
                  const point = this;
                  let valueText = point.originalY;
                  let suffixText = "";

                  // 検査区分のテキスト処理
                  if (point.examClass) {
                    const examClassText = point.examClass === "1" ? "(前)" :
                                        point.examClass === "2" ? "(後)" :
                                        point.examClass === "0" ? "(他)" : "";
                    if (examClassText) {
                      valueText = `${point.originalY}${examClassText}`;
                    }
                  }

                  // 範囲外の場合は追加のマーク
                  if (point.isTransformed) {
                    suffixText = " <span style='color:red;'>範囲外</span>";
                  }

                  return `<span style='color:${point.color}'>●</span> ${point.series.name}: <b>${valueText}</b>${suffixText}<br/>`;
                }
              },
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

                    if (scatterSeries && scatterSeries.visible) {
                      const newData = scatterSeries.data.map(point => ({
                        ...point.options,
                        marker: {
                          ...point.options.marker,
                          radius: 10
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
            });

            // 範囲外の点を独立したscatter系列として
            if (outOfRangePoints.length > 0) {

              outOfRangePoints = uniqBy(outOfRangePoints, item => `${item.date}-${item.examClass}-${item.x}-${item.seriesName}-${item.y}-${item.originalY}-${item.yAxis}`);
              seriesArr.push({
                type: "scatter",
                name: `${item.name}_範囲外`,
                color: item.color,
                yAxis: item.yAxis,
                zIndex: 10,
                showInLegend: false, // 凡例に表示しない
                linkedTo: item.name, // 主系列と関連付け
                enableMouseTracking: true,
                marker: {
                  symbol: 'circle',
                  radius: 0, // マーカーを非表示にしてUnicode文字のみ表示
                  fillColor: 'transparent',
                  lineColor: 'transparent',
                  lineWidth: 0
                },
                tooltip: {
                  pointFormatter: function() {
                    const point = this;
                    let valueText = point.originalY;

                    // 検査区分のテキスト処理
                    if (point.examClass) {
                      const examClassText = point.examClass === "1" ? "(前)" :
                                          point.examClass === "2" ? "(後)" :
                                          point.examClass === "0" ? "(他)" : "";
                      if (examClassText) {
                        valueText = `${point.originalY}${examClassText}`;
                      }
                    }

                    return `<span style='color:${point.seriesColor}'>●</span> ${point.seriesName}: <b>${valueText}</b> <span style='color:red;'>範囲外</span><br/>`;
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
                        s.name === lineName && s.type === 'line'
                      );

                      if (lineSeries && lineSeries.visible) {
                        lineSeries.setState('hover');
                      }
                    },
                    mouseOut: function() {
                      const chart = this.series.chart;
                      const lineName = this.series.name.replace('_範囲外', '');
                      const lineSeries = chart.series.find(s =>
                        s.name === lineName && s.type === 'line'
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
          }
            break;

          case "xrange": {
            const transformedXrangeData = mergeData(item.data).map(i => {
              const x = dateArr.findIndex((date) => date === i[0]);
              if (x === -1) return;
              const x2 = dateArr.findIndex((date) => date === i[1]) > -1 ? dateArr.findIndex((date) => date === i[1]) + 1.5 : dateArr.length + 2;
              const originalY = Number(i[2]);

              const axisConfig = this.getYAxisConfig(item.yAxis);
              const transformedY = transformYValue(originalY, item.yAxis);
              const isTransformed = originalY > axisConfig.max || originalY < axisConfig.min;

              return {
                x: x - 0.5,
                x2: x2 - 0.5,
                startDate: dayjs(i[0]).format('YYYY年M月D日(dd)'),
                endDate: dayjs(i[1]).format('YYYY年M月D日(dd)'),
                y: transformedY,
                originalY: originalY,
                isTransformed: isTransformed
              };
            }).filter(item => item !== undefined);

            seriesArr.push({
              type: "xrange",
              name: item.name,
              // 処方のグラフ（黄）
              // color: "#FFD900",
              color: item.color,
              yAxis: item.yAxis,
              grouping: false,
              zIndex: 8,
              id: isLegendIdExists ? undefined : item.no,
              linkedTo: isLegendIdExists ? item.name : undefined,
              pointWidth: 8,
              colorByPoint: false,
              turboThreshold: 999999,
              opacity: 0.8,
              data: transformedXrangeData,
              events: {
                legendItemClick: function(e) {
                  // 図例クリック時に矢印marker系列の表示/非表示を制御
                  const chart = this.chart;
                  const seriesName = this.name;
                  const willBeVisible = !this.visible;

                  setTimeout(() => {
                    // 範囲外マーカーシリーズを取得
                    const arrowSeries = chart.series.find(s => s.name === '範囲外標記');
                    if (arrowSeries) {
                      // line系列の表示状態を確認（クリックされたシリーズの将来の状態も考慮）
                      const hasVisibleLineSeries = chart.series.some(s => {
                        if (s.type === 'line' && s.name !== '範囲外標記') {
                          // 現在クリックされたシリーズの場合は反転後の状態を使用
                          if (s.name === seriesName) {
                            return willBeVisible;
                          }
                          return s.visible;
                        }
                        return false;
                      });

                      if (hasVisibleLineSeries) {
                        arrowSeries.show();
                      } else {
                        arrowSeries.hide();
                      }
                    }
                  }, 100);
                }
              }
            });
          }
            break;

          case "custom": {
            const transformedCustomData = item.data.map(i => {
              const x = dateArr.findIndex((date) => date === i[0]);
              const x2 = dateArr.findIndex((date) => date === i[1].format("YYYYMMDD")) + 1;
              const originalY = Number(i[2]);

              const axisConfig = this.getYAxisConfig(item.yAxis);
              const transformedY = transformYValue(originalY, item.yAxis);
              const isTransformed = originalY > axisConfig.max || originalY < axisConfig.min;

              return {
                x: x - 0.5,
                x2: x2 - 0.5,
                startDate: dayjs(i[0]).format('YYYY年M月D日(dd)'),
                endDate: dayjs(i[1]).format('YYYY年M月D日(dd)'),
                y: transformedY,
                originalY: originalY,
                isTransformed: isTransformed
              };
            });

            seriesArr.push({
              type: "xrange",
              name: item.name,
              color: item.color,
              yAxis: item.yAxis,
              zIndex: 8,
              id: isLegendIdExists ? undefined : item.no,
              linkedTo: isLegendIdExists ? item.name : undefined,
              pointWidth: 4,
              colorByPoint: false,
              turboThreshold: 999999,
              data: transformedCustomData,
              events: {
                legendItemClick: function(e) {
                  // 図例クリック時に矢印marker系列の表示/非表示を制御
                  const chart = this.chart;
                  const seriesName = this.name;
                  const willBeVisible = !this.visible;

                  setTimeout(() => {
                    // 範囲外マーカーシリーズを取得
                    const arrowSeries = chart.series.find(s => s.name === '範囲外標記');
                    if (arrowSeries) {
                      // line系列の表示状態を確認（クリックされたシリーズの将来の状態も考慮）
                      const hasVisibleLineSeries = chart.series.some(s => {
                        if (s.type === 'line' && s.name !== '範囲外標記') {
                          // 現在クリックされたシリーズの場合は反転後の状態を使用
                          if (s.name === seriesName) {
                            return willBeVisible;
                          }
                          return s.visible;
                        }
                        return false;
                      });

                      if (hasVisibleLineSeries) {
                        arrowSeries.show();
                      } else {
                        arrowSeries.hide();
                      }
                    }
                  }, 100);
                }
              }
            });
          }
            break;
        }

      });
      this.chartOptions.legend.enabled = false;
      return seriesArr[0] === undefined ? [{ data: dateArr.fill(null) }] : seriesArr;
    },
  }
};
</script>
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
