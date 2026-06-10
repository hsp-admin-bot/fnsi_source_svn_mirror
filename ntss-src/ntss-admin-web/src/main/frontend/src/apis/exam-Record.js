/**
 * 施設設定画面系API
 */
import {ApiHelper} from "@/apis/AxiosHelper";

/**
 * 参照先URL(examRecord)
 */
const URL_BASE = "/exam/examRecord";

/**
 * 参照先URL(MstInfo)
 */
const URL_MSTINFO = "/mstInfo";

/**
 * 指定施設検査セットデータ取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstExamSetList(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/examSet/${facilityCd}`);
}

/**
 * 指定施設検査項目マスタデータ取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstExamItemList(facilityCd) {
  return ApiHelper.get(`${URL_BASE}/examItem/${facilityCd}`);
}

/**
 * 指定施設検査項目マスタデータ取得
 * 検査使用区分：0:検査項目,1:システム標準検査項目,2:検査計算項目のデータを対象（有体に全部）
 * @param {*} facilityCd
 * @param {*} itemCd
 */
export function sendRequestGetMstExamItemListForItemCd(facilityCd,examItemCd) {
  return ApiHelper.post(`${URL_BASE}/examItem/selectSetData`,{
    facilityCd: facilityCd,
    examItemCd: examItemCd,
    examClass: ["0","1","2"]
  });
}

/**
 * 指定施設検査項目マスタデータ取得(全件)
 * 検査使用区分：0:検査項目,1:システム標準検査項目,2:検査計算項目のデータを対象（有体に全部）
 * @param {*} facilityCd
 * @param {*} itemCd
 */
export function sendRequestGetMstExamItemListForExamClass(facilityCd) {
  return ApiHelper.post(`${URL_BASE}/examItem/selectAllData`,{
    facilityCd: facilityCd,
    examClass: ["0","1","2"]
  });
}


/**
 * 指定透析実績日付選択用データ取得
 * @param {*} patId
 * @param {*} facilityCd
 */
export function sendRequestGetRstStartDateList(patId,facilityCd) {
  return ApiHelper.post(`${URL_BASE}/ordMain/selectRst`,{
    patId: patId,
    facilityCd: facilityCd
  });
}

/**
 * 患者個別検査結果一覧情報取得
 * @param {*} patIdList
 * @param {*} resultFrom
 * @param {*} resultTo
 *
 */
export function sendRequestGetPatExamMainRecordList(patIdList, resultFrom, resultTo,patientShareMode) {
  return ApiHelper.post(`${URL_BASE}/examMain/Record`,{
    patIdList,
    resultFrom,
    resultTo,
    patientShareMode
  });
}

/**
 * 患者個別検査結果一覧-最終検査日取得
 * @param {*} patIdList
 *
 */
export function sendRequestGetPatExamMainPatIdLastDate(patIdList) {
  return ApiHelper.post(`${URL_BASE}/examMain/PatIdLastDate`, {
    patIdList,
  });
}


/**
 * 患者検査結果データ1order分取得(json分割済)
 * @param {*} examMainCd
 *
 */
export function sendRequestGetPatExamMainOneOrder(examMainCd) {
  return ApiHelper.post(`${URL_BASE}/examMain/selectOneOrder`,{
    examMainCd: examMainCd
  });
}


/**
 * 患者個別検査結果-対象登録
 * @param {*} setParam
 *
 */
