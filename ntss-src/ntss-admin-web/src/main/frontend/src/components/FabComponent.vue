/**
 * FabPageレイアウト
 */
<template id='fab-page-template'>
  <div v-if="isLogined && isDispFloatMenu" @mousedown="toggleDevTool" @mouseup="cancelToggleDevTool" :class="{ 'dev-tool-unlocked': !isLockDevTool }">
    <span class="notification unread-count" @click="showNotificationMessage(), closeUserMenu()">{{ unreadCount }}</span>
    <v-ons-speed-dial id="user-menu" ref="user_menu" position="top right" direction="down" ripple="true" v-model:open="userMenuOpen" @click='showUserMenuPopover($event)'>
      <v-ons-fab>
        <v-ons-icon>{{ userName }}</v-ons-icon>
      </v-ons-fab>
      <div v-if="!isLockDevTool" class="memory-display" v-text="memoryDisplayText" />
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !isPasswordExpired" @click='showNotificationMessage(), closeUserMenu()'>
          <img :src="publicAssetPath('img/fab/information.png')" title="通知" class="ntss-fab-icon"/>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !isPasswordExpired">
        <v-ons-icon @click='showAccountEdit(), closeUserMenu()'>
          <img :src="publicAssetPath('img/fab/account2.png')" title="アカウント情報" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !isOnlyReMS && !isPasswordExpired">
        <v-ons-icon @click='showPersonalSettings(), closeUserMenu()'>
          <img :src="publicAssetPath('img/fab/Personal_Settings2.png')" title="個人設定" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="isNkkStaff && !isProvisional && !isWeightMode && !isPasswordExpired">
        <v-ons-icon @click='showStaffFacility(), closeUserMenu()'>
          <img :src="publicAssetPath('img/fab/my_client.png')" title="担当施設設定" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <!-- TODO: メニューを復活させる場合、"&& false"を削除する -->
      <v-ons-speed-dial-item v-if="!isProvisional && !isPasswordExpired" @click='hideItemPopover(), showFabPopover($event)'>
        <v-ons-icon>
          <img :src="publicAssetPath('img/fab/fontsizes.png')" title="文字サイズ" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !isPasswordExpired" @click='hideItemPopover(), showThemePopover($event)'>
        <v-ons-icon>
          <img :src="publicAssetPath('img/fab/theme.png')" title="テーマ切替" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !isPasswordExpired && isShowFacilitySwitch" @click='hideItemPopover(), showFacilitiesBtn($event)'>
        <v-ons-icon>
          <img :src="publicAssetPath('img/fab/switch_login.png')" title="施設切替" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <!-- mod #12462 患者情報共有 関 start -->
      <v-ons-speed-dial-item
        v-if="!isProvisional && !isWeightMode && !isPasswordExpired && isPatientSharedAuthorized && getItemAuthorized('PatientShare', 'default_authority')"
        @click='hideItemPopover(), showPatientSharedBtn($event)'>
        <v-ons-icon>
          <img :src="publicAssetPath('img/patdata-share/patdata-share.png')" title="患者共有" class="ntss-fab-icon" />
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <!-- mod #12462 患者情報共有 関 end -->
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && false && !isPasswordExpired" @click='hideItemPopover(), showSplitFramePopover($event)'>
        <v-ons-icon>
          <!-- 仮アイコン -->
          <label style="font-size: 17px">分割</label>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !isPasswordExpired" @click='showMenuBarEdit(), closeUserMenu()'>
        <v-ons-icon>
          <img :src="publicAssetPath('img/fab/menu2.png')" title="メニューバー設定" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !isOnlyReMS && !isPasswordExpired" @click='showWindowPrintDialog()'>
        <v-ons-icon>
          <img :src="publicAssetPath('img/fab/screen_printing4.png')" title="画面印刷" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item
        v-if="isReportButtonVisible"
        ref="reportButton"
        :disabled="reportButtonDisabled ? true : null"
        @click='hideItemPopover(), showReportPopover($event)'>
        <v-ons-icon>
          <img :src="publicAssetPath('img/fab/F_Print.png')" title="機能帳票印刷" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item  v-if="!isProvisional && !isWeightMode && !isPasswordExpired" @click='hideItemPopover(), showHelpPopover($event)'>
        <v-ons-icon>
          <img :src="publicAssetPath('img/fab/help.png')" title="ヘルプ" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && isAvailableNotification() && getIsRegisteredNotification && !isPasswordExpired">
        <v-ons-icon @click='unregisterNotification(), closeUserMenu()'>
          <img :src="publicAssetPath('img/fab/noti_on.png')" title="通知ON状態" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && isAvailableNotification() && !getIsRegisteredNotification && !isPasswordExpired">
        <v-ons-icon @click='registerNotification(), closeUserMenu()'>
          <img :src="publicAssetPath('img/fab/noti_off.png')" title="通知OFF状態" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !isAvailableNotification() && !isPasswordExpired">
        <v-ons-icon @click='unavailableMessage(), closeUserMenu()'>
          <img :src="publicAssetPath('img/fab/noti_unavailable.png')" title="通知無効状態" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <!-- add FNSI-メニューに共有ON／共有OFFを追加する。 周 start -->
      <!--mod 患者共有を隠す 劉 start-->
      <!--<v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && getIsRegisteredShared">-->
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && getIsRegisteredShared && false">
        <!--mod 患者共有を隠す 劉 end-->
        <v-ons-icon @click='unregisterShared(), closeUserMenu()'>
          <img :src="publicAssetPath('img/fab/shared_on.png')" title="共有ON状態" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <!--mod 患者共有を隠す 劉 start-->
      <!--<v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !getIsRegisteredShared">-->
      <v-ons-speed-dial-item v-if="!isProvisional && !isWeightMode && !getIsRegisteredShared && false">
        <!--mod 患者共有を隠す 劉 end-->
        <v-ons-icon @click='registerShared(), closeUserMenu()'>
          <img :src="publicAssetPath('img/fab/shared_off.png')" title="共有OFF状態" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <!-- add FNSI-メニューに共有ON／共有OFFを追加する。 周 end -->
      <v-ons-speed-dial-item v-if="!isWeightMode">
        <v-ons-icon @click='signOut'>
          <img :src="publicAssetPath('img/fab/signout3.png')" title="サインアウト" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
      <v-ons-speed-dial-item v-if="isWeightMode">
        <v-ons-icon @click='signOutAndExit'>
          <img :src="publicAssetPath('img/fab/exit.png')" title="終了" class="ntss-fab-icon"/>
        </v-ons-icon>
      </v-ons-speed-dial-item>
    </v-ons-speed-dial>

    <div ref="manualPdfArea" id="manualPdfArea" v-show="isShowManual">
      <a href="help/FNSi/FutureNetWeb+Si操作マニュアル.pdf" class="manual-download-btn control-z-index" download="FutureNetWeb+Si操作マニュアル.pdf" v-if="device != 'iOS' && showManualType == '1'">
        <ons-icon icon="fa-download"></ons-icon>
      </a>
      <a href="help/ReMS/ReMS操作マニュアル.pdf" class="manual-download-btn control-z-index" download="ReMS操作マニュアル.pdf" v-if="device != 'iOS' && showManualType == '2'">
        <ons-icon icon="fa-download"></ons-icon>
      </a>
      <div v-if="device == 'iOS'" class="manual-not-download control-z-index" id="hideText">
                お使いの端末ではダウンロードできません。
      </div>
      <ons-toolbar-button class="close-btn manual-close-btn" @click="closeManual()">
        <ons-icon icon="fa-times"></ons-icon>
      </ons-toolbar-button>
      <div ref="pdfContainer" id="pdf-container"  v-show="showManualType == '2'" style="width:100%;height:100%;overflow-y:scroll;-webkit-overflow-scrolling: touch;">
      </div>
      <div ref="pdfContainerFnsi" id="pdf-container-fnsi" v-show="showManualType == '1'" style="width:100%;height:100%;overflow-y:scroll;-webkit-overflow-scrolling: touch;">
      </div>
    </div>

    <v-ons-popover :class="fontSizeSet" id="user-menu-popover" cancelable v-model:visible='userMenuPopoverVisible' :target='userMenuPopoverTarget' :cover-target="true" @prehide="closeUserMenu">
    </v-ons-popover>
    <v-ons-popover :class="[fontSizeSet, 'user-menu-item-popover']" v-model:visible='fontSizePopoverVisible' :target='fontSizePopoverTarget' :direction='fontSizePopoverDirection'>
      <!-- add/ #12498 プルダウンui異常 tianqidong start-->
      <v-ons-range v-model='fontSize' min='0' max='3' @input="onFountSizeChange"></v-ons-range>
      <!-- add/ #12498 プルダウンui異常 tianqidong end-->
      <div class="popover-label">
        <!--mod FNSI-画面部品デザイン じょはく start-->
        <label class="fab-font-color">サイズ：{{ fontSizeName }}</label>
        <!--mod FNSI-画面部品デザイン じょはく end-->
      </div>
    </v-ons-popover>
    <v-ons-popover :class="[fontSizeSet, 'user-menu-item-popover theme']" v-model:visible='themePopoverVisible' :target='themePopoverTarget' :direction='themePopoverDirection'>
      <v-ons-switch v-model='isBlackTheme'></v-ons-switch>
      <div class="popover-label">
        <!--mod FNSI-画面部品デザイン じょはく start-->
        <label class="fab-font-color">テーマ切替</label>
        <!--mod FNSI-画面部品デザイン じょはく end-->
      </div>
    </v-ons-popover>

    <div class="facilitiesPopoverView" v-if="facilitiesPopoverVisible">
      <v-ons-popover :id="checkDomClass" :class="[fontSizeSet, 'user-menu-item-popover theme facilitesBox']"
        v-model:visible='facilitiesPopoverVisible' :target='facilitiesPopoverTarget'
        :direction='facilitiesPopoverDirection'>
        <can-login-facilities @childSendClose="childSendCloseFN" @childSendHidden="childSendHiddenFN" />
      </v-ons-popover>
    </div>

    <!-- mod #12462 患者情報共有 関 start -->
    <div v-if="patientSharedPopoverVisible">
      <v-ons-popover :class="[fontSizeSet, 'user-menu-item-popover']" v-model:visible='patientSharedPopoverVisible'
        :target='patientSharedPopoverTarget' :direction='patientSharedPopoverDirection'>

        <div class="radio-center-group">
          <div class="radio-item">
            <custom-radio :value="patientShareMode" :radio-value="1" name="patientShareMode"
              @change="changePatientShareMode(1)">
              自施設のみ
            </custom-radio>
          </div>
          <div class="radio-item">
            <custom-radio :value="patientShareMode" :radio-value="0" name="patientShareMode"
              @change="changePatientShareMode(0)">
            </custom-radio>

            <custom-select :value="selectedFacilityCd" :options="facilityOptions" class="input-style"
              @change="changePatientShareFacilityCdMode(selectedFacilityCd.editValue)"
              :disabled="patientShareMode.editValue == 1" />
            <div class="msg-wrapper">
              <div class="warning-msg">
                <div v-if="showMsg1" class="msg">{{ MSG1 }}</div>
                <div v-else-if="showMsg2" class="msg">{{ MSG2 }}</div>
              </div>
            </div>
          </div>
        </div>
      </v-ons-popover>
    </div>
    <!-- mod #12462 患者情報共有 関 end -->

    <v-ons-popover
      :class="[fontSizeSet, 'user-menu-item-popover popover-help']"
      cancelable
      v-model:visible="helpPopoverVisible"
      :target="helpPopoverTarget"
      :direction="helpPopoverDirection"
    >
      <div class="popover-help-panel">
        <ons-list class="popover-help-list">
          <ons-list-header class="popover-help-header">取扱説明書</ons-list-header>
          <ons-list-item
            class="popover-help-item"
            tappable
            v-show="isFNSi"
            @click="showHelpFnsi(); closeUserMenu()"
          >FutureNetWeb⁺Si取扱説明書</ons-list-item>
          <ons-list-item
            class="popover-help-item"
            tappable
            v-show="isReMS"
            @click="showHelp(); closeUserMenu()"
          >ReMS取扱説明書</ons-list-item>
          <ons-list-header class="popover-help-header popover-help-header--section">リリース情報</ons-list-header>
          <ons-list-item
            class="popover-help-item"
            tappable
            @click="showReleaseInfo(); closeUserMenu()"
          >リリース情報一覧</ons-list-item>
        </ons-list>
      </div>
    </v-ons-popover>

    <v-ons-popover :class="[fontSizeSet, 'user-menu-item-popover']" v-model:visible='splitFramePopoverVisible' :target='splitFramePopoverTarget' :direction='splitFramePopoverDirection'>
      <v-ons-switch v-model='isSplitFrame'></v-ons-switch>
      <div class="popover-label">
        <label>画面フレーム分割切替</label>
      </div>
    </v-ons-popover>
    <report-selector
      :popoverVisible="reportPopoverVisible"
      :popoverTarget="reportPopoverTarget"
      @popover-close="reportPopoverVisible = false"
    />
    <div v-if="messageDialogInfo.isDialogVisible">
      <message-dialog
        v-model:visible="messageDialogInfo.isDialogVisible"
        :title="messageDialogInfo.title"
        :message-cd="messageDialogInfo.messageCd"
        :type="messageDialogInfo.type"
        :string-params="messageDialogInfo.stringParams"
      />
    </div>
  </div>
