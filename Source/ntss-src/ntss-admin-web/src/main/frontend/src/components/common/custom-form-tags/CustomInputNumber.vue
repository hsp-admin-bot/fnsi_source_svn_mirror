<template>
  <ons-input
    :class="inputClass"
    :style="inputStyle"
    type="number"
    :step="stepValue"
    :disabled="disabled"
  >
    <input
      ref="input"
      v-bind="forwardedAttrs"
      class="text-input"
      type="number"
      :value="inputtedString"
      :step="stepValue"
      :required="isRequired"
      :disabled="disabled"
      @mouseup.stop="handleMouseUp"
      @focus="addFocusCss"
      @input="inputValidValue"
      @change="handleChangeValue"
      @blur="formatValue"
      @wheel.prevent="wheelChangeValue"
      @keydown="handleKeydown"
    >
    <span class="text-input__label"></span>
  </ons-input>
</template>

<script>
import BigNumber from "bignumber.js";
import {
  isDecimal,
  toFixed,
  plusDecimal,
  minusDecimal,
} from "@/functions/common/NumberFunctions.js";

/**
 * @description 共通数値入力タグ（Vue3対応版）
 * @summary
 *   ■機能
 *     ・上下限値設定
 *     ・桁数設定
 *     ・不正値入力制限
 *     ・上下キー、マウスホイールによる値の増減
 *     ・最大値/最小値へ到達後のループON/OFF
 *
 *   ■props
 *     ・value(必須): 値のオブジェクト({ initValue, editValue })
 *     ・maxValue(必須): 入力可能上限値を指定する
 *     ・minValue(必須): 入力可能下限値を指定する
 *     ・digits(必須): マイナス、小数点を除いた最大許容桁数
 *        例: -100.000を許容したいなら6
 *     ・decimalDigits: 小数部の桁数
 *     ・loopFlg: 最大値や最小値からスクロールさせた時に値をループさせるかさせないか
 *     ・initialValueLock: 初期表示時に入力値の小数部制御を実行するかしないか(初回のみ制御)
 *
 * Vue3移行メモ:
 *     ・Vue2版の BaseCustomForm mixin の値編集・編集判定・バリデーション契約をこのコンポーネント内に内蔵する。
 *     ・v-ons-input は native input へ置き換え、Vue2の $listeners 相当は $attrs のイベントを明示的に呼び出す。
 */
