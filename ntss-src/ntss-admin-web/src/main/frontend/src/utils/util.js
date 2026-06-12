import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";

/**
 * 2つの値が空の文字列とnullであるかどうかを比較します。
 * @param {*} val1 - 最初の比較値
 * @param {*} val2 - 2番目の比較値
 * @returns {boolean} trueを返します2つの値の1つが空の文字列で、もう1つがnullです
 */
const customComparator = (val1, val2) => {
  if ((val1 === "" && val2 === null) || (val1 === null && val2 === "")) {
    return true;
  }
};
const customComparatorForType = (val1, val2) => {
  if (
    ((val1 || val1 === 0) && (val2 || val2 === 0) && val1 == val2) ||
    (val1 === "" && val2 === null) ||
    (val1 === null && val2 === "") ||
    (val1 !== 0 && val2 !== 0 && val1 == val2)
  ) {
    return true;
  }
};
const sortCompare = (a, b) => {
  if (a?.sort && b?.sort) {
    return _.isEqual(a.sort(), b.sort());
  } else {
    return false;
  }
};
const emToPx = (em, fontSizeIndex) => {
  if (!em) {
    return 0;
  }
  const contrast = [0.8, 1, 1.1, 1.3];
  const pxStr = _.multiply(parseInt(em, 10), contrast[fontSizeIndex]) * 15 + "px";
  return pxStr;
};
const pxForFontSize = (pxStr, oldFontIndex, newFontIndex) => {
  const contrast = [8, 10, 11, 13];
  return (
    (parseFloat(pxStr) * 100) / contrast[oldFontIndex] * contrast[newFontIndex] / 100 + "px"
  );
};
const diffObj = (object1, object2) => {
  return _.transform(
    object1,
    function (result, value, key) {
      if (!_.isEqualWith(value, object2[key], customComparator)) {
        result[key] = value;
      }
    },
    {}
  );
};
const isEmpty = (value) => {
  if (typeof value === "number") {
    return value === 0;
  } else if (typeof value === "string") {
    return value === "";
  } else {
    return _.isEmpty(value);
  }
};
/**
 * 指定された開始日と終了日間のすべての日付文字列を含む配列を生成します。
 * @param {number} startDate - 開始日時刻（秒単位）。
 * @param {number} endDate - 終了日時刻（秒単位）。
 * @param {boolean} completion - 月の実際の日数を超えた日付を埋めるかどうか，默认はfalse。
 * @returns {Array} フォーマットがYYYYMMDDのすべての日付文字列を含む配列を返します。
 */
const generateDates = (startDate, endDate, completion = true) => {
  const dates = [];
  const startMoment = dayjs.unix(Math.floor(startDate / 1000));
  const endMoment = dayjs.unix(Math.floor(endDate / 1000));

  if (completion) {
    for (let date = startMoment; date.isBefore(endMoment); date = date.add(1, "day")) {
      const year = date.format("YYYY");
      const month = date.format("MM");
      let day = date.format("DD");
      const endOfMonth = date.endOf("month");
      const paddedDateString = `${year}${month.padStart(2, "0")}${day.padStart(2, "0")}`;
      dates.push(paddedDateString);
      if (date.isSame(endOfMonth, "day") && parseInt(day, 10) !== 31) {
        day = parseInt(day, 10);
        while (day < 31) {
          day += 1;
          dates.push(`${year}${month.padStart(2, "0")}${day.toString().padStart(2, "0")}`);
        }
      }
    }
  } else {
    for (let date = startMoment; date.isBefore(endMoment); date = date.add(1, "day")) {
      const paddedDateString = date.format("YYYYMMDD");
      dates.push(paddedDateString);
    }
    dates.push(endMoment.format("YYYYMMDD"));
  }
  return dates;
};
const replaceNullWithEmptyString = (value) => {
  return value !== null ? value : "";
};
const replaceLtGt = (value) => {
  if (value?.includes("<") || value?.includes(">")) {
    return value.replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }
  return value;
};
const calculateMaxMin = (integerDigits, decimalDigits) => {
  const maxIntegerPart = "9".repeat(integerDigits);
  const maxDecimalPart = "9".repeat(decimalDigits);
  const maxValue = parseFloat(`${maxIntegerPart}.${maxDecimalPart}`);

  const minIntegerPart = "-" + "9".repeat(integerDigits);
  const minDecimalPart = "9".repeat(decimalDigits);
  const minValue = parseFloat(`${minIntegerPart}.${minDecimalPart}`);
  const result = {
    maxValue: maxValue.toFixed(decimalDigits),
    minValue: minValue.toFixed(decimalDigits)
  };
  return result;
};

export {
  customComparator,
  customComparatorForType,
  sortCompare,
  emToPx,
  pxForFontSize,
  diffObj,
  isEmpty,
  replaceNullWithEmptyString,
  generateDates,
  replaceLtGt,
  calculateMaxMin
};
