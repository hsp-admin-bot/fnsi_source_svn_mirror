<template>
  <div class="pat-info-card">
    <!-- カードヘッダ部分 -->
    <div class="card-header color-header">
      <label class="card-name" @click="toggleCardShowing"
        >{{ cardName }}
        <template v-if="contentsNum !== null">
          ({{ contentsNum }}件)
        </template>
        <template v-else-if="cardName === '感染症' && infectionNum !== null">
          ({{ infectionNum }}件)
        </template>
        <template
          v-else-if="
            cardName === '透析困難・重症度・搬送区分' && dialDiffNum !== null
          "
        >
          ({{ dialDiffNum }}件)
        </template>
      </label>
      <!-- FNSI - mod-画面部品デザイン-じょはく start-->
      <!--      <span class="card-header-button-area">-->
      <!--        &lt;!&ndash; 項目追加ボタン &ndash;&gt;-->
      <!--        <label-->
      <!--          v-if="addItemAvailable"-->
      <!--          class="card-header-button"-->
      <!--          @click="addItem"-->
      <!--        >＋</label-->
      <!--        >-->
      <!--        &lt;!&ndash; 並び替えモードボタン &ndash;&gt;-->
      <!--        <label-->
      <!--          v-if="actionModeAvailable"-->
      <!--          class="card-header-button"-->
      <!--          @click="switchActionMode"-->
      <!--        >-->
      <!--          ≡-->
      <!--        </label>-->
      <!--      </span>-->
      <span class="card-header-button-area">
        <!-- 項目追加ボタン -->
        <!--mod 編集権限の適用 じょはく start-->
        <!--<label
          v-if="addItemAvailable"
          class="card-header-button"
          @click="addItem">
          <img class="pat-create-btn" src="img/pat-info/add.png"/>
        </label>-->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <label -->
        <!--   v-if="this.addFlag" -->
        <!--   class="card-header-button" -->
        <!--   @click="addItem" -->
        <!-- > -->
        <label
          v-if="this.addFlag && getItemAuthorized('PatInfo', 'default_authority')"
          class="card-header-button"
          :class="{ disabled: getIsOtherFacility }"
          @click="addItem"
        >
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <img class="pat-create-btn" src="img/pat-info/add.png"/>
        </label>
        <!-- 並び替えモードボタン -->
        <!--<label
          v-if="actionModeAvailable"
          class="card-header-button"
          @click="switchActionMode">
          <img class="pat-create-btn" src="img/pat-info/del.png"/>
        </label>-->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <label -->
        <!--   v-if="this.editFlag" -->
        <!--   class="card-header-button" -->
        <!--   @click="switchActionMode"> -->
        <label
          v-if="this.editFlag && getItemAuthorized('PatInfo', 'default_authority')"
          class="card-header-button"
          :class="{ disabled: getIsOtherFacility }"
          @click="switchActionMode">
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <img class="pat-create-btn" src="img/pat-info/del.png"/>
        </label>
        <!--mod 編集権限の適用 じょはく end-->
        <label
          v-if="this.isCardShowing"
          class="card-header-button"
          @click="toggleCardShowing">
          <img class="pat-create-btn" src="img/pat-info/up.png"/>
        </label>
        <label
          v-if="!this.isCardShowing"
          class="card-header-button"
          @click="toggleCardShowing">
          <img class="pat-create-btn" src="img/pat-info/down.png"/>
        </label>
      </span>
      <!-- FNSI - mod-画面部品デザイン-じょはく end-->
    </div>
    <!-- カード内容部分 -->
    <div v-show="isCardShowing && dispDataMode" class="card-contents">
      <slot></slot>
    </div>
    <!-- データなし表示 -->
    <div v-show="isCardShowing && !dispDataMode" class="card-contents no-data-box">
      <span class="no-data-inner">データなし</span>
    </div>
  </div>
</template>