</template>

<script>
//mod 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 start
//import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
//mod 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 end
import { EventBus } from "@/compat/vue/event-bus.js";
import ReportSelectorComponent from "@/components/ReportSelectorComponent";
import { ApiHelper } from "@/apis/AxiosHelper";
import { webPushSubscribe, saveNotificationList } from "@/functions/WebPushFunctions";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import canLoginFacilities from "@/components/canLoginFacilities/canLoginFacilities";
import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
import PopoverMixin from "@/components/PopoverMixin";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { PASSWORD_VALIDITY_PERIOD } from "@/constants/facilitySetting";
import dayjs from "@/compat/date/dayjs";
import { getFooterMenuHeight, getFooterMenuClientHeight, getViewportHeight, getScopedWindow, getScopedLocalStorage, getScopedUserAgent, createScopedImageElement } from "@/functions/common/LayoutMeasureHelper";
import { publicAssetPath } from "@/compat/assets/public-path";
import {
  getOnsSpeedDialElement,
  getOnsSpeedDialFabElement,
  getOnsSpeedDialItemElements,
  getOnsSpeedDialIconElements,
  getOnsSpeedDialEventTarget
} from "@/functions/common/OnsenFunctions";
// add FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 start
import store from "@/stores";
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 end
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end
// mod #12462 患者情報共有 関 start
import customRadio from "@/components/common/custom-form-tags/CustomRadio";
import CustomSelect from "@/components/common/custom-form-tags/CustomSelect";
import { FUNC_SHARING_PATIENT_INFORMATION } from "@/constants/function-code.js";
// mod #12462 患者情報共有 関 end
import { getAuthorized } from "@/functions/common/CommonFunctions";

/* テーマ定義 */
const THEME_WHITE = 0;
const THEME_BLACK = 1;

/* 画面フレーム分割定義 */
const NO_SPLIT_FRAME = 0;
const SPLIT_FRAME = 1;

/* TODO (仮) ヘルプ用URL */
const HELP_URL = "help/ReMS/ReMS操作マニュアル.pdf";
const MANUAL_DIR_URL = "help/ReMS/operation_manual";
const MANUAL_LIST_URL = "help/ReMS/operation_manual/list.txt"

/* TODO(仮) FNSiヘルプ用URL */
const FNSI_HELP_URL = "help/FNSi/FutureNetWeb+Si操作マニュアル.pdf";
const FNSI_MANUAL_DIR_URL = "help/FNSi/operation_manual";
const FNSI_MANUAL_LIST_URL = "help/FNSi/operation_manual/list.txt";

// 未読件数表示上限
const UNREAD_COUNT_MAX = 99;
const REPORT_FETCH_EXCLUDED_FUNC_CDS = [
  "02303",
  "03201",
  "03301",
  "03401",
  "02102",
  "02202",
  "01802",
  "02101"
];

