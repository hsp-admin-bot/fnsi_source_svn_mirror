<template>
  <span class="device-input-time">
    <custom-input-time
      ref="el"
      v-bind="deviceInfo"
      :is-required="required"
      :minutes-mode="true"
      :disabled="disabled"
      :default-time="defaultTime"
      max-value="09:59"
      v-on="$listeners"
    />
    {{ deviceInfo.unitName }}
  </span>
</template>

<script>
import customInputTime from "@/components/common/custom-form-tags/CustomInputTime.vue";
import baseForm from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoForm.vue";

/**
 * @description 装置設定値(時間)入力用コンポーネント
 * @summary
 *   ◯props
 *     ・required(任意): 入力必須フラグ ※必須ではない場合のみfalseを与えること
 */
export default {
  components: {
    "custom-input-time": customInputTime
  },

  mixins: [baseForm],

  props: {
    required: {
      type: Boolean,
      default: true
    },
    /**
     * @description 補正に使用するデフォルト値。指定無しの場合はTimeinputでsysdateの時刻で補正。
     * "HH:mm"形式で指定してください。
     */
    defaultTime: {
      type: String,
      default: ""
      }
  }
};
</script>

<style scoped>
</style>
