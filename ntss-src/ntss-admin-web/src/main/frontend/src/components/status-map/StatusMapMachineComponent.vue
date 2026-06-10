/**
 * マップ上に配置される装置(治療状況マップ)
 */
<template>
  <div
    ref="machine-container"
    class="machine"
    :id="'machine-' + machineData.bedLayout.machine_no"
    :style="sizeAndPosition"
    @mousedown="listenerStart"
    @mouseup="listenerEnd($event, machineData)"
    @mousemove="listenerMove"
    @touchstart="listenerStart"
    @touchend="listenerEnd($event, machineData)"
    @touchmove="listenerMove"
  >
    <template v-if="shouldRenderItem">
      <div
        class="display-full auto-event"
        :style="isBedMachineAtHome ? 'display: none;' : ''"
        @mouseup="showPopover"
        @touchend="showPopover"
        @mousewheel="$event.stopPropagation()"
        v-show="!popoverVisible"
      >
        <img class="img-icon" :src="image_src_all_view" />
      </div>
      <div
        v-if="isBedMachineAtHome"
        class="machine-inner auto-event"
        @mouseup="showPopover"
        @touchend="showPopover"
      >
        <StatusMapBedAtHome :bedData="machineData"></StatusMapBedAtHome>
      </div>
      <div v-else-if="isBedMachine" class="machine-inner auto-event">
        <StatusMapBed :bedData="machineData"></StatusMapBed>
      </div>
      <!-- mod FNSI-警報・報知追加 付 start -->
      <div v-else-if="!isBedMachine" class="machine-inner auto-event">
        <StatusMapMachineRoom :machineData="machineData"></StatusMapMachineRoom>
      </div>
      <!-- mod FNSI-警報・報知追加 付 end -->
      <!-- ツールチップ -->
      <v-ons-dialog
        v-if="popoverVisible"
        cancelable
        animation="none"
        :visible.sync="popoverVisible"
        :target="'#machine-' + machineData.bedLayout.machine_no"
        :direction="popoverDirection"
        @postshow="popoverAdjustment"
        @posthide="popoverClose"
        class="tool-tip"
      >
        <div class="popover-size">
          <StatusMapBedAtHomePopOver
            :isPopoverScroll="true"
            :bedData="machineData"
            v-if="popoverVisible && isBedMachineAtHome"
          ></StatusMapBedAtHomePopOver>
          <StatusMapBed
            :isPopoverScroll="true"
            :bedData="machineData"
            v-else-if="popoverVisible && isBedMachine && !isBedMachineAtHome"
          ></StatusMapBed>
          <StatusMapMachineRoom
            :isPopoverScroll="true"
            :machineData="machineData"
            v-else-if="popoverVisible && !isBedMachine"
          ></StatusMapMachineRoom>
        </div>
      </v-ons-dialog>
    </template>
  </div>
</template>

<script>
import StatusMapBed from "@/components/status-map/StatusMapBedComponent";
import StatusMapBedAtHome from "@/components/status-map/StatusMapBedAtHomeComponent";
import StatusMapBedAtHomePopOver from "@/components/status-map/StatusMapBedAtHomePopOverComponent";
import StatusMapMachineRoom from "@/components/status-map/StatusMapMachineRoomComponent";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import { MACHINE_MODEL } from "@/constants/machineModel";
import { mapGetters, mapActions, mapMutations } from "vuex";
import { EventBus } from "@/eventBus.js";

