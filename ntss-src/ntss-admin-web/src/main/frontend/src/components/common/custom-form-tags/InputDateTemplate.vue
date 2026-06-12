<template>
  <div class="flex-align-center">
    <date-input
      :min="dateMin"
      :max="dateMax"
      v-model="valueInput"
      id="inputdatetemp"
      class="input_date ntss-input-date"
      :classes="[...Object.keys(classObject).filter(key => classObject[key]), this.className].join(' ')"
      :disabled="disabled"
      v-bind="$attrs"
  	  @input="onInput($event)"
      @blur="onFocusOut($event)"
      @focus="onFocusIn($event)"
      :is-required="isRequired"
    />
    <common-calendar
	  v-model="valueInput"
	  @input="inputEvent"
	  :disabled="disabled" />
  </div>
</template>

<script>
  import dayjs from "@/compat/date/dayjs";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import BaseCustomInputStatus from '@/components/common/custom-form-tags/BaseCustomInputStatus.vue'
  import { findAncestorWithMethod } from "@/functions/common/ComponentOwnerResolver";
  import DateInput from "@/components/common/DateInput";

  export default {
  inheritAttrs: false,
  mixins:[BaseCustomInputStatus],
	components:{
		"common-calendar": commonCalender,
    "date-input": DateInput,
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
      },
      initialized: false
    }
  },
  mounted() {
    if (!this.functionArgs) {
      this.initValue = this.editValue = this.inputModel.date;
    }
  },
  /*add FNSI-改修内容6186 任 start*/
  watch:{
    data(value){
      if (!this.initialized) {
        if (!this.functionArgs && this.initValue === null && this.editValue === null) {
          this.initValue = this.editValue = value;
        }
      }
      this.initialized = true;

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
	      : dayjs(this.editValue).format("YYYY-MM-DD");
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
	      "date-input-edited": !this.functionArgs ? this.isEdited : false,
	      // 必須項目に適用されるclass
	      "date-input-required": this.isRequired,
	      // add じょはく start
	      // データ不正時に適用されるclass
	      "custom-input-date-invalid": !this.isValid
	      // add じょはく end
	    };
	  }
  },
  methods:{
    resolveTemplateOwner() {
      return findAncestorWithMethod(this, ["changeCondition"], { maxDepth: 12 }) ||
        findAncestorWithMethod(this, ["setStartNoticeValue"], { maxDepth: 12 }) ||
        findAncestorWithMethod(this, ["setEndNoticeValue"], { maxDepth: 12 }) ||
        this;
    },
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
        this.inputEvent(event);
      }
    },
    onFocusOut(event) {
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
        this.resolveTemplateOwner()?.setEndNoticeValue?.(event)
      }*/
	  if(this.tempName == 'bbsTempnoticeStartDate'){
	    this.resolveTemplateOwner()?.setStartNoticeValue?.(event)

	  }
	  if(this.tempName == 'bbsTempnoticeEndDate'){
      this.resolveTemplateOwner()?.setEndNoticeValue?.(event)
    }
      /*mod FNSI-改修内容6186 任 end*/
	  if(this.tempName == 'tabTemp'){

		this.$emit('update:data',event)
		this.resolveTemplateOwner()?.changeCondition?.(this.functionArgs)
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

</style>
