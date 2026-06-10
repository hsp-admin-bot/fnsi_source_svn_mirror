<template>
  <span class="device-input-date">
    <!--mod FNSI-検査日入力不可変更 楊 start -->
    <!--     <custom-input-date
      ref="el"
      v-bind="deviceInfo"
      :is-required="required"
      :disabled="disabled"
      v-on="$listeners"
    /> -->
    <custom-input-date
      ref="el"
      v-bind="deviceInfo"
      :is-required="required"
      :disabled="disabled"
      :callBackFunc="callBackFunc"
      v-on="$listeners"
    />
    <!--mod FNSI-検査日入力不可変更 楊 end -->
    {{ deviceInfo.unitName }}
  </span>
</template>

<script>
import customInputDate from "@/components/common/custom-form-tags/CustomInputDate.vue";
import baseForm from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoForm.vue";

/**
 * @description 装置設定値(時間)入力用コンポーネント
 * @summary
 *   ◯props
 *     ・required(任意): 入力必須フラグ ※必須ではない場合のみfalseを与えること
 */
export default {
  components: {
    "custom-input-date": customInputDate
  },

  mixins: [baseForm],

  props: {
    required: {
      type: Boolean,
      default: true
    },
    // add FNSI-検査日入力不可変更 楊 start
    callBackFunc: {
      type: Function,
      default: () => {}
    },
    // add FNSI-検査日入力不可変更 楊 end
  }
};
</script>

<style scoped></style>
