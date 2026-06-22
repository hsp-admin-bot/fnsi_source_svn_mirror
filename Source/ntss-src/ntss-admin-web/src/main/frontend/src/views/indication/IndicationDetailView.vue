<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" :no-split="true" />
    </template>
    <template #main-content>
      <main-component ref="mainComponent" />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/indications/IndicationDetailComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import { HISTORY_KEY_INDICATION_DETAIL } from "@/router/indication/HistoryKeyConstants";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import {mapGetters, mapMutations} from "@/compat/vue/vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end

export default {
  name: "IndicationReceiveApproveView",
  components: {
    "header-component": HeaderComponent,
    "bread-crumbs-component": BreadCrumbsComponent,
    "main-component": MainComponent
  },
  beforeRouteLeave(to, from, next) {
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
    const isDirty = this.$refs.mainComponent?.isDirty;
    const skipRoute = this.$refs.mainComponent?.skipRoute;
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    // if (!skipRoute && !isDirty) {
    if (!skipRoute && !isDirty || !!this.isPatInfoChaned) {
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
      this.$ons.notification.confirm({
        title: DIALOG_MESSAGES[13000004].title,
        message: DIALOG_MESSAGES[13000004].message,
        callback: answer => {
          if (answer === 1) {
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
            this.setIsPatInfoChaned(false);
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
            next();
          } else {
            // キャンセル時は遷移を明示的に中断しないと、次回の beforeRouteLeave が発火しなくなる
            next(false);
          }
        }
      });
    } else {
      next();
    }
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
  },
  data() {
    return {
      historyKey: HISTORY_KEY_INDICATION_DETAIL
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

<style scoped>
/* 患者共通ヘッダーにも適用されてしまうので、範囲を限定する */
.content-container :deep(#main-id *) {
  box-sizing: border-box;
}
</style>
