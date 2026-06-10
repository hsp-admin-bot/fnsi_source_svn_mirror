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
        @blur="onBlurTextarea"
        @focus="handleFocusTextarea($event)"
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
      <v-ons-input 
        ref="mySelect"
        :type="inputType"
        model-event="change"
        v-model.number="currentValue"
        :disabled="disabled"
        :step="step"
        @blur="onBlur"
        @focus="handleFocus($event)"
        @keypress="onKeyPress"
        @keydown="onKeyDown"
        @change="inputNumber($event)"
        @mousewheel.prevent="handleMouseWheel($event)"
      />
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end -->
      <label class="theme" style="margin-left: 0.5em;">{{unitName}}</label>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
import NumberInputMixin from "@/components/treatment-record/submenu/common/NumberInputMixin";
import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
import { TitleAndNumber } from "@/models/common/TitleAndNumber";

export default {
  mixins: [NumberInputMixin],
  components: {
    "custom-simple-textarea-b": CustomSimpleTextareaTypeB
  },
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
    value: {
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
      blurFlg: false,
      focusFlg:false,
      indexNum: 0,
      initNum: 0
    }
  },
  computed: {
    currentTitle: {
      get() {
        return this.value.title;
      },
      set(newVal) {
        this.$emit("input", new TitleAndNumber(newVal, this.value.value));
      }
    },
    currentValue: {
      get() {
        return this.value.value != null ? (this.value.value / this.base).toFixed(this.decimalLength) : null;
      },
      set(newVal) {
        this.$emit(
          "input",
          new TitleAndNumber(
            this.value.title,
            typeof newVal === "number" ? newVal * this.base : null
          )
        );
        // 数値以外の値が入力された場合は0に変更する
        if (!(typeof newVal === "number")) {          
          this.$nextTick(() => {
            this.$emit(
              "input",
              new TitleAndNumber(
                this.value.title,
                0
              )
            );
          })
        }
      }
    }
  },
  // mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start
  methods:  {
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
    },
    onBlur () {
      if (this.initNum === undefined) {
        this.initNum = null
      }
      if (this.value === undefined) {
        this.value = null
      }
      if (this.initNum.value !== this.value.value) {
        const inputElement = this.$refs.mySelect.$el.querySelector('input');
        const inputStyle = {
           border: "2px green solid",
           outline: '0'
        }
        Object.assign(inputElement.style, inputStyle);
      }else{
        const inputElement = this.$refs.mySelect.$el.querySelector('input');
        const inputStyle = {
        border: "unset",
        borderWidth: "2px",
        borderStyle: "inset",
        borderImageRepeat: "stretch",
        borderColor: "unset",
        height: "2em",
        borderRadius: "5px",
        boxSizing: "border-box",
        '-webkit-box-sizing': "border-box"
        }
        Object.assign(inputElement.style, inputStyle);
      }
      this.$emit('blur');
    },
    onBlurTextarea () {
            if (this.initNum.title !== this.value.title) {
        const inputElement = this.$refs.mySelecTitle.$el;
        const inputStyle = {
           border: "2px green solid",
           outline: '0'
        }
        Object.assign(inputElement.style, inputStyle);
      }else{
        const inputElement = this.$refs.mySelecTitle.$el;
        const inputStyle = {
        border: "unset",
        borderWidth: "2px",
        borderStyle: "inset",
        borderImageRepeat: "stretch",
        borderColor: "unset",
        height: "2em",
        borderRadius: "5px",
        boxSizing: "border-box",
        '-webkit-box-sizing': "border-box"
        }
        Object.assign(inputElement.style, inputStyle);
      }
    },
    handleFocusTextarea () {
            let element = event.target;
      element?.classList?.add("custom-input-edited");
      if (this.indexNum === 0 || this.indexNum == null || this.indexNum == undefined) {
        // 5521 治療記録の体重で入力制限のない項目がある 房 end
        this.initNum = this.value;
        this.indexNum = 1;
      }
    },
    // add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start
    handleFocus(event){
      let element = event.target;
      element?.classList?.add("custom-input-edited");
      if (this.indexNum === 0 || this.indexNum == null || this.indexNum == undefined) {
        // 5521 治療記録の体重で入力制限のない項目がある 房 end
        this.initNum = this.value;
        this.indexNum = 1;
      }
      this.focusFlg=true;
      this.blurFlg=true;
    },
    handleMouseWheel(e) {
      if (!this.focusFlg) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) || 
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
      }     
      let value = parseFloat(e.target.value);
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
      this.$nextTick(() => {
        this.$emit("input", new TitleAndNumber(
          this.value.title,
          value * this.base
        ));
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
.num-value ons-input {
  width: 10em;
}
.custom-input-edited {
  border: 2px green solid;
  outline: 0;
}
</style>
