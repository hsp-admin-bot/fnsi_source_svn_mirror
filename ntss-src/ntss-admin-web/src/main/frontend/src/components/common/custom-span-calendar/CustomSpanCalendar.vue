<template>
  <VueDatePicker
    ref="datePicker"
    v-model="internalDate"
    v-bind="$attrs"
    class="ntss-custom-span-calendar-picker"
    :locale="jaLocale"
    :format-locale="jaLocale"
    :week-start="1"
    :day-names="dayNames"
    :multi-calendars="multiCalendars"
    :disabled-dates="isDateDisabled"
    :filters="dateFilters"
    :min-date="minDate"
    :max-date="maxDate"
    :disabled="isDisabled"
    :clearable="false"
    :teleport="true"
    :centered="true"
    :transitions="false"
    :menu-id="menuOwnerId"
    :ui="datePickerUi"
    auto-apply
    :config="datePickerConfig"
    @update:model-value="handleModelUpdate"
    @update-month-year="handleCalendarMonthYearUpdate"
    @open="handleOpen"
    @closed="handleClosed"
  >

      <template #month-year="{ month, year, months, years, updateMonthYear, handleMonthYearChange }">
        <div class="ntss-calendar-month-year">
          <button
            type="button"
            class="dp__btn dp--arrow-btn-nav ntss-calendar-nav ntss-calendar-nav-prev"
            data-dp-element="action-prev"
            @click.stop.prevent="handleCalendarMonthYearNav(false, handleMonthYearChange)"
          ></button>
          <div class="ntss-calendar-month-year-title">
            <label
              class="pika-label ntss-calendar-month-year-label ntss-calendar-year-label"
              @pointerdown.stop
              @mousedown.stop
              @click.stop="openCalendarLabelSelect"
            >
              <span>{{ year }}年</span>
              <select
                class="ntss-calendar-month-year-select ntss-calendar-year-select"
                :value="year"
                @pointerdown.stop
                @mousedown.stop
                @mouseup.stop
                @click.stop
                @keydown.stop
                @change.stop="handleCalendarYearSelect($event, updateMonthYear, month)"
              >
                <option
                  v-for="option in getCalendarYearSelectOptions(years)"
                  :key="`year-${option.value}`"
                  :value="option.value"
                >
                  {{ option.text }}
                </option>
              </select>
            </label>
            <label
              class="pika-label ntss-calendar-month-year-label ntss-calendar-month-label"
              @pointerdown.stop
              @mousedown.stop
              @click.stop="openCalendarLabelSelect"
            >
              <span>{{ getCalendarMonthText(month, months) }}</span>
              <select
                class="ntss-calendar-month-year-select ntss-calendar-month-select"
                :value="month"
                @pointerdown.stop
                @mousedown.stop
                @mouseup.stop
                @click.stop
                @keydown.stop
                @change.stop="handleCalendarMonthSelect($event, updateMonthYear, year)"
              >
                <option
                  v-for="option in getCalendarSelectOptions(months)"
                  :key="`month-${option.value}`"
                  :value="option.value"
                >
                  {{ option.text }}
                </option>
              </select>
            </label>
          </div>
          <button
            type="button"
            class="dp__btn dp--arrow-btn-nav ntss-calendar-nav ntss-calendar-nav-next"
            data-dp-element="action-next"
            @click.stop.prevent="handleCalendarMonthYearNav(true, handleMonthYearChange)"
          ></button>
        </div>
      </template>

    <template #trigger>
      <span
        class="treatment-summary custom-span-calendar-trigger"
        :class="computedClasses"
      >
        {{ valueInput }}
      </span>
    </template>

    <template #day="{ day, date }">
      <span :class="[getDayClasses(date),istype?'ntss-calendar-day-zljl':'']">{{ day }}</span>
    </template>

    <template v-if="!viewMode" #action-buttons>
      <button
        type="button"
        class="ntss-calendar-today-btn"
        :disabled="isTodayDisabled"
        @click.stop="selectToday"
      >
        今日
      </button>
    </template>
  </VueDatePicker>
</template>

