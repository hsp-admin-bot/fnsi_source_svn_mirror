/**
 * マスタ一覧ページ
 */
 <template>
   <ntss-layout>
     <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
   </ntss-layout>
 </template>

 <script>
import MainComponent from "@/components/master-maintenance/MasterMainFrameComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_MASTER_MAINTENANCE_LIST } from "@/router/master-maintenance/HistoryKeyConstants";

export default {
  name: "MasterMainView",
  components: {
    "main-component": MainComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_MASTER_MAINTENANCE_LIST
    };
  }
};
</script>
<style scoped>
::v-deep .k-grid-header {
  border: solid 1px var(--ntss-list-border-color);
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
}
</style>
