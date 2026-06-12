<template>
  <ons-input
    class="custom-common-number-input-pro"
    :class="inputClass"
    :style="inputStyle"
    type="number"
    :step="step"
    :disabled="disabled"
    :required="required"
  >
    <input
      ref="input"
      v-bind="forwardedAttrs"
      class="text-input"
      type="number"
      :step="step"
      :value="inputValue"
      :disabled="disabled"
      :required="required"
      @focus="onFocus"
      @wheel.prevent="onInputWheel"
      @blur="onBlur"
      @input="onInput"
      @change="onChange"
      @keydown.enter.prevent="onKeydownEnter"
      @keydown="onKeydown"
    >
    <span class="text-input__label"></span>
  </ons-input>
</template>

<script>
import BigNumber from "bignumber.js";
import { plusDecimal, minusDecimal, toFixed } from "@/functions/common/NumberFunctions";

const NUMBER_INPUT_FORMAT = {
  decimalSeparator: ".",
  groupSeparator: "",
  groupSize: 3,
};
const NUMBER_GROUP_SEPARATOR = ",";

/**
 * @description 共通数値入力コンポーネント（Vue3対応版）
 * @summary
 * ■機能
 *     ・上下限値設定
 *     ・小数点桁数設定
 *     ・不正値入力制限
 *     ・上下キー、マウスホイールによる値の増減
 *     ・最大値/最小値へ到達後のループON/OFF
 *
 * Vue3移行メモ:
 *     ・Vue2版の v-ons-input / $listeners は使用せず、native input と $attrs 透過で置き換える。
 *     ・新しい v-model は modelValue / update:modelValue、既存呼び出し互換は value / update:value で吸収する。
 */
