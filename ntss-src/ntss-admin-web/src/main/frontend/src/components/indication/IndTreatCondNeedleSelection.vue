/** * 治療条件ーA */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row class="action-condition-target-weight"> -->
    <v-ons-row class="action-condition-target-weight" :class="getIsUseFlagNeedleSelection ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">
      シングルニードル
    </v-ons-col>
<!--    mod 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 start-->
    <!--<v-ons-col class="action-condition-data-column">
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondNeedleSelectionRadio'"
        :radio-value="1"
        @change="setIsSingleNeedle(isSingleNeedleUse)"
      >使用する
      </custom-radio>
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondNeedleSelectionRadio'"
        :radio-value="0"
        @change="setIsSingleNeedle(isSingleNeedleUse)"
      >使用しない
      </custom-radio>
    </v-ons-col>-->
    <v-ons-col class="action-condition-data-column">
      <!-- mod 8204 周安寧 start -->
      <!-- <custom-radio
        :value="displayInputValue"
        :name="'treatCondNeedleSelectionRadio'"
        :radio-value="1"
        @change="setIsSingleNeedle(isSingleNeedleUse),changeButton()"
        :disabled="getMstSingleNeedleDisable()"
      >使用する
      </custom-radio>
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondNeedleSelectionRadio'"
        :radio-value="0"
        @change="setIsSingleNeedle(isSingleNeedleUse),changeButton()"
        :disabled="getMstSingleNeedleDisable()"
      >使用しない
      </custom-radio> -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <custom-radio
        :value="displayInputValue"
        :name="'treatCondNeedleSelectionRadio'"
        :radio-value="1"
        @change="setIsSingleNeedle(isSingleNeedleUse),changeButton()"
        :disabled="getMstSingleNeedleDisable() || getIsUseFlagNeedleSelection"
      >使用する -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondNeedleSelectionRadio'" -->
      <!--   :radio-value="1" -->
      <!--   @change="setIsSingleNeedle(isSingleNeedleUse)" -->
      <!--   :disabled="getMstSingleNeedleDisable() || getIsUseFlagNeedleSelection" -->
      <!-- >使用する -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondNeedleSelectionRadio'"
        :radio-value="1"
        @change="setIsSingleNeedle(isSingleNeedleUse)"
        :disabled="getMstSingleNeedleDisable() || getIsUseFlagNeedleSelection || !getItemAuthorized('Indication', 'default_authority')"
      >使用する
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      </custom-radio>
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <custom-radio
        :value="displayInputValue"
        :name="'treatCondNeedleSelectionRadio'"
        :radio-value="0"
        @change="setIsSingleNeedle(isSingleNeedleUse),changeButton()"
        :disabled="getMstSingleNeedleDisable() || getIsUseFlagNeedleSelection"
      >使用しない -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondNeedleSelectionRadio'" -->
      <!--   :radio-value="0" -->
      <!--   @change="setIsSingleNeedle(isSingleNeedleUse)" -->
      <!--   :disabled="getMstSingleNeedleDisable() || getIsUseFlagNeedleSelection" -->
      <!-- >使用しない -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondNeedleSelectionRadio'"
        :radio-value="0"
        @change="setIsSingleNeedle(isSingleNeedleUse)"
        :disabled="getMstSingleNeedleDisable() || getIsUseFlagNeedleSelection || !getItemAuthorized('Indication', 'default_authority')"
      >使用しない
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      </custom-radio>
      <!-- mod 8204 周安寧 end -->
    </v-ons-col>
<!--    mod 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 end-->
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import {mapGetters, mapMutations} from "vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/eventBus";
export default {
  mixins: [IndTreatCondBase],

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      deviceMode: "getDeviceMode",
    // add 8204 周安寧 start
    getIsUseFlagNeedleSelection: "getIsUseFlagNeedleSelection"
    // add 8204 周安寧 end
    }),
    /**
     * @description SN使用フラグ
     * @returns {Boolean} 使用する: true, 使用しない: false
     */
    isSingleNeedleUse() {
      return this.displayInputValue.editValue == '1'; // mod #9973 value Number→文字列  shiyw
    }
  },
  //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
  created(){
    if (this.isIndication) {
      this.displayInputValue.editValue = this.velue === null ? null : this.velue == '0' ? 0 : 1 // mod #9973 value Number→文字列  shiyw
      this.displayInputValue.initValue = this.value === null ? null : this.value == '0' ? 0 : 1  // mod #9973 value Number→文字列  shiyw
    }
  },
  //8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
  mounted() {
    this.treatItemCd = "12";
    // 初期表示時にストアのSN使用フラグを現在の値に応じて書き換える
    this.setIsSingleNeedle(this.isSingleNeedleUse);
  },

  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
     //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    ...mapMutations("pat-viewer-treat-cond", ["setIsSingleNeedle"]),
    // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 start
    getMstSingleNeedleDisable() {
      if (
        //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.29(外結)対応 韓 start
        // this.isMst &&
        //del FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.29(外結)対応 韓 end
        this.deviceMode &&
        (
          this.deviceMode === 6 ||  //AFBF
          this.deviceMode === 10  //I-HDF
        )
      ) {
        // シングルニードル使用するになっていた場合は強制的にOFFにして、穿刺針(SN)を未登録にする。シングルニード使用を非活性。
        this.displayInputValue.editValue = "0"
        this.setIsSingleNeedle(false);
        return true
      }
      return false
    }
    // add 治療方法セットマスタ 指示_条件送信_治療方法セットマスタ 孔 end
  }
};
</script>
