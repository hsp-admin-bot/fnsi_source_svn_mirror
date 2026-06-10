<template>
  <v-ons-input
    ref="input"
    class="custom-common-number-input-pro"
    :class="classObject"
    type="number"
    :step="step"
    :style="[parentProvidedStyles,computedStyle]"
    v-model.trim.lazy="inputValue"
    :disabled="disabled"
    :required="required"
    @focus="onFocus"
    @wheel.prevent="onInputWheel"
    @blur="onBlur"
    @input="onInput"
    @keydown.enter.prevent="onKeydownEnter"
    @keydown="keyPress = true"
    v-on="$listeners"
    >
  </v-ons-input>
</template>

<script>
import { mapGetters } from "vuex";
import BigNumber from "bignumber.js";
import {
  removeTrailingZeros,
  isDecimal,
  plusDecimal,
  minusDecimal,
  toFixed,
} from "@/functions/common/NumberFunctions";
import { isEmpty } from "lodash";
/**
 * @description 共通数値入力コンポーネント
 * @summary
 * ■機能
 *     ・上下限値設定
 *     ・小数点桁数設定
 *     ・不正値入力制限
 *     ・上下キー、マウスホイールによる値の増減
 *     ・最大値/最小値へ到達後のループON/OFF
 */
export default {
  name: "CustomInputNumberPro",
  props: {
    // 入力値
    value: {
    },
    // 初期値(入力値とは別に初期表示時点で新たに初期値の指定が必要な場合に使用)
    initVal:{
    },
    //入力下限
    min: {
      type: Number,
      default: -999999999999999999,
    },
    //入力可能上限値を指定する
    minArray: {
      type: Array,
      default: () => [],
    },
    //入力上限
    max: {
      type: Number,
      default: 999999999999999999,
    },
    //入力可能下限値を指定する
    maxArray: {
      type: Array,
      default: () => [],
    },
    //入力不可フラグ
    disabled: {
      type: Boolean,
      default: false,
    },
    //不正値の配列
    invalidArray: {
      type: Array,
      default: () => [],
    },
    //必須入力フラグ
    required: {
      type: Boolean,
      default: false,
    },
    //ステップ
    step: {
      type: Number,
      required: true,
      default: 1,
    },
    //ループフラグ
    rollFlag: {
      type: Boolean,
      default: true,
    },
    //入力値が空値の場合に、フォーカスアウトした後に表示される値
    emptyVal: {
      type:[Number,Object]
    },
    //コンポネントから渡すスタイル
    parentProvidedStyles: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      inputValue: this.value,
      initValue: 0, //初期値
      initDispValue: 0, //初期表示値
      userHasInteracted: false, //ユーザーがインタラクションかどうかのフラグ
      isEdited: false, //編集後、入力値と初期値が異なる場合にtrue
      isValid: false, //空の文字列：true
      openWheelFlg: false, //フォーカスフラグ
      decimalPlaces: 0, //stepの小数桁数
      arrayIndex: 0,
      newArray: [], //maxArrayとminArrayを統合する
      keyPress: false,//キーボードから入力する場合にtrue
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getFontSize"]),
    //ダイナミックスタイル
    computedStyle(){
      return {
        minWidth:`${this.fontSizeToWidth(this.getFontSize) * this.max.toString().length * 11}px`,
      }
    },
    classObject() {
      return {
        // 編集後、入力値と初期値が異なる場合に適用されるclass
        "custom-input-number-edited": this.isEdited,
        // 必須入力に適用されるclass
        "custom-input-number-required": this.required,
        //データ不正時に適用されるclass
        "custom-input-number-invalid": this.isValid,
      };
    },
  },
  methods: {
    //add #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 start
    /**
     * @description 必須入力チェック for 【装置設定】
     */
    checkRequired(){
      if (this.required && !this.inputValue) {
        return false
      } else {
        return true
      }
    },
    //add #11120 I-HDF設定内の破棄確認メッセージ不正 張玲 end
    fontSizeToWidth(size){
      let chartWidth = ''
      switch (size) {
        case 0:
          chartWidth = '0.8';
          break;
        case 1:
          chartWidth = '1';
          break;
        case 2:
          chartWidth = '1.1';
          break;
        case 3:
          chartWidth = '1.3';
          break;
        default:
          break;
      }
      return chartWidth;
    },
    //フォーカス
    onFocus() {
      //フォーカス後はスクロールイベントを有効になる
      this.openWheelFlg = true;
    },
    handleFocus() {
      setTimeout(() => {
        this.$refs.input.$el.focus();
      }, 0);
    },
    //フォーカスアウト
    onBlur(e) {
      //フォーカスアウトする時にスクロールイベントを閉める
      this.openWheelFlg = false;
      if (!this.userHasInteracted && !this.fixedDecimalValue(e.target.value)) {
        //ユーザーがインタラクションをしない場合、初期表示値を表示
        this.inputValue = this.initDispValue;
      } else if (isEmpty(e.target.value)) {
        //ユーザーがインタラクションをしたと空値の場合
        if(this.emptyVal === null){
          //emptyValがnullの場合に、そのままを返却
          this.inputValue = this.emptyVal;
        } else if(this.emptyVal && this.emptyVal !== null){
          //emptyValがnullの以外の場合に、補足精度
          this.inputValue = this.fixedDecimal(this.emptyVal)
        } else {
          //その以外の場合に、e.target.valueを返却
          this.inputValue = e.target.value
        }
      } else {
        this.handlerKeyInputValue(e.target.value);
      }
      this.isValid = ((this.required && this.inputValue === "") || (this.invalidArray.findIndex(item => item === this.inputValue) !== -1)) ? true : false;
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
      var pattern = /^[-]?([1-9]\d*|0)(\.\d+)?$/;
      // 数値チェック
      return pattern.test(numVal);
    },
    //空値の処理
    fixedIsNaN(val) {
      return val == "" || isNaN(val) || val === null ? this.fixedDecimal(0) : val;
    },
    //補足精度：（切り捨て）
    fixedDecimal(val) {
      return toFixed(val, BigNumber(this.step).decimalPlaces());
    },
    /**
     * 精度を加算した値がvalと等しい場合、加算した値を使う。（例えば1.3->1.30）
     */
    fixedDecimalValue(val) {
      return BigNumber(val).isEqualTo(BigNumber(val).toFormat(this.decimalPlaces)) ? BigNumber(val).toFormat(this.decimalPlaces) : val;
    },
    //初期値と比較
    comparedToInitValue(oldVal, newVal) {
      //newValが初期値より大きく且oldValが初期値より小さい場合、またはnewValが初期値より小さく且oldValが初期値より大きい場合にtrueを返す。
      return (BigNumber(newVal).isGreaterThan(this.initValue) && BigNumber(oldVal).isLessThan(this.initValue))
        || (BigNumber(newVal).isLessThan(this.initValue) && BigNumber(oldVal).isGreaterThan(this.initValue))
    },
    /**
     * インプットイベント
     */
    onInput(e) {
      //入力イベントがトリガーされた場合、ユーザーがインタラクションを行ったことを証明する。
      this.userHasInteracted = true;
      if (
        this.newArray.length !== 0 &&
        this.newArray.findIndex((item) => item == this.fixedIsNaN(this.inputValue)) !== -1
      ) {
        this.arrayIndex = this.newArray.findIndex((item) => item == this.inputValue);
      }
      //e.inputTypeを使って、入力方式を判断できる
      //e.inputType = insertText:キーボードから入力；e.inputType = insertFromPaste：テキストの貼り付ける
      if (!e.inputType) {
        let computedStep = minusDecimal(
          BigNumber(e.target.value),
          BigNumber(this.fixedIsNaN(this.inputValue))
        );
        computedStep < 0
          ? this.decrementInputValue(this.inputValue, e.target.value, this.step)
          : this.incrementInputValue(this.inputValue, e.target.value, this.step);
      } else {
        //入力ボックスの値がキーボードから入力されたものではなく、上下の矢印をクリックして変更されたもので、その値がステップの精度と一致しない場合、補足精度する。
        this.inputValue = !this.keyPress ? this.fixedDecimalValue(e.target.value) : e.target.value
        if (this.newArray.length !== 0 && BigNumber(this.inputValue).eq(this.min)) {
          this.arrayIndex = this.newArray.length;
        } else if (this.newArray.length !== 0 && BigNumber(this.inputValue).eq(this.max)) {
          this.arrayIndex = -1;
        }
      }
    },
    //エンターとフォーカスアウトの共通処理
    handlerKeyInputValue(val) {
      if (this.newArray.findIndex((item) => item === val) !== -1) {
        this.inputValue = val;
      } else if (BigNumber(val).eq(BigNumber(this.initValue))) {
        //入力値と初期値が同じ場合に（物理的に同等：たとえば0=0.00）、入力値を表示する、一致しない場合に、初期表示値を表示。
        this.inputValue = BigNumber(this.initValue).isEqualTo(BigNumber(this.initValue).toFormat(this.decimalPlaces))
          ? BigNumber(this.initValue).toFormat(this.decimalPlaces)
          : this.initDispValue;
      } else if (BigNumber(val).comparedTo(this.max) === 1) {
        //入力値がmaxより大きな場合に、maxを表示する。
        this.inputValue = this.fixedDecimal(this.max);
      } else if (BigNumber(val).comparedTo(this.min) === -1) {
        //入力値がminより小さい場合に、maを表示する。
        this.inputValue = this.fixedDecimal(this.min);
      } else {
        //他の場合
        this.inputValue = this.fixedDecimal(val);
      }
    },
    //キーボードのエンターを押したとき
    onKeydownEnter(e) {
        this.handlerKeyInputValue(e.target.value);
    },
    //マウスホイール
    onInputWheel(e) {
      if (!this.openWheelFlg) {
        return;
      }
      if (e.deltaY > 0) {
        //マウスホイールアップ
        this.decrementInputValue(this.inputValue, minusDecimal(e.target.value, this.step), this.step);
      } else if (e.deltaY < 0) {
        //マウスホイールダウン
        this.incrementInputValue(this.inputValue, plusDecimal(e.target.value, this.step), this.step);
      }
    },
    /**
     * マウスホイールアップイベント
     * @param {*} value 古い値
     * @param {*} newVal 新しい値
     * @param {*} step ステップ
     */
    incrementInputValue(value, newVal, step) {
      //入力値が空値の場合に、arrayIndexを-1に設定する
      if (value == "" || isNaN(value) || value === null) {
        this.arrayIndex = -1;
        // 空値や不正値の場合は min + step を設定
        this.inputValue = this.fixedDecimal(this.min + step);
        return;
      }
      if (
        this.rollFlag &&
        (BigNumber(value).eq(this.max) ||
          BigNumber(value).comparedTo(this.max) === 1 ||
          BigNumber(value).comparedTo(this.min) === -1)
      ) {
        //ループ
        this.rollUp("up");
      } else {
        this.arrayIndex = -1;
        this.inputValue = this.comparedToInitValue(value, newVal)
          ? this.initDispValue
          : this.fixedDecimal(Math.min(plusDecimal(parseFloat(value), step), this.max));
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
        this.inputValue = this.fixedDecimal(this.min);
        return;
      }
      if (
        this.rollFlag &&
        (BigNumber(value).eq(this.min) ||
          BigNumber(value).comparedTo(this.min) === -1 ||
          BigNumber(value).comparedTo(this.max) === 1)
      ) {
        this.rollUp("down");
      } else {
        this.arrayIndex = this.newArray.length;
        //通常の計算値：古い値とステップを増やした計算値と最小値の間に最大値を取得する。
        let normalValue = Math.max(minusDecimal(value, step), this.min);
        //補足精度後の計算値
        let fixedDecimalValue = this.fixedDecimal(Math.max(minusDecimal(value, step), this.min));
        //薬剤切替操作：変更前薬剤の小数位が変更後の小数位よりも多い場合に、
        this.inputValue = this.comparedToInitValue(value, newVal) ? this.initDispValue :
          BigNumber(normalValue).isGreaterThan(BigNumber(fixedDecimalValue))
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
            ? this.fixedDecimal(this.min)
            : this.fixedDecimal(this.max);
      } else {
        // newArrayがある場合に、up：arrayIndexが1ずつを増やす。down:arrayIndexが1ずつを減らす
        this.arrayIndex =
          upOrDown === "up"
            ? plusDecimal(this.arrayIndex, 1)
            : minusDecimal(this.arrayIndex, 1);
        if (this.arrayIndex < 0) {
          this.inputValue = this.max;
          this.arrayIndex = 0;
        } else if (this.arrayIndex >= this.newArray.length) {
          this.inputValue = this.min;
          this.arrayIndex = this.newArray.length - 1;
        } else {
          this.inputValue = this.newArray[this.arrayIndex];
        }
      }
    },
  },

  created() {
    this.initValue = this.inputValue;//初期値を一時格納
    this.decimalPlaces = BigNumber(this.step).decimalPlaces(); //stepの小数点以下の桁数を取得
    //初期値が補完精度の値と等しい場合は、初期化時に補完精度の値が表示される、数字の場合に、初期値（ゼロをサプレス）を表示される。
    // this.inputValue = BigNumber(this.initValue).isEqualTo(BigNumber(this.initValue).toFormat(this.decimalPlaces)) ? BigNumber(this.initValue).toFormat(this.decimalPlaces) : this.isNumber(this.initValue) ? BigNumber(this.initValue).toString() : this.initValue
    const initValueBigNumber = BigNumber(this.initValue);
    const formattedValue = initValueBigNumber.toFormat(this.decimalPlaces).replace(/,/g, '');
    const isEqual = initValueBigNumber.isEqualTo(BigNumber(formattedValue));
    this.inputValue = isEqual
      ? formattedValue
      : this.isNumber(this.initValue)
      ? initValueBigNumber.toString()
      : this.initValue;
    //初期表示値を設定する
    this.initDispValue = this.inputValue;
    // 明示的に外から別の初期値を与えられている場合は初期値上書き(コンポーネント再作成等で一番最初の初期値が維持されない事象を防ぐ)
    if ('initVal' in this.$options.propsData) {
      this.initDispValue = this.initVal != null ? BigNumber(this.initValue) : null
      this.initValue = this.initVal;
      // 変更判定(初期表示時点で差異が出ている場合に変更扱いにする)
      this.isEdited = (this.initValue === this.inputValue) || BigNumber(this.initValue).eq(BigNumber(this.inputValue)) ? false : true;
    }
    //2つの配列を新しい配列につなぎ合わせ、最大値を超える配列の要素を最初にする。
    this.newArray = this.maxArray.concat(this.minArray);
    this.min = BigNumber(this.min).isGreaterThan(this.max) ? this.max : this.min;
    this.max = BigNumber(this.min).isGreaterThan(this.max) ? this.min : this.max;
  },
  mounted() {
  },
  watch: {
    //外部から明示的に指定した初期値を監視する
    initVal:{
      handler(val){
        //initValの値が変化したら、initValueを更新する。
        this.initValue = val;
        this.isEdited = (val === this.inputValue) || BigNumber(val).eq(BigNumber(this.inputValue)) ? false : true;
      }
    },
    //入力値を監視する
    inputValue: {
      handler(val) {
        this.isEdited = (val === this.initValue) || BigNumber(val).eq(BigNumber(this.initValue)) ? false : true;
        //不正値に赤い背景色を表示する。
        //必須入力ボックスに入力された値が空であるか、または入力された値が不正な配列である場合、赤色が表示される。
        this.isValid = ((this.required && val === "") || (this.invalidArray.findIndex(item => item === this.inputValue) !== -1)) ? true : false;
        this.$emit("handlerInput", val);
      },
    },
    //自動計算のたあ
    value:{
      handler(val){
        //valueの値が変化したら、inputValueを更新する。
        this.inputValue = val;
      }
    },
    //stepを監視する
    step:{
      handler(val,old){
        this.decimalPlaces = BigNumber(val).decimalPlaces();
        this.inputValue = BigNumber(this.inputValue).isEqualTo(BigNumber(this.inputValue).toFormat(this.decimalPlaces)) ? BigNumber(this.inputValue).toFormat(this.decimalPlaces) : this.isNumber(this.inputValue) ? BigNumber(this.inputValue).toString() : this.inputValue;
      }
    }
  },
};
</script>
<style scoped>
input {
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);

}

.custom-common-number-input-pro>>>input {
  text-align: right;
  min-width: 50px;
}

.custom-input-number-edited>>>input {
  border: 2px green solid;
  outline: 0;
}

.custom-input-number-required>>>input {
  color: black;
  background-color: #ffff99 !important;
}

.custom-input-number-invalid>>>input {
  color: black;
  background-color: rgba(255, 0, 0, 0.5) !important;
}
</style>
