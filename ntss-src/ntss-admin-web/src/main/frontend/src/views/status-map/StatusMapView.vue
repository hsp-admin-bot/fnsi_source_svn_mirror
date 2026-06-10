/**
 * 治療状況マップページ
 */
<template>
  <ntss-layout-split>
    <header-component slot='header-content' :history-key="historyKey" v-show="!isDisplayFullMode"/>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" @refresh='refresh' v-show="!isDisplayFullMode"/> -->
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" v-show="!isDisplayFullMode"/>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout-split>
</template>

<script>
import MainComponent from "@/components/status-map/StatusMapMainComponent";
import HeaderComponent from "@/components/status-map/StatusMapHeaderComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_STATUS_MAP } from "@/router/status-map/HistoryKeyConstants";
import { mapGetters } from "vuex";

export default {
  name: "StatusMapView",
  components: {
    "main-component": MainComponent,
    "header-component": HeaderComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  computed: {
    ...mapGetters("status-map/map", ["isDisplayFullMode"])
  },
  mixins: [ViewHelper],
  beforeRouteLeave(to, from, next) {
    // 全画面モードの場合
    if (this.$refs.mainComponent && this.$refs.mainComponent.isDisplayFullMode) {
      // ヘッダ表示
      this.$refs.mainComponent.setDisplayFullMode();
      // フッター表示
      if (this.$refs.mainComponent.isFooterDisp === true) {
        this.$refs.mainComponent.setDispMenuBar(1);
      }
    }

    next();
  },
  data() {
    return {
      historyKey: HISTORY_KEY_STATUS_MAP
    };
  }
};
</script>
