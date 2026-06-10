<template>
  <ntss-layout>
    <header-component slot="header-content" />
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split="true"
      @refresh="refresh"
    />
    <main-component
      slot="main-content"
      ref="mainComponent"
      :history-key="historyKey"
    />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/cache-test/CacheTestComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_CACHE_TEST } from "@/router/cache-test/HistoryKeyConstants";

/**
 * @description キャッシュテスト画面
 */

export default {
  name: "CacheTestView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_CACHE_TEST
    };
  }
};
</script>
