<template>
  <span :class="$attrs.class" :style="$attrs.style">
    <custom-radio
      v-for="(radioInfo, index) in deviceInfo.options"
      :ref="`el${index}`"
      :key="index"
      :value="deviceInfo.value"
      :name="formName"
      :radio-value="radioInfo.radioValue"
      :disabled="disabled"
      v-bind="radioAttrs"
    >
      {{ radioInfo.displayString }}
    </custom-radio>
  </span>
</template>

<script>
import customRadio from "@/components/common/custom-form-tags/CustomRadio.vue";
import baseForm from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoForm.vue";

/**
 * @description 装置設定値(数値)入力用コンポーネント
 */
export default {
  inheritAttrs: false,
  components: {
    "custom-radio": customRadio
  },

  mixins: [baseForm],

  computed: {
    radioAttrs() {
      const { class: _class, style: _style, ...attrs } = this.$attrs;
      return attrs;
    },

    /**
     * @description 編集有無フラグ
     */
    isEdited() {
      return this.$refs.el0[0].isEdited;
    }
  }
};
</script>

<style scoped>
</style>
