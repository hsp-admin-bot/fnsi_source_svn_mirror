/**
 * 数値入力共通コンポーネント
 */
<template>
  <v-ons-row>
    <v-ons-col class="title" v-if="titileVisible">
      <label class="theme">
        {{labelName}}
      </label>
    </v-ons-col>
    <v-ons-col class="num-value">
      <label v-if="subLabelName" class="sub-title theme">
        {{subLabelName}}
      </label>
      <!-- add FNSI-borderの追加 徐 start -->
      <!-- <v-ons-input
        type="text"
        model-event="change"
        v-model.number="currentValue"
        :disabled="disabled"
        @blur="onBlur"
        @keypress="onKeyPress"
        @keydown="onKeyDown"
      /> -->
      <!-- mod #5589 2023/03/29 数値IFのスタイル全不正 張博 start -->
      <!-- <v-ons-input
        type="text"
        model-event="change"
        v-model.number="currentValue"
        :disabled="disabled"
        :style="{ 'min-width': inputMinWidth}"
        @blur="onBlur"
        @blur.prevent="delFocusCss($event)"
        @keypress="onKeyPress"
        @keydown="onKeyDown"
        @focus="addFocusCss($event)" /> -->
      <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start -->
      <!-- <v-ons-input
        ref="mySelect"
        :type="inputType"
        model-event="change"
        v-model.number="currentValue"
        :disabled="disabled"
        :step="step"
        :style="{ 'min-width': inputMinWidth, textAlign: inputTextAlign }"
        @blur="onBlur"
        @blur.prevent="delFocusCss()"
        @keypress="onKeyPress"
        @keydown="onKeyDown"
        @focus="addFocusCss($event)"
        @change="inputNumber($event)"
        @mousewheel.prevent="handleMouseWheel($event)"
         />   -->
      <!-- #10628 数値IF修正 linjunfeng start -->
      <!-- <v-ons-input
        ref="mySelect"
        :type="inputType"
        model-event="change"
        v-model.number="currentValue"
        :disabled="disabled"
        :step="step"
        :style="{ 'min-width': inputMinWidth, textAlign: inputTextAlign }"
        :class="{'common-number-input-edited' : isEdited ? true : false}"
        @blur="onBlur"
        @blur.prevent="delFocusCss"
        @keypress="onKeyPress"
        @keydown="onKeyDown"
        @focus="addFocusCss($event)"
        @change="inputNumber($event)"
        @mousewheel.prevent="handleMouseWheel($event)"
         /> -->
      <!-- mod #10628 コンソールエラーを修正 Ji start -->
      <!-- <custom-input-number-pro
        :key="componentsKey"
        class="custom-input-number"
        ref="mySelect"
        :emptyVal="null"
        :style="{ 'min-width': inputMinWidth, textAlign: inputTextAlign }"
        :value="currentValuePro"
        :max="currentMax"
        :min="currentMin"
        :step="step"
        :disabled="disabled"
        @handlerInput="handlerInput"
        @blur="handlerInputBlur"
        v-on="$listeners"
      /> -->
      <custom-input-number-pro
        :key="componentsKey"
        class="custom-input-number"
        ref="mySelect"
        :emptyVal="null"
        :style="{ 'min-width': inputMinWidth, textAlign: inputTextAlign }"
        :value="currentValuePro"
        :max="currentMax"
        :min="currentMin"
        :step="step"
        :disabled="disabled"
        @handlerInput="handlerInput"
        @blur="handlerInputBlur"
      />
      <!-- mod #10628 コンソールエラーを修正 Ji end -->
      <!-- #10628 数値IF修正 linjunfeng end -->
      <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end -->
      <!-- mod #5589 2023/03/29 数値IFのスタイル全不正 張博 end -->
      <!-- add FNSI-borderの追加 徐 end -->
      <label class="theme" style="margin-left: 0.5em;">{{unitName}}</label>
     <!-- mod FNSI修正 bug #4164 対応 陳 start -->
     <!--<v-ons-col v-if="commandButton !== null">-->
      <div class="num-value" style="margin-left: 0.5em;" v-if="commandButton !== null">
    <!-- mod FNSI修正  bug #4164 対応 陳 end -->

      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
        <button
          :disabled="buttonDisabled"
          :data-non-authorize="nonAuthorize"
          class="button select-btn btn3-normal"
          @click="commandButton.onClick">{{ commandButton.name }}</button>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
      </div>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
