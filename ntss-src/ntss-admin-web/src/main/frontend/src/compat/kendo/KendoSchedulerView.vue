<script>
export default {
  name: "KendoSchedulerView",
  inheritAttrs: false,
  props: {
    type: { type: String, default: "day" },
    title: { type: String, default: undefined },
    selected: { type: Boolean, default: false },
    majorTick: { type: [Number, String], default: undefined },
    minorTickCount: { type: [Number, String], default: undefined },
    startTime: { type: Date, default: undefined },
    endTime: { type: Date, default: undefined },
    workDayStart: { type: Date, default: undefined },
    workDayEnd: { type: Date, default: undefined },
    workWeekStart: { type: [Number, String], default: undefined },
    workWeekEnd: { type: [Number, String], default: undefined }
  },
  computed: {
    schedulerViewOptions() {
      const options = { ...this.$attrs, type: this.type };
      [
        "title",
        "selected",
        "majorTick",
        "minorTickCount",
        "startTime",
        "endTime",
        "workDayStart",
        "workDayEnd",
        "workWeekStart",
        "workWeekEnd"
      ].forEach((key) => {
        if (this[key] !== undefined) {
          options[key] = this[key];
        }
      });
      return options;
    }
  },
  render() {
    return null;
  }
};
</script>