<script>
import {
  VueDatePicker,
  createVueDatePickerConfig
} from "@/compat/datepicker/vue-datepicker";
import {
  alignVueDatePickerMenuToTrigger,
  attachVueDatePickerMenuLayoutGuard,
  installDatePickerMenuFlashGuard,
  resetVueDatePickerMenuLayout
} from "@/components/common/custom-calendar/date-picker-menu-layout";
import "../custom-calendar/vue-datepicker-overlay-compat.css";
import { ja } from "@/compat/date/date-fns";
import { mapGetters, mapState } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import { getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

const DAY_NAMES = ["月", "火", "水", "木", "金", "土", "日"];
let customSpanCalendarInstanceSeq = 0;

const toArray = value => {
  if (Array.isArray(value)) {
    return value;
  }
  return [];
};

const flattenSelectOptions = value => {
  return toArray(value).reduce((result, item) => {
    if (Array.isArray(item)) {
      result.push(...item);
    } else if (item !== null && item !== undefined) {
      result.push(item);
    }
    return result;
  }, []);
};

const normalizeKey = value => {
  if (value === null || value === undefined || value === "") {
    return "";
  }

  if (value instanceof Date) {
    return dayjs(value).format("YYYYMMDD");
  }

  const text = `${value}`.trim();
  if (/^\d{8}$/.test(text)) {
    return text;
  }

  const parsed = dayjs(text);
  return parsed.isValid() ? parsed.format("YYYYMMDD") : "";
};

const parseDate = value => {
  const key = normalizeKey(value);
  if (!key) {
    return null;
  }

  const parsed = dayjs(key, "YYYYMMDD");
  return parsed.isValid() ? parsed.toDate() : null;
};

const formatOutput = value => {
  const date = parseDate(value);
  return date ? dayjs(date).format("YYYY-MM-DD") : "";
};

export default {
  components: {
    VueDatePicker
  },
  inheritAttrs: false,
  props: {
    modelValue: {
      type: [String, Date],
      default: undefined
    },
    value: {
      type: [String, Date],
      default: ""
    },
    dateShowInput: {
      type: String,
      default: ""
    },
    disabledDates: {
      type: Array,
      default: () => []
    },
    disabledNotExistDates: {
      type: Array,
      default: () => []
    },
    disabledWeekdays: {
      type: Array,
      default: () => []
    },
    numberOfMonths: {
      type: Number,
      default: 1
    },
    selectedDates: {
      type: [Array, Object],
      default: () => []
    },
    isDisabledPastDates: {
      type: Boolean,
      default: false
    },
    disableDatesBefore: {
      type: String,
      default: ""
    },
    disableDatesAfter: {
      type: String,
      default: ""
    },
    birthdayMode: {
      type: Boolean,
      default: false
    },
    viewMode: {
      type: Boolean,
      default: false
    },
    disablefacility: {
      type: Object,
      default: () => ({})
    },
    classes: {
      type: String,
      default: ""
    },
    istype:{
      type: Boolean,
      default: false
    }
  },
  emits: ["update:modelValue", "inputCalendar", "spanCalendarOpen", "spanCalendarClose"],
  data() {
    return {
      internalDate: null,
      menuLayoutGuardCleanup: null,
      menuPositionSnapshot: null,
      calendarViewMonth: null,
      calendarViewYear: null,
      menuOwnerId: `ntss-custom-span-calendar-${++customSpanCalendarInstanceSeq}`
    };
  },
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapState("treatment-record/common", ["ordNoDataSourcesState"]),
    jaLocale() {
      return ja;
    },
    externalValue() {
      return this.modelValue !== undefined ? this.modelValue : this.value;
    },
    selectedDatesComputed() {
      return Array.isArray(this.selectedDates)
        ? { default: this.selectedDates }
        : (this.selectedDates || {});
    },
    defaultSelectedDateKeys() {
      return toArray(this.selectedDatesComputed.default).map(normalizeKey).filter(Boolean);
    },
    defaultSelectedDateKeySet() {
      return new Set(this.defaultSelectedDateKeys);
    },
    defaultSelectedDateCounts() {
      return this.defaultSelectedDateKeys.reduce((result, key) => {
        result[key] = (result[key] || 0) + 1;
        return result;
      }, {});
    },
    customSelectedDateKeys() {
      return new Set(toArray(this.selectedDatesComputed.custom).map(normalizeKey).filter(Boolean));
    },
    disabledDateKeys() {
      return new Set(toArray(this.disabledDates).map(normalizeKey).filter(Boolean));
    },
    existingDateKeys() {
      return new Set(toArray(this.disabledNotExistDates).map(normalizeKey).filter(Boolean));
    },
    dateFilters() {
      return {
        weekDays: toArray(this.disabledWeekdays).map(value => {
          const weekday = Number(value);
          return weekday === 7 ? 0 : weekday;
        })
      };
    },
    multiCalendars() {
      if (!this.numberOfMonths || this.numberOfMonths <= 1) {
        return false;
      }

      return {
        count: this.numberOfMonths,
        static: true
      };
    },
    minDate() {
      const values = [];

      if (this.isDisabledPastDates) {
        values.push(dayjs().startOf("day"));
      }

      const before = parseDate(this.disableDatesBefore);
      if (before) {
        values.push(dayjs(before).startOf("day"));
      }

      if (!values.length) {
        return null;
      }

      return values.reduce((latest, current) => {
        return current.isAfter(latest) ? current : latest;
      }).toDate();
    },
    maxDate() {
      const after = parseDate(this.disableDatesAfter);
      return after ? dayjs(after).startOf("day").toDate() : null;
    },
    computedClasses() {
      const classList = [];
      if (this.classes !== "") {
        classList.push(...this.classes.split(" "));
      }
      return classList;
    },
    valueInput() {
      if (this.dateShowInput) {
        return this.dateShowInput.replace(/-/g, "/");
      }

      const formatted = formatOutput(this.externalValue);
      return formatted ? formatted.replace(/-/g, "/") : "";
    },
    isDisabled() {
      const disabled = this.$attrs.disabled;
      return disabled === "" || disabled === true || disabled === "true" || disabled === 1 || disabled === "1";
    },
    datePickerConfig() {
      return createVueDatePickerConfig({ keepActionRow: !this.viewMode });
    },
    datePickerUi() {
      return {
        menu: ["ntss-custom-calendar-panel"]
      };
    },
    dayNames() {
      return DAY_NAMES;
    },
    isTodayDisabled() {
      return this.isCalendarRuleDisabled(new Date());
    }
  },
  watch: {
    externalValue: {
      immediate: true,
      handler(value) {
        this.internalDate = parseDate(value);
      }
    }
  },
  mounted() {
    installDatePickerMenuFlashGuard(this.$el);
    // birthdayMode かつ 値未入力時は 75 年前を初期表示
    if (this.birthdayMode && (this.externalValue === null || this.externalValue === "" || this.externalValue === undefined)) {
      this.internalDate = dayjs().subtract(75, "year").toDate();
    }
    // #6119 Vue2 相当：ウィンドウリサイズ時の windowWidth 更新。メニューは再度開いた際に再配置される。
    this._windowResizeHandler = () => {
      this._lastWindowWidth = getScopedWindow(this.$el || this)?.innerWidth || 0;
    };
    getScopedWindow(this.$el || this)?.addEventListener("resize", this._windowResizeHandler);
  },
  beforeUnmount() {
    this.clearAlignMenuTimer();
    this.clearMenuLayoutGuard();
    this.resetMenuLayout();
    this.$refs.datePicker?.closeMenu?.();
    if (this._windowResizeHandler) {
      getScopedWindow(this.$el || this)?.removeEventListener("resize", this._windowResizeHandler);
      this._windowResizeHandler = null;
    }
  },
  methods: {
    getCalendarSelectOptions(options) {
      return flattenSelectOptions(options);
    },
    getCalendarYearSelectOptions(options) {
      const currentYear = dayjs().year();
      const firstYear = currentYear - 100;
      const lastYear = currentYear + 100;
      const normalizedOptions = flattenSelectOptions(options);
      const optionByYear = normalizedOptions.reduce((result, option) => {
        const value = Number(option && typeof option === "object" ? option.value : option);
        if (Number.isFinite(value)) {
          result[value] = option;
        }
        return result;
      }, {});

      return Array.from({ length: lastYear - firstYear + 1 }, (_, index) => {
        const value = firstYear + index;
        const option = optionByYear[value];
        if (option && typeof option === "object") {
          return {
            ...option,
            value,
            text: option.text || `${value}`
          };
        }
        return { value, text: `${value}` };
      });
    },
    getCalendarMonthText(month, months) {
      const monthValue = Number(month);
      const option = this.getCalendarSelectOptions(months).find(item => Number(item?.value) === monthValue);
      return option?.text || `${monthValue + 1}月`;
    },
    normalizeCalendarMonth(month) {
      const normalized = Number(month);
      if (!Number.isFinite(normalized)) {
        return null;
      }
      return normalized > 11 ? normalized - 1 : normalized;
    },
    setCalendarVisibleMonthYear(month, year) {
      const normalizedMonth = this.normalizeCalendarMonth(month);
      const normalizedYear = Number(year);
      if (!Number.isFinite(normalizedMonth) || !Number.isFinite(normalizedYear)) {
        return;
      }
      this.calendarViewMonth = normalizedMonth;
      this.calendarViewYear = normalizedYear;
    },
    getCalendarVisibleMonthDate() {
      if (this.calendarViewMonth === null || this.calendarViewYear === null) {
        return null;
      }
      return dayjs().year(this.calendarViewYear).month(this.calendarViewMonth).date(1).startOf("day");
    },
    isDateOutsideVisibleMonth(date) {
      const visibleMonth = this.getCalendarVisibleMonthDate();
      if (!visibleMonth) {
        return false;
      }
      const dateMonth = dayjs(date).date(1).startOf("day");
      const visibleMonths = Math.max(1, Number(this.numberOfMonths) || 1);
      const lastVisibleMonth = visibleMonth.add(visibleMonths - 1, "month");
      return dateMonth.isBefore(visibleMonth, "month") || dateMonth.isAfter(lastVisibleMonth, "month");
    },
    handleCalendarMonthYearUpdate(value, year) {
      if (value && typeof value === "object") {
        this.setCalendarVisibleMonthYear(value.month, value.year);
      } else {
        this.setCalendarVisibleMonthYear(value, year);
      }
      this.alignMenu();
    },
    handleCalendarMonthYearNav(isNext, handleMonthYearChange) {
      const visibleMonth = this.getCalendarVisibleMonthDate();
      if (visibleMonth) {
        const nextMonth = visibleMonth.add(isNext ? 1 : -1, "month");
        this.setCalendarVisibleMonthYear(nextMonth.month(), nextMonth.year());
      }
      if (typeof handleMonthYearChange === "function") {
        handleMonthYearChange(isNext, true);
      }
      this.alignMenu();
    },
    openCalendarLabelSelect(event) {
      const select = event?.currentTarget?.querySelector?.("select");
      this.openCalendarSelect({ target: select });
    },
    openCalendarSelect(event) {
      const select = event?.target;
      if (!select || typeof select.showPicker !== "function") {
        return;
      }
      try {
        select.showPicker();
      } catch (e) {
        // Native select may already be opened by the browser. Keep Vue2/Pikaday behavior.
      }
    },
    closeCalendarSelect(event) {
      const select = event?.target;
      this.$nextTick(() => {
        try {
          select?.blur?.();
        } catch (e) {
          // Native select blur is best-effort only.
        }
        this.alignMenu();
      });
    },
    handleCalendarYearSelect(event, updateMonthYear, month) {
      const year = Number(event?.target?.value);
      const normalizedMonth = this.normalizeCalendarMonth(month);
      if (Number.isFinite(year) && Number.isFinite(normalizedMonth)) {
        this.setCalendarVisibleMonthYear(normalizedMonth, year);
        if (typeof updateMonthYear === "function") {
          updateMonthYear(normalizedMonth, year, false);
        }
      }
      this.closeCalendarSelect(event);
    },
    handleCalendarMonthSelect(event, updateMonthYear, year) {
      const month = this.normalizeCalendarMonth(event?.target?.value);
      const normalizedYear = Number(year);
      if (Number.isFinite(month) && Number.isFinite(normalizedYear)) {
        this.setCalendarVisibleMonthYear(month, normalizedYear);
        if (typeof updateMonthYear === "function") {
          updateMonthYear(month, normalizedYear, false);
        }
      }
      this.closeCalendarSelect(event);
    },
    clearAlignMenuTimer() {
      if (this._alignMenuTimer) {
        clearTimeout(this._alignMenuTimer);
        this._alignMenuTimer = null;
      }
    },
    resetMenuLayout() {
      resetVueDatePickerMenuLayout(this.$el, this.menuOwnerId);
    },
    clearMenuLayoutGuard() {
      if (typeof this.menuLayoutGuardCleanup === "function") {
        this.menuLayoutGuardCleanup();
      }
      this.menuLayoutGuardCleanup = null;
    },
    installMenuLayoutGuard() {
      this.clearMenuLayoutGuard();
      this.$nextTick(() => {
        this.menuLayoutGuardCleanup = attachVueDatePickerMenuLayoutGuard({
          root: this.$el,
          trigger: this.$el?.querySelector?.('.custom-span-calendar-trigger'),
          ownerId: this.menuOwnerId,
          close: () => this.$refs.datePicker?.closeMenu?.(),
          realign: () => this.alignMenuNow()
        });
      });
    },
    alignMenuNow() {
      return alignVueDatePickerMenuToTrigger({
        root: this.$el,
        trigger: this.$el?.querySelector?.('.custom-span-calendar-trigger'),
        numberOfMonths: this.numberOfMonths,
        positionSnapshot: this.menuPositionSnapshot,
        ownerId: this.menuOwnerId,
        onPositionResolved: position => {
          if (!this.menuPositionSnapshot) {
            this.menuPositionSnapshot = position;
          }
        }
      });
    },
    alignMenu() {
      // Vue2 Pikaday 実装 toggleDatePickerVisibility の DOM 補正と同等。
      // 単月：ボタン右側に十分な幅がある場合は右側へ表示し、上下は近いエッジに合わせる。
      // 複数月：ボタン右側へ表示し、上下はボタン中央基準、下端が画面を超える場合は上方向へ補正。
      // Vue3 DatePicker は月送り後に menu wrapper の style を再計算するため、
      // redraw 後にも固定配置を再適用して Vue2 Pikaday と同じく親 popover の中へ流れ込ませない。
      this.$nextTick(() => {
        this.clearAlignMenuTimer();
        const realign = () => this.alignMenuNow();
        realign();
        this._alignMenuTimer = setTimeout(() => {
          this._alignMenuTimer = null;
          realign();
          const ownerWindow = this.$el?.ownerDocument?.defaultView || globalThis.window || null;
          ownerWindow?.requestAnimationFrame?.(realign);
          setTimeout(realign, 32);
        }, 0);
      });
    },
    handleOpen() {
      this.menuPositionSnapshot = null;
      if (this.dateShowInput) {
        this.internalDate = parseDate(this.dateShowInput);
      }
      const calendarOpenDate = parseDate(this.dateShowInput) || parseDate(this.externalValue) || this.internalDate || new Date();
      this.setCalendarVisibleMonthYear(dayjs(calendarOpenDate).month(), dayjs(calendarOpenDate).year());
      this.$emit("spanCalendarOpen");
      this.alignMenuNow();
      this.alignMenu();
      this.installMenuLayoutGuard();
    },
    handleClosed() {
      this.menuPositionSnapshot = null;
      this.clearAlignMenuTimer();
      this.clearMenuLayoutGuard();
      this.resetMenuLayout();
      this.$emit("spanCalendarClose");
    },
    handleModelUpdate(value) {
      if (!value) {
        this.internalDate = null;
        return;
      }
      if (this.isDateOutsideVisibleMonth(value)) {
        this.$refs.datePicker?.setMonthYear?.({
          month: this.calendarViewMonth,
          year: this.calendarViewYear
        });
        return;
      }
      this.internalDate = value;
      const formatted = formatOutput(value);
      this.$emit("update:modelValue", formatted);
      this.$emit("inputCalendar", formatted);
    },
    isCalendarWeekdayDisabled(date) {
      const day = dayjs(date).day();
      return toArray(this.disabledWeekdays).some(value => {
        const weekday = Number(value);
        if (!Number.isFinite(weekday)) {
          return false;
        }
        return (weekday === 7 ? 0 : weekday) === day;
      });
    },
    isCalendarRuleDisabled(date) {
      const key = normalizeKey(date);
      if (!key) {
        return false;
      }

      if (this.viewMode) {
        return true;
      }

      if (this.isCalendarWeekdayDisabled(date)) {
        return true;
      }

      if (this.disabledDateKeys.has(key)) {
        return true;
      }

      // Vue2 オリジナル挙動：disabledNotExistDates に含まれない日付は無効。
      // 空配列時は全日付が無効（V2 と同じ挙動）。呼び出し側(TreatmentSummaryComponent)は
      // データ投入後に使用する前提のため、この挙動を維持する。
      if (!this.existingDateKeys.has(key)) {
        return true;
      }

      if (this.minDate && dayjs(date).isBefore(this.minDate, "day")) {
        return true;
      }

      if (this.maxDate && dayjs(date).isAfter(this.maxDate, "day")) {
        return true;
      }

      return false;
    },
    isDateDisabled(date) {
      if (this.isDateOutsideVisibleMonth(date)) {
        return true;
      }

      return this.isCalendarRuleDisabled(date);
    },
    hasOtherFacility(key) {
      const facilities = toArray(this.disablefacility[key]);
      return facilities.filter(otherFacility => otherFacility !== this.getFacilityCd).length > 0;
    },
    hasOtherFacilityOrdNoDataSource(key) {
      return toArray(this.ordNoDataSourcesState).some(item =>
        item?.treatDate === key && item?.facilityCd !== this.getFacilityCd
      );
    },
    getDayClasses(date) {
      const key = normalizeKey(date);
      const hasDuplicate = (this.defaultSelectedDateCounts[key] || 0) > 1 && this.hasOtherFacility(key);
      const hasOtherFacilityOrdNo = this.hasOtherFacilityOrdNoDataSource(key);

      return {
        "ntss-calendar-day": true,
        "custom-span-selected": this.defaultSelectedDateKeySet.has(key) && !hasDuplicate,
        "custom-span-double-selected": hasDuplicate || hasOtherFacilityOrdNo,
        "has-custom-event": this.customSelectedDateKeys.has(key),
        "ntss-calendar-disabled": this.isDateDisabled(date)
      };
    },
    selectToday() {
      if (this.isTodayDisabled) {
        return;
      }

      const today = new Date();
      this.internalDate = today;
      const formatted = formatOutput(today);
      this.$emit("update:modelValue", formatted);
      this.$emit("inputCalendar", formatted);
      this.$refs.datePicker?.closeMenu();
    }
  }
};
</script>

