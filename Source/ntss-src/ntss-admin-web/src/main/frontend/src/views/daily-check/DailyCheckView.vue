<template>
  <ntss-layout-split>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" />
    </template>
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
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
