/**
 * 生体モニタリングページ
 */
<script>
import Vue from 'vue';
import BasePage from '@/components/BasePage';
import HeaderItem from '@/components/header-contents/CommonPatientInformationHeaderItem';
import MainItem from '@/components/main-contents/BioMonitoringDetailMainItem';

export default Vue.extend(BasePage).extend({
  pageTitle: '生体モニタリング詳細',
  components: {
    'header-content': HeaderItem,
    'main-content': MainItem,
  },
});
</script>
