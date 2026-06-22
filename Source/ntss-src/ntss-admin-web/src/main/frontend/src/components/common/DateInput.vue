
<template>
  <div class="date-input" :class="rootClass" :style="rootStyle">
    <input
      ref="input"
      type="date"
      :value="inputDisplayValue"
      :id="id"
      class="ntss-input-date date-wrapper"
      :class="computedClasses"
      :min="min"
      :max="max"
      :disabled="disabled"
      v-bind="inputAttrs"
      @focus="handleFocus"
      @keyup="handleKeyup"
      @change="handleChange"
      @input="handleInput"
      @blur.prevent="handleBlur"
      @wheel.prevent="handleWheel"
      v-rules="'date_format:yyyy-MM-dd'"
      :name="validationFieldName"
    />
    <span
      v-if="!disabled && dateValue && !isRequired"
      class="close-btn"
      title="clear"
      @click="handleClearInput"
    ><SvgIcon :icon="xIcon" /></span>
  </div>
</template>
<script>

import {
  DATE_FORMAT,
  dateFormat,
} from "@/functions/common/DateTimeUtils";
import dayjs from "@/compat/date/dayjs";
import { applyModelModifiers } from "@/compat/vue/model";
import { syncLegacyDateInputDom } from "@/components/common/date-input-dom";
import { SvgIcon } from '@progress/kendo-vue-common';
import { xIcon } from "@progress/kendo-svg-icons";

