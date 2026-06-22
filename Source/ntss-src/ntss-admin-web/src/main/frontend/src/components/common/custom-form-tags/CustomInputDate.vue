<template>
  <span class="flex-span">
    <date-input
      type="date"
      :value="displayDateValue"
      :disabled="disabled"
      :class="classObject"
      :classes="classes"
      :is-required="isRequired"
      max="9999-12-31"
      @input="inputValue"
      @blur="validateValue"
      @touchstart="focusInput"
      v-bind="$attrs"
      @handleClearInput="handleClearInput"
    />
    <common-calendar
      v-if="isCalendarMounted"
      ref="calendar"
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
    <button
      v-else
      type="button"
      class="ntss-btn-outset calendar calender"
      :disabled="disabled"
      :value="displayDateValue || ''"
      @click.stop.prevent="activateCalendar"
    >
      <v-ons-icon icon="fa-calendar" />
    </button>
  </span>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
// 共通タグ用ベースコンポーネント
import baseCustomForm from "@/components/common/custom-form-tags/BaseCustomForm";
// 共通カレンダーコンポーネント
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import DateInput from "@/components/common/DateInput.vue";
import { VOnsIcon } from "@/compat/onsen/components";
/**
 * @description 共通日付入力タグ
 */
export default {
  inheritAttrs: false,
  components: {
    "common-calendar": commonCalender,
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
    "date-input": DateInput,
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
    VOnsIcon
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
    },
    lazyCalendar: {
      type: Boolean,
      default: true
    }
  },

  data() {
    return {
      // Android端末であることを示すフラグ
      androidFlg: false,
      // iOS端末であることを示すフラグ
      iosFlg: false,
      isCalendarMounted: !this.lazyCalendar && !this.disabled
    };
  },

  computed: {
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
        // add じょはく start
        // データ不正時に適用されるclass
        "custom-input-date-invalid": !this.isValid
        // add じょはく end
      };
    },

    classes() {
      return [
        this.isRequired && "date-input-required",
        this.isEdited && "date-input-edited",
      ]
        .filter(Boolean)
        .join(" ");
    }
  },

  created() {
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }
  },

  watch: {
    disabled(value) {
      if (value) {
        this.isCalendarMounted = false;
      } else if (!this.lazyCalendar) {
        this.isCalendarMounted = true;
      }
    }
  },

  methods: {
    activateCalendar() {
      if (this.disabled) {
        return;
      }
      this.isCalendarMounted = true;
      this.$nextTick(() => {
        this.$refs.calendar?.openMenu?.();
      });
    },
    handleClearInput() {
      this.editValue = null;
      if (typeof this.callBackFunc === "function") {
        this.callBackFunc(this.editValue, this.arguments);
      }
    },
    inputValue(value) {
      // YYYY-MM-DDで入力されるのでYYYYMMDDに変換
      // mod FNSI-徐博 start
      this.editValue = value === "" ? null : dayjs(value).format("YYYYMMDD");

      // プロパティで受け取った関数を呼び出す
      if (typeof this.callBackFunc === "function") {
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

      if (str) {
        // 有効な入力値かつ入力制限値を超える場合：入力制限値に上書き
        if(this.editValue !== "" && this.editValue !== null){
          // 患者経過総合ビューア 身体情報
         // mod 6880 【S 14 _旅行透析テスト】患者情報：入外・転入出クリック日払い後に日付ページを選択せずにエラー zhou start
         //this.editValue = event.target.value

          const tempDate = event.target
            ? dayjs(event.target.value).format("YYYYMMDD")
            : dayjs(event).format("YYYYMMDD");
         this.editValue = isNaN(tempDate) ? null : tempDate;

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
        this.inputValue(dayjs()
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

/* ▼を消す */
.custom-input-date::-webkit-calendar-picker-indicator {
  display: none;
}
.custom-input-date{
  width: 100%;
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
  background-color: rgba(255, 0, 0, 0.5);
}
/*add じょはく end*/
.custom-span-input-date {
  display: flex;
  align-items: center;
}
</style>
