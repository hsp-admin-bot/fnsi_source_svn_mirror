<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      #bread-crumbs-content
      :history-key="historyKey"
      @refresh="refresh"
      :no-split="true"
    /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
        :no-split="true"
      />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component
        ref="mainComponent"
        :history-key="historyKey"
      />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/facility-calendar/FacilityCalenderEdit.vue";
import MainComponent from "@/components/bbs-info/BbsDetailedInfoContent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent.vue";
import ViewHelper from "@/views/ViewHelperMixin.js";
import { HISTORY_KEY_FACILITY_CALENDAR_CREATE } from "@/router/facility-calendar/HistoryKeyConstants.js";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "FacilityCalendarCreateView",
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
      historyKey: HISTORY_KEY_FACILITY_CALENDAR_CREATE
    };
  }
};
</script>
