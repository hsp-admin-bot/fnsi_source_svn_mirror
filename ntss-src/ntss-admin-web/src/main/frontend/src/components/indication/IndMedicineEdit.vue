/** * 投与薬剤ー編集画面 */

<template>
  <!-- add FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
  <div>
    <!-- add FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
  <v-ons-row>
    <v-ons-row class="row-style">
      <v-ons-col class="medicine-column"> 薬剤 </v-ons-col>
      <v-ons-col class="medicine-data-column" style="display: flex;">
        <!--<show-selected-item
          :propInitValue="medicineInputValue.initValue"
          :propEditValue="medicineInputValue.editValue"
          propBackgroundColor="#ebebe4"
          class="medicine-input-style"
        />-->
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
        <!-- <v-ons-button
          ref="popoverButton"
          :disabled="fieldsDisabled"
          class="common-style-select-button"
          @click="
            changeButton();
            createMedicinePopoverData();
            showMedicinePopover();
          "
        > -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   ref="popoverButton" -->
        <!--   :disabled="fieldsDisabled" -->
        <!--   class="common-style-select-button" -->
        <!--   @click=" -->
        <!--     createMedicinePopoverData(); -->
        <!--     showMedicinePopover(); -->
        <!--   " -->
        <!-- > -->
        <!--<v-ons-button
          ref="popoverButton"
          :disabled="fieldsDisabled || !getItemAuthorized('Indication', 'default_authority')"
          class="common-style-select-button"
          @click="
            createMedicinePopoverData();
            showMedicinePopover();
          "
        >-->
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
          <!-- 選択
        </v-ons-button>-->
        <common-master-selector
          :masterType="MasterType.MEDICATION_TREATMENT_RECORD"
          :initItem="medicineSelectorInitItem"
          :editItem="{
            text: medicineInputValue.editValue,
            value: medicineInputValue.editCd,
            unit: rstUnitForCd,
            procedureCd: procedureSelectValue.editValue,
            medicateTimingCd: timingSelectValue.editValue,
            compareProcedure: true,
            compareTiming: true
          }"
          :extraParams="medicineSelectorExtraParams"
          :patientId="selectedPatId"
          :facilityCd="facilityCd"
          :dialysisState="Number(rstDialysisState||0)"
          :allowedFields='allowedFields'
          :hasUnregisteredOption="false"
          :hasChangedOption="!showMedicineFieldOnly"
          :changeOptionMode="'nameAndUnit'"
          :selectedItemClass="'com-basic-sub-input'"
          :backgroundColor="'#f7f7f7'"
          :btnClass="'com-basic-sub-btn'"
          :btnDisabled="fieldsDisabled || !getItemAuthorized('Indication', 'default_authority')"
          :beforeCreatePopover="prepareMedicineSelectorPopover"
          @popover-return="masterUpdateInput($event);"
        />
      </v-ons-col>
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <pop-over
        v-bind="medicinePopoverData"
        :target-position-element="$refs.popoverButton"
        @popover-close="closePopover"
        @popover-return="updateMedicineInput"
        @change="changeButton()"
      /> -->
      <pop-over
        v-bind="medicinePopoverData"
        :target-position-element="$refs.popoverButton"
        @popover-close="closePopover"
        @popover-return="updateMedicineInput"
      />
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
    </v-ons-row>
    <v-ons-row v-if="!showMedicineFieldOnly" class="row-style">
      <v-ons-col class="medicine-column"> 数量 </v-ons-col>
      <v-ons-col class="medicine-data-column">
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
        <!-- <custom-input-number
          ref="amount"
          :value="amountInputValue"
          :digits="8"
          :decimal-digits="decPoint"
          :min-value="0"
          :max-value="999999"
          :loop-flg="true"
          :initial-value-lock="true"
          @change="changeButton()"
          class="amount-input-style common-style-input medicine-custom-input"
        /> -->
        <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng start  -->
        <!-- <custom-input-number
          ref="amount"
          :value="amountInputValue"
          :digits="8"
          :decimal-digits="decPoint"
          :min-value="0"
          :max-value="999999"
          :loop-flg="true"
          :initial-value-lock="true"
          class="amount-input-style common-style-input medicine-custom-input"
        /> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-input-number-pro -->
        <!--   ref="amount" -->
        <!--   :required="true" -->
        <!--   :invalidArray="getInvalidArray(decPoint)" -->
        <!--   :value="amountInputValue.editValue" -->
        <!--   :min="0" -->
        <!--   :max="maxPrecision(999999)" -->
        <!--   :step="unitStep(decPoint)" -->
        <!--   class="amount-input-style common-style-input medicine-custom-input" -->
        <!--   @handlerInput="handlerInput" -->
        <!-- /> -->
        <custom-input-number-pro
          ref="amount"
          :required="true"
          :invalidArray="getInvalidArray(decPoint)"
          :initVal="amountInputValue.initValue"
          :value="amountInputValue.editValue"
          :min="0"
          :max="maxPrecision(999999)"
          :step="unitStep(decPoint)"
          class="amount-input-style common-style-input medicine-custom-input"
          @handlerInput="handlerInput"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng end  -->
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
        <label>{{ unitLabelValue }}</label>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row v-if="!showMedicineFieldOnly" class="row-style">
      <v-ons-col class="medicine-column"> 手技 </v-ons-col>
      <v-ons-col class="medicine-data-column">
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
        <!-- <custom-select
          ref="procedure"
          :value="procedureSelectValue"
          :options="procedureDataset"
          class="select-style common-style-input"
          @change="changeValue(),changeButton()"
        /> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-select -->
        <!--   ref="procedure" -->
        <!--   :value="procedureSelectValue" -->
        <!--   :options="procedureDataset" -->
        <!--   class="select-style common-style-input" -->
        <!--   @change="changeValue()" -->
        <!-- /> -->
        <custom-select
          ref="procedure"
          :value="procedureSelectValue"
          :options="procedureDataset"
          class="select-style common-style-input"
          @change="changeValue()"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row v-if="!showMedicineFieldOnly" class="row-style">
      <v-ons-col class="medicine-column"> 投与タイミング </v-ons-col>
      <v-ons-col class="medicine-data-column">
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
        <!-- <custom-select
          ref="timing"
          :value="timingSelectValue"
          :options="timingDataset"
          class="select-style common-style-input"
          @change="changeValue(),changeButton()"
        /> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-select -->
        <!--   ref="timing" -->
        <!--   :value="timingSelectValue" -->
        <!--   :options="timingDataset" -->
        <!--   class="select-style common-style-input" -->
        <!--   @change="changeValue()" -->
        <!-- /> -->
        <custom-select
          ref="timing"
          :value="timingSelectValue"
          :options="timingDataset"
          class="select-style common-style-input"
          @change="changeValue()"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row v-if="!showMedicineFieldOnly && isComment" class="row-style">
      <v-ons-col class="medicine-column"> コメント </v-ons-col>
      <v-ons-col class="medicine-data-column">
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
        <!-- <com-textarea
          ref="comment"
          class="comTextarea"
          :content="commentInputValue"
          cssClass="textarea-custom-text-font comment-textarea-style comment-textarea textarea-resize-vertical"
          :idTextarea="'com-textarea-ind-medicine' + getNextIndex()"
          propMaxlength="2048"
          @set-content-data="setContentData"
          @change="changeButton()"
        /> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <com-textarea -->
        <!--   ref="comment" -->
        <!--   class="comTextarea" -->
        <!--   :content="commentInputValue" -->
        <!--   cssClass="textarea-custom-text-font comment-textarea-style comment-textarea textarea-resize-vertical" -->
        <!--   :idTextarea="'com-textarea-ind-medicine' + getNextIndex()" -->
        <!--   propMaxlength="2048" -->
        <!--   @set-content-data="setContentData" -->
        <!-- /> -->
        <com-textarea
          ref="comment"
          class="comTextarea"
          :content="commentInputValue"
          cssClass="textarea-custom-text-font comment-textarea-style comment-textarea textarea-resize-vertical"
          :idTextarea="'com-textarea-ind-medicine' + getNextIndex()"
          propMaxlength="2048"
          @set-content-data="setContentData"
          :disabled="!getItemAuthorized('Indication', 'default_authority')"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      </v-ons-col>
    </v-ons-row>
  </v-ons-row>
  <!-- add FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
  </div>
  <!-- add FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import {EventBus} from "@/compat/vue/event-bus.js";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import IndicationOwnerMixin from "@/components/indication/IndicationOwnerMixin";
import { medicineClass } from "@/functions/mst/MstGetters.js";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
import customSelect from "@/components/common/custom-form-tags/CustomSelect";
import { MASTER_MAINTENANCE_CURRENT_ROUTE_NAME } from "@/constants/masterMaintenanceConstants";
import { PATVIEWER_CURRENT_ROUTE_NAME } from "@/constants/PatViewerConstants";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import CommonTextArea from "@/components/common/CommonTextArea";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
import dayjs from "@/compat/date/dayjs";
import BigNumber from "@/compat/number/bignumber";
// add #9848+9849 数値IFのスタイル全不正 linjunfeng start

// add #9848+9849 数値IFのスタイル全不正 linjunfeng end
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";

import { getMstListCompose } from "@/apis/pat-prescription"
import { getMasterConfig } from "@/components/common/master-selector/builder/masterPopoverConfig";

import $ from "@/compat/jquery";
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";

