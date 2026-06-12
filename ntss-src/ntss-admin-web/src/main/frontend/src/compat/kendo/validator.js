import { KendoVueFormCompat, installKendoValidatorWrapper } from "@/compat/kendo/validator-wrapper.js";
import $ from "@/compat/jquery";
import { resolveHostElement, resolveOwnerDocument } from "@/compat/dom";
import {
  createJQueryValidator,
  destroyJQueryValidator,
  getJQueryValidator,
  prepareKendoJQueryServices,
} from "@/compat/kendo/kendo-jquery-services.js";

const validatorAdapters = new WeakMap();

function asJQueryElement(target = null) {
  if (target?.jquery) {
    return target;
  }
  const resolved = target?.element?.[0]
    || target?.wrapper?.[0]
    || target?.$el
    || target;
  return $(resolved || []);
}

function decorateValidationScope(target = null) {
  decorateValidationMessages(target);
  const scope = resolveValidationScope(target);
  const hasEditableGridTooltip = !!scope?.querySelector?.('.k-validator-tooltip .k-callout');
  if (!hasEditableGridTooltip) {
    appendFirstValidationCallout(target);
  }
  decorateInvalidFields(target);
}

function createValidatorAdapter(rawValidator, target) {
  if (!rawValidator) {
    return null;
  }
  if (rawValidator.rawValidator && rawValidator.__ntssKendoValidatorAdapter) {
    return rawValidator;
  }
  const cached = validatorAdapters.get(rawValidator);
  if (cached) {
    return cached;
  }
  const element = rawValidator.element || asJQueryElement(target);
  const wrapper = rawValidator.wrapper || element;
  const adapter = {
    __ntssKendoValidatorAdapter: true,
    element,
    wrapper,
    options: rawValidator.options || {},
    validate() {
      const result = !!rawValidator.validate?.();
      decorateValidationScope(wrapper?.[0] || element?.[0] || target);
      return result;
    },
    validateInput(input) {
      const inputElement = asJQueryElement(input);
      const result = rawValidator.validateInput
        ? !!rawValidator.validateInput(inputElement)
        : !!rawValidator.validate?.();
      decorateValidationScope(inputElement?.[0] || wrapper?.[0] || target);
      return result;
    },
    hideMessages() {
      const result = rawValidator.hideMessages?.();
      clearLegacyValidationMessages(wrapper?.[0] || element?.[0] || target);
      return result;
    },
    reset() {
      const result = rawValidator.reset?.();
      clearLegacyValidationMessages(wrapper?.[0] || element?.[0] || target);
      return result;
    },
    errors() {
      return rawValidator.errors?.() || [];
    },
    destroy() {
      if (target) {
        destroyJQueryValidator(target);
        return;
      }
      rawValidator.destroy?.();
    },
    rawValidator() {
      return rawValidator;
    },
    kendoWidget() {
      return rawValidator;
    }
  };
  rawValidator.element = rawValidator.element || element;
  rawValidator.wrapper = rawValidator.wrapper || wrapper;
  validatorAdapters.set(rawValidator, adapter);
  return adapter;
}

export async function prepareValidator() {
  return await prepareKendoJQueryServices();
}

export function createKendoValidator(target, options = {}) {
  const rawValidator = createJQueryValidator(target, options);
  const adapter = createValidatorAdapter(rawValidator, target);
  const element = resolveValidationTarget(target);
  if (element) {
    element.__ntssKendoValidator__ = adapter;
    element.classList?.add?.('k-validator', 'ntss-kendo-validator-legacy');
  }
  return adapter;
}

export function getValidator(target) {
  if (target?.__ntssKendoValidatorAdapter) {
    return target;
  }
  const element = resolveValidationTarget(target);
  return element?.__ntssKendoValidator__
    || createValidatorAdapter(getJQueryValidator(target), target);
}

export function destroyKendoValidator(target) {
  const raw = target?.rawValidator?.() || target;
  const element = resolveValidationTarget(target);
  if (element?.__ntssKendoValidator__) {
    delete element.__ntssKendoValidator__;
    element.classList?.remove?.('k-validator', 'ntss-kendo-validator-legacy');
  }
  const ElementCtor = element?.ownerDocument?.defaultView?.Element || globalThis.Element;
  if (raw?.element || raw?.wrapper || (ElementCtor && target instanceof ElementCtor)) {
    destroyJQueryValidator(target?.element?.[0] || target);
    return;
  }
  destroyJQueryValidator(target);
}

export function ensureKendoValidator(target, options = {}) {
  return getValidator(target) || createKendoValidator(target, options);
}

export function validateKendoValidator(target, options = {}) {
  return !!ensureKendoValidator(target, options)?.validate?.();
}

function resolveValidationTarget(root = null) {
  return resolveHostElement(root?.$el || root?.element?.[0] || root?.wrapper?.[0] || root)
    || root?.$el
    || root?.element?.[0]
    || root?.wrapper?.[0]
    || root
    || null;
}

function resolveValidationScope(root = null) {
  const target = resolveValidationTarget(root);
  if (target && typeof target.querySelectorAll === "function") {
    return target;
  }
  return null;
}

function getScopeDocument(scope = null) {
  return resolveOwnerDocument(scope) || null;
}

