<template>
  <div class="rad-requests-container">
    <div
      class="item"
      v-for="(rad, radIndex) in radRequests"
      :key="radIndex"
    >{{ rad.time }} {{ rad.name }}</div>
  </div>
</template>

<script>
// ライブラリ
import { mapGetters } from "@/compat/vue/vuex";
//日付処理用
import dayjs from "@/compat/date/dayjs";

export default {
  computed: {
    ...mapGetters("schedule-list", ["getHeaderDispInfo", "getRadRequests"]),
    radRequests() {
      let list = [];
      this.getRadRequests.forEach(rad => {
        if (
          dayjs(rad.regRadDate).format("YYYYMMDD") ===
          this.getHeaderDispInfo.treatDate
        ) {
          list = [
            ...list,
            ...JSON.parse(rad.orderRadSetInfo).map(item => ({
              name: item.rad_set_name,
              time: this.formatTime(rad.regRadDate)
            }))
          ];
        }
      });

      return list;
    }
  },
  methods: {
    formatTime(date) {
      return dayjs(date).format("HH:mm");
    }
  }
};
</script>

<style scoped>
.rad-requests-container {
  padding: 10px;
  font-size: 1.5em;
  overflow: auto;
  max-height: 600px;
}
.rad-requests-container .item {
  margin-bottom: 5px;
}
</style>
