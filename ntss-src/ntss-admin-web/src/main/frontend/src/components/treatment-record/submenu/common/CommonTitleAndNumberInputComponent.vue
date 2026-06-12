/**
 * タイトル、数値入力共通コンポーネント
 */
<template>
  <v-ons-row>
    <v-ons-col class="title">
      <custom-simple-textarea-b
        ref="mySelecTitle"
        v-model="currentTitle"
        :disabled="disabled"
        :init-value="initTitle"
        :is-edit="true"
        class="textarea-border-settings"
      />
    </v-ons-col>
    <v-ons-col class="num-value">
      <label v-if="subLabelName" class="sub-title theme">
        {{subLabelName}}
      </label>
      <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
      <!-- <v-ons-input 
        model-event="change"
        v-model.number="currentValue"
        :disabled="disabled"
        @blur="onBlur"
        @keypress="onKeyPress"
        @keydown="onKeyDown"
      /> -->
      <!-- <v-ons-input 
        :type="inputType"
        model-event="change"
        v-model.number="currentValue"
        :disabled="disabled"
        :step="step"
        @blur="onBlur"
        @keypress="onKeyPress"
        @keydown="onKeyDown"
        @input="inputNumber($event)"
        @mousewheel="(event)=>{ return event.target.value}"
      /> -->
      <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
      <CustomInputNumberPro
        ref="mySelect"
        :key="numberInputResetKey"
        class="custom-title-number-input"
        :emptyVal="null"
        :value-modifiers="{ lazy: true }"
        :value="currentValuePro"
        :min="currentMin"
        :max="currentMax"
        :step="currentStep"
        :roll-flag="true"
        :disabled="disabled"
        @handlerInput="handlerInput"
        @blur="onBlur"
      />
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end -->
      <label class="theme" style="margin-left: 0.5em;">{{unitName}}</label>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
import NumberInputMixin from "@/components/treatment-record/submenu/common/NumberInputMixin";
import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
import { TitleAndNumber } from "@/models/common/TitleAndNumber";

export default {
  mixins: [NumberInputMixin],
  components: {
    "custom-simple-textarea-b": CustomSimpleTextareaTypeB,
    CustomInputNumberPro
  },
  emits: ["update:modelValue", "blur"],
  props: {
    name: {
      type: String
    },
    labelName: {
      type: String
    },
    subLabelName: {
      type: String
    },
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: TitleAndNumber
    },
    disabled: {
      type: Boolean,
      default: false
    },
    // mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start
    inputType:{
      type: String,
      default:"text"
    },
    inputMin:{
      type: Number,
      default: null
    },
    inputMax:{
      type: Number,
      default: null
    },
    step: {
      type: Number,
      default: null
    },
    // mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end
  },
  data(){
    return {
      initTitle: this.modelValue?.title ?? ""
    }
  },
  computed: {
    currentTitle: {
      get() {
        return this.modelValue.title;
      },
      set(newVal) {
        this.$emit("update:modelValue", new TitleAndNumber(newVal, this.modelValue.value));
      }
    },
    currentValue: {
      get() {
        return this.modelValue.value != null ? (this.modelValue.value / this.base).toFixed(this.decimalLength) : null;
      },
      set(newVal) {
        this.$emit(
          "update:modelValue",
          new TitleAndNumber(
            this.modelValue.title,
            typeof newVal === "number" ? newVal * this.base : null
          )
        );
        // 数値以外の値が入力された場合は0に変更する
        if (!(typeof newVal === "number")) {          
          this.$nextTick(() => {
            this.$emit(
              "update:modelValue",
              new TitleAndNumber(
                this.modelValue.title,
                0
              )
            );
          })
        }
      }
    },
    currentValuePro() {
      return this.modelValue.value != null ? this.modelValue.value / this.base : null;
    },
    currentMin() {
      return this.inputMin ?? -999999999999999999;
    },
    currentMax() {
      return this.inputMax ?? 999999999999999999;
    },
    currentStep() {
      return this.step ?? 1;
    },
    numberInputResetKey() {
      return [
        this.unitName,
        this.base,
        this.currentMin,
        this.currentMax,
        this.currentStep
      ].join("_");
    }
  },
  // mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start
  methods:  {
    handlerInput(val) {
      const num = val == null || val === "" ? null : Number(val);
      this.$emit("update:modelValue", new TitleAndNumber(
        this.modelValue.title,
        num != null && !Number.isNaN(num) ? num * this.base : null
      ));
    },
    onBlur (event) {
      this.$nextTick(() => {
        this.$emit('blur', event);
      });
    },
    // add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end
  }
   // mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end
};
</script>

<style scoped>
.textarea-border-settings {
  width: 100%;
  margin-right: 0.5em;
  border-color: unset;
  border-style: inset;
}
.num-value ons-input,
.custom-title-number-input {
  width: 10em;
  height: 2em;
  vertical-align: top;
}
.custom-title-number-input :deep(input.text-input) {
  height: 2em;
  box-sizing: border-box;
}
.custom-input-edited {
  border: 2px green solid;
  outline: 0;
}
</style>
