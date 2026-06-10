/**
 * ベッド(治療状況マップ)
 */
<template>
  <div :class="[bedDivClass, bedBackColorClass]">
    <span>
      <div v-if="bedData.indicatorDispTreatment.length > 0" class="marker auto-event">
        <div v-if="dispIndicator('koutei')">
          <StatusMapMarker :color="kouteiColor"></StatusMapMarker>
        </div>
        <div v-if="dispIndicator('keihou')" class="stop-listenerend" @click="warnClick">
          <StatusMapMarker :color="keihouColor"></StatusMapMarker>
        </div>
        <div v-if="dispIndicator('indChange')" class="stop-listenerend" @click="markerClick">
          <StatusMapMarker :color="indChangeColor"></StatusMapMarker>
        </div>
      </div>
      <div
        class="bed-name auto-event"
        @click="bedNameClick"
        @mousedown="$event.stopPropagation();"
        @mouseup="$event.stopPropagation();"
        @mousewheel="$event.stopPropagation();"
        @mousemove="$event.stopPropagation();"
        @touchstart="$event.stopPropagation();"
        @touchend="$event.stopPropagation();"
        @touchmove="$event.stopPropagation();"
      >{{ bedName }}</div>
      <div
        class="bed-patient-name auto-event"
        @click="patNameClick"
        @mousedown="$event.stopPropagation();"
        @mouseup="$event.stopPropagation();"
        @mousewheel="$event.stopPropagation();"
        @mousemove="$event.stopPropagation();"
        @touchstart="$event.stopPropagation();"
        @touchend="$event.stopPropagation();"
        @touchmove="$event.stopPropagation();"
        :style="inOutCla"
      >
        {{ patName }}
        <img class="same-icon" v-show="isSame === '1'" :src="image_src_same" />
      </div>
      <div :style="bedLayoutHeight">
        <div style="position: relative" v-if="isOrdNo">
          <div
            v-for="viewItem in viewItemList"
            v-show="isDataVisible(viewItem)"
            :key="viewItem.order_no"
            class="data-row-disp"
          >
            <div v-if="!showDonutGraph(viewItem.data_class)">
              <div v-if="changedViewData(viewItem) == '警報'
              || changedViewData(viewItem) == '報知'
              || changedViewData(viewItem) == '警報報知' || viewItem.data_class == 111">
              {{ viewItem.title }}：&nbsp;
                <img src='img/status-list/keihou.gif' class='ntss-fab-icon'
                  v-if="changedViewData(viewItem) == '警報' || changedViewData(viewItem) == '警報報知'" @click="imgWarnClick"
                  @mousedown="$event.stopPropagation();"
                  @mouseup="$event.stopPropagation();"
                  @mousewheel="$event.stopPropagation();"
                  @mousemove="$event.stopPropagation();"
                  @touchstart="$event.stopPropagation();"
                  @touchend="$event.stopPropagation();"
                  @touchmove="$event.stopPropagation();"
                />
                <img src='img/status-list/houchi.gif' class='ntss-fab-icon' v-else-if="changedViewData(viewItem) == '報知'" @click="imgWarnClick"
                  @mousedown="$event.stopPropagation();"
                  @mouseup="$event.stopPropagation();"
                  @mousewheel="$event.stopPropagation();"
                  @mousemove="$event.stopPropagation();"
                  @touchstart="$event.stopPropagation();"
                  @touchend="$event.stopPropagation();"
                  @touchmove="$event.stopPropagation();"
                />
              </div>
              <div v-else-if="viewItem.data_class == 110" @click="onClickMachineRecordCd"
                @mousedown="$event.stopPropagation();"
                @mouseup="$event.stopPropagation();"
                @mousewheel="$event.stopPropagation();"
                @mousemove="$event.stopPropagation();"
                @touchstart="$event.stopPropagation();"
                @touchend="$event.stopPropagation();"
                @touchmove="$event.stopPropagation();"
              >
                {{ viewItem.title }}：&nbsp;{{ changedViewData(viewItem) }}
              </div>
              <!--#10407:変更なしでも画面を表示させる Start-->
              <div id="changeinstructionline" class="auto-event"
                 v-else-if ="changedViewData(viewItem) === '変更あり'
                 && viewItem.data_class == 109"
                 @click="ChangeInstructionClik">
                 {{ viewItem.title }}：&nbsp;
                 <span id="changeinstructionline" class="auto-event" :class="fontColor(viewItem.data_class)">
                  {{ changedViewData(viewItem) }}　</span>
              </div>
              <div id="changeinstructionline" class="auto-event" v-else-if ="(changedViewData(viewItem) === '変更なし'
                 || changedViewData(viewItem) === '　　　　')
                 && viewItem.data_class == 109" @click="ChangeInstructionClik">
                 {{ viewItem.title }}：&nbsp;{{ changedViewData(viewItem) }}
              </div>
              <!--#10407:変更なしでも画面を表示させる End-->
              <div v-else-if ="viewItem.data_class == 62">
                {{ viewItem.title }}：&nbsp;
                 <span :class="fontColor(viewItem.data_class)">
                  {{ changedViewData(viewItem) }} </span>
              </div>
              <div v-else>
                {{ viewItem.title }}：&nbsp;{{ changedViewData(viewItem) }}
              </div>
            </div>
            <div
              v-if="showDonutGraph(viewItem.data_class)"
              class="progress none-event"
            >
              {{ viewItem.title }}：&nbsp;
              <div v-if="isTreatment && treatmentProgress(viewData(viewItem.order_no)) != '-'">
                <StatusMapDonutGraph
                  :color="'#5F5F'"
                  :percent="treatmentProgress(viewData(viewItem.order_no))"
                ></StatusMapDonutGraph>
              </div>
              <span v-else>
                -
              </span>
            </div>
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
import { mapGetters, mapActions, mapMutations } from "vuex";
import { EventBus } from "@/eventBus.js";
import moment from "moment";
import { INDICATOR_VALUE_TREATMENT_MAP } from "@/constants/statusMapConstants";

