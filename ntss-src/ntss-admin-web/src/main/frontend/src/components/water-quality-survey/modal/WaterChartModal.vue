<template>
  <!--mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start-->
  <!-- <modal-base @onClose="close"> -->
  <modal-base @onClose="close">
  <!--mod FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end-->
    <div slot="body" id="water-chart" class="water-chart">
      <!-- mod FNSI-redmine4008 徐 start -->
      <!-- <highcharts :options="chartOptions" ref="waterChart" /> -->
      <div id= "legend-btn" class="header-icon ion-ios-menu" style="font-size: 30px !important;" @click="legendEnableChanged()"></div>
      <highcharts :options="chartOptions" ref="waterChart" style="min-width: 800px; min-height: 480px;"/>
      <!-- mod FNSI-redmine4008 徐 end -->
    </div>
    <!-- add FNSI-水質管理経過グラフにボタンを追加する。 周 start -->
    <!-- フッター -->
    <div slot="footer" class="flex-container flex-container-footer" style="margin: 0 10px 0 10px;">
      <!-- mod FNSI-改修内容IES205 姜 start -->
      <div class="registration-btn-area" style="background:none">
        <button
          class="button btn2-cancel"
          @click="close"
        >閉じる</button>
      </div>
      <!-- 閾値 -->
      <div style="flex: auto; background: none;">
        <ul id="selectLineUl">
          <span class="select-line-span">
            閾値表示
          </span>
          <span class="select-line-span" v-for="(item,i) in selfChartOption.seriesdisplay" :key="item.id">
            <v-ons-checkbox  v-model="selectLineArray.que" :value="i"></v-ons-checkbox>{{item.name}}
          </span>
        </ul>
      </div>
      <div style="background:none">
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button
          class="button
          registration-btn"
          @click="previewFile"
        >プレビュー</button> -->
        <button
          class="button
          registration-btn btn3-normal button-preview"
          @click="previewFile"
        >プレビュー</button>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
        &nbsp;&nbsp;
        <!-- mod 画面スタイル(ボタン)対応 徐 start -->
        <!-- <button
          class="button registration-btn"
          @click="printFile"
        >印刷</button> -->
        <button
          class="button registration-btn btn3-normal"
          @click="printFile"
        >印刷</button>
        <!-- mod 画面スタイル(ボタン)対応 徐 end -->
      <!-- mod FNSI-改修内容IES205 姜 end -->
      </div>
    </div>
    <!-- add FNSI-水質管理経過グラフにボタンを追加する。 周 end -->
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { Chart } from "highcharts-vue";
import Highcharts from "highcharts";
import moment from "moment";
import { mapActions, mapGetters } from "vuex";
import Boost from "highcharts/modules/boost";
//add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start
const THEME_BLACK = 1;
//add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end
// add FNSI-水質管理経過グラフにボタンを追加する。 周 start
import exportingInit from 'highcharts/modules/exporting';
import BigNumber from "bignumber.js";
exportingInit(Highcharts);
// add FNSI-水質管理経過グラフにボタンを追加する。 周 end
Boost(Highcharts);

Highcharts.setOptions({
  // add FNSI-水質管理曲綫調整 関 start
  colors: ['#4572A7', '#AA4643', '#89A54E', '#80699B', '#3D96AE', '#DB843D', '#92A8CD', '#A47D7C', '#B5CA92'],
  // add FNSI-水質管理曲綫調整 関 end
  lang: {
    shortWeekdays: ["日", "月", "火", "水", "木", "金", "土"],
    shortMonths: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
    //add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start
    resetZoom:"ズーム初期化",
    //add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end
    // add FNSI-水質管理経過グラフにボタンを追加する。 周 start
    resetZoomTitle: 'ズーム初期化 レベル 1:1',
    // add FNSI-水質管理経過グラフにボタンを追加する。 周 end
  },
  global: {
    useUTC: false
  }
});

