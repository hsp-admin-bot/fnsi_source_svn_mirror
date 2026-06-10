/**
 * 稼働ビューア（施設一覧）
 */
<template>
  <ntss-layout-split>
    <header-component slot='header-content' />
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" />
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/operation-viewer/facilities/FacilitiesHeaderComponent";
import MainComponent from "@/components/operation-viewer/facilities/FacilitiesMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_OPERATION_VIEWER_FACILITY } from "@/router/operation-viewer/HistoryKeyConstants";

export default {
  name: "FacilitiesView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_OPERATION_VIEWER_FACILITY
    };
  }
};
</script>
