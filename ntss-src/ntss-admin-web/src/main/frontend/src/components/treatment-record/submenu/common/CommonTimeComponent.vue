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
      :value="dateValue"
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
  props: {
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
      dateValue: this.value,
      initTime:"",
      indexNum:0
    }
  // add FNSI-borderの追加 徐 end
  },
  methods: {
    onBlur(ev) {
      if (!ev.target.value) {
        // 画面で入力不備がある場合、未入力状態にする
        const timeControl = this.$el.querySelector('input[type="time"]');
        timeControl.value = null;
      }
      this.$emit("input", ev.target.value ? ev.target.value : null, this.index);
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
    value(newValue) {
      this.dateValue = newValue;
    }
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
