<template>
  <div>
    <div
      class="time-span"
      :class="classObject"
    >
    <!-- mod FNSI-6669 劉全航 start -->
    <!-- <input
        type="number"
        class="time"
        :style="colorStyle"
        :value="hoursValue"
        @input="hoursValue = $event.target.value"
        @change="changeHoursValue($event)"
      />
      <p :style="colorStyle">:</p>
      <input
        class="time"
        type="number"
        :style="colorStyle"
        :value="minutesValue"
        @input="minutesValue = $event.target.value"
        @change="changeMinutesValue($event)"
        @focus="isFocusMinutesInput = true"
        @blur="isFocusMinutesInput = false"
      /> -->
      <!-- mod FNSI-6669 治療時間入力IFのコントロール不正　周安寧 start -->
      <!-- <input
        id="hourInput"
        type="number"
        class="time"
        :style="colorStyle"
        :value="hoursValue"
        :disabled="disabled"
        @input="hoursValue = $event.target.value"
        @change="changeHoursValue($event)"
        @mousewheel="changeHoursValue($event)"
        @keyup="switchFocus($event,'hour')"
        @focus="focus()"
      />
      <p :style="colorStyle">:</p>
      <input
        id="minuteInput"
        class="time"
        type="number"
        :style="colorStyle"
        :value="minutesValue"
        :disabled="disabled"
        @input="minutesValue = $event.target.value"
        @change="changeMinutesValue($event)"
        @focus="isFocusMinutesInput = true"
        @blur="isFocusMinutesInput = false"
        @mousewheel="changeMinutesValue($event)"
        @keydown="switchFocus($event,'minute')"
      /> -->
      <!-- #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng start -->
      <!-- <input
        :id="'hourInput'+uniqueId"
        type="number"
        class="time"
        style="text-align:center;width:32px"
        :style="colorStyle"
        :value="hoursValue"
        :disabled="disabled"
        @input="handleInputHour"
        @change="changeHoursValue($event)"
        @mousewheel="setDoLoop($event, true); changeHoursValue($event)"
        @keyup="switchFocus($event,'hour')"
        @keydown="setDoLoop($event)"
        @focus="isFocusHourInput = true; focus()"
        @blur="isFocusHourInput = false"
        placeholder="--"
      /> -->
      <input
        :id="'hourInput'+uniqueId"
        type="number"
        class="time"
        style="text-align:center;width:32px"
        :style="colorStyle"
        :value="hoursValue"
        :disabled="disabled"
        @input="handleInputHour"
        @change="changeHoursValue($event)"
        @mousewheel="setDoLoop($event, true); changeHoursValue($event)"
        @keyup="switchFocus($event,'hour')"
        @keydown="setDoLoop($event)"
        @focus="isFocusHourInput = true; focus()"
        @blur="isFocusHourInput = false;hoursValue=formatTimeValue(hoursValue ? hoursValue :'00')"
        placeholder="--"
      />
      <!-- #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng end -->
      <p :style="colorStyle">:</p>
      <!-- mod FNSI-6669 治療時間入力IFのコントロール不正　周安寧 start -->
      <!-- <input
        id="minuteInput"
        class="time"
        type="number"
        :style="colorStyle"
        :value="minutesValue"
        :disabled="disabled"
        max="59"
        min="00"
        @input="minutesValue = $event.target.value"
        @change="changeMinutesValue($event)"
        @focus="isFocusMinutesInput = true"
        @blur="isFocusMinutesInput = false"
        @mousewheel="changeMinutesValue($event)"
        @keydown="switchFocus($event,'minute')"
      /> -->
      <!-- #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng start -->
      <!-- <input
        :id="'minuteInput'+uniqueId"
        class="time"
        type="number"
        style="text-align:center;width:32px"
        :style="colorStyle"
        :value="minutesValue"
        :disabled="disabled"
        @input="handleInputMinutes"
        @change="changeMinutesValue($event)"
        @focus="isFocusMinutesInput = true; focusMinute()"
        @blur="isFocusMinutesInput = false"
        @mousewheel="changeMinutesValue($event)"
        @keydown="switchFocus($event,'minute')"
        placeholder="--"
      /> -->
      <input
        :id="'minuteInput'+uniqueId"
        class="time"
        type="number"
        style="text-align:center;width:32px"
        :style="colorStyle"
        :value="minutesValue"
        :disabled="disabled"
        @input="handleInputMinutes"
        @change="changeMinutesValue($event)"
        @focus="isFocusMinutesInput = true; focusMinute()"
        @blur="isFocusMinutesInput = false;minutesValue=formatTimeValue(minutesValue ? minutesValue : '00')"
        @mousewheel="changeMinutesValue($event)"
        @keydown="switchFocus($event,'minute')"
        placeholder="--"
      />
      <!-- #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng end -->
      <!-- mod FNSI-6669 治療時間入力IFのコントロール不正　周安寧 end -->
      <!-- mod FNSI-6669 治療時間入力IFのコントロール不正　周安寧 end -->
      <!-- mod FNSI-6669 劉全航 end -->
      <div class="treatment-time" v-show="isHoverTimeInput">
        <div
          class="wrap-arrow-up"
          @mousedown.prevent="startIncreaseValue()"
          @mouseup="stopIncreaseValue()"
          @mouseleave="stopIncreaseValue()"
          @touchstart.prevent="startIncreaseValue()"
          @touchend="stopIncreaseValue()"
          @touchcancel="stopIncreaseValue()"
        >
          <div class="arrow-up"></div>
        </div>
        <div
          class="wrap-arrow-down"
          @mousedown.prevent="startDecreaseValue()"
          @mouseup="stopDecreaseValue()"
          @mouseleave="stopDecreaseValue()"
          @touchstart.prevent="startDecreaseValue()"
          @touchend="stopDecreaseValue()"
          @touchcancel="stopDecreaseValue()"
        >
          <div class="arrow-down"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm.vue";
