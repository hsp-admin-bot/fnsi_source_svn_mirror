/**
 * 治療記録系API
 */
import { dateFormat } from "@/functions/common/DateTimeUtils";
import { BvmsGraphFunctions } from "@/functions/treatment-record/BvmsGraphFunctions";
import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";

/**
 * サインインしているユーザが所属する施設コードを取得.
 */
function getUserFacilityCd() {
  return store.getters["user/getFacilityCd"];
}

/**
 * マスターデータ取得.
 * @param {*} url マスター取得API用URL
 */
function getMaster(url) {
  return getWithLoader(url, {
    facilityCd: getUserFacilityCd()
  });
}

/**
 * マスターデータ取得（共通ローダ実行なし）.
 * @param {*} url マスター取得API用URL
 */
function getMasterWithoutLoader(url) {
  return ApiHelper.get(url, {
    facilityCd: getUserFacilityCd()
  });
}

/**
 * マスターデータ取得（共通ローダ実行なし）.
 * @param {*} url マスター取得API用URL
 */
function getMasterWithoutLoaderByFacilityCd(url, facilityCd) {
  return ApiHelper.get(url, {
    facilityCd: facilityCd
  });
}

/**
 * 利用者マスターデータ取得(施設コードの指定が他のマスタとは異なる).
 * @param {*} url 利用者マスター取得API用URL
 */
function getMasterPersonal(url) {
  return getWithLoader(url, {
    facility_cd: getUserFacilityCd()
  });
}

/**
 * 指定された患者IDから治療記録レコードの最新のオーダ番号を取得する.
 * @param {*} patId 患者ID
 */
export function sendRequestGetLatestOrdNo(patId) {
  return getWithLoader(`/treatment-record/${patId}/latest-ord-no`);
}

/**
 * 治療概要取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordSummary(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/summary`);
}

/**
 * 実績情報取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordResult(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/result`);
}
//add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
/**
 * 共通診療情報取得
 * @param {*} facilityCd 施設コード
 * @param {*} patId 患者ID
 *
 */
export function selectMedicalCareInfoByIdAndFacilityCd(facilityCd,patId){
  return getWithLoader(
    `/patInfo/selectMedicalCareInfoByIdAndFacilityCd/${facilityCd}/${patId}`
  );
}
//add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end


/**
 * 死活監視ステータス取得
 * @param {*} deviceEdgeNo 死活監視ステータス取得
 */
export function sendRequestGetmonistatus(deviceEdgeNo) {
  return ApiHelper.get(
    `/treatment-record/monistatus/${deviceEdgeNo}`);
}

/**
 * 実績情報更新
 * @param {*} ordNo オーダ番号
 * @param {*} treatmentRecordResult 実績情報
 */
export function sendRequestUpdateTreatmentRecordResult(
  ordNo,
  treatmentRecordResult
) {
  // if (treatmentRecordResult.rst_puncture_user_info) {
  //   treatmentRecordResult.rst_puncture_user_info.date =
  //   treatmentRecordResult.rst_puncture_user_info.date ?
  //     dateFormat.utc2Jst(treatmentRecordResult.rst_puncture_user_info.date) : null;
  // }
  // if (treatmentRecordResult.rst_return_user_info) {
  //   treatmentRecordResult.rst_return_user_info.date =
  //   treatmentRecordResult.rst_return_user_info.date ?
  //     dateFormat.utc2Jst(treatmentRecordResult.rst_return_user_info.date) : null;
  // }
  return putWithLoader(
    `/treatment-record/${ordNo}/result`,
    treatmentRecordResult
  );
}

/**
 * 実績情報更新
 * ※処理区分に応じた治療条件の更新も行う.
 * @param {*} ordNo オーダ番号
 * @param {*} treatmentRecordResult 実績情報
 * @param {Integer} processType 処理区分
 */
export function sendRequestUpdateTreatmentRecordResultWithCondition(
  ordNo,
  treatmentRecordResult,
  processType
) {
  if (treatmentRecordResult.rst_puncture_user_info) {
    treatmentRecordResult.rst_puncture_user_info.date =
    treatmentRecordResult.rst_puncture_user_info.date ?
      dateFormat.utc2Jst(treatmentRecordResult.rst_puncture_user_info.date) : null;
  }
  if (treatmentRecordResult.rst_return_user_info) {
    treatmentRecordResult.rst_return_user_info.date =
    treatmentRecordResult.rst_return_user_info.date ?
      dateFormat.utc2Jst(treatmentRecordResult.rst_return_user_info.date) : null;
  }
  return putWithLoader(
    `/treatment-record/${ordNo}/${processType}/result_with_condition`,
    treatmentRecordResult
  );
}

