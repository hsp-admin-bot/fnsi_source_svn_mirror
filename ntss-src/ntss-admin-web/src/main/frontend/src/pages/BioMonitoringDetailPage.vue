/**
 * 生体モニタリングページ（詳細）
 * レイアウトは BasePage.vue を extends（テンプレートは重複しない）
 */
<script>
import BasePage from "@/components/BasePage.vue";
import HeaderItem from "@/components/header-contents/CommonPatientInformationHeaderItem.vue";
import MainItem from "@/components/main-contents/BioMonitoringDetailMainItem.vue";

export default {
  name: "BioMonitoringDetailPage",
  extends: BasePage,
  components: {
    "header-content": HeaderItem,
    "main-content": MainItem
  },
  data() {
    return {
      /** vue2 の pageTitle と同等（パンくず用・BasePage の component） */
      component: "生体モニタリング詳細"
    };
  }
};
</script>
