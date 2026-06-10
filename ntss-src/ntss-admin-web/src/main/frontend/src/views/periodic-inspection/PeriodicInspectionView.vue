<template>
  <ntss-layout>
    <header-component slot="header-content" />

    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split="true"
    />
    <main-component
      slot="main-content"
      ref="mainComponent"
      :history-key="historyKey"
    />
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