/**
 * 投与薬剤情報取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordMediInfo(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/medi_info`);
}

/**
 * 投与薬剤情報更新
 * @param {*} ordNo オーダ番号
 * @param {*} treatmentRecordMediInfo 投与薬剤情報
 * treatmentRecordMediInfoは以下のプロパティを持つ
 * {
 *   rst_dialysis_state: string, 治療状況 (更新には使用しない)
 *   rst_start_date: string, 透析開始日 (更新には使用しない)
 *   rst_medi_info: string 実績: 投与薬剤情報の文字列表現
 * }
 */
export function sendRequestUpdateTreatmentRecordMediInfo(
  ordNo,
  treatmentRecordMediInfo
) {
  return putWithLoader(
    `/treatment-record/${ordNo}/medi_info`,
    treatmentRecordMediInfo
  );
}

/**
 * 医療材料情報取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordEquipInfo(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/equip_info`);
}

/**
 * 医療材料情報更新
 * @param {*} ordNo オーダ番号
 * @param {*} treatmentRecordEquipInfo 医療材料情報
 * treatmentRecordEquipInfoは以下のプロパティを持つ
 * {
 *   rst_dialysis_state: string, 治療状況 (更新には使用しない)
 *   rst_equip_info: string 実績: 医療材料情報の文字列表現
 * }
 */
export function sendRequestUpdateTreatmentRecordEquipInfo(
  ordNo,
  treatmentRecordEquipInfo
) {
  return putWithLoader(
    `/treatment-record/${ordNo}/equip_info`,
    treatmentRecordEquipInfo
  );
}

/**
 * 治療条件取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordCondition(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/condition`);
}

/**
 * MODIFY_SEND_CLASS取得
 * @param {*} facilityCd 施設コード
 */
export function sendRequestGetCoopIniSchModifySendClass(facilityCd) {
  return getWithLoader(`/treatment-record/${facilityCd}/sch-send-class`);
}

/**
 * 治療条件更新
 * @param {*} ordNo オーダ番号
 * @param {*} treatmentRecordCondition 治療条件
 */
export function sendRequestUpdateTreatmentRecordCondition(
  ordNo,
  treatmentRecordCondition
) {
  return putWithLoader(
    `/treatment-record/${ordNo}/condition`,
    treatmentRecordCondition
  );
}

/**
 * 体重情報取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordWeight(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/weight`);
}

/**
 * 体重情報更新
 * @param {*} ordNo オーダ番号
 * @param {*} treatmentRecordWeight 体重
 */
export function sendRequestUpdateTreatmentRecordWeight(
  ordNo,
  treatmentRecordWeight
) {
  return putWithLoader(
    `/treatment-record/${ordNo}/weight`,
    treatmentRecordWeight
  );
}

/**
 * 指示コメント取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordAddition(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/addition`);
}

/**
 * 指示コメント更新
 * @param {*} ordNo オーダ番号
 * @param {Object} treatmentRecordAddition 指示コメント情報
 */
export function sendRequestUpdateTreatmentRecordAddition(
  ordNo,
  treatmentRecordAddition
) {
  return putWithLoader(
    `/treatment-record/${ordNo}/addition`,
    treatmentRecordAddition
  );
}

/**
 * バイタルモニタ取得
 * @param {*} facilityCd 施設番号
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordVitalMonitor(facilityCd,ordNo) {
  return getWithLoader(`/treatment-record/${facilityCd}/${ordNo}/vital-monitor`);
}

/**
 * モニタ取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordMonitor(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/monitor`);
}

/**
 * モニタグラフ設定取得
 */
export function sendRequestGetMonitorGraphDefine() {
  return getWithLoader(`/monitor/graph-define`);
}

/**
 * 愁訴処置情報取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordComplaint(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/complaint`);
}

/**
 * 愁訴処置情報保存
 * @param {*} ordNo オーダ番号
 * @param {*} treatmentRecordComplaint 愁訴処置情報
 */
export function sendRequestUpdateTreatmentRecordComplaint(
  ordNo,
  forcedChangeFlag,
  treatmentRecordComplaint
) {
  return putWithLoader(
    `/treatment-record/${ordNo}/${forcedChangeFlag}/complaint`,
    treatmentRecordComplaint
  );
}

