/**
 * マスタ一覧ページ
 */
 <template>
   <ntss-layout>
     <header-component slot='header-content' />
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" :no-split=true />
     <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
   </ntss-layout>
 </template>

 <script>
import HeaderComponent from "@/components/master-maintenance/MasterListHeaderComponent";
import MainComponent from "@/components/master-maintenance/MasterListComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_MASTER_MAINTENANCE_LIST } from "@/router/master-maintenance/HistoryKeyConstants";

export default {
  name: "MasterListView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_MASTER_MAINTENANCE_LIST
    };
  }
};
</script>
