/**
 * 治療状況リスト：透析液調製装置トレンドグラフページ
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
import HeaderComponent from "@/components/trend-graph/TrendGraphHeaderComponent";
import MainComponent from "@/components/trend-graph/TrendGraphMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_TREND_GRAPH } from "@/router/trend-graph/HistoryKeyConstants";

export default {
  name: "TrendGraphView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_TREND_GRAPH
    };
  }
};
</script>
