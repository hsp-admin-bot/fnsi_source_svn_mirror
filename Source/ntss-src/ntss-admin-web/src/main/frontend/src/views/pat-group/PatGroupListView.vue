<template>
  <ntss-layout-split>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" />
    </template>
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/pat-group/PatGroupListHeaderComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import MainComponent from "@/components/pat-group/PatGroupListComponent";
import { HISTORY_KEY_PAT_GROUP_LIST } from "@/router/pat-group/HistoryKeyConstants";
import store from "@/stores";
import { mapGetters } from "@/compat/vue/vuex";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';

export default {
  name: "PatGroupListView",
  components: {
    "header-component": HeaderComponent,
    "bread-crumbs-component": BreadCrumbsComponent,
    "main-component": MainComponent
  },
  data() {
    return {
      historyKey: HISTORY_KEY_PAT_GROUP_LIST
    };
  },
  computed: {
    ...mapGetters("pat-group", ["isEditedSort", "isEitedPatGroupList"])
  },
  methods: {
    // 並び順の編集有無
    isSortChanged() {
      return this.isEditedSort;
    },
    // 患者グループの編集有無
    isPatGroupListChanged() {
      return this.isEitedPatGroupList;
    },
    // 内容破棄確認の表示
    async discardContentConfirm(next) {
      const confirmed = await this.$ons.notification.confirm(
        messageFormat(DIALOG_MESSAGES[13000004].message),
        {title: DIALOG_MESSAGES[13000004].title}
      );
      next(!!confirmed);
    }
  },
  // (内部)画面の切り替え・・・同コンポーネント(pat-group)間の遷移
  async beforeRouteUpdate(to, from, next) {
    // 並び順編集済の場合
    if (this.isSortChanged() || this.isPatGroupListChanged()) {
      store.dispatch("window-size/resetCurrentDepth");
      store.dispatch("window-size/setCurrentDepth", from.meta.depth);
      const confirmed = await this.$ons.notification.confirm(
        messageFormat(DIALOG_MESSAGES[13000004].message),
        {title: DIALOG_MESSAGES[13000004].title}
      );
      if (confirmed == 1) {
        store.dispatch("window-size/resetCurrentDepth");
        store.dispatch("window-size/setCurrentDepth", to.meta.depth);
      } else {
        next(false);
        return;
      }
    }
    next();
  },
  // (外部)画面の切り替え・・・異コンポーネント間の遷移
  async beforeRouteLeave(to, from, next) {
    // 並び順編集済の場合
    if (this.isSortChanged() || this.isPatGroupListChanged()) {
      this.discardContentConfirm(next);
      return;
    }
    next();
  }
};
</script>
