<template>
  <span class="ntss-custom-calendar-host">
    <VueDatePicker
      ref="datePicker"
      v-model="internalDate"
      class="ntss-custom-calendar-picker"
      v-bind="datePickerAttrs"
      :locale="jaLocale"
      :format-locale="jaLocale"
      :week-start="1"
      :day-names="dayNames"
      :multi-calendars="multiCalendars"
      :disabled-dates="isDateDisabled"
      :filters="dateFilters"
      :markers="calendarMarkers"
      :min-date="minDate"
      :max-date="maxDate"
      :disabled="isDisabled"
      :clearable="false"
      :enable-time-picker="false"
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
              @pointerdown.stop.prevent
              @mousedown.stop.prevent
              @click.stop.prevent="openCalendarLabelSelect"
            >
              <span>{{ year }}年</span>
              <select
                class="ntss-calendar-month-year-select ntss-calendar-year-select"
                :value="year"
                @pointerdown.stop.prevent="openCalendarSelect"
                @mousedown.stop.prevent="handleCalendarSelectPointerDown"
                @mouseup.stop
                @click.stop
                @keydown.stop
                @wheel.stop
                @focus.stop="handleCalendarSelectFocus"
                @blur.stop="handleCalendarSelectBlur"
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
              @pointerdown.stop.prevent
              @mousedown.stop.prevent
              @click.stop.prevent="openCalendarLabelSelect"
            >
              <span>{{ getCalendarMonthText(month, months) }}</span>
              <select
                class="ntss-calendar-month-year-select ntss-calendar-month-select"
                :value="month"
                @pointerdown.stop.prevent="openCalendarSelect"
                @mousedown.stop.prevent="handleCalendarSelectPointerDown"
                @mouseup.stop
                @click.stop
                @keydown.stop
                @wheel.stop
                @focus.stop="handleCalendarSelectFocus"
                @blur.stop="handleCalendarSelectBlur"
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
        <button
          :class="triggerClass"
          :style="triggerStyle"
          :title="triggerTitle"
          :value="externalValue || ''"
          class="ntss-btn-outset calendar"
          ref="button"
          onfocus="(function(e){e.stopImmediatePropagation()})(event)"
          :disabled="isDisabled"
          @blur="handleBlur"
        >
          <v-ons-icon icon="fa-calendar" />
        </button>
      </template>

      <template #day="{ day, date }">
        <span :ref="el => bindDayCellClasses(el, date)" :class="getDayClasses(date)">{{ day }}</span>
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
  </span>
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
import "./vue-datepicker-overlay-compat.css";
import { ja } from "@/compat/date/date-fns";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { VOnsIcon } from "@/compat/onsen/components";
import { getScopedDocument, getScopedElementsByClassName, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

const DAY_NAMES = ["月", "火", "水", "木", "金", "土", "日"];
let customCalendarInstanceSeq = 0;

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
    VueDatePicker,
    VOnsIcon
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
    disabledDates: {
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
    toMonth: {
      type: String,
      default: ""
    },
    viewMode: {
      type: Boolean,
      default: false
    },
    cardDiff: {
      type: Boolean,
      default: false
    },
    activeDate: {
      type: Boolean,
      default: false
    },
    /**
     * 初回投与日など、minDate より前でも「今日」を選べるようにする。
     * 日付セル・今日ボタンとも minDate（disable-dates-before）を今日だけ無視する。
     */
    enableTodayButton: {
      type: Boolean,
      default: false
    }
  },
  emits: ["update:modelValue", "input", "blur", "todayButtonClick"],
  data() {
    return {
      internalDate: null,
      editCell: null,
      initValue: null,
      isMenuOpen: false,
      alignMenuTimer: null,
      menuLayoutGuardCleanup: null,
      menuPositionSnapshot: null,
      calendarViewMonth: null,
      calendarViewYear: null,
      menuOwnerId: `ntss-custom-calendar-${++customCalendarInstanceSeq}`,
      menuReady: false,
      hasOpenedMenu: false
    };
  },
  computed: {
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
      return new Set(toArray(this.selectedDatesComputed.default).map(normalizeKey).filter(Boolean));
    },
    customSelectedDateKeys() {
      return new Set(toArray(this.selectedDatesComputed.custom).map(normalizeKey).filter(Boolean));
    },
    disabledDateKeys() {
      return new Set(toArray(this.disabledDates).map(normalizeKey).filter(Boolean));
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
    calendarMarkers() {
      // 背景色ハイライト利用時は marker（赤点）を使わない
      if (this.useSpanDateHighlight) {
        return [];
      }

      return [...this.defaultSelectedDateKeys]
        .map(parseDate)
        .filter(Boolean)
        .map(date => ({
          date,
          type: "dot"
        }));
    },
    useSpanDateHighlight() {
      if (this.viewMode) {
        return true;
      }

      if (!Array.isArray(this.selectedDates)) {
        return true;
      }

      return this.defaultSelectedDateKeys.size > 0;
    },
    isDisabled() {
      const disabled = this.$attrs.disabled;
      return disabled === "" || disabled === true || disabled === "true" || disabled === 1 || disabled === "1";
    },
    datePickerAttrs() {
      const attrs = { ...(this.$attrs || {}) };
      delete attrs.class;
      delete attrs.style;
      delete attrs.title;
      delete attrs.disabled;
      return attrs;
    },
    triggerClass() {
      return this.$attrs.class;
    },
    triggerStyle() {
      return this.$attrs.style;
    },
    triggerTitle() {
      return this.$attrs.title;
    },
    datePickerConfig() {
      return createVueDatePickerConfig({ keepActionRow: !this.viewMode });
    },
    datePickerUi() {
      return {
        menu: [
          "ntss-custom-calendar-panel",
          !this.menuReady
            ? "ntss-calendar-hidden"
            : ""
        ]
      };
    },
    dayNames() {
      return DAY_NAMES;
    },
    isTodayDisabled() {
      if (!this.enableTodayButton) {
        return this.isCalendarRuleDisabled(dayjs().startOf("day").toDate());
      }
      const today = dayjs().startOf("day").toDate();
      if (this.viewMode) {
        return true;
      }
      if (this.isCalendarWeekdayDisabled(today)) {
        return true;
      }
      if (this.maxDate && dayjs(today).isAfter(this.maxDate, "day")) {
        return true;
      }
      return false;
    }
  },
  watch: {
    externalValue: {
      immediate: true,
      handler(value) {
        const parsed = parseDate(value);
        this.internalDate = this.resolveInternalDate(value);
        if (parsed) {
          this.setCalendarVisibleMonthYear(dayjs(parsed).month(), dayjs(parsed).year());
        }
      }
    },
    toMonth(value) {
      if (this.isMenuOpen) {
        this.moveCalendar(value);
      }
    },
    selectedDates: {
      deep: true,
      handler() {
        if (this.isMenuOpen) {
          this.scheduleSyncAllDayCellClasses();
        }
      }
    },
    viewMode() {
      if (this.isMenuOpen) {
        this.scheduleSyncAllDayCellClasses();
      }
    }
  },
  created() {
    this._calendarNativeSelectOpen = false;
    this._calendarNativeSelectReleaseTimer = null;
    installDatePickerMenuFlashGuard(this.$el);
  },
  mounted() {
    this.editCell = this.getEditCell();
  },
  updated() {
    if (this.isMenuOpen) {
      this.scheduleSyncAllDayCellClasses();
    }
  },
  beforeUnmount() {
    this.clearAlignMenuTimer();
    this.clearCalendarNativeSelectReleaseTimer();
    this.clearMenuLayoutGuard();
    if (this.isMenuOpen || this.hasOpenedMenu) {
      this.resetMenuLayout();
      this.$refs.datePicker?.closeMenu?.();
    }
    if (this._windowResizeHandler) {
      getScopedWindow(this.$el || this)?.removeEventListener("resize", this._windowResizeHandler);
      this._windowResizeHandler = null;
    }
  },
  methods: {
    openMenu() {
      this.$refs.datePicker?.openMenu?.();
    },
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
      if (visibleMonth) {
        return !dayjs(date).isSame(visibleMonth, "month");
      }

      const dp = this.$refs.datePicker;
      if (!dp || dp.month === undefined || dp.year === undefined) {
        return false;
      }

      const fallbackVisibleMonth = dayjs()
        .year(dp.year)
        .month(dp.month)
        .startOf("month");

      return !dayjs(date).isSame(fallbackVisibleMonth, "month");
    },
    handleCalendarMonthYearUpdate(value, year) {
      if (value && typeof value === "object") {
        this.setCalendarVisibleMonthYear(value.month, value.year);
      } else {
        this.setCalendarVisibleMonthYear(value, year);
      }
      if (!this._calendarNativeSelectOpen) {
        this.alignMenu();
      }
      this.scheduleSyncAllDayCellClasses();
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
    clearCalendarNativeSelectReleaseTimer() {
      if (this._calendarNativeSelectReleaseTimer !== null) {
        clearTimeout(this._calendarNativeSelectReleaseTimer);
        this._calendarNativeSelectReleaseTimer = null;
      }
    },
    holdCalendarNativeSelectOpen() {
      this.clearCalendarNativeSelectReleaseTimer();
      this._calendarNativeSelectOpen = true;
      this.clearAlignMenuTimer();
    },
    releaseCalendarNativeSelectOpen({ align = true, delay = 80 } = {}) {
      this.clearCalendarNativeSelectReleaseTimer();
      this._calendarNativeSelectReleaseTimer = setTimeout(() => {
        this._calendarNativeSelectReleaseTimer = null;
        this._calendarNativeSelectOpen = false;
        if (align && this.isMenuOpen) {
          this.alignMenu();
        }
      }, delay);
    },
    handleCalendarSelectPointerDown() {
      this.holdCalendarNativeSelectOpen();
    },
    handleCalendarSelectFocus() {
      this.holdCalendarNativeSelectOpen();
    },
    handleCalendarSelectBlur() {
      this.releaseCalendarNativeSelectOpen();
    },
    openCalendarLabelSelect(event) {
      const select = event?.currentTarget?.querySelector?.("select");
      this.openCalendarSelect({ target: select });
    },
    openCalendarSelect(event) {
      const select = event?.target;
      if (!select) {
        return;
      }
      this.holdCalendarNativeSelectOpen();
      if (typeof select.showPicker !== "function") {
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
        this.releaseCalendarNativeSelectOpen();
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
      if (this.alignMenuTimer !== null) {
        clearTimeout(this.alignMenuTimer);
        this.alignMenuTimer = null;
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
    ensureWindowResizeHandler() {
      if (this._windowResizeHandler) {
        return;
      }
      this._windowResizeHandler = () => {
        if (this.isMenuOpen) {
          this.$refs.datePicker?.closeMenu?.();
        }
      };
      getScopedWindow(this.$el || this)?.addEventListener("resize", this._windowResizeHandler);
    },
    installMenuLayoutGuard() {
      this.clearMenuLayoutGuard();
      this.$nextTick(() => {
        this.menuLayoutGuardCleanup = attachVueDatePickerMenuLayoutGuard({
          root: this.$el,
          trigger: this.$refs.button,
          ownerId: this.menuOwnerId,
          close: () => this.$refs.datePicker?.closeMenu?.(),
          realign: () => this._calendarNativeSelectOpen ? false : this.alignMenuNow(),
          shouldSuspend: () => true
        });
      });
    },
    getCalendarScopeRoot() {
      return this.$refs.button || this.$el || null;
    },
    getEditCell() {
      const scopeRoot = this.getCalendarScopeRoot();
      const currentElement = scopeRoot instanceof Element ? scopeRoot : null;
      const closestEditCell = currentElement?.closest?.(".k-edit-cell");
      if (closestEditCell) {
        return closestEditCell;
      }

      const scopedEditCell = getScopedElementsByClassName("k-edit-cell", scopeRoot)[0];
      if (scopedEditCell) {
        return scopedEditCell;
      }

      const scopedDocument = getScopedDocument(scopeRoot);
      return scopedDocument?.getElementsByClassName?.("k-edit-cell")?.[0] || null;
    },
    handleOpen() {
      this.hasOpenedMenu = true;
      this.ensureWindowResizeHandler();
      this.menuReady = false;
      this.isMenuOpen = true;
      this.menuPositionSnapshot = null;
      const effectiveValue = this.externalValue || formatOutput(this.internalDate);
      this.initValue = formatOutput(effectiveValue);
      this.internalDate = this.resolveInternalDate(effectiveValue);
      const calendarOpenTarget = this.toMonth || (this.birthdayMode && !effectiveValue ? dayjs().subtract(75, "years").format("YYYY-MM-DD") : effectiveValue);
      const calendarOpenDate = parseDate(calendarOpenTarget);
      if (calendarOpenDate) {
        this.setCalendarVisibleMonthYear(dayjs(calendarOpenDate).month(), dayjs(calendarOpenDate).year());
      } else if (this.calendarViewMonth === null || this.calendarViewYear === null) {
        const fallbackDate = new Date();
        this.setCalendarVisibleMonthYear(dayjs(fallbackDate).month(), dayjs(fallbackDate).year());
      }
      this.moveCalendar(calendarOpenTarget);
      this.alignMenuNow();
      this.alignMenu();
      this.installMenuLayoutGuard();
      this.$nextTick(() => {
        this.alignMenuNow();

        requestAnimationFrame(() => {
          this.menuReady = true;
          this.syncAllDayCellClasses();
        });
      });
      this.$nextTick(() => {
        const dp = this.$refs.datePicker;

        if (dp?.month !== undefined && dp?.year !== undefined) {
          this.setCalendarVisibleMonthYear(dp.month, dp.year);
        }
      });
    },
    handleClosed() {
      this.menuReady = false;
      this.isMenuOpen = false;
      this.menuPositionSnapshot = null;
      this._calendarNativeSelectOpen = false;
      this.clearAlignMenuTimer();
      this.clearCalendarNativeSelectReleaseTimer();
      this.clearMenuLayoutGuard();
      this.resetMenuLayout();
    },
    isCalendarBlurToModalAction(event) {
      const relatedTarget = event?.relatedTarget;
      if (!(relatedTarget instanceof Element)) {
        return false;
      }
      return !!relatedTarget.closest(
        ".btn2-cancel, .common-style-cancel-button, .close-btn, .btn1-execute, .common-style-ok-button"
      );
    },
    handleBlur(event) {
      if (this.isCalendarBlurToModalAction(event)) {
        return;
      }
      if (this.initValue !== formatOutput(this.externalValue)) {
        this.$emit("blur", event);
      }
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
      this.emitValue(value);
    },
    emitValue(value) {
      if (this.editCell) {
        this.editCell.click();
      }

      if (this.cardDiff !== undefined && !this.cardDiff) {
        EventBus.$emit("calendarFlag", { isDatePicker: true });
      }

      const formatted = formatOutput(value);
      this.$emit("update:modelValue", formatted);
      this.$emit("input", formatted);
    },
    moveCalendar(value) {
      const target = parseDate(value);
      if (target) {
        this.setCalendarVisibleMonthYear(dayjs(target).month(), dayjs(target).year());
      }

      const visibleMonth = this.getCalendarVisibleMonthDate();
      if (!visibleMonth) {
        return;
      }

      this.$nextTick(() => {
        this.$refs.datePicker?.setMonthYear?.({
          month: visibleMonth.month(),
          year: visibleMonth.year()
        });
        this.alignMenu();
      });
    },
    alignMenuNow() {
      if (this._calendarNativeSelectOpen) {
        return false;
      }
      return alignVueDatePickerMenuToTrigger({
        root: this.$el,
        trigger: this.$refs.button,
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
      if (this._calendarNativeSelectOpen) {
        return;
      }
      // Vue2 Pikaday 実装の toggleDatePickerVisibility 内 DOM 補正と同等の位置決め処理。
      // 単月/複数月：カレンダー四隅のいずれかをアイコン四隅に貼り付け、周辺入力等と重ならない候補を選択。
      // Vue3 DatePicker は月送り後に menu wrapper の style を再計算するため、
      // redraw 後にも固定配置を再適用して Vue2 Pikaday と同じく親 popover の中へ流れ込ませない。
      this.$nextTick(() => {
        if (this._calendarNativeSelectOpen) {
          return;
        }
        this.clearAlignMenuTimer();
        const realign = () => this.alignMenuNow();
        realign();
        this.alignMenuTimer = setTimeout(() => {
          this.alignMenuTimer = null;
          realign();
          const ownerWindow = this.$refs.button?.ownerDocument?.defaultView || globalThis.window || null;
          ownerWindow?.requestAnimationFrame?.(realign);
          setTimeout(realign, 32);
        }, 0);
      });
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
    isTodayDate(date) {
      return dayjs(date).isSame(dayjs(), "day");
    },
    /**
     * グリッド上は選択不可だが v-model には入れられる日（今日ボタン等）は、
     * カレンダー上で dp__active_date の青枠を付けない。
     */
    resolveInternalDate(value) {
      const parsed = parseDate(value);
      if (!parsed) {
        return null;
      }
      if (this.enableTodayButton && this.isCalendarRuleDisabled(parsed)) {
        return null;
      }
      return parsed;
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

      if (this.activeDate) {
        return !this.defaultSelectedDateKeys.has(key);
      }

      if (this.disabledDateKeys.has(key)) {
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
    dayCellMarkerClasses() {
      return [
        "has-event",
        "has-custom-event",
        "custom-span-selected",
        "custom-span-double-selected",
        "is-disabled",
        "ntss-calendar-disabled"
      ];
    },
    getDayClasses(date) {
      const key = normalizeKey(date);
      const hasDefaultEvent = this.useSpanDateHighlight && this.defaultSelectedDateKeys.has(key);
      const isDisabled = this.isDateDisabled(date);
      // viewMode では default 確定前に custom だけ付くと黄緑→青のチラつきが出るため抑止
      const canShowCustomHighlight = !this.viewMode
        || !this.useSpanDateHighlight
        || this.defaultSelectedDateKeys.size > 0;
      const hasCustomEvent = canShowCustomHighlight
        && this.customSelectedDateKeys.has(key)
        && !this.defaultSelectedDateKeys.has(key);

      return {
        "ntss-calendar-day": true,
        "has-event": hasDefaultEvent,
        "has-custom-event": hasCustomEvent,
        // 配列形式（TreatPlanCopy 等）は has-event の青背景。object 形式の編集時のみ緑
        "custom-span-selected": hasDefaultEvent && !this.viewMode && !Array.isArray(this.selectedDates),
        "is-disabled": isDisabled,
        "ntss-calendar-disabled": isDisabled
      };
    },
    bindDayCellClasses(el, date) {
      if (!el) {
        return;
      }

      const applyCellClasses = () => {
        const cell = el.closest(".dp__cell_inner") || el.parentElement;
        if (!cell?.classList?.contains("dp__cell_inner")) {
          return;
        }

        const classMap = this.getDayClasses(date);
        this.dayCellMarkerClasses().forEach(name => {
          cell.classList.toggle(name, Boolean(classMap[name]));
        });
      };

      applyCellClasses();
      this.$nextTick(applyCellClasses);
    },
    syncAllDayCellClasses() {
      const menu = document.getElementById(this.menuOwnerId);
      if (!menu) {
        return;
      }

      menu.querySelectorAll(".dp__cell_inner .ntss-calendar-day").forEach(span => {
        const cell = span.closest(".dp__cell_inner");
        if (!cell) {
          return;
        }

        this.dayCellMarkerClasses().forEach(name => {
          cell.classList.toggle(name, span.classList.contains(name));
        });
      });
    },
    scheduleSyncAllDayCellClasses() {
      this.$nextTick(() => {
        this.syncAllDayCellClasses();
        requestAnimationFrame(() => {
          this.syncAllDayCellClasses();
        });
      });
    },
    selectToday() {
      if (this.isTodayDisabled) {
        return;
      }

      const today = dayjs().startOf("day").toDate();
      if (this.enableTodayButton) {
        // 今日ボタンは親の todayButtonClick のみで処理（input 発火で曜日連動しない）
        const formatted = formatOutput(today);
        this.$emit("update:modelValue", formatted);
        this.$emit("todayButtonClick");
        this.internalDate = this.resolveInternalDate(formatted);
        this.scheduleSyncAllDayCellClasses();
      } else {
        this.internalDate = today;
        this.emitValue(today);
        this.$emit("todayButtonClick");
      }
      this.$refs.datePicker?.closeMenu();
    },
    setSilently(value) {
      // this.internalDate = parseDate(value);
      const parsed = parseDate(value);
      this.internalDate = this.resolveInternalDate(value);
      if (parsed) {
        this.setCalendarVisibleMonthYear(dayjs(parsed).month(), dayjs(parsed).year());
      }
    }
  }
};
</script>

<style scoped>
button.calendar {
  font-size: inherit;
}
button.calendar .ons-icon {
  font-size: 1em;
}
.ntss-custom-calendar-host {
  display: inline-block;
  width: auto;
  vertical-align: middle;
}

.ntss-custom-calendar-picker {
  display: inline-block !important;
  width: auto !important;
  vertical-align: middle;
}

:deep(.ntss-custom-calendar-picker > div) {
  display: inline-block !important;
  width: auto !important;
}

:deep(.dp__selection_preview),
:deep(.dp--tp-wrap),
:deep(.dp__arrow_top),
:deep(.dp__action_row .dp__button) {
  display: none !important;
}

:deep(.dp--menu-wrapper) {
  position: fixed !important;
  right: auto !important;
  bottom: auto !important;
  transform: none !important;
  margin: 0 !important;
  z-index: 2147483647 !important;
}

:deep(.dp__menu) {
  width: 240px;
  min-width: 240px;
  max-width: 240px;
  border: 1px solid #a8a8a8;
  border-radius: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

:deep(.dp--header-wrap) {
  background: linear-gradient(#4fa6d4, #2f8dbc);
  color: #ffffff;
  padding: 0 2px;
  min-height: 30px;
}

:deep(.dp__month_year_wrap) {
  width: 100%;
}

:deep(.dp--header-wrap > .dp__month_year_wrap) {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 4px;
}

:deep(.dp--header-wrap > .dp__month_year_wrap > .dp__month_year_wrap) {
  display: flex;
  flex: 1 1 auto;
  justify-content: center;
  align-items: center;
  flex-direction: row-reverse;
  gap: 0.25em;
}

:deep(.dp__btn.dp--arrow-btn-nav),
:deep(.dp__btn.dp__month_year_select) {
  background: transparent;
  color: #ffffff;
  border: 0;
  box-shadow: none;
  min-height: 30px;
}

:deep(.dp__btn.dp__month_year_select) {
  font-weight: 700;
  padding: 0 4px;
}

:deep(.dp__calendar_header) {
  padding: 0 2px;
  min-height: 26px;
}

:deep(.dp__calendar_header_item) {
  color: #666666;
  font-weight: 700;
  font-size: 12px;
  line-height: 26px;
  height: 26px;
}

:deep(.dp__calendar_header_separator) {
  display: none;
}

:deep(.dp__calendar) {
  padding: 0 2px 2px;
}

:deep(.dp__calendar_row) {
  margin: 0;
  min-height: 34px;
}

:deep(.dp__calendar_item) {
  line-height: 1;
  min-height: 34px;
}

:deep(.dp__cell_inner) {
  border-radius: 0;
  width: 28px;
  height: 28px;
  min-height: 28px;
  padding: 0;
  line-height: 28px;
  margin: 1px auto;
  font-size: 12px;
}

:deep(.dp__active_date) {
  background: #3296db;
}

:deep(.dp__action_row) {
  justify-content: flex-start;
  min-height: 0;
  padding: 4px 8px 4px;
  border-top: 0;
}

:deep(.dp__action_buttons) {
  margin-left: 0;
}

:deep(.ntss-calendar-today-btn) {
  min-width: 38px;
  height: 30px;
  padding: 0 10px;
  border: 1px solid #9f9f9f;
  background: #f5f5f5;
  color: #333333;
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
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(:hover),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(:hover) {
  color: #333333 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(:hover):not(:has(> .has-event)) .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(:hover):not(:has(> .has-event)) .ntss-calendar-day {
  color: #33aaff !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select option {
  color: #000000 !important;
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

/* 配列 selected-dates: 選択可能な治療日 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-event:not(.has-custom-event):not(.is-disabled) {
  background-color: var(--ntss-calendar-button-is-disabled-background-color, #005da9);
  border-radius: 3px;
  opacity: 1;
  color: #ffffff;
}

/* ntss.css .has-event.is-disabled .pika-button 互換（背景は外層 .dp__cell_inner） */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled.has-event.is-disabled:not(.has-custom-event),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-event.is-disabled:not(.has-custom-event) {
  background-color: var(--ntss-calendar-button-is-disabled-background-color, #005da9);
  border-radius: 3px;
  opacity: 0.75;
  color: #ffffff;
}

/* ntss.css .has-custom-event.pika-button 互換 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled.has-custom-event,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-custom-event {
  background-color: #9acd32;
  border-radius: 3px;
  color: #ffffff;
}

/* ntss.css .is-disabled .has-custom-event.pika-button 互換 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled.has-custom-event.is-disabled,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-custom-event.is-disabled {
  opacity: 0.75;
}

/* ntss.css .custom-span-selected.has-event .pika-button 互換 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.custom-span-selected.has-event {
  background: #00b050;
  border-radius: 3px;
  color: #ffffff;
  opacity: 1;
}

/* ntss.css .custom-span-double-selected.has-event .pika-button 互換 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.custom-span-double-selected.has-event {
  background: #adff2f;
  border-radius: 3px;
  color: #ffffff;
  opacity: 1;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-event .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-custom-event .ntss-calendar-day {
  color: #ffffff;
  background: transparent;
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

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_offset:not(.has-event),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled:not(.has-event) {
  color: #c5c5c5 !important;
  opacity: 1 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_offset.has-event,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled.has-event,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled.has-custom-event {
  color: #ffffff !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:hover,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:hover {
  background-color: var(--ntss-calendar-button-hover-background-color) !important;
  text-decoration: underline !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__today:not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(.dp__cell_disabled):not(.dp__cell_offset) {
  color: #3296db !important;
  font-weight: 700 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__range_start,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__range_end {
  background: #3296db !important;
  color: #fff !important;
  box-shadow: none !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__range_start .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__range_end .ntss-calendar-day {
  color: #fff !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-day {
  display: block !important;
  width: 100% !important;
  height: 100% !important;
  line-height: inherit !important;
  text-align: inherit !important;
}

/* 配列 selected-dates: 選択可能な治療日 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-event:not(.has-custom-event):not(.is-disabled) {
  background: var(--ntss-calendar-button-is-disabled-background-color, #005da9) !important;
  background-color: var(--ntss-calendar-button-is-disabled-background-color, #005da9) !important;
  background-image: none !important;
  border-radius: 3px !important;
  opacity: 1 !important;
  color: #ffffff !important;
}

/* ntss.css .has-event.is-disabled .pika-button 互換（背景は外層 .dp__cell_inner） */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled.has-event.is-disabled:not(.has-custom-event),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-event.is-disabled:not(.has-custom-event) {
  background: var(--ntss-calendar-button-is-disabled-background-color, #005da9) !important;
  background-color: var(--ntss-calendar-button-is-disabled-background-color, #005da9) !important;
  background-image: none !important;
  border-radius: 3px !important;
  opacity: 0.75 !important;
  color: #ffffff !important;
}

/* ntss.css .has-custom-event.pika-button 互換 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled.has-custom-event,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-custom-event {
  background: #9acd32 !important;
  background-color: #9acd32 !important;
  background-image: none !important;
  border-radius: 3px !important;
  color: #ffffff !important;
}

/* ntss.css .is-disabled .has-custom-event.pika-button 互換 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_disabled.has-custom-event.is-disabled,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-custom-event.is-disabled {
  opacity: 0.75 !important;
}

/* ntss.css .custom-span-selected.has-event .pika-button 互換 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.custom-span-selected.has-event {
  background: #00b050 !important;
  border-radius: 3px !important;
  color: #ffffff !important;
  opacity: 1 !important;
}

/* ntss.css .custom-span-double-selected.has-event .pika-button 互換 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.custom-span-double-selected.has-event {
  background: #adff2f !important;
  border-radius: 3px !important;
  color: #ffffff !important;
  opacity: 1 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-event .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.has-custom-event .ntss-calendar-day {
  background: transparent !important;
  color: #ffffff !important;
  opacity: 1 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__action_row {
  display: block !important;
  box-sizing: border-box !important;
  width: 100% !important;
  height: 40px !important;
  min-height: 40px !important;
  max-height: 40px !important;
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
  margin: 8px !important;
  padding: 3px !important;
  border: 1px solid var(--ntss-calendar-button-goto-today-border-color) !important;
  border-radius: 0 !important;
  background: var(--ntss-calendar-button-goto-today-background-color) !important;
  color: var(--ntss-calendar-button-goto-today-color) !important;
  font-size: 12px !important;
  line-height: 15px !important;
  text-align: center !important;
  cursor: pointer !important;
  outline: none !important;
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



/* Vue3 DatePicker menu is teleported outside this scoped component.
   Keep it hidden until compat has applied the Vue2/Pikaday-equivalent fixed position. */
.dp--menu-wrapper.ntss-custom-calendar-panel-positioning,
.dp__menu.ntss-custom-calendar-panel:not(.ntss-custom-calendar-panel-ready) {
  visibility: hidden !important;
}



/* Vue2 Pikaday parity fine tuning after replacing @vuepic overlay with native select.
   Keep selectable displayed-month day text black until it is actually selected or hovered. */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(:hover):not(:has(> .has-event)),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(:hover):not(:has(> .has-event)) {
  color: #333333 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(:hover):not(:has(> .has-event)) .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:not(.dp__cell_offset):not(.dp__cell_disabled):not(.dp__active_date):not(.dp__range_start):not(.dp__range_end):not(:hover):not(:has(> .has-event)) .ntss-calendar-day {
  color: #333333 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select option {
  color: #000000 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-month-year-select option:checked {
  color: #ffffff !important;
}

/* 治療日ハイライト: ファイル末尾で #333 / #f5f5f5 より優先 */
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner:has(> .ntss-calendar-day.has-event):not(:has(> .has-custom-event)):not(:has(> .is-disabled)):not(.is-disabled):not(.dp__cell_offset),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__pointer:has(> .ntss-calendar-day.has-event):not(:has(> .has-custom-event)):not(:has(> .is-disabled)):not(.is-disabled):not(.dp__cell_offset),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__date_hover:has(> .ntss-calendar-day.has-event):not(:has(> .has-custom-event)):not(:has(> .is-disabled)):not(.is-disabled):not(.dp__cell_offset) {
  background: var(--ntss-calendar-button-is-disabled-background-color, #005da9) !important;
  background-color: var(--ntss-calendar-button-is-disabled-background-color, #005da9) !important;
  background-image: none !important;
  border-radius: 3px !important;
  color: #ffffff !important;
  opacity: 1 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner:has(> .ntss-calendar-day.has-event.is-disabled):not(:has(> .has-custom-event)),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__cell_offset.has-event:not(:has(> .has-custom-event)) {
  background: #005da9 !important;
  background-color: #005da9 !important;
  box-shadow: inset 0 1px 3px #0076c9 !important;
  border-radius: 3px !important;
  color: #ffffff !important;
  opacity: 0.75 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner:has(> .has-custom-event) {
  background: #9acd32 !important;
  background-color: #9acd32 !important;
  border-radius: 3px !important;
  color: #ffffff !important;
  opacity: 0.75 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner:has(> .ntss-calendar-day.has-event) .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-day.has-event:not(.has-custom-event) {
  color: #ffffff !important;
  -webkit-text-fill-color: #ffffff !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-day.has-event:not(.has-custom-event) {
  background: var(--ntss-calendar-button-is-disabled-background-color, #005da9) !important;
  background-color: var(--ntss-calendar-button-is-disabled-background-color, #005da9) !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .ntss-calendar-day.has-event.is-disabled:not(.has-custom-event) {
  box-shadow: inset 0 1px 3px #0076c9 !important;
  opacity: 0.75 !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__today.dp__cell_disabled,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__today.is-disabled,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__today.ntss-calendar-disabled,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date.is-disabled:not(.has-event),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date.ntss-calendar-disabled:not(.has-event),
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date.dp__cell_disabled:not(.has-event) {
  background: transparent !important;
  background-color: transparent !important;
  box-shadow: none !important;
  color: #c5c5c5 !important;
  font-weight: normal !important;
}

:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__today.dp__cell_disabled .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__today.is-disabled .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__today.ntss-calendar-disabled .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date.is-disabled:not(.has-event) .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date.ntss-calendar-disabled:not(.has-event) .ntss-calendar-day,
:where(.ntss-custom-calendar-menu, .ntss-custom-calendar-panel) .dp__cell_inner.dp__active_date.dp__cell_disabled:not(.has-event) .ntss-calendar-day {
  color: #c5c5c5 !important;
  -webkit-text-fill-color: #c5c5c5 !important;
  background: transparent !important;
}

</style>