const LEGACY_VALIDATION_MESSAGE_SELECTOR = '.k-invalid-msg';
const VALIDATION_MESSAGE_SELECTOR = [
  '.k-invalid-msg',
  '.k-tooltip-validation',
  '.k-validation-message',
  '.k-form-error',
  '[data-for].k-form-error',
  '[data-valmsg-for]',
  '[role="alert"].k-form-error'
].join(',');

function uniqueElements(elements = []) {
  return Array.from(new Set(elements.filter(Boolean)));
}


function isConnectedValidationElement(element) {
  return !!element?.ownerDocument?.documentElement?.contains?.(element);
}

function pickCurrentValidationMessage(elements = [], root = null) {
  const connected = elements.filter(isConnectedValidationElement);
  const candidates = connected.length ? connected : elements.filter(Boolean);
  if (!candidates.length) {
    return null;
  }
  const scope = resolveValidationScope(root);
  const activeElement = scope?.ownerDocument?.activeElement || null;
  if (activeElement) {
    const activeMessage = candidates.find((message) => message === activeElement || message.contains?.(activeElement) || activeElement.contains?.(message));
    if (activeMessage) {
      return activeMessage;
    }
  }
  // popup/dialog 内で validation message が複数ある場合は、DOM 後方の現在層を優先する。
  return candidates[candidates.length - 1] || null;
}

function normalizeLegacyValidationMessageElement(element) {
  if (!element?.classList) {
    return element || null;
  }
  // Grid Editable は k-validator-tooltip と callout を既に持つ。legacy class を重ねるとレイアウト再計算で位置がちらつく。
  if (element.classList.contains('k-validator-tooltip')) {
    element.classList.add('k-invalid-msg');
    return element;
  }
  ['k-widget', 'k-tooltip', 'k-tooltip-validation', 'k-invalid-msg'].forEach((className) => {
    element.classList.add(className);
  });
  return element;
}

function decorateInvalidFields(root = null) {
  const scope = resolveValidationScope(root);
  if (!scope) {
    return [];
  }
  const invalidElements = uniqueElements(Array.from(scope.querySelectorAll?.([
    '.k-invalid',
    '.k-input-validation-error',
    '[aria-invalid="true"]'
  ].join(',')) || []));
  invalidElements.forEach((element) => {
    element.classList?.add?.('k-invalid');
    const wrapper = element.closest?.('.k-widget, .k-input, .k-input-inner, .k-picker, .k-dropdown, .k-dropdownlist, .k-multiselect, .k-numerictextbox');
    wrapper?.classList?.add?.('k-invalid');
  });
  return invalidElements;
}

function clearLegacyValidationMessages(root = null) {
  const scope = resolveValidationScope(root);
  if (!scope) {
    return;
  }
  Array.from(scope.querySelectorAll?.('.k-invalid') || []).forEach((element) => {
    element.classList?.remove?.('k-invalid');
  });
}

export function queryValidationElements(root = null, selector = VALIDATION_MESSAGE_SELECTOR) {
  const scope = resolveValidationScope(root);
  if (!scope) {
    return [];
  }
  const results = uniqueElements(Array.from(scope.querySelectorAll?.(selector) || []));
  if (selector === VALIDATION_MESSAGE_SELECTOR || selector === LEGACY_VALIDATION_MESSAGE_SELECTOR) {
    return results.map(normalizeLegacyValidationMessageElement).filter(Boolean);
  }
  return results;
}

export function decorateValidationMessages(root = null) {
  // runtime は validation message の検索と Vue2 旧 class 契約の復元だけを担当する。
  // callout の追加は appendValidationCallout へ集約し、利用側は実行タイミングだけを決める。
  return queryValidationElements(root);
}

export function appendValidationCallout(messageElement) {
  const message = normalizeLegacyValidationMessageElement(messageElement);
  if (!message || message.querySelector?.('.k-callout')) {
    return message || null;
  }
  const callout = message.ownerDocument?.createElement?.('div');
  if (!callout) {
    return message;
  }
  callout.className = 'k-callout k-callout-n';
  message.appendChild(callout);
  return message;
}

export function appendFirstValidationCallout(root = null) {
  const firstMessage = pickCurrentValidationMessage(queryValidationElements(root, LEGACY_VALIDATION_MESSAGE_SELECTOR), root)
    || pickCurrentValidationMessage(queryValidationElements(root), root)
    || null;
  return appendValidationCallout(firstMessage);
}

export function observeValidationMessages(root = null, callback = null) {
  const scope = resolveValidationScope(root);
  if (!scope) {
    return null;
  }
  const ownerWindow = getScopeDocument(scope)?.defaultView || window;
  const Observer = ownerWindow?.MutationObserver || MutationObserver;
  if (typeof Observer === 'undefined') {
    callback?.();
    return null;
  }
  let queued = false;
  const run = () => {
    queued = false;
    callback?.();
  };
  const observer = new Observer(() => {
    if (queued) {
      return;
    }
    queued = true;
    Promise.resolve().then(run);
  });
  observer.observe(scope, {
    subtree: true,
    childList: true,
    attributes: true,
    attributeFilter: ['class', 'style']
  });
  callback?.();
  return observer;
}

export function isValidationMessageElement(target) {
  return !!target?.closest?.(VALIDATION_MESSAGE_SELECTOR);
}

export { KendoVueFormCompat, installKendoValidatorWrapper };
