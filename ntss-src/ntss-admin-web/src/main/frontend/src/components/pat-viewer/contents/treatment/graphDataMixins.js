import moment from "moment";
export default {
  methods: {
    caculatePlotLines () {
      let plotLines = [];
      function buildArr (period, step) {
        const base = parseInt(period);
        let arr = [];
        for (let index = 1; index < base; index++) {
          let value = {
            color: '#cccccc',
            width: 1,
            value: index * step
          }
          arr.push(value);
        }
        return arr;
      }
      switch (this.displayPeriod) {
        case '4': // 12周
          plotLines = buildArr('12', 7);
          break;
        case '5': // 6个月
          plotLines = buildArr('6', 31);
          break;
        case '6': // 1年
          plotLines = buildArr('12', 31);
          break;
        case '7': // 3年
          plotLines = buildArr('3', 372);
          break;
      }
      return plotLines;
    },
    caculateTickPositions () {
      function isValidDate(dateStr) {
        return moment(dateStr, 'YYYYMMDD', true).isValid();
      }
      let step;
      switch (this.displayPeriod) {
        case '4': // 12周
          step = 7;
          break;
        case '5': // 6个月
          step = 31;
          break;
        case '6': // 1年
          step = 31;
          break;
        case '7': // 3年
          step = 372;
          break;
      }
      const tickPositions = [];
      this.chartOptions.xAxis.categories.forEach((item, index) => {
        if (index % step === 0) {
          tickPositions.push(index);
        }
      });
      const lastIndex = _.findLastIndex(this.chartOptions.xAxis.categories, isValidDate);
      tickPositions.push(lastIndex);
      return tickPositions;
    },
  }
};
