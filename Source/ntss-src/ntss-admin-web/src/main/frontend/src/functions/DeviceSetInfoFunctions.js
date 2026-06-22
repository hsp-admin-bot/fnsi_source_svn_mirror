import { ApiHelper } from "@/apis/AxiosHelper";
import { deepCopy } from "@/functions/common/CommonFunctions";

/**
 * @description  装置設置DB更新処理
 * @param data         一覧データ(deviceSetInfo)
 * @param sizeComparisonData
 *     上限下限比較データ(sizeComparisonDictionary、sizeComparisonDictionaryZeroIgnore)
 * @param table_flag   テーブル区分
 *     0->システムのみ、1->患者情報のみ、2->治療情報(指示)のみ、4->システム&患者情報、5->システム&治療情報
 * @param facility_cd  施設コード
 * @param pat_id       患者ID
 * @param ord_no       Ord番号
 * @param start_date   治療開始日
 * @param end_date     治療終了日
 * @param week         曜日パターン(配列)
 * @param treat_method 治療方法(配列)
 * @param kur_cd       クールコード(配列)
 * @return data        変更後の一覧データ
 */
export const updateDeviceSetInfo = (
  data,
  table_flag,
  sizeComparisonData,
  facility_cd,
  pat_id,
  ord_no,
  start_date,
  end_date,
  week,
  treat_method,
  kur_cd
) => {
  const sendJson = {};
  table_flag = Number(table_flag);
  if (table_flag === 0) {
    sendJson.table_flag = table_flag;
    sendJson.second_table_flag = null;
  } else if (table_flag === 1) {
    sendJson.table_flag = table_flag;
    sendJson.second_table_flag = null;
  } else if (table_flag === 2) {
    sendJson.table_flag = table_flag;
    sendJson.second_table_flag = null;
  } else if (table_flag === 3) {
    sendJson.table_flag = table_flag;
    sendJson.second_table_flag = null;
  } else if (table_flag === 4) {
    sendJson.table_flag = 0;
    sendJson.second_table_flag = 1;
  } else if (table_flag === 5) {
    sendJson.table_flag = 0;
    sendJson.second_table_flag = 2;
  }
  sendJson.facility_cd = facility_cd;
  sendJson.pat_id = pat_id;
  sendJson.ord_no = ord_no;
  sendJson.start_date = start_date;
  sendJson.end_date = end_date;
  sendJson.week = week;
  sendJson.treat_method = treat_method;
  sendJson.kur_cd = kur_cd;
  sendJson.update_data = JSON.stringify(
    createUpdateData(deepCopy(data), 0, sizeComparisonData)
  );
  ApiHelper.post("/deviceSetInfo/updateDeviceSetInfo", sendJson);
};

/**
 *
 * @param data                一覧データ(deviceSetInfo)
 * @param flag                戻り値フラグ 0->DB用更新用データ 1->変更有無フラグ
 * @param sizeComparisonData  上限下限比較データ
 * @return flagにより戻り値変更
 */
export const createUpdateData = (data, flag, sizeComparisonData) => {
  const updateData = {};
  // DBデータ画面キー
  let screen_key;
  // DBデータタグキー(装置設定タグ、次患者タグ)
  let first_key;
  // DBデータAorBorCタグ
  let second_key;
  // 数値キー
  let thrid_key;
  // 変更回数
  let changeCount = 0;
  // 上限下限値キー(内部データ)
  let comparsionKey = null;
  // 上限下限値キー(DB数値キー)
  let conparsionNum = null;
  for (const key in data) {
    // 内部データのキー取得
    screen_key = data[key].screenKey;
    first_key = data[key].key1;
    second_key = data[key].key2;
    thrid_key = data[key].key3;
    if (
      null !== sizeComparisonData &&
      undefined !== sizeComparisonData &&
      0 !== sizeComparisonData.length
    ) {
      comparsionKey = getLimitsKey(sizeComparisonData, key);
      if (null !== comparsionKey) {
        conparsionNum = String(Number(comparsionKey.slice(-4)));
      }
    }
    // 初期値と編集値が異なる場合、更新用データを格納する
    if (data[key].initValue !== data[key].editValue) {
      data[key].initValue = data[key].editValue;
      changeCount++;
      if (screen_key in updateData) {
        if (first_key in updateData[screen_key]) {
          if (second_key in updateData[screen_key][first_key]) {
            updateData[screen_key][first_key][second_key][thrid_key] =
              data[key].editValue;
            if (null !== comparsionKey) {
              // 変更したデータが上限値下限値の場合、片方の値も更新データに入れる
              updateData[screen_key][first_key][second_key][conparsionNum] =
                data[comparsionKey].editValue;
            }
          } else {
            updateData[screen_key][first_key][second_key] = {};
            updateData[screen_key][first_key][second_key][thrid_key] =
              data[key].editValue;
            if (null !== comparsionKey) {
              // 変更したデータが上限値下限値の場合、片方の値も更新データに入れる
              updateData[screen_key][first_key][second_key][conparsionNum] =
                data[comparsionKey].editValue;
            }
          }
        } else {
          updateData[screen_key][first_key] = {};
          updateData[screen_key][first_key][second_key] = {};
          updateData[screen_key][first_key][second_key][thrid_key] =
            data[key].editValue;
          if (null !== comparsionKey) {
            // 変更したデータが上限値下限値の場合、片方の値も更新データに入れる
            updateData[screen_key][first_key][second_key][conparsionNum] =
              data[comparsionKey].editValue;
          }
        }
      } else {
        updateData[screen_key] = {};
        updateData[screen_key][first_key] = {};
        updateData[screen_key][first_key][second_key] = {};
        updateData[screen_key][first_key][second_key][thrid_key] =
          data[key].editValue;
        if (null !== comparsionKey) {
          // 変更したデータが上限値下限値の場合、片方の値も更新データに入れる
          updateData[screen_key][first_key][second_key][conparsionNum] =
            data[comparsionKey].editValue;
        }
      }
    }
  }
  let sendData;
  if (flag === 0) {
    if (changeCount > 0) {
      sendData = updateData;
      return sendData;
    } else {
      return null;
    }
  } else {
    if (changeCount > 0) {
      return true;
    } else {
      return false;
    }
  }
};