export default {
  components: {
    "modal-base": ModalBase,
    highcharts: Chart
  },

  data() {
    return {
      // add FNSI-閾値直線表示 関 start
      selectLine : -1,
      // add FNSI-水質管理曲綫調整 関 start
      selectLineArray: {
        que:[]
      },
      selfChartOption: [],
      defaultColors: ['#4572A7', '#AA4643', '#89A54E', '#80699B', '#3D96AE', '#DB843D', '#92A8CD', '#A47D7C', '#B5CA92'],
      // add FNSI-水質管理曲綫調整 関 end
      // add FNSI-閾値直線表示 関 end
      chartData: [],
      arrType: [],
      minHeight: 480,
      chartHeight: null,
      legendEnabled: false,
      legendMaxHeight: 0,
      legendPoint: 0
    };
  },

  computed: {
    ...mapGetters("water-quality-survey/list", [
      "getChartData",
      "mstSurveyType"
    ]),
    ...mapGetters("water-quality-survey/chart", ["getRangeDate"]),
    //add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start
    ...mapGetters("account-edit", ["getTheme","getFontSize"]),
    //add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end
    ...mapGetters("window-size", {
      windowWidth: "getWindowWidth",
      windowHeight: "getWindowHeight"
    }),
    chartOptions() {
      return {
        chart: {
          zoomType: "x",
          panning: true,
          panKey: "shift",
          zoomKey: "ctrl",
          //mod FNSI-閾値直線表示 関 start
          // height: "730px",
          height: this.chartHeight,
          marginTop: 14,
          //mod FNSI-閾値直線表示 関 end
          // add FNSI-水質管理経過グラフにボタンを追加する。 周 start
          events: {
            beforePrint: function () {

            },
            afterPrint: function (e) {
              // 印刷領域の最大幅を設定する
              // 印刷領域の最大幅「初期値：780」
              e.target.options.exporting.printMaxWidth = 780;
            }
          },
          // add FNSI-水質管理経過グラフにボタンを追加する。 周 end
          marginRight: 18,
          spacingBottom: 0
        },
        // add FNSI-水質管理経過グラフにボタンを追加する。 周 start
        navigation: {
          buttonOptions: {
            enabled: false
          }
        },
        // add FNSI-水質管理経過グラフにボタンを追加する。 周 end
        title: {
          text: ""
        },
        xAxis: [
          {
            min: moment(this.getRangeDate[0])
              .subtract(1, "days")
              .valueOf(),
            max: moment(this.getRangeDate[1])
              .add(1, "days")
              .valueOf(),
            gridLineWidth: "0",
            margin: "5",
            title: {
              enabled: false
            },
            type: "datetime",
            labels: {
              formatter: function() {
                // mod FNSI-redmine3770 徐 start
                // return moment(this.value).format("YYYY/MM/DD");
                return moment(this.value).format("YYYY<br>MM/DD");
                // mod FNSI-redmine3770 徐 end
              }
              //add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start
              ,style:{
                color: this.getTheme===THEME_BLACK ? "white" : "black",
                fontSize: "11px"
              },
              //add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end
            }
          }
        ],
        yAxis: this.yAxisData(this.chartData),
        credits: {
          enabled: false
        },
        legend: {
          backgroundColor: "rgba(255, 255, 255, 0.75)",
          floating: true,
          layout: "vertical",
          align: "left",
          verticalAlign: "middle",
          x: this.legendPoint,
          enabled: this.legendEnabled,
          y: -100,
          shadow: true,
          maxHeight: this.legendMaxHeight,
          overflow: "auto",
          padding: 5,
          itemMarginTop: 0,
          itemMarginBottom: 0,
          itemStyle: {
            fontSize: "1em !important"
          }
        },
        tooltip: {
          xDateFormat: "%Y年%b月%e(%a)",
          hideDelay: 100,
          snap: 0,
          pointFormatter: function () {
            // 指数表記を回避して文字列にする
            const decimalDigits = this.series.userOptions.decimalDigits;
            const valueStr = new BigNumber(this.y).toFixed(decimalDigits);
            // Highchartsのデフォルト書式に寄せつつyだけ差し替え
            return `<span style="color:${this.color}">\u25CF</span> 
                    ${this.series.name}: <b>${valueStr}</b><br/>`;
          }
        },
        series: this.setSeriesData(),
        // add FutreNetWeb+SI課題管理No6319 趙 start
        seriesdisplay: this.setSeriesDatadisplay()
        // add FutreNetWeb+SI課題管理No6319 趙 end
      };
    }
  },

  methods: {
    ...mapActions("multi-modal", ["hideModal"]),

    close() {
      this.hideModal();
    },
    // 凡例の表示・非表示
    legendEnableChanged() {
      // 凡例表示済の場合
      if (this.$refs.waterChart.chart.legend.display != null) {
        this.legendEnabled = false;
      } else {
        this.legendEnabled = true;
      }
    },
    // add FNSI-水質管理経過グラフにボタンを追加する。 周 start
    async previewFile() {
      // modify start 馬 #10362
      const chart = this.$refs.waterChart.chart;
      const exportUrl = chart.options.exporting.url;
      const exportOptions = {
        type: 'application/pdf',
        filename: '水質管理経過グラフ'
      };
      const exportForm = document.createElement('form');
      exportForm.action = exportUrl;
      exportForm.method = 'post';
      exportForm.target = '_blank';

      for (const key in exportOptions) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = key;
        input.value = exportOptions[key];
        exportForm.appendChild(input);
      }

      const svg = chart.getSVG();
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = 'svg';
      input.value = svg;
      exportForm.appendChild(input);

      document.body.appendChild(exportForm);
      exportForm.submit();
      document.body.removeChild(exportForm);
      // this.$refs.waterChart.chart.exportChart({
      //     type: 'application/pdf',
      //     filename: '水質管理経過グラフ'
      // });
      // modify end 馬 #10362
    },

    async printFile() {
      // 印刷領域の最大幅を設定する
      // 「beforePrint」 実行時点は正しくない
      // チャートの幅 * スケール「初期値：2」
      this.$refs.waterChart.chart.options.exporting.printMaxWidth = this.$refs.waterChart.chart.chartWidth * this.$refs.waterChart.chart.options.exporting.scale;

      this.$refs.waterChart.chart.print();
    },
    // add FNSI-水質管理経過グラフにボタンを追加する。 周 end

    setSeriesData() {
      const seriesArr = [];
      // del FutreNetWeb+SI課題管理No6319 趙 start
      // add FNSI-改修内容6319修正 xuty start
      // const nameConst = [];
      // add FNSI-改修内容6319修正 xuty end
      // del FutreNetWeb+SI課題管理No6319 趙 end

      this.chartData.forEach((item, index) => {
        const series = {
          type: "line",
          yAxis: this.arrType.findIndex(i => i === item.surveyTypeCd),
          id: index,
          // mod FutreNetWeb+SI課題管理No6319 趙 start
          // add FNSI-改修内容6319修正 xuty start
          name: `${item.pointName}(${item.surveyTypeName})`,
          // name: `${item.surveyTypeName}`,
          // add FNSI-改修内容6319修正 xuty end
          // mod FutreNetWeb+SI課題管理No6319 趙 end
          data: item.surveyData.map(i => {
            const x = moment(i.inspectionDate).valueOf();
            // #11047 数値IF修正 mod by Z.T. start
            // let y = i.value;
            let y = Number(i.value);
            // #11047 数値IF修正 mod by Z.T. End
            return [x, y];
          }),
          decimalDigits: this.mstSurveyType.find(t => t.surveyTypeCd === item.surveyTypeCd).decimalDigits
        };
        // mod FutreNetWeb+SI課題管理No6319 趙 start
        // mod FNSI-改修内容6319修正 xuty start
        seriesArr.push(series);
        // if (nameConst.indexOf(series.name) < 0) {
        //   seriesArr.push(series);
        //   nameConst.push(series.name)
        // }
        // mod FNSI-改修内容6319修正 xuty end
        // mod FutreNetWeb+SI課題管理No6319 趙 end
      });
      return seriesArr[0] === undefined ? [{ showInLegend: false }] : seriesArr;
    },
    // add FutreNetWeb+SI課題管理No6319 趙 start
    setSeriesDatadisplay() {
      const seriesArr = [];
      this.chartData.forEach((item, index) => {
        const series = {
          type: "line",
          yAxis: this.arrType.findIndex(i => i === item.surveyTypeCd),
          id: index,
          surveytypecd: `${item.surveyTypeCd}`,
          name: `${item.surveyTypeName}`,
          data: item.surveyData.map(i => {
            const x = moment(i.inspectionDate).valueOf();
            let y = i.value;
            return [x, y];
          })
        };
        seriesArr.push(series);
      });
      var obj = {}
      const seriesArr1 = seriesArr.reduce((acc, cur) => {
        obj[cur.surveytypecd] ? "" : obj[cur.surveytypecd] = true && acc.push(cur);
        return acc;
      }, []);
      return seriesArr1[0] === undefined ? [{ showInLegend: false }] : seriesArr1;
    },
    // add FutreNetWeb+SI課題管理No6319 趙 end

    sortInspectionDate(item) {
      item.surveyData.sort((a, b) => {
        const dateA = moment(a.inspectionDate);
        const dateB = moment(b.inspectionDate);
        return dateA.diff(dateB);
      });
      item.surveyData = item.surveyData.filter(val => {
        // 結果値に数字データが入っていない場合はプロットしない
        if (val.value === "") {
          return false;
        }
        return true;
      });

      return item;
    },

    yAxisData(chartData) {
      if (chartData.length === 0) {
        return [];
      }

      chartData.forEach(d => {
        this.arrType.push(d.surveyTypeCd);
      });

      const formatValue = {
        labels: {},
        title: {
          text: ""
        },
        startOnTick: false,
        lineWidth: "0",
        gridLineWidth: "0"
      };
      // mod FNSI-閾値直線表示 関 start
      // const yAxisValue = [];
      var yAxisValue = [];
      // mod FNSI-閾値直線表示 関 end
      this.arrType.forEach((cd, index) => {
        // add FNSI-バグ 水質管理267 徐 start
        var decimalDigits = this.mstSurveyType.find(t => t.surveyTypeCd === cd).decimalDigits;
        // add FNSI-バグ 水質管理267 徐 end
        const yAxisMin = this.yAxisRange(cd)[0];
        const yAxisMax = this.yAxisRange(cd)[1];
        //add FNSI-閾値直線表示 関 start
        const yPlotLineMin = this.yPlotLineFind(cd)[0];
        const yPlotLineMax = this.yPlotLineFind(cd)[1];
        formatValue.PlotLineMin = yPlotLineMin;
        formatValue.PlotLineMax = yPlotLineMax;
        //add FNSI-閾値直線表示 関 end
        formatValue.min = yAxisMin;
        formatValue.max = yAxisMax;
        formatValue.tickPositions = this.computeTickPositions(
          6,
          yAxisMin,
          yAxisMax
        );
        if (yAxisMin === undefined || yAxisMax === undefined) {
          formatValue.startOnTick = true;
          formatValue.tickPositions = undefined;
        }
        const titleObj = {
          text: this.getTypeTextByCd(cd),
          style: {
            color: Highcharts.getOptions().colors[index],
            fontSize: "11px"
          }
        };
        const labelObj = {
          // add FNSI-バグ 水質管理267 徐 start
          formatter: function () {
            return this.value.toFixed(decimalDigits);
          },
          // add FNSI-バグ 水質管理267 徐 end
          enabled: true,
          style: {
            color: Highcharts.getOptions().colors[index]
              //add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 start
            ,fontSize: "11px"
              //add FNSI-改修内容「水質管理の表示」を「修正」に変更 江 end
          }
        };
        formatValue.title = titleObj;
        formatValue.labels = labelObj;
        // mod FNSI-水質管理曲綫調整 関 start
        // yAxisValue.push({ ...formatValue });
        if (index < this.chartData.length) {
          yAxisValue.push({ ...formatValue });
        }
        // mod FNSI-水質管理曲綫調整 関 end
      });
      if (yAxisValue && yAxisValue.length) {
        delete yAxisValue[0].gridLineWidth;
      }
      //add FNSI-閾値直線表示 関 start
      var yResultAxisValue = [];
      // add FNSI-水質管理曲綫調整 関 start
      var yPush = [];
      // add FNSI-水質管理曲綫調整 関 end
      yAxisValue.forEach((everyLine , index) => {
        // mod FNSI-水質管理曲綫調整 関 start
        var plotSelect = false;
        var color = '#FF0000';
        this.selectLineArray.que.forEach(everySelectLine => {
          if (this.selfChartOption.series[everySelectLine].yAxis == index) {
            plotSelect = true;
            color = this.defaultColors[everySelectLine%9];
          }
        });
        // if (index == this.selectLine) {
        // mod FNSI-水質管理曲綫調整 関 end
        if (plotSelect) {
          everyLine.plotLines = [
            {
              // mod FNSI-水質管理曲綫調整 関 start
              // color: '#FF0000',
              color: color,
              dashStyle:'ShortDot',
              // mod FNSI-水質管理曲綫調整 関 end
              width: 2,
              value: everyLine.PlotLineMin
            },
            {
              // mod FNSI-水質管理曲綫調整 関 start
              // color: '#FF0000',
              color: color,
              dashStyle:'ShortDot',
              // mod FNSI-水質管理曲綫調整 関 end
              width: 2,
              value: everyLine.PlotLineMax
            }
          ];
        }
        else {
          everyLine.plotLines = [];
        }
        // mod FNSI-水質管理曲綫調整 関 start
        // if (index < this.chartData.length) {
          // yResultAxisValue.push(everyLine);
          everyLine.labels.style.color = "black";
          everyLine.title.style.color = "black";
          if (yPush[everyLine.title.text] == undefined) {
            yPush[everyLine.title.text] = true;
          }
          else {
            everyLine.visible = false;
          }
          yResultAxisValue[index] = everyLine;
        // }
        // mod FNSI-水質管理曲綫調整 関 end
      });
      yAxisValue = yResultAxisValue;
      //add FNSI-閾値直線表示 関 end
      return yAxisValue;
    },

    yAxisRange(cd) {
      let filterItem = this.mstSurveyType.find(t => t.surveyTypeCd === cd);
      if (filterItem) {
        const lowerLimit =
          filterItem.graphLowerLimit === null
            ? undefined
            : filterItem.graphLowerLimit;
        const upperLimit =
          filterItem.graphUpperLimit === null
            ? undefined
            : filterItem.graphUpperLimit;
        let a = [lowerLimit, upperLimit];
        return a;
      }
      return [undefined, undefined];
    },
    //add FNSI-閾値直線表示 関 start
    yPlotLineFind(cd) {
      let filterItem = this.mstSurveyType.find(t => t.surveyTypeCd === cd);
      if (filterItem) {
        const lowerPlotLine =
          filterItem.lowerThreshold === null
            ? undefined
            : filterItem.lowerThreshold;
        const upperPlotLine =
          filterItem.upperThreshold === null
            ? undefined
            : filterItem.upperThreshold;
        let a = [lowerPlotLine, upperPlotLine];
        return a;
      }
      return [undefined, undefined];
    },
    //add FNSI-閾値直線表示 関 end
    getTypeTextByCd(cd) {
      let filterItem = this.mstSurveyType.find(t => t.surveyTypeCd === cd);
      if (filterItem) {
        return filterItem.surveyTypeName;
      }
      return "";
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
        min = parseFloat(min.toFixed(10)); //toFixedは浮動小数点の対策
        resArr.push(min);
      }
      return resArr;
    },
    // 水質管理の再描画
    resizeWaterChart() {
      // スクロールボディ
      const scrollWrapper = document.getElementById("scrollbody");
      // グラフ
      const graphWrapper = document.querySelector("rect.highcharts-background");
      // 凡例項目最大幅
      const maxItemWidth = this.$refs.waterChart.chart.legend.maxItemWidth;
      // チャート高さ
      scrollWrapper.style.height = "calc(100% - 70px - 2.4em)";
      this.chartHeight = this.getChartHeight(scrollWrapper.clientHeight);
      // 凡例高
      this.legendMaxHeight = this.$refs.waterChart.chart.legend.itemHeight * 11;
      // 凡例位置
      this.legendPoint = Number(graphWrapper.width.baseVal.value) - (maxItemWidth + 45);
      // 凡例ボタン位置
      const legendButtonPositon = Number(graphWrapper.width.baseVal.value) - 50;
      document.getElementById("legend-btn").style.marginLeft = String(legendButtonPositon) + "px";
      // 再描画
      this.$refs.waterChart.chart.reflow();
    },
    // チャート高さの取得
    getChartHeight(clientHeight) {
      // チャート高さ
      const val = clientHeight - 5;
      // チャート高さの取得
      const chartHeight = val > this.minHeight ? val + "px;" : this.minHeight + "px;";
      // チャート高さ
      return chartHeight;
    }
  },

  created() {
    this.chartData = JSON.parse(JSON.stringify(this.getChartData));
    this.chartData.map(item => {
      return this.sortInspectionDate(item);
    });
    this.selfChartOption = this.chartOptions;
  },

  watch: {
    windowWidth() {
      this.$nextTick(() => {
        this.resizeWaterChart();
      });
    },
    windowHeight() {
      this.$nextTick(() => {
        this.resizeWaterChart();
      });
    },
    getFontSize() {
      this.$nextTick(() => {
        this.resizeWaterChart();
      });
    },
    chartOptions() {
      this.$nextTick(() => {
        this.resizeWaterChart();
      });
    }
  }
};
</script>