/**
 * 愁訴マスタ取得
 */
export function sendRequestGetMstComplaint() {
  return ApiHelper.get(`/complaint/mst-complaint`);
}

/**
 * 愁訴マスタ取得
 */
export function sendRequestGetMstComplaintByFacilityCd(facilityCd) {
  return ApiHelper.get(`/complaint/mst-complaint/data/${facilityCd}`);
}

/**
 * 愁訴マスタ更新（マスタメンテ用）
 * @param {*} mstComplaints 愁訴マスタ
 */
export function sendRequestUpdateMstComplaint(mstComplaints) {
  return putWithLoader(`/complaint/mst-complaint`, mstComplaints);
}

/**
 * 処置マスタ取得
 */
export function sendRequestGetMstCompTreatment() {
  return ApiHelper.get(`/complaint/mst-comp-treatment`);
}

/**
 * 処置マスタ更新（マスタメンテ用）
 * @param {*} mstCompTreatments 処置マスタ
 */
export function sendRequestUpdateMstCompTreatment(mstCompTreatments) {
  return putWithLoader(`/complaint/mst-comp-treatment`, mstCompTreatments);
}

/**
 * 設定値読み込み履歴取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordSetting(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/setting`);
}

/**
 * 実績：装置設定情報取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordRstDeviceSetInfo(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/rst-device-set-info`);
}

/**
 * 実績：回診記録情報取得
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordRstRoundsInfo(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/rst-rounds-info`);
}

/**
 * 実績：回診記録情報更新
 * @param {*} ordNo オーダ番号
 * @param {*} rstRoundsInfo 実績：回診記録情報
 * rstRoundsInfoは以下のプロパティを持つ
 * {
 *   rst_rounds_info: string, 実績：回診記録情報
 *   up_date: String, 更新日時
 * }
 */
export function sendRequestUpdateTreatmentRecordRstRoundsInfo(ordNo, rstRoundsInfo) {
  return putWithLoader(`/treatment-record/${ordNo}/rst-rounds-info`, rstRoundsInfo);
}

/**
 * 指定されたオーダ番号に紐付くマージ対象の実績情報リストを取得する.
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetResultMergeList(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/result-merge`);
}

/**
 * マージ実行後の実績情報を更新する.
 * @param {*} ordNo オーダ番号
 * @param {*} ordMain 実績情報
 */
export function sendRequestUpdateResultMerge(ordNo, ordMain) {
  return putWithLoader(`/treatment-record/${ordNo}/result-merge`, ordMain);
}

/**
 * 設定値読出し指示
 * @param {*} param パラメータオブジェクト
 */
export function sendRequestPostOrderReadSettingValue(param) {
  return ApiHelper.post(`/device_edge_order/read_setting_value`, param);
}

/**
 * 治療方法マスタ取得
 * (サインインしている施設コードで絞り込み)
 */
// mod #12462 患者情報共有 Ji start
export function sendRequestGetMstTreatment(facilityCd) {
  if (facilityCd) {
    return getWithLoader("/mstInfo/mstTreatment", {
      facilityCd: facilityCd
    });
  }
// mod #12462 患者情報共有 Ji end
  return getMaster("/mstInfo/mstTreatment");
}

/**
 * VAマスタ取得
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstVa() {
  return getMaster("/mstInfo/mstVa");
}

/**
 * ダイアライザマスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstDialyzer() {
  return getMaster("/mstInfo/mstDialyzer");
}

/**
 * ダイアライザマスタ取得.
 * (禁忌・アレルギー情報を含む)
 */
export function sendRequestGetMstDialyzerTabooAllergy(patId) {
  // ？？？？患者(patId=null)表示時の対応
  //mod 9706 横展開 ljx start
  //const strPatId = patId ? patId.toString() : "";
  const strPatId = patId ? patId.toString() : "-1";
  //mod 9706 横展開 ljx end
  const url = "/mstInfo/mstDialyzer/" + strPatId;
  return getMaster(url);
}

/**
 * ダイアライザマスタ取得.
 * (禁忌・アレルギー情報を含む)期限切れ除外
 */
//#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
export function sendRequestGetMstDialyzerTabooAllergyNoexpire(patId, TreatDate) {
  const strPatId = patId ? patId.toString() : "-1";
  const  strTreatDate = (TreatDate != undefined && TreatDate != null) ? TreatDate : null;
  const url = "/mstInfo/mstDialyzer/" + strPatId + "/" + strTreatDate;
  return getMaster(url);
}
//#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End

