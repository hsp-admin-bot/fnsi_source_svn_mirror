/** * 治療条件ー抗凝固剤 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagAntiCoaguLant ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">抗凝固剤</v-ons-col>
    <!--<v-ons-col class="action-condition-data-column" style="display: flex;">-->
    <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
    <common-master-selector
      :masterType="MasterType.ANTICOAGULANT_INDICATION"
      :initItem="{text:displayInputValue.initValue,value:displayInputValue.initCd}"
      :editItem="{text:displayInputValue.editValue,value:displayInputValue.editCd}"
      :patientId="selectedPatId"
      :extraParams="mstExtraParams"
      :facilityCd="facilityCd"
      :isMedicament="'1'"
      :isSelectionRequired="true"
      :hasChangedOption="true"
      :dialysisState="dialysisStateSafe"
      :selectedItemClass="'com-basic-sub-input'"
      :backgroundColor="'#f7f7f7'"
      :btnClass="'com-basic-sub-btn'"
      :btnDisabled="getIsUseFlagAntiCoaguLant || !getItemAuthorized('Indication', 'default_authority')"
      @popover-return="masterUpdateInput($event);"
    />
    </v-ons-col>
      <!--<show-selected-item
        :propInitValue="displayInputValue.initValue"
        :propEditValue="displayInputValue.editValue"
        propBackgroundColor="#ebebe4"
        class="action-condition-input"
      />-->
      <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
      <!-- mod 8204 周安寧 start -->
      <!-- <v-ons-button
        ref="popoverButton"
        class="common-style-select-button"
        @click="
          createPopoverData();
          showPopover();
          changeButton();
        "
      > -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <v-ons-button -->
      <!--   ref="popoverButton" -->
      <!--   class="common-style-select-button" -->
      <!--   :disabled="getIsUseFlagAntiCoaguLant" -->
      <!--   @click=" -->
      <!--     createPopoverData(); -->
      <!--     showPopover(); -->
      <!--     changeButton(); -->
      <!--   " -->
      <!-- > -->
       <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
      <!--<v-ons-button
        ref="popoverButton"
        class="common-style-select-button"
        :disabled="getIsUseFlagAntiCoaguLant || !getItemAuthorized('Indication', 'default_authority')"
        @click="
          createPopoverData();
          showPopover();
          changeButton();
        "
      >-->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- mod 8204 周安寧 end -->
        <!--選択
      </v-ons-button>
    </v-ons-col>-->
    <!-- mod 8681 ljx start -->
<!--    <pop-over
      v-bind="popoverData"
      :target-position-element="$refs.popoverButton"
      @popover-close="closePopover"
      @popover-return="updateInput"
    />-->
    <!--<pop-over
      v-bind="popoverData"
      :treat-item-cd="treatItemCd"
      :target-position-element="$refs.popoverButton"
      @popover-close="closePopover"
      @popover-return="updateInputNew($event,'25')"
    />-->
    <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
    <!-- mod 8681 ljx end -->
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { mapMutations, mapGetters } from "vuex";
import { medicineAllergy, medicineClass, medicineMixAllergy } from "@/functions/mst/MstGetters.js";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { MASTER_MAINTENANCE_CURRENT_ROUTE_NAME } from "@/constants/masterMaintenanceConstants";
import { PATVIEWER_CURRENT_ROUTE_NAME } from "@/constants/PatViewerConstants";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import { ApiHelper } from "@/apis/AxiosHelper";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
import {EventBus} from "@/eventBus";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { CODES } from "@/constants/TreatmentRecord";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import moment from "moment";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { Master } from "@/models/common/master-selector-condition/Master";
import { getMstListCompose } from "@/apis/pat-prescription"

const CLASS_MISMATCH_LABEL = "【分類不一致】";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
export default {
  mixins: [IndTreatCondBase],
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
  components: {
    "common-master-selector": commonMasterSelector,
  },
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

  data() {
    return {
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      kbnValue:'',
      mstExtraParams:{
        treatDate:'',
        rstInfo:{
          rstName:'',
          rstUnit:''
        }
      },
      MasterType,
      displayInputValue: {
        initValue: null,
        editValue: null,
        text:'',
        editCd:'',
        initCd:'',
      },
      selectedMst:{},
      selectedEditMst:{},
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      mstMedicine: [],
      mstMedicineMix: [],
      isChangedMedicineType: false,
      isDefaultSetUnitFlg:false,
      deletedMedicine: {
        cd : null,
        isMedicineTypeMix : false
      },
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      initValue : this.value
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-treat-cond", {
      antiCoagulantUnit: "getAntiCoagulantUnit",
      // add 8204 周安寧 start
      getIsUseFlagAntiCoaguLant: "getIsUseFlagAntiCoaguLant"
      // add 8204 周安寧 end
    }),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    // mod FNSI-小数点の修正 楊 start
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    ...mapGetters("pat-viewer",
    [
      "getMstMedicineIncludeDeletedData",
      "getMstMedicineMixIncludeDeletedData"
    ]),
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end  
    // mod FNSI-小数点の修正 楊 end
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
      // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //return medicineType === "2";
	    return medicineType == "2";
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    },
    dialysisStateSafe() {
      const val = this.getSettingIndData &&
                  this.getSettingIndData.orderMainData &&
                  this.getSettingIndData.orderMainData.rstDialysisState;
      return Number(val || 0);
    }
  },

  watch: {
    inputValue: {
      handler(data) {
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
        this.setAntiCoagulant(medicine ? medicine: null);
        // del FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 start
        // this.setAntiCoagulantDisabled(!data);
        // del FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end

        if(medicine){
          // mod FNSI-小数点の修正 楊 start
          if (this.isMst) {
            this.setAntiCoagulantDecPoint(medicine.unitDecimalPoint);
          } else {
            let componentDataList = this.$parent.$parent.componentData.filter(item => {
              return item.cd === 26;
            });
            // mod FNSI redmine 4703 劉祥霖 start
            let rstDialysisState = "0";
            if(componentDataList&&componentDataList.length>0){
               rstDialysisState = componentDataList[0].fields.rstDialysisState;
            }
            // mod FNSI redmine 4703 劉祥霖 end
              if (rstDialysisState === "0" || this.popoverData.isMedicineCdChg) {
                this.setAntiCoagulantDecPoint(medicine.unitDecimalPoint);
              } else {
                // セルからの場合、DBデータ桁数を設定
                // mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 start
                // if (this.settingIndData.ordNo) {
                if (this.settingIndData.ordNo && componentDataList[0].fields.value.toString().split(".").length > 1) {
                // mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.28(外結)対応 韓 end
                  this.setAntiCoagulantDecPoint(componentDataList[0].fields.value.toString().split(".")[1].length);
                } else {
                  // タイトルから場合、マスタの桁数設定
                  this.setAntiCoagulantDecPoint(medicine.unitDecimalPoint);
                }
              }

          }
          // mod FNSI-小数点の修正 楊 end
          
          if(this.isDefaultSetUnitFlg || this.antiCoagulantUnit === null){
            this.setAntiCoagulantUnit(medicine["unit"]);
            //mod FNSI-5553 劉全航 start
            if(!medicine["unit"]){
               this.setAntiCoagulantFlowRateUnit("/h");
            }else{
              this.setAntiCoagulantFlowRateUnit(medicine["unit"] + "/h");
            }
            // this.setAntiCoagulantFlowRateUnit(medicine["unit"] + "/h");
            //mod FNSI-5553 劉全航 end
            this.setAntiCoagulantAmountTotalUnit(medicine["unit"]);
          }
          // add FNSI-【8630】単位が表示されない対応 曲 start
          if(this.isDefaultSetUnitFlg) {
            this.setAntiCoagulantUnitChangeFlag(true);
            this.setAntiCoagulantFlowRateUnitChangeFlag(true);
            this.setAntiCoagulantAmountTotalUnitChangeFlag(true);
          }
          // add FNSI-【8630】単位が表示されない対応 曲 end
          this.isDefaultSetUnitFlg = true;
        }else{
          if(this.isDefaultSetUnitFlg){
            this.setAntiCoagulantDecPoint(0);
            this.setAntiCoagulantUnit(null);
            this.setAntiCoagulantFlowRateUnit(null);
            this.setAntiCoagulantAmountTotalUnit(null);
          }
        }
      },
      deep: true
    },

    editedMedicineType() {
      this.isChangedMedicineType = true;
    }
  },

  async mounted() {
    this.treatItemCd = "25";
    await this.createPopoverData();
    
    // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    /*const selectedMst = this.popoverData.popoverContentDataset.find(
      item =>{
        // 薬剤マスタ・調製薬剤マスタを$で区別
        // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        //item.value == (this.isMedicineTypeMix ? `${this.value}$` : this.value) // mod #9973 value Number→文字列  shiyw
        return item.value == this.value && item.type == (this.isMedicineTypeMix ? "2" : "1")
  });
    //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou start
    const selectedEditMst = this.popoverData.popoverContentDataset.find(item => {
      //return item.value == (this.isMedicineTypeMix ? `${this.velue}$` : this.velue); // mod #9973 value Number→文字列  shiyw
      return item.value == this.value && item.type == (this.isMedicineTypeMix ? "2" : "1")
    });
    //if (selectedMst) {
      //this.displayInputValue.initValue = selectedMst.text;
      //this.displayInputValue.editValue = selectedMst.text;
      //this.popoverData.popoverContentSelected = selectedMst;
    if (selectedMst || selectedEditMst) {
      //this.displayInputValue.initValue = selectedMst ? selectedMst.text : '';
      //this.displayInputValue.editValue = this.isIndication ? (selectedEditMst ? selectedEditMst.text : '') : this.displayInputValue.initValue;
      this.selectedMst = selectedMst
      this.selectedEditMst = selectedEditMst
      this.popoverData.popoverContentSelected = selectedEditMst ? selectedEditMst :selectedMst ;
    // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou end
    // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 start
    //}
    } else {
      
      // FNSI-修正 マスタ削除の対応 wangchen add start
        if(this.value){
           // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 start
            // ApiHelper.get("/mstInfo/mstMedicine/getByCd", {medicineCd:this.value}).then((res) => {
            ApiHelper.get("/mstInfo/mstMedicine/getByCd", {medicineCd:this.value,medicineType:this.medicineType}).then((res) => {
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
                //let medicineName =this.medicineType ==="1" ? res.data.medicineName: res.data.medicineMixName;
                let medicineName =this.medicineType == 1 ? res.data.medicineName: res.data.medicineMixName;
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
                //add 5323 患者経過総合ビューアで分類が問題ない場合でも「分類不一致」と表示されることがある。張 start
                Mst.medicineClass(this.facilityCd).then(response=>{
                  const mstClassValue = response.find(mstData => {
                    return mstData.classCd === res.data.classCd;
                  });
                 if((mstClassValue && 1 != mstClassValue.classType)||res.data.classCd===-1){
                    this.displayInputValue.initValue = "【分類不一致】" + medicineName;
                    this.displayInputValue.editValue = "【分類不一致】" + medicineName;
                  }else{
                    this.displayInputValue.initValue = medicineName;
                    this.displayInputValue.editValue = medicineName;
                  }
                  //add 5323 患者経過総合ビューアで分類が問題ない場合でも「分類不一致」と表示されることがある。張 end
                  if (res && res.data && res.data.isDisp == '1' && res.data.isDel == '0') {
                    this.displayInputValue.initValue = this.displayInputValue.initValue;
                    this.displayInputValue.editValue = this.displayInputValue.initValue;
                  } else {
                    this.displayInputValue.initValue = MASTER_DELETE_DISPLAY.DELETED + this.displayInputValue.initValue;
                    this.displayInputValue.editValue = MASTER_DELETE_DISPLAY.DELETED + this.displayInputValue.initValue;
                  }
                  // mod FNSI-FutreNetWeb+SI課題管理No.4878 李 end
                  // this.displayInputValue.initValue = "削除済み "+medicineName;
                  // this.displayInputValue.editValue = "削除済み "+medicineName;
                  // del FNSI redmine 4877 4879 劉祥霖 start
                  // this.popoverData.popoverContentSelected.value = null;
                  // del FNSI redmine 4877 4879 劉祥霖 end
                  // this.displayInputValue.initValue = MASTER_DELETE_DISPLAY.DELETED+medicineName;
                  // this.displayInputValue.editValue = MASTER_DELETE_DISPLAY.DELETED+medicineName;
                }).catch(err => {
                    throw err;
                  });
                // mod 8374 2023-02-20 15:20 薬剤分類が抗凝固剤の調製薬剤で指示を発行しても分類不一致と表示される 張 end
            })
        }
      // FNSI-修正 マスタ削除の対応 wangchen add end
    }*/
    // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // this.checkMstDispStatus("medicineCd");
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    
      const rst = this.mstMedicine.find(
          item =>{
            item.value = item.key_cd
            item.type = item.key_type
            return item.medicineCd == this.value
      });
      const rstMix = this.mstMedicineMix.find(
          item =>{
            item.value = item.key_cd
            item.type = item.key_type
            return item.medicineMixCd == this.value
      });
      if(rst){
        this.popoverData.popoverContentSelected = rst
      } else if (rstMix) {
        this.popoverData.popoverContentSelected = rstMix
      }
    if(this.value){
      let prefix = '';
      let statusText = '';
      var text = '';
      let value = '';
      if(this.medicineType == 2){
        if (rstMix.key_type == 2 && rstMix.key_class == -1) {
          prefix = CLASS_MISMATCH_LABEL;
        }
        if (this.getSettingIndData || 
          this.getSettingIndData.orderMainData || 
          this.getSettingIndData.orderMainData.rstDialysisState == 0) {
          statusText = `${rstMix.expired}${rstMix.deleted}${rstMix.includeDeleted}`;
        }
        text = prefix + rstMix.tabooAllergy + statusText + rstMix.medicineMixName
        value = rstMix.key_cd
        this.mstExtraParams.rstInfo.rstUnit = rstMix.unit
        this.unit = rstMix.unit
      }else{
        if (rst.key_type == 2 && rst.key_class == -1) {
          prefix = CLASS_MISMATCH_LABEL;
        }
        if ( this.getSettingIndData || 
          this.getSettingIndData.orderMainData || 
          this.getSettingIndData.orderMainData.rstDialysisState == 0) {
          statusText = `${rst.expired}${rst.deleted}${rst.includeDeleted}`;
        }
        text = prefix + rst.tabooAllergy + statusText + rst.medicineName
        value = rst.key_cd
        this.mstExtraParams.rstInfo.rstUnit=rst.unit
        this.unit = rst.unit
      }
      this.displayInputValue.initValue = text
      this.displayInputValue.editValue = text
      this.displayInputValue.text = text
      this.displayInputValue.editCd = value
      this.displayInputValue.initCd = value
      this.mstExtraParams.treatDate = this.getIndStartDate||'';
      this.mstExtraParams.rstInfo.rstName = text||'';
    }
    
    // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  },

  methods: {
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    mstClick(item) {
      const val = item.data.lists.list3.items.filter(item => item.key_type == 1) || []
      return val
      
    },
    mstMixClick(item) {
      const val = item.data.lists.list3.items.filter(item => item.key_type == 2) || [];
      return val
    },
    masterUpdateInput(val){
      this.displayInputValue.editValue = val.text
      this.displayInputValue.text = val.text
      this.displayInputValue.editCd = val.value
      this.kbnValue = val.kbnValue
      this.unit = val.unit
      const data = {
        fnValue:{
          '薬剤分類': val.classCd,
          '薬剤区分': val.kbnValue
        },
        isDisp: val.isDisp,
        text: val.text,
        type: val.kbnValue,
        value: val.value
      }
      this.updateInputNew(data,'25')
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    ...mapMutations("pat-viewer-treat-cond", [
      "setAntiCoagulantDisabled",
      "setAntiCoagulant",
      "setAntiCoagulantDecPoint",
      "setAntiCoagulantUnit",
      "setAntiCoagulantFlowRateUnit",
      "setAntiCoagulantAmountTotalUnit",
      // add FNSI-【8630】単位が表示されない対応 曲 start
      "setAntiCoagulantUnitChangeFlag",
      "setAntiCoagulantFlowRateUnitChangeFlag",
      "setAntiCoagulantAmountTotalUnitChangeFlag"
      // add FNSI-【8630】単位が表示されない対応 曲 end
    ]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end

    async createPopoverData() {
      // 選択中薬剤のIDを取得
      let selectedMediCd = null;
      let selectedMediMixCd = null;
      if (this.isMedicineTypeMix) {
        selectedMediMixCd = this.value;
      } else {
        selectedMediCd = this.value;
      }
      let filterArr = [];
      let contentArr = [];
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let treatDate = null;
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      const item = {
        lists: [
          {
            id: "list1",
            name: "固定分类",
            sourceType: "FIXED",
            fixedItems: [
              { value: 0, text: "すべて" },
              { value: "1", text: "通常薬剤" },
              { value: "2", text: "調製薬剤" }
            ],
            keyMapping: [
              { keyName: "key_type", valueFrom: "value" }
            ]
          },
          {
            id: "list2",
            name: "药剂分类MST",
            sourceType: "MST",
            mstSource: {
              mstCode: "mstMedicineClassDaoImpl",
              sqlParams: { facilityCd: this.facilityCd }
            },
            keyMapping: [
              { keyName: "key_class", valueFrom: "classCd" }
            ]
          },
          {
            id: "list3",
            name: "通常药剂 + 调制药剂 合并",
            sourceType: "MST_COMBINED",
            mstSourceList: [
              {
                mstCode: "mstMedicineDaoImpl",
                sourceTag: "1",
                sqlParams: { facilityCd: this.facilityCd,patId:this.selectedPatId ? String(this.selectedPatId) : null },
                keyMapping: [
                  { keyName: "key_type", valueFrom: "sourceTag" },
                  { keyName: "key_class", valueFrom: "classCd" },
                  { keyName: "key_cd", valueFrom: "medicineCd" }
                ]
              },
              {
                mstCode: "mstMedicineMixDaoImpl",
                sourceTag: "2",
                sqlParams: { facilityCd: this.facilityCd,patId:this.selectedPatId ? String(this.selectedPatId) : null },
                keyMapping: [
                  { keyName: "key_type", valueFrom: "sourceTag" },
                  { keyName: "key_class", valueFrom: "classCd" },
                  { keyName: "key_cd", valueFrom: "medicineMixCd" }
                ]
              }
            ]
          }
        ]
      }
      /*const [medicineData, medicineMixData, classData] = await Promise.all([
        // マスタ系画面以外では患者のタブー・アレルギー情報込みで取得する
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? Mst.medicine(this.facilityCd) : Mst.medicineTabooAllergy(this.selectedPatId),
        //this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? this.getMstMedicineIncludeDeletedData : Mst.medicineAllergy(this.selectedPatId, true),
        //this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? this.getMstMedicineIncludeDeletedData : getMstListCompose(item),
        getMstListCompose(item),
        // this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? Mst.medicineMix(this.facilityCd) : Mst.medicineMixTabooAllergy(this.selectedPatId),
        //this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? this.getMstMedicineMixIncludeDeletedData : Mst.medicineMixAllergy(this.selectedPatId, true),
        //this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? this.getMstMedicineMixIncludeDeletedData : getMstListCompose(item),
        getMstListCompose(item),
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        medicineClass(this.facilityCd)
      ]).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndTreatCondAntiCoagulant.vue', 'createPopoverData', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });*/
      const res = await getMstListCompose(item).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndTreatCondAntiCoagulant.vue', 'createPopoverData', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      const medicineData = this.mstClick(res)
      const medicineMixData = this.mstMixClick(res)
      const classData = res.data.lists.list2.items || [];
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      // 患者経過総合ビューア(予定)表示時は、予定範囲と薬剤の使用期限を見て表示内容を補正する
      if (this.$router.currentRoute.name === PATVIEWER_CURRENT_ROUTE_NAME) {
        // 薬剤
        this.mstMedicine = medicineData.filter(medi => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return fitTermCheck(medi.useStartDate, medi.useEndDate, this.getIndStartDate) || medi.medicineCd == selectedMediCd; // mod #9973 value Number→文字列  shiyw
          return fitTermCheck(medi.useStartDate, medi.useEndDate, this.getIndStartDate) || (this.initValue != null && medi.medicineCd == this.initValue) || (this.initValue != null && medi.medicineMixCd == this.initValue);
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
        // 調製薬剤
        this.mstMedicineMix = medicineMixData.filter(medi => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, this.getIndStartDate) || medi.medicineMixCd == selectedMediMixCd; // mod #9973 value Number→文字列  shiyw
          return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, this.getIndStartDate) || (this.initValue != null && medi.medicineCd == this.initValue) || (this.initValue != null && medi.medicineMixCd == this.initValue);
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
        // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        treatDate = this.getIndStartDate;
        // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      } else {
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // this.mstMedicine = medicineData;
        // this.mstMedicineMix = medicineMixData;
        treatDate = moment().format("YYYYMMDD");
        // 薬剤
        this.mstMedicine = medicineData.filter(medi => {
          return fitTermCheck(medi.useStartDate, medi.useEndDate, treatDate) || (this.initValue != null && medi.medicineCd == this.initValue);
        });
        // 調製薬剤
        this.mstMedicineMix = medicineMixData.filter(medi => {
          return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, treatDate) || (this.initValue != null && medi.medicineMixCd == this.initValue);
        }); 
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      }
      this.filterDataset = classData;

      // ポップオーバのフィルタデータを取りまとめる
      const filterParam = item => {
        return item.classType === 1;
      };
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd
        };
      };

      filterArr = this.filterDataset.filter(filterParam).map(filterMapping);
      filterArr.unshift({ text: "すべて", value: 0 });

      // ポップオーバのコンテンツデータ(フィルタデーしたデータ)を取りまとめる
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // const contentParam = item => {
      const contentParam = (item, cd) => {
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end  
        return filterArr.find(i => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return item.classCd === i.value;
          return item.classCd === i.value || (this.initValue != null && item[cd] == this.initValue);
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
      };
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // const contentParamIsDisp = item => {
      const contentParamIsDisp = (item, cd) => {
        // return item.isDisp === "1";
        return item.isDisp === "1" || (this.initValue != null && item[cd] == this.initValue);
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      };
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let rstName = "";
      if (
        this.$router.currentRoute.name === PATVIEWER_CURRENT_ROUTE_NAME &&
        this.getSettingIndData && 
        this.getSettingIndData.orderMainData && 
        this.getSettingIndData.orderMainData.rstDialysisState != 0
      ) {
        const rstCondInfo = this.getSettingIndData.orderMainData.indCondInfo;
        const rstCondInfoObj = rstCondInfo ? JSON.parse(rstCondInfo) : [];
        rstName = rstCondInfoObj[this.treatItemCd]?.value_name_1;
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      /* modify by chamaojia 2024-02-28 [10196] The deleted data needs to be displayed in the drop-down list --start */
      const contentMapping = (item, cdKey, nameKey, category, delFlag) => {
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        let prefix = '';
        let statusText = '';

        if (item.key_type == 2 && item.key_class == -1) {
          prefix = CLASS_MISMATCH_LABEL;
        }

        if (this.getSettingIndData || 
          this.getSettingIndData.orderMainData ||
          this.getSettingIndData.orderMainData.rstDialysisState == 0) {
          statusText = `${item.expired}${item.deleted}${item.includeDeleted}`;
        }
        return {
          //value: category === "1" ? item[cdKey] : `${item[cdKey]}$`,
          value: category === "1" ? item[cdKey] : `${item[cdKey]}`,
          type: category,
          fnValue: {
            薬剤区分: category,
            薬剤分類: item.classCd
          },
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: delFlag ? MASTER_DELETE_DISPLAY.DELETED + item[nameKey] : item[nameKey]
          /*text: rstName && item[cdKey] == this.initValue ? rstName : getPrefix({ 
            treatDate: treatDate,
            normalClassType: CODES.MEDICINE_CLASS.ANTI_COAGULANT.classType,
            ...item 
          }) + item[nameKey],*/
          text: prefix + item.tabooAllergy + statusText + item[nameKey],
          isDisp: item.isDisp,
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
        };
      };

      this.contentDataset = [...this.mstMedicine, this.mstMedicineMix];

      const contentMedicine = this.mstMedicine
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // .filter(contentParam)
        // .filter(contentParamIsDisp)
        .filter(item => contentParam(item, "medicineCd"))
        .filter(item => contentParamIsDisp(item, "medicineCd"))
        .map(item => contentMapping(item, "medicineCd", "medicineName", "1", false));
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      const contentMedicineMix = this.mstMedicineMix
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // .filter(contentParam)
        // .filter(contentParamIsDisp)
        .filter(item => contentParam(item, "medicineMixCd"))
        .filter(item => contentParamIsDisp(item, "medicineMixCd"))
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        .map(item =>
          contentMapping(item, "medicineMixCd", "medicineMixName", "2", false)
        );
      if (this.deletedMedicine.cd == null) {
        this.deletedMedicine.cd = this.value;
        this.deletedMedicine.isMedicineTypeMix = this.isMedicineTypeMix;
      }

      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // let currentMedicineOrMedicineMix = [];
      // if (this.deletedMedicine.cd) {
      //   if (this.deletedMedicine.isMedicineTypeMix) {
      //     const medicineMixByCd = await medicineMixTabooAllergyByCd(this.selectedPatId==null?-1:this.selectedPatId, this.deletedMedicine.cd);
      //     if (medicineMixByCd) {
      //       currentMedicineOrMedicineMix = medicineMixByCd
      //           .filter(item => {return item.medicineCd == this.deletedMedicine.cd && item.isDisp == "0"});
      //       if (currentMedicineOrMedicineMix != null && currentMedicineOrMedicineMix.length > 0) {
      //         this.mstMedicineMix.push(currentMedicineOrMedicineMix[0])
      //         currentMedicineOrMedicineMix = currentMedicineOrMedicineMix
      //             .map(item =>
      //                 contentMapping(item, "medicineMixCd", "medicineMixName", "2", true)
      //             );
      //       }
      //     }
      //   } else {
      //     const medicineByCd = await medicineTabooAllergyByCd(this.selectedPatId==null?-1:this.selectedPatId, this.deletedMedicine.cd);
      //     if (medicineByCd) {
      //       currentMedicineOrMedicineMix = medicineByCd
      //           .filter(item => {return item.medicineCd == this.deletedMedicine.cd && item.isDisp == "0"});
      //       if (currentMedicineOrMedicineMix != null && currentMedicineOrMedicineMix.length > 0) {
      //         this.mstMedicine.push(currentMedicineOrMedicineMix[0])
      //         currentMedicineOrMedicineMix = currentMedicineOrMedicineMix.map(item =>
      //             contentMapping(item, "medicineCd", "medicineName", "1", true)
      //         );
      //       }
      //     }
      //   } 
      // }
      // contentArr = [...contentMedicine, ...contentMedicineMix, ...currentMedicineOrMedicineMix];
      contentArr = [...contentMedicine, ...contentMedicineMix];
      contentArr = contentArr.sort(function (a, b) {
        return b.isDisp - a.isDisp;
      });
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      /* modify by chamaojia 2024-02-28 [10196] The deleted data needs to be displayed in the drop-down list --end */

      this.popoverData.popoverTitleHeader = "薬剤";
      this.popoverData.popoverFilter = [
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
      this.popoverData.popoverContentLabel = "薬剤名";
      this.popoverData.popoverContentDataset = contentArr;
    }
  }
};
</script>