export default {
  mixins: [PopoverMixin],
  components: {
    "report-selector": ReportSelectorComponent,
    "message-dialog": messageDialog,
    "can-login-facilities": canLoginFacilities,
    // mod #12462 患者情報共有 関 start
    "custom-radio": customRadio,
    "custom-select": CustomSelect,
    // mod #12462 患者情報共有 関 end
  },
  data() {
    return {
      // add FNSI-患者選択された状態 じょはく start
      printFlag: null,
      // add FNSI-患者選択された状態 じょはく end
      userMenuOpen: false,
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      fontSizePopoverVisible: false,
      fontSizePopoverTarget: null,
      fontSizePopoverDirection: "left",
      themePopoverVisible: false,
      themePopoverTarget: null,
      themePopoverDirection: "left",
      facilitiesPopoverVisible: false,
      facilitiesPopoverTarget: null,
      facilitiesPopoverDirection: "left",
      // mod #12462 患者情報共有 関 start
      patientSharedPopoverTarget: false,
      patientSharedPopoverVisible: null,
      patientSharedPopoverDirection: "left",
      // mod #12462 患者情報共有 関 end
      helpPopoverVisible: false,
      helpPopoverTarget: null,
      helpPopoverDirection: "left",
      splitFramePopoverVisible: false,
      splitFramePopoverTarget: null,
      splitFramePopoverDirection: "left",
      reportPopoverVisible: false,
      reportPopoverTarget: null,
      isShowManual: false,
      showManualType: null,
      manualPdf: null,
      device: null,
      //ReMS用
      lstManualImg: [],
      manualImgPageCnt: 0,
      dispManualPageCnt: 0,
      //fnSi用
      lstManualImgFnsi: [],
      manualImgPageCntFnsi: 0,
      dispManualPageCntFnsi: 0,
      // メニューアイコンのサイズと位置
      itemHeight: 0,
      itemWidth: 0,
      itemMargin: 16,
      itemTop: 0,
      itemLeft: 0,
      lockDevToolTimeout: null,
      terminalUniqueString: null,
      // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
      userSharedData: {
        userId: null,
        patientShared: null
      },
      // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end
      //メッセージ設定用のJson
      messageDialogInfo: {
        isDialogVisible: false,
        title: null,
        messageCd: null,
        type: "1",
        stringParams: []
      },
      passwordValidityPeriod: 999,
      performanceMemory: {
        jsHeapSizeLimit: "",
        totalJSHeapSize: "",
        usedJSHeapSize: "",
      },
      checkDomClass: "",
      // mod #12462 患者情報共有 関 start
      patientShareMode: {
        initValue: 0,
        editValue: 0
      },
      facilityOptions: [],
      selectedFacilityCd: {
        initValue: null,
        editValue: null
      },
      // mod #12462 患者情報共有 関 end
      // 患者情報共有メッセージ
      MSG1: '対象外機能のため自施設データのみ表示中',
      MSG2: '対象施設未共有のため自施設データのみ表示中',
      changeSelectedPatId : false,
      selectedFacilityCdCache : null,
    };
  },

  computed: {
    // mod #12462 患者情報共有 関 start
    // add FNSI-患者選択された状態 じょはく start
    ...mapGetters("pat-info", ["selectedPat", "selectedPatId", "getIsOtherFacility", "getOtherFacilityCd"]),
    // add FNSI-患者選択された状態 じょはく end
    ...mapGetters("facility-calendar", ["viewMode"]),
    ...mapGetters("account-edit", [
      "getRegistResult",
      "getStateUserAccountInfo",
      "getUserNameForFab",
      "getFontSize",
      "getTheme",
      "getSplitFrame",
      "getUserId",
      "getPatientShareMode",
      "getPatientShareFacilityCdMode",
    ]),
    ...mapGetters("facility", ["isUseFunction"]),
    // mod #12462 患者情報共有 関 end
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
    ...mapGetters("split-graph", {getSelPat: "getSelPat"}),
    //add 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      isDispFloatMenu: "getIsDispFloatMenu"
    }),
    ...mapGetters("notification-message", ["getUnreadCount"]),
    ...mapGetters("window-size", { windowHight: "getWindowHeight" }),
    ...mapGetters("report", ["getMstReports"]),
    ...mapGetters("send-condition/weight", ["getWeightMode"]),
    ...mapGetters("toggle-dev-tool", ["isLockDevTool", "pressedKeys"]),
    ...mapGetters("user", {
      getFacilityCd: "getFacilityCd",
      getSystemUseSetting: "getSystemUseSetting",
      isSignIn: "isSignIn",
      advancedSettings: "getAdvancedSettings"
    }),
    ...mapGetters("notification", ["getIsRegisteredNotification"]),
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
    ...mapGetters("mst-user", ["getIsRegisteredShared"]),
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end

    // ユーザ情報取得未済の場合、falseを返す
    isLogined() {
      return this.getStateUserAccountInfo;
    },
    // 利用者名を取得
    userName() {
      return this.getUserNameForFab;
    },
    // 日機装社員か否かを返す
    isNkkStaff() {
      return this.getStateUserAccountInfo.userType === 1;
    },
    // 管理者ユーザか否かを返す
    isAdminUser() {
      return this.getStateUserAccountInfo.administrator === 1;
    },
    // 初回ログインユーザー（仮登録）か否かを返す
    isProvisional() {
      return this.getStateUserAccountInfo.isProvisional;
    },
    // ReMSの表示有無を返す
    isReMS(){
      return this.getSystemUseSetting === "1" || this.getSystemUseSetting === "3";
    },
    isOnlyReMS() {
      return this.getSystemUseSetting === "1";
    },
    // FNSiの表示有無を返す
    isFNSi(){
      return this.getSystemUseSetting === "2" || this.getSystemUseSetting === "3";
    },
    // add #12462 患者情報共有 関 start
    isPatientSharedAuthorized() {
      return this.isUseFunction(FUNC_SHARING_PATIENT_INFORMATION);
    },
    // add #12462 患者情報共有 関 end
    /**
     * パスワード有効期限切れか.
     * @return 前回変更日から有効期間以上経っているか、前回変更日がnullなら、true
     */
    isPasswordExpired() {
      if (this.$route.path !== "/provisional-account-edit") {
        // 初回ログイン画面以外ではユーザーフロート制御しない
        return false;
      }
      if (this.passwordValidityPeriod === 0) {
        // パスワード有効期間が0の場合は無期限のため、期限切れチェックをしない
        return false;
      }
      if (this.getStateUserAccountInfo.regPasswordDate === null) {
        // 前回変更日がnullなら、true
        return true;
      }
      // 現在日時
      const nowDate = dayjs(new Date());
      // パスワード変更日時
      const regPasswordDate = dayjs(this.getStateUserAccountInfo.regPasswordDate);
      // 差分
      const monthDiff = nowDate.diff(regPasswordDate, 'months');
      return monthDiff >= this.passwordValidityPeriod;
    },
    fontSize: {
      get() {
        return this.getFontSize;
      },
      set(value) {
        this.changeFontSize(value, this.fontSize);
      }
    },
    // 文字サイズ名を取得
    fontSizeName() {
      const names = ["小", "中", "大", "特大"];
      return names[this.fontSize];
    },
    // テーマ切替
    isBlackTheme: {
      get() {
        // Storeの値が0:false, 1:trueを返却
        return this.getTheme === THEME_WHITE ? false : true;
      },
      set(value) {
        // valueがfalse:0, true:1をセット
        this.changeTheme(value, this.isBlackTheme);
      },
    },
    // 画面フレーム分割切替
    isSplitFrame: {
      get() {
        // Storeの値が0:false, 1:trueを返却
        return this.getSplitFrame === NO_SPLIT_FRAME ? false : true;
      },
      set(value) {
        // valueがfalse:0, true:1をセット
        this.changeSplitFrame(value, this.isSplitFrame);
      }
    },
    // 未読件数
    unreadCount() {
      const count = this.getUnreadCount;
      if (count > UNREAD_COUNT_MAX) {
        return UNREAD_COUNT_MAX + "+";
      } else if (count > 0) {
        return String(count);
      } else {
        return "";
      }
    },
    // 印刷可能かどうか
    canReport() {
      //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 start
      // return this.getMstReports.length > 0;
      if (this.$route.name == "split-graph") {
        return Array.isArray(this.getSelPat) && this.getSelPat.length > 0;
      } else {
        return Array.isArray(this.getMstReports) && this.getMstReports.length > 0;
      }
      //mod 7297 初回リリース対象外の機能とその関連機能を隠す 姜 end
    },
    isReportButtonVisible() {
      return !this.isProvisional && !this.isWeightMode && !this.isOnlyReMS && !this.isPasswordExpired;
    },
    reportButtonDisabled() {
      return !this.canReport;
    },
    // 体重計モードかどうか
    isWeightMode() {
      if (this.getWeightMode) {
        return this.getWeightMode.isWeightMode;
      }
      return false;
    },
    ...mapGetters("app", { url: "getUrl" }),
    memoryDisplayText() {
      if (!this.performanceMemory) return "";
      const keys = ["jsHeapSizeLimit", "totalJSHeapSize", "usedJSHeapSize"];
      const text = keys.map(key => this.performanceMemory[key]).join("\n");
      const userId = ` userId : ${this.getUserId}`;
      return `${text}\n${userId}`;
    },
    //装置設定+共有対象外の画面
    msg1Page() {
      return [
        "deviceset-info",
        "bbs-info",
        "check-list",
        "daily-check",
        "external-coop",
        "facility-calendar",
        "indication",
        "master-maintenance",
        "measure-history",
        "multi-pat-list",
        "operation-viewer",
        "pat-group",
        "pat-info-sharing",
        "periodic-inspection",
        "report-menu",
        "schedule-list",
        "send-condition",
        "status-list",
        "status-map",
        "view-log",
        "water-quality-survey",
        "weight-send-condition",
        "individual-master"
      ].some(page =>
        this.$route.name?.startsWith(page)
      );
    },
    //メッセージ2Page
    msg2Page() {
      return (
        this.$route.name === "pat-info" ||
        this.$route.name === "deviceset-info"
      );
    },
    //共有チェックON
    isOtherSelected() {
      return this.patientShareMode.editValue == 0;
    },
    //施設を選択
    isSelectFacility() {
      return this.selectedFacilityCd.editValue !== null;
    },
    //共有元なし
    isNoSharedPatient() {
      return (
        this.facilityOptions.length === 1 &&
        this.facilityOptions[0].displayValue === "マージ表示"
      );
    },
    showMsg1() {
      if (this.changeSelectedPatId) {
        const isSelectFacilityBefore =
          this.selectedFacilityCdCache !== null &&
          this.selectedFacilityCdCache !== this.getFacilityCd;

        if (this.isOtherSelected && isSelectFacilityBefore && this.isNoSharedPatient) {
          return !(
            this.$route.name === "deviceset-info" ||
            this.$route.name === "pat-info"
          );
        }
      }
      // 共有チェックON+マージ表示を選択
      const case1 =
        this.isOtherSelected &&
        !this.isSelectFacility &&
        this.msg1Page;
      // 共有チェックON+施設を選択
      const case2 =
        this.isOtherSelected &&
        this.isSelectFacility &&
        this.$route.name !== "deviceset-info" &&
        this.$route.name !== "pat-info";

      return case1 || case2;
    },
    //共有チェックON+マージ表示を選択+共有元なし患者+患者情報,装置設定
    showMsg2() {
      if (this.changeSelectedPatId) {
        const isSelectFacilityBefore =
          this.selectedFacilityCdCache !== null &&
          this.selectedFacilityCdCache !== this.getFacilityCd;

        if (this.isOtherSelected && isSelectFacilityBefore && this.isNoSharedPatient) {
          return (
            this.$route.name === "deviceset-info" ||
            this.$route.name === "pat-info"
          );
        }
      }
      return (
        this.isOtherSelected &&
        !this.isSelectFacility &&
        this.isNoSharedPatient &&
        this.msg2Page
      );
    },
    // 施設マスタ＞拡張機能 施設切替のON／OFF
    isShowFacilitySwitch() {
      if (!this.advancedSettings.func_advcds) return false;
      return this.advancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.FACILITY_SWITCH
      );
    }
  },
  watch: {
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
    $route(to, from) {
      this.changePrintFlag();

      const isToTarget =
        to.name === "pat-info" || to.name === "deviceset-info" || to.name === "pat-calendar";

      const isFromTarget =
        from && (from.name === "pat-info" || from.name === "deviceset-info");

      const selectedFacilityCd = this.selectedFacilityCd.editValue;

      const isOther =
        selectedFacilityCd && selectedFacilityCd !== this.getFacilityCd;

      const isPrescriptionFlow =
        to.name?.startsWith("prescription") &&
        from?.name?.startsWith("prescription");

      const isExamFlow =
        to.name?.startsWith("exam-request") &&
        from?.name?.startsWith("exam-request");

      const isRadFlow =
        to.name?.startsWith("rad-request") &&
        from?.name?.startsWith("rad-request");

      const isSameFlow =
        isPrescriptionFlow || isExamFlow || isRadFlow;

      const isLeavingTarget = !isToTarget && isFromTarget && !isSameFlow;
      let otherFacilityCd;
      let isOtherFacility;
      let selectedFacility;

      if (isLeavingTarget) {
        if (selectedFacilityCd !== null) {
          isOtherFacility = false;
          otherFacilityCd = this.getFacilityCd;
        } else {
          isOtherFacility = isOther;
          otherFacilityCd = isOther
            ? selectedFacilityCd
            : this.getFacilityCd;
        }
        selectedFacility = this.getFacilityCd;
      } else {
        if (isSameFlow) {
          this.setOtherFacilityInfo({
            isOtherFacility: this.getIsOtherFacility,
            otherFacilityCd: this.getOtherFacilityCd
          });
          this.selectPat({
            selectedPatId: this.selectedPatId,
            selectedFacility: this.getOtherFacilityCd
          });
          return;
        }
        isOtherFacility = isOther;
        otherFacilityCd = isOther
          ? selectedFacilityCd
          : this.getFacilityCd;

        selectedFacility = selectedFacilityCd;
      }

      this.setOtherFacilityInfo({
        isOtherFacility,
        otherFacilityCd
      });
      if (this.getPatientShareMode === 1) {
        selectedFacility = this.getOtherFacilityCd
      }
      if (to.name?.startsWith("pat-info-sharing-detail") || from.name?.startsWith("split-graph") || to.name?.startsWith("split-graph")) {
        selectedFacility = null;
      }
      this.selectPat({
        selectedPatId: this.selectedPatId,
        selectedFacility
      });
    },
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
    userMenuOpen(value) {
      this.userMenuPopoverVisible = value;
      this.$nextTick(() => {
        this.syncReportButtonDisabled();
        this.syncFabCompatDom();
        if (value) {
          this.moveSpeedDialItems();
          EventBus.$emit("closeFooterList");
        }
      });
    },
    /**
     * ウィンドウの高さが変更した時
     */
    windowHight() {
      if (this.userMenuOpen) {
        // メニューアイテムを再配置させるためメニューを閉じる
        this.closeUserMenu();
      }
    },
    selectedPat() {
      this.changePrintFlag();
    },
    canReport() {
      this.syncReportButtonDisabled();
    },
    // mod #12462 患者情報共有 関 start
    selectedPatId(newVal, oldVal) {
      this.refreshFacilityData();
      this.changePrintFlag();
      if (newVal && oldVal && newVal !== oldVal) {
        if (this.patientShareMode.editValue == 0 && this.selectedFacilityCd.editValue == null) {
          this.setOtherFacilityInfo({
            isOtherFacility: true,
            otherFacilityCd: null
          });
        }
        this.changeSelectedPatId = true;
        this.selectedFacilityCd.initValue = null;
        this.selectedFacilityCd.editValue = null;
        this.setPatientShareFacilityCdMode(null);
        this.refreshFacilityData();
      }
    },
    // mod #12462 患者情報共有 関 end
    isLockDevTool() {
      this.updatePerformanceMemory();
    },
  },
  methods: {
    publicAssetPath,
    onFooterLayoutChanged() {
      this.$nextTick(() => {
        this.syncFabCompatDom();
        if (this.userMenuOpen) {
          this.moveSpeedDialItems();
        }
      });
    },
    resolveFooterOffset() {
      return getFooterMenuClientHeight(this.$el || null);
    },
    getUserMenuRoot() {
      return getOnsSpeedDialElement(this.$refs.user_menu, this.$el, "#user-menu");
    },
    getUserMenuFabButton(menuRoot = this.getUserMenuRoot()) {
      return getOnsSpeedDialFabElement(menuRoot);
    },
    getUserMenuItemNodes(menuRoot = this.getUserMenuRoot()) {
      return getOnsSpeedDialItemElements(menuRoot);
    },
    getFabDocument() {
      return this.getUserMenuRoot()?.ownerDocument
        || this.$refs.manualPdfArea?.ownerDocument
        || this.$el?.ownerDocument
        || null;
    },
    getFabHead() {
      return this.getFabDocument()?.head || null;
    },
    getViewportMeta() {
      return Array.from(this.getFabHead()?.children || []).find((element) => {
        return element?.tagName === 'META' && element.getAttribute?.('name') === 'viewport';
      }) || null;
    },
    setViewportContent(content) {
      this.getViewportMeta()?.setAttribute('content', content);
    },
    getManualViewer(type = 'rems') {
      const manualRoot = this.$refs.manualPdfArea || null;
      if (type === 'fnsi') {
        return this.$refs.pdfContainerFnsi
          || manualRoot?.querySelector?.('#pdf-container-fnsi')
          || null;
      }
      return this.$refs.pdfContainer
        || manualRoot?.querySelector?.('#pdf-container')
        || null;
    },
    createManualImage(viewer, src) {
      const img = createScopedImageElement(viewer || this.$el || this);
      if (!img) {
        return null;
      }
      img.src = src;
      img.style.width = "100%";
      return img;
    },
    appendManualImage(viewer, src) {
      const img = this.createManualImage(viewer, src);
      if (img) {
        viewer?.appendChild?.(img);
      }
      return img;
    },
    getUserMenuPopoverElements() {
      const refs = ['userMenuPopover', 'fontSizePopover', 'themePopover', 'helpPopover', 'splitFramePopover', 'reportPopover']
        .map((name) => this.$refs[name]?.$el || this.$refs[name])
        .filter(Boolean);
      return refs.length > 0 ? refs : [];
    },
    syncFabCompatDom() {
      const menuRoot = this.getUserMenuRoot();
      if (!menuRoot) {
        return;
      }
      const footerOffset = this.resolveFooterOffset();
      menuRoot.setAttribute("data-ntss-fab-role", "user-menu");
      menuRoot.style.setProperty("--ntss-footer-offset", `${footerOffset}px`);
      const fab = getOnsSpeedDialFabElement(menuRoot);
      if (fab) {
        fab.setAttribute("data-ntss-fab-role", "fab-button");
        fab.classList.remove("ntss-user-fab-button");
      }
      menuRoot.classList.remove("ntss-user-fab-root");
      getOnsSpeedDialItemElements(menuRoot).forEach((item, index) => {
        item.setAttribute("data-ntss-fab-role", `fab-item-${index}`);
        item.classList.remove("ntss-user-fab-item");
      });
      menuRoot.querySelectorAll(".ntss-user-fab-icon").forEach((node) => {
        if (node.tagName !== "IMG") {
          node.classList.remove("ntss-user-fab-icon");
        }
      });
      getOnsSpeedDialIconElements(menuRoot).forEach((icon) => {
        icon.classList.add("ntss-user-fab-icon");
      });
    },
    getUserMenuItems() {
      const menuRoot = this.getUserMenuRoot();
      if (!menuRoot) {
        return [];
      }
      const fabButton = this.getUserMenuFabButton(menuRoot);
      const items = this.getUserMenuItemNodes(menuRoot);
      return fabButton ? [fabButton, ...items] : items;
    },
    resolvePopoverTarget(evt) {
      return getOnsSpeedDialEventTarget(evt);
    },
    getFabFooterOffset() {
      return getFooterMenuHeight({ isDispMenu: this.isDispMenu });
    },
//add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 start
    ...mapMutations("status-list/list", [
      "clearConditionTreatList"
    ]),
    ...mapMutations("status-map/map", [
      "clearConditionTreatMap"
    ]),
//add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 end
    ...mapActions("multi-modal", {
      // Fabメニューのうち、モーダル化したい画面は、MultiModalStoreとこのmapActionsに画面名の設定を行う
      showAccountEdit: "showAccountEdit",
      showMenuBarEdit: "showMenuBarEdit",
      showStaffFacility: "showStaffFacility",
      showPersonalSettings: "showPersonalSettings",
      showNotificationMessage: "showNotificationMessage",
      showReleaseInfo: "showReleaseInfo"
    }),
    ...mapActions("user", {
      userSignOut: "signOut"
    }),
    ...mapActions("account-edit", [
      "updateFontSize",
      "setFontSize",
      "updateTheme",
      "setTheme",
      "setIsSplitFrame",
      "updateIsSplitFrame",
      // mod #12462 患者情報共有 関 start
      "setPatientShareMode",
      "setPatientShareFacilityCdMode",
      "updatePatShareMode",
      // mod #12462 患者情報共有 関 end
      "clearUserAccountInfo"
    ]),
    ...mapActions("bread-crumb", ["resetKeepHistory"]),
    ...mapActions("toggle-dev-tool", ["lockDevTool", "unlockDevTool"]),
    ...mapActions("notification", ["setIsRegisteredNotificationFromDb"]),
    ...mapActions("operation-viewer/machine", ["clearFacilityCd"]),
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
    // mod FNSI-メニューに共有ON／共有OFFを追加する。 江 start
    // ...mapActions("mst-user", ["setIsRegisteredSharedFromDb"]),
    ...mapActions("mst-user", ["setIsRegisteredSharedFromDb","getIsRegisteredSharedFromDb"]),
    // mod FNSI-メニューに共有ON／共有OFFを追加する。 江 end
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end
    //FutreNetWeb+SI課題管理 no.6029 劉全航 start
    ...mapActions("notification-message", ["getNotificationMessageAll"]),
    //FutreNetWeb+SI課題管理 no.6029 劉全航 end
    //mod FNSI-6967 劉全航 start
    ...mapActions("pat-viewer",["setSelectedCondition"]),
    //mod FNSI-6967 劉全航 end
    // add 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start
    ...mapMutations("periodic-inspection", [
      "setStorSimlpSearchQurey",
    ]),
    // add 8436 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 end
    // add 8199 【デグレ】個人設定>定期点検の表示期間が適用されない 周安寧 start
    ...mapMutations("periodic-inspection",{ setperiodicinspection : "setSelectedCondition"}),
    // add 8199 【デグレ】個人設定>定期点検の表示期間が適用されない 周安寧 end
    ...mapActions("pat-info", ["selectPat"]),
    ...mapMutations("pat-info", {
      setOtherFacilityInfo: "setOtherFacilityInfo"
    }),
    // add FNSI-患者選択された状態 じょはく start
    changePrintFlag() {
      const hasSelectedPatient =
        (
          this.selectedPatId !== null &&
          this.selectedPatId !== undefined &&
          this.selectedPatId !== ""
        ) ||
        this.selectedPat !== null;
      this.printFlag = hasSelectedPatient ? 1 : 0;
      // add FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 start
      const funcCd = getCurrentFunctionCd();
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      if(!REPORT_FETCH_EXCLUDED_FUNC_CDS.includes(funcCd)){
        // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
        if (funcCd) {
          store.dispatch("report/getMstReport", {funcCd: funcCd, printFlag: this.printFlag}).catch(error => {
            getErrorMessage("FabComponent.vue", "changePrintFlag", error);
          });
        }
      }
      // add FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 end
    },
    // add FNSI-患者選択された状態 じょはく end

    /**
     * 初期処理.
     */
    init() {
      if (this.getUserMenuItems().length <= 2) {
        // メニューアイテムが１つ以下(fab除く)の場合処理しない
        return;
      }
      const menuRoot = this.getUserMenuRoot();
      if (!menuRoot) {
        return;
      }
      // fab以外を取得
      const items = this.getUserMenuItems().slice(1);
      const rootRect = menuRoot.getBoundingClientRect?.() || { top: 0, left: 0 };
      const firstRect = items[0].getBoundingClientRect?.() || { top: 0, left: 0, height: items[0].clientHeight, width: items[0].clientWidth };
      const secondRect = items[1].getBoundingClientRect?.() || firstRect;
      // アイコンサイズ取得
      this.itemHeight = firstRect.height || items[0].clientHeight;
      this.itemWidth = firstRect.width || items[0].clientWidth;
      // 一番左の一番上のアイコン位置を取得
      this.itemTop = Math.max(firstRect.top - rootRect.top, 0);
      this.itemLeft = firstRect.left - rootRect.left;
      // 余白を取得(アイテム同士のtop位置から算出)
      const top1 = firstRect.top - rootRect.top;
      const top2 = secondRect.top - rootRect.top;
      this.itemMargin = top2 - top1 - this.itemHeight;
    },
    /**
     * メニューアイコンの位置を調整する.
     */
    moveSpeedDialItems() {
      //add #9907 ユーザーフロートボタンメニューが画面から飛び出る zhangbo start
      // if (!this.userMenuOpen) {
      //   // ユーザメニュー非表示の場合は何もしない
      //   return;
      // }
      //add #9907 ユーザーフロートボタンメニューが画面から飛び出る zhangbo end
      const menuRoot = this.getUserMenuRoot();
      if (!menuRoot) {
        return;
      }
      // フッタメニュー除いた表示領域を取得
      let fmh = 5;
      if (this.isDispMenu === 1) {
        fmh = this.getFabFooterOffset() + 5;
      }
      const rootRect = menuRoot.getBoundingClientRect?.() || { top: 0 };
      const areaHeight = getViewportHeight() - fmh - rootRect.top;

      // Top,Leftの初期値設定
      let top = this.itemTop;
      let left = this.itemLeft - (this.itemWidth + this.itemMargin);

      // ウィンドウ外に位置する最初のアイテムを検索.
      const items = this.getUserMenuItems();
      let pos = items.findIndex((item) => {
        const bottom =
          Number((item.style.top || "0").replace("px", "")) +
          this.itemHeight +
          this.itemMargin;
        return areaHeight <= bottom;
      });

      if (pos < 0) {
        // ウィンドウ内に収まっている場合,２列目以降の再調整が可能か調べる
        pos = items.findIndex(
          (item) => Number((item.style.left || "0").replace("px", "")) < 0);
        if (pos < 0) {
          // 再調整不要
          return;
        }
        // 2列目の最初のメニューアイテムを１列目の最後尾に移動
        const item = items[pos];
        item.style.top =
          Number((items[pos - 1].style.top || "0").replace("px", "")) +
          this.itemHeight +
          this.itemMargin +
          "px";
        item.style.left = items[pos - 1].style.left;
        const bottom =
          Number((item.style.top || "0").replace("px", "")) + this.itemHeight;
        if (areaHeight > bottom) {
          // 移動後に収まっていれば次のアイテムから位置を調整とする
          pos++;
        }
      }

      // 外れたメニューアイテム以降を全て位置調整する
      for (let i = pos; i < items.length; i++) {
        const item = items[i];
        item.style.top = top + "px";
        item.style.left = left + "px";
        // 次の位置を算出
        top += this.itemHeight + this.itemMargin;
        const bottom = top + this.itemHeight + this.itemMargin;
        if (areaHeight <= bottom) {
          // さらにウィンドウの外になった場合は改行する
          top = this.itemTop;
          left -= this.itemWidth + this.itemMargin;
        }
      }
    },
    // ユーザーメニューボタン押下時のポップオーバー表示
    showUserMenuPopover(evt) {
      this.userMenuPopoverTarget = this.resolvePopoverTarget(evt);
      //add #9907 ユーザーフロートボタンメニューが画面から飛び出る zhangbo start
      // this.$nextTick(() => {
      //   this.moveSpeedDialItems();
      // });
      //add #9907 ユーザーフロートボタンメニューが画面から飛び出る zhangbo end
    },
    // Fab内のボタンのポップオーバー非表示
    hideItemPopover() {
      this.fontSizePopoverTarget = null;
      this.fontSizePopoverVisible = false;
      this.themePopoverTarget = null;
      this.themePopoverVisible = false;
      this.facilitiesPopoverTarget = null;
      this.facilitiesPopoverVisible = false;
      this.patientSharedPopoverTarget = null;
      this.patientSharedPopoverVisible = false;
      this.helpPopoverTarget = null;
      this.helpPopoverVisible = false;
      this.splitFramePopoverTarget = null;
      this.splitFramePopoverVisible = false;
      this.reportPopoverTarget = null;
      this.reportPopoverVisible = false;
    },
    getReportButtonElement() {
      const button = this.$refs.reportButton;
      return button?.$el || button || null;
    },
    syncReportButtonDisabled() {
      this.$nextTick(() => {
        const button = this.getReportButtonElement();
        if (!button) {
          return;
        }
        if (this.reportButtonDisabled) {
          button.disabled = true;
          button.setAttribute("disabled", "");
        } else {
          button.disabled = false;
          button.removeAttribute("disabled");
        }
      });
    },
    // Fab内ボタン押下時のポップオーバー表示
    showFabPopover(evt) {
      this.fontSizePopoverTarget = this.resolvePopoverTarget(evt);
      this.fontSizePopoverVisible = true;
    },
    // Fab内のテーマボタン押下時のポップオーバー表示
    showThemePopover(evt) {
      this.themePopoverTarget = this.resolvePopoverTarget(evt);
      this.themePopoverVisible = true;
    },
    // Fab内の施設切替ボタン押下時のポップオーバー表示
    showFacilitiesBtn(evt) {
      this.facilitiesPopoverTarget = this.resolvePopoverTarget(evt);
      this.facilitiesPopoverVisible = true;
    },
    // Fab内の患者共有ボタン押下時のポップオーバー表示
    showPatientSharedBtn(evt) {
      this.patientSharedPopoverTarget = this.resolvePopoverTarget(evt);
      this.patientSharedPopoverVisible = true;
      this.refreshFacilityData();
    },
    // Fab内ボタン押下時のポップオーバー表示
    showHelpPopover(evt) {
      this.helpPopoverTarget = this.resolvePopoverTarget(evt);
      this.helpPopoverVisible = true;
    },
    // Fab内の画面フレーム分割設定ボタン押下時のポップオーバー表示
    showSplitFramePopover(evt) {
      this.splitFramePopoverTarget = this.resolvePopoverTarget(evt);
      this.splitFramePopoverVisible = true;
    },
    // 印刷ダイアログ呼び出し
    showWindowPrintDialog() {
// add FNSI redmain_3937 指示受け・指示承認で画面印刷を行うとレイアウトが崩れる dou start
      // 画面印刷中のイベント発火 各画面ではこのイベントを拾って個別処理する
      EventBus.$emit('printing')
      EventBus.$emit('print-start')
// add FNSI redmain_3937 指示受け・指示承認で画面印刷を行うとレイアウトが崩れる dou end
      this.closeUserMenu();
      const ownerWindow = getScopedWindow(this.$el) || window;
      const interval = ownerWindow.setInterval(() => {
        const popoverList = this.getUserMenuPopoverElements();
        const isAllClosed = Array.from(popoverList).every(popover => (popover.style?.display || "none") === "none");
        if (isAllClosed) {
          ownerWindow.clearInterval(interval);
          ownerWindow.setTimeout(() => {
            ownerWindow.print();
            EventBus.$emit('print-end')
          }, 1000);
        }
      });
    },
    // Fab内の印刷ボタン押下時のポップオーバー表示
    showReportPopover(evt) {
      if (!this.canReport) {
        return;
      }
      this.reportPopoverTarget = this.resolvePopoverTarget(evt);
      this.reportPopoverVisible = true;
    },
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // ReMSヘルプページ(PDF)表示（別タブに表示）
    async showHelp() {
      if (this.device == "notMobile") {
        this.showHelpNotMobile(HELP_URL);
      } else {
        const viewer = this.getManualViewer('rems');
        this.setViewportContent('"width=device-width, initial-scale=1.0, user-scalable=yes');
        if (viewer.hasChildNodes()) {
          this.isShowManual = true;
          this.showManualType = "2";
        } else {
          // 初期表示なのでスクロール監視イベント付与
          viewer.addEventListener("scroll", this.scrollPdfContainer);

          // 画像ファイルのリストを取得
          var xhr = new XMLHttpRequest();
          await xhr.open("GET", MANUAL_LIST_URL);
          await xhr.send();
          xhr.onload = ()=> {
            var text = xhr.response;
            var arr = text.split(/\r\n|\r|\n/);
            for(var i = 0; i < arr.length; i++){
              if (arr[i] !== ""){
                this.lstManualImg.push(arr[i]);
              }
            }

            this.manualImgPageCnt = this.lstManualImg.length;
            // 読み込んだ画像をイメージとして書き出す(まずは5ページ分書き出し)
            for(let idx = 0; idx < 5; idx++){
              this.appendManualImage(viewer, MANUAL_DIR_URL + "/" + this.lstManualImg[idx]);
              this.dispManualPageCnt += 1;
            }
            this.isShowManual = true;
            this.showManualType = "2";
          };
        }
      }
    },
    // ReMSヘルプスクロール制御
    scrollPdfContainer(e) {
      const target = e.target;
      if((target.scrollHeight - (target.offsetHeight + target.scrollTop)) / target.scrollHeight <= 0){
        // スクロール最下部に来ていた場合最大2ページ分追加読込する
        if (this.dispManualPageCnt < this.manualImgPageCnt) {
          const viewer = this.getManualViewer('rems');
          for(let i = 0; i < 2; i++){
            this.appendManualImage(viewer, MANUAL_DIR_URL + "/" + this.lstManualImg[this.dispManualPageCnt]);
            this.dispManualPageCnt += 1;
            if (this.dispManualPageCnt === this.manualImgPageCnt){
              break;
            }
          }
        }
      }
    },

    // FNSiヘルプページ(PDF)表示（別タブに表示）
    async showHelpFnsi() {
      if (this.device == "notMobile") {
        this.showHelpNotMobile(FNSI_HELP_URL);
      } else {
        const viewer = this.getManualViewer('fnsi');
        this.setViewportContent('"width=device-width, initial-scale=1.0, user-scalable=yes');
        if (viewer.hasChildNodes()) {
          this.isShowManual = true;
          this.showManualType = "1";
        } else {
          // 初期表示なのでスクロール監視イベント付与
          viewer.addEventListener("scroll", this.scrollPdfContainerFnsi);

          // 画像ファイルのリストを取得
          var xhr = new XMLHttpRequest();
          await xhr.open("GET", FNSI_MANUAL_LIST_URL);
          await xhr.send();
          xhr.onload = ()=> {
            var text = xhr.response;
            var arr = text.split(/\r\n|\r|\n/);
            for(var i = 0; i < arr.length; i++){
              if (arr[i] !== ""){
                this.lstManualImgFnsi.push(arr[i]);
              }
            }

            this.manualImgPageCntFnsi = this.lstManualImgFnsi.length;
            // 読み込んだ画像をイメージとして書き出す(まずは5ページ分書き出し)
            for(let idx = 0; idx < 5; idx++){
              this.appendManualImage(viewer, FNSI_MANUAL_DIR_URL + "/" + this.lstManualImgFnsi[idx]);
              this.dispManualPageCntFnsi += 1;
            }
            this.isShowManual = true;
            this.showManualType = '1';
          };
        }
      }
    },
    //FNSiヘルプ スクロール制御
    scrollPdfContainerFnsi(e) {
      const target = e.target;
      if((target.scrollHeight - (target.offsetHeight + target.scrollTop)) / target.scrollHeight <= 0){
        // スクロール最下部に来ていた場合最大2ページ分追加読込する
        if (this.dispManualPageCntFnsi < this.manualImgPageCntFnsi) {
          const viewer = this.getManualViewer('fnsi');
          for(let i = 0; i < 2; i++){
            this.appendManualImage(viewer, FNSI_MANUAL_DIR_URL + "/" + this.lstManualImgFnsi[this.dispManualPageCntFnsi]);
            this.dispManualPageCntFnsi += 1;
            if (this.dispManualPageCntFnsi === this.manualImgPageCntFnsi){
              break;
            }
          }
        }
      }
    },
    // ヘルプページ(PDF)を閉じる
    closeManual() {
      this.setViewportContent('"width=device-width, initial-scale=1.0, user-scalable=no, maximum-scale=1.0');
      this.isShowManual = false;
      this.showManualType = null;
    },
    // サインアウト処理
    signOut() {
      // 確認のダイアログを表示する
      this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "サインアウト",
         title: DIALOG_MESSAGES[13000001].title,
        // message: "サインアウトします。<br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000001].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer == 1) {
            //OK
            // 利用者情報をクリアする
            this.clearUserInfo();
            // ログイン画面へ遷移
            // ※URLにパラメータが含まれている場合に書き変わらない為、
            // window.locationで遷移するように変更
            (getScopedWindow(this.$el) || window).location.href = this.url;
            // #8576 【デグレ】サインアウト後サインインすると強制サインアウトのメッセージが表示される dou start
            (getScopedWindow(this.$el) || window).location.reload();
            // #8576 【デグレ】サインアウト後サインインすると強制サインアウトのメッセージが表示される dou end
            // パンくずリストをクリア
            this.resetKeepHistory();
            // 施設コードをクリア
            this.clearFacilityCd();
            //mod FNSI-6967 劉全航 start
            this.clearPatViewerCondition();
            //mod FNSI-6967 劉全航 end
            //add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 start
            this.clearConditionTreatList();
            this.clearConditionTreatMap();
            //add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 end
            // add 8436 8199 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start
            this.clearCondition();
            // add 8436 8199 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 end
            /* modify by yangzhaokai 2022-11-07 #7756 サインアウトしてもデバッグモードから抜けない --start */
            this.lockDevTool()
            /* modify by yangzhaokai 2022-11-07 #7756 サインアウトしてもデバッグモードから抜けない --end */
          }
        }
      });
    },
    signOutAndExit() {
      // TODO: 体重計モードの終了処理
      // FNSI-add redmine4750 徐 start
      // this.$ons.notification.alert({
      //   title: "未実装",
      //   message: "体重計モードの終了処理を実装予定です",
      //   callback: this.signOut  // とりあえず通常のサインアウト関数を呼び出し
      //   });
      // 確認のダイアログを表示する
      this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // title: "",
        title: DIALOG_MESSAGES[13000002].title,
        // message: "体重計測定画面を閉じます。<br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000002].message),
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer == 1) {
          	// 利用者情報をクリアする
            this.clearUserInfo();
          	// 全画面を解除する
            (getScopedWindow(this.$el) || window).open('', '_blank').close();
            // 空白に遷移
            (getScopedWindow(this.$el) || window).open('about:blank', '_self');
          }
        }
      });
      // FNSI-add redmine4750 徐 end
    },

    /**
     * 利用者情報のクリア処理
     */
    clearUserInfo() {
      // storeに保持している利用者情報をクリア
      this.userSignOut();
      this.clearUserAccountInfo();
      this.setTheme(THEME_WHITE);
    },
    //mod FNSI-6967 劉全航 start
    //storeに保持している患者経過総合ビューアレイアウトデータをクリア
    clearPatViewerCondition(){
      this.setSelectedCondition(null);
    },
    //mod FNSI-6967 劉全航 end
    // add 8436 8199 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start
    clearCondition(){
      this.setStorSimlpSearchQurey(null);
      this.setperiodicinspection(null);
    },
    // add 8436 8199 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 end
    // 文字サイズ変更処理
    changeFontSize(newFontSize, oldFontSize) {
      this.setFontSize(newFontSize);
      const request = {
        userId: this.getStateUserAccountInfo.userId,
        fontSize: newFontSize
      };
      this.updateFontSize(request).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FabComponent.vue', 'clearUserInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end

        if (error.response.status === 400) {
          this.fontSizePopoverVisible = false;
          this.$ons.notification
            .alert({
              title: "更新に失敗しました。",
              message: error.response.data.errorMessage
            })
            .then(() => this.setFontSize(oldFontSize));
        }
      });
      // del #9717 施設カレンダーでサイドコンテンツの開閉の際に読み込みが走り表示に時間がかかる linjunfeng start
      // if (
      //   this.$route.name === "facility-calendar" &&
      //   (this.viewMode === 1 || this.viewMode === 2)
      //) {
      //   EventBus.$emit("updateViewCalendar", this.viewMode);
      // }
      // del #9717 施設カレンダーでサイドコンテンツの開閉の際に読み込みが走り表示に時間がかかる linjunfeng end
    },
    // テーマ変更処理
    changeTheme(newThemeBool, oldThemeBool) {
      // newTheme, oldThemeがtrue:1, false:0をセット
      var newTheme = newThemeBool ? THEME_BLACK : THEME_WHITE;
      var oldTheme = oldThemeBool ? THEME_BLACK : THEME_WHITE;

      this.setTheme(newTheme);
      const request = {
        userId: this.getStateUserAccountInfo.userId,
        theme: newTheme
      };
      // 更新処理呼び出し
      this.updateTheme(request).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FabComponent.vue', 'changeTheme', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        if (error.response.status === 400) {
          this.themePopoverVisible = false;
          this.$ons.notification
            .alert({
              title: "更新に失敗しました。",
              message: error.response.data.errorMessage
            })
            .then(() => this.setTheme(oldTheme));
        }
      });
    },
    // 画面フレーム分割変更処理
    changeSplitFrame(newValueBool, oldValueBool) {
      // newValue, oldValueにtrue:1, false:0をセット
      var newValue = newValueBool ? SPLIT_FRAME : NO_SPLIT_FRAME;
      var oldValue = oldValueBool ? SPLIT_FRAME : NO_SPLIT_FRAME;
      // Storeに格納
      this.setIsSplitFrame(newValue);
      const request = {
        userId: this.getStateUserAccountInfo.userId,
        isSplitFrame: newValue
      };
      // 更新処理呼び出し
      this.updateIsSplitFrame(request).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FabComponent.vue', 'changeSplitFrame', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        if (error.response.status === 400) {
          this.splitFramePopoverVisible = false;
          this.$ons.notification
            .alert({
              title: "更新に失敗しました。",
              message: error.response.data.errorMessage
            })
            .then(() => this.setIsSplitFrame(oldValue));
        }
      });
    },
    childSendCloseFN() {
      // メニューアイテムを再配置させるためメニューを閉じる
      this.closeUserMenu();
    },
    childSendHiddenFN(data) {
      this.checkDomClass = data.class;
    },
    // ユーザーメニューを閉じる
    closeUserMenu() {
      this.hideItemPopover();
      this.userMenuOpen = false;
    },
    toggleDevTool() {
      this.lockDevToolTimeout = (getScopedWindow(this.$el) || window).setTimeout(() => {
        // 171[左Ctrl]
        // 161[左shift]
        // 181[左Alt]
        if (
          !this.pressedKeys[161] ||
          !this.pressedKeys[171] ||
          !this.pressedKeys[181]
        ) {
          return;
        }

        this.isLockDevTool ? this.unlockDevTool() : this.lockDevTool();
      }, 5000);
    },
    cancelToggleDevTool() {
      (getScopedWindow(this.$el) || window).clearTimeout(this.lockDevToolTimeout);
    },
    // 通知をONにする
    async registerNotification() {
      // 端末固有IDを取得
      this.terminalUniqueString =
        getScopedLocalStorage(this.$el).getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);
      // 公開鍵
      let publicKey = null;
      // Subscription処理の戻り値
      let subscriptionObj = null;

      // [01] 鍵取得
      await ApiHelper.get( `/send-push/publicKey`)
      .then(response => {
        publicKey = response.data;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FabComponent.vue', 'registerNotification', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });

      // [02] Subscription
      await webPushSubscribe(publicKey, this.$el)
      .then(response => {
        subscriptionObj = response;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FabComponent.vue', 'registerNotification', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });

      // サブスクリプションエラー時、通知をOFFにする
      if (subscriptionObj === null) {
        this.unregisterNotification();
        return;
      }

      // サブスクリプション失敗時、処理を抜ける
      if (subscriptionObj === undefined) {
        return;
      }

      // [03] 端末固有IDの生成
      if (this.terminalUniqueString === null) {
        this.terminalUniqueString = new Date().getTime().toString(16) + Math.floor(1000 * Math.random()).toString(16);
        getScopedLocalStorage(this.$el).setItem('terminalUniqueString', this.terminalUniqueString);
      }

      // [04] 宛先情報をサーバに保存
      await saveNotificationList(
        this.getFacilityCd,
        this.getStateUserAccountInfo.userId,
        this.terminalUniqueString,
        subscriptionObj,
        this.$el
      );
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 start
      this.setIsRegisteredNotificationFromDb(this.terminalUniqueString);
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 end
    },
    // 通知をOFFにする
    async unregisterNotification() {
      // 端末固有IDを取得
      this.terminalUniqueString = getScopedLocalStorage(this.$el).getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);

      // ブラウザの通知解除(unSubscribe)
      (getScopedWindow(this.$el) || window).navigator.serviceWorker.ready.then(function(reg) {
        reg.pushManager.getSubscription().then(function(subscription) {
          subscription.unsubscribe();
        })
      });

      if (this.terminalUniqueString !== null) {
        // 施設コード、ログイン者のIDに該当する送信先を削除する
        await ApiHelper.put(`/send-push/pushDelete/${this.terminalUniqueString}`)
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('FabComponent.vue', 'unregisterNotification', error);
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          throw error;
        });
      }
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 start
      this.setIsRegisteredNotificationFromDb(this.terminalUniqueString);
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 end
    },
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
    // 共有をONにする
    async registerShared() {
      this.userSharedData.userId = this.getStateUserAccountInfo.userId;
      this.userSharedData.patientShared = 1;

      this.setIsRegisteredSharedFromDb(this.userSharedData);
    },
    // 共有をOFFにする
    async unregisterShared() {
      this.userSharedData.userId = this.getStateUserAccountInfo.userId;
      this.userSharedData.patientShared = 0;

      this.setIsRegisteredSharedFromDb(this.userSharedData);
    },
    // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end
    // 通知が使えるかどうか（通知設定：許可 and ブラウザが通知対応）
    isAvailableNotification() {
      const ownerWindow = getScopedWindow(this.$el) || window;
      if ("Notification" in ownerWindow === false) {
        return false;
      }
      return ownerWindow.Notification.permission === "granted";
    },
    // 通知無効時のメッセージ
    unavailableMessage() {
      if (this.device == "iOS") {
        this.messageDialogInfo.messageCd = 23030005;
        this.messageDialogInfo.title = DIALOG_MESSAGES['23030005'].title;
      } else {
        this.messageDialogInfo.messageCd = 23030001;
        this.messageDialogInfo.title = DIALOG_MESSAGES['23030001'].title;
      }
      this.messageDialogInfo.stringParams = [];
      this.messageDialogInfo.type = "1";
      this.messageDialogInfo.isDialogVisible = true;
    },
    updatePerformanceMemory() {
      if (this.isLockDevTool || !this.performanceMemory) return;
      Object.keys(this.performanceMemory).forEach(key => {
        this.performanceMemory[key] = `${Math.floor(performance.memory[key] / 1048576)} MB`;
      });
      setTimeout(() => {
        this.updatePerformanceMemory();
      }, 500);
    },
    onFountSizeChange(){
      setTimeout(()=>{
        EventBus.$emit("onResize");
      },0)
    },
    /**
     * 他施設取得
     */
    async refreshFacilityData() {
      if (!this.selectedPatId) {
        let options = [];
        options.unshift({
          value: null,
          displayValue: "マージ表示"
        });
        this.facilityOptions = options;
        return;
      }
      try {
        const response = await ApiHelper.get(
          `/patInfo/getPatHospitalById/${this.selectedPatId}`
        );
        const options = response.data.map(item => ({
          value: item.facilityCd,
          displayValue: item.facilityName
        }));

        options.unshift({
          value: null,
          displayValue: "マージ表示"
        });

        this.facilityOptions = options;
        if (
          this.facilityOptions.length == 1 &&
          this.facilityOptions[0].value == null &&
          this.patientShareMode.editValue !== 1
        ) {
          this.selectedFacilityCd.initValue = null;
          this.selectedFacilityCd.editValue = null;
          this.setPatientShareFacilityCdMode(null);
          this.setOtherFacilityInfo({
            isOtherFacility: null,
            otherFacilityCd: null
          });
        }

      } catch (error) {
        getErrorMessage("FabComponent.vue.vue", "refreshFacilityData", error);
        throw error;
      }
    },
    // mod #12462 患者情報共有 20260330 start
    changePatientShareMode(val) {
      const oldPatientShareMode = this.patientShareMode.initValue;
      this.patientShareMode.editValue = val;
      this.patientShareMode.initValue = val;
      this.setPatientShareMode(val);
      const request = {
        userId: this.getStateUserAccountInfo.userId,
        patShareMode: val
      };
      this.updatePatShareMode(request).catch(error => {
        getErrorMessage('FabComponent.vue', 'changePatientShareMode', error);

        if (error.response.status === 400) {
          this.fontSizePopoverVisible = false;
          this.setPatientShareMode(oldPatientShareMode);
          this.patientShareMode.editValue = oldPatientShareMode;
          this.patientShareMode.initValue = oldPatientShareMode;
          this.$ons.notification
            .alert({
              title: "更新に失敗しました。",
              message: error.response.data.errorMessage
            })
        }
      });
      let facilityCd;
      if (val === 1) {
        // 自施設
        facilityCd = this.getFacilityCd;
        this.setOtherFacilityInfo({
          isOtherFacility: false,
          otherFacilityCd: null
        });
      } else {
        // 他施設
        facilityCd = this.selectedFacilityCd.editValue;
        const isOther = facilityCd && facilityCd !== this.getFacilityCd;
        this.setOtherFacilityInfo({
          isOtherFacility: isOther,
          otherFacilityCd: facilityCd
        });
      }
      const isTargetScreen =
        this.$route.name === "pat-info" ||
        this.$route.name === "deviceset-info";
      if (!isTargetScreen && facilityCd !== null) {
        facilityCd = this.getFacilityCd;
      }
      this.selectPat({
        selectedPatId: this.selectedPatId,
        selectedFacility: facilityCd
      });

      if (this.$route.name === "pat-event" || this.$route.name === "pat-intro-letter") {
        EventBus.$emit("refreshPatEventList");
      }
      if (this.$route.name === "observe-record") {
        EventBus.$emit("refreshObserveList");
      }
    },
    changePatientShareFacilityCdMode(val) {
      this.selectedFacilityCd.editValue = val;
      this.selectedFacilityCd.initValue = val
      this.selectedFacilityCdCache = val
      this.setPatientShareFacilityCdMode(val);
      let facilityCd = val;
      const isTargetScreen =
        this.$route.name === "pat-info" ||
        this.$route.name === "deviceset-info";
      let isOther = val && val !== this.getFacilityCd;
      if (!isTargetScreen) {
        if (this.selectedFacilityCd.editValue == null) {
          isOther = true;
          facilityCd = val;
        } else {
          isOther = false;
          facilityCd = this.getFacilityCd;
        }
      }
      this.setOtherFacilityInfo({
        isOtherFacility: isOther,
        otherFacilityCd: facilityCd
      });
      this.selectPat({
        selectedPatId: this.selectedPatId,
        selectedFacility: facilityCd
      });

      // add #12462 患者情報共有 20260330 start
      if (
        this.$route.name === "pat-event" ||
        this.$route.name === "pat-intro-letter"
      ) {
        EventBus.$emit("refreshPatEventList");
      }

      if (this.$route.name === "observe-record") {
        EventBus.$emit("refreshObserveList");
      }
      // add #12462 患者情報共有 20260330 end
    },
    // mod #12462 患者情報共有 20260330 end
    //操作マニュアルの表示
    showHelpNotMobile(url){
      const FAVICON_URL = {
        0: "/ntss-admin-web/img/login/NIKKISO.ico",
        1: "/ntss-admin-web/img/login/NIKKISO.ico",  // ReMS
        2: "/ntss-admin-web/img/login/favicon.ico",  // FNSi
        3: "/ntss-admin-web/img/login/favicon.ico"  // FNSi＋ReMS
      };
      //システム利用設定の取得
      let systemUseSetting = this.getSystemUseSetting != null ? this.getSystemUseSetting : 0;
      //favicon.icoのURLの設定
      getScopedLocalStorage(this.$el).setItem("faviconURL", FAVICON_URL[systemUseSetting]);
      const helpWindow = (getScopedWindow(this.$el) || window).open("about:blank");
      if (helpWindow) {
        helpWindow.location.href = url;
      }
    }
  },
  async created() {
    this.updatePerformanceMemory();
    // add FNSI-患者選択された状態 じょはく start

    // add FNSI-患者選択された状態 じょはく end
    // add 性能改善メモリ不足 shan start
    EventBus.$off("closeUserMenu", this.closeUserMenu);
    EventBus.$off("footerLayoutChanged", this.onFooterLayoutChanged);
    EventBus.$on("closeUserMenu", this.closeUserMenu);
    EventBus.$on("footerLayoutChanged", this.onFooterLayoutChanged);
    // add 性能改善メモリ不足 shan end
    // 端末判別
    const ua = getScopedUserAgent(this.$el);
    if (ua.match(/iPhone|iPad/)) {
      this.device = "iOS";
    } else if (!ua.match(/Android/)) {
      this.device = "notMobile";
    }
    // add FNSI-メニューに共有ON／共有OFFを追加する。 江 start
    this.getIsRegisteredSharedFromDb(this.getStateUserAccountInfo)
    // add FNSI-メニューに共有ON／共有OFFを追加する。 江 end

    getMstFacilitySettingValue(this.getStateUserAccountInfo.facilityCd, PASSWORD_VALIDITY_PERIOD)
      .then(response => {
        this.passwordValidityPeriod = response.data;
      });
    //FutreNetWeb+SI課題管理 no.6029 劉全航 start
    await this.getNotificationMessageAll(0);
    //FutreNetWeb+SI課題管理 no.6029 劉全航 end

    // mod #12462 患者情報共有 関 start
    this.patientShareMode.initValue = "1";
    this.patientShareMode.editValue = "1";
    // mod #12462 患者情報共有 関 end
    this.changePatientShareMode(1)
  },
  mounted() {
    this.changePrintFlag();
    this.$nextTick(() => {
      this.syncReportButtonDisabled();
      this.init();
      this.syncFabCompatDom();
    });
    //Service Workerの登録
    if (this.device == "notMobile" && 'serviceWorker' in navigator) {
      navigator.serviceWorker.register('/ntss-admin-web/app-file.js', {scope: '/ntss-admin-web/help/'})
      .catch((e) => console.error(e));
    }
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    this.patientShareMode.initValue = "1";
    this.patientShareMode.editValue = "1";
    this.changePatientShareMode(1)
    EventBus.$off("closeUserMenu", this.closeUserMenu);
    EventBus.$off("footerLayoutChanged", this.onFooterLayoutChanged);
    //Service Workerの登録解除
    if (this.device == "notMobile" && 'serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(registrations => {
        registrations.forEach(reg => {
          const sw = reg.active;
          if (!sw) return;
          if (sw.scriptURL.endsWith('/app-file.js')) {
            reg.unregister()
            .catch((e) => console.error(e));
          }
        });
      });
    }
  }
};
</script>

