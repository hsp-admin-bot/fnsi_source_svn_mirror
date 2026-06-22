function cloneKendoValue(value) {
  return Array.isArray(value) ? [...value] : value;
}

export function normalizeKendoValue(value, fallback = null) {
  if (value === undefined) {
    return fallback;
  }
  return cloneKendoValue(value);
}

export function isSameKendoValue(left, right) {
  const leftIsArray = Array.isArray(left);
  const rightIsArray = Array.isArray(right);
  if (leftIsArray || rightIsArray) {
    const leftValue = leftIsArray ? left : [];
    const rightValue = rightIsArray ? right : [];
    if (leftValue.length !== rightValue.length) {
      return false;
    }
    return leftValue.every((value, index) => String(value) === String(rightValue[index]));
  }
  return String(left ?? "") === String(right ?? "");
}

export function readLegacySenderValue(sender, fallback = null) {
  if (!sender) {
    return fallback;
  }
  if (typeof sender.value === "function") {
    try {
      const value = sender.value();
      return value === undefined ? fallback : cloneKendoValue(value);
    } catch (_error) {
      return fallback;
    }
  }
  if (Object.prototype.hasOwnProperty.call(sender, "_value") && typeof sender._value !== "function") {
    return cloneKendoValue(sender._value);
  }
  return fallback;
}

export function readLegacySenderText(sender, fallback = "") {
  if (!sender) {
    return fallback;
  }
  if (typeof sender.text === "function") {
    try {
      const text = sender.text();
      return text === undefined || text === null ? fallback : text;
    } catch (_error) {
      return fallback;
    }
  }
  return sender._oldText ?? fallback;
}

export function updateLegacySenderState(sender, {
  value,
  text,
  dataItem,
  dataItems,
  selectedIndex,
  currentDataItem,
  currentDataItems,
  element,
  wrapper
} = {}) {
  if (!sender || typeof sender !== "object") {
    return sender;
  }

  const resolvedValue = value !== undefined ? cloneKendoValue(value) : readLegacySenderValue(sender, sender._old);
  sender._old = cloneKendoValue(resolvedValue);
  if (!Array.isArray(resolvedValue)) {
    // jQuery Kendo DropDownList 2026 keeps an internal _value() method.
    // Vue2 wrapper code exposed scalar _value only on wrapper-side senders; do not
    // shadow jQuery Kendo internals or widget.value(...) will fail in _dataValue().
    if (typeof sender._value !== "function") {
      sender._value = resolvedValue;
    }
    if (typeof sender._valueBeforeCascade !== "function") {
      sender._valueBeforeCascade = resolvedValue;
    }
  }

  if (text !== undefined) {
    sender._oldText = text ?? "";
  } else if (sender._oldText === undefined) {
    sender._oldText = readLegacySenderText(sender, "");
  }

  const resolvedCurrentDataItem = currentDataItem !== undefined ? currentDataItem : dataItem;
  if (resolvedCurrentDataItem !== undefined) {
    sender.currentDataItem = resolvedCurrentDataItem;
  }

  const resolvedCurrentDataItems = currentDataItems !== undefined ? currentDataItems : dataItems;
  if (resolvedCurrentDataItems !== undefined) {
    sender.currentDataItems = Array.isArray(resolvedCurrentDataItems)
      ? [...resolvedCurrentDataItems]
      : resolvedCurrentDataItems;
  }

  if (selectedIndex !== undefined) {
    sender.selectedIndex = selectedIndex;
  }

  if (element !== undefined) {
    sender.element = element;
  }

  if (wrapper !== undefined) {
    sender.wrapper = wrapper;
  }

  return sender;
}

export function createLegacyKendoEvent(rawEvent = null, sender = null, payload = {}) {
  const resolvedSender = updateLegacySenderState(sender || rawEvent?.sender || payload?.sender, payload);
  const event = rawEvent && typeof rawEvent === "object"
    ? { ...rawEvent }
    : {};

  Object.assign(event, payload);
  event.sender = resolvedSender;

  if (rawEvent && typeof rawEvent.preventDefault === "function") {
    event.preventDefault = rawEvent.preventDefault.bind(rawEvent);
  }
  if (rawEvent && typeof rawEvent.isDefaultPrevented === "function") {
    event.isDefaultPrevented = rawEvent.isDefaultPrevented.bind(rawEvent);
  }

  if (event.value === undefined) {
    event.value = readLegacySenderValue(resolvedSender, payload.value);
  }
  if (event.text === undefined && resolvedSender?._oldText !== undefined) {
    event.text = resolvedSender._oldText;
  }
  if (event.dataItem === undefined && resolvedSender?.currentDataItem !== undefined) {
    event.dataItem = resolvedSender.currentDataItem;
  }
  if (event.dataItems === undefined && resolvedSender?.currentDataItems !== undefined) {
    event.dataItems = Array.isArray(resolvedSender.currentDataItems)
      ? [...resolvedSender.currentDataItems]
      : resolvedSender.currentDataItems;
  }

  return event;
}

export function withProgrammaticKendoUpdate(sender, callback) {
  if (!sender || typeof sender !== "object") {
    return callback();
  }
  sender.__ntssSuppressChange = (sender.__ntssSuppressChange || 0) + 1;
  try {
    return callback();
  } finally {
    sender.__ntssSuppressChange -= 1;
    if (sender.__ntssSuppressChange <= 0) {
      delete sender.__ntssSuppressChange;
    }
  }
}

export function isKendoChangeSuppressed(sender) {
  return !!sender?.__ntssSuppressChange;
}
