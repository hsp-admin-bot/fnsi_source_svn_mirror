/** * 治療予定メニューポップオーバー */
<template>
  <div v-if="showPopoverMenu">
    <v-ons-popover
      :class="[fontSizeSet, 'popover-content popover-content-treatplan-menu']"
      cancelable
      v-model:visible="showPopoverMenu"
      :target="targetTreatPlanMenuPopover"
      :direction="directionTreatPlanMenuPopover"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="hideTreatPlanMenuPopover(); popoverPosthide($event)"
    >
      <div class="popover-content-div">
        <v-ons-row
          v-if="getIsShowTreatPlanMenuPopoverDisplayOrdNo"
          class="popover-content-row"
        >
          <v-ons-col class="popover-content-col" style="justify-content: center;">
              透析番号： {{ ordInfo.ordNo }}
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-if="isShowTreatPlanMenuPopoverCreateButton"
          class="popover-content-row"
        >
          <v-ons-col class="popover-content-col">
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
            <!-- <v-ons-button
              class="popover-content-button button"
              @click="clickEvent(showModalIndPlanCreate)"
            >
              予定作成
            </v-ons-button> -->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="btn3-normal" -->
            <!--   @click="clickEvent(showModalIndPlanCreate)" -->
            <!-- > -->
            <v-ons-button
              class="btn3-normal"
              @click="clickEvent(showModalIndPlanCreate)"
              :disabled="!getItemAuthorized('Indication', 'item_treat_plan_menu')"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              予定作成
            </v-ons-button>
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-if="isShowTreatPlanMenuPopoverCopyButton"
          class="popover-content-row"
        >
          <v-ons-col class="popover-content-col">
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
            <!-- <v-ons-button
              class="popover-content-button button"
              @click="clickEvent(showModalIndPlanCopy)"
            >
              コピー
            </v-ons-button> -->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="btn3-normal" -->
            <!--   @click="clickEvent(showModalIndPlanCopy)" -->
            <!-- > -->
            <v-ons-button
              class="btn3-normal"
              @click="clickEvent(showModalIndPlanCopy)"
              :disabled="!getItemAuthorized('Indication', 'item_treat_plan_menu')"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              コピー
            </v-ons-button>
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-if="isShowTreatPlanMenuPopoverMoveButton"
          class="popover-content-row"
        >
          <v-ons-col class="popover-content-col">
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
            <!-- <v-ons-button
              class="popover-content-button button"
              @click="clickEvent(showModalIndPlanMove)"
            >
              移動
            </v-ons-button> -->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="btn3-normal" -->
            <!--   @click="clickEvent(showModalIndPlanMove)" -->
            <!-- > -->
            <v-ons-button
              class="btn3-normal"
              @click="clickEvent(showModalIndPlanMove)"
              :disabled="!getItemAuthorized('Indication', 'item_schedule')"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              移動
            </v-ons-button>
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-if="isShowTreatPlanMenuPopoverDeleteButton"
          class="popover-content-row"
        >
          <v-ons-col class="popover-content-col">
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
            <!-- <v-ons-button
              class="popover-content-button button"
              @click="showModalIndPlanDelete"
            >
              中止
            </v-ons-button> -->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="btn4-alert" -->
            <!--   @click="showModalIndPlanDelete" -->
            <!-- > -->
            <v-ons-button
              class="btn4-alert"
              @click="showModalIndPlanDelete"
              :disabled="!getItemAuthorized('Indication', 'item_treat_plan_menu')"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              中止
            </v-ons-button>
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-if="isShowTreatPlanMenuPopoverWeekPatternButton"
          class="popover-content-row"
        >
          <v-ons-col class="popover-content-col">
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
            <!-- <v-ons-button
              class="popover-content-button button"
              @click="showModalChangeDayOfWeekPattern"
            >
              曜日パターン変更
            </v-ons-button> -->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="btn3-normal" -->
            <!--   @click="showModalChangeDayOfWeekPattern" -->
            <!-- > -->
            <v-ons-button
              class="btn3-normal"
              @click="showModalChangeDayOfWeekPattern"
              :disabled="!getItemAuthorized('Indication', 'item_treat_plan_menu')"
            >
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              曜日パターン変更
            </v-ons-button>
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-if="isShowTreatPlanMenuPopoverRstCreateButton"
          class="popover-content-row"
        >
          <v-ons-col class="popover-content-col">
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 start -->
            <!-- <v-ons-button
              class="popover-content-button button"
              @click="showModalIndPlanRstCreate"
            >
              手動実績作成
            </v-ons-button> -->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="btn3-normal" -->
            <!--   @click="showModalIndPlanRstCreate" -->
            <!-- > -->
            <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-button -->
            <!--   class="btn3-normal" -->
            <!--   @click="showModalIndPlanRstCreate" -->
            <!--   :disabled="!getItemAuthorized('Indication', 'item_treat_plan_menu')" -->
            <!-- > -->
            <v-ons-button
              class="btn3-normal"
              @click="showModalIndPlanRstCreate"
              :disabled="!getItemAuthorized('Indication', 'item_treat_plan_menu_rstcreate')"
            >
            <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
              手動実績作成
            </v-ons-button>
            <!-- mod FNSI-患者経過総合ビューア 画面デザイン 李 end -->
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>

    <message-dialog
      class="message-dialog"
      v-model:visible="isDieMessage"
      :message-cd="12010003"
      type="1"
    />
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { findAncestorWithAnyKey } from "@/functions/common/ComponentOwnerResolver";
// add #10359 編集権限の動作不正 dengshen end

