<template>
  <ntss-layout-split>
    <header-component slot="header-content" />
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
    />
    <main-component
      slot="main-content"
      ref="mainComponent"
      :history-key="historyKey"
    />
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/daily-check/DailyInspectionHeaderComponent";
import MainComponent from "@/components/daily-check/DailyInspectionListComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import { HISTORY_KEY_DAILY_CHECK } from "@/router/daily-check/HistoryKeyConstants";

export default {
  name: "DailyCheckView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  data() {
    return {
      historyKey: HISTORY_KEY_DAILY_CHECK
    };
  },
};
</script>
