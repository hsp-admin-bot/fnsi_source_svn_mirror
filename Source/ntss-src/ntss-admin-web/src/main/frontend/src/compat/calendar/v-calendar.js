import { h } from "vue";
import VCalendar from "v-calendar";
import "v-calendar/style.css";
import "@/compat/calendar/v-calendar.css";

const SCREEN_BREAKPOINTS = {
  xl: 1200,
  lg: 992,
  md: 768,
  sm: 576,
};

const JAPANESE_MONTH_LABELS = [
  "一月",
  "二月",
  "三月",
  "四月",
  "五月",
  "六月",
  "七月",
  "八月",
  "九月",
  "十月",
  "十一月",
  "十二月",
];

const ENGLISH_MONTH_INDEX = {
  jan: 1,
  january: 1,
  feb: 2,
  february: 2,
  mar: 3,
  march: 3,
  apr: 4,
  april: 4,
  may: 5,
  jun: 6,
  june: 6,
  jul: 7,
  july: 7,
  aug: 8,
  august: 8,
  sep: 9,
  sept: 9,
  september: 9,
  oct: 10,
  october: 10,
  nov: 11,
  november: 11,
  dec: 12,
  december: 12,
};

const resolveScreensValue = (valueMap = {}) => {
  if (!valueMap || typeof valueMap !== "object") return valueMap;
  const width = typeof window !== "undefined" ? window.innerWidth : 0;
  if (width >= SCREEN_BREAKPOINTS.xl && valueMap.xl !== undefined) return valueMap.xl;
  if (width >= SCREEN_BREAKPOINTS.lg && valueMap.lg !== undefined) return valueMap.lg;
  if (width >= SCREEN_BREAKPOINTS.md && valueMap.md !== undefined) return valueMap.md;
  if (width >= SCREEN_BREAKPOINTS.sm && valueMap.sm !== undefined) return valueMap.sm;
  return valueMap.default;
};

const firstDefined = (...values) => values.find(value => value !== undefined);

const monthLabelFromNumber = (month) => {
  const index = Number(month);
  if (!Number.isFinite(index) || index < 1 || index > 12) return "";
  return JAPANESE_MONTH_LABELS[index - 1];
};

const parseLegacyHeaderLabels = (slotProps = {}) => {
  if (slotProps.yearLabel && slotProps.monthLabel) {
    return {
      yearLabel: slotProps.yearLabel,
      monthLabel: slotProps.monthLabel,
    };
  }

  const title = String(slotProps.title || "").trim();
  const yearLabel = slotProps.yearLabel
    || slotProps.year
    || slotProps?.month?.year
    || title.match(/(\d{4})/)?.[1]
    || "";
  let monthLabel = slotProps.monthLabel || "";

  if (!monthLabel) {
    monthLabel = monthLabelFromNumber(slotProps.month)
      || monthLabelFromNumber(slotProps.monthNumber)
      || monthLabelFromNumber(slotProps?.month?.month)
      || monthLabelFromNumber(slotProps?.page?.month);
  }

  if (!monthLabel) {
    const japaneseMonth = title.match(/年\s*([一二三四五六七八九十]+月)/)?.[1]
      || title.match(/([一二三四五六七八九十]+月)/)?.[1];
    if (japaneseMonth) monthLabel = japaneseMonth;
  }

  if (!monthLabel) {
    const numericMonth = title.match(/年\s*(\d{1,2})\s*月/)?.[1]
      || title.match(/(?:^|\D)(\d{1,2})\s*月/)?.[1];
    monthLabel = monthLabelFromNumber(numericMonth);
  }

  if (!monthLabel) {
    const englishMonthKey = title.match(/([A-Za-z]+)/)?.[1]?.toLowerCase();
    monthLabel = monthLabelFromNumber(ENGLISH_MONTH_INDEX[englishMonthKey]);
  }

  return { yearLabel, monthLabel };
};

