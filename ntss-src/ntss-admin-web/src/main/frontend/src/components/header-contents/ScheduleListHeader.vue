<template>
  <div class="pat-header">
    <table class="event-area mark-leftmost-header">
      <tr>
        <template v-if="headerDispMode == 1">
          <!-- 患者情報表示モード -->
          <td id="pat-name-area" class="pat-name-area">
            <label id="pat-name-label" @click="clickHeader()">
              <span class="hosp-pat-id">
                ID:{{ selectedPatInfo.selectedPatId }}
                <img v-if="selectedPatInfo.dispSameNameMsgFlag" class="same-icon" :src="image_src_same" />
              </span>
              <br />
              <!-- mod FNSI-redmine3880 徐 start -->
              <!-- <span class="pat-name" :class="patNameClass" :style="patNameFontStyle">{{ selectedPatInfo.selectedPatName }}</span> -->
              <span id="pat-name" class="pat-name" style="max-width: 5.5em;text-overflow: ellipsis;" :style="patNameFontStyle">{{ selectedPatInfo.selectedPatName }}</span>
              <!-- mod FNSI-redmine3880 徐 end -->
            </label>
          </td>

          <td class="pat-icon-area">
            <!--// add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start-->
            <div class="pat-icons-flex pat-icons-flex-1" v-show="!getIsScheduleEnabled">
              <!-- 感染一致/不一致 -->
              <img :src="selectedPatInfo.mismatch_infection ? mismatchInfectionImg : matchInfectionImg" class="cls-status-icon"/>
              <!-- VA一致/不一致 -->
              <img :src="selectedPatInfo.mismatch_va ? mismatchVaImg : matchVaImg" class="cls-status-icon"/>
              <!-- 治療一致/不一致 -->
              <img :src="selectedPatInfo.mismatch_treatment ? mismatchTreatmentImg : matchTreatmentImg" class="cls-status-icon"/>
            </div>
            <div class="pat-icons-flex pat-icons-flex-2" v-show="!getIsScheduleEnabled">
              <!--// add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end-->
              <!-- 患者イベント一致/不一致 -->
              <img
                :src="selectedPatInfo.mismatch_event ? mismatchEventImg : matchEventImg"
                class="cls-status-icon"
                @click="showPatEvents"
                v-if="showPatEventsBtn"
              />
              <!-- 検査予定一致/不一致 -->
              <img
                :src="selectedPatInfo.mismatch_inspection ? mismatchInspectionImg : matchInspectionImg"
                class="cls-status-icon"
                @click="showExamRequests"
                v-if="showExamRequestsBtn"
              />
              <!-- 放射線予定一致/不一致 -->
              <img
                :src="selectedPatInfo.mismatch_radiation ? mismatchRadiationImg : matchRadiationImg"
                class="cls-status-icon"
                @click="showRadRequests"
                v-if="showRadRequestsBtn"
              />
            </div>
            <v-ons-popover
              :visible.sync="patEventsVisible"
              :target="popoverTarget"
              :direction="popoverDirection"
              cancelable
              v-if="showPatEventsBtn"
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
              v-if="showExamRequestsBtn"
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
              v-if="showRadRequestsBtn"
              :class="fontSizeSet"
              @preshow="popoverPreShow"
              @postshow="popoverPostShow"
              @posthide="popoverPosthide"
            >
              <rad-requests/>
            </v-ons-popover>
          </td>
          <td>
            <div class="pat-button-area">
              <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
              <!-- <v-ons-button @click="showPopOver($event)" class="manual-operation-button">機能切替</v-ons-button> -->
              <v-ons-button @click="showPopOver($event)" class="manual-operation-button btn3-normal button">
                <p class="style-text-button">画面</p>
                <p class="style-text-button">遷移</p>
              </v-ons-button>
              <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
            </div>
          </td>
          <td><!-- 余白調整の為のエリア --></td>
        </template>
        <template v-else-if="headerDispMode == 2">
          <!-- デフォルトメッセージ表示モード -->
          <td class="pat-name-area">
            <label>
              <span class="schedule-default-msg">
                {{ getHeaderDefaultMsg }}
              </span>
            </label>
          </td>
        </template>
      </tr>
    </table>

    <!-- メニューエリア -->
    <v-ons-popover cancelable
                   :visible.sync="headerPopoverShowFlag"
                   :target="popoverTarget"
                   :direction="popoverDirection"
                   :cover-target="false"
                   :class="[fontSizeSet, 'schedule-list-header']">
      <div style="margin: 5px;">
        <v-ons-row style="margin-bottom: 5px;">
          <v-ons-col>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <!-- <v-ons-button
              class="btn-scheldule-list"
              title="選択を解除します"
              @click="releaseSelection">
              <div class="icon"></div>
              選択解除
            </v-ons-button> -->
            <v-ons-button
              class="btn-scheldule-list btn3-normal"
              title="選択を解除します"
              :disabled="getIsScheduleEnabled"
              @click="releaseSelection">
              <div class="icon"></div>
              選択解除
            </v-ons-button>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row style="margin-bottom: 5px;">
          <v-ons-col>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <!-- add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229 -->
            <!-- <v-ons-button
              class="btn-scheldule-list"
              title="患者情報画面に移動します"
              @click="changeView('pat-info')"
              :disabled="!canToPatInfo">
              <img class="icon" :src="imagePatInfo"/>
              患者情報
            </v-ons-button> -->
            <!-- add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229 -->
            <v-ons-button
              class="btn-scheldule-list btn3-normal"
              title="患者情報画面に移動します"
              @click="changeView('pat-info')"
              :disabled="!canToPatInfo">
              <img class="icon" :src="imagePatInfo"/>
              患者情報
            </v-ons-button>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row style="margin-bottom: 5px;">
          <v-ons-col>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <!-- add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229 -->
            <!-- <v-ons-button
              class="btn-scheldule-list"
              title="患者経過総合ビューア画面に移動します"
              @click="changeView('pat-viewer')"
              :disabled="!canToPatViewer">
              <img class="icon" :src="imagePatViewer"/>
              患者経過総合ビューア
            </v-ons-button> -->
            <!-- add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229 -->
            <v-ons-button
              class="btn-scheldule-list btn3-normal"
              title="患者経過総合ビューア画面に移動します"
              @click="changeView('pat-viewer')"
              :disabled="!canToPatViewer || getIsScheduleEnabled">
              <img class="icon" :src="imagePatViewer"/>
              患者経過総合ビューア
            </v-ons-button>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row style="margin-bottom: 5px;">
          <v-ons-col>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <!-- <v-ons-button
              class="btn-scheldule-list"
              title="条件送信画面に移動します"
              @click="changeView('send-condition')"
              :disabled="!sendCondFlag">
              <img class="icon" :src="imageWeight"/>
              条件送信
            </v-ons-button> -->
            <v-ons-button
              class="btn-scheldule-list btn3-normal"
              title="体重測定画面に移動します"
              @click="changeView('send-condition')"
              :disabled="!sendCondFlag || getIsScheduleEnabled">
              <img class="icon" :src="imageWeight"/>
              体重測定
            </v-ons-button>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 start -->
            <!-- add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229 -->
            <!-- <v-ons-button
              class="btn-scheldule-list"
              title="治療記録画面に移動します"
              @click="changeView('treatment-record')"
              :disabled="selectedPatInfo.dialysisState == 0 || !canToTreatmentRecord">
              <img class="icon" :src="imageTreatmentRecord" />
              治療記録
            </v-ons-button> -->
            <!-- add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229 -->
            <!-- mod FNSI-6056 titleに付けるbtn3-normalを削除 ljx start -->
            <!-- <v-ons-button
              class="btn-scheldule-list btn3-normal"
              title="治療記録画面に移動します btn3-normal"
              @click="changeView('treatment-record')"
              :disabled="selectedPatInfo.dialysisState == 0 || !canToTreatmentRecord">
              <img class="icon" :src="imageTreatmentRecord" />
              治療記録
            </v-ons-button>-->
            <v-ons-button
              class="btn-scheldule-list btn3-normal"
              title="治療記録画面に移動します"
              @click="changeView('treatment-record')"
              :disabled="selectedPatInfo.dialysisState == 0 || !canToTreatmentRecord || getIsScheduleEnabled">
              <img class="icon" :src="imageTreatmentRecord" />
              治療記録
            </v-ons-button>
            <!-- mod FNSI-6056 ljx end -->
            <!-- FNSI-add 画面スタイル(ボタン)対応 徐 end -->
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>

    <!-- 患者情報カード一覧  ※患者未選択の場合は描画しない -->
    <!-- fix FNSI 内结bug スケジュール表 No.10 start --Sanjingye Sun 20210112 -->
    <!--mod FNSI-画面部品デザイン じょはく start-->
    <!-- mod #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎 start -->
    <div
        v-if="!isPatInfoPageShowing && isPatSelected && !isLoadingPat && isPatInfoVisibleLocal && checkCancelClick()"
      class="card-list"
      :class="cardListSize"
      :style="{ 'width': windowWidth + 'px' }"
    >
    <!-- mod #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎 end -->
    <!--mod FNSI-画面部品デザイン じょはく end-->
    <!-- fix FNSI 内结bug スケジュール表 No.10 end --Sanjingye Sun 20210112 -->
      <card-list :pat-record="selectedPat" :header-click="true" />
      <!-- add FNSI 画面部品デザイン start -- Sanjingye Sun 20210114-->
      <div v-if="selectedPat !== null" class="type-right">
        <img v-if="this.getTheme === 0 && direction === 'left' " class="menu-btn" id="menu-btn" src="img/pat-info/left_w.png" @click="menuDisplay()" style="z-index: 10; opacity: 0.5; top: -85vh; margin-left: 130px;"/>
        <img v-else-if="this.getTheme === 0 && direction === 'right' " class="menu-btn" id="menu-btn" src="img/pat-info/right_w.png" @click="menuDisplay()" style="z-index: 10; opacity: 0.5; top: -85vh; margin-left: 130px;"/>
        <img v-else-if="this.getTheme === 1 && direction === 'left' " class="menu-btn" id="menu-btn" src="img/pat-info/left_b.png" @click="menuDisplay()" style="z-index: 10; opacity: 0.5; top: -85vh; margin-left: 130px;"/>
        <img v-else-if="this.getTheme === 1 && direction === 'right' " class="menu-btn" id="menu-btn" src="img/pat-info/right_b.png" @click="menuDisplay()" style="z-index: 10; opacity: 0.5; top: -85vh; margin-left: 130px;"/>
      </div>
      <!-- add FNSI 画面部品デザイン end -- Sanjingye Sun 20210114-->
    </div>

  </div>
