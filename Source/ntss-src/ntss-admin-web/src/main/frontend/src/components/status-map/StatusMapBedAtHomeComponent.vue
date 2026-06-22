/**
 * 在宅ベッド(治療状況マップ)
 */
<template>
    <div
      :class="bedDivClass"
      :style='{ backgroundColor: kouteiColor }'>
    </div>
</template>

<script>
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import {
  PROCESS_STATE,
  MARKER_COLOR
} from "@/constants/statusMapConstants.js";
import { mapActions } from "@/compat/vue/vuex";

export default {
  mixins: [NextTransitionMixin, PatHeaderControlMixin],
  computed: {
    bedDivClass() {
      if (this.isPopoverScroll) {
        return `bed-inner`;
      }
      return `bed-inner  bed-event`;
    },
    /**
     * 工程の進行状況によってマーカーの色を設定
     */
    kouteiColor() {

      let rtn;
      if (
        this.bedData.treatment !== null &&
        this.bedData.treatment !== undefined
      ) {
        switch (this.bedData.treatment.processState) {
          case PROCESS_STATE.PRESET:
          case PROCESS_STATE.JUNBIKAISYUU:
          case PROCESS_STATE.GASS_PURGE:
          case PROCESS_STATE.HAIEKI:
            rtn = MARKER_COLOR.MARKER_WHITE;
            break;
          case PROCESS_STATE.SENJYOU:
          case PROCESS_STATE.SANSEN:
          case PROCESS_STATE.SYOUDOKU:
          case PROCESS_STATE.TAIRYUU:
          case PROCESS_STATE.EKITIKAN:
            rtn = MARKER_COLOR.MARKER_BLUE;
            break;
          case PROCESS_STATE.TEISI:
          case PROCESS_STATE.UNTEN:
            rtn = MARKER_COLOR.MARKER_GREEN;
            break;
          case PROCESS_STATE.IJYOU:
            rtn = MARKER_COLOR.MARKER_GRAY;
            break;
          default:
            rtn = MARKER_COLOR.MARKER_WHITE;
            break;
        }
      } else {
        rtn = MARKER_COLOR.MARKER_WHITE;
      }
      return rtn;
    },
    /**
     * 指示番号
     */
    ordNo() {
      return this.bedData.ordMain ? this.bedData.ordMain.ordNo : "";
    },
  },
  props: ["bedData", "historyKey", "isPopoverScroll"],
  methods: {
    ...mapActions("multi-modal", ["showSchedule"]),
    ...mapActions("schedule-assignment/modal", {
      scheduleAssignmentSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapActions("send-condition/scale", {
      sendConditionSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapActions("treatment-record/common", {
      setTreatmentRecordOrdNo: "setOrdNo"
    }),
  }
};
</script>
<style scoped>
.progress {
  padding: 0.2em;
  width: 3em;
  height: 3em;
  transform: scale(1);
}
.bed {
  position: absolute;
  border-radius: 5px;
  z-index: 2;
}
.bed-inner {
  width: 100%;
  height: 100%;
  overflow: hidden !important;
  border: 1px solid #000;
  border-radius: 30px 30px 30px 0px;
  padding: 0.2em;
  transform: rotate(-45deg);
}
</style>
