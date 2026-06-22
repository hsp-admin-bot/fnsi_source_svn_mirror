/**
 * 検査依頼一覧用メイン
 */
<template>
  <component
    :is="currentBodyComponent"
    class="exam-request-body-item"
    :history-key="historyKey"
    :controller="controller"
  />
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import ExamRequestDailyComponent from "@/components/exam-request/ExamRequestDailyComponent.vue";
import ExamRequestPeriodComponent from "@/components/exam-request/ExamRequestPeriodComponent.vue";

export default {
  name: "ExamRequestComponent",
  components: {
    ExamRequestDailyComponent,
    ExamRequestPeriodComponent,
  },
  props: {
    historyKey: {
      type: String,
      required: true,
    },
    controller: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapGetters("exam-request/daily", ["getPeriodType"]),
    currentBodyComponent() {
      switch (this.getPeriodType) {
        case 1:
          return "ExamRequestPeriodComponent";
        case 2:
          return "ExamRequestDailyComponent";
        default:
          return "ExamRequestPeriodComponent";
      }
    },
  },
};
</script>

<style scoped>
.exam-request-body-item {
  width: 100%;
}
</style>