import NumberInputMixin from "@/components/treatment-record/submenu/common/NumberInputMixin";
import { EventBus } from "@/compat/vue/event-bus.js";
// add #10628 数値IF修正 linjunfeng start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
import BigNumber from "@/compat/number/bignumber";
// add #10628 数値IF修正 linjunfeng end

export default {
  mixins: [NumberInputMixin],
  // add #10628 数値IF修正 linjunfeng start
  components: {
    "custom-input-number-pro": CustomInputNumberPro
  },
  // add #10628 数値IF修正 linjunfeng end
  emits: ["update:modelValue", "input", "blur", "getChildData"],
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
    modelValue: {},
    disabled: {
      type: Boolean,
      default: false
    },
    commandButton: {
      type: Object,
      default: null
    },
    buttonDisabled: {
      type: Object,
      default: null
    },
    nonAuthorize: {
      type: Boolean,
      default: false
    },
    initialValueLock:{
      type:Boolean,
      default: false
    },
    initValue: {
      type: [String, Number]
    },
    isEmpty: {
      type: Boolean,
      default: false
    },
    inputMinWidth: {
      type: String,
      default: ""
    },
    titileVisible: {
      type: Boolean,
      default: true
    },
    // mod #5589 2023/03/29 数値IFのスタイル全不正 張博 start
    inputTextAlign: {
      type: String,
      default: "left"
    },
    inputType: {
      type: String,
      default: "text"
    },
    inputMin: {
      type: Number,
      default: null
    },
    inputMax: {
      type: Number,
      default: null
    },
    step: {
      type: Number,
      // #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng start
      // default: null
      default: 1
      // #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng end
    },
    // mod #5589 2023/03/29 数値IFのスタイル全不正 張博 end
  },
  data() {
    return {
      // 入力された文字列
        valueLock:false,
        // add FNSI-borderの追加 徐 start
        initNum:0,
        // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
        // indexNum:0,
        // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
        // add FNSI-borderの追加 徐 end
        // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 start
        blurFlg: false,
        focusflg: false,
        // add #5589 2023/04/14 数値IFのスタイル全不正 林峻峰 end
        // add #10628 数値IF修正 linjunfeng start
        currentValuePro: this.modelValue,
        componentsKey: 0,
        currentMax: this.inputMax??99999999,
        currentMin: this.inputMin??-99999999,
        // add #10628 数値IF修正 linjunfeng end
    };
  },
  computed: {
    currentValue: {
      get() {
        // DB設定値がマスタの小数点桁数を超えている場合のみオーバー表示でセットする
        // 入力・フォーカスアウトした場合は小数点桁数によって値は書き換わっているため、桁数オーバーがvalueに入っていることは無い
        if(this.initialValueLock && this.getDecimalPointLength(this.modelValue) > this.decimalLength && !this.checkValueLock()){
          this.setValueLock();
          return this.modelValue != null ? (this.modelValue / this.base).toFixed(this.getDecimalPointLength(this.modelValue)) : null;
        }else{
          if(this.modelValue){
            this.setValueLock();
          }
          if (this.modelValue === "" && this.isEmpty == true) {
            return "";
          }
          return this.modelValue != null ? (this.modelValue / this.base).toFixed(this.decimalLength) : null;
        }
      },
      set(newVal) {
        const emitted = typeof newVal === "number" ? newVal * this.base : null;
        this.$emit("update:modelValue", emitted);
        this.$emit("input", emitted);
      }
    },
    // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
    // 編集フラグ
    isEdited() {
      //「コメント」内容未变更时，输入框样式表示为内容变更的样式。
      if (this.initNum == null && this.currentValue == null) {
        return false;
      }
      return Number(this.initNum) !== Number(this.currentValue);
    }
  },
  created() {
    this.initNum = this.initValue === undefined ? this.currentValue : this.initValue;
    // add #10628 数値IF修正 linjunfeng start
    const decimalPlaces = BigNumber(this.step).decimalPlaces();
    this.currentMin = Number(this.currentMin.toFixed(decimalPlaces))
    this.currentMax = Number(BigNumber(this.currentMax).toFixed(
      Math.max(decimalPlaces, this.getDecimalPointLength(this.currentMax)), 1
    ))
    this.currentValuePro = this.currentValuePro === "" ? null : this.currentValuePro;
    EventBus.$off('refreshMonitorNumberInput', this.handleRefreshMonitorNumberInput);
    EventBus.$on('refreshMonitorNumberInput', this.handleRefreshMonitorNumberInput);
    // add #10628 数値IF修正 linjunfeng end
  },
  beforeUnmount() {
    EventBus.$off('refreshMonitorNumberInput', this.handleRefreshMonitorNumberInput);
  },
  // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
  methods: {
    // add #10628 数値IF修正 linjunfeng start
    handleRefreshMonitorNumberInput() {
      const decimalPlaces = BigNumber(this.step).decimalPlaces();
      this.currentValuePro = (this.initValue == null || this.initValue === "") ? null : BigNumber(this.initValue).toFormat(decimalPlaces);
    },
    handlerInput(val) {
      this.currentValuePro = (val == null || val === "") ? null : val;
      const num = val == null || val === "" ? null : Number(val);
      const emitted = num != null && !Number.isNaN(num) ? num * this.base : null;
      this.$emit("update:modelValue", emitted);
      this.$emit("input", emitted);
      this.$emit("getChildData", emitted ?? val);
    },
    handlerInputBlur() {
      this.$nextTick(() => {
        this.$emit('blur', this.currentValuePro);
      })
    },
    // add #10628 数値IF修正 linjunfeng end
    // mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start
    inputNumber(event){
        // 数値範囲内かどうかの確認
        if (this.inputMin != null && this.inputMax != null) {
          if (event.target.value > this.inputMax) {
              event.target.value = this.inputMin;
              this.blurFlg = true;
          } else if (event.target.value < this.inputMin) {
              event.target.value = this.inputMax;
              this.blurFlg = true;
          } else {
            this.blurFlg = false;
          }
        }
        // 内部 治療法マスタ:フォーカスアウト時初期値設定不正です start
        this.$emit("getChildData", event.target.value);
        // 内部 治療法マスタ:フォーカスアウト時初期値設定不正です end
    },
    handleBlur(event){
      // #6765 観察記録：修正時、修正していないが保存ボタンが有効になってしまっている横展開 訾浩 start
      EventBus.$emit("onInputAmount");
      // #6765 観察記録：修正時、修正していないが保存ボタンが有効になってしまっている横展開 訾浩 end
      if (event.target.value == this.inputMax && this.blurFlg) {
        this.currentValue = this.inputMin;
        this.blurFlg = false
      }else if (event.target.value == this.inputMin && this.blurFlg) {
        this.currentValue = this.inputMax;
        this.blurFlg = false
      }
    },
    handleMouseWheel(e) {
      if (!this.focusflg) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
      }
      let value = parseFloat(e.target.value);
      if (!this.step) {
        this.step = 1;
      }
      const parameterStep = parseFloat(this.step);
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > this.inputMax) {
        value = this.inputMin;
      }
      if(value < this.inputMin) {
        value = this.inputMax;
      }
      this.$emit("update:modelValue", value);
      this.$emit("input", value);
    },
    // mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end
    /**
     * @description 設定値の小数点桁数算出
     * @param {Number} value 値
     */
    getDecimalPointLength(number){
      var numbers = String(number).split('.');
      return (numbers[1]) ? numbers[1].length : 0;
    },
    checkValueLock(){
      return this.valueLock;
    },
    setValueLock(){
      this.valueLock = true;
    },
    // add FNSI-borderの追加 徐 start
    addFocusCss(event){
      let element = event.target;
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
      // element?.classList?.add("custom-input-edited");
      element?.classList?.add("common-number-input-edited");
      // 5521 治療記録の体重で入力制限のない項目がある 房 start
      // if (this.indexNum === 0 || this.indexNum == null || this.indexNum == undefined) {
      //   // 5521 治療記録の体重で入力制限のない項目がある 房 end
      //   this.initNum = this.value;
      //   this.indexNum = 1;
      // }
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
      this.focusflg = true
    },
    delFocusCss(event){
      //add  治療記録 入力枠は「緑」相关问题
      if (this.initNum === undefined) {
        this.initNum = null
      }
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
      // if (this.initNum !== this.value) {
        //   const inputElement = this.$refs.mySelect.$el.querySelector('input');
        //   const inputStyle = {
           //      border: "2px green solid",
           //      outline: '0'
        //   }
      //   Object.assign(inputElement.style, inputStyle);
      // }else{
        //   const inputElement = this.$refs.mySelect.$el.querySelector('input');
        //   const inputStyle = {
        //   border: "unset",
        //   borderWidth: "2px",
        //   borderStyle: "inset",
        //   borderImageRepeat: "stretch",
        //   borderColor: "unset",
        //   height: "2em",
        //   borderRadius: "5px",
        //   boxSizing: "border-box",
        //   '-webkit-box-sizing': "border-box"
        //   }
      //   Object.assign(inputElement.style, inputStyle);
// }
      let element = event.target;
      if(!this.isEdited){
        element.classList.remove("common-number-input-edited");
      }
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
      this.focusflg = false
    },
  },
  watch: {
    modelValue: {
      handler(val) {
        if (this.currentValuePro != null && this.currentValuePro !== "") {
          return;
        }
        this.currentValuePro = (val == null || val === "") ? null : val;
      }
    },
    initValue: {
      // #10628 数値IF修正 linjunfeng start
      // handler(){
      handler(val){
      // #10628 数値IF修正 linjunfeng end
        this.initNum = this.initValue;
        // add #10628 数値IF修正 linjunfeng start
        const decimalPlaces = BigNumber(this.step).decimalPlaces();
        this.currentValuePro = (val == null || val === "") ? null : BigNumber(val).toFormat(decimalPlaces);
        this.componentsKey++;
        // add #10628 数値IF修正 linjunfeng end
      }
    },
    // del #10628 数値IF修正 linjunfeng start
    // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
    // currentValue: {
    //   handler(value){
    //     // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 №41 dengshen start
    //     // this.$emit('input', Number(value))
    //     this.$emit('input', value)
    //     // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 №41 dengshen end
    //   }
    // }
    // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
    // del #10628 数値IF修正 linjunfeng end
  }
};
</script>

<style scoped>
.num-value ons-input {
  width: 10em;
}
.select-btn {
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  min-width: 4em;
  font-size: 1em;
  cursor: pointer;
}
.select-btn:hover {
  color: #212529;
}
/* add FNSI-borderの追加 徐 start */
.custom-input-edited {
  border: 2px green solid;
  outline: 0;
}
/* add FNSI-borderの追加 徐 end */
</style>
<style>
/* #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start */
.common-number-input-edited input[type="number"]{
  border: 2px green solid !important;
  outline: 0 !important;
}
/* #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end */
</style>