</template>

<script>
import {
  FUNC_EXAM_REQUEST,
  FUNC_RAD_REQUEST,
  FUNC_PAT_EVENT,
  // add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229
  FUNC_PAT_VIEWER,
  FUNC_TREATMENT_RECORD,
  FUNC_PAT_INFO
  // add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229
} from "@/constants/function-code.js";
import PopoverMixin from "@/components/PopoverMixin";
// 画像
import mismatchInfectionImg from "@/../public/img/schedule-list/mismatch_infection.png";
import matchInfectionImg from "@/../public/img/schedule-list/match_infection.png";
import mismatchVaImg from "@/../public/img/schedule-list/mismatch_va.png";
import matchVaImg from "@/../public/img/schedule-list/match_va.png";
import mismatchTreatmentImg from "@/../public/img/schedule-list/mismatch_treatment.png";
import matchTreatmentImg from "@/../public/img/schedule-list/match_treatment.png";
import mismatchEventImg from "@/../public/img/schedule-list/mismatch_event.png";
import matchEventImg from "@/../public/img/schedule-list/match_event.png";
import mismatchInspectionImg from "@/../public/img/schedule-list/mismatch_inspection.png";
import matchInspectionImg from "@/../public/img/schedule-list/match_inspection.png";
import mismatchRadiationImg from "@/../public/img/schedule-list/mismatch_radiation.png";
import matchRadiationImg from "@/../public/img/schedule-list/match_radiation.png";

