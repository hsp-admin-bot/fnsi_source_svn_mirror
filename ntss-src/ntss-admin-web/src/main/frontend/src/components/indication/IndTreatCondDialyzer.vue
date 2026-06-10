/** * 治療条件ーダイアライザ */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagDialyzer ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">ダイアライザ</v-ons-col>
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
      <!--   :disabled="getIsUseFlagDialyzer" -->
      <!--   @click=" -->
      <!--     createPopoverData(); -->
      <!--     showPopover(); -->
      <!--     changeButton(); -->
      <!--   " -->
      <!-- > -->
      <v-ons-button
        ref="popoverButton"
        class="common-style-select-button"
        :disabled="getIsUseFlagDialyzer || !getItemAuthorized('Indication', 'default_authority')"
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
      @popover-return="updateInputNew($event,'5')"
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
import { dialyzerIncludeDeleted, dialyzerTabooAllergyDeleted } from "@/functions/mst/MstGetters.js";
import { mapGetters } from "vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { MASTER_MAINTENANCE_CURRENT_ROUTE_NAME } from "@/constants/masterMaintenanceConstants";
import { PATVIEWER_CURRENT_ROUTE_NAME } from "@/constants/PatViewerConstants";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import _ from "underscore";
import { ApiHelper } from "@/apis/AxiosHelper";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
//add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
import moment from "moment";
//add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
import {EventBus} from "@/eventBus";

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
    ...mapGetters("pat-viewer-treat-cond", {
      deviceMode: "getDeviceMode",
      // add 8204 周安寧 start
      getIsUseFlagDialyzer: "getIsUseFlagDialyzer"
      // add 8204 周安寧 end
    }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"])
  },

  async mounted() {
    this.localSelectedCd = this.value;
    this.treatItemCd = "5";

    await this.createPopoverData();
    const selectedMst = this.popoverData.popoverContentDataset.find(item => {
      //mod FNSI-5639 劉全航 start
      //return item.value === this.value;
      return item.value == this.velue; // mod #9973 value Number→文字列  shiyw
      //mod FNSI-5639 劉全航 end
    });
    //mod FNSI-5639 劉全航 start
    let editItem = this.popoverData.popoverContentDataset.find(item => {
      return item.value == this.value; // mod #9973 value Number→文字列  shiyw
    });
    //mod FNSI-5639 劉全航 end
    //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou start
    //if (selectedMst) {
    if (selectedMst || editItem) {

      //add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
      // var item = this.contentDataset.find(o=>o.dialyzerCd === this.value);
      // let useEndDate = moment(item.useEndDate);
      // let indStartDate = moment(this.getIndStartDate);
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // var item = this.contentDataset.find(o=>o.dialyzerCd == this.velue); // mod #9973 value Number→文字列  shiyw
      // let useEndDate = null;
      // let indStartDate = null;
      // if (item) {
      //   useEndDate = moment(item.useEndDate);
      //   indStartDate = moment(this.getIndStartDate);
      // }
      
      //if(useEndDate.isBefore(indStartDate)){
      // if(useEndDate !=null && useEndDate.isBefore(indStartDate)){
      //   // this.displayInputValue.initValue = "【期限切れ】"+selectedMst.text;
      //   // //mod FNSI-5639 劉全航 start
      //   // //this.displayInputValue.editValue = "【期限切れ】"+selectedMst.text;
      //   // this.displayInputValue.editValue = "【期限切れ】"+editItem.text;
      //   //mod FNSI-5639 劉全航 end
      //   this.displayInputValue.initValue = editItem ? "【期限切れ】"+editItem.text: '';
      //   this.displayInputValue.editValue = this.isIndication ? (selectedMst ? "【期限切れ】"+selectedMst.text: '') : this.displayInputValue.initValue;
      // }else{
      //   // this.displayInputValue.initValue = selectedMst.text;
      //   // //mod FNSI-5639 劉全航 start
      //   // //this.displayInputValue.editValue = selectedMst.text;
      //   // this.displayInputValue.editValue = editItem.text;
      //   //mod FNSI-5639 劉全航 end
      //   this.displayInputValue.initValue = editItem ? editItem.text : '';
      //   this.displayInputValue.editValue = this.isIndication ? (selectedMst ? selectedMst.text : '') : this.displayInputValue.initValue;
      // }
      this.displayInputValue.initValue = editItem ? editItem.text : '';
      this.displayInputValue.editValue = this.isIndication ? (selectedMst ? selectedMst.text : '') : this.displayInputValue.initValue;
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // this.displayInputValue.initValue = selectedMst.text;
      // this.displayInputValue.editValue = selectedMst.text;
      //add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
      // this.popoverData.popoverContentSelected = selectedMst;
      this.popoverData.popoverContentSelected = selectedMst ? selectedMst : editItem;
      //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod zhou end
    }else{
        // FNSI-修正 マスタ削除の対応 wangchen add start
        if(this.value){
            ApiHelper.get("/mstInfo/mstDialyzer/getByCd", {dialyzerCd:this.value}).then((res) => {
              //mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
                // this.displayInputValue.initValue = "削除済み "+res.data.modelNumber;
                // this.displayInputValue.editValue = "削除済み "+res.data.modelNumber;
                // mod #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
                if (res.data.isDisp === '1' && res.data.isDel === '0') {
                  this.displayInputValue.initValue = res.data.modelNumber;
                  this.displayInputValue.editValue = res.data.modelNumber;
                } else {
                  // mod 治療法セシャトマスタ画面では「undefined」が表示されています linjunfeng start
                  this.displayInputValue.initValue = res.data.modelNumber ? MASTER_DELETE_DISPLAY.DELETED + res.data.modelNumber : '';
                  this.displayInputValue.editValue = res.data.modelNumber ? MASTER_DELETE_DISPLAY.DELETED + res.data.modelNumber : '';
                  // mod 治療法セシャトマスタ画面では「undefined」が表示されています linjunfeng end
                }
                // this.displayInputValue.initValue = MASTER_DELETE_DISPLAY.DELETED+res.data.modelNumber;
                // this.displayInputValue.editValue = MASTER_DELETE_DISPLAY.DELETED+res.data.modelNumber;
                // mod #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
                //mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
            })
        }
        // FNSI-修正 マスタ削除の対応 wangchen add end
    }
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // this.checkMstDispStatus("dialyzerCd");
    // del #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
  },

  watch: {
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
    async createPopoverData() {
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // const dataSet = this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? await dialyzer(this.facilityCd) : await dialyzerTabooAllergy(this.selectedPatId);
      const dataSet = this.$router.currentRoute.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? await dialyzerIncludeDeleted(this.facilityCd) : await dialyzerTabooAllergyDeleted(this.selectedPatId);
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // 患者経過総合ビューア(予定)表示時は、予定範囲と薬剤の使用期限を見て表示内容を補正する
      //#8484　医療材料選択IFのリスト不正 追加修正　Start
      var conds = [ PATVIEWER_CURRENT_ROUTE_NAME , MASTER_MAINTENANCE_CURRENT_ROUTE_NAME];
      if (conds.includes(this.$router.currentRoute.name)) {
        //#8484　医療材料選択IFのリスト不正 追加修正　End
        this.contentDataset = dataSet.filter(dialyzer => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return fitTermCheck(dialyzer.useStartDate, dialyzer.useEndDate, this.getIndStartDate) || dialyzer.dialyzerCd === this.localSelectedCd;
          return fitTermCheck(dialyzer.useStartDate, dialyzer.useEndDate, this.getIndStartDate) || dialyzer.dialyzerCd == this.localSelectedCd;
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
      } else {
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // this.contentDataset = dataSet;
        const today = moment().format("YYYYMMDD");
        this.contentDataset = dataSet.filter(dialyzer => {
          return fitTermCheck(dialyzer.useStartDate, dialyzer.useEndDate, today) || dialyzer.dialyzerCd == this.localSelectedCd;
        });
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      }
      // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 start
      // 積層型ダイアライザが選択されていた場合は未登録に強制変更、積層型ダイアライザーを候補から外す。
      if (this.isMst && 10 === this.deviceMode) { //I-HDF
        this.contentDataset = this.contentDataset.filter(dialyzer => {
          return dialyzer.dialyzerType !== "1"
        })
      }
      // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 end
      const [tempArr, tempArr2, tempArr3] = [
        // メーカー
        this.contentDataset.map(function(item) {
          if (item.maker === null) {
            return { text: "なし", value: item.maker };
          }
          return { text: item.maker, value: item.maker };
        }),
        // ダイアライザ種別
        [{ text: "すべて", value: 'all' },
         { text: "中空糸", value: "0" },
         { text: "積層", value: "1" }]
        ,
        // 機能分類
        this.contentDataset.map(function(item) {
          if (item.functionClass === null) {
            return { text: "未分類", value: item.functionClass };
          }
          return { text: item.functionClass, value: item.functionClass };
        })]

      // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 start
      // 積層型ダイアライザが選択されていた場合は未登録に強制変更、積層型ダイアライザーを候補から外す。
      if (this.isMst && 10 === this.deviceMode) { //I-HDF
        const index = tempArr2.findIndex(item => item.value === "1")
        if (index !== -1) {
          tempArr2.splice(index, 1);
        }
      }
      // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 end

      // ポップオーバのフィルタデータを取りまとめる
      const filterArr = _.uniq(tempArr, "value");
      const filterArr2 = _.uniq(tempArr2, "value");
      const filterArr3 = _.uniq(tempArr3, "value");

      filterArr.sort(this.sortPopoverValue);
      filterArr.unshift({ text: "すべて", value: 0 });
      filterArr3.sort(this.sortPopoverValue);
      filterArr3.unshift({ text: "すべて", value: 0 });

      // ポップオーバのコンテンツデータ(フィルタデーしたデータ)を取りまとめる
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
      const contentArr = this.contentDataset
        .filter(item => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return item.isDisp === "1";
          return item.isDisp === "1" || item.dialyzerCd == this.localSelectedCd;
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        })
        .map(item => {
          return {
            value: item.dialyzerCd,
            fnValue: {
              メーカー: item.maker,
              ダイアライザ種別: item.dialyzerType,
              機能分類: item.functionClass
            },
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // text: item.modelNumber
            text: rstName && item.dialyzerCd == this.localSelectedCd ? rstName : getPrefix({treatDate: this.getIndStartDate , ...item}) + item.modelNumber,
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          };
        });

      this.popoverData.popoverTitleHeader = "ダイアライザ";
      this.popoverData.popoverFilter = [
        {
          popoverFilterLabel: "メーカー",
          popoverFilterDataset: filterArr
        },
        {
          popoverFilterLabel: "ダイアライザ種別",
          popoverFilterDataset: filterArr2
        },
        {
          popoverFilterLabel: "機能分類",
          popoverFilterDataset: filterArr3
        }
      ];
      this.popoverData.popoverContentLabel = "ダイアライザ名";
      this.popoverData.popoverContentDataset = contentArr;
    },
    sortPopoverValue(a,b) {
        let r = 0;
        if( a.value < b.value ){ r = -1; }
        else if( a.value > b.value ){ r = 1; }
        return r;
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    }
  }
};
</script>
