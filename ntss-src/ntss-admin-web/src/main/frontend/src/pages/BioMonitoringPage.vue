/**
 * 生体モニタリングページ
 */
<script>
import Vue from 'vue';
import BasePage from '@/components/BasePage';
import HeaderItem from '@/components/header-contents/BioMonitoringListHeaderItem';
import MainItem from '@/components/main-contents/BioMonitoringListMainItem';

export default Vue.extend(BasePage).extend({
  pageTitle: '生体モニタリング',
  components: {
    'header-content': HeaderItem,
    'main-content': MainItem,
  },
});
</script>
