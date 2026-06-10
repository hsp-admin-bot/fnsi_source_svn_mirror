/**
 * 検査依頼一覧
 */
<template>
  <ntss-layout>
    <header-component slot="header-content" />
    <bread-crumbs-component slot="bread-crumbs-content" ref="breadCrumbsComponent" :history-key="historyKey" :no-split="true" />
    <main-component slot="main-content" ref="mainComponent" :history-key="historyKey" :controller="controller" />
  </ntss-layout>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import HeaderComponent from "@/components/exam-request/ExamRequestHeaderComponent";
import MainComponent from "@/components/exam-request/ExamRequestComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import { EXAM_REQUEST } from "@/constants/defaultSettingConstants";
import ExamRequestContollerMixin from "@/views/exam-request/ExamRequestContollerMixin";
import { HISTORY_KEY_EXAM_REQUEST_LIST } from "@/router/exam-request/HistoryKeyConstants";

export default {
  name: "ExamRequestListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ExamRequestContollerMixin],
  data() {
    return {
      historyKey: HISTORY_KEY_EXAM_REQUEST_LIST
    };
  },
  async beforeRouteLeave(to, _from, next) {
    if (await this.controller.confirmAllowDiscardChangesForBeforeRouteLeave(to.name)) {
      // キャンセルされなかった場合
      next();
    } else {
      // キャンセルされた場合
      next(false);
    }
  },
  computed: {
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    ...mapGetters("exam-request/daily", ["getPeriodType"]),
  },
  methods: {
    ...mapActions("exam-request/daily", ["setPeriodType"])
  },
  created() {
    // 初回表示時、Store未設定のため、個人設定＞デフォルト設定読み込み
    if (!this.getPeriodType) {
      const defaultPeriodType = this.getDefaultSetting[EXAM_REQUEST.KEY_NAME]?.[EXAM_REQUEST.KEY_NAME_PERIOD_TYPE];
      this.setPeriodType(defaultPeriodType || 1);
    }
  },
};
</script>
