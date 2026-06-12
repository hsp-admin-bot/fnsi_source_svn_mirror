/** * 治療条件ーVA */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagVA ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">VA</v-ons-col>
    <common-master-selector
      :masterType="MasterType.VA_TREATMENT_RECORD"
      :initItem="vaSelectorInitItem"
      :editItem="{ text: displayInputValue.editValue, value: displayInputValue.editCd }"
      :patientId="selectedPatId"
      :facilityCd="facilityCd"
      :dialysisState="Number(rstDialysisState || 0)"
      :hasChangedOption="true"
      :selectedItemClass="'com-basic-sub-input'"
      :backgroundColor="'#ebebe4'"
      :btnClass="'com-basic-sub-btn'"
      :btnDisabled="getIsUseFlagVA || !getItemAuthorized('Indication', 'default_authority')"
      @popover-return="masterUpdateInput($event);"
    />
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// add 8204 周安寧 start
import { mapGetters } from "@/compat/vue/vuex";
// add 8204 周安寧 end
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { ApiHelper } from "@/apis/AxiosHelper";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { buildMasterPopover } from "@/components/common/master-selector/builder/builderFactory";

export default {
  mixins: [IndTreatCondBase],
  components: {
    "common-master-selector": commonMasterSelector,
  },
   // add 8204 周安寧 start
   computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-treat-cond", {getIsUseFlagVA: "getIsUseFlagVA"}),
    rstDialysisState() {
      const orderMainData = (this.getSettingIndData || this.settingIndData)?.orderMainData;
      return orderMainData && orderMainData.rstDialysisState != null
        ? orderMainData.rstDialysisState
        : 0;
    },
    isActualRst() {
      return Number(this.rstDialysisState || 0) !== 0;
    },
    vaSelectorInitItem() {
      return {
        text: this.isActualRst
          ? this.rstNameForCd != null && this.rstNameForCd !== ""
            ? this.rstNameForCd
            : this.displayInputValue.editValue
          : this.displayInputValue.initValue,
        value: this.displayInputValue.initCd
      };
    }
  },
  // add 8204 周安寧 end
  data() {
    return {
      displayInputValue: {
        initValue: null,
        editValue: null,
        text: "",
        editCd: "",
        initCd: ""
      },
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      initValue: this.value,
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      MasterType,
      masterLabelForCd: null,
      rstNameForCd: null,
      localSelectedCd: null,
    };
  },

  async mounted() {
    this.localSelectedCd = this.value;
    this.treatItemCd = "2";

    await this.createPopoverData();
    const selectedMst = this.popoverData.popoverContentDataset.find(item => {
      return item.value == this.value; // mod #9973 value Number→文字列  shiyw
    });
   //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start
    // if (selectedMst) {
    //   this.displayInputValue.initValue = selectedMst.text;
    //   this.displayInputValue.editValue = selectedMst.text;
    //   this.popoverData.popoverContentSelected = selectedMst;
    const initItem = this.popoverData.popoverContentDataset.find(item => {
      // mod #10937 20260428 Ji start
      // return item.value == this.value; // mod #9973 value Number→文字列  shiyw
      return item.value == (this.velue ?? this.value);
      // mod #10937 20260428 Ji end
    });
    if (selectedMst || initItem) {
      const masterText =
        this.masterLabelForCd != null && this.masterLabelForCd !== ""
          ? this.masterLabelForCd
          : (selectedMst ? selectedMst.text : "");
      this.displayInputValue.initValue = masterText;
      this.displayInputValue.editValue = this.isIndication
        ? (initItem ? initItem.text : "")
        : (selectedMst ? selectedMst.text : masterText);
      const initCdVal = selectedMst && selectedMst.value != null ? selectedMst.value : this.value;
      const editCdVal =
        this.isIndication && initItem && initItem.value != null
          ? initItem.value
          : initCdVal;
      this.displayInputValue.initCd = initCdVal;
      this.displayInputValue.editCd = editCdVal;
      this.displayInputValue.text = this.displayInputValue.editValue;
      this.popoverData.popoverContentSelected = initItem ? initItem : selectedMst;
    // 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
    }
  },

  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    masterUpdateInput(val = {}) {
      this.displayInputValue.editValue = val.text;
      this.displayInputValue.text = val.text;
      this.displayInputValue.editCd = val.value;

      const data = {
        fnValue: {
          VA方向: val.vaDirect ?? val.classValue,
        },
        isDisp: val.isDisp,
        text: val.text,
        value: val.value,
      };
      this.updateInputNew(data, "2");
    },
    async createPopoverData() {
      const initValue =
        this.displayInputValue.initCd != null && this.displayInputValue.initCd !== ""
          ? this.displayInputValue.initCd
          : this.value;
      const context = {
        facilityCd: this.facilityCd,
        patientId: this.selectedPatId,
        extraParams: { initValue },
        initItem: { value: initValue },
        selectedItem: { value: this.value },
        dialysisState: Number(this.rstDialysisState || 0),
      };

      const popover = await buildMasterPopover(MasterType.VA_TREATMENT_RECORD, context).catch(
        error => {
          getErrorMessage("IndTreatCondVa.vue", "createPopoverData", error);
          throw error;
        }
      );

      const categories = popover?.categories ?? [];
      const baseOptions = popover?.master?.options ?? [];

      const options = baseOptions.filter(
        // mod #10937 20260428 Ji start
        item => item.isDisp === "1" || String(item.value) == String(this.localSelectedCd)|| String(item.value) == String(this.velue)
        // mod #10937 20260428 Ji end
      );

      const masterRow = options.find(o => String(o.value) === String(this.localSelectedCd));
      this.masterLabelForCd =
        masterRow && masterRow.text != null ? String(masterRow.text) : null;

      let rstName = "";
      const orderMainData = (this.getSettingIndData || this.settingIndData)?.orderMainData;
      if (orderMainData && orderMainData.rstDialysisState != 0) {
        const raw = orderMainData.indCondInfo;
        if (raw != null && raw !== "") {
          try {
            const rstCondInfoObj = typeof raw === "string" ? JSON.parse(raw) : raw;
            const rstRow =
              rstCondInfoObj[this.treatItemCd] ?? rstCondInfoObj[Number(this.treatItemCd)];
            const n = rstRow && rstRow.value_name_1;
            rstName = n != null && n !== "" ? String(n) : "";
          } catch (e) {
            rstName = "";
          }
        }
      }
      this.rstNameForCd = rstName != null && rstName !== "" ? String(rstName) : null;

      const contentArr = options
        .map(item => ({
          ...item,
          fnValue: { VA方向: item.vaDirect ?? item.classValue },
          text:
            rstName && String(item.value) == String(this.localSelectedCd)
              ? rstName
              : item.text,
        }))
        .sort((a, b) => b.isDisp - a.isDisp);

      this.popoverData.popoverTitleHeader = "VA";
      this.popoverData.popoverFilter = categories.map(category => ({
        popoverFilterLabel: category.label,
        popoverFilterDataset: category.options,
      }));
      this.popoverData.popoverContentLabel = "VA名";
      this.popoverData.popoverContentDataset = contentArr;
      this.popoverData.type = this.treatItemCd;
    },
  }
};
</script>
