import * as KendoDataQuery from "@progress/kendo-data-query";

export * from "@progress/kendo-data-query";

function toCountableArray(value) {
  if (Array.isArray(value)) {
    return value;
  }
  if (value && Array.isArray(value.data)) {
    return value.data;
  }
  if (value && typeof value.length === "number") {
    return Array.prototype.slice.call(value);
  }
  if (value && typeof value[Symbol.iterator] === "function") {
    return Array.from(value);
  }
  return [];
}

// Vue2 では @progress/kendo-data-query/dist/npm/array.operators の count を参照していた。
// Kendo Vue 8 側の public export に存在しないため、旧利用名を compat 側で補完する。
export function count(value, predicate = null) {
  const items = toCountableArray(value);
  if (typeof predicate === "function") {
    return items.filter((item, index) => predicate(item, index)).length;
  }
  return items.length;
}

export default KendoDataQuery;