<style scoped>
.dev-tool-unlocked :deep(ons-speed-dial ons-fab ons-icon) {
  background-color: var(--emergency-background-color);
}
.button {
  width: 80%;
}
#user-menu {
  top: 5px;
  right: 5px;
}
ons-speed-dial .ons-icon {
  font-size: 11pt;
  font-weight: normal;
  display: block;
}
ons-speed-dial .fab__icon,
ons-speed-dial ons-fab .fab__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
}
ons-speed-dial .fab__icon .ons-icon,
ons-speed-dial ons-fab .fab__icon .ons-icon,
ons-speed-dial ons-fab ons-icon.fa-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  margin: 0;
  text-align: center;
  line-height: 1;
}
/* fix 2026/06/09 Safari FABユーザ名大文字化 fa-icon誤適用 start */
ons-speed-dial ons-fab ons-icon.fa-icon {
  font-family: inherit;
  text-transform: none;
}
/* fix 2026/06/09 Safari FABユーザ名大文字化 fa-icon誤適用 end */
#user-menu :deep(ons-speed-dial-item.speed-dial__item > .ons-icon),
#user-menu :deep(ons-speed-dial-item.speed-dial__item > ons-icon) {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  box-sizing: border-box;
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
  text-align: center;
  line-height: 1;
  transform: none;
}
#user-menu :deep(ons-speed-dial-item.speed-dial__item .ntss-fab-icon) {
  display: block;
  flex: 0 0 auto;
  margin: 5px auto 0;
  vertical-align: top;
}
ons-speed-dial .fab {
  box-shadow: 0 4px 4px 0 rgba(0, 0, 0, 0.12);
  background-color: #0076ff;
  color: #ffffff;
  background-image: -webkit-linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  box-shadow: 0 2px 2px 0 rgba(0, 0, 0, 0.12), 0 4px 2px 0 rgba(0,0,0,.24);
}

