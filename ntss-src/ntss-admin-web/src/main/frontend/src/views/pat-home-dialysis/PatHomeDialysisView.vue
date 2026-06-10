 <!-- 在宅透析患者用 -->
<template>
  <ntss-layout>
    <!-- パンくずを表示しない -->
    <header-component style="margin-bottom: 35px;" slot='header-content' />
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/pat-home-dialysis/PatHomeDialysisMainFrameComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_PAT_HOME_DIALYSIS } from "@/router/pat-home-dialysis/HistoryKeyConstants";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import {mapGetters, mapMutations} from "vuex";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end

export default {
  name: "PatHomeDialysisView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent
  },
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
      getErrorMessage('PatHomeDialysisView.vue', 'beforeRouteLeave', error);
      next();
    }
  },
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  data() {
    return {
      historyKey: HISTORY_KEY_PAT_HOME_DIALYSIS
    };
  },
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
