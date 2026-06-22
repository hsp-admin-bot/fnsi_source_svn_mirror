import dayjs from "@/compat/date/dayjs";

/**
 * @description 基準日を第3週とするカレンダー配列作成
 * @param {Moment} baseDate 基準日moment
 * @param {Boolean} isBaseDateOnCenterWeek 基準日を第3週にずらして表示するか
 * @returns {Array} カレンダー配列 ※各日付はMoment
 */
export const createCalendarArray = (baseDate, isBaseDateOnCenterWeek) => {
  // 基準日の月の一日
  const firstDayOfMonth = dayjs([baseDate.year(), baseDate.month(), 1]).day();
  // 基準日が第何週か
  const weekOfMonth = isBaseDateOnCenterWeek
    ? Math.floor((baseDate.date() - baseDate.isoWeekday() + 12) / 7)
    : 3;

  const range = Array(35)
    .fill()
    // 要素に日付を割り振る
    .map((_, i) =>
      dayjs(
        new Date(
          baseDate.year(),
          baseDate.month(),
          // 要素番号を日付とする
          // ※負数は前月、その月に存在しない日付は翌月の日付となる
          2 - firstDayOfMonth + (weekOfMonth - 3) * 7 + i
        )
      )
    );
  return range;
};

export const splitCalendarArrayByWeek = array => {
  // 7日×5週の2次元配列にする
  const calendar = [];
  array.forEach((_, i) => {
    if (i % 7 === 0) {
      // 7日ごとに切り出す
      calendar.push(array.slice(i, i + 7));
    }
  });
  return calendar;
};

export const createCalendarMonth = baseDate => {
  // mod FNSI-関 start
  // return Array(35)
  return Array(49)
  // mod FNSI-関 end
    .fill()
    .map((_, i) =>
      dayjs(baseDate)
        .startOf("month")
        .startOf("isoWeek")
        .add(i, "day")
    );
};

export const createCalendarWeek = (baseDate, numWeeks) => {
  return Array(7 * Math.abs(numWeeks))
    .fill()
    .map((_, i) => dayjs(baseDate).startOf("isoWeek").add(i, "day"));
};

export const createCalendarDayContents = (date, contents) => {
  let exists = contents.find(eventInDay => eventInDay.date === date);
  if (exists) {
    const filterList = exists.items.filter(item => item.routerLink);
    return filterList.map(i => i.content).join("\n");
  } else {
    return "";
  }
};