/**
 * ベッド(治療状況スケジュール)
 */
<template>
  <div :class="[bedDivClass, bedBackColorClass]">
    <span :style="{cursor: 'pointer' }">
      <div v-if="bedData.indicatorDispSchedule.length > 0" class="marker none-event">
        <StatusMapMarker v-if="dispIndicator('koutei')" :color="kouteiColor"></StatusMapMarker>
<!--        mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc start-->
<!--        <img class="img-icon" :src="inOutMarker" v-if="this.bedData.treatment" />-->
<!--        <img class="img-icon" :src="infectionMarker" v-if="this.bedData.treatment" />-->
<!--        <img class="img-icon" :src="shuntMarker" v-if="this.bedData.treatment" />-->
<!--        <img class="img-icon" :src="treatmentMarker" v-if="this.bedData.treatment" />-->
<!--        <img class="img-icon" :src="eventMarker" v-if="this.bedData.treatment" @click="showPatEvents" />-->
<!--        <img class="img-icon" :src="inspectionMarker" v-if="this.bedData.treatment" @click="showExamRequests" />-->
<!--        <img class="img-icon" :src="radiationMarker" v-if="this.bedData.treatment" @click="showRadRequests" />-->
        <img class="img-icon" :src="inOutMarker" v-if="this.bedData.treatment && !!this.bedData.treatment.ordNo && dispIndicator('inOut')" />
        <img class="img-icon" :src="infectionMarker" v-if="this.bedData.treatment && !!this.bedData.treatment.ordNo && dispIndicator('infection')" />
        <img class="img-icon" :src="shuntMarker" v-if="this.bedData.treatment && !!this.bedData.treatment.ordNo && dispIndicator('va')" />
        <img class="img-icon" :src="treatmentMarker" v-if="this.bedData.treatment && !!this.bedData.treatment.ordNo && dispIndicator('treatment')" />
        <img class="img-icon" :src="eventMarker" v-if="this.bedData.treatment && !!this.bedData.treatment.ordNo && dispIndicator('patEvent')" @click="showPatEvents" />
        <img class="img-icon" :src="inspectionMarker" v-if="this.bedData.treatment && !!this.bedData.treatment.ordNo && dispIndicator('examRequest')" @click="showExamRequests" />
        <img class="img-icon" :src="radiationMarker" v-if="this.bedData.treatment && !!this.bedData.treatment.ordNo && dispIndicator('radRequest')" @click="showRadRequests" />
