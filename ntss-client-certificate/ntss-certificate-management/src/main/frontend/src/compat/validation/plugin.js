import { reactive } from "vue";

const customRules = Object.create(null);
let localeMessages = {};

function unwrapInput(el) {
  if (!el) return null;
  if (el.matches && (el.matches("input") || el.matches("textarea") || el.matches("select"))) return el;
  return el.querySelector?.("input, textarea, select") || el._input || null;
}

function getFieldName(el, input) {
  return (
    el.getAttribute?.("data-vv-name") ||
    input?.getAttribute?.("data-vv-name") ||
    el.getAttribute?.("name") ||
    input?.getAttribute?.("name") ||
    el.getAttribute?.("input-id") ||
    input?.getAttribute?.("id") ||
    el.getAttribute?.("id") ||
    ""
  );
}

function getValue(input) {
  if (!input) return "";
  if (input.type === "checkbox") return input.checked;
  return input.value ?? "";
}

function parseRules(ruleValue) {
  if (!ruleValue) return [];
  if (typeof ruleValue === "string") return ruleValue.split("|").filter(Boolean);
  if (Array.isArray(ruleValue)) return ruleValue;
  if (typeof ruleValue === "object") {
    return Object.keys(ruleValue)
      .filter(key => !!ruleValue[key])
      .map(key => ruleValue[key] === true ? key : `${key}:${ruleValue[key]}`);
  }
  return [];
}

function messageFor(name, rule, alias, param) {
  const label = alias || name;
  const messages = localeMessages?.dictionary?.ja?.messages || localeMessages?.messages || localeMessages || {};
  if (rule === "required") return messages.required ? messages.required(label, []) : `${label}は必須です`;
  if (rule === "confirmed") return messages.confirmed ? messages.confirmed(label, []) : `${label}が一致しません`;
  if (rule === "regex" || rule === "alpha_num_symbol") return messages.regex ? messages.regex(label, []) : `${label}の形式が正しくありません`;
  if (rule === "min") return messages.min ? messages.min(label, [param]) : `${label}は${param}文字以上を入力してください`;
  if (rule === "max") return messages.max ? messages.max(label, [param]) : `${label}は${param}文字以内で入力してください`;
  return `${label}の形式が正しくありません`;
}

function createErrorBag() {
  const state = reactive({ items: [] });
  const api = {
    items: state.items,
    has(name) {
      return state.items.some(item => item.field === name);
    },
    first(name) {
      const hit = state.items.find(item => item.field === name);
      return hit ? hit.msg : undefined;
    },
    remove(name) {
      for (let i = state.items.length - 1; i >= 0; i -= 1) {
        if (state.items[i].field === name) state.items.splice(i, 1);
      }
    },
    add(error) {
      api.remove(error.field);
      state.items.push(error);
    },
    clear() {
      state.items.splice(0, state.items.length);
    }
  };
  return api;
}

const errors = createErrorBag();
const validator = {
  errors,
  reset() {
    errors.clear();
  },
  validate() {
    return Promise.resolve(errors.items.length === 0);
  },
  validateAll() {
    return Promise.resolve(errors.items.length === 0);
  }
};

function validateElement(el, ruleValue) {
  const input = unwrapInput(el);
  const name = getFieldName(el, input);
  if (!name) return true;
  const alias = el.getAttribute?.("data-vv-as") || input?.getAttribute?.("data-vv-as") || name;
  const value = getValue(input);
  const rules = parseRules(ruleValue);
  errors.remove(name);

  for (const rawRule of rules) {
    const [rule, ...rest] = String(rawRule).split(":");
    const param = rest.join(":");
    if (rule === "required" && (value === "" || value === null || value === undefined || value === false)) {
      errors.add({ field: name, msg: messageFor(name, "required", alias), rule });
      return false;
    }
    if (rule === "regex") {
      try {
        const rx = new RegExp(param);
        if (value && !rx.test(String(value))) {
          errors.add({ field: name, msg: messageFor(name, "regex", alias), rule });
          return false;
        }
      } catch {
        return true;
      }
    }
    if (rule === "min" && value && String(value).length < Number(param)) {
      errors.add({ field: name, msg: messageFor(name, "min", alias, param), rule });
      return false;
    }
    if (rule === "max" && value && String(value).length > Number(param)) {
      errors.add({ field: name, msg: messageFor(name, "max", alias, param), rule });
      return false;
    }
    if (rule === "min_value" && value !== "" && Number(value) < Number(param)) {
      errors.add({ field: name, msg: messageFor(name, "min_value", alias, param), rule });
      return false;
    }
    if (rule === "max_value" && value !== "" && Number(value) > Number(param)) {
      errors.add({ field: name, msg: messageFor(name, "max_value", alias, param), rule });
      return false;
    }
    if (rule === "numeric" && value !== "" && !/^\d+$/.test(String(value))) {
      errors.add({ field: name, msg: messageFor(name, "numeric", alias, param), rule });
      return false;
    }
    if (rule === "after" && value) {
      const target = new Date(param);
      const current = new Date(value);
      if (!Number.isNaN(target.valueOf()) && !Number.isNaN(current.valueOf()) && current <= target) {
        errors.add({ field: name, msg: messageFor(name, "after", alias, param), rule });
        return false;
      }
    }
    if (rule === "confirmed") {
      const other = document.querySelector(`[name="${param}"], #${param}`);
      const otherValue = getValue(unwrapInput(other));
      if (value && otherValue !== value) {
        errors.add({ field: name, msg: messageFor(name, "confirmed", alias), rule });
        return false;
      }
    }
    if (customRules[rule]) {
      const result = customRules[rule](value, param);
      if (!result) {
        errors.add({ field: name, msg: messageFor(name, rule, alias), rule });
        return false;
      }
    }
  }
  return true;
}

function bind(el, binding) {
  const run = () => validateElement(el, binding.value);
  el.__legacyValidateRun = run;
  setTimeout(run, 0);
  const input = unwrapInput(el);
  if (input && !el.__legacyValidateBound) {
    ["input", "change", "blur"].forEach(evt => input.addEventListener(evt, run));
    el.__legacyValidateBound = { input, run };
  }
}

function unbind(el) {
  const bound = el.__legacyValidateBound;
  if (bound?.input && bound?.run) {
    ["input", "change", "blur"].forEach(evt => bound.input.removeEventListener(evt, bound.run));
  }
  const input = unwrapInput(el);
  const name = getFieldName(el, input);
  if (name) errors.remove(name);
}

const LegacyValidation = {
  install(app, messages = {}) {
    localeMessages = messages || {};
    app.config.globalProperties.errors = errors;
    app.config.globalProperties.$validator = validator;
    app.mixin({
      beforeCreate() {
        if (!this.errors) this.errors = errors;
      }
    });
    app.directive("validate", {
      mounted: bind,
      updated: bind,
      unmounted: unbind
    });
  }
};

export const Validator = {
  localize(_locale, messages) {
    localeMessages = messages || localeMessages;
  },
  extend(name, rule) {
    customRules[name] = value => {
      if (!rule) return true;
      if (typeof rule === "function") return rule(value);
      if (typeof rule.validate === "function") return rule.validate(value);
      return true;
    };
  }
};

export default LegacyValidation;
