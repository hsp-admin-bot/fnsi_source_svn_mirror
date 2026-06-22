/** * 治療条件ー補液 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIv ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">補液</v-ons-col>
    <v-ons-col class="action-condition-data-column" style="display: flex;">
      <common-master-selector
        :masterType="MasterType.MEDICATION_TREATMENT_CLASSTYPE_RECORD"
        :initItem="equipmentSelectorInitItem"
        :editItem="{ text: displayInputValue.editValue, value: displayInputValue.editCd, unit: rstUnitForCd, unitSecond: receiptUnitForCd }"
        :patientId="selectedPatId"
        :extraParams="{
          treatDate: mstExtraParams.treatDate,
          rstInfo: mstExtraParams.rstInfo,
          classType: 3,
          initValue: displayInputValue.initCd,
          medicineType: medicineType,
          actualName: rstNameForCd,
          receiptUnit: receiptUnitForCd,
          compareReceiptUnit: true
        }"
        :facilityCd="facilityCd"
        :isMedicament="'1'"
        :hasChangedOption="true"
        :changeOptionMode="'nameAndUnit'"
        :dialysisState="dialysisStateSafe"
        :selectedItemClass="'com-basic-sub-input'"
        :backgroundColor="'#f7f7f7'"
        :btnClass="'com-basic-sub-btn'"
        :btnDisabled="isOnlineReplenish || getIsUseFlagIv || !getItemAuthorized('Indication', 'default_authority')"
        @popover-return="masterUpdateInput($event);"
      />
    </v-ons-col>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
// #10739 コンバート施設で指示受け(治療単位)が表示されない linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import {getAuthorized, getPrefix} from "@/functions/common/CommonFunctions.js";
import { CODES } from "@/constants/TreatmentRecord";
// #10739 コンバート施設で指示受け(治療単位)が表示されない linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapMutations } from "@/compat/vue/vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { ApiHelper } from "@/apis/AxiosHelper";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
import {EventBus} from "@/compat/vue/event-bus.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import dayjs from "@/compat/date/dayjs";
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { buildMasterPopover } from "@/components/common/master-selector/builder/builderFactory";
//#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(透析液処理に吸収)　Start
import IndicationOwnerMixin from '@/components/indication/IndicationOwnerMixin';
//#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 End
export default {
  //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(透析液処理に吸収)　Start
  mixins: [IndicationOwnerMixin, IndTreatCondBase],
  //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要　End
  components: {
    "common-master-selector": commonMasterSelector,
  },
  data() {
    return {
      kbnValue: "",
      mstExtraParams: {
        treatDate: "",
        rstInfo: {
          rstName: "",
          rstUnit: ""
        }
      },
      MasterType,
      displayInputValue: {
        initValue: null,
        editValue: null,
        text: "",
        editCd: "",
        initCd: ""
      },
      mstMedicine: [],
      mstMedicineMix: [],
      masterLabelForCd: null,
      masterUnitForCd: null,
      rstUnitForCd: null,
      rstUnitBaselineForCd: null,
      rstNameForCd: null,
      receiptUnitForCd: null,
      isChangedMedicineType: false,
      isDefaultSetUnitFlg: false,
      deletedMedicine: {
        cd : null,
        isMedicineTypeMix : false
      },
      localSelectedCd: null,
      initValue: this.value
    };
  },

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      deviceMode: "getDeviceMode",
      dialysateCd: "getDialysateCd",
      ivUnit: "getIvUnit",
      // add 8204 周安寧 start
      getIsUseFlagIv: "getIsUseFlagIv"
      // add 8204 周安寧 end
    }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    // mod FNSI-小数点の修正 楊 start
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    // mod FNSI-小数点の修正 楊 end

    isOnlineReplenish() {
      // add 補液は透析液にする。透析液変更の場合は補液も合わせて変更。王 start
      /*if (this.isMst) {
        return (
          this.deviceMode === 6 || // AFBF
          this.deviceMode === 10  // I-HDF
        )
      }*/
      //del 余分なlogを削除する 周安寧 start
      //console.log("11111" + this.getIsUseFlagIv);
      //del 余分なlogを削除する 周安寧 start
      if (this.isMst) {
        return (
          //FNSI  7066   AFBFはHDF，HFと同様に補液を薬剤マスターから選択可能にする事修正   xmj   改   start
          //this.deviceMode === 6 || // AFBF
          this.deviceMode === 10 ||// I-HDF
          this.deviceMode === 4 || //HD+補液
          this.deviceMode === 7 || //OHDF
          this.deviceMode === 8 || //OHF
          this.deviceMode === 5 // ECUM+補液
        );
      }
      return (
        //mod FNSI-6955 劉全航 start
        this.deviceMode === 10 || // I-HDF
        //mod FNSI-6955 劉全航 end
        this.deviceMode === 4 || //HD+補液
        this.deviceMode === 7 || //OHDF
        this.deviceMode === 8 || //OHF
        this.deviceMode === 5// ECUM+補液
        // mod #7884-治療モードAFBFにて、補液が選択出来ない_再発 徐博 start
        // this.deviceMode === 6  // AFBF
        // mod #7884-治療モードAFBFにて、補液が選択出来ない_再発 徐博 end
        //FNSI  7066   AFBFはHDF，HFと同様に補液を薬剤マスターから選択可能にする事修正   xmj   改   end
      );
      // add 補液は透析液にする。透析液変更の場合は補液も合わせて変更。王 end
      // del 治療方法セットマスタ OHDFの場合、補助液情報が正しくありません。 孔 start
      /*return (
        this.deviceMode === 4 || //HD+補液
        this.deviceMode === 7 || //OHDF
        this.deviceMode === 8 || //OHF
        this.deviceMode === 5 // ECUM+補液
      );*/
      // del 治療方法セットマスタ OHDFの場合、補助液情報が正しくありません。 孔 end
    },

    // 調製薬剤フラグ
    isMedicineTypeMix() {
      let medicineType = this.medicineType;
      if (
        this.isChangedMedicineType ||
        // this.displayInputValue.initValue !== this.displayInputValue.editValue
        this.displayInputValue.initValue != this.displayInputValue.editValue    // Mod #9973 By Tao.zhou fix the type of JSON value node.
      ) {
        // medicine_typeタイプに変更がある場合
        medicineType = this.editedMedicineType;
      }
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //return medicineType === "2";
      return medicineType == 2;
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    },
    dialysisStateSafe() {
      const val = this.settingIndData &&
                  this.settingIndData.orderMainData &&
                  this.settingIndData.orderMainData.rstDialysisState;
      return Number(val || 0);
    },
    isActualRst() {
      return this.dialysisStateSafe !== 0;
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

  watch: {
    getIndStartDate: {
      handler(val) {
        this.mstExtraParams.treatDate = this.normalizeTreatDate(val);
      },
      immediate: true
    },
    inputValue: {
      handler(data) {
        // add 9664補液及び透析液仕様修正します yangqingzhe start
        if(this.treatItemCd === "19"){
        // add 9664補液及び透析液仕様修正します yangqingzhe end
          let mstMedi = this.mstMedicine;
          let mediCd = "medicineCd";
          if (this.isMedicineTypeMix) {
            mstMedi = this.mstMedicineMix;
            mediCd = "medicineMixCd";
          }

          const medicine = mstMedi.find(item => {
            return item[mediCd] == data; // mod #9973 value Number→文字列  shiyw
          });
          //this.unit = medicine && medicine.unit;
          this.setIv(medicine ? {"value": medicine[mediCd]} : null);
          // del FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 start
          // this.setIvDisabled(!data);
          // del FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end
          if(medicine){
            // mod FNSI-小数点の修正 楊 start
            // this.setIvDecPoint(medicine.unitDecimalPointSecond);
            // mod 治療方法セットマスタ 補液使用数、透析液使用数の小数点桁数は、薬剤の指示単位小数部桁数と同じです 孔 start
            if (this.isMst) {
              // mod 9664補液及び透析液仕様修正します yangqingzhe start
              // this.setIvDecPoint(medicine.unitDecimalPoint);
              this.setIvDecPoint(medicine.unitDecimalPointSecond);
              this.setIvUnit(medicine["unitSecond"]);
              // mod 9664補液及び透析液仕様修正します yangqingzhe end
            } else {
              let componentDataList = this._indicationFlowOwner().componentData.filter(item => {
                return item.cd === 22;
              });
              let rstDialysisState = componentDataList[0].fields.rstDialysisState;
              if (rstDialysisState === "0" || this.popoverData.isMedicineCdChg) {
                this.setIvDecPoint(medicine.unitDecimalPointSecond);
              } else {
                // #9973 Mod by Zhou.tao fix this out of range problem. Start
                let valStr = componentDataList[0].fields.value.toString();
                // セルからの場合、DBデータ桁数を設定
                if (this.settingIndData.ordNo
                  && valStr
                  && typeof valStr === "string"
                  && valStr.indexOf(".") > 0
                ) {
                  this.setIvDecPoint(valStr.split(".")[1].length);
                } else {
                  // タイトルから場合、マスタの桁数設定
                  this.setIvDecPoint(medicine.unitDecimalPointSecond);
                }
                // #9973 Mod by Zhou.tao fix this out of range problem. End
              }
              // mod 治療方法セットマスタ 補液使用数、透析液使用数の小数点桁数は、薬剤の指示単位小数部桁数と同じです 孔 end
            }
            // mod FNSI-小数点の修正 楊 end
            if((this.isDefaultSetUnitFlg || this.ivUnit === null) && !this.isActualRst){
              this.setIvUnit(medicine["unitSecond"]);
              // add 10179 by kangjie 20240223 start
              // del #10196 数値IFのスタイル全不正 linjunfeng start
              // this.setIvDecPoint(medicine.unitDecimalPointSecond);
              // del #10196 数値IFのスタイル全不正 linjunfeng end
              // add 10179 by kangjie 20240223 end
            }
            /* delete by chamaojia 2024-02-28 [10196] Enter the save button on the editing page to use status error correction --start */
            // add FNSI-【8630】単位が表示されない対応 曲 start
            // if (this.isDefaultSetUnitFlg) {
            //   this.setIvUnitChangeFlag(true);
            // }
            // add FNSI-【8630】単位が表示されない対応 曲 end
            /* delete by chamaojia 2024-02-28 [10196] Enter the save button on the editing page to use status error correction --end */
            this.isDefaultSetUnitFlg = true;
          }else{
            if(this.isDefaultSetUnitFlg){
              this.setIvDecPoint(0);
              this.setIvUnit(null);
            }
          }
        }
      },
      deep: true
    },

    deviceMode() {
      this.setDialysateCdAsValue();
    },

    dialysateCd() {
      this.setDialysateCdAsValue();
    }
  },

  async mounted() {
    this.localSelectedCd = this.value;
    this.treatItemCd = "19";
    if (!this.mstExtraParams.treatDate) {
      this.mstExtraParams.treatDate = this.normalizeTreatDate(this.getIndStartDate);
    }
    //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(以下薬剤区分フィルター削除) 透析液処理に吸収　Start
    await this.createPopoverData();
    //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(以下薬剤区分フィルター削除) Start
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
      this.displayInputValue.editValue = this.isIndication ? (selectedEditMst ? selectedEditMst.text : '') : (selectedMst ? selectedMst.text : masterText);
      this.displayInputValue.text = this.displayInputValue.editValue;
      this.displayInputValue.initCd = selectedMst ? selectedMst.value : "";
      this.displayInputValue.editCd = selectedEditMst ? selectedEditMst.value : this.displayInputValue.initCd;
      this.mstExtraParams.rstInfo.rstUnit = (selectedEditMst || selectedMst).unit || "";
      this.rstUnitForCd =
        (selectedEditMst || selectedMst).unit != null && (selectedEditMst || selectedMst).unit !== ""
          ? String((selectedEditMst || selectedMst).unit)
          : this.rstUnitForCd;
      this.popoverData.popoverContentSelected = selectedEditMst ? selectedEditMst : selectedMst;
     //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
    // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 start
    //}
    } else {
      // mod FNSI-FutreNetWeb+SI課題管理No.4878 李 start
      if (this.value) {
          ApiHelper.get("/mstInfo/mstMedicine/getByCd", {medicineCd:this.value}).then((res) => {
            if (res && res.data && res.data.isDisp == '1' && res.data.isDel == '0') {
              this.displayInputValue.initValue = res.data.medicineName;
              this.displayInputValue.editValue = res.data.medicineName;
            } else {
              this.displayInputValue.initValue = MASTER_DELETE_DISPLAY.DELETED + res.data.medicineName;
              this.displayInputValue.editValue = MASTER_DELETE_DISPLAY.DELETED + res.data.medicineName;
              this.popoverData.popoverContentSelected.value = null;
            }
            this.displayInputValue.text = this.displayInputValue.editValue;
            this.displayInputValue.initCd = this.value;
            this.displayInputValue.editCd = this.value;
          })
      }
      // this.displayInputValue.initValue = "未登録";
      // this.displayInputValue.editValue = "未登録";
      // this.popoverData.popoverContentSelected.value = null;
      // mod FNSI-FutreNetWeb+SI課題管理No.4878 李 end
    }
    // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end
    this.mstExtraParams.treatDate = this.getIndStartDate || "";
    this.mstExtraParams.rstInfo.rstName =
      this.displayInputValue.editValue || this.displayInputValue.initValue || "";
    this.setDialysateCdAsValue();
    this.checkMstDispStatus("medicineCd");
  },

  methods: {
    ...mapMutations("pat-viewer-treat-cond", [
      "setIvDisabled",
      "setIvUnit",
      // add FNSI-【8630】単位が表示されない対応 曲 start
      "setIvUnitChangeFlag",
      // add FNSI-【8630】単位が表示されない対応 曲 end
      "setIv",
      "setIvDecPoint"
    ]),
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
      const kbnValue = val.kbnValue ?? val.type ?? val.key_type ?? this.medicineType;
      const classCd = val.classCd ?? val.classValue ?? val.key_class;
      this.displayInputValue.editValue = val.text;
      this.displayInputValue.text = val.text;
      this.displayInputValue.editCd = val.value;
      this.kbnValue = kbnValue;
      this.unit = val.unit ?? "";
      this.mstExtraParams.rstInfo.rstUnit = this.unit;
      this.rstUnitForCd =
        this.unit != null && this.unit !== "" ? String(this.unit) : this.rstUnitForCd;
      if (val?.unitSecond != null && val.unitSecond !== "") {
        this.setIvUnit(String(val.unitSecond));
        this.setIvUnitChangeFlag(true);
      }
      const data = {
        fnValue: {
          薬剤分類: classCd,
          薬剤区分: kbnValue
        },
        isDisp: val.isDisp,
        text: val.text,
        type: kbnValue,
        value: val.value,
        unit: this.unit
      };
      this.updateInputNew(data, "19");
    },

    async createPopoverData() {
      const initValue =
        this.displayInputValue.initCd != null && this.displayInputValue.initCd !== ""
          ? this.displayInputValue.initCd
          : this.value;
      const treatDate =
        this.normalizeTreatDate(this.getIndStartDate || this.mstExtraParams.treatDate || dayjs().format("YYYYMMDD"));
      this.mstExtraParams.treatDate = treatDate;
      const extraParams = {
        treatDate,
        rstInfo: this.mstExtraParams.rstInfo,
        classType: 3,
        initValue,
        medicineType: this.medicineType
      };
      const context = {
        facilityCd: this.facilityCd,
        patientId: this.selectedPatId,
        extraParams,
        initItem: { value: initValue },
        selectedItem: { value: this.value },
        hasChangedOption: true,
        isMedicament: "1",
        dialysisState: this.dialysisStateSafe,
        allowedFields: { showMedicineFieldOnly: false, data: [] }
      };

      const popover = await buildMasterPopover(
        MasterType.MEDICATION_TREATMENT_CLASSTYPE_RECORD,
        context
      ).catch(error => {
        getErrorMessage("IndTreatCondIv.vue", "createPopoverData", error);
        throw error;
      });

      const categories = popover?.categories ?? [];
      const options = popover?.master?.options ?? [];
      const filteredOptions = options.filter(item => {
        // mod #10937 20260428 Ji start
        return item.isDisp === "1" || String(item.value) == String(this.localSelectedCd) || String(item.value) == String(this.velue);
        // mod #10937 20260428 Ji end
      });

      const masterRow = filteredOptions.find(
        o => String(o.value) === String(this.localSelectedCd)
      );
      this.masterLabelForCd = masterRow && masterRow.text != null ? String(masterRow.text) : null;
      this.masterUnitForCd =
        masterRow && masterRow.unit != null && masterRow.unit !== ""
          ? String(masterRow.unit)
          : null;

      let rstName = "";
      let rstUnit = "";
      let receiptUnit = "";
      const om = this.settingIndData && this.settingIndData.orderMainData;
      if (
        om &&
        om.rstDialysisState != null &&
        String(om.rstDialysisState) !== "" &&
        Number(om.rstDialysisState) !== 0
      ) {
        const raw = om.indCondInfo;
        if (raw != null && raw !== "") {
          try {
            const obj = typeof raw === "string" ? JSON.parse(raw) : raw;
            const row = obj[this.treatItemCd] ?? obj[Number(this.treatItemCd)];
            rstName = row?.value_name_1 || "";
            rstUnit = row?.unit || "";
            const row22 = obj?.["22"] ?? obj?.[22];
            receiptUnit = row22?.unit || "";
          } catch (e) {
            rstName = "";
            rstUnit = "";
            receiptUnit = "";
          }
        }
      }
      this.rstUnitForCd =
        rstUnit != null && rstUnit !== "" ? String(rstUnit) : this.masterUnitForCd;
      this.rstUnitBaselineForCd =
        rstUnit != null && rstUnit !== "" ? String(rstUnit) : null;
      this.rstNameForCd = rstName != null && rstName !== "" ? String(rstName) : null;
      this.receiptUnitForCd = receiptUnit != null && receiptUnit !== "" ? String(receiptUnit) : null;
      if (this.receiptUnitForCd != null && this.receiptUnitForCd !== "") {
        this.setIvUnit(String(this.receiptUnitForCd));
        this.setIvUnitChangeFlag(true);
      }
      if (
        om &&
        om.rstDialysisState != null &&
        String(om.rstDialysisState) !== "" &&
        Number(om.rstDialysisState) !== 0 &&
        rstUnit != null &&
        rstUnit !== ""
      ) {
        this.unit = String(rstUnit);
      }

      const contentArr = filteredOptions.map(item => ({
        ...item,
        fnValue: {
          薬剤分類: item.classCd ?? item.classValue ?? item.key_class,
          薬剤区分: item.kbnValue ?? item.key_type
        },
        type: item.kbnValue ?? item.key_type,
        text:
          rstName && String(item.value) == String(this.localSelectedCd)
            ? String(rstName)
            : item.text
      }));

      this.mstMedicine = contentArr.filter(item => String(item.kbnValue ?? item.key_type) === "1");
      this.mstMedicineMix = contentArr.filter(item => String(item.kbnValue ?? item.key_type) === "2");
      this.contentDataset = [...this.mstMedicine, ...this.mstMedicineMix];
      this.popoverData.popoverTitleHeader = "薬剤";
      this.popoverData.popoverFilter = categories.map(category => ({
        popoverFilterLabel: category.label,
        popoverFilterDataset: category.options
      }));
      this.popoverData.popoverContentLabel = "薬剤名";
      this.popoverData.popoverContentDataset = contentArr;
      this.popoverData.type = this.treatItemCd;
    },

    /**
     * オンライン系治療方法を使用する場合、補液に透析液と同じ値に設定
     */
    setDialysateCdAsValue() {
      if (!this.isOnlineReplenish) return;

      let mstMedi = this.mstMedicine;
      let mediCd = "medicineCd";
      if (this.isMedicineTypeMix) {
        mstMedi = this.mstMedicineMix;
        mediCd = "medicineMixCd";
      }

      const dialysateCd = this.dialysateCd;
      const dialysateInfo = mstMedi.find(item => {
        // return item[mediCd] === dialysateCd;
        return item[mediCd] == dialysateCd;   // mod #9973  fix the type of JSON value node.
      });

      if (dialysateInfo) {
        this.masterLabelForCd = dialysateInfo.text != null ? String(dialysateInfo.text) : null;
        this.masterUnitForCd =
          dialysateInfo.unit != null && dialysateInfo.unit !== ""
            ? String(dialysateInfo.unit)
            : this.masterUnitForCd;

        let rstName = "";
        let rstUnit = "";
        const om = this.settingIndData && this.settingIndData.orderMainData;
        if (
          om &&
          om.rstDialysisState != null &&
          String(om.rstDialysisState) !== "" &&
          Number(om.rstDialysisState) !== 0
        ) {
          const raw = om.indCondInfo;
          if (raw != null && raw !== "") {
            try {
              const obj = typeof raw === "string" ? JSON.parse(raw) : raw;
              const row = obj[this.treatItemCd] ?? obj[Number(this.treatItemCd)];
              rstName = row?.value_name_1 || "";
              rstUnit = row?.unit || "";
            } catch (e) {
              rstName = "";
              rstUnit = "";
            }
          }
        }
        this.rstUnitForCd =
          rstUnit != null && rstUnit !== "" ? String(rstUnit) : this.masterUnitForCd;
        this.rstUnitBaselineForCd =
          rstUnit != null && rstUnit !== "" ? String(rstUnit) : null;
        this.rstNameForCd = rstName != null && rstName !== "" ? String(rstName) : null;

        const rawDialysisState =
          this.settingIndData &&
          this.settingIndData.orderMainData &&
          this.settingIndData.orderMainData.rstDialysisState;
        const isRst =
          rawDialysisState != null && String(rawDialysisState) !== "" && Number(rawDialysisState) !== 0;
        const editText =
          isRst && rstName ? String(rstName) : (dialysateInfo.text != null ? String(dialysateInfo.text) : "");
        this.displayInputValue.initValue = this.masterLabelForCd;
        this.displayInputValue.editValue = editText;
        this.displayInputValue.text = this.displayInputValue.editValue;
        this.displayInputValue.initCd = this.dialysateCd;
        this.displayInputValue.editCd = this.dialysateCd;
        this.mstExtraParams.rstInfo.rstUnit = dialysateInfo.unit ?? dialysateInfo.unitSecond ?? "";
        this.popoverData.popoverContentSelected.value = this.dialysateCd;
      } else {
        this.displayInputValue.initValue = null;
        this.displayInputValue.editValue = null;
        this.displayInputValue.text = null;
        this.displayInputValue.initCd = "";
        this.displayInputValue.editCd = "";
        this.popoverData.popoverContentSelected = {};
      }
      this.checkMstDispStatus("medicineCd");
    },
     //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
  }
};
</script>

<style scoped>
.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
</style>
