/**
 * 生体モニタリングページ（一覧）
 * レイアウトは BasePage.vue を extends（テンプレートは重複しない）
 */
<script>
import BasePage from "@/components/BasePage.vue";
import HeaderItem from "@/components/header-contents/BioMonitoringListHeaderItem.vue";
import MainItem from "@/components/main-contents/BioMonitoringListMainItem.vue";

export default {
  name: "BioMonitoringPage",
  extends: BasePage,
  components: {
    "header-content": HeaderItem,
    "main-content": MainItem
  },
  data() {
    return {
      /** vue2 の pageTitle と同等（パンくず用・BasePage の component） */
      component: "生体モニタリング"
    };
  }
};
</script>
