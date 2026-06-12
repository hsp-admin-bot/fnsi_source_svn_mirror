import dayjs from "@/compat/date/dayjs";

export function normalizeGridDateInputValue(value) {
  if (value === null || value === undefined || value === "") {
    return "";
  }
  const text = String(value).trim();
  const parsed = dayjs(text, ["YYYY-MM-DD", "YYYY/MM/DD", "YYYYMMDD"], true);
  return parsed.isValid() ? parsed.format("YYYY-MM-DD") : "";
}