const resolveLegacyDatePickerComponent = (app, options = {}) => {
  const prefix = options?.componentPrefix || "V";
  const pascalPrefix = String(prefix).replace(/(^|-)([a-z])/g, (_, separator, char) => char.toUpperCase());
  const candidates = [
    `${pascalPrefix}DatePicker`,
    `${prefix}DatePicker`,
    `${prefix}-date-picker`,
    "VDatePicker",
    "DatePicker",
    "vc-date-picker",
  ];

  for (const name of candidates) {
    const component = app.component(name);
    if (component) {
      return { component, names: candidates.filter(candidate => app.component(candidate)) };
    }
  }

  return { component: null, names: [] };
};


const isLegacyMultipleMode = (attrs = {}) => String(firstDefined(attrs.mode, attrs.Mode) || "").toLowerCase() === "multiple";

const normalizeLegacyDate = (value) => {
  if (value == null || value === "") return null;
  if (value instanceof Date) return value;
  const dateValue = new Date(value);
  return Number.isNaN(dateValue.getTime()) ? null : dateValue;
};

const normalizeLegacyDateList = (value) => {
  if (Array.isArray(value)) {
    return value.map(normalizeLegacyDate).filter(Boolean);
  }
  const dateValue = normalizeLegacyDate(value);
  return dateValue ? [dateValue] : [];
};

const isSameLegacyDate = (left, right) => {
  const leftDate = normalizeLegacyDate(left);
  const rightDate = normalizeLegacyDate(right);
  if (!leftDate || !rightDate) return false;
  return leftDate.getFullYear() === rightDate.getFullYear()
    && leftDate.getMonth() === rightDate.getMonth()
    && leftDate.getDate() === rightDate.getDate();
};

const normalizeLegacyMultipleModelValue = (nextValue, previousValue) => {
  if (Array.isArray(nextValue)) {
    return normalizeLegacyDateList(nextValue);
  }
  const nextDate = normalizeLegacyDate(nextValue);
  if (!nextDate) {
    // v-calendar v3 が clearIfEqual で null を出しても、多選を全解除しない
    return normalizeLegacyDateList(previousValue);
  }
  const previousList = normalizeLegacyDateList(previousValue);
  const exists = previousList.some(date => isSameLegacyDate(date, nextDate));
  if (exists) {
    return previousList.filter(date => !isSameLegacyDate(date, nextDate));
  }
  return [...previousList, nextDate].sort((left, right) => left.getTime() - right.getTime());
};

const mergeLegacyMultipleAttributes = (attrs = {}, selectedDates = []) => {
  const base = Array.isArray(attrs.attributes) ? [...attrs.attributes] : [];
  const filtered = base.filter(item => item?.key !== "legacy-vc-selected");
  if (selectedDates.length) {
    filtered.push({
      key: "legacy-vc-selected",
      highlight: true,
      dates: selectedDates,
      pinPage: true,
    });
  }
  return filtered;
};

const callLegacyHandler = (handler, ...args) => {
  if (Array.isArray(handler)) {
    handler.forEach(item => callLegacyHandler(item, ...args));
    return;
  }
  if (typeof handler === "function") {
    handler(...args);
  }
};

const createEmptySlot = () => null;

const appendLegacyCalendarClass = (attrs = {}) => {
  const compatAttrs = { ...attrs };
  const classList = [];
  const pushClass = (value) => {
    if (!value) return;
    if (Array.isArray(value)) {
      value.forEach(pushClass);
      return;
    }
    if (typeof value === "object") {
      classList.push(value);
      return;
    }
    String(value).split(/\s+/).filter(Boolean).forEach(name => classList.push(name));
  };
  pushClass(compatAttrs.class);
  if (!classList.some(value => value === "ntss-vcalendar-legacy" || (typeof value === "object" && value["ntss-vcalendar-legacy"]))) {
    classList.push("ntss-vcalendar-legacy");
  }
  compatAttrs.class = classList;
  return compatAttrs;
};


