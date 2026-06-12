<template>
  <div class="menu-bar">
    <div
      id="menu-bar-id"
      class="menu-bar-contents button-size block"
      :style="{ 'height': menuBarHeight + 'px' }"
    >
      <!--患者情報共有使う-->
      <v-ons-select
        v-model="seletedfacilityCd"
        class="facilitylist"
        v-show="false"
        @change="changeFacility(seletedfacilityCd)"
      >
        <option
          v-for="facility in mstFacility"
          :value="facility.facilityCd"
          :key="facility.facilityCd"
        >
          {{ `${facility.facilityName}` }}
        </option>
      </v-ons-select>
      <ons-button
        id="open"
        class="btn3-normal"
        @click="openAllCard()"
      >
        OPEN
      </ons-button>
      <ons-button
        id="close"
        class="btn3-normal"
        @click="closeAllCard()"
      >
        CLOSE
      </ons-button>
      <ons-button
        id="basicInfoCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.basicInfoCard)"
      >
        本人情報
      </ons-button>
      <ons-button
        id="otherContactCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.otherContactCard)"
      >
        連絡先
      </ons-button>
      <ons-button
        id="vendorContactCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.vendorContactCard)"
      >
        サービス業者
      </ons-button>
      <ons-button
        id="patMemoCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.patMemoCard)"
      >
        患者メモ
      </ons-button>
      <ons-button
        v-show="isShowInsurance && !isCreationPat"
        id="insuranceInfoCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.insuranceInfoCard)"
      >
        保険情報
      </ons-button>
      <ons-button
        id="difficultySeverityTransportCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.difficultySeverityTransportCard)"
      >
        困難・搬送
      </ons-button>
      <ons-button
        id="medicalCareInfoCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.medicalCareInfoCard)"
      >
        診療
      </ons-button>
      <ons-button
        id="chargeStaffCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.chargeStaffCard)"
      >
        担当情報
      </ons-button>
      <ons-button
        id="tabooAllergyCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.tabooAllergyCard)"
      >
        禁忌ｱﾚﾙｷﾞｰ
      </ons-button>
      <ons-button
        id="infectionCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.infectionCard)"
      >
        感染症
      </ons-button>
      <ons-button
        id="implantCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.implantCard)"
      >
        ｲﾝﾌﾟﾗﾝﾄ
      </ons-button>
      <ons-button
        id="medicalHstCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.medicalHstCard)"
      >
        既往歴
      </ons-button>
      <ons-button
        id="visitHstCard"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.visitHstCard)"
      >
        入外転入出
      </ons-button>
      <ons-button
        v-show="!isCreationPat"
        id="physicalInfoCard"
        :class="(isHomeDialysisPat && enableHomeDialysis) || isShowPatGroup? 'btn3-normal' : 'last-element-bottom btn3-normal'"
        @click="toggleClosingCardToShowing(cardComponents.physicalInfoCard)"
      >
        身体情報
      </ons-button>
      <ons-button
        v-show="isHomeDialysisPat && enableHomeDialysis"
        id="remoteMonitorCard"
        :class="(isHomeDialysisPat && enableHomeDialysis) && !isShowPatGroup ? 'last-element-bottom btn3-normal' : 'btn3-normal'"
        @click="toggleClosingCardToShowing(cardComponents.remoteMonitorCard)"
      >
        遠隔
      </ons-button>
      <ons-button
        v-show="isShowPatGroup"
        id="patGroupCard"
        :class="isShowPatGroup ? 'btn3-normal' : 'last-element-bottom btn3-normal'"
        @click="toggleClosingCardToShowing(cardComponents.patGroupCard)"
      >
        患者ｸﾞﾙｰﾌﾟ
      </ons-button>
      <ons-button
        v-show="isShowAdditionInfo"
        id="additionSetting"
        class="btn3-normal"
        @click="toggleClosingCardToShowing(cardComponents.additionSettingCard)"
      >
        加算管理料
      </ons-button>
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <ons-button -->
      <!--   v-show="!isCreationPat && isCardDeviceConnected" -->
      <!--   id="createCard" -->
      <!--   :class="(isHomeDialysisPat && enableHomeDialysis) || isShowPatGroup? 'btn3-normal' : 'last-element-bottom btn3-normal'" -->
      <!--   @click="createCard()" -->
      <!-- > -->
      <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
      <!-- <ons-button -->
      <!--   v-show="!isCreationPat && isCardDeviceConnected && getItemAuthorized('PatInfo', 'item_createCard_btn')" -->
      <!--   id="createCard" -->
      <!--   :class="(isHomeDialysisPat && enableHomeDialysis) || isShowPatGroup? 'btn3-normal' : 'last-element-bottom btn3-normal'" -->
      <!--   @click="createCard()" -->
      <!-- > -->
      <ons-button
        v-show="!isCreationPat && isCardDeviceConnected"
        :disabled="!getItemAuthorized('PatInfo', 'item_createCard_btn')"
        id="createCard"
        :class="(isHomeDialysisPat && enableHomeDialysis) || isShowPatGroup? 'btn3-normal' : 'last-element-bottom btn3-normal'"
        @click="createCard()"
      >
      <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
        カード作成
      </ons-button>
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <ons-button -->
      <!--   v-show="!isCreationPat && isShowPatientCapture" -->
      <!--   class="btn1-execute" -->
      <!--   :disabled="this.editFlag" -->
      <!--   @click="getInputId" -->
      <!-- > -->
      <ons-button
        v-show="!isCreationPat && isShowPatientCapture"
        class="btn1-execute"
        :disabled="this.editFlag || !getItemAuthorized('PatInfo', 'default_authority')"
        @click="getInputId"
      >
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
        患者取込
      </ons-button>
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <ons-button -->
      <!--   v-if="isShowDeletePat" -->
      <!--   class="delete-button btn4-alert" -->
      <!--   @click="deletePat()" -->
      <!-- > -->
      <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
      <!-- <ons-button -->
      <!--   v-if="isShowDeletePat && getItemAuthorized('PatInfo', 'item_delete_btn')" -->
      <!--   class="delete-button btn4-alert" -->
      <!--   @click="deletePat()" -->
      <!-- > -->
      <ons-button
        v-if="!isCreationPat"
        :style="{ 'opacity': this.getItemAuthorized('PatInfo', 'item_delete_btn') ? 1 : 0.6}"
        class="delete-button btn4-alert"
        @click="deletePat()"
      >
      <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
        患者削除
      </ons-button>
    </div>
  </div>
