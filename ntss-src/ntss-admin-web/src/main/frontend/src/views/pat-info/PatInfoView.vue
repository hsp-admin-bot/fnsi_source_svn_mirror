<!--患者情報-->
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
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/pat-info/PatInfoContent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_PAT_INFO } from "@/router/pat-info/HistoryKeyConstants";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { confirmIsOk } from "@/functions/common/OnsenFunctions";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import { mapGetters, mapMutations } from "@/compat/vue/vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

export default {
  name: "PatInfoView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  async beforeRouteLeave(to, from, next) {
    try {
      if (to.name != "signin" && this.$refs.mainComponent && this.hasEditedComponent) {
        const isOK = await confirmIsOk(DIALOG_MESSAGES[13000004]);
        if (isOK) {
          this.setIsPatInfoChaned(false);
          this.resetEditedComponent();
          next();
        } else {
          next(false);
        }
        return;
      }
      next();
    } catch(error) {
      getErrorMessage('PatInfoView.vue','beforeRouteLeave',error);
      next();
    }
  },
  data() {
    return {
      historyKey: HISTORY_KEY_PAT_INFO
    };
  },
  computed: {
    ...mapGetters("pat-info", ["hasEditedComponent"]),
  },
  watch: {
    hasEditedComponent(val) {
      // 患者を切り替えるときに外部コンポーネントに通知し、破棄ダイアログ ボックスをポップアップ表示します。
      this.setIsPatInfoChaned(val);
    }
  },
  methods: {
    ...mapMutations("pat-info", ["setIsPatInfoChaned", "resetEditedComponent", "setStartRenderPatInfoContent"]),
  },
  beforeUnmount() {
    this.setStartRenderPatInfoContent(false)
  }
};
</script>
