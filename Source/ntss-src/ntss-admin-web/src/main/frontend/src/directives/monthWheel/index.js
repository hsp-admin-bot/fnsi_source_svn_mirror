/**
 * 年月IFのマウスホイールピッキング
 */
const parseMonth = (value, fallbackYear, fallbackMonth) => {
  const matched = String(value || "").match(/^(\d{1,4})-(\d{1,2})$/);
  if (!matched) {
    return { year: fallbackYear, month: fallbackMonth };
  }
  const year = Number(matched[1]);
  const month = Number(matched[2]);
  if (!Number.isFinite(year) || !Number.isFinite(month) || month < 1 || month > 12) {
    return { year: fallbackYear, month: fallbackMonth };
  }
  return { year, month };
};

const compareMonth = (left, right) => {
  if (left.year !== right.year) {
    return left.year - right.year;
  }
  return left.month - right.month;
};

const addMonth = (value, amount) => {
  const monthIndex = value.year * 12 + (value.month - 1) + amount;
  return {
    year: Math.floor(monthIndex / 12),
    month: (monthIndex % 12) + 1
  };
};

const formatMonth = (value) => {
  const year = String(value.year).padStart(4, "0");
  const month = String(value.month).padStart(2, "0");
  return `${year}-${month}`;
};

const monthWheel = {
  mounted(el) {
    el._monthWheelHandler = (event) => {
      // ブラウザ標準のホイール操作を抑止
      event.preventDefault();

      // 非活性、またはフォーカスなしの場合は処理しない
      if (el.disabled) return;
      if (document.activeElement !== el) return;

      // 入力可能な年月範囲
      const minMonth = parseMonth(el.min, 1, 1);
      const maxMonth = parseMonth(el.max, 9999, 12);

      // 現在値。未入力時は最小年月を設定
      let currentMonth = el.value
        ? parseMonth(el.value, minMonth.year, minMonth.month)
        : { ...minMonth };

      if (event.deltaY < 0) {
        // ホイール上：翌月へ。最大年月の場合は最小年月へ戻す
        if (compareMonth(currentMonth, maxMonth) >= 0) {
          currentMonth = { ...minMonth };
        } else {
          currentMonth = addMonth(currentMonth, 1);
        }
      } else {
        // ホイール下：前月へ。最小年月の場合は最大年月へ戻す
        if (compareMonth(currentMonth, minMonth) <= 0) {
          currentMonth = { ...maxMonth };
        } else {
          currentMonth = addMonth(currentMonth, -1);
        }
      }

      // 入力値を更新
      el.value = formatMonth(currentMonth);

      // v-model更新
      el.dispatchEvent(new Event("input", { bubbles: true }));

      // @change発火
      el.dispatchEvent(new Event("change", { bubbles: true }));
    };

    el.addEventListener("wheel", el._monthWheelHandler, { passive: false });
  },

  unmounted(el) {
    if (el._monthWheelHandler) {
      el.removeEventListener("wheel", el._monthWheelHandler);
      delete el._monthWheelHandler;
    }
  }
};

export default monthWheel;
