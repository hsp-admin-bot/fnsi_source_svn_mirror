/** * 装置プログラムーチャート */

<template>
  <highcharts :options="chartOptions" ref="refDcProgramChart" />
</template>

<script>
import { mapGetters } from "vuex";
import { Chart } from "highcharts-vue";

export default {
  components: {
    highcharts: Chart
  },
  props: {
    /**
     * @description チャートの高さ
     */
    height: {
      type: Number,
      default: null
    },

    /**
     * @description チャートの広さ
     */
    width: {
      type: Number,
      default: null
    },

    /**
     * @description チャートデータ
     */
    data: {
      type: Object,
      default() {
        return {
          mode: 0,
          courseValue: 0,
          courseStartValue: 0,
          courseEndValue: 0,
          courseMinValue: 0,
          courseMaxValue: 0,
          stepMinValue: 0,
          stepMaxValue: 0,
          stepValues: []
        };
      }
    },

    /**
     * @description 軸ラベル表示設定
     */
    showTickLabel: {
      type: Boolean,
      default: true
    }
  },

  computed: {
    ...mapGetters("account-edit", {
      fontSize: "getFontSize",
    }),

    chartOptions() {
      let yAxisData = [],
        seriesData = [];
      const tempArr = [];

      switch (this.data.mode) {
        case "ufr-step":
        case "na-step":
          yAxisData = [
            {
              min: this.data.stepMinValue || 0,
              max: this.data.stepMaxValue || 50,
              tickAmount: 6,
              title: {
                enabled: false
              },
              labels: {
                enabled: this.showTickLabel
              },
              opposite: false
            },
            {
              min: this.data.courseMinValue || 0,
              max: this.data.courseMaxValue || 200,
              tickAmount: 6,
              title: {
                enabled: false
              },
              labels: {
                enabled: this.showTickLabel
              },
              opposite: true
            }
          ];

          seriesData = [
            {
              type: "column",
              data: this.data.stepValues,
              yAxis: 0
            },
            {
              yAxis: 1 // 第二Y軸を強制的表示するために
            }
          ];

          break;

        case "b-fluid-conc-step":
          yAxisData = [
            // del FNSI-濃度プログラムの修正 楊 start
            // {
            //   tickPositions: [0, 6, 12, 18, 24, 30],
            //   title: {
            //     enabled: false
            //   },
            //   labels: {
            //     enabled: this.showTickLabel
            //   },
            //   opposite: false
            // },
            // del FNSI-濃度プログラムの修正 楊 end
            {
              tickPositions: [1.5, 2.6, 3.7, 4.8, 5.9, 7.0],
              title: {
                enabled: false
              },
              labels: {
                // mod FNSI-濃度プログラムの修正 楊 start
                // enabled: this.showTickLabel
                enabled: this.showTickLabel,
                formatter: function() {
                  var strVal = this.value + '';
                  if (strVal.indexOf('.') === -1) {
                    return strVal + '.00';
                  } else {
                    var arr = strVal.split('.');
                    if (arr[1].length === 2) {
                      return strVal;
                    } else {
                      return strVal + '0';
                    }
                  }
                },
                y:5
                // mod FNSI-濃度プログラムの修正 楊 end
              },
              // mod FNSI-濃度プログラムの修正 楊 start
              // opposite: true
              opposite: false
              // mod FNSI-濃度プログラムの修正 楊 end
            }
          ];

          seriesData = [
            // del FNSI-濃度プログラムの修正 楊 start
            // {
            //   type: "column",
            //   data: this.data.stepValues[0],
            //   stack: "upper",
            //   yAxis: 0
            // },
            // del FNSI-濃度プログラムの修正 楊 end
            {
              type: "column",
              data: this.data.stepValues[1],
              stack: "lower",
              // mod FNSI-濃度プログラムの修正 楊 start
              // yAxis: 1
              yAxis: 0
              // mod FNSI-濃度プログラムの修正 楊 end
            }
          ];
          break;

        case "dialysate-conc-step":
          yAxisData = [
            // del FNSI-濃度プログラムの修正 楊 start
            // {
            //   tickPositions: [0, 6, 12, 18, 24, 30],
            //   title: {
            //     enabled: false
            //   },
            //   labels: {
            //     enabled: this.showTickLabel
            //   },
            //   opposite: false
            // },
            // del FNSI-濃度プログラムの修正 楊 end
            {
              tickPositions: [12.5, 13.1, 13.7, 14.3, 14.9, 15.5],
              title: {
                enabled: false
              },
              labels: {
                enabled: this.showTickLabel,
                y:5,
                
              },
              // mod FNSI-濃度プログラムの修正 楊 start
              // opposite: true
              opposite: false
              // mod FNSI-濃度プログラムの修正 楊 end
            }
          ];

          seriesData = [
            // del FNSI-濃度プログラムの修正 楊 start
            // {
            //   type: "column",
            //   data: this.data.stepValues[0],
            //   stack: "upper",
            //   yAxis: 0
            // },
            // del FNSI-濃度プログラムの修正 楊 end
            {
              type: "column",
              data: this.data.stepValues[1],
              stack: "lower",
              // mod FNSI-濃度プログラムの修正 楊 start
              // yAxis: 1
              yAxis: 0
              // mod FNSI-濃度プログラムの修正 楊 end
            }
          ];
          break;

        case "ufr-course":
        case "na-course":
          for (let i = 1; i < 11; i++) {
            const CourseUFR = parseFloat(this.data.courseValue);
            const CourseStartUFR = parseFloat(this.data.courseStartValue);
            const CourseEndUFR = parseFloat(this.data.courseEndValue);

            const Ts = (480 / 10) * (i - 1);
            const X = -0.5 * (CourseUFR - 1) * (CourseUFR - 4) * (1 - Ts / 480);
            const Exp = Math.exp(X);

            const In =
              ((CourseEndUFR - CourseStartUFR) / 480) * Ts * Exp +
              parseFloat(CourseStartUFR);

            tempArr.push(parseFloat(In));

            if (i === 10) {
              tempArr.push(CourseEndUFR);
            }
          }

          yAxisData = [
            {
              min: this.data.courseMinValue || 0,
              max: this.data.courseMaxValue || 200,
              tickAmount: 6,
              title: {
                enabled: false
              },
              labels: {
                enabled: this.showTickLabel
              },
              opposite: true
            }
          ];

          seriesData = [
            {
              type: "spline",
              data: tempArr,
              yAxis: 0
            }
          ];
          break;

        case "b-fluid-conc-course":
          for (let i = 1; i < 11; i++) {
            const CourseUFR = parseFloat(this.data.courseValue);
            const CourseStartUFR = parseFloat(this.data.courseStartValue);
            const CourseEndUFR = parseFloat(this.data.courseEndValue);

            const Ts = (480 / 10) * (i - 1);
            const X = -0.5 * (CourseUFR - 1) * (CourseUFR - 4) * (1 - Ts / 480);
            const Exp = Math.exp(X);

            const In =
              ((CourseEndUFR - CourseStartUFR) / 480) * Ts * Exp +
              parseFloat(CourseStartUFR);

            tempArr.push(parseFloat(In));

            if (i === 10) {
              tempArr.push(CourseEndUFR);
            }
          }

          yAxisData = [
            {
              tickPositions: [1.5, 2.6, 3.7, 4.8, 5.9, 7.0],
              title: {
                enabled: false
              },
              labels: {
                enabled: this.showTickLabel
              },
              // add FNSI-濃度プログラムの修正 楊 start
              // opposite: true
              opposite: false
              // add FNSI-濃度プログラムの修正 楊 end
            }
          ];

          seriesData = [
            {
              type: "spline",
              data: tempArr,
              yAxis: 0
            }
          ];
          break;

        case "dialysate-conc-course":
          for (let i = 1; i < 11; i++) {
            const CourseUFR = parseFloat(this.data.courseValue);
            const CourseStartUFR = parseFloat(this.data.courseStartValue);
            const CourseEndUFR = parseFloat(this.data.courseEndValue);

            const Ts = (480 / 10) * (i - 1);
            const X = -0.5 * (CourseUFR - 1) * (CourseUFR - 4) * (1 - Ts / 480);
            const Exp = Math.exp(X);

            const In =
              ((CourseEndUFR - CourseStartUFR) / 480) * Ts * Exp +
              parseFloat(CourseStartUFR);

            tempArr.push(parseFloat(In));

            if (i === 10) {
              tempArr.push(CourseEndUFR);
            }
          }

          yAxisData = [
            {
              tickPositions: [12.5, 13.1, 13.7, 14.3, 14.9, 15.5],
              title: {
                enabled: false
              },
              labels: {
                enabled: this.showTickLabel
              },
              // add FNSI-濃度プログラムの修正 楊 start
              // opposite: true
              opposite: false
              // add FNSI-濃度プログラムの修正 楊 end
            }
          ];

          seriesData = [
            {
              type: "spline",
              data: tempArr,
              yAxis: 0
            }
          ];
          break;

        default:
          break;
      }

      return {
        chart: {
          height: this.height,
          backgroundColor: "#FFF",
          borderWidth: 1,
          borderColor: "#999",
          events: {
            load() {
              // 初期ロード時にスクロールバー有無によってチャートがちゃんと描画されてないことがあるため
              // 描画された直後、1秒待機をして強制的リサイズをする
              // setTimeout(() => {
                this.reflow();
//              }, 1000);
            }
          },
          marginTop: 25,
          marginBottom: 10
        },
        credits: {
          enabled: false
        },
        legend: {
          enabled: false
        },
        plotOptions: {
          series: {
            marker: {
              enabled: false,
              states: {
                hover: {
                  enabled: false
                }
              }
            }
          },
          column: {
            animation: false
          }
        },
        xAxis: [
          {
            tickInterval: 0,
            tickWidth: 0,
            visible: false
          }
        ],
        exporting: [
          {
             enabled:false
          }
        ],
        yAxis: yAxisData,
        title: {
          text: ""
        },
        series: seriesData,
        tooltip: {
          enabled: false
        }
      };
    }
  },

  watch: {
    fontSize() {
      // グラフのリサイズ
      this.$refs.refDcProgramChart.chart.reflow();
    }
  },
  beforeDestroy() {
    const chartRef = this.$refs.refDcProgramChart;
    if (chartRef?.chart) {
      if (typeof chartRef.chart.destroy === 'function') {
        chartRef.chart.destroy();
      }
      chartRef.chart = null;
    }
  }
};
</script>
