 <!-- 処方箋 -->
<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" :no-split="true" @refresh='refresh' />
    </template> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" :no-split="true" />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/prescription/PrescriptionHeaderComponent";
import MainComponent from "@/components/prescription/PrescriptionListComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_PRESCRIPTION_LIST } from "@/router/prescription/HistoryKeyConstants";

export default {
  name: "PrescriptionView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_PRESCRIPTION_LIST
    };
  }
};
</script>
