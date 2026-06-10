/**
 * ベッド(治療状況マップ)
 */
<template>
  <div :class="[bedDivClass, bedBackColorClass]">
    <span>
      <div class="marker none-event">
        <StatusMapMarker :color="kouteiColor"></StatusMapMarker>
        <StatusMapMarker :color="keihouColor"></StatusMapMarker>
        <StatusMapMarker :color="indChangeColor"></StatusMapMarker>
      </div>
        <div class="bed-name none-event">{{ bedName }}</div>
        <div class="bed-patient-name none-event">{{ patName }}</div>
        <div class="bed-patient-id none-event">患者ID:{{ patId }}</div>
      <div :style="bedLayoutHeight">
          <div class="button-area" v-if="this.bedData.treatment">
            <button
              class="button button-on-bed"
              v-if="isTreatment"
              @click="moveConditionOrRecord($event, bedData.treatment)"
              @mousedown="$event.stopPropagation();"
              @mouseup="$event.stopPropagation();"
              @mousewheel="$event.stopPropagation();"
              @mousemove="$event.stopPropagation();"
              @touchstart="$event.stopPropagation();"
              @touchend="$event.stopPropagation();"
              @touchmove="$event.stopPropagation();"
            >治療記録</button>
          </div>
        <div style="position: relative" v-if="this.bedData.treatment">
          <div v-for="viewItem in viewItemList" :key="viewItem.order_no" class="none-event">
            {{ viewItem.title }}:
            <wbr />
            {{ viewData(viewItem.order_no) }}
          </div>
          <!-- add #6954 2022/10/08 【デグレ】進捗率の値の部分が改行されて表示される dou start -->
          <!-- <div v-if="isTreatment" class="progress none-event"> -->
          <div v-if="isTreatment && treatmentProgress != '-'" class="progress none-event">
          <!-- add #6954 2022/10/08 【デグレ】進捗率の値の部分が改行されて表示される dou end -->
            <StatusMapDonutGraph :color="'#5F5F'" :percent="treatmentProgress"></StatusMapDonutGraph>
          </div>
        </div>
      </div>
    </span>
  </div>
</template>

<script>
import StatusMapMarker from "@/components/status-map/StatusMapMarkerComponent";
import StatusMapDonutGraph from "@/components/status-map/StatusMapDonutGraph";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import {
  PROCESS_STATE,
  MARKER_COLOR,
  DIALISYS_STATE,
  COMM_ERROR
} from "@/constants/statusMapConstants.js";
import { mapActions } from "vuex";