/**
 * Vue関連
 */
import { mapGetters, mapActions } from "@/compat/vue/vuex";

/**
 * 外部ライブラリ関連
 */
// 日付操作
import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";

/**
 * 共通操作
 */
import { deepCopy } from "@/functions/common/CommonFunctions";
import { ApiHelper } from "@/apis/AxiosHelper";

import messageDialog from "@/components/common/message-dialog/MessageDialog";
import PopoverMixin from "@/components/PopoverMixin";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import { FUNC_TREATMENT_RECORD } from "@/constants/function-code";
// add mod FNSI-連携イベントの登録適正化 楊 start
import { createJournal } from "@/apis/journal";
// add mod FNSI-連携イベントの登録適正化 楊 end
// add FNSI-No.IES145 権限対応  吉 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add FNSI-No.IES145 権限対応 権限関連 吉 end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import MODAL_TITLE from "@/components/common/ModalTitleContrast.js";
export default {
  //mod FNSI-No.IES145 権限対応  吉 start
  // mixins: [PopoverMixin,UserAuthorityMixin],
  mixins: [PopoverMixin, UserAuthorityMixin,ComponentGuardMixin],
  //mod FNSI-No.IES145 権限対応  吉 end

  components: {
    "message-dialog": messageDialog
  },

  data() {
    return {
      /**
       * ポップオーバー表示/非表示切替
       */
      showPopoverMenu: false,
      // 死亡日※メッセージ表示用
      dieInfo: { is_die: "0", die_date: null },
      isDieMessage: false,
      //add FNSI-No.IES145 権限対応  吉 start
      authorityCds:[
        AUTHORITY_CODES.RST_EDIT,
      ],
      flagAuthority:false,
      //add FNSI-No.IES145 権限対応  吉 end
    };
  },

  computed: {
    // mod FNSI-連携イベントの登録適正化 楊 start
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    // mod FNSI-連携イベントの登録適正化 楊 end
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-viewer", ["getDateList"]),
    ...mapGetters("pat-viewer-modal", [
      "getDefaultSettingIndPlanCreateNewData",
      "getDefaultSettingIndPlanCreateDeleteData",
      "getBaseDate"
    ]),
    // mod FNSI-連携イベントの登録適正化 楊 start
    ...mapGetters("pat-info", ["selectedPat"]),
    // mod FNSI-連携イベントの登録適正化 楊 end
    ...mapGetters("pat-viewer-popover", [
      "getIsShowTreatPlanMenuPopover",
      "getTargetTreatPlanMenuPopover",
      "getDirectionTreatPlanMenuPopover",
      "getIsShowTreatPlanMenuPopoverDisplayOrdNo",
      "getIsShowTreatPlanMenuPopoverCreateButton",
      "getIsShowTreatPlanMenuPopoverCopyButton",
      "getIsShowTreatPlanMenuPopoverMoveButton",
      "getIsShowTreatPlanMenuPopoverDeleteButton",
      "getIsShowTreatPlanMenuPopoverWeekPatternButton",
      "getIsShowTreatPlanMenuPopoverRstCreateButton",
      "getCopyFlag",
      "getModalInfo",
      "getTreatmentData"
    ]),

    /**
     * 患者ID
     */
    patId() {
      return this.selectedPatId;
    },

    /**
     * 施設コード
     */
    facilityCd() {
      return this.getFacilityCd;
    },

    /**
     * 患者経過総合ビューア一覧の日付リスト
     */
    dateList() {
      return this.getDateList;
    },

    /**
     * 治療予定モーダル(予定作成)に渡すデータ(雛型)
     */
    defaultSettingIndPlanCreateNewData() {
      return this.getDefaultSettingIndPlanCreateNewData;
    },

    /**
     * 治療予定モーダル(中止)に渡すデータ(雛型)
     */
    defaultSettingIndPlanCreateDeleteData() {
      return this.getDefaultSettingIndPlanCreateDeleteData;
    },

    /**
     * ポップオーバー表示／非表示切替
     */
    isShowTreatPlanMenuPopover() {
      return this.getIsShowTreatPlanMenuPopover;
    },

    /**
     * 治療予定メニューポップオーバー表示処理箇所のイベント情報
     */
    targetTreatPlanMenuPopover() {
      return this.getTargetTreatPlanMenuPopover;
    },

    /**
     * 治療予定メニューポップオーバー表示位置("up"、"down"、"left"、"right")
     */
    directionTreatPlanMenuPopover() {
      return this.getDirectionTreatPlanMenuPopover;
    },

    /**
     * 治療予定メニューポップオーバー「オーダー番号」表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverDisplayOrdNo() {
      return this.getIsShowTreatPlanMenuPopoverDisplayOrdNo;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定作成ボタン」表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverCreateButton() {
      return this.getIsShowTreatPlanMenuPopoverCreateButton;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定コピーボタン」表示/非表示切り替え
     *
     */
    isShowTreatPlanMenuPopoverCopyButton() {
      return this.getIsShowTreatPlanMenuPopoverCopyButton;
    },

    /**
     * 治療予定メニューポップオーバー「治療予定移動ボタン」表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverMoveButton() {
      // mod #10359 編集権限の動作不正 dengshen start
      // // mod #7437 スケジュール移動の権限が仕様通りではない dou start
      // // return this.getIsShowTreatPlanMenuPopoverMoveButton;
      // return this.getIsShowTreatPlanMenuPopoverMoveButton
      // && this.getUserAuthorityCds().includes(AUTHORITY_CODES.SCHE_MOVE)
      // && (this.getUserAuthorityCds().includes(AUTHORITY_CODES.IND_PEDIT)
      //   || this.getUserAuthorityCds().includes(AUTHORITY_CODES.IND_EDIT));
      // // mod #7437 スケジュール移動の権限が仕様通りではない dou end
      return this.getIsShowTreatPlanMenuPopoverMoveButton;
      // mod #10359 編集権限の動作不正 dengshen end
    },

    /**
     * 治療予定メニューポップオーバー「治療予定中止ボタン」表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverDeleteButton() {
      return this.getIsShowTreatPlanMenuPopoverDeleteButton;
    },

    /**
     * 治療予定メニューポップオーバー「曜日パターン変更ボタン」表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverWeekPatternButton() {
      return this.getIsShowTreatPlanMenuPopoverWeekPatternButton;
    },

    /**
     * 治療予定メニューポップオーバー「手動実績作成ボタン」表示/非表示切り替え
     */
    isShowTreatPlanMenuPopoverRstCreateButton() {
      return this.getIsShowTreatPlanMenuPopoverRstCreateButton;
    },

    /**
     * 治療予定コピーフラグ
     */
    copyFlag() {
      return this.getCopyFlag;
    },

    /**
     * 基準日
     */
    baseDate() {
      return this.getBaseDate;
    },

    /**
     * 対象セルの治療情報
     * @description オーダー番号、治療状況、治療日、1日限定フラグ
     */
    ordInfo() {
      return this.getModalInfo;
    },

    isDie() {
      // const treatDate = dayjs(this.ordInfo.treatDate, "YYYY-MM-DD").format(
      //   "YYYYMMDD"
      // );
      // return treatDate > this.dieInfo.die_date;
      return this.dieInfo.is_die === "1";
    },

    /**
     * スケジュール自動延長最終日
     */
    schExtEndDate() {
      // TODO: 自動延長の実行タイミングによりデータ不一致が発生する可能性がある
      return this.selectedPat.pat_main.sch_ext_end_date;
    },

    /**
     * 終了日の最大日(本日から一年未満)
     */
    maxDate() {
      const day = dayjs().format("YYYYMMDD");
      // 一年後に最大日を設定
      let endMaxDate = this.schExtEndDate
        ? dayjs(this.schExtEndDate, "YYYYMMDD")
        : dayjs(day).add(1, "year");
      endMaxDate = dayjs(endMaxDate).endOf("month");
      return dayjs(endMaxDate).format("YYYY-MM-DD");
    },
  },

  watch: {
    async showPopoverMenu(value) {
      if (!value) {
        // ポップオーバーを非表示
        // del bug 8003 修正 chen start
        // this.hideTreatPlanMenuPopover();
        // del bug 8003 修正 chen end
      } else {
        const patInfo = await this.getPatInfo();
        this.dieInfo = this.getDieInfo(patInfo);
      }
    },

    isShowTreatPlanMenuPopover(value) {
      // ストアで変更されたポップオーバー表示/非表示切替を格納
      this.showPopoverMenu = value;
    }
  },

  methods: {
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    ...mapActions("pat-viewer-popover", ["setHideTreatPlanMenuPopover"]),
    ...mapActions("pat-viewer-modal", [
      "showIndModal",
      "showPlanCopyModal",
      "showPlanMoveModal",
      "showWeekPatternModal"
    ]),
    ...mapActions("treatment-record/common", ["setOrdNo"]),
    // add 更新中の予定を表示する様にする。 李 start
    ...mapActions("pat-viewer", ["setScrollBarPositioningOrdNo"]),
    // add 更新中の予定を表示する様にする。 李 end
    // add FNSI-障害票一覧_予実リストNo.1対応 李 start
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),
    // add FNSI-障害票一覧_予実リストNo.1対応 李 end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    /**
     * 開始日を取得
     */
    getStartDay() {
      // 本日日付を格納
      let day = dayjs().format("YYYY-MM-DD");
      if (this.dateList && 0 !== this.dateList.length) {
        // 本日日付と一覧に表示している開始日を比較
        // 本日より未来日の場合、その日付を設定
        // 本日より過去日の場合、本日日付を設定
        const startday = dayjs(this.dateList[0]).format("YYYY-MM-DD");
        if (day < startday) {
          // 一覧に表示している日付の開始日を設定
          day = startday;
        }
      }

      return day;
    },

    /**
     * 治療予定メニューポップオーバーを閉じた際に行う処理
     */
    hideTreatPlanMenuPopover() {
      // ポップオーバー表示フラグをfalseに設定
      this.setHideTreatPlanMenuPopover();
    },

    /**
     * 予定作成、コピーの対象日付チェック
     */
    isOverMaxDate(treatDate) {
      // 日付指定で予定作成、コピーをする場合に対象日付のチェック
      const tgt = new Date(`${treatDate} 00:00:00`);
      const max = new Date(`${this.maxDate} 00:00:00`);
      // 対象日付がMAX値よりも大きい場合はダイアログを表示し処理を中断
      if (tgt > max) {
        // ポップオーバーを閉じる
        this.hideTreatPlanMenuPopover();
        // メッセージ表示
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES["70000034"].title,
          message: DIALOG_MESSAGES["70000034"].message,
        });
        // mod #12306 スケジュール作成可能期間外について、患者経過総合ビューア＆スケジュール表で動作不正 関 start
        return true;
        // mod #12306 スケジュール作成可能期間外について、患者経過総合ビューア＆スケジュール表で動作不正 関 end
      }
      return false;
    },

    /**
     * 治療予定モーダル表示(予定作成)
     */
    showModalIndPlanCreate() {
      // 日付がMAX値を超えている場合処理を中断
      if(this.isOverMaxDate(this.ordInfo.treatDate)) {
        return;
      }
      // 治療予定メニューポップオーバーを閉じる
      this.hideTreatPlanMenuPopover();
      const settingData = deepCopy(this.defaultSettingIndPlanCreateNewData);
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // 【通常】【隔日】切替ボタンー表示
      settingData.showSegment = !this.ordInfo.isOneDay;
      // 治療開始日
      settingData.startDate = this.ordInfo.treatDate;
      // 治療終了日
      settingData.endDate = this.ordInfo.isOneDay ? this.ordInfo.treatDate : "";
      if (this.ordInfo.isOneDay) {
        // 開始日操作不可
        settingData.startDateEdit = true;
        // 終了日操作不可
        settingData.endDateEdit = true;
        // 全曜日選択をfalse
        settingData.allWeek = false;
        // 選択された曜日以外をfalseへ変更
        for (let i = 0; i < 7; i++) {
          settingData[this.changeWeekStr(i)] =
            i !== dayjs(this.ordInfo.treatDate, "YYYYMMDD").day()
              ? false
              : true;
        }
      }else{
        // 全曜日選択をfalse
        settingData.allWeek = false;
        // 全ての曜日選択をfalse
        for (let i = 0; i < 7; i++) {
          settingData[this.changeWeekStr(i)] = false;
        }
      }
      // モーダル表示
      this.showIndModal({
        dispComponentId: "ind-plan-create",
        settingIndData: settingData
      });
    },

    /**
     * 治療予定コピー
     */
    showModalIndPlanCopy() {
      // 日付がMAX値を超えている場合処理を中断
      if(this.isOverMaxDate(this.ordInfo.treatDate)) {
        return;
      }
      // 治療予定コピーモーダルに渡す情報の設定
      const settingData = {};
      // オーダー番号
      settingData.propOrdNo = this.ordInfo.ordNo;
      // 患者ID
      settingData.propPatId = this.patId;
      // 施設コード
      settingData.propFacilityCd = this.facilityCd;
      // コピー元日付格納
      settingData.propDialysisDate = this.ordInfo.treatDate;
      // コピーフラグ(0->選択先がコピー元となる、1->選択先がコピー先となる)
      settingData.propSelFlag = this.copyFlag;
      // 治療予定メニューポップオーバーを閉じる
      this.hideTreatPlanMenuPopover();
      // モーダル表示
      this.showPlanCopyModal({ settingIndData: settingData });
    },

    /**
     * 治療予定移動
     */
    showModalIndPlanMove() {
      const settingData = {};
      // オーダー番号
      settingData.propOrdNo = this.ordInfo.ordNo;
      // 施設コード
      settingData.propFacilityCd = this.facilityCd;
      // 患者ID
      settingData.propPatId = this.patId;
      // 移動元日
      settingData.propDialysisDate = this.ordInfo.treatDate;
      // 治療予定メニューポップオーバーを閉じる
      this.hideTreatPlanMenuPopover();
      // モーダル表示
      this.showPlanMoveModal({ settingIndData: settingData });
    },

    /**
     * 治療予定モーダル表示(中止)
     */
    showModalIndPlanDelete() {
      // 治療予定(中止)モーダルに渡す情報の設定(雛型構造のコピー)
      const settingData = deepCopy(this.defaultSettingIndPlanCreateDeleteData);
      // 患者ID
      settingData.patId = this.patId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // オーダー番号
      settingData.ordNo = this.ordInfo.ordNo;
      // 開始日
      settingData.startDate = this.ordInfo.treatDate;
      // 終了日
      settingData.endDate = this.ordInfo.isOneDay ? this.ordInfo.treatDate : "";
      // 1日限定の場合以下のよりを実行
      if (this.ordInfo.isOneDay) {
        // 開始日操作不可
        settingData.startDateEdit = true;
        // 終了日操作不可
        settingData.endDateEdit = true;
      }

      // モーダルを先に表示し、ポップオーバー閉鎖時の白枠フラッシュを抑止
      this.showIndModal({
        dispComponentId: "ind-plan-delete",
        settingIndData: settingData
      });
      this.hideTreatPlanMenuPopover();
    },

    /**
     * 曜日パターン変更モーダル表示
     */
    showModalChangeDayOfWeekPattern() {
      const settingData = {};
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // 患者ID
      settingData.patId = this.patId;
      // 表示・非表示切替
      settingData.showFlag = true;
      // ヘッダータイトル
      settingData.headerTitle = MODAL_TITLE["曜日パターン変更"];
      // add FNSI-曜日パターン変更の開始日に基準日を変更する 李 start
      // 曜日パターン変更開始日
      settingData.startDate = this.baseDate;
      // add FNSI-曜日パターン変更の開始日に基準日を変更する 李 end

      // 治療予定メニューポップオーバーを閉じる
      this.hideTreatPlanMenuPopover();

      // モーダル表示
      this.showWeekPatternModal({ settingIndData: settingData });
    },

    /**
     * 手動実績作成
     */
    getTreatPlanDialogOwner() {
      return findAncestorWithAnyKey(this, ["messageDialogInfo"], { maxDepth: 16 }) || this;
    },
    showTreatPlanDialog(messageCd) {
      const owner = this.getTreatPlanDialogOwner();
      if (owner?.messageDialogInfo) {
        owner.messageDialogInfo.messageCd = messageCd;
        owner.messageDialogInfo.isDialogVisible = true;
      }
    },
    async showModalIndPlanRstCreate() {
      console.log("TreatPlanMenu.vue showModalIndPlanRstCreate this.startLoadingScreen();");
      this.startLoadingScreen();
      //add FNSI-No.IES145 権限対応  吉 start
      this.flagAuthority = this.getTreatmentRecordAuthority();
      if(!this.flagAuthority){
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "",
          // message: "権限不足"
          title: DIALOG_MESSAGES['00200116'].title,
          message: messageFormat(DIALOG_MESSAGES['00200116'].mesage)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        console.log("TreatPlanMenu.vue showModalIndPlanRstCreate return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      //add FNSI-No.IES145 権限対応  吉 end
      // ポップオーバーを非表示にする
      this.hideTreatPlanMenuPopover();
      // 権限チェックを行う
      if (!this.hasNextAuthority(FUNC_TREATMENT_RECORD)) {
        console.log("TreatPlanMenu.vue showModalIndPlanRstCreate return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return true;
      }
      if (this.getTreatmentData && (!this.getTreatmentData.indKurCd || !this.getTreatmentData.indBedCd)) {
        this.hideTreatPlanMenuPopover();
        this.showTreatPlanDialog(99999997);
        console.log("TreatPlanMenu.vue showModalIndPlanRstCreate return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }

      const ordNo = Number(this.ordInfo.ordNo);
      const response = await ApiHelper.put(
        `/mainData/sendCondResultOnly/${ordNo}/${this.patId}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('TreatPlanMenu.vue', 'showModalIndPlanRstCreate', error);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        console.log("TreatPlanMenu.vue showModalIndPlanRstCreate throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });
      if (undefined !== response.data.retMsg) {
        this.showTreatPlanDialog(response.data.retMsg);
        // ポップオーバーを非表示
        this.hideTreatPlanMenuPopover();
        console.log("TreatPlanMenu.vue showModalIndPlanRstCreate return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // mod FNSI-連携イベントの登録適正化 楊 start
      if (200 === response.status) {
        const params = {
          ope_cd: "004039",
          crud: "C",
          facility_cd: this.facilityCd,
          hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
          pat_id: this.selectedPat.pat_personal_main.pat_id,
          ord_no: ordNo,
// mod 2021-10-22 #5890:Medicom連携ができない(受付情報(accept)) 孫 start
//          base_date: this.ordInfo.treatDate,
          base_date: dayjs(this.ordInfo.treatDate).format("YYYYMMDD"),
// mod 2021-10-22 #5890:Medicom連携ができない(受付情報(accept)) 孫 end
          user_id: this.getStateUserAccountInfo.userId
        };
        createJournal(params);
      }
      // mod FNSI-連携イベントの登録適正化 楊 end
      //　チェックリスト実績作成
      await ApiHelper.post(
        `/check-list/updateSendCondition/${ordNo}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('TreatPlanMenu.vue', 'showModalIndPlanRstCreate', error);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        //throw error;
      });

      // 治療記録画面へ遷移
      this.setOrdNo(ordNo);
      this.$router.push({ name: "treatment-record" });

      // add FNSI-障害票一覧_予実リストNo.1対応 李 start
      // 予実リストの更新
      this.setResultUpdate(new Date());
      // add FNSI-障害票一覧_予実リストNo.1対応 李 end

      console.log("TreatPlanMenu.vue showModalIndPlanRstCreate hideTreatPlanMenuPopover this.finishLoadingScreen();");
      this.finishLoadingScreen();
      // ポップオーバーを非表示
      this.hideTreatPlanMenuPopover();
    },

    /**
     * 曜日を英語表記に変換
     */
    changeWeekStr(num) {
      switch (num) {
        case 0:
          return "sunday";
        case 1:
          return "monday";
        case 2:
          return "tuesday";
        case 3:
          return "wednesday";
        case 4:
          return "thursday";
        case 5:
          return "friday";
        case 6:
          return "saturday";
        default:
          return null;
      }
    },

    async getPatInfo() {
      const uri = "/patInfo/getPatById";
      const responsePat = await ApiHelper.get(`${uri}/${this.patId}`).catch(
        () => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('TreatPlanMenu.vue', 'getPatInfo', "[PatInfoFunctions.js]getPatById(): APIエラー  404以外ならJavaのログ確認してください");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          throw new Error(
            "[PatInfoFunctions.js]getPatById(): APIエラー  404以外ならJavaのログ確認してください"
          );
        }
      );
      return _.mapValues(responsePat.data, patInfoJson =>
        JSON.parse(patInfoJson)
      );
    },

    /**
     * @description 死亡情報取得
     * @returns { Object } is_die: "0" or "1", die_date: null or "YYYYMMDD"
     */
    getDieInfo(patInfo) {
      const patPersonalMain = patInfo.pat_personal_main;
      const isDie = patPersonalMain.is_die;
      const dieInfo = { is_die: "0", die_date: null };
      if (isDie === "1") {
        // 「"1": 死亡」なら
        dieInfo.is_die = "1";
        const date = patPersonalMain.die_date;

        if (date === null) {
          // 死亡日が"YYYYMMDD"でないならnullとなる
          const patUnique = patInfo.pat_unique;
          const medicalHstInfo = JSON.parse(patUnique.medical_hst_info);
          // 「"10": 死亡」
          const item = medicalHstInfo.find(item => item.out_come === "10");

          if (item) {
            const year =
              item.diagnosis_year === null ? "0000" : item.diagnosis_year;
            const month =
              item.diagnosis_month === null ? "00" : item.diagnosis_month;
            const day = item.diagnosis_day === null ? "00" : item.diagnosis_day;
            dieInfo.die_date = `${year}${month}${day}`;
          }
        } else {
          dieInfo.die_date = dayjs(date, "YYYY-MM-DD HH:mm:ss").format(
            "YYYYMMDD"
          );
        }
      }

      return dieInfo;
    },

    clickEvent(func) {
      // add 更新中の予定を表示する様にする。 李 start
      this.setScrollBarPositioningOrdNo({ ordNoName: "creat" });
      // add 更新中の予定を表示する様にする。 李 end
      if (this.isDie) {
        this.isDieMessage = true;
      } else {
        func();
      }
    },
    //add FNSI-No.IES145 権限対応  吉 start
    getTreatmentRecordAuthority() {
      return this.hasAuthority();
    },
    //add FNSI-No.IES145 権限対応  吉 end
  },
  //add FNSI-No.IES145 権限対応  吉 start
  created() {
    this.flagAuthority = this.getTreatmentRecordAuthority();
  },
  //add FNSI-No.IES145 権限対応  吉 start
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@use "../css/style.scss" as *;

.message-dialog {
  z-index: 30000 !important;
}
</style>
