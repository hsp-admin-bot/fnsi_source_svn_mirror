/**
 * 患者イベントページ
 */
 <template>
  <ntss-layout>
    <template #header-content>
      <header-component :key="$route.name" />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      #bread-crumbs-content
      :history-key="historyKey"
      :no-split="true"
      @refresh="refresh"
       :key="routerName"
    /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component
        :history-key="historyKey"
        :no-split="true"
        :key="$route.name"
      />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" :key="$route.name" />
    </template>
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
import {mapGetters, mapMutations} from "@/compat/vue/vuex";
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
    try {
      const mainComponent = this.$refs.mainComponent;
      if (
        to.name !== "signin" &&
        mainComponent &&
        mainComponent.selectedPatId &&
        mainComponent.isEdit &&
        !(await mainComponent.confirmAllowDiscardChanges())
      ) {
        // 内容破棄確認でキャンセルした場合はページ遷移をキャンセルする
        next(false);
        return;
      }

      // Vue Router 4では next を複数回呼び出すと遷移ガードが破綻するため、
      // Vue2の確認順序を保ったまま最終結果を一度だけ返す。
      if (to.name !== "signin" && !!this.isPatInfoChaned) {
        const answer = await new Promise((resolve) => {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000004].title,
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: resolve,
          });
        });
        if (answer === 1) {
          this.setIsPatInfoChaned(false);
          next();
        } else {
          next(false);
        }
        return;
      }

      next();
    } catch (_error) {
      next();
    }
  },
  data() {
    return {
      historyKey: HISTORY_KEY_PAT_EVENT,
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
