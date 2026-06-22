<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      #bread-crumbs-content
      :history-key="historyKey"
      @refresh="refresh"
    /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
      />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component ref="mainComponent"
        :history-key="historyKey"
      />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/BbsHeader";
import MainComponent from "@/components/bbs-info/BbsInfoContent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_BBS_INFO } from "@/router/bbs-info/HistoryKeyConstants";

/**
 * @description 掲示板一覧情報
 */
export default {
  name: "BbsInfoView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_BBS_INFO
    };
  }
};
</script>
