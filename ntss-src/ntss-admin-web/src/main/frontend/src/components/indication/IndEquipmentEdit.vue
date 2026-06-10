/** * 医療材料ー編集画面 */
<template>
  <v-ons-row>
    <v-ons-row v-if="!showEquipmentFieldOnly && !hideAutoInsertField" class="row-style">
      <v-ons-col class="equipment-column">{{ checkBoxLabel.label }}</v-ons-col>
      <v-ons-col class="equipment-data-column">
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-radio -->
        <!--   ref="icon1" -->
        <!--   :value="autoInsertValue" -->
        <!--   :name="uniqueRadioName" -->
        <!--   :radio-value="0" -->
        <!--   @change="changeButton()" -->
        <!-- >{{ checkBoxLabel.off }}</custom-radio> -->
        <!-- <v-ons-icon -->
        <!--   icon="fa-question-circle" -->
        <!--   @click="showTipsPopOver($event, tipsText.off),changeButton()" -->
        <!--   id="icon-1" -->
        <!-- /> -->
        <!-- <br> -->
        <!-- <custom-radio -->
        <!--   ref="icon2" -->
        <!--   :value="autoInsertValue" -->
        <!--   :name="uniqueRadioName" -->
        <!--   :radio-value="1" -->
        <!-- >{{ checkBoxLabel.on }}</custom-radio> -->
        <!-- <v-ons-icon -->
        <!--   icon="fa-question-circle" -->
        <!--   @click="showTipsPopOver($event, tipsText.on),changeButton()" -->
        <!--   id="icon-2" -->
        <!-- /> -->
        <custom-radio
          ref="icon1"
          :value="autoInsertValue"
          :name="uniqueRadioName"
          :radio-value="0"
          @change="changeButton()"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        >{{ checkBoxLabel.off }}</custom-radio>
        <v-ons-icon
          icon="fa-question-circle"
          @click="showTipsPopOver($event, tipsText.off),changeButton()"
          id="icon-1"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        />
        <br>
        <custom-radio
          ref="icon2"
          :value="autoInsertValue"
          :name="uniqueRadioName"
          :radio-value="1"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        >{{ checkBoxLabel.on }}</custom-radio>
        <v-ons-icon
          icon="fa-question-circle"
          @click="showTipsPopOver($event, tipsText.on),changeButton()"
          id="icon-2"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="row-style">
      <v-ons-col class="equipment-column">{{ equipmentSelectLabel }}</v-ons-col>
      <v-ons-col class="equipment-data-column" style="display: flex;">
        <show-selected-item
          ref="selectedItem"
          :propInitValue="equipmentInputValue.initValue"
          :propEditValue="equipmentInputValue.editValue"
          propBackgroundColor="#ebebe4"
          class="equipment-input-style"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   ref="popoverButton" -->
        <!--   class="common-style-select-button" -->
        <!--   @click=" -->
        <!--     showPopover(),changeButton(); -->
        <!--   " -->
        <!-- >選択</v-ons-button> -->
        <v-ons-button
          ref="popoverButton"
          class="common-style-select-button"
          @click="
            showPopover(),changeButton();
          "
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        >選択</v-ons-button>
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <pop-over
          v-bind="popoverData"
          :target-position-element="$refs.popoverButton"
          @popover-close="closePopover"
          @popover-return="updateInput"
          @change="changeButton()"
        />
      </v-ons-col>
    </v-ons-row>
    <v-ons-row v-if="!showEquipmentFieldOnly" class="row-style">
      <v-ons-col class="equipment-column">数量</v-ons-col>
      <v-ons-col class="equipment-data-column">
        <!--mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
        <!--<custom-input-number
          :value="amountInputValue"
          :digits="4"
          :min-value="1"
          :max-value="9999"
          class="amount-input-style common-style-input"
        /> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-input-number -->
        <!--   ref="amount" -->
        <!--   :value="amountInputValue" -->
        <!--   :digits="4" -->
        <!--   :min-value="1" -->
        <!--   :max-value="9999" -->
        <!--   @change="changeButton()" -->
        <!--   class="amount-input-style common-style-input ntss-custom-input-cond" -->
        <!-- /> -->
        <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng start-->
        <!-- <custom-input-number
          ref="amount"
          :value="amountInputValue"
          :digits="4"
          :min-value="1"
          :max-value="9999"
          @change="changeButton()"
          class="amount-input-style common-style-input ntss-custom-input-cond"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        /> -->
        <custom-input-number-pro
          ref="amount"
          :required="true"
          :value="amountInputValue.editValue"
          :invalidArray="['0']"
          :min="0"
          :max="9999"
          :step="1"
          class="amount-input-style common-style-input ntss-custom-input-cond"
          @handlerInput="(val) =>{ amountInputValue.editValue = val }"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        />
        <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng end-->
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!--mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
        <label>&nbsp;{{ unitLabelValue }}</label>
      </v-ons-col>
    </v-ons-row>
    <v-ons-popover
      cancelable
      :visible.sync="userMenuPopoverVisible"
      :target="userMenuPopoverTarget"
      :cover-target="false"
      :direction="userMenuPopoverDirection"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
      @change="changeButton()"
    >
      <div class="help-area">
        <div v-for="(tips, index) in viewTipsTexts" :key="index">
          <label>{{ tips }}</label>
        </div>
      </div>
    </v-ons-popover>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapGetters,mapActions } from "vuex";
import { MASTER_MAINTENANCE_CURRENT_ROUTE_NAME } from "@/constants/masterMaintenanceConstants";
import { PATVIEWER_CURRENT_ROUTE_NAME } from "@/constants/PatViewerConstants";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import { dialyzer, dialyzerTabooAllergyDeleted, equipment, equipmentAllergy, equipmentClass, equipmentIncludeDeleted } from "@/functions/mst/MstGetters.js";
import _ from "underscore";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customRadio from "@/components/common/custom-form-tags/CustomRadio";
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import {EventBus} from "@/eventBus";
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end
// add #9848+9849 数値IFのスタイル全不正 linjunfeng start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
// add #9848+9849 数値IFのスタイル全不正 linjunfeng end