<!--        mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc end-->
        <v-ons-popover
          :visible.sync="patEventsVisible"
          :target="popoverTarget"
          :direction="popoverDirection"
          cancelable
          v-if="showPatEventsBtn && patEventsVisible"
          :class="fontSizeSet"
          @preshow="popoverPreShow"
          @postshow="popoverPostShow"
          @posthide="popoverPosthide"
        >
          <pat-events/>
        </v-ons-popover>
        <v-ons-popover
          :visible.sync="examRequestsVisible"
          :target="popoverTarget"
          :direction="popoverDirection"
          cancelable
          v-if="showExamRequestsBtn && examRequestsVisible"
          :class="fontSizeSet"
          @preshow="popoverPreShow"
          @postshow="popoverPostShow"
          @posthide="popoverPosthide"
        >
          <exam-requests/>
        </v-ons-popover>
        <v-ons-popover
          :visible.sync="radRequestsVisible"
          :target="popoverTarget"
          :direction="popoverDirection"
          cancelable
          v-if="showRadRequestsBtn && radRequestsVisible"
          :class="fontSizeSet"
          @preshow="popoverPreShow"
          @postshow="popoverPostShow"
          @posthide="popoverPosthide"
        >
          <rad-requests/>
        </v-ons-popover>
      </div>
      <!-- add FNSI redmine5436 fang end -->
      <div class="bed-name none-event">{{ bedName }}</div>
      <!-- mod FNSI-同姓同名患者の場合はアイコンを表示 付 start -->
      <!-- <div class="bed-patient-name none-event"> -->
      <div class="bed-patient-name none-event" :style="inOutCla">
      <!-- mod FNSI-同姓同名患者の場合はアイコンを表示 付 end -->
        {{ patName }}
        <!-- add FNSI-同姓同名患者の場合はアイコンを表示 付 start -->
        <img class="same-icon" v-show="isSame === '1'" :src="image_src_same" />
        <!-- add FNSI-同姓同名患者の場合はアイコンを表示 付 end -->
      </div>
      <div :style="bedLayoutHeight">
        <span v-if="this.bedData.treatment">
          <div
            v-for="viewItem in viewItemList"
            v-show="isDataVisible(viewItem)"
            :key="viewItem.order_no"
            class="none-event data-row-disp"
          >
            <!-- mod FNSI-389 付 start -->
            <!-- {{ viewItem.title }}:&nbsp; -->
            <div v-if="!showDonutGraph(viewItem.data_class)">
              <!-- :class="fontColor(viewItem.data_class)" -->
              <!--#10623:治療状況マップの装置自己診断行押下時の動作不正 Start-->
              <div id="deviceselfdiagnosisline" class="auto-event" v-if="viewItem.data_class == 110" @click="onClickMachineRecordCd">
              <!--#10623:治療状況マップの装置自己診断行押下時の動作不正 End-->
                {{ viewItem.title }}：&nbsp;
                {{ changedViewData(viewItem) }}
              </div>
              <!--#10407:変更なしでも画面を表示させる Start-->
              <div id="changeinstructionline" class="auto-event"
                 v-else-if ="changedViewData(viewItem) === '変更あり'
                 && viewItem.data_class == 109"
                 @click="ChangeInstructionClik">
                 {{ viewItem.title }}：&nbsp;
                 <span id="changeinstructionline" :class="fontColor(viewItem.data_class)">
                  {{ changedViewData(viewItem) }} </span>
              </div>
              <div  id="changeinstructionline"  class="auto-event" v-else-if ="(changedViewData(viewItem) === '変更なし'
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
                {{ viewItem.title }}：&nbsp;
                {{ changedViewData(viewItem) }}
              </div>
            </div>
            <div v-if="showDonutGraph(viewItem.data_class)" class="progress none-event">
              {{ viewItem.title }}：&nbsp;
              <!-- add FNSI-It has been confirmed with Tokyo BSE that it is the wrong code 付 start -->
              <!-- mod #6954 2022/10/08 【デグレ】進捗率の値の部分が改行されて表示される dou start -->
              <!-- <div v-if="isTreatment"> -->
              <div v-if="isTreatment && treatmentProgress(viewData(viewItem.order_no)) != '-'">
                <!-- mod #6954 2022/10/08 【デグレ】進捗率の値の部分が改行されて表示される dou end -->
                <StatusMapDonutGraph
                  :color="'#5F5F'"
                  :percent="treatmentProgress(viewData(viewItem.order_no))"
                ></StatusMapDonutGraph>
              </div>
              <!-- add #6954 2022/10/08 【デグレ】進捗率の値の部分が改行されて表示される dou start -->
              <span v-else>
                -
              </span>
              <!-- add #6954 2022/10/08 【デグレ】進捗率の値の部分が改行されて表示される dou end -->
              <!-- add FNSI-It has been confirmed with Tokyo BSE that it is the wrong code 付 end -->
            </div>
            <!-- mod FNSI-389 付 end -->
          </div>
        </span>
      </div>
    </span>
