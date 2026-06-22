/**
 * デバイスエッジ稼働監視
 */
<template>
  <ntss-layout-split>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" />
    </template>
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/device-edge-operation/manage/DeviceEdgeManageHeaderComponent";
import MainComponent from "@/components/device-edge-operation/manage/DeviceEdgeManageMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_DEVICE_EDGE_MANAGE } from "@/router/device-edge-operation/HistoryKeyConstants";

export default {
  name: "DeviceEdgeOperationView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_DEVICE_EDGE_MANAGE
    };
  }
};
</script>
