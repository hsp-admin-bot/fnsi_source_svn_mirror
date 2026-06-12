import { ApiHelper } from "@/apis/AxiosHelper";
import dayjs from "@/compat/date/dayjs";
import { mapObject, isUnderscoreObject } from "@/functions/common/CommonFunctions";

/**
 * @description 年齢計算
 * @param {String} birthday 日付文字列(YYYYMMDD形式)
 * @return {Number} 年齢
 */
//  mod 8294 死亡患者の年齢が現時点での年齢で表示されている 関 start
// export const calculateAge = birthday => {
//   return dayjs().diff(birthday, "years");
// };
export const calculateAge = (birthday, date) => {
  return dayjs(date).diff(birthday, "years");
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

  return mapObject(response.data, (patInfoJson) => JSON.parse(patInfoJson));
};

/**
 * 編集用レコード変換関数用内部関数
 * @param {object} data 変換対象データ({ key: value })
 * @return {object} 編集用オブジェクト ({ key: { initValue: value, editValue: value } })
 */
const encodeEditableData = (data) => {
  const mapFunc = (val) => ({ initValue: val, editValue: val });

  if (!isUnderscoreObject(data)) {
    return mapFunc(data);
  }
  if (Array.isArray(data)) {
    return data.map((obj) => mapObject(obj, mapFunc));
  }
  return mapObject(data, mapFunc);
};

/**
 * 編集用レコード変換
 *   APIで取得したレコードを共通タグで編集するための形式に変換する
 * @param {object} record 変換対象レコード
 * @return {object} 編集用オブジェクト
 */
export const encodeEditableRecord = (record) => {
  return mapObject(record, encodeEditableData);
};

/**
 * 編集用レコード復元関数用内部関数
 * @param {object} record 変換対象レコード
 * @return {object} 編集用オブジェクト
 */
const decodeEditableData = (data) => {
  const mapFunc = (obj) => obj?.editValue ?? null;

  if (!data) return data;

  if (data.editValue !== undefined) {
    return mapFunc(data);
  }
  if (Array.isArray(data)) {
    return data.map((obj) => mapObject(obj, mapFunc));
  }
  return mapObject(data, mapFunc);
};

/**
 * 編集用レコード復元
 *   共通タグ編集用形式のレコードを更新API用に元の形に変換する
 * @param {object} record 変換対象レコード
 * @return {object} 編集用オブジェクト
 */
export const decodeEditableRecord = (record) => {
  if (Array.isArray(record)) {
    return record.map((item) => decodeEditableData(item));
  }
  return mapObject(record, decodeEditableData);
};

/**
 * 編集用レコード変更箇所抽出用内部関数
 * @param {object} data 変換対象レコード
 * @return {object} 編集用オブジェクト
 */
const extractChangesData = (data) => {
  const mapFunc = (obj) => {
    if (obj && obj.editValue !== obj.initValue) {
      return obj;
    }
  };

  if (data.editValue !== undefined) {
    return mapFunc(data);
  }
  if (Array.isArray(data)) {
    const mapData = data.map((obj) => mapObject(obj, mapFunc));
    if (mapData.length) {
      const filteredMapData = mapData.filter((item) => {
        return JSON.stringify(item) !== "{}";
      });
      if (filteredMapData.length) {
        return mapData;
      }
    }
  } else {
    const mapData = mapObject(data, mapFunc);
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
export const extractChangesRecord = (record) => {
  return mapObject(record, extractChangesData);
};