import {EventBus} from "@/eventBus";
/**
 * @description 共通日時入力タグ
 * @summary
 *   ■props
 *     ・minHoursValue: 時の入力可能下限値
 *     ・maxHoursValue: 時の入力可能上限値
 *     ・minMinutesValue: 分の入力可能下限値
 *     ・maxMinutesValue: 分の入力可能上限値
 */
export default {
  mixins: [baseCustomForm],
  props: {
    minHoursValue: {
      type: Number,
      default: 0
    },
    maxHoursValue: {
      type: Number,
      default: 72
    },
    minMinutesValue: {
      type: Number,
      default: 0
    },
    maxMinutesValue: {
      type: Number,
      default: 59
    },
    fontColor: {
      type: String,
      default: ""
    },
    // add 6668 治療時間が72時間まで入力できない 房 start
    disabled: {
      type: Boolean,
      default: false
    },
    // add 6668 治療時間が72時間まで入力できない 房 end
    /**
     * @description componentをユニークとする識別子
     */
    uniqueId: {
      type: String,
      default: ""
    },
    /**
     * @description デフォルト値
     *  空入力、欠落入力の場合はデフォルト値で補正します
     */
    defaultValue: {
      type: String,
      default: "00"
    }
  },
  data() {
    return {
      // 分値
      minutesValue: "",
      // 時間値
      hoursValue: "",
      // 頭0埋め前の時間値
      hoursValueInput: "",
      // 時入力用コントロールのフォーカスフラグ
      isFocusHourInput: false,
      // 分入力用コントロールのフォーカスフラグ
      isFocusMinutesInput: false,
      // 時刻入力タグのフォーカスフラグ
      isHoverTimeInput: false,
      //値増やしに費やした時間
      increaseTimeout: null,
      //値増やし用の遅延量
      increaseInterval: null,
      //値減らしに費やした時間
      decreaseTimeout: null,
      //値減らし用の遅延量
      decreaseInterval: null,
      //add FNSI-6669 治療時間入力IFのコントロール不正　周安寧 start
      maxminutes:"59",
      //add FNSI-6669 治療時間入力IFのコントロール不正　周安寧 end
      // ピッカーループ、マウスホイールピッキング実施フラグ
      doLoop: false
    };
  },
  computed: {
    classObject() {
      return {
        // 常に適用されるclass
        "custom-input-time": true,
        // 編集時に適用されるclass
        "custom-input-time-edited": this.isEdited || this.isFocusHourInput || this.isFocusMinutesInput,
        // 必須項目に適用されるclass
        "custom-input-time-required": this.isRequired,
        // データ不正時に適用されるclass
        "custom-input-time-invalid": !this.isValid,
        // add 6668 治療時間が72時間まで入力できない 房 start
        // 非活性
        "div-dis-color": this.disabled
        // add 6668 治療時間が72時間まで入力できない 房 end
      };
    },
    colorStyle() {
      let rtn = {};
      if (this.fontColor) {
        rtn = { "color" : this.fontColor };
      }
      return rtn;
    },
    //add FNSI-6669 治療時間入力IFのコントロール不正　周安寧 start
    maxMinutes() {
      if (this.hoursValue === "72"){
        return "00"
      } else{return "59"}
    //add FNSI-6669 治療時間入力IFのコントロール不正　周安寧 end
    }
  },
  methods: {
    /**
     * @description 編集値の格納
     */
    setEditValue() {
      const hours = this.hoursValue === "" ? null : Number(this.hoursValue);
      const minutes = this.minutesValue === "" ? null : Number(this.minutesValue);

      this.editValue = hours == null && minutes == null ? null :
                       hours === 0 && !minutes ? 0 :
                       hours * 60 + minutes;
      this.changeButton();
    },
    //mod FNSI-6669 劉全航 start
    focus(){
      document.getElementById(`hourInput${this.uniqueId}`).select();
    },
    focusMinute(){
      document.getElementById(`minuteInput${this.uniqueId}`).select();
    },

    switchFocus(event, location){
      let direction = event.key;
      if(direction === "ArrowRight" && location === "hour"){
        document.getElementById(`minuteInput${this.uniqueId}`).focus();
        document.getElementById(`minuteInput${this.uniqueId}`).select();
      }else if(direction === "ArrowLeft" && location === "minute"){
        document.getElementById(`hourInput${this.uniqueId}`).focus();
         document.getElementById(`hourInput${this.uniqueId}`).select();
      }else if(direction !== "ArrowRight"
        &&direction !== "ArrowLeft"
        &&direction !== "ArrowUp"
        &&direction !== "ArrowDown"
        &&direction !== "Backspace" 
        &&direction !== "Delete"
        &&(!event.shiftKey && event.key !== "Tab") && direction !== "Shift"
        && this.hoursValueInput.length > 1
        && document.activeElement.id === `hourInput${this.uniqueId}`) {
        // add #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng start
        document.getElementById(`minuteInput${this.uniqueId}`).focus();
        // add #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng end
        document.getElementById(`minuteInput${this.uniqueId}`).select();
      }
    },
    //mod FNSI-6669 劉全航 end

    /**
     * @description 時刻を表示用形式に変換
     */
    formatTimeValue(value = 0) {
      return value !== "" ? value.toString().padStart(2, "0") : "";
    },

    /**
     * @description 時に変更があった場合の処理
     */
    changeHoursValue(ev, newValue = this.defaultValue) {
      let value = ev ? ev.target.value : newValue;

      const oldValue = this.hoursValue;
      if (value !== "") {
        value = Number(value);
        if (value < this.minHoursValue) {
          value = this.minHoursValue;
        } else if (value > this.maxHoursValue) {
          value = this.maxHoursValue;
        }
  
        if (
          +this.minutesValue > this.minMinutesValue &&
          value === this.maxHoursValue
        ) {
          //FNSI-修正 #5658 横展開対応、xugj add start
          //value = this.maxHoursValue - 1;
          this.minutesValue = this.formatTimeValue(this.minMinutesValue);
          //FNSI-修正 #5658 横展開対応、xugj add end
        }
        this.hoursValue = this.formatTimeValue(value);
      } else {
        // 時が空入力の場合は時分をデフォルト値で補正
        this.hoursValue = this.defaultValue;
        // del #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng start
        // this.minutesValue = this.defaultValue;
        // del #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng end
      }
      
      if (this.hoursValue === oldValue) {
        this.$forceUpdate();
      }

      this.setEditValue();
    },

    /**
     * @description 分に変更があった場合の処理
     */
    changeMinutesValue(ev, newValue = this.defaultValue) {
      let value = ev ? ev.target.value : newValue;
      
      const oldValue = this.minutesValue;
      if (value !== "") {
        value = Number(value);
        //mod FNSI-6669 劉全航 start
        let length = value.toString().length;
        value = Number(value.toString().substring(length-2, length));
        //mod FNSI-6669 劉全航 end
        if (value < this.minMinutesValue) {
          value = this.minMinutesValue;
        } else if (value > this.maxMinutesValue) {
          value = this.maxMinutesValue;
        }
  
        if (+this.hoursValue === this.maxHoursValue) {
          value = this.minMinutesValue;
        }
  
        this.minutesValue = this.formatTimeValue(value);
      } else {
        // 分が空入力の場合は時分をデフォルト値で補正
        // del #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng start
        // this.hoursValue = this.defaultValue;
        // del #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng end
        this.minutesValue = this.defaultValue;
      }
      
      if (this.minutesValue === oldValue) {
        this.$forceUpdate();
      }

      this.setEditValue();
    },

    /**
     * @description マウスダウン時、値増やしを開始
     */
    startIncreaseValue() {
      this.stopIncreaseValue();
      const increaseValue = () => {
        this.isFocusMinutesInput
          ? this.changeMinutesValue(null, +this.minutesValue + 1)
          : this.changeHoursValue(null, +this.hoursValue + 1);
      };

      increaseValue();
      this.increaseTimeout = setTimeout(() => {
        this.increaseInterval = setInterval(() => {
          increaseValue();
        }, 30);
      }, 400);
    },

    /**
     * @description マウスアップ時、値増やしを停止
     */
    stopIncreaseValue() {
      clearTimeout(this.increaseTimeout);
      clearInterval(this.increaseInterval);
    },

    /**
     * @description マウスダウン時、値減らしを開始
     */
    startDecreaseValue() {
      this.stopDecreaseValue();
      const decreaseValue = () => {
        this.isFocusMinutesInput
          ? this.changeMinutesValue(null, +this.minutesValue - 1)
          : this.changeHoursValue(null, +this.hoursValue - 1);
      };

      decreaseValue();
      this.decreaseTimeout = setTimeout(() => {
        this.decreaseInterval = setInterval(() => {
          decreaseValue();
        }, 30);
      }, 400);
    },

    /**
     * @description マウスアップ時、値減らしを停止
     */
    stopDecreaseValue() {
      clearTimeout(this.decreaseTimeout);
      clearInterval(this.decreaseInterval);
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /** 
    * @description 時間(hour) inputイベントハンドラ
    * - 十字キーの上キー、下キー押下、マウスホイールのときに
    * - 入力された時間(hour)をminHoursValue, maxHoursValue指定範囲内の値で設定する
    */
    handleInputHour(event) {
      let value = event.target.value;
      if (value !== "") {
        if (this.doLoop) {
          if (value < this.minHoursValue) {
            value = this.maxHoursValue; // 下限超えは上限に
          } else if (value > this.maxHoursValue) {
            value = this.minHoursValue; // 上限超えは下限に
          }
        }
      } else {
        // 時が空入力の場合は時分をデフォルト値で補正
        value = this.defaultValue;
        // del #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng start
        // this.minutesValue = this.defaultValue;
        // del #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng end
      }
      this.hoursValue = value;
      this.hoursValueInput = value; // 頭0埋め前の入力値をフォーカス移動判定用に退避
      
      this.doLoop = false;
      
      this.setEditValue();
      this.$emit('input', this.editValue);
    },
    /** 
    * @description 分(minutes) inputイベントハンドラ
    * 入力された分(minutes)をminMinutesValue, maxMinutesValue指定範囲内の値で設定する
    */
    handleInputMinutes(event) {
      let value = event.target.value;
      if (value !== "") {
        // #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng start
        // if (value < this.minMinutesValue) {
        if (value <= this.minMinutesValue) {
          // 下限超えは上限に
          // value = this.maxMinutesValue;
          value = event.inputType ? "00" : this.maxMinutesValue;
        // #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng end  
        } else if (value > this.maxMinutesValue) {
          // 上限超えは下限に
          // #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng start
          // value = this.minMinutesValue;
          value = event.inputType ? this.maxMinutesValue : this.minMinutesValue;
        }
        if (event.inputType) {
          event.target.value = value;
        }
        // #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng end
      } else {
        // 分が空入力の場合は時分をデフォルトで補正
        // del #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng start
        // this.hoursValue = this.defaultValue;
        // del #12393 iPadでの患者経過総合ビューアの透析時間の入力改善 linjunfeng end
        value = this.defaultValue;
      }
      this.minutesValue = value;
      
      this.setEditValue();
      this.$emit('input', this.editValue);
    },
    /**
     * @description ピッカーループ、マウスホイールピッキング実施フラグ
     * - 十字キーの上キー、下キー押下、マウスホイールのときにフラグON
     */
    setDoLoop(event, mousewheel) {
      this.doLoop = mousewheel || event.key === "ArrowUp" || event.key === "ArrowDown";
    },
  },
  created() {
    if (this.editValue !== null) {
      this.hoursValue = this.formatTimeValue((this.editValue / 60) | 0);
      this.minutesValue = this.formatTimeValue(this.editValue % 60 | 0);
    }
  },
  // add 6668 治療時間が72時間まで入力できない 房 start
  watch: {
    editValue(){
      if (this.editValue !== null) {
        this.hoursValue = this.formatTimeValue((this.editValue / 60) | 0);
        this.minutesValue = this.formatTimeValue(this.editValue % 60 | 0);
      } else {
        this.hoursValue = this.defaultValue;
        this.minutesValue = this.defaultValue;
      }
    }
  },
  // add 6668 治療時間が72時間まで入力できない 房 end
  beforeDestroy() {
    this.stopIncreaseValue();
    this.stopDecreaseValue();
  }
};
</script>

<style scoped>
input {
  font-family: helvetica, arial, "hiragino kaku gothic pro", meiryo,
    "ms pgothic", sans-serif;
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);
  width: 20px;
  height: 26px !important;
  outline: 0;
  text-align: center;
  border-radius: 0 !important;
  border: none;
}

