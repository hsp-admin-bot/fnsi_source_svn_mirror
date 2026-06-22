/**
 * 治療状況リスト：装置一覧ページ
 */
<template>
  <ntss-layout-split>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" @refresh='refresh' /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/status-list/StatusListAlarmHeaderComponent";
import MainComponent from "@/components/status-list/StatusListAlarmComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_STATUS_LIST_ALARM } from "@/router/status-list/HistoryKeyConstants";

export default {
  name: "StatusListAlarmView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_STATUS_LIST_ALARM
    };
  }
};
</script>
