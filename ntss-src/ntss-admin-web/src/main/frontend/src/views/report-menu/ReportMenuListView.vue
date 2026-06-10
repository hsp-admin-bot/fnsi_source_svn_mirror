<template>
  <ntss-layout>
    <header-component slot="header-content" />
    <bread-crumbs-component slot="bread-crumbs-content" :history-key="historyKey" />
    <main-component slot="main-content" ref="mainComponent" :history-key="historyKey" />
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