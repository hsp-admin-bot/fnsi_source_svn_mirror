import { nextTick } from "@/compat/vue/runtime";
import { getComponentParent } from "@/functions/common/ComponentOwnerResolver";
import {
  resolveHostElement,
  resolveOwnerDocument,
  queryElementBySelectors,
} from "@/compat/dom";

export function normalizeValidationFieldName(value) {
  return String(value ?? "").trim();
}

export function normalizeValidationRules(rules) {
  if (rules == null || rules === false) {
    return "";
  }
  return rules;
}

export function getValidationOwnerCandidate(instance) {
  if (!instance) {
    return null;
  }
  const hasValidationApi = (candidate) => typeof candidate?.registerValidationField === "function"
    && typeof candidate?.validateField === "function";
  if (hasValidationApi(instance)) {
    return instance;
  }
  let current = getComponentParent(instance);
  while (current) {
    if (hasValidationApi(current)) {
      return current;
    }
    current = getComponentParent(current);
  }
  return instance;
}

export function resolveValidationOwner(instance) {
  const componentName = instance?.$options?.name;
  if (componentName === "DateInput" || componentName === "TimeInput") {
    return getValidationOwnerCandidate(getComponentParent(instance) || instance);
  }
  return getValidationOwnerCandidate(instance);
}

export function resolveValidationTarget(el) {
  const host = resolveHostElement(el) || el;
  if (!host) {
    return null;
  }
  if (typeof host.matches === "function" && host.matches("input, textarea, select, [contenteditable='true']")) {
    return host;
  }
  return queryElementBySelectors([
    "input:not([type='hidden'])",
    "textarea",
    "select",
    "[contenteditable='true']",
    "input",
  ], host) || host;
}

export function getValidationOwnerDocument(target) {
  return resolveOwnerDocument(target) || document;
}

export function getValidationAttr(target, el, names = []) {
  for (const name of names) {
    const targetValue = target?.getAttribute?.(name);
    if (targetValue != null && targetValue !== "") {
      return targetValue;
    }
    const elementValue = el?.getAttribute?.(name);
    if (elementValue != null && elementValue !== "") {
      return elementValue;
    }
  }
  return "";
}

export function buildValidationFieldMeta(el, binding) {
  const target = resolveValidationTarget(el);
  const scope = getValidationAttr(target, el, ["data-validation-scope", "validation-scope"]);
  const fieldName = getValidationAttr(target, el, ["data-validation-name", "name", "input-id", "id"]);
  const label = getValidationAttr(target, el, ["data-validation-label", "aria-label", "placeholder"]) || fieldName;
  const id = getValidationAttr(target, el, ["id", "input-id", "name"]) || fieldName;
  const fullName = scope && fieldName ? `${scope}.${fieldName}` : fieldName;

  return {
    el,
    target,
    id: normalizeValidationFieldName(id),
    scope: normalizeValidationFieldName(scope),
    label: normalizeValidationFieldName(label),
    fieldName: normalizeValidationFieldName(fieldName),
    fullName: normalizeValidationFieldName(fullName),
    rules: normalizeValidationRules(binding?.value),
    immediate: !!binding?.modifiers?.immediate,
    ownerDocument: getValidationOwnerDocument(target || el)
  };
}

export function extractValidationValue(target) {
  if (!target) {
    return undefined;
  }
  if (target.type === "checkbox") {
    return !!target.checked;
  }
  if (target.type === "radio") {
    const name = target.getAttribute?.("name");
    if (!name) {
      return target.checked ? target.value : undefined;
    }
    const doc = getValidationOwnerDocument(target);
    const escapedName = typeof CSS !== "undefined" && CSS.escape ? CSS.escape(name) : String(name).replace(/"/g, '\\"');
    const checked = doc.querySelector?.(`input[type="radio"][name="${escapedName}"]:checked`);
    return checked?.value;
  }
  if (target.tagName === "SELECT" && target.multiple) {
    return Array.from(target.selectedOptions || []).map((option) => option.value);
  }
  if (target.isContentEditable) {
    return target.textContent || "";
  }
  return target.value;
}

export function getObjectPathValue(source, path) {
  const normalized = normalizeValidationFieldName(path);
  if (!source || !normalized) {
    return undefined;
  }
  return normalized.split(".").reduce((current, key) => current?.[key], source);
}

export function queueValidationTask(callback) {
  return nextTick(() => {
    const requestFrame = typeof requestAnimationFrame === "function" ? requestAnimationFrame : (fn) => setTimeout(fn, 0);
    requestFrame(() => callback?.());
  });
}
