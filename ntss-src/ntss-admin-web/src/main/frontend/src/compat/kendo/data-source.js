import { toRaw } from "vue";

import {
  createJQueryDataSource,
  isJQueryDataSource,
  prepareKendoJQueryServices,
  setKendoProgress,
} from "@/compat/kendo/kendo-jquery-services.js";

export async function prepareDataSource() {
  return await prepareKendoJQueryServices();
}

export function createDataSource(options) {
  return ensureKendoDataSourceLocalData(createJQueryDataSource(normalizeKendoDataSourceOptions(options)));
}

export function isDataSource(source) {
  return isJQueryDataSource(source);
}

export { setKendoProgress };

function toArray(data) {
  if (!data) {
    return [];
  }
  try {
    return Array.from(data);
  } catch (_error) {
    return [];
  }
}

function unwrapKendoDataSourceValue(value) {
  try {
    return toRaw(value);
  } catch (_error) {
    return value;
  }
}

function parseKendoDateValue(value) {
  if (value == null) {
    return value;
  }
  // If already a Date, return as-is
  if (value instanceof Date) {
    return value;
  }
  // Accept numeric timestamps or ISO-like strings
  if (typeof value === "number" || typeof value === "string") {
    const d = new Date(value);
    if (!Number.isNaN(d.getTime())) {
      return d;
    }
  }
  return value;
}

export function normalizeKendoDataSourceOptions(options = {}) {
  const rawOptions = unwrapKendoDataSourceValue(options) || {};
  if (Array.isArray(rawOptions)) {
    return { data: rawOptions };
  }
  const normalized = { ...rawOptions };
  ["data", "transport", "schema", "sort", "filter", "group", "aggregate"].forEach((key) => {
    if (normalized[key] !== undefined) {
      normalized[key] = unwrapKendoDataSourceValue(normalized[key]);
    }
  });
  normalizeKendoDataSourceItem(normalized);
  if (Array.isArray(normalized.data)) {
    normalized.data = [...normalized.data];
  }
  return normalized;
}
export function normalizeKendoDataSourceItem(normalized) {
  const schema = normalized.schema;
  const modelFields = schema?.model?.fields;
  const data = normalized.data;
  if (Array.isArray(data) && modelFields && typeof modelFields === "object") {
    normalized.data = data.map((item) => {
        Object.keys(modelFields).forEach((fieldName) => {
        try {
          const field = modelFields[fieldName] || {};
          if (field.type === "date") {
            item[fieldName] = parseKendoDateValue(item[fieldName]);
          }
        } catch (_e) {
          // noop per-field
        }
      });
      return item;
    });
  }
}
export function ensureKendoDataSourceLocalData(source) {
  const localData = unwrapKendoDataSourceValue(source?.options?.data);
  if (!Array.isArray(localData) || localData.length === 0 || typeof source?.data !== "function") {
    return source;
  }
  try {
    const currentData = source.data();
    if ((currentData?.length || 0) === 0) {
      source.data([...localData]);
    }
  } catch (_error) {
    // noop
  }
  return source;
}

export function toKendoDataSourcePlainItem(item) {
  if (item && typeof item.toJSON === "function") {
    try {
      return item.toJSON();
    } catch (_error) {
      // noop
    }
  }
  return item;
}


export function getKendoDataSourceCollection(source) {
  return asKendoDataCollection(source);
}

function asKendoDataCollection(source) {
  if (!source) {
    return null;
  }
  try {
    if (typeof source?.data === "function") {
      return source.data();
    }
  } catch (_error) {
    // noop
  }
  return source;
}

export function toKendoDataSourcePlainItems(data) {
  if (!data) {
    return [];
  }
  try {
    if (typeof data?.toJSON === "function") {
      return data.toJSON();
    }
  } catch (_error) {
    // noop
  }
  return toArray(data).map(toKendoDataSourcePlainItem);
}

export function getKendoDataSourceItemAt(source, index) {
  try {
    const data = asKendoDataCollection(source);
    if (typeof data?.at === "function") {
      return data.at(index);
    }
    return toArray(data)[index] || null;
  } catch (_error) {
    return null;
  }
}

export function getKendoDataSourceTotal(source) {
  try {
    if (typeof source?.total === "function") {
      return source.total();
    }
  } catch (_error) {
    // noop
  }
  return getKendoDataSourceItems(source).length;
}

