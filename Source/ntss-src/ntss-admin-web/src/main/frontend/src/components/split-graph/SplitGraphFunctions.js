import dayjs from "@/compat/date/dayjs";

/**
 * プロット対象となる検査結果の最新の検査日を基準として、
 * 1～6月、7～12月の期間ごと(凡例4期目は2年以上遡るデータを含めて表示)に、
 * プロットおよび線の色を各設定色にする。
 * @param {*} listExam 
 * @param {*} startDate 
 * @param {*} endDate 
 */
export function getExamInRange(listExam, startDate, endDate) {
  if (startDate && endDate) {
      return listExam.filter(
        exam =>
          dayjs(exam.date) >= dayjs(startDate) &&
          dayjs(exam.date) <= dayjs(endDate)
      );
  } else {
    return listExam;
  }
}

export function simpleDateFormat(date) {
  return dayjs(date).format("YYYY/MM/DD");
}

/**
 * 時間の長さまたは部分。(最大4期間)
 */
export function periods(data) {
  let periods = [];
  if (data[0]) {
    // 最新の情報を取得
    let newestDay = dayjs(data[0].date, "YYYY/MM/DD");
    let month = newestDay.format("M");
    let year = newestDay.format("YYYY");
    let beginOfYear = month < 7;
    // 初回検査日の情報を取得
    let lastDate = dayjs(data[data.length-1].date, "YYYY/MM/DD");
    let lastMonth = lastDate.format("M");
    let lastYear = lastDate.format("YYYY");
    for (let i = 0; i < 4; i++) {
      let start = dayjs().format("YYYY/MM/DD");
      let end = dayjs().format("YYYY/MM/DD");
      // 検査日データが全て2年以内
      if (i < 3 || i == 3 && lastYear >= year) {
        if (beginOfYear) {
          start = dayjs(`${year}-01-01`)
            .startOf("month")
            .format("YYYY/MM/DD");
          end = dayjs(`${year}-06-01`)
            .endOf("month")
            .format("YYYY/MM/DD");
          year--;
        } else {
          start = dayjs(`${year}-07-01`)
            .startOf("month")
            .format("YYYY/MM/DD");
          end = dayjs(`${year}-12-01`)
            .endOf("month")
            .format("YYYY/MM/DD");
        }
      } else {
        if (beginOfYear) {
          start = dayjs(`${lastYear}-${lastMonth}-01`)
            .startOf("month")
            .format("YYYY/MM/DD");
          end = dayjs(`${year}-06-01`)
            .endOf("month")
            .format("YYYY/MM/DD");
        } else {
          start = dayjs(`${lastYear}-${lastMonth}-01`)
            .startOf("month")
            .format("YYYY/MM/DD");
          end = dayjs(`${year}-12-01`)
            .endOf("month")
            .format("YYYY/MM/DD");
        }
      }
      beginOfYear = !beginOfYear;
      periods.push({ start, end });
    }
  }
  return periods;
}

/**
 * 折れ線は、検査日の時間軸でプロットを繋げる。
 */
export function simpleSort(data, key) {
  const list = data.slice();
  list.sort((a, b) => {
    a = a[key];
    b = b[key];
    let sortItem = 0;
    if (a === b) {
      sortItem = 0;
    } else if (a < b) {
      sortItem = 1;
    } else {
      sortItem = -1;
    }
    return sortItem;
  });
  return list;
}

export const DEFAULT_SETTINGS = {
  plotSize: 3,
  // 散布図
  plotColor: "lawngreen",
  plotSelectedColor: "red",
  plotOutsideColor: "lawngreen",
  // 線グラフ
  plotProgress1Color: "rgba(255, 0, 0, 1)",
  plotProgress2Color: "rgba(255, 0, 0, 0.8)",
  plotProgress3Color: "rgba(255, 0, 0, 0.6)",
  plotProgress4Color: "rgba(255, 0, 0, 0.4)",

  lineProgress1Color: "rgba(255, 0, 0, 1)",
  lineProgress2Color: "rgba(255, 0, 0, 0.8)",
  lineProgress3Color: "rgba(255, 0, 0, 0.6)",
  lineProgress4Color: "rgba(255, 0, 0, 0.4)",
  seriesLineWidth: 1,
};

