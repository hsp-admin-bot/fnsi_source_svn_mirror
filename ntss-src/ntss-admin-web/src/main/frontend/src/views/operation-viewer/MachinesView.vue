/**
 * 稼働ビューア
 */
<template>
  <ntss-layout-split>
    <header-component slot='header-content' />
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" />
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/operation-viewer/machines/MachinesHeaderComponent";
import MainComponent from "@/components/operation-viewer/machines/MachinesMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_OPERATION_VIEWER_MACHINE } from "@/router/operation-viewer/HistoryKeyConstants";

export default {
  name: "MachinesView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_OPERATION_VIEWER_MACHINE
    };
  }
};
</script>