export default {
  components: {
    StatusMapMarker,
    StatusMapDonutGraph
  },
  data() {
    return {
      // add 同姓同名配布 linjunfeng start
      image_src_same: require("../../assets/name_duplication.png"),
      // add 同姓同名配布 linjunfeng end
    }
  },
  mixins: [NextTransitionMixin, PatHeaderControlMixin],
  computed: {
    ...mapGetters("status-map/map", {
      getPatTreatmentStatusToPatList: "getPatTreatmentStatusToPatList"
    }),
    ...mapGetters("user", ["getFacilityCd"]),

    // add FNSI-同姓同名患者の場合はアイコンを表示 付 start
    /**
     * 入院外来
     */
    inOutCla() {
      if (
        this.bedData.treatment &&
        this.bedData.treatment.inOutClass === 1
      ) {
        return "color: #A356A3;";
      } else {
        return "";
      }
    },
    // add FNSI-同姓同名患者の場合はアイコンを表示 付 end

    /**
     * 表示項目一覧(ベッド)
     */
    viewItemList() {
      return this.bedData.viewItems;
    },
    /**
     * 工程、通信状況によってベッドの背景色と文字色のクラスを設定
     */
    bedBackColorClass() {
      if (!this.bedData.treatment) {
        // 患者割り当てなし
        return "bed-color-none-patient";
      } else if (
        1 === this.bedData.treatment.isPreventiveMainte ||
        this.bedData.treatment.processState === "99"
      ) {
        // 通信エラー
        return "bed-color-communication-error";
      } else if ("0" === this.bedData.treatment.rstDialysisState) {
        // 次患者
        // mod FNSI- 東京側指摘対応 陳 start
        // return "bed-color-next-patient";
        return "bed-color-none-patient";
        // mod FNSI- 東京側指摘対応 陳 end
      } else if (["1", "2"].includes(this.bedData.treatment.rstDialysisState)) {
        // 条件送信済
        return "bed-color-send";
      } else if ("3" === this.bedData.treatment.rstDialysisState) {
        // 治療中
        return "bed-color-treat";
      } else if ("4" === this.bedData.treatment.rstDialysisState) {
        // 後体重入力まち
        return "bed-color-treat-end";
      } else if ("5" === this.bedData.treatment.rstDialysisState) {
        // 版確定まち
        return "bed-color-treat-unconfirmed";
      } else if ("6" === this.bedData.treatment.rstDialysisState) {
        // 版確定後
        return "bed-color-treat-confirmed";
      } else {
        // 他
        return "bed-color-none-patient";
      }
    },
    /**
     * 高さの算出
     */
    bedLayoutHeight() {
      let ret = "";
      if (this.isPopoverScroll) {
        // mod FNSI-redmine#3950 付 start
        ret = ret + "overflow-y:auto; max-height:280px; min-height:100px;";
        // mod FNSI-redmine#3950 付 end
      } else {
        ret = ret + "overflow-y:hidden";
      }
      return ret;
    },
    bedDivClass() {
      let ret = "bed-inner";
      if (this.isPopoverScroll) {
        ret = ret + " " + document.getElementById("app").getAttribute("class");
      } else {
        ret = ret + " bed-event";
      }
      return ret;
    },
    /**
     * 工程の進行状況によってマーカーの色を設定
     */
    kouteiColor() {
      const PRESET = "01";
      const SENJYOU = "02";
      const SANSEN = "03";
      const SYOUDOKU = "04";
      const TAIRYUU = "05";
      const EKITIKAN = "06";
      const JUNBIKAISYUU = "07";
      const GASS_PURGE = "08";
      const HAIEKI = "09";
      const TEISI = "10";
      const UNTEN = "11";
      const IJYOU = "99";

      let rtn;
      if (
        this.bedData.treatment !== null &&
        this.bedData.treatment !== undefined
      ) {
        switch (this.bedData.treatment.processState) {
          case PRESET:
          case JUNBIKAISYUU:
          case GASS_PURGE:
          case HAIEKI:
            rtn = "#FFFFFF";
            break;
          case SENJYOU:
          case SANSEN:
          case SYOUDOKU:
          case TAIRYUU:
          case EKITIKAN:
            rtn = "#00B0F0";
            break;
          case TEISI:
          case UNTEN:
            rtn = "#00B050";
            break;
          case IJYOU:
            rtn = "#AAAAAA";
            break;
          default:
            rtn = "#FFFFFF";
            break;
        }
      } else {
        rtn = "#FFFFFF";
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
          return "#FF6666";
        } else if (this.bedData.treatment.machineStatus & 0x20) {
          // 報知
          return "#FFF682";
        // add FNSI-警報報知修正 付 start
        } else if (this.bedData.treatment.machineStatus & 0x28) {
          // 警報報知
          return "#FF6666";
        }
        // add FNSI-警報報知修正 付 end
      }
      // 無し
      return "#FFFFFF";
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
     //#10407:変更なしでも画面を表示させる Start
    /**
     * 指示変更の有無で文字色を設定
     */
    fontColor(){
       // 指示変更ありの場合色を付ける
       return viewItems => {
         if (this.bedData.treatment) {
           if(viewItems === 109){
             let changedItem = this.bedData.treatment.IsContentChanged;
             if(changedItem === "1"){
               return "changeColor";
             } else {
               return "nonChangeColor";
             }
           }else if(viewItems === 62){
             let color = "";
             switch (this.bedData.treatment.roundStateHighlighting) {
              case "1":
                color = "roundStateOrange";
                break;
              case "2":
                color = "roundStateRed";
                break;
              default:
                color = "";
                break;
             }
             return color;
           }
         }
       };
    },
    //#10407:変更なしでも画面を表示させる End
    /**
     * OrdNoチェック
     */
    isOrdNo() {
      return this.ordNo != "";
    },
    /**
     * 指示番号
     */
    ordNo() {
      return this.bedData.treatment ? this.bedData.treatment.ordNo : "";
    },
    isTreatment() {
      return (
        //画面エラー修正　20211101 劉祥霖　start
        this.bedData.treatment ?
        this.bedData.treatment &&
        "3" === this.bedData.treatment.rstDialysisState : false
        //画面エラー修正　20211101 劉祥霖　end
      );
    },
    popoverBedData() {
      if (this.popoverVisible === true) {
        return this.bedData;
      } else {
        return null;
      }
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
      return this.bedData.treatment &&
        this.bedData.treatment.hasOwnProperty("ordNo") &&
        this.bedData.treatment.ordNo != null &&
        this.bedData.treatment.hasOwnProperty("patId")
        ? this.bedData.treatment.patId === null
          ? "？？？？"
          : this.bedData.treatment.patName
        : "-";
    },
    // add FNSI-同姓同名患者の場合はアイコンを表示 付 start
    isSame() {
      return this.bedData.treatment
      && this.bedData.treatment.hasOwnProperty("isSame")
      && this.bedData.treatment.isSame != null
      ? this.bedData.treatment.isSame : "";
    },
    // add FNSI-同姓同名患者の場合はアイコンを表示 付 end
    /**
     * 表示項目の表示判定
     */
    isDataVisible() {
      return item => {
        let ret = true;
        // add #7862 2022-10-24 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
        if ("36" == item.key_name|| "77" == item.key_name || "94" == item.key_name) {
          return ret;
        }
        // add #7862 2022-10-24 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
        // 表示項目データ取得
        let data = this.viewData(item.order_no);
        // モニタ、バイタルデータでデータがundefined、NULL、または空の場合
        if (
          // #9216 治療状況レイアウトマスタで患者IDの設定がNG dengshen start
          // 500 <= item.data_class &&
          -10000 >= item.data_class &&
          // #9216 治療状況レイアウトマスタで患者IDの設定がNG dengshen end
          (data === undefined || data === null || data === "")
        ) {
          // 表示しない
          ret = false;
        }
        return ret;
      };
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
     * 表示項目データ：指示変更
     */
    changedViewData() {
      return viewItems => {
        if(this.bedData.treatment){
          if(viewItems.data_class === 109){
            const changedItem = this.bedData.treatment.IsContentChanged;
            if(changedItem === "1"){
              return "変更あり";
            } else if(changedItem === "2"){
              return "条件未送信";
            //#10407:変更なしでも画面を表示させる Start
            } else if (changedItem === "0") {
              return "変更なし";
            } else {
              return "　　　　";
            }
            //#10407:変更なしでも画面を表示させる End
          // add FNSI-装置自己診断の追加 徐 start
          } else if (viewItems.data_class === 110) {
            const machineRecordCd = this.bedData.treatment.machineRecordCd;
            // mod #10063 by zhangruixue 2023-11-17  rollback 7192--start
            // mod FNSI redmine 7192 共通プロトコルV4の自己診断結果が正しく登録されない 劉祥霖 start
            if(machineRecordCd === "G100"){
              return "合格";
            } else if(machineRecordCd === "G101"){
              return "不合格";
            } else if(machineRecordCd === "G102") {
              return "合格(注意)";
            // if(machineRecordCd === "- "){
            //   return "合格";
            // } else if(machineRecordCd === "-   "){
            //   return "不合格";
            // } else if(machineRecordCd === "-  ") {
            //   return "合格(注意)";
              //mod FNSI redmine 7192 共通プロトコルV4の自己診断結果が正しく登録されない 劉祥霖 end
              // mod #10063 by zhangruixue 2023-11-17  rollback 7192--end
            }else{
              //mod FNSI-redmine6018 劉祥霖 start
              // return "";
              return "未実施";
              //mod FNSI-redmine6018 劉祥霖 end
            }
          // add FNSI-装置自己診断の追加 徐 end
          // add FNSI-警報報知の追加 付 start
          } else if (viewItems.data_class === 111) {
            const machineStatus = this.bedData.treatment.machineStatus;
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
          // add FNSI-警報報知の追加 付 end
          // add FNSI-患者名の追加 付 start
          } else if (viewItems.data_class === 2) {
            const hospPatId = this.bedData.treatment.hospPatId;
            if (hospPatId != null && hospPatId != '' && hospPatId != undefined) {
              return hospPatId;
            } else {
              return "";
            }
          // add FNSI-患者名の追加 付 end
          // add #8876 治療状況マップの表示が不正を修正する。 dengshen start
          } else if (viewItems.data_class === -10007) {
            let ret = "";
            switch (this.bedData.treatment["field_" + viewItems.order_no]) {
              case "1": {
                ret = "プリセット";
                break;
              }
              case "2": {
                ret = "洗浄";
                break;
              }
              case "3": {
                ret = "酸洗";
                break;
              }
              case "4": {
                ret = "消毒";
                break;
              }
              case "5": {
                ret = "滞留";
                break;
              }
              case "6": {
                ret = "液置換";
                break;
              }
              case "7": {
                ret = "準備回収";
                break;
              }
              case "8": {
                ret = "ガスパージ";
                break;
              }
              case "9": {
                ret = "排液";
                break;
              }
              case "10": {
                ret = "停止";
                break;
              }
              case "11": {
                ret = "運転";
                break;
              }
              case "99": {
                ret = "通信異常、電源OFF、異常";
                break;
              }
              default: {
                ret = this.bedData.treatment["field_" + viewItems.order_no];
                break;
              }
            }
            return ret;
          } else if(viewItems.data_class === -10038){
            let ret = "";
            switch (this.bedData.treatment["field_" + viewItems.order_no]) {
                case "0": {
                  ret = "HD";
                  break;
                }
                case "1": {
                  ret = "ECUM";
                  break;
                }
                case "2": {
                  ret = "HDF";
                  break;
                }
                case "3": {
                  ret = "HF";
                  break;
                }
                case "4": {
                  ret = "HD+補液";
                  break;
                }
                case "5": {
                  ret = "ECUM+補液";
                  break;
                }
                case "6": {
                  ret = "AFBF";
                  break;
                }
                case "7": {
                  ret = "OHDF";
                  break;
                }
                case "8": {
                  ret = "OHF";
                  break;
                }
                case "9": {
                  ret = "特殊浄化";
                  break;
                }
                case "10": {
                  ret = "I-HDF";
                  break;
                }
                case "-1": {
                  ret = "不明";
                  break;
                }
                default: {
                  ret = "";
                  break;
                }
            }
            return ret;
          } else if(viewItems.data_class === -10012
           || viewItems.data_class === -10013
           || viewItems.data_class === -10025
           || viewItems.data_class === -10039
           || viewItems.data_class === -10040
           || viewItems.data_class === -10059
           || viewItems.data_class === -10060
           || viewItems.data_class === -10070
           || viewItems.data_class === -10071
           || viewItems.data_class === -10074
           || viewItems.data_class === -10076
           || viewItems.data_class === -10077
           || viewItems.data_class === -10078
           || viewItems.data_class === -10081
           || viewItems.data_class === -10082){
            if (typeof this.bedData.treatment["field_" + viewItems.order_no] !== 'number' && !isNaN(typeof this.bedData.treatment["field_" + viewItems.order_no])) {
              return this.bedData.treatment["field_" + viewItems.order_no];
            }
            return Number(this.bedData.treatment["field_" + viewItems.order_no]).toFixed(2);
          // add #8876 治療状況マップの表示が不正を修正する。 dengshen end
          } else {
            return this.bedData.treatment["field_" + viewItems.order_no];
          }
        }
      };
    },
    /**
     * ドーナッツグラフ表示判定
     */
    showDonutGraph() {
      return dataClass => {
        return StatusMapDonutGraph.SHOW_DATA_CLASS.includes(dataClass);
      }
    },
    /**
     * ドーナッツグラフ表示値
     */
    treatmentProgress() {
      return data => {
        return data ? data : "-";
      }
    }
  },
  props: ["bedData", "historyKey", "isPopoverScroll"],
  methods: {
    // mod FNSI-警報・報知追加 付 start
    ...mapActions("multi-modal", ["showSchedule", "showIndicationsDiffModal", "showAralmDetail"]),
    // mod FNSI-警報・報知追加 付 end
    ...mapActions("status-map/ind", {
      setIndOrdNo: "setOrdNo"
    }),
    ...mapActions("schedule-assignment/modal", {
      scheduleAssignmentSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapActions("send-condition/scale", {
      sendConditionSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapActions("treatment-record/common", {
      setTreatmentRecordOrdNo: "setOrdNo",
      setOrdNoForSideBarRecord: "setOrdNoForSideBarRecord"
    }),
    ...mapMutations("pat-info", {
      updateTreatmentPatList: "updateTreatmentPatList",
      setSrcFuncName: "setSrcFuncName"
    }),
    // add FNSI-警報・報知追加 付 start
    ...mapMutations("status-map/map", {
      setAlarmData: "setAlarmData"
    }),
    // add FNSI-警報・報知追加 付 end
    ...mapActions("operation-viewer/motion-record-detail", ["setMotionRecord"]),
    ...mapActions("operation-viewer/motion-record", ["setHeaderInfo"]),
    ...mapActions("operation-viewer/machine", ["getMachine"]),
    ...mapGetters("operation-viewer/machine", ["getSelectMachine"]),
    // ベッド名クリックイベント
    bedNameClick(e) {
      e.preventDefault();
      e.stopPropagation();

      if (this.bedData.treatment !== null) {
        // ordNo
        let selOrdNo = this.bedData.treatment.ordNo;
        // 治療状況
        const selRstDialysisState = this.bedData.treatment.rstDialysisState;
        // 患者ID
        const selPatId = this.bedData.treatment.patId;

        // ordNo判定
        if (selOrdNo !== null) {
          // mod #6400「前体重送信済みや治療中でも体重送信画面へ移行する事がある」について、対応する。 dengshen start
          // if (selRstDialysisState < "3" && selPatId !== null) {
          if (selRstDialysisState == "0" && selPatId !== null) {
          // mod #6400「前体重送信済みや治療中でも体重送信画面へ移行する事がある」について、対応する。 dengshen end
            // 次患者または条件送信済み患者かつ？？？？患者でない場合

            // 患者選択リストに格納
            this.updateTreatmentPatList(this.getPatTreatmentStatusToPatList);
            // 機能コード設定、選択 ord_no を保持
            this.setOrdNoForSideBarRecord(selOrdNo);
            this.setSrcFuncName(this.$router.currentRoute.name);

            // ordNoセット
            this.sendConditionSetSelectOrdNo({
              ordNo: selOrdNo,
              ordNo2: null
            }).then(() => {
              // 条件送信画面へ遷移
              this.goSpecifiedView("send-condition");
            });
          // mod #6400「前体重送信済みや治療中でも体重送信画面へ移行する事がある」について、対応する。 dengshen start
          // } else if (selRstDialysisState !== "0") {
          } else if (selRstDialysisState != "0") {
          // mod #6400「前体重送信済みや治療中でも体重送信画面へ移行する事がある」について、対応する。 dengshen end
            // 治療中以降の患者の場合

            // 患者選択リストに格納
            this.updateTreatmentPatList(this.getPatTreatmentStatusToPatList);
            // 機能コード設定、選択 ord_no を保持
            this.setOrdNoForSideBarRecord(selOrdNo);
            this.setSrcFuncName(this.$router.currentRoute.name);

            // ordNoセット
            this.setSelectedPatHeader(selPatId).then(() => {
              this.$nextTick(() => {
                this.setTreatmentRecordOrdNo(selOrdNo);
                // 治療記録画面へ遷移
                this.$router.push({ name: "treatment-record" });
              });
            });
          }
        }
      }
    },
    // 患者名クリックイベント
    patNameClick(e) {
      e.preventDefault();
      e.stopPropagation();

      if (this.bedData.treatment !== null) {
        // ordNo
        let selOrdNo = this.bedData.treatment.ordNo;
        // 患者ID
        const selPatId = this.bedData.treatment.patId;
        // 治療状況
        const selRstDialysisState = this.bedData.treatment.rstDialysisState;

        // ordNo判定
        if (selOrdNo !== null) {
          // 患者ID判定
          if (selPatId === null) {
            // ？？？患者の場合
            // 名前割り当て画面へ遷移
            // 選択されたord_noの情報をセット
            this.scheduleAssignmentSetSelectOrdNo(selOrdNo).then(() => {
              // スケジュール・名前割り当てモーダル画面表示
              // mod FNSI-？？？？患者割り当てtitle名不正 陳 start
              // mod FNSI-？？？？患者割り当てtitle名不正 付 start
              // this.showSchedule();
              // this.showSchedule({title :"スケジュール割り当て"});
              this.showSchedule({title :"？？？？患者治療割り当て"});
              // mod FNSI-？？？？患者割り当てtitle名不正 付 end
              // mod FNSI-？？？？患者割り当てtitle名不正 陳 end
            });
          /* mod FNSI-治療状況マップ不具合対応 陳 start */
          //} else if (selRstDialysisState == "0") {
          // mod #6400「前体重送信済みや治療中でも体重送信画面へ移行する事がある」について、対応する。 dengshen start
          // } else if (selRstDialysisState < "3") {
          } else if (selRstDialysisState == "0") {
          // mod #6400「前体重送信済みや治療中でも体重送信画面へ移行する事がある」について、対応する。 dengshen end
          /* mod FNSI-治療状況マップ不具合対応 陳 end */

            // 次患者または条件送信済み患者の場合

            // 患者選択リストに格納
            this.updateTreatmentPatList(this.getPatTreatmentStatusToPatList);
            // 機能コード設定、選択 ord_no を保持
            this.setOrdNoForSideBarRecord(selOrdNo);
            this.setSrcFuncName(this.$router.currentRoute.name);

            // ordNoセット
            this.sendConditionSetSelectOrdNo({
              ordNo: selOrdNo,
              ordNo2: null
            }).then(() => {
              // 条件送信画面へ遷移
              this.goSpecifiedView("send-condition");
            });
          } else {
            // 治療中以降の患者の場合

            // 患者選択リストに格納
            this.updateTreatmentPatList(this.getPatTreatmentStatusToPatList);
            // 機能コード設定、選択 ord_no を保持
            this.setOrdNoForSideBarRecord(selOrdNo);
            this.setSrcFuncName(this.$router.currentRoute.name);

            // ordNoセット
            this.setSelectedPatHeader(selPatId).then(() => {
              this.$nextTick(() => {
                this.setTreatmentRecordOrdNo(selOrdNo);
                // 治療記録画面へ遷移
                this.$router.push({ name: "treatment-record" });
              });
            });
          }
        }
      }
    },
    /**
     * ？？？？患者割当後の治療記録画面への遷移
     */
    moveTreatmentRecord(params) {
      this.setSelectedPatHeader(params.patId).then(() => {
        // ordNoセット
        this.$nextTick(() => {
          this.setTreatmentRecordOrdNo(params.ordNo);
          // 治療記録画面へ遷移
          this.$router.push({ name: "treatment-record" });
        });
      });
    },
    //#10407:変更なしでも画面を表示させる Start
    // 指示変更クリックイイベント
    ChangeInstructionClik() {
      if (
        this.bedData.treatment &&
        this.bedData.treatment.rstDialysisState !== "0" &&
        ( this.bedData.treatment.IsContentChanged === null || this.bedData.treatment.IsContentChanged === "0" ||  this.bedData.treatment.IsContentChanged === "1")
      ) {
        this.onClickPatIndChanged();
      }
    },
    // マーカー部クリックイベント
    markerClick(e) {
      e.preventDefault();
      e.stopPropagation();
      if (
        this.bedData.treatment &&
        //#10407:変更なしでも画面を表示させる Start
        this.bedData.treatment.rstDialysisState !== "0" &&
        ( this.bedData.treatment.IsContentChanged === null || this.bedData.treatment.IsContentChanged === "0" ||  this.bedData.treatment.IsContentChanged === "1")
        //#10407:変更なしでも画面を表示させる End
      ) {
        this.onClickPatIndChanged();
      }
    },
    // add FNSI-警報・報知追加 付 start
    imgWarnClick(e) {
      e.preventDefault();
      e.stopPropagation();
      let alarmData = {};
      // alarmData['bedName'] = this.bedData.treatment.bedName;
      // alarmData['patName'] = this.bedData.treatment.patName;
      alarmData['machineTypeCd'] = this.bedData.treatment.machineTypeCd;
      alarmData['machineSerial'] = this.bedData.treatment.machineSerial;
      alarmData['mode'] = 1;
      this.setAlarmData(alarmData);
      // add FNSI-popup close 付 start
      EventBus.$emit("closeDialog");
      // add FNSI-popup close 付 end
      this.showAralmDetail();
    },
    warnClick(e) {
      e.preventDefault();
      e.stopPropagation();
      let alarmData = {};
      // alarmData['bedName'] = this.bedName;
      // alarmData['patName'] = this.patName;
      alarmData['machineTypeCd'] = this.bedData.treatment.machineTypeCd;
      alarmData['machineSerial'] = this.bedData.treatment.machineSerial;
      alarmData['mode'] = 1;
      this.setAlarmData(alarmData);
      // add FNSI-popup close 付 start
      EventBus.$emit("closeDialog");
      // add FNSI-popup close 付 end
      this.showAralmDetail();
    },
    // add FNSI-警報・報知追加 付 end
    // 指示変更内容表示
    onClickPatIndChanged() {
      this.setIndOrdNo(this.bedData.treatment.ordNo).then(() => {
        /* mod #8535 by zhangruixue 2023-05-23 --start */
        EventBus.$emit("closeDialog");
        /* mod #8535 by zhangruixue 2023-05-23 --end */
        this.showIndicationsDiffModal();
      });
    },
    async onClickMachineRecordCd(e) {
      e.preventDefault();
      e.stopPropagation();

      // 装置情報をstoreに設定
      const condition = {
        facilityCd: this.getFacilityCd,
        machineTypeCd: this.bedData.treatment.machineTypeCd,
        machineSerial: this.bedData.treatment.machineSerial
      }
      await this.getMachine(condition);
      await this.setHeaderInfo(this.getSelectMachine());

      // 装置記録表示設定をstoreに設定
      const today = moment().format("YYYY/MM/DD");
      const motionRecord = {
        motionRecordNo: 0, // 自己診断データの検索にはmotionRecordNoを使わないため、任意の数値を指定(nullだとエラーになる)
        dataType: 4,  // 4:自己診断 で固定
        testType: 1,  // 1:配管 で固定
        eventRegDate: today // 当日(YYYY/MM/DD)
      };
      this.setMotionRecord(motionRecord);
      this.goSpecifiedView("operation-viewer-non-split-motion-record-detail");
    },
    /**
     * インジケータの表示判定
     * @param {String} targetField
     * @return {Boolean} true: 表示、false: 非表示
     */
    dispIndicator(targetField) {
      const target = INDICATOR_VALUE_TREATMENT_MAP[targetField];
      return this.bedData.indicatorDispTreatment.includes(target);
    },
  },
  watch: {},
  beforeCreate() {},
  created() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off("ScheduleAssignment", this.moveTreatmentRecord);
    // add 性能改善メモリ不足 shan end
    // スケジュール割当後の治療記録への遷移
    EventBus.$on("ScheduleAssignment", this.moveTreatmentRecord);
  },
  beforeMount() {},
  mounted() {},
  beforeUpdate() {},
  updated() {},
  beforeDestroy() {
    // スケジュール割当後の治療記録への遷移
    EventBus.$off("ScheduleAssignment", this.moveTreatmentRecord);
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

.bed {
  position: absolute;
  border-radius: 5px;
  z-index: 2;
}
.bed-inner {
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start */
  /* width: 100%; */
  box-sizing: border-box;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end */
  height: 100%;
  overflow: hidden !important;
  border: 1px solid #000;
  border-radius: 5px;
  padding: 0.2em;
}
.marker {
  width: 3em;
  height: 1.2em;
  display: -webkit-box;
  -webkit-box-align: center;
  display: flex;
  align-items: center;
}
/* .bed-name {
  height: 30%;
}
.bed-patient-name {
  height: 30%;
} */
div.displayFull {
  position: absolute;
  top: 0.5em;
  right: 0.5em;
  background-color: #eeef;
  color: #000f;
}

div.bed-color-none-patient {
  background-color: var(--status-map-bed-state-color-next-patient);
  color: #000;
}

div.bed-color-next-patient {
  /* mod FNSI-治療状況マップ不具合対応 陳 start */
  /* background-color: var(--status-map-bed-state-color-next-patient); */
  background-color: var(--status-map-bed-state-color-next-patient1);
  /* mod FNSI-治療状況マップ不具合対応 陳 end */
  color: #000;
}

div.bed-color-send {
  /* mod FNSI-治療状況マップ不具合対応 付 start */
  /* background-color: var(--status-map-bed-state-color-send); */
  background-color: var(--status-map-bed-state-color-send1);
  /* mod FNSI-治療状況マップ不具合対応 付 end */
  color: #fff;
}

div.bed-color-treat {
  background-color: var(--status-map-bed-state-color-treat);
  color: #fff;
}

div.bed-color-treat-end {
  background-color: var(--status-map-bed-state-color-treat-end);
  color: #fff;
}
div.bed-color-treat-unconfirmed {
  background-color: var(--status-map-bed-state-color-treat-unconfirmed);
  color: #fff;
}
div.bed-color-treat-confirmed {
  background-color: var(--status-map-bed-state-color-treat-confirmed);
  color: #fff;
}

div.bed-color-communication-error {
  background-color: var(--status-map-bed-state-communication-error);
  color: #fff;
}

.progress {
  /*del FNSI redmine 6020 劉祥霖　start*/
  /*padding: 0.2em;*/
  /*width: 3em;*/
  /*height: 3em;*/
  /*del FNSI redmine 6020 劉祥霖　end*/
  transform: scale(1);
}

div.data-row-disp {
  display: flex;
  display: -webkit-flex;
}
/*#10407:変更なしでも画面を表示させる Start*/
.changeColor {
  color: #FFA500;
}
/*#10407:変更なしでも画面を表示させる End*/
.nonChangeColor {
  color: black;
}

/* mod FNSI-警報報知修正 付 start */
.ntss-fab-icon {
  margin-top: 2px;
  height: 20px;
  width: 20px;
}
/* mod FNSI-警報報知修正 付 end */

/* add FNSI-同姓同名患者の場合はアイコンを表示 付 start */
.same-icon {
  position: relative;
  top: 0.25em;
  height: 20px;
}
/* add FNSI-同姓同名患者の場合はアイコンを表示 付 end */
/* 回診状態_強調表示：オレンジ */
.roundStateOrange {
  color: #FFA500;
}

/* 回診状態_強調表示：赤 */
.roundStateRed {
  color: #FF3366;
}
</style>
