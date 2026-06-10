/**
 * 装置記録
 */
 <template>
  <ntss-layout-split>
    <header-component slot='header-content' />
    <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" />
    <main-component slot='main-content' ref='mainComponent' :history-key="historyKey" />
  </ntss-layout-split>
</template>

<script>
import HeaderComponent from "@/components/operation-viewer/motion-records/MotionRecordsHeaderComponent";
import MainComponent from "@/components/operation-viewer/motion-records/MotionRecordsMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_OPERATION_VIEWER_RECORD } from "@/router/operation-viewer/HistoryKeyConstants";

export default {
  name: "MotionRecordsView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_OPERATION_VIEWER_RECORD
    };
  }
};
</script>
