/**
 * 処方系 API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

function withSelectedPatId(params = undefined, selectedPatId) {
  if (selectedPatId === null || selectedPatId === undefined || selectedPatId === "") {
    return params;
  }
  return {
    ...(params || {}),
    selectedPatId
  };
}

/**
 * 薬剤選択IFでデータを取得
 */
export function sendRequestGetDrugs(
  classCd,
  medicineName,
  genericName,
  facilityCd,
  patId
) {
  const obj = {
    facilityCd,
    classCd,
    medicineName,
    genericName,
    patId
  };
  return ApiHelper.post("/pat-prescription/search_medicine_selection", obj);
}

/**
 * すべての薬剤分類を取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetAllMedicineClass(facilityCd, selectedPatId) {
  const param = { facilityCd };
  return ApiHelper.get("/mstInfo/mstMedicineClass", withSelectedPatId(param, selectedPatId));
}

// add FNSI5516処方薬剤選択画面の表示が遅い 周 start
/**
 * 薬剤検索（offset / limit 付き）
 */
export function sendRequestGetDrugsByOffsetAndLimit(
  classCd,
  medicineName,
  genericName,
  facilityCd,
  patId,
  offset,
  limit
) {
  const obj = {
    facilityCd,
    classCd,
    medicineName,
    genericName,
    patId,
    offset,
    limit
  };
  return ApiHelper.post("/pat-prescription/search_medicine_selection", obj);
}
// add FNSI5516処方薬剤選択画面の表示が遅い 周 end

/**
 * すべての薬剤分類を取得（削除済み含む）
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetAllMedicineClassIncludeDeleted(facilityCd) {
  const param = { facilityCd };
  return ApiHelper.get("/mstInfo/mstMedicineClassIncludeDeleted", param);
}

/**
 * 用法・用語マスタを取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetTakeMedicine(facilityCd, selectedPatId) {
  return ApiHelper.get(`/pat-prescription/take_medicine/${facilityCd}`, withSelectedPatId(undefined, selectedPatId));
}

/**
 * 処方箋を保存
 */
export function sendRequestSavePrescription(ordPrescription, ordPersonalPrescription) {
  const obj = {
    ordPrescription,
    ordPersonalPrescription
  };
  return ApiHelper.post("/pat-prescription/save", obj);
}

/**
 * 患者の保険一覧を取得
 */
export function sendRequestGetPatInsurance(patId, facilityCd, ordPrescriptionNo) {
  const obj = {
    patId,
    facilityCd,
    ordPrescriptionNo: ordPrescriptionNo != 0 ? ordPrescriptionNo : null
  };
  return ApiHelper.get("/pat-prescription/pat_insu_names", obj);
}

/**
 * 処方箋履歴一覧を取得
 * @param {Record<string, unknown>} data 検索条件（patId, facilityCd, prescriptionType 等）
 */
export function sendRequestGetOrderPrescription(data) {
  const obj = {
    patId: data.patId,
    facilityCd: data.facilityCd,
    prescriptionType: data.prescriptionType,
    issueDateFrom: data.issueDateFrom,
    issueDateTo: data.issueDateTo,
    issueState: data.issueState,
    ordPrescriptionNo: data.ordPrescriptionNo,
    patientShareMode: data.patientShareMode
  };
  return ApiHelper.post("/pat-prescription/search_ord_prescription", obj);
}

/**
 * 処方詳細を取得
 */
export function sendRequestGetOrderPrescriptionDetail(ordPrescriptionNo, selectedPatId) {
  const obj = { ordPrescriptionNo };
  return ApiHelper.get("/pat-prescription/prescription_details", withSelectedPatId(obj, selectedPatId));
}

/**
 * 処方箋を削除
 */
export function sendRequestDeleteOrderPrescription(ordPrescriptionNo) {
  return ApiHelper.delete(`/pat-prescription/${ordPrescriptionNo}`);
}

/**
 * 施設の医師一覧を取得
 */
export function sendRequestGetDoctorsAtFacility(facilityCd, ordPrescriptionNo) {
  const obj = {
    ordPrescriptionNo: ordPrescriptionNo != 0 ? ordPrescriptionNo : null
  };
  return ApiHelper.get(
    `/facilities/${facilityCd}/personal-user/job/doctor/prescription`,
    obj
  );
}

/**
 * 患者保険テーブルの保険情報を取得
 */
export function sendRequestGetInsuInfoByCd(insuranceCd, selectedPatId) {
  const obj = { insuranceCd };
  return ApiHelper.get("/pat-prescription/insu_info", withSelectedPatId(obj, selectedPatId));
}

// add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
/**
 * 施設名を取得
 * @param {string} facilityCd 施設コード
 */
export function sendRequestGetFacilityNameByCd(facilityCd, selectedPatId) {
  const obj = { facilityCd };
  return ApiHelper.get("/pat-prescription/facility_name", withSelectedPatId(obj, selectedPatId));
}

/**
 * 処方一覧を取得
 */
export function sendRequestGetPrescriptionList(
  patIdList,
  issueDate,
  prescriptionTypeList,
  patientShareMode
) {
  const obj = {
    patIdList,
    issueDate,
    prescriptionTypeList,
    patientShareMode
  };
  return ApiHelper.post("/pat-prescription/prescription-list", obj);
}
// add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end

/**
 * 対象処方件数を取得（一括交付済み変更）
 */
export function sendRequestGetPatPrescriptionCount(patIdList, issueDate, facilityCd) {
  const obj = {
    patIdList,
    issueDate,
    facilityCd
  };
  return ApiHelper.post("/pat-prescription/prescription-count", obj);
}

/**
 * 交付状態変更対象を取得（一括交付済み変更）
 */
export function sendRequestGetOrdPrescriptionNoList(patIdList, issueDate, facilityCd) {
  const obj = {
    patIdList,
    issueDate,
    facilityCd
  };
  return ApiHelper.post("/pat-prescription/ord-prescription-no-list", obj);
}

/**
 * 交付状態変更（一括交付済み変更）
 */
export function sendRequestUpdateIssueState(
  ordPrescriptionNoList,
  insuDrId,
  selectedPreDoctor,
  facilityCd
) {
  const obj = {
    ordPrescriptionNoList,
    insuDrId,
    selectedPreDoctor,
    facilityCd
  };
  return ApiHelper.post("/pat-prescription/update-issue-state", obj);
}

/**
 * 一括処理オーダー 過去の処方を複製して登録
 */
export function sendRequestSaveCopyPrescription(
  ordPrescriptionNoList,
  insuDrId,
  issueState,
  issueDate,
  selectedPreDoctor
) {
  const obj = {
    ordPrescriptionNoList,
    insuDrId,
    issueState,
    issueDate,
    selectedPreDoctor
  };
  return ApiHelper.post("/pat-prescription/copy-prescription", obj);
}

// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
/**
 * マスタ組み合わせ一覧取得
 */
export function getMstListCompose(obj) {
  return ApiHelper.post("/master_maintenance/mst-list-compose", obj);
}
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

export { sendRequestGetPrescriptionList as sendRequestGetprescriptionList };
export { sendRequestUpdateIssueState as updateIssueState };