export function formatGraphSettings(setting) {
  setting.limitLowerThresholdX = parseFloat(setting.limitLowerThresholdX);
  setting.limitLowerThresholdY = parseFloat(setting.limitLowerThresholdY);
  setting.limitLowerX = parseFloat(setting.limitLowerX);
  setting.limitLowerY = parseFloat(setting.limitLowerY);
  setting.limitUpperThresholdX = parseFloat(setting.limitUpperThresholdX);
  setting.limitUpperThresholdY = parseFloat(setting.limitUpperThresholdY);
  setting.limitUpperX = parseFloat(setting.limitUpperX);
  setting.limitUpperY = parseFloat(setting.limitUpperY);
  setting.lineProgress1Color = setting.lineProgress1Color === "1" ? DEFAULT_SETTINGS.lineProgress1Color : setting.lineProgress1Color;
  setting.lineProgress2Color = setting.lineProgress2Color === "1" ? DEFAULT_SETTINGS.lineProgress2Color : setting.lineProgress2Color;
  setting.lineProgress3Color = setting.lineProgress3Color === "1" ? DEFAULT_SETTINGS.lineProgress3Color : setting.lineProgress3Color;
  setting.lineProgress4Color = setting.lineProgress4Color === "1" ? DEFAULT_SETTINGS.lineProgress4Color : setting.lineProgress4Color;
  // 散布図
  setting.plotColor = setting.plotColor === "1" ? DEFAULT_SETTINGS.plotColor : setting.plotColor;
  setting.plotOutsideColor = setting.plotOutsideColor === "1" ? DEFAULT_SETTINGS.plotOutsideColor : setting.plotOutsideColor;
  // 線グラフ
  setting.plotProgress1Color = setting.plotProgress1Color === "1" ? DEFAULT_SETTINGS.plotProgress1Color : setting.plotProgress1Color;
  setting.plotProgress2Color = setting.plotProgress2Color === "1" ? DEFAULT_SETTINGS.plotProgress2Color : setting.plotProgress2Color;
  setting.plotProgress3Color = setting.plotProgress3Color === "1" ? DEFAULT_SETTINGS.plotProgress3Color : setting.plotProgress3Color;
  setting.plotProgress4Color = setting.plotProgress4Color === "1" ? DEFAULT_SETTINGS.plotProgress4Color : setting.plotProgress4Color;
  setting.plotSelectedColor = setting.plotSelectedColor === "1" ? DEFAULT_SETTINGS.plotSelectedColor : setting.plotSelectedColor;
  setting.plotSize = parseFloat(setting.plotSize);
  setting.seriesLineWidth = parseFloat(setting.seriesLineWidth);
}

/**
 * 小数第2位を四捨五入し、小数第1位まで表示
 * @param { Float } number 
 */
export function DecimalFormat(number) {
  const str = number.toFixed(2);
  return str.slice(0, str.indexOf('.') + 2);
}

/**
 * 設定不備の条件
 * @param { Object } graphSetting
 */
