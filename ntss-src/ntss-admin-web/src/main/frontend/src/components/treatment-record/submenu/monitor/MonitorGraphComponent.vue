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
    <highcharts :options="chartOptions" class="monitorGraphView"></highcharts>
  </div>
  <!-- mod FNSI-改修内容 monitorグラフ修正 房 end -->
</template>

<script>
  import Vue from "vue";
  import moment from "moment";
  import {mapGetters} from "vuex";
  import VueHighcharts from "vue-highcharts";
  import Highcharts from "highcharts";
  import Boost from "highcharts/modules/boost";
  import {CODES} from "@/constants/TreatmentRecord";
  import {MonitorGraphDefine} from "@/models/treatment-record/monitor/MonitorGraphDefine";
  // add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
  import {convertToHalfWidth} from "@/functions/common/CommonFunctions";
  // add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
  import {Monitor} from "@/models/treatment-record/monitor/Monitor";

  Vue.use(VueHighcharts);
  Boost(Highcharts);

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
      labels: {
        formatter: function () {
          //alert("3startBef"+this.axis.startBef)
          //alert("3min"+this.axis.min)
          const currentDate = moment(this.value);
          if (this.axis.options.occurStartDate) {
            // 時系列での表示
            //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
            let startDate = moment(this.axis.options.occurStartDate);
            //const startDate = moment(this.axis.options.occurStartDate+30*60*1000);
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
              startDate = moment(this.axis.options.occurStartDate);
              // let c= new Date();
              // moment(c.getTime());
              // let d=c.getTime()-15*60*1000*5;
              // moment(d);
              // moment(c.getTime())
              // .subtract(moment(d).hour(), "hours")
              // .subtract(moment(d).minute(), "minutes")
              // .subtract(moment(d).second(), "seconds").format("H:mm")

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
    yAxis: [],
    legend: {
      // グラフの凡例
      layout: "horizontal", // 横方向に並べる
      align: "left", // グラフの左に表示（左右中央）
      verticalAlign: "top", // グラフの上に表示（上下中央）
      floating: false, // 凡例をプロット外部に表示
      x: 20,
      y: -5
    },
    plotOptions: {
      // 点の設定
      series: {
        marker: {
          enabled: true // データプロット(●、▲、■)を表示
        }
      }
    },
    // FNSI-グラフの操作モーダルを削除 周 add start
    navigation: {
      buttonOptions: {
        enabled: false
      }
    },
    // FNSI-グラフの操作モーダルを削除 周 add end
    scrollbar: {
      enabled: true
    },
    series: [],
    //add FNSI-7978(治療記録側) ljx start
    tooltip: {
      xDateFormat: "%Y-%b-%e(%a) %H:%M",
      hideDelay: 100,
      snap: 0
    }
    //add FNSI-7978(治療記録側) ljx end
  };

  /**
   * グラフ種別
   */
  const CHART_KIND = {
    LEFT: 0,
    RIGHT: 1
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
      chartScale: {
        type: String,
        default: CODES.CHART_SCALE.TIME.cd
      },
      graphDefine: {
        type: MonitorGraphDefine
      },
      monitorItem: {
        type: Array,
        default: () => []
      },
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
      graphTime: {
        type: Number
      },
      rstDialysisState: {
        type: String
      }
      //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
    },
    data() {
      return {
        monitorData: [],
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
       * グラフ用データ生成
       */
      createChartData() {
        const yAxis = [];
        const series = [];

        [CHART_KIND.LEFT, CHART_KIND.RIGHT].forEach((chartKind, index) => {
          const isLeft = chartKind === CHART_KIND.LEFT;
          const dataIndex = isLeft
            ? this.graphDefine.leftDataIndex
            : this.graphDefine.rightDataIndex;
          const color = isLeft
            ? this.graphDefine.leftColor
            : this.graphDefine.rightColor;
          //add FNSI-改修内容 グラフ様式修正 房 start
          const lineSize = isLeft
            ? this.graphDefine.leftLineSize
            : this.graphDefine.rightLineSize
          const lineType = isLeft
            ? this.graphDefine.leftLineTypeValue
            : this.graphDefine.rightLineTypeValue
          const pointColor = isLeft
            ? this.graphDefine.leftPointColor
            : this.graphDefine.rightPointColor
          const pointSize = isLeft
            ? this.graphDefine.leftPointSize
            : this.graphDefine.rightPointSize
          const pointType = isLeft
            ? this.graphDefine.leftPointTypeValue
            : this.graphDefine.rightPointTypeValue
          //add FNSI-改修内容 グラフ様式修正 房 end
          //mod 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
          // const item = this.monitorItem.find(e => e.dataIndex === dataIndex);
          // if (item) {
          //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
          const min = isLeft ? Number(this.graphDefine.leftGraphLowerLimit) : Number(this.graphDefine.rightGraphLowerLimit);
          const max = isLeft ? Number(this.graphDefine.leftGraphUpperLimit) : Number(this.graphDefine.rightGraphUpperLimit);
          const range = isLeft ? Number(this.graphDefine.leftGraphUpperLimit) - Number(this.graphDefine.leftGraphLowerLimit)
            : Number(this.graphDefine.rightGraphUpperLimit) - Number(this.graphDefine.rightGraphLowerLimit);
          const intervalItem = range / 10;
          let yArry = [];
          for (let index = 1; index < 10; index++) {
            let yitem = min + (intervalItem * index);
            yArry.push(Number(yitem.toFixed(1)));
          }
          yArry.unshift(min);
          yArry.push(max);
          //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
          yAxis.push({
            title: false,
            //add FNSI-9858改修内容 グラフ様式修正 杜天成 start
            min: isLeft==true ? this.graphDefine.leftGraphLowerLimit : this.graphDefine.rightGraphLowerLimit,
            max: isLeft==true ? this.graphDefine.leftGraphUpperLimit : this.graphDefine.rightGraphUpperLimit,
            //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
            tickPositions: yArry,
            //add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
            alignTicks: false,
            tickAmount: 10,
            opposite: !isLeft,
            labels: {
              align: "right",
              x: isLeft ? -5 : 30,
              style: {
                width: "40px",
                textOverflow: "none"
              },
              format:isLeft==true ? (this.graphDefine.leftGraphUpperLimit - this.graphDefine.leftGraphLowerLimit) < 10 ? "{value: .1f}" : null
                : (this.graphDefine.rightGraphUpperLimit - this.graphDefine.rightGraphLowerLimit) < 10 ? "{value: .1f}" : null
            }
          });
            series.push({
              type: "line",
              // name: item.shortName,
              name: isLeft==true ?this.graphDefine.leftName:this.graphDefine.rightName,
              color: color,
              //add FNSI-改修内容 グラフ様式修正 房 start
              lineWidth: Number(lineSize),
              dashStyle: lineType,
              //add FNSI-改修内容 グラフ様式修正 房 end
              data: this.monitorData
                // mod #10077 by zhangruixue 2024-3-12  start
            // .filter(e => e.monitorData[String(dataIndex)] !== null)
                .filter(e => {
                  const value = e.monitorData[String(dataIndex)];
                  // mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
                  // if (isNaN(Number(this.convertToHalfWidth(value)))){
                  if (isNaN(Number(convertToHalfWidth(value)))){
                  // mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
                    return false;
                  }
                  if (typeof value === 'number') {
                    return !isNaN(value);
                  }
                  else if (typeof value === 'string') {
                    return value.trim() !== "";
                  }
                  return value != null;
                })
                // mod #10077 by zhangruixue 2024-3-12  end
                // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
                // .map(e => [
                //   e.occurDateUTC,
                //   // mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
                //   // Number(this.convertToHalfWidth(e.monitorData[String(dataIndex)]))
                //   Number(convertToHalfWidth(e.monitorData[String(dataIndex)]))
                //   // mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
                // ]),
                .map(e => {
                  const rawValue = convertToHalfWidth(e.monitorData[String(dataIndex)]);
                  return {
                    x: e.occurDateUTC,
                    y: Number(rawValue),
                    rawY: rawValue
                  }
                }),
              tooltip: {
                pointFormatter: function () {
                  return `●${this.series.name}: ${this.rawY}`;
                }
              },
              // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
              yAxis:yAxis.length-1,
           //add FNSI-9858改修内容 グラフ様式修正 杜天成 end
              //add FNSI-改修内容 グラフ様式修正 房 start
              marker: {
                symbol: pointType,
                radius: Number(pointSize),
                fillColor: pointColor,
              }
              //add FNSI-改修内容 グラフ様式修正 房 end
            });
          // }
          //mod 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end
        });

        this.chartOptions.yAxis = yAxis;
        this.chartOptions.series = series;


        // del FNSI-改修内容 monitorグラフ修正 房 start
        // // x軸の間隔(30分間隔)
        // const xAxisUnit = 30 * 60 * 1000;
        // // 30分間隔で6時間表示
        // let createCount = 13;


        // if (this.monitorData.length > 0) {
        //   // グラフの左端を調整するためにダミーデータを追加
        //   let dummyStartData = this.isTimeSeries
        //     // 時系列表示
        //     ? this.startDate
        //       ? date2UTC(this.startDate)
        //       : Math.floor(this.monitorData[0].occurDateUTC / xAxisUnit) * xAxisUnit
        //     // 時刻表示(治療開始日)
        //     // 治療開始日時が設定されている場合は、治療開始日を基準とする.
        //     // 治療開始日時が未設定の場合は、データ内の最古の発生日時を基準とする.
        //     : this.startDate
        //       ? date2UTC(this.startDate) - xAxisUnit
        //       : Math.floor(this.monitorData[0].occurDateUTC / xAxisUnit) * xAxisUnit;
        //
        //   // 治療開始日時と終了日時から表示するx軸の目盛数を算出
        //   createCount = getXAxisRangeCount(new Date(dummyStartData), this.endDate);
        //   // 治療開始日時とデータの最古の日付が同一の場合
        //   if (!this.isTimeSeries &&
        //       this.startDate &&
        //       ((date2UTC(this.startDate) === this.monitorData[0].occurDateUTC) ||
        //         date2UTC(this.startDate) < this.monitorData[0].occurDateUTC)) {
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
        //   if (this.chartOptions.series[0]) {
        //     this.chartOptions.series[0].data.unshift([dummyStartData, null]);
        //     this.chartOptions.series[0].data.push([dummyStartData + (xAxisUnit * createCount), null]);
        //   }
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

        // // 時系列での表示時、X軸の値のオフセットを設定
        // this.chartOptions.xAxis.occurStartDate = this.isTimeSeries
        //   ? date2UTC(this.startDate)
        //   : null;
        // del FNSI-改修内容 monitorグラフ修正 房 end
        //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 start 20221031  赵
        // add FNSI-改修内容 monitorグラフ修正 房 start
        // let xShowArrs = [];
        // let loopCnt = 0;
        // if (this.monitorData.length > 0) {
        //   this.startDate = this.monitorData[0].occurDateUTC;
        //   this.endDate = this.monitorData[this.monitorData.length-1].occurDateUTC;
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
        //     this.startDate = this.monitorData[0].occurDateUTC;
        //     this.endDate = this.monitorData[this.monitorData.length-1].occurDateUTC;
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
        //   const beginDate = moment(new Date().getTime()).utc().valueOf();
        //   if (this.isTimeSeries) {
        //     this.startDate = beginDate;
        //     xShowArrs[0] = beginDate;
        //     for (let sIndex = 1; sIndex <= 12; sIndex++) {
        //       xShowArrs[sIndex] = beginDate + sIndex*30*60*1000
        //     }
        //     xShowArrs[13] = beginDate + 12*30*60*1000 + 15*60*1000;
        //   } else {
        //     xShowArrs[0] = beginDate -  15*60*1000;
        //     xShowArrs[1] = beginDate ;
        //     for (let sIndex = 2; sIndex <=13; sIndex++) {
        //       xShowArrs[sIndex] = beginDate  + (sIndex-1)*30*60*1000;
        //     }
        //     xShowArrs[14] = beginDate + 12*30*60*1000 + 15*60*1000;
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
        // if (this.monitorData.length > 0) {
        //   if(this.startDate>this.monitorData[0].occurDateUTC){
        //     this.startDate = this.monitorData[0].occurDateUTC;
        //   }else{
        //     this.startDate=this.startDate.getTime();
        //   }
        //   if(this.endDate<this.monitorData[this.monitorData.length-1].occurDateUTC){
        //     this.endDate = this.monitorData[this.monitorData.length-1].occurDateUTC;
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
        //     xShowArrs[0] = this.startDate - 15 * 60 * 1000 * 2;
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
        //     this.startDate = this.monitorData[0].occurDateUTC;
        //     this.endDate = this.monitorData[this.monitorData.length-1].occurDateUTC;
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
        //} else {
        if (this.endDate != null) {
          initEndDateNum = this.endDate.getTime();
        }
        let tmpStartDate = this.startDate;
        let tmpEndDate = this.endDate;
        if ((this.rstDialysisState == 1 || this.rstDialysisState == 2) && this.monitorData.length <= 0) {
          tmpStartDate = currentDate;
          tmpEndDate = new Date(tmpStartDate.getTime() + 360 * 60 * 1000);
          this.startBef = 0;
          if (tmpEndDate < this.endDate) {
            tmpEndDate = this.endDate;
            this.endAft = 15;
          }
        }
        if ((this.rstDialysisState == 1 || this.rstDialysisState == 2) && this.monitorData.length > 0) {
          tmpStartDate = new Date(this.monitorData[0].occurDateUTC);
          if (this.monitorData.length == 1) {
            tmpEndDate = new Date(tmpStartDate.getTime() + 360 * 60 * 1000);
          } else if (this.monitorData.length > 1) {
            if (this.monitorData[this.monitorData.length - 1].occurDateUTC < (tmpStartDate.getTime() + 360 * 60 * 1000)) {
              tmpEndDate = new Date(tmpStartDate.getTime() + 360 * 60 * 1000);
            } else {
              tmpEndDate = new Date(this.monitorData[this.monitorData.length - 1].occurDateUTC);
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
          if (this.monitorData.length > 0) {
            if (this.startDate == null) {
              this.startBef = 0;
              tmpStartDate = new Date(this.monitorData[0].occurDateUTC);
            } else {
              if (tmpStartDate.getTime() > this.monitorData[0].occurDateUTC) {
                this.startBef = (Math.floor(Math.floor((tmpStartDate.getTime() - this.monitorData[0].occurDateUTC) / (60 * 1000) / 5) / 3) + 1) * 15;
              } else {
                this.startBef = 15;
              }
            }
            initEndDateNum = (moment(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000) + 360 * 60 * 1000;
            if (this.monitorData[this.monitorData.length - 1].occurDateUTC < initEndDateNum) {
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
            } else {
              tmpEndDate = new Date(this.monitorData[this.monitorData.length - 1].occurDateUTC);
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
              initEndDateNum = (moment(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000) + 360 * 60 * 1000;
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
          if (this.monitorData.length > 0) {
            if (this.startDate == null) {
              this.startBef = 0;
              tmpStartDate = new Date(this.monitorData[0].occurDateUTC);
            } else {
              if (tmpStartDate.getTime() > this.monitorData[0].occurDateUTC) {
                this.startBef = (Math.floor(Math.floor((tmpStartDate.getTime() - this.monitorData[0].occurDateUTC) / (60 * 1000) / 5) / 3) + 1) * 15;
              } else {
                this.startBef = 15;
              }
            }
            initEndDateNum = (moment(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000) + 360 * 60 * 1000;
            if (this.monitorData[this.monitorData.length - 1].occurDateUTC < initEndDateNum) {
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
            } else {
              tmpEndDate = new Date(this.monitorData[this.monitorData.length - 1].occurDateUTC);
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
              initEndDateNum = (moment(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000) + 360 * 60 * 1000;
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
          if (this.monitorData.length > 0) {
            if (tmpStartDate.getTime() > this.monitorData[0].occurDateUTC) {
              this.startBef = (Math.floor(Math.floor((tmpStartDate.getTime() - this.monitorData[0].occurDateUTC) / (60 * 1000) / 5) / 3) + 1) * 15;
            }else{
              this.startBef = 15;
            }
            if (tmpEndDate.getTime() < this.monitorData[this.monitorData.length - 1].occurDateUTC) {
              initEndDateNum = this.monitorData[this.monitorData.length - 1].occurDateUTC;
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 0;
            }
            if((initEndDateNum - (tmpStartDate.getTime() - (this.startBef * 60 * 1000))) <= 345 * 60 * 1000){
              initEndDateNum = tmpStartDate.getTime() - (this.startBef * 60 * 1000) + 360 * 60 * 1000;
              tmpEndDate = new Date(initEndDateNum);
              this.endAft = 15;
              if (initEndDateNum > this.monitorData[this.monitorData.length - 1].occurDateUTC){
                this.endAft = 0;
              }
            }else{
              this.endAft = 15;
            }
            if(this.endDate.getTime() < this.monitorData[this.monitorData.length - 1].occurDateUTC){
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
        // const beginDate = moment(tmpStartDate).utc().valueOf() - this.startBef * 60 * 1000;
        // const lastDate = moment(tmpEndDate).utc().valueOf() + this.endAft * 60 * 1000;
        const millisecondsOfBeginDate = moment(tmpStartDate).utc().valueOf();
        const millisecondsOfEndDate = moment(tmpEndDate).utc().valueOf();
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
        // x軸の最小最大を設定
        if (this.chartOptions.series[0]) {
          this.chartOptions.series[0].data.unshift([xShowArrs[0], null]);
          this.chartOptions.series[0].data.push([xShowArrs[xShowArrs.length - 1], null]);
        }
        //}
        this.chartOptions.xAxis.min = xShowArrs[0];
        this.chartOptions.xAxis.max = xShowArrs[xShowArrs.length - 1];
        //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正  赵 end
        this.chartOptions.xAxis.occurStartDate = this.isTimeSeries
          ? tmpStartDate + this.startBef * 60 * 1000
          : null;
        // add FNSI-改修内容 monitorグラフ修正 房 end
        if (this.startDate != null && this.endDate != null) {
          this.chartOptions.xAxis.plotLines = [{
            color: 'green',
            value: this.startDate.getTime(),
            width: 2
          }, {
            color: 'green',
            value: this.endDate.getTime(),
            width: 2
          }];
        } else if (this.startDate != null) {
          this.chartOptions.xAxis.plotLines = [{
            color: 'green',
            value: this.startDate.getTime(),
            width: 2
          }];
        } else if(this.endDate != null) {
          this.chartOptions.xAxis.plotLines = [{
            color: 'green',
            value: this.endDate.getTime(),
            width: 2
          }];
        }

        //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
        const submenuMainHeight = document.getElementsByClassName(
          "submenu-main"
        )[0].clientHeight;

        const chartHeight = (submenuMainHeight - 20) / 2 - 40;
        this.chartOptions.chart.height = chartHeight >= 250 ? chartHeight : 250;
        //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正  赵 start
        // add FNSI-改修内容 monitorグラフ修正 房 start
        // const submenuMainWidth = document.getElementsByClassName(
        //   "highcharts-config"
        // )[0].clientWidth;
        // const element = document.getElementsByClassName("monitorGraphView");
        // if (loopCnt > 13) {
        //   element[0].style.width = submenuMainWidth / 13 * loopCnt + 'px';
        // } else {
        //   if (submenuMainWidth-1 < 1200) {
        //     element[0].style.width ='1200px';
        //   } else {
        //     element[0].style.width = (submenuMainWidth-1) + 'px';
        //   }
        // }
        const submenuMainWidth = document.getElementsByClassName(
          "highcharts-config"
        )[0].clientWidth;
        const element = document.getElementsByClassName("monitorGraphView");
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
        //mod 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正  赵 end
        //del 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正  赵 start
        //add FNSI-修正 redmine4844 房 start
        setTimeout(()=>{
          let scrollRight = document.getElementsByClassName("highcharts-config");
          // mod 12409 治療状況リストから治療記録に遷移しサイドメニューから画面を開きパンくずリストの治療状況リストを押下すると画面遷移せずパンくずリストが消える zkm start
          // if (this.rstDialysisState <= 5) {
          if (this.rstDialysisState <= 5 && scrollRight.length > 0) {
            // mod 12409 治療状況リストから治療記録に遷移しサイドメニューから画面を開きパンくずリストの治療状況リストを押下すると画面遷移せずパンくずリストが消える zkm end
            scrollRight[0].scrollLeft = scrollRight[0].scrollWidth;
          }
        },100)
        //add FNSI-修正 redmine4844 房 end
        // add FNSI-改修内容 monitorグラフ修正 房 end
        //del 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正  赵 end
      },
      // add #10077 by zhangruixue 2024-2-20  start
      /**
       * 全角の数値を半角に変換
       * */
      // del #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
      // convertToHalfWidth(convertToHalfStr){
      //   var parttern = /[０-９ー＋－．]/g;
      //   if(parttern.test(convertToHalfStr)){
      //     convertToHalfStr = convertToHalfStr.replace(parttern, function(match) {
      //       const fullToHalfMap = {
      //         '０': '0', '１': '1', '２': '2', '３': '3', '４': '4',
      //         '５': '5', '６': '6', '７': '7', '８': '8', '９': '9',
      //         '＋': '+', '－': '-', '．': '.', 'ー': '-'
      //       };
      //       return fullToHalfMap[match];
      //     });
      //     return convertToHalfStr;
      //   }else {
      //     return convertToHalfStr;
      //   }
      // },
      // del #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
      // add #10077 by zhangruixue 2024-2-20  end
      /**
       * グラフエリアのリサイズ
       */
      graphResize() {
        this.createChartData();
      }
    },
    watch: {
      value() {
        // gridデータに影響がないように深いコピーを行う
        this.monitorData = this.value
          .filter(e => !e.isNew)
          .map(e => {
            const monitor = new Monitor();
            Object.assign(monitor, e);
            return monitor;
          });
        // 経過時間はオブジェクト{initValue, editValue}のため、monitorDataをDBのデータ形式に変換する
        this.monitorData.forEach(item => {
          item.monitorData = item.convertMonitorDataForDb(item.monitorData, "editValue");
        });
        this.createChartData();
      },
      chartScale() {
        this.createChartData();
      },
      graphDefine() {
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
    beforeDestroy() {
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    },
    destroyed() {
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
</style>
