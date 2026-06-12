<template>
  <div>
    <highcharts ref="highcharts" :options="chartOptions"></highcharts>
  </div>
</template>

<script>
import Highcharts from "@/compat/charts/highcharts";
import { Boost } from "@/compat/charts/highcharts";

export default {
  props: {
    widthComponent: {
      type: Number
    },
    graphDefine: {
      type: Object
    },
    graphSetting: {
      type: Object
    }
  },
  data() {
    return {
      widthParentComponent: 0,
      chartOptions: {
        chart: {
          type: "spline",
          reflow: false
        },

        credits: {
          enabled: false
        },

        title: false,

        subtitle: false,

        yAxis: [
          {
            endOnTick: false,
            maxPadding: 0.02,
            plotLines: [
              {
                value: 0,
                color: "black",
                width: 3
              }
            ]
          },
          {
            title: {
              rotation: 270
            },
            endOnTick: false,
            opposite: true
          }
        ],

        xAxis: {
          type: "linear",
          labels: {
            format: "{value:%H:%M}"
          }
        },

        tooltip: {
          borderColor: "#333333",
          backgroundColor: 'var(--highcharts-background-fill)',
          crosshairs: {
            color: "red",
            width: 1,
            dashStyle: "solid"
          },
          formatter: function() {
            var rV = "";
            if (this.points) {
              this.points.forEach(function(d) {
                var unit = d.series.userOptions.unit;
                rV +=
                  '<span style="color:' +
                  d.color +
                  '">' +
                  d.series.name +
                  ': </span><b style="color:' +
                  d.color +
                  '">' +
                  d.y +
                  unit +
                  "</b><br/>";
              });
            } else {
              rV += this.point.text;
            }
            return rV;
          },
          shared: true
        },

        pane: {
          size: "80%"
        },

        legend: {
          align: "right",
          layout: "vertical",
          borderWidth: 1,
          verticalAlign: "middle"
        },

        plotOptions: {
          series: {
            connectNulls: true,
            cursor: "pointer"
          }
        },
        series: []
      }
    };
  },
  created() {
    Boost(Highcharts);
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  methods: {
    mergeConfig() {
      var dst = {},
        src,
        p,
        args = [].splice.call(arguments, 0);
      while (args.length > 0) {
        src = args.splice(0, 1)[0];
        if (toString.call(src) == "[object Object]") {
          for (p in src) {
            if (Object.prototype.hasOwnProperty.call(src, p)) {
              if (toString.call(src[p]) == "[object Object]") {
                dst[p] = this.mergeConfig(dst[p] || {}, src[p]);
              } else {
                dst[p] = src[p];
              }
            }
          }
        }
      }
      return dst;
    },
    createChartLayout() {
      this.chartOptions = this.mergeConfig(
        this.chartOptions,
        this.graphDefine.setting,
        {
          chart: {
            width: this.widthComponent
          }
        }
      );
      if (this.graphSetting && this.graphSetting.setting) {
        this.chartOptions.yAxis[0] = this.mergeConfig(
          this.chartOptions.yAxis[0],
          this.graphSetting.setting.yAxis[0]
        );
        this.chartOptions.yAxis[1] = this.mergeConfig(
          this.chartOptions.yAxis[1],
          this.graphSetting.setting.yAxis[1]
        );
      }
    },
    createChartReflow() {
      if (this.$refs.highcharts) {
        this.$refs.highcharts.chart.reflow();
      }
    }
  },
  watch: {
    widthComponent() {
      this.createChartLayout();
      this.createChartReflow();
    }
  }
};
</script>