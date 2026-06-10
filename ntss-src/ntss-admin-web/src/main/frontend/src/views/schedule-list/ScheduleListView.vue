/**
 * スケジュール表
 */
<template>
  <ntss-layout>
    <!--mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start-->
<!--    <header-component slot='header-content' ref='headerComponent' />-->
    <header-component slot='header-content' ref='headerComponent' />
    <!--mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end-->
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" :no-split="true" @refresh='refresh' /> -->
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" :no-split="true" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/ScheduleListHeader";
import MainComponent from "@/components/schedule-list/ScheduleListMainItem";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_SCHEDULE_LIST } from "@/router/schedule-list/HistoryKeyConstants";

export default {
  name: "ScheduleListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_SCHEDULE_LIST
    };
  }
};
</script>
