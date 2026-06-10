/** * 治療条件ー吸着カラム */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagColumn ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">吸着カラム</v-ons-col>
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
      <!--   :disabled="getIsUseFlagColumn" -->
      <!--   @click=" -->
      <!--     createPopoverData(); -->
      <!--     showPopover(); -->
      <!--     changeButton(); -->
      <!--   " -->
      <!-- > -->
      <v-ons-button
        ref="popoverButton"
        class="common-style-select-button"
        :disabled="getIsUseFlagColumn || !getItemAuthorized('Indication', 'default_authority')"
        @click="
        createPopoverData();
        showPopover();
        changeButton();"
      >
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- mod 8204 周安寧 end -->
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
    <!-- #10171:医療材料ポップアップ表示位置不正(再修正)　Start
    :treat-item-cd="treatItemCd"
     #10171:医療材料ポップアップ表示位置不正(再修正)　End  -->
    <pop-over
      v-bind="popoverData"
      :target-position-element="$refs.popoverButton"
      @popover-close="closePopover"
      @popover-return="updateInputNew($event,'6')"
    />
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
import { equipmentAllergy, equipmentClass, equipmentIncludeDeleted } from "@/functions/mst/MstGetters.js";
import { mapGetters } from "vuex";
import { MASTER_MAINTENANCE_CURRENT_ROUTE_NAME } from "@/constants/masterMaintenanceConstants";
import { PATVIEWER_CURRENT_ROUTE_NAME } from "@/constants/PatViewerConstants";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { ApiHelper } from "@/apis/AxiosHelper";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
import {EventBus} from "@/eventBus";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { CODES } from "@/constants/TreatmentRecord";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
export default {
  mixins: [IndTreatCondBase],

  data() {
    return {
      displayInputValue: {
        initValue: null,
        editValue: null
      },
      // 画面を開いた時に選択状態になっている対象のコードを保持
      localSelectedCd: null
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    // add 8204 周安寧 start
    ...mapGetters("pat-viewer-treat-cond", {getIsUseFlagColumn: "getIsUseFlagColumn"})
    // add 8204 周安寧 end
  },

  async mounted() {
    this.localSelectedCd = this.value;
    this.treatItemCd = "6";

    await this.createPopoverData();
    const selectedMst = this.popoverData.popoverContentDataset.find(item => {
      return item.value == this.value; // mod #9973 value Number→文字列  shiyw
    });
    //mod FNSI-5639 劉全航 start
    const initItem = this.popoverData.popoverContentDataset.find(item => {
      return item.value == this.velue; // mod #9973 value Number→文字列  shiyw
    });
    //mod FNSI-5639 劉全航 end
    //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou start
    //if (selectedMst) {
    if (selectedMst || initItem) {
    //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou end
      //add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
      //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou start
      //var item = this.contentDataset.find(o=>o.equipmentCd === this.value);
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // var item = this.contentDataset.find(o=>o.equipmentCd == this.velue); // mod #9973 value Number→文字列  shiyw
      //let useEndDate = moment(item.useEndDate);
      //let indStartDate = moment(this.getIndStartDate);
      // let useEndDate = null ;
      // let indStartDate = null ;
      // if (item) {
      //   useEndDate = moment(item.useEndDate);
      //   indStartDate = moment(this.getIndStartDate);
      // }
      //if(useEndDate.isBefore(indStartDate)){
      // if(useEndDate != null && useEndDate.isBefore(indStartDate)){

      //   //mod FNSI-5639 劉全航 start
      //   //this.displayInputValue.initValue = "【期限切れ】"+selectedMst.text;
      //   // this.displayInputValue.initValue = "【期限切れ】"+initItem.text;
      //   // //mod FNSI-5639 劉全航 end
      //   // this.displayInputValue.editValue = "【期限切れ】"+selectedMst.text;
      //   this.displayInputValue.initValue = selectedMst ? "【期限切れ】"+selectedMst.text : "";
      //   //mod FNSI-5639 劉全航 end
      //   this.displayInputValue.editValue = this.isIndication ? (initItem ? "【期限切れ】"+initItem.text : "") : this.displayInputValue.initValue;
      //  //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou end
      // }else{
      //   //mod FNSI-5639 劉全航 start
      //   //this.displayInputValue.initValue = selectedMst.text;
      //   //mod 8196 周安寧　start
      //   //this.displayInputValue.initValue = initItem.text;
      //   //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou start
      //   //if (initItem === undefined) {
      //     //this.displayInputValue.initValue = selectedMst.text;
      //     this.displayInputValue.initValue = selectedMst ? selectedMst.text : "";
      //   // } else {
      //   //   this.displayInputValue.initValue = initItem.text;
      //   // }
      //   //mod 8196 周安寧　end
      //   //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou end
      //   //mod FNSI-5639 劉全航 end
      //   //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou start
      //   //this.displayInputValue.editValue = selectedMst.text;
      //   this.displayInputValue.editValue =  this.isIndication ? (initItem ? initItem.text : '') : this.displayInputValue.initValue;
      //   //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou end
      // }
      this.displayInputValue.initValue = selectedMst ? selectedMst.text : "";
      this.displayInputValue.editValue =  this.isIndication ? (initItem ? initItem.text : '') : this.displayInputValue.initValue;
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // this.displayInputValue.initValue = selectedMst.text;
      // this.displayInputValue.editValue = selectedMst.text;
      //add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
      //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou start
      //this.popoverData.popoverContentSelected = selectedMst;
      this.popoverData.popoverContentSelected = initItem ? initItem : selectedMst ;
      //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou end
    }else{
        // FNSI-修正 マスタ削除の対応 wangchen add start
        if(this.value){
            ApiHelper.get("/mstInfo/mstEquipment/getByCd", {equipmentCd:this.value}).then((res) => {
              //add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
              let classType = null;
              ApiHelper.get("/mstInfo/getMstEquipmentTypeByClass",{classCd:res.data.classCd}).then((response) => {
                classType = response.data.classType;
              });
              //add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
              // mod FNSI-FutreNetWeb+SI課題管理No.4878 李 start
              if (res && res.data && res.data.isDisp == '1' && res.data.isDel == '0') {
                //add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
                if(classType !== 4){
                  this.displayInputValue.initValue = "【分類不一致】" + res.data.equipmentName;
                  this.displayInputValue.editValue = "【分類不一致】" + res.data.equipmentName;
                }else{
                  this.displayInputValue.initValue = res.data.medicineName;
                  this.displayInputValue.editValue = res.data.medicineName;
                }
                // this.displayInputValue.initValue = res.data.equipmentName;
                // this.displayInputValue.editValue = res.data.equipmentName;
                //add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
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
              // this.popoverData.popoverContentSelected = null;
              // del FNSI redmine 4877 4879 劉祥霖 end
            })
        }
        // FNSI-修正 マスタ削除の対応 wangchen add end
    }
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // this.checkMstDispStatus("equipmentCd");
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
  },

  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    async createPopoverData() {
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // const dataSet = this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? await equipment(this.facilityCd) : await equipmentTabooAllergy(this.selectedPatId);
      const dataSet = this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? await equipmentIncludeDeleted(this.facilityCd) : await equipmentAllergy(this.selectedPatId, true);
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // 患者経過総合ビューア(予定)表示時は、予定範囲と薬剤の使用期限を見て表示内容を補正する
      //#8484　医療材料選択IFのリスト不正 追加修正　Start
      var conds = [ PATVIEWER_CURRENT_ROUTE_NAME , MASTER_MAINTENANCE_CURRENT_ROUTE_NAME];
      if (conds.includes(this.$router.currentRoute.name)) {
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
        return item.classType === 4;
      };
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd
        };
      };

      let filterArr = this.filterDataset
        .filter(filterParam)
        .map(filterMapping);
      filterArr.unshift({ text: "すべて", value: 0 });

      // ポップオーバのコンテンツデータ(フィルタデーしたデータ)を取りまとめる
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
      const contentMapping = item => {
        return {
          value: item.equipmentCd,
          fnValue: {
            医療材料分類: item.classCd
          },
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: item.equipmentName,
          text: rstName && item.equipmentCd == this.localSelectedCd ? rstName : getPrefix({
            normalClassType: CODES.EQUIPMENT_CLASS.ADSORPTION_COLUMN.classType,
            treatDate: this.getIndStartDate,
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
