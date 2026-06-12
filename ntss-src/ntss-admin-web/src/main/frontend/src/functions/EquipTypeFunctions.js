
/**
 * 部材(医療材料・ダイアライザ)の医療材料区分 equipType に関する共通関数.
 */

/**
 * DB永続化用のコードからダイアライザ用の内部展開したコード表現にする.
 * @param {any} cd DB永続化用のコード(例: 1 ).
 * @param {Number} equipType equipType (0:医療材料, 1:ダイアライザ).
 * @returns {any} "dialyzer"を付与したコード(例: "dialyzer1" )、または引数そのままの値(医療材料の場合).
 * 
 */
export const encryptPersistentCodeToInternalCd = (cd=null, equipType=0) => {
  if (!cd) {return null};
  return equipType === 1 ? "dialyzer" + cd : cd
};

/** 
 * ダイアライザの場合内部展開したコード表現をDB永続化用のコードに戻す.
 * @param {String} cd string 内部的なコード(例: "dialyzer1" ).
 * @returns {any} "dialyzer"を除いた数値(例: 1 )または引数そのままの値(医療材料の場合).
 */
export const decryptDialyzerCdToPersistentCode = (cd=null) => {
  if (!cd) {return null};
  let ret = cd;
  if (typeof cd === "string" && cd.indexOf("dialyzer") !== -1) {
    ret = Number(cd.replace(/dialyzer/g, ""));
  }
  return ret;
};

/**
 * 内部展開したコード表現から医療材料区分を判別する.
 * @param {any} cd 医療材料コード.
 * @returns {Number} 1: 医療材料区分はダイアライザ, 0: 医療材料区分は医療材料.
 */
export const detectEquipTypeFromCode = (cd=null) => {
  if (!cd) {return null};
  return typeof cd === "string" && cd.indexOf("dialyzer") !== -1 ? 1 : 0;
};
