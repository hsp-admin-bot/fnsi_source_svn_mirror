/**
 * 日付関係ユーティリティ
 */
import moment from "moment-timezone";

export const DATE_FORMAT_QUEUE= "YYYYMMDD";
export const DATE_FORMAT = "yyyy-MM-dd";
export const DATE_FORMAT_NORMAL = "YYYY/MM/DD";
export const DATE_TIME_FORMAT = "yyyy/MM/dd hh:mm";
export const SHORT_TIME_FORMAT = "hh:mm";
export const LONG_TIME_FORMAT = "hh:mm:ss";

export const dateFormat = {
  _fmt: {
    yyyy: function(date) {
      return date.getFullYear() + "";
    },
    MM: function(date) {
      return ("0" + (date.getMonth() + 1)).slice(-2);
    },
    dd: function(date) {
      return ("0" + date.getDate()).slice(-2);
    },
    hh: function(date) {
      return ("0" + date.getHours()).slice(-2);
    },
    mm: function(date) {
      return ("0" + date.getMinutes()).slice(-2);
    },
    ss: function(date) {
      return ("0" + date.getSeconds()).slice(-2);
    }
  },
  _priority: ["yyyy", "MM", "dd", "hh", "mm", "ss"],

  /**
   * 日付フォーマット
   * @param {Date} date
   * @param {String} format
   */
  format: function(date, format) {
    return this._priority.reduce(
      (res, fmt) => res.replace(fmt, this._fmt[fmt](date)),
      format
    );
  },

  /**
   * UTC文字列をJST文字列に変換する
   * example
   *   input:  2019-01-01T00:00:00Z
   *   output: 2019-01-01T00:00:00.000+09:00
   * @param {String} utcDate
   */
  utc2Jst: function(utcDate) {
    return moment(utcDate)
      .tz("Asia/Tokyo")
      .format("YYYY-MM-DDTHH:mm:ss.SSS+09:00");
  },
  /**
   * HHMMを表す文字列をHH:mmに変換する
   * @param {String} char
   */
  char2time: function(char) {
    const hour = char.substring(0, 2);
    const min = char.substring(2);
    return `${hour}:${min}`;
  },
  /**
   * 分数を表す文字列をHH:mmに変換する
   * @param {String} char
   */
  mChar2time: function(char) {
    let charNam;
    if (isNaN(Number(char))) {
      charNam = 0;
    } else {
      charNam = Number(char);
    }
    const min = charNam % 60;
    const hour = (charNam - min) / 60;
    const minStr = ("00" + min).slice(-2);
    const hourStr = ("00" + hour).slice(-2);
    return `${hourStr}:${minStr}`;
  },
  /**
   * HH:mmからHHMMを表す文字列に変換する
   * @param {String} time
   */
  time2char: function(time) {
    return time.replace(/:/g, "");
  },
  /**
   * HH:mmから HH × 60 + mm を表す文字列に変換する
   * @param {String} time
   */
  time2MChar: function(time) {
    const timeStr = time.replace(/:/g, "");
    const hour = timeStr.substring(0, 2);
    const min = timeStr.substring(2);
    return Number(hour) * 60 + Number(min);
  },
  /**
   * YYYYMMDDを表す文字列に変換する
   * @param {String} date
   */
  queueDate: function(date) {
    return moment(date).format(DATE_FORMAT_QUEUE);
  },
  /**
   * YYYY/MM/DDを表す文字列に変換する
   * @param {String} date
   */
  normalDate: function(date) {
    return moment(date).format(DATE_FORMAT_NORMAL);
  },
  /**
   * YYYY/MM/DDを表す文字列に変換する(変換できなかった場合は空文字を返す)
   * @param {String} date
   */
  normalDateWithCheck: function(date) {
    const rtnDate = moment(date);
    return rtnDate.isValid() ? rtnDate.format(DATE_FORMAT_NORMAL) : "";
  }
};

/**
 * 日付文字列＋時刻文字列のパース
 * @param {String} dateString 日付文字列(yyyy-MM-dd or yyyy/MM/dd)
 * @param {String} timeString 時刻文字列(HH:mm)
 */
export function parseDate(dateString, timeString) {
  if (dateString && timeString) {
    return new Date(`${dateString.replace(/-/g, "/")} ${timeString}`);
  } else {
    return null;
  }
}

/**
 * Date型の日付をUTC日付に変換する.
 * @param {*} date
 */
export function date2UTC(date) {
  return Date.UTC(
    date.getUTCFullYear(),
    date.getUTCMonth(),
    date.getUTCDate(),
    date.getUTCHours(),
    date.getUTCMinutes(),
    date.getUTCSeconds()
  );
}

/**
 * 年、月から該当年月の最終日を取得する
 * 年が不明で2月の場合、29を返す
 * @param {String} year 年(YYYY)
 * @param {String} month 月(MM)
 * @return {Number} 該当年月の最終日
 */
export const getMaxDay = (year, month) => {
  if (month === "02") {
    const targetYear = moment(year + "0101");
    if (targetYear.isValid()) {
      return targetYear.isLeapYear() ? 29 : 28;
    } else {
      return 29;
    }
  }
  return new Date(year, month, 0).getDate();
}

/**
 * 検査依頼、放射線検査依頼の締め切り日を取得する
 * 締め切り日付(現在時刻 + 締切日数(日曜をカウントしない) + 時刻が過ぎていた場合はさらに+1した日数)
 * @param {*} deadlineCondition 締切日設定
 * @return {String} 締め切り日付
 */
