/**
 * 装置記録詳細（分割表示なし、治療状況リスト/マップからの遷移用）
 */
<template>
  <ntss-layout>
    <header-component slot='header-content' />
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" />
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/operation-viewer/motion-records/MotionRecordsHeaderComponent";
import MainComponent from "@/components/operation-viewer/motion-record-details/MotionRecordDetailsMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_OPERATION_VIEWER_DETAIL } from "@/router/operation-viewer/HistoryKeyConstants";

export default {
  name: "MotionRecordDetailsView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_OPERATION_VIEWER_DETAIL
    };
  }
};
</script>
