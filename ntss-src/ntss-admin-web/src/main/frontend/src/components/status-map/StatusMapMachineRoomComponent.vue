/**
 * 機械室の装置(治療状況マップ)
 */
<template>
  <div :class= "machineDivClass"
    :style='{ backgroundColor: machineBackColor }'>
    <span :style='{ color: machineTextColor }'>
      <!-- mod FNSI-警報・報知追加 付 start -->
      <div class="marker auto-event"
        @mousedown="$event.stopPropagation();"
        @mouseup="$event.stopPropagation();"
        @mousewheel="$event.stopPropagation();"
        @mousemove="$event.stopPropagation();"
        @touchstart="$event.stopPropagation();"
        @touchend="$event.stopPropagation();"
        @touchmove="$event.stopPropagation();"
      >
        <div>
          <StatusMapMarker :color="kouteiColor"></StatusMapMarker>
        </div>
        <div @click="warnClick" v-if="keihouColor == '#FFFFFF'">
          <StatusMapMarker :color="keihouColor"></StatusMapMarker>
        </div>
        <div @click="warnClick" v-else>
          <StatusMapMarker :color="keihouColor"></StatusMapMarker>
        </div>
      </div>
      <!-- mod FNSI-警報・報知追加 付 end -->
      <div class='machine-name none-event'>
        {{ machineName }}
      </div>
      <div :style= "machineLayoutHeight">
        <span v-if="this.machineData.treatment">
          <div v-for="viewItem in viewItemList" v-show="isDataVisible(viewItem)" :key="viewItem.order_no"  class='auto-event'>
            <!-- {{ viewItem.title }}:&nbsp;{{ viewData(viewItem.order_no) }} -->
            <!-- mod FNSI-警報報知修正 付 start -->
              <div v-show="changedViewData(viewItem) == '警報'
              || changedViewData(viewItem) == '報知'
              || changedViewData(viewItem) == '警報報知'">
                {{ viewItem.title }}：&nbsp;
                <img src='img/status-list/keihou.gif' class='ntss-fab-icon'
                  v-if="changedViewData(viewItem) == '警報' || changedViewData(viewItem) == '警報報知'" @click="warnClick"
                  @mousedown="$event.stopPropagation();"
                  @mouseup="$event.stopPropagation();"
                  @mousewheel="$event.stopPropagation();"
                  @mousemove="$event.stopPropagation();"
                  @touchstart="$event.stopPropagation();"
                  @touchend="$event.stopPropagation();"
                  @touchmove="$event.stopPropagation();"
                />
                <img src='img/status-list/houchi.gif' class='ntss-fab-icon' v-else-if="changedViewData(viewItem) == '報知'" @click="warnClick"
                  @mousedown="$event.stopPropagation();"
                  @mouseup="$event.stopPropagation();"
                  @mousewheel="$event.stopPropagation();"
                  @mousemove="$event.stopPropagation();"
                  @touchstart="$event.stopPropagation();"
                  @touchend="$event.stopPropagation();"
                  @touchmove="$event.stopPropagation();"
                />
              </div>
              <!-- add #8876 治療状況マップの表示が不正を修正する。 dengshen end -->
              <!-- <div v-show="changedViewData(viewItem) != '警報' -->
              <!-- && changedViewData(viewItem) != '報知' -->
              <!-- && changedViewData(viewItem) != '警報報知' -->
              <!-- && viewItem.key_name != 'D99' -->
              <!-- && viewItem.key_name != 'R99' -->
              <!-- && viewItem.key_name != 'A99'"> -->
              <!--   {{ viewItem.title }}：&nbsp;{{ viewData(viewItem.order_no) }} -->
              <!-- </div> -->
              <div v-show="changedViewData(viewItem) != '警報'
              && changedViewData(viewItem) != '報知'
              && changedViewData(viewItem) != '警報報知'
              && viewItem.key_name != 'D99'
              && viewItem.key_name != 'R99'
              && viewItem.key_name != 'A99'">
                {{ viewItem.title }}：&nbsp;{{ changedViewData(viewItem) }}
              </div>
              <!-- add #8876 治療状況マップの表示が不正を修正する。 dengshen end -->
              <!-- mod FNSI-警報報知修正 付 end -->
          </div>
        </span>
      </div>
    </span>
  </div>
