import $ from "jquery";
import _ from "underscore";
import moment from "moment";
// add #10359 編集権限の動作不正 dengshen start
import store from "@/stores";
import {PAGE_AUTHORITY_CODES} from "@/constants/pageAuthorities";
// add #10359 編集権限の動作不正 dengshen end
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import {fitTermCheck} from "@/functions/common/DateTimeUtils";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";

/**
 * 日時文字列のフォーマット
 * @param {String} datetimeString 日時文字列
 * @param {String} formatTo フォーマット後の形式
 * @param {String} formatFrom フォーマット前の形式
 * @return {String}
 */
export const formatDatetime = (datetimeString, formatTo, formatFrom = null) => {
  if (formatFrom === null) {
    return datetimeString === "" ? "" : moment(datetimeString).format(formatTo);
  }
  return datetimeString === ""
    ? ""
    : moment(datetimeString, formatFrom).format(formatTo);
};

/**
 * オブジェクト、配列のディープコピー
 * @param {Object|Array} obj オブジェクト、または配列
 * @return {Object}
 */
export const deepCopy = obj => {
  return $.extend(true, _.isArray(obj) ? [] : {}, obj);
};

/**
 * オブジェクト、配列の場合は要素の値で比較する同一性の判定
 * Object以外の型の===で一致判定できない値（NaNなど）については未対応
 * （JSON.stringifyの結果は規格上では要素の順番が保証されていないため
 * オブジェクトの内容の一致比較にはこのような関数を使うことが望ましい）
 * @param {any} objA 比較する値
 * @param {any} objB 比較する値
 * @return {boolean}
 */
export const hasEqualValues = (objA, objB) => {
  if (objA === objB) return true;
  if (typeof objA !== typeof objB) return false;
  if (typeof objA !== "object") return objA === objB;
  if (Array.isArray(objA) !== Array.isArray(objB)) return false;

  if (Array.isArray(objA)) {
    return hasArrayEqualValues(objA, objB);
  } else {
    return hasObjectEqualValues(objA, objB);
  }
};

/**
 * 配列の要素の値で比較する同一性の判定
 * @param {Array} objA 配列
 * @param {Array} objB 配列
 * @return {boolean}
 */
export const hasArrayEqualValues = (objA, objB) => {
  if (objA.length !== objB.length) return false;
  return objA.every((item, index) => {
    if (typeof item !== "object") return item === objB[index];
    return hasEqualValues(item, objB[index]);
  });
};

/**
 * オブジェクトの要素の値で比較する同一性の判定
 * @param {Object} objA オブジェクト
 * @param {Object} objB オブジェクト
 * @return {boolean}
 */
export const hasObjectEqualValues = (objA, objB) => {
  if (objA === objB) return true;
  if ((objA === null) || (objB === null)) return false;

  const entriesA = Object.entries(objA);
  const entriesB = Object.entries(objB);
  if (entriesA.length !== entriesB.length) return false;
  return entriesA.every((entry) => {
    if (typeof entry[1] !== "object") return entry[1] === objB[entry[0]];
    return hasEqualValues(entry[1], objB[entry[0]]);
  });
};

/**
 * オブジェクト、配列のマージ
 * @param {Object|Array} baseObj ベース(マージ先)となるオブジェクト、または配列
 * @param {Object|Array} mergeObj マージ元となるオブジェクト、または配列
 */
export const merge = (baseObj, mergeObj) => {
  $.extend(true, baseObj, mergeObj);
};

/**
 * 整数文字列判定
 * @param {string} str 文字列
 * @return {boolean} true:整数文字列である false:整数文字列でない
 */
export const isIntegerString = str => {
  const regexp = new RegExp(/^[0-9]+$/);
  return regexp.test(str);
};

/**
 * 配列要素の最大値を取得
 * @param {array} array 数値のみの配列、またはオブジェクト配列
 * @param {string} propName (arrayがオブジェクト配列の場合)対象のプロパティ名
 * @return {number}
 */
