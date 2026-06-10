<template>
  <span>
    <custom-select
      ref="el"
      v-bind="deviceInfo"
      :disabled="disabled"
      v-on="$listeners"
    />
  </span>
</template>

<script>
import customSelect from "@/components/common/custom-form-tags/CustomSelect.vue";
import baseForm from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoForm.vue";

/**
 * @description 装置設定値(数値)入力用コンポーネント
 */
export default {
  components: {
    "custom-select": customSelect
  },

  mixins: [baseForm]
};
</script>

<style scoped>
</style>
