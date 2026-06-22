/** * 治療条件ー1次膜 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagFirstPass ? 'cell-disabled' : ''" >
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">1次膜</v-ons-col>
    <common-master-selector
      :masterType="MasterType.EQUIPMENT_TREATMENT_CLASSTYPE_RECORD"
      :initItem="equipmentSelectorInitItem"
      :editItem="{ text: displayInputValue.editValue, value: displayInputValue.editCd, unit: rstUnitForCd }"
      :patientId="selectedPatId"
      :extraParams="{ treatDate: mstExtraParams.treatDate, classType: filmClassType, actualName: rstNameForCd }"
      :facilityCd="facilityCd"
      :dialysisState="Number(rstDialysisState || 0)"
      :hasChangedOption="true"
      :changeOptionMode="'nameAndUnit'"
      :selectedItemClass="'com-basic-sub-input'"
      :backgroundColor="'#ebebe4'"
      :btnClass="'com-basic-sub-btn'"
      :btnDisabled="getIsUseFlagFirstPass || !getItemAuthorized('Indication', 'default_authority')"
      @popover-return="masterUpdateInput($event);"
    />
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters } from "@/compat/vue/vuex";
import { MASTER_MAINTENANCE_CURRENT_ROUTE_NAME } from "@/constants/masterMaintenanceConstants";
import { PATVIEWER_CURRENT_ROUTE_NAME } from "@/constants/PatViewerConstants";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { ApiHelper } from "@/apis/AxiosHelper";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { buildMasterPopover } from "@/components/common/master-selector/builder/builderFactory";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { CODES } from "@/constants/TreatmentRecord";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
export default {
  mixins: [IndTreatCondBase],
  components: {
    "common-master-selector": commonMasterSelector,
  },

  data() {
    return {
      displayInputValue: {
        initValue: null,
        editValue: null,
        text: "",
        editCd: "",
        initCd: "",
      },
      masterLabelForCd: null,
      masterUnitForCd: null,
      rstUnitForCd: null,
      rstUnitBaselineForCd: null,
      rstNameForCd: null,
      mstExtraParams: {
        treatDate: "",
        rstInfo: {
          rstName: "",
          rstUnit: "",
        },
      },
      MasterType,
      filmClassType: "5,6",
      // 画面を開いた時に選択状態になっている対象のコードを保持
      localSelectedCd: null
    };
  },
  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    // add 8204 周安寧 start
    ...mapGetters("pat-viewer-treat-cond", {getIsUseFlagFirstPass: "getIsUseFlagFirstPass"}),
    // add 8204 周安寧 end
    rstDialysisState() {
      const orderMainData = (this.getSettingIndData || this.settingIndData)?.orderMainData;
      return orderMainData && orderMainData.rstDialysisState != null
        ? orderMainData.rstDialysisState
        : 0;
    },
    isActualRst() {
      return Number(this.rstDialysisState || 0) !== 0;
    },
    equipmentSelectorInitItem() {
      return {
        text: this.isActualRst
          ? this.rstNameForCd != null && this.rstNameForCd !== ""
            ? this.rstNameForCd
            : this.displayInputValue.editValue
          : this.displayInputValue.initValue,
        value: this.displayInputValue.initCd,
        unit: this.isActualRst
          ? this.rstUnitBaselineForCd != null && this.rstUnitBaselineForCd !== ""
            ? this.rstUnitBaselineForCd
            : this.masterUnitForCd
          : this.masterUnitForCd
      };
    }
  },

  async mounted() {
    this.localSelectedCd = this.value;
    this.treatItemCd = "7";

    if (!this.mstExtraParams.treatDate) {
      this.mstExtraParams.treatDate = this.normalizeTreatDate(this.getIndStartDate);
    }
    await this.createPopoverData();
    const selectedMst = this.popoverData.popoverContentDataset.find(item => {
      return item.value == this.value; // mod #9973 value Number→文字列  shiyw
    });
    //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start
    //if (selectedMst) {
        //this.displayInputValue.initValue = selectedMst.text;
        //this.displayInputValue.editValue = selectedMst.text;
        //this.popoverData.popoverContentSelected = selectedMst;
    const selectedEditMst = this.popoverData.popoverContentDataset.find(item => {
      // mod #10937 20260428 Ji start
      // return item.value == this.value; // mod #9973 value Number→文字列  shiyw
      return item.value == (this.velue ?? this.value);
      // mod #10937 20260428 Ji end
    });
    if (selectedMst || selectedEditMst) {
      const masterText =
        this.masterLabelForCd != null && this.masterLabelForCd !== ""
          ? this.masterLabelForCd
          : (selectedMst ? selectedMst.text : "");
      this.displayInputValue.initValue = masterText;
      this.displayInputValue.editValue = this.isIndication
        ? (selectedEditMst ? selectedEditMst.text : "")
        : (selectedMst ? selectedMst.text : masterText);
      const initCdVal = selectedMst && selectedMst.value != null ? selectedMst.value : this.value;
      const editCdVal =
        this.isIndication && selectedEditMst && selectedEditMst.value != null
          ? selectedEditMst.value
          : initCdVal;
      this.displayInputValue.initCd = initCdVal;
      this.displayInputValue.editCd = editCdVal;
      this.displayInputValue.text = this.displayInputValue.editValue;
      this.popoverData.popoverContentSelected = selectedEditMst ? selectedEditMst : selectedMst;
    //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
    }
  },

  watch: {
    getIndStartDate: {
      handler(val) {
        this.mstExtraParams.treatDate = this.normalizeTreatDate(val);
      },
      immediate: true
    },
  },

  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    normalizeTreatDate(val) {
      if (val == null) return "";
      return String(val).replaceAll("-", "");
    },
    masterUpdateInput(val = {}) {
      this.displayInputValue.editValue = val.text;
      this.displayInputValue.text = val.text;
      this.displayInputValue.editCd = val.value;

      const data = {
        fnValue: {
          医療材料分類: val.classCd,
        },
        isDisp: val.isDisp,
        text: val.text,
        value: val.value,
        unit: val.unit,
      };
      this.updateInputNew(data, "7");
    },

    async createPopoverData() {
      const initValue =
        this.displayInputValue.initCd != null && this.displayInputValue.initCd !== ""
          ? this.displayInputValue.initCd
          : this.value;
      const extraParams = {
        treatDate: this.mstExtraParams.treatDate,
        classType: this.filmClassType,
        initValue
      };
      const context = {
        facilityCd: this.facilityCd,
        patientId: this.selectedPatId,
        extraParams,
        initItem: { value: initValue },
        selectedItem: { value: this.value },
        dialysisState: Number(this.rstDialysisState || 0)
      };

      const popover = await buildMasterPopover(
        MasterType.EQUIPMENT_TREATMENT_CLASSTYPE_RECORD,
        context
      ).catch(error => {
        getErrorMessage("IndTreatCondFirstPass.vue", "createPopoverData", error);
        throw error;
      });

      const baseOptions = popover?.master?.options ?? [];
      const categories = popover?.categories ?? [];

      let options = baseOptions;
      const conds = [PATVIEWER_CURRENT_ROUTE_NAME, MASTER_MAINTENANCE_CURRENT_ROUTE_NAME];
      if (conds.includes(this.$route.name)) {
        options = baseOptions.filter(item => {
          return (
            fitTermCheck(item.useStartDate, item.useEndDate, this.getIndStartDate) ||
            String(item.value) == String(this.localSelectedCd) ||
            // add #10937 20260428 Ji start
            String(item.value) == String(this.velue)
            // add #10937 20260428 Ji end
          );
        });
      }

      options = options.filter(item => {
        // mod #10937 20260428 Ji start
        return item.isDisp === "1" || String(item.value) == String(this.localSelectedCd) || String(item.value) == String(this.velue);
        // mod #10937 20260428 Ji end
      });

      const masterRow = options.find(o => String(o.value) === String(this.localSelectedCd));
      this.masterLabelForCd = masterRow && masterRow.text != null ? String(masterRow.text) : null;
      this.masterUnitForCd = masterRow && masterRow.unit != null && masterRow.unit !== "" ? String(masterRow.unit) : null;

      let rstName = "";
      let rstUnit = "";
      const orderMainData = (this.getSettingIndData || this.settingIndData)?.orderMainData;
      if (
        orderMainData &&
        orderMainData.rstDialysisState != 0
      ) {
        const rstCondInfo = orderMainData.indCondInfo;
        const rstCondInfoObj = rstCondInfo ? JSON.parse(rstCondInfo) : [];
        const rstRow = rstCondInfoObj[this.treatItemCd];
        rstName = rstRow?.value_name_1;
        rstUnit = rstRow?.unit;
      }
      this.rstUnitForCd = rstUnit != null && rstUnit !== "" ? String(rstUnit) : null;
      this.rstUnitBaselineForCd =
        rstUnit != null && rstUnit !== "" ? String(rstUnit) : null;
      if (this.isActualRst && this.rstUnitForCd != null && this.rstUnitForCd !== "") {
        this.unit = this.rstUnitForCd;
      }
      this.rstNameForCd = rstName != null && rstName !== "" ? String(rstName) : null;

      let contentArr = options.map(item => ({
        ...item,
        fnValue: { 医療材料分類: item.classCd },
        text:
          rstName && String(item.value) == String(this.localSelectedCd)
            ? rstName
            : item.text,
      }));
      contentArr = contentArr.sort((a, b) => b.isDisp - a.isDisp);

      this.popoverData.popoverTitleHeader = "医療材料";
      this.popoverData.popoverFilter = categories.map(category => ({
        popoverFilterLabel: category.label,
        popoverFilterDataset: category.options,
      }));
      this.popoverData.popoverContentLabel = "医療材料名";
      this.popoverData.popoverContentDataset = contentArr;
      this.popoverData.type = this.treatItemCd;
    },
  }
};
</script>