.time-span {
  border-radius: 3px;
  border: 2px inset;
  display: inline-flex;
  align-items: center;
  height: 28px;
  width: 70px;
  cursor: auto;
  background-color: #f7f7f7;
}

.custom-input-time-edited {
  border: 2px green solid;
  outline: 0;
}

.custom-input-time-required {
  color: black;
  background-color: #ffff99;
}

.custom-input-time-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 0.5);
}

.treatment-time {
  color: white;
  float: right;
  margin-top: 50%;
  margin-right: 12%;
}

.arrow-up {
  width: 0;
  height: 0;
  border-left: 5px solid transparent;
  border-right: 5px solid transparent;
  border-bottom: 5px solid #444444;
}

.arrow-down {
  width: 0;
  height: 0;
  border-left: 5px solid transparent;
  border-right: 5px solid transparent;
  border-top: 5px solid #444444;
}

.wrap-arrow-up {
  padding: 4px 3px 3px 3px;
}

.wrap-arrow-down {
  padding: 3px 3px 4px 3px;
}

.wrap-arrow-up:hover,
.wrap-arrow-down:hover {
  background-color: Silver;
}

input::-webkit-outer-spin-button,
input::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

input[type="number"] {
  -moz-appearance: textfield;
  border: none;
}

input:disabled {
  border-style: none !important;
  box-shadow: none !important;
}

/* add 6668 治療時間が72時間まで入力できない 房 start */
.div-dis-color {
  background-color: #ebebe4 !important;
}
/* add 6668 治療時間が72時間まで入力できない 房 start */
</style>
