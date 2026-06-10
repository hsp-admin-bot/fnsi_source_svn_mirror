import { isIntegerString } from "@/functions/common/CommonFunctions";

/**
 * 整数文字列検証
 */
export const validateInteger = value => {
  let invalidReason = "";
  if (!isIntegerString(value)) {
    invalidReason = "値が不正です。";
  }
  return invalidReason;
};

/**
 * 文字列長(最大長)検証
 * @param {number} maxLength 最大長
 */
export const validateMaxLength = maxLength => value => {
  let invalidReason = "";
  if (maxLength < value.length) {
    invalidReason = `値が長すぎます。(最大値:${maxLength})`;
  }
  return invalidReason;
};

/**
 * メールアドレス検証
 */
export const validateEmailAddress = str => {
  let invalidReason = "";
  const regexp = new RegExp(
    "/^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$/"
  );
  if (!regexp.test(str)) {
    invalidReason = "メールアドレスの形式が不正です。";
  }
  return invalidReason;
};

/**
 * ID検証
 */
export const validateID = str => {
  let invalidReason = "";

  const regexp = new RegExp("^[a-zA-Z0-9]*$");
  if (!regexp.test(str)) {
    invalidReason = "IDの形式が不正です。\n半角英数字のみ登録できます。";
  }
  return invalidReason;
};
