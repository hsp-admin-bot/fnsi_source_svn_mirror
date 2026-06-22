
// add 12031 患者経過総合ビューアのグラフオートレンジ zkm start
export const isValidNumber = (val) => {
  return val !== '' && val != null && !isNaN(Number(val));
};

export const getThreshold = (mstMax, mstMin, dataArr, chartType) => {
  const validData = dataArr.filter(v => null != v && '' !== v).map(v => Number(v)).filter(Number.isFinite);
  let max = mstMax ? Number(mstMax) : mstMax;
  let min = mstMin ? Number(mstMin) : mstMin;
  if (isValidNumber(mstMax) && isValidNumber(mstMin)) {
    if (chartType !== 'line') {
      max = validData.length > 0 ? Math.max(max, Math.max(...validData)) : max;
      min = validData.length > 0 ? Math.min(min, Math.min(...validData)) : min;
    }
    if (max < min) {
      return { max: min, min: max };
    }
    return { max, min };
  }
  if (validData.length === 0) {
    return { max: 4, min: 0 };
  }
  if (chartType !== 'line') {
    max = validData.length > 0 ? Math.max(max, Math.max(...validData)) : max;
    min = validData.length > 0 ? (isValidNumber(min) ? Math.min(min, Math.min(...validData)) : Math.min(...validData)) : min;
  } else {
    max = isValidNumber(mstMax) ? Number(mstMax) : Math.max(...validData);
    min = isValidNumber(mstMin) ? Number(mstMin) : Math.min(...validData);
  }

  if (max < min) {
    return { max: min, min: max };
  }
  return { max, min };
};
// add 12031 患者経過総合ビューアのグラフオートレンジ zkm end

export const getSeriesMarker = (key, color) => {
  switch (key) {
    // "△"
    case "triangle": return { enabled: true, symbol: "triangle", fillColor: "white", lineWidth: 1, lineColor: color };
    // "▲"
    case "triangle-b": return { enabled: true, symbol: "triangle" };
    // "▽"
    case "triangle-down": return { enabled: true, symbol: "triangle-down", fillColor: "white", lineWidth: 1, lineColor: color };
    // "▼"
    case "triangle-down-b": return { enabled: true, symbol: "triangle-down" };
    // "□"
    case "square": return { enabled: true, symbol: "square", fillColor: "white", lineWidth: 1, lineColor: color };
    // "■"
    case "square-b": return { enabled: true, symbol: "square" };
    // "◇"
    case "diamond": return { enabled: true, symbol: "diamond", fillColor: "white", lineWidth: 1, lineColor: color };
    // "◆"
    case "diamond-b": return { enabled: true, symbol: "diamond" };
    // "○"
    case "circle": return { enabled: true, symbol: "circle", fillColor: "white", lineWidth: 1, lineColor: color };
    // "●"
    case "circle-b": return { enabled: true, symbol: "circle" };
    // "◎"
    case "double-circle": return { enabled: true, symbol: "double-circle" };
    default: return null;
  }
};

