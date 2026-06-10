/**
 * 患者イベントページ
 */
 <template>
  <ntss-layout>
    <header-component slot="header-content" :key="routerName"/>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split="true"
      @refresh="refresh"
       :key="routerName"
    /> -->
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      :no-split="true"
       :key="routerName"
    />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot="main-content" ref="mainComponent" :history-key="historyKey" :key="routerName"/>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/pat-event/PatEventMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_PAT_EVENT } from "@/router/pat-event/HistoryKeyConstants";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";
import {mapGetters, mapMutations} from "vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end

export default {
  name: "PatEventView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  async beforeRouteLeave(to, from, next) {
    if (to.name != "signin" && this.$refs.mainComponent
      && this.$refs.mainComponent.selectedPatId
      && this.$refs.mainComponent.isEdit
      && !(await this.$refs.mainComponent.confirmAllowDiscardChanges())
    ) {
      // 内容破棄確認でキャンセルした場合はページ遷移をキャンセルする
      next(false);
      return;
    } else {
      next();
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
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
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  },
  data() {
    return {
      historyKey: HISTORY_KEY_PAT_EVENT,
      routerName: this.$router.currentRoute.name
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
