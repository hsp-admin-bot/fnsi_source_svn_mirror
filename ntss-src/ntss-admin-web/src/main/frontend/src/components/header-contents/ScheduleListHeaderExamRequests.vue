<template>
  <!--mod FNSI-画面部品デザイン じょはく start-->
  <!--<div class="exam-requests-container">-->
  <div class="exam-requests-container fab-font-color">
    <!--mod FNSI-画面部品デザイン じょはく end-->
    <div
      class="item"
      v-for="(exam, examIndex) in examRequests"
      :key="examIndex"
    >{{ exam.name + exam.className }}</div>
  </div>
</template>

<script>
// ライブラリ
import { mapGetters } from "@/compat/vue/vuex";
//日付処理用
import dayjs from "@/compat/date/dayjs";

export default {
  data() {
    return {
      // 1:透析前 2:透析後 0:その他 の順で表示
      showRegOrderClass: {
        "1": "(前)",
        "2": "(後)",
        "0": "(他)"
      }
    };
  },
  computed: {
    ...mapGetters("schedule-list", ["getHeaderDispInfo", "getExamRequests"]),
    examRequests() {
      let list = [];
      this.getExamRequests.forEach(exam => {
        if (
          dayjs(exam.regExamDate).format("YYYYMMDD") ===
          this.getHeaderDispInfo.treatDate
        ) {
          list = [
            ...list,
            ...JSON.parse(exam.orderExamSetInfo).map(item => ({
              name: item.set_name,
              cd: item.set_cd,
              className: this.showRegOrderClass[exam.regOrderClass]
            }))
          ];
        }
      });

      return list.sort((a, b) => a.cd - b.cd);
    }
  }
};
</script>

<style scoped>
.exam-requests-container {
  padding: 10px;
  font-size: 1.5em;
  overflow: auto;
  max-height: 600px;
}
.exam-requests-container .item {
  margin-bottom: 5px;
}
</style>
