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
      <v-ons-col class="equipment-data-column equipment-selector-column">
        <common-master-selector
          class="equipment-master-selector-stretch"
          :masterType="MasterType.EQUIPMENT_TREATMENT_RECORD"
          :initItem="masterSelectorInitItem"
          :editItem="masterSelectorEditItem"
          :extraParams="masterSelectorExtraParams"
          :patientId="selectedPatId"
          :facilityCd="facilityCd"
          :dialysisState="Number(rstDialysisState || 0)"
          :hasChangedOption="true"
          :changeOptionMode="'nameAndUnit'"
          :hasUnregisteredOption="false"
          :selectedItemClass="'equipment-input-style'"
          :backgroundColor="'#ebebe4'"
          :btnClass="'common-style-select-button'"
          :btnDisabled="!getItemAuthorized('Indication', 'default_authority')"
          @popover-return="masterUpdateInput($event);"
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
          :initVal="amountInputValue.initValue"
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
      v-model:visible="userMenuPopoverVisible"
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
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapGetters,mapActions } from "@/compat/vue/vuex";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import _ from "@/compat/collections/lodash";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
import customRadio from "@/components/common/custom-form-tags/CustomRadio";
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import {EventBus} from "@/compat/vue/event-bus.js";
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";

import IndicationOwnerMixin from '@/components/indication/IndicationOwnerMixin';
import { messageFormat } from "@/functions/common/MessageFormat";
// add #9848+9849 数値IFのスタイル全不正 linjunfeng end
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { buildMasterPopover } from "@/components/common/master-selector/builder/builderFactory";

