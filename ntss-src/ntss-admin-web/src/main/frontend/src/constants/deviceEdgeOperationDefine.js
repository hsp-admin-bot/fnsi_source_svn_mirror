
/**
 * 与えられたキーでのソート関数
 *
 * @param {*} a 比較対象1
 * @param {*} b 比較対象2
 * @param {String} key ソートキー
 * @param {Boolean} isAsc 昇順の場合trueを指定(デフォルト)
 */
export const compareKey = (a, b, key, isAsc = true) => {
  a = a[key];
  b = b[key];

  let sortItem1;
  let sortItem2;

  if (a === b) {
    sortItem1 = 0;
  } else if (a > b) {
    sortItem1 = 1;
  } else {
    sortItem1 = -1;
  }
  if (isAsc) {
    sortItem2 = 1;
  } else {
    sortItem2 = -1;
  }
  return sortItem1 * sortItem2;
}

/**
 * 未接続発生順にソートに関する情報
 */
export const IS_ALARM_TEXT = "未接続発生順にソート";
