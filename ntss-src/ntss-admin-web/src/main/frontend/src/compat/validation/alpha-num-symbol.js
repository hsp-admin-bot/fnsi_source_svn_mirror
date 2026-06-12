// ユーザーID用の英字/数字/記号のバリデーションユーティリティ
export const ALPHA_NUM_SYMBOL_PATTERN = /^[a-zA-Z0-9&%$#@!_-]+$/;

export function isAlphaNumSymbol(value) {
  const normalized = value == null ? "" : String(value);
  return ALPHA_NUM_SYMBOL_PATTERN.test(normalized);
}

export default isAlphaNumSymbol;