const CLASS_MISMATCH_LABEL = "【分類不一致】";
export default {
  mixins: [IndicationOwnerMixin],
  components: {
    "common-master-selector": commonMasterSelector,
    "pop-over": MasterSelector,
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-select": customSelect,
    "com-textarea": CommonTextArea,
    "show-selected-item": customDivShowSelectedItem,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    "custom-input-number-pro":CustomInputNumberPro,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
  },

  // 親が @input リスナで使用するため input を明示宣言する。
  emits: ["input"],

  props: {
    // add #10359 編集権限の動作不正 dengshen start
    isMst: {
      type: Boolean,
      default: false
    },
    // add #10359 編集権限の動作不正 dengshen end
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
        seqNo: null,
        cd: null,
        unit: null,
        amount: 0,
        timingCd: null,
        procedureCd: null,
        medicineType: null,
        rstDialysisState:0,
        comment: "",
        decPoint: 0
      })
    },

    /**
     * @description 「薬剤」選択のみ表示
     */
    showMedicineFieldOnly: {
      type: Boolean,
      default: false
    },

    /**
     * @description コメント項目表示フラグ
     */
    isComment: {
      type: Boolean,
      default: true
    }
  },

  data() {
    return {
      treatDate:'',
      MasterType,
      /**
       * @description 「投薬」マスタデータ
       */
      medicineDataset: [],
      /**
       * @description 「調製薬剤」マスタデータ
       */
      medicineMixDataset: [],

      /**
       * @description 「投薬」マスタ選択用データ
       */
      medicinePopoverData: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {}
      },

      /**
       * @description 選択された「投薬」表示値
       */
      medicineInputValue: {
        initValue: null,
        editValue: null,
        text:'',
        editCd:'',
        initCd:'',
      },
      masterLabelForCd: null,
      masterUnitForCd: null,
      rstNameForCd: null,
      rstUnitForCd: null,
      rstUnitBaselineForCd: null,
      localSelectedCd: null,
      medicineInitSnapshot: null,

      /**
       * @description 「数量」入力値
       */
      amountInputValue: {
        // #9848+9849 数値IFのスタイル全不正 linjunfeng start
        // initValue: Number(this.fieldsData.amount) || 0,
        // editValue: Number(this.fieldsData.amount) || 0
        initValue: Number(this.fieldsData.amount) || "",
        editValue: Number(this.fieldsData.amount) || ""
        // #9848+9849 数値IFのスタイル全不正 linjunfeng end
      },

      /**
       * @description 「数量」の「単位」表示値
       */
      unitLabelValue: this.fieldsData.unit,

      // mod FNSI-小数点の修正 楊 start
      /**
       * @description 治療状況
       */
      rstDialysisState: this.fieldsData.rstDialysisState,
      // mod FNSI-小数点の修正 楊 end

      /**
       * @description 「手技」マスタデータ
       */
      procedureDataset: [],

      /**
       * @description 「手技」選択値
       */
      procedureSelectValue: {
        initValue: this.fieldsData.procedureCd,
        editValue: this.fieldsData.procedureCd
      },

      /**
       * @description 「投与タイミング」マスタデータ
       */
      timingDataset: [],

      /**
       * @description 「投与タイミング」選択値
       */
      timingSelectValue: {
        initValue: this.fieldsData.timingCd,
        editValue: this.fieldsData.timingCd
      },

      /**
       * @description 薬剤区分
       */
      medicineType: this.fieldsData.medicineType,

      /**
       * @description 薬剤小数点桁数
       */
      decPoint: this.fieldsData.decPoint,

      /**
       * @description 「共通定型文」マスタデータ
       */
      commentDataset: [],

      /**
       * @description 「共通定型文」入力値
       */
      commentInputValue: {
        initValue: this.fieldsData.comment,
        editValue: this.fieldsData.comment
      },

      oldOrdMainList: [],
      textAreaIdIndex: 0,

      initValueModel: {
        medicine: null,
        // #9848+9849 数値IFのスタイル全不正 linjunfeng start
        // amount: this.fieldsData.amount || 0,
        amount: this.fieldsData.amount || "",
        // #9848+9849 数値IFのスタイル全不正 linjunfeng end
        procedure: this.fieldsData.procedureCd,
        timing: this.fieldsData.timingCd,
        comment: this.fieldsData.comment
      },
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      initValue : this.fieldsData.cd,
      currentOrdMainData: {},
      /** 中止 popup 白名单（getPatIndMmdicine） */
      allowedIndMedicineList: [],
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    //mod FNSI-5800 劉全航 start
    // ...mapGetters("pat-viewer", {ordNoMediList: "getOrdNoMediList"}),
    //mod FNSI-5800 劉全航 end
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-viewer", { ordNoList : "getOrdNoList" }),
    // add FNSI-FutreNetWeb+SI課題管理No.4718 李 start
    ...mapGetters("pat-viewer",
      ["getMstMedicineAllergyData",
      //mod FNSI-5906 劉全航 start
      "getMstProcedureData",
      "getMstMedicateTimingData",
      "getMstMedicineClassData",
      "getMstMedicineData",
      "getMstMedicineTabooAllergyData",
      "getMstMedicineMixData",
      "getMstMedicineMixAllergyData",
      //mod FNSI-5906 劉全航 end
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      "getMstMedicineIncludeDeletedData",
      "getMstMedicineMixIncludeDeletedData"
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      ]),
    // add FNSI-FutreNetWeb+SI課題管理No.4718 李 end
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    // mod FNSI-連携イベントの登録適正化 楊 start
    ...mapGetters("pat-info", ["selectedPat"]),
    // mod FNSI-連携イベントの登録適正化 楊 end

    fieldsComputed() {
      let amnt = null;
      if(this.amountInputValue.editValue !== null) {
        // mod FNSI-小数点の修正 楊 start
        // amnt = parseFloat(this.amountInputValue.editValue)
        // #9848+9849 数値IFのスタイル全不正 linjunfeng start
        // amnt = parseFloat(this.amountInputValue.editValue).toFixed(this.decPoint);
        // #10196 数値IFのスタイル全不正 linjunfeng start
        // amnt = parseFloat(this.amountInputValue.editValue)
        amnt = this.amountInputValue.editValue
        // #10196 数値IFのスタイル全不正 linjunfeng end        // #9848+9849 数値IFのスタイル全不正 linjunfeng end
        // mod FNSI-小数点の修正 楊 end
      }
      // add redmine 4903 薬剤のコメントが存在しない 孔 start
      if (this.isComment) {
        return {
          cd:
            parseFloat(this.medicinePopoverData.popoverContentSelected.value) ||
            null,
          amount: amnt,
          timingCd: parseFloat(this.timingSelectValue.editValue) || null,
          procedureCd: parseFloat(this.procedureSelectValue.editValue) || null,
          medicineType: this.medicineType || null,
          comment: this.commentInputValue.editValue
        };
      }
      // add redmine 4903 薬剤のコメントが存在しない 孔 end
      return {
        cd:
          parseFloat(this.medicinePopoverData.popoverContentSelected.value) ||
          null,
        amount: amnt,
        timingCd: parseFloat(this.timingSelectValue.editValue) || null,
        procedureCd: parseFloat(this.procedureSelectValue.editValue) || null,
        medicineType: this.medicineType || null
      };
    },

    isMedicineMix() {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //return this.medicineType === "2";
      return this.medicineType == 2;
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    },
    isActualRst() {
      return Number(this.rstDialysisState || 0) !== 0;
    },
    medicineSelectorInitItem() {
      return {
        text: this.isActualRst
          ? (this.rstNameForCd != null && this.rstNameForCd !== "" ? this.rstNameForCd : this.medicineInputValue.editValue)
          : this.medicineInputValue.initValue,
        value: this.medicineInputValue.initCd,
        unit: this.isActualRst && this.rstUnitBaselineForCd != null && this.rstUnitBaselineForCd !== ""
          ? this.rstUnitBaselineForCd
          : this.masterUnitForCd
      };
    },
    indMedicineProcedureTimingChanged() {
      return (
        String(this.initValueModel?.procedure ?? "") !==
          String(this.procedureSelectValue.editValue ?? "") ||
        String(this.initValueModel?.timing ?? "") !==
          String(this.timingSelectValue.editValue ?? "")
      );
    },
    medicineNameOrUnitChangedForMasterSelector() {
      const cdChanged =
        this.medicineInputValue.initCd != null &&
        this.medicineInputValue.editCd != null &&
        String(this.medicineInputValue.initCd) !== String(this.medicineInputValue.editCd);
      const nameChanged =
        this.medicineInputValue.initValue != null &&
        this.medicineInputValue.editValue != null &&
        String(this.medicineInputValue.initValue) !== String(this.medicineInputValue.editValue);
      const unitChanged =
        this.masterUnitForCd != null &&
        this.rstUnitForCd != null &&
        String(this.masterUnitForCd) !== String(this.rstUnitForCd);

      return cdChanged || nameChanged || unitChanged;
    },
    medicineSelectorExtraParams() {
      return {
        treatDate: this.treatDate,
        rstInfo: {
          rstName: this.isActualRst
            ? (this.rstNameForCd != null && this.rstNameForCd !== "" ? this.rstNameForCd : (this.medicineInputValue?.initValue || ""))
            : (this.medicineInputValue?.initValue || ""),
          rstUnit: this.fieldsData.unit
        },
        actualName: this.isActualRst ? (this.rstNameForCd != null && this.rstNameForCd !== "" ? this.rstNameForCd : "") : "",
        medicineType: this.fieldsData.medicineType,
        baseProcedureCd: this.initValueModel?.procedure ?? null,
        baseTimingCd: this.initValueModel?.timing ?? null,
        procedureCd: this.procedureSelectValue?.editValue ?? null,
        timingCd: this.timingSelectValue?.editValue ?? null,
        compareProcedure: true,
        compareTiming: true,
        currentOrdMainData: this.currentOrdMainData,
      };
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    allowedFields() {
      return {
        data: this.allowedIndMedicineList,
        showMedicineFieldOnly: this.showMedicineFieldOnly,
      };
    }
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  },

  watch: {
    "fieldsData.cd": {
      immediate: true,
      handler(val) {
        this.localSelectedCd = val;
        this.medicineInitSnapshot = null;
      },
    },
    "fieldsData.unit": {
      immediate: true,
      handler(val) {
        this.rstUnitForCd = val != null && val !== "" ? String(val) : this.rstUnitForCd;
        if (this.isActualRst && val != null && val !== "") {
          this.rstUnitBaselineForCd = String(val);
        }
      },
    },
    fieldsComputed(data) {
      this.$emit("input", data);
    },

    "medicinePopoverData.popoverVisible"(value) {
      if (this.isMedicineMix) {
        // 吹き出しの選択状態を設定
        if (value) {
          // 吹き出し表示:コードを Number → String
          const value = `${this.medicinePopoverData.popoverContentSelected.value}$`;
          this.medicinePopoverData.popoverContentSelected.value = value;
        } else if (
          typeof this.medicinePopoverData.popoverContentSelected.value ===
          "string") {
          // 吹き出し非表示:コードを String → Number
          const value = this.medicinePopoverData.popoverContentSelected.value;
          this.medicinePopoverData.popoverContentSelected.value = Number(
            value.split("$")[0]);
        }
      }
    }
  },

  mounted() {
    this.localSelectedCd = this.fieldsData?.cd;
    this.rstUnitForCd =
      this.fieldsData?.unit != null && this.fieldsData?.unit !== ""
        ? String(this.fieldsData.unit)
        : null;
    if (this.isActualRst && this.rstUnitForCd) {
      this.rstUnitBaselineForCd = this.rstUnitForCd;
    }
    this.retrieveMstData();
  },

  methods: {
    ...mapActions('loading-screen', [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    masterUpdateInput(val){
      this.medicineInputValue.editValue = val.text
      this.medicineInputValue.text = val.text
      this.medicineInputValue.editCd = val.value
      // common-master-selector（MEDICATION_TREATMENT_RECORD）は option に kbnValue が無い場合があるため、
      // key_type(=1/2) 等から薬剤区分を必ず補完する
      const resolvedType =
        val?.kbnValue ?? val?.type ?? val?.key_type ?? val?.keyType ?? this.medicineType ?? this.fieldsData?.medicineType ?? null;
      const item = {
        ...val,
        isDisp: val.isDisp,
        text: val.text,
        value: val.value,
        type: resolvedType
      };
      this.updateMedicineInput(item)
    },

    mstClick(item) {
      const val = (item.data?.master?.items ?? []).filter(i => i.key_type == 1);
      return val

    },
    mstMixClick(item) {
      const val = (item.data?.master?.items ?? []).filter(i => i.key_type == 2);
      return val
    },
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    handlerInput(val){
      if (this.decPoint !== undefined) {
        this.amountInputValue.editValue = val
      }
    },
    unitStep(decPoint) {
      var num = parseInt(decPoint);

      if(isNaN(num)){
        return 1;
      }
      var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
      return data;
    },
    maxPrecision(value) {
      let num = parseInt(this.decPoint);
      if(isNaN(num)){
        return value;
      }
      const decimalNumber = parseFloat(`${value}.${'9'.repeat(num)}`);
      return Number(decimalNumber.toFixed(num));
    },
    getInvalidArray(decPoint) {
      let arr = [];
      let num = parseInt(decPoint);
      let zero = 0;
      let data = isNaN(num) ? "0" : zero.toFixed(num);
      arr.push(data)
      return arr;
    },
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
    //[確認]ボタンの状態の変更をトリガーします
   changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     * @description マスターデータを取得及び初期化関数
     */
    //add FNSI内容修正 バグ284、286 姜 start
    //mod FNSI-5800 劉全航 start
    // ...mapActions("treatment-record", {
    //   sendRequestChangeIndMediInfoRst: "sendRequestChangeIndMediIn",
    // }),
    ...mapActions("treatment-record/mediInfo", {
      sendRequestChangeIndMediInfoRst: "sendRequestChangeIndMediIn",
    }),
    //mod FNSI-5800 劉全航 end
    ...mapActions("treatment-record/common", ["getMstMachineByOrdNoRst", "sendGetNoticeMedi"]),
    //add FNSI内容修正 バグ284、286  姜 end
    // add #10266 薬剤編集と投薬、編集画面で薬剤に変化が生じ、操作を中止した場合、薬剤はリセットされません。 linjunfeng start
    /**
     * 編集/中止切替
     */
     selectSegment(edit) {
      this.selectedEdit = Number(edit);
      // 初期データに戻す処理
      this.medicineInputValue.editValue = this.medicineInputValue.initValue;
    },
    // add #10266 薬剤編集と投薬、編集画面で薬剤に変化が生じ、操作を中止した場合、薬剤はリセットされません。 linjunfeng end
    /** 中止 popup 打开前：先加载白名单与 currentOrdMainData，避免列表为空或实绩名为空 */
    async prepareMedicineSelectorPopover() {
      if (!this.showMedicineFieldOnly) return;

      await this.loadAllowedIndMedicineList();
      if (this.settingIndData?.ordNo) {
        this.currentOrdMainData = await ApiHelper.get(
          `/mainData/getOrdMainByOrdNo/${this.settingIndData.ordNo}`
        );
      }
    },
    resolveMedicineEditBase() {
      const owner =
        typeof this._indicationFlowOwner === "function"
          ? this._indicationFlowOwner()
          : null;
      if (owner?.settingData != null && owner?.structData != null) {
        return owner;
      }

      let parent = this.$parent;
      for (let depth = 0; depth < 6 && parent; depth += 1) {
        if (parent.settingData != null && parent.structData != null) {
          return parent;
        }
        parent = parent.$parent;
      }
      return null;
    },
    /** 中止 popup：指示範囲内の薬剤白名单（getPatIndMmdicine） */
    async loadAllowedIndMedicineList() {
      if (!this.showMedicineFieldOnly) {
        this.allowedIndMedicineList = [];
        return;
      }
      const base = this.resolveMedicineEditBase();
      if (!base?.structData) {
        this.allowedIndMedicineList = [];
        return;
      }
      const paramJson = {
        patId: base.structData.patId,
        facilityCd: base.structData.facilityCd,
        dialysisDateFrom: dayjs(base.structData.indStartDate).format("YYYYMMDD"),
        dialysisDateTo: base.structData.indEndDate
          ? dayjs(base.structData.indEndDate).format("YYYYMMDD")
          : null,
      };
      try {
        const res = await ApiHelper.post("/mainData/getPatIndMmdicine", paramJson);
        this.allowedIndMedicineList = res.data || [];
      } catch (error) {
        getErrorMessage("IndMedicineEdit.vue", "loadAllowedIndMedicineList", error);
        this.allowedIndMedicineList = [];
        throw error;
      }
    },
    async retrieveMstData() {
      //mod FNSI-5906 劉全航 end
      this.procedureDataset = this.getMstProcedureData;
      this.timingDataset = this.getMstMedicateTimingData;
      // [
      //   this.procedureDataset,
      //   this.timingDataset,
      //   this.commentDataset
      // ] = await Promise.all([
      //   procedure(this.facilityCd).catch(error => {
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      //     getErrorMessage('IndMedicineEdit.vue', 'procedure', error);
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      //     throw error;
      //   }),
      //   medicateTiming(this.facilityCd).catch(error => {
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      //     getErrorMessage('IndMedicineEdit.vue', 'medicateTiming', error);
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      //     throw error;
      //   }),
      //   mstComFixedPhrase(this.facilityCd).catch(error => {
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      //     getErrorMessage('IndMedicineEdit.vue', 'mstComFixedPhrase', error);
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      //     throw error;
      //   })
      // ]);
      //mod FNSI-5906 劉全航 end
      this.procedureDataset = this.procedureDataset.map(item => {
        return {
          value: item.procedureCd,
          displayValue: item.pricedureName
        };
      });

      this.timingDataset = this.timingDataset.map(item => {
        return {
          value: item.medicateTimingCd,
          displayValue: item.medicateTimingName
        };
      });
      // add #9848+9849 手技、投与タイミング 空選択肢あり linjunfeng start
      this.procedureDataset.unshift({
        value: null,
        displayValue: null,
      })
      this.timingDataset.unshift({
        value: null,
        displayValue: null,
      })
      // add #9848+9849 手技、投与タイミング 空選択肢あり linjunfeng end
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      if (this.settingIndData && this.settingIndData.ordNo) {
        this.currentOrdMainData = await ApiHelper.get(`/mainData/getOrdMainByOrdNo/${this.settingIndData.ordNo}`)
      }
      await this.loadAllowedIndMedicineList();
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      await this.createMedicinePopoverData();
      const selectedMst = this.medicinePopoverData.popoverContentDataset.find(
        item => {
          let medicineCd = this.fieldsData.cd;
          if (this.isMedicineMix) {
            // 調製薬剤なら
            medicineCd = `${medicineCd}`;
          }

          return item.value === medicineCd;
        });
      if (selectedMst) {
        this.medicineInputValue.initValue = selectedMst.text;
        this.medicineInputValue.editValue = selectedMst.text;
        this.medicineInputValue.text = selectedMst.text;
        this.medicineInputValue.editCd = selectedMst.value;
        this.medicineInputValue.initCd = selectedMst.value;
        if (this.isMedicineMix) {
          selectedMst.value = Number(selectedMst.value.split("$")[0]);
        }
        this.medicinePopoverData.popoverContentSelected = selectedMst;

      // add FNSI-FutreNetWeb+SI課題管理No.4718 李 start
      } else {
        //mod FNSI no.6663 調整薬剤内の薬剤が削除されても【削除済み】と表示されない 劉全航 start
        //削除済み調製薬剤の場合
        /*var resMedicine;
         if (this.isMedicineMix){
           resMedicine = this.medicineMixDataset.find(o=>{
             return o.medicineMixCd === this.fieldsData.cd;
           });
           if (resMedicine) {
              this.medicineInputValue.initValue = '【削除済み】' + resMedicine.medicineMixName;
              this.medicineInputValue.editValue = '【削除済み】' + resMedicine.medicineMixName;
            } else {
              this.medicineInputValue.initValue = null;
              this.medicineInputValue.editValue = null;
          }
         }else{
            resMedicine = this.getMstMedicineAllergyData.find(item => {
              return item.medicineCd == this.fieldsData.cd;
            });
            if (resMedicine) {
              this.medicineInputValue.initValue = '【削除済み】' + resMedicine.medicineName;
              this.medicineInputValue.editValue = '【削除済み】' + resMedicine.medicineName;
            } else {
              this.medicineInputValue.initValue = null;
              this.medicineInputValue.editValue = null;
          }
         }*/
        // 削除済み薬剤の場合
        // const resMedicine = this.getMstMedicineAllergyData.find(item => {
        //   return item.medicineCd == this.fieldsData.cd;
        // });
        // if (resMedicine) {
        //   this.medicineInputValue.initValue = '【削除済み】' + resMedicine.medicineName;
        //   this.medicineInputValue.editValue = '【削除済み】' + resMedicine.medicineName;
        // } else {
        //   this.medicineInputValue.initValue = null;
        //   this.medicineInputValue.editValue = null;
        // }
        //mod FNSI no.6663 調整薬剤内の薬剤が削除されても【削除済み】と表示されない 劉全航 end
      }
      // add FNSI-FutreNetWeb+SI課題管理No.4718 李 end
      // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // this.checkMstDispStatus("medicineCd");
      // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

      let med = null;
      if (!this.isMedicineMix) {
        // 薬剤マスタ
        med = this.medicineDataset.find(item => {
          return item.medicineCd === this.fieldsComputed.cd;});
      } else {
        // 調製薬剤マスタ
        med = this.medicineMixDataset.find(item => {
          return item.medicineMixCd === this.fieldsComputed.cd;});
      }
      this.masterUnitForCd =
        med && med.unit != null && med.unit !== ""
          ? String(med.unit)
          : this.masterUnitForCd;

      const initText = this.isActualRst && this.rstNameForCd != null && this.rstNameForCd !== ""
        ? this.rstNameForCd
        : (this.masterLabelForCd != null && this.masterLabelForCd !== ""
            ? this.masterLabelForCd
            : (this.medicineInputValue.initValue || ""));
      const initUnit = this.isActualRst && this.rstUnitForCd != null && this.rstUnitForCd !== ""
        ? this.rstUnitForCd
        : (this.masterUnitForCd || "");

      this.medicineInitSnapshot = {
        text: initText,
        value: this.medicineInputValue.initCd,
        unit: initUnit
      };

      // mod FNSI-小数点の修正 楊 start
      // this.decPoint = med && med.unitDecimalPoint;
      if (this.rstDialysisState && this.rstDialysisState !== "0") {
        //mod 7793 使用数の小数点以下が表示されない 張 start
        // if (this.settingIndData.isTitleCk) {
        //   // タイトルから場合、マスタの桁数設定
        //   this.decPoint = med && med.unitDecimalPoint;
        // } else {
        //   this.decPoint = med && med.unitDecimalPoint;
        //   // this.decPoint = this.amountInputValue.editValue.toString().split(".").length>2?this.amountInputValue.editValue.toString().split(".")[1].length:0;
        // }
         this.decPoint = med && med.unitDecimalPoint;
        //mod 7793 使用数の小数点以下が表示されない 張 end
      } else {
        this.decPoint = med && med.unitDecimalPoint;
        //mod FNSI-6512 劉全航 start
        //this.amountInputValue.initValue =  parseFloat(this.amountInputValue.initValue).toFixed(this.decPoint);
        // del #9848+9849 数値IFのスタイル全不正 linjunfeng start
        // this.amountInputValue.initValue =  parseFloat(parseFloat(this.amountInputValue.initValue).toFixed(this.decPoint));
        // del #9848+9849 数値IFのスタイル全不正 linjunfeng end
        //mod FNSI-6512 劉全航 end
        //mod FNSI-5639 劉全航 start
        // this.amountInputValue.editValue =  parseFloat(this.amountInputValue.editValue).toFixed(this.decPoint);
        // del #9848+9849 数値IFのスタイル全不正 linjunfeng start
        // this.amountInputValue.editValue =  Number(parseFloat(this.amountInputValue.editValue).toFixed(this.decPoint));
        // del #9848+9849 数値IFのスタイル全不正 linjunfeng end
        //mod FNSI-5639 劉全航 end
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      if (!this.decPoint) {
        this.decPoint = 0;
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // mod FNSI-小数点の修正 楊 end
    },

    /**
     * @description  ポップオーバーを表示する前に、必要なデータを取得して、
     *               ポップオーバー用フォーマットをコンバートする
     */
    /**
     * 指示が無い・予定日未設定の場合でもマスタ取得・表示が空にならないよう治療日を補完する
     */
    resolveTreatDateForExtraParams() {
      const struct = this._indicationFlowOwner()?.structData ?? this.$parent?.$parent?.structData;
      if (struct?.indStartDate) {
        return dayjs(struct.indStartDate).format("YYYYMMDD");
      }
      if (this.getIndStartDate) {
        return dayjs(this.getIndStartDate).format("YYYYMMDD");
      }
      return dayjs().format("YYYYMMDD");
    },

    async createMedicinePopoverData() {
      this.treatDate = this.resolveTreatDateForExtraParams();

      // 選択中薬剤のIDを取得
      let selectedMediCd = null;
      let selectedMediMixCd = null;
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (this.fieldsData.medicineType === "1") {
      if (this.medicineType == 1) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        selectedMediCd = this.fieldsData.cd;
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //} else if (this.fieldsData.medicineType === "2") {
      } else if (this.medicineType == 2) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        selectedMediMixCd = this.fieldsData.cd;
      }
      let filterArr = [];
      let contentArr = [];
      //mod FNSI-5906 劉全航 start
      // const [medicineData, medicineMixData, classData] = await Promise.all([
      //   // マスタ系画面以外では患者のタブー・アレルギー情報込みで取得する
      //   this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? medicine(this.facilityCd) : medicineTabooAllergy(this.selectedPatId),
      //   //mod FNSI no.6663 調整薬剤内の薬剤が削除されても【削除済み】と表示されない 劉全航 start
      //   // this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? medicineMix(this.facilityCd) : medicineMixTabooAllergy(this.selectedPatId),
      //   this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? medicineMix(this.facilityCd) : medicineMixAllergy(this.selectedPatId,true),
      //   //mod FNSI no.6663 調整薬剤内の薬剤が削除されても【削除済み】と表示されない 劉全航 end
      //   // medicineClass(this.facilityCd)
      // ]).catch(error => {
      //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      //   getErrorMessage('IndMedicineEdit.vue', 'createMedicinePopoverData', error);
      //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      //   throw error;
      // });
      /*var medicineData = this.$route.name ===
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? this.getMstMedicineData : this.getMstMedicineTabooAllergyData;
        MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? this.getMstMedicineIncludeDeletedData : this.getMstMedicineAllergyData;
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      var medicineMixData = this.$route.name ===
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? this.getMstMedicineMixData : this.getMstMedicineMixAllergyData;
        MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? this.getMstMedicineMixIncludeDeletedData : this.getMstMedicineMixAllergyData;
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      var classData = this.getMstMedicineClassData;*/
      const initCd = this.fieldsData?.cd;
      const extraParams = {
        treatDate: this.treatDate,
        rstInfo: {
          rstName: this.medicineInputValue?.initValue || "",
          rstUnit: this.fieldsData?.unit || ""
        },
        medicineType: this.medicineType || null,
        initValue: initCd
      };
      const context = {
        facilityCd: this.facilityCd,
        patientId: this.selectedPatId,
        extraParams,
        initItem: { value: initCd },
        selectedItem: { value: initCd },
        dialysisState: Number(this.rstDialysisState || 0),
        allowedFields: this.allowedFields
      };

      const item = getMasterConfig(MasterType.MEDICATION_TREATMENT_RECORD, context);
      const res = await getMstListCompose(item).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndTreatCondAntiCoagulant.vue', 'createPopoverData', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      const medicineData = this.mstClick(res)
      const medicineMixData = this.mstMixClick(res)
      let classData = res.data?.filterList?.[0]?.list2?.items ?? [];

      // add 薬剤分類の初期値が空 商 start
      if (!classData || classData.length === 0) {
        classData = await medicineClass(this.facilityCd).catch(
          error => {
            getErrorMessage('IndMedicineEdit.vue', 'async', error);
            throw error;
          });
      }
      // add 薬剤分類の初期値が空 商 end
      //mod FNSI-5906 劉全航 end
      let filteredMedicineData = medicineData;
      let filteredMedicineMixData = medicineMixData;
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let treatDate = null;
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // 患者経過総合ビューア(予定)表示時は、予定範囲と薬剤の使用期限を見て表示内容を補正する
      if (this.$route.name === PATVIEWER_CURRENT_ROUTE_NAME) {
        let indMmdicine =null;
        if(this._indicationFlowOwner().settingData!=undefined&&this._indicationFlowOwner().edit == 1){
          const paramJson = {
            patId: this._indicationFlowOwner().structData.patId,
            facilityCd: this._indicationFlowOwner().structData.facilityCd,
            dialysisDateFrom: dayjs(this._indicationFlowOwner().structData.indStartDate).format("YYYYMMDD"),
            dialysisDateTo: this._indicationFlowOwner().structData.indEndDate?dayjs(this._indicationFlowOwner().structData.indEndDate).format("YYYYMMDD"):null
          }
          indMmdicine = await ApiHelper.post(
            "/mainData/getPatIndMmdicine",
            paramJson).catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
          });
        }
        // 薬剤
        filteredMedicineData = medicineData.filter(medi => {
          if(indMmdicine!=null&&indMmdicine.data!=null){
            let medicine = indMmdicine.data.find(med=>{return med.medicineType=="1"&&med.cd==medi.medicineCd})
            if (medicine) {
              return fitTermCheck(medi.useStartDate, medi.useEndDate, this.getIndStartDate) || medi.medicineCd === selectedMediCd;
            }
          }else{
            return fitTermCheck(medi.useStartDate, medi.useEndDate, this.getIndStartDate) || medi.medicineCd === selectedMediCd;
          }
        });
        // 調製薬剤
        filteredMedicineMixData = medicineMixData.filter(medi => {
          if(indMmdicine!=null&&indMmdicine.data!=null){
            let medicineMix = indMmdicine.data.find(med=>{return med.medicineType=="2"&&med.cd==medi.medicineMixCd})
            if (medicineMix) {
              return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, this.getIndStartDate) || medi.medicineMixCd === selectedMediMixCd;
            }
          }else{
            return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, this.getIndStartDate) || medi.medicineMixCd === selectedMediMixCd;
          }
          // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
        });
        // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        treatDate = this._indicationFlowOwner()?.structData?.indStartDate;
      } else if (this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME) {
        treatDate = dayjs().format("YYYYMMDD");
        // 薬剤
        filteredMedicineData = medicineData.filter(medi => {
          return fitTermCheck(medi.useStartDate, medi.useEndDate, treatDate) || (this.fieldsData.cd != null && medi.medicineCd == this.fieldsData.cd);
        });
        // 調製薬剤
        filteredMedicineMixData = medicineMixData.filter(medi => {
          return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, treatDate) || (this.fieldsData.cd != null && medi.medicineMixCd == this.fieldsData.cd);
        });
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

      this.medicineDataset = filteredMedicineData;
      this.medicineMixDataset = filteredMedicineMixData;

      // ポップオーバのフィルタデータを取りまとめる
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd
        };
      };

      filterArr = classData.map(filterMapping);
      filterArr.unshift({ text: "すべて", value: 0 });
      // mod #8202 2023/01/05 投与薬剤編集モーダルにて薬剤分類「未分類」を選択して抽出すると、薬剤が何も表示されない dou start
      // filterArr.push({ text: "未分類", value: null });
      filterArr.push({ text: "未分類", value: -1 });
      // mod #8202 2023/01/05 投与薬剤編集モーダルにて薬剤分類「未分類」を選択して抽出すると、薬剤が何も表示されない dou end

      // ポップオーバのコンテンツデータ(フィルターしたデータ)を取りまとめる
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // const contentParamIsDisp = item => {
        // return item.isDisp === "1";
      const contentParamIsDisp = (item, cd) => {
        return item && (item.isDisp === "1" || item[cd] == this.initValue);
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      };
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let rstName = "";
      let rstUnit = "";
      if (
        this.currentOrdMainData &&
        this.currentOrdMainData.data &&
        this.currentOrdMainData.data.rstDialysisState != 0) {
        const cd = this.initValue;
        const type = this.fieldsData?.medicineType;
        const indRaw = this.currentOrdMainData?.data?.indMediInfo;
        const rstRaw = this.currentOrdMainData?.data?.rstMediInfo;
        const indArr = indRaw ? JSON.parse(indRaw) : [];
        const rstArr = rstRaw ? JSON.parse(rstRaw) : [];
        const match = (arr) =>
          Array.isArray(arr)
            ? arr.find((it) =>
                String(it?.cd) === String(cd) &&
                (type == null || type === "" || String(it?.medicine_type) === String(type))
              )
            : null;
        const indRow = match(indArr);
        const rstRow = match(rstArr);
        const picked = indRow || rstRow;
        rstName = picked && picked.name ? String(picked.name) : "";
        rstUnit = picked && picked.unit ? String(picked.unit) : "";
      }
      this.rstNameForCd = rstName;
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      const contentMapping = (item, cdKey, nameKey, category) => {
        const baseText =
          (item.classInconsistent || '') +
          item.tabooAllergy +
          item.expired +
          item.deleted +
          item.includeDeleted +
          item[nameKey];
        return {
          //value: category == 1 ? item[cdKey] : `${item[cdKey]}$`,
          value: category == 1 ? item[cdKey] : `${item[cdKey]}`,
          // value: category === "1" ? item[cdKey] : `${item[cdKey]}$`,
          fnValue: {
            薬剤区分: category,
            薬剤分類: item.classCd
          },
          unit: item.unit,
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: item[nameKey]
          //text: rstName && item[cdKey] == this.initValue ? rstName : getPrefix({treatDate, ...item}) + item[nameKey],
          text: rstName && item[cdKey] == this.initValue ? rstName : baseText,
          isDisp: item.isDisp,
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        };
      };

      const mstRow =
        filteredMedicineData.find(o => String(o.medicineCd) == String(this.localSelectedCd)) ||
        filteredMedicineMixData.find(o => String(o.medicineMixCd) == String(this.localSelectedCd));
      if (mstRow) {
        const mstName = mstRow.medicineName || mstRow.medicineMixName || "";
        const mstBaseText =
          (mstRow.classInconsistent || "") +
          mstRow.tabooAllergy +
          mstRow.expired +
          mstRow.deleted +
          mstRow.includeDeleted +
          mstName;
        this.masterLabelForCd = mstBaseText;
        this.masterUnitForCd =
          mstRow.unit != null && mstRow.unit !== ""
            ? String(mstRow.unit)
            : this.masterUnitForCd;
      }
      this.rstUnitForCd =
        rstUnit != null && rstUnit !== "" ? String(rstUnit) : this.rstUnitForCd;
      this.rstUnitBaselineForCd =
        rstUnit != null && rstUnit !== "" ? String(rstUnit) : null;

      if (
        this.isActualRst &&
        this.rstUnitForCd != null &&
        this.rstUnitForCd !== ""
      ) {
        this.unit = this.rstUnitForCd;
        this.unitLabelValue = this.rstUnitForCd;
      }

      contentArr = filteredMedicineData
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        .filter(item => contentParamIsDisp(item, 'medicineCd'))
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          //.map(item => contentMapping(item, "medicineCd", "medicineName", "1"));
          .map(item => contentMapping(item, "medicineCd", "medicineName", 1));
      const mixArr = filteredMedicineMixData
        .filter(item => contentParamIsDisp(item, 'medicineMixCd'))
        .map(item =>
            //contentMapping(item, "medicineMixCd", "medicineMixName", "2"));
            contentMapping(item, "medicineMixCd", "medicineMixName", 2));
      contentArr = [...contentArr, ...mixArr];
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      contentArr = contentArr.sort(function (a, b) {
        return b.isDisp - a.isDisp;
      });
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      this.medicinePopoverData.popoverTitleHeader = "薬剤";
      this.medicinePopoverData.popoverFilter = [
        {
          popoverFilterLabel: "薬剤区分",
          popoverFilterDataset: [
            { text: "すべて", value: 0 },
            { text: "通常薬剤", value: "1" },
            { text: "調製薬剤", value: "2" }
          ]
        },
        {
          popoverFilterLabel: "薬剤分類",
          popoverFilterDataset: filterArr
        }
      ];
      this.medicinePopoverData.popoverContentLabel = "薬剤名";
      this.medicinePopoverData.popoverContentDataset = contentArr;
      // add #9849+9849 薬剤，空選択肢なし linjunfeng start
      this.medicinePopoverData.hasUnregisteredOption = false;
      // add #9849+9849 薬剤，空選択肢なし linjunfeng end
    },
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // checkMstDispStatus() {
    //   if (this.fieldsData.cd === null) {
    //     return;
    //   }

    //   const mst = this.medicineDataset.find(item => {
    //     return item.medicineCd === this.fieldsData.cd;
    //   });

    //   if (mst && mst.isDisp === "0") {
    //     this.medicineInputValue.initValue = "削除済み";
    //     this.medicineInputValue.editValue = "削除済み";
    //   }
    // },
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    /**
     * @description 「投薬」マスター選択を表示
     */
    showMedicinePopover() {
      this.medicinePopoverData.popoverVisible = true;
    },

    /**
     * @description ポップオーバーが隠れてからのコールバック関数
     */
    closePopover() {
      this.medicinePopoverData.popoverVisible = false;
    },

    /**
     * @description 「投薬」が選択されてからのコールバック関数
     */
    updateMedicineInput(data) {
      // add #10266 投与薬剤編集モーダル選択ボタンを押下しOK押下　NGエラー発生 linjunfeng start
      if (!data) {
        return;
      }
      // add #10266 投与薬剤編集モーダル選択ボタンを押下しOK押下　NGエラー発生 linjunfeng end
      //const medicineType = data.value ? data.fnValue.薬剤区分 : null;
      const medicineType =
        data.value
          ? (data.type ?? data.kbnValue ?? data.key_type ?? data.keyType ?? this.medicineType ?? this.fieldsData?.medicineType ?? null)
          : null;
      const selectedData = data;

      let med = null;
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === "1") {
      if (medicineType == 1) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 薬剤マスタ
        med = this.medicineDataset.find(item => {
          return item.medicineCd === selectedData.value;
        });
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //} else if (medicineType === "2") {
      } else if (medicineType == 2) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        // 調製薬剤マスタ
        const rawVal = selectedData.value;
        // common-master-selector 経由では number が来る場合がある
        selectedData.value =
          rawVal == null
            ? rawVal
            : Number(String(rawVal).split("$")[0]);
        med = this.medicineMixDataset.find(item => {
          return item.medicineMixCd === selectedData.value;
        });
      }

      this.medicinePopoverData.popoverContentSelected = selectedData;
      this.medicineInputValue.editValue = selectedData.text || null;
      const chosenUnit =
        selectedData && selectedData.unit != null && selectedData.unit !== ""
          ? selectedData.unit
          : (med && med.unit != null && med.unit !== "" ? med.unit : null);
      this.unitLabelValue = chosenUnit != null && chosenUnit !== "" ? chosenUnit : this.unitLabelValue;
      this.rstUnitForCd =
        chosenUnit != null && chosenUnit !== ""
          ? String(chosenUnit)
          : this.rstUnitForCd;
      this.medicineType = medicineType;
      this.decPoint = med && med.unitDecimalPoint;
      // #9848+9849 薬剤変更時,薬剤マスタ依存＋薬剤マスタで未指定の場合変更しない linjunfeng start
      if (selectedData?.__isMasterChangedRow) {
        if (selectedData.__procedureCd !== undefined) {
          this.procedureSelectValue.editValue = selectedData.__procedureCd;
        }
        if (selectedData.__timingCd !== undefined) {
          this.timingSelectValue.editValue = selectedData.__timingCd;
        }
      } else {
        if (med?.procedureCd) {
          this.procedureSelectValue.editValue = med.procedureCd;
        }
        if (med?.medicateTimingCd) {
          this.timingSelectValue.editValue = med.medicateTimingCd;
        }
      }
      // #9848+9849 薬剤変更時,薬剤マスタ依存＋薬剤マスタで未指定の場合変更しない linjunfeng end
    },

    /**
     * @description APIにリクエストする
     */
    async updateIndInfo(structData) {
      console.log("IndMedicineEdit.vue updateIndInfo this.startLoadingScreen();");
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

      // add FNSI-FutreNetWeb+SI課題管理No.4718 李 start
      let cdValue = null;
      // 削除済み薬剤の場合
      if (this.medicineInputValue.initValue && !this.fieldsComputed.cd) {
        cdValue = this.fieldsData.cd;
      } else {
        cdValue = this.fieldsComputed.cd;
      }
      // add FNSI-FutreNetWeb+SI課題管理No.4718 李 end

      /* modify by chamaojia 2024-01-22 [10196] Default value setting error correction  --start */
      const resolvedMedicineType =
        this.medicineType ?? this.fieldsData?.medicineType ?? this.fieldsComputed?.medicineType ?? null;

      const indInfo = {
        no: this.fieldsData.seqNo,
        // class_cd: null,
        // class_name: null,
        // class_type: null,
        medicine_type: resolvedMedicineType != null ? Number(resolvedMedicineType) : null,
        // mod FNSI-FutreNetWeb+SI課題管理No.4718 李 start
        // cd: this.fieldsComputed.cd,
        cd: cdValue,
        // mod FNSI-FutreNetWeb+SI課題管理No.4718 李 end
        // name: this.medicineInputValue.editValue,
        // short_name: null,
        // unit: this.unitLabelValue,
        unit: this.rstUnitForCd != null && this.rstUnitForCd !== "" ? String(this.rstUnitForCd) : (this.unitLabelValue != null ? String(this.unitLabelValue) : null),
        // mod #11311 編集箇所のみ保存の再精査 zkm start
        // amount: this.fieldsComputed.amount,
        ...(1 !== structData.flag && structData.editOnly && this.fieldsComputed.amount == this.amountInputValue.initValue ? {} : { amount: this.fieldsComputed.amount }),
        // mod #11311 編集箇所のみ保存の再精査 zkm end
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng start
        // init_date: structData.indDayIntervalStartDate.replace(/-/g, ""),
        init_date: structData.indDayIntervalStartDate ? structData.indDayIntervalStartDate.replace(/-/g, "") : structData.indStartDate.replace(/-/g, ''),
        // #11473 投与間隔・初回投与日関連バグ修正 linjunfeng end
        date_interval: structData.indDayIntervalSelected,
        timing_cd: this.fieldsComputed.timingCd,
        // timing_name: null,
        procedure_cd: this.fieldsComputed.procedureCd,
        // procedure_name: null,
        comment: this.commentInputValue.editValue,
        ind_user_id: structData.indUser,
        // mod FNSI-小数点の修正 楊 start
        // #10196 数値IFのスタイル全不正 linjunfeng start
        // isAmountchg: this.amountInputValue.initValue == this.amountInputValue.editValue && structData.editOnly,
        isAmountchg: this.fieldsData.amount == this.fieldsComputed.amount && structData.editOnly,
        // #10196 数値IFのスタイル全不正 linjunfeng end        // mod FNSI-小数点の修正 楊 end
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
        cop_order_no: null
      };
      /* modify by chamaojia 2024-01-22 [10196] Default value setting error correction  --end */

      const indOrdDates = structData.treatDates;
      // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy start
      let isEdit = false;
      if (structData.flag!==1) {
        // mod #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
         // isEdit = this.$parent.$parent.initStructData.indWeeks !== structData.indWeeks ? true :false;
         isEdit = JSON.stringify(this._indicationFlowOwner().initStructData.indWeeks) !== JSON.stringify(structData.indWeeks);
        // mod #12471 ord_main.ind_medi_infoに不正データが登録される zkm end
      }
      const sendJson = {
        pat_id: structData.patId,
        facility_cd: this.facilityCd,
        ind_dates: JSON.stringify(indOrdDates),
        start_date: structData.indStartDate,
        end_date: structData.indEndDate,
        weeks: JSON.stringify(structData.indWeeks),
        ind_kur_cd: JSON.stringify(structData.selectedKur),
        ind_treatment_cd: JSON.stringify(structData.selectedTreat),
        ind_info: JSON.stringify(indInfo),
        count_before: structData.indNumDays.init,
        count_after: structData.indNumDays.edit,
        date_interval: structData.indDayIntervalSelected,
        init_date: structData.indDayIntervalStartDate,
        // is_edit_other_amount: this.getIsEditotherAmount(),
        is_edit_other_amount: isEdit ? true : this.getIsEditotherAmount(),
        // mod 9267 9296 患者経過総合ビューアにて投与薬剤の投与間隔を変更すると新規で作成される。治療予定作成時の開始日が空欄 zy end
        // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
        is_deadline: structData.isDeadline,
        is_rst_update: false,
        // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
        // add FNSI-投与薬剤編集にて「投薬パターン」、「曜日パターン」の変更 興 start
        treat_dates: structData.treatDates,
        treat_date_list_all: structData.treatDateListAll,
        // add FNSI-投与薬剤編集にて「投薬パターン」、「曜日パターン」の変更 興 end
        // add FNSI-FutreNetWeb+SI課題管理No.3848 李 start
        interval_flg: structData.intervalFlg,
        // add FNSI-FutreNetWeb+SI課題管理No.3848 李 end
        //add #IES_6790 by zhangruixue 2023-07-04 --start
        ords: [],
        //add #IES_6790 by zhangruixue 2023-07-04 --end
        //add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
        number_of_doses: structData.number_of_doses,
        //add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        //add #10266 start
        update_flag: this.settingIndData.update_flag
        //add #10266 end
      };

      // 古いリスト
      const startDate = structData.indStartDate.replace(/-/g, '');
      const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      const searchData = await ApiHelper.get(
        `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
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

        if (structData.flag === 1 && this._indicationResultOwner().isRstUpdateFlg === true) {
          // 複数の薬剤が追加された場合、且つ 実績の変更をする確認した場合
          sendJson.is_rst_update = true;
        }else {
          this.oldOrdMainList.forEach(item => {
            const isSelectedTreat = structData.selectedTreat.length > 0 ? structData.selectedTreat.includes(parseInt(item.indTreatmentCd)) : true;
            const isSelectedKur = structData.selectedKur.length > 0 ? structData.selectedKur.includes(parseInt(item.indKurCd)) : true;
            const isTreatWeek = weekList.length > 0 ? weekList.includes(parseInt(item.treatWeek)) : true;
            if(item.rstDialysisState !=="0" && isSelectedTreat && isSelectedKur && isTreatWeek) {
              isRstHave = true;
            }
          });
            //mod 7114 治療中の透析指示の投与薬剤、医療材料、指示コメント削除を実施した場合の注意メッセージがない 張 start
          // if (isRstHave && (structData.flag === 1 || structData.flag === 2) && !this.$parent.$parent.$parent.$parent.$parent.$parent.isShowedMessage) {
            if (isRstHave && (structData.flag === 1 || structData.flag === 2|| structData.flag === 3) && !this._indicationResultOwner().isShowedMessage) {
            //mod 7114 治療中の透析指示の投与薬剤、医療材料、指示コメント削除を実施した場合の注意メッセージがない 張 end

              //mod #10266  start
              // if (await this.showUpdateCheckDialog(structData.flag)) {
              if (this.settingIndData.update_flag != "2" && await this.showUpdateCheckDialog(structData.flag)) {
              //mod #10266  end

                //add FNSI内容修正 バグ284、286 姜 start
              // FNSI-修正 #5800(#4707)DEへの投与薬剤変更通知用、外部Api調用、xugj modify start
              if (this.medicineInputValue.initValue !== this.medicineInputValue.initValue
                || this.amountInputValue.initValue !== this.amountInputValue.editValue
                || this.procedureSelectValue.initValue !== this.procedureSelectValue.editValue
                || this.timingSelectValue.initValue !== this.timingSelectValue.editValue
                || this.commentInputValue.initValue !== this.commentInputValue.editValue) {
                // FNSI-修正 #5800(#4707)DEへの投与薬剤変更通知用、外部Api調用、xugj modify end
                //mod FNSI-5800 劉全航 start
                // if (this.ordNoMediList.length > 0) {
                  // this.ordNoMediList.forEach(ordNo => {
                    if (this.oldOrdMainList.length > 0) {
                    this.oldOrdMainList.forEach(ord =>{
                      /* add #IES_6790 by zhangruixue 2023-07-04 --start */
                      sendJson.ords.push(ord.ordNo)
                      /* add #IES_6790 by zhangruixue 2023-07-04 --end */
                      //mod FNSI-5800 劉全航 end
                      /* mod #IES_6790 by zhangruixue 2023-07-04 --start */
                    // this.sendGetNoticeMedi(ord.ordNo).then(results=>{
                    //   if (results.data == true) {
                    //     this.getMstMachineByOrdNoRst(ord.ordNo).then(machineRes => {
                    //       const params = {
                    //         ordNo: ord.ordNo, //オーダー番号
                    //         machineNo: machineRes.data[0].machineNo, //装置マスタ.装置番号
                    //         deviceEdgeNo: machineRes.data[0].deviceEdgeNo, //デバイスエッジ番号
                    //         facilityCd: this.facilityCd //施設コード
                    //       };
                    //       try {
                    //         this.sendRequestChangeIndMediInfoRst(params);
                    //       } catch (e) {
                    //         //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
                    //         getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', '装置へ送信に失敗しました。');
                    //         //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
                    //         this.$ons.notification.alert({
                    //           modifier: "warn",
                    //           // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                    //           // title: "送信に失敗しました",
                    //           // message: `装置へ送信に失敗しました。`
                    //           title: DIALOG_MESSAGES['00200033'].title,
                    //           message: messageFormat(DIALOG_MESSAGES['00200033'].message),
                    //           // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                    //         });
                    //       }
                    //     });
                    //   }
                    // });
                      /* mod #IES_6790 by zhangruixue 2023-07-04 --end */
                  })
                }
              }
              //add FNSI内容修正 バグ284、286 姜 end
              sendJson.is_rst_update = true;
              if (structData.flag === 1) {
                this._indicationResultOwner().isRstUpdateFlg = true;
              }
              // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 start
            }else {
              sendJson.is_rst_update = false;
              // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end
            }
          }
        }
      }
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end

      let response = null;
      // add FNSI-連携イベントの登録適正化 楊 start
      // let opeCd = "";
      /* modify by chamaojia 2023-08-09 [9303] この判断条件は必要ない  --start */
      // if (structData.nLstFlg != 1) {
      sendJson.hosp_pat_id = this.selectedPat.pat_personal_main.hosp_pat_id;
      sendJson.user_id = this.getStateUserAccountInfo.userId;
      // }
      /* modify by chamaojia 2023-08-09 [9303] この判断条件は必要ない  --end */
      // add FNSI-連携イベントの登録適正化 楊 end
      switch (structData.flag) {
        case 1:
          /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---start */
          // response = await ApiHelper.post(
          //   "/mainData/createOrdMainMediInfo/",
          //   sendJson
          // ).catch(error => {
          //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          //   getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', error);
          //   //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          //   throw error;
          // });
          this.finishLoadingScreen();
          return sendJson;
          /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---end */
          // add FNSI-連携イベントの登録適正化 楊 start
          // opeCd = "004023";
          // add FNSI-連携イベントの登録適正化 楊 end
          //break;
        case 2:
          // 投与薬剤修正時、amountが未変更の場合は追加
          var indInfoObj = JSON.parse(sendJson.ind_info);
          if (!Object.prototype.hasOwnProperty.call(indInfoObj, 'amount') || indInfoObj.amount === null || indInfoObj.amount === '') {
            indInfoObj.amount = this.fieldsComputed.amount;
            sendJson.ind_info = JSON.stringify(indInfoObj);
          }
          // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
          if (structData.type && 'upd' === structData.type) {
            response = await ApiHelper.post(
              "/patients/medications/update",
              sendJson).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', error);
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              this.finishLoadingScreen();
              throw error;
            });
          } else {
            // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end
            response = await ApiHelper.post(
              "/mainData/updateOrdMainMediInfo",
              sendJson).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', error);
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              this.finishLoadingScreen();
              throw error;
            });
          }
          // add FNSI-連携イベントの登録適正化 楊 start
          if (this.procedureSelectValue.initValue !== this.procedureSelectValue.editValue ||
            // mod FNSI-小数点の修正 楊 start
            // this.amountInputValue.initValue !== this.amountInputValue.editValue ||
            this.amountInputValue.initValue != this.amountInputValue.editValue ||
            // mod FNSI-小数点の修正 楊 end
            this.medicineInputValue.initValue !== this.medicineInputValue.editValue) {
            // opeCd = "004024";
          }
          // add FNSI-連携イベントの登録適正化 楊 end
          break;
        case 3:
          // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm start
          if (structData.type && 'del' === structData.type) {
            response = await ApiHelper.post(
              "/patients/medications/delete",
              sendJson).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', error);
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              this.finishLoadingScreen();
              throw error;
            });
          } else {
            // add #12471 ord_main.ind_medi_infoに不正データが登録される zkm end
            response = await ApiHelper.post(
              "/mainData/deleteOrdMainMediInfo",
              sendJson).catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', error);
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              this.finishLoadingScreen();
              throw error;
            });
          }
          // add FNSI-連携イベントの登録適正化 楊 start
          // opeCd = "004025";
          // add FNSI-連携イベントの登録適正化 楊 end
          break;
        default:
          // 該当なし
          break;
      }
      /* add #IES_6790 by zhangruixue 2023-07-04 --start */
      if (this.medicineInputValue.initValue !== this.medicineInputValue.initValue
        || this.amountInputValue.initValue !== this.amountInputValue.editValue
        || this.procedureSelectValue.initValue !== this.procedureSelectValue.editValue
        || this.timingSelectValue.initValue !== this.timingSelectValue.editValue
        || this.commentInputValue.initValue !== this.commentInputValue.editValue) {
        // FNSI-修正 #5800(#4707)DEへの投与薬剤変更通知用、外部Api調用、xugj modify end
        //mod FNSI-5800 劉全航 start
        // if (this.ordNoMediList.length > 0) {
        // this.ordNoMediList.forEach(ordNo => {
        if (this.oldOrdMainList.length > 0) {
          this.oldOrdMainList.forEach(ord =>{
            //mod FNSI-5800 劉全航 end
            this.sendGetNoticeMedi(ord.ordNo).then(results=>{
              if (results.data == true) {
                this.getMstMachineByOrdNoRst(ord.ordNo).then(machineRes => {
                  const params = {
                    ordNo: ord.ordNo, //オーダー番号
                    machineNo: machineRes.data[0].machineNo, //装置マスタ.装置番号
                    deviceEdgeNo: machineRes.data[0].deviceEdgeNo, //デバイスエッジ番号
                    facilityCd: this.facilityCd //施設コード
                  };
                  try {
                    this.sendRequestChangeIndMediInfoRst(params);
                  } catch (e) {
                    //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
                    getErrorMessage('IndMedicineEdit.vue', 'updateIndInfo', '装置へ送信に失敗しました。');
                    //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
                    this.$ons.notification.alert({
                      modifier: "warn",
                      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                      // title: "送信に失敗しました",
                      // message: `装置へ送信に失敗しました。`
                      title: DIALOG_MESSAGES['00200033'].title,
                      message: messageFormat(DIALOG_MESSAGES['00200033'].message),
                      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                    });
                  }
                });
              }
            });
          })
        }
      }
      /* add #IES_6790 by zhangruixue 2023-07-04 --end */
      // mod FNSI-連携イベントの登録適正化 楊 start
      // ビューア画面の投与薬剤モーダルより内容を修正し保存した時
      // const params = {
      //   facility_cd: this.facilityCd,
      //   coop_cd: "ind_dial",
      //   coop_cd_index: "",
      //   crud: "U",
      //   direction: "S",
      //   ana_result:"0",
      //   coop_result:"0",
      //   pat_id : structData.patId,
      //   ord_no : this.settingIndData.ordNo,
      //   user_id: this.getStateUserAccountInfo.userId
      // };
      // if (this.settingIndData.ordNo) {
      //   createJournal(params);
      // } else {
      //   if (this.oldOrdMainList) {
      //     this.oldOrdMainList.forEach(item => {
      //       const isSelectedTreat = structData.selectedTreat.includes(item.indTreatmentCd);
      //       const isSelectedKur = structData.selectedKur.includes(item.indKurCd);
      //       if (structData.selectedKur.length > 0) {
      //         if (isSelectedKur) {
      //           createJournal({...params, ord_no: item.ordNo});
      //         }
      //       } else {
      //         if (structData.selectedTreat.length > 0) {
      //           if (isSelectedTreat) {
      //             createJournal({...params, ord_no: item.ordNo});
      //           }
      //         } else {
      //           createJournal({...params, ord_no: item.ordNo});
      //         }
      //       }
      //     });
      //   }
      // }
      // if (200 === response.status && opeCd) {
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
      // mod FNSI-連携イベントの登録適正化 楊 end

      this.finishLoadingScreen();
      return response;
    },
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
            }else {
              rtn = false;
              // add キャンセル（実績に反映しない）を選択　⇒　実績に反映される修正  xmj 2022-08-11 end
          }
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
        this.medicineInputValue.initValue !== this.medicineInputValue.editValue) {
        changeCount++;
      }
      // mod FNSI-小数点の修正 楊 start
      // if (this.amountInputValue.initValue !== this.amountInputValue.editValue) {
      if (this.amountInputValue.initValue != this.amountInputValue.editValue) {
        // mod FNSI-小数点の修正 楊 end
        changeCount++;
      }
      if (
        this.procedureSelectValue.initValue !==
        this.procedureSelectValue.editValue) {
        changeCount++;
      }
      if (
        this.timingSelectValue.initValue !== this.timingSelectValue.editValue) {
        changeCount++;
      }
      if (
        this.commentInputValue.initValue !== this.commentInputValue.editValue) {
        changeCount++;
      }
      return 0 !== changeCount ? true : false;
    },

    /**
     * 数量以外が変更されたかどうかチェック
     */
    getIsEditotherAmount() {
      let isEdit = false;
      // 薬剤コードが変更されたかチェック
      isEdit =
        this.medicineInputValue.initValue !== this.medicineInputValue.editValue
          ? true
          : isEdit;

      // 手技が変更されたかチェック
      isEdit =
        this.procedureSelectValue.initValue !==
        this.procedureSelectValue.editValue
          ? true
          : isEdit;

      // 投与タイミングが変更されたかどうかチェック
      isEdit =
        this.timingSelectValue.initValue !== this.timingSelectValue.editValue
          ? true
          : isEdit;

      // コメントが変更されたかどうかチェック
      isEdit =
        this.commentInputValue.initValue !== this.commentInputValue.editValue
          ? true
          : isEdit;
      return isEdit;
    },

    getScopedElementByIdSafe(id) {
      return getScopedElementById(id, this.$el || null);
    },
    getNextIndex() {
      return (this.$ && this.$.uid) || 0;
    },

    setContentData(newValue) {
      this.commentInputValue.editValue = newValue;
      // mod FNSI-4882 劉全航 start
      if(newValue === ""){
        this.commentInputValue.editValue = null;
      }
      this.changeValue();
      // mod FNSI-4882 劉全航 end
    },

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    isEdit() {
      const treatCondItems = this.$refs;
      let editCount = 0;
      Object.keys(treatCondItems).forEach(key => {
        if ((treatCondItems[key] && treatCondItems[key].isEdited)
          // #10196 中止です 日が変わります 操作卓エラー linjunfeng start
          // || (treatCondItems[key][0] && treatCondItems[key][0].isEdited)
          // || (key === "comment" && (treatCondItems[key].content.initValue !== treatCondItems[key].content.editValue))) {
          || (key === "comment" && (treatCondItems[key]?.content?.initValue !== treatCondItems[key]?.content?.editValue))) {
          // #10196 中止です 日が変わります 操作卓エラー 操作卓エラー linjunfeng end

          // 変更箇所数格納
          editCount += 1;
        }
      });
      if (0 === editCount) {
        return false;
      }
      return true;
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async resetComponentIndData(structData){
      if (this.isEdit()) {
        this._indicationDialogOwner().messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this._indicationDialogOwner().messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        return this.getComponentData(structData,2);
      }
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async getComponentData(structData,answer) {

      if (answer === 1) {
        return;
      }

      let indWeeks = [
        {
          text: "全",
          done: true,
          value: 0
        },
        {
          text: "月",
          done: true,
          value: 1
        },
        {
          text: "火",
          done: true,
          value: 2
        },
        {
          text: "水",
          done: true,
          value: 3
        },
        {
          text: "木",
          done: true,
          value: 4
        },
        {
          text: "金",
          done: true,
          value: 5
        },
        {
          text: "土",
          done: true,
          value: 6
        },
        {
          text: "日",
          done: true,
          value: 7
        }
      ];
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = structData.facilityCd;
      // 患者情報
      paramJson.pat_id = structData.patId;
      // 治療開始日時
      paramJson.start_date = structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = "";
      // クール
      paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 曜日パターン
      paramJson.weeks = JSON.stringify(indWeeks);

      // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
      let response = await ApiHelper.post(
        "/mainData/getOrdMainDataInfo",
        paramJson).catch(error => {
        getErrorMessage('IndEquipmentEditBase.vue', 'getComponentData', error);
        throw error;
      });

      let ordMainData = response.data;
      if(ordMainData && ordMainData.length > 0) {
        // #10266 投与薬剤子ヘッダー押下,  開始日が変わり、数、手技、投とタイミロング、コメンドが不正確に表示されます。 linjunfeng start
        // ordMainData = ordMainData[0];
        ordMainData = ordMainData.find(item =>
          item.indMediInfo != null &&
          item.indMediInfo !== "[]" &&
          JSON.parse(item.indMediInfo).some(info => info.cd === this.fieldsData.cd) &&
          item.rstDialysisState === "0");
        if (!ordMainData) {
          return;
        }
        // #10266 投与薬剤子ヘッダー押下,  開始日が変わり、数、手技、投とタイミロング、コメンドが不正確に表示されます。 linjunfeng end
      } else {
        return;
      }

      // 最新の検索結果すべてを画面に設定する
      const dataObject  = ordMainData ? JSON.parse(ordMainData.indMediInfo) : null;
      let indMediInfo = null;
      for(let data of dataObject) {
        if(data.cd === this.medicinePopoverData.popoverContentSelected.value) {
          indMediInfo = data;
        }
      }
      if(!indMediInfo) {
        indMediInfo = dataObject[0];
      }
      // #10196 投与薬剤行ヘッダー子 キーボードの上下ボタンで開始日を変更コンソールエラーを返します linjunfeng start
      if(!indMediInfo) {
        return;
      }
      // #10196 投与薬剤行ヘッダー子 キーボードの上下ボタンで開始日を変更コンソールエラーを返します linjunfeng end

      // 初期値設定
      this.amountInputValue.initValue = Number(indMediInfo.amount);
      this.procedureSelectValue.initValue = indMediInfo.procedure_cd;
      this.timingSelectValue.initValue = indMediInfo.timing_cd;
      this.commentInputValue.initValue = indMediInfo.comment;

      if(answer === 3) {
        if (this.initValueModel.medicine != null
          && (this.medicinePopoverData.popoverContentSelected.value != this.initValueModel.medicine)) {

          indMediInfo.cd = this.medicinePopoverData.popoverContentSelected.value;
        }
        if (this.amountInputValue.editValue != this.initValueModel.amount) {
          indMediInfo.amount = this.amountInputValue.editValue;
        }
        if (this.procedureSelectValue.editValue != this.initValueModel.procedure) {
          indMediInfo.procedure_cd = this.procedureSelectValue.editValue;
        }
        if (this.timingSelectValue.editValue != this.initValueModel.timing) {
          indMediInfo.timing_cd = this.timingSelectValue.editValue;
        }
        if (this.commentInputValue.editValue != this.initValueModel.comment) {
          indMediInfo.comment = this.commentInputValue.editValue;
        }
      }

      this.medicinePopoverData.popoverContentSelected.value = indMediInfo.cd;
      this.amountInputValue.editValue = indMediInfo.amount;
      this.procedureSelectValue.editValue = indMediInfo.procedure_cd;
      this.timingSelectValue.editValue = indMediInfo.timing_cd;
      this.commentInputValue.editValue = indMediInfo.comment;

      this.initValueModel = {
          medicine: this.medicinePopoverData.popoverContentSelected.value,
          amount: this.amountInputValue.initValue,
          procedure: this.procedureSelectValue.initValue,
          timing: this.timingSelectValue.initValue,
          comment: this.commentInputValue.initValue
      }
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    // mod FNSI-4882 劉全航 start
    changeValue(){
      if(this.procedureSelectValue.initValue !== this.procedureSelectValue.editValue
       ||this.timingSelectValue.initValue !== this.timingSelectValue.editValue
       ||this.commentInputValue.initValue !== this.commentInputValue.editValue){
         this.$emit("changeFlag",true);
      }else{
        this.$emit("changeFlag",false);
      }
    }
    // mod FNSI-4882 劉全航 end
  },

  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
  async created() {
    this._indicationDialogOwner().isDialogType9 = true;
    //FNSI-修正 #5525 横展開対応、xugj add start
    this._indicationResultOwner().isSendNextPatInfoFlg = true;
    //FNSI-修正 #5525 横展開対応、xugj add end
    // 治療方法セットマスタ 手技&投与タイミング没有值 zhao start
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // this.getMstProcedure({ facilityCd: this.facilityCd });
    // this.getMstMedicateTiming({ facilityCd: this.facilityCd });
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    // 治療方法セットマスタ 手技&投与タイミング没有值 zhao end
  }
  //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
};
</script>

<style scoped>
.row-style {
  margin: 2.5px 0px;
  align-items: center;
}

.medicine-input-style {
  width: 70%;
  margin: 0px 5px 0px 0px;
}

.amount-input-style {
  width: 90px;
}

.select-style {
  width: 100%;
}

div :deep(.comment-textarea-style) {
  height: 2.5em;
  box-sizing: border-box;
}

.medicine-column {
  /* add FNSI-薬剤指示画面等の画面崩れの修正 楊 start */
  /*flex: 0 0 30%;*/
  flex: 0 0 9.4em;
  /* add FNSI-薬剤指示画面等の画面崩れの修正 楊 end */
  max-width: 30%;
  white-space: normal;
}

.medicine-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}

.medicine-custom-input {
  display: inline-flex;
}
/*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start*/
:deep(.com-basic-sub-btn) {
  margin-left: 5px
}
:deep(.com-basic-sub-input) {
  min-width: 13em;
  width: 100%;
  max-width: 28em;
  background-color: #f7f7f7;
}
/* // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end*/
</style>
