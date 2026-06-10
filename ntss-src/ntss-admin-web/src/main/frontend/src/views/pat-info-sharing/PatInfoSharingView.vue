<template>
  <shr-split-layout>
    <header-component slot="header-content" />
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      @refresh="refresh"
    />
    <main-component
      slot="main-content"
      ref="mainComponent"
      :history-key="historyKey"
    />
  </shr-split-layout>
</template>

<script>
import ShrSplitLayout from "@/views/pat-info-sharing/ShrSplitLayout";
import HeaderComponent from "@/components/pat-info-sharing/sharing/SharingHeaderComponent";
import MainComponent from "@/components/pat-info-sharing/sharing/SharingMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import { EventBus } from "@/eventBus.js";
import { HISTORY_KEY_PAT_INFO_SHARING } from "@/router/pat-info-sharing/HistoryKeyConstants";

export default {
  name: "PatInfoSharingView",
  components: {
    "shr-split-layout": ShrSplitLayout,
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent,
  },
  data() {
    return {
      historyKey: HISTORY_KEY_PAT_INFO_SHARING,
    };
  },
  methods: {
    refresh(arg) {
      if (arg === this.historyKey) {
        if (
          this.$refs.mainComponent &&
          typeof this.$refs.mainComponent.refresh === "function"
        ) {
          this.$refs.mainComponent.refresh();
        }
      }
    },
  },
  created() {
    EventBus.$on("refresh", this.refresh);
  },
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
  },
};
</script>
