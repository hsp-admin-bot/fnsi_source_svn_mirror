<template>
  <span>
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
import { VOnsIcon } from "@/compat/onsen/components";

/**
 * @description 共通日付入力タグ
 */
export default {
  components: {
    "common-calendar": commonCalender,
    VOnsIcon
  },

  mixins: [baseCustomForm],

  props: {
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
    lazyCalendar: {
      type: Boolean,
      default: true
    },

  },

  data() {
    return {
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
        // 編集時に適用されるclass
        "custom-input-date-edited": this.isEdited,
        // 必須項目に適用されるclass
        "custom-input-date-required": this.isRequired
      };
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    isEdited() {
      return this.initValue !== this.editValue;
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
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
    inputValue(value) {
      // YYYY-MM-DDで入力されるのでYYYYMMDDに変換
      this.editValue = value === "" ? null : dayjs(value).format("YYYYMMDD");

      // プロパティで受け取った関数を呼び出す
      this.callBackFunc(this.editValue, this.arguments);
    },
  }
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
</style>
