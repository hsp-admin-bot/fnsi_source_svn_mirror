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
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/facility-home-dialysis/FacilityHomeDialysisComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_FACILITY_HOME_DIALYSIS } from "@/router/facility-home-dialysis/HistoryKeyConstants";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import {mapGetters, mapMutations} from "vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

/**
 * @description 患者情報画面
 */

export default {
  name: "HomeDialysisInstrView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  beforeRouteLeave(to, from, next) {
    // if (this.$refs.mainComponent && this.$refs.mainComponent.selectedPatId && this.$refs.mainComponent.isEdit) {
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    // if (to.name != "signin" && this.$refs.mainComponent && this.$refs.mainComponent.selectedPatId && this.$refs.mainComponent.isEdit) {
    if (to.name != "signin" &&
        (this.$refs.mainComponent && this.$refs.mainComponent.selectedPatId && this.$refs.mainComponent.isEdit
        || !!this.isPatInfoChaned)) {
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
          if (answer === 1) {
            this.setIsPatInfoChaned(false);
            next();
          }
          // next(answer === 1);
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
        }
      });
    } else {
      next();
    }
  },
  data() {
    return {
      historyKey: HISTORY_KEY_FACILITY_HOME_DIALYSIS
    };
  },
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
  computed: {
    ...mapGetters("pat-info", ["isPatInfoChaned"]),
  },
  methods: {
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
  }
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
};
</script>
