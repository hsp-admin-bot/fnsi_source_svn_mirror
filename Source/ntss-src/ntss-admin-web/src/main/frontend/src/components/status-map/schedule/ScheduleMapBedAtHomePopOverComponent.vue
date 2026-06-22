/**
 * ベッド(治療状況スケジュール)
 */
<template>
  <div :class="bedDivClass">
    <span :style="{ color: bedTextColor, cursor: 'pointer' }">
      <div class="marker none-event">
        <span>
          <StatusMapMarker :color="kouteiColor"></StatusMapMarker>
        </span>
        <img class="img-icon" :src="inOutMarker" v-if="this.bedData.treatment" />
        <img class="img-icon" :src="tabooMarker" v-if="this.bedData.treatment" />
        <img class="img-icon" :src="shuntMarker" v-if="this.bedData.treatment" />
        <img class="img-icon" :src="treatmentMarker" v-if="this.bedData.treatment" />
      </div>
      <div class="bed-name none-event">{{ bedName }}</div>
      <div class="bed-patient-name none-event">{{ patName }}</div>
      <div class="bed-patient-id none-event">患者ID:{{ patId }}</div>
      <div :style="bedLayoutHeight">
        <span v-if="this.bedData.treatment">
          <div v-for="viewItem in viewItemList" :key="viewItem.order_no" class="none-event">
            {{ viewItem.title }}:
            <wbr />
            {{ viewData(viewItem.order_no) }}
          </div>
          <div class="button-area" >
            <button
              class="button button-on-bed"
              @click="movePatViewer($event, bedData.treatment)"
              @mousedown="$event.stopPropagation();"
              @mouseup="$event.stopPropagation();"
              @mousewheel="$event.stopPropagation();"
              @mousemove="$event.stopPropagation();"
              @touchstart="$event.stopPropagation();"
              @touchend="$event.stopPropagation();"
              @touchmove="$event.stopPropagation();"
            >総合ビューア</button>
          </div>
        </span>
      </div>
    </span>
  </div>
</template>

<script>
import StatusMapMarker from "@/components/status-map/StatusMapMarkerComponent";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import inImg from "../../../assets/in.png";
import outImg from "../../../assets/out.png";
import infectionOnImg from "../../../assets/infection_on.png";
import infectionOffImg from "../../../assets/infection_off.png";
import moOnImg from "../../../assets/mo_on.png";
import moOffImg from "../../../assets/mo_off.png";
import vOnImg from "../../../assets/v_on.png";
import vOffImg from "../../../assets/v_off.png";

import {
  PROCESS_STATE,
  MARKER_COLOR
} from "@/constants/statusMapConstants.js";
// import { mapActions } from "@/compat/vue/vuex";

export default {
  data() {
    return {
      image_src_in: inImg,
      image_src_out: outImg,
      image_src_taboo_on: infectionOnImg,
      image_src_taboo_off: infectionOffImg,
      image_src_mo_on: moOnImg,
      image_src_mo_off: moOffImg,
      image_src_v_on: vOnImg,
      image_src_v_off: vOffImg
    };
  },
  components: {
    StatusMapMarker
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
      return `bed-inner  none-event`;
    },
    /**
     * 工程、通信状況によって変わる背景色に合わせて
     * テキストの背景色を設定
     */
    bedTextColor() {
      return "#000F";
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
     * 入院外来マーカー
     */
    inOutMarker() {
      if (
        this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.inOutClass === 1
      ) {
        return this.image_src_in;
      } else {
        return this.image_src_out;
      }
    },
    /**
     * 禁忌マーカー
     */
    tabooMarker() {
      if (
        this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isInfectionMismatch === false
      ) {
        return this.image_src_taboo_off;
      } else {
        return this.image_src_taboo_on;
      }
    },
    /**
     * シャントマーカー
     */
    shuntMarker() {
      if (
        this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isShuntMismttch === false
      ) {
        return this.image_src_v_off;
      } else {
        return this.image_src_v_on;
      }
    },
    /**
     * 治療方法マーカー
     */
    treatmentMarker() {
      if (
        this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isTreatmentMismatch === false
      ) {
        return this.image_src_mo_off;
      } else {
        return this.image_src_mo_on;
      }
    },
    /**
     * 指示番号
     */
    ordNo() {
      return this.bedData.ordMain ? this.bedData.ordMain.ordNo : "";
    }
  },
  props: ["bedData", "historyKey", "isPopoverScroll"],
  methods: {
    /**
     * 患者経過総合ビューアへ遷移
     */
    movePatViewer(ev, treatment) {
      ev.stopPropagation();
      this.setSelectedPatHeader(treatment.patId).then(() => {
        // ordNoセット
        this.$nextTick(() => {
          // 患者経過総合ビューアへ遷移
          this.$router.push({ name: "pat-viewer" });
        });
      });
    }
  },





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
  cursor: pointer;
  border: 1px solid #000;
  border-radius: 5px;
  padding: 0.2em;
}
div.button-area {
  position: absolute;
  right: 1.2em;
  top: 1em;
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
}
button.button-on-bed {
  font-size: 1em;
  margin-left: 0.25em;
  pointer-events: auto;
  zoom: 0.67;
}
</style>