export function addKendoDataSourceItem(source, item) {
  try {
    if (typeof source?.add === "function") {
      return source.add(item);
    }
  } catch (_error) {
    // noop
  }
  const items = getKendoDataSourceItems(source);
  items.push(item);
  setKendoDataSourceItems(source, items);
  return item;
}

export function removeKendoDataSourceItem(source, item) {
  try {
    if (typeof source?.remove === "function") {
      return source.remove(item);
    }
  } catch (_error) {
    // noop
  }
  const items = getKendoDataSourceItems(source).filter((candidate) => candidate !== item && candidate?.uid !== item?.uid);
  return setKendoDataSourceItems(source, items);
}

export function getKendoDataSourceItemByUid(source, uid) {
  if (!uid) {
    return null;
  }
  try {
    if (typeof source?.getByUid === "function") {
      return source.getByUid(uid);
    }
  } catch (_error) {
    // noop
  }
  return getKendoDataSourceItems(source).find((item) => item?.uid === uid) || null;
}

export function bindKendoDataSourceEvent(source, eventName, handler) {
  try {
    if (typeof source?.bind === "function") {
      return source.bind(eventName, handler);
    }
  } catch (_error) {
    // noop
  }
  return null;
}

export function unbindKendoDataSourceEvent(source, eventName, handler) {
  try {
    if (typeof source?.unbind === "function") {
      return source.unbind(eventName, handler);
    }
  } catch (_error) {
    // noop
  }
  return null;
}

export function triggerKendoDataSourceEvent(source, eventName, args) {
  try {
    if (typeof source?.trigger === "function") {
      return source.trigger(eventName, args);
    }
  } catch (_error) {
    // noop
  }
  return null;
}

export function getKendoDataSourceTake(source) {
  try {
    if (typeof source?.take === "function") {
      return source.take();
    }
  } catch (_error) {
    // noop
  }
  return getKendoDataSourceItems(source).length;
}

export function getKendoDataSourceCurrentRangeStart(source) {
  const value = source?._currentRangeStart;
  return Number.isFinite(value) ? value : 0;
}

export function rangeKendoDataSource(source, start, take, callback) {
  try {
    if (typeof source?.range === "function") {
      return source.range(start, take, callback);
    }
  } catch (_error) {
    // noop
  }
  callback?.();
  return null;
}

export function readKendoDataSource(source) {
  try {
    if (typeof source?.read === "function") {
      return source.read();
    }
  } catch (_error) {
    // noop
  }
  return null;
}

export function refreshKendoDataSource(source) {
  try {
    if (typeof source?.read === "function") {
      return source.read();
    }
  } catch (_error) {
    // noop
  }
  try {
    if (typeof source?.fetch === "function") {
      return source.fetch();
    }
  } catch (_error) {
    // noop
  }
  return source;
}

export function getKendoDataSourceItems(source) {
  try {
    if (typeof source?.data === "function") {
      return toArray(source.data());
    }
  } catch (_error) {
    // noop
  }
  try {
    if (typeof source?.view === "function") {
      return toArray(source.view());
    }
  } catch (_error) {
    // noop
  }
  return toArray(source?.options?.data || source?.data);
}

export function getKendoDataSourcePlainItems(source) {
  try {
    if (typeof source?.data === "function") {
      return toKendoDataSourcePlainItems(source.data());
    }
  } catch (_error) {
    // noop
  }
  return getKendoDataSourceItems(source).map(toKendoDataSourcePlainItem);
}

export function getKendoDataSourceDirtyItems(source) {
  return getKendoDataSourceItems(source).filter((item) => item?.dirty);
}

export function setKendoDataSourceItems(source, items) {
  const normalizedItems = Array.isArray(items) ? [...items] : toArray(items);
  try {
    if (typeof source?.data === "function") {
      return source.data(normalizedItems);
    }
  } catch (_error) {
    // noop
  }
  if (source?.options) {
    source.options.data = normalizedItems;
  }
  return normalizedItems;
}

export function hasKendoDataSourceChanges(source) {
  try {
    if (typeof source?.hasChanges === "function") {
      return source.hasChanges();
    }
  } catch (_error) {
    // noop
  }
  return false;
}

export function syncKendoDataSource(source) {
  try {
    if (typeof source?.sync === "function") {
      return source.sync();
    }
  } catch (_error) {
    // noop
  }
  return null;
}
