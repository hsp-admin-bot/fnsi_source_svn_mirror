/**
* グラフ表示コンポーネント
*/
<template>
  <!-- mod FNSI-改修内容 monitorグラフ修正 房 start -->
  <!--
  <div>
    <highcharts :options="chartOptions"></highcharts>
  </div>
  -->
  <div class="highcharts-config">
    <highcharts ref="vitalChart" :options="chartOptions" class="vitalGraphView"></highcharts>
  </div>
  <!-- mod FNSI-改修内容 monitorグラフ修正 房 start -->
</template>

<script>
import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
  import dayjs from "@/compat/date/dayjs";
  import {mapGetters} from "@/compat/vue/vuex";
  import Highcharts from "@/compat/charts/highcharts";
  import { Boost } from "@/compat/charts/highcharts";
  import {CODES} from "@/constants/TreatmentRecord";
  Boost(Highcharts);
  // Highcharts v9 相当: X軸の基準線と目盛り線を同色にする（v12 既定値では色がずれる）
  const X_AXIS_STROKE_COLOR = "#ccd6eb";
  // グラフデータのテンプレート
  const CHART_OPTIONS_TEMPLATE = {
    chart: {
      marginRight: 50,
      marginLeft: 45,
      reflow: true
    },
    //mod redmine4094修正 房 start
    exporting: {
      enabled: false,
    },
    //mod redmine4094修正 房 end
    time: {
      useUTC: false
    },
    credits: {
      enabled: false
    },
    title: false,
    xAxis: {
      type: "datetime",
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
      min: null,
      max: null,
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
      // Highcharts v12: 中間の目盛り・縦グリッドを表示（v9 相当）
      gridLineWidth: 1,
      gridLineColor: "#e6e6e6",
      lineColor: X_AXIS_STROKE_COLOR,
      lineWidth: 1,
      tickColor: X_AXIS_STROKE_COLOR,
      tickWidth: 1,
      tickLength: 5,
      tickPixelInterval: 0,
      labels: {
        step: 1,
        allowOverlap: true,
        formatter: function () {
          //alert("3startBef"+this.axis.startBef)
          //alert("3min"+this.axis.min)
          const currentDate = dayjs(this.value);
          if (this.axis.options.occurStartDate) {
            // 時系列での表示
            //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
            let startDate = dayjs(this.axis.options.occurStartDate);
            //const startDate = dayjs(this.axis.options.occurStartDate+30*60*1000);
            //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
            if (!currentDate.isBefore(startDate)) {
              //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
              // if (this.value == this.axis.max - 30 * 60 * 1000) {
              //   return "";
              // }
              //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
              return currentDate
                .subtract(startDate.hour(), "hours")
                .subtract(startDate.minute(), "minutes")
                .subtract(startDate.second(), "seconds")
                .format("H:mm");
            } else {
              startDate = dayjs(this.axis.options.occurStartDate);
              // let c= new Date();
              // dayjs(c.getTime());
              // let d=c.getTime()-15*60*1000*5;
              // dayjs(d);
              // dayjs(c.getTime())
              // .subtract(dayjs(d).hour(), "hours")
              // .subtract(dayjs(d).minute(), "minutes")
              // .subtract(dayjs(d).second(), "seconds").format("H:mm")

              let fz = 2360 - currentDate
                .subtract(startDate.hour(), "hours")
                .subtract(startDate.minute(), "minutes")
                .subtract(startDate.second(), "seconds")
                .format("Hmm") + "";
              if (fz.length == 2 && ((fz.substr(-2, 2) / 60) % 1) !== 0) {
                return "-0:" + fz;
              } else if (fz.length == 3 && ((fz.substr(-2, 2) / 60) % 1) !== 0) {
                //return soure.slice(0, 1) + ":" + fz.slice(1)
                return "-" + fz.slice(0, 1) + ":" + fz.slice(1)
              } else if (((fz.substr(-2, 2) / 60) % 1) === 0) {
                //return "-" + (fz.substr(-2, 2)/ 60+1) + ":00";
                if (fz.length == 2) {
                  return "-" + fz / 60 + ":00";
                }
                return "-" + (fz.substr(0, 1) / 1 + 1) + ":00";
              }
              return currentDate.format("H:mm");
            }
          } else {
            //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
            // if (this.value == this.axis.max - 30 * 60 * 1000) {
            //   return "";
            // }
            //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
            return currentDate.format("H:mm");
          }
        }
      }
    },
    yAxis: [
      {
        // 左y軸(「血圧」「脈拍」「血糖値」用)
        title: false,
        min: 40,
        max: 280,
        alignTicks: false,
        tickInterval: 20,
        labels: {
          align: "left",
          x: -28,
          style: {
            textOverflow: "none"
          }
        },
        showLastLabel: false
      },
      {
        // 右y軸(「体温」用)
        title: false,
        min: 34.5,
        max: 40.5,
        alignTicks: false,
        tickInterval: 0.5,
        opposite: true, // 右側のy軸とする
        allowDecimals: true,
        labels: {
          align: "right",
          x: 45,
          style: {
            width: "50px"
          },
          format: "{value:.1f} ℃"
        },
        showLastLabel: false
      }
    ],
    legend: {
      // グラフの凡例
      layout: "horizontal", // 横方向に並べる
      align: "left", // グラフの左に表示（左右中央）
      verticalAlign: "top", // グラフの上に表示（上下中央）
      floating: false, // 凡例をプロット外部に表示
      x: 20,
      y: -5
    },
    // FNSI-グラフの操作モーダルを削除 周 add start
    navigation: {
      buttonOptions: {
        enabled: false
      }
    },
    // FNSI-グラフの操作モーダルを削除 周 add end
    plotOptions: {
      // 点の設定
      series: {
        marker: {
          enabled: true // データプロット(●、▲、■)を表示
        }
      }
    },
    scrollbar: {
      enabled: true
    },
    //mod FNSI-改修内容 グラフ様式修正 房 start
    series: [],
    //add FNSI-7978(治療記録側) ljx start
    tooltip: {
      formatter: function () {

        var s = Highcharts.dateFormat('%Y-%b-%e(%a) %H:%M', this.x);
        if (this.series.name == "体温") {
          s += '<br />' + this.series.name + '：' + '<b>' + Highcharts.numberFormat(this.point.y, 1) + '</b>';
        } else {
          s += '<br />' + this.series.name + '：' + '<b>' + this.point.y + '</b>';
        }
        return s
      },
      hideDelay: 100,
      snap: 0
    }
    //add FNSI-7978(治療記録側) ljx end
    // series: [
    //   {
    //     type: "line",
    //     name: "最高血圧",
    //     color: "#99FFFF",
    //     data: [],
    //     yAxis: 0
    //   },
    //   {
    //     type: "line",
    //     name: "最低血圧",
    //     color: "#FF9933",
    //     data: [],
    //     yAxis: 0
    //   },
    //   {
    //     type: "line",
    //     name: "平均血圧",
    //     color: "#FF3333",
    //     data: [],
    //     yAxis: 0
    //   },
    //   {
    //     type: "line",
    //     name: "脈拍",
    //     color: "#99FF33",
    //     data: [],
    //     yAxis: 0
    //   },
    //   {
    //     type: "line",
    //     name: "体温",
    //     color: "#0000A0",
    //     data: [],
    //     yAxis: 1
    //   },
    //   {
    //     type: "scatter",
    //     name: "血糖値",
    //     color: "#6666FF",
    //     data: [],
    //     yAxis: 0,
    //     marker: {
    //       enabled: true
    //     },
    //     enableMouseTracking: false,
    //     dataLabels: [
    //       {
    //         enabled: true,
    //         align: "left",
    //         verticalAlign: "middle",
    //         format: "{point.bloodSugarLevel} mg/dl",
    //         style: {
    //           fontWeight: "none"
    //         }
    //       }
    //     ]
    //   }
    // ]
    //mod FNSI-改修内容 グラフ様式修正 房 end
  };

  /**
   * グラフ種別
   */
  const CHART_KIND = {
    BP_MAX: 0,
    BP_MIN: 1,
    BP_AVE: 2,
    PULSE: 3,
    TEMPERATURE: 4,
    BLOOD_SUGAR_LEVEL: 5
  };

  export default {
    props: {
      value: {
        type: Array,
        default: () => []
      },
      startDate: {
        type: Date
      },
      endDate: {
        type: Date
      },
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
      graphTime: {
        type: Number
      },
      rstDialysisState: {
        type: String
      },
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
      chartScale: {
        type: String,
        default: CODES.CHART_SCALE.TIME.cd
      },
      //add FNSI-改修内容 グラフ様式修正 房 start
      graphDefine: {
        type: Array,
        default: () => []
      }
      //add FNSI-改修内容 グラフ様式修正 房 end
    },
    data() {
      return {
        vitalData: [],
        chartOptions: CHART_OPTIONS_TEMPLATE,
        startBef: null,
        endAft: null
      };
    },
    computed: {
      ...mapGetters("window-size", {
        windowHeight: "getWindowHeight",
        windowWidth: "getSplittedWidth"
      }),
      /**
       * 時系列の表示かどうか.
       */
      isTimeSeries() {
        return this.chartScale === CODES.CHART_SCALE.TIME_SERIES.cd;
      }
    },
    methods: {
      /**
       * 透析開始/終了の縦線（Highcharts v12 は軸範囲外で非表示になるため force が必要）
       */
      applyDialysisPlotLines() {
        const baseLine = {
          color: 'green',
          width: 2,
          zIndex: 99,
          force: true
        };
        const plotLines = [];
        if (this.startDate != null) {
          plotLines.push({
            ...baseLine,
            id: 'dialysis-start',
            value: this.startDate.getTime()
          });
        }
        if (this.endDate != null) {
          plotLines.push({
            ...baseLine,
            id: 'dialysis-end',
            value: this.endDate.getTime()
          });
        }
        this.chartOptions.xAxis.plotLines = plotLines;
      },
      /**
       * X軸の目盛り・縦グリッド・緑線を Highcharts v12 で確実に反映する
       */
      syncChartAxis(xShowArrs) {
        this.$nextTick(() => {
          const chart = this.$refs.vitalChart?.chart;
          const xAxis = chart?.xAxis?.[0];
          if (!xAxis || !xShowArrs?.length) {
            return;
          }
          xAxis.update({
            tickPositions: xShowArrs,
            min: xShowArrs[0],
            max: xShowArrs[xShowArrs.length - 1],
            tickPixelInterval: 0,
            gridLineWidth: 1,
            gridLineColor: "#e6e6e6",
            lineColor: X_AXIS_STROKE_COLOR,
            lineWidth: 1,
            tickColor: X_AXIS_STROKE_COLOR,
            tickWidth: 1
          }, false);
          xAxis.removePlotLine('dialysis-start');
          xAxis.removePlotLine('dialysis-end');
          (this.chartOptions.xAxis.plotLines || []).forEach((plotLine) => {
            xAxis.addPlotLine(plotLine, false);
          });
          chart.redraw(false);
        });
      },
      /**
       * グラフ用データ生成
       */
      createChartData() {
        //add FNSI-改修内容 グラフ様式修正 房 start
        const series = [];

        this.chartOptions.series = [];
        let graph1 = undefined;
        // MOD 6499 治療記録バイタルマスタの並び順を変更したが治療記録のバイタルグラフに反映されない 周安寧 START
        // let graph1Define = this.graphDefine.filter(el => el.vitalGraphName == "最高血圧")[0];
        // if (graph1Define != undefined) {
        //   graph1 = {
        //     type: "line",
        //     name: "最高血圧",
        //     color: graph1Define.vitalLineColor,
        //     dashStyle: graph1Define.vitalLineTypeValue,
        //     lineWidth: Number(graph1Define.vitalLineSize),
        //     data: [],
        //     yAxis: 0,
        //     marker: {
        //       symbol: graph1Define.vitalPointTypeValue,
        //       radius: Number(graph1Define.vitalPointSize),
        //       fillColor: graph1Define.vitalPointColor
        //     }
        //   }
        //   series.push(graph1);
        // }
        // let graph2 = undefined;
        // let graph2Define = this.graphDefine.filter(el => el.vitalGraphName == "最低血圧")[0];
        // if (graph2Define != undefined) {
        //   graph2 = {
        //     type: "line",
        //     name: "最低血圧",
        //     color: graph2Define.vitalLineColor,
        //     dashStyle: graph2Define.vitalLineTypeValue,
        //     lineWidth: Number(graph2Define.vitalLineSize),
        //     data: [],
        //     yAxis: 0,
        //     marker: {
        //       symbol: graph2Define.vitalPointTypeValue,
        //       radius: Number(graph2Define.vitalPointSize),
        //       fillColor: graph2Define.vitalPointColor
        //     }
        //   }
        //   series.push(graph2);
        // }
        // let graph3 = undefined;
        // let graph3Define = this.graphDefine.filter(el => el.vitalGraphName == "平均血圧")[0];
        // if (graph3Define != undefined) {
        //   graph3 = {
        //     type: "line",
        //     name: "平均血圧",
        //     color: graph3Define.vitalLineColor,
        //     dashStyle: graph3Define.vitalLineTypeValue,
        //     lineWidth: Number(graph3Define.vitalLineSize),
        //     data: [],
        //     yAxis: 0,
        //     marker: {
        //       symbol: graph3Define.vitalPointTypeValue,
        //       radius: Number(graph3Define.vitalPointSize),
        //       fillColor: graph3Define.vitalPointColor
        //     }
        //   }
        //   series.push(graph3);
        // }
        // let graph4 = undefined;
        // let graph4Define = this.graphDefine.filter(el => el.vitalGraphName == "脈拍")[0];
        // if (graph4Define != undefined) {
        //   graph4 = {
        //     type: "line",
        //     name: "脈拍",
        //     color: this.graphDefine.filter(el => el.vitalGraphName == "脈拍")[0].vitalLineColor,
        //     dashStyle: this.graphDefine.filter(el => el.vitalGraphName == "脈拍")[0].vitalLineTypeValue,
        //     lineWidth: Number(this.graphDefine.filter(el => el.vitalGraphName == "脈拍")[0].vitalLineSize),
        //     data: [],
        //     yAxis: 0,
        //     marker: {
        //       symbol: this.graphDefine.filter(el => el.vitalGraphName == "脈拍")[0].vitalPointTypeValue,
        //       radius: Number(this.graphDefine.filter(el => el.vitalGraphName == "脈拍")[0].vitalPointSize),
        //       fillColor: this.graphDefine.filter(el => el.vitalGraphName == "脈拍")[0].vitalPointColor
        //     }
        //   }
        //   series.push(graph4);
        // }
        // let graph5 = undefined;
        // let graph5Define = this.graphDefine.filter(el => el.vitalGraphName == "体温")[0];
        // if (graph5Define != undefined) {
        //   graph5 = {
        //     type: "line",
        //     name: "体温",
        //     color: graph5Define.vitalLineColor,
        //     dashStyle: graph5Define.vitalLineTypeValue,
        //     lineWidth: Number(graph5Define.vitalLineSize),
        //     data: [],
        //     yAxis: 1,
        //     marker: {
        //       symbol: graph5Define.vitalPointTypeValue,
        //       radius: Number(graph5Define.vitalPointSize),
        //       fillColor: graph5Define.vitalPointColor
        //     }
        //   }
        //   series.push(graph5);
        // }
        // let graph6 = undefined;
        // let graph6Define = this.graphDefine.filter(el => el.vitalGraphName == "血糖値")[0];
        // if (graph6Define != undefined) {
        //   graph6 = {
        //     type: "scatter",
        //     name: "血糖値",
        //     color: graph6Define.vitalLineColor,
        //     dashStyle: graph6Define.vitalLineTypeValue,
        //     lineWidth: Number(graph6Define.vitalLineSize),
        //     data: [],
        //     yAxis: 0,
        //     marker: {
        //       //
        //       enabled: true,
        //       symbol: graph6Define.vitalPointTypeValue,
        //       radius: Number(graph6Define.vitalPointSize),
        //       fillColor: graph6Define.vitalPointColor
        //     },

        //     dataLabels: [
        //       {
        //         enabled: true,
        //         align: "left",
        //         verticalAlign: "middle",
        //         format: "{point.bloodSugarLevel} mg/dl",
        //         style: {
        //           fontWeight: "none"
        //         }
        //       }
        //     ]
        //   }
        //   series.push(graph6);
        // }
        //let graph1Define = this.graphDefine.filter(el => el.vitalGraphName == "最高血圧")[0];
        let graph1Define = this.graphDefine[0];
        if (graph1Define != undefined && graph1Define.vitalGraphName !== "血糖値") {
          graph1 = {
            type: "line",
            name: graph1Define.vitalGraphName,
            color: graph1Define.vitalLineColor,
            dashStyle: graph1Define.vitalLineTypeValue,
            lineWidth: Number(graph1Define.vitalLineSize),
            data: [],
            yAxis: graph1Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              symbol: graph1Define.vitalPointTypeValue,
              radius: Number(graph1Define.vitalPointSize),
              fillColor: graph1Define.vitalPointColor
            }
          }
          series.push(graph1);
        } else {
          graph1 = {
            type: "scatter",
            name: graph1Define.vitalGraphName,
            color: graph1Define.vitalLineColor,
            dashStyle: graph1Define.vitalLineTypeValue,
            lineWidth: Number(graph1Define.vitalLineSize),
            data: [],
            yAxis: graph1Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              //
              enabled: true,
              symbol: graph1Define.vitalPointTypeValue,
              radius: Number(graph1Define.vitalPointSize),
              fillColor: graph1Define.vitalPointColor
            },

            dataLabels: [
              {
                enabled: true,
                align: "left",
                verticalAlign: "middle",
                format: "{point.bloodSugarLevel} mg/dl",
                style: {
                  fontWeight: "none"
                }
              }
            ]
          }
          series.push(graph1);
        }

        let graph2 = undefined;
        let graph2Define =this.graphDefine[1];
        if (graph2Define != undefined && graph2Define.vitalGraphName !== "血糖値") {
          graph2 = {
            type: "line",
            name: graph2Define.vitalGraphName,
            color: graph2Define.vitalLineColor,
            dashStyle: graph2Define.vitalLineTypeValue,
            lineWidth: Number(graph2Define.vitalLineSize),
            data: [],
            yAxis: graph2Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              symbol: graph2Define.vitalPointTypeValue,
              radius: Number(graph2Define.vitalPointSize),
              fillColor: graph2Define.vitalPointColor
            }
          }
          series.push(graph2);
        } else {
          graph2 = {
            type: "scatter",
            name: graph2Define.vitalGraphName,
            color: graph2Define.vitalLineColor,
            dashStyle: graph2Define.vitalLineTypeValue,
            lineWidth: Number(graph2Define.vitalLineSize),
            data: [],
            yAxis: graph2Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              //
              enabled: true,
              symbol: graph2Define.vitalPointTypeValue,
              radius: Number(graph2Define.vitalPointSize),
              fillColor: graph2Define.vitalPointColor
            },

            dataLabels: [
              {
                enabled: true,
                align: "left",
                verticalAlign: "middle",
                format: "{point.bloodSugarLevel} mg/dl",
                style: {
                  fontWeight: "none"
                }
              }
            ]
          }
          series.push(graph2);
        }
        let graph3 = undefined;
        let graph3Define = this.graphDefine[2];
        if (graph3Define != undefined && graph3Define.vitalGraphName !== "血糖値" ) {
          graph3 = {
            type: "line",
            name: graph3Define.vitalGraphName,
            color: graph3Define.vitalLineColor,
            dashStyle: graph3Define.vitalLineTypeValue,
            lineWidth: Number(graph3Define.vitalLineSize),
            data: [],
            yAxis: graph3Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              symbol: graph3Define.vitalPointTypeValue,
              radius: Number(graph3Define.vitalPointSize),
              fillColor: graph3Define.vitalPointColor
            }
          }
          series.push(graph3);
        } else {
          graph3 = {
            type: "scatter",
            name: graph3Define.vitalGraphName,
            color: graph3Define.vitalLineColor,
            dashStyle: graph3Define.vitalLineTypeValue,
            lineWidth: Number(graph3Define.vitalLineSize),
            data: [],
            yAxis: graph3Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              //
              enabled: true,
              symbol: graph3Define.vitalPointTypeValue,
              radius: Number(graph3Define.vitalPointSize),
              fillColor: graph3Define.vitalPointColor
            },

            dataLabels: [
              {
                enabled: true,
                align: "left",
                verticalAlign: "middle",
                format: "{point.bloodSugarLevel} mg/dl",
                style: {
                  fontWeight: "none"
                }
              }
            ]
          }
          series.push(graph3);
        }
        let graph4 = undefined;
        let graph4Define = this.graphDefine[3];
        if (graph4Define != undefined && graph4Define.vitalGraphName !== "血糖値") {
          graph4 = {
            type: "line",
            name: graph4Define.vitalGraphName,
            color: graph4Define.vitalLineColor,
            dashStyle: graph4Define.vitalLineTypeValue,
            lineWidth: Number(graph4Define.vitalLineSize),
            data: [],
            yAxis: graph4Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              symbol: graph4Define.vitalPointTypeValue,
              radius: Number(graph4Define.vitalPointSize),
              fillColor: graph4Define.vitalPointColor
            }
          }
          series.push(graph4);
        } else {
          graph4 = {
            type: "scatter",
            name: graph4Define.vitalGraphName,
            color: graph4Define.vitalLineColor,
            dashStyle: graph4Define.vitalLineTypeValue,
            lineWidth: Number(graph4Define.vitalLineSize),
            data: [],
            yAxis: graph4Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              //
              enabled: true,
              symbol: graph4Define.vitalPointTypeValue,
              radius: Number(graph4Define.vitalPointSize),
              fillColor: graph4Define.vitalPointColor
            },

            dataLabels: [
              {
                enabled: true,
                align: "left",
                verticalAlign: "middle",
                format: "{point.bloodSugarLevel} mg/dl",
                style: {
                  fontWeight: "none"
                }
              }
            ]
          }
          series.push(graph4);
        }
        let graph5 = undefined;
        let graph5Define = this.graphDefine[4];
        if (graph5Define != undefined && graph5Define.vitalGraphName !== "血糖値") {
          graph5 = {
            type: "line",
            name: graph5Define.vitalGraphName,
            color: graph5Define.vitalLineColor,
            dashStyle: graph5Define.vitalLineTypeValue,
            lineWidth: Number(graph5Define.vitalLineSize),
            data: [],
            yAxis: graph5Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              symbol: graph5Define.vitalPointTypeValue,
              radius: Number(graph5Define.vitalPointSize),
              fillColor: graph5Define.vitalPointColor
            }
          }
          series.push(graph5);
        } else {
          graph5 = {
            type: "scatter",
            name: graph5Define.vitalGraphName,
            color: graph5Define.vitalLineColor,
            dashStyle: graph5Define.vitalLineTypeValue,
            lineWidth: Number(graph5Define.vitalLineSize),
            data: [],
            yAxis: graph5Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              //
              enabled: true,
              symbol: graph5Define.vitalPointTypeValue,
              radius: Number(graph5Define.vitalPointSize),
              fillColor: graph5Define.vitalPointColor
            },

            dataLabels: [
              {
                enabled: true,
                align: "left",
                verticalAlign: "middle",
                format: "{point.bloodSugarLevel} mg/dl",
                style: {
                  fontWeight: "none"
                }
              }
            ]
          }
          series.push(graph5);
        }
        let graph6 = undefined;
        let graph6Define = this.graphDefine[5];
        if (graph6Define != undefined && graph6Define.vitalGraphName !== "血糖値") {
          graph6 = {
            type: "line",
            name: graph6Define.vitalGraphName,
            color: graph6Define.vitalLineColor,
            dashStyle: graph6Define.vitalLineTypeValue,
            lineWidth: Number(graph6Define.vitalLineSize),
            data: [],
            yAxis: graph6Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              symbol: graph6Define.vitalPointTypeValue,
              radius: Number(graph6Define.vitalPointSize),
              fillColor: graph6Define.vitalPointColor
            }
          }
          series.push(graph6);
        } else {
          graph6 = {
            type: "scatter",
            name: graph6Define.vitalGraphName,
            color: graph6Define.vitalLineColor,
            dashStyle: graph6Define.vitalLineTypeValue,
            lineWidth: Number(graph6Define.vitalLineSize),
            data: [],
            yAxis: graph6Define.vitalGraphName === "体温" ? 1 : 0,
            marker: {
              //
              enabled: true,
              symbol: graph6Define.vitalPointTypeValue,
              radius: Number(graph6Define.vitalPointSize),
              fillColor: graph6Define.vitalPointColor
            },

            dataLabels: [
              {
                enabled: true,
                align: "left",
                verticalAlign: "middle",
                format: "{point.bloodSugarLevel} mg/dl",
                style: {
                  fontWeight: "none"
                }
              }
            ]
          }
          series.push(graph6);
        }

        this.chartOptions.series = series;
        //add FNSI-改修内容 グラフ様式修正 房 end
        // 最高血圧のデータ
        let indexBP_MAX =this.graphDefine.findIndex(el => el.vitalGraphName == "最高血圧");
        if (indexBP_MAX !== -1){
          this.chartOptions.series[indexBP_MAX].data = this.vitalData
          .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MAX.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MAX.cd] !== undefined)
          .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MAX.cd]]);
        }
        // this.chartOptions.series[CHART_KIND.BP_MAX].data = this.vitalData
        //   .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MAX.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MAX.cd] !== undefined)
        //   .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MAX.cd]]);
        // 最低血圧のデータ
        let indexBP_MIN =this.graphDefine.findIndex(el => el.vitalGraphName == "最低血圧");
        if (indexBP_MIN !== -1){
          this.chartOptions.series[indexBP_MIN].data = this.vitalData
          .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MIN.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MIN.cd] !== undefined)
          .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MIN.cd]]);
        }
        // this.chartOptions.series[CHART_KIND.BP_MIN].data = this.vitalData
        //   .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MIN.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MIN.cd] !== undefined)
        //   .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.BP_MIN.cd]]);
        // 平均血圧のデータ
        let indexBP_AVE =this.graphDefine.findIndex(el => el.vitalGraphName == "平均血圧");
        if (indexBP_AVE != -1) {
          this.chartOptions.series[indexBP_AVE].data = this.vitalData
          .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.BP_AVE.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.BP_AVE.cd] !== undefined)
          .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.BP_AVE.cd]]);
        }
        // this.chartOptions.series[CHART_KIND.BP_AVE].data = this.vitalData
        //   .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.BP_AVE.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.BP_AVE.cd] !== undefined)
        //   .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.BP_AVE.cd]]);
        // 脈拍のデータ
        let indexPULSE =this.graphDefine.findIndex(el => el.vitalGraphName == "脈拍");
        if (indexPULSE != -1) {
          this.chartOptions.series[indexPULSE].data = this.vitalData
          .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.PULSE.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.PULSE.cd] !== undefined)
          .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.PULSE.cd]]);
        }
        // this.chartOptions.series[CHART_KIND.PULSE].data = this.vitalData
        //   .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.PULSE.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.PULSE.cd] !== undefined)
        //   .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.PULSE.cd]]);
        // 体温のデータ
        let indexTEMPERATURE =this.graphDefine.findIndex(el => el.vitalGraphName == "体温");
        if (indexTEMPERATURE != -1) {
          this.chartOptions.series[
            indexTEMPERATURE
          ].data = this.vitalData
          .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.TEMPERATURE.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.TEMPERATURE.cd] !== undefined)
          .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.TEMPERATURE.cd]]);
        }
        // this.chartOptions.series[
        //   CHART_KIND.TEMPERATURE
        //   ].data = this.vitalData
        //   .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.TEMPERATURE.cd] !== null && e.monitorData[CODES.VITAL_MONITOR_KEY.TEMPERATURE.cd] !== undefined)
        //   .map(e => [e.occurDateUTC, e.monitorData[CODES.VITAL_MONITOR_KEY.TEMPERATURE.cd]]);
        // 血糖値のデータ
        let indexBLOOD_SUGAR_LEVEL =this.graphDefine.findIndex(el => el.vitalGraphName == "血糖値");
        if (indexBLOOD_SUGAR_LEVEL != -1) {
          this.chartOptions.series[
            indexBLOOD_SUGAR_LEVEL
          ].data = this.vitalData
          .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.BLOOD_SUGAR.cd] !== null &&
            e.monitorData[CODES.VITAL_MONITOR_KEY.BLOOD_SUGAR.cd] !== undefined)
          .map(e => {
            return {
              x: e.occurDateUTC,
              /* modify by chamaojia 2023-06-01 バイタル血糖值表示错误  --start */
              // 元の固定値270が読み出した記録値に変更される
              y: e.monitorData[CODES.VITAL_MONITOR_KEY.BLOOD_SUGAR.cd],
              /* modify by chamaojia 2023-06-01 バイタル血糖值表示错误  --end */
              bloodSugarLevel: e.monitorData[CODES.VITAL_MONITOR_KEY.BLOOD_SUGAR.cd]
            };
          });
        }
        // this.chartOptions.series[
        //   CHART_KIND.BLOOD_SUGAR_LEVEL
        //   ].data = this.vitalData
        //   .filter(e => e.monitorData[CODES.VITAL_MONITOR_KEY.BLOOD_SUGAR.cd] !== null &&
        //     e.monitorData[CODES.VITAL_MONITOR_KEY.BLOOD_SUGAR.cd] !== undefined)
        //   .map(e => {
        //     return {
        //       x: e.occurDateUTC,
        //       y: 270,
        //       bloodSugarLevel: e.monitorData[CODES.VITAL_MONITOR_KEY.BLOOD_SUGAR.cd]
        //     };
        //   });
        // MOD 6499 治療記録バイタルマスタの並び順を変更したが治療記録のバイタルグラフに反映されない 周安寧 END
        // del FNSI-改修内容 monitorグラフ修正 房 start
        // // x軸の間隔(30分間隔)
        // const xAxisUnit = 30 * 60 * 1000;
        // // 30分間隔で6時間表示
        // let createCount = 13;
        // // バイタルデータ有り
        // if (this.vitalData.length > 0) {
        //   // グラフの左端を調整するためにダミーデータを追加
        //   let dummyStartData = this.isTimeSeries
        //     // 時系列表示
        //     ? this.startDate
        //       ? date2UTC(this.startDate)
        //       : Math.floor(this.vitalData[0].occurDateUTC / xAxisUnit) * xAxisUnit
        //     // 時刻表示(治療開始日)
        //     // 治療開始日時が設定されている場合は、治療開始日を基準とする.
        //     // 治療開始日時が未設定の場合は、バイタルデータ内の最古の発生日時を基準とする.
        //     : this.startDate
        //       ? date2UTC(this.startDate) - xAxisUnit
        //       : Math.floor(this.vitalData[0].occurDateUTC / xAxisUnit) * xAxisUnit;
        //
        //   // 治療開始日時と終了日時から表示するx軸の目盛数を算出
        //   createCount = getXAxisRangeCount(new Date(dummyStartData), this.endDate);
        //   // 治療開始日時とバイタルデータの最古の日付が同一の場合
        //   if (!this.isTimeSeries &&
        //       this.startDate &&
        //       ((date2UTC(this.startDate) === this.vitalData[0].occurDateUTC) ||
        //         date2UTC(this.startDate) < this.vitalData[0].occurDateUTC)) {
        //     // ダミーデータの開始日に治療開始日を設定
        //     dummyStartData = date2UTC(this.startDate);
        //     // 目盛数を-1
        //     createCount = createCount - 1;
        //   }
        //
        //   // 時系列表示
        //   if (this.isTimeSeries) {
        //     createCount = createCount - 1;
        //   }
        //
        //   // x軸の最小最大を設定
        //   this.chartOptions.series[0].data.unshift([dummyStartData, null]);
        //   this.chartOptions.series[0].data.push([dummyStartData + (xAxisUnit * createCount), null]);
        //
        //   // 3o分ごとにX軸の目盛りを表示する
        //   this.chartOptions.xAxis.tickPositions = [...Array(48)].map(
        //     (_, i) => dummyStartData + xAxisUnit * i
        //   );
        // } else {
        //   // 治療開始日時と治療終了日時からx軸の目盛数を算出
        //   createCount = getXAxisRangeCount(this.startDate, this.endDate);
        //   // 治療開始日時が設定されている場合のみ処理
        //   if (this.startDate) {
        //     const dummyStartData = this.isTimeSeries
        //       ? date2UTC(this.startDate)
        //       : Math.floor(date2UTC(this.startDate) / xAxisUnit) * xAxisUnit;
        //     this.chartOptions.xAxis.tickPositions = [...Array(createCount)].map(
        //       (_, i) => dummyStartData + xAxisUnit * i
        //     );
        //     this.chartOptions.series[0].data = [...Array(createCount)].map(
        //       (_, i) => [dummyStartData + xAxisUnit * i, null]
        //     );
        //   }
        // }
        // del FNSI-改修内容 monitorグラフ修正 房 end

        //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 start 20221031 赵
        // add FNSI-改修内容 monitorグラフ修正 房 start

        // let xShowArrs = [];
        // let loopCnt = 0;
        // if (this.vitalData.length > 0) {
        //   this.startDate = this.vitalData[0].occurDateUTC;
        //   this.endDate = this.vitalData[this.vitalData.length-1].occurDateUTC;
        //   loopCnt = Math.ceil((this.endDate - this.startDate) / 1000 / 60 / 30);
        //   if (loopCnt < 12) {
        //     loopCnt = 13;
        //   } else {
        //     loopCnt += 1;
        //   }
        //   if (!this.isTimeSeries) {
        //     xShowArrs[0] = this.startDate - 15 * 60 * 1000;
        //     for (let startIndex = 0; startIndex < loopCnt; startIndex++) {
        //       xShowArrs[startIndex+1] = this.startDate + 30 * 60 * 1000 * startIndex;
        //     }
        //     xShowArrs[loopCnt+1] = this.startDate + 30 * 60 * 1000 * (loopCnt-1) + 15 * 60 * 1000;
        //     // x軸の最小最大を設定
        //     if (this.chartOptions.series[0]) {
        //       this.chartOptions.series[0].data.unshift([xShowArrs[0], null]);
        //       this.chartOptions.series[0].data.push([xShowArrs[loopCnt+1], null]);
        //     }
        //     this.chartOptions.xAxis.tickPositions = xShowArrs;
        //   } else {
        //     this.startDate = this.vitalData[0].occurDateUTC;
        //     this.endDate = this.vitalData[this.vitalData.length-1].occurDateUTC;
        //     xShowArrs[0] = this.startDate;
        //     for (let sIndex = 1; sIndex < loopCnt; sIndex++) {
        //       xShowArrs[sIndex] = this.startDate + sIndex*30*60*1000
        //     }
        //     xShowArrs[loopCnt] = this.startDate + (loopCnt-1)*30*60*1000 + 15*60*1000;
        //     if (this.chartOptions.series[0]) {
        //       this.chartOptions.series[0].data.unshift([xShowArrs[0], null]);
        //       this.chartOptions.series[0].data.push([xShowArrs[loopCnt], null]);
        //     }
        //     this.chartOptions.xAxis.tickPositions = xShowArrs;
        //   }
        // } else {
        //   const beginDate = dayjs(new Date().getTime()).utc().valueOf() - 15*60*1000;
        //   if (this.isTimeSeries) {
        //     this.startDate = beginDate;
        //     xShowArrs[0] = beginDate;
        //     for (let sIndex = 1; sIndex <= 12; sIndex++) {
        //       xShowArrs[sIndex] = beginDate + sIndex*30*60*1000
        //     }
        //     xShowArrs[13] = beginDate + 12*30*60*1000 + 15*60*1000;
        //   } else {
        //     xShowArrs[0] = beginDate;
        //     xShowArrs[1] = beginDate + 15*60*1000;
        //     for (let sIndex = 2; sIndex <=13; sIndex++) {
        //       xShowArrs[sIndex] = beginDate + 15*60*1000 + (sIndex-1)*30*60*1000;
        //     }
        //     xShowArrs[14] = beginDate + 13*30*60*1000
        //   }
        //   this.chartOptions.xAxis.tickPositions = xShowArrs;
        //   // x軸の最小最大を設定
        //   if (this.chartOptions.series[0]) {
        //     this.chartOptions.series[0].data.unshift([xShowArrs[0], null]);
        //     this.chartOptions.series[0].data.push([xShowArrs[xShowArrs.length-1] , null]);
        //   }
        // }
        let xShowArrs = [];
        let loopCnt = 0;
        let initEndDateNum;
        let currentDate = new Date();
        // this.startBef=15;
        // this.endAft=15;
        // if (this.vitalData.length > 0) {
        //   if(this.startDate>this.vitalData[0].occurDateUTC){
        //     this.startDate = this.vitalData[0].occurDateUTC;
        //   }else{
        //     this.startDate=this.startDate.getTime();
        //   }
        //   if(this.endDate<this.vitalData[this.vitalData.length-1].occurDateUTC){
        //     this.endDate = this.vitalData[this.vitalData.length-1].occurDateUTC;
        //   }else{
        //     this.endDate = this.endDate.getTime();
        //   }
        //   loopCnt = Math.ceil((this.endDate - this.startDate) / 1000 / 60 / 30);
        //   // if (loopCnt < 12) {
        //   //   loopCnt = 13;
        //   // } else {
        //   //   loopCnt += 1;
        //   // }
        //   if (!this.isTimeSeries) {
        //     xShowArrs[0] = this.startDate - 15 * 60 * 1000;
        //     for (let startIndex = 0; startIndex < loopCnt+1; startIndex++) {
        //       xShowArrs[startIndex+1] = this.startDate + 30 * 60 * 1000 * startIndex;
        //     }
        //     xShowArrs[loopCnt+2] = this.startDate + 30 * 60 * 1000 * (loopCnt) + 15 * 60 * 1000;
        //     // x軸の最小最大を設定
        //     if (this.chartOptions.series[0]) {
        //       this.chartOptions.series[0].data.unshift([xShowArrs[0], null]);
        //       this.chartOptions.series[0].data.push([xShowArrs[xShowArrs.length-1], null]);
        //     }
        //     this.chartOptions.xAxis.tickPositions = xShowArrs;
        //   } else {
        //     // this.startDate = this.vitalData[0].occurDateUTC;
        //     // this.endDate = this.vitalData[this.vitalData.length-1].occurDateUTC;
        //     xShowArrs[0] = this.startDate;
        //     for (let sIndex = 1; sIndex < loopCnt; sIndex++) {
        //       xShowArrs[sIndex] = this.startDate + sIndex*30*60*1000
        //     }
        //     xShowArrs[loopCnt] = this.startDate + (loopCnt-1)*30*60*1000 + 15*60*1000;
        //     if (this.chartOptions.series[0]) {
        //       this.chartOptions.series[0].data.unshift([xShowArrs[0], null]);
        //       this.chartOptions.series[0].data.push([xShowArrs[xShowArrs.length-1], null]);
        //     }
        //     this.chartOptions.xAxis.tickPositions = xShowArrs;
        //   }
        //} else {
        if(this.endDate != null){
          initEndDateNum = this.endDate.getTime();
        }
        let tmpStartDate = this.startDate;
        let tmpEndDate = this.endDate;
        if ((this.rstDialysisState == 1 || this.rstDialysisState == 2) && this.vitalData.length <= 0) {
          tmpStartDate = currentDate;
          tmpEndDate = new Date(tmpStartDate.getTime() + 360 * 60 * 1000);
          this.startBef = 0;
          if (tmpEndDate < this.endDate) {
            tmpEndDate = this.endDate;
            this.endAft = 15;
          }
        }
        if ((this.rstDialysisState == 1 || this.rstDialysisState == 2) && this.vitalData.length > 0) {
          tmpStartDate = new Date(this.vitalData[0].occurDateUTC);
          if (this.vitalData.length == 1) {
            tmpEndDate = new Date(tmpStartDate.getTime() + 360 * 60 * 1000);
          } else if (this.vitalData.length > 1) {
            if (this.vitalData[this.vitalData.length - 1].occurDateUTC < (tmpStartDate.getTime() + 360 * 60 * 1000)) {
              tmpEndDate = new Date(tmpStartDate.getTime() + 360 * 60 * 1000);
            } else {
              tmpEndDate = new Date(this.vitalData[this.vitalData.length - 1].occurDateUTC);
            }
          }
          if (tmpEndDate < currentDate) {
            tmpEndDate = currentDate;
          }
          if (tmpEndDate < this.endDate) {
            tmpEndDate = this.endDate;
            this.endAft = 15;
          }
          this.startBef = 0;
        }
        if (this.rstDialysisState == 3) {
          if (this.vitalData.length > 0) {
            if (this.startDate == null) {
              this.startBef = 0;
              tmpStartDate = new Date(this.vitalData[0].occurDateUTC);
            } else {
              if (tmpStartDate.getTime() > this.vitalData[0].occurDateUTC) {
                this.startBef = (Math.floor(Math.floor((tmpStartDate.getTime() - this.vitalData[0].occurDateUTC) / (60 * 1000) / 5) / 3) + 1) * 15;
              } else {
                this.startBef = 15;
              }
            }
            initEndDateNum = (dayjs(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000) + 360 * 60 * 1000;
            if (this.vitalData[this.vitalData.length - 1].occurDateUTC < initEndDateNum) {
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
            } else {
              tmpEndDate = new Date(this.vitalData[this.vitalData.length - 1].occurDateUTC);
              this.endAft = 0;
            }
            if (tmpEndDate < currentDate) {
              tmpEndDate = currentDate;
              this.endAft = 0;
            }
            if (tmpEndDate < this.endDate) {
              tmpEndDate = this.endDate;
              this.endAft = 15;
            }
          } else {
            if (this.startDate == null) {
              this.startBef = 0;
              tmpStartDate = currentDate;
              initEndDateNum = tmpStartDate.getTime() + 360 * 60 * 1000;
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
              if (tmpEndDate < this.endDate) {
                tmpEndDate = this.endDate;
                this.endAft = 15;
              }
            } else {
              this.startBef = 15;
              initEndDateNum = (dayjs(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000) + 360 * 60 * 1000;
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
              if (tmpEndDate < currentDate) {
                tmpEndDate = currentDate;
                this.endAft = 0;
              }
              if (tmpEndDate < this.endDate) {
                tmpEndDate = this.endDate;
                this.endAft = 15;
              }
            }
          }
        }
        if ((this.rstDialysisState == 4 || this.rstDialysisState == 5 || this.rstDialysisState == 6) && (this.startDate == null || this.endDate == null)) {
          if (this.vitalData.length > 0) {
            if (this.startDate == null) {
              this.startBef = 0;
              tmpStartDate = new Date(this.vitalData[0].occurDateUTC);
            } else {
              if (tmpStartDate.getTime() > this.vitalData[0].occurDateUTC) {
                this.startBef = (Math.floor(Math.floor((tmpStartDate.getTime() - this.vitalData[0].occurDateUTC) / (60 * 1000) / 5) / 3) + 1) * 15;
              } else {
                this.startBef = 15;
              }
            }
            initEndDateNum = (dayjs(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000) + 360 * 60 * 1000;
            if (this.vitalData[this.vitalData.length - 1].occurDateUTC < initEndDateNum) {
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
            } else {
              tmpEndDate = new Date(this.vitalData[this.vitalData.length - 1].occurDateUTC);
              this.endAft = 0;
            }
            if (tmpEndDate < this.endDate) {
              tmpEndDate = this.endDate;
              this.endAft = 15;
            }
          } else {
            if (this.startDate == null) {
              this.startBef = 0;
              tmpStartDate = currentDate;
              initEndDateNum = tmpStartDate.getTime() + 360 * 60 * 1000;
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
            } else {
              this.startBef = 15;
              initEndDateNum = (dayjs(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000) + 360 * 60 * 1000;
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
            }
            if (tmpEndDate < this.endDate) {
              tmpEndDate = this.endDate;
              this.endAft = 15;
            }
          }
        }
        if ((this.rstDialysisState == 4 || this.rstDialysisState == 5 || this.rstDialysisState == 6) && (this.startDate != null && this.endDate != null)) {
          if (this.vitalData.length > 0) {
            if (tmpStartDate.getTime() > this.vitalData[0].occurDateUTC) {
              this.startBef = (Math.floor(Math.floor((tmpStartDate.getTime() - this.vitalData[0].occurDateUTC) / (60 * 1000) / 5) / 3) + 1) * 15;
            }else{
              this.startBef = 15;
            }
            if (tmpEndDate.getTime() < this.vitalData[this.vitalData.length - 1].occurDateUTC) {
              initEndDateNum = this.vitalData[this.vitalData.length - 1].occurDateUTC;
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
            }
            if((initEndDateNum - (tmpStartDate.getTime() - (this.startBef * 60 * 1000))) <= 345 * 60 * 1000){
                initEndDateNum = tmpStartDate.getTime() - (this.startBef * 60 * 1000) + 360 * 60 * 1000;
                tmpEndDate = new Date(initEndDateNum);
                this.endAft = 15;
                if (initEndDateNum > this.vitalData[this.vitalData.length - 1].occurDateUTC){
                  this.endAft = 0;
                }
            }else{
              this.endAft = 15;
            }
            if(this.endDate.getTime() < this.vitalData[this.vitalData.length - 1].occurDateUTC){
              this.endAft = 0;
            }
          } else {
            this.startBef = 15;
            this.endAft = 15;
            if((tmpEndDate.getTime() - tmpStartDate.getTime()) < 330 * 60 * 1000){
              tmpEndDate = new Date(tmpStartDate.getTime() + 330 * 60 * 1000);
            }
          }
        }
        // mod 2024-06-10 #10515 治療記録のバイタル/モニタに登録されているデータによってサーバーが高負荷となる shiyw start
        // const beginDate = dayjs(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000;
        // const lastDate = dayjs(tmpEndDate).utc().valueOf() + this.endAft * 60 * 1000;
        const millisecondsOfBeginDate = dayjs(tmpStartDate).utc().valueOf();
        const millisecondsOfEndDate = dayjs(tmpEndDate).utc().valueOf();
        const beginDate = millisecondsOfBeginDate - this.startBef * 60 * 1000;
        let lastDate = millisecondsOfEndDate + this.endAft * 60 * 1000;
        // Highchartsタイムライン（X軸）最大240時間表示
        const millisecondsOf240h = 240 * 60 * 60 * 1000;
        if( (millisecondsOfEndDate - millisecondsOfBeginDate) > millisecondsOf240h ) {
          lastDate = (millisecondsOfBeginDate + millisecondsOf240h) + this.endAft * 60 * 1000;
        }
        // mod 2024-06-10 #10515 治療記録のバイタル/モニタに登録されているデータによってサーバーが高負荷となる shiyw end
        loopCnt = Math.ceil((lastDate - beginDate) / 1000 / 60 / 15);
        if (this.isTimeSeries) {
          tmpStartDate = beginDate;
          xShowArrs[0] = beginDate;
          for (let sIndex = 1; sIndex <= loopCnt; sIndex++) {
            xShowArrs[sIndex] = beginDate + sIndex * 15 * 60 * 1000;
          }
          //xShowArrs[xShowArrs.length] = lastDate - 30 * 60 * 1000;
          //xShowArrs[xShowArrs.length] = lastDate - 15 * 60 * 1000;
          //xShowArrs[xShowArrs.length] = lastDate;
        } else {
          xShowArrs[0] = beginDate;
          //xShowArrs[1] = beginDate + 30*60*1000;
          for (let sIndex = 1; sIndex <= loopCnt; sIndex++) {
            xShowArrs[sIndex] = beginDate + sIndex * 15 * 60 * 1000;
          }
          // if((lastDate - 30*60*1000)<xShowArrs[xShowArrs.length-1] + 30*60*1000){
          //   xShowArrs[xShowArrs.length] = lastDate - 30*60*1000;
          //   xShowArrs[xShowArrs.length] = xShowArrs[xShowArrs.length-2] + 30*60*1000;
          //   xShowArrs[xShowArrs.length] = lastDate;
          // }else{
          //   xShowArrs[xShowArrs.length] = lastDate - 30*60*1000;
          //   xShowArrs[xShowArrs.length] = lastDate;
          // }

          //xShowArrs[xShowArrs.length] = lastDate - 30 * 60 * 1000;
          //xShowArrs[xShowArrs.length] = lastDate - 15 * 60 * 1000;
          //xShowArrs[xShowArrs.length] = lastDate;
          // xShowArrs[xShowArrs.length] = lastDate - 30*60*1000;
          // xShowArrs[xShowArrs.length] = xShowArrs[xShowArrs.length-2] + 30*60*1000;
          // xShowArrs[xShowArrs.length] = lastDate;
        }
        this.chartOptions.xAxis.tickPositions = xShowArrs;
        this.chartOptions.xAxis.tickPixelInterval = 0;
        this.chartOptions.xAxis.gridLineWidth = 1;
        this.chartOptions.xAxis.labels.step = 1;
        this.chartOptions.xAxis.labels.allowOverlap = true;
        // x軸の最小最大を設定
        if (this.chartOptions.series[0]) {
          this.chartOptions.series[0].data.unshift([xShowArrs[0], null]);
          this.chartOptions.series[0].data.push([xShowArrs[xShowArrs.length - 1], null]);
        }
        //}
        this.chartOptions.xAxis.min = xShowArrs[0];
        this.chartOptions.xAxis.max = xShowArrs[xShowArrs.length - 1];
        //this.chartOptions.xAxis.startBef = this.startBef;
        //("2"+this.chartOptions.xAxis.startBef);

        this.chartOptions.xAxis.occurStartDate = this.isTimeSeries
          ? tmpStartDate + this.startBef * 60 * 1000
          : null;

        if (this.startDate != null || this.endDate != null) {
          this.applyDialysisPlotLines();
        }
        this.syncChartAxis(xShowArrs);

        // if((this.rstDialysisState==1||this.rstDialysisState==2)&&this.vitalData.length <= 0){
        //   this.chartOptions.xAxis.plotLines = [{
        //   color: 'green',
        //   value: this.startDate,
        //   width: 2
        // }, {
        //   color: 'green',
        //   value: this.endDate,
        //   width: 2
        // }];
        // }
        // if((this.rstDialysisState==1||this.rstDialysisState==2)&&this.vitalData.length > 0){
        //   this.chartOptions.xAxis.plotLines = [{
        //   color: 'green',
        //   value: this.startDate,
        //   width: 2
        // }, {
        //   color: 'green',
        //   value: this.endDate,
        //   width: 2
        // }];
        // }
        //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
        // add FNSI-改修内容 monitorグラフ修正 房 end

        // del FNSI-改修内容 monitorグラフ修正 房 start
        // // 時系列での表示時、X軸の値のオフセットを設定
        // this.chartOptions.xAxis.occurStartDate = this.isTimeSeries
        //   ? date2UTC(this.startDate)
        //   : null;
        // del FNSI-改修内容 monitorグラフ修正 房 end

        const submenuMainHeight = Number(getScopedElementsByClassName("submenu-main", this.$el || null)[0]?.clientHeight || 0);

        let chartHeight = (submenuMainHeight - 20) / 2 - 40;
        if (chartHeight < 250) {
          chartHeight = 280;
        }
        this.chartOptions.chart.height = chartHeight;
        //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正  赵 start
        // add FNSI-改修内容 monitorグラフ修正 房 start
        // const submenuMainWidth = document.getElementsByClassName(
        //   "highcharts-config"
        // )[0].clientWidth;
        // const element = getScopedElementsByClassName("vitalGraphView", this.$el || null);
        // if (loopCnt > 13) {
        //   element[0].style.width = submenuMainWidth / 13 * loopCnt + 'px';
        // } else {
        //   if (submenuMainWidth-1 < 1200) {
        //     element[0].style.width ='1200px';
        //   } else {
        //     element[0].style.width = (submenuMainWidth-1) + 'px';
        //   }
        // }
        const submenuMainWidth = Number(getScopedElementsByClassName("highcharts-config", this.$el || null)[0]?.clientWidth || 0);
        const element = getScopedElementsByClassName("vitalGraphView", this.$el || null);
        //if(initEndDate){
        if (loopCnt > (6*4)) {
          element[0].style.width = submenuMainWidth / 24 * loopCnt + 'px';
        } else {
          if (submenuMainWidth < 550) {
            element[0].style.width = '550px'
          } else {
            element[0].style.width = (submenuMainWidth - 1) + 'px';
          }
        }
        if (submenuMainWidth > 900) {
          this.chartOptions.xAxis.labels.rotation = 0;
        } else {
          this.chartOptions.xAxis.labels.rotation = 45;
        }
        // }else{
        //     if (submenuMainWidth-1 < 1200) {
        //       element[0].style.width ='1000px';
        //     } else {
        //       element[0].style.width = (submenuMainWidth-1) + 'px';
        //     }
        // }
        //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正  赵 end
        //del 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正  赵 start
        // add FNSI-改修内容 monitorグラフ修正 房 end
        //add FNSI-修正 redmine4844 房 start
        setTimeout(() => {
          let scrollRight = getScopedElementsByClassName("highcharts-config", this.$el || null);
          // mod 12409 治療状況リストから治療記録に遷移しサイドメニューから画面を開きパンくずリストの治療状況リストを押下すると画面遷移せずパンくずリストが消える zkm start
          // if (this.rstDialysisState <= 5) {
          if (this.rstDialysisState <= 5 && scrollRight.length > 0) {
            // mod 12409 治療状況リストから治療記録に遷移しサイドメニューから画面を開きパンくずリストの治療状況リストを押下すると画面遷移せずパンくずリストが消える zkm end
            scrollRight[0].scrollLeft = scrollRight[0].scrollWidth;
          }
        }, 100)
        //add FNSI-修正 redmine4844 房 end
        //del 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正  赵 end
      },
      /**
       * グラフエリアのリサイズ
       */
      graphResize() {
        this.createChartData();
      }
    },
    watch: {
      value: {
        handler() {
          this.vitalData = (Array.isArray(this.value) ? this.value : []).filter(e => !e.isNew);
          this.$nextTick(() => this.createChartData());
        },
        immediate: true,
        deep: true
      },
      chartScale() {
        this.createChartData();
      },
      windowHeight() {
        this.$nextTick(() => {
          this.createChartData();
        });
      },
      windowWidth() {
        this.$nextTick(() => {
          this.createChartData();
        });
      }

    },
    mounted() {
      // this.vitalData = (Array.isArray(this.value) ? this.value : []).filter(e => !e.isNew);
      this.$nextTick(() => {
        this.createChartData();
      });
    },
    beforeUnmount() {
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    },
    unmounted() {
      // グラフデータをクリア
      this.chartOptions.series.forEach(e => (e.data = []));
      // グラフ横軸緑線のクリア
      this.chartOptions.xAxis.plotLines = [];
    }
  };
</script>

<style scoped>
  .highcharts-config {
    overflow: auto;
  }
  :deep(.highcharts-axis.highcharts-xaxis .highcharts-axis-line),
  :deep(.highcharts-axis.highcharts-xaxis .highcharts-tick) {
    stroke: #ccd6eb;
  }
</style>
