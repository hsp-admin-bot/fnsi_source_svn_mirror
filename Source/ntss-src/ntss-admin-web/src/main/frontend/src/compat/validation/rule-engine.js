import dayjs from "@/compat/date/dayjs";
import buildValidationMessage from "@/compat/validation/messages.js";
import isAlphaNumSymbol from "@/compat/validation/alpha-num-symbol.js";

function isEmptyValue(value) {
  return value === undefined || value === null || value === "";
}

function parseRuleToken(token) {
  const trimmed = String(token || "").trim();
  if (!trimmed) {
    return null;
  }
  const separatorIndex = trimmed.indexOf(":");
  if (separatorIndex < 0) {
    return {
      name: trimmed,
      param: undefined,
      params: []
    };
  }
  const name = trimmed.slice(0, separatorIndex).trim();
  const rawParam = trimmed.slice(separatorIndex + 1).trim();
  return {
    name,
    param: rawParam,
    params: rawParam === "" ? [] : rawParam.split(",").map((item) => item.trim())
  };
}

export function parseRuleSpec(ruleSpec) {
  if (!ruleSpec) {
    return [];
  }

  if (typeof ruleSpec === "string") {
    return ruleSpec
      .split("|")
      .map(parseRuleToken)
      .filter(Boolean);
  }

  if (Array.isArray(ruleSpec)) {
    return ruleSpec
      .flatMap((item) => parseRuleSpec(item))
      .filter(Boolean);
  }

  if (typeof ruleSpec === "object") {
    return Object.entries(ruleSpec)
      .filter(([, enabled]) => !!enabled)
      .map(([name, param]) => ({
        name,
        param,
        params: param === undefined ? [] : [param]
      }));
  }

  return [];
}

function validateDateFormat(value, format) {
  if (isEmptyValue(value)) {
    return true;
  }

  const text = String(value);
  if (format === "yyyy-MM-dd") {
    return /^\d{4}-\d{2}-\d{2}$/.test(text) && dayjs(text, "YYYY-MM-DD", true).isValid();
  }
  if (format === "HH:mm") {
    return /^\d{2}:\d{2}$/.test(text) && dayjs(text, "HH:mm", true).isValid();
  }
  return true;
}

function validateMinRule(value, minValue) {
  if (isEmptyValue(value)) {
    return true;
  }

  const numericValue = typeof value === "number" ? value : Number(value);
  const numericMin = Number(minValue);
  const isNumericText = typeof value === "number" || /^-?\d+(\.\d+)?$/.test(String(value));
  if (isNumericText && Number.isFinite(numericValue) && Number.isFinite(numericMin)) {
    return numericValue >= numericMin;
  }

  return String(value).length >= numericMin;
}

function validateRule(rule, value, context) {
  switch (rule.name) {
    case "required": {
      if (rule.param === "invalidateFalse") {
        return value === true;
      }
      if (Array.isArray(value)) {
        return value.length > 0;
      }
      if (typeof value === "boolean") {
        return value;
      }
      return !isEmptyValue(value);
    }
    case "max":
      if (isEmptyValue(value)) {
        return true;
      }
      return String(value).length <= Number(String(rule.param).trim());
    case "min":
      return validateMinRule(value, rule.param);
    case "alpha_num_symbol":
      if (isEmptyValue(value)) {
        return true;
      }
      return isAlphaNumSymbol(value);
    case "date_format":
      return validateDateFormat(value, rule.param);
    case "confirmed": {
      if (isEmptyValue(value)) {
        return true;
      }
      const targetField = context.resolveFieldValue?.(rule.param);
      return String(value) === String(targetField ?? "");
    }
    case "dialysisDate": {
      const validationResult = context.customRules?.dialysisDate?.(value, context);
      return validationResult;
    }
    default:
      return true;
  }
}

export function runValidationRules(ruleSpec, value, context = {}) {
  const rules = parseRuleSpec(ruleSpec);
  for (const rule of rules) {
    const result = validateRule(rule, value, context);
    if (result === true) {
      continue;
    }
    if (typeof result === "string") {
      return {
        valid: false,
        message: result,
        rule
      };
    }
    return {
      valid: false,
      message: buildValidationMessage(rule, context),
      rule
    };
  }
  return {
    valid: true,
    message: "",
    rule: null
  };
}

export default runValidationRules;
