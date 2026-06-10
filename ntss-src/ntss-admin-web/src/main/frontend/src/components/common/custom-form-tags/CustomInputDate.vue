<template>
  <span class="flex-span">
    <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
    <!--mod FNSI- 年に6桁を避ける 徐博 start-->
    <!-- <input
      type="date"
      :value="displayDateValue"
      :disabled="disabled"
      :class="classObject"
      @input="inputValue($event.target.value)"
      @blur="validateValue"
      @touchstart="focusInput"
      v-on="$listeners"
      max="9999-12-31"
    /> -->
    <date-input v-if="isShowClear"
      type="date"
      :value="displayDateValue"
      :disabled="disabled"
      :class="classObject"
      max="9999-12-31"
      @input="inputValue"
      @blur="validateValue"
      @touchstart="focusInput"
      v-on="$listeners"
      @handleClearInput="handleClearInput"
    />
    <input v-else
      type="date"
      :value="displayDateValue"
      :disabled="disabled"
      :class="classObject"
      @input="inputValue($event.target.value)"
      @blur="validateValue"
      @touchstart="focusInput"
      v-on="$listeners"
      max="9999-12-31"
    />
    <!--mod FNSI- 年に6桁を避ける 徐博 end-->
    <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
    <!--mod FNSI- 7778 limingyang start-->
    <common-calendar
      v-model="calendarValue"
      class="calender"
      :disabled="disabled"
      :birthday-mode="birthdayMode"
      :selected-dates="selectedDates"
      :disabled-dates="disabledDates"
      :disable-dates-before="disableDatesBefore"
      :disable-dates-after="disableDatesAfter"
      :cardDiff = "cardDiff"
    />
    <!--mod FNSI- 7778 limingyang end-->
  </span>
</template>

<script>
import moment from "moment";
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";
// 共通カレンダーコンポーネント
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
import DateInput from "@/components/common/DateInput.vue";
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
import {DATE_FORMAT, dateFormat } from "@/functions/common/DateTimeUtils.js"
/**
 * @description 共通日付入力タグ
 */
export default {
  components: {
    "common-calendar": commonCalender,
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
    "date-input": DateInput,
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  },

  mixins: [baseCustomForm],

  props: {
    // add 7778 limingyang start
     cardDiff: {
       type: Boolean,
       default: false
     },
     // add 7778 limingyang end
    disabled: {
      type: Boolean,
      default: false
    },

    /**
     * @description 生年月日モード
     * @summary カスタムカレンダーの初期値を75年前にする用
     */
    birthdayMode: {
      type: Boolean,
      default: false
    },

    /**
     * @description イベントあり日付
     */
    selectedDates: {
      type: [Array, Object],
      default: () => []
    },

    /**
     * @description 無効日付
     */
    disabledDates: {
      type: Array,
      default: () => []
    },
    /**
     * @description 指定日までの日付を無効
     */
    disableDatesBefore: {
      type: String,
      default: ""
    },

    /**
     * @description 指定日からの日付を無効
     */
    disableDatesAfter: {
      type: String,
      default: ""
    },

    /**
     * @description 日付選択時に呼ばれる関数
     */
    callBackFunc: {
      type: Function,
      default: () => {}
    },

    /**
     * @description 日付選択時に呼ばれる関数の引数リスト
     */
    arguments: {
      type: Object,
      default: () => {}
    },
    isShowClear: {
      type: Boolean,
      default: true
    }
  },

  data() {
    return {
      // 入力フィールドの値をクリアするかを判定するフラグ
      isClear: false,
      // Android端末であることを示すフラグ
      androidFlg: false,
      // iOS端末であることを示すフラグ
      iosFlg: false
    };
  },

  computed: {
    // DBの日付データの形式はYYYYMMDDなのでYYYY-MM-DDに変換
    displayDateValue() {
      // 年のみ、月のみ、日のみを入力してフォーカスアウトすると画面に値が表示されたままクリアされない。その場合は"defaultValue"を返すことで入力値をクリアする
      if (this.editValue === null && this.isClear) {
        return "defaultValue";
      }
      if (this.editValue === null && this.isRequired) {
        return dateFormat.format(new Date(), DATE_FORMAT);
      } else {
        return this.editValue === null
          ? null
          : moment(this.editValue).format("YYYY-MM-DD");
      }
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

  created() {
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }
  },

  methods: {
    handleClearInput() {
      this.editValue = null;
      this.isClear = false;
      this.callBackFunc !== {} && this.callBackFunc(this.editValue, this.arguments);
    },
    inputValue(value) {
      // YYYY-MM-DDで入力されるのでYYYYMMDDに変換
      // mod FNSI-徐博 start
      this.editValue = value === "" ? null : moment(value).format("YYYYMMDD");
      // 入力フィールドの値をクリアするかを判定するフラグを初期化
      this.isClear = false;

      // プロパティで受け取った関数を呼び出す
      if (this.callBackFunc !== {}) {
      // if (this.callBackFunc != {}) {
        this.callBackFunc(this.editValue, this.arguments);
      }
      // mod FNSI-徐博 end
    },

    /**
     * 全角入力や貼り付けなど
     * 最大値と最小値の間に値が含まれているかどうかをチェックし、
     * 範囲外なら最大／最小値に設定しなおす
     */
    validateValue(event) {
      let str = event.target.value;

      // 空入力、欠落入力の場合
      if (!str) {
        // 必須入力の場合はsysdateで補正
        if (this.isRequired) {
          this.$emit('input', "");
          this.$emit('blur', "");
          // "YYYY-MM-DD"形式の日付をセット
          str = dateFormat.format(new Date(), DATE_FORMAT);
          this.editValue = str;
        }
      } else {
        // 有効な入力値かつ入力制限値を超える場合：入力制限値に上書き
        if(this.editValue !== "" && this.editValue !== null){
          // 患者経過総合ビューア 身体情報
         // mod 6880 【S 14 _旅行透析テスト】患者情報：入外・転入出クリック日払い後に日付ページを選択せずにエラー zhou start
         //this.editValue = event.target.value

          let tempDate = "";
          if (event.target){
           tempDate = moment(event.target.value).format("YYYYMMDD");
          }else {
            tempDate = moment(event).format("YYYYMMDD");
         }
         this.editValue = isNaN(tempDate) ? null : tempDate;
         // 日付以外の場合は入力フィールドの値をクリア
         this.isClear = isNaN(tempDate);

         // mod 6880 【S 14 _旅行透析テスト】患者情報：入外・転入出クリック日払い後に日付ページを選択せずにエラー zhou end
         // 上限値を超える値:上限値をセット
         if(this.disableDatesAfter !== "" && this.disableDatesAfter < this.editValue){
           this.editValue = this.disableDatesAfter;
         }
         // 下限値未満の値：下限値をセット
         if(this.disableDatesBefore !== "" && this.disableDatesBefore > this.editValue){
           this.editValue = this.disableDatesBefore;
         }
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
  },
};
</script>

<style scoped>
input {
  font-family: helvetica, arial, "hiragino kaku gothic pro", meiryo,
    "ms pgothic", sans-serif;
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);
  font-size: inherit;
  display: inline-block;
  width: 85%;
  box-sizing: border-box;
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

.calender {
  font-size: 1em;
}

.flex-span {
  display: inline-flex;
}
/*add じょはく start*/
.custom-input-date-invalid {
  color: black;
  background-color: #FE3E3E;
}
/*add じょはく end*/
.custom-span-input-date {
  display: flex;
  align-items: center;
}
</style>
