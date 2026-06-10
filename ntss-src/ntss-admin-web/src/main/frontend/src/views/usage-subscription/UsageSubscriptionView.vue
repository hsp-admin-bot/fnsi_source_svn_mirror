/**
 * 利用申込
 */
<template>
  <ntss-layout-split>
    <header-component slot='header-content' />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" @refresh='refresh' /> -->
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/usage-subscription/UsageSubscriptionHeaderComponent";
import MainComponent from "@/components/usage-subscription/UsageSubscriptionMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_USAGE_SUBSCRIPTION } from "@/router/usage-subscription/HistoryKeyConstants";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "UsageSubscriptionView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  // add 利用申込 データを更新してマスタ一覧リンクを押下した後、メッセージが表示されない 孔s start
  beforeRouteLeave(to, from, next) {
    try {
      // #10053 dou start
      // if (this.$refs.mainComponent && this.$refs.mainComponent.isChanged) {
      if (to.name != "signin" && this.$refs.mainComponent && this.$refs.mainComponent.isChanged) {
        // #10053 dou end
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            next(answer === 1);
          }
        });
      } else {
        next();
      }
    } catch (error){
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
      getErrorMessage('UsageSubscriptionView.vue','beforeRouteLeave',error);
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
      next();
    }
  },
  // add 利用申込 データを更新してマスタ一覧リンクを押下した後、メッセージが表示されない 孔s end
  data() {
    return {
      historyKey: HISTORY_KEY_USAGE_SUBSCRIPTION
    };
  }
};
</script>