export const getDeadlineDate = (deadlineCondition) => {
  let count = 0;
  let nowDate = moment(new Date());
  let rtnDate = moment(nowDate.format("YYYY/MM/DD"));
  while (count < deadlineCondition.deadlineDateCount) {
    rtnDate.add(1, "days");
    if (rtnDate.format('E') !== "7") {
      count++;
    }
  }
  // 締切時刻を過ぎている場合、さらに+1加算
  const time = deadlineCondition.deadlineTimeCount.split(':');
  if (nowDate.isAfter(moment(nowDate.format("YYYY/MM/DD")).hour(Number(time[0])).minutes(Number(time[1])))) {
    rtnDate.add(1, "days");
  }
  return rtnDate.format("YYYY/MM/DD");
}

/**
 * 指定開始日が、使用期間開始日以降且つ、使用期間終了日を超えていないかを判定する
 * 物品系マスタの使用期限の判定に使用
 * @param {String} strUseStartDate 使用期間開始日(YYYYMMDD)
 * @param {String} strUseEndDate 使用期間終了日(YYYYMMDD)
 * @param {String} strStartDate 開始日(YYYYMMDD)
 * @return {boolean} 判定結果
 */
export const fitTermCheck = (strUseStartDate, strUseEndDate, strStartDate) => {
  // 使用期間開始日、使用期間終了日がどちらも未設定の場合は無制限とする
  if(!strUseStartDate && !strUseEndDate) {
    return true;
  }

  let rtn = false;
  // 開始日
  const startDate = moment(strStartDate);
  // 使用期間開始日
  const objStartDate = !strUseStartDate ? null : moment(strUseStartDate);
  // 使用期間終了日
  const objEndDate = !strUseEndDate ? null : moment(strUseEndDate);

  if(objStartDate && !objEndDate) {
    // 使用期間開始日のみの場合
    if (!objStartDate.isAfter(startDate)) {
      // 使用期間開始日は、開始日より後ではない → 開始日時点で開始日か、開始日を過ぎている
      rtn = true;
    }
  } else if (!objStartDate && objEndDate) {
    // 使用期間終了日のみの場合
    if (!objEndDate.isBefore(startDate)) {
      // 使用期間終了日は、開始日より前ではない → 開始日時点では使用期間終了日を過ぎていない
      rtn = true;
    }
  } else if (objStartDate && objEndDate) {
    // 使用期間開始日、使用期間終了日 が存在する場合
    if (!objStartDate.isAfter(startDate) && !objEndDate.isBefore(startDate)) {
      rtn = true;
    }
  }
  return rtn;
}

/**
 * 保存時に、
 * ・指定開始日が、使用期間開始日以降且つ、使用期間終了日を超えていないか
 * ・指定終了日が、使用期間終了日を超えていないか
 * を判定する
 * 物品系マスタの使用期限の判定に使用
 * @param {String} strUseStartDate 使用期間開始日(YYYYMMDD)
 * @param {String} strUseEndDate 使用期間終了日(YYYYMMDD)
 * @param {String} strStartDate 開始日(YYYYMMDD)
 * @param {String} strEndDate 終了日(YYYYMMDD)
 * @return {boolean} 判定結果
 */
export const fitTermCheckForUpdate = (strUseStartDate, strUseEndDate, strStartDate, strEndDate) => {
  // 使用期間開始日、使用期間終了日がどちらも未設定の場合は無制限とする
  if(!strUseStartDate && !strUseEndDate) {
    return true;
  }

  let rtn = false;
  // 開始日
  const startDate = moment(strStartDate);
  // 終了日
  const endDate = moment(strEndDate);
  // 使用期間開始日
  const objStartDate = !strUseStartDate ? null : moment(strUseStartDate);
  // 使用期間終了日
  const objEndDate = !strUseEndDate ? null : moment(strUseEndDate);

  if(objStartDate && !objEndDate) {
    // 使用期間開始日のみの場合
    if (!objStartDate.isAfter(startDate)) {
      // 使用期間開始日は、開始日より後ではない → 開始日時点で開始日か、開始日を過ぎている
      rtn = true;
    }
  } else if (!objStartDate && objEndDate) {
    // 使用期間終了日のみの場合
    if (!objEndDate.isBefore(endDate)) {
      // 使用期間終了日は、終了日より前ではない
      rtn = true;
    }
  } else if (objStartDate && objEndDate) {
    // 使用期間開始日、使用期間終了日 が存在する場合
    if (!objStartDate.isAfter(startDate) && !objEndDate.isBefore(endDate)) {
      rtn = true;
    }
  }
  return rtn;
}

/**
 * 開始～終了日時の差を分単位で取得
 * @param {Date} startDate 開始日時
 * @param {Date} endDate 終了日時
 * @return {Number} 差 ※分単位
 */
export const diffDateInMinutes = (startDate, endDate) => {
  // 差をミリ秒単位で取得
  const diffInMilliseconds = endDate - startDate;
  // ミリ秒を分に変換
  const diffInMinutes = diffInMilliseconds / 1000 / 60;
  return diffInMinutes;
}

/**
 * 開始～終了日時の時刻の差を分単位で取得
 * @param {Date} startDate 開始日時
 * @param {Date} endDate 終了日時
 * @return {Number} 差 ※分単位
 */
export const diffTimeInMinutes = (startDate, endDate) => {
  const startMinutes = startDate.getUTCHours() * 60 + startDate.getUTCMinutes();
  const endMinutes = endDate.getUTCHours() * 60 + endDate.getUTCMinutes();
  const diffInMinutes = endMinutes - startMinutes;
  return diffInMinutes;
}


