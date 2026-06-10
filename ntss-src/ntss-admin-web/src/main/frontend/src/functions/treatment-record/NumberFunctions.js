import BigNumber from "bignumber.js";

/**
 * @description 符号付き小数判定
 * @param {String} string 判定する文字列
 * @returns {Boolean}
 */
export const isDecimal = string => {
  // 符号付き小数の正規表現
  const regexp = /^-?([1-9]\d*|0)(\.\d+)?$/;
  return regexp.test(string);
};

/**
 * @description 小数を指定桁数に丸める
 * @summary 普通にやると誤差が発生するのでBigNumber.jsを使用して計算する
 * @param {Number} decimal 小数
 * @param {Number} digits 桁数(デフォルト0桁)
 * @returns {Number} 指定桁数未満を切り捨てた値
 * @example
 *   truncateDecimal(1.2345) // 1
 *   truncateDecimal(1.2345, 3) // 1.234
 */
export const truncateDecimal = (decimal, digits = 0) => {
  // 小数点を指定桁数右にずらす
  const pow = Math.pow(10, digits);
  const multiplied = BigNumber(decimal).multipliedBy(pow);
  // 指定桁数未満を切り捨てる
  const truncated = multiplied.integerValue(BigNumber.ROUND_DOWN);
  // 小数点を元に戻す
  const divided = truncated.dividedBy(pow);
  return +divided;
};

/**
 * @description 小数の加算
 * @summary 普通にやると誤差が発生するのでBigNumber.jsを使用して計算する
 * @param {Number} decimals 小数(複数指定可)
 * @returns {Number} 加算結果
 * @example
 *   0.1 + 0.2; // 0.30000000000000004
 *   plusDecimal(0.1, 0.2) // 0.3
 */
export const plusDecimal = (...decimals) => {
  return +BigNumber.sum(...decimals);
};

/**
 * @description 小数の乗算
 * @summary 普通にやると誤差が発生するのでBigNumber.jsを使用して計算する
 * @param {Number} value1 被乗数
 * @param {Number} value2 乗数
 * @returns {Number} 乗算結果
 */
export const multiplyDecimal = (value1, value2) => {
  return BigNumber(value1)
    .multipliedBy(value2)
    .toNumber();
};

/**
 * @description 小数の除算
 * @summary 普通にやると誤差が発生するのでBigNumber.jsを使用して計算する
 * @param {Number} value1 被除数
 * @param {Number} value2 除数
 * @returns {Number} 除算結果
 */
export const divideDecimal = (value1, value2) => {
  return BigNumber(value1)
    .dividedBy(value2)
    .toNumber();
};
