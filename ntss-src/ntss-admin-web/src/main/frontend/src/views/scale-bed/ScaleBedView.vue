/**
 * スケールベッド一覧画面：スケールベッドページ
 */
<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" />
    </template>
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/views/scale-bed/ScaleBedListHeaderComponent";
import MainComponent from "@/components/scale-bed/ScaleBedListMainComponent.vue";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_SCALE_BED_LIST } from "@/router/scale-bed/HistoryKeyConstants";


export default {
  name: "ScaleBedListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_SCALE_BED_LIST
    };
  }
};
</script>
