/**
 * 数値→文字列変換.
 * @param {*} value 数値
 */
export function numberToString(value) {
  return value === null ? null : value.toString();
}

/**
 * 文字列→数値変換.
 * @param {*} value 文字列
 */
export function stringToNumber(value) {
  return value === null ? null : Number(value);
}