.range {
  width: 80%;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}
.popover-label {
  margin-left: 5%;
  margin-top: 5%;
}

.facilitesBox :deep(.popover__content) {
  width: 300px;
  max-height: 500px;
  overflow-y: auto;
}

.facilitesBox :deep(.card-header) {
  padding-left: 12px;
}

.facilitesBox :deep(.card-header-button-area) {
  position: absolute;
  right: 0;
  margin: 1px 10px 0 0;
}

#needHidden :deep(.popover) {
  z-index: 2000;
}

.switch {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}
/* Fabメニューのアイコンのスタイル定義 */
.ntss-fab-icon {
  margin-top: 5px;
  height: 30px;
  width: 30px;
}
/* PDFのスタイル定義 */
#manualPdfArea {
  width: 100vw;
  height: 100vh;
  top: 0;
  right: 0;
  z-index: 10002;
  display: block;
  position: absolute;
  background-color: white;
}
.manual-close-btn {
  position: absolute;
  top: 15px;
  right: 10px;
  font-size: 30px;
  z-index: 10003;
  height: auto;
}
.manual-download-btn {
  float: right;
  position: absolute;
  top: 15px;
  right: 60px;
  font-size: 30px;
}
.manual-not-download {
  float: right;
  position: absolute;
  top: 26px;
  right: 60px;
  font-size: 15px;
  color: #999999;
}
/* ヘルプメニュー：一体型カード（取扱説明書／リリース情報） */
/* Onsen 既定の .popover__content は width:220px + overflow:auto のため横スクロールが出やすい → 上書き */
.popover-help :deep(.popover__content) {
  padding: 0;
  background: transparent;
  width: auto !important;
  min-width: 0;
  max-width: min(94vw, 360px);
  min-height: 0 !important;
  overflow-x: hidden !important;
  overflow-y: visible;
}

