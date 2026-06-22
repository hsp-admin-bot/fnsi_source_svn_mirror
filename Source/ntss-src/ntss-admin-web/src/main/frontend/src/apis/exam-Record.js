/**
 * 検査結果（検査記録）系API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 参照先URL(examRecord)
 */
const URL_BASE = "/exam/examRecord";

/**
 * 参照先URL(MstInfo)
 */
const URL_MSTINFO = "/mstInfo";

function selectedPatIdParams(selectedPatId) {
  return selectedPatId === null || selectedPatId === undefined || selectedPatId === ""
    ? undefined
    : { selectedPatId };
}

function postWithSelectedPatId(url, payload, selectedPatId) {
  const params = selectedPatIdParams(selectedPatId);
  if (params) {
    return ApiHelper.configPost(url, payload, { params });
  }
  return ApiHelper.post(url, payload);
}

/**
 * 指定施設検査セットデータ取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstExamSetList(facilityCd, selectedPatId) {
  return ApiHelper.get(`${URL_BASE}/examSet/${facilityCd}`, selectedPatIdParams(selectedPatId));
}

/**
 * 指定施設検査項目マスタデータ取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstExamItemList(facilityCd, selectedPatId) {
  return ApiHelper.get(`${URL_BASE}/examItem/${facilityCd}`, selectedPatIdParams(selectedPatId));
}

/**
 * 指定施設検査項目マスタデータ取得
 * 検査使用区分：0:検査項目,1:システム標準検査項目,2:検査計算項目のデータを対象（有体に全部）
 * @param {string} facilityCd 施設コード
 * @param {string} examItemCd 検査項目コード
 */
export function sendRequestGetMstExamItemListForItemCd(facilityCd, examItemCd, selectedPatId) {
  return postWithSelectedPatId(`${URL_BASE}/examItem/selectSetData`, {
    facilityCd,
    examItemCd,
    examClass: ["0", "1", "2"]
  }, selectedPatId);
}

/**
 * 指定施設検査項目マスタデータ取得(全件)
 * 検査使用区分：0:検査項目,1:システム標準検査項目,2:検査計算項目のデータを対象（有体に全部）
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstExamItemListForExamClass(facilityCd, selectedPatId) {
  return postWithSelectedPatId(`${URL_BASE}/examItem/selectAllData`, {
    facilityCd,
    examClass: ["0", "1", "2"]
  }, selectedPatId);
}

/**
 * 指定透析実績日付選択用データ取得
 * @param {string|number} patId 患者ID
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetRstStartDateList(patId, facilityCd) {
  return ApiHelper.post(`${URL_BASE}/ordMain/selectRst`, {
    patId,
    facilityCd
  });
}

/**
 * 患者個別検査結果一覧情報取得
 * @param {unknown[]} patIdList 患者IDリスト
 * @param {string} resultFrom 結果期間From
 * @param {string} resultTo 結果期間To
 */
export function sendRequestGetPatExamMainRecordList(patIdList, resultFrom, resultTo, patientShareMode, selectedPatId) {
  return postWithSelectedPatId(`${URL_BASE}/examMain/Record`, {
    patIdList,
    resultFrom,
    resultTo,
    patientShareMode
  }, selectedPatId);
}

/**
 * 患者個別検査結果一覧-最終検査日取得
 * @param {unknown[]} patIdList 患者IDリスト
 */
export function sendRequestGetPatExamMainPatIdLastDate(patIdList, selectedPatId) {
  return postWithSelectedPatId(`${URL_BASE}/examMain/PatIdLastDate`, {
    patIdList
  }, selectedPatId);
}

/**
 * 患者検査結果データ1order分取得(json分割済)
 * @param {string|number} examMainCd 検査メインコード
 */
export function sendRequestGetPatExamMainOneOrder(examMainCd, selectedPatId) {
  return postWithSelectedPatId(`${URL_BASE}/examMain/selectOneOrder`, {
    examMainCd
  }, selectedPatId);
}

/**
 * 患者個別検査結果-対象登録
 * @param {Record<string, unknown>} setParam 登録パラメータ
 */
export function sendRequestInsertPatExamMainOneOrder(setParam) {
  return ApiHelper.post(`${URL_BASE}/examMain/insertOneOrder`, {
    patId: setParam.patId,
    facilityCd: setParam.facilityCd,
    regExamDate: setParam.regExamDate,
    regOrderClass: setParam.regOrderClass,
    ordNo: setParam.ordNo,
    resultExamDate: setParam.resultExamDate,
    examResultInfo: setParam.examResultInfo,
    regStaff: setParam.staff,
    updStaff: setParam.staff
  });
}

/**
 * 患者個別検査結果-対象更新
 * @param {Record<string, unknown>} setParam 更新パラメータ
 */
export function sendRequestUpdatePatExamMainOneOrder(setParam) {
  return ApiHelper.post(`${URL_BASE}/examMain/updateOneOrder`, {
    patId: setParam.patId,
    facilityCd: setParam.facilityCd,
    examMainCd: setParam.examMainCd,
    examResultInfo: setParam.examResultInfo,
    upStaff: setParam.upStaff,
    examDate: setParam.examDate,
    regOrderClass: setParam.regOrderClass
  });
}

// add FNSI-改修内容redmain6287 任 start
/**
 * 再取得用削除トリガ
 * @param {string|number} patId 患者ID
 */