export const arrayMaxValue = function(array, propName) {
  if (propName === undefined) {
    return Math.max(...array);
  } else {
    return Math.max(...array.map(el => el[propName]));
  }
};

/**
 * JSONカラムのデシリアライズ
 *   APIから取得したレコードのJSONカラムをデシリアライズする
 *   ※非破壊
 * @param {object} record 変換対象レコード
 * @param {string} jsonColumnNames 対象のJSONカラム名
 * @return {object} JSONカラムをデシリアライズしたレコード
 */
export const deserializeJsonColumn = (record, jsonColumnNames) => {
  // レコードをコピー
  const deserializedObj = deepCopy(record);
  for (const colName of jsonColumnNames) {
    // 指定したJSONカラムがレコードに存在するかチェック
    if (!_.contains(_.keys(record), colName)) {
      throw new Error(`JSONカラム[${colName}]は存在しません。`);
    }
    try {
      deserializedObj[colName] = JSON.parse(record[colName]);
    } catch (ex) {
      throw new Error(
        `JSONカラムのデシリアライズに失敗しました。(カラム:${colName})`
      );
    }
  }
  return deserializedObj;
};

/**
 * JSONカラムのシリアライズ
 *   APIに渡すレコードのJSONカラムをシリアライズする
 *   ※非破壊
 * @param {object} record 変換対象レコード
 * @param {string} jsonColumnNames 対象のJSONカラム名
 * @return {object} JSONカラムをシリアライズしたレコード
 */
export const serializeJsonColumn = (record, jsonColumnNames) => {
  // レコードをコピー
  const serializedObj = deepCopy(record);
  for (const colName of jsonColumnNames) {
    // 指定したJSONカラムがレコードに存在するかチェック
    if (!_.contains(_.keys(record), colName)) {
      throw new Error(`JSONカラム[${colName}]は存在しません。`);
    }
    try {
      serializedObj[colName] = JSON.stringify(record[colName]);
    } catch (ex) {
      throw new Error(
        `JSONカラムのシリアライズに失敗しました。(カラム:${colName})`
      );
    }
  }
  return serializedObj;
};

/**
 * マスタコードを名称に変換
 * @param {Array} mstData マスタデータ
 * @param {Number|String} mstCd 変換対象コード
 * @param {String} mstCdColumn カラム名(マスタコード)
 * @param {String} mstNameColumn カラム名(マスタ名称)
 * @return {String} マスタ名称
 */
export const mstCdToName = function(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null) {
    if (!_.has(mstData[0], mstCdColumn)) {
      // console.log(`カラム名(マスタコード)がマスタに存在しません。`);
      return "削除済み";
    }
    if (!_.has(mstData[0], mstNameColumn)) {
      // console.log(`カラム名(マスタ名称)がマスタに存在しません。`);
      return "削除済み";
    }
    // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる 関 start
    // const mstRecord = mstData.find(mst => mst[mstCdColumn] === mstCd);
    const mstRecord = mstData.find(mst => mst[mstCdColumn] == mstCd);
    // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる 関  end
    if (mstRecord === undefined) {
      return "削除済み";
    }
    return mstRecord[mstNameColumn];
  }
};

// add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
/**
 * マスタコードを名称に変換
 * @param {Array} mstData マスタデータ
 * @param {Number|String} mstCd 変換対象コード
 * @param {String} mstCdColumn カラム名(マスタコード)
 * @param {String} mstNameColumn カラム名(マスタ名称)
 * @return {String} マスタ名称
 */
