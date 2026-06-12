import dayjs from "@/compat/date/dayjs";
import _ from "@/compat/collections/lodash";

const PAT_VIEWER_CHART_BOTTOM_MARGIN = 16;
const PAT_VIEWER_X_LABELS_Y = 12;

const sortBreaks = breaks =>
  [...(breaks || [])].sort((a, b) => a.from - b.from);

const isTimestampInBreak = (timestamp, breaks) =>
  sortBreaks(breaks).some(brk => timestamp >= brk.from && timestamp < brk.to);

const getVisibleTimeIntervals = (min, max, breaks) => {
  const sortedBreaks = sortBreaks(breaks);
  const intervals = [];
  let cursor = min;
  sortedBreaks.forEach(brk => {
    if (brk.from > cursor) {
      intervals.push({ start: cursor, end: Math.min(brk.from, max) });
    }
    cursor = Math.max(cursor, brk.to);
  });
  if (cursor < max) {
    intervals.push({ start: cursor, end: max });
  }
  return intervals.filter(interval => interval.end > interval.start);
};

/** 列内の時刻目盛り（表示期間 1=3日 / 2=7日 / 3=14日） */
const PAT_VIEWER_COLUMN_TICK_HOURS = {
  1: [0, 6, 12, 18],
  2: [0, 8, 16],
  3: [0, 12]
};

const getPatViewerColumnTickHours = displayPeriod => {
  const period = Number(displayPeriod);
  return PAT_VIEWER_COLUMN_TICK_HOURS[period] || PAT_VIEWER_COLUMN_TICK_HOURS[1];
};

const columnXFromDayHour = (dayIndex, hour) => dayIndex + hour / 24;

const formatPatViewerColumnAxisTickLabel = value => {
  const dayIndex = Math.floor(value);
  const fraction = value - dayIndex;
  if (fraction < 0 || fraction > 1) {
    return "";
  }
  const hour = Math.round(fraction * 24) % 24;
  return `${String(hour).padStart(2, "0")}:00`;
};

const timestampAtVisibleOffset = (min, max, breaks, offset) => {
  const intervals = getVisibleTimeIntervals(min, max, breaks);
  const totalVisible = intervals.reduce(
    (sum, interval) => sum + (interval.end - interval.start),
    0
  );
  if (totalVisible <= 0) {
    return null;
  }
  let remaining = offset;
  for (const interval of intervals) {
    const length = interval.end - interval.start;
    if (remaining <= length) {
      return interval.start + remaining;
    }
    remaining -= length;
  }
  return max;
};