</template>

<script>
// add 10436#10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { FUNC_PAT_GROUP, FUNC_PAT_INFO } from "@/constants/function-code";
import {ADVANCED_SETTINGS} from "@/constants/advancedSettings";
import {createJournal} from "@/apis/journal";
import dayjs from "@/compat/date/dayjs";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getFooterMenuElement, getContentContainerElement, getPatInfoHeaderAreaElement, getPatHeaderElement, getRightExeButtonElement, getScopedElementById, getScopedElementsByClassName, queryScopedSelector } from "@/functions/common/LayoutMeasureHelper";
import { MENU_BAR } from "@/components/pat-info/PatInfoConfig.js";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 start
import { EventBus } from "@/compat/vue/event-bus.js";
// add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 end

export default {
  inject: {
    getNtssLayoutRootElement: { default: null },
    getNtssFooterMenuElement: { default: null }
  },
  mixins: [ComponentGuardMixin],
  props: {
    cardComponents: { required: true },
    historyKey: null,
    // 新規登録フラグ
    isCreationPat: { type: Boolean, default: false },
    headerClick: { type: Boolean, default: false },
  },
  computed: {
    ...mapGetters("window-size", { windowHeight: "getWindowHeight" }),
    ...mapGetters("account-edit", ["getTheme", "getFontSize","getStateUserAccountInfo","getUseFunctions", "isDispMenu"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd", advancedSettings: "getAdvancedSettings" }),
    // mod 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 start
    // ...mapGetters("pat-info", ["selectedPatId", "isHomeDialysisPat", "searchedPatList", "srcFuncName",
    //   "treatmentPatList", "selectedPat", "mstFacility", "isNewPatPage" ]),
    ...mapGetters("pat-info", ["selectedPatId", "isHomeDialysisPat", "searchedPatList", "srcFuncName",
      "treatmentPatList", "selectedPat", "mstFacility", "isNewPatPage", "getSortPatInfo"]),
    // mod 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 end
    ...mapGetters("facility", ["useFunction"]),
    ...mapGetters("websocket-card", ["getSocketIsConnected", "getSocketMessages", "getCardDeviceStatus"]),
    isShowPatGroup() {
      // mod #10371 使用許可機能権限OFF時に動作不正 20240528 ztc start
      // return this.useFunction.includes(FUNC_PAT_GROUP);
      return this.useFunction.includes(FUNC_PAT_GROUP) && this.getAuthorizedFunctions().includes(FUNC_PAT_GROUP);
      // mod #10371 使用許可機能権限OFF時に動作不正 20240528 ztc end
    },
    isShowInsurance() {
      if (!this.advancedSettings.func_advcds) {
        return false;
      }
      return this.advancedSettings.func_advcds.some(setting => setting.func_advcd === ADVANCED_SETTINGS.INSURANCE_INFO);
    },
    enableHomeDialysis() {
      if (!this.advancedSettings.func_advcds) {
        return false;
      }
      return this.advancedSettings.func_advcds.some(setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS);
    },
    isShowPatientCapture() {
      if (!this.advancedSettings.func_advcds) {
        return false;
      }
      return this.advancedSettings.func_advcds.some(setting => setting.func_advcd === ADVANCED_SETTINGS.PATIENT_CAPTURE_BUTTON);
    },
    isShowAdditionInfo() {
      if (!this.advancedSettings.func_advcds) {
        return false;
      }
      return this.advancedSettings.func_advcds.some(setting => setting.func_advcd === ADVANCED_SETTINGS.ADDITION_INFO);
    }
  },
  data() {
    return {
      clickTrue: false,
      menuBarVisble: false,
      isDeletePatWarning: false,
      authorityCds: [AUTHORITY_CODES.DEL_PAT],
      // インターバルID
      intervalId: undefined,
      editFlag: null,
      isCardDeviceConnected: false,
      socketInterval: null,
      menuBarHeight: 300,
      tmpObserver: null,
      seletedfacilityCd: '',
      cardData: [
        "basicInfoCard",
        "otherContactCard",
        "vendorContactCard",
        "patMemoCard",
        "insuranceInfoCard",
        "difficultySeverityTransportCard",
        "medicalCareInfoCard",
        "chargeStaffCard",
        "tabooAllergyCard",
        "infectionCard",
        "implantCard",
        "medicalHstCard",
        "visitHstCard",
        "physicalInfoCard",
        "remoteMonitorCard",
        "createCard",
        "patGroupCard",
        "additionSetting"
      ],
      headerData: [
        "basic-info-card-content",
        "other-contact-card-content",
        "vendor-contact-card-contents",
        "pat-memo-card-contents",
        "insurance-info-card",
        "difficulty-severity-transport-card-content",
        "medical-care-info-card-content",
        "charge-staff-card-content",
        "taboo-allergy-card-content",
        "infection-card-contents",
        "implant-card-content",
        "medical-hst-card-content",
        "visit-hst-card-content",
        "physical-info-card-contents",
        "remote-monitor-card-content",
        "pat-group-card-content",
        "addition-setting-card-content"
      ]
    };
  },
  mounted() {
    // メニューサイズが各デバイスの画面サイズに合わせるため、ダイナミック変化
    let ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toUpperCase();
    let isIpad = false;
    let isIphone = false;
    let isPc = true;
    if (ua.indexOf('ANDROID') != -1 || ua.indexOf('MOBILE') != -1) {
      isPc = false;
    }
    if (ua.indexOf('IPAD') != -1) {
      isIpad = true;
      isPc = false;
    }
    if (ua.indexOf('IPHONE') != -1) {
      isIphone = true;
      isPc = false;
    }
    // 展開ボタンを少し下す
    if (isIphone) {
      const isIphoneObj = this.getPatInfoElementById('menu-bar-trigger-id');
      if (isIphoneObj) {
        isIphoneObj?.classList?.add("ios-margin-bottom");
      }
    }
    this.intervalId = setInterval(() => {
      if (isPc || isIpad) {
        const menuBar = this.getPatInfoElementById('menu-bar-id');
        if (menuBar) {
          menuBar.style.overflow = "scroll";
        }
      }
    }, 1000);
    // ResizeObserverの設定
    const headerObj = getScopedElementsByClassName("header", this.getPatInfoLayoutRoot());
    if (headerObj.length > 0) {
      let tmpThis = this;
      this.tmpObserver = new ResizeObserver((entries) => {
        tmpThis.resizeHeight();
      });
      // 監視を開始
      this.tmpObserver.observe(headerObj[0]);
    }
  },
  async created() {
    let isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    // mod #10359 編集権限の動作不正 dengshen start
    // let isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    // this.editFlag = !(isPatViewAuthorized && isPatEditAuthorized);
    this.editFlag = !isPatViewAuthorized;
    // mod #10359 編集権限の動作不正 dengshen end
    if (this.$route.name === "pat-info") {
      if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
        // card appのwebsokcet以外場合、接続したサービスを閉じました
        if (this.getSocketIsConnected) {
          this.close();
          await SleepNSeconds(100);
        }
        // 遅延のミリ秒(millisecond)
        let delayMillisecond = 1000;
        // localStorageのportを利用する
        let defaultPort = (this.$el?.ownerDocument?.defaultView?.localStorage || globalThis?.localStorage)?.getItem("CARD_APP_PORT");
        // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 start
        if(!/^\d+$/.test(defaultPort)){
          (this.$el?.ownerDocument?.defaultView?.localStorage || globalThis?.localStorage)?.removeItem("CARD_APP_PORT");
          defaultPort = null;
        }
        // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 end
        if (null !== defaultPort) {
          // localStorageがあり場合、接続を実施する
          this.init({ port: defaultPort, facilityCd: "" });
          this.connect();
          // Nミリ秒を待つ
          await SleepNSeconds(delayMillisecond);
        }
        // 接続確認実施
        // APP接続しません、または、カードリーダーが無し
        if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
          // 「カードアプリポート管理」からportを取得する
          let facilityCd = this.facilityCd;
          let cardPorts = await ApiHelper.get(`${MENU_BAR.uriGetCardAppPort}/${facilityCd}`).catch(() => {
            getErrorMessage('MenuBar.vue', 'created', 'カードアプリポート管理から、ポートを取得しません。');
            throw new Error("カードアプリポート管理から、ポートを取得しません。");
          });
          // portsをループする
          let portList = new Array();
          if (cardPorts.data.toString().indexOf(",") === -1) {
            portList[0] = cardPorts.data.toString();
          } else {
            portList = cardPorts.data.toString().split(",");
          }
          for (let i = 0; i < portList.length; i++) {
            // APP接続しません、または、カードリーダーが無し
            if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
              // card appのwebsokcet以外場合、接続したサービスを閉じました
              if (this.getSocketIsConnected) {
                this.close();
                await SleepNSeconds(100);
              }
              // 接続を実施する
              this.init({ port: portList[i], facilityCd: "" });
              this.connect();
              // Nミリ秒を待つ
              await SleepNSeconds(delayMillisecond);
            }
          }
        }
      } else {
        this.isCardDeviceConnected = this.getCardDeviceStatus
      }
    }
    if ("" === this.selectedPatId || null === this.selectedPatId) {
      // 顧客未選択時は何もしない
      this.seletedfacilityCd=this.facilityCd;
      this.setIsOwnFacility(true);
      this.setSelectedFacilityCd(this.seletedfacilityCd);
    } else {
      if (!this.isNewPatPage) {
        if (this.selectedPat.pat_personal_main.facility_cd !== this.facilityCd) {
          this.setIsOwnFacility(false);
        } else {
          this.setIsOwnFacility(true);
        }
        this.seletedfacilityCd = this.selectedPat.pat_personal_main.facility_cd;
        this.setSelectedFacilityCd(this.seletedfacilityCd);
      } else {
        this.seletedfacilityCd=this.facilityCd;
        this.setSelectedFacilityCd(this.seletedfacilityCd);
        this.setIsOwnFacility(true);
      }
      this.checkHomeDialysisPat();
      // 拡張設定
      this.setAdvancedSettings();
    }
    function SleepNSeconds(num) {
      return new Promise((resolve) => {
        setTimeout(() => {
          resolve(1 * num);
        }, num);
      });
    }
  },
  methods: {

    ...mapGetters("account-edit", ["getUserId"]),
    getPatInfoLayoutRoot() {
      return typeof this.getNtssLayoutRootElement === "function"
        ? this.getNtssLayoutRootElement()
        : (this.$el || null);
    },
    getPatInfoElementById(id) {
      return getScopedElementById(id, this.getPatInfoLayoutRoot());
    },
    getPatInfoFirstByClassName(className) {
      return getScopedElementsByClassName(className, this.getPatInfoLayoutRoot())[0]
        || null;
    },
    queryPatInfo(selector) {
      return queryScopedSelector(selector, this.getPatInfoLayoutRoot());
    },
    // mod 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 start
    // ...mapActions("pat-info", ["clearSelectedPat", "checkHomeDialysisPat", "setAdvancedSettings", "setIsOwnFacility"]),
    ...mapActions("pat-info", ["clearSelectedPat", "checkHomeDialysisPat", "setAdvancedSettings", "setIsOwnFacility", "setSearchedPatList", "sortPatList"]),
    // mod 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 end
    ...mapMutations("pat-info", ["updateSearchedPatList", "updateTreatmentPatList", "setSelectedFacilityCd"]),
    ...mapMutations("pat-info", { setPat: "setSelectedPat", setIsNullPat: "setIsNullPat" }),
    ...mapActions("websocket-card", ["init", "connect", "sendSocketMessage", "close", "clearSocketMessage"]),
    ...mapActions("loading-screen", ["setLoadingScreenMessage","setLoadingScreenVisible"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    changeFacility(seletedfacilityCd) {
      if (this.facilityCd !== seletedfacilityCd) {
        this.setIsOwnFacility(false);
      } else {
        this.setIsOwnFacility(true);
      }
      var changedPatId = null;
      this.mstFacility.map((item) => {
        if (item.facilityCd === seletedfacilityCd) {
          changedPatId = item.patId;
        }
      })
      this.setSelectedPatInfo(changedPatId);
      this.setSelectedFacilityCd(seletedfacilityCd);
    },
    // 選択した患者の患者情報レコードをストアに格納する
    setSelectedPatInfo(selectedPatId) {
      this.setPat(null);
      this.setIsNullPat(false);
      this.selectPat(selectedPatId).catch(() => {
        getErrorMessage('MenuBar.vue', 'setSelectedPatInfo', '患者選択失敗');
        throw new Error("[MenuBar.vue]setSelectedPatInfo(): 患者選択失敗");
      });
    },
    getInputId() {
      if (this.clickTrue === true) {
        return;
      }
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      if (this.clickTrue === false) {
        this.clickTrue = true
      }
      const params = {
        facility_cd: this.facilityCd,
        coop_cd: "profile",
        coop_cd_index: "",
        crud: "C",
        direction: "S",
        ana_result: "0",
        coop_result: "0",
        pat_id: this.selectedPat.pat_personal_main.pat_id,
        hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
        ord_no: "",
        base_date: dayjs().format("YYYYMMDD"),
        ope_cd: "007001",
        user_id: this.getUserId()
      };
      createJournal(params).then(() => {
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "完了",
          // message: "患者情報をリクエストしました。"
          title: DIALOG_MESSAGES[12000312].title,
          message: messageFormat(DIALOG_MESSAGES[12000312].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        this.clickTrue = false
      }).catch(error => {
        if (error.response.status === 400) {
          getErrorMessage('MenuBar.vue', 'getInputId', '患者情報をリクエストしませんでした。');
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "失敗",
            // message: "患者情報をリクエストしませんでした。"
            title: DIALOG_MESSAGES[12000313].title,
            message: messageFormat(DIALOG_MESSAGES[12000313].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        } else if (error.response.status === 404) {
          getErrorMessage('MenuBar.vue', 'getInputId', '当該機能が連携対象外施設');
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "失敗",
            // message: "当該機能が連携対象外施設"
            title: DIALOG_MESSAGES["00200114"].title,
            message: messageFormat(DIALOG_MESSAGES["00200114"].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
        this.clickTrue = false
        throw error;
      })
    },
    setAllClass () {
      for (const card of this.cardData) {
        const cardEl = this.getPatInfoElementById(card);
        if (cardEl) {
          cardEl.setAttribute("class","btn3-normal");
        }
      }
    },
    setAllHeadClass () {
      for (const header of this.headerData) {
        const headerEl = this.getPatInfoElementById(header);
        if (headerEl?.children?.[0]) {
          headerEl.children[0].setAttribute("class","card-header color-header");
        }
      }
    },
    toHump(str) {
      let re = /-(\w)/g;
      return str.replace(re, function($0,$1){
        return $1.toUpperCase();
      })
    },
    getCardButtonId(cardComponent) {
      const cardEntry = Object.entries(this.cardComponents).find(([, component]) => component === cardComponent);
      if (!cardEntry) {
        return cardComponent?.$options?._componentTag && this.toHump(cardComponent.$options._componentTag);
      }
      return cardEntry[0] === "additionSettingCard" ? "additionSetting" : cardEntry[0];
    },
    // ボタンクリックで該当カードにスクロールする。閉鎖カードだけを展開
    toggleClosingCardToShowing(cardComponents) {
      const isCardShowing = cardComponents.cardFrame.isCardShowing;
      // 折り畳みのカードを展開
      if (!isCardShowing) {
        cardComponents.toggleCardShowing();
      }
      this.setAllClass();
      this.setAllHeadClass();
      this.getPatInfoElementById(this.getCardButtonId(cardComponents))?.setAttribute("class","green-btn");
      const selectedHeader = this.getPatInfoElementById(cardComponents.$attrs.id);
      if (selectedHeader?.children?.[0]) {
        selectedHeader.children[0].setAttribute("class", "color-header-selected");
      }
      this.queryPatInfo('#' + cardComponents.$attrs.id)?.scrollIntoView?.();
    },
    // 全カードオープン
    openAllCard() {
      this.setAllClass();
      this.setAllHeadClass();
      for (const card of Object.values(this.cardComponents)) {
        card.openCard();
      }
      this.$emit('all-card-show', true);
    },
    // 全カードクローズ
    closeAllCard() {
      this.setAllClass();
      this.setAllHeadClass();
      for (const card of Object.values(this.cardComponents)) {
        card.closeCard();
      }
      this.$emit('all-card-show', false);
    },
    async deletePat() {
      // add #10359_NG対応 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('PatInfo', 'item_delete_btn')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "患者削除")
        });
        return;
      }
      // add #10359_NG対応 編集権限の動作不正 dengshen end
      let deleteFlg = false;
      let dialogDispFlg = false;
      await this.$ons.notification.confirm({
        modifier: "warn",
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "患者削除警告",
        title: DIALOG_MESSAGES[13000109].title,
        // message: "患者を削除します。患者に関連するデータすべてが削除されます。削除すると二度と元に戻せません。削除しますか？",
        message: messageFormat(DIALOG_MESSAGES[13000109].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer == 1) {
            deleteFlg = true;
            dialogDispFlg = true;
          }
        }
      });
      if (dialogDispFlg) {
        await this.$ons.notification.confirm({
          modifier: "warn",
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "患者削除最終確認",
          title: DIALOG_MESSAGES[13000110].title,
          // message: "患者を削除します。本当によろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000110].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 0) {
              deleteFlg = false;
            }
          }
        });
      }
      // キャンセルされた場合は処理を中断
      if (!deleteFlg) {
        return;
      }
      const params = {
        ope_cd: "007008",
        crud: "U",
        facility_cd: this.facilityCd,
        pat_id: this.selectedPat.pat_personal_main.pat_id,
        hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
        ord_no: "",
        base_date: dayjs().format("YYYYMMDD"),
        user_id: this.getUserId(),
      };
      // 患者削除処理（論理削除）
      let targetPatId = this.selectedPatId;
      // mod #6227 2022-08-11 ord_mainの削除データ不正 赵鑫宇 start
      //await ApiHelper.put(`${MENU_BAR.uriDeletePatInfo}/${targetPatId}`).catch(() => {
        //getErrorMessage('MenuBar.vue', 'deletePat', '患者削除失敗');
        //throw new Error("患者削除失敗");
      //});
      //await ApiHelper.put(`${MENU_BAR.uriCopyPatInfo}/${targetPatId}`).catch(() => {
                   // getErrorMessage('MenuBar.vue', 'deletePat', '患者削除失敗');
                    //throw new Error("患者削除失敗");
      //});

      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
      // await ApiHelper.put(`${MENU_BAR.uriCopyPatInfo}/${targetPatId}`).catch(() => {
      //         getErrorMessage('MenuBar.vue', 'deletePat', '患者削除失敗');
      //         throw new Error("患者削除失敗");
      //       });
      // del 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
      // mod 10880 start
      // await ApiHelper.put(`${MENU_BAR.uriDeletePatInfo}/${targetPatId}`).catch(() => {
      //   getErrorMessage('MenuBar.vue', 'deletePat', '患者削除失敗');
      //   throw new Error("患者削除失敗");
      // });
      let treatmentFlg = false;
      await ApiHelper.put(`${MENU_BAR.uriDeletePatInfo}/${targetPatId}`).then(response => {
        const data = response.data;
        if (data == '22020005') {
          treatmentFlg = true;
          this.$ons.notification.alert({
            title: "",
            message: messageFormat(DIALOG_MESSAGES['22020005'].message)
          });
        }
      }).catch(() => {
        getErrorMessage('MenuBar.vue', 'deletePat', '患者削除失敗');
        throw new Error("患者削除失敗");
      });
      if (treatmentFlg) {
        return;
      }
      // mod 10880 end
      // mod #6227 2022-08-11 ord_mainの削除データ不正 赵鑫宇 end
      // add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 start
      if (this.searchedPatList.length > 0) {
        const uriPersonalMain = "/patInfo/getPatPersonalMainByList";
        const searchedPatIdList = deepCopy(this.searchedPatList).map(pat => pat.pat_id);
        const resPersonalMain = await ApiHelper.post(uriPersonalMain, searchedPatIdList).catch(() => {
          throw new Error("[SearchPatSimple.vue]searchPat(): 検索失敗");
        });
        const searchPatList = resPersonalMain.data.map(pat => {
          return {
            pat_id: pat.pat_id,
            hosp_pat_id: pat.hosp_pat_id,
            pat_sex: pat.pat_sex,
            pat_last_name: pat.pat_last_name,
            pat_first_name: pat.pat_first_name,
            is_same: pat.is_same,
            pat_first_name_kana: pat.pat_first_name_kana,
            pat_last_name_kana: pat.pat_last_name_kana,
            in_out_class: pat.in_out_class
          }
        })
        this.setSearchedPatList(searchPatList);
        if (null !== this.getSortPatInfo && this.getSortPatInfo.length >0) {
          if (null !== this.getSortPatInfo[0].key) {
            await this.sortPatList({
              sortConditions: this.getSortPatInfo,
              selectedPatId: this.selectedPatId
            });
          }
        }
        EventBus.$emit("scrollTop");
      }
      // add 10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない 関 end
      // 選択患者を未選択状態にする
      this.clearSelectedPat();
      // サイドバーに表示されている患者から該当患者を削除
      // 3868 患者削除時に同姓同名のマークが消えない 吉
      var deletPatName;
      const tmpPatList = deepCopy(this.searchedPatList).filter(function(patObj) {
        // 3868 患者削除時に同姓同名のマークが消えない 吉
        if (patObj.pat_id === targetPatId && patObj.is_same === 1) {
          deletPatName = patObj.pat_first_name+patObj.pat_last_name;
        }
        if (patObj.pat_id !== targetPatId) {
          return true;
        }
      });
      // 3868 患者削除時に同姓同名のマークが消えない 吉
      tmpPatList.forEach(item => {
        if (item.pat_first_name + item.pat_last_name === deletPatName) {
          item.is_same = null;
        }
      });
      this.updateSearchedPatList(tmpPatList);
      // 機能別の患者リストを表示している場合は、そちらのリストからも削除する
      if (this.srcFuncName !== "") {
        const tmpTreatPatList = deepCopy(this.treatmentPatList).filter(function(patObj) {
          if (patObj.pat_id !== targetPatId) {
            return true;
          }
        });
        this.updateTreatmentPatList(tmpTreatPatList);
      }
      createJournal(params);
    },
    createCard() {
      if (this.getSocketIsConnected) {
        this.setLoadingScreenVisible(true);
        this.sendSocketMessage(`WRITE_PAT_CARD-${this.facilityCd}-${this.selectedPatId}`);
      } else {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "保存失敗",
          // message: "カードの書き込みに失敗しました。"
          title: DIALOG_MESSAGES["00200103"].title,
          message: messageFormat(DIALOG_MESSAGES["00200103"].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
      }
    },
    resizeHeight() {
      // ヘッダーとフッターの高さを取得
      // ヘッダーの高さを取得
      let headerHeight = 0;
      const headerObj = getScopedElementsByClassName("header", this.getPatInfoLayoutRoot());
      if (headerObj.length > 0) {
        headerHeight = headerObj[0].offsetHeight;
      }
      // フッターの高さを取得
      let footerHeight = 0;
      const footerObj = getFooterMenuElement(this.getPatInfoLayoutRoot());
      if (footerObj) {
        footerHeight = footerObj.offsetHeight;
      }
      // 高さを設定
      this.menuBarHeight = this.windowHeight - (headerHeight + footerHeight);
      // add #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start
      let patInfo = getPatInfoHeaderAreaElement(this.getPatInfoLayoutRoot());
      // ヘッダから表示された患者情報画面の場合のみ、ヘッダーエリアの高さを計算して適用する
      if (!patInfo) {
        return;
      }
      let rightExeBtn = getScopedElementsByClassName("right-exe-btn", this.getPatInfoLayoutRoot());
      let btnHeight = rightExeBtn[0].clientHeight;
      let contentContainer = getContentContainerElement(this.getPatInfoLayoutRoot())?.clientHeight || 0;
      let patHeader = getPatHeaderElement(this.getPatInfoLayoutRoot())?.clientHeight || 0;
      // ヘッダーエリアの高さと、メニューバーの高さを合わせる
      this.menuBarHeight = contentContainer - patHeader - btnHeight - 5 - 40;
      patInfo.style.height = this.menuBarHeight + "px";
      // add #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end
    }
  },
  beforeUnmount () {
    clearInterval(this.socketInterval);
    // インターバルをクリア
    if (this.intervalId !== undefined) {
      clearInterval(this.intervalId);
    }
    // this.tmpObserverが空でなければ監視を解除
    if (this.tmpObserver) {
      this.tmpObserver.disconnect();
    }
  },
  watch: {
    getSocketIsConnected(value) {
      this.isCardDeviceConnected = false;
      if (value === true) {
        clearInterval(this.socketInterval);
      }
    },
    getSocketMessages(value) {
      if (value == null) return;
      const splitMsg = value.split("\t");
      if (splitMsg.length > 1) {
        if (splitMsg[0] === "CARD_CLIENT") {
          switch(splitMsg[1]) {
            case "CARD_READER_STATUS":
              this.isCardDeviceConnected = JSON.parse(splitMsg[2].toLowerCase());
              this.clearSocketMessage();
              break;
            case "CARD_WRITE_STATUS":
              this.setLoadingScreenVisible(false);
              if (JSON.parse(splitMsg[2].toLowerCase()) === true) {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存成功",
                  // message: "カード情報が</br>保存されました。"
                  title: DIALOG_MESSAGES[12000291].title,
                  message: messageFormat(DIALOG_MESSAGES[12000291].message)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              } else {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存失敗",
                  // message: "カードの書き込みに失敗しました。"
                  title: DIALOG_MESSAGES["00200103"].title,
                  message: messageFormat(DIALOG_MESSAGES['00200103'].message)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              }
              this.clearSocketMessage();
              break;
          }
        }
      }
    },
    getCardDeviceStatus(value) {
      this.isCardDeviceConnected = value;
    },
    windowHeight() {
      this.resizeHeight();
    },
    isDispMenu() {
      this.resizeHeight();
    }
  }
};
</script>

