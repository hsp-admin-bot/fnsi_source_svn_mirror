/** * 装置プログラムーチャート */

<template>
  <div class="" ref="device-program-chart-container">
    <highcharts v-if="shouldRenderChart" ref="highchart" :options="chartOptions" />
  </div>
</template>

<script>
import {
  valueInfoDc,
  valueInfoNa,
  valueInfoUfr,
  valueInfoQbqd
} from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions";
import { Chart } from "highcharts-vue";
import elementResizeDetectorMaker from "element-resize-detector";
const erd = elementResizeDetectorMaker({
  strategy: "scroll"
});

export default {
  data() {
    return {
      shouldRenderChart: false,
      observer: null
    }
  },
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
          stepValues: [],
          title: ""
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
    chartOptions() {
      let yAxisData = [],
        seriesData = [],
        tempArr = [];

      const xAxisData = {
        visible: false
      };

      // ステップ・コースそれぞれの共通設定
      switch (this.data.mode) {
        case "ufr-step":
        case "na-step":
        case "b-fluid-conc-step":
        case "dialysate-conc-step":
        case "qbqd-step":
        case "ihdf-step":
          yAxisData = [
            {
              title: {
                enabled: false
              },
              labels: {
                enabled: this.showTickLabel
              },
              opposite: false
            },
            {
              title: {
                enabled: false
              },
              labels: {
                enabled: this.showTickLabel
              },
              opposite: true
            }
          ];

          break;

        case "ufr-course":
        case "na-course":
        case "b-fluid-conc-course":
        case "dialysate-conc-course":
          tempArr = this.computeCourseValues(
            this.data.courseValue,
            this.data.courseStartValue,
            this.data.courseEndValue
          );

          yAxisData = [
            {
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
        default:
          break;
      }

      // 各モードの独自設定
      switch (this.data.mode) {
        case "ufr-step":
          // mod 9802 除水プログラムのグラフが登録内容とことなる。zhou start
          // yAxisData[0].tickPositions = this.computeTickPositions(
          //   6,
          //   valueInfoUfr.dev.B[0].minValue,
          //   valueInfoUfr.dev.B[0].maxValue
          // );
          yAxisData[0].tickPositions = this.computeTickPositions(
            6,
            valueInfoUfr.dev.A[301].minValue,
            valueInfoUfr.dev.A[301].maxValue
          );
          // mod 9802 除水プログラムのグラフが登録内容とことなる。zhou end
          yAxisData[1].tickPositions = this.computeTickPositions(
            6,
            valueInfoUfr.dev.A[301].minValue,
            valueInfoUfr.dev.A[301].maxValue
          );

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

        case "na-step":
          yAxisData[0].tickPositions = this.computeTickPositions(
            6,
            valueInfoNa.dev.A[316].minValue,
            valueInfoNa.dev.A[316].maxValue
          );

          seriesData = [
            {
              type: "column",
              data: this.data.stepValues,
              yAxis: 0
            }
          ];
          break;

        case "b-fluid-conc-step":
          // mod FNSI-濃度プログラムの修正 楊 start
          // yAxisData[0].tickPositions = this.computeTickPositions(
          //   6,
          //   valueInfoDc.dev.B[10].minValue,
          //   valueInfoDc.dev.B[10].maxValue
          // );
          // yAxisData[1].tickPositions = this.computeTickPositions(
            yAxisData[0].tickPositions = this.computeTickPositions(
              // mod FNSI-濃度プログラムの修正 楊 end
            6,
            valueInfoDc.dev.A[351].minValue,
            valueInfoDc.dev.A[351].maxValue
          );

          seriesData = [
            // mod FNSI-濃度プログラムの修正 楊 start
            // {
            //   type: "column",
            //   data: this.data.stepValues[0],
            //   stack: "upper",
            //   yAxis: 0
            // },
            // mod FNSI-濃度プログラムの修正 楊 end
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
          // mod FNSI-濃度プログラムの修正 楊 start
          // yAxisData[0].tickPositions = this.computeTickPositions(
          //   6,
          //   valueInfoDc.dev.B[20].minValue,
          //   valueInfoDc.dev.B[20].maxValue
          // );
          // yAxisData[1].tickPositions = this.computeTickPositions(
          yAxisData[0].tickPositions = this.computeTickPositions(
            // mod FNSI-濃度プログラムの修正 楊 end
            6,
            valueInfoDc.dev.A[341].minValue,
            valueInfoDc.dev.A[341].maxValue
          );

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

        case "qbqd-step":
          yAxisData[0].tickPositions = this.computeTickPositions(
            7,
            0,
            valueInfoQbqd.dev.A[410].maxValue
          );

          xAxisData.max = this.data.xAxisMax;

          seriesData = [
            {
              type: "line",
              data: this.data.stepValues[0],
              color: "blue"
            },
            {
              type: "line",
              data: this.data.stepValues[1],
              color: "red"
            }
          ];
          break;

        case "ihdf-step":
          yAxisData[0].tickPositions = this.computeTickPositions(11, -500, 500);

          seriesData = [
            {
              type: "column",
              data: this.data.stepValues[0],
              yAxis: 0
            },
            {
              type: "column",
              data: this.data.stepValues[1],
              yAxis: 0
            }
          ];
          break;

        case "ufr-course":
          yAxisData[0].tickPositions = this.computeTickPositions(
            6,
            valueInfoUfr.dev.A[313].minValue,
            valueInfoUfr.dev.A[313].maxValue
          );
          break;

        case "na-course":
          yAxisData[0].tickPositions = this.computeTickPositions(
            6,
            valueInfoNa.dev.A[329].minValue,
            valueInfoNa.dev.A[329].maxValue
          );
          break;

        case "b-fluid-conc-course":
          yAxisData[0].tickPositions = this.computeTickPositions(
            6,
            valueInfoDc.dev.A[365].minValue,
            valueInfoDc.dev.A[365].maxValue
          );
          break;

        case "dialysate-conc-course":
          yAxisData[0].tickPositions = this.computeTickPositions(
            6,
            valueInfoDc.dev.A[362].minValue,
            valueInfoDc.dev.A[362].maxValue
          );
          break;
        default:
          break;
      }

      return {
        chart: {
          height: this.height,
          width: this.width,
          backgroundColor: "#FFF",
          borderWidth: 1,
          borderColor: "#999"
        },
        credits: {
          enabled: false
        },
        legend: {
          enabled: false
        },
        // add FNSI-4401 そのメニュー自体消してよい liumx start
        navigation: {
          buttonOptions: {
            enabled: false
          }
        },
        // add FNSI-4401 そのメニュー自体消してよい」 liumx end
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
          }
        },
        xAxis: xAxisData,
        yAxis: yAxisData,
        title: {
          text: this.data.title,
          floating: true,
          align: "left"
        },
        series: seriesData,
        tooltip: {
          enabled: false
        }
      };
    }
  },

  mounted() {
    // 親コンポネントリサイズ時にグラフのサイズを合わせて
    erd.listenTo(this.$parent.$el, () => {
      // mod bug 8003 修正 chen start
      if (this.$refs.highchart) {
        this.$refs.highchart?.chart?.reflow();
      }
      // mod bug 8003 修正 chen end
    });
    this.observer = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.shouldRenderChart = true;
          observer.unobserve(entry.target);
        }
      });
    });
    this.observer.observe(this.$refs["device-program-chart-container"]);
  },

  methods: {
    /**
     * @description 除水プロ(コース)の計算
     * @param {Number} amount コース値
     * @param {Number} startVal 開始指数
     * @param {Number} endVal 終了指数
     * @returns {Array}
     */
    computeCourseValues(amount, startVal, endVal) {
      const resArr = [];

      for (let i = 1; i < 11; i++) {
        const CourseUFR = parseFloat(amount);
        const CourseStartUFR = parseFloat(startVal);
        const CourseEndUFR = parseFloat(endVal);

        const Ts = (480 / 10) * (i - 1);
        const X = -0.5 * (CourseUFR - 1) * (CourseUFR - 4) * (1 - Ts / 480);
        const Exp = Math.exp(X);

        const In =
          ((CourseEndUFR - CourseStartUFR) / 480) * Ts * Exp +
          parseFloat(CourseStartUFR);

        resArr.push(parseFloat(In));

        if (i === 10) {
          resArr.push(CourseEndUFR);
        }
      }

      return resArr;
    },

    /**
     * @description 目盛の値を計算
     * @param {Number} tickAmount 目盛数
     * @param {Number} min 下限
     * @param {Number} max 上限
     * @returns {Array}
     */
    computeTickPositions(tickAmount, min, max) {
      const resArr = [];
      const tickInterval = (max - min) / (tickAmount - 1);

      resArr.push(min);
      while (min < max) {
        min += tickInterval;
        min = parseFloat(min.toFixed(1)); //toFixedは浮動小数点の対策
        resArr.push(min);
      }

      return resArr;
    }
  },
  beforeDestroy() {
    if (this.$parent?.$el) {
      erd.uninstall(this.$parent.$el);
    }

    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }

    const chartRef = this.$refs.highchart;
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