// ライブラリ

import { mapGetters, mapActions, mapMutations } from "vuex";
//日付処理用
import moment from "moment";
//サイドバーボタンの余白を設定
import { EventBus } from "@/eventBus.js";

// コンポーネント
import cardList from "@/components/pat-info/PatInfoCardList.vue";
import patEvents from "@/components/header-contents/ScheduleListHeaderPatEvents.vue";
import examRequests from "@/components/header-contents/ScheduleListHeaderExamRequests.vue";
import radRequest from "@/components/header-contents/ScheduleListHeaderRadRequests.vue";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #10371 編集権限について、対応する。 dengshen start
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
// add #10371 編集権限について、対応する。 dengshen end
//add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
import {
  DEF_DISABLED,
  DEF_DM_AFBF,
  DEF_DM_ECUM,
  DEF_DM_ECUM_HO,
  DEF_DM_HD,
  DEF_DM_HD_HO,
  DEF_DM_HDF,
  DEF_DM_HF,
  DEF_DM_IHDF,
  DEF_DM_OHDF,
  DEF_DM_OHF,
  DEF_DM_PURIFICATION,
  DEF_DM_UNKNOWN,
  DEF_SHUNT_NONE,
  DEF_SHUNT_UNKNOWN, DEF_SUPPORTED, DEF_UNSUPPORTED
} from "@/stores/schedule-list/ScheduleListStore";
//add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end

/**
 * @description 患者情報ヘッダ
 */