/**
 * 上限値下限値キー取得
 * @param  sizeComparisonData 上限値下限値キー情報
 * @param  key 検索用キー(keyを元についになるキーを検索)
 * @return keyと対になる上限下限値キー
 */
const getLimitsKey = (sizeComparisonData, key) => {
  let sizeComparisonkey = null;
  sizeComparisonData.forEach(eleDispItem => {
    if (eleDispItem.big === key) {
      // キーが上限値の場合、戻り値は下限値
      sizeComparisonkey = eleDispItem.small;
    } else if (eleDispItem.small === key) {
      // キーが下限値の場合、戻り値は上限値
      sizeComparisonkey = eleDispItem.big;
    }
  });
  return sizeComparisonkey;
};

/**
 *
 * @param data  変更するデータ
 * @param flag  0 -> 時間型データ   1 -> 数値型データ
 * @return flagにより戻り値変更
 */
export const changeTimeData = (data, flag) => {
  let changeData;
  let hour;
  let min;
  if (flag === 0) {
    // 数値データ型 --> 時間型データ(HHmm)
    if (data.editValue !== "") {
      hour = String(Math.floor(Number(data.editValue) / 60));
      if (hour.length === 1) {
        hour = `0${hour}`;
      }
      min = String(Number(data.editValue) % 60);
      if (min.length === 1) {
        min = `0${min}`;
      }
      changeData = {
        initValue: `${hour}${min}`,
        editValue: `${hour}${min}`
      };
    } else {
      changeData = {
        initValue: null,
        editValue: null
      };
    }
  } else {
    // 時間型データ(HHmm) --> 数値データ型
    if (data === "" || data === null) {
      changeData = "";
    } else {
      hour = Number(String(data).slice(0, -2));
      min = Number(String(data).slice(2));
      changeData = hour * 60 + min;
    }
  }
  return changeData;
};

export const changeNumToDate = data => {
  const hour = `0${String(Math.floor(Number(data) / 60))}`.slice(-2);
  const min = `0${String(Number(data) % 60)}`.slice(-2);
  return `${hour}:${min}`;
};

/**
 * 配列 -> API引数用JsonArray
 * @param 配列
 * @return Json配列
 */
export const changeJsonArray = data => {
  const jsonArray = [];
  for (let i = 0; i < data.length; i++) {
    jsonArray.push({ value: data[i] });
  }
  return JSON.stringify(jsonArray);
};

/**
 * 大小チェック
 **/
export const sizeComparison = (
  equalAcceptFlag,
  bigOne,
  smallOne,
  messageDialogInfo
) => {
  const ret = messageDialogInfo;

  if (equalAcceptFlag) {
    if (bigOne.editValue < smallOne.editValue) {
      const str = `${bigOne.clauseName}≧${smallOne.clauseName}`;
      ret.messageCd = "23010002";
      ret.type = "1";
      ret.stringParams = [str];
      ret.isDialogVisible = true;
      // console.log(`error : 「${str}」となるように設定してください。`);
    }
  } else {
    if (bigOne.editValue <= smallOne.editValue) {
      const str = `${bigOne.clauseName}＞${smallOne.clauseName}`;
      ret.messageCd = "23010002";
      ret.type = "1";
      ret.stringParams = [str];
      ret.isDialogVisible = true;
      // console.log(`error : 「${str}」となるように設定してください。`);
    }
  }
  return ret;
};

/**
 * 必須項目チェック
 * @param data 画面で保有しているデータ(deviceSetInfo)
 * @return 必須項目入力漏れの項目名文字列 (漏れがなければnullを返す)
 */
export const checkRequiredItem = data => {
  for (const checkData in data) {
    if (
      null === data[checkData].editValue ||
      "" === data[checkData].editValue
    ) {
      return data[checkData].clauseName;
    }
  }
  return null;
};

/**
 * 風袋・除水 2データ間の差異取得
 * @param initData 修正前データ
 * @param editData 修正後データ
 * @return 差異データ
 */
export const createDifferenceData = (initData, editData) => {
  let differenceData = {};
  let editCount = 0;
  for (const weekNum in initData) {
    for (const itemName in initData[weekNum]) {
      if (weekNum in editData) {
        if (initData[weekNum][itemName] !== editData[weekNum][itemName]) {
          editCount++;
          if (weekNum in differenceData) {
            differenceData[weekNum][itemName] = editData[weekNum][itemName];
          } else {
            differenceData[weekNum] = {};
            differenceData[weekNum][itemName] = editData[weekNum][itemName];
          }
        }
      }
    }
  }
  if (editCount === 0) {
    differenceData = null;
  }
  return differenceData;
};
