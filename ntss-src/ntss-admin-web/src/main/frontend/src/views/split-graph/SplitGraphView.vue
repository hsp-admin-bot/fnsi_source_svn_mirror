<template>
  <ntss-layout>
    <header-component slot="header-content" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      slot="bread-crumbs-content"
      :no-split="true"
      :history-key="historyKey"
      @refresh="refresh"
    /> -->
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :no-split="true"
      :history-key="historyKey"
    />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot="main-content" ref="mainComponent" :history-key="historyKey" />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/split-graph/SplitGraphHeader.vue";
import MainComponent from "@/components/split-graph/SplitGraphComponent.vue";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent.vue";
import ViewHelper from "@/views/ViewHelperMixin.js";
import { HISTORY_KEY_SPLIT_GRAPH } from "@/router/split-graph/HistoryKeyConstants.js";

export default {
  name: "SplitGraphView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_SPLIT_GRAPH
    };
  }
};
</script>