export default {
  // mod #10371 編集権限について、対応する。 dengshen start
  // mixins: [PopoverMixin],
  mixins: [PopoverMixin, UserAuthorityMixin],
  // mod #10371 編集権限について、対応する。 dengshen end

  components: {
    "card-list": cardList,
    "pat-events": patEvents,
    "exam-requests": examRequests,
    "rad-requests": radRequest
  },

  data() {
    return {
      // FNSI - add-画面部品デザイン start --Sanjingye Sun 20210114
      direction: null,
      // FNSI - add-画面部品デザイン end --Sanjingye Sun 20210114
      mismatchInfectionImg, // 画像：感染症不一致
      matchInfectionImg,    // 画像：感染症一致
      mismatchVaImg,        // 画像：VA不一致
      matchVaImg,           // 画像：VA一致
      mismatchTreatmentImg, // 画像：治療不一致
      matchTreatmentImg,    // 画像：治療一致
      mismatchEventImg,     // 画像：患者イベント不一致
      matchEventImg,        // 画像：患者イベント一致
      mismatchInspectionImg,// 画像：検査予定不一致
      matchInspectionImg,   // 画像：検査予定一致
      mismatchRadiationImg, // 画像：放射線予定不一致
      matchRadiationImg,    // 画像：放射線予定一致
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      headerDispMode: 2, //ヘッダー表示モード
      selectedPatInfo: {
        selectedPatId: "", //患者ID
        hospPatId: "", //院内表示用の患者ID
        selectedPatName: "", //患者名
        dispSameNameMsgFlag: false, //同名存在メッセージ表示フラグ
        mismatch_infection: false, //不一致情報:感染症
        mismatch_va: false, //不一致情報:VAシャント
        mismatch_treatment: false, //不一致情報:治療
        mismatch_event: false, //不一致情報:患者イベント
        mismatch_inspection: false, //不一致情報:検査予定
        mismatch_radiation: false, //不一致情報:放射線予定
        plan_inspection: 0.2, //予定:検査
        plan_radioactive: 1, //予定:放射線
        plan_event: 1, //予定:イベント
        dialysisState: 0, //状態
        // fix FNSI 内結 障害 No.8 start -- Sanjingye Sun 20201231
        inOutClass: 0 // 入外区分
        // fix FNSI 内結 障害 No.8 end -- Sanjingye Sun 20201231
      },
      headerPopoverShowFlag: false, //メニューの表示フラグ
      sendCondFlag: true, //条件送信可不可フラグ true:可能
      image_src_same: require('../../assets/name_duplication3.png'), //同姓同名アイコン
      patNameFontSize: 0, //患者名の文字サイズ
      examRequestsVisible: false,
      radRequestsVisible: false,
      patEventsVisible: false,
      imagePatInfo: require("@/../public/img/pat-info/pat-info.png"),
      imagePatViewer: require("@/../public/img/pat-viewer/pat-viewer.png"),
      imageWeight: require("@/../public/img/weight/weight.png"),
      imageTreatmentRecord: require("@/../public/img/treatment-record/treatment-record.png"),
      isPatInfoVisibleLocal: false // add by #9691 shiyw // mod #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎
    };
  },
  computed: {
    ...mapGetters("account-edit", [
        "getStateUserAccountInfo",
        // add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229
        "getUseFunctions",
        // add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229
        // add FNSI 画面部品デザイン start -- Sanjingye Sun 20210114
        "getTheme",
        // add FNSI 画面部品デザイン end -- Sanjingye Sun 20210114
        "getFontSize"
      ]),
    ...mapGetters("facility", ["isUseFunction"]),
    ...mapGetters("pat-info", [
      "selectedPat",
      "isPatInfoVisible", // del #9691 // mod #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎
      "isPatInfoPageShowing",
      "isLoadingPat"
    ]),
    ...mapGetters("window-size", {
      windowWidth: "getSplittedWidth",
      mainWindowWidth: "getMainWindowWidth"
    }),
    ...mapGetters("schedule-list", [
      "getHeaderDispInfo",
      "getHeaderDefaultMsg",
      "getHeaderDispMode",
      "getExamRequests",
      "hasExamRequests",
      "getRadRequests",
      "hasRadRequests",
      "getPatEvents",
      "hasPatEvents",
      //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx start
      "getBedUnmatchCheckInfo",
      //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx end
      "getIsScheduleEnabled"
    ]),

    cardListSize() {
      switch (+this.getFontSize) {
        case 0:
          return "small";
        case 1:
          return "medium";
        case 2:
          return "big";
        case 3:
          return "xbig";
        default:
          return "";
      }
    },

    /**
     * @description 患者選択フラグ
     * @returns {Boolean}
     */
    isPatSelected() {
      return this.selectedPat !== null;
    },
     /**
     * @description 患者名に適用するクラス
     */
    patNameClass() {
      return {
        "pat-name-in-hospital":
          this.isPatSelected &&
          // fix FNSI 内結 障害 No.8 start -- Sanjingye Sun 20201231
          this.selectedPatInfo.inOutClass == 1
          // this.selectedPat.pat_personal_main["in_out_class"] === 1
          // fix FNSI 内結 障害 No.8 end -- Sanjingye Sun 20201231
      };
    },
    // 患者名の文字サイズを設定
    patNameFontStyle() {
      return { "font-size": `${this.patNameFontSize}px`};
    },
    showExamRequestsBtn() {
      return this.isUseFunction(FUNC_EXAM_REQUEST);
    },
    showRadRequestsBtn() {
      return this.isUseFunction(FUNC_RAD_REQUEST);
    },
    showPatEventsBtn() {
      return this.isUseFunction(FUNC_PAT_EVENT);
    },

    // add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229
    canToPatViewer() {
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // return this.getUseFunctions.find(ele => ele == FUNC_PAT_VIEWER) ? true : false;
      return true;
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
    },
    canToTreatmentRecord() {
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // return this.getUseFunctions.find(ele => ele == FUNC_TREATMENT_RECORD) ? true : false;
      return true;
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
    },
    canToPatInfo() {
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // return this.getUseFunctions.find(ele => ele == FUNC_PAT_INFO) ? true : false;
      return true;
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
    }
    // add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229
  },

  watch: {
    /*
     *  ヘッダーの表示モード監視
     *   1:患者情報表示
     *   2:デフォルトメッセージ表示
     */
    getHeaderDispInfo(newVal) {
      if (null !== newVal) {
        //セット情報の組み立て
        const patJson = newVal;

        let shuntFlag = true;
        let infectionFlag = true;
        let deviceModeFlag = true;

        let isSameFlag = false;

        //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx start
        // if ("shuntFlag" in patJson) shuntFlag = patJson.shuntFlag;
        const bedInfo = this.getBedUnmatchCheckInfo(patJson?.bed_cd)
        const bedVaDirect = String(bedInfo?.shunt_position); //ベッドのシャント方向
        const patVaDirect = patJson?.vaDirect; //患者のシャント方向
        if (!patVaDirect || patVaDirect === "undefined" || !bedVaDirect || bedVaDirect === "undefined") {
          shuntFlag = true;
        }else if (DEF_SHUNT_NONE == patVaDirect || DEF_SHUNT_NONE == bedVaDirect) {
          // 3:無
          shuntFlag = true;
        }else if (DEF_SHUNT_UNKNOWN == patVaDirect) {
          // -:不明
          shuntFlag = false;
        }else if (bedVaDirect != patVaDirect) {
          shuntFlag = false;
        }
        //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx end
        //mod #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
        // if ("infectionFlag" in patJson) infectionFlag = patJson.infectionFlag;
        infectionFlag = (bedInfo?.is_infection == null || bedInfo.is_infection === '') ? true : bedInfo.is_infection === patJson.isInfect;
        // if ("deviceModeFlag" in patJson) deviceModeFlag = patJson.deviceModeFlag;
        if (!bedInfo) {
          deviceModeFlag = true;
        } else if (DEF_DISABLED === bedInfo.is_disable) {
          deviceModeFlag = false;
        } else {
          //装置モード:-1:不明、0:HD、1:ECUM,2:HDF、3:HF、4:HD+補液、5:ECUM+補液、6:AFBF、7:OHDF、8:OHF、9:特殊浄化、10:I-HDF
          const deviceModeSupport = {
            [DEF_DM_HD]: bedInfo.is_support_hd,
            [DEF_DM_ECUM]: bedInfo.is_support_ecum,
            [DEF_DM_HDF]: bedInfo.is_support_hdf,
            [DEF_DM_HF]: bedInfo.is_support_hf,
            [DEF_DM_HD_HO]: bedInfo.is_support_hd_ho,
            [DEF_DM_ECUM_HO]: bedInfo.is_support_ecum_ho,
            [DEF_DM_AFBF]: bedInfo.is_support_afbf,
            [DEF_DM_OHDF]: bedInfo.is_support_ohdf,
            [DEF_DM_OHF]: bedInfo.is_support_ohf,
            [DEF_DM_IHDF]: bedInfo.is_support_i_hdf,
            [DEF_DM_PURIFICATION]: bedInfo.is_support_blood_purify,
            [DEF_DM_UNKNOWN]: DEF_UNSUPPORTED
          };
          deviceModeFlag = deviceModeSupport[patJson.deviceMode] === DEF_SUPPORTED;
        }
        //mod #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
        if ("isSame" in patJson) {
          isSameFlag = "1" === patJson.isSame;
        }
        const setJson = {};
        // mod 9485 nullを空文字列判定に変換します 張博 start
        setJson.selectedPatName = `${patJson.patLastName === (null||undefined) ? "" : patJson.patLastName} ${patJson.patFirstName === (null||undefined) ? "" : patJson.patFirstName}`;
        // mod 9485 nullを空文字列判定に変換します 張博 end
        //TODO:削除 setJson.selectedPatId = Math.round(Math.random() * 1000000); //患者ID  TODO:データから設定
        // setJson.selectedPatId = patJson.pat_id; //患者ID  TODO:データから設定
        setJson.selectedPatId = patJson.hospPatId; //患者ID  TODO:データから設定
        // setJson.dispSameNameMsgFlag = Math.random() > 0.5; //同名存在メッセージ表示フラグ TODO:判定して設定
        setJson.dispSameNameMsgFlag = isSameFlag; //同名存在メッセージ表示フラグ TODO:判定して設定
        setJson.mismatch_infection = !infectionFlag; //不一致情報:感染症
        setJson.mismatch_va = !shuntFlag; //不一致情報:VAシャント
        setJson.mismatch_treatment = !deviceModeFlag; //不一致情報:治療
        setJson.plan_inspection = this.generateOpacity(false); //予定:検査
        setJson.plan_radioactive = this.generateOpacity(false); //予定:放射線
        setJson.plan_event = this.generateOpacity(false); //予定:イベント
        //add FutreNetWeb+SI課題管理No5435対応 呉 start
        setJson.mismatch_event = false;
        setJson.mismatch_inspection = false;
        setJson.mismatch_radiation = false;
        //add FutreNetWeb+SI課題管理No5435対応 呉 end
        setJson.ordNo = patJson.ordNo;
        setJson.dialysisState = patJson.dialysisState;
        // fix FNSI 内結 障害 No.8 start -- Sanjingye Sun 20201231
        setJson.inOutClass = patJson.inOutClass
        // fix FNSI 内結 障害 No.8 end -- Sanjingye Sun 20201231

        if (this.showExamRequestsBtn) {
          this.initExamRequests({
            patIdList: [patJson.pat_id],
            startDate: moment(patJson.treatDate, 'YYYYMMDD').format('YYYY/MM/DD'),
            endDate: null
          });
        }

        if (this.showRadRequestsBtn) {
          this.initRadRequests({
            patIdList: [patJson.pat_id],
            startDate: moment(patJson.treatDate, 'YYYYMMDD').format('YYYY/MM/DD'),
            endDate: null
          });
        }

        if (this.showPatEventsBtn) {
          this.initPatEvents({
            patId: patJson.pat_id,
            startDate: null,
            endDate: null
          });
        }

        //組み立てた値の格納
        this.selectedPatInfo = setJson;
        // console.log("end ScheduleListHeader 表示内容が変更された");

        //選択された患者IDをストアに格納
        this.setSelectedPat(patJson.pat_id);
        //選択されたオーダー番号をストアに格納
        this.setOrdNo(patJson.ordNo);
        //選択された治療日付をストアに格納
        //yyyymmdd -> yyyy-mm-dd
        const year = patJson.treatDate.substring(0, 4);
        const month = patJson.treatDate.substring(4, 6);
        const day = patJson.treatDate.substring(6, 8);
        const treatDate_yyyy_mm_dd = `${year}-${month}-${day}`;

        this.setTreatBaseDate(treatDate_yyyy_mm_dd);

        const mToday = moment().format("YYYY-MM-DD");

        //条件送信可不可確認
        if (
          mToday === treatDate_yyyy_mm_dd &&
          patJson.dialysisState <= 2
        ) {
          //条件送信可能
          this.sendCondFlag = true;
        } else {
          //条件送信できない
          this.sendCondFlag = false;
        }
      }
      //表示ブロックの表示選択(のバインド変数への値のセット)
      this.headerDispMode = this.getHeaderDispMode;
      //操作ポップアップの非表示化
      this.headerPopoverShowFlag = false;
      this.setHeaderSelectionFlag(this.headerPopoverShowFlag);
    },

    // 患者選択時の動作
    selectedPatInfo() {
      if (this.selectedPatInfo !== null && this.selectedPatInfo.selectedPatName != undefined) {
        // 患者名幅の調整
        setTimeout(() => {
          this.calPatNameAreaWidth();
        },0);
      }
    },

    mainWindowWidth(){
      this.calPatNameAreaWidth();
    },
    getFontSize(){
      this.calPatNameAreaWidth();
    },

    getExamRequests() {
      this.selectedPatInfo.mismatch_inspection = this.hasExamRequests(this.getHeaderDispInfo.treatDate);
    },
    getRadRequests() {
      this.selectedPatInfo.mismatch_radiation = this.hasRadRequests(this.getHeaderDispInfo.treatDate);
    },
    getPatEvents() {
      this.selectedPatInfo.mismatch_event = this.hasPatEvents(this.getHeaderDispInfo.treatDate);
    }
  },
  async created() {
    if (!this.isPatInfoPageShowing) {
      // ヘッダのカード一覧を非表示
      this.setIsPatInfoVisible(false);
    }
    // FNSI - add-画面部品デザイン start --Sanjingye Sun 20210114
    this.direction = "left";
    // FNSI - add-画面部品デザイン end --Sanjingye Sun 20210114
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
    EventBus.$on("changeMismatchVa", this.changeMismatchVa);
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    EventBus.$on("changeMismatchInfection", this.changeMismatchInfection);
    EventBus.$on("changeMismatchTreatment", this.changeMismatchTreatment);
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
  },
  beforeDestroy() {
    EventBus.$off("changeMismatchVa", this.changeMismatchVa);
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    EventBus.$off("changeMismatchInfection", this.changeMismatchInfection);
    EventBus.$off("changeMismatchTreatment", this.changeMismatchTreatment);
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
  },

  methods: {
    ...mapActions("schedule-list", [
      "setHeaderInfo",
      "setBedInfoForHeader",
      "setHeaderSelectionFlag",
      "initExamRequests",
      "initRadRequests",
      "initPatEvents",
      "setIsPatientEnabled"
    ]),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("treatment-record/common", ["setOrdNo", "setOrdNoForSideBarRecord", "setOrd"]),
    ...mapActions("pat-viewer", ["setTreatBaseDate"]),
    ...mapMutations("pat-info", {
      setPat: "setSelectedPat",
      setIsLoadingPat: "setIsLoadingPat",
      setIsPatInfoVisible: "setIsPatInfoVisible",
      setSrcFuncName: "setSrcFuncName"
    }),
    ...mapActions("send-condition/scale", ["setSelectOrdNo", "setInputPatId"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    changeMismatchVa(value) {
      this.selectedPatInfo.mismatch_va = value;
    },
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    changeMismatchInfection(value) {
      this.selectedPatInfo.mismatch_infection = value;
    },
    changeMismatchTreatment(value) {
      this.selectedPatInfo.mismatch_treatment = value;
    },
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    //  add FNSI-ジャンルメニューの固定化 start --Sanjingye Sun 20210114
    menuDisplay() {
      let name = document.getElementById("menu-bar-id");
      if (name.classList.contains("block")) {
        this.direction = "right";
        document.getElementById("menu-btn").style.marginLeft = "0px";
        document.getElementById("menu-bar-id").setAttribute("class", "menu-bar-contents button-size none");
        document.getElementsByClassName("card-infos")[0].style.marginLeft = "0px";
      } else {
        this.direction = "left";
        document.getElementById("menu-btn").style.marginLeft = "130px";
        document.getElementById("menu-bar-id").setAttribute("class", "menu-bar-contents button-size block");
        document.getElementsByClassName("card-infos")[0].style.marginLeft = "143px";
      }
    },
    //  add FNSI-ジャンプメニューの固定化 start --Sanjingye Sun 20210114

    /**
     * @description ヘッダクリック時のカード一覧表示切り替え
     */
    clickHeader() {
      // add #10371 編集権限について、対応する。 dengshen start
      // 権限チェックを行う
      if (!this.hasNextAuthority(FUNC_PAT_INFO)) {
        return;
      }
      // add #10371 編集権限について、対応する。 dengshen end
      // add FNSI スケジュール表 権限対応 start -- Sanjingye Sun 20201229
      if(!this.canToPatInfo) {
        return;
      }
      // add FNSI スケジュール表 権限対応 end -- Sanjingye Sun 20201229

      if (this.getStateUserAccountInfo.patId === null) {
        // mod #9691 by shiyw start
        // this.setIsPatInfoVisible(!this.isPatInfoVisible);
        // ヘッド患者情報card-listの表示状態を制御するためにローカル変数を使用する
        this.isPatInfoVisibleLocal = !this.isPatInfoVisibleLocal; // mod #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎
        // mod #9691 by shiyw end
      }
    },
    // add #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎 start
    /**
     * @description キャンセルボタン、および保存ボタンクリック時の画面表示制御用処理
     */
    checkCancelClick() {
      // キャンセルボタン、および保存ボタンがクリックされた場合、ローカルの表示制御フラグ状態と比較する
      if (this.isPatInfoVisible == this.isPatInfoVisibleLocal) {
        // フラグ状態が一致している場合、キャンセルボタン、および保存ボタンがクリックされたため、ローカルの表示制御フラグ共に初期化
        this.isPatInfoVisibleLocal = false;
        this.setIsPatInfoVisible(false);
        // 画面を非表示にするため、falseを返却
        return false;
      }
      // フラグ状態が不一致の場合、キャンセルボタン、および保存ボタンはクリックされていないため、画面表示状態にする
      return true;
    },
    // add #10234 スケジュール表のヘッダーから表示される患者情報画面の動作不正修正 宮崎 end
    /**
     * @description 患者選択
     * @summary 選択した患者の患者情報レコードをストアに格納する
     */
    async setSelectedPat(selectedPatId) {
      this.setIsLoadingPat(true);
      this.setPat(null);
      await this.selectPat(selectedPatId).catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ScheduleListHeader.vue', 'setSelectedPat', '患者選択失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // TODO: エラー処理検討
        throw new Error("[PatList.vue]setSelectedPat(): 患者選択失敗");
      });
      this.setIsLoadingPat(false);
    },
    /**
     * @description 操作ポップオーバーの表示
     */
    showPopOver(event) {
      this.popoverTarget = event;
      //表示フラグ反転
      this.headerPopoverShowFlag = !this.headerPopoverShowFlag;
      //ストアに状態を通知
      this.setHeaderSelectionFlag(this.headerPopoverShowFlag);
    },
    /**
     * 選択解除処理
     */
    releaseSelection() {
      // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
      this.setIsPatientEnabled(false)
      // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
      //ストアの患者の情報をクリア
      this.setHeaderInfo(null);
      this.setBedInfoForHeader(null);
      //操作メニュー表示オフ
      this.headerPopoverShowFlag = false;
      this.setHeaderSelectionFlag(this.headerPopoverShowFlag);
      //add FutreNetWeb+SI課題管理No4221対応 呉 start
      this.$parent.$children[2].senntakuKaijyou();
      //add FutreNetWeb+SI課題管理No4221対応 呉 end
    },
    /**
     * opacity値の設定
     * flagがtrueの時、1を返す。falseの時、0.2を返す
     * @param flag true/false
     */
    generateOpacity(flag) {
      //     flag = Math.random() > 0.5; //値をランダムに決定 TODO:呼び出し元でデータから取得。後、取り外す

      const retVal = flag ? 1 : 0.2;

      return retVal;
    },
    /**
      ページ遷移処理
      @param toName   遷移先の登録名 ntss-admin-web\src\main\frontend\src\router\json\routing-defs.jsonのrouter_name
     */
    changeView(toName) {
      // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong start
      this.setIsPatientEnabled(false)
      // add/ #10239【デグレ】スケジュール表表示時の患者検索、患者リストでの患者切替不可 tianqidong end
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      //操作メニュー表示オフ
      this.headerPopoverShowFlag = false;
      // mod #10359、#10331 編集権限について、対応する。 dengshen end
      //TODO:遷移先に必要な情報(患者ID)を渡すorストアにセットする
      if (toName === "send-condition") {
        if (this.sendCondFlag) {
          this.setInputPatId(this.selectedPatInfo.hospPatId);
          this.setSelectOrdNo({
            ordNo: this.selectedPatInfo.ordNo,
            ordNo2: null
          });
        } else {
          //何もしない
          return;
        }
      }
      // add FNSI修正 治療記録画面バッグ 房 start
      if (toName === "treatment-record") {
        this.setOrd({readOnly: false,});
      }
      // add FNSI修正 治療記録画面バッグ 房 end
      //選択 ord_no を保持
      this.setOrdNoForSideBarRecord(this.selectedPatInfo.ordNo);
      //画面遷移
      this.setSrcFuncName(this.$router.currentRoute.name);
      this.$router.push({ name: toName });
    },
    showPatEvents(event) {
      if (this.selectedPatInfo.mismatch_event) {
        this.patEventsVisible = true;
        this.popoverTarget = event;
      }
    },
    showExamRequests(event) {
      if (this.selectedPatInfo.mismatch_inspection) {
        this.examRequestsVisible = true;
        this.popoverTarget = event;
      }
    },
    showRadRequests(event) {
      if (this.selectedPatInfo.mismatch_radiation) {
        this.radRequestsVisible = true;
        this.popoverTarget = event;
      }
    },
    // ID・名前エリアの横幅設定
    calPatNameAreaWidth() {
      // ID表示部の縦位置を戻す
      if (document.getElementById("pat-name-label")) {
        document.getElementById("pat-name-label").style.verticalAlign = "0em";
      }

      if (this.headerDispMode === 2) {
        return;
      }

      if (this.selectedPatInfo === null || this.selectedPatInfo.selectedPatId === "") {
        return;
      }

      // サイドバー表示エリアのサイズチェック
      const searchButtonAreaStyles = window.getComputedStyle(document.getElementsByClassName("event-area")[0]);
      const searchButtonAreaLength = Number(searchButtonAreaStyles.getPropertyValue("margin-left").replace("px",""));

      // ID・名前エリア MAX幅
      // ヘッダー横幅 - サイドコンテンツ - ②エリア - ③エリア - フロートメニュー
      let patNameMaxWidth = document.getElementsByClassName("pat-header")[0].clientWidth
        - searchButtonAreaLength
        - document.getElementsByClassName("pat-icon-area")[0].clientWidth
        - document.getElementsByClassName("pat-button-area")[0].clientWidth
        - document.getElementById("user-menu").clientWidth;

      // ID・名前エリア MIN幅
      // iPhone横幅(375px) - サイドコンテンツ - ②エリア - ③エリア - フロートメニュー
      let patNameMinWidth = 375
        - searchButtonAreaLength
        - document.getElementsByClassName("pat-icon-area")[0].clientWidth
        - document.getElementsByClassName("pat-button-area")[0].clientWidth
        - document.getElementById("user-menu").clientWidth;

      // エリア削除してもMAX幅がMIN幅未満の場合、MAX幅 = MIN幅にする
      if(patNameMaxWidth < patNameMinWidth) {
        // MAX幅の再計算
        patNameMaxWidth = patNameMinWidth;
      }

      // 患者名フォントサイズ：標準
      document.getElementById("pat-name").style.fontSize = "3.5em";

      // ID・名前エリアはMIN幅・MAX幅のみ設定し、横幅を自動変更できるようにする
      document.getElementById("pat-name-area").style.minWidth = patNameMinWidth + "px" ;
      document.getElementById("pat-name-area").style.maxWidth = patNameMaxWidth + "px" ;
      document.getElementById("pat-name").style.maxWidth = patNameMaxWidth + "px" ;

      // 変更後の幅を取る
      let changedWidth = document.getElementById("pat-name").clientWidth;

      // 変更後の幅がMAX幅を超える場合、フォントサイズを小さくする
      if (changedWidth >= patNameMaxWidth) {
        // 患者名フォントサイズ：第1段階
        document.getElementById("pat-name").style.fontSize = "2.5em";

        // 変更後の幅を取る
        changedWidth = document.getElementById("pat-name").clientWidth;

        // 変更後の幅がMAX幅を超える場合、フォントサイズを小さくする
        // ここまで小さくしても収まらない場合、「…」で省略
        if (changedWidth >= patNameMaxWidth) {
          // 患者名フォントサイズ：第2段階
          document.getElementById("pat-name").style.fontSize = "1.5em";

          // アイコンが隠れる可能性がある場合、縦位置調整
          let hospPatIdLabel = document.getElementsByClassName("hosp-pat-id")[0].clientWidth;
          changedWidth = document.getElementById("pat-name").clientWidth;
          if (hospPatIdLabel >= changedWidth) {
            document.getElementById("pat-name-label").style.verticalAlign = "0.5em";
          }
        }
      }
    },
  }
};
</script>

