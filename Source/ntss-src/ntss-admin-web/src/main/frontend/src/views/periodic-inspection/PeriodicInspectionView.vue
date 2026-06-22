<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>

    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
        :no-split="true"
      />
    </template>
    <template #main-content>
      <main-component ref="mainComponent"
        :history-key="historyKey"
      />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/periodic-inspection/PeriodicInspectionHeader";
import MainComponent from "@/components/periodic-inspection/PeriodicInspectionMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import { HISTORY_KEY_PERIODIC_INSPECTION } from "@/router/periodic-inspection/HistoryKeyConstants";

export default {
  name: "PeriodicInspectionView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  data() {
    return {
      historyKey: HISTORY_KEY_PERIODIC_INSPECTION
    };
  },

};
</script>
