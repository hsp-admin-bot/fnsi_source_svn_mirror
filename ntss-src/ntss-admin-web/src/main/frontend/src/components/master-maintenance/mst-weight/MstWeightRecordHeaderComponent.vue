
<template>
  <div>
    <template v-if="isDetailHeaderView === true">
      <detail-header-component></detail-header-component>
    </template>
    <template v-if="isDetailHeaderView === false">
      <list-header-component></list-header-component>
    </template>
  </div>
</template>

<script>
import listHeader from "@/components/master-maintenance/mst-weight/MstWeightRecordListHeaderComponent";
import detailHeader from "@/components/master-maintenance/IndividualMasterHeaderComponent";
import { EventBus } from "@/eventBus.js";

export default {
  data() {
    return {
      isDetailHeader: false
    };
  },
  components: {
    "list-header-component": listHeader,
    "detail-header-component": detailHeader
  },
  computed: {
    isDetailHeaderView() {
      return this.isDetailHeader;
    }
  },
  methods: {
    setIsDetailHeaderView(val) {
      this.isDetailHeader = val;
    }
  },
  mounted() {},
  created() {
    EventBus.$on("setIsDetailHeaderView", this.setIsDetailHeaderView);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("setIsDetailHeaderView", this.setIsDetailHeaderView);
  },
  // add 性能改善メモリ不足 shan end
  watch: {}
};
</script>
