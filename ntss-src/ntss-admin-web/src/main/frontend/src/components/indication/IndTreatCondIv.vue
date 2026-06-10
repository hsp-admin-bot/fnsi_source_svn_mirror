/** * 治療条件ー補液 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIv ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">補液</v-ons-col>
    <v-ons-col class="action-condition-data-column" style="display: flex;">
      <show-selected-item
        :propInitValue="displayInputValue.initValue"
        :propEditValue="displayInputValue.editValue"
        propBackgroundColor="#ebebe4"
        class="action-condition-input"
      />
      <!-- mod 8204 周安寧 start -->
      <!-- <v-ons-button
        ref="popoverButton"
        class="common-style-select-button"
        :disabled="isOnlineReplenish"
        @click="
          createPopoverData();
          showPopover();
          changeButton();
        "
      >-->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <v-ons-button -->
      <!--   ref="popoverButton" -->
      <!--   class="common-style-select-button" -->
      <!--   :disabled="isOnlineReplenish || getIsUseFlagIv" -->
      <!--   @click=" -->
      <!--     createPopoverData(); -->
      <!--     showPopover(); -->
      <!--     changeButton(); -->
      <!--   " -->
      <!-- > -->
      <v-ons-button
        ref="popoverButton"
        class="common-style-select-button"
        :disabled="isOnlineReplenish || getIsUseFlagIv || !getItemAuthorized('Indication', 'default_authority')"
        @click="
        createPopoverData();
        showPopover();
        changeButton();"
      >
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
        選択
      </v-ons-button>
    </v-ons-col>
    <!-- mod 8681 ljx start -->
<!--    <pop-over
      v-bind="popoverData"
      :target-position-element="$refs.popoverButton"
      @popover-close="closePopover"
      @popover-return="updateInput"
    />-->
    <pop-over
      v-bind="popoverData"
      :treat-item-cd="treatItemCd"
      :target-position-element="$refs.popoverButton"
      @popover-close="closePopover"
      @popover-return="updateInputNew($event,'19')"
    />
    <!-- mod 8681 ljx end -->
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
import { mapGetters, mapMutations } from "vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { ApiHelper } from "@/apis/AxiosHelper";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
import {EventBus} from "@/eventBus";
//#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(透析液処理に吸収)　Start
import IndTreatCondDialysate from "@/components/indication/IndTreatCondDialysate";
//#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要　End
export default {
  //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(透析液処理に吸収)　Start
  mixins: [IndTreatCondBase, IndTreatCondDialysate],
  //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要　End
  data() {
    return {
      displayInputValue: {
        initValue: null,
        editValue: null
      },
      mstMedicine: [],
      mstMedicineMix: [],
      isChangedMedicineType: false,
      isDefaultSetUnitFlg: false
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
    }
  },

  watch: {
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
              let componentDataList = this.$parent.$parent.componentData.filter(item => {
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
            if(this.isDefaultSetUnitFlg || this.ivUnit === null){
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
    this.treatItemCd = "19";
    //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(以下薬剤区分フィルター削除) 透析液処理に吸収　Start
    //await this.createPopoverData();
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
      return item.value == this.velue; // mod #9973 value Number→文字列  shiyw
    });
    if (selectedMst || selectedEditMst) {
      this.displayInputValue.initValue = selectedMst ? selectedMst.text : '';
      this.displayInputValue.editValue = this.isIndication ? (selectedEditMst ? selectedEditMst.text : '') : this.displayInputValue.initValue;
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
          })
      }
      // this.displayInputValue.initValue = "未登録";
      // this.displayInputValue.editValue = "未登録";
      // this.popoverData.popoverContentSelected.value = null;
      // mod FNSI-FutreNetWeb+SI課題管理No.4878 李 end
    }
    // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end
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
        this.displayInputValue.initValue = dialysateInfo.medicineName;
        // #10739 コンバート施設で指示受け(治療単位)が表示されない linjunfeng start
        // this.displayInputValue.editValue = dialysateInfo.medicineName;
        const treatDate = this.getIndStartDate;
        const deviceModeOnlineClassType = [CODES.MEDICINE_CLASS.DIALYSATE.classType, CODES.MEDICINE_CLASS.REPLACEMENT.classType];
        this.displayInputValue.editValue = getPrefix({ 
            treatDate: treatDate,
            normalClassType: deviceModeOnlineClassType,
            ...dialysateInfo
        }) + dialysateInfo.medicineName;
         // #10739 コンバート施設で指示受け(治療単位)が表示されない linjunfeng end 
        this.popoverData.popoverContentSelected.value = this.dialysateCd;
      } else {
        this.displayInputValue.initValue = null;
        this.displayInputValue.editValue = null;
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