<style scoped>
.bar-toggler {
  margin-right: 80px;
}
#menu-bar-id {
  overflow: scroll;
}
.block {
  display: block;
}
.none {
  display: none;
}
.menu-bar {
  margin-left: -143px;
  width: 130px;
  position: fixed;
  left: 0;
  text-align: center;
  box-sizing: border-box;
  z-index: 2;
}
.menu-bar-trigger {
  display: inline-block;
  background-color: #cccccc;
  border-radius: 0;
  font-size: 15px;
  border-bottom: solid 4px #777575;
}
.menu-bar-trigger:hover {
  background: #b3b0b0 ;
  color: #FFF;
}
.ios-margin-bottom{
    margin-bottom: -1px;
}
.menu-bar-contents {
  border: hidden;
}
.last-element-bottom{
  margin-bottom: 6px !important;
}
.button-size ons-button{
  width: 90%;
  height: 35px;
  margin: 2px 0;
  font-size: inherit;
  padding: 0.2em 1em 0em 1em !important;
}
.facilitylist{
  width: 90%;
  height: 35px;
}
.menu-bar-contents button {
  display: inline-block;
  box-sizing: border-box;
  color: white;
  background-color: #0cf;
  outline: 0;
}
.delete-button {
  background-color: #FF3366 !important;
  background-image: -webkit-linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
.menu-bar-contents::-webkit-scrollbar {
  display: none;
}
@media screen and (max-height: 700px) {
  .menu-bar-contents {
    height: 300px;
    overflow: auto;
  }
  .menu-bar-contents::-webkit-scrollbar {
    display: none;
  }
}
@media screen and (max-height: 420px) {
  .menu-bar-contents {
    height: 160px;
    overflow: auto;
  }
  .menu-bar-contents::-webkit-scrollbar {
    display: none;
  }
}
</style>
