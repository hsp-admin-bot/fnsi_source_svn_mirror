/**
 * 検査依頼一覧用ヘッダ
 */
<template>
  <v-card>
    <component
      :is="currentHeaderComponent"
      class="exam-request-header-item"
    />
  </v-card>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import ExamRequestDailyHeaderComponent from "@/components/exam-request/ExamRequestDailyHeaderComponent.vue";
import ExamRequestPeriodHeaderComponent from "@/components/exam-request/ExamRequestPeriodHeaderComponent.vue";

export default {
  name: "ExamRequestHeaderComponent",
  components: {
    ExamRequestDailyHeaderComponent,
    ExamRequestPeriodHeaderComponent,
  },
  computed: {
    ...mapGetters("exam-request/daily", ["getPeriodType"]),
    currentHeaderComponent() {
      switch (this.getPeriodType) {
        case 1:
          return "ExamRequestPeriodHeaderComponent";
        case 2:
          return "ExamRequestDailyHeaderComponent";
        default:
          return "ExamRequestPeriodHeaderComponent";
      }
    },
  },
};
</script>

<style scoped>
.exam-request-header-item {
  width: 100%;
}
</style>
