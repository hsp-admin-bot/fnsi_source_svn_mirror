<template>
  <ntss-layout>
    <header-component slot="header-content" ref="headerComponent"/>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot="bread-crumbs-content" :history-key="historyKey" :no-split="true" @refresh='refresh'/> -->
    <bread-crumbs-component slot="bread-crumbs-content" :history-key="historyKey" :no-split="true" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot="main-content" ref="mainComponent" :history-key="historyKey" />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/indications/IndicationListHeaderComponent";
import MainComponent from "@/components/indications/IndicationListComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import { HISTORY_KEY_INDICATION_LIST } from "@/router/indication/HistoryKeyConstants";

export default {
  name: "IndicationListView",
  components: {
    "header-component": HeaderComponent,
    "bread-crumbs-component": BreadCrumbsComponent,
    "main-component": MainComponent
  },
  data() {
    return {
      historyKey: HISTORY_KEY_INDICATION_LIST
    };
  },
  // add 6299 指示受け・指示承認画面を開くたびに、患者の表示順が勝手に入れ替わる 張 start
    methods: {
    // リフレッシュ処理（パンくずリストクリック時の画面再描画）
    refresh() {
      if (typeof this.$refs.headerComponent.refresh === "function") {
        this.$refs.headerComponent.refresh();
      }
    }
  }
    // add 6299 指示受け・指示承認画面を開くたびに、患者の表示順が勝手に入れ替わる 張 end
};
</script>

<style scoped>
.content-container >>> * {
  box-sizing: border-box;
}
</style>
