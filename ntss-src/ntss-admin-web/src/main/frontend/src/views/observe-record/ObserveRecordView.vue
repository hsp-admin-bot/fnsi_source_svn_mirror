/**
 * 観察記録ページ
 */
<!--
/**
 * *************************************************************
 * NOTE: 分割表示に戻す際は、<ntss-layout>タグを<ntss-layout-split>に変更する
 *       また、router.indexのOBSERVE_RECORDの内容をコメントアウトのJSONに変更し、
 *       参照されなくなったOBSERVE_RECORD_LIST関係の要素を削除する
 * **************************************************************
 */
 -->
<template>
  <ntss-layout-content>
    <!-- mod FNSI-顯示調整 関 start -->
    <!-- <header-component slot="header-content" />
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :no-split="true"
      :history-key="historyKey"
      @refresh="refresh"
    /> -->
    <!-- mod FNSI-顯示調整 関 end -->
    <main-component slot="main-content" ref="mainComponent" :history-key="historyKey" />
  </ntss-layout-content>
</template>

<script>
// mod FNSI-顯示調整 関 start
// import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/observe-record/ObserveRecordMainComponent";
// import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
// mod FNSI-顯示調整 関 end
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_OBSERVE_RECORD_LIST } from "@/router/observe-record/HistoryKeyConstants";

export default {
  name: "ObserveRecordListView",
  // mod FNSI-顯示調整 関 start
  components: {
    // "header-component": HeaderComponent,
    // "main-component": MainComponent,
    // "bread-crumbs-component": BreadCrumbsComponent
    "main-component": MainComponent
  },
  // mod FNSI-顯示調整 関 end
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_OBSERVE_RECORD_LIST
    };
  }
};
</script>
