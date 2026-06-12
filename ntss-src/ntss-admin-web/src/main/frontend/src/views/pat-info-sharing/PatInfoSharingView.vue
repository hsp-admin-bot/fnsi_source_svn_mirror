<template>
  <shr-split-layout>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
        @refresh="refresh"
      />
    </template>
    <template #main-content>
      <main-component
        ref="mainComponent"
        :history-key="historyKey"
      />
    </template>
  </shr-split-layout>
</template>

<script>
import ShrSplitLayout from "@/views/pat-info-sharing/ShrSplitLayout";
import HeaderComponent from "@/components/pat-info-sharing/sharing/SharingHeaderComponent";
import MainComponent from "@/components/pat-info-sharing/sharing/SharingMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import { EventBus } from "@/compat/vue/event-bus.js";
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
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
  },
};
</script>