<!--        mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc start-->
<!--    <div-->
<!--      class="button-area"-->
<!--      v-if="this.bedData.treatment && !this.isPopoverScroll"-->
<!--    >-->
    <div
      class="button-area"
      v-if="this.bedData.treatment && !!this.bedData.treatment.ordNo && !this.isPopoverScroll"
    >
      <!--        mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc end-->
      <v-ons-button
        @click="showPopOver($event)"
        @mousedown="$event.stopPropagation();"
        @mouseup="$event.stopPropagation();"
        @mousewheel="$event.stopPropagation();"
        @mousemove="$event.stopPropagation();"
        @touchstart="$event.stopPropagation();"
        @touchend="$event.stopPropagation();"
        @touchmove="$event.stopPropagation();"
        class="auto-event openclose-icon"
        icon="ion-ios-menu"
        :id="'machine-' + machineNo"
        :disabled="!isShowPopOver"
      ></v-ons-button>
    </div>
    <!-- メニューエリア -->
    <v-ons-popover
      v-if="headerPopoverShowFlag"
      cancelable
      :visible.sync="headerPopoverShowFlag"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'button-area']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div style="margin: 5px;">
        <v-ons-row style="margin-bottom: 5px;">
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   title="ベッド未登録に変更" -->
          <!--   class="btn3-normal" -->
          <!--   @click="unassigment($event, bedData.treatment)" -->
          <!--   :disabled="!this.bedData.isClickable" -->
          <!-- > -->
          <v-ons-button
            title="ベッド未登録に変更"
            class="btn3-normal"
            @click="unassigment($event, bedData.treatment)"
            :disabled="!this.bedData.isClickable || !getItemAuthorized('StatusListMap', 'item_map_schedule_move')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <div class="empty-icon"/>
            ベッド未登録に変更&emsp;
          </v-ons-button>
        </v-ons-row>
        <v-ons-row style="margin-bottom: 5px;">
          <v-ons-button
            title="患者経過総合ビューア"
            class="btn3-normal"
            @click="movePatViewer($event, bedData.treatment)"
          >
            <img class="img-icon2" :src="this.image_pat_viewer" />
            患者経過総合ビューア
          </v-ons-button>
        </v-ons-row>
        <v-ons-row style="margin-bottom: 5px;">
          <v-ons-button
            title="体重測定"
            class="btn3-normal"
            @click="moveWeight($event, bedData.treatment)"
            :disabled="!this.bedData.isEnableWeight"
          >
            <img class="img-icon2" :src="this.image_weight" />
            体重測定&emsp; &emsp; &emsp; &emsp; &emsp;
          </v-ons-button>
        </v-ons-row>
        <v-ons-row style="margin-bottom: 5px;">
          <v-ons-button
            title="治療記録"
            class="btn3-normal"
            @click="moveTreatmentRecord($event, bedData.treatment)"
            :disabled="!this.bedData.isEnableTreatmentRecord"
          >
            <img class="img-icon2" :src="this.image_treatment_record" />
            治療記録&emsp; &emsp; &emsp; &emsp; &emsp;
          </v-ons-button>
        </v-ons-row>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import StatusMapMarker from "@/components/status-map/StatusMapMarkerComponent";
import StatusMapDonutGraph from "@/components/status-map/StatusMapDonutGraph";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import { mapGetters, mapActions, mapMutations } from "vuex";
import PopoverMixin from "@/components/PopoverMixin";
import moment from "moment";
//add FNSI redmine5436 fang start
import {
  FUNC_EXAM_REQUEST,
  FUNC_RAD_REQUEST,
  FUNC_PAT_EVENT,
} from "@/constants/function-code.js";
import patEvents from "@/components/header-contents/ScheduleListHeaderPatEvents.vue";
import examRequests from "@/components/header-contents/ScheduleListHeaderExamRequests.vue";
import radRequest from "@/components/header-contents/ScheduleListHeaderRadRequests.vue";
//add FNSI redmine5436 fang end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
//#10407:変更なしでも画面を表示させる Start
import { EventBus } from "@/eventBus.js";
//#10407:変更なしでも画面を表示させる End
import { INDICATOR_VALUE_SCHEDULE_MAP } from "@/constants/statusMapConstants";

