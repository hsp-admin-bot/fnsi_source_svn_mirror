<!--患者情報-->
<template>
  <ntss-layout>
    <header-component slot="header-content" />
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split="true"
    />
    <main-component
      slot="main-content"
      ref="mainComponent"
      :history-key="historyKey"
    />
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
import { messageFormat } from '@/functions/common/MessageFormat';
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import {mapMutations, mapGetters} from "vuex";
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
      if (to.name != "signin" && this.$refs.mainComponent && this.hasEditedComponent ) {
        await this.$ons.notification.confirm({
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              this.setIsPatInfoChaned(false);
              this.resetEditedComponent();
              next();
            }
          }
        });
      } else {
        next();
      }
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
  beforeDestroy () {
    this.setStartRenderPatInfoContent(false)
  }
};
</script>
