/* eslint-disable */

import {deepCopy} from "@/functions/common/CommonFunctions";

/**
 * マスタ選択画面(ポップオーバー)表示用オブジェクト作成
 * @param {String} popoverTitleHeader ヘッダ名
 * @param {String} popoverFilterLabel フィルタ名
 * @param {Array} popoverFilterDataset フィルタ用データセット ※わからん適当
 * @param {String} popoverContentLabel マスタ内容名称
 * @param {Array} mstData マスタレコード配列
 * @param {String} mstCdColumn カラム名(マスタコード)
 * @param {String} mstNameColumn カラム名(マスタ名称)
 * @param {} objFn ※わからん
 * @return {Object} ポップオーバー表示用オブジェクト
 * @return {String} mstNameColumn2 カラム名(マスタコード)、マスタ名を2つ表示させたいときに使用する。例:患者情報の名前項目
 */
export const createPopoverData = (
    popoverTitleHeader, popoverFilterLabel, popoverFilterDataset,
    popoverContentLabel, mstData, mstCdColumn, mstNameColumn,
    objFn, mstNameColumn2 = null, selectedValue = null) => {
  const popoverContentDataset = [];
  for (let mst of mstData) {
    // add 9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。 張玲 start
    mst[mstNameColumn] = mst[mstNameColumn] ? mst[mstNameColumn] : "";
    mst[mstNameColumn2] = mst[mstNameColumn2] ? mst[mstNameColumn2] : "";
    // add 9485 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。 張玲 end
    popoverContentDataset.push({
      value: mst[mstCdColumn],
      text: mstNameColumn2 === null ? mst[mstNameColumn] : mst[mstNameColumn] + ' ' + mst[mstNameColumn2],
      fnValue: mst[objFn],
    });
  }

  // mod bug #5815 修正 chen start
  // const popoverContentSelected = popoverContentDataset.find(
  const popoverContentSelected = deepCopy(popoverContentDataset.find(
    // mod bug #5815 修正 chen end
    ({ value }) => value === selectedValue
  )) || {
    value: null,
    fnValue: {},
    text: ""
  };

  return {
    popoverVisible: false,
    popoverTitleHeader,
    popoverFilterLabel,
    popoverFilterDataset,
    popoverContentLabel,
    popoverContentDataset,
    popoverContentSelected
  };
}

/**
 * 施設マスタ選択画面(ポップオーバー)表示用オブジェクト作成
 * @param {String} popoverTitleHeader ヘッダ名
 * @param {String} popoverContentLabel マスタ内容名称
 * @param {Array} mstData マスタレコード配列
 * @param {String} selectedValue 初期選択の施設コード
 * @return {Object} ポップオーバー表示用オブジェクト
 */
export const createPopoverDataFacility = (popoverTitleHeader, popoverContentLabel, mstData, selectedValue = null) => {
  const popoverContentDataset = [];
  for (let mst of mstData) {
    popoverContentDataset.push({
      //update データを修正 facilityCd -> medicalInstitutionCd 顔
      value: mst["medicalInstitutionCd"],
      //end データを修正 facilityCd -> medicalInstitutionCd 顔
      text: mst["facilityName"],
      prefecturesCd: mst["prefecturesCd"],
      //add FNSI-施設選択の箇所を対応する 江 start
      medicalInstitutionCd: mst["medicalInstitutionCd"]
      //add FNSI-施設選択の箇所を対応する 江 end
    });
  }

  const popoverContentSelected = popoverContentDataset.find(
    ( facility ) => facility.value === selectedValue
  ) || {
    // selectedValueが自由入力した施設名の場合には
    // ポップアップ側で未登録と区別されるようにvalueに入れておく
    value: selectedValue || null,
    prefecturesCd: "",
    text: "",
    //add FNSI-施設選択の箇所を対応する 江 start
    medicalInstitutionCd: ""
    //add FNSI-施設選択の箇所を対応する 江 end
  };

  return {
    popoverVisible: false,
    popoverTitleHeader,
    popoverContentLabel,
    popoverContentDataset,
    popoverContentSelected
  };
}
//add 患者透析困難情報を検索する 劉全航 start
export const createPopoverDataSeverity = (popoverTitleHeader, popoverFilterLabel, popoverFilterDataset, popoverContentLabel, mstData,selectedValue = null) => {
  const popoverContentDataset = [];
  for (let mst of mstData.data) {
    popoverContentDataset.push({
      value: mst["severityCd"],
      text: mst["severityName"]
    });
  }

  const popoverContentSelected = popoverContentDataset.find(
    ( severity ) => severity.value === selectedValue
  ) || {
    value: null,
    text: "",
  };

  return {
    popoverVisible: false,
    popoverTitleHeader,
    popoverFilterLabel,
    popoverFilterDataset,
    popoverContentLabel,
    popoverContentDataset,
    popoverContentSelected
  };
}
//add 患者透析困難情報を検索する 劉全航 end
//add 搬送区分検索機能追加 劉全航 start
export const createPopoverDataTransport = (popoverTitleHeader, popoverFilterLabel, popoverFilterDataset, popoverContentLabel, mstData,selectedValue = null) => {
  const popoverContentDataset = [];
  for (let mst of mstData.data) {
    popoverContentDataset.push({
      value: mst["transportCd"],
      text: mst["transportName"]
    });
  }

  const popoverContentSelected = popoverContentDataset.find(
    ( transport ) => transport.value === selectedValue
  ) || {
    value: null,
    text: "",
  };

  return {
    popoverVisible: false,
    popoverTitleHeader,
    popoverFilterLabel,
    popoverFilterDataset,
    popoverContentLabel,
    popoverContentDataset,
    popoverContentSelected
  };
}
//add 搬送区分検索機能追加 劉全航 end

//add NO338 患者情報加算 劉全航 start
export const createPopoverDataAddition = (popoverTitleHeader, popoverFilterLabel, popoverFilterDataset, popoverContentLabel, mstData,selectedValue = null) => {
  const popoverContentDataset = [];
  for (let mst of mstData.data) {
    popoverContentDataset.push({
      value: mst["additionCd"],
      text: mst["additionName"]
    });
  }

  const popoverContentSelected = popoverContentDataset.find(
    ( transport ) => transport.value === selectedValue
  ) || {
    value: null,
    text: "",
  };

  return {
    popoverVisible: false,
    popoverTitleHeader,
    popoverFilterLabel,
    popoverFilterDataset,
    popoverContentLabel,
    popoverContentDataset,
    popoverContentSelected
  };
}
//add NO338 患者情報加算 劉全航 end

/**
 * マスタ選択画面(ポップオーバー)を開く関数
 *   引数に渡されたポップオーバーを表示する
 * @param {Object} popoverData ポップオーバー表示用オブジェクト
 */
export const showPopover = popoverData => {
  popoverData.popoverVisible = true;
};

/**
 * マスタ選択画面(ポップオーバー)を閉じる関数
 *   引数に渡されたポップオーバーを非表示にする
 * @param {Object} popoverData ポップオーバー表示用オブジェクト
 */
export const closePopover = popoverData => {
  popoverData.popoverVisible = false;
};
