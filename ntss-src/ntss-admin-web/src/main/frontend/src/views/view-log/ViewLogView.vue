<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      #bread-crumbs-content
      :no-split="true"
      :history-key="historyKey"
      @refresh="refresh"
    /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :no-split="true"
        :history-key="historyKey"
      />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component ref="mainComponent"
        :history-key="historyKey"
      />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/ViewLogHeader.vue";
import MainComponent from "@/components/view-log/ViewLog.vue";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent.vue";
import ViewHelper from "@/views/ViewHelperMixin.js";
import { HISTORY_KEY_VIEW_LOG } from "@/router/view-log/HistoryKeyConstants.js";

export default {
  name: "ViewLogView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_VIEW_LOG
    };
  }
};
</script>
