/**
 * モニタ用数値入力コンポーネント
 */
<template>
  <!-- mod 7908 狭すぎるため全て表示しきれていない。 房 start -->
  <!-- mod 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 start -->
  <!-- <v-ons-input
    :class="isChanged"
    class="input-width"
    type="text"
    model-event="change"
    v-model.number="currentValue"
    @blur="onMyBlur($event)"
    @focus="onFocus()"
    @keypress="onKeyPress"
    @keydown="onKeyDown"
	@mousewheel="onMousewheel"
  /> -->
<!-- mod 8506 ljx start -->
<!--  <input
      v-if="inputStatus"
      :id="'myInput' + monitorUniqueId"
      :class="isChanged"
      class="input-width"
      type="text"
      v-model.number="currentValue"
      @blur="onMyBlur($event)"
      @focus="onFocus"
      @keypress="onKeyPress"
      @keydown="onKeyDown"
      @mousewheel="onMousewheel"
    />
  <span v-else :class="isChanged" class="monitior-span-input" @click="handleSwitchShowStatus(monitorUniqueId)">{{ currentValue }}</span>-->
  <!-- mod 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 end -->
  <!-- <input
    :id="'myInput' + monitorUniqueId"
    :class="isChanged"
    class="input-width"
    type="text"
    v-model.number="currentValue"
    @blur="onMyBlur($event)"
    @focus="onFocus"
    @keypress="onKeyPress"
    @keydown="onKeyDown"
    @mousewheel="onMousewheel"
  /> -->
  <!-- mod 8506 ljx end -->
  <!-- add #5589 2023/03/31 数値IFのスタイル全不正 林峻峰 start -->
  <!-- #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start -->
  <!-- <input
    :id="'myInput' + monitorUniqueId"
    :class="isChanged"
    :step="step"
    class="input-width"
    type="number"
    ref="input"
    v-model.number="currentValue"
    @blur="onMyBlur($event)"
    @focus="onFocus"
    @change="inputValidValue($event)"
    @mousewheel.prevent="mousewheel($event)"
  /> -->
  <custom-input-number-pro
    :id="'myInput' + monitorUniqueId"
    :step="step"
    class="input-width"
    :style="{'--base-size' : exSize}"
    ref="input"
    :min="min"
    :max="max"
    :value="currentValuePro"
    :emptyVal="null"
    @handlerInput="handlerInput"
    :key="componentsKey"
  />
  <!-- #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng end -->
  <!-- mod 7908 狭すぎるため全て表示しきれていない。 房 end -->
  <!-- add #5589 2023/03/31 数値IFのスタイル全不正 林峻峰 end -->
</template>

<script>
import { resolveRefElement } from "@/functions/common/LayoutMeasureHelper";
import NumberInputMixin from "@/components/treatment-record/submenu/common/NumberInputMixin";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
// add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
import { EventBus } from "@/compat/vue/event-bus.js";

import BigNumber from "@/compat/number/bignumber";
// add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng end