</template>

<script>
import StatusMapMarker from "@/components/status-map/StatusMapMarkerComponent";
import {MACHINE_MODEL} from "@/constants/machineModel";
// add FNSI-警報・報知追加 付 start
import { mapActions, mapMutations } from "vuex";
import { NOTIFY_TOPIC_MACHINE_RESULT } from "@/constants/websocketNotifyTopic";
// add FNSI-警報・報知追加 付 end
import { EventBus } from "@/eventBus.js";

export default {
  // add FNSI-警報・報知追加 付 start
  data () {
    return {
      notifyTopic: NOTIFY_TOPIC_MACHINE_RESULT,
      notifyValue: [],
    }
  },
  // add FNSI-警報・報知追加 付 end
  components: {
    StatusMapMarker
  },
  computed: {
    /**
     * 表示項目一覧(ベッド)
     */
    viewItemList() {
      return this.machineData.viewItems;
    },
    /**
     * 表示項目の表示判定
     */
    isDataVisible() {
      return item => {
        let ret = true;
        // add #7862 2022-09-13 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
        if ("36" == item.key_name || "94" == item.key_name) {
          return ret;
        }
        // add #7862 2022-09-13 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
        // 表示項目データ取得
        let data = this.viewData( item.order_no );
        // モニタ、バイタルデータでデータがundefined、NULL、または空の場合
        // mod #9216 治療状況レイアウトマスタで患者IDの設定がNG dengshen start
        // if ( 500 <= item.data_class && ( data === undefined || data === null
        if ( -10000 >= item.data_class && ( data === undefined || data === null
        // mod #9216 治療状況レイアウトマスタで患者IDの設定がNG dengshen end
          //del FNSI redmine 6017 項目名ごと表示しない再修正　劉祥霖　start
          // || data === ""
          //del FNSI redmine 6017 項目名ごと表示しない再修正　劉祥霖　end
        )) {
          // 表示しない
          ret = false;
        }

        return ret;
      }
    },
    /**
     * 表示項目データ
     */
    viewData() {
      return orderNo => {
        return this.machineData.treatment
          ? this.machineData.treatment["field_" + orderNo]
          : "";
      };
    },
    // add FNSI-警報報知の追加 付 start
    /**
     * 表示項目データ：警報報知
     */
    changedViewData() {
      return viewItems => {
        if(this.machineData.treatment){
          if (viewItems.key_name == "D99"
          || viewItems.key_name == "R99"
          || viewItems.key_name == "A99"
          ) {
            const machineStatus = this.machineData.treatment.machineStatus;
            if (machineStatus & 0x08) {
              // 警報
              return "警報";
            } else if (machineStatus & 0x20) {
              // 報知
              return "報知";
            } else if (machineStatus & 0x28) {
              // 警報報知
              return "警報報知";
            } else {
              return "";
            }
          }
          // add #8876 治療状況マップの表示が不正を修正する。 dengshen start
          // else if(viewItems.data_class === -10232 || viewItems.data_class === -10273){
          //   let ret = "";
          //   switch (this.machineData.treatment["field_" + viewItems.order_no]) {
          //       case "1": {
          //         ret = "プリセット";
          //         break;
          //       }
          //       case "2": {
          //         ret = "洗浄";
          //         break;
          //       }
          //       case "3": {
          //         ret = "酸洗";
          //         break;
          //       }
          //       case "4": {
          //         ret = "消毒";
          //         break;
          //       }
          //       case "5": {
          //         ret = "滞留";
          //         break;
          //       }
          //       case "6": {
          //         ret = "液置換";
          //         break;
          //       }
          //       case "7": {
          //         ret = "準備回収";
          //         break;
          //       }
          //       case "8": {
          //         ret = "ガスパージ";
          //         break;
          //       }
          //       case "9": {
          //         ret = "排液";
          //         break;
          //       }
          //       case "10": {
          //         ret = "停止";
          //         break;
          //       }
          //       case "11": {
          //         ret = "運転";
          //         break;
          //       }
          //       case "20": {
          //         ret = "プリセット";
          //         break;
          //       }
          //       case "21": {
          //         ret = "透析";
          //         break;
          //       }
          //       case "22": {
          //         ret = "予備透析";
          //         break;
          //       }
          //       case "23": {
          //         ret = "液置換";
          //         break;
          //       }
          //       case "24": {
          //         ret = "薬液消毒";
          //         break;
          //       }
          //       case "25": {
          //         ret = "滞留消毒";
          //         break;
          //       }
          //       case "26": {
          //         ret = "熱水消毒";
          //         break;
          //       }
          //       case "27": {
          //         ret = "酸洗浄";
          //         break;
          //       }
          //       case "28": {
          //         ret = "洗浄";
          //         break;
          //       }
          //       case "29": {
          //         ret = "排液";
          //         break;
          //       }
          //       case "40": {
          //         ret = "プリセット";
          //         break;
          //       }
          //       case "41": {
          //         ret = "給水";
          //         break;
          //       }
          //       case "42": {
          //         ret = "循環";
          //         break;
          //       }
          //       case "43": {
          //         ret = "移送待機";
          //         break;
          //       }
          //       case "44": {
          //         ret = "移送";
          //         break;
          //       }
          //       case "45": {
          //         ret = "排液";
          //         break;
          //       }
          //       case "46": {
          //         ret = "洗浄";
          //         break;
          //       }
          //       case "47": {
          //         ret = "消毒";
          //         break;
          //       }
          //       case "60": {
          //         ret = "通常運転";
          //         break;
          //       }
          //       case "61": {
          //         ret = "夜間運転";
          //         break;
          //       }
          //       case "62": {
          //         ret = "熱水消毒運転";
          //         break;
          //       }
          //       case "63": {
          //         ret = "薬液消毒運転";
          //         break;
          //       }
          //       case "64": {
          //         ret = "強制冷却待機中";
          //         break;
          //       }
          //       case "65": {
          //         ret = "強制洗出し待機中";
          //         break;
          //       }
          //       case "99": {
          //         ret = "通信異常、電源OFF、異常";
          //         break;
          //       }
          //       default: {
          //         ret = "";
          //         break;
          //       }
          //   }
          //   return ret;
          // }
          else {
            return this.machineData.treatment["field_" + viewItems.order_no];
          }
          // add #8876 治療状況マップの表示が不正を修正する。 dengshen end
        }
      };
    },
    // add FNSI-警報報知の追加 付 end
    /**
     * 装置名
     */
    machineName() {
      return this.machineData.bedLayout.name;
    },
    /**
     * 警報、通信エラー等の状態によって背景色を決定
     */
    machineBackColor() {
      if (null !== this.machineData.treatment) {
        if (1 === this.machineData.treatment.isPreventiveMainte || this.machineData.treatment.processState === "99") {
          // 通信エラー
          return "#FF6699";
        } else if (this.machineData.treatment.machineStatus & 0x08) {
          // 警報
          return "#FF6666";
        } else if (this.machineData.treatment.machineStatus & 0x20) {
          // 報知
          return "#FFF682";
        }
      }
      return "#FFFFFF";
    },
    /**
     * 高さの算出
     */
    machineLayoutHeight(){
      let ret = "";
      if (this.isPopoverScroll) {
        ret = ret
        // mod FNSI-redmine#3950 付 start
         + "max-height:280px; min-height:100px; overflow-y:auto";
        // mod FNSI-redmine#3950 付 end
      } else {
        ret = ret
          + "overflow-y:hidden";
      }
      return ret;
    },
    machineDivClass(){
      let ret = "machine-room-inner";
      if (this.isPopoverScroll) {
        ret = ret+ " " + document.getElementById("app").getAttribute("class");
      }
      // mod FNSI-警報・報知追加 付 start
      //  else {
      // ret = ret + " none-event";
      // }
      // mod FNSI-警報・報知追加 付 end
      return ret;
    },
    /**
     * 工程、通信状況によって変わる背景色に合わせて
     * テキストの背景色を設定
     */
    machineTextColor() {
      if (null !== this.machineData.treatment) {
        if (1 === this.machineData.treatment.isPreventiveMainte || this.machineData.treatment.processState === "99") {
          // 通信エラー
          return "white";
        } else if (this.machineData.treatment.machineStatus & 0x08) {
          // 警報
          return "white";
        } else if (this.machineData.treatment.machineStatus & 0x20) {
          // 報知
          return "black";
        }
      }
      return "black";
    },
    /**
     * 工程の進行状況によってマーカーの色を設定
     */
    kouteiColor() {
      if (this.machineData.treatment !== null) {
        let rtn;
        switch (this.machineData.treatment.model) {
          case MACHINE_MODEL.DRO: {
            rtn = this.KouteiDroColor(this.machineData.treatment.processState);
            break;
          }
          case MACHINE_MODEL.DAB: {
            rtn = this.KouteiDabColor(this.machineData.treatment.processState);
            break;
          }
          case MACHINE_MODEL.DAD: {
            rtn = this.KouteiDadColor(this.machineData.treatment.processState);
            break;
          }
        }
        return rtn;
      } else {
        return "#FFFF";
      }
    },
    // add FNSI-警報報知修正 付 start
    /**
     * 警報の状態によってマーカーの色を設定
     */
    keihouColor() {
      if (this.machineData.treatment) {
        if (this.machineData.treatment.machineStatus & 0x08) {
          // 警報
          return "#FF6666";
        } else if (this.machineData.treatment.machineStatus & 0x20) {
          // 報知
          return "#FFF682";
        } else if (this.machineData.treatment.machineStatus & 0x28) {
          // 警報報知
          return "#FF6666";
        }
      }
      // 無し
      return "#FFFFFF";
    },
    // add FNSI-警報報知修正 付 end
  },
  props: ["machineData", "isPopoverScroll"],
  methods: {
    // add FNSI-警報・報知追加 付 start
    ...mapMutations("status-map/map", {
      setAlarmData: "setAlarmData"
    }),
    ...mapActions("multi-modal", ["showAralmDetail"]),
    ...mapActions("websocket", ["addWatchTopics", "removeWatchTopics", "dequeueMessage"]),
    warnClick(e) {
      e.preventDefault();
      e.stopPropagation();
      let alarmData = {};
      alarmData['machineTypeCd'] = this.machineData.treatment.machineTypeCd;
      alarmData['machineSerial'] = this.machineData.treatment.machineSerial;
      alarmData['mode'] = 2;
      this.setAlarmData(alarmData);
      // add FNSI-popup close 付 start
      EventBus.$emit("closeDialog");
      // add FNSI-popup close 付 end
      this.showAralmDetail();
    },
    // add FNSI-警報・報知追加 付 end
    KouteiDroColor(processState) {
      const TUUJYOUUNTEN = "60";
      const YAKANNUNTEN = "61";
      const NESSUISYOUDOKUUNNTEN = "62";
      const YAKUZAISYOUDOKUUNNTEN = "63";
      const KYOUSEIREIKYAKUTAIKITYUU = "64";
      const KYOUSEIARAIDASITAIKITYUU = "65";
      const IJYOU = "99";

      let rtn;
      switch (processState) {
        case TUUJYOUUNTEN: {
          rtn = "#00B050";
          break;
        }
        case YAKANNUNTEN: {
          rtn = "#FFFFFF";
          break;
        }
        case NESSUISYOUDOKUUNNTEN:
        case YAKUZAISYOUDOKUUNNTEN:
        case KYOUSEIREIKYAKUTAIKITYUU:
        case KYOUSEIARAIDASITAIKITYUU: {
          rtn = "#00B0F0";
          break;
        }
        case IJYOU: {
          rtn = "#AAAAAA";
          break;
        }
        default: {
          rtn = "#FFFFFF";
          break;
        }
      }
      return rtn;
    },
    KouteiDabColor(processState) {
      const PRESET = "20";
      const TOUSEKI = "21";
      const YOBITOUSEKI = "22";
      const EKITIKAN = "23";
      const YAKUEKISYOUDOKU = "24";
      const TAIRYUUSYOUDOKU = "25";
      const NESSUISYOUDOKU = "26";
      const SANSENJYOU = "27";
      const SENJYOU = "28";
      const HAIEKI = "29";
      const IJYOU = "99";

      let rtn;
      switch (processState) {
        case PRESET:
        case HAIEKI: {
          rtn = "#FFFFFF";
          break;
        }
        case TOUSEKI:
        case YOBITOUSEKI: {
          rtn = "#00B050";
          break;
        }
        case EKITIKAN:
        case YAKUEKISYOUDOKU:
        case TAIRYUUSYOUDOKU:
        case NESSUISYOUDOKU:
        case SANSENJYOU:
        case SENJYOU: {
          rtn = "#00B0F0";
          break;
        }
        case IJYOU: {
          rtn = "#AAAAAA";
          break;
        }
        default: {
          rtn = "#FFFFFF";
          break;
        }
      }
      return rtn;
    },
    KouteiDadColor(processState) {
      const KYUUSHI = "40";
      const ARAISHOUJUNBI = "41";
      const ARAISHOU = "42";
      const YOUKAIJUNBI = "43";
      const YOUKAI = "44";
      const GENTENFUKKI = "45";
      const SUDOUSOUSA = "46";
      const CHOUSEI = "47";
      const IJYOU = "99";

      // DRY-50A：工程定義
      const dry50aProcessCode = {
        code1 : "A0", // プリセット
        code2 : "A1", // 準備溶解
        code3 : "A2", // 溶解
        code4 : "A3", // 追加溶解
        code5 : "A4", // 溶解停止
        code6 : "A5", // 全排液
        code7 : "A6", // 排液溶解槽1
        code8 : "A7", // 排液溶解槽2
        code9 : "A8", // 全洗浄
        code10 : "A9",  // 洗浄溶解槽1
        code11 : "AA",  // 洗浄溶解槽2
        code12 : "AB",  // 給水管熱水洗浄
        code13 : "AC",  // 全消毒
        code14 : "AD",  // 消毒溶解槽2
        code15 : "AE"   // 調整
      };
      // DRY-50B：工程定義
      const dry50bProcessCode = {
        code1 : "B0", // プリセット
        code2 : "B1", // 全消毒
        code3 : "B2", // 全洗浄
        code4 : "B3", // 溶解
        code5 : "B4", // 準備溶解
        code6 : "B5", // 溶解停止
        code7 : "B6", // 消毒溶解槽
        code8 : "B7", // 消毒サブタンク
        code9 : "B8", // 全排液
        code10 : "B9", // 洗浄溶解槽
        code11 : "BA",  // 給水管熱水洗浄
        code12 : "BB",  // 洗浄サブタンク
        code13 : "BC",  // 調整
      };

      let rtn;
      switch (processState) {
        case KYUUSHI:
        case GENTENFUKKI:
        case SUDOUSOUSA:
        case CHOUSEI:
        case dry50aProcessCode.code1:
        case dry50aProcessCode.code6:
        case dry50aProcessCode.code7:
        case dry50aProcessCode.code8:
        case dry50aProcessCode.code15:
        case dry50bProcessCode.code1:
        case dry50bProcessCode.code9:
        case dry50bProcessCode.code13: {
          // 白色
          rtn = "#FFFFFF";
          break;
        }
        case YOUKAIJUNBI:
        case YOUKAI:
        case dry50aProcessCode.code2:
        case dry50aProcessCode.code3:
        case dry50aProcessCode.code4:
        case dry50aProcessCode.code5:
        case dry50bProcessCode.code4:
        case dry50bProcessCode.code5:
        case dry50bProcessCode.code6: {
          // 緑色
          rtn = "#00B050";
          break;
        }
        case ARAISHOUJUNBI:
        case ARAISHOU:
        case dry50aProcessCode.code9:
        case dry50aProcessCode.code10:
        case dry50aProcessCode.code11:
        case dry50aProcessCode.code12:
        case dry50aProcessCode.code13:
        case dry50aProcessCode.code14:
        case dry50bProcessCode.code2:
        case dry50bProcessCode.code3:
        case dry50bProcessCode.code7:
        case dry50bProcessCode.code8:
        case dry50bProcessCode.code10:
        case dry50bProcessCode.code11:
        case dry50bProcessCode.code12: {
          // 水色
          rtn = "#00B0F0";
          break;
        }
        case IJYOU: {
          rtn = "#AAAAAA";
          break;
        }
        default: {
          rtn = "#FFFFFF";
          break;
        }
      }
      return rtn;
    }
  },
  watch: {
    // add FNSI-画面リロードの修正 付 start
    /**
     * WebSocket通知監視
     */
    "notifyValue.length"(newValue) {
      if (newValue > 0) {
        this.dequeueMessage(this.notifyTopic).then(value => {
          let statusOrdNo = value.split(",");
          if (statusOrdNo[3] != '' && statusOrdNo[3] != null && statusOrdNo[3] != undefined) {
            if (this.machineData.treatment) {
              if (this.machineData.treatment.machineSerial != undefined
              && this.machineData.treatment.machineSerial != null
              && this.machineData.treatment.machineSerial == statusOrdNo[3]) {
                if (this.machineData.treatment.machineStatus != undefined) {
                  this.machineData.treatment.machineStatus = statusOrdNo[0];
                }
              }
            }
          }
        });
      }
    },
    // add FNSI-画面リロードの修正 付 start
  },
  beforeCreate() {},
  created() {
    // add FNSI-画面リロードの修正 付 start
    this.$nextTick(() => {
      this.notifyTopic = `${NOTIFY_TOPIC_MACHINE_RESULT}/${this.getFacilityCd}`;
      this.addWatchTopics({
        topic: this.notifyTopic,
        obj: this.notifyValue
      });
    });
    // add FNSI-画面リロードの修正 付 end
  },
  beforeMount() {},
  mounted() {},
  beforeUpdate() {},
  updated() {},
  beforeDestroy() {
    // add FNSI-画面リロードの修正 付 start
    this.removeWatchTopics(this.notifyTopic);
    // add FNSI-画面リロードの修正 付 end
  },
  destroyed() { }
};
</script>
<style scoped>
.none-event {
  pointer-events: none;
}
.auto-event {
  pointer-events: auto;
}
/* add FNSI-警報報知修正 付 start */
.ntss-fab-icon {
  margin-top: 2px;
  height: 20px;
  width: 20px;
}
/* add FNSI-警報報知修正 付 end */
.machine {
  position: absolute;
  border-radius: 5px;
  z-index: 2;
}
.machine-room-inner {
  width: 100%;
  height: 100%;
  overflow: hidden !important;
  border: 1px solid #000;
  border-radius: 5px;
  padding: 0.2em;
}
.marker {
  height: 1.2em;
  display: -webkit-box;
  -webkit-box-align: center;
  display: flex;
  align-items: center;
}
</style>
