/**
 * 観察記録ページ
 */
<template>
  <ntss-layout>
    <!-- add FNSI-顯示調整 関 start -->
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      #bread-crumbs-content
      :no-split="true"
      :history-key="historyKey"
      @refresh="refresh"
    /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :no-split="true"
        :history-key="historyKey"
      />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <!-- add FNSI-顯示調整 関 start -->
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout>
</template>

<script>
import ViewHelper from "@/views/ViewHelperMixin";
import MainComponent from "@/components/observe-record/ObserveRecordMainFrameComponent";
import { HISTORY_KEY_OBSERVE_RECORD_DETAIL, HISTORY_KEY_OBSERVE_RECORD_LIST } from "@/router/observe-record/HistoryKeyConstants";
// add FNSI-顯示調整 関 start
import HeaderComponent from "@/components/header-contents/PatHeader";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
import {mapGetters, mapMutations} from "@/compat/vue/vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
// add FNSI-顯示調整 関 start
export default {
  name: "MasterMainView",
  // mod FNSI-顯示調整 関 start
  components: {
    "header-component": HeaderComponent,
    "bread-crumbs-component": BreadCrumbsComponent,
    "main-component": MainComponent
  },
  // mod FNSI-顯示調整 関 start
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
      getErrorMessage('ObserveRecordMainView.vue', 'beforeRouteLeave', error);
      next();
    }
  },
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  data() {
    return {
      // mod FNSI-顯示調整 房 start
      historyKey: HISTORY_KEY_OBSERVE_RECORD_DETAIL
      // mod FNSI-顯示調整 房 end
    };
  },
  // mod FNSI-顯示調整 房 start
  created() {
    if (this.$route.name === "observe-record") {
      this.historyKey = HISTORY_KEY_OBSERVE_RECORD_LIST;
    } else {
      this.historyKey = HISTORY_KEY_OBSERVE_RECORD_DETAIL;
    }
  },
  // mod FNSI-顯示調整 房 end
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
