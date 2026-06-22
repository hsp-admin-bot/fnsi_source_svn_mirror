
import dayjs from "@/compat/date/dayjs";
// add #10359 編集権限の動作不正 dengshen start
import store from "@/stores";
import { PAGE_AUTHORITY_CODES } from "@/constants/pageAuthorities";

// add #10359 編集権限の動作不正 dengshen end
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { fitTermCheck } from "@/functions/common/DateTimeUtils";

// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";

import _ from "@/compat/collections/lodash";
import $ from "@/compat/jquery";

/** Object.prototype.hasOwnProperty の安全ラッパー */
export function hasOwn(obj, key) {
  return obj != null && Object.prototype.hasOwnProperty.call(obj, key);
}

/**
 * Underscore mapObject 相当（プレーンオブジェクトの各値を変換）
 * @param {Record<string, any>} obj
 * @param {(value: any, key: string, object: object) => any} iteratee
 */
export function mapObject(obj, iteratee) {
  if (obj == null || typeof obj !== "object" || Array.isArray(obj)) {
    return {};
  }
  const out = {};
  for (const k of Object.keys(obj)) {
    out[k] = iteratee(obj[k], k, obj);
  }
  return out;
}

/**
 * Underscore isObject 相当（null 以外の object 型）
 */
export function isObjectLoose(v) {
  return v != null && typeof v === "object";
}

/** Underscore _.isObject と同等（function も true） */
export function isUnderscoreObject(v) {
  return v != null && (typeof v === "object" || typeof v === "function");
}

/**
 * Underscore propertyOf 相当。path はキー配列（例: [1, "value"]）
 * @param {object} obj
 * @returns {(path: string|number|Array<string|number>) => any}
 */
export function propertyOf(obj) {
  return function (path) {
    if (obj == null) return undefined;
    if (!Array.isArray(path)) {
      return obj[path];
    }
    let cur = obj;
    for (const p of path) {
      cur = cur == null ? undefined : cur[p];
    }
    return cur;
  };
}

/**
 * 日時文字列のフォーマット
 * @param {String} datetimeString 日時文字列
 * @param {String} formatTo フォーマット後の形式
 * @param {String} formatFrom フォーマット前の形式
 * @return {String}
 */
export const formatDatetime = (datetimeString, formatTo, formatFrom = null) => {
  if (formatFrom === null) {
    return datetimeString === "" ? "" : dayjs(datetimeString).format(formatTo);
  }
  return datetimeString === ""
    ? ""
    : dayjs(datetimeString, formatFrom).format(formatTo);
};

/**
 * オブジェクト、配列のディープコピー
 * @param {Object|Array} obj オブジェクト、または配列
 * @return {Object}
 */
export const deepCopy = obj => {
  return $.extend(true, Array.isArray(obj) ? [] : {}, obj);
};

/**
 * 施設設定などで保存されている「配列文字列」を安全に配列へ変換
 * eval を使わず、JSON 文字列 / 単純な配列表現 / 既存配列を許容する
 * @param {any} value
 * @return {string[]}
 */
