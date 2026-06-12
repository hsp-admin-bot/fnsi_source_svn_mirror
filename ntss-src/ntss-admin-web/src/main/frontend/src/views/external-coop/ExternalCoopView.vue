<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
        :no-split="true"
      />
    </template>
    <template #main-content>
      <main-component
        ref="mainComponent"
        :history-key="historyKey"
      />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/external-coop/ExternalCoopHeaderComponent";
import MainComponent from "@/components/external-coop/ExternalCoopComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import { HISTORY_KEY_EXTERNAL_COOP } from "@/router/external-coop/HistoryKeyConstants";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from "@/functions/common/MessageFormat";

export default {
  name: "ExternalCoopView",
  components: {
    "header-component": HeaderComponent,
    "bread-crumbs-component": BreadCrumbsComponent,
    "main-component": MainComponent
  },
  beforeRouteLeave(to, from, next) {
    if (!this.$refs.mainComponent.hasChanges) {
      next(); // 変更なし → そのまま遷移
    } else {
      this.confirmLeave().then(confirmed => next(confirmed));
    }
  },
  data() {
    return {
      historyKey: HISTORY_KEY_EXTERNAL_COOP
    };
  },
  methods: {
    confirmLeave() {
      return new Promise(resolve => {
        // 内容破棄
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => resolve(answer === 1)
        });
      });
    }
  }
};
</script>

<style scoped>
.content-container :deep(*) {
  box-sizing: border-box;
}
</style>
