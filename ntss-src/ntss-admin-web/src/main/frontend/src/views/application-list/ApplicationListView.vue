/**
 * 申込一覧
 */
<template>
  <ntss-layout-split>
    <header-component slot='header-content' />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" @refresh='refresh' /> -->
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/application-list/ApplicationListHeaderComponent";
import MainComponent from "@/components/application-list/ApplicationListMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_APPLICATION_LIST } from "@/router/application-list/HistoryKeyConstants";

export default {
  name: "ApplicationListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_APPLICATION_LIST
    };
  }
};
</script>
