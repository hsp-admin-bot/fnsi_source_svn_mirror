/** * 治療条件ー穿刺針V */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row v-if="!isSingleNeedle"> -->
    <v-ons-row v-if="!isSingleNeedle" :class="getIsUseFlagNeedleSelection ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">穿刺針(V)</v-ons-col>
    <common-master-selector
      :masterType="MasterType.EQUIPMENT_TREATMENT_CLASSTYPE_RECORD"
      :initItem="equipmentSelectorInitItem"
      :editItem="{ text: displayInputValue.editValue, value: displayInputValue.editCd, unit: rstUnitForCd }"
      :patientId="selectedPatId"
      :extraParams="{ treatDate: mstExtraParams.treatDate, classType: needleClassType, initValue: displayInputValue.initCd, actualName: rstNameForCd }"
      :facilityCd="facilityCd"
      :dialysisState="Number(rstDialysisState || 0)"
      :hasChangedOption="true"
      :changeOptionMode="'nameAndUnit'"
      :selectedItemClass="'com-basic-sub-input'"
      :backgroundColor="'#ebebe4'"
      :btnClass="'com-basic-sub-btn'"
      :btnDisabled="getIsUseFlagNeedleSelection || !getItemAuthorized('Indication', 'default_authority')"
      @popover-return="masterUpdateInput($event);"
    />
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapMutations } from "@/compat/vue/vuex";
import { equipmentAllergy, equipmentClass, equipmentIncludeDeleted } from "@/functions/mst/MstGetters.js";
import { MASTER_MAINTENANCE_CURRENT_ROUTE_NAME } from "@/constants/masterMaintenanceConstants";
import { PATVIEWER_CURRENT_ROUTE_NAME } from "@/constants/PatViewerConstants";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { ApiHelper } from "@/apis/AxiosHelper";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
import {EventBus} from "@/compat/vue/event-bus.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { CODES } from "@/constants/TreatmentRecord";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { buildMasterPopover } from "@/components/common/master-selector/builder/builderFactory";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
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
      needleClassType: 2,
      // 画面を開いた時に選択状態になっている対象のコードを保持
      localSelectedCd: null,
      // add #10937 20260428 Ji start
      type:'V'
      // add #10937 20260428 Ji end
    };
  },

  computed: {
    // mod #10937 20260428 Ji start
    ...mapGetters("pat-viewer-treat-cond", {
      isSingleNeedle: "getIsSingleNeedle",
      getNeedleInit: "getNeedleInit"
    }),
    // mod #10937 20260428 Ji end
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    // add 8204 周安寧 start
    // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
    ...mapGetters("pat-viewer-treat-cond", {getIsUseFlagNeedleV: "getIsUseFlagNeedleV",
    // add 8204 周安寧 end
    //  add 9664補液及び透析液仕様修正します yangqingzhe start
    getIsUseFlagNeedleSelection: "getIsUseFlagNeedleSelection"
    }),
    // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
      //  add 9664補液及び透析液仕様修正します yangqingzhe end
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
      // add #10937 20260428 Ji start
      const storeInit = this.getNeedleInit[this.type];
      // add #10937 20260428 Ji end
      return {
        text: this.isActualRst
          ? this.rstNameForCd != null && this.rstNameForCd !== ""
            ? this.rstNameForCd
            : this.displayInputValue.editValue
          // mod #10937 20260428 Ji start
          // : this.displayInputValue.initValue,
          : (storeInit ?? this.displayInputValue.initValue),
          // mod #10937 20260428 Ji end
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
    this.treatItemCd = "10";
    this.popoverData.needleType = 2;
    if (!this.mstExtraParams.treatDate) {
      this.mstExtraParams.treatDate = this.normalizeTreatDate(this.getIndStartDate);
    }

    await this.createPopoverData();
    const selectedMst = this.popoverData.popoverContentDataset.find(item => {
      return item.value == this.value; // mod #9973 value Number→文字列  shiyw
    });
    //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start
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
      // add #10937 20260428 Ji start
      this.setNeedleInit({
        type: this.type,
        value: masterText
      });
      // add #10937 20260428 Ji end
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
    //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
    }else{
        // FNSI-修正 マスタ削除の対応 wangchen add start
        if(this.value){
            ApiHelper.get("/mstInfo/mstEquipment/getByCd", {equipmentCd:this.value}).then((res) => {
              // mod FNSI-FutreNetWeb+SI課題管理No.4878 李 start
              if (res && res.data && res.data.isDisp == '1' && res.data.isDel == '0') {
                this.displayInputValue.initValue = res.data.equipmentName;
                this.displayInputValue.editValue = res.data.equipmentName;
              } else {
                this.displayInputValue.initValue = MASTER_DELETE_DISPLAY.DELETED + res.data.equipmentName;
                this.displayInputValue.editValue = MASTER_DELETE_DISPLAY.DELETED + res.data.equipmentName;
              }
              // mod FNSI-FutreNetWeb+SI課題管理No.4878 李 end
              //mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
              // this.displayInputValue.initValue = "削除済み "+res.data.equipmentName;
              // this.displayInputValue.editValue = "削除済み "+res.data.equipmentName;
              // this.displayInputValue.initValue = MASTER_DELETE_DISPLAY.DELETED+res.data.equipmentName;
              // this.displayInputValue.editValue = MASTER_DELETE_DISPLAY.DELETED+res.data.equipmentName;
              //mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
              // del FNSI redmine 4877 4879 劉祥霖 start
              //this.popoverData.popoverContentSelected = null;
              // del FNSI redmine 4877 4879 劉祥霖 end
            })
        }
        // FNSI-修正 マスタ削除の対応 wangchen add end
    }
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // this.checkMstDispStatus("equipmentCd");
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
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
    // add #10937 20260428 Ji start
    ...mapMutations("pat-viewer-treat-cond", [
      "setNeedleInit"
    ]),
    // add #10937 20260428 Ji end
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
      this.rstUnitForCd = val.unit != null && val.unit !== "" ? String(val.unit) : null;

      const data = {
        fnValue: {
          医療材料分類: val.classCd ?? val.classValue ?? val.key_class,
        },
        isDisp: val.isDisp,
        text: val.text,
        value: val.value,
        unit: val.unit,
      };
      this.updateInputNew(data, "10");
    },
    async createPopoverData() {
      const initValue =
        this.displayInputValue.initCd != null && this.displayInputValue.initCd !== ""
          ? this.displayInputValue.initCd
          : this.value;
      const extraParams = {
        treatDate: this.mstExtraParams.treatDate,
        classType: this.needleClassType,
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
        getErrorMessage("IndTreatCondNeedleV.vue", "createPopoverData", error);
        throw error;
      });

      const categories = popover?.categories ?? [];
      let options = popover?.master?.options ?? [];
      const conds = [PATVIEWER_CURRENT_ROUTE_NAME, MASTER_MAINTENANCE_CURRENT_ROUTE_NAME];
      if (conds.includes(this.$route.name)) {
        options = options.filter(item => {
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
        fnValue: { 医療材料分類: item.classCd ?? item.classValue ?? item.key_class },
        text:
          rstName && String(item.value) == String(this.localSelectedCd)
            ? rstName
            : item.text,
      }));
      contentArr = contentArr.sort((a, b) => b.isDisp - a.isDisp);

      this.contentDataset = options;
      this.popoverData.popoverTitleHeader = "医療材料";
      this.popoverData.popoverFilter = categories.map(category => ({
        popoverFilterLabel: category.label,
        popoverFilterDataset: category.options
      }));
      this.popoverData.popoverContentLabel = "医療材料名";
      this.popoverData.popoverContentDataset = contentArr;
      this.popoverData.type = this.treatItemCd;
    },
    async createPopoverDataLegacy() {
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // const dataSet = this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? await equipment(this.facilityCd) : await equipmentTabooAllergy(this.selectedPatId);
      const dataSet = this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? await equipmentIncludeDeleted(this.facilityCd) : await equipmentAllergy(this.selectedPatId, true);
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // 患者経過総合ビューア(予定)表示時は、予定範囲と薬剤の使用期限を見て表示内容を補正する
      //#8484　医療材料選択IFのリスト不正 追加修正　Start
      var conds = [ PATVIEWER_CURRENT_ROUTE_NAME , MASTER_MAINTENANCE_CURRENT_ROUTE_NAME];
      if (conds.includes(this.$route.name)) {
        //#8484　医療材料選択IFのリスト不正 追加修正　End
        this.contentDataset = dataSet.filter(equipment => {
          return fitTermCheck(equipment.useStartDate, equipment.useEndDate, this.getIndStartDate) || equipment.equipmentCd == this.localSelectedCd; // mod #9973 value Number→文字列  shiyw
        });
      } else {
        this.contentDataset = dataSet;
      }
      this.filterDataset = await equipmentClass(this.facilityCd);

      // ポップオーバのフィルタデータを取りまとめる
      const filterParam = item => {
        return item.classType === 2;
      };

      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd,
          needle: item.classType === 2 && item.classType
        };
      };

      let filterArr = this.filterDataset
        .filter(filterParam)
        .map(filterMapping);
      filterArr.unshift({ text: "すべて", value: 0 });

      // ポップオーバのコンテンツデータ(フィルタしたデータ)を取りまとめる
      const contentParam = item => {
        return filterArr.find(i => {
          // Mod #9973 fix the type of JSON value node.
          // return item.classCd === i.value;
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return item.classCd == i.value;
          return item.classCd == i.value || item.equipmentCd == this.localSelectedCd;
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
      };
      const contentParamIsDisp = item => {
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // return item.isDisp === "1";
        return item.isDisp === "1" || item.equipmentCd == this.localSelectedCd;
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      };
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let rstName = "";
      if (
        this.$route.name === PATVIEWER_CURRENT_ROUTE_NAME &&
        this.getSettingIndData &&
        this.getSettingIndData.orderMainData &&
        this.getSettingIndData.orderMainData.rstDialysisState != 0
      ) {
        const rstCondInfo = this.getSettingIndData.orderMainData.indCondInfo;
        const rstCondInfoObj = rstCondInfo ? JSON.parse(rstCondInfo) : [];
        rstName = rstCondInfoObj[this.treatItemCd]?.value_name_1;
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      const contentMapping = item => {
        return {
          value: item.equipmentCd,
          fnValue: {
            医療材料分類: item.classCd
          },
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: item.equipmentName
          text: rstName && item.equipmentCd == this.localSelectedCd ? rstName : getPrefix({
            treatDate: this.getIndStartDate,
            normalClassType: CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType,
            ...item
          }) + item.equipmentName,
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        };
      };

      const contentArr = this.contentDataset
        .filter(contentParam)
        .filter(contentParamIsDisp)
        .map(contentMapping);

      this.popoverData.popoverTitleHeader = "医療材料";
      this.popoverData.popoverFilter = [
        {
          popoverFilterLabel: "医療材料分類",
          popoverFilterDataset: filterArr
        }
      ];
      this.popoverData.popoverContentLabel = "医療材料名";
      this.popoverData.popoverContentDataset = contentArr;
    },
     //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
  }
};
</script>