export const mstCdToCountryName = function(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null) {
    if (!_.has(mstData[0], mstCdColumn)) {
      // console.log(`カラム名(マスタコード)がマスタに存在しません。`);
      return "削除済み";
    }
    if (!_.has(mstData[0], mstNameColumn)) {
      // console.log(`カラム名(マスタ名称)がマスタに存在しません。`);
      return "削除済み";
    }
    // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる 関 start
    // const mstRecord = mstData.find(mst => mst[mstCdColumn] === mstCd);
    const mstRecord = mstData.find(mst => mst[mstCdColumn] == mstCd);
    // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる 関  end
    if (mstRecord === undefined) {
      return "【削除済み】" + mstCd;
    }
    return mstRecord[mstNameColumn];
  }
};
// add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end

/**
 * マスタコードを名称に変換(存在しない場合は空を返却)
 * @param {Array} mstData マスタデータ
 * @param {Number|String} mstCd 変換対象コード
 * @param {String} mstCdColumn カラム名(マスタコード)
 * @param {String} mstNameColumn カラム名(マスタ名称)
 * @return {String} マスタ名称
 */
export const mstCdToNameFreeWord = function(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null && !isNaN(mstCd)) {
    if (!_.has(mstData[0], mstCdColumn)) {
      return null;
    }
    if (!_.has(mstData[0], mstNameColumn)) {
      return null
    }
    // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる 関 start
    // const mstRecord = mstData.find(mst => mst[mstCdColumn] === mstCd);
    const mstRecord = mstData.find(mst => mst[mstCdColumn] == mstCd);
    // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる 関  end
    if (mstRecord === undefined) {
      return null;
    }
    return mstRecord[mstNameColumn];
  }
  return null;
};

/**
 * マスタコードを名称に変換(削除済の場合は名称に【削除】を付与して返却)
 * @param {Array} mstData マスタデータ
 * @param {Number|String} mstCd 変換対象コード
 * @param {String} mstCdColumn カラム名(マスタコード)
 * @param {String} mstNameColumn カラム名(マスタ名称)
 * @param {Boolean} isDeleted 【削除済み】を必ず付与するか（defaultはfalse）
 * @return {String} マスタ名称
 */
export const mstCdToNameIncludeDeleted = function(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn,
  isDeleted = false
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null) {
    if (!_.has(mstData[0], mstCdColumn)) {
      return "削除済み";
    }
    if (!_.has(mstData[0], mstNameColumn)) {
      return "削除済み";
    }
    // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる 関 start
    // const mstRecord = mstData.find(mst => mst[mstCdColumn] === mstCd);
    const mstRecord = mstData.find(mst => mst[mstCdColumn] == mstCd);
    // mod 8304 【デグレ】実績マージを実行すると診療情報の一部が削除済みとなる 関  end
    if (mstRecord === undefined) {
      return "削除済み";
    }

    if (mstRecord.isDisp === "0" || mstRecord.isDel === "1") {
      return "【削除済み】" + mstRecord[mstNameColumn];
    }
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    if (mstRecord.isIncludeDel) {
      return "【削除済み含む】" + mstRecord[mstNameColumn];
    }
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    if (isDeleted) {
      return "【削除済み】" + mstRecord[mstNameColumn];
    }

    return mstRecord[mstNameColumn];
  }
  return null;
};

// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
/**
 * マスタコードを名称に変換(削除済の場合は名称に【削除】を付与して返却)
 * @param {Array} mstData マスタデータ
 * @param {Number|String} mstCd 変換対象コード
 * @param {String} mstCdColumn カラム名(マスタコード)
 * @param {String} mstNameColumn カラム名(マスタ名称)
 * @param {Boolean} isDeleted 【削除済み】を必ず付与するか（defaultはfalse）
 * @return {String} マスタ名称
 */
