/**
 * マスタ選択共通コンポーネント
 */
<template>
  <v-ons-row class="mst-selector">
    <v-ons-col v-if="showLabelName" class="title d-flex align-items-center">
      <label class="theme">
        {{ labelName }}
      </label>
    </v-ons-col>
    <v-ons-col class="text-value d-flex align-items-center">
      <label class="theme">
        {{ externalValue ? externalValue.name : "" }}
      </label>
    </v-ons-col>
    <v-ons-col class="select-button-col d-flex align-items-center">
      <!-- mod FNSI-redmine3855 徐 start -->
      <!-- <v-ons-button
        class="button select-btn btn3-normal"
        @click="createPopoverData(externalValue ? externalValue.cd : null)"
        :disabled="isDisabled">選択</v-ons-button> -->
      <v-ons-button
        class="button select-btn-self btn3-normal"
        @click="createPopoverData(externalValue ? externalValue.cd : null)"
        :class="isClass"
        :disabled="isDisabled">選択</v-ons-button>
      <!-- mod FNSI-redmine3855 徐 end -->
      <pop-over v-bind="popoverData" @popover-close="closePopover" @popover-return="updateInput" :exeLableName="exeLableName"/>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
import MasterSelectorMixin from "@/components/common/master-selector/MasterSelectorMixin";
import { Master } from "@/models/common/master-selector-condition/Master";

export default {
  mixins: [MasterSelectorMixin],
  emits: [
    "update:modelValue",
    "input",
    "changeUnit",
    "changeDecPoint",
    "changePersonalUser"
  ],
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
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: Object,
      default: undefined
    },
    value: {
      type: Object,
      default: undefined
    },
    isDisabled: {
      type: Boolean,
      default: false
    },
    // add FNSI-redmine3855 徐 start
    isClass: {
      type: [Array, String],
      default: () => []
    },
    // add FNSI-redmine3855 徐 end
    exeLableName: {
      type: String,
      default: "OK"
    }
  },
  computed: {
    externalValue() {
      return this.modelValue !== undefined ? this.modelValue : this.value;
    }
  },
  methods: {
    updateInput(data) {
      const master = new Master(data.value, data.text);
      if (data.needle) {
        master.needle = data.needle;
      }
      this.popoverData.popoverContentSelected = data;
      this.$emit("update:modelValue", master, this.index);
      this.$emit("input", master, this.index);
      this.$emit("changeUnit", data.unit, this.index);
      this.$emit("changeDecPoint",data.decPoint, this.index);
      this.$emit("changePersonalUser", data.personalUserInfo, this.index);
    }
  }
};
</script>

<style scoped>
.select-button-col{
  flex: 0 0 4em;
}
.select-btn-self {
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  min-width: 4em;
  font-size: 1em;
  cursor: pointer;
}
.select-btn-self:hover {
  color: #212529;
}
.mst-selector .text-value {
  padding: 0 5px;
}
</style>
