import moment from "moment";

const makeDateTime = (date, time) => ({ date, time });
const makeFromTo = (from, to) => ({ from, to });
// modify 9583 by kangjie 20240404 start
// const makeFromToDateTime = (fromDate, fromTime, toDate, toTime) => makeFromTo(
export const makeFromToDateTime = (fromDate, fromTime, toDate, toTime) => makeFromTo(
// modify 9583 by kangjie 20240404 end
  makeDateTime(fromDate, fromTime),
  makeDateTime(toDate, toTime)
);

export const makeDefaultCondition = () => {
  const sysDateTime = moment();
  const sysDate = sysDateTime.format("YYYY-MM-DD");
  const startTime = "00:00";
  return {
    limit: 100,
    coopCd: [],
    direction: ["S", "R"],
    anaResult: ["E1", "E2"],
    coopResult: ["E1", "E2"],
    date: makeFromToDateTime(sysDate, startTime, null, null),
    regDate: makeFromToDateTime(null, null, null, null),
    baseDate: makeFromToDateTime(null, null, null, null),
    content: "",
  };
};
