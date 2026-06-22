/**
 * 時刻入力共通コンポーネント
 */
<template>
  <div class="common-time-input" >
    <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
    <!-- add FNSI-borderの追加 徐 start -->
    <!-- <input class="text-input" type="time" :value="value" :disabled="disabled" @blur="onBlur" /> -->
    <!-- <input class="text-input" type="time"
    :value="value"
    :disabled="disabled"
    @blur="onBlur"
    @focus="addFocusCss($event)" /> -->
    <!-- add FNSI-borderの追加 徐 end -->
    <time-input
      :classes="'text-input ' +classes"
      v-model="dateValue"
      :disabled="disabled"
      @blur="onBlur"
      @change="onBlur"
      @focus="addFocusCss"
      @handleClearInput="handleClearInput()"
    />
    <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
  </div>
</template>

<script>
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
import TimeInput from "@/components/common/TimeInput.vue";
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
export default {
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
  components: {
    TimeInput
  },
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  // Vue3 は v-model の既定が modelValue / update:modelValue。
  // Vue2 互換で @input リスナーも親が利用しているため input も合わせて emit する。
  emits: ["update:modelValue", "input", "focus"],
  props: {
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: String
    },
    // Vue2 互換: :value バインディング
    value: {
      type: String
    },
    index: {
      type: Number,
      default: undefined
    },
    disabled: {
      type: Boolean,
      default: false
    },
    /**
     * @description 入力要素に適用するカスタムCSSクラス
     */
    classes: {
      type: String,
      default: ""
    },
  },
  // add FNSI-borderの追加 徐 start
  data(){
    return{
      dateValue: this.modelValue ?? this.value ?? null,
      initTime:"",
      indexNum:0
    }
  // add FNSI-borderの追加 徐 end
  },
  computed: {
    externalValue() {
      return this.modelValue !== undefined ? this.modelValue : this.value;
    },
  },
  methods: {
    onBlur(ev) {
      if (!ev.target.value) {
        // 画面で入力不備がある場合、未入力状態にする
        const timeControl = this.$el.querySelector('input[type="time"]');
        timeControl.value = null;
      }
      const emitted = ev.target.value ? ev.target.value : null;
      this.dateValue = emitted;
      this.$emit("update:modelValue", emitted, this.index);
      this.$emit("input", emitted, this.index);
      // add FNSI-borderの追加 徐 start
      if (ev.target.value === this.initTime) {
        let element = ev.target;
        element.classList.remove("custom-input-edited");
      }
      // add FNSI-borderの追加 徐 end
    },
    handleClearInput(){
      this.dateValue = null
      if (this.index !== undefined) {
        this.$emit("update:modelValue", null, this.index);
        this.$emit("input", null, this.index);
      }
    },
    // add FNSI-borderの追加 徐 start
    addFocusCss(ev){
      let element = ev.target;
      element?.classList?.add("custom-input-edited");
      if (this.indexNum === 0) {
        this.initTime = ev.target.value;
        this.indexNum = 1;
      }
      this.$emit('focus', ev);
    },
    // add FNSI-borderの追加 徐 end
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
    indexNumInit(){
      this.indexNum = 0;
    }
    // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
  },
  watch: {
    externalValue(newValue) {
      this.dateValue = newValue ?? null;
    },
  },
};
</script>

<style scoped>
.common-time-input {
  display: inline-block;
  padding: 0;
  color: #aaa;
  margin: 0;
  width: 100%;
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  border-radius: 3px;
  -webkit-box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
}
 /* add FNSI-borderの追加 徐 start */
.custom-input-edited {
  border: 2px green solid;
  outline: 0;
}
/* add FNSI-borderの追加 徐 end */
</style>
