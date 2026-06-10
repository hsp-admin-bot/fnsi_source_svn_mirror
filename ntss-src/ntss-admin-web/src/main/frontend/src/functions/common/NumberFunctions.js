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
 * @param {Number} decimal 小数
 * @param {Number} digits 桁数(デフォルト0桁) ※decimalの小数桁より大きい場合は0を付加
 * @returns {String} 指定桁数未満を切り捨てた値 ※文字列なので注意
 * @example
 *   toFixed(2.345) // '2'
 *   toFixed(2.345, 2) // '2.34'
 *   toFixed(2.345, 4) // '2.3450'
 */
export const toFixed = (decimal, digits = 0) => {
  return BigNumber(decimal).toFixed(digits, 1);
};

/**
 * @description 小数を指定桁数に丸める
 * @param {Number} decimal 小数
 * @param {Number} digits 桁数(デフォルト0桁) ※decimalの小数桁より大きい場合は0を付加
 * @param {Number} roundingMode 丸めモード (デフォルト0: 四捨五入)
 *   - 0: 四捨五入
 *   - 1: 切り捨て
 *   - 2: 切り上げ
 *   - 3: 0に近い方に丸める
 *   - 4: 0から遠い方に丸める
 *   - 5: 絶対値が0.5の場合は偶数に丸める
 * @returns {String} 指定桁数未満を丸めた値 ※文字列なので注意
 * @example
 *   toFixedWithRoundingMode(2.345) // '2'
 *   toFixedWithRoundingMode(2.345, 2) // '2.34'
 *   toFixedWithRoundingMode(2.345, 4) // '2.3450'
 *   toFixedWithRoundingMode(2.345, 2, 1) // '2.34' (切り捨て)
 *   toFixedWithRoundingMode(2.3455, 2, 5) // '2.35' (偶数に丸める)
 */
