/** * 患者カレンダー用バイタル・モニタグラフ */

<template>
  <div class="pat-calendar-chart">
    <highcharts :options="chartOptions" :ref="dispDataItem" />
  </div>
</template>

<script>
import { Chart } from "@/compat/charts/highcharts";
import Highcharts from "@/compat/charts/highcharts";
import { Boost } from "@/compat/charts/highcharts";
import dayjs from "@/compat/date/dayjs";
import { mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import graphDataMixins from "@/components/pat-viewer/contents/treatment/graphDataMixins";

/** 改修前（図1）相当のコンパクトレイアウト */
const PAT_CALENDAR_CHART_HEIGHT = 150;
const PAT_CALENDAR_CHART_MARGIN = [0, -1, 20, 0];
const PAT_CALENDAR_X_LABELS_Y = 12;

Boost(Highcharts);

Highcharts.setOptions({
  lang: {
    shortWeekdays: ["日", "月", "火", "水", "木", "金", "土"],
    shortMonths: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
  },
  global: {
    useUTC: false
  },
  accessibility: {
    enabled: false
  }
});

export default {
  components: {
    highcharts: Chart
  },
  mixins: [graphDataMixins],

  data() {
    return {
      isMounted: false,
      chartOptions: {
        chart: {
          height: PAT_CALENDAR_CHART_HEIGHT,
          margin: [...PAT_CALENDAR_CHART_MARGIN],
          spacingTop: 0,
          spacingBottom: 0,
          spacingLeft: 0,
          spacingRight: 0,
          events: {
            load() {
              setTimeout(() => {
                this.reflow();
                EventBus.$emit("reflowPatViewerCharts", this);
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
          title: {
            enabled: false
          },
          type: "datetime",
          tickLength: 3,
          gridLineWidth: 1,
          labels: {
            enabled: true,
            y: PAT_CALENDAR_X_LABELS_Y,
            autoRotation: false,
            style: {
              fontSize: "10px"
            },
            formatter() {
              return dayjs(this.value).format("HH:mm");
            }
          }
        },
        yAxis: [],
        legend: {
          enabled: false
        },
        navigation: {
          buttonOptions: {
            enabled: false
          }
        },
        series: [],
        tooltip: {
          xDateFormat: "%Y年%b月%e(%a) %H:%M",
          hideDelay: 100,
          snap: 0,
          useHTML: true
        }
      }
    };
  },
  props: {
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
    xAxisMin: {
      type: Number,
      default: undefined
    },
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
    })
  },

  created() {
    this.init();
  },

  mounted() {
    this.isMounted = true;
    this.$nextTick(() => {
      this.applyCalendarChartLayout();
      this.resizeChart();
    });
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
      this.chartOptions.xAxis.min = this.xAxisMin;
      this.chartOptions.xAxis.max = this.xAxisMax;
      this.chartOptions.yAxis = this.buildYAxisWithGrid(this.yAxis);
      const tickPositions = this.tickPositioner();
      this.chartOptions.xAxis.tickPositions = tickPositions;
      this.chartOptions.series = this.seriesData();
    },
    applyCalendarChartLayout() {
      const chart = this.$refs[this.dispDataItem]?.chart;
      if (!chart) {
        return;
      }
      chart.update(
        {
          chart: {
            height: PAT_CALENDAR_CHART_HEIGHT,
            margin: [...PAT_CALENDAR_CHART_MARGIN],
            spacingTop: 0,
            spacingBottom: 0,
            spacingLeft: 0,
            spacingRight: 0
          }
        },
        false
      );
      const tickPositions = this.chartOptions.xAxis.tickPositions;
      this.syncPatViewerChartAxis(chart, {
        tickPositions,
        breaks: [],
        plotLines: [],
        isDatetime: true,
        xAxisMin: this.xAxisMin,
        xAxisMax: this.xAxisMax
      });
      chart.reflow();
    },
    resizeChart() {
      const chart = this.$refs[this.dispDataItem]?.chart;
      if (!chart) {
        return;
      }
      this.applyCalendarChartLayout();
    },
    seriesData() {
      const seriesArr = [];
      const legendIdArr = [];
      const seriesColors = {};

      this.chartData.forEach(item => {
        const isLegendIdExists = legendIdArr.includes(item.name);

        if (!isLegendIdExists) {
          seriesColors[item.name] = item.color;
          legendIdArr.push(item.name);
        }

        seriesArr.push({
          id: isLegendIdExists ? undefined : item.no,
          name: item.name,
          yAxis: item.yAxis,
          linkedTo: isLegendIdExists ? item.name : undefined,
          color: seriesColors[item.name],
          data: (item.data || []).map(i => {
            const x = dayjs(i[1]).valueOf();
            const y = i[2];
            return [x, y];
          }),
          marker: item.marker ? item.marker : {},
          animation: false
        });
      });

      return seriesArr.length === 0 ? [{ showInLegend: false, data: [] }] : seriesArr;
    },
    tickPositioner() {
      if (
        this.xAxisMin == null ||
        this.xAxisMax == null ||
        !Number.isFinite(this.xAxisMin) ||
        !Number.isFinite(this.xAxisMax)
      ) {
        return undefined;
      }
      const tickAmount = 3;
      const ticks = [];
      for (let i = 1; i < tickAmount; i++) {
        const val = this.xAxisMin + ((this.xAxisMax - this.xAxisMin) / tickAmount) * i;
        ticks.push(val);
      }
      return [this.xAxisMin, ...ticks, this.xAxisMax];
    }
  }
};
</script>

<style scoped>
.pat-calendar-chart {
  width: 100%;
  overflow: hidden;
  line-height: 0;
}
.pat-calendar-chart :deep(.highcharts-container) {
  margin: 0 !important;
}
</style>
