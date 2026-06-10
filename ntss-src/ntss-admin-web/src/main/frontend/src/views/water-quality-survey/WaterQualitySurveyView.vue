/**
 * 水質調査
 */
<template>
  <ntss-layout>
    <header-component slot='header-content' />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" :no-split="true" @refresh='refresh' /> -->
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" :no-split="true" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/water-quality-survey/WaterQualitySurveyHeaderComponent";
import MainComponent from "@/components/water-quality-survey/WaterQualitySurveyComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_WATER_QUALITY_SURVEY } from "@/router/water-quality-survey/HistoryKeyConstants";

export default {
  name: "WaterQualitySurvey",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_WATER_QUALITY_SURVEY
    };
  }
};
</script>
