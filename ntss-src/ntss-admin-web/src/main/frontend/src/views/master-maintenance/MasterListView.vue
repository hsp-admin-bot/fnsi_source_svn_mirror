/**
 * マスタ一覧ページ
 */
 <template>
   <ntss-layout>
     <template #header-content>
       <header-component />
     </template>
     <template #bread-crumbs-content>
       <bread-crumbs-component :history-key="historyKey" :no-split="true" />
     </template>
     <template #main-content>
       <main-component ref="mainComponent" :history-key="historyKey" />
     </template>
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