export default {
  mixins: [PopoverMixin],

  components: {
    "pop-over": MasterSelector,
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-radio": customRadio,
    "show-selected-item": CustomDivShowSelectedItem,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    "custom-input-number-pro": CustomInputNumberPro,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
  },

  props: {
    /**
     * @description 全入力有効無効
     */
    fieldsDisabled: {
      type: Boolean,
      default: false
    },

    /**
     * @description 全入力の初期値
     */
    fieldsData: {
      type: Object,
      default: () => ({
        cd: null,
        amount: 0,
        unit: null,
        needleType: null
      })
    },

    /**
     * @description 医療材料の選択のみ表示
     */
    showEquipmentFieldOnly: {
      type: Boolean,
      default: false
    },

    //add 患者経済総合ビューア（計画）_医療材料：予定日医療材料を選択する場合、編集対象はマスターのデータを取る ztc 20230606 start
    /**
     * @description 医療材料Data
     */
    showPopoverContentData: {
      type: Boolean,
      default: false
    },
    //add 患者経済総合ビューア（計画）_医療材料：予定日医療材料を選択する場合、編集対象はマスターのデータを取る ztc 20230606 end

    /**
     * @description 医療材料選択のラベル
     */
    equipmentSelectLabel: {
      type: String,
      default: "医療材料"
    },

    /**
     * @description 穴埋め選択を非表示
     */
    hideAutoInsertField: {
      type: Boolean,
      default: false
    },

    /**
     * @description 「すべて」選択を表示
     */
    showAllSelectTag: {
      type: Boolean,
      default: false
    },

    /**
     * @description ダイアライザ選択可能・不可能
     */
    hasDialyzerOption: {
      type: Boolean,
      default: false
    },
    /**
     * @description 新規モードフラグ
     */
    isCreate: {
      type: Boolean,
      default: false
    }
  },

  data() {
    let cdTest;
    return {
      /**
       * @description 「ダイアライザ」マスターデータ
       */
      dialyzerDataset: [],
      equipmentDatatest1 :[],

      /**
       * @description 「医療材料」マスターデータ
       */
      equipmentDataset: [],

      /**
       * @description 「医療材料」マスタ選択用データ
       */
      popoverData: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },

      /**
       * @description 「穴埋」入力値
       */
      autoInsertValue: {
        initValue: 0,
        editValue: 0
      },

      /**
       * @description 「医療材料」表示値
       */
      equipmentInputValue: {
        initValue: null,
        editValue: null
      },

      /**
       * @description 「数量」入力値
       */
      amountInputValue: {
        //mod FNSI-6512 劉全航 start
        // initValue: this.fieldsData.amount || 1,
        // editValue: this.fieldsData.amount || 1
        initValue: Number.parseFloat(this.fieldsData.amount) || 1,
        editValue: Number.parseFloat(this.fieldsData.amount) || 1
        //mod FNSI-6512 劉全航 end
      },

      /**
       * @description 「数量」の「単位」表示値
       */
      unitLabelValue: null,

      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: "up",
      viewTipsTexts: [],
      oldOrdMainList: []
      //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
      ,EquipmentList: [],
      //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      currentOrdMainData: {},
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-viewer", { ordNoList : "getOrdNoList",
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
    getIndEndDate: "getIndEndDate",
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
    getAllData:'getAllData'
    }),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    // mod FNSI-連携イベントの登録適正化 楊 start
    ...mapGetters("pat-info", ["selectedPat"]),
    // mod FNSI-連携イベントの登録適正化 楊 end


    uniqueRadioName() {
      return _.uniqueId("equipmentAutoInsertRadio");
    },

    fieldsComputed() {
      // ダイアライザの場合
      if (
        this.popoverData.popoverContentSelected.fnValue &&
        //mod FNSI-6829 劉全航 start
        // this.popoverData.popoverContentSelected.fnValue["医療材料分類"] === -1
        this.popoverData.popoverContentSelected.fnValue["医療材料分類"] === "dialyzer"
        //mod FNSI-6829 劉全航 end
        //
      ) {
        return {
          //add FutreNetWeb+SI課題管理 no.6099 劉全航 start
          // cd: parseFloat(this.popoverData.popoverContentSelected.value) || null,
          cd: this.popoverData.popoverContentSelected.cd,
          //add FutreNetWeb+SI課題管理 no.6099 劉全航 end
          // add 9973 -4by kangjie 20231025 start
          // amount: parseFloat(this.amountInputValue.editValue) || null,
          amount: this.amountInputValue.editValue? this.amountInputValue.editValue+"" : "1",
          // add 9973 -4by kangjie 20231025 end
          unit: null,
          autoInsertValue: this.autoInsertValue,
          needleType:
            parseFloat(this.popoverData.popoverContentSelected.needle) || null,
          equipType: 1
        };
      }
      // 医療材料の場合
      else {
        return {
          //7155-------------------------ljg    start
          cd: this.cdTest || null,
          //7155-------------------------ljg    end
          // add 9973 -4by kangjie 20231025 start
          // amount: parseFloat(this.amountInputValue.editValue) || null,
          amount: this.amountInputValue.editValue? this.amountInputValue.editValue+"" : "1",
          // add 9973 -4by kangjie 20231025 end
          unit: this.unitLabelValue,
          autoInsertValue: this.autoInsertValue,
          needleType:
            parseFloat(this.popoverData.popoverContentSelected.needle) || null,
          equipType: 0
        };
      }
    },
    tipsText() {
      if (this.isCreate) {
        return {
          on: [
            "追加する医療材料がない治療予定の場合、設定内容を追加する。",
            "追加する医療材料がある治療予定の場合、元の数量のままとする。"
          ],
          off: [
            "追加する医療材料がない治療予定の場合、設定内容を追加する。",
            "追加する医療材料がある治療予定の場合、数量を加算する。"
          ]
        };
      } else {
        return {
          on: [
            "対象の医療材料がない治療予定の場合、設定内容を追加する。",
            "対象の医療材料がある治療予定の場合、設定内容通り変更する。"
          ],
          off: [
            "対象の医療材料がない治療予定の場合、設定内容を追加しない。",
            "対象の医療材料がある治療予定の場合、設定内容通り変更する。"
          ]
        };
      }
    },
    checkBoxLabel() {
      if (this.isCreate) {
        return {
          label: "追加方式",
          off: "全追加",
          on: "穴埋め追加"
        };
      } else {
        return {
          label: "編集方式",
          off: "補填なし編集",
          on: "補填あり編集"
        };
      }
    }
  },

  watch: {
    fieldsComputed(data) {
      this.$emit("input", data);
    },
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
    getIndStartDate(){
      this.createPopoverData();
      // this.changeEquipSelectList();
    },
    getIndEndDate(){
      this.createPopoverData();
      // this.changeEquipSelectList();
    }
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
  },
  //7155-------------------------ljg    start
  async created(){
    // mod 画面のエーラを処理する　徐博 start
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // this.equipmentDatatest1 = await equipment(this.facilityCd).catch(error => {
    //   throw error;
    // });
    this.equipmentDatatest1 = await equipmentIncludeDeleted(this.facilityCd).catch(error => {
      throw error;
    });
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    const equip66 = this.equipmentDatatest1.find(item => {
      return item.equipmentCd === this.fieldsData.cd;
    });
    if (equip66 != undefined) {
      this.equipmentInputValue.editValue =equip66.equipmentName;
      this.equipmentInputValue.initValue =equip66.equipmentName;
      this.unitLabelValue=equip66.unit;
      this.cdTest=this.fieldsData.cd;
      this.popoverData.popoverContentSelected.text=equip66.equipmentName;
      this.popoverData.popoverContentSelected.unit=equip66.unit;
      this.popoverData.popoverContentSelected.value=this.fieldsData.cd;
    }
    // mod 画面のエーラを処理する　徐博 end
  },
  //7155-------------------------ljg    end
  async mounted() {
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    if (this.settingIndData.ordNo) {
        this.currentOrdMainData = await ApiHelper.get(`/mainData/getOrdMainByOrdNo/${this.settingIndData.ordNo}`)
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    await this.createPopoverData();
    const selectedMst = this.popoverData.popoverContentDataset.find(item => {
      // ダイアライザの場合
      if (this.fieldsData.equipType === 1) {
        return (
          //mod FNSI-6829 劉全航 start
          // item.cd === this.fieldsData.cd && item.fnValue["医療材料分類"] === -1
          item.cd === this.fieldsData.cd && item.fnValue["医療材料分類"] === "dialyzer"
          //mod FNSI-6829 劉全航 end
        );
      }
      // 医療材料の場合
      else {
        return item.value === this.fieldsData.cd;
      }
    });
    if (selectedMst) {
      this.equipmentInputValue.initValue = selectedMst.text;
      this.equipmentInputValue.editValue = selectedMst.text;
      this.popoverData.popoverContentSelected = selectedMst;
      this.unitLabelValue = selectedMst.unit;
    }
    this.checkMstDispStatus();
  },

  methods: {
    ...mapActions('loading-screen', [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    /**
     * @description  ポップオーバーを表示する前に、必要なデータを取得して、
     *               ポップオーバー用フォーマットをコンバートする
     */
    async createPopoverData() {
      // 選択中のダイアライザ/医療材料のIDを取得
      let selectedDialyzerCd = null;
      let selectedEquipmentCd = null;
      if (this.fieldsData.equipType === 0) {
        selectedEquipmentCd = this.fieldsData.cd;
      } else if (this.fieldsData.equipType === 1) {
        selectedDialyzerCd = this.fieldsData.cd;
      } else {
        // this.fieldsData.equipType が存在しない(追加時)
        if (!isNaN(this.fieldsData.cd)) {
          selectedEquipmentCd = this.fieldsData.cd;
        } else if (this.fieldsData.cd.indexOf("dialyzer") > -1) {
          // this.fieldsData.cd に "dialyzer" の文字が入っていたらダイアライザ
          selectedDialyzerCd = this.fieldsData.cd.split("dialyzer")[1];
        }
      }
      const tmpEquipmentData = this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? await equipment(this.facilityCd) : await equipmentAllergy(this.selectedPatId, true);
      let equipmentData = tmpEquipmentData;
      // 患者経過総合ビューア(予定)表示時は、予定範囲と薬剤の使用期限を見て表示内容を補正する
      //mod FNSI-5485 劉全航 start
      // if (this.$router.currentRoute.name === PATVIEWER_CURRENT_ROUTE_NAME) {
      //   equipmentData = tmpEquipmentData.filter(equipment => {
      //     return fitTermCheck(equipment.useStartDate, equipment.useEndDate, this.getIndStartDate) || equipment.equipmentCd === selectedEquipmentCd;
      //   });
      // }
      //mod FNSI-5485 劉全航 end
      const classData = await equipmentClass(this.facilityCd);

      this.equipmentDataset = equipmentData;

      // ポップオーバのフィルタデータを取りまとめる
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd
        };
      };

      const filterArr = classData.map(filterMapping);
      if (this.showAllSelectTag) {
        //mod FNSI-6937 劉全航 start
        // filterArr.unshift({ text: "すべて", value: 0 });
        filterArr.unshift(
          { text: "すべて", value: 0 },
          { text: "未登録", value: -1}
        );
        //nod FNSI-6937 劉全航 end
      }

      // ポップオーバのコンテンツデータ(フィルターしたデータ)を取りまとめる
      //mod FNSI-5485 劉全航 start
      // const contentParamIsDisp = item => {
      //   return item.isDisp === "1";
      // };
      //mod FNSI-5485 劉全航 end
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let rstName = "";
      if (
        this.$router.currentRoute.name === PATVIEWER_CURRENT_ROUTE_NAME &&
        this.currentOrdMainData && 
        this.currentOrdMainData.data && 
        this.currentOrdMainData.data.rstDialysisState != 0
      ) {
        const rstEquipInfo = this.currentOrdMainData.data.indEquipInfo;
        const rstEquipInfoArr = rstEquipInfo ? JSON.parse(rstEquipInfo) : [];
        const rstEquipInfoArrInfo = rstEquipInfoArr.find(item => item.cd == this.fieldsData.cd);
        rstName = rstEquipInfoArrInfo && rstEquipInfoArrInfo.name ? rstEquipInfoArrInfo.name : "";
      }
      
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      const contentMapping = item => {
        return {
          value: item.equipmentCd,
          fnValue: {
            医療材料分類: item.classCd
          },
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: item.equipmentName,
          text: rstName && item.equipmentCd == this.fieldsData.cd ? rstName : getPrefix({treatDate: this.getIndStartDate, ...item}) + item.equipmentName,
          isDisp: item.isDisp,
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          unit: item.unit
        };
      };
      var contentArr = equipmentData
        //mod FNSI-5485 劉全航 start
        // .filter(contentParamIsDisp)
        //mod FNSI-5485 劉全航 end
        .map(contentMapping);

      if (this.hasDialyzerOption) {
        // ダイアライザをフィルタデータに追加
        filterArr.push({
          text: "ダイアライザ",
          //mod FNSI-6829 劉全航 start
          // value: -1
          value: "dialyzer"
          //mod FNSI-6829 劉全航 end
        });
        //#8484　医療材料選択IFのリスト不正　Start
        const tmpDialyzer = this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ?
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // await dialyzer(this.facilityCd) : await dialyzerTabooAllergyIncludeDeleted(this.selectedPatId);
        await dialyzer(this.facilityCd) : await dialyzerTabooAllergyDeleted(this.selectedPatId);
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        this.dialyzerDataset = tmpDialyzer;
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // const tmpmstEquipment = await equipmentTabooAllergyIncludeDeleted(this.selectedPatId);
        const tmpmstEquipment = await equipmentAllergy(this.selectedPatId, true);
        // tmpmstEquipment.forEach(o => {
        //   if (o.isDisp === "0") {
        //     o.equipmentName = `【削除済み】${o.equipmentName}`;
        //   }
        //   if (!fitTermCheck(o.useStartDate, o.useEndDate, this.getIndStartDate)) {
        //     o.equipmentName = `【期限切れ】${o.equipmentName}`;
        //   }
        // });
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        this.equipment = tmpmstEquipment;
        // 削除済み・期限切れの医療材料を除外:但し選択中除く
        if (this.$router.currentRoute.name === PATVIEWER_CURRENT_ROUTE_NAME) {
          this.equipment = tmpmstEquipment.filter(item => {
            if (selectedEquipmentCd === item.equipmentCd || (item.isDisp === "1" && fitTermCheck(item.useStartDate, item.useEndDate, this.getIndStartDate))) {
              return item;
            }
          });
          contentArr = this.equipment.map(contentMapping);
        }
        //#8484　医療材料選択IFのリスト不正　End
        // 患者経過総合ビューア(予定)表示時は、予定範囲と薬剤の使用期限を見て表示内容を補正する
        if (this.$router.currentRoute.name === PATVIEWER_CURRENT_ROUTE_NAME) {
          this.dialyzerDataset = tmpDialyzer.filter(dialyzer => {
            return fitTermCheck(dialyzer.useStartDate, dialyzer.useEndDate, this.getIndStartDate) || dialyzer.dialyzerCd === selectedDialyzerCd;
          });
        }
        //#8484　医療材料選択IFのリスト不正　Start
        // ダイアライザの期限済み、削除済みを判定 接頭辞に付加する。
        // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // if (this.$router.currentRoute.name === PATVIEWER_CURRENT_ROUTE_NAME) {
        //   this.dialyzerDataset.forEach(item => {
        //     if (item.isDisp === "0") {
        //       item.modelNumber = `【削除済み】${item.modelNumber}`;
        //     }
        //     if (!fitTermCheck(item.useStartDate, item.useEndDate, this.getIndStartDate)) {
        //       item.modelNumber = `【期限切れ】${item.modelNumber}`;
        //     }
        //   });
        // }
        // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        //#8484　医療材料選択IFのリスト不正　End
        // ダイアライザをコンテンツデータに追加
        const contentDialyzer = this.dialyzerDataset
          .filter(item => {
            //#8484　医療材料選択IFのリスト不正　Start
            // 削除済みは選択中のみ対象
            return item.isDisp === "1"
              || (item.isDisp === "0" && selectedDialyzerCd === item.dialyzerCd);
            //#8484　医療材料選択IFのリスト不正　End
          })
          .map(item => {
            return {
              // 医療材料と競合するため、マスター選択用値を作って使用
              value: `dialyzer${item.dialyzerCd}`,
              cd: item.dialyzerCd,
              fnValue: {
                //mod FNSI-6829 劉全航 start
                // 医療材料分類: -1
                医療材料分類: "dialyzer"
                //mod FNSI-6829 劉全航 end
              },
              // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
              // text: item.modelNumber
              text: rstName && item.equipmentCd == this.fieldsData.cd ? rstName : getPrefix({treatDate: this.getIndStartDate, ...item}) + item.modelNumber,
              isDisp: item.isDisp,
              // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            };
          });

        contentArr.push(...contentDialyzer);
      }

      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      contentArr = contentArr.sort(function (a, b) {
        return b.isDisp - a.isDisp;
      });
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

      this.popoverData.popoverTitleHeader = "医療材料";
      this.popoverData.popoverFilter = [
        {
          popoverFilterLabel: "医療材料分類",
          popoverFilterDataset: filterArr
        }
      ];
      this.popoverData.popoverContentLabel = "医療材料名";
      this.popoverData.popoverContentDataset = contentArr;
      this.EquipmentList = contentArr;
      //#10126:医療材料選択IF追加修正 Start
      this.popoverData.hasUnregisteredOption = false
      //#10126:医療材料選択IF追加修正 End

      //mod FNSI-5485 劉全航 start
      //add 患者経済総合ビューア（計画）_医療材料：予定日医療材料を選択する場合、編集対象はマスターのデータを取る ztc 20230606 start
      if (this.isCreate === false && this.showEquipmentFieldOnly) {
      //add 患者経済総合ビューア（計画）_医療材料：予定日医療材料を選択する場合、編集対象はマスターのデータを取る ztc 20230606 end
        // this.searchPatEquipment();
        let startDate = Number(this.getIndStartDate.replaceAll("-", ""));
        //mod FNSI-8681 ljx start
        let patId = this.selectedPatId == null ? 0 : this.selectedPatId;
        const response = await ApiHelper.get(
          "/mainData/getEquipmentListByPatId",
          // { patId: this.selectedPatId, facilityCd: this.facilityCd, treatDate: startDate }
          { patId: patId, facilityCd: this.facilityCd, treatDate: startDate }
        );
        //mod FNSI-8681 ljx end
        let endDate = "";
        if (this.getIndEndDate === "") {
          let treatDateList = this.$parent.$parent.$parent.$parent.treatDateListAll;
          endDate = treatDateList[treatDateList.length - 1];
        } else {
          endDate = Number(this.getIndEndDate.replaceAll("-", ""));
        }
        let cdList = [];
        let map = new Map(Object.entries(response.data));
        for (let key of Object.keys(response.data)) {
          let dayList = [];
          dayList = map.get(key);
          if (dayList.find(d => d <= endDate && d >= startDate)) {
            cdList.push(Number(key));
          }
        }
        if (!cdList.includes(this.fieldsData.cd)) {
          this.equipmentInputValue.initValue = "";
          this.equipmentInputValue.editValue = "";
        } else {
          this.equipmentInputValue.initValue = this.popoverData.popoverContentSelected.text;
          this.equipmentInputValue.editValue = this.popoverData.popoverContentSelected.text;
        }
        this.popoverData.popoverContentDataset = this.EquipmentList.filter(function (item) {
          //add FutreNetWeb+SI課題管理 no.6099 劉全航 start
          if (item.fnValue["医療材料分類"] === "dialyzer") {
            let dialyzerCd = Number((item.value + "").replace("dialyzer", ""));
            return cdList.includes(dialyzerCd);
          }
          //add FutreNetWeb+SI課題管理 no.6099 劉全航 end
          return cdList.includes(item.value);
        });
      }
      //mod FNSI-5485 劉全航 end
    },
    checkMstDispStatus() {
      if (this.fieldsData.cd === null) {
        return;
      }
      //mod FNSI-5485 劉全航 start
      // const mst =
      //   this.fieldsData.equipType === 1
      //     ? this.dialyzerDataset.find(item => {
      //         return item.dialyzerCd === this.fieldsData.cd;
      //       })
      //     : this.equipmentDataset.find(item => {
      //         return item.equipmentCd === this.fieldsData.cd;
      //       });

      // if (mst && mst.isDisp === "0") {
      //   this.equipmentInputValue.initValue = "削除済み";
      //   this.equipmentInputValue.editValue = "削除済み";
      // }
      //mod FNSI-5485 劉全航 end
    },

    /**
     * @description マスター選択を表示
     */
    showPopover() {
      this.popoverData.popoverVisible = true;
    },

    /**
     * @description マスター選択を非表示
     */
    closePopover() {
      this.popoverData.popoverVisible = false;
    },

    /**
     * @description マスター選択から選択後コールバック
     */
    updateInput(data) {
      const equip = this.equipmentDataset.find(item => {
        return item.equipmentCd === data.value;
      });

      this.popoverData.popoverContentSelected = data;
      this.equipmentInputValue.editValue = data.text || null;
      this.unitLabelValue = equip && equip.unit;
      //7155-------------------------ljg    start
      this.cdTest=data.value;
      //7155-------------------------ljg    end
    },

    /**
     * @description APIにリクエストする
     */
    async updateIndInfo(structData, targetEdit = null, targetEditType = null) {
      console.log("IndEquipmentEdit.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // mod FNSI-指示編集でDB登録データの更新 楊 start
      // 指示者ドロップダウンの設定
      let doctorList = structData.userOptions;
      const doctor = doctorList.find(doctor => doctor.user_id === Number(structData.indUser));
      // mod FNSI-指示編集でDB登録データの更新 楊 end

      /* del by chamaojia 2024-01-22 [10196] Value error, changed to Java query  --start */
      // #9973 added by Zhou.tao fix missing update user info Start
      // let updDoc = doctorList.find(d => d.user_id === Number(structData.updUser));
      // #9973 added by Zhou.tao fix missing update user info Start
      /* del by chamaojia 2024-01-22 [10196] Value error, changed to Java query  --end */

      /* modify by chamaojia 2024-01-22 [10196] Default value setting error correction  --start */
      const indInfo = {
        // class_cd: null,
        // class_name: null,
        // class_type: null,
        cd: this.fieldsComputed.cd,
        // name: this.equipmentInputValue.editValue,
        // short_name: null,
        // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 start
        // needle_type: this.fieldsComputed.needleType,
        // del #11586 治療記録＞医療材料にてダイアライザを追加すると保存できない。 関 end
        // mod #11311 編集箇所のみ保存の再精査 zkm start
        // amount: this.fieldsComputed.amount,
        ...(1 !== structData.flag && structData.editOnly && this.fieldsComputed.amount == this.amountInputValue.initValue ? {} : { amount: this.fieldsComputed.amount }),
        // mod #11311 編集箇所のみ保存の再精査 zkm end
        // unit: this.unitLabelValue,
        ind_user_id: structData.indUser,
        // mod FNSI-指示編集でDB登録データの更新 楊 start
        // ind_user_last_name: null,
        // ind_user_first_name: null,
        ind_user_last_name: doctor.user_last_name,
        ind_user_first_name: doctor.user_first_name,
        // mod FNSI-指示編集でDB登録データの更新 楊 end
        upd_user_id: structData.updUser,

        // #9973 added by Zhou.tao fix missing update user info Start
        upd_user_last_name: null,
        upd_user_first_name: null,
        // upd_user_last_name: updDoc.user_last_name,
        // upd_user_first_name: updDoc.user_first_name,
        // #9973 added by Zhou.tao fix missing update user info End

        input_class: 1,
        is_editable: "1",
        cop_order_no: null,
        equip_type: this.fieldsComputed.equipType
      };
      /* modify by chamaojia 2024-01-22 [10196] Default value setting error correction  --start */

      const sendJson = {
        pat_id: structData.patId,
        facility_cd: this.facilityCd,
        start_date: structData.indStartDate,
        end_date: structData.indEndDate,
        weeks: JSON.stringify(structData.indWeeks),
        ind_kur_cd: JSON.stringify(structData.selectedKur),
        ind_treatment_cd: JSON.stringify(structData.selectedTreat),
        ind_info: JSON.stringify(indInfo),
        // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start
        send_equip_info: JSON.stringify({amount: this.amountInputValue.initValue+"", edit_only: structData.editOnly}),
        // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm end
        auto_insert: this.autoInsertValue.editValue,
        target_equip_edit: targetEdit,
        is_edit_other_amount: this.fieldsComputed.cd !== targetEdit,
        is_deadline: structData.isDeadline,
        target_equip_edit_type: targetEditType,
        // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
        is_rst_update: false,
        // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
        //add #10266 start
        update_flag: this.settingIndData.update_flag
        //add #10266 end
      };

      // 古いリスト
      const startDate = structData.indStartDate.replace(/-/g, '');
      const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      const searchData = await ApiHelper.get(
        `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndEquipmentEdit.vue', 'updateIndInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        console.log("IndEquipmentEdit.vue updateIndInfo throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });
      this.oldOrdMainList = searchData.data;

      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
      let weekList = [];
      structData.indWeeks.forEach(eleItem => {
        if (eleItem.done === true) {
          weekList.push(parseInt(eleItem.value));
        }
      });
      if (this.oldOrdMainList) {
        // 実績があるフラグ
        let isRstHave = false;

        if (structData.flag === 1 && this.$parent.$parent.$parent.$parent.isRstUpdateFlg === true) {
          // 複数が追加された場合、且つ 実績の変更をする確認した場合
          sendJson.is_rst_update = true;
        }else {
          this.oldOrdMainList.forEach(item => {
            const isSelectedTreat = structData.selectedTreat.length > 0 ? structData.selectedTreat.includes(parseInt(item.indTreatmentCd)) : true;
            const isSelectedKur = structData.selectedKur.length > 0 ? structData.selectedKur.includes(parseInt(item.indKurCd)) : true;
            const isTreatWeek = weekList.length > 0 ? weekList.includes(parseInt(item.treatWeek)) : true;
            if (item.rstDialysisState !=="0" && isSelectedTreat && isSelectedKur && isTreatWeek) {
              isRstHave = true;
            }
          });
          //mod 7114 治療中の透析指示の投与薬剤、医療材料、指示コメント削除を実施した場合の注意メッセージがない 張 start
          // if (isRstHave && (structData.flag === 1 || structData.flag === 2) && !this.$parent.$parent.$parent.$parent.isShowedMessage) {
            if (isRstHave && (structData.flag === 1 || structData.flag === 2|| structData.flag === 3) && !this.$parent.$parent.$parent.$parent.isShowedMessage) {
            //mod 7114 治療中の透析指示の投与薬剤、医療材料、指示コメント削除を実施した場合の注意メッセージがない 張 end

              //mod #10266  start
              // if (await this.showUpdateCheckDialog(structData.flag)) {
              if (this.settingIndData.update_flag != "2" && await this.showUpdateCheckDialog(structData.flag)) {
                //mod #10266  end

                sendJson.is_rst_update = true;
                if (structData.flag === 1) {
                  this.$parent.$parent.$parent.$parent.isRstUpdateFlg = true;
                }
              // mod #10266  end
              // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 start
            }else{
             sendJson.is_rst_update =  false;
            }
            // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end
          }
        }
      }
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
      // add FNSI-連携イベントの登録適正化 楊 start
      // let opeCd = "";
      // let response = null;
      /* modify by chamaojia 2023-08-07 [9303] この判断条件は必要ない  --start */
      // if (structData.nLstFlg != 1) {
      sendJson.hosp_pat_id = this.selectedPat.pat_personal_main.hosp_pat_id;
      sendJson.user_id = this.getStateUserAccountInfo.userId;
      // }
      /* modify by chamaojia 2023-08-07 [9303] この判断条件は必要ない  --end */
      let response = null;
      // add FNSI-連携イベントの登録適正化 楊 end
      switch (structData.flag) {
        case 1:
          /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---start */
          // await ApiHelper.post(
          //   "/mainData/createOrdMainEquipInfo/",
          //   sendJson
          // ).catch(error => {
          //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          //   getErrorMessage('IndEquipmentEdit.vue', 'updateIndInfo', error);
          //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          //   throw error;
          // });
          console.log("IndEquipmentEdit.vue updateIndInfo return sendJson; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return sendJson;
        /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---end */
        case 2:
          // mod FNSI-連携イベントの登録適正化 楊 start
          // await ApiHelper.post(
          //   "/mainData/updateOrdMainEquipInfo/",
          //   sendJson
          // ).catch(error => {
          //   throw error;
          // });

          //#11397 Add
          let getSettingData = this.settingIndData;
          let allList = this.getAllData;
          if(getSettingData&&getSettingData.ordNo&&allList){
            function getNewNo(allList, tOrdNo, tCd) {
              for (let i = 0; i < allList.length; i++) {
                const item = allList[i];
                if (item.ordNo !== tOrdNo) continue;
                const rstList = JSON.parse(item.rstEquipInfo || "[]");
                for (let k = 0; k < rstList.length; k++) {
                  const rst = rstList[k];
                  if (rst.cd === tCd && rst.no != null && rst.no !== "") {
                    return rst.no;
                  }
                }
                const indList = JSON.parse(item.indEquipInfo || "[]");
                for (let j = 0; j < indList.length; j++) {
                  const ind = indList[j];
                  if (ind.cd === tCd && ind.no != null && ind.no !== "") {
                    return ind.no;
                  }
                }
                return "";
              }
              return "";
            }
            let tOrdNo = getSettingData.ordNo;
            let get_ind_info = JSON.parse(sendJson.ind_info)
            let tCd = get_ind_info.cd;
            let getNo = getNewNo(allList,tOrdNo, tCd);
            if(getNo){
              get_ind_info.no = getNo
            }
            sendJson.ind_info = JSON.stringify(get_ind_info)
          }
          //#11397 end

          // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start
          if (structData.type && 'equip-update' === structData.type) {
            response = await ApiHelper.post(
              "/patients/equip/update",
              sendJson
            ).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('IndEquipmentSet.vue', 'updateIndInfo', error);
              console.log("IndTreatMethod.vue updateIndInfo throw error; this.finishLoadingScreen();");
              this.finishLoadingScreen();
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              throw error;
            });
          } else {
            // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm end
            response = await ApiHelper.post(
              "/mainData/updateOrdMainEquipInfo/",
              sendJson
            ).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('IndEquipmentEdit.vue', 'updateIndInfo', error);
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              console.log("IndEquipmentEdit.vue updateIndInfo throw error; this.finishLoadingScreen();");
              this.finishLoadingScreen();
              throw error;
            });
          }
            // opeCd = "004027";
          // mod FNSI-連携イベントの登録適正化 楊 end
          break;
        case 3:
          // mod FNSI-連携イベントの登録適正化 楊 start
          // await ApiHelper.post(
          //   "/mainData/deleteOrdMainEquipInfo/",
          //   sendJson
          // ).catch(error => {
          //   throw error;
          // });
          response = await ApiHelper.post(
            "/mainData/deleteOrdMainEquipInfo/",
            sendJson
          ).catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('IndEquipmentEdit.vue', 'updateIndInfo', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            console.log("IndEquipmentEdit.vue updateIndInfo throw error; this.finishLoadingScreen();");
            this.finishLoadingScreen();
            throw error;
          });

          // opeCd = "004028";
          // mod FNSI-連携イベントの登録適正化 楊 end
          break;
        default:
          // 該当なし
          break;
      }

      // mod FNSI-連携イベントの登録適正化 楊 start
      // ビューア画面の医療材料モーダルより内容を修正し保存した時
      //   const params = {
      //     facility_cd: this.facilityCd,
      //     coop_cd: "ind_dial",
      //     coop_cd_index: "",
      //     crud: "U",
      //     direction: "S",
      //     ana_result:"0",
      //     coop_result:"0",
      //     pat_id : structData.patId,
      //     ord_no : this.settingIndData.ordNo,
      //     user_id: this.getStateUserAccountInfo.userId
      //   };
      //   if (this.settingIndData.ordNo) {
      //     createJournal(params);
      //   } else {
      //     if (this.oldOrdMainList) {
      //       this.oldOrdMainList.forEach(item => {
      //         const isSelectedTreat = structData.selectedTreat.includes(item.indTreatmentCd);
      //         const isSelectedKur = structData.selectedKur.includes(item.indKurCd);
      //         if (structData.selectedKur.length > 0) {
      //           if (isSelectedKur) {
      //             createJournal({...params, ord_no: item.ordNo});
      //           }
      //         } else {
      //           if (structData.selectedTreat.length > 0) {
      //             if (isSelectedTreat) {
      //               createJournal({...params, ord_no: item.ordNo});
      //             }
      //           } else {
      //             createJournal({...params, ord_no: item.ordNo});
      //           }
      //         }
      //       });
      //     }
      //   }
      // },
      // if (200 === response.status) {
      //   const params = {
      //     ope_cd: "",
      //     crud: "U",
      //     facility_cd: this.facilityCd,
      //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //     pat_id: structData.patId,
      //     ord_no: this.settingIndData.ordNo,
      //     base_date: "",
      //     user_id: this.getStateUserAccountInfo.userId
      //   };
      //   if (this.settingIndData.ordNo) {
      //     // 変更対象クールが未登録ではないの場合、外部連携APIを呼び出す
      //     if (this.oldOrdMainList[0].indKurCd !== null && this.oldOrdMainList[0].indKurCd !== 0) {
      //       createJournal({...params, base_date: this.oldOrdMainList[0].treatDate, ope_cd: opeCd});
      //     }
      //   } else {
      //     if (this.oldOrdMainList) {
      //       this.oldOrdMainList.forEach(item => {
      //         const isSelectedTreat = structData.selectedTreat.includes(item.indTreatmentCd);
      //         const isSelectedKur = structData.selectedKur.includes(item.indKurCd);
      //         if (structData.selectedKur.length > 0) {
      //           if (isSelectedKur) {
      //             if (item.indKurCd !== null && item.indKurCd !== 0) {
      //               createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate, ope_cd: opeCd});
      //             }
      //           }
      //         } else {
      //           if (structData.selectedTreat.length > 0) {
      //             if (isSelectedTreat) {
      //               if (item.indKurCd !== null && item.indKurCd !== 0) {
      //                 createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate, ope_cd: opeCd});
      //               }
      //             }
      //           } else {
      //             if (item.indKurCd !== null && item.indKurCd !== 0) {
      //               createJournal({...params, ord_no: item.ordNo, base_date: item.treatDate, ope_cd: opeCd});
      //             }
      //           }
      //         }
      //       });
      //     }
      //   }
      // }
      console.log("IndEquipmentEdit.vue updateIndInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
      return response;
    },
    // mod FNSI-連携イベントの登録適正化 楊 end

    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
    // 条件送信以降の場合、実績の変更をするか確認する。
    async showUpdateCheckDialog(flag) {
        let rtn = false;
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000050].title,
          // message: "条件送信済みまたは治療中、治療終了後の指示を変更しました。<br>" +
          //          "実績データへの反映をしますか？",
          message: messageFormat(DIALOG_MESSAGES[13000050].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              rtn = true;
              // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 start
            }else{
              rtn = false;
            }
            // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end
          }
        });
        if (flag ===1) {
          // 薬剤を追加した場合
          this.$parent.$parent.$parent.$parent.isShowedMessage = true;
        }

        return rtn;
    },
    // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end

    /**
     * 変更箇所
     */
    checkEdit() {
      let changeCount = 0;
      if (
        this.equipmentInputValue.initValue !==
        this.equipmentInputValue.editValue
      ) {
        changeCount++;
      }
      if (this.amountInputValue.initValue !== this.amountInputValue.editValue) {
        changeCount++;
      }
      return 0 !== changeCount ? true : false;
    },
    /**
     * 吹き出し表示処理
     */
    showTipsPopOver(event, message) {
      this.viewTipsTexts = message;
      this.userMenuPopoverTarget = event;
      this.userMenuPopoverVisible = true;
    },
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 start
    async changeEquipSelectList(){
      if(this.isCreate === false) {
        // this.searchPatEquipment();
        let startDate = Number(this.getIndStartDate.replaceAll("-", ""));
        //mod FNSI-8681 ljx start
        let patId = this.selectedPatId == null?0:this.selectedPatId;
        var response = await ApiHelper.get("/mainData/getEquipmentListByPatId",
        //{patId: this.selectedPatId, facilityCd: this.facilityCd, treatDate: startDate});
        {patId: patId, facilityCd: this.facilityCd, treatDate: startDate});
        //mod FNSI-8681 ljx end
        let endDate = "";
        if (this.getIndEndDate === "") {
          let treatDateList = this.$parent.$parent.$parent.$parent.treatDateListAll;
          endDate = treatDateList[treatDateList.length - 1];
        } else {
          endDate = Number(this.getIndEndDate.replaceAll("-", ""));
        }
        let cdList = [];
        let map = new Map(Object.entries(response.data));
        for (let key of Object.keys(response.data)) {
          let dayList = [];
          dayList = map.get(key);
          if (dayList.find(d => d <= endDate && d >= startDate)) {
            cdList.push(Number(key));
          }
        }
        if(!cdList.includes(this.fieldsData.cd)){
          this.equipmentInputValue.initValue = "";
          this.equipmentInputValue.editValue = "";
        }else{
          this.equipmentInputValue.initValue = this.popoverData.popoverContentSelected.text;
          this.equipmentInputValue.editValue = this.popoverData.popoverContentSelected.text;
        }
        this.popoverData.popoverContentDataset = this.EquipmentList.filter(function (item) {
          //add FutreNetWeb+SI課題管理 no.6099 劉全航 start
          if (item.fnValue["医療材料分類"] === "dialyzer") {
            let dialyzerCd = Number((item.value + "").replace("dialyzer", ""));
            return cdList.includes(dialyzerCd);
          }
          //add FutreNetWeb+SI課題管理 no.6099 劉全航 end
          return cdList.includes(item.value);
        });
      }
    }
    //add FutreNetWeb+SI課題管理 no.5485 劉全航 end
  }
};
</script>

<style scoped>
.row-style {
  margin: 2.5px 0px;
}

.equipment-input-style {
  width: 70%;
  margin: 0px 5px 0px 0px;
}

.amount-input-style {
  width: 50px;
}

.equipment-column {
  /* add FNSI-薬剤指示画面等の画面崩れの修正 楊 start */
  /*flex: 0 0 30%;*/
  flex: 0 0 9.4em;
  /* add FNSI-薬剤指示画面等の画面崩れの修正 楊 end */
  max-width: 30%;
  white-space: normal;
  margin: auto;
}

.equipment-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}
.help-area {
  margin: 10px;
}
.help-area label {
  font-size: 1.5em;
}
#icon-1 {
  margin-right: 0.5em;
}
/* add FNSI-薬剤指示画面等の画面崩れの修正 楊 start */
.ntss-custom-input-cond {
  height: 2em;
  font-size: inherit;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  display: inline-flex;
}
/* add FNSI-薬剤指示画面等の画面崩れの修正 楊 end */
</style>
