<template>
  <div class="flex-align-center">
    <!--mod FNSI-改修内容日付のチェックの追加対応。 任 start-->
    <!--<input
      type="date"
      :min="dateMin"
      :max="dateMax"
      v-model="inputModel.weekEndDate"
      class="input_date ntss-input-date"
    />-->
    <!--#10715:日付IF修正Start-->
    <!--#10715：日付IF修正20240910検証NG対応：村上(プロパティ不正) Start -->
    <input
      type="date"
      :min="dateMin"
      :max="dateMax"
      v-model="valueInput"
      id="inputdatetemp"
      class="input_date ntss-input-date"
      :class="[classObject,this.className]"
      :disabled="disabled"
      v-on="$listeners"
  	  @input="onInput($event)"
      @blur="onFocusOut($event)"
      @focus="onFocusIn($event)"
    />
    <!--#10715:日付IF修正End-->
    <!--#10715：日付IF修正20240910検証NG対応：村上(プロパティ不正) End -->
    <!--mod FNSI-改修内容日付のチェックの追加対応。 任 end-->
    <common-calendar
	  v-model="valueInput"
	  @input="inputEvent"
	  :disabled="disabled" />
  </div>
</template>

<script>
  import moment from "moment";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import BaseCustomInputStatus from '@/components/common/custom-form-tags/BaseCustomInputStatus.vue'
  //#10715：日付IF修正20240910検証NG対応：村上Start
  import {DATE_FORMAT, dateFormat } from "@/functions/common/DateTimeUtils.js";
  //#10715：日付IF修正20240910検証NG対応：村上End

  export default {
  mixins:[BaseCustomInputStatus],
	components:{
		"common-calendar": commonCalender,
	},
  props:{
    dateMin:{
      required:false
    },
    dateMax:{
      required:true
    },
    data:{
      required:true
    },
    className:{
      required:false,
	  type:String
    },
    functionArgs:{
      required:false
    },
	tempName:{
	  type:String,
	  required:true
	}
  },
  data() {
    return {
      hasFocus: false,
      hasInput: false,
      inputModel:{
        date:this.data
      }
    }
  },
  /*add FNSI-改修内容6186 任 start*/
  watch:{
    data(value){
      this.valueInput = value
      return value
    }
  },
  /*add FNSI-改修内容6186 任 end*/
  computed:{
	  // DBの日付データの形式はYYYYMMDDなのでYYYY-MM-DDに変換
	  displayDateValue() {
	    return this.editValue === null
	      ? null
	      : moment(this.editValue).format("YYYY-MM-DD");
	  },

	  calendarValue: {
	    get() {
	      return this.displayDateValue;
	    },

	    set(value) {
	      this.inputValue(value);
	    }
	  },

	  classObject() {
	    return {
	      // 常に適用されるclass
	      "custom-input-date": true,
	      // 編集時に適用されるclass
	      "custom-input-date-edited": this.isEdited,
	      // 必須項目に適用されるclass
	      "custom-input-date-required": this.isRequired,
	      // add じょはく start
	      // データ不正時に適用されるclass
	      "custom-input-date-invalid": !this.isValid
	      // add じょはく end
	    };
	  }
  },
  methods:{
    onFocusIn(event) {
      this.addFocusCss(event);
  	  if (this.tempName == 'tabTemp') {
        this.hasInput = false;
        this.hasFocus = true;
      }
    },
    onInput(event) {
  	  if (this.tempName == 'tabTemp') {
        if (!this.hasInput) {
          this.hasInput = true;
        }
      } else {
        this.inputEvent(event.target.value);
      }
    },
    onFocusOut(event) {
      //#10715：日付IF修正20240910検証NG対応：村上Start
      this.validateValue(event);
      //#10715：日付IF修正20240910検証NG対応：村上End
      if (this.tempName == 'tabTemp') {
        this.hasFocus = false;
        if (this.hasInput) {
          this.hasInput = false;
          this.inputEvent(event.target.value);
        }
      }
    },
    inputEvent(event){
  	  if (this.tempName == 'tabTemp' && this.hasFocus) return;
      /*mod FNSI-改修内容6186 任 start*/
      /*if(this.tempName == 'bbsTemp'){
        this.$parent.setEndNoticeValue(event)
      }*/
	  if(this.tempName == 'bbsTempnoticeStartDate'){
	    this.$parent.setStartNoticeValue(event)

	  }
	  if(this.tempName == 'bbsTempnoticeEndDate'){
      this.$parent.setEndNoticeValue(event)
    }
      /*mod FNSI-改修内容6186 任 end*/
	  if(this.tempName == 'tabTemp'){

		this.$emit('update:data',event)
		this.$parent.changeCondition(this.functionArgs)
	  }

    },
	/**
	 * 全角入力や貼り付けなど
	 * 最大値と最小値の間に値が含まれているかどうかをチェックし、
	 * 範囲外なら最大／最小値に設定しなおす
	 */
  //#10715：日付IF修正20240910検証NG対応：村上Start
	validateValue(event) {
  //#10715：日付IF修正20240910検証NG対応：村上End
    //#10715:日付IF修正Start
    //#10715：日付IF修正20240910検証NG対応：村上Start
    if((this.editValue == "" || this.editValue == null) && this.valueInput == null) {
    //#10715:日付IF修正End
      if (this.isRequired) {
        this.editValue = dateFormat.format(new Date(), DATE_FORMAT);
        event.target.value = this.editValue ;
      } else {
        //必須以外
        this.isValid = !this.isValid
      }
    }
    //#10715：日付IF修正20240910検証NG対応：村上End
	  // 有効な入力値かつ入力制限値を超える場合：入力制限値に上書き
	  if(this.editValue !== "" && this.editValue !== null){
	    // 上限値を超える値:上限値をセット
	    if(this.disableDatesAfter !== "" && this.disableDatesAfter < moment(this.editValue).format("YYYYMMDD")){
	      this.editValue = this.disableDatesAfter;
	    }
	    // 下限値未満の値：下限値をセット
	    if(this.disableDatesBefore !== "" && this.disableDatesBefore > moment(this.editValue).format("YYYYMMDD")){
	      this.editValue = this.disableDatesBefore;
	    }
	  }
	},
	// 生年月日入力モードかつAndroidまたはiOSの場合、
	// フォームタップで75年前の日付を表示
	focusInput() {
	  if (this.birthdayMode && !this.displayDateValue &&
	     (this.androidFlg || this.iosFlg)) {
	    this.inputValue(moment()
	        .subtract(75, "years")
	        .toDate())
	  }
	}
  }
}
</script>

<style scoped>
  input {
    color: #000000;
    background-color: var(--ntss-list-background-color);
  }

  .custom-input-date-edited {
    border: 2px green solid;
    outline: 0;
  }

  .custom-input-date-required {
    color: black;
    background-color: #ffff99;
  }
/* ▼を消す */
.custom-input-date::-webkit-calendar-picker-indicator {
  display: none;
}
  .custom-input-date-invalid {
    color: black;
    background-color: rgba(255, 0, 0, 0.5);
  }
</style>