export default {
  name: "CustomInputNumberPro",
  inheritAttrs: false,
  emits: ["handlerInput", "update:modelValue", "update:value"],
  props: {
    // Vue3標準の入力値（v-model）
    modelValue: {},
    // Vue2互換の入力値（既存呼び出しの移行用）
    value: {},
    // 初期値（入力値とは別に初期表示時点で新たに初期値の指定が必要な場合に使用）
    // pat-viewer では編集判定の比較基準としても使用する（#10937）
    initVal: {
      type: [Number, String],
    },
    // v-model修飾子をattrsとしてnative inputへ落とさないために受け取る。
    modelModifiers: {
      type: Object,
      default: () => ({}),
    },
    // v-model:value修飾子をattrsとしてnative inputへ落とさないために受け取る。
    valueModifiers: {
      type: Object,
      default: () => ({}),
    },
    // 入力下限
    min: {
      type: Number,
      default: -999999999999999999,
    },
    // ループ時に使用する補助値配列（下限側）
    minArray: {
      type: Array,
      default: () => [],
    },
    // 入力上限
    max: {
      type: Number,
      default: 999999999999999999,
    },
    // ループ時に使用する補助値配列（上限側）
    maxArray: {
      type: Array,
      default: () => [],
    },
    // 入力不可フラグ
    disabled: {
      type: Boolean,
      default: false,
    },
    // 不正値の配列
    invalidArray: {
      type: Array,
      default: () => [],
    },
    // 必須入力フラグ
    required: {
      type: Boolean,
      default: false,
    },
    // ステップ
    step: {
      type: Number,
      required: true,
      default: 1,
    },
    // ループフラグ
    rollFlag: {
      type: Boolean,
      default: true,
    },
    // 入力値が空値の場合に、フォーカスアウトした後に表示される値
    emptyVal: {
      type: [Number, Object],
    },
    // コンポーネント外から渡すスタイル
    parentProvidedStyles: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      inputValue: this.modelValue !== undefined ? this.modelValue : this.value,
      // 初期値
      initValue: 0,
      // 初期表示値
      initDispValue: 0,
      // ユーザーが入力・操作を行ったかどうか
      userHasInteracted: false,
      // 編集後、入力値と初期値が異なる場合にtrue
      isEdited: false,
      // 必須未入力または不正値の場合にtrue
      isValid: false,
      // フォーカス中のみマウスホイール操作を有効にする
      openWheelFlg: false,
      // stepの小数桁数
      decimalPlaces: 0,
      arrayIndex: 0,
      // maxArrayとminArrayを統合したループ用配列
      newArray: [],
      // キーボードから入力する場合にtrue
      keyPress: false,
      // Vue3ではpropsを直接書き換えないため、正規化済み上下限を内部状態として保持する
      effectiveMin: this.min,
      effectiveMax: this.max,
      // 初期化中に親へupdateを返すと、Vue3のmount処理中に親側再描画が走るため抑止する。
      readyToEmitValue: false,
      // 親propsから内部値へ同期している間は、同じ値を親へ返さない。
      syncingFromParent: false,
      // 入力イベント中の親側再描画を避けるため、値通知は次tickにまとめる。
      pendingValueEmit: false,
      queuedEmitValue: undefined,
      // pat-viewer で編集判定に使う initVal の初期値（#10937）
      propInitVal: this.initVal,
      // フッター切替時の sessionStorage フラグ比較用（#10937）
      lastUsedFlag: null,
    };
  },
  computed: {
    getFontSize() {
      return this.$store?.getters?.["account-edit/getFontSize"] ?? 1;
    },
    forwardedAttrs() {
      // class/style は入力要素側で明示的に合成するため、attrsからは除外する。
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
    shouldUseLazyUpdate() {
      return Boolean(this.modelModifiers?.lazy || this.valueModifiers?.lazy);
    },
    inputClass() {
      return [
        this.$attrs.class,
        {
          // 編集後、入力値と初期値が異なる場合に適用されるclass
          "custom-input-number-edited": this.isEdited,
          // 必須入力に適用されるclass
          "custom-input-number-required": this.required,
          // データ不正時に適用されるclass
          "custom-input-number-invalid": this.isValid,
        },
      ];
    },
    inputStyle() {
      return [this.parentProvidedStyles, this.computedStyle, this.$attrs.style];
    },
    computedStyle() {
      // フォントサイズと最大値の桁数から、旧コンポーネントと同じ最小幅を算出する。
      return {
        minWidth: `${this.fontSizeToWidth(this.getFontSize) * this.effectiveMax.toString().length * 11}px`,
      };
    },
    getPressDwSwitchButton() {
      return this.$store?.getters?.["pat-viewer-treat-cond/getPressDwSwitchButton"] ?? false;
    },
  },
  created() {
    // 初期値を一時格納
    this.initValue = this.inputValue;
    // stepの小数点以下の桁数を取得
    this.decimalPlaces = BigNumber(this.step).decimalPlaces();

    // 初期値が空値の場合はBigNumberへ渡さず、空値のまま保持する。
    const normalizedInitValue = this.normalizeNumberInputValue(this.initValue);
    if (!this.isEmpty(normalizedInitValue) && this.canUseBigNumber(normalizedInitValue)) {
      // 初期値が補完精度の値と等しい場合は補完後の値を表示し、通常の数値はゼロサプレスして表示する。
      const initValueBigNumber = BigNumber(normalizedInitValue);
      const formattedValue = this.toFormatWithoutGroupSeparator(normalizedInitValue);
      const isEqual = initValueBigNumber.isEqualTo(BigNumber(formattedValue));

      this.inputValue = isEqual
        ? formattedValue
        : this.isNumber(normalizedInitValue)
          ? initValueBigNumber.toString()
          : normalizedInitValue;
    }

    // 初期表示値を設定する
    this.initDispValue = this.inputValue;
    if (this.initVal !== undefined) {
      this.initDispValue = this.canUseBigNumber(this.initVal)
        ? BigNumber(this.initVal)
        : (this.isEmpty(this.initVal) ? this.initVal : null);
      this.initValue = this.initVal;
      this.isEdited = this.isSameAsInitValue(this.inputValue) ? false : true;
    }
    // 2つの配列を新しい配列につなぎ合わせる。
    this.newArray = this.maxArray.concat(this.minArray);
    this.effectiveMin = BigNumber(this.min).isGreaterThan(this.max) ? this.max : this.min;
    this.effectiveMax = BigNumber(this.effectiveMin).isGreaterThan(this.max) ? this.effectiveMin : this.max;
  },
  mounted() {
    this.readyToEmitValue = true;
  },
  watch: {
    // 入力値を監視する
    inputValue: {
      handler(val) {
        this.isEdited = this.isSameAsInitValue(val) ? false : true;
        // 必須入力ボックスが空、または入力値が不正配列に含まれる場合は不正表示にする。
        this.isValid =
          (this.required && val === "") ||
          this.invalidArray.findIndex(item => item === this.inputValue) !== -1
            ? true
            : false;
        if (!this.readyToEmitValue || this.syncingFromParent) {
          return;
        }
        if (!this.shouldUseLazyUpdate) {
          this.queueValueEmit(val);
        }
      },
    },
    // 親コンポーネント側の自動計算などでmodelValueが変化した場合、内部値を同期する。
    modelValue: {
      handler(val) {
        if (val !== undefined && val !== this.inputValue) {
          this.syncInputValueFromParent(val);
        }
      },
    },
    // Vue2互換のvalue指定を使用している呼び出し元向けの同期処理
    value: {
      handler(val) {
        if (this.modelValue === undefined && val !== this.inputValue) {
          this.syncInputValueFromParent(val);
        }
      },
    },
    // 入力値とは別に指定された初期値を監視する。
    initVal: {
      handler(val) {
        if (this.isPatViewerRoute()) {
          if (val !== null && val !== undefined) {
            this.initValue = val;
            if (this.propInitVal) {
              this.isEdited = this.isSameValueAs(this.inputValue, this.propInitVal) ? false : true;
            }
          }
          const flag = sessionStorage.getItem("press_footer_flag");
          if (this.getPressDwSwitchButton === true || (flag && flag !== this.lastUsedFlag)) {
            this.lastUsedFlag = flag;
            this.isEdited = this.isSameValueAs(this.inputValue, val) ? false : true;
            this.setPressDwSwitchButton(false);
          }
          return;
        }
        if (val === undefined) {
          return;
        }
        this.initValue = val;
        this.isEdited = this.isSameAsInitValue(this.inputValue) ? false : true;
      },
      immediate: true,
    },
    // stepを監視する
    step: {
      handler(val) {
        this.decimalPlaces = BigNumber(val).decimalPlaces();
        const normalizedInputValue = this.normalizeNumberInputValue(this.inputValue);
        if (this.canUseBigNumber(normalizedInputValue)) {
          const formattedValue = this.toFormatWithoutGroupSeparator(normalizedInputValue);
          this.inputValue = BigNumber(normalizedInputValue).isEqualTo(
            BigNumber(formattedValue)
          )
            ? formattedValue
            : this.isNumber(normalizedInputValue)
              ? BigNumber(normalizedInputValue).toString()
              : normalizedInputValue;
        }
      },
    },
    min: {
      handler() {
        // Vue2版のようにpropsを直接変更しないため、内部上下限を再計算する。
        this.refreshEffectiveRange();
      },
    },
    max: {
      handler() {
        this.refreshEffectiveRange();
      },
    },
    minArray: {
      handler() {
        this.refreshEffectiveArray();
      },
    },
    maxArray: {
      handler() {
        this.refreshEffectiveArray();
      },
    },
  },
  methods: {
    /**
     * @description 必須入力チェック for 【装置設定】
     */
    checkRequired() {
      if (this.required && !this.inputValue) {
        return false;
      }
      return true;
    },
    refreshEffectiveRange() {
      this.effectiveMin = BigNumber(this.min).isGreaterThan(this.max) ? this.max : this.min;
      this.effectiveMax = BigNumber(this.effectiveMin).isGreaterThan(this.max)
        ? this.effectiveMin
        : this.max;
    },
    refreshEffectiveArray() {
      this.newArray = this.maxArray.concat(this.minArray);
    },
    normalizeNumberInputValue(value) {
      return typeof value === "string" ? value.split(NUMBER_GROUP_SEPARATOR).join("") : value;
    },
    formatNumberInputValue(value) {
      const normalizedValue = this.normalizeNumberInputValue(value);
      if (this.isEmpty(normalizedValue) || !this.canUseBigNumber(normalizedValue)) {
        return value;
      }
      const numberValue = BigNumber(normalizedValue);
      const formattedValue = this.toFormatWithoutGroupSeparator(normalizedValue);
      return numberValue.isEqualTo(BigNumber(formattedValue))
        ? formattedValue
        : this.isNumber(normalizedValue)
          ? numberValue.toString()
          : normalizedValue;
    },
    syncInputValueFromParent(val) {
      this.syncingFromParent = true;
      this.inputValue = this.formatNumberInputValue(val);
      this.$nextTick(() => {
        this.syncingFromParent = false;
      });
    },
    isControlledAttrListenerKey(key) {
      return ["onInput", "onFocus", "onBlur", "onChange", "onKeydown", "onWheel"].includes(key);
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
    queueAttrListener(key, event) {
      const listener = this.$attrs[key];
      if (!listener) {
        return;
      }
      this.$nextTick(() => {
        this.callAttrListener(key, event);
      });
    },
    queueValueEmit(val) {
      this.queuedEmitValue = val;
      if (this.pendingValueEmit) {
        return;
      }
      this.pendingValueEmit = true;
      this.$nextTick(() => {
        this.pendingValueEmit = false;
        this.emitValue(this.queuedEmitValue);
      });
    },
    emitValue(val) {
      this.$emit("handlerInput", val);
      // Vue3標準v-modelと、旧value連携の両方へ変更を通知する。
      this.$emit("update:modelValue", val);
      this.$emit("update:value", val);
    },
    commitValueChange() {
      if (!this.readyToEmitValue || this.syncingFromParent) {
        return;
      }
      this.queueValueEmit(this.inputValue);
    },
    // フォントサイズ設定を幅計算用の係数に変換する。
    fontSizeToWidth(size) {
      let chartWidth = "";
      switch (size) {
        case 0:
          chartWidth = "0.8";
          break;
        case 1:
          chartWidth = "1";
          break;
        case 2:
          chartWidth = "1.1";
          break;
        case 3:
          chartWidth = "1.3";
          break;
        default:
          break;
      }
      return chartWidth;
    },
    // フォーカス
    onFocus(e) {
      // フォーカス後はスクロールイベントを有効にする。
      this.openWheelFlg = true;
      this.callAttrListener("onFocus", e);
    },
    handleFocus() {
      setTimeout(() => {
        // Vue3版はnative inputを使うが、v-ons-input互換を考慮して$elも見る。
        const input = this.$refs.input?.$el || this.$refs.input;
        input?.focus();
      }, 0);
    },
    // フォーカスアウト
    onBlur(e) {
      // フォーカスアウトする時にスクロールイベントを閉める。
      this.openWheelFlg = false;
      if (!this.userHasInteracted && !this.fixedDecimalValue(e.target.value)) {
        // ユーザーがインタラクションをしない場合、初期表示値を表示
        this.inputValue = this.initDispValue;
      } else if (this.isEmpty(e.target.value)) {
        // ユーザーがインタラクションをした状態で空値の場合、emptyValの指定に従って補完する。
        if (this.emptyVal === null) {
          // emptyValがnullの場合に、そのままを返却
          this.inputValue = this.emptyVal;
        } else if (this.emptyVal && this.emptyVal !== null) {
          // emptyValがnull以外の場合に、補足精度
          this.inputValue = this.fixedDecimal(this.emptyVal);
        } else {
          // それ以外の場合に、e.target.valueを返却
          this.inputValue = e.target.value;
        }
      } else {
        this.handlerKeyInputValue(e.target.value);
      }
      this.isValid =
        (this.required && this.inputValue === "") ||
        this.invalidArray.findIndex(item => item === this.inputValue) !== -1
          ? true
          : false;
      if (this.shouldUseLazyUpdate) {
        this.commitValueChange();
      }
      this.callAttrListener("onBlur", e);
    },
    isEmpty(value) {
      return value === "" || value === null || value === undefined;
    },
    canUseBigNumber(value) {
      if (this.isEmpty(value)) {
        return false;
      }
      try {
        return BigNumber(this.normalizeNumberInputValue(value)).isFinite();
      } catch (e) {
        return false;
      }
    },
    isPatViewerRoute() {
      return this.$route?.name === "pat-viewer";
    },
    getCompareInitValue() {
      if (this.propInitVal !== undefined && this.isPatViewerRoute()) {
        return this.propInitVal;
      }
      return this.initValue;
    },
    isSameValueAs(val, compareValue) {
      if (val === compareValue) {
        return true;
      }
      if (!this.canUseBigNumber(val) || !this.canUseBigNumber(compareValue)) {
        return false;
      }
      return BigNumber(this.normalizeNumberInputValue(val)).eq(
        BigNumber(this.normalizeNumberInputValue(compareValue))
      );
    },
    isSameAsInitValue(val) {
      return this.isSameValueAs(val, this.getCompareInitValue());
    },
    setPressDwSwitchButton(value) {
      this.$store?.commit?.("pat-viewer-treat-cond/setPressDwSwitchButton", value);
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
    // 空値の処理
    fixedIsNaN(val) {
      return val == "" || isNaN(val) || val === null ? this.fixedDecimal(0) : val;
    },
    // 補足精度：（切り捨て）
    fixedDecimal(val) {
      return toFixed(val, BigNumber(this.step).decimalPlaces());
    },
    // native number input が受け取れるよう、BigNumberの区切りなし書式で表示値を作る。
    toFormatWithoutGroupSeparator(val, decimalPlaces = this.decimalPlaces) {
      return BigNumber(this.normalizeNumberInputValue(val))
        .toFormat(decimalPlaces, NUMBER_INPUT_FORMAT);
    },
    /**
     * 精度を加算した値がvalと等しい場合、加算した値を使う。（例えば1.3->1.30）
     */
    fixedDecimalValue(val) {
      if (!this.canUseBigNumber(val)) {
        return val;
      }
      const normalizedValue = this.normalizeNumberInputValue(val);
      const formattedValue = this.toFormatWithoutGroupSeparator(normalizedValue);
      return BigNumber(normalizedValue).isEqualTo(BigNumber(formattedValue))
        ? formattedValue
        : normalizedValue;
    },
    // 初期値と比較
    comparedToInitValue(oldVal, newVal) {
      if (
        !this.canUseBigNumber(oldVal) ||
        !this.canUseBigNumber(newVal) ||
        !this.canUseBigNumber(this.initValue)
      ) {
        return false;
      }
      const normalizedOldVal = this.normalizeNumberInputValue(oldVal);
      const normalizedNewVal = this.normalizeNumberInputValue(newVal);
      const normalizedInitValue = this.normalizeNumberInputValue(this.initValue);
      // newValが初期値をまたいだ場合にtrueを返す。
      return (
        (BigNumber(normalizedNewVal).isGreaterThan(normalizedInitValue) &&
          BigNumber(normalizedOldVal).isLessThan(normalizedInitValue)) ||
        (BigNumber(normalizedNewVal).isLessThan(normalizedInitValue) &&
          BigNumber(normalizedOldVal).isGreaterThan(normalizedInitValue))
      );
    },
    /**
     * インプットイベント
     */
    onInput(e) {
      // 入力イベントがトリガーされた場合、ユーザーがインタラクションを行ったことを証明する。
      this.userHasInteracted = true;
      // 親の@inputはVue3のattrs fallthroughによりnative inputへ直接渡す。

      if (
        this.newArray.length !== 0 &&
        this.newArray.findIndex(item => item == this.fixedIsNaN(this.inputValue)) !== -1
      ) {
        this.arrayIndex = this.newArray.findIndex(item => item == this.inputValue);
      }

      // e.inputTypeを使って、入力方式を判断できる。
      // e.inputTypeなし: ブラウザの数値入力スピナー等 / insertText: キーボード入力 / insertFromPaste: 貼り付け
      if (!e.inputType) {
        if (!this.canUseBigNumber(e.target.value)) {
          this.inputValue = e.target.value;
          this.queueAttrListener("onInput", e);
          return;
        }
        const computedStep = minusDecimal(
          BigNumber(e.target.value),
          BigNumber(this.fixedIsNaN(this.inputValue))
        );
        computedStep < 0
          ? this.decrementInputValue(this.inputValue, e.target.value, this.step)
          : this.incrementInputValue(this.inputValue, e.target.value, this.step);
      } else {
        // キーボード入力ではない場合、stepの精度と一致する値を補完する。
        this.inputValue = !this.keyPress ? this.fixedDecimalValue(e.target.value) : e.target.value;
        if (
          this.newArray.length !== 0 &&
          this.canUseBigNumber(this.inputValue) &&
          BigNumber(this.inputValue).eq(this.effectiveMin)
        ) {
          this.arrayIndex = this.newArray.length;
        } else if (
          this.newArray.length !== 0 &&
          this.canUseBigNumber(this.inputValue) &&
          BigNumber(this.inputValue).eq(this.effectiveMax)
        ) {
          this.arrayIndex = -1;
        }
      }
      this.queueAttrListener("onInput", e);
    },
    // エンターとフォーカスアウトの共通処理
    handlerKeyInputValue(val) {
      if (this.newArray.findIndex(item => item === val) !== -1) {
        this.inputValue = val;
      } else if (!this.canUseBigNumber(val)) {
        this.inputValue = val;
      } else if (
        this.canUseBigNumber(this.initValue) &&
        BigNumber(val).eq(BigNumber(this.normalizeNumberInputValue(this.initValue)))
      ) {
        // 入力値と初期値が物理的に同等（例: 0 = 0.00）の場合、初期表示値との整合を保つ。
        const normalizedInitValue = this.normalizeNumberInputValue(this.initValue);
        const initFormattedValue = this.toFormatWithoutGroupSeparator(normalizedInitValue);
        this.inputValue = this.canUseBigNumber(normalizedInitValue) &&
          BigNumber(normalizedInitValue).isEqualTo(BigNumber(initFormattedValue))
          ? initFormattedValue
          : this.initDispValue;
      } else if (BigNumber(val).comparedTo(this.effectiveMax) === 1) {
        // 入力値がmaxより大きな場合に、maxを表示する。
        this.inputValue = this.fixedDecimal(this.effectiveMax);
      } else if (BigNumber(val).comparedTo(this.effectiveMin) === -1) {
        // 入力値がminより小さい場合に、minを表示する。
        this.inputValue = this.fixedDecimal(this.effectiveMin);
      } else {
        // その他の場合は指定stepの小数桁に補正する。
        this.inputValue = this.fixedDecimal(val);
      }
    },
    // キーボードのエンターを押したとき
    onKeydownEnter(e) {
      this.handlerKeyInputValue(e.target.value);
      if (this.shouldUseLazyUpdate) {
        this.commitValueChange();
      }
    },
    onKeydown(e) {
      this.keyPress = true;
      this.callAttrListener("onKeydown", e);
    },
    onChange(e) {
      if (this.shouldUseLazyUpdate) {
        this.commitValueChange();
      }
      this.callAttrListener("onChange", e);
    },
    // マウスホイール
    onInputWheel(e) {
      if (!this.openWheelFlg) {
        return;
      }
      const targetValue = e.target.value;
      if (e.deltaY > 0) {
        // マウスホイールアップ
        const newVal = this.canUseBigNumber(targetValue)
          ? minusDecimal(targetValue, this.step)
          : targetValue;
        this.decrementInputValue(this.inputValue, newVal, this.step);
      } else if (e.deltaY < 0) {
        // マウスホイールダウン
        const newVal = this.canUseBigNumber(targetValue)
          ? plusDecimal(targetValue, this.step)
          : targetValue;
        this.incrementInputValue(this.inputValue, newVal, this.step);
      }
      this.callAttrListener("onWheel", e);
    },
    /**
     * マウスホイールアップイベント
     * @param {*} value 古い値
     * @param {*} newVal 新しい値
     * @param {*} step ステップ
     */
    incrementInputValue(value, newVal, step) {
      // 入力値が空値の場合に、arrayIndexを-1に設定する。
      if (value == "" || isNaN(value) || value === null) {
        this.arrayIndex = -1;
        // 空値や不正値の場合は min + step を設定
        this.inputValue = this.fixedDecimal(this.effectiveMin + step);
        return;
      }
      if (
        this.rollFlag &&
        (BigNumber(value).eq(this.effectiveMax) ||
          BigNumber(value).comparedTo(this.effectiveMax) === 1 ||
          BigNumber(value).comparedTo(this.effectiveMin) === -1)
      ) {
        // ループ
        this.rollUp("up");
      } else {
        this.arrayIndex = -1;
        this.inputValue = this.comparedToInitValue(value, newVal)
          ? this.initDispValue
          : this.fixedDecimal(Math.min(plusDecimal(parseFloat(value), step), this.effectiveMax));
      }
    },
    /**
     * マウスホイールダウンイベント
     * @param {*} value  古い値
     * @param {*} newVal 新しい値
     * @param {*} step   ステップ
     */
    decrementInputValue(value, newVal, step) {
      if (value == "" || isNaN(value) || value === null) {
        this.arrayIndex = this.newArray.length;
        // 空値や不正値の場合は min を設定
        this.inputValue = this.fixedDecimal(this.effectiveMin);
        return;
      }
      if (
        this.rollFlag &&
        (BigNumber(value).eq(this.effectiveMin) ||
          BigNumber(value).comparedTo(this.effectiveMin) === -1 ||
          BigNumber(value).comparedTo(this.effectiveMax) === 1)
      ) {
        this.rollUp("down");
      } else {
        this.arrayIndex = this.newArray.length;
        // 通常の計算値：古い値とステップを減算した計算値と最小値の間に最大値を取得する。
        const normalValue = Math.max(minusDecimal(value, step), this.effectiveMin);
        // 補足精度後の計算値
        const fixedDecimalValue = this.fixedDecimal(
          Math.max(minusDecimal(value, step), this.effectiveMin)
        );
        this.inputValue = this.comparedToInitValue(value, newVal)
          ? this.initDispValue
          : BigNumber(normalValue).isGreaterThan(BigNumber(fixedDecimalValue))
            ? this.fixedDecimal(plusDecimal(fixedDecimalValue, step))
            : fixedDecimalValue;
      }
    },
    /**
     * ループ処理
     * @param {*} upOrDown up:ループアップ;down:ループダウン
     */
    rollUp(upOrDown) {
      // newArrayがない場合に、up：最小値を表示する。down:最大値を表示する。
      if (this.newArray.length == 0) {
        this.inputValue =
          upOrDown === "up"
            ? this.fixedDecimal(this.effectiveMin)
            : this.fixedDecimal(this.effectiveMax);
      } else {
        // newArrayがある場合に、up：arrayIndexを1ずつ増やす。down：arrayIndexを1ずつ減らす。
        this.arrayIndex =
          upOrDown === "up" ? plusDecimal(this.arrayIndex, 1) : minusDecimal(this.arrayIndex, 1);
        if (this.arrayIndex < 0) {
          this.inputValue = this.effectiveMax;
          this.arrayIndex = 0;
        } else if (this.arrayIndex >= this.newArray.length) {
          this.inputValue = this.effectiveMin;
          this.arrayIndex = this.newArray.length - 1;
        } else {
          this.inputValue = this.newArray[this.arrayIndex];
        }
      }
    },
  },
};
</script>

<style scoped>
.custom-common-number-input-pro :deep(input.text-input) {
  color: black;
  -webkit-text-fill-color: black;
  text-align: right !important;
  min-width: 50px;
}

.custom-common-number-input-pro.ntss-custom-input-cond:not(.custom-input-number-required):not(.custom-input-number-invalid) :deep(input.text-input:not(:disabled)) {
  background-color: #F7F7F7 !important;
}

.custom-common-number-input-pro :deep(input.text-input:focus) {
  border: 2px solid green !important;
  outline: 0;
}

.custom-input-number-edited :deep(input.text-input) {
  border: 2px green solid;
  outline: 0;
}

.custom-input-number-required :deep(input.text-input) {
  color: black;
  -webkit-text-fill-color: black;
  background-color: #ffff99 !important;
}

.custom-input-number-invalid :deep(input.text-input) {
  color: black;
  -webkit-text-fill-color: black;
  background-color: rgba(255, 0, 0, 0.5) !important;
}
</style>
