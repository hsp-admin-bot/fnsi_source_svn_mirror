
<template>
  <div class="date-input">
    <input
      type="date"
      :value="dateValue"
      :id="id"
      class="ntss-input-date date-wrapper"
      :class="computedClasses"
      :min="min"
      :max="max"
      :disabled="disabled"
      v-bind="$attrs"
      @focus="handleFocus"
      @keyup="handleKeyup"
      @change="handleChange"
      @input="handleInput"
      @blur.prevent="handleBlur"
      v-validate="'date_format:yyyy-MM-dd'"
      :name="nameForVeeValidate"
    />
    <span
      v-if="!disabled && dateValue && dateValue !== 'defaultValue' && !isRequired"
      class="k-icon k-i-close close-btn"
      title="clear"
      @click="handleClearInput"
    ></span>
  </div>
</template>
<script>

import {
  DATE_FORMAT,
  dateFormat,
} from "@/functions/common/DateTimeUtils";
import moment from 'moment';

export default {
  name: "DateInput",
  modal: {
    event: "blur",
  },
  props: {
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
      default: "0000-01-01"
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
  },
  computed: {
    nameForVeeValidate() {
      // v-validateを指定する際はname（もしくはdata-vv-name）の
      // 指定も必要なため、指定されていない場合は代替の値を設定する
      return this.$attrs.name || this.$attrs["data-vv-name"] || this.id || "DateInput";
    },
    dateValue() {
      return this.value ? moment(this.value).format('YYYY-MM-DD') : null;
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
  },
  methods: {
    handleClearInput() {
      this.$emit("handleClearInput");
    },
    handleFocus(event) {
      this.$emit("focus", event);
    },
    handleKeyup(event) {
      this.$emit("keyup", event);
    },
    handleInput(event) {
      this.$emit("input", event.target.value);
    },
    handleChange(event) {
      this.$emit("change", event);
    },
    handleBlur(event) {
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
          this.$emit("input", modifiledValue);
        }
      }

      this.$emit("blur", event);
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
</style>
