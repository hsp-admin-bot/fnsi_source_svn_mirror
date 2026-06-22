/**
 * 装置記録
 */
 <template>
  <ntss-layout-split>
    <template #header-content>
      <header-component />
    </template>
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" />
    </template>
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
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
