/** 指示有効な医療材料 編集画面 */
<template>
  <v-ons-row class="row-style">
    <v-ons-col class="equipment-column">{{ equipmentSelectLabel }}</v-ons-col>
    <v-ons-col class="equipment-data-column equipment-selector-column">
      <common-master-selector
        ref="masterSelector"
        class="equipment-master-selector-stretch"
        :masterType="MasterType.VALID_IND_EQUIPMENT"
        :initItem="masterSelectorInitItem"
        :editItem="masterSelectorEditItem"
        :extraParams="masterSelectorExtraParams"
        :patientId="selectedPatId"
        :facilityCd="facilityCd"
        :dialysisState="Number(rstDialysisState || 0)"
        :hasChangedOption="true"
        :changeOptionMode="'nameAndUnit'"
        :hasUnregisteredOption="false"
        popoverExtraClass="valid-ind-equip-master-popover"
        :selectedItemClass="'equipment-input-style'"
        :backgroundColor="'#ebebe4'"
        :btnClass="'common-style-select-button'"
        :btnDisabled="!getItemAuthorized('Indication', 'default_authority')"
        :beforeCreatePopover="beforeMasterCreatePopover"
        @popover-return="masterUpdateInput"
      />
    </v-ons-col>
  </v-ons-row>
</template>

<script>
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { mapGetters } from "@/compat/vue/vuex";
import IndicationOwnerMixin from "@/components/indication/IndicationOwnerMixin";
import { EventBus } from "@/compat/vue/event-bus.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { ApiHelper } from "@/apis/AxiosHelper";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from "@/functions/common/MessageFormat";
import ValidIndEquipmentSelectMixin from "@/components/indication/ValidIndEquipmentSelectMixin";
import CommonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import {
  decryptDialyzerCdToPersistentCode,
  detectEquipTypeFromCode,
  encryptPersistentCodeToInternalCd,
} from "@/functions/EquipTypeFunctions";

