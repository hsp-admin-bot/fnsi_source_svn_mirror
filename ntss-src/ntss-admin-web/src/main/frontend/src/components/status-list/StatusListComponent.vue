/**
 * 治療状況リスト（治療状況・装置一覧切替画面） MainContent
 */
<template>
  <div class="status-list-main-content">
    <StatusListMainComponent></StatusListMainComponent>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import StatusListMainComponent from "@/components/status-list/StatusListMainComponent";
import NextTransitionMixin from "@/components/NextTransitionMixin";

export default {
  mixins: [NextTransitionMixin],
  components: {
    StatusListMainComponent
  },
  computed: {
    ...mapGetters("status-list/list", ["getIsGoAlarmPage"]),
  },
  methods: {
    ...mapActions("status-list/list", ["setIsGoAlarmPage"]),
    changePage() {
      if (this.getIsGoAlarmPage == true) {
        this.setIsGoAlarmPage(false);
      }
    },
  },
  watch: {
    getIsGoAlarmPage(value) {
      if (value === true) {
        this.goSpecifiedView("status-list-alarm");
        this.setIsGoAlarmPage(false);
      }
    },
  },
  created() {
    this.changePage();
  },
};
</script>
<style scoped>
.status-list-main-content {
  height: 100%;
  width: 100%;
  overflow: hidden;
}
</style>
