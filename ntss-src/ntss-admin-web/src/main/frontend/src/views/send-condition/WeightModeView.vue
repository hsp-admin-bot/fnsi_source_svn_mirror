/**
 * 体重計モードページ
 */
 <template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <!-- mod FNSI-体重計画面 徐 start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" :no-split=true @refresh='refresh'/> -->
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" :no-split=true @refresh='refresh' v-show="breadMode"/> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" :no-split=true v-show="breadMode"/>
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <!-- mod FNSI-体重計画面 徐 end -->
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout>
</template>

<script>
import HeaderComponent from "@/components/send-condition/WeightModeHeader";
import MainComponent from "@/components/send-condition/WeightModeMainFrameComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_WEIGHT_MODE } from "@/router/send-condition-weight/HistoryKeyConstants";
// add FNSI-体重計画面 徐 start
import { mapGetters} from "@/compat/vue/vuex";
// add FNSI-体重計画面 徐 end
export default {
  name: "SendConditionView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  // add FNSI-体重計画面 徐 start
  computed: {
    ...mapGetters("app", ["getQueryParameters"]),
  },
  created() {
    const queryParameters = this.getQueryParameters;
    if (Number(queryParameters.MODE) == 1) {
      this.breadMode = false;
    }
  },
  // add FNSI-体重計画面 徐 end
  data() {
    return {
      // add FNSI-体重計画面 徐 start
      breadMode: true,
      // add FNSI-体重計画面 徐 end
      historyKey: HISTORY_KEY_WEIGHT_MODE
    };
  }
};
</script>
