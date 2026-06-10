import { ApiHelper } from "@/apis/AxiosHelper";
import _ from "underscore";
import moment from "moment";

/**
 * @description 年齢計算
 * @param {String} birthday 日付文字列(YYYYMMDD形式)
 * @return {Number} 年齢
 */
//  mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関 start
// export const calculateAge = birthday => {
//   return moment().diff(birthday, "years");
// };
export const calculateAge = (birthday,date) => {
  return moment(date).diff(birthday, "years");
};
// mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関  end

/**
 * @description 患者レコード取得(1患者)
 * @summary
 *   指定したpat_idのpat_personal_main, pat_main, pat_uniqueレコードを1つにして返す
 * @param {Number} patId
 * @return {Object} 患者情報オブジェクト({ pat_personal_main: { ... }, pat_main: { ... }, pat_unique: { ... } })
 */
export const getPatById = async (patId, facilityCd = null) => {
  const baseUri = "/patInfo/getPatSharingById";

  const validFacilityCd =
  facilityCd === undefined || facilityCd === null
    ? null
    : facilityCd;

  const uri = validFacilityCd
    ? `${baseUri}/${patId}/${validFacilityCd}`
    : `${baseUri}/${patId}`;

  const response = await ApiHelper.get(uri).catch(() => {
    throw new Error(
      "[PatInfoFunctions.js]getPatById(): APIエラー  404以外ならJavaのログ確認してください"
    );
  });

  return _.mapObject(response.data, patInfoJson => JSON.parse(patInfoJson));
};

/**
 * 編集用レコード変換関数用内部関数
 * @param {object} data 変換対象データ({ key: value })
 * @return {object} 編集用オブジェクト ({ key: { initValue: value, editValue: value } })
 */
const encodeEditableData = data => {
  // 変換用関数
  const mapFunc = val => ({ initValue: val, editValue: val });

  if (!_.isObject(data)) {
    // 単一カラムの場合
    return mapFunc(data);
  } else if (_.isArray(data)) {
    // JSON配列カラムの場合
    return data.map(obj => _.mapObject(obj, mapFunc));
  } else {
    // JSONカラムの場合
    return _.mapObject(data, mapFunc);
  }
};

/**
 * 編集用レコード変換
 *   APIで取得したレコードを共通タグで編集するための形式に変換する
 * @param {object} record 変換対象レコード
 * @return {object} 編集用オブジェクト
 */
export const encodeEditableRecord = record => {
  return _.mapObject(record, encodeEditableData);
};

/**
 * 編集用レコード復元関数用内部関数
 * @param {object} record 変換対象レコード
 * @return {object} 編集用オブジェクト
 */
const decodeEditableData = data => {
  // const mapFunc = obj => obj.editValue;
  const mapFunc = obj => obj?.editValue ?? null;

  if (!data) return data;

  if (data.editValue !== undefined) {
    // 単一カラムの場合
    return mapFunc(data);
  } else if (_.isArray(data)) {
    // JSON配列カラムの場合
    return data.map(obj => _.mapObject(obj, mapFunc));
  } else {
    // JSONカラムの場合
    return _.mapObject(data, mapFunc);
  }
};

/**
 * 編集用レコード復元
 *   共通タグ編集用形式のレコードを更新API用に元の形に変換する
 * @param {object} record 変換対象レコード
 * @return {object} 編集用オブジェクト
 */
export const decodeEditableRecord = record => {
  return _.mapObject(record, decodeEditableData);
};

/**
 * 編集用レコード変更箇所抽出用内部関数
 * @param {object} data 変換対象レコード
 * @return {object} 編集用オブジェクト
 */
const extractChangesData = data => {
  const mapFunc = obj => {
    if (obj && obj.editValue !== obj.initValue) {
      return obj;
    }
  }

  if (data.editValue !== undefined) {
    // 単一カラムの場合
    return mapFunc(data);
  } else if (_.isArray(data)) {
    // JSON配列カラムの場合
    const mapData = data.map(obj => _.mapObject(obj, mapFunc));
    if (mapData.length) {
      const filteredMapData = mapData.filter(item => {
        return JSON.stringify(item) !== "{}";
      })
      if (filteredMapData.length) {
        return mapData;
      }
    }
  } else {
    // JSONカラムの場合
    const mapData = _.mapObject(data, mapFunc);
    if (JSON.stringify(mapData) !== "{}") {
      return mapData;
    }
  }
};

/**
 * 編集用レコード変更箇所抽出
 *   共通タグ編集用形式のレコードから変更箇所を抽出
 * @param {object} record 変換対象レコード
 * @return {object} 編集用オブジェクト
 */
export const extractChangesRecord = record => {
  return _.mapObject(record, extractChangesData);
};
