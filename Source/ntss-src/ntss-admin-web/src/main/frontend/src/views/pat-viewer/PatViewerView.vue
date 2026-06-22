<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      #bread-crumbs-content
      :history-key="historyKey"
      :no-split="true"
      @refresh="refresh"
    /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
        :no-split="true"
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
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/pat-viewer/PatViewer";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_PAT_VIEWER } from "@/router/pat-viewer/HistoryKeyConstants";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import {mapGetters, mapMutations} from "@/compat/vue/vuex";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end

/**
 * @description 患者経過総合ビューア
 */
export default {
  name: "PatViewerView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
  async beforeRouteLeave(to, from, next) {
    try {
      if (to.name != "signin" && !!this.isPatInfoChaned) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              this.setIsPatInfoChaned(false);
              next();
            }
          }
        });
      } else {
        next();
      }
    } catch (error) {
      getErrorMessage('PatViewerView.vue', 'beforeRouteLeave', error);
      next();
    }
  },
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  data() {
    return {
      historyKey: HISTORY_KEY_PAT_VIEWER
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
