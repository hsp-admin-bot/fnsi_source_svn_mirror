/**
 * 日付入力共通コンポーネント
 */
<template>
  <div>
    <v-ons-row class="date-time" :style="rowHeightStyle()">
      <v-ons-col class="title">
        <label class="theme">
          {{labelName}}
        </label>
      </v-ons-col>
      <v-ons-col class="date-value">
        <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
        <!-- <input
          class="ntss-input-date ntss-control-size"
          type="date"
          name="dateValue"
          v-model="currentDate"
          :disabled="disabled"
          @change="onChange"
          @blur="onBlur"
          v-validate.immediate="{required: this.isDateRequired}"
        /> -->
        <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
        <!-- <input
          :class="timeClass"
          class="ntss-input-date ntss-control-size"
          style="min-width: 7.7em;"
          type="date"
          name="dateValue"
          v-model="currentDate"
          :disabled="disabled"
          :max="maxValue"
          :id="dateID"
          @keyup="showMsg"
          @change="onChange"
          @blur="onBlur"
          v-validate.immediate="{required: this.isDateRequired}"
        /> -->
        <date-input
          :classes="'ntss-input-date ntss-control-size date-input-focus '+requiredClass +timeClass +inValidClass"
          style="min-width: 7.7em;"
          name="dateValue"
          v-model="currentDate"
          :disabled="disabled"
          :max="maxValue"
          :id="dateID"
          @keyup="showMsg"
          @change="onChange"
          @blur="onBlur"
          @handleClearInput="handleClearInput"
          :is-required="required"
        />
        <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
        <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
        <!-- add FNSI-日付書式の修正 徐 start -->
        <!-- <common-calendar v-model="currentDate" :disabled="disabled" @input="onChange; onBlur" /> -->
        <!-- add FNSI-日付書式の修正 徐 end -->
        <common-calendar v-model="currentDate" :disabled="disabled" @input="onChange" />
        <div v-if="timeVisible">
          <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
          <time-input
            :classes="'time-input-focus ' +requiredTimeClass +inputClass +inValidClass"
            type="time"
            name="timeValue"
            v-model="currentTime"
            :disabled="disabled"
            @input="onChange"
            @blur="onBlur"
            @handleClearInput="handleClearInputime"
            :is-required="required"
          />
          <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
        </div>
        <div v-if="appendix !== ''">
          <label class="appendix">
            {{ appendix }}
          </label>
        </div>
      </v-ons-col>
    </v-ons-row>
    <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
    <!-- <v-ons-row class="error-message-area" v-show="errors.has('dateValue') || errors.has('timeValue')"> -->
    <v-ons-row class="error-message-area" v-show="this.showErrorMsg || errors.has('dateValue') || errors.has('timeValue')">
    <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
      <v-ons-col class="title">
      </v-ons-col>
      <v-ons-col class="date-error">
        <span v-show="errors.has('dateValue')" class="error-message">
          {{ errors.first('dateValue') }}
        </span>
        <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
        <span v-show="this.showErrorMsg" class="error-message">
          {{ this.msgDiaLog }}
        </span>
        <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
      </v-ons-col>
      <v-ons-col class="date-error">
        <span v-show="errors.has('timeValue')" class="error-message">
          {{ errors.first('timeValue') }}
        </span>
      </v-ons-col>
    </v-ons-row>
  </div>
</template>

<script>
import {
  DATE_FORMAT,
  SHORT_TIME_FORMAT,
  dateFormat,
  parseDate
} from "@/functions/common/DateTimeUtils.js";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
// add FNSI-横展開 日付のチェックの追加 徐 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-横展開 日付のチェックの追加 徐 end
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
import DateInput from "@/components/common/DateInput.vue";
import TimeInput from "@/components/common/TimeInput.vue";
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end