export const toFixedWithRoundingMode  = (decimal, digits = 0, roundingMode = 0) => {
  return BigNumber(decimal).toFixed(digits, roundingMode);
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
 * @description 小数の減算
 * @summary 普通にやると誤差が発生するのでBigNumber.jsを使用して計算する
 * @param {Number} decimals 小数(複数指定可)
 * @returns {Number} 減算結果
 * @example
 *   0.3 - 0.1; // 0.19999999999999998
 *   minusDecimal(0.3, 0.1); // 0.2
 */
export const minusDecimal = (...decimals) => {
  let result = new BigNumber(decimals[0]);
  for (let i = 1; i < decimals.length; i++) {
    result = result.minus(decimals[i]);
  }
  return result.toNumber();
};

/**
 * @description 除算
 * @param {Number} value1 被除数
 * @param {Number} value2 除数
 * @returns {Number} 除算結果
 */
export const divide = (value1, value2) => {
  return BigNumber(value1)
    .dividedBy(value2)
    .toNumber();
};

/**
 * @description 除算(小数点切り捨て)
 * @param {Number} value1 被除数
 * @param {Number} value2 除数
 * @returns {Number} 除算結果
 */
export const divideDown = (value1, value2) => {
  return BigNumber(value1)
    .dividedBy(value2)
    .integerValue(BigNumber.ROUND_DOWN)
    .toNumber();
};

/**
 * @description 剰余演算
 * @param {Number} value1 被除数
 * @param {Number} value2 除数
 * @returns {Number} 剰余
 */
export const modulo = (value1, value2) => {
  return BigNumber(value1)
    .mod(value2)
    .toNumber();
};

/** String decimal point const */
export const DECIMAL_POINT = ".";
/** Zero String const */
export const ZERO_STRING = "0";

/**
 * Accurate addition method with multi-parameter
 *
 * @author Zhou.tao
 * @param addends
 * @returns {number} result
 */
export function accAdd(...addends) {
  let result = 0        // init the calculation's result
    , tempArr = []        // temp array for this calculation
    , decimalPoint = 0; // the largest digit

  if (addends) {
    // try to find out the largest digit among these params,and push this number into temp array.
    // if some addend is not a number, it will not participate in calculation.
    for (let aIdx in addends) {
      let tempNum = ZERO_STRING;
      try {
        tempNum = addends[aIdx].toString();
        if (!isDecimal(tempNum)) continue;
        let length = 0;
        if (tempNum.indexOf(DECIMAL_POINT) > 0)
          length = tempNum.split(DECIMAL_POINT)[1].length;
        decimalPoint = length > decimalPoint ? length : decimalPoint;
      } catch (e) {
        tempNum = ZERO_STRING;
      }
      tempArr.push(tempNum);
    }

    // ascending power the float number, use integer number to calculate.
    if (tempArr.length > 0) {

      if (tempArr.length === 1) return Number(tempArr[0]);

      let m = Math.pow(10, decimalPoint)
      for (let tmpIdx in tempArr) {
        result += Number(tempArr[tmpIdx]) * m;
      }
      // descending order
      result = result / m;
    }
  } else {
    return 0; // meaning false
  }
  return result;
}

/**
 * Accurate subtraction method
 *
 * @author Zhou.tao
 * @param subtrahend
 * @param minuend
 * @returns {number} result
 */
export function accSub(subtrahend, minuend) {
  let result = 0;
  let s, m, tp1, tp2, p = 0;

  s = isDecimal(subtrahend.toString()) ? Number(subtrahend) : 0
  m = isDecimal(minuend.toString()) ? Number(minuend) : 0;

  tp1 = s.toString().indexOf(DECIMAL_POINT) > 0
    ? s.toString().split(DECIMAL_POINT)[1].length : 0;

  tp2 = m.toString().indexOf(DECIMAL_POINT) > 0
    ? m.toString().split(DECIMAL_POINT)[1].length : 0;

  p = Math.pow(10, tp1 > tp2 ? tp1 : tp2);
  result = (s * p - m * p) / p;

  return result;
}

/**
 * Accurate multiplication method with multi-parameter
 *
 * @param multipliers
 * @returns {number|*} result
 */
export function accMulti(...multipliers) {
  let result = 1        // init the calculation's result
    , decimalPoint = 0; // the total digit length

  if (multipliers) {
    if (multipliers.length === 1) return multipliers[0];
    for (let key in multipliers) {
      let tempNum = ZERO_STRING;
      try {
        tempNum = multipliers[key].toString();
        if (!isDecimal(tempNum)) continue;
        let length = 0;
        if (tempNum.indexOf(DECIMAL_POINT) > 0)
          length = tempNum.split(DECIMAL_POINT)[1].length;
        decimalPoint += length;
        // commutative law of multiplication, change all the decimal into int value, and descending order in the end.
        result = result * Number(tempNum.replace(DECIMAL_POINT, ""));
      } catch (e) { continue; }
    }
    // descending order
    return  result / Math.pow(10, decimalPoint);
  } else {
    return 0; // meaning false
  }
}

/**
 * Simple Accurate Division method
 *
 * @param divider
 * @param dividend
 * @returns {number} result
 */
export function simpleAccDivision(divider, dividend) {
  let tDivider, pDivider = 0;
  let tDividend = 1, pDividend = 0;

  tDivider = isDecimal(divider.toString()) ? divider : 0;
  tDividend = isDecimal(dividend.toString())? dividend : 0;

  if (tDivider.toString().indexOf(DECIMAL_POINT) > 0) {
    pDivider = tDivider.toString().split(DECIMAL_POINT)[1].length;
    tDivider = Number(tDivider.toString().replace(DECIMAL_POINT, ""));
  }

  if (tDividend.toString().indexOf(DECIMAL_POINT) > 0) {
    pDividend = tDividend.toString().split(DECIMAL_POINT)[1].length;
    tDividend = Number(tDividend.toString().replace(DECIMAL_POINT, ""));
    // Dividend can not be 0. TODO Maybe return a NaN.
    tDividend = tDividend === 0 ? 1 : tDividend;
  }

  // with power exponent, the Divider & Dividend's Division can be a subtraction.
  return tDivider / tDividend * Math.pow(10, pDividend - pDivider);
}