export const mstCdToNameIncludeExpiredAndDeleted = function(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn,
  isDeleted = false
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null) {
    if (!_.has(mstData[0], mstCdColumn)) {
      return "削除済み";
    }
    if (!_.has(mstData[0], mstNameColumn)) {
      return "削除済み";
    }

    const mstRecord = mstData.find(mst => mst[mstCdColumn] == mstCd);
    if (mstRecord === undefined) {
      return "削除済み";
    }

    let today = moment().format("YYYY-MM-DD");
    let expired = "";
    if (mstRecord.useEndDate && today < mstRecord.useEndDate) {
      expired = "【期限切れ】";
    }

    if (mstRecord.isDisp === "0" || mstRecord.isDel === "1") {
      return  expired + "【削除済み】" + mstRecord[mstNameColumn];
    }

    if (mstRecord.isIncludeDel) {
      return expired + "【削除済み含む】" + mstRecord[mstNameColumn];
    }

    if (isDeleted) {
      return expired + "【削除済み】" + mstRecord[mstNameColumn];
    }

    return expired + mstRecord[mstNameColumn];
  }
  return null;
};
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

/**
 * @description オブジェクト配列の重複排除
 * @summary
 *  指定したキーの値が一致するオブジェクトを配列から削除する
 *  ※後の要素が削除される
 *  ※非破壊
 * @param {Array} objAry オブジェクト配列
 * @param {String} uniqueKeys キー名 ※複数指定可
 * @return {Array} 重複排除された配列
 * @example
 *   const ary = [
 *     { foo: 1, bar: 2, baz: 1 },
 *     { foo: 2, bar: 2, baz: 1 },
 *     { foo: 1, bar: 2, baz: 3 }
 *   ];
 *   deduplicateObjects(ary, 'foo', 'bar'); // => [{ foo: 1, bar: 2, baz: 1 }, { foo: 2, bar: 2, baz: 1 }]
 */

export const deduplicateObjects = (objAry, ...uniqueKeys) => {
  return objAry.filter((obj1, index, thisAry) => {
    // キー値が同一となるオブジェクトの要素番号を検索し、
    // それが自身の番号と一致する要素のみを取り出す
    return (
      thisAry.findIndex(obj2 => {
        return uniqueKeys.every(key => obj1[key] === obj2[key]);
      }) === index
    );
  });
};
// 患者詳細検索の検索結果がサイドコンテンツにのみ反映される  5836  shan  start
export const deduplicateObjectsGroup = (objAry, ...uniqueKeys) => {
  return objAry.filter((obj1, index, thisAry) => {
    return (
      thisAry.findIndex(obj2 => {
        return uniqueKeys.every(key => obj1[key] === obj2[key]);
      }) === index
    );
  });
};
// 患者詳細検索の検索結果がサイドコンテンツにのみ反映される  5836  shan  end
// add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
/**
 * 全角の数値を半角に変換
 * */
export const convertToHalfWidth= (convertToHalfStr) =>{
  var parttern = /[０-９ー＋－．]/g;
  if(parttern.test(convertToHalfStr)){
    convertToHalfStr = convertToHalfStr.replace(parttern, function(match) {
      const fullToHalfMap = {
        '０': '0', '１': '1', '２': '2', '３': '3', '４': '4',
        '５': '5', '６': '6', '７': '7', '８': '8', '９': '9',
        '＋': '+', '－': '-', '．': '.', 'ー': '-'
      };
      return fullToHalfMap[match];
    });
    return convertToHalfStr;
  }else {
    return convertToHalfStr;
  }
}
// add #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
// add #10359 編集権限の動作不正 dengshen start
/**
 * 画面項目権限設定
 * @param pageCd 画面名
 * @param itemCd　項目名
 * @returns {Boolean}権限判定結果
 */
