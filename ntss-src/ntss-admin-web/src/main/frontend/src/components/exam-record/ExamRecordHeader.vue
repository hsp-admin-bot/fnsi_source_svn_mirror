/**
 * 検査結果用共通ヘッダ
 */
<template>
  <div>
    <template v-if="isListHeaderView === true">
      <exam-record-header-component></exam-record-header-component>
    </template>
    <template v-if="isListHeaderView === false">
      <pat-header-component></pat-header-component>
    </template>
  </div>
</template>

<script>
import patHeader from "@/components/header-contents/PatHeader";
import examRecordHeader from "@/components/exam-record/ExamRecordHeaderComponent";

export default {
  components: {
    "pat-header-component": patHeader,
    "exam-record-header-component": examRecordHeader
  },
  computed: {
    /**
     * ヘッダの表示状態(true:検査結果一覧,false:検査結果)
     */
    isListHeaderView() {
      const isDetailHeaderView = this.$route.fullPath.startsWith(
        "/exam-record/detail"
      );
      return !isDetailHeaderView;
    }
  },
  methods: {},
  mounted() {},
  created() {},
  destroyed() { },
  watch: {}
};
</script>
