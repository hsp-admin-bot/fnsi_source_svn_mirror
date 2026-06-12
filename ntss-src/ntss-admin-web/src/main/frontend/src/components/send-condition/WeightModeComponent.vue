/**
 * 体重計モード・体重計患者検索画面
 */
<template>
  <!-- #9556 測定患者選択画面にスクロールバーが常に表示される linjunfeng start -->
  <div
    class="send-condition-main-content-area ntss-send-condition-content-area"
    v-bind:style="formColor"
  >
  <!-- #9556 測定患者選択画面にスクロールバーが常に表示される linjunfeng end -->
    <div class="weight-mode-head-content">
      <v-ons-row>
        <v-ons-col>
          <v-ons-button
            class="weight-mode-mst-weight-button btn3-normal"
            ref="mstWeightButton"
            @click="showMstWeightPopover"
            :disabled="isAssignedWeightNo || isDisableWeightSelect"
          >
            <span class="weight-mode-mst-weight-button-text">{{ getSelectWeightSetting.weightName }}</span>
          </v-ons-button>
        </v-ons-col>
        <v-ons-col>
          <v-ons-button
            v-if="isEditMstWheelChair"
            class="weight-mode-wheelchair-button btn3-normal"
            @click="onClickWheelChair"
          >
            車いすマスタ編集
          </v-ons-button>
          <!-- 体重モードかつ、施設設定マスタで体重計モード測定記録ボタン表示が指定時のみ表示（※車いすマスタ編集ボタンが非表示の場合、測定記録ボタンは1段目に表示する） -->
          <v-ons-button
            v-else-if="!isEditMstWheelChair && getWeightMode.isWeightMode && shouldDisplayMeasureHistoryButton"
            class="weight-mode-measure-history-button btn3-normal"
            ref="measureHistoryButton"
            @click="onClickMeasureHistory"
          >
            測定記録
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>

      <!-- 体重モードかつ、施設設定マスタで体重計モード測定記録ボタン表示が指定時のみ表示（※車いすマスタ編集ボタンが表示の場合、測定記録ボタンは2段目に表示する） -->
      <v-ons-row v-if="isEditMstWheelChair && getWeightMode.isWeightMode && shouldDisplayMeasureHistoryButton" style="margin-top: 20px;">
        <v-ons-col>
          <v-ons-button
            class="weight-mode-measure-history-button btn3-normal"
            ref="measureHistoryButton"
            @click="onClickMeasureHistory"
          >
            測定記録
          </v-ons-button>
        </v-ons-col>
      </v-ons-row>

    </div>
    <div class="weight-mode-main-content">
      <div class="weight-mode-input-block">
        <div class="weight-mode-title-label ntss-send-condition-text">
          <div>{{ patSearchMessage }}</div>
        </div>
        <v-ons-input
          ref="patIdInput"
          id="patIdID"
          class="weight-mode-pat-id-input"
          @keydown.enter="inputPatId($event.target.value)"
        ></v-ons-input>
        <img height="40px" style="vertical-align: bottom" :src="image_src" @click="show"/>
        <v-ons-button
          class="weight-mode-pat-search-button btn3-normal"
          @click="onClickPatSearch"
          >患者選択</v-ons-button
        >
      </div>
    </div>
    <div class="weight-mode-footer-content"></div>

    <!-- 日時表示領域 -->
    <div class="weight-mode-time-content enable-weight-color">
      <span style="margin-left: 1em;">{{weightName}}</span>
      <span style="margin-left: 1em;">{{ymdTime}}</span>
    </div>

    <pop-over
      v-bind="popoverData"
      :target-position-element="$refs.mstWeightButton"
      class="font-size-set-pat-search-modal"
      @popover-close="closePopover"
      @popover-return="returnPopover"
    />

    <!-- テンキー -->
    <v-ons-popover
      ref="numericPopover"
      cancelable
      id="numericPopOver"
      v-model:visible="cavisible"
      :target="popoverTarget"
      direction="down"
      class="popoverClass"
      @posthide="tenkeyClose"
    >
      <vue-touch-keyboard :options="options" :layout="layout" :cancel="cancel" :accept="accept" :input="input"/>
    </v-ons-popover>
  </div>
</template>

