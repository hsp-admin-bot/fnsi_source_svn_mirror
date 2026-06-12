/**
 * 一般撮影検査依頼
 */
<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" :no-split="true" />
    </template>
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" :controller="controller" />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/rad-request/RadRequestDetailComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ExamRequestContollerMixin from "@/views/exam-request/ExamRequestContollerMixin";
import { HISTORY_KEY_RAD_REQUEST_DETAIL } from "@/router/rad-request/HistoryKeyConstants";

export default {
  name: "RadRequestDetailView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ExamRequestContollerMixin],
  data() {
    return {
      historyKey: HISTORY_KEY_RAD_REQUEST_DETAIL
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
};
</script>
