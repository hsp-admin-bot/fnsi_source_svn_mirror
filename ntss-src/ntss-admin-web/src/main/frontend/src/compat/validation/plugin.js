import { configure, defineRule } from "vee-validate";
import dayjs from "@/compat/date/dayjs";
import buildValidationMessage from "@/compat/validation/messages.js";
import isAlphaNumSymbol from "@/compat/validation/alpha-num-symbol.js";

function isEmptyValue(value) {
  return value === undefined || value === null || value === "";
}

function defineCompatRule(name, validator) {
  try {
    defineRule(name, validator);
  } catch (_error) {
    // 同一 rule が複数回 install された場合でも Vue2 互換実行を止めない。
  }
}

export function installVeeValidateCompat() {
  configure({
    generateMessage: (context) => buildValidationMessage({
      name: context?.rule?.name || context?.rule || "",
      param: context?.rule?.params?.[0],
      params: context?.rule?.params || []
    }, {
      label: context?.field || ""
    }),
    validateOnBlur: true,
    validateOnChange: true,
    validateOnInput: false,
    validateOnModelUpdate: true
  });

  defineCompatRule("required", (value, params = []) => {
    if (params?.[0] === "invalidateFalse") {
      return value === true;
    }
    if (Array.isArray(value)) {
      return value.length > 0;
    }
    if (typeof value === "boolean") {
      return value;
    }
    return !isEmptyValue(value);
  });

  defineCompatRule("max", (value, params = []) => {
    if (isEmptyValue(value)) {
      return true;
    }
    return String(value).length <= Number(String(params?.[0]).trim());
  });

  defineCompatRule("min", (value, params = []) => {
    if (isEmptyValue(value)) {
      return true;
    }
    const minValue = params?.[0];
    const numericValue = typeof value === "number" ? value : Number(value);
    const numericMin = Number(minValue);
    const isNumericText = typeof value === "number" || /^-?\d+(\.\d+)?$/.test(String(value));
    if (isNumericText && Number.isFinite(numericValue) && Number.isFinite(numericMin)) {
      return numericValue >= numericMin;
    }
    return String(value).length >= numericMin;
  });

  defineCompatRule("alpha_num_symbol", (value) => isEmptyValue(value) || isAlphaNumSymbol(value));

  defineCompatRule("date_format", (value, params = []) => {
    if (isEmptyValue(value)) {
      return true;
    }
    const format = params?.[0];
    const text = String(value);
    if (format === "yyyy-MM-dd") {
      return /^\d{4}-\d{2}-\d{2}$/.test(text) && dayjs(text, "YYYY-MM-DD", true).isValid();
    }
    if (format === "HH:mm") {
      return /^\d{2}:\d{2}$/.test(text) && dayjs(text, "HH:mm", true).isValid();
    }
    return true;
  });

  defineCompatRule("confirmed", (value, params = [], context = {}) => {
    if (isEmptyValue(value)) {
      return true;
    }
    const target = context?.form?.[params?.[0]];
    return String(value) === String(target ?? "");
  });
}

export default {
  install(app) {
    installVeeValidateCompat();
    if (app?.config?.globalProperties) {
      app.config.globalProperties.$veeValidateCompat = {
        defineRule,
        configure
      };
    }
  }
};
