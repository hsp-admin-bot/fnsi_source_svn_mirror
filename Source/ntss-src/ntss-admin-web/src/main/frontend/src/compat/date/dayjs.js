/**
 * Day.js 共通設定（moment 代替）
 * 必要なプラグインをここで一度だけ extend し、プロジェクト全体で同一インスタンスを使う。
 */
import dayjs from "dayjs";
import utc from "dayjs/plugin/utc";
import timezone from "dayjs/plugin/timezone";
import customParseFormat from "dayjs/plugin/customParseFormat";
import arraySupport from "dayjs/plugin/arraySupport";
import isLeapYear from "dayjs/plugin/isLeapYear";
import duration from "dayjs/plugin/duration";
import minMax from "dayjs/plugin/minMax";
import isBetween from "dayjs/plugin/isBetween";
import isSameOrBefore from "dayjs/plugin/isSameOrBefore";
import isSameOrAfter from "dayjs/plugin/isSameOrAfter";
import isoWeek from "dayjs/plugin/isoWeek";
import weekday from "dayjs/plugin/weekday";
import weekOfYear from "dayjs/plugin/weekOfYear";
import badMutable from "dayjs/plugin/badMutable";
import updateLocale from "dayjs/plugin/updateLocale";
import "dayjs/locale/ja";

dayjs.extend(utc);
dayjs.extend(timezone);
dayjs.extend(customParseFormat);
dayjs.extend(arraySupport);
dayjs.extend(isLeapYear);
dayjs.extend(duration);
dayjs.extend(minMax);
dayjs.extend(isBetween);
dayjs.extend(isSameOrBefore);
dayjs.extend(isSameOrAfter);
dayjs.extend(isoWeek);
dayjs.extend(weekday);
dayjs.extend(weekOfYear);
dayjs.extend(badMutable);
dayjs.extend(updateLocale);
dayjs.extend((_, DayjsClass) => {
  const proto = DayjsClass.prototype;
  const bindUnitAlias = (pluralName, singularName) => {
    if (typeof proto[pluralName] === "function") {
      return;
    }
    proto[pluralName] = function(value) {
      if (value === undefined) {
        return this[singularName]();
      }
      return this[singularName](value);
    };
  };

  // moment 互換の plural getter/setter を Day.js instance に補完する。
  bindUnitAlias("years", "year");
  bindUnitAlias("months", "month");
  bindUnitAlias("dates", "date");
  bindUnitAlias("hours", "hour");
  bindUnitAlias("minutes", "minute");
  bindUnitAlias("seconds", "second");
  bindUnitAlias("milliseconds", "millisecond");
});

dayjs.locale("ja");

export default dayjs;