export default {
  methods: {
    applyPatViewerChartBottomLayout(chartOptions) {
      if (!chartOptions) {
        return;
      }
      chartOptions.chart = chartOptions.chart || {};
      chartOptions.chart.margin = [0, -1, PAT_VIEWER_CHART_BOTTOM_MARGIN, 0];
      chartOptions.chart.spacingBottom = 0;
      if (!chartOptions.xAxis) {
        return;
      }
      chartOptions.xAxis.tickLength = chartOptions.xAxis.tickLength ?? 3;
      chartOptions.xAxis.gridLineWidth = 1;
      chartOptions.xAxis.labels = {
        ...(chartOptions.xAxis.labels || {}),
        y: PAT_VIEWER_X_LABELS_Y
      };
    },
    buildYAxisWithGrid(yAxisArray) {
      if (!yAxisArray?.length) {
        return yAxisArray;
      }
      return yAxisArray.map(axis => {
        const next = {
          ...axis,
          gridLineWidth: 1,
          gridLineColor: "#e6e6e6"
        };
        if (typeof axis.tickPositioner === "function") {
          const positions = axis.tickPositioner();
          if (positions?.length) {
            next.min = positions[0];
            next.max = positions[positions.length - 1];
            next.tickPositions = positions;
          }
        }
        return next;
      });
    },
    syncPatViewerYAxisGrid(chart) {
      chart?.yAxis?.forEach(axis => {
        const update = {
          gridLineWidth: 1,
          gridLineColor: "#e6e6e6"
        };
        const positions = axis.tickPositions?.length
          ? axis.tickPositions
          : (typeof axis.userOptions?.tickPositioner === "function"
            ? axis.userOptions.tickPositioner.call(axis)
            : null);
        if (positions?.length) {
          update.min = positions[0];
          update.max = positions[positions.length - 1];
          update.tickPositions = positions;
        }
        axis.update(update, false);
      });
    },
    syncPatViewerXAxis(chart, { tickPositions, breaks, plotLines, isDatetime, xAxisMin, xAxisMax } = {}) {
      const xAxis = chart?.xAxis?.[0];
      if (!xAxis) {
        return;
      }
      const updateOptions = {
        gridLineWidth: 1,
        breaks: breaks || [],
        labels: {
          y: PAT_VIEWER_X_LABELS_Y
        }
      };
      if (tickPositions?.length) {
        updateOptions.tickPositions = tickPositions;
      }
      if (xAxisMin != null && xAxisMax != null) {
        updateOptions.min = xAxisMin;
        updateOptions.max = xAxisMax;
      }
      if (!isDatetime) {
        updateOptions.startOnTick = false;
        updateOptions.endOnTick = false;
        updateOptions.alignTicks = false;
        updateOptions.minPadding = 0;
        updateOptions.maxPadding = 0;
      }
      xAxis.update(updateOptions, false);
      (plotLines || []).forEach((_, index) => {
        xAxis.removePlotLine(`pat-viewer-plot-line-${index}`);
      });
      (plotLines || []).forEach((plotLine, index) => {
        xAxis.addPlotLine({
          ...plotLine,
          id: plotLine.id || `pat-viewer-plot-line-${index}`
        }, false);
      });
    },
    syncPatViewerChartAxis(chart, options = {}) {
      if (!chart) {
        return;
      }
      this.syncPatViewerXAxis(chart, options);
      this.syncPatViewerYAxisGrid(chart);
      chart.redraw(false);
    },
    caculatePlotLines () {
      let plotLines = [];
      function buildArr (period, step) {
        const base = parseInt(period);
        let arr = [];
        for (let index = 1; index < base; index++) {
          let value = {
            color: '#cccccc',
            width: 1,
            value: index * step,
            zIndex: 5,
            force: true
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
  /**
   * 短期間（3/7/14日）datetime軸の目盛りをヘッダー日付列に合わせて配置
   * breaks がある場合は非治療日を除外した表示幅上に均等配置する
   */
  caculateDatetimeTickPositions(xAxisMin, xAxisMax, displayPeriod, dateList, breaks = []) {
    const period = displayPeriod + "";
    const hasBreaks = breaks?.length > 0;
    const sortedDateList = [...(dateList || [])].sort(
      (a, b) => Number(a) - Number(b)
    );

    if (!sortedDateList.length && !hasBreaks) {
      return null;
    }

    let ticksPerDay;
    switch (period) {
      case "1":
        ticksPerDay = 4;
        break;
      case "2":
        ticksPerDay = 3;
        break;
      case "3":
        ticksPerDay = 2;
        break;
      default:
        return null;
    }

    const pushTick = (ticks, tick) => {
      if (
        tick == null ||
        !Number.isFinite(tick) ||
        tick < xAxisMin ||
        tick > xAxisMax ||
        isTimestampInBreak(tick, breaks)
      ) {
        return;
      }
      if (!ticks.includes(tick)) {
        ticks.push(tick);
      }
    };

    const ticks = [];
    const tickHours = getPatViewerColumnTickHours(period);
    const MS_PER_HOUR = 60 * 60 * 1000;

    if (sortedDateList.length) {
      sortedDateList.forEach(dateStr => {
        const dayStart = dayjs(dateStr, "YYYYMMDD").startOf("day").valueOf();
        const dayEnd = dayjs(dateStr, "YYYYMMDD").endOf("day").valueOf();
        if (dayEnd < xAxisMin || dayStart > xAxisMax) {
          return;
        }
        tickHours.forEach(hour => {
          pushTick(ticks, dayStart + hour * MS_PER_HOUR);
        });
      });
    } else if (hasBreaks) {
      const tickAmount =
        sortedDateList.length > 0
          ? sortedDateList.length * ticksPerDay
          : Math.max(ticksPerDay, 1);
      const intervals = getVisibleTimeIntervals(xAxisMin, xAxisMax, breaks);
      const totalVisible = intervals.reduce(
        (sum, interval) => sum + (interval.end - interval.start),
        0
      );
      if (totalVisible > 0) {
        for (let i = 1; i < tickAmount; i++) {
          pushTick(
            ticks,
            timestampAtVisibleOffset(
              xAxisMin,
              xAxisMax,
              breaks,
              (totalVisible / tickAmount) * i
            )
          );
        }
      }
    }

    ticks.sort((a, b) => a - b);
    return ticks.length >= 2 ? ticks : null;
  },
  /**
   * breaks 適用時にカレンダー日数ではなく表示上の有効区間で均等分割する
   */
  caculateBrokenAxisTickPositions(xAxisMin, xAxisMax, displayPeriod, breaks) {
    if (!breaks?.length) {
      return null;
    }

    let tickAmount = 0;
    const intervals = getVisibleTimeIntervals(xAxisMin, xAxisMax, breaks);
    const visibleDays = Math.max(
      1,
      Math.ceil(
        intervals.reduce((sum, interval) => sum + (interval.end - interval.start), 0) /
          86400000
      )
    );

    switch (displayPeriod + "") {
      case "1":
        tickAmount = visibleDays * 4;
        break;
      case "2":
        tickAmount = visibleDays * 3;
        break;
      case "3":
        tickAmount = visibleDays * 2;
        break;
      default:
        return null;
    }

    const ticks = [xAxisMin];
    const totalVisible = intervals.reduce(
      (sum, interval) => sum + (interval.end - interval.start),
      0
    );
    if (totalVisible <= 0) {
      return [xAxisMin, xAxisMax];
    }

    for (let i = 1; i < tickAmount; i++) {
      const tick = timestampAtVisibleOffset(
        xAxisMin,
        xAxisMax,
        breaks,
        (totalVisible / tickAmount) * i
      );
      if (
        tick != null &&
        Number.isFinite(tick) &&
        !isTimestampInBreak(tick, breaks) &&
        !ticks.includes(tick)
      ) {
        ticks.push(tick);
      }
    }
    if (ticks[ticks.length - 1] !== xAxisMax) {
      ticks.push(xAxisMax);
    }
    return ticks;
  },
  /** @deprecated 列内の「目盛り個数」は getPatViewerColumnTickCount を使用 */
  getPatViewerTicksPerDay(displayPeriod) {
    return this.getPatViewerColumnTickCount(displayPeriod) + 1;
  },
  getPatViewerColumnTickCount(displayPeriod) {
    return getPatViewerColumnTickHours(displayPeriod).length;
  },
  buildPatViewerColumnDateIndexMap(dateList) {
    const map = {};
    (dateList || []).forEach((dateStr, index) => {
      map[dateStr] = index;
    });
    return map;
  },
  mapOccurDateToColumnX(occurDate, dateIndexMap) {
    const occur = dayjs(occurDate);
    const dateKey = occur.format("YYYYMMDD");
    const dayIndex = dateIndexMap[dateKey];
    if (dayIndex === undefined) {
      return null;
    }
    const dayStart = dayjs(dateKey, "YYYYMMDD").startOf("day");
    const dayEnd = dayjs(dateKey, "YYYYMMDD").endOf("day");
    const duration = dayEnd.valueOf() - dayStart.valueOf() || 1;
    const fraction = (occur.valueOf() - dayStart.valueOf()) / duration;
    return {
      x: dayIndex + Math.min(Math.max(fraction, 0), 1),
      date: dateKey,
      occurTime: occur.valueOf()
    };
  },
  caculateColumnAlignedTickPositions(dayCount, displayPeriod) {
    if (!dayCount) {
      return [];
    }
    const hours = getPatViewerColumnTickHours(displayPeriod);
    const ticks = [];
    for (let dayIndex = 0; dayIndex < dayCount; dayIndex++) {
      hours.forEach(hour => {
        ticks.push(columnXFromDayHour(dayIndex, hour));
      });
    }
    return ticks;
  },
  buildColumnDayPlotLines(dayCount) {
    const plotLines = [];
    for (let index = 1; index < dayCount; index++) {
      plotLines.push({
        color: "#cccccc",
        width: 1,
        value: index,
        zIndex: 5
      });
    }
    return plotLines;
  },
  insertColumnAxisDayBreaks(points) {
    if (!points?.length) {
      return points;
    }
    const sorted = [...points].sort((a, b) => a.x - b.x);
    const result = [];
    sorted.forEach((point, index) => {
      if (index > 0) {
        const prevDay = Math.floor(sorted[index - 1].x);
        const curDay = Math.floor(point.x);
        if (prevDay !== curDay) {
          result.push({ x: sorted[index - 1].x, y: null, y0: null });
        }
      }
      result.push(point);
    });
    return result;
  },
  formatColumnAxisTickLabel(value) {
    return formatPatViewerColumnAxisTickLabel(value);
  },
    caculateTickPositions () {
      function isValidDate(dateStr) {
        return dayjs(dateStr, 'YYYYMMDD', true).isValid();
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

export {
  formatPatViewerColumnAxisTickLabel,
  getPatViewerColumnTickHours,
  columnXFromDayHour
};