<style scoped>
:deep(.dp--menu-wrapper) {
  position: fixed !important;
  right: auto !important;
  bottom: auto !important;
  transform: none !important;
  margin: 0 !important;
  z-index: 2147483647 !important;
}

.ntss-custom-span-calendar-picker {
  display: inline-block !important;
  width: auto !important;
  /* vertical-align: middle; */
}

:deep(.ntss-custom-span-calendar-picker > div) {
  display: inline-block !important;
  width: auto !important;
}

button {
  padding: 0px;
  border: none;
}

/* Vue2 Pikaday final corner/nav alignment.
   Keep the strict @vuepic layout mapping above, then only refine the details
   that differ from Vue2 Pikaday: smaller panel corner radius and CSS triangle
   navigation buttons. */
:where(.ntss-custom-calendar-menu .dp__menu, .dp__menu.ntss-custom-calendar-panel) {
  border-radius: 3px !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__menu_inner,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__instance_calendar,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_row {
  border-radius: 0 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav {
  color: transparent !important;
  opacity: 1 !important;
  overflow: hidden !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav .dp__inner_nav,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav .dp__icon {
  display: none !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav::before {
  content: "";
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  transform: translate(-50%, -50%);
  opacity: .55;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav[data-dp-element="action-prev"]::before {
  margin-left: -1px;
  border-top: 5px solid transparent;
  border-bottom: 5px solid transparent;
  border-right: 6px solid #566f7f;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav[data-dp-element="action-next"]::before {
  margin-left: 1px;
  border-top: 5px solid transparent;
  border-bottom: 5px solid transparent;
  border-left: 6px solid #566f7f;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav:hover::before {
  opacity: .8;
}



/* Vue2 Pikaday parity fine tuning after replacing @vuepic overlay with native select.
   Keep selectable displayed-month day text black until it is actually selected or hovered. */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover) {
  color: #333333 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover) .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover) .ntss-calendar-day {
  color: #333333 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select option {
  font-family: Helvetica Neue, Helvetica, Arial, Osaka, Meiryo, sans-serif!important;
  color: #000000 !important;
  font-weight: 100!important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select option:checked {
  color: #ffffff !important;
}

</style>

<style>
.ntss-custom-calendar-menu {
  position: fixed !important;
  right: auto !important;
  bottom: auto !important;
  transform: none !important;
  margin: 0 !important;
  z-index: 2147483647 !important;
}

.ntss-custom-calendar-menu .dp__selection_preview,
.ntss-custom-calendar-menu .dp--tp-wrap,
.ntss-custom-calendar-menu .dp__arrow_top,
.ntss-custom-calendar-menu .dp__action_row .dp__button {
  display: none !important;
}

.ntss-custom-calendar-menu .dp__menu {
  width: 240px;
  min-width: 240px;
  max-width: 240px;
  border: 1px solid #a8a8a8;
  border-radius: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

.ntss-custom-calendar-menu .dp--header-wrap {
  background: linear-gradient(#4fa6d4, #2f8dbc);
  color: #ffffff;
  padding: 0 2px;
  min-height: 30px;
}

.ntss-custom-calendar-menu .dp__month_year_wrap {
  width: 100%;
}

.ntss-custom-calendar-menu .dp--header-wrap > .dp__month_year_wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 4px;
}

.ntss-custom-calendar-menu .dp--header-wrap > .dp__month_year_wrap > .dp__month_year_wrap {
  display: flex;
  flex: 1 1 auto;
  justify-content: center;
  align-items: center;
  flex-direction: row-reverse;
  gap: 0.25em;
}

.ntss-custom-calendar-menu .dp__btn.dp--arrow-btn-nav,
.ntss-custom-calendar-menu .dp__btn.dp__month_year_select {
  background: transparent;
  color: #ffffff;
  border: 0;
  box-shadow: none;
  min-height: 30px;
}

.ntss-custom-calendar-menu .dp__btn.dp__month_year_select {
  font-weight: 700;
  padding: 0 4px;
}

.ntss-custom-calendar-menu .dp__calendar_header {
  padding: 0 2px;
  min-height: 26px;
}

.ntss-custom-calendar-menu .dp__calendar_header_item {
  color: #666666;
  font-weight: 700;
  font-size: 12px;
  line-height: 26px;
  height: 26px;
}

.ntss-custom-calendar-menu .dp__calendar_header_separator {
  display: none;
}

.ntss-custom-calendar-menu .dp__calendar {
  padding: 0 2px 2px;
}

.ntss-custom-calendar-menu .dp__calendar_row {
  margin: 0;
  min-height: 34px;
}

.ntss-custom-calendar-menu .dp__calendar_item {
  line-height: 1;
  min-height: 34px;
}

.ntss-custom-calendar-menu .dp__cell_inner {
  border-radius: 0;
  width: 28px;
  height: 28px;
  min-height: 28px;
  padding: 0;
  line-height: 28px;
  margin: 1px auto;
  font-size: 12px;
}

.ntss-custom-calendar-menu .dp__active_date {
  background: #3296db;
}

.ntss-custom-calendar-menu .dp__action_row {
  justify-content: flex-start;
  min-height: 0;
  padding: 4px 8px 4px;
  border-top: 0;
}

.ntss-custom-calendar-menu .dp__action_buttons {
  margin-left: 0;
}

.ntss-custom-calendar-menu .ntss-calendar-today-btn {
  min-width: 38px;
  height: 30px;
  padding: 0 10px;
  border: 1px solid #9f9f9f;
  background: #f5f5f5;
  color: #333333;
}

.dp__menu.ntss-custom-calendar-panel:not(.ntss-custom-calendar-panel-ready) {
  visibility: hidden;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__selection_preview,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--tp-wrap,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__arrow_top,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_row .dp__button {
  display: none !important;
}

:where(.ntss-custom-calendar-menu .dp__menu, .dp__menu.ntss-custom-calendar-panel) {
  width: 240px;
  min-width: 240px;
  max-width: 240px;
  border: 1px solid #a8a8a8;
  border-radius: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap {
  background: linear-gradient(#4fa6d4, #2f8dbc);
  color: #ffffff;
  padding: 0 2px;
  min-height: 30px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__month_year_wrap {
  width: 100%;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap > .dp__month_year_wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 4px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap > .dp__month_year_wrap > .dp__month_year_wrap {
  display: flex;
  flex: 1 1 auto;
  justify-content: center;
  align-items: center;
  flex-direction: row-reverse;
  gap: 0.25em;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp__month_year_select {
  background: transparent;
  color: #ffffff;
  border: 0;
  box-shadow: none;
  min-height: 30px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp__month_year_select {
  font-weight: 700;
  padding: 0 4px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_header {
  padding: 0 2px;
  min-height: 26px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_header_item {
  color: #666666;
  font-weight: 700;
  font-size: 12px;
  line-height: 26px;
  height: 26px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_header_separator {
  display: none;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar {
  padding: 0 2px 2px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_row {
  margin: 0;
  min-height: 34px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_item {
  line-height: 1;
  min-height: 34px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner {
  border-radius: 0;
  width: 28px;
  height: 28px;
  min-height: 28px;
  padding: 0;
  line-height: 28px;
  margin: 1px auto;
  font-size: 12px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__active_date {
  background: #3296db;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_row {
  justify-content: flex-start;
  min-height: 0;
  padding: 4px 8px 4px;
  border-top: 0;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_buttons {
  margin-left: 0;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-today-btn {
  min-width: 38px;
  height: 30px;
  padding: 0 10px;
  border: 1px solid #9f9f9f;
  background: #f5f5f5;
  color: #333333;
}


/* Vue2 Pikaday visual compatibility for teleported @vuepic/vue-datepicker menus. */
:where(.ntss-custom-calendar-menu .dp__menu, .dp__menu.ntss-custom-calendar-panel) {
  border-radius: 7.5px;
  box-sizing: border-box;
  font-size: 12px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__menu_inner {
  padding: 0;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap {
  min-height: 28px;
  height: 28px;
  padding: 0;
  background-color: var(--ntss-calendar-title-label-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%, transparent 50%, transparent 50%, rgba(0,0,0,.1) 100%);
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap > .dp__month_year_wrap {
  gap: 0;
  height: 28px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap > .dp__month_year_wrap > .dp__month_year_wrap {
  flex: 0 1 auto;
  width: auto;
  gap: 10px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp__month_year_select {
  min-height: 28px;
  height: 28px;
  line-height: 28px;
  padding: 0 4px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp__month_year_select {
  flex: 0 0 auto;
  width: auto;
  font-size: 14px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_header {
  min-height: 22px;
  height: 22px;
  padding: 0 2px;
  margin: 0;
  background-color: var(--ntss-calendar-header-background-color);
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_header_item {
  height: 22px;
  line-height: 22px;
  padding: 0;
  font-size: 12px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar {
  padding: 0 2px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_row,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_item {
  min-height: 24px;
  height: 24px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner {
  width: 28px;
  height: 22px;
  min-height: 22px;
  line-height: 22px;
  margin: 0 auto;
  font-size: 12px;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_offset,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_disabled {
  color: #c5c5c5;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner:hover {
  background-color: var(--ntss-calendar-button-hover-background-color);
  text-decoration: underline;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-day {
  display: block;
  width: 100%;
  height: 100%;
  line-height: inherit;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .has-custom-event {
  background-color: #9acd32;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .custom-span-selected {
  background: #00b050;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .custom-span-double-selected {
  background: #adff2f;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-disabled {
  opacity: 0.75;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_row {
  display: block;
  min-height: 40px;
  height: 40px;
  padding: 0;
  border: 1px solid var(--ntss-calendar-button-footer-border-color);
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_buttons {
  display: inline-block;
  margin: 0;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-today-btn {
  min-width: 0;
  height: auto;
  margin: 8px;
  padding: 3px;
  line-height: 15px;
  color: var(--ntss-calendar-button-goto-today-color);
  background: var(--ntss-calendar-button-goto-today-background-color);
  border: 1px solid var(--ntss-calendar-button-goto-today-border-color);
  border-radius: 0;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-today-btn:disabled {
  opacity: .25;
}

/* Strict Vue2 Pikaday computed-style compatibility for @vuepic/vue-datepicker. */
:where(.ntss-custom-calendar-menu .dp__menu, .dp__menu.ntss-custom-calendar-panel) {
  --dp-font-size: 12px !important;
  --dp-menu-padding: 0 !important;
  --dp-row-margin: 0 !important;
  --dp-cell-size: 24px !important;
  --dp-cell-padding: 0 !important;
  --dp-cell-border-radius: 0 !important;
  --dp-month-year-row-height: 30px !important;
  box-sizing: border-box !important;
  border: 1px solid #aaa !important;
  border-radius: 7.5px !important;
  background: #fff !important;
  color: #333 !important;
  font-size: 12px !important;
  line-height: normal !important;
  overflow: hidden !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__menu_inner,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__instance_calendar,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar > div[role="grid"],
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar[role="rowgroup"] {
  box-sizing: border-box !important;
  margin: 0 !important;
  padding: 0 !important;
  width: 100% !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap {
  box-sizing: border-box !important;
  position: relative !important;
  height: 30px !important;
  min-height: 30px !important;
  max-height: 30px !important;
  margin: 0 !important;
  padding: 0 !important;
  background-color: var(--ntss-calendar-title-label-background-color) !important;
  background-image: linear-gradient(rgba(255,255,255,.3) 0%, transparent 50%, transparent 50%, rgba(0,0,0,.1) 100%) !important;
  color: var(--ntss-calendar-title-label-color) !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap > .dp__month_year_wrap {
  position: relative !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  width: 100% !important;
  height: 30px !important;
  min-height: 30px !important;
  margin: 0 !important;
  padding: 0 26px !important;
  gap: 0 !important;
  box-sizing: border-box !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap > .dp__month_year_wrap > .dp__month_year_wrap {
  display: flex !important;
  flex: 0 1 auto !important;
  flex-direction: row-reverse !important;
  align-items: center !important;
  justify-content: center !important;
  width: auto !important;
  height: 30px !important;
  min-height: 30px !important;
  gap: 6px !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav {
  position: absolute !important;
  top: 0 !important;
  width: 26px !important;
  height: 30px !important;
  min-width: 26px !important;
  min-height: 30px !important;
  margin: 0 !important;
  padding: 0 !important;
  border: 0 !important;
  background: transparent !important;
  color: #888 !important;
  opacity: .65 !important;
  box-shadow: none !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav:first-child {
  left: 0 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav:last-child {
  right: 0 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__inner_nav,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__icon {
  width: 16px !important;
  height: 16px !important;
  min-width: 16px !important;
  min-height: 16px !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp__month_year_select {
  flex: 0 0 auto !important;
  width: auto !important;
  min-width: 0 !important;
  height: 30px !important;
  min-height: 30px !important;
  margin: 0 !important;
  padding: 5px 3px !important;
  border: 0 !important;
  background: transparent !important;
  color: var(--ntss-calendar-title-label-color) !important;
  box-shadow: none !important;
  font-size: 14px !important;
  font-weight: 700 !important;
  line-height: 20px !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp__month_year_select[data-dp-element="overlay-year"]::after {
  content: "年";
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_header {
  display: flex !important;
  box-sizing: border-box !important;
  width: 100% !important;
  height: 25px !important;
  min-height: 25px !important;
  max-height: 25px !important;
  margin: 0 !important;
  padding: 0 !important;
  background-color: var(--ntss-calendar-header-background-color) !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_header_item {
  flex: 1 1 calc(100% / 7) !important;
  box-sizing: border-box !important;
  width: calc(100% / 7) !important;
  height: 25px !important;
  min-height: 25px !important;
  margin: 0 !important;
  padding: 0 !important;
  color: #999 !important;
  font-size: 12px !important;
  font-weight: 700 !important;
  line-height: 25px !important;
  text-align: center !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_header_separator {
  display: none !important;
  height: 0 !important;
  min-height: 0 !important;
  margin: 0 !important;
  padding: 0 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_row {
  display: flex !important;
  box-sizing: border-box !important;
  width: 100% !important;
  height: 25px !important;
  min-height: 25px !important;
  max-height: 25px !important;
  margin: 0 !important;
  padding: 0 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_item {
  flex: 1 1 calc(100% / 7) !important;
  box-sizing: border-box !important;
  width: calc(100% / 7) !important;
  height: 25px !important;
  min-height: 25px !important;
  max-height: 25px !important;
  margin: 0 !important;
  padding: 0 !important;
  line-height: 25px !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner {
  display: block !important;
  box-sizing: border-box !important;
  width: 100% !important;
  height: 25px !important;
  min-height: 25px !important;
  max-height: 25px !important;
  margin: 0 !important;
  padding: 5px !important;
  border: 0 !important;
  border-radius: 0 !important;
  background: transparent !important;
  color: #666 !important;
  font-size: 12px !important;
  font-weight: 400 !important;
  line-height: 15px !important;
  text-align: right !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_offset,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled {
  color: #c5c5c5 !important;
  opacity: 1 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:hover,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:hover {
  background-color: var(--ntss-calendar-button-hover-background-color) !important;
  text-decoration: underline !important;
  box-shadow: inset 0 1px 3px var(--ntss-calendar-button-hover-background-color)!important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner{
  font-family: Helvetica Neue, Helvetica, Arial, sans-serif!important;
}
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-title{
  font-family: Helvetica Neue, Helvetica, Arial, sans-serif!important;
}



:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__today:not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(.dp__cell_disabled):not(.dp__cell_offset) {
  color: #33aaff !important;
  font-weight: 700 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__range_start,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__range_end {
  background: #33aaff !important;
  color: #fff !important;
  font-weight: 700 !important;
  box-shadow: none !important;
  border-radius: 3px !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__range_start .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__range_end .ntss-calendar-day {
  color: #fff !important;
  font-weight: 700 !important;
}
/* 日历选中日期的样式 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date{
  background: #33aaff !important;
  color: #fff !important;
  border-radius: 3px !important;
  box-shadow: inset 0 1px 3px #178fe5 !important;
}
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date:has(.ntss-calendar-day.custom-span-selected) {
  background: #00b050 !important;
}
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:has(.ntss-calendar-day.custom-span-selected){
  background-color: #00b050 !important;
  border-radius: 3px !important;
  box-shadow: inset 0 1px 3px #0076c9 !important;
}
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:has(.ntss-calendar-day.custom-span-selected):hover{
  background-color: #00b050 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-day {
  display: block !important;
  width: 100% !important;
  height: 100% !important;
  line-height: inherit !important;
  text-align: inherit !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .has-custom-event {
  background-color: #9acd32 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .custom-span-selected {
  background: #00b050 !important;
  box-shadow: none !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .custom-span-double-selected {
  background: #adff2f !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-disabled {
  opacity: .75 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_row {
  display: block !important;
  box-sizing: border-box !important;
  width: 100% !important;
  height: 48px !important;
  min-height: 48px !important;
  max-height: 48px !important;
  margin: 0 !important;
  padding: 0 !important;
  border: 1px solid var(--ntss-calendar-button-footer-border-color) !important;
  background: #fff !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_buttons {
  display: block !important;
  width: 100% !important;
  height: 100% !important;
  margin: 0 !important;
  padding: 0 !important;
  text-align: left !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-today-btn {
  display: inline-block !important;
  box-sizing: border-box !important;
  width: auto !important;
  min-width: 0 !important;
  height: auto !important;
  min-height: 0 !important;
  margin: 9px 10px !important;
  padding: 6.5px 5.5px !important;
  border: 1px solid var(--ntss-calendar-button-goto-today-border-color) !important;
  border-radius: 0 !important;
  background: var(--ntss-calendar-button-goto-today-background-color) !important;
  color: var(--ntss-calendar-button-goto-today-color) !important;
  font-size: 13.333px !important;
  line-height: 15px !important;
  text-align: center !important;
  cursor: pointer !important;
  outline: none !important;
  font-family: 'Microsoft YaHei' !important;
  font-size: 1.25em !important;
}


/* Vue2 Pikaday final corner/nav alignment.
   Keep the strict @vuepic layout mapping above, then only refine the details
   that differ from Vue2 Pikaday: smaller panel corner radius and CSS triangle
   navigation buttons. */
:where(.ntss-custom-calendar-menu .dp__menu, .dp__menu.ntss-custom-calendar-panel) {
  border-radius: 3px !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__menu_inner,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__instance_calendar,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp--header-wrap,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_row {
  border-radius: 0 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav {
  color: transparent !important;
  opacity: 1 !important;
  overflow: hidden !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav .dp__inner_nav,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav .dp__icon {
  display: none !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav::before {
  content: "";
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  transform: translate(-50%, -50%);
  opacity: .55;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav[data-dp-element="action-prev"]::before {
  margin-left: -1px;
  border-top: 5px solid transparent;
  border-bottom: 5px solid transparent;
  border-right: 6px solid #566f7f;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav[data-dp-element="action-next"]::before {
  margin-left: 1px;
  border-top: 5px solid transparent;
  border-bottom: 5px solid transparent;
  border-left: 6px solid #566f7f;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav:hover::before {
  opacity: .8;
}


/* Vue2 Pikaday final color alignment.
   Keep Vue3 DatePicker DOM, but match the color tone of Pikaday's
   navigation arrows and weekday header. */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav::before {
  opacity: .85 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav[data-dp-element="action-prev"]::before {
  border-right-color: #25485a !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav[data-dp-element="action-next"]::before {
  border-left-color: #25485a !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__btn.dp--arrow-btn-nav:hover::before {
  opacity: .95 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__calendar_header_item {
  color: #999 !important;
  opacity: 1 !important;
  text-decoration: none !important;
  /* text-decoration-line: underline !important;
  text-decoration-style: dotted !important;
  text-decoration-color: rgba(153, 153, 153, .65) !important;
  text-decoration-thickness: 1px !important;
  text-underline-offset: 2px !important; */
}




/* Vue2 Pikaday parity fine tuning after replacing @vuepic overlay with native select.
   Keep selectable displayed-month day text black until it is actually selected or hovered. */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover) {
  color: #333333 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover) .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover) .ntss-calendar-day {
  color: #333333 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select option {
  color: #000000 !important;
  font-family: Helvetica Neue, Helvetica, Arial, Osaka, Meiryo, sans-serif!important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select option:checked {
  color: #ffffff !important;
}
.ntss-calendar-month-year .ntss-calendar-nav-next:hover::before{
  border-left-color: #000000 !important;
}
.ntss-calendar-month-year .ntss-calendar-nav-prev:hover::before{
  border-right-color: #000000 !important;
}

.dp__menu.ntss-custom-calendar-panel {
  --ntss-span-day-text-color: #666666!important; 
}

.dp__menu.ntss-custom-calendar-panel .dp__cell_inner:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover),
.dp__menu.ntss-custom-calendar-panel .dp__cell_inner:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover) .ntss-calendar-day {
  color: var(--ntss-span-day-text-color) !important;
  font-family: Helvetica Neue, Helvetica, Arial, Osaka, Meiryo, sans-serif!important;
}

.dp__menu.ntss-custom-calendar-panel .dp__cell_inner:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__today):not(.dp__range_start):not(.dp__range_end):not(:hover) .ntss-calendar-day.custom-span-selected{
  color: #fff !important;
  font-weight: 700 !important;
}
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) :has(.ntss-calendar-day-zljl){
  background-color:  #f2f8fd; 
}
</style>
