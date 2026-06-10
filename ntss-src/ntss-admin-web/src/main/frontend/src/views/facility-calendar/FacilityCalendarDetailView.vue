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
// mod 5878 施設カレンダーから施設イベント画面を開いた際、ヘッダーが他の画面と異なる 関 start
// import HeaderComponent from "@/components/facility-calendar/FacilityCalenderEdit.vue";
import HeaderComponent from "@/components/header-contents/BbsDetailedHeader";
// mod 5878 施設カレンダーから施設イベント画面を開いた際、ヘッダーが他の画面と異なる 関 end
import MainComponent from "@/components/bbs-info/BbsDetailedInfoContent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent.vue";
import ViewHelper from "@/views/ViewHelperMixin.js";
import { HISTORY_KEY_FACILITY_CALENDAR_DETAIL } from "@/router/facility-calendar/HistoryKeyConstants.js";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "FacilityCalendarDetailView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
// add FNSI-改修内容 施設イベント詳細画面で、内容を編集しても、キャンセルで内容を廃棄のメッセージが出てこない dou start
  beforeRouteLeave(to, from, next) {
    // ダウンロードエラー時にサインイン画面へ移動する際に下記のメッセージを表示させない
    const isChanged = this.$refs.mainComponent.$refs.isChanged;
    // #10053 dou start
    // if (isChanged) {
    if (to.name != "signin" && isChanged) {
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
  },
// add FNSI-改修内容 施設イベント詳細画面で、内容を編集しても、キャンセルで内容を廃棄のメッセージが出てこない dou end
  data() {
    return {
      historyKey: HISTORY_KEY_FACILITY_CALENDAR_DETAIL
    };
  }
};
</script>