export default {
  data() {
    return {
      shouldRenderItem: false,
      observer: null,
      isListenerStarted: false,
      moveCount: 0,
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "right down up left",
      image_src_all_view: require("../../assets/all_view.png")
    };
  },
  components: {
    StatusMapBed,
    StatusMapBedAtHome,
    StatusMapBedAtHomePopOver,
    StatusMapMachineRoom
  },
  mixins: [NextTransitionMixin, PatHeaderControlMixin],
  computed: {
    ...mapGetters("status-map/map", {
      getPatTreatmentStatusToPatList: "getPatTreatmentStatusToPatList"
    }),
    /**
     * ポインターカーソル表示有無
     */
    isCursorPointer() {
      return (
        this.machineData.treatment
        && ((( this.isBedMachine || this.isBedMachineAtHome ) && this.machineData.treatment.ordNo )
          || ! this.isBedMachine )
      );
    },
    sizeAndPosition() {
      let ret =
        `width: ${this.machineData.bedLayout.width}px; `
         + `height: ${this.machineData.bedLayout.height}px; `
         + `top: ${this.machineData.bedLayout.top}px; `
         + `left: ${this.machineData.bedLayout.left}px;`;
         if (this.isCursorPointer) {
          ret = ret+ "cursor: pointer"
         }
      return ret;
    },
    isBedMachine() {
      if (
        this.machineData.bedLayout &&
        [MACHINE_MODEL.PERSONAL, MACHINE_MODEL.DCS].includes(
          this.machineData.bedLayout.model
        )
      ) {
        return true;
      } else {
        return false;
      }
    },
    isBedMachineAtHome() {
      if (
        this.machineData.bedLayout &&
        [MACHINE_MODEL.PERSONAL, MACHINE_MODEL.DCS].includes(
          this.machineData.bedLayout.model
        ) &&
        "1" === this.machineData.bedLayout.is_home_dialysis
      ) {
        return true;
      } else {
        return false;
      }
    }
  },
  props: ["machineData", "historyKey"],
  methods: {
    ...mapActions("send-condition/scale", {
      sendConditionSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapActions("treatment-record/common", {
      setTreatmentRecordOrdNo: "setOrdNo",
      setOrdNoForSideBarRecord: "setOrdNoForSideBarRecord"
    }),
    ...mapActions("trend-graph", ["setMachineInfo"]),
    ...mapMutations("pat-info", {
      updateTreatmentPatList: "updateTreatmentPatList",
      setSrcFuncName: "setSrcFuncName"
    }),

    clickStatusMachine(machineData) {
      if (this.isBedMachine
      ) {
        if (
          !machineData.treatment
          || 1 === machineData.treatment.isPreventiveMainte
          || ! machineData.bedLayout.machine_no
        ) {
          // なにもしない
        } else if (
          ["0"].includes(machineData.treatment.rstDialysisState)
        ) {
          // 条件送信画面(体重計画面)へ遷移

          // 患者選択リストに格納
          this.updateTreatmentPatList(this.getPatTreatmentStatusToPatList);
          // 機能コード設定、選択 ord_no を保持
          this.setOrdNoForSideBarRecord(machineData.treatment.ordNo);
          this.setSrcFuncName(this.$router.currentRoute.name);

          //
          this.sendConditionSetSelectOrdNo({
            ordNo: machineData.treatment.ordNo,
            ordNo2: null
          }).then(() => {
            this.goSpecifiedView("send-condition");
          });
        } else if (
          ["1", "2", "3", "4", "5", "6"].includes(machineData.treatment.rstDialysisState)
        ) {
          // 治療中のベッド 治療記録へ遷移
          // console.log("clickStatusMachine/治療中のベッド");

          // 患者選択リストに格納
          this.updateTreatmentPatList(this.getPatTreatmentStatusToPatList);
          // 機能コード設定、選択 ord_no を保持
          this.setOrdNoForSideBarRecord(machineData.treatment.ordNo);
          this.setSrcFuncName(this.$router.currentRoute.name);

          //
          this.setSelectedPatHeader(machineData.treatment.patId).then(() => {
            // ordNoセット
            this.$nextTick(() => {
              this.setTreatmentRecordOrdNo(machineData.treatment.ordNo);
              // 治療記録画面へ遷移
              this.$router.push({ name: "treatment-record" });
            });
          });
        }
      } else {
        // 機械室装置の場合 トレンドグラフへ遷移
        const machineInfo = {
          machineName: machineData.bedLayout.name,
          machineSerial: machineData.bedLayout.machine_serial,
          machineTypeCd: machineData.bedLayout.machine_type_cd,
          model: machineData.bedLayout.model
          // add FNSI redmine 7187 劉祥霖 start
          , comFormatCd: machineData.treatment.comFormatCd
          // add FNSI redmine 7187 劉祥霖 end
        };
        this.setMachineInfo(machineInfo).then(() => {
          this.$router.push({ name: "trend-graph" });
        });
      }
    },
    popoverClose() {
      this.popoverVisible = false;
    },
    /**
     * 表示後にポップアップの位置を調整
     * （在宅アイコン用）
     */
    popoverAdjustment() {
      // 右表示の位置調整(在宅アイコン)
      if (document.getElementsByClassName("popover--left") != null) {
        let leftPopOver = document.getElementsByClassName("popover--left");
        this.$nextTick(() => {
          let arrayLeftPopOver = Array.from(leftPopOver);
          arrayLeftPopOver.forEach(pop => {
            const newAttr =
              pop.getAttribute("style") + " transform-origin: left;";
            pop.setAttribute("style", newAttr);
          });
        });
      }
      // 左表示の位置調整(在宅アイコン)
      if (document.getElementsByClassName("popover--right") != null) {
        let rightPopOver = document.getElementsByClassName("popover--right");
        this.$nextTick(() => {
          let arrayRightPopOver = Array.from(rightPopOver);
          arrayRightPopOver.forEach(pop => {
            const newAttr =
              pop.getAttribute("style") + " transform-origin: right;";
            pop.setAttribute("style", newAttr);
          });
        });
      }
      // 上表示の位置調整(在宅アイコン)
      if (document.getElementsByClassName("popover--top") != null) {
        let topPopOver = document.getElementsByClassName("popover--top");
        this.$nextTick(() => {
          let arrayTopPopOver = Array.from(topPopOver);
          arrayTopPopOver.forEach(pop => {
            const newAttr =
              pop.getAttribute("style") + " transform-origin: top;";
            pop.setAttribute("style", newAttr);
          });
        });
      }
      // 下表示の位置調整(在宅アイコン)
      if (document.getElementsByClassName("popover--bottom") != null) {
        let bottomPopOver = document.getElementsByClassName("popover--bottom");
        this.$nextTick(() => {
          let arrayBottomPopOver = Array.from(bottomPopOver);
          arrayBottomPopOver.forEach(pop => {
            const newAttr =
              pop.getAttribute("style") + " transform-origin: bottom;";
            pop.setAttribute("style", newAttr);
          });
        });
      }
    },
    // add FNSI-popup close 付 start
    closeDialog() {
      this.popoverVisible = false;
    },
    // add FNSI-popup close 付 end
    showPopover(event) {
      event.preventDefault();
      event.stopPropagation();
      if (
        this.isListenerStarted === true &&
        this.moveCount <= 3
      ) {
        this.popoverVisible = true;
      }
      this.isListenerStarted = false;
      this.listenerMove(event);
    },
    listenerStart(e) {
      //#10407:変更なしでも画面を表示させる Start
      if (!(e.target.id != undefined && e.target.id === 'changeinstructionline')) {
        //_指示変更行クリック優先以外：治療記録画面遷移
         e.preventDefault();
         this.isListenerStarted = true;
         this.moveCount = 0;
      }
      //#10407:変更なしでも画面を表示させる End
    },
    listenerMove(e) {
      e.preventDefault();
      if (
        this.isListenerStarted === true &&
        (e.movementX !== 0 || e.movementY !== 0)
      ) {
        this.moveCount = this.moveCount + 1;
      }
    },
    listenerEnd(e, machine) {
      const classList = Array.from(e.target.classList)
      e.preventDefault();
      if (this.isListenerStarted === true && this.moveCount <= 3 && !classList.includes('stop-listenerend')) {
        this.clickStatusMachine(machine);
      }
      this.isListenerStarted = false;
    }
  },
  watch: {},
  beforeCreate() {},
  created() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off("closeDialog", this.closeDialog);
    // add 性能改善メモリ不足 shan end
    // add FNSI-popup close 付 start
    EventBus.$on("closeDialog", this.closeDialog);
    // add FNSI-popup close 付 end
  },
  beforeMount() {},
  mounted() {
    this.observer = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.shouldRenderItem = true;
          observer.unobserve(entry.target);
        }
      });
    });
    this.observer.observe(this.$refs["machine-container"]);
  },
  beforeUpdate() {},
  updated() {},
  beforeDestroy() {
    this.observer?.disconnect();
    EventBus.$off("closeDialog", this.closeDialog);
  },
  destroyed() { }
};
</script>
<style scoped>
.machine {
  position: absolute;
  z-index: 2;
  /* del FNSI-No388 font-size 付 start */
  /* font-size: 1.2em; */
  /* del FNSI-No388 font-size 付 end */
}

