// Vue3 共通バリデーションメッセージ

function getRuleParam(rule) {
  if (Array.isArray(rule.params) && rule.params.length > 0) {
    return rule.params[0];
  }
  return rule.param;
}

export function buildValidationMessage(rule, context = {}) {
  const fieldLabel = context.label || context.fieldLabel || context.fieldName || "";
  const param = getRuleParam(rule);

  switch (rule.name) {
    case "max":
      return `${String(param).trim()}文字以内で入力してください。`;
    case "required":
      return "必須項目が入力されていません。";
    case "regex":
    case "date_format":
    case "numeric":
    case "alpha_num_symbol":
      return "入力形式に誤りがあります。";
    case "confirmed":
      return `${fieldLabel}が一致しません。`;
    default:
      return "入力形式に誤りがあります。";
  }
}

export default buildValidationMessage;
