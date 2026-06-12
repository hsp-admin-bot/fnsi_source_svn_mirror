<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" />
    </template>
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/report-menu/ReportMenuListHeaderComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import MainComponent from "@/components/report-menu/ReportMenuListComponent";
import { HISTORY_KEY_REPORT_MENU_LIST } from "@/router/report-menu/HistoryKeyConstants";

export default {
  name: "ReportMenuListView",
  components: {
    "header-component": HeaderComponent,
    "bread-crumbs-component": BreadCrumbsComponent,
    "main-component": MainComponent
  },
  data() {
    return {
      historyKey: HISTORY_KEY_REPORT_MENU_LIST
    };
  }
};
</script>
