/**
 * チェックリストページ
 */
 <template>
  <ntss-layout-split>
    <header-component slot='header-content' />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" @refresh='refresh' /> -->
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" />
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/check-list/CheckListHeaderComponent";
import MainComponent from "@/components/check-list/CheckListComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_CHECK_LIST } from "@/router/check-list/HistoryKeyConstants";

export default {
  name: "CheckListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_CHECK_LIST
    };
  }
};
</script>
