<template>
  <ntss-layout>
    <header-component slot="header-content" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      @refresh="refresh"
      :no-split="true"
    /> -->
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split="true"
    />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component
      slot="main-content"
      ref="mainComponent"
      :history-key="historyKey"
    />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/facility-calendar/FacilityCalendarHeader.vue";
import MainComponent from "@/components/facility-calendar/FacilityCalendar.vue";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent.vue";
import ViewHelper from "@/views/ViewHelperMixin.js";
import { HISTORY_KEY_FACILITY_CALENDAR_LIST } from "@/router/facility-calendar/HistoryKeyConstants.js";

export default {
  name: "FacilityCalendarView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_FACILITY_CALENDAR_LIST
    };
  }
};
</script>