export const getAuthorized = (pageCd, itemCd) => {
  const userInfo = store.getters["account-edit/getStateUserAccountInfo"];
  let hasAuthorities = userInfo.userSettings.authorized_authorities;
  let authorizedLst = PAGE_AUTHORITY_CODES[pageCd][itemCd]["authority"];

  let retBoolean = authorizedLst.length == authorizedLst.filter(authority => {
    return authority.some(item => {
      return hasAuthorities.includes(item)
    });
  }).length;

  return retBoolean;
};
// add #10359 編集権限の動作不正 dengshen end
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
/**
 * 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応
 * @param {Boolean} isTaboo 禁忌
 * @param {Boolean} isAllergy アレルギー
 * @param {String} normalClassType 正常な分類です
 * @param {String || Array} classType 修正された分類です
 * @param {String} treatDate 治療日  
 * @param {String} useStartDate 開始日
 * @param {String} useEndDate  終了日
 * @param {String} maxUseStartDate  開始日(調製薬剤)
 * @param {String} minUseEndDate  終了日(調製薬剤)
 * @param {Boolean} isDisp 削除
 * @param {Boolean} isDel  削除 
 * @param {Boolean} isIncludeDel  削除済み含む 
 * @returns {String} つなぎ合わせた接頭辞です
 */
export const getPrefix = ({ isTaboo, isAllergy, normalClassType, classType, treatDate, useStartDate, useEndDate, maxUseStartDate, minUseEndDate, isDisp, isDel, isIncludeDel }) => {
  const TABOO_CLASS_PREFIX = "【禁忌】";
  const ALLERGY_CLASS_PREFIX = "【ｱﾚﾙｷﾞｰ】";
  const TABOO_ALLERGY_CLASS_PREFIX = "【禁忌・ｱﾚﾙｷﾞｰ】";
  const ClASSIFICATION_PREFIX = "【分類不一致】";
  const EXPIRED_DATE_PREFIX = "【期限切れ】";
  const DELETE_PREFIX = "【削除済み】";
  const INCLUDE_DELETED_PREFIX = "【削除済み含む】";
  let prefix = "";
  // 禁忌・アレルギー
  if (isTaboo && isAllergy) {
    prefix += TABOO_ALLERGY_CLASS_PREFIX;
  } else if (isTaboo && !isAllergy) {
    prefix += TABOO_CLASS_PREFIX;
  } else if (!isTaboo && isAllergy) {
    prefix += ALLERGY_CLASS_PREFIX;
  }
  // 分類不一致
  if (normalClassType != null && classType != null ) {
    if (Array.isArray(normalClassType)) {
      if (!normalClassType.includes(Number(classType))) {
        prefix += ClASSIFICATION_PREFIX;
      }
    } else if(normalClassType != classType) {
      prefix += ClASSIFICATION_PREFIX;
    }
  }
  // 期限切れ
  if (treatDate != null && !fitTermCheck(useStartDate, useEndDate, treatDate)) {
    prefix += EXPIRED_DATE_PREFIX;
  } else if (treatDate != null && !fitTermCheck(maxUseStartDate, minUseEndDate, treatDate)) {
    prefix += EXPIRED_DATE_PREFIX;
  }
  
  // 削除済み
  if (isDisp == 0 || isDel == 1) {
    prefix += DELETE_PREFIX;
  } else if (isIncludeDel) { // 削除済み含む
    prefix += INCLUDE_DELETED_PREFIX;
  }
  
  return prefix;
};
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
/**
 * 休日のスタイル取得
 * @param date 日付文字列
 * @param normalBackground 通常背景か否か
 * @return 休日のスタイル (ntss.cssに定義)
 */
export const getHolidayStyle = (date, normalBackground) => {
  if (!moment(date).isValid()) {
    return "";
  }
  const holidays = store.getters["mst-holiday/getHolidays"];
  const week = moment(date).day();
  let cssString = 
    week === 0 ? "list-header-sunday" :
    week === 6 ? (normalBackground ? "normal-background-saturday" : "list-header-saturday") :
    "";

  if (holidays[moment(date).format("YYYY-MM-DD")]) {
    cssString = "list-header-holiday";
  }

  return cssString;
};

/**
 * 施設設定マスタから自動更新サインアウトフラグを取得し、ストアに設定します
 * @param {object} targetStore 保存先ストア
 * @param {object} facilitySettingNo 施設設定番号
 */
