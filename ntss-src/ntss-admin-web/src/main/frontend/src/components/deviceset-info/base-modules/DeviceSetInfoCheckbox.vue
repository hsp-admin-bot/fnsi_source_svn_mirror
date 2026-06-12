<template>
  <span>
    <custom-checkbox
      ref="el"
      v-bind="{ ...deviceInfo, ...$attrs }"
      :disabled="disabled"
    >
      {{ deviceInfo.displayString }}
    </custom-checkbox>
  </span>
</template>

<script>
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox.vue";
import baseForm from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoForm.vue";

/**
 * @description 装置設定値(チェックボックス)入力用コンポーネント
 * @summary
 *   ■props
 *     ・deviceInfo(必須): DeviceSetInfoFunctions.js encodeDeviceSetInfoXXX()によって作成した各装置設定のオブジェクト
 */
export default {
  inheritAttrs: false,
  components: {
    "custom-checkbox": customCheckbox
  },

  mixins: [baseForm]
};
</script>

<style scoped></style>
