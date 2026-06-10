/**
 * 体重計測定記録ページ
 */
 <template>
  <ntss-layout-split>
    <header-component slot='header-content' />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" /> -->
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey"  @refresh='refresh'/>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/measure-history/MeasureHistoryHeaderComponent";
import MainComponent from "@/components/measure-history/MeasureHistoryComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_MEASURE_HISTORY } from "@/router/measure-history/HistoryKeyConstants";

export default {
  name: "MeasureHistoryView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_MEASURE_HISTORY
    };
  }
};
</script>
