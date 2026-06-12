import dayjs from "@/compat/date/dayjs";

/**
 * API の点検日（YYYY-MM-DD または ISO8601）を YYYY-MM-DD に正規化する
 */
export function normalizeMenteDate(value) {
  if (value == null || value === "") {
    return "";
  }
  if (typeof value === "string" && /^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return value;
  }
  const parsed = dayjs(value);
  return parsed.isValid() ? parsed.format("YYYY-MM-DD") : "";
}

/**
 * 一覧の日付列ヘッダ表示（例: 2026/05/21 (木)）
 */
export function formatMenteDateHeader(dateString) {
  const normalized = normalizeMenteDate(dateString);
  if (!normalized) {
    return "";
  }
  return dayjs(normalized, "YYYY-MM-DD").format("YYYY/MM/DD (ddd)");
}

/**
 * 点検結果配列の menteDate を正規化する
 */
export function normalizeMenteDateInResults(resultData) {
  if (!Array.isArray(resultData)) {
    return resultData;
  }
  return resultData.map(item => ({
    ...item,
    menteDate: normalizeMenteDate(item.menteDate)
  }));
}