export default {
  mixins: [NumberInputMixin],
  // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
  components: {
    "custom-input-number-pro": CustomInputNumberPro
  },
  // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng end
  emits: ["update:modelValue", "blur"],
  props: {
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      // #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
      // type: [Number]
      // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
      // type: [Number, String]
      type: String
      // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
      // #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
    },
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
    initValue: {
      // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
      // type: Number
      type: String
      // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
    },
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
    // 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 start
    monitorUniqueId: {
      type: String,
      default: ""
    },
    // 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 end
    // add #5589 2023/03/31 数値IFのスタイル全不正 林峻峰 start
    min: {
      type: Number,
      default: null
    },
    max: {
      type: Number,
      default: null
    },
    step: {
      type: Number,
      default: null
    }
    // add #5589 2023/03/31 数値IFのスタイル全不正 林峻峰 end
  },
  // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
  data(){
    return {
      isOnFocus: false,
      blurFlg: false,
      //  del 8506 ljx start
      // 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 start
      //inputStatus: false,
      // 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 end
      //  del 8506 ljx end
      // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
      currentValuePro: this.modelValue == null ? null : this.modelValue,
      exSize: 3,
      componentsKey: 0
      // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng end
    }
  },
  methods: {
    requestViewForceUpdate() {
      if (this.$?.isMounted) {
        this.$forceUpdate();
      }
    },
    handleRefreshMonitorNumberInput() {
      this.currentValuePro = this.formatValueByStep(this.initValue);
    },
    onMyBlur(event){
      if (event.target.value == this.max && this.blurFlg) {
        this.currentValue = this.min;
        this.blurFlg = false
      }else if (event.target.value == this.min && this.blurFlg) {
        this.currentValue = this.max;
        this.blurFlg = false
      }
      this.requestViewForceUpdate();
      // console.log('blur',event)
      this.isOnFocus = false;
      // this.onBlur(event);
      // add #5589 2023/04/19 血圧の平均値を自動的に算出します 林峻峰 start
      this.$emit("blur", event);
      // add #5589 2023/04/19 血圧の平均値を自動的に算出します 林峻峰 end
    },
    onFocus(){
      this.isOnFocus = true;
    },
    // add #5589 2023/03/31 数値IFのスタイル全不正 林峻峰 start
    inputValidValue(event) {
      // 数値範囲内かどうかの確認
      if (event.target.value > this.max) {
       this.currentValue = this.min;
       this.blurFlg = true;
      } else if (event.target.value < this.min) {
        this.currentValue = this.max;
        this.blurFlg = true;
      } else {
        this.blurFlg = false;
      }
      // #6765 2023/05/04 バイタル,モニタ修正時保存ボタンは未起動です 張博 start
      this.$emit("blur", event);
      // #6765 2023/05/04 バイタル,モニタ修正時保存ボタンは未起動です 張博 end
    },
    mousewheel(e) {
      if (!this.isOnFocus) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) || 
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = this.min - 1;
      }              
      let value = parseFloat(e.target.value);
      const parameterStep = this.step;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      if (value > this.max) {
        value = this.min;
      }
      if(value < this.min) {
        value = this.max;
      }
      this.currentValue=value;
       // #6765 2023/05/04 バイタル,モニタ修正時保存ボタンは未起動です 張博 start
      // #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
      this.$emit("blur", e);
      // #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng end
      // #6765 2023/05/04 バイタル,モニタ修正時保存ボタンは未起動です 張博 end
    },
    // add #5589 2023/03/31 数値IFのスタイル全不正 林峻峰 end
    //del 8506 ljx start
    //add 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 start
    /*handleSwitchShowStatus(monitorUniqueId) {
      this.inputStatus = true;
      this.isOnFocus = true;
      this.$nextTick(() => {
        getScopedElementById('myInput' + monitorUniqueId, this.$el || null)?.focus?.()
      })
    }*/
    //add 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 end
    //del 8506 ljx end
    updateBaseSize() {
      if (!this.$refs.input) return;
      const minDigit = countDigit(this.min).integer;
      const maxDigit = countDigit(this.max).integer;
      const decimalDigit = countDigit(this.step).decimal;
      // 一文字分の幅を1.1exとして入力桁数から幅を計算
      // 小数部がある場合はピリオド分として0.5文字分足す
      // 符号分は正負によらず1ex分足しておく
      // （そのほかの余白分などは別途calc時に25px足している）
      const exSize = 1 + (1.1 * (Math.max(minDigit, maxDigit) + (decimalDigit ? decimalDigit + 0.5 : 0)));
      // #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
      // this.$refs.input.style.setProperty("--base-size", exSize);
      resolveRefElement(this, "input")?.style?.setProperty("--base-size", exSize);
      this.exSize = exSize;
      // #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng end
    },
    // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
    handlerInput(val) {
      this.currentValuePro = val;
      // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
      // const formattedValue = (val == null || val === "") ? null : Number(val);
      const formattedValue = (val == null || val === "") ? null : val;
      // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
      this.$emit('update:modelValue', formattedValue);
      this.$emit('blur', val);
    },
    // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng end
    /** 値をstepに応じた小数部桁数で文字列化 **/
    formatValueByStep(value) {
      if (value == null) return null;
      const decimalPlaces = BigNumber(this.step).decimalPlaces();
      return BigNumber(value).toFixed(decimalPlaces);
    }
  },
  // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
  computed: {
    currentValue: {
      get() {
        return this.modelValue != null ? (this.modelValue / this.base).toFixed(this.decimalLength) : null;
      },
      set(newVal) {
        this.$emit(
          "update:modelValue",
          typeof newVal === "number" ? newVal * this.base : null
        );
      }
    },
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
    isChanged(){
      let isChanged = true;
      if ((this.modelValue === this.initValue) || 
        (this.modelValue === null && this.initValue === undefined) || 
        (this.modelValue === undefined && this.initValue === null)) {
        if (this.isOnFocus) {
          isChanged = true;
        } else {
          isChanged = false;
        }
      }
      return {
        "custom-input-edited": isChanged
      }
    }
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
  },
  watch: {
    min() {
      this.updateBaseSize();
    },
    max() {
      this.updateBaseSize();
    },
    step() {
      this.updateBaseSize();
    },
    // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
    initValue(val) {
      // add #10774 治療記録＞観察記録 患者・実績を切替た場合 linjunfeng start
      this.currentValuePro = this.formatValueByStep(val);
      // add #10774 治療記録＞観察記録 患者・実績を切替た場合 linjunfeng end
      this.componentsKey++;
    },
    // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng end
    modelValue(val) {
      this.currentValuePro = this.formatValueByStep(val);
    }
  },
  mounted() {
    this.updateBaseSize();
    // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng start
    EventBus.$off('refreshMonitorNumberInput', this.handleRefreshMonitorNumberInput);
    EventBus.$on('refreshMonitorNumberInput', this.handleRefreshMonitorNumberInput);
    // add #11047 ②治療記録＞バイタル モニタ入力範囲が0～ではない項目にて空欄にできない。  linjunfeng end
  },
  beforeUnmount() {
    EventBus.$off('refreshMonitorNumberInput', this.handleRefreshMonitorNumberInput);
  },
};