export function settingErrorMessage(setting) {
  let missingSettingStatus = "グラフ設定に不備があるため、表示できません";

  // ①X軸グラフ閾値上限 ≦ X軸グラフ閾値下限
  if (setting.limitUpperThresholdX < setting.limitLowerThresholdX) {
    missingSettingStatus += "<br>X軸グラフ閾値上限 ＜ X軸グラフ閾値下限";
  }

  // ①Y軸グラフ閾値上限 ≦ Y軸グラフ閾値下限
  if (setting.limitUpperThresholdY < setting.limitLowerThresholdY) {
    missingSettingStatus += "<br>Y軸グラフ閾値上限 ＜ Y軸グラフ閾値下限";
  }

  // ②X軸グラフ閾値下限 ＜ X軸グラフ下限値
  if (setting.limitLowerThresholdX < setting.limitLowerX) {
    missingSettingStatus += "<br>X軸グラフ閾値下限 ＜ X軸グラフ下限値";
  }
  // ②Y軸グラフ閾値下限 ＜ Y軸グラフ下限値
  if (setting.limitLowerThresholdY < setting.limitLowerY) {
    missingSettingStatus += "<br>Y軸グラフ閾値下限 ＜ Y軸グラフ下限値";
  }

  // ③X軸グラフ上限値 ＜ X軸グラフ閾値上限
  if (setting.limitUpperX < setting.limitUpperThresholdX) {
    missingSettingStatus += "<br>X軸グラフ上限値 ＜ X軸グラフ閾値上限";
  }
  // ③Y軸グラフ上限値 ＜ Y軸グラフ閾値上限
  if (setting.limitUpperY < setting.limitUpperThresholdY) {
    missingSettingStatus += "<br>Y軸グラフ上限値 ＜ y軸グラフ閾値上限";
  }

  // ④X軸グラフ上限値 ≦ X軸グラフ下限値
  if (setting.limitUpperX <= setting.limitLowerX) {
    missingSettingStatus += "<br>X軸グラフ上限値 ≦ X軸グラフ下限値";
  }
  // ④Y軸グラフ上限値 ≦ Y軸グラフ下限値
  if (setting.limitUpperY <= setting.limitLowerY) {
    missingSettingStatus += "<br>Y軸グラフ上限値 ≦ Y軸グラフ下限値";
  }

  // X軸の両方の検査マスタ指定が未選択
  if (
    !setting.examItemCdX ||
    setting.examItemCdX === "" ||
    setting.examItemCdX === "0"
  ) {
    missingSettingStatus += "<br>X軸の検査項目が未設定";
  }
  // Y軸の両方の検査マスタ指定が未選択
  if (
    !setting.examItemCdY ||
    setting.examItemCdY === "" ||
    setting.examItemCdY === "0"
  ) {
    missingSettingStatus += "<br>Y軸の検査項目が未設定";
  }

  // X軸グラフ上限値の検査項目が未設定
  if (isNaN(Number(setting.limitUpperX))) {
    missingSettingStatus += "<br>X軸グラフ上限値の検査項目が未設定"
  }
  // Y軸グラフ上限値の検査項目が未設定
  if (isNaN(Number(setting.limitUpperY))) {
    missingSettingStatus += "<br>Y軸グラフ上限値の検査項目が未設定"
  }

  // X軸グラフ閾値上限の検査項目が未設定
  if (isNaN(Number(setting.limitUpperThresholdX))) {
    missingSettingStatus += "<br>X軸グラフ閾値上限の検査項目が未設定"
  }
  // Y軸グラフ閾値上限の検査項目が未設定
  if (isNaN(Number(setting.limitUpperThresholdX))) {
    missingSettingStatus += "<br>X軸グラフ閾値上限の検査項目が未設定"
  }

  // X軸グラフ閾値下限の検査項目が未設定
  if (isNaN(Number(setting.limitLowerThresholdX))) {
    missingSettingStatus += "<br>X軸グラフ閾値下限の検査項目が未設定"
  }
  // Y軸グラフ閾値下限の検査項目が未設定
  if (isNaN(Number(setting.limitLowerThresholdY))) {
    missingSettingStatus += "<br>Y軸グラフ閾値下限の検査項目が未設定"
  }

  // X軸グラフ下限値の検査項目が未設定
  if (isNaN(Number(setting.limitLowerX))) {
    missingSettingStatus += "<br>X軸グラフ下限値の検査項目が未設定"
  }
  // Y軸グラフ下限値の検査項目が未設定
  if (isNaN(Number(setting.limitLowerY))) {
    missingSettingStatus += "<br>Y軸グラフ下限値の検査項目が未設定"
  }

  if (missingSettingStatus === "グラフ設定に不備があるため、表示できません") {
    missingSettingStatus = null;
  }
  return missingSettingStatus;
}