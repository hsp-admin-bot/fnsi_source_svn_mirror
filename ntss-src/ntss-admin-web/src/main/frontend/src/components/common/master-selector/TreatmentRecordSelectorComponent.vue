
<template>
    <v-ons-col style="max-width: fit-content;">
      <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start -->
      <!-- <v-ons-button
        class="button common-style-select-button btn3-normal"
        style="margin-left:5px;"
        @click="createPopoverData(value ? value.cd : null)"
        :class="isClass"
        :disabled="isDisabled">選択</v-ons-button> -->
        <v-ons-button
        class="button common-style-select-button btn3-normal"
        style="margin-left:5px;"
        @click="createPopoverData(value ? value.cd : null, index)"
        :class="isClass"
        :disabled="isDisabled">選択</v-ons-button>
      <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end -->
      <pop-over v-bind="popoverData" @popover-close="closePopover" @popover-return="updateInput" :exeLableName="exeLableName" :isActiveBtn="isActiveBtn"/>
    </v-ons-col>
</template>

<script>
import MasterSelectorMixin from "@/components/common/master-selector/MasterSelectorMixin";
import { Master } from "@/models/common/master-selector-condition/Master";

export default {
  mixins: [MasterSelectorMixin],
  props: {
    index: {
      type: Number,
      default: undefined
    },
    name: {
      type: String
    },
    labelName: {
      type: String
    },
    showLabelName: {
      type: Boolean,
      default: true
    },
    showClassFilter: {
      type: Boolean,
      default: true
    },
    value: {
      type: Object
    },
    isDisabled: {
      type: Boolean,
      default: false
    },
    isClass: {
      type: [Array, String],
      default: () => []
    },
    exeLableName: {
      type: String,
      default: "OK"
    },
    isActiveBtn: {
      type: Boolean,
      default: true
    },
  },
  methods: {
    updateInput(data) {
      // add #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng start
      if (!data) {
        return;
      }
      // add #11585 治療記録＞医療材料で登録済み医療材料と同一の医療材料を追加できてしまう。 linjunfeng end
      const master = new Master(data.value, data.text);
      if (data.needle) {
        master.needle = data.needle;
      }
      this.popoverData.popoverContentSelected = data;
      this.$emit("input", master, this.index);
      this.$emit("changeUnit", data.unit, this.index);
      this.$emit("changeDecPoint",data.decPoint, this.index);
      this.$emit("changePersonalUser", data.personalUserInfo, this.index);
    }
  }
};
</script>

<style scoped>

</style>
