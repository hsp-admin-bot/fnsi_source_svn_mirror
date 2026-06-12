function toNumber(value) {
  if (value === "") {
    return value;
  }
  const numberValue = Number(value);
  return Number.isNaN(numberValue) ? value : numberValue;
}

export function applyModelModifiers(value, modifiers = {}) {
  let nextValue = value;
  if (modifiers.trim && typeof nextValue === "string") {
    nextValue = nextValue.trim();
  }
  if (modifiers.number) {
    nextValue = toNumber(nextValue);
  }
  return nextValue;
}

export function callModelHandler(handler, value, ...args) {
  if (Array.isArray(handler)) {
    handler.forEach((entry) => callModelHandler(entry, value, ...args));
    return;
  }
  if (typeof handler === "function") {
    handler(value, ...args);
  }
}

export function withModelModifierHandler(attrs = {}, options = {}) {
  const {
    updateEvent = "onUpdate:modelValue",
    modifiersKey = "modelModifiers"
  } = options;
  const forwardedAttrs = { ...attrs };
  const modifiers = forwardedAttrs[modifiersKey];
  const updateHandler = forwardedAttrs[updateEvent];

  if (modifiers && updateHandler) {
    forwardedAttrs[updateEvent] = (value, ...args) => {
      callModelHandler(updateHandler, applyModelModifiers(value, modifiers), ...args);
    };
  }

  delete forwardedAttrs[modifiersKey];
  return forwardedAttrs;
}