div.display-full {
  position: absolute;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start*/
  /* ベッドの図はかぶっているように見える */
  /* top: 0.2em;
  right: -0.4em; */
  top: 0.4em;
  right: 0.1em;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end*/
  background-color: #0000;
  z-index: 2;
}
img.img-icon {
  cursor: pointer;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start*/
  /* ベッドの図はかぶっているように見える */
  /* height: 1.5em;
  width: 1.5em; */
  height: 1em;
  width: 1em;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end*/
}
.machine-inner {
  height: 100%;
  width: 100%;
}
.none-event {
  pointer-events: none;
}
.auto-event {
  pointer-events: auto;
}
img.img-icon {
  cursor: pointer;
  height: 1.5em;
  width: 1.5em;
}
.popover-size {
  padding: 0.5rem 1.0rem 0.5rem 0.5rem;
  font-size: 1.3em;
}
@media (max-height: 410px){
   /* 高さが410px以下の場合に適用するスタイル */
   .tool-tip { transform: scale(1.0); }
}
@media  (min-height:411px) and (max-height:450px){
   /* 高さが411pxから450pxにて適用するスタイル */
   .tool-tip { transform: scale(1.1); }
}
@media  (min-height:451px) and (max-height:550px){
   /* 高さが451pxから550pxにて適用するスタイル */
   .tool-tip { transform: scale(1.2); }
}
@media  (min-height:551px) and (max-height:679px) and (max-width:320px){
   /* 高さが551pxから679pxかつ横幅が320px以内に適用するスタイル */
   .tool-tip { transform: scale(1.2); }
}
@media  (min-height:551px) and (max-height:679px) and (min-width:321px) and (max-width: 419px){
   /* 高さが551pxから679pxかつ横幅が321pxから420px以下に適用するスタイル */
   .tool-tip { transform: scale(1.28); }
}
@media  (min-height:551px) and (max-height:679px) and (min-width:420px){
   /* 高さが551pxから679pxかつ横幅が420p以上に適用するスタイル */
   .tool-tip { transform: scale(1.45); }
}
@media  (min-height:680px) and (max-width:320px){
   /* 高さが680px以上かつ横幅が320px以内に適用するスタイル */
   .tool-tip { transform: scale(1.2); }
}
@media  (min-height:680px) and (min-width:321px) and (max-width: 419px){
   /* 高さが680px以上かつ横幅が321pxから420px以下に適用するスタイル */
   .tool-tip { transform: scale(1.28); }
}
@media  (min-height:680px) and (min-width:420px){
   /* 高さが680px以上かつ横幅が420p以上に適用するスタイル */
   .tool-tip { transform: scale(1.6); }
}
</style>