/**
 * 薬剤マスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstMedicine() {
  return getMaster("/mstInfo/mstMedicine");
}

/**
 * 薬剤マスタ取得(禁忌・アレルギー情報込み).
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstMedicineTabooAllergy(patId) {
  if (patId === null) {
    patId = -1;
  }
  const strPatId = patId.toString();
  const url = "/mstInfo/mstMedicine/" + strPatId;
  return getMaster(url);
}

/**
 * 薬剤マスタ取得（共通ローダ実行なし）.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstMedicineWithoutLoader() {
  return getMasterWithoutLoader("/mstInfo/mstMedicine");
}

/**
 * 薬剤セットマスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstMedicineSet() {
  return getMaster("/mstInfo/mstMedicineSet");
}

/**
 * 薬剤セットマスタ取得（共通ローダ実行なし）.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstMedicineSetWithoutLoader() {
  return getMasterWithoutLoader("/mstInfo/mstMedicineSet");
}

/**
 * 薬剤分類マスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstMedicineClass() {
  return getMaster("/mstInfo/mstMedicineClass");
}

/**
 * 薬剤分類マスタ取得（共通ローダ実行なし）.
 * (指定した施設コードで絞り込み)
 */
export function sendRequestGetMstMedicineClassWithoutLoaderByFacilityCd(facilityCd) {
  return getMasterWithoutLoaderByFacilityCd("/mstInfo/mstMedicineClass", facilityCd);
}

/**
 * 調整薬剤マスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstMedicineMix() {
  return getMaster("/mstInfo/mstMedicineMix");
}

/**
 * 調整薬剤マスタ取得(禁忌・アレルギー情報込み).
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstMedicineMixTabooAllergy(patId) {
  if (patId === null) {
    patId = -1;
  }
  const strPatId = patId.toString();
  const url = "/mstInfo/mstMedicineMix/" + strPatId;
  return getMaster(url);
}

/**
 * 調整薬剤マスタ取得（共通ローダ実行なし）.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstMedicineMixWithoutLoader() {
  return getMasterWithoutLoader("/mstInfo/mstMedicineMix");
}

/**
 * 医療材料マスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstEquipment() {
  return getMaster("/mstInfo/mstEquipment");
}

/**
 * 医療材料マスタ取得(禁忌・アレルギー情報を含む).
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstEquipmentTabooAllergy(patId) {
  // ？？？？患者(patId=null)表示時の対応
  //mod 9706 横展開 ljx start
  //const strPatId = patId ? patId.toString() : "";
  const strPatId = patId ? patId.toString() : "-1";
  //mod 9706 横展開 ljx end
  const url = "/mstInfo/mstEquipment/" + strPatId;
  return getMaster(url);
}

/**
 * 医療材料分類毎の医療材料マスタ取得(禁忌・アレルギー情報を含む).
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstEquipmentTabooAllergyByClass(patId, classIdList) {
  // ？？？？患者(patId=null)表示時の対応
  //mod 9706 横展開 ljx start
  //const strPatId = patId ? patId.toString() : "";
  const strPatId = patId ? patId.toString() : "-1";
  //mod 9706 横展開 ljx end
  const url = "/mstInfo/mstEquipment/" + strPatId;
  return putWithLoader(url, classIdList);
}

//#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
/**
 * 医療材料分類毎の医療材料マスタ取得(禁忌・アレルギー情報を含む).
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(patId, classIdList, TreatDate) {
  const strPatId = patId ? patId.toString() : "-1";
  const  strTreatDate = (TreatDate != undefined && TreatDate != null) ? TreatDate : null;
  const url = "/mstInfo/mstEquipment/" + strPatId + "/" + strTreatDate;
  return putWithLoader(url, classIdList);
}
//#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End

/**
 * 医療材料分類マスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstEquipmentClass() {
  return getMaster("/mstInfo/mstEquipmentClass");
}

/**
 * 医療材料分類マスタ取得.（削除済み含む）
 * (サインインしている施設コードで絞り込み)
 */
 export function sendRequestGetMstEquipmentClassIncludeDeleted() {
  return getMaster("/mstInfo/mstEquipmentClassIncludeDeleted");
}