export default {
  name: "CustomInputNumber",
  inheritAttrs: false,
  emits: ["update:value"],
  props: {
    // 値のオブジェクト({ initValue, editValue })
    value: {
      type: Object,
      required: true,
    },
    formName: {
      type: String,
      default: "フォーム名未設定",
    },
    // 必須項目ならtrueを渡す
    isRequired: {
      type: Boolean,
      default: false,
    },
    // バリデーション用関数の配列
    validators: {
      type: Array,
      default: () => [],
      validator: functions => {
        for (const func of functions) {
          if (typeof func !== "function") {
            return false;
          }
        }
        return true;
      },
    },
    defaultHeight: {
      type: String,
      default: "50px",
    },
    maxValue: {
      type: Number,
      required: true,
    },
    minValue: {
      type: Number,
      required: true,
    },
    digits: {
      type: Number,
      required: true,
    },
    decimalDigits: {
      type: Number,
      default: 0,
    },
    loopFlg: {
      type: Boolean,
      default: true,
    },
    initialValueLock: {
      type: Boolean,
      default: false,
    },
    disabled: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      // 入力された文字列
      inputtedString: "",
      // データ整合フラグ
      isValid: true,
      valueLock: false,
      // フォーカス中フラグ。フォーカス中の緑枠表示とホイール操作可否に使用する。
      focusflg: false,
      // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
      blurFlg: false,
      // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
    };
  },
  computed: {
    forwardedAttrs() {
      const attrs = { ...this.$attrs };
      delete attrs.class;
      delete attrs.style;
      Object.keys(attrs).forEach(key => {
        if (this.isControlledAttrListenerKey(key)) {
          delete attrs[key];
        }
      });
      return attrs;
    },
    inputClass() {
      return [
        this.$attrs.class,
        {
          // 常に適用されるclass
          "custom-input-number": true,
          // 編集時に適用されるclass
          "custom-input-number-edited": this.isEdited,
          // 必須項目に適用されるclass
          "custom-input-number-required": this.isRequired,
          // データ不正時に適用されるclass
          "custom-input-number-invalid": !this.isValid,
        },
      ];
    },
    inputStyle() {
      return this.$attrs.style;
    },
    stepValue() {
      return 1 / Math.pow(10, this.decimalDigits);
    },
    // 渡されたデータの初期値
    initValue: {
      get() {
        return this.value.initValue;
      },
      set(value) {
        this.value.initValue = value;
        this.$emit("update:value", this.value);
      },
    },
    // 渡されたデータの編集値
    editValue: {
      get() {
        return this.value.editValue;
      },
      set(value) {
        this.value.editValue = value;
        this.$emit("update:value", this.value);
      },
    },
    // 編集フラグ
    isEdited() {
      return this.initValue != this.editValue;
    },
  },
  watch: {
    /**
     * @description editValueの変更検知
     * @summary 使用画面においてeditValueが直接変更される際に必要
     */
    editValue(newValue) {
      let editString;
      if (newValue === null) {
        // 空欄
        editString = "";
      } else {
        editString = this.toFixedByDecimalDigits(this.editValue);
      }
      this.inputtedString = editString;
      this.fourceUpdateValue(editString);
      this.isValid = true;
    },
    isEdited() {
      // 「コメント」内容未变更时，输入框样式表示为内容变更的样式。
      if ((this.initValue === null || this.initValue === undefined) && this.editValue === "") {
        this.initValue = "";
      }
    },
    decimalDigits(decimalDigits) {
      let initString;
      if (this.editValue === null) {
        // 空欄
        initString = "";
      } else if (
        this.initialValueLock &&
        !this.valueLock &&
        this.getDecimalPointLength(this.editValue) > decimalDigits
      ) {
        // 初期表示時DB取得値の小数点以下数値切り捨て制御テスト
        initString = this.canUseBigNumber(this.editValue)
          ? BigNumber(this.editValue).toFixed()
          : "";
        this.valueLock = true;
      } else {
        initString = this.toFixedByDecimalDigits(this.editValue, decimalDigits);
        if (initString !== "") {
          this.editValue = Number(initString);
        }
        this.valueLock = true;
      }
      this.inputtedString = initString;
      this.fourceUpdateValue(initString);
    },
  },
  /**
   * @description 初期表示時に表示値をセットする
   */
  mounted() {
    let initString;
    if (this.editValue === null) {
      // 空欄
      initString = "";
    } else {
      initString = this.toFixedByDecimalDigits(this.editValue);
    }
    this.inputtedString = initString;
    this.fourceUpdateValue(initString);
  },
  methods: {
    isControlledAttrListenerKey(key) {
      return [
        "onMouseup",
        "onFocus",
        "onInput",
        "onChange",
        "onBlur",
        "onWheel",
        "onKeydown",
      ].includes(key);
    },
    callAttrListener(key, event) {
      const listener = this.$attrs[key];
      if (Array.isArray(listener)) {
        listener.forEach(handler => {
          if (typeof handler === "function") {
            handler(event);
          }
        });
      } else if (typeof listener === "function") {
        listener(event);
      }
    },
    canUseBigNumber(value) {
      if (value === "" || value === null || value === undefined) {
        return false;
      }
      try {
        return BigNumber(value).isFinite();
      } catch (e) {
        return false;
      }
    },
    // add FNSI-入力コンポーネントの変更 徐博 start
    addFocusCss(event) {
      this.focusflg = true;
      this.callAttrListener("onFocus", event);
    },
    // add FNSI-入力コンポーネントの変更 徐博 end

    // mod 7109 修正 chen start
    /**
     * @description 文字列入力処理
     * @summary 入力可能な文字列を入力値として保持する
     */
    inputValidValue(event) {
      if (
        event.data === undefined ||
        event.data === null ||
        this.isNumber(event.data) ||
        ((event.data === "-" || event.data === ".") &&
          this.isNumber(event.target.value))
      ) {
        const el = event.target;
        const value = el.value;
        const stepNum = this.stepValue;

        // spin操作かどうか判定
        if (!event.inputType) {
          // 「空 → spin」の場合
          if (this.inputtedString === "") {
            // ▲か▼かを判別する
            const computedStep = this.canUseBigNumber(value)
              ? minusDecimal(BigNumber(value), BigNumber(0))
              : 0;
            if (computedStep < 0) {
              // ▼（decrement）
              el.value = this.minValue;
            } else {
              // ▲（increment）
              el.value = this.minValue + stepNum;
            }
          }
        }

        this.inputtedString = event.target.value;
      }
      this.callAttrListener("onInput", event);
    },
    /**
     * 数値チェック関数
     * 入力値が数値 (符号あり小数 (- のみ許容)) であることをチェックする
     * [引数]   numVal: 入力値
     * [返却値] true:  数値
     *          false: 数値以外
     */
    isNumber(numVal) {
      // チェック条件パターン
      const pattern = /^[-]?([1-9]\d*|0)(\.\d+)?$/;
      // 数値チェック
      return pattern.test(numVal);
    },
    // mod 7109 修正 chen end

    /**
     * @description 入力文字列のフォーマット
     * @summary 不正値の0リセット、限界値判定、小数桁切り捨て、共通タグバリデーション
     */
    formatValue(event) {
      this.focusflg = false;

      if (this.inputtedString === "") {
        // 空欄はそのまま
        this.udpateValue(null);
        this.callAttrListener("onBlur", event);
        return;
      } else if (!isDecimal(this.inputtedString)) {
        // 不正な文字列は初期値に
        this.udpateValue(this.initValue);
        this.callAttrListener("onBlur", event);
        return;
      }
      // 限界値判定
      let limitedValue = Number(this.inputtedString);
      if (limitedValue > this.maxValue) {
        limitedValue = this.maxValue;
      } else if (limitedValue < this.minValue) {
        limitedValue = this.minValue;
      }

      // 小数指定桁切り捨て
      const truncatedValue = +this.toFixedByDecimalDigits(limitedValue);
      this.udpateValue(truncatedValue);
      this.validate();
      this.callAttrListener("onBlur", event);
    },
    // add #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 start
    handleMouseUp(event) {
      if (event.target.value === "" && !this.isRequired) {
        this.editValue = null;
      } else if (event.target.value > this.maxValue) {
        this.editValue = this.minValue;
      } else if (event.target.value < this.minValue) {
        this.editValue = this.maxValue;
      } else {
        this.editValue = +event.target.value;
      }
      this.udpateValue(this.editValue);
      this.callAttrListener("onMouseup", event);
    },
    // add #9857 2023/11/29 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 end
    handleChangeValue(event) {
      let truncatedValue;
      // 患者経過総合ビューア 身体情報 焦点が離れた時は初期値になりますバグ修正
      if (this.isRequired) {
        truncatedValue = +this.toFixedByDecimalDigits(event.target.value);
      } else {
        truncatedValue = this.toFixedByDecimalDigits(event.target.value);
      }
      this.udpateValue(truncatedValue);
      this.validate();
      this.callAttrListener("onChange", event);
    },
    /**
     * @description マウスホイールイベントハンドラ
     * @summary マウスホイールでの入力値の増減を可能にする
     */
    wheelChangeValue(event) {
      // disabledでマウスホイールを拾わない
      if (this.$refs.input?.disabled) {
        return;
      }
      if (this.focusflg) {
        // マウスホイールの向き
        const isUp = event.deltaY < 0;
        // 変更量(小数最下位を1ずつ)
        const stepNum = this.stepValue * (isUp ? 1 : -1);

        // 空欄 ▼（decrement）: 最小値、▲（increment）: 最小値＋step
        if (this.inputtedString === "") {
          const updVal = isUp ? (this.minValue + stepNum) : this.minValue;
          this.udpateValueAndNotifyChange(updVal, event);
          this.callAttrListener("onWheel", event);
          return;
        }
        // 不正値は最小値に
        if (!isDecimal(this.inputtedString)) {
          this.udpateValueAndNotifyChange(this.minValue, event);
          this.callAttrListener("onWheel", event);
          return;
        }

        this.stepChangeValue(stepNum, event);
      }
      this.callAttrListener("onWheel", event);
    },
    // add #9857 2023/12/05 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 start
    keyDownValue(event) {
      if (event.target.value > this.maxValue) {
        this.editValue = this.maxValue;
      } else if (event.target.value < this.minValue) {
        this.editValue = this.minValue;
      } else {
        this.editValue = +event.target.value;
      }
      this.udpateValue(this.editValue);
    },
    // add #9857 2023/12/05 Na注入プログラムの詳細画面で画面遷移直後は最大値の制限が適用されずに編集可能 張玲 end

    /**
     * @description キー押下イベントハンドラ
     * @summary Vue2版の v-on="$listeners" と同じく、親コンポーネントの keydown も全キーで呼び出す
     */
    handleKeydown(event) {
      if (event.key === "ArrowUp" || event.key === "ArrowDown") {
        event.preventDefault();
        this.keyChangeValue(event);
      } else if (event.key === "Enter") {
        this.keyDownValue(event);
      }
      this.callAttrListener("onKeydown", event);
    },

    /**
     * @description キー押下イベントハンドラ
     * @summary 上下キーでの入力値の増減を可能にする
     */
    keyChangeValue(event) {
      // 上下キー判定
      const isUp = event.key === "ArrowUp";
      // 変更量(小数最下位を1ずつ)
      const stepNum = this.stepValue * (isUp ? 1 : -1);
      // 空欄 ▼（decrement）: 最小値、▲（increment）: 最小値＋step
      if (this.inputtedString === "") {
        const updVal = isUp ? (this.minValue + stepNum) : this.minValue;
        this.udpateValueAndNotifyChange(updVal, event);
        return;
      }
      // 不正値は最小値に
      if (!isDecimal(this.inputtedString)) {
        this.udpateValueAndNotifyChange(this.minValue, event);
        return;
      }

      this.stepChangeValue(stepNum, event);
    },

    /**
     * @description マウスホイールと上下キーによる値の増減
     * @param {Number} stepNum 増減させる値
     */
    stepChangeValue(stepNum, event = null) {
      // 限界値判定
      let plusResult = plusDecimal(Number(this.inputtedString), stepNum);
      // 限界値を超えた際の値をループ設定有無で振り分け
      if (plusResult > this.maxValue) {
        plusResult = this.loopFlg ? this.minValue : this.maxValue;
      } else if (plusResult < this.minValue) {
        plusResult = this.loopFlg ? this.maxValue : this.minValue;
      }
      if (event) {
        this.udpateValueAndNotifyChange(plusResult, event);
      } else {
        this.udpateValue(plusResult);
      }
    },

    /**
     * @description 編集値の更新と同時に表示値を書き換える
     * @param {Number} value 値
     */
    udpateValue(value) {
      this.editValue = value;
      let editString;
      if (value === null) {
        // 空欄
        editString = "";
      } else {
        // 0詰め
        editString = this.toFixedByDecimalDigits(value);
      }
      this.inputtedString = editString;
      this.fourceUpdateValue(editString);
    },
    /**
     * @description 手動ステップ操作時の値更新通知
     * @summary
     *   ホイール/上下キーはブラウザ標準のchangeを発火しないため、
     *   Vue2版の$listeners相当として親コンポーネントのchange処理も呼び出す。
     */
    udpateValueAndNotifyChange(value, event) {
      this.udpateValue(value);
      if (event?.target) {
        event.target.value = this.inputtedString;
      }
      this.validate();
      this.callAttrListener("onChange", event);
    },

    /**
     * @description value属性強制更新
     * @summary 入力制限による値の動的な変更は、valueバインドだけでは反映タイミングがずれるため直接補正する
     * @param {String} valueString 書き換える値
     */
    fourceUpdateValue(valueString) {
      this.inputtedString = valueString;
      this.$nextTick(() => {
        if (this.$refs.input) {
          this.$refs.input.value = valueString;
        }
      });
    },

    /**
     * @description 設定値の小数点桁数算出
     * @param {Number} value 値
     */
    getDecimalPointLength(number) {
      const numbers = String(number).split(".");
      return numbers[1] ? numbers[1].length : 0;
    },

    /**
     * @description 小数を指定桁数に丸める
     * @param {Number} value 値
     * @param {Number} decimalDigits 桁数
     */
    toFixedByDecimalDigits(value, decimalDigits = this.decimalDigits) {
      // 患者経過総合ビューア 身体情報 焦点が離れた時は初期値になりますバグ修正
      if (!this.isRequired && (value === "" || isNaN(value))) {
        return "";
      }
      if (!this.canUseBigNumber(value)) {
        return "";
      }
      return decimalDigits === Infinity ? value : toFixed(value, decimalDigits);
    },
    /**
     * @description バリデーション
     * @returns {String} バリデーション失敗理由 ※成功の場合は空文字
     */
    validate() {
      let invalidReason = "";
      if (this.editValue !== null) {
        // 値が入力されている場合、与えられたバリデーション関数を全て実行
        for (const validator of this.validators) {
          invalidReason = validator(this.editValue);
          if (invalidReason !== "") {
            // バリデーション失敗
            this.isValid = false;
            break;
          }
        }
      }
      return invalidReason;
    },
    /**
     * @description 必須チェック
     */
    checkRequired() {
      let isValid = true;
      if (this.isRequired && (this.editValue === null || this.editValue === "")) {
        isValid = false;
      }
      this.isValid = isValid;
      return isValid;
    },
    /**
     * @description 入力内容確定時のバリデーション
     * @summary 確定や保存時にバリデーションと必須チェックを同時に実行する
     */
    validateForCommitting() {
      return this.validate() === "" && this.checkRequired();
    },
  },
};
</script>

<style scoped>
:deep(input.text-input) {
  color: black;
  background-color: #F7F7F7;
  text-align: right !important;
  min-width: 50px;
}

:deep(input.text-input:focus) {
  border: 2px solid green !important;
  outline: 0;
}

.custom-input-number-edited :deep(input.text-input) {
  border: 2px green solid;
  outline: 0;
}

.custom-input-number-required :deep(input.text-input) {
  color: black;
  background-color: #ffff99;
}

.custom-input-number-invalid :deep(input.text-input) {
  color: black;
  background-color: rgba(255, 0, 0, 0.5) !important;
}
</style>