<style scoped>
/* fix FNSI 内结bug スケジュール表 No.10 end --Sanjingye Sun 20210112 */
.card-list {
  font-size: 150%;
  /*del FNSI-画面部品デザイン じょはく start*/
  /*overflow-y: scroll;*/
  /*del FNSI-画面部品デザイン じょはく end*/
  position: fixed;
  height: auto;
  top: 3.8em;
  /* bottom: 70px;
  margin-top:40px;
  margin-bottom: 1%; */
  bottom: 0;
  padding: 20px;
  padding-left: 17px;
  background-color: var(--header-item-background-color);
}
/* fix FNSI 内结bug スケジュール表 No.10 end --Sanjingye Sun 20210112 */

.pat-header {
  width: 100%;
  height: 6.2em;
  background-color: var(--header-item-background-color);
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-image:         linear-gradient(rgba(210,210,210,.2) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
/*add FNSI-画面部品デザイン じょはく start*/
/* mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start */
.pat-info-header-area {
  width: 98%;
  height: calc(100% - 80px);
}
/* mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end */
.card-list.small {
  top: 49.59px;
  height: calc(100% - 52px);
}
.card-list.medium {
  top: 62px;
  height: calc(100% - 64px);
}
.card-list.big {
  top: 68.19px;
  height: calc(100% - 71px);
}
.card-list.xbig {
  top: 80.59px;
  height: calc(100% - 82px);
}
/*add FNSI-画面部品デザイン じょはく end*/
.event-area {
  color: var(--ntss-header-color);
  width: 100%;
  height: 6.0em;
  border-collapse: collapse;
}

.pat-icon-area {
  width: 5em;
}

.pat-icons-flex {
  display: flex;
  /* mod FNSI-redmine3880 徐 start */
  /* flex-wrap: wrap; */
  flex-wrap: nowrap;
  /* mod FNSI-redmine3880 徐 end */
}

.pat-button-area {
  width: 75px;
}

.hosp-pat-id {
  width: 160%;
  display: inline-block;
  font-size: 0.9em;
}

.pat-name {
  display: inline-block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  height: 1.5em;
}

.pat-name-in-hospital {
  color: rgb(163, 86, 163);
}

.pat-name-area {
  width: 18em;
}

.same-icon{
  height: 1.0em;
  display: inline-block;
  vertical-align: -0.1em;
}

.manual-operation-button {
  min-height: unset;
  font-size: 1.5em;
  width: auto;
  height: auto;
  display: inline-block;
}

.font-size-set-small .manual-operation-button {
  padding: 3px 5px;
  font-size: 1.3em;
}
/* #9760 掲示版の新規登録と全て既読のスイッチがはみ出ている 張博 start */
.style-text-button {
  margin: 0;
  line-height: initial;
  height: 1.2em;
}
/* #9760 掲示版の新規登録と全て既読のスイッチがはみ出ている 張博 start */

/* 患者情報のスタイル */

.cls-status-icon {
  height: 1.5em;
  width: 1.5em;
  margin: 0 1px 1px 0;
}

.btn-scheldule-list {
  justify-content: left;
  padding: 0;
  margin-right: 5px;
}

.btn-scheldule-list .icon {
  height: 1.5em;
  width: 1.5em;
  margin: 0 5px 0 5px;
}

.schedule-list-header >>> .popover--top {
  width: auto;
}

.schedule-default-msg {
  font-size: 1.5em;
}

/* add FNSI 画面部品デザイン start -- Sanjingye Sun 20210114 */
.card-list >>> .menu-bar {
  position: absolute;
  left: 161px !important;
  top: 20px;
}

/*mod FNSI-画面部品デザイン じょはく start*/
/* mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start */
.card-list >>> .card-infos {
  height: 100% !important;
  margin-left: 143px;
  overflow-y: scroll;
}
/* mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end */
/*mod FNSI-画面部品デザイン じょはく end*/
/* add FNSI 画面部品デザイン end -- Sanjingye Sun 20210114 */

/* スマホスタイル */
@media screen and (max-width: 480px) {
  .event-area {
    width: 75%;
  }

  .schedule-default-msg {
    vertical-align: middle;
  }


  .pat-icons-flex-1 {
    margin-top: 0.5em;
  }

  .cls-status-icon {
    height: 1.2em;
    width: 1.2em;
  }

  .manual-operation-button {
    font-size: 1.5em
  }
}

@media screen and (max-width: 380px) {
  .cls-status-icon {
    height: 1.2em;
    width: 1.2em;
  }
  .pat-icons-flex-1 {
    margin-top: 1em;
  }
}

@media screen and (max-width: 320px) {
  .cls-status-icon {
    height: 0.6em;
    width: 0.6em;
  }

  .manual-operation-button {
    font-size: 1.1em
  }
}

@media print {
  .card-list {
    position: relative !important;
    padding: 0;
    top: 0 !important;
  }
  .pat-info-header-area {
    height: auto !important;
    background-color: unset;
  }
  .card-list >>> .menu-bar {
    top: 0;
  }
  .card-list >>> div {
    height: auto !important;
  }
  /** 見出し開閉ボタン非表示 */
  .type-right {
    display: none;
  }
}
</style>