export default {
  mixins: [IndicationOwnerMixin, ValidIndEquipmentSelectMixin],
  components: {
    "common-master-selector": CommonMasterSelector,
  },

  emits: ["input"],

  props: {
    fieldsDisabled: {
      type: Boolean,
      default: false,
    },
    fieldsData: {
      type: Object,
      default: () => ({
        cd: null,
        amount: 0,
        unit: null,
        equipType: 0,
      }),
    },
    showEquipmentFieldOnly: {
      type: Boolean,
      default: false,
    },
    equipmentSelectLabel: {
      type: String,
      default: "医療材料",
    },
    hideAutoInsertField: {
      type: Boolean,
      default: false,
    },
    showAllSelectTag: {
      type: Boolean,
      default: false,
    },
    hasDialyzerOption: {
      type: Boolean,
      default: false,
    },
    isCreate: {
      type: Boolean,
      default: false,
    },
  },

  data() {
    return {
      MasterType,
      dialyzerDataset: [],
      equipmentDatatest1: [],
      equipmentDataset: [],
      autoInsertValue: {
        initValue: 0,
        editValue: 0,
      },
      equipmentInputValue: {
        initValue: null,
        editValue: null,
      },
      unitLabelValue: null,
      oldOrdMainList: [],
      selectedEquipment: {
        cd: null,
        equipType: 0,
      },
      cdTest: null,
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-viewer", {
      ordNoList: "getOrdNoList",
      getIndEndDate: "getIndEndDate",
    }),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    ...mapGetters("pat-info", ["selectedPat"]),

    rstDialysisState() {
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

    masterSelectorValue() {
      const selected =
        this.popoverDataValidIndEquipment &&
        this.popoverDataValidIndEquipment.popoverContentSelected;
      if (selected && selected.value != null) {
        return selected.value;
      }
      const cd = this.fieldsData && this.fieldsData.cd;
      const equipType = this.fieldsData && this.fieldsData.equipType;
      if (cd == null) return null;
      return encryptPersistentCodeToInternalCd(cd, equipType);
    },

    masterSelectorInitItem() {
      return {
        text: this.isActualRst
          ? this.rstNameForCd != null && this.rstNameForCd !== ""
            ? this.rstNameForCd
            : this.equipmentInputValue
              ? this.equipmentInputValue.initValue
              : null
          : this.equipmentInputValue
            ? this.equipmentInputValue.initValue
            : null,
        value: this.masterSelectorValue,
        unit:
          this.popoverDataValidIndEquipment.popoverContentSelected?.unit ?? null,
      };
    },

    masterSelectorEditItem() {
      const selectedVal =
        this.popoverDataValidIndEquipment &&
        this.popoverDataValidIndEquipment.popoverContentSelected &&
        this.popoverDataValidIndEquipment.popoverContentSelected.value;
      return {
        text: this.equipmentInputValue ? this.equipmentInputValue.editValue : null,
        value: selectedVal != null ? selectedVal : this.masterSelectorValue,
        unit:
          this.popoverDataValidIndEquipment.popoverContentSelected?.unit ?? null,
      };
    },

    masterSelectorExtraParams() {
      return {
        structData: this.structData,
        fieldsData: this.fieldsData,
        showAllSelectTag: this.effectiveShowAllSelectTag,
        selectedEquipment: this.selectedEquipment,
        popoverContentSelected:
          this.popoverDataValidIndEquipment.popoverContentSelected,
        mstEquipmentClass: this.mstEquipmentClass,
        mstEquipment: this.mstEquipment,
        mstDialyzer: this.mstDialyzer,
        mstEquipmentDialyzerIncludedDeleted:
          this.mstEquipmentDialyzerIncludedDeleted,
        currentOrdMainData: this.currentOrdMainData,
        validIndEquipments: this.validIndEquipments,
        refreshValidList: false,
      };
    },

    fieldsComputed() {
      const selected = this.popoverDataValidIndEquipment.popoverContentSelected || {};
      if (selected.value == null) {
        return { cd: null, equipType: 0 };
      }
      return {
        cd: decryptDialyzerCdToPersistentCode(selected.value),
        equipType: detectEquipTypeFromCode(selected.value),
      };
    },
  },

  watch: {
    fieldsComputed(data) {
      this.$emit("input", data);
    },
  },

  beforeUnmount() {
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    checkMstDispStatus() {
      if (this.fieldsData.cd === null) {
        return;
      }
    },
    masterUpdateInput(val) {
      if (!val) {
        return;
      }
      const isDialyzer =
        val?.fnValue?.["医療材料分類"] === "dialyzer" ||
        detectEquipTypeFromCode(val?.value) === 1;

      const mapped = {
        text: val?.text,
        value: val?.value ?? null,
        fnValue: isDialyzer
          ? { 医療材料分類: "dialyzer" }
          : {
              医療材料分類:
                val?.classCd ?? val?.fnValue?.["医療材料分類"] ?? null,
            },
        unit: val?.unit ?? null,
        isDisp: val?.isDisp,
        useStartDate: val?.useStartDate,
        useEndDate: val?.useEndDate,
      };

      this.popoverDataValidIndEquipment.popoverContentSelected = mapped;
      this.equipmentInputValue.editValue = mapped.text || null;
      this.cdTest = mapped.value;
      this.changeButton();
    },
    async updateIndInfo(structData, targetEdit = null, targetEditType = null) {
      const doctorList = structData.userOptions;
      const doctor = doctorList.find(
        doctor => doctor.user_id === Number(structData.indUser)
      );
      const indInfo = {
        class_cd: null,
        class_name: null,
        class_type: null,
        cd: this.fieldsComputed.cd,
        name: this.equipmentInputValue.editValue,
        short_name: null,
        needle_type: this.fieldsComputed.needleType,
        amount: this.fieldsComputed.amount,
        unit: this.unitLabelValue,
        ind_user_id: structData.indUser,
        ind_user_last_name: doctor.user_last_name,
        ind_user_first_name: doctor.user_first_name,
        upd_user_id: structData.updUser,
        upd_user_last_name: null,
        upd_user_first_name: null,
        input_class: 1,
        is_editable: 1,
        cop_order_no: 1,
        equip_type: this.fieldsComputed.equipType,
      };

      const sendJson = {
        pat_id: structData.patId,
        facility_cd: this.facilityCd,
        start_date: structData.indStartDate,
        end_date: structData.indEndDate,
        weeks: JSON.stringify(structData.indWeeks),
        ind_kur_cd: JSON.stringify(structData.selectedKur),
        ind_treatment_cd: JSON.stringify(structData.selectedTreat),
        ind_info: JSON.stringify(indInfo),
        auto_insert: this.autoInsertValue.editValue,
        target_equip_edit: targetEdit,
        is_edit_other_amount: this.fieldsComputed.cd !== targetEdit,
        is_deadline: structData.isDeadline,
        target_equip_edit_type: targetEditType,
        is_rst_update: false,
        update_flag: this.settingIndData.update_flag,
      };

      const startDate = structData.indStartDate.replace(/-/g, "");
      const endDate =
        structData.indEndDate == null
          ? null
          : structData.indEndDate.replace(/-/g, "");
      const searchData = await ApiHelper.get(
        `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      ).catch(error => {
        getErrorMessage("IndEquipmentEdit.vue", "updateIndInfo", error);
        throw error;
      });
      this.oldOrdMainList = searchData.data;

      const weekList = [];
      structData.indWeeks.forEach(eleItem => {
        if (eleItem.done === true) {
          weekList.push(parseInt(eleItem.value));
        }
      });
      const resultOwner = this._indicationResultOwner();
      if (this.oldOrdMainList) {
        let isRstHave = false;

        if (structData.flag === 1 && resultOwner.isRstUpdateFlg === true) {
          sendJson.is_rst_update = true;
        } else {
          this.oldOrdMainList.forEach(item => {
            const isSelectedTreat =
              structData.selectedTreat.length > 0
                ? structData.selectedTreat.includes(parseInt(item.indTreatmentCd))
                : true;
            const isSelectedKur =
              structData.selectedKur.length > 0
                ? structData.selectedKur.includes(parseInt(item.indKurCd))
                : true;
            const isTreatWeek =
              weekList.length > 0
                ? weekList.includes(parseInt(item.treatWeek))
                : true;
            if (
              item.rstDialysisState !== "0" &&
              isSelectedTreat &&
              isSelectedKur &&
              isTreatWeek
            ) {
              isRstHave = true;
            }
          });
          if (
            isRstHave &&
            (structData.flag === 1 || structData.flag === 2 || structData.flag === 3) &&
            !resultOwner.isShowedMessage
          ) {
            if (
              this.settingIndData.update_flag != "2" &&
              (await this.showUpdateCheckDialog(structData.flag))
            ) {
              sendJson.is_rst_update = true;
              if (structData.flag === 1) {
                resultOwner.isRstUpdateFlg = true;
              }
            } else {
              sendJson.is_rst_update = false;
            }
          }
        }
      }
      if (structData.nLstFlg != 1) {
        sendJson.hosp_pat_id = this.selectedPat.pat_personal_main.hosp_pat_id;
        sendJson.user_id = this.getStateUserAccountInfo.userId;
      }
      let response = null;
      switch (structData.flag) {
        case 1:
          return sendJson;
        case 2:
          response = await ApiHelper.post(
            "/mainData/updateOrdMainEquipInfo/",
            sendJson
          ).catch(error => {
            getErrorMessage("IndEquipmentEdit.vue", "updateIndInfo", error);
            throw error;
          });
          break;
        case 3:
          if (structData.type && "equip-del" === structData.type) {
            response = await ApiHelper.post("/patients/equip/delete", sendJson).catch(
              error => {
                getErrorMessage("IndEquipmentSet.vue", "updateIndInfo", error);
                throw error;
              }
            );
          } else {
            response = await ApiHelper.post(
              "/mainData/deleteOrdMainEquipInfo/",
              sendJson
            ).catch(error => {
              getErrorMessage("IndEquipmentEdit.vue", "updateIndInfo", error);
              throw error;
            });
          }
          break;
        default:
          break;
      }

      return response;
    },
    async showUpdateCheckDialog(flag) {
      let rtn = false;
      await this.$ons.notification.confirm({
        title: DIALOG_MESSAGES[13000050].title,
        message: messageFormat(DIALOG_MESSAGES[13000050].message),
        callback: answer => {
          if (answer === 1) {
            rtn = true;
          } else {
            rtn = false;
          }
        },
      });
      if (flag === 1) {
        this._indicationResultOwner().isShowedMessage = true;
      }

      return rtn;
    },
    checkEdit() {
      return this.equipmentInputValue.initValue !== this.equipmentInputValue.editValue;
    },
  },
};
</script>

<style scoped>
.row-style {
  margin: 2.5px 0px;
  width: 100%;
}

/* common-master-selector 内の show-selected-item へ deep で当てる（IndEquipmentEdit と同様） */
:deep(.equipment-input-style) {
  width: 70%;
  flex: 0 0 70%;
  max-width: 70%;
  min-width: 0;
  box-sizing: border-box;
  margin: 0px 5px 0px 0px;
}

.equipment-column {
  flex: 0 0 9.4em;
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

/* 子 MasterPicker の flex 行が親幅いっぱいに広がる */
:deep(.equipment-master-selector-stretch > ons-col) {
  flex: 1 1 auto;
  min-width: 0;
  width: 100%;
  max-width: 100%;
}
</style>

<!-- POP は body 直下に出るため scoped 外で旧 MasterSelector 相当サイズを指定 -->
<style lang="css">
.valid-ind-equip-master-popover.popover-style .popover__content {
  width: 500px !important;
  min-width: 500px;
  box-sizing: border-box;
}

.valid-ind-equip-master-popover.popover-style .popover--top,
.valid-ind-equip-master-popover.popover-style .popover--right,
.valid-ind-equip-master-popover.popover-style .popover--left,
.valid-ind-equip-master-popover.popover-style .popover--bottom {
  max-width: none;
}

/* 旧 select size="10" 相当：件数が少なくても一覧高さを維持 */
.valid-ind-equip-master-popover .master-list-scroll {
  min-height: 13.5em;
  max-height: 13.5em;
}

@media screen and (max-height: 420px) {
  .valid-ind-equip-master-popover.popover-style .popover__content {
    width: 500px !important;
    min-width: 500px;
  }
}
</style>
