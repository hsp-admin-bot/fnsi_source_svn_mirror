/** * 治療条件ーダイアライザ */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagDialyzer ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">ダイアライザ</v-ons-col>
    <common-master-selector
      :masterType="MasterType.DIALYZER_TREATMENT_RECORD"
      :initItem="dialyzerSelectorInitItem"
      :editItem="{ text: displayInputValue.editValue, value: displayInputValue.editCd }"
      :patientId="selectedPatId"
      :extraParams="{ treatDate: mstExtraParams.treatDate }"
      :facilityCd="facilityCd"
      :dialysisState="Number(rstDialysisState || 0)"
      :hasChangedOption="true"
      :selectedItemClass="'com-basic-sub-input'"
      :backgroundColor="'#ebebe4'"
      :btnClass="'com-basic-sub-btn'"
      :btnDisabled="getIsUseFlagDialyzer || !getItemAuthorized('Indication', 'default_authority')"
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
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
// import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
//add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
// import dayjs from "@/compat/date/dayjs";
//add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { buildMasterPopover } from "@/components/common/master-selector/builder/builderFactory";

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
      mstExtraParams: {
        treatDate: "",
        rstInfo: {
          rstName: "",
          rstUnit: ""
        }
      },
      MasterType,
      // 画面を開いた時に選択状態になっている対象のコードを保持
      localSelectedCd: null,
      masterLabelForCd: null,
      rstNameForCd: null,
    };
  },
  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      deviceMode: "getDeviceMode",
      // add 8204 周安寧 start
      getIsUseFlagDialyzer: "getIsUseFlagDialyzer"
      // add 8204 周安寧 end
    }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    rstDialysisState() {
      const orderMainData = (this.getSettingIndData || this.settingIndData)?.orderMainData;
      return orderMainData && orderMainData.rstDialysisState != null
        ? orderMainData.rstDialysisState
        : 0;
    },
    isActualRst() {
      return Number(this.rstDialysisState || 0) !== 0;
    },
    dialyzerSelectorInitItem() {
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

  async mounted() {
    this.localSelectedCd = this.value;
    this.treatItemCd = "5";

    if (!this.mstExtraParams.treatDate) {
      this.mstExtraParams.treatDate = this.normalizeTreatDate(this.getIndStartDate);
    }
    await this.createPopoverData();
    const selectedMst = this.popoverData.popoverContentDataset.find(item => {
      return item.value == this.value; // mod #9973 value Number→文字列  shiyw
    });
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
        this.isIndication && initItem && initItem.value != null ? initItem.value : initCdVal;
      this.displayInputValue.initCd = initCdVal;
      this.displayInputValue.editCd = editCdVal;
      this.displayInputValue.text = this.displayInputValue.editValue;
      this.popoverData.popoverContentSelected = initItem ? initItem : selectedMst;
    }
  },

  watch: {
    getIndStartDate: {
      handler(val) {
        this.mstExtraParams.treatDate = this.normalizeTreatDate(val);
      },
      immediate: true
    },
    // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 start
    deviceMode() {
      // 積層型ダイアライザが選択されていた場合は未登録に強制変更、積層型ダイアライザーを候補から外す。
      if (this.isMst && 10 === this.deviceMode) { //I-HDF
        if (this.popoverData.popoverContentSelected.value && this.popoverData.popoverContentSelected.fnValue.ダイアライザ種別 === "1") {
          const dataTemp = {text: "", value: null}
          this.updateInput(dataTemp)
        }
      }
    }
    // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 end
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
          メーカー: val.maker,
          ダイアライザ種別: val.dialyzerType,
          機能分類: val.functionClass
        },
        isDisp: val.isDisp,
        text: val.text,
        type: val.dialyzerType,
        value: val.value
      };
      this.updateInputNew(data, "5");
    },
    async createPopoverData() {
      const initValue =
        this.displayInputValue.initCd != null && this.displayInputValue.initCd !== ""
          ? this.displayInputValue.initCd
          : this.value;
      const extraParams = {
        treatDate: this.mstExtraParams.treatDate,
        initValue
      };
      const context = {
        facilityCd: this.facilityCd,
        patientId: this.selectedPatId,
        extraParams,
        initItem: { value: initValue },
        selectedItem: { value: this.value },
        dialysisState: Number(this.rstDialysisState || 0),
      };
      const popover = await buildMasterPopover(
        MasterType.DIALYZER_TREATMENT_RECORD,
        context
      ).catch(error => {
        getErrorMessage("IndTreatCondDialyzer.vue", "createPopoverData", error);
        throw error;
      });

      const baseOptions = popover?.master?.options ?? [];
      const baseCategories = popover?.categories ?? [];
      let options = baseOptions;
      let categories = baseCategories;

      // 積層型ダイアライザが選択されていた場合は未登録に強制変更、積層型ダイアライザーを候補から外す。
      if (this.isMst && 10 === this.deviceMode) { //I-HDF
        options = baseOptions.filter(item => String(item.dialyzerType) !== "1");
        categories = baseCategories.map(category => {
          if (category.key !== "dialyzerType") return category;
          return {
            ...category,
            options: (category.options || []).filter(opt => String(opt.value) !== "1")
          };
        });
      }

      this.contentDataset = options;

      const filtered = options.filter(
	      // mod #10937 20260428 Ji start
        //item => item.isDisp === "1" || String(item.value) == String(this.localSelectedCd)
        item => item.isDisp === "1" || String(item.value) == String(this.localSelectedCd)|| String(item.value) == String(this.velue)
        // mod #10937 20260428 Ji end
      );

      const masterRow = filtered.find(o => String(o.value) === String(this.localSelectedCd));
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

      let contentArr = filtered.map(item => ({
        ...item,
        fnValue: {
          メーカー: item.maker,
          ダイアライザ種別: item.dialyzerType,
          機能分類: item.functionClass
        },
        type: item.dialyzerType,
        text:
          rstName && String(item.value) === String(this.localSelectedCd)
            ? rstName
            : item.text,
      }));
      contentArr = contentArr.sort((a, b) => b.isDisp - a.isDisp);

      this.popoverData.popoverTitleHeader = "ダイアライザ";
      this.popoverData.popoverFilter = categories.map(category => ({
        popoverFilterLabel: category.label,
        popoverFilterDataset: category.options
      }));
      this.popoverData.popoverContentLabel = "ダイアライザ名";
      this.popoverData.popoverContentDataset = contentArr;
      this.popoverData.type = this.treatItemCd;
    },
    sortPopoverValue(a,b) {
        let r = 0;
        if( a.value < b.value ){ r = -1; }
        else if( a.value > b.value ){ r = 1; }
        return r;
    },
  }
};
</script>