/**
 * 利用者マスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstPersonalUser() {
  return getMasterPersonal("/mstInfo/mstPersonalUser");
}

/**
 * 手技マスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetMstProcedure() {
  return getMaster("/mstInfo/mstProcedure");
}

/**
 * 手技マスタ取得（共通ローダ実行なし）.
 * (指定した施設コードで絞り込み)
 */
export function sendRequestGetMstProcedureWithoutLoaderByFacilityCd(facilityCd) {
  return getMasterWithoutLoaderByFacilityCd("/mstInfo/mstProcedure", facilityCd);
}

/**
 * 手技マスタ（削除済み含む）取得（共通ローダ実行なし）.
 * (指定した施設コードで絞り込み)
 */
 export function sendRequestGetMstProcedureWithoutLoaderIncludeDeletedByFacilityCd(facilityCd) {
  return getMasterWithoutLoaderByFacilityCd("/mstInfo/mstProcedureIncludeDeleted", facilityCd);
}

/**
 * 車いすマスタ取得.
 * (サインインしている施設コードで絞り込み)
 */
export function sendRequestGetWheelChair() {
  return getWithLoader(
    `/weight_setting/wheel_chair/find/${getUserFacilityCd()}`
  );
}

/**
 * 再循環率取得.
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetRecirculationRate(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/recirculation-rate`);
}

/**
 * 共通ローダを実行するGETリクエスト
 * @param {*} url URL
 * @param {*} param パラメータ
 */
