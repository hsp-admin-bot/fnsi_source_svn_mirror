
<template>
<!-- #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 start -->
  <div class="time-input">
    <input
      type="time"
      :class="classes"
      class="time-wrapper"
      :value="dateValue"
      :id="id"
      :min="min"
      :max="max"
      :disabled="disabled"
      v-validate="'date_format:HH:mm'"
      :name="nameForVeeValidate"
      v-bind="$attrs"
      @change="handleChange"
      @input="handleInput"
      @blur="handleBlur"
      @focus="handleFocus"
      @keydown="handleKeydown"
      :style="computedStyle"
    />
    <span v-if="!disabled && dateValue && dateValue !== 'defaultValue' && !isRequired" :style="{left:left+'%'}" class="k-icon k-i-close close-btn" title="clear" @click="handleClearInput"></span>
    <!-- //  #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 end -->
  </div>
</template>
<script>
  
import moment from "moment";
  
export default {
  name: 'TimeInput',
  modal: {
    event: 'blur'
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
     * @description 許容する時刻の最小値
     */
    min: {
      type: String,
      default: "00:00"
    },
    /**
     * @description 許容する時刻の最大値
     */
    max: {
      type: String,
      default: "23:59"
    },
    /**
     * @description 必須か任意入力かを切り替えるフラグ
     */
    isRequired: {
      type: Boolean,
      default: false
    },
    /**
     * @description 補正に使用するデフォルト値。指定無しの場合はsysdateの時刻で補正。
     * "HH:mm"形式で指定してください。
     */
    defaultTime: {
      type: String,
      default: ""
    },
    //  #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 start
    width:{
      type: Number,
      default: 7,
    },
    left:{
      type: Number,
      default: 65,
    }
    //  #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 end
  },
  data() {
    return {
      clickAllowUp: false, // 十字キーの上キーが押下されたかを保持
    };
  },
  computed: {
    nameForVeeValidate() {
      // v-validateを指定する際はname（もしくはdata-vv-name）の
      // 指定も必要なため、指定されていない場合は代替の値を設定する
      return this.$attrs.name || this.$attrs["data-vv-name"] || this.id || "TimeInput";
    },
    dateValue() {
      // 無効な時刻の場合は親側に通知
      if (this.value === "aN:aN") {
        this.$emit('input', "");
        this.$emit('blur', "");
      }
      return this.value || null
    },  
    computedStyle() {
      return !this.isRequired ? { width: this.width + 'em' } : {};
    }
  },
  methods: {
    handleClearInput() {
      this.$emit('handleClearInput')
    },
    handleKeydown(event) {
      this.clickAllowUp = event.key === "ArrowUp";
      this.$emit('keydown', event);
    },
    /** 
    * @description inputイベントハンドラ
    * 入力された時分をmin, max指定範囲内の値でループする
    */
    handleInput(event) {
      let value = event.target.value;
      if (value !== "") {
        let totalMinutes = this.convertTimeToMinutes(value);
        const minTotalMinutes = this.convertTimeToMinutes(this.min);
        const maxTotalMinutes = this.convertTimeToMinutes(this.max);
    
        if (this.clickAllowUp && totalMinutes > maxTotalMinutes) {
          // 十字キーの上キーが押下された際にmaxを超えたら分のみリセット
          totalMinutes = Math.floor(totalMinutes / 60) * 60;
        } else {
          // 時分をmin, max指定範囲内の値に設定
          totalMinutes = Math.min(Math.max(totalMinutes, minTotalMinutes), maxTotalMinutes);
        }
        // 分→時分変換
        value = this.convertMinutesToTime(totalMinutes);
      }
      this.$emit('input', value);
    },
    handleChange(event) {
      this.$emit('change', event);
    },
    handleBlur (event) {
      let value = event.target.value;
      
      // 補正前後の値が同じ場合、入力フィールドの値が更新されないためinputイベントを発火して現在の入力フィールドの値をクリアする
      this.$emit('input', "");
      
      // 空入力、欠落入力の場合
      if (!value) {
        if (this.isRequired) {
          // 必須入力の場合は補正。defaultTimeが""の場合は現在日時の時刻で補正
          // "HH:mm"形式の時刻をセット
          value = this.defaultTime === "" ? this.getCurrentTime() : this.defaultTime;
        } else if (this.defaultTime !== "") {
          // 任意入力の場合でdefaultTimeが設定されていたらdefaultTimeで補正
          value = this.defaultTime;
        } else {
          // 入力フィールドの値をクリアする
          event.target.value = "00:00";
          event.target.value = "";
        }
      } else {
        // 値が入力されている場合はmin、maxの値で補正
        let totalMinutes = this.convertTimeToMinutes(value);
        const minTotalMinutes = this.convertTimeToMinutes(this.min);
        const maxTotalMinutes = this.convertTimeToMinutes(this.max);
        // min、maxの範囲内の値に補正
        totalMinutes = Math.min(Math.max(totalMinutes, minTotalMinutes), maxTotalMinutes);
        // 分→時分変換
        value = this.convertMinutesToTime(totalMinutes);
      }
      this.$emit('input', value);
      this.$emit('blur', event);
    },
    handleFocus (event) {
      this.$emit('focus', event);
    },
    /**
     * @description 時分→分変換
     */
    convertTimeToMinutes(time) {
      return moment.duration(time).asMinutes();
    },
    /**
     * @description 分→時分変換
     */
    convertMinutesToTime(minutes) {
      // 分を時間と分に
      const duration = moment.duration(minutes, "minutes");
      const hour = duration.hours();
      const minute = duration.minutes();
      // 時間と分からモーメントを作成しフォーマット
      const mo = moment();
      mo.hours(hour);
      mo.minutes(minute);
      return mo.format("HH:mm");
    },
    /**
     * @description 現在の日時の分をHH:mm形式で取得
     */
    getCurrentTime() {
      const now = new Date();
      const hours = String(now.getHours()).padStart(2, '0');
      const minutes = String(now.getMinutes()).padStart(2, '0');
      return `${hours}:${minutes}`;
    }
  }
}
</script>
<style scoped>
.time-input{
  position: relative;
  display: inline-block;
}
.time-input:hover>.close-btn{
  display: block;
}
.time-input .close-btn{
  /* display: none; */
  position: absolute;
  left: 65%;
  padding: 0;
  color: #212529;
  cursor: pointer;
  top: 50%;
  transform: translate(0, -50%);
}
.k-icon{
  opacity: .5;
}
.k-icon:hover{
  opacity: 1;
}
.custom-input-edited{
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
/* #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start */
.time-input-edited{
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
/* #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end */
.time-input-required {
  background-color: #ffff99 !important;
}
.time-input-required:disabled {
  color: #999;
}
.time-input-focus:focus {
  border: 2px #008000 solid;
  outline: 0;
}
.time-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}
.time-wrapper {
  text-align: center;
  -webkit-appearance: none;
}
</style>