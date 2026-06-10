/** * 治療条件ーVA */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagVA ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">VA</v-ons-col>
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
      <!--   :disabled="getIsUseFlagVA" -->
      <!--   @click=" -->
      <!--     createPopoverData(); -->
      <!--     showPopover(); -->
      <!--     changeButton(); -->
      <!--   " -->
      <!-- > -->
      <v-ons-button
        ref="popoverButton"
        class="common-style-select-button"
        :disabled="getIsUseFlagVA || !getItemAuthorized('Indication', 'default_authority')"
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
    <pop-over
      v-bind="popoverData"
      :treat-item-cd="treatItemCd"
      :target-position-element="$refs.popoverButton"
      @popover-close="closePopover"
      @popover-return="updateInputNew($event,'2')"
    />
    <!-- mod 8681 ljx end -->
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// add 8204 周安寧 start
import { mapGetters } from "vuex";
// add 8204 周安寧 end
import { va } from "@/functions/mst/MstGetters.js";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { ApiHelper } from "@/apis/AxiosHelper";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
import {EventBus} from "@/eventBus";

export default {
  mixins: [IndTreatCondBase],
   // add 8204 周安寧 start
   computed: {
    ...mapGetters("pat-viewer-treat-cond", {getIsUseFlagVA: "getIsUseFlagVA"})
  },
  // add 8204 周安寧 end
  data() {
    return {
      displayInputValue: {
        initValue: null,
        editValue: null
      },
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      initValue: this.value
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    };
  },

  async mounted() {
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
    const selectedEditMst = this.popoverData.popoverContentDataset.find(item => {
      return item.value == this.velue; // mod #9973 value Number→文字列  shiyw
    });
    if (selectedMst || selectedEditMst) {
      this.displayInputValue.initValue = selectedMst ? selectedMst.text : '';
      this.displayInputValue.editValue = this.isIndication ? (selectedEditMst ? selectedEditMst.text : '') : this.displayInputValue.initValue;
      this.popoverData.popoverContentSelected = selectedEditMst ? selectedEditMst : selectedMst;
    // 8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
    }else{
        // FNSI-修正 マスタ削除の対応 wangchen add start
        if(this.value){
            ApiHelper.get("/mstInfo/mstVa/getVaName", {vaCd:this.value}).then((res) => {
              //mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
                // this.displayInputValue.initValue = "削除済み "+res.data;
                // this.displayInputValue.editValue = "削除済み "+res.data;
                this.displayInputValue.initValue = MASTER_DELETE_DISPLAY.DELETED+res.data;
                this.displayInputValue.editValue = MASTER_DELETE_DISPLAY.DELETED+res.data;
                //mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
            })
        }
        // FNSI-修正 マスタ削除の対応 wangchen add end
    }
    this.checkMstDispStatus("vaCd");
  },

  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    async createPopoverData() {
      this.contentDataset = await va(this.facilityCd);

      // ポップオーバのフィルタデータを取りまとめる
      const filterArr = [
        { text: "すべて", value: 'all' },
        { text: "両方", value: "0" },
        { text: "左", value: "1" },
        { text: "右", value: "2" },
        { text: "なし", value: "3" },
        { text: "不明", value: "-" }
      ];

      // ポップオーバのコンテンツデータ(フィルタしたデータ)を取りまとめる
      const contentArr = this.contentDataset
        .filter(item => {
          return item.isDisp === "1";
        })
        .map(item => {
          return {
            value: item.vaCd,
            fnValue: {
              VA方向: item.vaDirect
            },
            text: item.vaName
          };
        });
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      const delInfo = contentArr.find(item => item.value == this.initValue);
      if(!delInfo && this.initValue) {
        const delName = await ApiHelper.get("/mstInfo/mstVa/getVaName", {vaCd: this.initValue});
        contentArr.push({
          value: this.initValue,
            fnValue: {
              VA方向: "all"
            },
            text: MASTER_DELETE_DISPLAY.DELETED + delName.data
        });
      } 
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      this.popoverData.popoverTitleHeader = "VA";
      this.popoverData.popoverFilter = [
        {
          popoverFilterLabel: "VA方向",
          popoverFilterDataset: filterArr
        }
      ];
      this.popoverData.popoverContentLabel = "VA名";
      this.popoverData.popoverContentDataset = contentArr;
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    }
  }
};
</script>
