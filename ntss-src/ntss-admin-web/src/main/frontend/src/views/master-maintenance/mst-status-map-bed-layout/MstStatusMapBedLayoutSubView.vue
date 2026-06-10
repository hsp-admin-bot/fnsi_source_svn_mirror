/**
 * 治療状況ベッドレイアウトマスタ子画面用ページ
 */
<template>
  <ntss-layout>
    <header-component slot="header-content" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split="true"
      @refresh="refresh"
    /> -->
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split="true"
    />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot="main-content" ref="mainComponent" :history-key="historyKey" />
  </ntss-layout>
</template>

<script>
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import HeaderComponent from "@/components/master-maintenance/IndividualMasterHeaderComponent";
import MainComponent from "@/components/master-maintenance/mst-status-map-bed-layout/IndividualMasterComponentMstStatusMapBedLayout";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_MASTER_MAINTENANCE_EX_MAP_BED_LAYOUT } from "@/router/master-maintenance/HistoryKeyConstants";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "MstStatusMapBedLayoutSubView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_MASTER_MAINTENANCE_EX_MAP_BED_LAYOUT
    };
  },
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
    } catch(error) {
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
      getErrorMessage('MstStatusMapBedLayoutSubView.vue','beforeRouteLeave',error);
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
      next();
    }
  },
};
</script>
