/**
 * 治療状況リスト：大画面表示ページ
 */
<template>
  <ntss-layout-split>
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout-split>
</template>

<script>
import MainComponent from "@/components/status-list/large-display/StatusListLargeDispMainComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_STATUS_LIST_LARGEDISP } from "@/router/status-list-large/HistoryKeyConstants";

export default {
  name: "StatusListLargeDispView",
  components: {
    "main-component": MainComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_STATUS_LIST_LARGEDISP
    };
  }
};
</script>
