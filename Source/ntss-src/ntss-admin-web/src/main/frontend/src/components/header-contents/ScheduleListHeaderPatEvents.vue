<template>
  <div class="pat-events-container">
    <div class="item" v-for="(event, eventIndex) in patEvents" :key="eventIndex">
      {{ formatDate(event.eventStartDate) }} {{ event.eventStartTime }}
      <span
        v-if="event.eventEndDate !== null"
      >～ {{ formatDate(event.eventEndDate) }} {{ event.eventEndTime }}</span>
      {{ event.subCategoryName }}
    </div>
  </div>
</template>

<script>
// ライブラリ
import { mapGetters } from "@/compat/vue/vuex";
//日付処理用
import dayjs from "@/compat/date/dayjs";

export default {
  computed: {
    ...mapGetters("schedule-list", ["getHeaderDispInfo", "getPatEvents"]),
    patEvents() {
      let list = [];
      let startDate = 0;
      let endDate = 0;
      if (this.getHeaderDispInfo && this.getHeaderDispInfo.treatDate) {
        const treatDate = dayjs(this.getHeaderDispInfo.treatDate, "YYYYMMDD");
        this.getPatEvents.forEach(item => {
          startDate = dayjs(item.eventStartDate)
              .hours(0)
              .minutes(0)
              .seconds(0)
              .milliseconds(0);
          endDate = dayjs(item.eventEndDate)
              .add(1, "d")
              .hours(0)
              .minutes(0)
              .seconds(0)
              .milliseconds(0);
          if (
              treatDate.isSameOrAfter(startDate) &&
              (treatDate.isBefore(endDate) || item.eventEndDate === null)
          ) {
            list.push(item);
          }
        });
      }

      return list;
    }
  },
  methods: {
    formatDate(date) {
      const mDate = dayjs(date);

      if (mDate.hours() === 0 && mDate.minutes() === 0) {
        return mDate.format("M/DD");
      }

      return mDate.format("M/DD H:mm");
    }
  }
};
</script>

<style scoped>
.pat-events-container {
  padding: 10px;
  font-size: 1.2em;
  overflow: auto;
  max-height: 600px;
}
.pat-events-container .item {
  margin-bottom: 5px;
}
</style>
