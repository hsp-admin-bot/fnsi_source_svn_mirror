/**
 * 体重計マスタ子画面用ページ
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
import HeaderComponent from "@/components/master-maintenance/IndividualMasterHeaderComponent";
import MainComponent from "@/components/master-maintenance/mst-weight/sub-item/MstWeightComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_MASTER_MAINTENANCE_EX_WEIGHT } from "@/router/master-maintenance/HistoryKeyConstants";

export default {
  name: "MstWeightSubView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_MASTER_MAINTENANCE_EX_WEIGHT
    };
  }
};
</script>