.popover-help-panel {
  width: 100%;
  box-sizing: border-box;
  min-width: 260px;
  max-width: min(92vw, 320px);
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.12);
  background: #ffffff;
}

.popover-help :deep(ons-list.popover-help-list) {
  margin: 0;
  width: 100%;
  box-sizing: border-box;
  background: transparent;
  background-image: none;
  overflow-x: hidden;
}

.popover-help :deep(ons-list-header.popover-help-header) {
  display: block;
  width: 100%;
  box-sizing: border-box;
  background: #333333;
  background-image: none;
  border: none;
  box-shadow: none;
  color: #ffffff;
  font-weight: 600;
  font-size: 0.95em;
  min-height: auto;
  line-height: 1.4;
  padding: 0.65em 0.95em;
  text-transform: none;
  text-align: left;
}

.popover-help :deep(ons-list-header.popover-help-header:first-of-type) {
  border-radius: 8px 8px 0 0;
}

.popover-help :deep(ons-list-header.popover-help-header--section) {
  margin-top: 0;
}

.popover-help :deep(ons-list-item.popover-help-item) {
  width: 100%;
  box-sizing: border-box;
  color: var(--all-label-color, #212121) !important;
  background: #ffffff;
  background-image: none;
  border-bottom: 1px solid #e8e8e8;
  min-height: auto;
}

.popover-help :deep(ons-list-item.popover-help-item.list-item) {
  padding-left: 0;
  padding-right: 0;
}

.popover-help :deep(ons-list-item.popover-help-item:last-of-type) {
  border-bottom: none;
  border-radius: 0 0 8px 8px;
}

.popover-help :deep(ons-list-item.popover-help-item .list-item__center) {
  padding: 0.65em 0.95em;
  white-space: normal;
  word-break: break-word;
  min-width: 0;
}

.popover-help :deep(ons-list-item.popover-help-item:active) {
  background: #f3f3f3;
}
/*mod FNSI-モーダル表示中だとユーザーフロートを表に出す 徐博 start*/
#user-menu {
  /*z-index: 100;*/
  z-index: 9999;
}
/*mod FNSI-モーダル表示中だとユーザーフロートを表に出す 徐博 end*/
.control-z-index {
  z-index: 10002;
}
/*mod FNSI-モーダル表示中だとユーザーフロートを表に出す 徐博 start*/
#user-menu-popover :deep(.popover-mask) {
  /*z-index: 99;*/
  z-index: 9998;
}
/*mod FNSI-モーダル表示中だとユーザーフロートを表に出す 徐博 end*/
#user-menu-popover :deep(.popover) {
  display: none;
}
.user-menu-item-popover :deep(.popover-mask) {
  display: none;
}
#hideText {
  -moz-animation: cssAnimation 0s ease-in 5s forwards;
  /* Firefox */
  -webkit-animation: cssAnimation 0s ease-in 5s forwards;
  /* Safari and Chrome */
  -o-animation: cssAnimation 0s ease-in 5s forwards;
  /* Opera */
  animation: cssAnimation 0s ease-in 5s forwards;
  -webkit-animation-fill-mode: forwards;
  animation-fill-mode: forwards;
}
@keyframes cssAnimation {
  to {
    width: 0;
    height: 0;
    overflow: hidden;
  }
}
@-webkit-keyframes cssAnimation {
  to {
    width: 0;
    height: 0;
    visibility: hidden;
  }
}
/*mod FNSI-モーダル表示中だとユーザーフロートを表に出す 徐博 start*/
.unread-count {
  position: absolute;
  top: 0;
  right: 0;
  margin: 2px;
  /*z-index: 101;*/
  z-index: 10000;
}
/*mod FNSI-モーダル表示中だとユーザーフロートを表に出す 徐博 end*/
.theme :deep(.popover__content) {
  min-height: 120px;
}

.memory-display {
  position: relative;
  top: -16px;
  z-index: 20001;
  background-color: white;
  color: blue;
  opacity: 0.7;
  font-size: 10px;
  width: 56px;
  text-align: center;
  white-space: pre-wrap;
}

@media print {
  /** 1枚に収める */
  ons-speed-dial-item.speed-dial__item {
    display: none;
  }
}
/* mod #12462 患者情報共有 関 start */
.radio-center-group {
  display: flex;
  flex-direction: column;
  padding-left: 12px;
  padding-top: 12px;
  gap: 8px;
}

.radio-item {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

.input-style {
  width: 150px;
}

.warning-msg {
  margin-top: 6px;
}

.msg {
  color: red;
  font-size: 12px;
  line-height: 1.4;
}

.msg-wrapper {
  width: 100%;
}

/* mod #12462 患者情報共有 関 end */
</style>