<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { weightScaleClass } from "@/constants/weightDefine";
import { EventBus } from "@/compat/vue/event-bus.js";
import dayjs from "@/compat/date/dayjs";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
// add 画面印刷プレビューと印刷の実現 陳 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add 画面印刷プレビューと印刷の実現 陳 end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
// add #6107 2023/03/24 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/24 メッセージボックス全調整 林峻峰 end
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
import store from "@/stores";
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
import { MST_WEIGHT_EDIT_WITH_PAT_SELECTION, WEIGHT_MODE_MEASURE_HISTORY_BUTTON_DISPLAY } from "@/constants/facilitySetting";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import TouchKeyboard from "@/compat/keyboard/TouchKeyboard.vue";
import { publicAssetPath } from "@/compat/assets/public-path";
import {
  appendScopedStylesheet,
  getFooterMenuElement,
  getScopedDocumentElement,
  getScopedElementById,
  getScopedLocalStorage,
  getScopedUserAgent,
  getViewportHeight,
} from "@/functions/common/LayoutMeasureHelper";

export default {
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null,
  },
  components: {
    "pop-over": MasterSelector,
    "vue-touch-keyboard": TouchKeyboard,
  },
  mixins: [NextTransitionMixin, PatHeaderControlMixin],
  data() {
    return {
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "down",
        popoverTitleHeader: "",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
      },
      selectedWeight: -1,
      finishLoading: false,
      isDisableWeightSelect: true,
      weightName: "",
      ymdTime: "",
      ymdUpdateProc: null,
      isAssignedWeightNo: false,
      patid:null,
      selfScreenName: "",
      isEditMstWheelChair: false,
      // テンキーで使用 start
      cavisible: false,
      layout: null,
      input: null,
      options: {
        useKbEvents: false,
        preventClickEvent: false
      },
      image_src: publicAssetPath("img/keyboard/keyboard.png"),
      popoverTarget: null,
      // テンキーで使用 end
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
      popoverOpened: false,
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
      // 体重計モード測定記録ボタン表示/非表示
      shouldDisplayMeasureHistoryButton: false,
    };
  },
  computed: {
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "isDispMenu", "getFontSize"]),
    ...mapGetters("window-size", { windowHeight: "getWindowHeight" }),
    ...mapGetters("send-condition/weight", [
      "getWeightMode",
      "getMstWeightList",
      "getSelectedMstWeight",
      "getMstWeightSelectorResource",
      "getMstWeightIndex",
      "getSelectedWeightNo",
      "getIsEnableWeightSelect",
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
      "getFocus",
      "getIsHospPatId",
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
      //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
      "getSelectedPats",
      //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
    ]),
    ...mapGetters("send-condition/scale/setting", [
      "getWeightColorSetting",
      "getWeightConfigInfo"
    ]),
    selectedWeightIdx: {
      get() {
        return this.selectedWeight;
      },
      set(value) {
        this.selectedWeight = value;
        if (this.finishLoading) {
          this.setMstWeightSelectIdx(value);
        }
      },
    },
    getSelectWeightSetting: {
      get() {
        return this.getSelectedMstWeight !== null &&
          this.getSelectedMstWeight !== undefined
          ? this.getSelectedMstWeight
          : {
              weightCd: -1,
              weightName: "体重計接続なし",
            };
      },
    },
    formColor: {
      get() {
        let bgColor = "inherit";
        let paddingOption = "";
        let timeContentPaddingBottom = "";
        if (
          this.getWeightColorSetting !== undefined &&
          this.getWeightColorSetting !== null &&
          this.getWeightColorSetting.form !== undefined &&
          this.getWeightColorSetting.form !== null
        ) {
          bgColor = this.getWeightColorSetting.form;
          paddingOption = " margin: 0; padding: 5px; padding-top: 0;";
          timeContentPaddingBottom = "5px";
        }

        /* パンくずリスト背景色を設定 */
        const elm = this.getBreadcrumbAreaElements();
        // add FNSI-体重計モードテンキーの追加  徐 start
        if (elm && elm.length > 0) {
          // add FNSI-体重計モードテンキーの追加  徐 end
          elm[0].style.backgroundColor = bgColor;
          elm[0].style.marginLeft = 0;
          elm[0].style.marginRight = 0;
          elm[0].style.paddingLeft = "5px";
        }

        /* その他エリアの背景色を設定 */
        const weightModeTimeContent = this.getWeightModeTimeContentElements();
        for (let elem of weightModeTimeContent) {
          elem.style.backgroundColor = bgColor;
          elem.style.paddingBottom = timeContentPaddingBottom;
        }

        /* 背景色を設定 */
        return "background-color: " + bgColor + ";" + paddingOption;
      },
    },
    patSearchMessage: {
      get() {
        if (this.getWeightMode.isWeightMode) {
          return "患者カードを置いてください";
        } else {
          return "患者IDを入力するか患者を選択してください";
        }
      },
    },
  },
  methods: {
    getWeightModeOwnerDocument() {
      return this.$el?.ownerDocument || document;
    },
    getWeightModeScopeRoot() {
      return this.$el?.closest?.('.send-condition-main-content-area, .ntss-send-condition-content-area, .main-content-area, #app')
        || this.$el
        || this.getWeightModeOwnerDocument();
    },
    getPatIdHostElement() {
      return this.$refs.patIdInput?.$el
        || this.$el?.querySelector?.("#patIdID")
        || this.getWeightModeScopeRoot()?.querySelector?.("#patIdID")
        || this.getWeightModeOwnerDocument()?.getElementById?.("patIdID")
        || null;
    },
    getPatIdInputElement() {
      const patIdHostElement = this.getPatIdHostElement();
      return patIdHostElement?.querySelector?.("input, .text-input")
        || patIdHostElement?.firstElementChild
        || patIdHostElement
        || null;
    },
    getNumericPopoverElement() {
      return this.$refs.numericPopover?.$el
        || this.$el?.querySelector?.("#numericPopOver")
        || this.getWeightModeScopeRoot()?.querySelector?.("#numericPopOver")
        || this.getWeightModeOwnerDocument()?.getElementById?.("numericPopOver")
        || null;
    },
    getBreadcrumbAreaElements() {
      return Array.from(this.$el?.ownerDocument?.getElementsByClassName?.("breadcrumb-area") || []);
    },
    getWeightModeTimeContentElements() {
      return Array.from(this.$el?.querySelectorAll?.(".weight-mode-time-content") || this.$el?.ownerDocument?.getElementsByClassName?.("weight-mode-time-content") || []);
    },
    /**
     * レイアウトの #main-id（ntss-layout / LayoutView）の --height を再計算し、
     * ビューポートからヘッダー・フッターを除いた領域に合わせる（LayoutMixin.calculateMainHeight と同趣旨）。
     */
    calculateContentHeight() {
      const root = this.$el;
      if (!root) {
        return;
      }
      const mainEl =
        root.closest?.("#main-id") ||
        getScopedElementById("main-id", root.ownerDocument?.body || null);
      if (!mainEl) {
        return;
      }
      const wh = Number(this.windowHeight) || getViewportHeight(root);
      const contentContainer = mainEl.closest?.(".content-container");
      const headerEl = contentContainer?.querySelector?.(".header");
      const hh = headerEl?.clientHeight ?? 0;

      let hhTmp = 0;
      if (this.getWeightMode?.isWeightMode) {
        if (this.getFontSize + "" === "0") {
          hhTmp = 100;
        } else if (this.getFontSize + "" === "1") {
          hhTmp = 125;
        } else if (this.getFontSize + "" === "2") {
          hhTmp = 137.5;
        } else if (this.getFontSize + "" === "3") {
          hhTmp = 162.5;
        }
      } else {
        if (this.getFontSize + "" === "0") {
          hhTmp = 85;
        } else if (this.getFontSize + "" === "1") {
          hhTmp = 97;
        } else if (this.getFontSize + "" === "2") {
          hhTmp = 104;
        } else if (this.getFontSize + "" === "3") {
          hhTmp = 115;
        }
      }

      const fh =
        this.isDispMenu === 1
          ? (getFooterMenuElement(root)?.clientHeight || 0)
          : 0;

      let mainHeight;
      if (hh !== 0) {
        mainHeight = wh - (Number(hh) || hhTmp) - fh;
      } else {
        mainHeight = wh - fh;
      }

      mainEl.style.setProperty("--height", `${mainHeight}px`);
    },
    ...mapActions("multi-modal", ["showPatSearch"]),
    ...mapActions("account-edit", ["setDispMenuBar", "setIsDispSidebarBtn"]),
    ...mapActions("send-condition/scale", [
      "setMeasuredValue",
      "calcWeightValue",
      "saveMeasure",
      "setBaseOrdWeightNo",
    ]),
    ...mapActions("send-condition/schedule", [
      "setScheduleList",
      "searchWeightSchedule",
    ]),
    ...mapActions("send-condition/weight", [
      "fetchMstWeightList",
      "setWeightMode",
      // ADD #7221 2023/02/05 By HandsomeLin Start
      // In order to enter the scale mode as soon as possible.
      // Action of setWeightMode is not only for weight mode variable, so we add a new action for weight mode only.
      "setWeightModeOnly",
      // ADD #7221 2023/02/05 By HandsomeLin Start
      "setMstWeightSelectIdx",
      "setMstWeightList",
      "selectMstWeightByNo",
      "selectMstWeightByCd",
      "fetchEnableWeightSelect",
      "setEnableWeightSelect",
        // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
      "setFocus",
      "setIsHospPatId"
        // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
    ]),
    ...mapActions("master-maintenance", [
      "setMasterName",
      "setLogicalMasterName",
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    // add 画面印刷プレビューと印刷の実現 陳 start
    requestrReportParams(param) {
      // 機能コード判定
      // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3) && !this.popoverOpened) {
      // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        // 機能一致

        // 印刷パラメータを応答
        const param = {
          facilityCd: this.getFacilityCd,
          // add #5984 体重測定 コンテンツを追加する 孟堅 start　
          // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          patId: this.selectedPatId,
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 start
          patIds: this.getSelectedPats.map(({ patId }) => patId),
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 end
          // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          functionCd:"01301",
          date: dayjs(Date.now()).format("YYYYMMDD"),     // 日付（1日）：今日
          fromDate: dayjs(Date.now()).format("YYYY/MM/DD"), //  日付（期間）：今日から今日
          toDate: dayjs(Date.now()).format("YYYY/MM/DD"),
          // add #5984 体重測定 コンテンツを追加する 孟堅 end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 陳 end
    // 体重計選択ポップアップ
    showMstWeightPopover() {
      this.popoverData.popoverVisible = true;
    },
    createPopoverContentData(mstData, objCd, objName) {
      const retArr = [];
      for (let i = 0; i < mstData.length; i++) {
        retArr.push({
          value: mstData[i][objCd],
          text: mstData[i][objName],
        });
      }
      return retArr;
    },

    closePopover() {
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
      this.popoverOpened = false;
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
      this.popoverData.popoverVisible = false;
      if (this.getWeightMode.isWeightMode) {
        // 体重計モード時、体重計選択ポップアップ閉じた時に患者ID入力欄へフォーカスする
        this.focusPatInput();
      }
    },
    returnPopover(selectData) {
      this.selectMstWeightByCd(selectData.value);
      // add #10359 編集権限の動作不正 start
      if (selectData.value != null && selectData.value != -1 && Number(this.getQueryParameters.MODE) == 1) {
        this.isAssignedWeightNo = true;
      }
      // add #10359 編集権限の動作不正 end
    },
    // 車いすマスタ編集クリック
    onClickWheelChair() {
      this.setMasterName("mst_wheel_chair");
      this.setLogicalMasterName("mst_wheel_chair");
      this.goSpecifiedView("wheelchair");
    },
    // 患者ID入力エリアクリック
    inputPatId(value) {
      // 入力された患者ID
      let hospPatId = value;

      if (hospPatId.length > 0) {
        // FNSI-修正 ログ対応 徐 start
        let msg = "患者検索が[" + hospPatId + "]で検索しました。";
        let paramObj = {'message': msg, 'functionName': '患者検索'};
        ApiHelper.put("/logs/event/conditionlog", paramObj)
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('WeightModeComponent.vue', 'inputPatId', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          });
        // FNSI-修正 ログ対応 徐 end
        EventBus.$emit("searchHospPatIdSchedule", {
          hospPatId: hospPatId,
        });
      }
    },
    // 患者検索ボタン
    // -----------------------------------------
    // 患者検索モーダル表示
    // -----------------------------------------
    onClickPatSearch() {
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
      this.popoverOpened = true;
      // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      store.dispatch("report/getMstReport", {funcCd: "01302",printFlag: 0});
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
      let isHospPatId = this.getPatIdInputElement()?.value || "";
      this.setIsHospPatId(isHospPatId);
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
      // 条件セット
      const today = dayjs().format("YYYYMMDD");
      // FNSI-修正 ログ対応 徐 start
      let msg = "患者検索が[" + today + "]で検索しました。";
      let paramObj = {'message': msg, 'functionName': '患者検索'};
      ApiHelper.put("/logs/event/conditionlog", paramObj)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('WeightModeComponent.vue', 'onClickPatSearch', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        });
      // FNSI-修正 ログ対応 徐 end
      // 本日のスケジュールを取得
      this.searchWeightSchedule({ treatDate: today, isPast: false }).then(
        (response) => {
          // 取得したスケジュールをセット
          this.setScheduleList(response.data).then(() => {
            // 患者検索モーダル表示
            this.showPatSearchModal();
          });
        }
      );
    },
    // -----------------------------------------
    // 患者検索モーダル表示
    // -----------------------------------------
    showPatSearchModal() {
      // 患者検索モーダル表示
      this.showPatSearch();
    },
    moveToMeasureView() {
      // 選択した患者で条件送信画面画面へ遷移
      this.goSpecifiedView("weight-send-condition");
    },
    // 測定値受信
    onReceiveMeasureValue(value) {
      // 測定値受信
      this.setMeasuredValue(value);
      this.calcWeightValue();

      // 測定記録保存
      this.saveMeasure({
        facilityCd: this.getFacilityCd,
        userId: this.getStateUserAccountInfo.userId,
        weightInfo: this.getSelectedMstWeight,
        category: weightScaleClass.scale,
      })
        .then((r) => {
          // 保存成功
          this.setBaseOrdWeightNo(r.data.weight_scale_no);
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('WeightModeComponent.vue', 'onReceiveMeasureValue', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            // 記録に失敗
          }
        });
      // 測定画面へ遷移
      this.goSpecifiedView("weight-send-condition");
    },
    refresh() {
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      store.dispatch("report/getMstReport", {funcCd: "01302",printFlag: 9});
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      this.setLoadingScreenVisible(true);

      // 施設設定マスタから測定患者選択画面の車いすマスタ編集
      sendRequestGetMstFacilitySettingValue(this.getFacilityCd, MST_WEIGHT_EDIT_WITH_PAT_SELECTION).then(response => {
        const isEditFlag = response.data;
        /**
         * NOTE
         * isEditFlag = 0 : 管理者権限を持っているアカウントは表示し、一般アカウントは非表示
         * isEditFlag = 1 : 全アカウントで表示
        */
        if ((isEditFlag === 0 && this.getStateUserAccountInfo.administrator === 1) || isEditFlag === 1) {
          this.isEditMstWheelChair = true;
        } else {
          this.isEditMstWheelChair = false;
        }
      });

      this.fetchMstWeightList(this.getFacilityCd)
        .then((r) => {
          this.setMstWeightList(r.data).then(() => {
            this.popoverData.popoverTitleHeader = "体重計選択";
            this.popoverData.popoverContentLabel = "接続体重計";
            this.popoverData.popoverContentDataset = this.createPopoverContentData(
              this.getMstWeightList.filter((elm) => elm.weightNo !== 0),
              "weightCd",
              "weightName"
            );
            this.fetchEnableWeightSelect().then((r) => {
              const enableWeightSelect = r.data;
              this.setEnableWeightSelect(enableWeightSelect).then(() => {
                // mod #10359 編集権限の動作不正 start
                if (Number(this.getQueryParameters.MODE) == 1) {
                  //mod #12385 体重測定画面で患者選択後にキャンセルすると、体重計ボタンが非活性になる zrx start
                  this.isDisableWeightSelect = !this.getIsEnableWeightSelect && this.getSelectWeightSetting.weightCd == -1;
                  //mod #12385 体重測定画面で患者選択後にキャンセルすると、体重計ボタンが非活性になる zrx end
                } else {
                  this.isDisableWeightSelect = !this.getIsEnableWeightSelect;
                }
                // mod #10359 編集権限の動作不正 end
              });
              const selectedWeightNo = this.getSelectedWeightNo;
              //add #12385 体重測定画面で患者選択後にキャンセルすると、体重計ボタンが非活性になる zrx start
              // 体重計番号固定で起動した場合に固定する、そうでない場合はリセット
              const queryParameters = this.getQueryParameters;
              //add #12385 体重測定画面で患者選択後にキャンセルすると、体重計ボタンが非活性になる zrx end
              if (selectedWeightNo === null) {
                // mod FNSI-redMine #4524対応  陳 start
                if (Number(queryParameters.WEIGHTNO) >= 0) {
                // mod FNSI-redMine #4524対応  陳 end
                  // 体重計番号指定起動
                  this.isAssignedWeightNo = true;
                  const localFuncSelectMstWeightByCd = async () => {
                    this.selectMstWeightByNo(
                      Number(queryParameters.WEIGHTNO)
                    ).then(() => {
                      this.finishStartupLoading();
                      this.selectedWeightIdx = this.getMstWeightIndex;
                      // add #10359 編集権限の動作不正 start
                      if (this.getMstWeightIndex < 0) {
                        this.isAssignedWeightNo = false;
                      }
                      // add #10359 編集権限の動作不正 end
                    });
                  };
                  if (Number(queryParameters.MODE) == 1) {
                    localFuncSelectMstWeightByCd().then(() => {
                      // 体重計モード
                      // 体重計番号が不正な場合は選択ボタン活性にする
                      this.setWeightMode({
                        isWeightMode: true,
                        defaultDispMenu: this.isDispMenu,
                      });

                      // フッターメニューの非表示切り替え
                      this.setDispMenuBar(0);
                      // サイドメニューを閉じる
                      EventBus.$emit("forceCloseSideBar");
                      // サイドメニュー、サイドメニュー開閉ボタンを非表示化
                      this.setIsDispSidebarBtn(false);
                    });
                  } else {
                    // 体重計モードではない
                    if (Number(enableWeightSelect) === 1) {
                      // 体重計変更可能
                      localFuncSelectMstWeightByCd();
                    } else {
                      // 体重計変更不可
                      this.selectedWeightIdx = -1;
                      this.setMstWeightSelectIdx(-1).then(() => {
                        this.finishStartupLoading();
                      });
                    }
                  }
                } else {
                  // 体重計番号指定せず起動
                  this.selectedWeightIdx = -1;
                  this.setMstWeightSelectIdx(-1).then(() => {
                    this.finishStartupLoading();
                  });
                  if (Number(queryParameters.MODE) == 1) {
                    this.setWeightMode({
                      isWeightMode: true,
                      defaultDispMenu: this.isDispMenu,
                    });

                    // フッターメニューの非表示切り替え
                    this.setDispMenuBar(0);
                    // サイドメニューを閉じる
                    EventBus.$emit("forceCloseSideBar");
                    // サイドメニュー、サイドメニュー開閉ボタンを非表示化
                    this.setIsDispSidebarBtn(false);
                  }
                }
              } else {
                this.selectMstWeightByNo(selectedWeightNo).then(() => {
                  this.finishStartupLoading();
                  this.selectedWeightIdx = this.getMstWeightIndex;
                  // add #10359 編集権限の動作不正 start
                  //mod #12385 体重測定画面で患者選択後にキャンセルすると、体重計ボタンが非活性になる zrx start
                  if (Number(queryParameters.WEIGHTNO) >= 0) {
                    this.isAssignedWeightNo = true;
                  }
                  //mod #12385 体重測定画面で患者選択後にキャンセルすると、体重計ボタンが非活性になる zrx end
                  if (this.getMstWeightIndex < 0) {
                    this.isAssignedWeightNo = false;
                  }
                  // add #10359 編集権限の動作不正 end
                });
              }
              // 患者情報ヘッダ用の患者情報クリア
              this.resetSelectedPatHeader();
            });
          });
        })
        .catch((e) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('WeightModeComponent.vue', 'refresh', e);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          console.error(e);
          this.setLoadingScreenVisible(false);
        });
    },
    // 体重計モードの専用cssファイル読み込み
    readWeightModeCss() {
      appendScopedStylesheet("./css/ntss_weight_mode.css", this.$el || null);
    },
    finishStartupLoading() {
      if (!this.finishLoading) {
        this.finishLoading = true;
        this.setLoadingScreenVisible(false);
      }
      this.setLoadingScreenVisible(false);
      this.$nextTick(() => {
        this.calculateContentHeight();
      });
    },
    isMobileBrowser() {
      return /android|iphone|ipad/i.test(getScopedUserAgent(this.$el || null));
    },
    focusPatInput() {
      if (!this.isMobileBrowser()) {
        this.getPatIdInputElement()?.focus?.();
      }
    },
    /**
     * テンキー表示
     */
    show() {
      this.input = this.getPatIdInputElement();
      this.input.setAttribute("readonly", "readonly");

      this.selectAllInput(this.input);

      let name = ["{clr} {backspace}", "7 8 9", "4 5 6", "1 2 3", "{zero} {cancel}"];
      let meta = {
        "clr": { func: "accept", text: "CLR", classes: "control"},
        "backspace": { func: "backspace", classes: "control"},
        "zero": { key: "0"},
        "cancel": { func: "cancel", text: "確定", classes: "featured"}
      };
      let layoutparam = {default: name, _meta: meta};
      this.layout = layoutparam;
      this.popoverTarget = this.input;
      this.cavisible = !this.cavisible;
    },
    // テンキー用関数 accept: 全文字クリア
    accept() {
      this.clearValue();
      this.moveCursor();
    },
    // テンキー用関数 cancel: 画面テンキーを閉じる
    cancel() {
      this.getNumericPopoverElement()?.hide?.();
      this.cavisible = false;
      if (this.getWeightMode.isWeightMode) {
        // 体重計モード時、テンキー閉じた時に患者ID入力欄へフォーカスする
        this.focusPatInput();
      }
      // 患者検索（テキストボックスのエンターキー操作と同等）
      this.inputPatId(this.input.value);
    },
    // テンキー用関数 tenkeyClose: 画面テンキーを閉じた際の内部処理
    tenkeyClose() {
      this.input?.removeAttribute("readonly");
      this.input = null;
      if (this.getWeightMode.isWeightMode) {
        // 体重計モード時、テンキー閉じた時に患者ID入力欄へフォーカスする
        this.focusPatInput();
      }
    },
    // テンキー用内部関数 moveCursor: カーソル位置を右端にセットする
    moveCursor() {
      this.input.focus();
      this.input.setSelectionRange(10, 10);
    },
    // テンキー用内部関数 selectAllInput: 入力内容を全選択状態にする
    selectAllInput(inputElement) {
      inputElement.focus();
      inputElement.setSelectionRange(0, inputElement.value.length);
    },
    // テンキー用内部関数 clearValue: 患者IDをクリアする
    clearValue() {
      this.input.value = null;
    },
    /**
     * 体重計測定記録画面へ遷移します。
     */
    onClickMeasureHistory() {
      this.goSpecifiedView("weight-mode-measure-history");
    },
    /**
     * 体重計モード測定記録ボタン表示/非表示を施設設定マスタから取得し、shouldDisplayMeasureHistoryButtonにセットします。
     * 1：表示するのみtrue。それ以外はfalse。
     */
    fetchMeasureHistoryButtonDisplay() {
      sendRequestGetMstFacilitySettingValue(this.getFacilityCd, WEIGHT_MODE_MEASURE_HISTORY_BUTTON_DISPLAY)
        .then(response => {
          this.shouldDisplayMeasureHistoryButton =
            Number(response && response.data) === 1;
        })
        .catch(error => {
          getErrorMessage('WeightModeComponent.vue', 'fetchMeasureHistoryButtonDisplay', error);
        });
    },
  },
  created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // ADD #7221 2023/02/05 By HandsomeLin Start
    // In order to enter the scale mode as soon as possible.
    // ADD #7221 2023/02/05 By HandsomeLin End

    const queryParameters = this.getQueryParameters;
    if (Number(queryParameters.MODE) === 1) {
      this.setWeightModeOnly(true);
      this.readWeightModeCss();

      // 全画面メッセージの表示をチェックする
      const scopedLocalStorage = getScopedLocalStorage(this.$el || null);
      let isFullScreenMsgShow = JSON.parse(scopedLocalStorage.getItem(LOCAL_STORAGE_KEY.FULL_SCREEN_MSG_SHOW));
      if (isFullScreenMsgShow) {
        scopedLocalStorage.removeItem(LOCAL_STORAGE_KEY.FULL_SCREEN_MSG_SHOW);

        // 全画面にする
        this.$ons.notification.confirm({
          modifier:"info",
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          title: DIALOG_MESSAGES[13000127].title,
          message: messageFormat(DIALOG_MESSAGES[13000127].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if(answer === 1)
            {
              setTimeout(() => {
                var element = getScopedDocumentElement(this.$el || null);
                var requestMethod = element?.requestFullScreen || element?.webkitRequestFullScreen || element?.mozRequestFullScreen || element?.msRequestFullScreen;
                if (requestMethod) {
                  requestMethod.call(element);
                }
              });
            }
            // 体重計モード時、初期表示時に患者ID入力欄へフォーカスする
            // (mounted()でもフォーカスをしているが、モーダルの影響でフォーカスが外れる為、再度フォーカスし直す)
            // モーダル閉じた時や全画面表示とのタイミング調整、0.1秒遅延させる
            setTimeout(() => {
              this.focusPatInput();
            }, 100);
          }
        });
      }
    }

    this.setLoadingScreenVisible(true);
    EventBus.$on("loadSendConditionView", this.moveToMeasureView);
    EventBus.$on("onReceiveMeasureValue", this.onReceiveMeasureValue);
    EventBus.$on("refresh", this.refresh);
    // add 画面印刷プレビューと印刷の実現 陳 start
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 陳 end
    EventBus.$on("weightModeFocusPatId", this.focusPatInput);

    // ymdtime更新処理(初回)
    this.weightName = this.getWeightConfigInfo.weightName !== null && this.getWeightConfigInfo.weightName !== undefined
          ? this.getWeightConfigInfo.weightName
          : "体重計接続なし";
    var weekday=["日","月","火","水","木","金","土"];
    this.ymdTime = dayjs().format("YYYY/MM/DD") + "(" + weekday[dayjs().day()] + ") " + dayjs().format("HH:mm");

    this.ymdUpdateProc = setInterval(() => {
      // ymdtime更新処理(1秒ごと)
      this.weightName = this.getWeightConfigInfo.weightName !== null && this.getWeightConfigInfo.weightName !== undefined
            ? this.getWeightConfigInfo.weightName
            : "体重計接続なし";
      var weekday=["日","月","火","水","木","金","土"];
      this.ymdTime = dayjs().format("YYYY/MM/DD") + "(" + weekday[dayjs().day()] + ") " + dayjs().format("HH:mm");
    }, 1000);

    if (this.getWeightMode.isWeightMode) {
      // 体重計モード時、測定記録ボタン表示/非表示を施設設定マスタから取得しセット
      this.fetchMeasureHistoryButtonDisplay();
    }
  },
  mounted() {
    this.resetSelectedPatHeader();
    this.refresh();

    this.$nextTick(() => {
      // 体重計モード時、他画面から遷移時に患者ID入力欄へフォーカスする
      // OnsenUI描画とのタイミング調整、0.1秒遅延させる
      setTimeout(() => {
        this.focusPatInput();
      }, 100);
    });
  },
  beforeUnmount() {
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    EventBus.$off("refresh", this.refresh);
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    EventBus.$off("loadSendConditionView", this.moveToMeasureView);
    /* modify by chamaojia 2023-06-01 体重計modokiと体重計アプリが使いにくくなった  --start */
    // イベントのアンバインドはバインドと一致する必要があります
    EventBus.$off("onReceiveMeasureValue", this.onReceiveMeasureValue);
    /* modify by chamaojia 2023-06-01 体重計modokiと体重計アプリが使いにくくなった  --end */
    // add 画面印刷プレビューと印刷の実現 陳 start
    // 印刷パラメータ要求
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // add 画面印刷プレビューと印刷の実現 陳 end
    clearInterval(this.ymdUpdateProc);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());

    EventBus.$off("weightModeFocusPatId", this.focusPatInput);
  },
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao start
  watch :{
    getFocus(){
      if (this.getWeightMode.isWeightMode) {
        // 体重計モード時、患者選択モーダルを×かキャンセルで閉じた時に患者ID入力欄へフォーカスする
        this.focusPatInput();
      } else if(this.getIsHospPatId){
        this.getPatIdInputElement()?.focus?.();
      }
      this.setFocus("2");
    }
  }
  // add 8449【デグレ】体重測定画面を開くと患者名欄が緑枠（変更状態）になる zhao end
};
</script>
<style scoped>
/* #9556 測定患者選択画面にスクロールバーが常に表示される linjunfeng start */
.send-condition-main-content-area {
  display: flex;
  flex-direction: column;
  margin: 5px;
  margin-top: 0;
}
 
/* #9556 測定患者選択画面にスクロールバーが常に表示される linjunfeng end */
.popoverClass :deep(.popover--top) {
  width: fit-content;
}
:deep(.vue-touch-keyboard .keyboard .key.featured) {
  flex-grow: 86;
}
:deep(.vue-touch-keyboard .keyboard .key.backspace) {
  background-size: 1.25em;
}
/*
  ntss.cssで定義されたons-input .text-input:focusのスタイル打消し
  ※コンポーネントの<style>内に定義する関係でvue独自IDがセレクタに自動付与される。
    その為、OnsenUIが自動挿入する要素に対してセレクタが当たらなくなる。これを回避する為に:deepを付与している。
*/
:deep(ons-input#patIdID .text-input:focus) {
  border-width: 2px !important;
  border-style: inset !important;
  border-color: initial !important;
  outline: initial !important;
}
@media print {
  .weight-mode-time-content{
    position:static !important;
  }
}
</style>