export default {
  mixins: [IndicationOwnerMixin, PopoverMixin],

  components: {
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-radio": customRadio,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    "custom-input-number-pro": CustomInputNumberPro,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
    "common-master-selector": commonMasterSelector,
  },

  // 親が @input リスナで使用するため input を明示宣言する。
  emits: ["input"],

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
      MasterType,
      /** マスタ一覧の表示名（【名前変更】比較用・実績名と分離） */
      masterLabelForCd: null,
      /** マスタ側の単位（【単位変更】比較用・実績単位と分離） */
      masterUnitForCd: null,
      /** 実績側に保存された単位（editItem.unit・選択で更新） */
      rstUnitForCd: null,
      /** indEquipInfo から解凍した実績単位（initItem.unit のみ。選択では更新しない） */
      rstUnitBaselineForCd: null,
      /** common-master-selector の initItem 用（実績名） */
      rstNameForCd: null,
      /**
       * @description 「ダイアライザ」マスターデータ
       */
      dialyzerDataset: [],

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

    rstDialysisState() {
      // 実績判定は viewer では currentOrdMainData を優先する。
      const cur =
        this.currentOrdMainData &&
        this.currentOrdMainData.data &&
        this.currentOrdMainData.data.rstDialysisState;
      if (cur != null && String(cur) !== "") return cur;
      const om = this.settingIndData && this.settingIndData.orderMainData;
      return om && om.rstDialysisState != null ? om.rstDialysisState : 0;
    },
    isActualRst() {
      return Number(this.rstDialysisState || 0) !== 0;
    },

    uniqueRadioName() {
      return _.uniqueId("equipmentAutoInsertRadio");
    },

    masterSelectorValue() {
      return this.fieldsData && this.fieldsData.cd;
    },

    masterSelectorInitItem() {
      return {
        text: this.isActualRst
          ? (this.rstNameForCd != null && this.rstNameForCd !== ""
              ? this.rstNameForCd
              : (this.equipmentInputValue ? this.equipmentInputValue.editValue : null))
          : (this.equipmentInputValue ? this.equipmentInputValue.initValue : null),
        value: this.masterSelectorValue,
        unit: this.isActualRst
          ? this.rstUnitBaselineForCd != null && this.rstUnitBaselineForCd !== ""
            ? this.rstUnitBaselineForCd
            : this.masterUnitForCd
          : this.masterUnitForCd,
      };
    },

    masterSelectorEditItem() {
      const selectedVal =
        this.popoverData &&
        this.popoverData.popoverContentSelected &&
        this.popoverData.popoverContentSelected.value;
      return {
        text: this.equipmentInputValue ? this.equipmentInputValue.editValue : null,
        value: selectedVal != null ? selectedVal : this.masterSelectorValue,
        unit: this.rstUnitForCd != null && this.rstUnitForCd !== ""
          ? this.rstUnitForCd
          : this.unitLabelValue,
      };
    },

    masterSelectorExtraParams() {
      const equipType = this.fieldsData && this.fieldsData.equipType;
      return {
        treatDate: this.getIndStartDate,
        equipType,
        actualName: this.rstNameForCd,
      };
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
          equipType: this.fieldsData.equipType ?? 0
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
  created(){
    if (this.isCreate && this.applyFieldsDataDisplay()) {
      return;
    }
    // 初期表示は mounted()->createPopoverData() に統一する。
    // created() で raw 名称を入れると、共通マスタセレクタの接頭辞付き候補と差分判定がずれる。
  },
  //7155-------------------------ljg    end
  async mounted() {
    if (this.isCreate && this.applyFieldsDataDisplay()) {
      this.checkMstDispStatus();
      return;
    }
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    if (this.settingIndData.ordNo) {
        this.currentOrdMainData = await ApiHelper.get(`/mainData/getOrdMainByOrdNo/${this.settingIndData.ordNo}`)
    }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    await this.createPopoverData();
    // 初期表示の表示名/単位/選択行は createPopoverData() で確定させる。
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
    masterUpdateInput(val) {
      const isDialyzer =
        val?.key_class === "-2" ||
        val?.key_class === -2 ||
        val?.dialyzerCd != null ||
        val?.dialyzerType != null;

      const mapped = isDialyzer
        ? {
            text: val?.text,
            value: val?.value ?? null,
            cd: val?.value ?? val?.dialyzerCd ?? null,
            fnValue: { 医療材料分類: "dialyzer" },
            unit: val?.unit ?? null,
          }
        : {
            text: val?.text,
            value: val?.value ?? null,
            fnValue: { 医療材料分類: val?.classCd ?? val?.classValue ?? null },
            unit: val?.unit ?? null,
          };

      this.popoverData.popoverContentSelected = mapped;
      this.equipmentInputValue.editValue = mapped.text || null;
      this.unitLabelValue =
        mapped.unit != null && mapped.unit !== "" ? mapped.unit : this.unitLabelValue;
      this.rstUnitForCd =
        mapped.unit != null && mapped.unit !== "" ? String(mapped.unit) : this.rstUnitForCd;
      //7155-------------------------ljg    start
      if (!isDialyzer) {
        this.cdTest = mapped.value;
      }
      //7155-------------------------ljg    end
    },
    /**
     * @description  ポップオーバーを表示する前に、必要なデータを取得して、
     *               ポップオーバー用フォーマットをコンバートする
     */
    async createPopoverData() {
      try {
        const initValue = this.fieldsData ? this.fieldsData.cd : null;
        const rawEquipType = this.fieldsData ? this.fieldsData.equipType : null;
        let normalizedEquipType = null;
        if (rawEquipType === 0 || rawEquipType === "0") {
          normalizedEquipType = 0;
        } else if (rawEquipType === 1 || rawEquipType === "1") {
          normalizedEquipType = 1;
        } else if (typeof initValue === "string" && /^dialyzer/i.test(initValue)) {
          normalizedEquipType = 1;
        }
        const dialysisState = Number(this.rstDialysisState || 0);
        const isActualRst = dialysisState !== 0;

        let rstName = "";
        let rstUnit = "";
        if (
          isActualRst &&
          this.currentOrdMainData &&
          this.currentOrdMainData.data
        ) {
          const rstEquipInfo = this.currentOrdMainData.data.indEquipInfo;
          const rstEquipInfoArr = rstEquipInfo ? JSON.parse(rstEquipInfo) : [];
          const rstRow = rstEquipInfoArr.find(item => String(item.cd) === String(this.fieldsData.cd));
          rstName = rstRow && rstRow.name ? String(rstRow.name) : "";
          rstUnit = rstRow && rstRow.unit ? String(rstRow.unit) : "";
        }

        const context = {
          facilityCd: this.facilityCd,
          patientId: this.selectedPatId,
          extraParams: {
            treatDate: this.getIndStartDate,
            equipType: normalizedEquipType,
            fieldsDataCd: this.fieldsData ? this.fieldsData.cd : null,
            rstNameForCurrentCd: rstName || "",
            actualName: rstName || "",
          },
          initItem: { value: initValue },
          selectedItem: { value: initValue },
          dialysisState,
        };

        const pop = await buildMasterPopover(MasterType.EQUIPMENT_TREATMENT_RECORD, context);
        const baseOptions = pop && pop.master && pop.master.options ? pop.master.options : [];
        const options = (baseOptions || []).map(o => ({
          ...o,
          text:
            rstName &&
            initValue != null &&
            String(o.value) === String(initValue)
              ? String(rstName)
              : o.text,
        }));

        this.popoverData.popoverTitleHeader = pop?.headerTitle ?? "医療材料";
        this.popoverData.popoverContentLabel = pop?.master?.label ?? "医療材料名";
        this.popoverData.popoverContentDataset = options;
        this.EquipmentList = options;
        if (Array.isArray(pop?.categories) && pop.categories.length > 0) {
          this.popoverData.popoverFilter = pop.categories.map(c => ({
            popoverFilterLabel: c.label,
            popoverFilterDataset: c.options
          }));
        }

        const matchByTypeAndValue = (o) => {
          if (String(o?.value) !== String(initValue)) return false;
          if (normalizedEquipType == null) return true;
          const isDialyzer = o?.key_class === "-2" || o?.key_class === -2;
          return normalizedEquipType === 1 ? isDialyzer : !isDialyzer;
        };
        const fallbackSelected = pop?.master?.selectedItem || null;
        const selected =
          options.find(matchByTypeAndValue) ||
          options.find(o => String(o?.value) === String(initValue)) ||
          (fallbackSelected &&
          (normalizedEquipType == null ||
            (normalizedEquipType === 1
              ? (fallbackSelected?.key_class === "-2" || fallbackSelected?.key_class === -2)
              : !(fallbackSelected?.key_class === "-2" || fallbackSelected?.key_class === -2)))
            ? fallbackSelected
            : null) ||
          null;

        if (selected) {
          const isDialyzer = selected.key_class === "-2" || selected.key_class === -2;
          const mapped = isDialyzer
            ? { ...selected, cd: selected.value, fnValue: { 医療材料分類: "dialyzer" } }
            : {
                ...selected,
                fnValue: {
                  医療材料分類:
                    selected.classCd != null ? selected.classCd : selected.classValue
                }
              };

          this.popoverData.popoverContentSelected = mapped;

          const buildMasterBaseText = (row, ds) => {
            if (!row) return null;
            const ext =
              (ds === 0 || ds == null)
                ? [row.tabooAllergy, row.classInconsistent, row.expired, row.deleted, row.includeDeleted]
                : [row.tabooAllergy];
            const prefix = (ext || []).filter(Boolean).join("");
            const rawName =
              row.equipmentName != null && row.equipmentName !== ""
                ? String(row.equipmentName)
                : row.modelNumber != null && row.modelNumber !== ""
                  ? String(row.modelNumber)
                  : "";
            return (prefix + rawName) || null;
          };

          this.masterLabelForCd = buildMasterBaseText(mapped, dialysisState);
          this.masterUnitForCd =
            mapped.unit != null && mapped.unit !== "" ? String(mapped.unit) : null;
          this.rstNameForCd = rstName != null && rstName !== "" ? String(rstName) : null;
          this.rstUnitForCd =
            rstUnit != null && rstUnit !== "" ? String(rstUnit) : this.masterUnitForCd;
          this.rstUnitBaselineForCd =
            rstUnit != null && rstUnit !== "" ? String(rstUnit) : null;

          this.equipmentInputValue.initValue = this.masterLabelForCd;
          this.equipmentInputValue.editValue =
            mapped.text != null ? String(mapped.text) : this.masterLabelForCd;
          this.unitLabelValue = this.rstUnitForCd;
          if (!isDialyzer) {
            this.cdTest = mapped.value;
          }
        }
      } catch (e) {
        throw e;
      }

      return;
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

    applyFieldsDataDisplay() {
      if (!this.fieldsData?.displayName) {
        return false;
      }
      this.equipmentInputValue.initValue = this.fieldsData.displayName;
      this.equipmentInputValue.editValue = this.fieldsData.displayName;
      this.unitLabelValue = this.fieldsData.unit ?? null;
      this.cdTest = this.fieldsData.cd;
      if (this.fieldsData.equipType === 1) {
        this.popoverData.popoverContentSelected = {
          text: this.fieldsData.displayName,
          value: this.fieldsData.cd,
          cd: this.fieldsData.cd,
          unit: this.fieldsData.unit ?? null,
          fnValue: {
            医療材料分類: "dialyzer"
          }
        };
      } else {
        this.popoverData.popoverContentSelected = {
          text: this.fieldsData.displayName,
          value: this.fieldsData.cd,
          unit: this.fieldsData.unit ?? null,
          fnValue: {
            医療材料分類: 0
          }
        };
      }
      return true;
    },

    /**
     * @description マスター選択を表示
     */
    async showPopover() {
      if (!this.popoverData.popoverContentDataset?.length) {
        await this.createPopoverData();
      }
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
      if (!data) return;

      const isDialyzer =
        data?.fnValue?.["医療材料分類"] === "dialyzer" ||
        (typeof data?.value === "string" && data.value.indexOf("dialyzer") === 0);

      this.popoverData.popoverContentSelected = data;
      this.equipmentInputValue.editValue = data.text || null;
      this.unitLabelValue = data.unit ?? this.unitLabelValue;
      //7155-------------------------ljg    start
      if (!isDialyzer) {
        this.cdTest = data.value;
      }
      //7155-------------------------ljg    end
    },

    /**
     * @description APIにリクエストする
     */
    async updateIndInfo(structData, targetEdit = null, targetEditType = null, sharedOrdMainList = null) {
      const isBatchCollect = structData.flag === 1;
      if (!isBatchCollect) {
        this.startLoadingScreen();
      }
      try {
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
        unit: this.rstUnitForCd != null && this.rstUnitForCd !== ""
          ? String(this.rstUnitForCd)
          : (this.unitLabelValue != null ? String(this.unitLabelValue) : null),
        ind_user_id: structData.indUser,
        // mod FNSI-指示編集でDB登録データの更新 楊 start
        // ind_user_last_name: null,
        // ind_user_first_name: null,
        ind_user_last_name: doctor?.user_last_name ?? null,
        ind_user_first_name: doctor?.user_first_name ?? null,
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
      if (sharedOrdMainList) {
        this.oldOrdMainList = sharedOrdMainList;
      } else {
        const startDate = structData.indStartDate.replace(/-/g, '');
        const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
        const searchData = await ApiHelper.get(
          `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
        ).catch(error => {
          getErrorMessage("IndEquipmentEdit.vue", "updateIndInfo", error);
          throw error;
        });
        this.oldOrdMainList = searchData.data;
      }

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

        if (structData.flag === 1 && this._indicationResultOwner().isRstUpdateFlg === true) {
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
            if (isRstHave && (structData.flag === 1 || structData.flag === 2|| structData.flag === 3) && !this._indicationResultOwner().isShowedMessage) {
            //mod 7114 治療中の透析指示の投与薬剤、医療材料、指示コメント削除を実施した場合の注意メッセージがない 張 end

              //mod #10266  start
              // if (await this.showUpdateCheckDialog(structData.flag)) {
              if (this.settingIndData.update_flag != "2" && await this.showUpdateCheckDialog(structData.flag)) {
                //mod #10266  end

                sendJson.is_rst_update = true;
                if (structData.flag === 1) {
                  this._indicationResultOwner().isRstUpdateFlg = true;
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
              "/mainData/updateOrdMainEquipInfo",
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
            "/mainData/deleteOrdMainEquipInfo",
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
      return response;
      } finally {
        if (!isBatchCollect) {
          this.finishLoadingScreen();
        }
      }
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
          this._indicationResultOwner().isShowedMessage = true;
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
          let treatDateList = this._indicationResultOwner().treatDateListAll;
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

:deep(.equipment-input-style) {
  width: 70%;
  flex: 0 0 70%;
  max-width: 70%;
  min-width: 0;
  box-sizing: border-box;
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
.equipment-selector-column {
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 0;
}
.equipment-master-selector-stretch {
  flex: 1 1 auto;
  min-width: 0;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
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
:deep(.ntss-custom-input-cond) {
  height: 2em;
  font-size: inherit;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  display: -webkit-inline-box;
  display: -ms-inline-flexbox;
  display: inline-flex;
}
/* add FNSI-薬剤指示画面等の画面崩れの修正 楊 end */
</style>
