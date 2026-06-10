<template>
  <span class="device-input-number">
  <!--mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start-->
    <!-- <custom-input-number
      ref="el"
      v-bind="deviceInfo"
      :is-required="required"
      :disabled="disabled"
      v-on="$listeners"
    /> -->
    <custom-input-number-pro
      class="custom-input-number"
      ref="el"
      :initVal="deviceInfo.value.initValue"
      :value="deviceInfo.value.editValue"
      :max="deviceInfo.maxValue"
      :min="deviceInfo.minValue"
      :step="deviceInfo.step"
      :required="required"
      :disabled="disabled"
      @handlerInput="handlerInput"
      @mouseup="handlerMouseUp"
      v-on="$listeners"
    />
  <!--mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end-->
    {{ deviceInfo.unitName }}
  </span>
</template>

<script>
//mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start
//import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber.vue";
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
import baseForm from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoForm.vue";
//mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end

/**
 * @description 装置設定値(数値)入力用コンポーネント
 * @summary
 *   ◯props
 *     ・required(任意): 入力必須フラグ ※必須ではない場合のみfalseを与えること
 */
export default {
  components: {
    //mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start
    // "custom-input-number": customInputNumber
    "custom-input-number-pro": CustomInputNumberPro
    //mod #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end
  },

  mixins: [baseForm],

  props: {
    required: {
      type: Boolean,
      default: true
    }
  },
  //add #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start
  methods: {
    handlerMouseUp(){
      if(this.deviceInfo.minValue === this.deviceInfo.maxValue && this.deviceInfo.maxValue === 0){
        this.deviceInfo.value.editValue = "0"
      }
    },
    handlerInput(val){
      if(this.deviceInfo.value.editValue != val){
        this.deviceInfo.value.editValue = val;
      }
      this.$emit("input")
    },
  },
  //add #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end
};
</script>