export default {
  components: {
    "common-calendar": commonCalender,
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
    "date-input": DateInput,
    "time-input": TimeInput,
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  },
  props: {
    labelName: {
      type: String
    },
    value: {
      type: Date
    },
    disabled: {
      type: Boolean,
      default: false
    },
    timeVisible: {
      type: Boolean,
      default: true
    },
    required: {
      type: Boolean,
      default: true
    },
    // add FNSI-横展開 日付のチェックの追加 徐 start
    maxValue: {
      type: String,
      default: "9999-12-31"
    },
    dateID: {
      type: String,
      default: "dateID"
    },
    errorMsg: {
      type: Boolean,
      default: false
    },
    // add FNSI-横展開 日付のチェックの追加 徐 end
    rowHeight: {
      type: String,
      default: ""
    },
    isShowClear: {
      type: Boolean,
      default: false
    },
    // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
    initValue: {
      type: [Date, String],
    },
    // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
    isValid: {
      type: Boolean,
      default: true
    },
    /**
     * @description 付加情報 値を設定した場合は時刻フィールドの右横に表示されます
     */
    appendix: {
      type: [Number, String],
      default: ""
    }
  },
  data() {
    return {
      currentDate: this.value ? dateFormat.format(this.value, DATE_FORMAT) : null,
      currentTime: this.value && this.timeVisible ? dateFormat.format(this.value, SHORT_TIME_FORMAT) : null,
      // add FNSI-横展開 日付のチェックの追加 徐 start
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorMsg: false,
      // add FNSI-横展開 日付のチェックの追加 徐 end
      initDate: this.value ? dateFormat.format(this.value, DATE_FORMAT) : null,
      initTime: this.value && this.timeVisible ? dateFormat.format(this.value, SHORT_TIME_FORMAT) : null,
      // del #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
      // initDateFlag: null
      // del #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
    };
  },
  watch: {
    /**
     * 本コンポーネントに対するvalue(v-model)を監視し、変更された値を入力項目に反映する.
     */
    value(newVal, oldVal) {
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng start
      // this.currentDate = null;
      // this.currentTime = null;
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng end
      if (newVal) {
        this.currentDate = dateFormat.format(newVal, DATE_FORMAT);
        if (this.timeVisible === true) {
          this.currentTime = dateFormat.format(newVal, SHORT_TIME_FORMAT);
        }
      }
      //add #10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
      else if (newVal === null && this.initValue === null ){
        this.currentDate = newVal;
        if (this.timeVisible === true) {
          this.currentTime = newVal;
        }
      }
      //add #10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
      if (this.value && !this.initDate) {
        this.initDate = oldVal ? dateFormat.format(this.value, DATE_FORMAT) : null;
        if (this.timeVisible === true) {
          this.initTime = dateFormat.format(this.value, SHORT_TIME_FORMAT);
        }
      }
      // del #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
      // if (this.dateID == 'ctrMeasureDate') {
      //   this.initDate = this.$parent?.initModel?.ctrMeasureDate ? dateFormat.format(this.$parent?.initModel?.ctrMeasureDate , DATE_FORMAT) : null;
      // }
      // if (this.dateID == 'weightAfterDate' && !this.$parent?.initModel?.weightAfterDate) {
      //   this.initTime = this.$parent?.initModel?.weightAfterDate ? dateFormat.format(this.$parent?.initModel?.weightAfterDate, SHORT_TIME_FORMAT) : null
      // }
      // if (this.dateID == 'weightBeforeDate' && !this.$parent?.initModel?.weightBeforeDate) {
      //   this.initTime = this.$parent?.initModel?.weightBeforeDate ? dateFormat.format(this.$parent?.initModel?.weightBeforeDate, SHORT_TIME_FORMAT) : null
      // }
      // del #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
    }
  },
  computed: {
    isDateRequired() {
      // 日付のみの場合、バリデーションチェックしない
      if (!this.timeVisible) {
        return false;
      }
      return (
        this.required &&
        (!!this.currentTime || (!this.currentDate && !this.currentTime))
      );
    },
    isTimeRequired() {
      return this.required && !!this.currentDate;
    },
    inputClass(){
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
      // if (this.initTime == null && this.currentTime == "") {
      //   return "";
      // } else if (this.initTime != this.currentTime) {
      //   return "custom-input-edited";
      // } else {
      //   return "";
      // }
      
      let initTime = this.initValue ? dateFormat.format(this.initValue , SHORT_TIME_FORMAT) : null;
      if (this.initValue === undefined) {
        initTime = this.initTime;
      }
      if (!initTime && !this.currentTime) {
        return "";
      } else if (initTime !== this.currentTime) {
        return "custom-input-edited ";
      } else {
        return "";
      }
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
    },
    timeClass(){
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
      // if (this.initDate == null && this.currentDate == "") {
      //   return "";
      // } else if (this.initDate != this.currentDate) {
      //   return "time-input-edited";
      // } else {
      //   return "";
      // }
      let initDate = this.initValue ? dateFormat.format(this.initValue , DATE_FORMAT) : null;
      if (this.initValue === undefined) {
        initDate = this.initDate;
      }
      if (!initDate && !this.currentDate) {
        return "";
      } else if (initDate !== this.currentDate) {
        return "time-input-edited ";
      } else {
        return "";
      }
      // #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
    },
    requiredClass(){
      if (this.required) {
        return "date-input-required ";
      } else {
        return "";
      }
    },
    requiredTimeClass(){
      if (this.required) {
        return "time-input-required ";
      } else {
        return "";
      }
    },
    inValidClass(){
      if (!this.isValid) {
        return "input-date-invalid ";
      } else {
        return "";
      }
    }
  },
  methods: {
    // 内部 日付没入,データ登録できました start
    handleClearInput () {
      this.currentDate = null
      this.$emit("handleCurrentDateChange", this.currentDate);
      this.$emit('handleClearInput')
    },
    handleClearInputime () {
      this.currentTime = null
      this.$emit("handleCurrentTimeChange", this.currentTime);
      this.$emit('handleClearInput')
    },
    // 内部 日付没入,データ登録できました end
    /**
     * 日時の入力値を返す.
     */
    getDateVal() {
      let dateVal = null;
      if (this.timeVisible === true) {
        // 日付＋時刻を設定
        dateVal =
          this.currentDate && this.currentTime
            ? parseDate(this.currentDate, this.currentTime)
            : null;
      } else {
        // 日付のみを設定
        dateVal = this.currentDate
          ? parseDate(this.currentDate, "00:00")
          : null;
      }
      return dateVal;
    },
    /**
     * Changeイベント発火時に、Inputイベントを発火させ、入力内容を反映させる.
     */
    onChange() {
      // add FNSI-横展開 日付のチェックの追加 徐 start
      // this.$emit("input", this.getDateVal());
      let dateValueFlg = false;
      if (this.currentDate) {
        if (Number(this.currentDate.replace(/-/g, "")) <= 19700101) {
          dateValueFlg = false;
        } else {
          dateValueFlg = true;
        }
      }
      //mod FNSI-治療記録外結バッグ71 房 start
      if (dateValueFlg || this.currentDate == "") {
        //mod FNSI-治療記録外結バッグ71 房 end
        this.$emit("input", this.getDateVal());
      }
      // add FNSI-横展開 日付のチェックの追加 徐 end
      // 内部 日付没入,データ登録できました start
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng start
      // this.$emit("handleCurrentTimeChange", this.currentDate);
      // this.$emit("handleCurrentDateChange", this.currentTime);
      this.$emit("handleCurrentDateChange", this.currentDate ? this.currentDate: null);
      this.$emit("handleCurrentTimeChange", this.currentTime ? this.currentTime: null);
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng end
      // 内部 日付没入,データ登録できました end
    },
    /**
     * Blurイベント発火時に、blurイベントを発火させ、入力内容を反映させる.
     */
    onBlur() {
      // add FNSI-横展開 日付のチェックの追加 徐 start
      // this.$emit("blur", this.getDateVal());
      let dateValueFlg = false;
      if (this.currentDate) {
        if (Number(this.currentDate.replace(/-/g, "")) <= 19700101) {
          dateValueFlg = false;
        } else {
          dateValueFlg = true;
        }
      }
      if (dateValueFlg) {
        this.$emit("blur", this.getDateVal());
      }
      // add FNSI-横展開 日付のチェックの追加 徐 end
      // 内部 日付没入,データ登録できました start
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng start
      // this.$emit("handleCurrentTimeChange", this.currentDate);
      // this.$emit("handleCurrentDateChange", this.currentTime);
      this.$emit("handleCurrentDateChange", this.currentDate ? this.currentDate: null);
      this.$emit("handleCurrentTimeChange", this.currentTime ? this.currentTime: null);
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng end
      // 内部 日付没入,データ登録できました end
    },
    // add FNSI-横展開 日付のチェックの追加 徐 start
    showMsg() {
      let dateValue = {
          name: this.dateID,
          id: this.dateID,
          scope: this.dateID
        };
      if (this.currentDate && document.getElementById(this.dateID).validationMessage) {
        this.$validator.errors.items.push(dateValue);
        if (this.errorMsg) {
          this.showErrorMsg = true;
        }
      } else {
        this.$validator.errors.removeById(this.dateID);
        if (this.errorMsg) {
          this.showErrorMsg = false;
        }
      }
    },
    // add FNSI-横展開 日付のチェックの追加 徐 end
    rowHeightStyle() {
      if (this.rowHeight) {
        return { 'height': this.rowHeight };
      } else {
        return null;
      }
    },
    // #10044 時刻の時分どちらか一方でも消すと日付も消える linjunfeng start
    clearDateTime() {
      if (!this.value) {
        this.currentDate = null;
        this.currentTime = null;
        this.initDate = null;
        this.initTime = null;
      }
    }
    // #10044 時刻の時分どちらか一方でも消すと日付も消える linjunfeng end
  },
  // add FNSI-横展開 日付のチェックの追加 徐 start
  destroyed() {
    this.$validator.errors.removeById("startDate");
    this.$validator.errors.removeById("endDate");
    this.$validator.errors.removeById("weightBeforeDate");
    this.$validator.errors.removeById("ctrMeasureDate");
    this.$validator.errors.removeById("weightAfterDate");
  }
  // add FNSI-横展開 日付のチェックの追加 徐 end
};
</script>

<style scoped>
.treatment-record-accordion ons-col.date-error {
  flex: 0 0 15.5em;
  white-space: nowrap;
  display: flex;
  align-items: flex-start;
}
.error-message-area {
  height: 2em;
}
.custom-input-edited >>> input {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.time-input-edited {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
div >>> .input-date-invalid {
  color: black;
  background-color: #ff6666 !important;
}
.appendix {
  padding-left: 15px;
}
</style>