function getWithLoader(url, params) {
  /* modify by chamaojia 2022-10-26 [7217] クエリ判断の追加  --start */
  const screenMessage = store.getters["loading-screen/getLoadingScreenMessage"];
  if (screenMessage !== "処理中・・・") {
    store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  }
  /* modify by chamaojia 2022-10-26 [7217] クエリ判断の追加  --end */
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 共通ローダを実行するPUTリクエスト
 * @param {*} url URL
 * @param {*} param パラメータ
 */
function putWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.put(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}

/**
 * 共通ローダを実行するPOST Configリクエスト
 * @param {*} url URL
 * @param {*} param パラメータ
 * @param {*} config 設定
 */
function configPostWithLoader(url, params, config) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.configPost(url, params, config).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
//add FNSI-8360 ljx start
/**
 * 共通ローダを実行するPOSTリクエスト
 * @param { String } url URL
 * @param {any} params パラメータ
 */
function postWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return ApiHelper.post(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
//add FNSI-8360 ljx end
/**
 * バイタル更新
 * @param {*} ordNo オーダ番号
 * @param {List} ordMonitors バイタル情報
 */
export function sendRequestUpdateTreatmentRecordVitalForMniMonitor(
  ordNo,
  ordMonitors
) {
  return putWithLoader(
    `/treatment-record/${ordNo}/vital-monitor-data`,
    ordMonitors
  );
}

/**
 * オーダ番号に該当する治療方法マスタ取得.
 */
export function sendRequestGetReportInfoByOrdNoWithLoader(ordNo) {
  return getWithLoader(
    `/treatment-record/${ordNo}/report-info`
    );
}

/**
 * 版確定処理
 * @param {*} ordNo オーダ番号
 */
//mod FNSI-7531 劉全航 start
// export function sendRequestUpdateTreatmentRecordConfirm(ordNo) {
//   return putWithLoader(`/treatment-record/${ordNo}/1/confirm`);
// }
export function sendRequestUpdateTreatmentRecordConfirm(ordNo, userId) {
  return putWithLoader(`/treatment-record/${ordNo}/${userId}/1/confirm`);
}
//mod FNSI-7531 劉全航 end

/**
 * 条件送信キャンセル
 * @param {*} params パラメータ
 */
export function sendRequestCancelCondition(params) {
  return postWithLoader(`/treatment-record/cancelSendCond`, params);
}

/**
 * 装置マスタ取得.
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetMstMachineByOrdNoRst(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/mst-machine-rst`);
}

/**
 * 装置状態取得.
 * @param {*} facilityCd 施設番号
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetMntMachineState(facilityCd,ordNo) {
  return getWithLoader(`/treatment-record/${facilityCd}/${ordNo}/mnt-machine-state`);
}
/**
 * 特殊浄化フラグ取得.
 * @param {*}} treatmentCd 治療方法コード
 */
export function sendRequestGetIsPurification(treatmentCd) {
  return getWithLoader(`/treatment-record/${treatmentCd}/is-purification`);
}

/**
 * 薬剤マスタ及び調整薬剤マスタ取得.
 * @returns 薬剤マスタ及び調整薬剤マスタ
 */
export function getMedicineAll() {
  return getMaster("/mstInfo/mstMedicineWithMix");
}

/**
 * 薬剤マスタ及び調整薬剤マスタ取得（共通ローダ実行なし）.
 * @returns 薬剤マスタ及び調整薬剤マスタ
 */
export function getMedicineAllWithoutLoaderByFacilityCd(facilityCd) {
  return getMasterWithoutLoaderByFacilityCd("/mstInfo/mstMedicineWithMix", facilityCd);
}

/**
 * 薬剤マスタ及び調整薬剤マスタ取得(禁忌・アレルギー情報込み).
 * @returns (禁忌・アレルギー情報込み)薬剤マスタ及び調整薬剤マスタ
 */
export function getMedicineAllTabooAllergy(patId) {
  // ？？？？患者(patId=null)表示時の対応
  //mod 9706 横展開 ljx start
  // const strPatId = patId ? patId.toString() : "";
  const strPatId = patId ? patId.toString() : "-1";
  //mod 9706 横展開 ljx end
  const url = "/mstInfo/mstMedicineWithMix/" + strPatId;
  return getMaster(url);
}

/**
 * 分類区分でフィルタされた薬剤マスタ及び調整薬剤マスタ取得(禁忌・アレルギー情報込み).
 * @returns (禁忌・アレルギー情報込み)分類区分でフィルタされた薬剤マスタ及び調整薬剤マスタ
 */
export function getMedicineAllTabooAllergyFilterByType(patId, classType) {
  // ？？？？患者(patId=null)表示時の対応
  //mod 9706 横展開 ljx start
  // const strPatId = patId ? patId.toString() : "";
  const strPatId = patId ? patId.toString() : "-1";
  //mod 9706 横展開 ljx end
  const url = "/mstInfo/mstMedicineWithMix/" + strPatId + "/" + classType;
  return getMaster(url);
}

/**
 * 条件に合致するモニタ項目（システム設定）を取得.
 * @param {*} param 検索条件
 *                    { moniDataType: null, vitalMonitorClass: "2"}
 * @returns 条件に合致するモニタ項目のリスト
 */
export function sendRequestGetSysMonitorItem(param) {
  return getWithLoader(`/treatment-record/sys_monitor_item`, param);
}

/**
 * 個別追加のモニタ項目マスタ取得.
 * @param { String } vitalMonitorClass バイタルモニタ区分
 * @returns 該当する個別追加モニタ項目マスタ
 */
// mod #12462 患者情報共有 Ji start
export function sendRequestGetMstAddMonitor(vitalMonitorClass, facilityCd) {
  return getWithLoader("/mstInfo/mstAddMonitorByClass", {
    // facility_cd: getUserFacilityCd(),
    facility_cd: facilityCd,
// mod #12462 患者情報共有 Ji end
    vital_monitor_class: vitalMonitorClass
  });
}
// add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy start
/**
 * 追加のモニタ項目マスタ取得.
 * @returns 追加モニタ項目マスタ
 */
// mod #12462 患者情報共有 Ji start
export function sendRequestGetMstAddMonitorAll(facilityCd) {
  return getWithLoader("/mstInfo/mstAddMonitorByFacilityCd", {
    // facility_cd: getUserFacilityCd()
    facility_cd: facilityCd
// mod #12462 患者情報共有 Ji end
  });
}
// add 9858 治療記録＞モニタが治療記録モニタグラフマスタで指定した上下限値でグラフレンジが生成されない zy end

/**
 * sendRequestGetBvGraph
 * @param {*} param
 */
export function sendRequestGetBvGraph(param) {
  var ordNo = param.ordNo;
  if (ordNo !== null) {
    return new Promise(function (resolve) {
      let graphName = "bvGraph";
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx start
      //ApiHelper.post(`/bvms/` + graphName + "/" + ordNo, param).then(function (response) {
      postWithLoader(`/bvms/` + graphName + "/" + ordNo, param).then(function (response) {
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx end
        resolve(BvmsGraphFunctions.mapGraph(response, graphName, param));
      });
    });
  }
}

/**
 * sendRequestGetBvGraphWithUploadFile
 * @param {*} param
 */
export function sendRequestGetBvGraphWithUploadFile(param) {
  var ordNo = param.ordNo;
  if (ordNo !== null) {
    return new Promise(function (resolve) {
      let graphName = "bvGraph";
      let formData = setFormData(param, false);
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx start
      //ApiHelper.post(`/bvms/` + graphName + "/byUploadFile/" + ordNo, formData).then(function (response) {
      postWithLoader(`/bvms/` + graphName + "/byUploadFile/" + ordNo, formData).then(function (response) {
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx end
        resolve(BvmsGraphFunctions.mapGraph(response, graphName, param));
      });
    });
  }
}

/**
 * sendRequestGetDdmGraph
 * @param {*} param
 */
export function sendRequestGetDdmGraph(param) {
  var ordNo = param.ordNo;
  if (ordNo !== null) {
    return new Promise(function (resolve) {
      let graphName = "ddmGraph";
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx start
      //ApiHelper.post(`/bvms/` + graphName + "/" + ordNo, param).then(function (response) {
      postWithLoader(`/bvms/` + graphName + "/" + ordNo, param).then(function (response) {
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx end
        resolve(BvmsGraphFunctions.mapGraph(response, graphName, param));
      });
    });
  }
}

/**
 * sendRequestGetDdmGraphWithUploadFile
 * @param {*} param
 */
export function sendRequestGetDdmGraphWithUploadFile(param) {
  var ordNo = param.ordNo;
  if (ordNo !== null) {
    return new Promise(function (resolve) {
      let graphName = "ddmGraph";
      let formData = setFormData(param, false);
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx start
      //ApiHelper.post(`/bvms/` + graphName + "/byUploadFile/" + ordNo, formData).then(function (response) {
      postWithLoader(`/bvms/` + graphName + "/byUploadFile/" + ordNo, formData).then(function (response) {
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx end
        resolve(BvmsGraphFunctions.mapGraph(response, graphName, param));
      });
    });
  }
}

/**
 * sendRequestGetHtGraph
 * @param {*} param
 */
export function sendRequestGetHtGraph(param) {
  var ordNo = param.ordNo;
  if (ordNo !== null) {
    return new Promise(function (resolve) {
      let graphName = "htGraph";
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx start
      //ApiHelper.post(`/bvms/` + graphName + "/" + ordNo, param).then(function (response) {
      postWithLoader(`/bvms/` + graphName + "/" + ordNo, param).then(function (response) {
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx end
        resolve(BvmsGraphFunctions.mapGraph(response, graphName, param));
      });
    });
  }
}

/**
 * sendRequestGetHtGraphWithUploadFile
 * @param {*} param
 */
export function sendRequestGetHtGraphWithUploadFile(param) {
  var ordNo = param.ordNo;
  if (ordNo !== null) {
    return new Promise(function (resolve) {
      let graphName = "htGraph";
      let formData = setFormData(param, false);
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx start
      //ApiHelper.post(`/bvms/` + graphName + "/byUploadFile/" + ordNo, formData).then(function (response) {
      postWithLoader(`/bvms/` + graphName + "/byUploadFile/" + ordNo, formData).then(function (response) {
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx end
        resolve(BvmsGraphFunctions.mapGraph(response, graphName, param));
      });
    });
  }
}

/**
 * sendRequestGetRrGraph
 * @param {*} param
 */
export function sendRequestGetRrGraph(param) {
  var ordNo = param.ordNo;
  if (ordNo !== null) {
    return new Promise(function (resolve) {
      let graphName = "rrGraph";
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx start
      //ApiHelper.post(`/bvms/` + graphName + "/" + ordNo, param).then(function (response) {
      postWithLoader(`/bvms/` + graphName + "/" + ordNo, param).then(function (response) {
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx end
        resolve(BvmsGraphFunctions.mapGraph(response, graphName, param));
      });
    });
  }
}

/**
 * sendRequestGetRrGraphWithUploadFile
 * @param {*} param
 */
export function sendRequestGetRrGraphWithUploadFile(param) {
  var ordNo = param.ordNo;
  if (ordNo !== null) {
    return new Promise(function (resolve) {
      let graphName = "rrGraph";
      let formData = setFormData(param, true);
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx start
      //ApiHelper.post(`/bvms/` + graphName + "/byUploadFile/" + ordNo, formData).then(function (response) {
      postWithLoader(`/bvms/` + graphName + "/byUploadFile/" + ordNo, formData).then(function (response) {
      //mod FNSI-8360画面切り替え時やグラフ切替時には共通ローダーを展開する ljx end
        resolve(BvmsGraphFunctions.mapGraph(response, graphName, param));
      });
    });
  }
}

/**
 * setFormData
 * @param {*} param
 */
function setFormData(param, isRrGraph) {
  const formData = new FormData();
  formData.append("files", param.files, "file.csv");
  if (isRrGraph) {
    formData.append("graphY1From", param.graphY1From);
    formData.append("graphY1To", param.graphY1To);
  }
  else {
    formData.append("graph1Y1From", param.graph1Y1From);
    formData.append("graph1Y1To", param.graph1Y1To);
    formData.append("graph1Y2From", param.graph1Y2From);
    formData.append("graph1Y2To", param.graph1Y2To);
    formData.append("graph2Y1From", param.graph2Y1From);
    formData.append("graph2Y1To", param.graph2Y1To);
    formData.append("graph2Y2From", param.graph2Y2From);
    formData.append("graph2Y2To", param.graph2Y2To);
  }
  return formData;
}

/**
 * sendRequestUpdateListComment
 * @param {*} param
 */
export function sendRequestUpdateListComment(param) {
  var ordNo = param.ordNo;
  if (ordNo !== null) {
    delete param.ordNo;
    return ApiHelper.post(`/re-loop-rate-main-comments/${ordNo}`, param[0]);
  }
}

/**
 * 治療記録削除処理.
 * @param {Integer} ordNo オーダ番号
 */
export function sendRequestDeleteTreatmentRecordRst(ordNo) {
  return putWithLoader(`/treatment-record/delete/${ordNo}`, ordNo);
}

/**
 * オフライン実績マージ
 * @param {*} ordNo オーダー番号
 * @param {*} resultData オフライン実績データ
 */
export function sendOfflineTreatResultMerge(ordNo, resultData) {
  return configPostWithLoader(
    `/blood_purify/post_data/${ordNo}`,
    resultData,
    { headers: {"Content-Type": "text/plain"}}
  );
}

/**
 * 治療中情報有無判断
 * @param {*} ordNo オーダ番号
 */
export function sendRequestTreatingOrdNo(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/treating_ordno`);
}

//add FNSI-改修内容 グラフ様式修正 房 start
/**
 * モニタグラフ設定取得
 */
export function sendRequestGetVitalGraphDefine(facilityCd) {
  return getWithLoader(`/vital/graph-define/${facilityCd}`);
}
//add FNSI-改修内容 グラフ様式修正 房 end

//add FNSI-改修内容 投薬変更のお知らせ修正 房 start
export function sendGetNoticeMedi(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/medi_notice`);
}
//add FNSI-改修内容 投薬変更のお知らせ修正 房 end
/**
 * モニタ情報取得
 * @param {*} ordNo オーダ番号
 */
// mod #12462 患者情報共有 Ji start
export function sendRequestgetMonitorMsgRecord(ordNo, facilityCd) {
  return getWithLoader(`/treatment-record/${ordNo}/monitor_record`,{facilityCd});
// mod #12462 患者情報共有 Ji end
}

export function sendRequestUpdMonitorMsgRecord(MntMonitorMsgRecord) {
  return putWithLoader(`/treatment-record/update/monitor_record`, MntMonitorMsgRecord);
}

export function sendRequestUpdateMniMachineState(ordNo, bedNo) {
  return putWithLoader(`/treatment-record/result/bed_change/${ordNo}/${bedNo}`);
}

/**
 * 指定されたオーダ番号に紐付くマージ対象の実績情報リストを取得する.
 * @param {*} ordNo オーダ番号
 */
export function sendRequestGetResultMergeListForSelect(ordNo, startDate, endDate, isunKnown) {
  return getWithLoader(`/treatment-record/result-merge-list/${ordNo}/${startDate}/${endDate}/${isunKnown}`);
}

// #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 start
/**
 * 現在治療状況を取得する
 * @param {Number} ordNo オーダ番号
 */
export function sendRequestGetTreatmentRecordCurrentRstDialysisState(ordNo) {
  return getWithLoader(`/treatment-record/${ordNo}/current-dialysis-state`);
}
// #9315 2024.02.14 add オフライン治療開始後画面リロード処理 TDC片口 end
// add #11471 ord_mian操作時の治療モードデータの登録 関 start
export function sendRequestGetGetRstCondInfoSettingByOrdNo(ordNo) {
  return getWithLoader(
    `/treatment-record/${ordNo}/rst_cond_info_setting`
    );
}
// add #11471 ord_mian操作時の治療モードデータの登録 関 end
