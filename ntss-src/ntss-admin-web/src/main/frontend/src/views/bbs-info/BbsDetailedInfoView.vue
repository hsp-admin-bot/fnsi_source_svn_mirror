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
    <main-component
      slot="main-content"
      ref="mainComponent"
      :history-key="historyKey"
    />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/BbsDetailedHeader";
import MainComponent from "@/components/bbs-info/BbsDetailedInfoContent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import {HISTORY_KEY_BBS_DETAILED_INFO } from "@/router/bbs-info/HistoryKeyConstants";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

/**
 * @description 掲示板詳細情報
 */
export default {
  name: "BbsDetailedInfoView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],

  beforeRouteLeave(to, from, next) {
    // ダウンロードエラー時にサインイン画面へ移動する際に下記のメッセージを表示させない
    const isDownload = this.$refs.mainComponent.$refs.fileDownloader.isDownload;
    const isUpdated = this.$refs.mainComponent.$refs.fileUploader.isUpdated;
// add FNSI-改修内容 詳細画面で修正がない場合、キャンセルしても、内容を廃棄のメッセージが出てしまう dou start
    const isChanged = this.$refs.mainComponent.$refs.isChanged;
// add FNSI-改修内容 詳細画面で修正がない場合、キャンセルしても、内容を廃棄のメッセージが出てしまう dou end

    if (
// add FNSI-改修内容 詳細画面で修正がない場合、キャンセルしても、内容を廃棄のメッセージが出てしまう dou start
      isChanged &&
// add FNSI-改修内容 詳細画面で修正がない場合、キャンセルしても、内容を廃棄のメッセージが出てしまう dou end
      this.$refs.mainComponent &&
      !this.$refs.mainComponent.isNotEdited &&
      !isDownload &&
      !isUpdated
    ) {
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
  },

  data() {
    return {
      historyKey: HISTORY_KEY_BBS_DETAILED_INFO
    };
  }
};
</script>
