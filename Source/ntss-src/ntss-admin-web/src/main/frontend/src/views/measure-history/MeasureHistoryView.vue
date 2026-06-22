/**
 * 体重計測定記録ページ
 */
 <template>
  <ntss-layout-split>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey"  @refresh='refresh'/>
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
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
