/**
 * グラフ表示コンポーネント
 */
<template>
  <div class="expandable-content">
    <div slot="main" id="graph-component" style="width:100%;">
      <div class="chart-area">
        <highcharts :options="createChartData()"></highcharts>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from "vue";
import { mapGetters } from "vuex";
import VueHighcharts from "vue-highcharts";
import Highcharts from "highcharts";
import Boost from "highcharts/modules/boost";
import highchartsMore from "highcharts/highcharts-more";
import { deepCopy } from "@/functions/common/CommonFunctions";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end

Vue.use(VueHighcharts);
Boost(Highcharts);
highchartsMore(Highcharts);

// グラフデータのテンプレート
const CHART_OPTIONS_TEMPLATE = {
  chart: {
    marginRight: 50,
    marginLeft: 45,
    reflow: true
    // add FNSI-redmine#3962 付 start
    // ,height: '400px'
    // add FNSI-redmine#3962 付 end
  },
  // add FNSI-redmine#4088 付 start
  exporting: {
    enabled: false,
  },
  // add FNSI-redmine#4088 付 end
  time: {
    useUTC: false
  },
  credits: {
    enabled: false
  },
  title: false,
  xAxis: {
    type: "datetime",
    scrollbar: {
        enabled: true
    },
    dateTimeLabelFormats: {
      // don't display the dummy year
      minute: "%Y/%m/%d<br/>%H:%M",
      hour: "%Y/%m/%d<br/>%H:%M",
      day: "%Y<br/>%m/%d",
      week: "%Y<br/>%m/%d",
      month: "%Y/%m",
      year: "%Y"
    }
  },
  yAxis: [
    {
      // 左y軸
      title: false,
      min: 0,
      max: 100,
      alignTicks: false,
      labels: {
        align: "left",
        x: -28,
        style: {
          textOverflow: "none"
        }
      },
      allowDecimals: true,
      // 最上部の目盛りラベルも表示する
      showLastLabel: true
    },
    {
      // 右y軸
      title: false,
      // min: 0,
      // max: 30,
      alignTicks: false,
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
    x: 20,
    y: -5
  },
  plotOptions: {
    // 点の設定
    series: {
      marker: {
        enabled: true // データプロット(●、▲、■)を非表示
      }
    }
  },
  scrollbar: {
    enabled: true
  },
  series: []
};

export default {
  computed: {
    ...mapGetters("trend-graph", [
      "getMonitorDataList",
      "getConditionInfo",
      "getGraphItemList",
      "getSelectedTemplate"
    ]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getSplittedWidth"
    }),
    templateName() {
      if (this.getSelectedTemplate) {
        return this.getSelectedTemplate.templateName;
      }
      return null;
    },
    // -----------------------------------------
    // モニター一覧表示データ取得
    // -----------------------------------------
    getTrendGraphItemList() {
      return this.getGraphItemList;
    }
  },
  methods: {
    /**
     * グラフ用データ生成
     */
    createChartData() {
      let options = this.createChartOption();
      if (this.getSelectedTemplate) {
        const seriesInfoList = this.getSelectedTemplate.seriesInfo;
        const plotStartTime = this.getTimeFromDateStr(
          this.getConditionInfo.startDate,
          false
        );
        const plotEndTime = this.getTimeFromDateStr(
          this.getConditionInfo.endDate,
          true
        );
        const monitorItemList = this.getMonitorDataList;
        const seriesArr = [];
        // 範囲用最小・最大日付
        let plotMinTime = plotStartTime;
        let plotMaxTime = plotEndTime;
        for (const seriesInfo of seriesInfoList) {
          let series = {
            id: `data${seriesInfo.moni_cd}`,
            // 凡例名
            name: seriesInfo.moni_name,
            // 左右軸
            yAxis: seriesInfo.axis_direction,
            // シリーズ線の色
            color: seriesInfo.line_color,
            type: "line",
            // プロットデータ
            data: []
          };
          if (plotStartTime) {
            series.data.push([plotStartTime, null]);
          }
          // NOTE: プロットデータを array.filter().map()を使って構築しようとしたらpromiseが返ってきたのでループ
          const cd = String(seriesInfo.moni_cd);
          for (let monitorItem of monitorItemList) {
            const elem = monitorItem.monitorData;
            // mod #8115 2022/11/23 透析液調製装置トレンドグラフが表示しない dou start
            // if (elem[cd] !== undefined && elem[cd] !== null) {
            if (!!elem && elem[cd] !== undefined && elem[cd] !== null) {
            // mod #8115 2022/11/23 透析液調製装置トレンドグラフが表示しない dou end
              const baseDateTime = new Date(monitorItem.occurDate).getTime();
              series.data.push([baseDateTime, +elem[cd]]);

              if (plotMinTime === null || plotMinTime > baseDateTime) {
                plotMinTime = baseDateTime;
              }
              if (plotMaxTime === null || plotMaxTime < baseDateTime) {
                plotMaxTime = baseDateTime;
              }
            }
          }
          if (plotEndTime) {
            series.data.push([plotEndTime, null]);
          }
          seriesArr.push(series);
        }
        for (const seriesInfo of seriesInfoList) {
          if (seriesInfo.is_show_target_line === "1") {
            let targetSeries = {
              id: `target${seriesInfo.moni_cd}`,
              // 凡例名
              name: `${seriesInfo.moni_name} 目標値`,
              // 左右軸
              yAxis: seriesInfo.axis_direction,
              // シリーズ線の色
              color: seriesInfo.line_color,
              type: "line",
              lineWidth: 2,
              marker: {
                enabled: false
              },
              // プロットデータ
              data: [
                [plotMinTime, Number(seriesInfo.target_value)],
                [plotMaxTime, Number(seriesInfo.target_value)]
              ]
            };
            let rangeSeries = {
              id: `range${seriesInfo.moni_cd}`,
              // 凡例名
              name: `${seriesInfo.moni_name} 上下限範囲`,
              // 左右軸
              yAxis: seriesInfo.axis_direction,
              // シリーズ線の色
              color: seriesInfo.line_color,
              type: "arearange",
              lineWidth: 0,
              fillOpacity: 0.3,
              marker: {
                enabled: false
              },
              // プロットデータ
              data: [
                [
                  plotMinTime,
                  Number(seriesInfo.lower_value),
                  Number(seriesInfo.upper_value)
                ],
                [
                  plotMaxTime,
                  Number(seriesInfo.lower_value),
                  Number(seriesInfo.upper_value)
                ]
              ]
            };
            seriesArr.push(targetSeries);
            seriesArr.push(rangeSeries);
          }
        }

        options.series = seriesArr;
      }
      return options;
    },
    createChartOption() {
      // -----------------------------
      // 構成材料の用意
      // -----------------------------
      const options = deepCopy(CHART_OPTIONS_TEMPLATE);
      if (this.getSelectedTemplate) {
        const verticalRange = {
          right: {
            max: this.getSelectedTemplate.verticalRangeRightMax,
            min: this.getSelectedTemplate.verticalRangeRightMin
          },
          left: {
            max: this.getSelectedTemplate.verticalRangeLeftMax,
            min: this.getSelectedTemplate.verticalRangeLeftMin
          }
        };
        // optionの構成
        options.yAxis[0].max = verticalRange.left.max;
        options.yAxis[0].min = verticalRange.left.min;
        options.yAxis[1].max = verticalRange.right.max;
        options.yAxis[1].min = verticalRange.right.min;
      }
      return options;
    },
    /**
     * YYYY-MM-DD 形式の文字列から Date.getTimeを取得
     */
    getTimeFromDateStr(dateStr, isEndDate) {
      let r = null;
      try {
        if (dateStr) {
          let d = null;
          const parts = dateStr.split("-");
          if (isEndDate) {
            d = new Date(parts[0], parts[1] - 1, parts[2], 23, 59, 59, 999);
          } else {
            d = new Date(parts[0], parts[1] - 1, parts[2]);
          }
          r = d.getTime();
        }
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('TrendGraphComponent.vue','getTimeFromDateStr',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        console.error(error);
        r = null;
      }
      return r;
    }
  },
  destroyed() {
    // グラフデータをクリア
  }
};
</script>

<style scoped>
.template-name {
  margin-left: 15px;
  font-size: 1.5em;
  color: var(--ntss-base-color);
}
.chart-area {
  width: 100%;
  margin: auto;
  min-width: 900px;
}
#graph-component {
  overflow-x: auto;
}
</style>