export const parseStoredArray = value => {
  if (Array.isArray(value)) {
    return value.map(item => String(item));
  }
  if (value == null) {
    return [];
  }

  const raw = String(value).trim();
  if (raw === "") {
    return [];
  }

  const tryParse = source => {
    const parsed = JSON.parse(source);
    if (Array.isArray(parsed)) {
      return parsed.map(item => String(item));
    }
    return null;
  };

  try {
    const parsed = tryParse(raw);
    if (parsed) {
      return parsed;
    }
  } catch (_) {
    // JSON 形式ではない場合は次の候補を試す
  }

  try {
    const parsed = tryParse(raw.replace(/'/g, '"'));
    if (parsed) {
      return parsed;
    }
  } catch (_) {
    // 単純配列表現として解釈する
  }

  const match = raw.match(/^\[(.*)\]$/s);
  if (!match) {
    return [];
  }

  return match[1]
    .split(",")
    .map(item => item.trim())
    .filter(item => item !== "")
    .map(item => item.replace(/^['"]|['"]$/g, ""));
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
    if (!Object.keys(record).includes(colName)) {
      throw new Error(`JSONカラム[${colName}]は存在しません。`);
    }
    try {
      deserializedObj[colName] = JSON.parse(record[colName]);
    } catch (ex) {
      throw new Error(
        `JSONカラムのデシリアライズに失敗しました。(カラム:${colName})`,
        { cause: ex }
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
    if (!Object.keys(record).includes(colName)) {
      throw new Error(`JSONカラム[${colName}]は存在しません。`);
    }
    try {
      serializedObj[colName] = JSON.stringify(record[colName]);
    } catch (ex) {
      throw new Error(
        `JSONカラムのシリアライズに失敗しました。(カラム:${colName})`,
        { cause: ex }
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
export function mstCdToName(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null) {
    if (!hasOwn(mstData[0], mstCdColumn)) {
      // console.log(`カラム名(マスタコード)がマスタに存在しません。`);
      return "削除済み";
    }
    if (!hasOwn(mstData[0], mstNameColumn)) {
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
}

// add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
/**
 * マスタコードを名称に変換
 * @param {Array} mstData マスタデータ
 * @param {Number|String} mstCd 変換対象コード
 * @param {String} mstCdColumn カラム名(マスタコード)
 * @param {String} mstNameColumn カラム名(マスタ名称)
 * @return {String} マスタ名称
 */
export function mstCdToCountryName(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null) {
    if (!hasOwn(mstData[0], mstCdColumn)) {
      // console.log(`カラム名(マスタコード)がマスタに存在しません。`);
      return "削除済み";
    }
    if (!hasOwn(mstData[0], mstNameColumn)) {
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
}
// add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end

/**
 * マスタコードを名称に変換(存在しない場合は空を返却)
 * @param {Array} mstData マスタデータ
 * @param {Number|String} mstCd 変換対象コード
 * @param {String} mstCdColumn カラム名(マスタコード)
 * @param {String} mstNameColumn カラム名(マスタ名称)
 * @return {String} マスタ名称
 */
export function mstCdToNameFreeWord(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null && !isNaN(mstCd)) {
    if (!hasOwn(mstData[0], mstCdColumn)) {
      return null;
    }
    if (!hasOwn(mstData[0], mstNameColumn)) {
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
}

/**
 * マスタコードを名称に変換(削除済の場合は名称に【削除】を付与して返却)
 * @param {Array} mstData マスタデータ
 * @param {Number|String} mstCd 変換対象コード
 * @param {String} mstCdColumn カラム名(マスタコード)
 * @param {String} mstNameColumn カラム名(マスタ名称)
 * @param {Boolean} isDeleted 【削除済み】を必ず付与するか（defaultはfalse）
 * @return {String} マスタ名称
 */
export function mstCdToNameIncludeDeleted(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn,
  isDeleted = false
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null) {
    if (!hasOwn(mstData[0], mstCdColumn)) {
      return "削除済み";
    }
    if (!hasOwn(mstData[0], mstNameColumn)) {
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
}

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
export function mstCdToNameIncludeExpiredAndDeleted(
  mstData,
  mstCd,
  mstCdColumn,
  mstNameColumn,
  isDeleted = false
) {
  if (mstData !== null && mstData.length > 0 && mstCd !== null) {
    if (!hasOwn(mstData[0], mstCdColumn)) {
      return "削除済み";
    }
    if (!hasOwn(mstData[0], mstNameColumn)) {
      return "削除済み";
    }

    const mstRecord = mstData.find(mst => mst[mstCdColumn] == mstCd);
    if (mstRecord === undefined) {
      return "削除済み";
    }

    let today = dayjs().format("YYYY-MM-DD");
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
}
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
 * @param itemCd 項目名
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
  // #12505 接頭文字対応 ligh edit start
  // 調製薬剤本体が削除済みかつ構成薬に削除ありの場合、両方付与
  if (isDisp == 0 || isDel == 1) {
    prefix += DELETE_PREFIX;
  }
  if (isIncludeDel) {
    prefix += INCLUDE_DELETED_PREFIX;
  }
  // #12505 接頭文字対応 ligh edit end
  
  return prefix;
};
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
/**
 * 送信後接頭文字追加
 * 禁忌、アレルギー、の接頭文字対応
 * @param {Boolean} isTaboo 禁忌
 * @param {Boolean} isAllergy アレルギー
 * @returns {String} つなぎ合わせた接頭辞です
 */
export const getPrefixSend = ({ isTaboo, isAllergy }) => {
  const TABOO_CLASS_PREFIX = "【禁忌】";
  const ALLERGY_CLASS_PREFIX = "【ｱﾚﾙｷﾞｰ】";
  const TABOO_ALLERGY_CLASS_PREFIX = "【禁忌・ｱﾚﾙｷﾞｰ】";
  let prefix = "";
  if (isTaboo && isAllergy) {
    prefix += TABOO_ALLERGY_CLASS_PREFIX;
  } else if (isTaboo && !isAllergy) {
    prefix += TABOO_CLASS_PREFIX;
  } else if (!isTaboo && isAllergy) {
    prefix += ALLERGY_CLASS_PREFIX;
  }
  return prefix;
};

/**
 * 休日のスタイル取得
 * @param date 日付文字列
 * @param normalBackground 通常背景か否か
 * @return 休日のスタイル (ntss.cssに定義)
 */
export const getHolidayStyle = (date, normalBackground) => {
  if (!dayjs(date).isValid()) {
    return "";
  }
  const holidays = store.getters["mst-holiday/getHolidays"];
  const week = dayjs(date).day();
  let cssString = 
    week === 0 ? "list-header-sunday" :
    week === 6 ? (normalBackground ? "normal-background-saturday" : "list-header-saturday") :
    "";

  if (holidays[dayjs(date).format("YYYY-MM-DD")]) {
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
  const target = event?.currentTarget || event?.target;
  if (!target) {
    return;
  }

  const wrapper = typeof target.closest === 'function'
    ? target.closest('.password-wrapper')
    : null;
  const input = wrapper?.querySelector?.('input, .text-input, .ons-input__control, .text-input__input')
    || target.previousElementSibling;

  if (!input || typeof input.getAttribute !== 'function' || typeof input.setAttribute !== 'function') {
    return;
  }

  const type = input.getAttribute('type');
  const nextType = type === 'password' ? 'text' : 'password';
  input.setAttribute('type', nextType);

  const nextIcon = nextType === 'password' ? 'fa-eye' : 'fa-eye-slash';
  if (typeof target.setAttribute === 'function') {
    target.setAttribute('icon', nextIcon);
  }
  if (target.classList) {
    target.classList.remove('fa-eye', 'fa-eye-slash');
    target.classList.add(nextIcon);
  }
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


//#11219 カスタム HTML 安全フィルタ関数
export const customSanitizer = (rawHtml) => {
  if (!rawHtml) return '';

  const parser = new DOMParser();
  const decodedHtml = rawHtml.replace(/\\"/g, '"');
  const doc = parser.parseFromString(decodedHtml, 'text/html');

  // 1. タグのホワイトリスト：'IMG' を追加
  const allowedTags = ['P', 'SPAN', 'BR', 'B', 'STRONG', 'I', 'EM', 'DEL', 'U', 'IMG'];

  // 2. スタイルのホワイトリスト：従来どおり、画像向けに width/height を追加
  const allowedStyles = [
    'font-family', 'font-size', 'color', 'background-color',
    'text-decoration', 'white-space', 'width', 'height'
  ];

  const sanitizeNode = (node) => {
    var htmlText = ''
    Array.from(node.childNodes).forEach(child => {
      if (child.nodeType === 1) {
        const tagName = child.tagName;

        // タグが許可されているか確認
        // console.log(allowedTags.includes(tagName),tagName);
        if (!allowedTags.includes(tagName)) {
          // 1. child ノードを文字列に変換する（タグ自体を含む）
          const nodeAsString = child.outerHTML;
          // 2. テキストノードを作成し、直前に変換した文字列を内容とする
          // 注意：createTextNode は < > などの文字を自動エスケープし、ブラウザによる HTML 解析を防ぐ
          const textNode = document.createTextNode(nodeAsString);
          child.parentNode.replaceChild(textNode, child);
          return;
        }

        // --- 属性処理ロジック ---
        const styles = child.style;
        const safeStylePairs = [];
        let safeSrc = '';

        // スタイルを処理
        allowedStyles.forEach(prop => {
          const value = styles.getPropertyValue(prop);
          if (value) safeStylePairs.push(`${prop}: ${value}`);
        });

        // IMG の src 属性を専用処理
        if (tagName === 'IMG') {
          const src = child.getAttribute('src') || '';
          // 安全検証：http、https、base64 画像のみ許可
          if (src.match(/^(https?:\/\/|data:image\/)/i)) {
            safeSrc = src;
          } else {
            const nodeAsString = child.outerHTML;
            // 2. テキストノードを作成し、直前に変換した文字列を内容とする
            // 注意：createTextNode は < > などの文字を自動エスケープし、ブラウザによる HTML 解析を防ぐ
            const textNode = document.createTextNode(nodeAsString);
            child.parentNode.replaceChild(textNode, child);
            return;
          }
        }

        // 元の属性をすべて削除（onerror、onclick などを除去）
        while (child.attributes.length > 0) {
          child.removeAttribute(child.attributes[0].name);
        }

        // 安全な属性を再設定
        if (safeStylePairs.length > 0) {
          child.setAttribute('style', safeStylePairs.join('; '));
        }
        if (tagName === 'IMG' && safeSrc) {
          child.setAttribute('src', safeSrc);
          // 画像がコンテナをはみ出さないようデフォルトスタイルを付与
          child.style.maxWidth = '100%';
        }

        sanitizeNode(child);
      }
    });
  };

  sanitizeNode(doc.body);
  return doc.body.innerHTML;
};