const countDigit = (value) => {
  // 数値の桁数を符号、整数部、小数部に分けて得る
  const digits = {
    sign: 0,
    integer: 0,
    decimal: 0,
  };
  if (!value) {
    // nullの場合は1桁とする
    value = 0;
  }
  if (value < 0) {
    digits.sign = 1;
    // 符号は含まない値にする
    value = -value;
  }
  // （指数表現にならない前提で）文字列化して整数部と小数部の桁数を返す
  const stringParts = ("" + value).split(".");
  digits.integer = stringParts[0].length;
  if (stringParts.length > 1) {
    digits.decimal = stringParts[1].length;
  }
  return digits;
};
</script>

<style scoped>
.input-width {
  --base-size: 3;
  width: calc((var(--base-size) * 1ex) + 25px);
}
.custom-input-edited {
  border: 2px green solid;
  outline: 0;
}
/*del 8506 ljx start */
/*add 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 start */
/*.monitior-span-input {
  display: inline-block;
  width: 50px;
  height: 30px;
  border: unset;
  border-width: 2px;
  border-style: inset;
  border-image-repeat: stretch;
  border-radius: 5px;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  color: var(--time-input-color);
  background-color: var(--time-input-background-color);
  font-size: 1.0em;
  line-height: 27px;
  outline: 0;
}*/
/*add 8453 2023/03/20 治療記録 【デグレ】治療記録>モニタにて全て表示が遅い 林峻峰 end */
/*del 8506 ljx end */
</style>