export default {
  data() {
    return {
      image_src_in: require("../../../assets/in.png"),
      image_src_out: require("../../../assets/out.png"),
      image_src_infection_on: require("@/../public/img/schedule-list/mismatch_infection.png"),
      image_src_infection_off: require("@/../public/img/schedule-list/match_infection.png"),
      image_src_mo_on: require("@/../public/img/schedule-list/mismatch_treatment.png"),
      image_src_mo_off: require("@/../public/img/schedule-list/match_treatment.png"),
      image_src_v_on: require("@/../public/img/schedule-list/mismatch_va.png"),
      image_src_v_off: require("@/../public/img/schedule-list/match_va.png"),
      //add FNSI redmine5436 fang start
      image_src_event_on: require("@/../public/img/schedule-list/mismatch_event.png"),
      image_src_event_off: require("@/../public/img/schedule-list/match_event.png"),
      image_src_inspection_on: require("@/../public/img/schedule-list/mismatch_inspection.png"),
      image_src_inspection_off: require("@/../public/img/schedule-list/match_inspection.png"),
      image_src_radiation_on: require("@/../public/img/schedule-list/mismatch_radiation.png"),
      image_src_radiation_off: require("@/../public/img/schedule-list/match_radiation.png"),
      //add FNSI redmine5436 fang end
      image_weight: require("@/../public/img/weight/weight.png"),
      image_treatment_record: require("@/../public/img/treatment-record/treatment-record.png"),
      image_pat_viewer: require("@/../public/img/pat-viewer/pat-viewer.png"),
      headerPopoverShowFlag: false, //メニューの表示フラグ
      popoverTarget: null,
      popoverDirection: "down",
      // add FNSI-同姓同名患者の場合はアイコンを表示 付 start
      inOutCla: "",
      // add FNSI-同姓同名患者の場合はアイコンを表示 付 end
      //add FNSI redmine5436 fang start
      examRequestsVisible: false,
      radRequestsVisible: false,
      patEventsVisible: false,
      //add FNSI redmine5436 fang end
      // add 同姓同名配布 linjunfeng start
      image_src_same: require("../../../assets/name_duplication.png"),
      // add 同姓同名配布 linjunfeng end
    };
  },
  components: {
    StatusMapMarker,
    StatusMapDonutGraph,
    "pat-events": patEvents,
    "exam-requests": examRequests,
    "rad-requests": radRequest
  },
  mixins: [NextTransitionMixin, PatHeaderControlMixin, PopoverMixin],
  computed: {
    ...mapGetters("status-map/map", {
      getPatTreatmentScheduleToPatList: "getPatTreatmentScheduleToPatList",
      getSelectedTreatmentSchedule: "getSelectedTreatmentSchedule",
      getConditionTreatMapCurrentDate: "getConditionTreatMapCurrentDate",
      //add FNSI redmine5436 fang start
      getShowFlg: "getShowFlg"
      //add FNSI redmine5436 fang end
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    /**
     * 表示項目一覧(ベッド)
     */
    viewItemList() {
      return this.bedData.viewItems;
    },
    //画面エラー修正　20211101 劉祥霖　start
    isTreatment() {
      return (
        this.bedData.treatment ?
          this.bedData.treatment &&
          "3" === this.bedData.treatment.rstDialysisState : false
      );
    },
    //画面エラー修正　20211101 劉祥霖　start
    /**
     * 工程、通信状況によってベッドの背景色と文字色のクラスを設定
     */
    bedBackColorClass() {
      if (!this.bedData.treatment) {
        // 患者割り当てなし
        return "bed-color-none-patient";
        // add FNSI-redmine 5461 6350 劉祥霖 start
      } else if(this.bedData.treatment.isDummy==="1") {
        //ダミー部分
        return "bed-color-is-dummy";
        // add FNSI-redmine 5461 6350 劉祥霖 end
      } else if ("0" === this.bedData.treatment.rstDialysisState) {
        // 次患者
        return "bed-color-next-patient";
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
        ret = ret + "max-height:280px; min-height:100px; overflow-y:auto";
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
        ret = ret + " none-event";
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
      //mod #11804 治療状況マップ＞スケジュール画面で工程の表示色が白のまま変化しない zrx start
      if (
        // this.bedData.statusMapInfo !== null &&
        // this.bedData.statusMapInfo !== undefined
        this.bedData.processState !== null &&
        this.bedData.processState !== undefined
      ) {
        // switch (this.bedData.statusMapInfo.processState) {
        switch (this.bedData.processState) {
          //mod #11804 治療状況マップ＞スケジュール画面で工程の表示色が白のまま変化しない zrx end
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
     * 入院外来マーカー
     */
    inOutMarker() {
      if (
        this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.inOutClass === 1
      ) {
        // add FNSI-同姓同名患者の場合はアイコンを表示 付 start
        this.inOutCla = "color: #A356A3;";
        // add FNSI-同姓同名患者の場合はアイコンを表示 付 end
        return this.image_src_in;
      } else {
        // add FNSI-同姓同名患者の場合はアイコンを表示 付 start
        this.inOutCla = "";
        // add FNSI-同姓同名患者の場合はアイコンを表示 付 end
        return this.image_src_out;
      }
    },
    /**
     * 感染症マーカー
     */
    infectionMarker() {
      if (
        this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isInfectionMismatch === false
      ) {
        return this.image_src_infection_off;
      } else {
        return this.image_src_infection_on;
      }
    },
    /**
     * シャントマーカー
     */
    shuntMarker() {
      if (
        this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isShuntMismatch === false
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
    //add FNSI redmine5436 fang start
    /**
     * 患者イベント
     */
    eventMarker() {
      if (this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isEventMismatch) {
        return this.image_src_event_on;
      } else {
        return this.image_src_event_off;
      }
    },

    /**
     * 検査予定
     */
    inspectionMarker() {
      if (this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isInspectionMismatch) {
        return this.image_src_inspection_on;
      } else {
        return this.image_src_inspection_off;
      }
    },

    /**
     * 一般撮影検査予定
     */
    radiationMarker() {
      if (this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isRadiationMismatch) {
        return this.image_src_radiation_on;
      } else {
        return this.image_src_radiation_off;
      }
    },
    //add FNSI redmine5436 fang end
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
    /**
     * 表示項目の表示判定
     */
    isDataVisible() {
      return item => {
        let ret = true;
        // del #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240619 ztc start
        // add #7862 2022-09-13 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
        // if ("36" == item.key_name || "94" == item.key_name) {
        //   return ret;
        // }
        // add #7862 2022-09-13 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
        // del #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240619 ztc end
        // 表示項目データ取得
        let data = this.viewData(item.order_no);
        // モニタ、バイタルデータでデータがundefined、NULL、または空の場合
        if (
          // 500 <= item.data_class &&
          -10000 >= item.data_class &&
          (data === undefined || data === null || data === "")
        ) {
          // 表示しない
          ret = false;
        // add #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc start
        } else if (!!this.bedData.treatment && this.bedData.treatment.ordNo == null && 110 !== item.data_class) {
          ret = false;
        }
        // add #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc end
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
            }else {
              //mod FNSI-redmine6018 劉祥霖 start
              // return "";
              return "未実施";
              //mod FNSI-redmine6018 劉祥霖 end
            }
          // add FNSI-装置自己診断の追加 徐 end
          // add FNSI-患者名の追加 付 start
          } else if (viewItems.data_class === 2) {
            const hospPatId = this.bedData.treatment.hospPatId;
            if (hospPatId != null && hospPatId != '' && hospPatId != undefined) {
              return hospPatId;
            } else {
              return "";
            }
          // add FNSI-患者名の追加 付 end
          } else {
            return this.bedData.treatment["field_" + viewItems.order_no];
          }
        }
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
     * 機械番号
     */
    machineNo() {
      return this.bedData.bedLayout.machine_no;
    },
    /**
     * ドーナッツグラフ表示判定
     */
    showDonutGraph() {
      return dataClass => {
        return StatusMapDonutGraph.SHOW_DATA_CLASS.includes(dataClass);
      };
    },
    /**
     * ドーナッツグラフ表示値
     */
    treatmentProgress() {
      return data => {
        return data ? data : "-";
      };
    },
    isShowPopOver() {
      if (this.getSelectedTreatmentSchedule === null) {
        return true;
      }
      return false;
    },
    //add FNSI redmine5436 fang start
    showExamRequestsBtn() {
      return this.isUseFunction(FUNC_EXAM_REQUEST);
    },
    showRadRequestsBtn() {
      return this.isUseFunction(FUNC_RAD_REQUEST);
    },
    showPatEventsBtn() {
      return this.isUseFunction(FUNC_PAT_EVENT);
    },
    //add FNSI redmine5436 fang end
  },
  props: ["bedData", "historyKey", "isPopoverScroll"],
  methods: {
    ...mapActions("status-map/map", ["unassigmentScheduleOrdMain"]),
    //    ...mapActions("treatment-record/common", ["setOrdNoForSideBarRecord"]),
    ...mapMutations("pat-info", {
      updateTreatmentPatList: "updateTreatmentPatList",
      setSrcFuncName: "setSrcFuncName"
    }),
    //#10407:変更なしでも画面を表示させる Start
    ...mapActions("multi-modal", ["showIndicationsDiffModal"]),
    //#10407:変更なしでも画面を表示させる End
    ...mapActions("treatment-record/common", {
      setTreatmentRecordOrdNo: "setOrdNo",
      setOrdNoForSideBarRecord: "setOrdNoForSideBarRecord"
    }),
    ...mapActions("send-condition/scale", {
      sendConditionSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapActions("operation-viewer/motion-record-detail", ["setMotionRecord"]),
    ...mapActions("operation-viewer/motion-record", ["setHeaderInfo"]),
    ...mapActions("operation-viewer/machine", ["getMachine"]),
    ...mapGetters("operation-viewer/machine", ["getSelectMachine"]),
    //add FNSI redmine5436 fang start
    ...mapGetters("facility", ["isUseFunction"]),
    ...mapActions("schedule-list", [
      "initExamRequests",
      "initRadRequests",
      "initPatEvents",
    ]),
    ...mapActions("schedule-list", {
      setHeaderTreatDateInfo: 'setHeaderInfo'
    }),
    //#10407:変更なしでも画面を表示させる Start
    ...mapActions("status-map/ind", {
      setIndOrdNo: "setOrdNo"
    }),
     //#10407:変更なしでも画面を表示させる End
    //add FNSI redmine5436 fang end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    //#10407:変更なしでも画面を表示させる Start
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
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
    // 指示変更内容表示
    onClickPatIndChanged() {
      this.setIndOrdNo(this.bedData.treatment.ordNo).then(() => {
        EventBus.$emit("closeDialog");
        this.showIndicationsDiffModal();
      });
    },
    //#10407:変更なしでも画面を表示させる End
    /**
     * スケジュール未登録に変更
     */
    unassigment(ev, treatment) {
      // 表示フラグ反転
      this.headerPopoverShowFlag = false;
      ev.stopPropagation();
      this.unassigmentScheduleOrdMain(treatment);
    },
    /**
     * 体重測定へ遷移
     */
    moveWeight(ev, treatment) {
      // add #10359、#10331 編集権限について、対応する。 dengshen start
      //表示フラグ反転
      this.headerPopoverShowFlag = false;
      // add #10359、#10331 編集権限について、対応する。 dengshen end
      ev.stopPropagation();
      // 患者選択リストに格納
      this.updateTreatmentPatList(this.getPatTreatmentScheduleToPatList);
      // 機能コード設定、選択 ord_no を保持
      this.setOrdNoForSideBarRecord(treatment.ordNo);
      this.setSrcFuncName(this.$router.currentRoute.name);
      // ordNoセット
      this.sendConditionSetSelectOrdNo({
        ordNo: treatment.ordNo,
        ordNo2: null
      }).then(() => {
        // 条件送信画面へ遷移
        this.goSpecifiedView("send-condition");
      });
    },
    /**
     * 治療記録へ遷移
     */
    moveTreatmentRecord(ev, treatment) {
      // add #10359、#10331 編集権限について、対応する。 dengshen start
      //表示フラグ反転
      this.headerPopoverShowFlag = false;
      // add #10359、#10331 編集権限について、対応する。 dengshen end
      ev.stopPropagation();
      // 患者選択リストに格納
      this.updateTreatmentPatList(this.getPatTreatmentScheduleToPatList);
      // 機能コード設定、選択 ord_no を保持
      this.setOrdNoForSideBarRecord(treatment.ordNo);
      this.setSrcFuncName(this.$router.currentRoute.name);

      this.setSelectedPatHeader(treatment.patId).then(() => {
        // ordNoセット
        this.$nextTick(() => {
          this.setTreatmentRecordOrdNo(treatment.ordNo);
          // 治療記録画面へ遷移
          this.$router.push({ name: "treatment-record" });
        });
      });
    },
    /**
     * 患者経過総合ビューアへ遷移
     */
    movePatViewer(ev, treatment) {
      // add #10359、#10331 編集権限について、対応する。 dengshen start
      //表示フラグ反転
      this.headerPopoverShowFlag = false;
      // add #10359、#10331 編集権限について、対応する。 dengshen end
      ev.stopPropagation();
      // 患者選択リストに格納
      this.updateTreatmentPatList(this.getPatTreatmentScheduleToPatList);
      // 機能コード設定、選択 ord_no を保持
      this.setOrdNoForSideBarRecord(treatment.ordNo);
      this.setSrcFuncName(this.$router.currentRoute.name);

      this.setSelectedPatHeader(treatment.patId).then(() => {
        // ordNoセット
        this.$nextTick(() => {
          // 患者経過総合ビューアへ遷移
          this.$router.push({ name: "pat-viewer" });
        });
      });
    },
    /**
     * @description ヘッダー部の画面切り替えの表示
     */
    showPopOver(event) {
      this.popoverTarget = event;
      //表示フラグ反転
      this.headerPopoverShowFlag = !this.headerPopoverShowFlag;
      //ストアに状態を通知
      //this.setHeaderSelectionFlag(this.headerPopoverShowFlag);
    },
    async onClickMachineRecordCd() {
      // 装置情報をstoreに設定
      const condition = {
        facilityCd: this.getFacilityCd,
        machineTypeCd: this.bedData.treatment.machineTypeCd,
        machineSerial: this.bedData.treatment.machineSerial
      }
      await this.getMachine(condition);
      await this.setHeaderInfo(this.getSelectMachine());

      // 装置記録表示設定をstoreに設定
      const today = moment(this.getConditionTreatMapCurrentDate).format("YYYY/MM/DD");
      const motionRecord = {
        motionRecordNo: 0, // 自己診断データの検索にはmotionRecordNoを使わないため、任意の数値を指定(nullだとエラーになる)
        dataType: 4,  // 4:自己診断 で固定
        testType: 1,  // 1:配管 で固定
        eventRegDate: today // 当日(YYYY/MM/DD) getConditionTreatMapCurrentDate
      };
      this.setMotionRecord(motionRecord);
      this.goSpecifiedView("operation-viewer-non-split-motion-record-detail");
    },
    //add FNSI redmine5436 fang start
    showPatEvents(event) {
      const today = moment(this.getConditionTreatMapCurrentDate).format("YYYYMMDD");
      if (this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isEventMismatch) {
        this.setHeaderTreatDateInfo({
          treatDate: today
        });
        this.initPatEvents({
          patId: this.bedData.statusMapInfo.patId,
          startDate: null,
          endDate: null
        });
        this.patEventsVisible = true;
        this.popoverTarget = event;
      }
    },
    showExamRequests(event) {
      const today = moment(this.getConditionTreatMapCurrentDate).format("YYYYMMDD");
      if (this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isInspectionMismatch) {
        this.setHeaderTreatDateInfo({
          treatDate: today
        });
        this.initExamRequests({
          patIdList: [this.bedData.statusMapInfo.patId],
          startDate: moment(this.bedData.statusMapInfo.treatDate, 'YYYYMMDD').format('YYYY/MM/DD'),
          endDate: null
        });
        this.examRequestsVisible = true;
        this.popoverTarget = event;
      }
    },
    showRadRequests(event) {
      const today = moment(this.getConditionTreatMapCurrentDate).format("YYYYMMDD");
      if (this.bedData.statusMapInfo &&
        this.bedData.statusMapInfo.isRadiationMismatch) {
        this.setHeaderTreatDateInfo({
          treatDate: today
        });
        this.initRadRequests({
          patIdList: [this.bedData.statusMapInfo.patId],
          startDate: moment(this.bedData.statusMapInfo.treatDate, 'YYYYMMDD').format('YYYY/MM/DD'),
          endDate: null
        });
        this.radRequestsVisible = true;
        this.popoverTarget = event;
      }
    },
    //add FNSI redmine5436 fang end
    /**
     * インジケータの表示判定
     * @param {String} targetField
     * @return {Boolean} true: 表示、false: 非表示
     */
    dispIndicator(targetField) {
      const target = INDICATOR_VALUE_SCHEDULE_MAP[targetField];
      return this.bedData.indicatorDispSchedule.includes(target);
    },
  },
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
.auto-event {
  pointer-events: auto;
}

.bed {
  cursor: pointer;
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
  cursor: pointer;
  border: 1px solid #000;
  border-radius: 5px;
  padding: 0.2em;
}
.marker {
  /* add FNSI-389Marker修正 付 start */
  /* display: flex; */
  /* add FNSI-389Marker修正 付 end */
  align-items: center;
  width: calc(100% - 1.4em);
  display: flex;
  flex-wrap: wrap;
}
img.img-icon {
  cursor: pointer;
  height: 1.2em;
  /* width: 1.2em; */
  /* margin: 0 1px; */
  padding-left: 0.25em;
}
div.button-area {
  position: absolute;
  display: inline-block;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start */
  /* right: -0.4em;
  bottom: -0.6em; */
  right: 0em;
  bottom: -0.1em;
  /* #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end */
}
div.button-area div {
  margin: 2px 3px;
  display: inline-block;
}
.button-area div img.img-icon {
  cursor: pointer;
  /* position: absolute; */
  height: 1.7em;
  width: 1.7em;

  padding: 2px 3px;
  border-radius: 3px;
  /* background-color: #808080; */
  background-color: #0076ff;
}

button.button-on-bed {
  font-size: 1em;
  margin-left: 0.25em;
  pointer-events: auto;
}

/* div.bed-color-selected {
  background-color: #fedf;
  color: #000;
  border: 4px solid rgb(247, 121, 3);
  margin-top: -3px;
  margin-left: -3px;
} */

div.bed-color-none-patient {
  background-color: var(--status-map-bed-state-color-next-patient);
  color: #000;
}
/*add FNSI-redmine 5461 劉祥霖 start*/
div.bed-color-is-dummy {
  background-color: var(--status-map-bed-state-color-is-dummy);
  color: #ffffff;
}
/*add FNSI-redmine 5461 劉祥霖 end*/


div.bed-color-next-patient {
  background-color: var(--status-map-bed-state-color-next-patient);
  color: #000;
}

div.bed-color-send {
  background-color: var(--status-map-bed-state-color-send);
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

.openclose-icon {
  font-size: 1em;
  /* mod FNSI-No389 付 start */
  /* background: #31a9ee; */
  background: rgba(49, 169, 238, 0.5);
  /* mod FNSI-No389 付 end */
  color: black;
  margin-bottom: 2px;
}
.pat-button-area {
  margin: 13px;
}
.button-area div img.img-icon2 {
  cursor: pointer;
  height: 1.5em;
  width: 1.5em;
  margin-right: 16px;
  padding: 2px 3px;
  border-radius: 3px;
}
.button-area div div.empty-icon {
  cursor: pointer;
  height: 1.5em;
  width: 1.5em;
  margin-right: 16px;
  padding: 2px 3px;
  border-radius: 3px;
}
/* mod FNSI-4460 文字サイズ：特大の際に遷移先が見切れる liumx start */
ons-popover >>> .popover--top {
  width: 260px;
  min-height: initial;
}
ons-popover >>> .popover--top > .popover__content {
  width: 260px;
}
/* mod FNSI-4460 文字サイズ：特大の際に遷移先が見切れる liumx end */
.img-name {
  cursor: pointer;
  font-size: 1.5em;
}
.img-name-area {
  padding-top: 2px;
  padding-left: 3px;
}
/*#10407:変更なしでも画面を表示させる Start*/
.changeColor {
  color: #FFA500;
}
/*#10407:変更なしでも画面を表示させる End*/
.nonChangeColor {
  color: black;
}
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
