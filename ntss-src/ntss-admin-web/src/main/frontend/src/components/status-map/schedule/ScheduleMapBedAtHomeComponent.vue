/**
 * 在宅ベッド(治療状況スケジュール)
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

export default {
  components: {},
  mixins: [NextTransitionMixin, PatHeaderControlMixin],
  computed: {
    bedDivClass() {
      if (this.isPopoverScroll) {
        return `bed-inner`;
      }
      return `bed-inner  none-event`;
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
    }
  },
  props: ["bedData", "historyKey", "isPopoverScroll"],
  methods: {},
  watch: {},
  beforeCreate() {},
  created() {},
  beforeMount() {},
  mounted() {},
  beforeUpdate() {},
  updated() {},
  beforeDestroy() { },
  destroyed() { }
};
</script>
<style scoped>
.bed {
  cursor: pointer;
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
/* .none-event {
  pointer-events: none;
} */
div.button-area {
  position: absolute;
  right: 0em;
  bottom: 0em;
}
div.displayFull {
  cursor: pointer;
  position: absolute;
  top: 0.5em;
  right: 0.5em;
  background-color: #eeef;
}

img.img-icon {
  cursor: pointer;
  height: 1.2em;
  padding-left: 0.25em;
  /* height: 2em; */
}

button.button-on-bed {
  font-size: 1em;
  margin-left: 0.25em;
  pointer-events: auto;
}
</style>