export default {
  components: { SvgIcon },
  data() {
    return {
      xIcon,
      /** フォーカス中は DOM の入力値を優先（type=date の手入力が :value で潰れないようにする） */
      focusedValue: null,
      defaultEmptyActive: false,
    };
  },
  name: "DateInput",
  inheritAttrs: false,
  modal: {
    event: "blur",
  },
  props: {
    modelValue: [String, Number],
    value: [String, Number],
    id: String,
    disabled: Boolean,
    /**
     * @description 入力要素に適用するカスタムCSSクラス
     */
    classes: {
      type: String,
      default: ""
    },
    /**
     * @description 許容する日付の最小値
     */
    min: {
      type: String,
      default: "0001-01-01"
    },
    /**
     * @description 許容する日付の最大値
     */
    max: {
      type: String,
      default: "9999-12-31"
    },
    /**
     * @description 無指定(空)を許容する(TRUE)か否(FALSE)かを切り替えるフラグ
     * @deprecated 代わりに必須か任意入力かを切り替えるisRequiredを使用してください
     */
    enabledBlank: {
      type: Boolean,
      default: false
    },
    /**
     * @description 必須か任意入力かを切り替えるフラグ
     */
    isRequired: {
      type: Boolean,
      default: false
    },
    /**
     * @description 補正に使用するデフォルト値。指定無しの場合はsysdateで補正。
     * "YYYY-MM-DD"形式で指定してください。
     */
    defaultDate: {
      type: String,
      default: ""
    },
    /**
     * @description 画面表示時、デフォルトだけ空にしたい場合に指定。
     */
    defaultEmpty: {
      type: Boolean,
      default: false
    },
    modelModifiers: {
      type: Object,
      default: () => ({})
    },
  },
  computed: {
    rootClass() {
      return this.$attrs.class;
    },
    rootStyle() {
      return this.$attrs.style;
    },
    inputAttrs() {
      const attrs = { ...this.$attrs };
      delete attrs.class;
      delete attrs.style;
      return attrs;
    },
    validationFieldName() {
      // v-rulesを指定する際はname（もしくはdata-validation-name）の
      // 指定も必要なため、指定されていない場合は代替の値を設定する
      return this.$attrs.name || this.$attrs["data-validation-name"] || this.id || "DateInput";
    },
    externalValue() {
      return this.modelValue !== undefined ? this.modelValue : this.value;
    },
    dateValue() {
      const raw = this.externalValue;
      if (raw === null || raw === undefined || raw === "") {
        return null;
      }
      const text = String(raw);
      const strict = dayjs(text, ["YYYY-MM-DD", "YYYYMMDD"], true);
      if (strict.isValid()) {
        return strict.format("YYYY-MM-DD");
      }
      const loose = dayjs(text);
      return loose.isValid() ? loose.format("YYYY-MM-DD") : null;
    },
    inputDisplayValue() {
      if (this.defaultEmptyActive) {
        return null;
      }
      if (this.focusedValue !== null) {
        return this.focusedValue;
      }
      return this.dateValue;
    },
    computedClasses() {
      const baseClasses = [];
      if (this.classes !== "") {
        baseClasses.push(...this.classes.split(" "));
      }
      if (this.isRequired) {
        baseClasses.push("date-input-just-size");
      }
      return baseClasses;
    },
    validationMessage() {
      return this.$refs.input?.validationMessage || "";
    },
  },
  mounted() {
    this.defaultEmptyActive = this.defaultEmpty;
    this.syncLegacyDom();
  },
  updated() {
    this.syncLegacyDom();
  },
  methods: {
    syncLegacyDom() {
      syncLegacyDateInputDom(this.$refs.input, { required: this.isRequired });
    },
    handleClearInput() {
      this.$emit("handleClearInput");
    },
    handleFocus(event) {
      this.focusedValue = event.target.value || "";
      this.$emit("focus", event);
    },
    handleKeyup(event) {
      this.$emit("keyup", event);
    },
    emitInputValue(value) {
      this.defaultEmptyActive = false;
      const nextValue = applyModelModifiers(value, this.modelModifiers);
      if (String(nextValue ?? "") === String(this.externalValue ?? "")) {
        return;
      }
      this.$emit("update:modelValue", nextValue);
      this.$emit("input", nextValue);
    },
    handleInput(event) {
      this.focusedValue = event.target.value;
      this.emitInputValue(event.target.value);
    },
    handleChange(event) {
      this.$emit("change", event);
    },
    handleBlur(event) {
      this.focusedValue = null;
      const inputValue = event.target.value;
      if (!inputValue) {
        // 空入力、欠落入力の場合
        if (event.target.validationMessage) {
          // 入力形式エラーがある場合
          // 一度有効な日付を入力した状態にしてから入力状態を空にする
          event.target.value = dateFormat.format(new Date(), DATE_FORMAT);
          event.target.value = "";
        }

        let modifiledValue = inputValue;
        if (this.defaultDate !== "") {
          // defaultDateが設定されていたらdefaultDateで補正
          modifiledValue = this.defaultDate;
        } else if (this.isRequired) {
          // defaultDateがなく必須入力の場合はsysdateで補正
          // "YYYY-MM-DD"形式の日付をセット
          modifiledValue = dateFormat.format(new Date(), DATE_FORMAT);
        }
        if (modifiledValue !== inputValue) {
          // 入力値の補正を行う場合は補正後の入力値でのinputイベントを発火しておく
          event.target.value = modifiledValue;
          this.emitInputValue(modifiledValue);
        }
      } else {
        const minDate = dayjs(this.min, "YYYY-MM-DD");
        const maxDate = dayjs(this.max, "YYYY-MM-DD");
        const currentDate = dayjs(inputValue, "YYYY-MM-DD");

        let modifiledValue = inputValue;
        if (currentDate.isBefore(minDate)) {
          modifiledValue = minDate.format("YYYY-MM-DD");
        } else if (currentDate.isAfter(maxDate)) {
          modifiledValue = maxDate.format("YYYY-MM-DD");
        }

        if (modifiledValue !== inputValue) {
          event.target.value = modifiledValue;
          this.emitInputValue(modifiledValue);
        }
      }

      this.$emit("blur", event);
    },
    handleWheel(event) {
      event.preventDefault();
      if (this.disabled) {
        return;
      }

      const input = event.target;
      const ownerDocument = input.ownerDocument || document;
      if (ownerDocument.activeElement !== input) {
        return;
      }

      const minDate = dayjs(this.min, "YYYY-MM-DD");
      const maxDate = dayjs(this.max, "YYYY-MM-DD");
      let currentDate = input.value ? dayjs(input.value, "YYYY-MM-DD") : minDate.clone();

      if (event.deltaY < 0) {
        currentDate = currentDate.isSameOrAfter(maxDate)
          ? minDate.clone()
          : currentDate.add(1, "day");
      } else {
        currentDate = currentDate.isSameOrBefore(minDate)
          ? maxDate.clone()
          : currentDate.subtract(1, "day");
      }

      const newValue = currentDate.format("YYYY-MM-DD");
      input.value = newValue;
      this.focusedValue = newValue;
      this.emitInputValue(newValue);
    },
  }
}
</script>
<style scoped>
.date-input {
  position: relative;
  display: inline-block;
}
.date-input input {
  width: 100%;
}
.date-input:hover>.close-btn {
  display: block;
}
.date-input .close-btn {
  position: absolute;
  right: 5px;
  padding: 0;
  color: #212529;
  cursor: pointer;
  top: 50%;
  transform: translate(0, -50%);
}
.k-icon {
  opacity: .5;
}
.k-icon:hover {
  opacity: 1;
}
.time-input-edited {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.date-wrapper {
  -webkit-appearance: none;
}
.date-input-required {
  background-color: #ffff99 !important;
}
.date-input-required:disabled {
  color: #999;
}
.date-input-edited {
  border: 2px green solid !important;
  outline: 0;
}
.date-input-edited:disabled {
  opacity: 0.5;
}
.date-input-focus:focus {
  border: 2px #008000 solid;
  outline: 0;
}
.date-input-just-size {
  padding-right: unset !important;
}
.date-input-unjust-size {
  padding-right: 1.8em !important;
}
.custom-input-date-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.5) !important;
}
</style>