export const initForceSignOutFlag = async (targetStore, facilitySettingNo) => {
  // ユーザーの施設コードを取得
  const facilityCd = store.getters["user/getFacilityCd"];
  // 施設設定値を取得
  const response = await getMstFacilitySettingValue(facilityCd, facilitySettingNo);
  const forceSignOutFlag = response.status === 200 && response.data ? response.data : 0;
  store.dispatch(targetStore, forceSignOutFlag);
};

/**
 * パスワード入力欄の伏字表示切り替えを行います
 * 使用した主な実装方法はLoginView.vueのコードを参照してください
 */
export const changeShowPassword = (event) => {
  const input = event.target.previousElementSibling;
  const type = input.getAttribute('type');
  input.setAttribute('type', type === 'password' ? 'text' : 'password');
  event.target.setAttribute('icon', type === 'password' ? 'fa-eye-slash' : 'fa-eye');
}

/**
 * 値の正規化:
 * "" / "null" / null → null
 * 数値文字列 → 数値
 * 数値 → 小数点の末尾0を除去
 */
export const normalizeValue = (value) => {
  if (value === "" || value === null || value === "null") return null;
  if (typeof value === "string" && !isNaN(value)) return Number(value);
  if (typeof value === "number") return parseFloat(value.toFixed(10));
  if (Array.isArray(value)) return value.map(v => normalizeValue(v));
  if (isPlainObject(value)) {
    const result = {};
    for (const k in value) result[k] = normalizeValue(value[k]);
    return result;
  }
  return value;
};

export const toObjectIfJson = (v) => {
  if (typeof v === "string") {
    try {
      return JSON.parse(v);
    } catch (e) {
      return v;
    }
  }
  return v;
};

/**
 * 深い比較（標準化後）
 */
export const isDeepEqualRelaxed = (a, b) => {
  

  if (a === b) return true;
  if (typeof a !== typeof b) return false;

  if (Array.isArray(a)) {
    if (a.length !== b.length) return false;
    for (let i = 0; i < a.length; i++) {
      if (!isDeepEqualRelaxed(a[i], b[i])) return false;
    }
    return true;
  }
//mod #12300 20260427 zhaojinzhao start
  // if (isPlainObject(a)) {
  //   const keysA = Object.keys(a);
  //   const keysB = Object.keys(b);
  //   if (keysA.length !== keysB.length) return false;
  //   for (const k of keysA) {
  //     if (!isDeepEqualRelaxed(a[k], b[k])) return false;
  //   }
  //   return true;
  // }
    if (isPlainObject(a) && isPlainObject(b)) {
    const keysA = Object.keys(a);
    const keysB = Object.keys(b);
    if (keysA.length !== keysB.length) return false;
    for (const k of keysA) {
      if (!isDeepEqualRelaxed(a[k], b[k])) return false;
    }
    return true;
  }
//mod #12300 20260427 zhaojinzhao end

  return a === b;
};
const isPlainObject = (obj) =>
  Object.prototype.toString.call(obj) === "[object Object]";

/**
 * ゆるやかJSON比較（高速判定付き）
 */
export const isJsonChanged = (initial, current) => {
  const initObj = toObjectIfJson(initial);
  const currObj = toObjectIfJson(current);
  const normA = normalizeValue(initObj);
  const normB = normalizeValue(currObj);
  return !isDeepEqualRelaxed(normA, normB);
};

/**
 * 文字列に禁忌・アレルギータグが含まれているかを判定する。
 *
 * @param {string} name - 判定する文字列。nullやundefined、文字列以外の場合はfalseを返却。
 * @returns {boolean} - タグが含まれていればtrue、含まれていなければfalse。
 */
export const containsTabooAllergyTag = (name) => {
  if (typeof name !== 'string') return false;
  const tags = ['【禁忌】', '【ｱﾚﾙｷﾞｰ】', '【禁忌・ｱﾚﾙｷﾞｰ】'];
  return tags.some(tag => name.includes(tag));
};