const installLegacyDatePickerCompat = (app, options = {}) => {
  const { component: OriginalDatePicker, names } = resolveLegacyDatePickerComponent(app, options);
  if (!OriginalDatePicker) return;

  const LegacyDatePicker = {
    name: "LegacyVcDatePicker",
    inheritAttrs: false,
    setup(_, { attrs, slots }) {
      return () => {
        const rows = Number(attrs.rows || 1);
        const columns = Number(attrs.columns || 1);
        const isMultiPane = rows > 1 || columns > 1;
        const compatAttrs = appendLegacyCalendarClass(attrs);
        const legacyExpanded = firstDefined(attrs.expanded, attrs.isExpanded, attrs["is-expanded"]);
        const legacyMultipleMode = isLegacyMultipleMode(compatAttrs);

        if (legacyMultipleMode) {
          const updateModelValue = compatAttrs["onUpdate:modelValue"];
          const inputHandler = compatAttrs.onInput;
          const selectedDates = normalizeLegacyDateList(compatAttrs.modelValue);
          compatAttrs.modelValue = selectedDates;
          compatAttrs.attributes = mergeLegacyMultipleAttributes(compatAttrs, selectedDates);
          delete compatAttrs.selectAttribute;
          delete compatAttrs["select-attribute"];
          compatAttrs["onUpdate:modelValue"] = (nextValue, ...args) => {
            const currentList = normalizeLegacyDateList(attrs.modelValue);
            const normalizedValue = normalizeLegacyMultipleModelValue(nextValue, currentList);
            callLegacyHandler(updateModelValue, normalizedValue, ...args);
          };
          if (inputHandler) {
            compatAttrs.onInput = (nextValue, ...args) => {
              const currentList = normalizeLegacyDateList(attrs.modelValue);
              const normalizedValue = normalizeLegacyMultipleModelValue(nextValue, currentList);
              callLegacyHandler(inputHandler, normalizedValue, ...args);
            };
          }
        }

        if (legacyExpanded !== undefined) {
          compatAttrs.expanded = legacyExpanded;
        }
        delete compatAttrs.isExpanded;
        delete compatAttrs["is-expanded"];

        if (isMultiPane && compatAttrs.disablePageSwipe === undefined && compatAttrs["disable-page-swipe"] === undefined) {
          compatAttrs.disablePageSwipe = true;
        }

        const compatSlots = { ...slots };
        if (slots["header-title"]) {
          compatSlots["header-title"] = (slotProps = {}) => {
            const legacyLabels = parseLegacyHeaderLabels(slotProps);
            return slots["header-title"]({
              ...slotProps,
              ...legacyLabels,
            });
          };
        }

        if (isMultiPane) {
          compatSlots["header-prev-button"] = slots["header-prev-button"] || createEmptySlot;
          compatSlots["header-next-button"] = slots["header-next-button"] || createEmptySlot;
          compatSlots["nav-prev-button"] = slots["nav-prev-button"] || createEmptySlot;
          compatSlots["nav-next-button"] = slots["nav-next-button"] || createEmptySlot;
        }

        return h(OriginalDatePicker, compatAttrs, compatSlots);
      };
    },
  };

  const registerNames = new Set([...names, "vc-date-picker", "VcDatePicker"]);
  registerNames.forEach(name => {
    // Vue2 側では同一コンポーネント名の再定義は警告にならず、
    // 後勝ちで旧 API を差し替えられていました。Vue3 の app.component setter は
    // 既存名の再登録で warning を出すため、compat 層では registry を直接更新し、
    // 旧 vc-date-picker 名を Legacy wrapper に差し替えます。
    if (app?._context?.components) {
      app._context.components[name] = LegacyDatePicker;
    } else {
      app.component(name, LegacyDatePicker);
    }
  });
};

// Vue2 時代の v-calendar 入口を Vue3 側でも一箇所に固定します。
// Vue2 の v-calendar が提供していた $screens 参照も compat 層で承接します。
export default {
  ...VCalendar,
  install(app, options) {
    app.use(VCalendar, options);
    installLegacyDatePickerCompat(app, options);
    app.config.globalProperties.$screens = resolveScreensValue;
  },
};