export function deleteRefresh(patId) {
  return ApiHelper.post(`${URL_BASE}/examMain/deleteRefresh`, {
    patId
  });
}
// add FNSI-改修内容redmain6287 任 end

/**
 * 単一患者個別検査結果一覧情報取得
 * @param {string|number} patId 患者ID
 * @param {string} resultFrom 結果期間From
 * @param {string} resultTo 結果期間To
 * @param {unknown} examDateOrder 検査日ソート指定
 */
export function sendRequestGetPatExamMainDetailList(patId, resultFrom, resultTo, examDateOrder, patientShareMode) {
  return ApiHelper.get(`${URL_BASE}/examMain/PatRecord`, {
    patId,
    resultFrom,
    resultTo,
    examDateOrder,
    patientShareMode
  });
}

/**
 * 指定施設検査セットソート順取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstExamSetSort(facilityCd, selectedPatId) {
  return ApiHelper.get(`${URL_MSTINFO}/mst_exam_set/mstSharingSelector`, {
    ...selectedPatIdParams(selectedPatId),
    facilityCd
  });
}

/**
 * 指定施設検査項目ソート順取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstExamItemSort(facilityCd, selectedPatId) {
  return ApiHelper.get(`${URL_MSTINFO}/mst_exam_item/mstSharingSelector`, {
    ...selectedPatIdParams(selectedPatId),
    facilityCd
  });
}

// #9477 2023.11.17 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 start
/**
 * 指定施設 検査項目 通信SV用(ソート順+「仮想端末表示がONのもの」を100件) 取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetMstExamItemSortForComsv(facilityCd) {
  return ApiHelper.get(`${URL_MSTINFO}/mstExamItemForComsv`, {
    facilityCd
  });
}
// #9477 2023.11.17 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 end

/**
 * 既に存在する検査結果データの取得.
 * @param {string|number} patId 患者Id
 * @param {string|number} regOrderClass 検査区分
 * @param {string} resultExamDate 検査日時
 * @param {string|number} exclExamMainCd 除外する検査結果コード
 * @returns {Promise} 検査結果データ
 */
export function sendRequestGetExistResult(patId, regOrderClass, resultExamDate, exclExamMainCd) {
  return ApiHelper.post(`${URL_BASE}/examMain/getExistResult`, {
    patId,
    regOrderClass,
    resultExamDate,
    exclExamMainCd
  });
}

/**
 * 既に存在する検査依頼データの取得.
 * @param {string|number} patId 患者Id
 * @param {string|number} regOrderClass 検査区分
 * @param {string} regExamDate 検査依頼日
 * @param {string} resultExamDate 検査日時
 * @param {string|number} exclExamMainCd 除外する検査結果コード
 * @returns {Promise} 検査依頼データ
 */
export function sendRequestGetExistOrder(
  patId,
  regOrderClass,
  regExamDate,
  resultExamDate,
  exclExamMainCd
) {
  return ApiHelper.post(`${URL_BASE}/examMain/getExistOrder`, {
    patId,
    regOrderClass,
    regExamDate,
    resultExamDate,
    exclExamMainCd
  });
}

/**
 * 指定施設検査項目マスタデータ取得
 * @param {string|number} examMainCd 検査メインコード
 */
export function sendRequestGetPatExamMainByExamMainCd(examMainCd, selectedPatId) {
  return ApiHelper.get(
    `${URL_BASE}/examMain/getPatExamMainByExamMainCd/${examMainCd}`,
    selectedPatIdParams(selectedPatId)
  );
}

/**
 * 患者個別検査結果-検査結果情報の内容削除(予定ありレコード削除時)
 * @param {string|number} examMainCd 検査メインコード
 */
export function sendRequestClearExamResultInfo(examMainCd) {
  return ApiHelper.post(`${URL_BASE}/examMain/clearExamResultInfo/${examMainCd}`);
}

/**
 * 患者個別検査結果-更新時予定無しレコード論理削除
 * @param {string|number} examMainCd 検査メインコード
 */
export function sendRequestDeletePatExamMain(examMainCd) {
  return ApiHelper.post(`${URL_BASE}/examMain/deletePatExamMain/${examMainCd}`);
}

/**
 * 患者個別検査結果-対象レコード削除ボタン押下時処理
 * @param {Record<string, unknown>} setParam 削除パラメータ
 * @returns {Promise} 削除結果Response(失敗時用メッセージ付)
 */
export function sendRequestDeletePatExamMainOneOrder(setParam) {
  return ApiHelper.post(`${URL_BASE}/examMain/deleteOneOrder`, {
    examMainCd: setParam.examMainCd,
    upStaff: setParam.upStaff,
    checkDate: setParam.checkDate
  });
}

// add マスタ削除対応 張 start
/**
 * 指定施設削除します検査項目マスタデータ取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetDispExamItemListForFacilityCd(facilityCd, selectedPatId) {
  const payload = {
    facilityCd
  };
  const params = selectedPatIdParams(selectedPatId);
  if (params) {
    return ApiHelper.configPost(`${URL_BASE}/examItem/selectSetDataForFacilityCd`, payload, { params });
  }
  return ApiHelper.post(`${URL_BASE}/examItem/selectSetDataForFacilityCd`, payload);
}
// add マスタ削除対応 張 end