export default {
  components: {
    StatusMapMarker,
    StatusMapDonutGraph
  },
  mixins: [NextTransitionMixin, PatHeaderControlMixin],
  computed: {
    /**
     * 表示項目一覧(ベッド)
     */
    viewItemList() {
      return this.bedData.viewItems;
    },
    /**
     * 表示項目データ
     */
    viewData() {
      return orderNo => {
        return this.bedData.treatment
          ? this.bedData.treatment["field_" + orderNo]
          : "";
      };
    },
    /**
     * ベッド名
     */
    bedName() {
      return this.bedData.bedLayout.name;
    },
    /**
     * 患者名
     */
    patName() {
      return this.bedData.treatment
        ? this.bedData.treatment.patId
          ? this.bedData.treatment.patName
          : "？？？？"
        : "-";
    },
    /**
     * 患者ID(院内)
     */
    patId() {
      return this.bedData.treatment
        ? this.bedData.treatment.hospPatId
        : "-";
    },
    /**
     * 工程、通信状況によってベッドの背景色と文字色のクラスを設定
     */
    bedBackColorClass() {
      if (!this.bedData.treatment) {
        // 患者割り当てなし
        return "bed-color-none-patient";
      } else if (COMM_ERROR === this.bedData.treatment.isPreventiveMainte) {
        // 通信エラー
        return "bed-color-communication-error";
      } else if (DIALISYS_STATE.BEFORE_SEND_CONDITION === this.bedData.treatment.rstDialysisState) {
        // 次患者
        return "bed-color-next-patient";
      } else if ([
          DIALISYS_STATE.AFTER_SEND_CONDITION,
          DIALISYS_STATE.CONFIRMED_SEND_CONDITION
        ].includes(this.bedData.treatment.rstDialysisState)) {
        // 条件送信済
        return "bed-color-send";
      } else if ([
          DIALISYS_STATE.DURING_TREATMENT,
          DIALISYS_STATE.AFTER_DRAINAGE,
          DIALISYS_STATE.AFTER_WEIGHT_MEASURING,
          DIALISYS_STATE.CONFIRMED_WEIGHT_MEASURING
        ].includes(this.bedData.treatment.rstDialysisState)
      ) {
        // 治療中
        return "bed-color-treat";
      } else {
        // 他
        return "bed-color-none-patient";
      }
    },
    /**
     * 高さの算出
     */
    bedLayoutHeight() {
      let ret = "max-height:240px; min-height:100px;";
      if (this.isPopoverScroll) {
        ret = ret
         + "overflow-y:auto";
      } else {
        ret = ret
          + "overflow-y:hidden";
      }
      return ret;

    },
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
     * 警報の状態によってマーカーの色を設定
     */
    keihouColor() {
      if (this.bedData.treatment) {
        if (this.bedData.treatment.machineStatus & 0x08) {
          // 警報
          return "#F00F";
        } else if (this.bedData.treatment.machineStatus & 0x20) {
          // 報知
          return "#FF0F";
        }
      }
      // 無し
      return "#FFFF";
    },
    /**
     * 指示変更の有無でマーカーの色を設定
     */
    indChangeColor() {
      // 指示変更
      if (
        this.bedData.treatment &&
        this.bedData.treatment.rstDialysisState !== "0" &&
        this.bedData.treatment.IsContentChanged === "1"
      ) {
        return "#FFA500FF";
      }
      return "#FFFF";
    },
    /**
     * 指示番号
     */
    ordNo() {
      return this.bedData.ordMain ? this.bedData.ordMain.ordNo : "";
    },
    /**
     * 透析進捗率
     */
    treatmentProgress() {
      if (
        this.bedData.treatment &&
        this.bedData.treatment.rstRunningTime &&
        this.bedData.treatment.condTime > 0
      ) {
        // 経過時間(??:??)形式文字列→経過時間(分)に変換
        const remainTime
          = Number(this.bedData.treatment.runningTime.substring(0, this.bedData.treatment.runningTime.length - 3)) * 60
          + Number(this.bedData.treatment.runningTime.slice(-2));
        // (100 * 経過時間 / 透析予定時間)[%]
        return Math.floor(
          (100 * remainTime) /
            this.bedData.treatment.condTime
        );
      } else {
        return "-";
      }
    },
    isTreatment() {
      return (
        this.bedData.treatment &&
        DIALISYS_STATE.DURING_TREATMENT === this.bedData.treatment.rstDialysisState
      );
    }
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
    /**
     * 治療記録へ遷移
     * 治療中以外は遷移させない（ボタンも表示しない）
     */
    moveConditionOrRecord(ev, treatment) {
      ev.stopPropagation();
      if ([DIALISYS_STATE.DURING_TREATMENT].includes(treatment.rstDialysisState)
      ) {
        // 治療中のベッド 治療記録へ遷移
        this.setSelectedPatHeader(treatment.patId).then(() => {
          // ordNoセット
          this.$nextTick(() => {
            this.setTreatmentRecordOrdNo(treatment.ordNo);
            // 治療記録画面へ遷移
            this.$router.push({ name: "treatment-record" });
          });
        });
      }
    }
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
  border-radius: 5px;
  padding: 0.2em;
}
/*add FNSI-不具合対応 陳 start*/
.marker {
  width: 3em;
  height: 1.2em;
  display: -webkit-box;
  -webkit-box-align: center;
  display: flex;
  align-items: center;
}
/*add FNSI-不具合対応 陳 end*/
.none-event {
  pointer-events: none;
}

div.bed-color-none-patient {
  background-color: var(--status-map-bed-state-color-next-patient);
  color: #000;
}

div.bed-color-next-patient {
  background-color: var(--status-map-bed-state-color-next-patient);
  color: #000;
}

div.bed-color-send {
  background-color: var(--status-map-bed-state-color-send);
  color: #000;
}

div.bed-color-treat {
  background-color: var(--status-map-bed-state-color-treat);
  color: #fff;
}

div.bed-color-treat-end {
  background-color: var(--status-map-bed-state-color-treat-end);
  color: #fff;
}

div.bed-color-communication-error {
  background-color: var(--status-map-bed-state-communication-error);
  color: #000;
}
div.button-area {
  position: absolute;
  right: 1.2em;
  top: 1em;
}
button.button-on-bed {
  font-size: 1em;
  margin-left: 0.25em;
  pointer-events: auto;
  zoom: 0.67;
}
</style>