export function sendRequestInsertPatExamMainOneOrder(setParam) {
  // console.log(setParam);
  return ApiHelper.post(`${URL_BASE}/examMain/insertOneOrder`,{
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
 * @param {*} examMainCd
 * @param {*} examResultInfo
 * @param {*} upDate
 * @param {*} upStaff
 *
 */
export function sendRequestUpdatePatExamMainOneOrder(setParam) {
  return ApiHelper.post(`${URL_BASE}/examMain/updateOneOrder`,{
    patId:setParam.patId,
    facilityCd:setParam.facilityCd,
    examMainCd: setParam.examMainCd,
    examResultInfo: setParam.examResultInfo,
    upStaff: setParam.upStaff,
    examDate: setParam.examDate,
    regOrderClass: setParam.regOrderClass
  });
}
/*add FNSI-改修内容redmain6287 任 start*/
export function deleteRefresh(patId) {
  return ApiHelper.post(`${URL_BASE}/examMain/deleteRefresh`,{
    patId:patId
  });
}
/*add FNSI-改修内容redmain6287 任 end*/


/**
 * 単一患者個別検査結果一覧情報取得
 * @param {*} patId
 * @param {*} resultFrom
 * @param {*} resultTo
 * @param {*} examDateOrder
 *
 */
export function sendRequestGetPatExamMainDetailList(patId, resultFrom, resultTo, examDateOrder,patientShareMode) {
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
 * @param {*} facilityCd
 */
export function sendRequestGetMstExamSetSort(facilityCd) {
  return ApiHelper.get(`${URL_MSTINFO}/mst_exam_set/mstSharingSelector/` , {
    facilityCd: facilityCd
  });
}

/**
 * 指定施設検査項目ソート順取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstExamItemSort(facilityCd) {
  return ApiHelper.get(`${URL_MSTINFO}/mst_exam_item/mstSharingSelector/` , {
    facilityCd: facilityCd
  });
}

// #9477 2023.11.17 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 start
/**
 * 指定施設 検査項目 通信SV用(ソート順+「仮想端末表示がONのもの」を100件) 取得
 * @param {*} facilityCd
 */
export function sendRequestGetMstExamItemSortForComsv(facilityCd) {
  return ApiHelper.get(`${URL_MSTINFO}/mstExamItemForComsv` , {
    facilityCd: facilityCd
  });
}
// #9477 2023.11.17 add 検査項目マスタで「仮想端末表示がONのもの」を100件まで取得 TDC山崎 end

/**
 * 既に存在する検査結果データの取得.
 * @param patId 患者Id.
 * @param regOrderClass 検査区分.
 * @param resultExamDate 検査日時.
 * @param exclExamMainCd 除外する検査結果コード.
 * @return 検査結果データ.
 */
export function sendRequestGetExistResult(patId, regOrderClass, resultExamDate, exclExamMainCd) {
  return ApiHelper.post(`${URL_BASE}/examMain/getExistResult/` , {
    patId: patId,
    regOrderClass: regOrderClass,
    resultExamDate: resultExamDate,
    exclExamMainCd: exclExamMainCd
  });
}

/**
 * 既に存在する検査依頼データの取得.
 * @param patId 患者Id.
 * @param regOrderClass 検査区分.
 * @param regExamDate 検査依頼日.
 * @param resultExamDate 検査日時.
 * @param exclExamMainCd 除外する検査結果コード.
 * @return 検査依頼データ.
 */
export function sendRequestGetExistOrder(patId, regOrderClass, regExamDate, resultExamDate, exclExamMainCd) {
  return ApiHelper.post(`${URL_BASE}/examMain/getExistOrder/` , {
    patId: patId,
    regOrderClass: regOrderClass,
    regExamDate: regExamDate,
    resultExamDate: resultExamDate,
    exclExamMainCd: exclExamMainCd
  });
}

/**
 * 指定施設検査項目マスタデータ取得
 * @param {*} examMainCd
 */
export function sendRequestGetPatExamMainByExamMainCd(examMainCd) {
  return ApiHelper.get(`${URL_BASE}/examMain/getPatExamMainByExamMainCd/${examMainCd}`);
}

/**
 * 患者個別検査結果-検査結果情報の内容削除(予定ありレコード削除時)
 * @param {*} examMainCd
 *
 */
export function sendRequestClearExamResultInfo(examMainCd) {
  return ApiHelper.post(`${URL_BASE}/examMain/clearExamResultInfo/${examMainCd}`);
}

/**
 * 患者個別検査結果-更新時予定無しレコード論理削除
 * @param {*} examMainCd
 *
 */
export function sendRequestDeletePatExamMain(examMainCd) {
  return ApiHelper.post(`${URL_BASE}/examMain/deletePatExamMain/${examMainCd}`);
}


/**
 * 患者個別検査結果-対象レコード削除ボタン押下時処理
 * @param {*} examMainCd
 * @param {*} upStaff
 * @param {*} checkDate
 * @return 削除結果Response(失敗時用メッセージ付)
 *
 */
export function sendRequestDeletePatExamMainOneOrder(setParam) {
  return ApiHelper.post(`${URL_BASE}/examMain/deleteOneOrder`,{
    examMainCd:setParam.examMainCd,
    upStaff: setParam.upStaff,
    checkDate: setParam.checkDate
  });
}
// add マスタ削除対応 張 start
/**
 * 指定施設削除します検査項目マスタデータ取得
 * @param {*} facilityCd
 */
 export function sendRequestGetDispExamItemListForFacilityCd(facilityCd) {
  return ApiHelper.post(`${URL_BASE}/examItem/selectSetDataForFacilityCd`,{
    facilityCd: facilityCd
  });
}
// add マスタ削除対応 張 end
