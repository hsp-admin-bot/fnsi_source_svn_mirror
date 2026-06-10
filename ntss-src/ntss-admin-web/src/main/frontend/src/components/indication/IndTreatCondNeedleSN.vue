/** * 治療条件ー穿刺針SN */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row v-if="isSingleNeedle"> -->
    <v-ons-row v-if="isSingleNeedle" :class="getIsUseFlagNeedleSelection ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">穿刺針(SN)</v-ons-col>
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
      <!--   :disabled="getIsUseFlagNeedleNeedleSN" -->
      <!--   @click=" -->
      <!--     createPopoverData(); -->
      <!--     showPopover(); -->
      <!--     changeButton(); -->
      <!--   " -->
      <!-- > -->
      <!-- mod #10150 piao start -->
      <v-ons-button
        ref="popoverButton"
        class="common-style-select-button"
        :disabled="getIsUseFlagNeedleSelection || !getItemAuthorized('Indication', 'default_authority')"
        @click="
        createPopoverData();
        showPopover();
        changeButton();
      "
      >
        <!-- mod #10150 piao end -->
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
      :target-position-element="$refs.popoverButton"
      @popover-close="closePopover"
      @popover-return="updateInputNew($event,'11')"
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
import { mapGetters } from "vuex";
import { equipmentAllergy, equipmentClass, equipmentIncludeDeleted } from "@/functions/mst/MstGetters.js";
import { MASTER_MAINTENANCE_CURRENT_ROUTE_NAME } from "@/constants/masterMaintenanceConstants";
import { PATVIEWER_CURRENT_ROUTE_NAME } from "@/constants/PatViewerConstants";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { ApiHelper } from "@/apis/AxiosHelper";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
import {EventBus} from "@/eventBus";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
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
    ...mapGetters("pat-viewer-treat-cond", {
      isSingleNeedle: "getIsSingleNeedle"
    }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    // add 8204 周安寧 start
    ...mapGetters("pat-viewer-treat-cond", {
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
      getIsUseFlagNeedleNeedleSN: "getIsUseFlagNeedleNeedleSN",
      // add 8204 周安寧 end
      //  add 9664補液及び透析液仕様修正します yangqingzhe start
      getIsUseFlagNeedleSelection: "getIsUseFlagNeedleSelection"
    })
    //  add 9664補液及び透析液仕様修正します yangqingzhe end
    // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
  },

  async mounted() {
    this.localSelectedCd = this.value;
    this.treatItemCd = "11";
    this.popoverData.needleType = 3;

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
      return item.value == this.velue; // mod #9973 value Number→文字列  shiyw
    });
    if (selectedMst || selectedEditMst) {
      this.displayInputValue.initValue = selectedMst ? selectedMst.text : '';
      this.displayInputValue.editValue = this.isIndication ? (selectedEditMst ? selectedEditMst.text : '') : this.displayInputValue.initValue;
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
      return getAuthorized(pageCd, itemCd);
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
        return item.classType === 3;
      };

      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd,
          needle: item.classType === 3 && item.classType
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
          // text: item.equipmentName
          text: rstName && item.equipmentCd == this.localSelectedCd ? rstName : getPrefix({
            treatDate: this.getIndStartDate,
            normalClassType: CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE_SN.classType,
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
