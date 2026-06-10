/**
 * 一般撮影検査依頼一覧
 */
<template>
  <ntss-layout>
    <header-component slot="header-content" />
    <bread-crumbs-component slot="bread-crumbs-content" :history-key="historyKey" :no-split="true" />
    <main-component slot="main-content" ref="mainComponent" :history-key="historyKey" :controller="controller" />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/rad-request/RadRequestHeaderComponent";
import MainComponent from "@/components/rad-request/RadRequestComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ExamRequestContollerMixin from "@/views/exam-request/ExamRequestContollerMixin";
import { HISTORY_KEY_RAD_REQUEST_LIST } from "@/router/rad-request/HistoryKeyConstants";

export default {
  name: "RadRequestListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ExamRequestContollerMixin],
  data() {
    return {
      historyKey: HISTORY_KEY_RAD_REQUEST_LIST
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
  }
};
</script>