<script>
import { resolveDefaultSlotComponent } from "@/compat/vue/slots";
import { getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from "@/functions/common/LayoutMeasureHelper";
/**
 * write a component's description
 */
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// mod 編集権限の適用 じょはく start
import {mapActions, mapGetters,mapMutations} from "@/compat/vue/vuex";
// mod 編集権限の適用 じょはく end
// add 編集権限の適用 じょはく start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority.js";
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 じょはく end

export default {
  props: {
    cardName: {
      type: String,
      required: true
    },

    addItemAvailable: {
      type: Boolean,
      default: false
    },

    actionModeAvailable: {
      type: Boolean,
      default: false
    },
    // add 編集権限の適用 じょはく start
    isCreationPat: {
      type: Boolean,
      default: false
    },
    // add 編集権限の適用 じょはく end
  },

  data() {
    return {
      isCardShowing: true,
      cardContent: null,
      isPatViewAuthorized: null,
      isPatEditAuthorized: null,
      isCreatePatViewAuthorized: null,
      editFlag: null,
      addFlag: null,
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

  computed: {
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 じょはく end
    ...mapGetters("pat-info", ["getIsOtherFacility"]),
    /**
     * @description カード内容の件数
     */
    contentsNum() {
      if (
        this.cardContent !== null &&
        this.cardContent.jsonArray !== undefined
      ) {
        return this.cardContent.jsonArray.length;
      }
      return null;
    },

    /**
     * @description チェックされた透析困難の件数
     */
    dialDiffNum() {
      if (this.cardContent !== null) {
        return this.cardContent.dialDiffNum;
      }
      return null;
    },

    /**
     * @description 結果のある感染症の件数
     */
    infectionNum() {
      if (this.cardContent !== null) {
        return this.cardContent.infectionNum;
      }
      return null;
    },

    /**
     * @description データを表示するか否か
     */
    dispDataMode() {
      // true条件は contentsNum が null または 0以外
      // false条件は  contentsNum が null以外 または 0
      // 例外 +ボタンが非表示なら無条件true
      // 例外 既往歴なら無条件true（糖尿病患者、血糖検査、透析導入原疾患は表示するため）

      if (!this.addItemAvailable) return true;
      if (this.cardName === "既往歴") return true;
      return this.contentsNum === null || this.contentsNum !== 0;
    }
  },

  watch:{
    contentsNum() {
      this.$nextTick(() => {
        this.$emit("trigger-show", true);
      });
    }
  },
  mounted() {
    // slotにコンポーネントが埋め込まれるのを待ってカード内容を保持 ※待たないとundefined
    this.$nextTick(() => {
      this.resolveCardContent();
    });
  },

  methods: {
    getScopedElementById(id) {
      return getScopedElementById(id, this);
    },
    getScopedElementsByClassName(className) {
      return getScopedElementsByClassName(className, this);
    },
    getScopedQuery(selector) {
      return queryScopedSelector(selector, this);
    },
    getScopedQueryAll(selector) {
      return queryScopedSelectorAll(selector, this);
    },

    getDefaultSlotComponent() {
      return resolveDefaultSlotComponent(this);
    },
    resolveCardContent() {
      const cardContent = this.getDefaultSlotComponent() || this.$parent?.cardContent || this.$parent?.$refs?.cardContent || null;
      if (cardContent) {
        this.cardContent = cardContent;
      }
      return this.cardContent;
    },
    // mod FNSI redmine #4342修正 鄧シン start
    // ...mapActions("pat-insurance", ["setInsuranceModalVisible", "setIsCreate"]),
    ...mapActions("pat-insurance", ["setIsCreate", "updatePatInsurance"]),
    // mod FNSI redmine #4342修正 鄧シン end
    ...mapMutations("pat-info", ["setIsAdd"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    setAllClass () {
      for (const card of this.cardData) {
        if (this.getScopedElementById(card)) {
          this.getScopedElementById(card).setAttribute("class","btn3-normal");
        }
      }
    },
    setAllHeadClass () {
      for (const header of this.headerData) {
        if (this.getScopedElementById(header)) {
          this.getScopedElementById(header).children[0].setAttribute("class","card-header color-header");
        }
      }
    },
    // カード開閉
    toggleCardShowing() {
      this.setAllHeadClass();
      this.setAllClass();
      // add FNSI-カードとボタンの調整 じょはく start
      if ( this.isCardShowing === true ) {
        this.$el.children[0].setAttribute("class", "card-header color-header");
      } else {
        this.$el.children[0].setAttribute("class", "card-header color-header-selected");
        switch (this.cardName) {
          case "本人情報":
            this.getScopedElementById("basicInfoCard").setAttribute("class","green-btn");
            this.getScopedElementById("basic-info-card-content").children[0].setAttribute("class", "color-header-selected");
            this.getScopedQuery("#basic-info-card-content").scrollIntoView();
            break;
          case "連絡先":
            this.getScopedElementById("otherContactCard").setAttribute("class","green-btn");
            this.getScopedElementById("other-contact-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#other-contact-card-content").scrollIntoView();
            break;
            // mod FNSI-画面部品デザイン じょはく start
          case "連絡先(サービス業者)":
            this.getScopedElementById("vendorContactCard").setAttribute("class","green-btn");
            this.getScopedElementById("vendor-contact-card-contents").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#vendor-contact-card-contents").scrollIntoView();
            break;
            // mod FNSI-画面部品デザイン じょはく end
          case "患者メモ":
            this.getScopedElementById("patMemoCard").setAttribute("class","green-btn");
            this.getScopedElementById("pat-memo-card-contents").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#pat-memo-card-contents").scrollIntoView();
            break;
          case "保険情報":
            this.getScopedElementById("insuranceInfoCard").setAttribute("class","green-btn");
            this.getScopedElementById("insurance-info-card").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#insurance-info-card").scrollIntoView();
            break;
          case "透析困難・重症度・搬送区分":
            this.getScopedElementById("difficultySeverityTransportCard").setAttribute("class","green-btn");
            this.getScopedElementById("difficulty-severity-transport-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#difficulty-severity-transport-card-content").scrollIntoView();
            break;
          case "診療情報":
            this.getScopedElementById("medicalCareInfoCard").setAttribute("class","green-btn");
            this.getScopedElementById("medical-care-info-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#medical-care-info-card-content").scrollIntoView();
            break;
          case "担当者":
            this.getScopedElementById("chargeStaffCard").setAttribute("class","green-btn");
            this.getScopedElementById("charge-staff-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#charge-staff-card-content").scrollIntoView();
            break;
          case "禁忌・アレルギー":
            this.getScopedElementById("tabooAllergyCard").setAttribute("class","green-btn");
            this.getScopedElementById("taboo-allergy-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#taboo-allergy-card-content").scrollIntoView();
            break;
          case "感染症":
            this.getScopedElementById("infectionCard").setAttribute("class","green-btn");
            this.getScopedElementById("infection-card-contents").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#infection-card-contents").scrollIntoView();
            break;
          case "インプラント":
            this.getScopedElementById("implantCard").setAttribute("class","green-btn");
            this.getScopedElementById("implant-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#implant-card-content").scrollIntoView();
            break;
          case "既往歴":
            this.getScopedElementById("medicalHstCard").setAttribute("class","green-btn");
            this.getScopedElementById("medical-hst-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#medical-hst-card-content").scrollIntoView();
            break;
          case "入外・転入出":
            this.getScopedElementById("visitHstCard").setAttribute("class","green-btn");
            this.getScopedElementById("visit-hst-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#visit-hst-card-content").scrollIntoView();
            break;
          case "身体情報":
            this.getScopedElementById("physicalInfoCard").setAttribute("class","green-btn");
            this.getScopedElementById("physical-info-card-contents").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#physical-info-card-contents").scrollIntoView();
            break;
          case "患者グループ":
            this.getScopedElementById("patGroupCard").setAttribute("class","green-btn");
            this.getScopedElementById("pat-group-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#pat-group-card-content").scrollIntoView();
            break;
          case "利用遠隔モニタリングサービス":
            this.getScopedElementById("remoteMonitorCard").setAttribute("class","green-btn");
            this.getScopedElementById("remote-monitor-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#remote-monitor-card-content").scrollIntoView();
            break;
          case "加算・管理料":
            this.getScopedElementById("additionSetting").setAttribute("class","green-btn");
            this.getScopedElementById("addition-setting-card-content").children[0].setAttribute("class","color-header-selected");
            this.getScopedQuery("#addition-setting-card-content").scrollIntoView();
            break;
          default:
            this.getScopedQuery("#basic-info-card-content").scrollIntoView();
            break;
        }
      }
      // add FNSI-カードとボタンの調整 じょはく end
      this.isCardShowing = !this.isCardShowing;
      // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
      this.$emit('card-show', this.isCardShowing);
      // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
    },
    /**
     * @description 「+」によるカード内容への項目追加処理
     * @summary
     *   カード内容部分に実装されたaddItem()を実行し項目追加を行う
     */
    addItem() {
      if (this.getIsOtherFacility) {
        return;
      }
      this.setIsAdd(1);
      // add FNSI-カードとボタンの調整 じょはく start
      this.setAllHeadClass();
      this.setAllClass();
      this.$el.children[0].setAttribute("class", "card-header color-header-selected");
      switch (this.cardName) {
        case "本人情報":
          this.getScopedElementById("basicInfoCard").setAttribute("class","green-btn");
          this.getScopedElementById("basic-info-card-content").children[0].setAttribute("class", "color-header-selected");
          this.getScopedQuery("#basic-info-card-content").scrollIntoView();
          break;
        case "連絡先":
          this.getScopedElementById("otherContactCard").setAttribute("class","green-btn");
          this.getScopedElementById("other-contact-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#other-contact-card-content").scrollIntoView();
          break;
          // mod FNSI-画面部品デザイン じょはく start
        case "連絡先(サービス業者)":
          this.getScopedElementById("vendorContactCard").setAttribute("class","green-btn");
          this.getScopedElementById("vendor-contact-card-contents").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#vendor-contact-card-contents").scrollIntoView();
          break;
          // mod FNSI-画面部品デザイン じょはく end
        case "患者メモ":
          this.getScopedElementById("patMemoCard").setAttribute("class","green-btn");
          this.getScopedElementById("pat-memo-card-contents").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#pat-memo-card-contents").scrollIntoView();
          break;
        case "保険情報":
          this.getScopedElementById("insuranceInfoCard").setAttribute("class","green-btn");
          this.getScopedElementById("insurance-info-card").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#insurance-info-card").scrollIntoView();
          break;
        case "透析困難・重症度・搬送区分":
          this.getScopedElementById("difficultySeverityTransportCard").setAttribute("class","green-btn");
          this.getScopedElementById("difficulty-severity-transport-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#difficulty-severity-transport-card-content").scrollIntoView();
          break;
        case "診療情報":
          this.getScopedElementById("medicalCareInfoCard").setAttribute("class","green-btn");
          this.getScopedElementById("medical-care-info-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#medical-care-info-card-content").scrollIntoView();
          break;
        case "担当者":
          this.getScopedElementById("chargeStaffCard").setAttribute("class","green-btn");
          this.getScopedElementById("charge-staff-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#charge-staff-card-content").scrollIntoView();
          break;
        case "禁忌・アレルギー":
          this.getScopedElementById("tabooAllergyCard").setAttribute("class","green-btn");
          this.getScopedElementById("taboo-allergy-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#taboo-allergy-card-content").scrollIntoView();
          break;
        case "感染症":
          this.getScopedElementById("infectionCard").setAttribute("class","green-btn");
          this.getScopedElementById("infection-card-contents").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#infection-card-contents").scrollIntoView();
          break;
        case "インプラント":
          this.getScopedElementById("implantCard").setAttribute("class","green-btn");
          this.getScopedElementById("implant-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#implant-card-content").scrollIntoView();
          break;
        case "既往歴":
          this.getScopedElementById("medicalHstCard").setAttribute("class","green-btn");
          this.getScopedElementById("medical-hst-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#medical-hst-card-content").scrollIntoView();
          break;
        case "入外・転入出":
          this.getScopedElementById("visitHstCard").setAttribute("class","green-btn");
          this.getScopedElementById("visit-hst-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#visit-hst-card-content").scrollIntoView();
          break;
        case "身体情報":
          this.getScopedElementById("physicalInfoCard").setAttribute("class","green-btn");
          this.getScopedElementById("physical-info-card-contents").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#physical-info-card-contents").scrollIntoView();
          break;
        case "患者グループ":
          this.getScopedElementById("patGroupCard").setAttribute("class","green-btn");
          this.getScopedElementById("pat-group-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#pat-group-card-content").scrollIntoView();
          break;
        case "利用遠隔モニタリングサービス":
          this.getScopedElementById("remoteMonitorCard").setAttribute("class","green-btn");
          this.getScopedElementById("remote-monitor-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#remote-monitor-card-content").scrollIntoView();
          break;
        case "加算・管理料":
          this.getScopedElementById("isShowAdditionInfo").setAttribute("class","green-btn");
          this.getScopedElementById("addition-setting-card-content").children[0].setAttribute("class","color-header-selected");
          this.getScopedQuery("#addition-setting-card-content").scrollIntoView();
          break;
        default:
          this.getScopedQuery("#basic-info-card-content").scrollIntoView();
          break;
      }
      // add FNSI-カードとボタンの調整 じょはく end
      this.isCardShowing = true;

      this.$emit("card-show", this.isCardShowing);

      const cardContent = this.resolveCardContent();
      if (cardContent === null || cardContent.addItem === undefined) {
        throw new Error(`${this.cardName}カードの項目追加処理が未実装です。`);
      } else {
        cardContent.addItem();
      }
      this.$nextTick(() => {
        this.$emit("trigger-show", true);
      });
    },

    /**
     * @description 並び替えモード切り替え
     */
    switchActionMode() {
      if (this.getIsOtherFacility) {
        return;
      }
      this.isCardShowing = true;
       this.$emit("card-show", this.isCardShowing);
      if (
        this.cardContent.editRecord[this.getKeyByName(this.cardName)] &&
        this.cardContent.editRecord[this.getKeyByName(this.cardName)].length === 0
      ) {
        this.cardContent.actionMode = false;
      } else {
        this.cardContent.actionMode = !this.cardContent.actionMode;
        // add FNSI redmine #4342修正 鄧シン start
        this.saveExchange(this.cardName);
        // add FNSI redmine #4342修正 鄧シン end
      }
    },
    // add FNSI redmine #4342修正 鄧シン start
    saveExchange(cardName){
      switch (cardName){
        case "保険情報":
          this.updatePatInsurance();
          break;
      }
    },
    // add FNSI redmine #4342修正 鄧シン end
    getKeyByName(name) {
      switch (name) {
        case "連絡先":
          return "other_contact_info";
          // mod FNSI-画面部品デザイン じょはく start
        case "連絡先(サービス業者)":
          return "vendor_contact_info";
          // mod FNSI-画面部品デザイン じょはく end
        case "担当者":
          return "charge_staff_info";
        case "インプラント":
          return "implant_info";
        case "入外・転入出":
          return "in_out_visit_history_info";
      }
    }
  },
  created() {
    // mod #10359 編集権限の動作不正 dengshen start
    // // add 編集権限の適用 じょはく start
    // if ( this.isCreationPat ) {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   this.isCreatePatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = this.addItemAvailable && this.isCreatePatViewAuthorized && this.isPatEditAuthorized;
    //   this.addFlag = this.actionModeAvailable && this.isCreatePatViewAuthorized && this.isPatEditAuthorized;
    // } else {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    //   this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.addFlag = this.addItemAvailable && this.isPatViewAuthorized && this.isPatEditAuthorized;
    //   this.editFlag = this.actionModeAvailable && this.isPatViewAuthorized && this.isPatEditAuthorized;
    // }
    // // add 編集権限の適用 じょはく end
    this.addFlag = this.addItemAvailable;
    this.editFlag = this.actionModeAvailable;
    // mod #10359 編集権限の動作不正 dengshen end
  }
};
</script>

<style scoped>
/* カードヘッダ全体（ntss.css の .color-header { height: 2em } を上書き） */
.card-header {
  border: 1px solid;
  position: relative;
  height: auto;
  min-height: 2em;
  box-sizing: border-box;
}

/* カード名 */
.card-name {
  display: inline-block;
  width: 95%;
  margin: 0 5px;
}

/* ヘッダボタン部分 */
.card-header-button-area {
  position: absolute;
  right: 0;
  margin: 1px 10px 0 0;
}

/* ヘッダボタン */
.card-header-button {
  padding: 0 2px;
}

.disabled .pat-create-btn {
  filter: grayscale(80%) brightness(0.8);
}

/* カード内容部分 */
.card-contents {
  border: 1px solid #dddddd;
  border-top-style: hidden;
  background-color: var(--ntss-base-background-color);
}

/* データなし表示 外側 */
.no-data-box {
  height: 35px;
  border-bottom: none;
}

/* データなし表示 内側 */
.no-data-inner {
  padding: 6px 7px;
  display: inline-block;
}
</style>
