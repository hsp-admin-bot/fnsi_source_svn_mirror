/**
 * 条件送信ページ
 */
 <template>
  <!-- mod FNSI-改修内容 顯示調整 趙慧敏 start -->
  <!-- <ntss-layout-split> -->
  <ntss-layout>
  <!-- mod FNSI-改修内容 顯示調整 趙慧敏 end -->
    <header-component slot="header-content" :isWeightScale="true" :isCannotSwipe="true" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
      @refresh="refresh"
    /> -->
    <bread-crumbs-component
      slot="bread-crumbs-content"
      :history-key="historyKey"
    />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot="main-content" ref="mainComponent" :history-key="historyKey" />
  <!-- mod FNSI-改修内容 顯示調整 趙慧敏 start -->
  <!-- </ntss-layout-split> -->
  </ntss-layout>
  <!-- mod FNSI-改修内容 顯示調整 趙慧敏 end -->
</template>

<script>
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/send-condition/SendConditionMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_SEND_CONDITION } from "@/router/send-condition/HistoryKeyConstants";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import {mapActions, mapGetters, mapMutations} from "vuex";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end

export default {
  name: "SendConditionView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
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
      getErrorMessage('SendConditionView.vue', 'beforeRouteLeave', error);
      next();
    }
  },
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  data() {
    return {
      historyKey: HISTORY_KEY_SEND_CONDITION
    };
  },
  computed: {
    ...mapGetters("app", ["getQueryParameters"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    ...mapGetters("pat-info", ["isPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
    // #11987 2026.03.23 add スケールベッドからの呼び出しに対応 TDC片口 start
    ...mapGetters("scale-bed/send-cond", ["getIsFromScaleBed"]),
    // #11987 2026.03.23 add スケールベッドからの呼び出しに対応 TDC片口 end
  },
  methods: {
    ...mapActions("app", ["setQueryParameters"]),
    ...mapActions("send-condition/scale/setting", ["clearWeightConfigInfo"]),
    ...mapActions("send-condition/weight", [
      "setWeightMode",
      "setMstWeightSelectIdx"
    ]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  },
  created() {
    // #11987 2026.03.23 mod スケールベッドからの呼び出しに対応 TDC片口 start
    // // 他機能から遷移した時点で体重計選択は「体重計接続なし」とする。
    // this.setMstWeightSelectIdx(-1);
    // let queryParameters = this.getQueryParameters;
    // queryParameters.WEIGHTNO = undefined;
    // queryParameters.MODE = undefined;
    // this.setQueryParameters(queryParameters);
    // this.clearWeightConfigInfo();
    if (!this.getIsFromScaleBed) {
      // スケールベッド以外の機能から遷移した時点で体重計選択は「体重計接続なし」とする。
      this.setMstWeightSelectIdx(-1);
      let queryParameters = this.getQueryParameters;
      queryParameters.WEIGHTNO = undefined;
      queryParameters.MODE = undefined;
      this.setQueryParameters(queryParameters);
      this.clearWeightConfigInfo();
    }
    // #11987 2026.03.23 mod スケールベッドからの呼び出しに対応 TDC片口 end
    // 体重計モード削除
    this.setWeightMode({
      isWeightMode: false,
      defaultDispMenu: null
    });
    const cssLink = document.head.querySelectorAll(
      "link[href='./css/ntss_weight_mode.css']"
    );
    for (const link of cssLink) {
      document.head.removeChild(link);
    }
  }
};
</script>