<style>
@media print {
  /** グラフ */
  body:has(#water-chart) .highcharts-container {
    width: auto !important;
    height: auto !important;
  }
  
  body:has(#water-chart) .highcharts-root {
    width: 100%;
    height: 100%;
  }
}
</style>

<style scoped>
/* mod FNSI-redmine4008 徐 start */
/*#water-chart {
  height: 100%;
};*/
#water-chart {
  height: 92%;
};
/* mod FNSI-redmine4008 徐 end */
::v-deep .highcharts-x-axis .highcharts-grid-line {
  stroke: unset;
}
::v-deep .highcharts-legend-item text {
  fill: #333333 !important;
}
/* add #11332 【たくしん会】自己診断判定マスタ詳細の対象機種範囲バージョンの追加IFの表示が不正 linjunfeng start */
.select-line-span {
  padding: 10px;
}
.header-icon {
  position: absolute;
  z-index: 1;
  margin-top: 20px;
  margin-left: 0px;
  width: 30px;
  height: 30px;
  background-color: var(--ntss-base-background-color);
  text-align: center;
  line-height: 30px;
  opacity: 0.2;
}
/* add #11332 【たくしん会】自己診断判定マスタ詳細の対象機種範囲バージョンの追加IFの表示が不正 linjunfeng end */

@media print {
  .modal-mask >>> .modal-wrapper {
    display: inline-block !important;
  }
  
  /* プレビューボタン消す */
  .button-preview {
    display: none
  }
}
</style>

