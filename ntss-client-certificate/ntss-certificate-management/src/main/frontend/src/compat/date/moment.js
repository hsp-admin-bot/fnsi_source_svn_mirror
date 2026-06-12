import dayjs from "dayjs";

function createMoment(value) {
  const instance = value === undefined ? dayjs() : dayjs(value);
  return {
    format(pattern) {
      return instance.format(pattern);
    },
    isValid() {
      return instance.isValid();
    },
    toDate() {
      return instance.toDate();
    },
    valueOf() {
      return instance.valueOf();
    }
  };
}

createMoment.utc = value => createMoment(value);
createMoment.isMoment = value => !!value && typeof value.format === "function";

export default createMoment;
