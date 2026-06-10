import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * 薬剤選択IFでデータを取得
 * @param {*} classCd 薬剤分類
 * @param {*} medicineName 薬剤名
 * @param {*} genericName 一般名処方
 * @param {*} facilityCd 施設CD
 */
export function sendRequestGetDrugs(classCd, medicineName, genericName, facilityCd, patId) {
    const obj = {
        facilityCd: facilityCd,
        classCd: classCd,
        medicineName: medicineName,
        genericName: genericName,
        patId: patId
    }
    return ApiHelper.post("/pat-prescription/search_medicine_selection", obj);
}

/**
 * すべての薬剤分類を取得
 * @param {*} facilityCd
 */
export function sendRequestGetAllMedicineClass(facilityCd) {
    const param = {
        facilityCd: facilityCd
    }
    return ApiHelper.get("/mstInfo/mstMedicineClass", param);
}

// add FNSI5516処方薬剤選択画面の表示が遅い 周 start
/**
 * すべての薬剤分類を取得
 * @param {*} facilityCd
 * @param {*} offset
 * @param {*} limit
 */
 export function sendRequestGetDrugsByOffsetAndLimit(classCd, medicineName, genericName, 
    facilityCd, patId, offset, limit) {
    const obj = {
        facilityCd: facilityCd,
        classCd: classCd,
        medicineName: medicineName,
        genericName: genericName,
        patId: patId,
        offset: offset,
        limit: limit
    }
    return ApiHelper.post("/pat-prescription/search_medicine_selection", obj);
}
// add FNSI5516処方薬剤選択画面の表示が遅い 周 end

/**
 * すべての薬剤分類を取得（削除済み含む）
 * @param {*} facilityCd
 */
 export function sendRequestGetAllMedicineClassIncludeDeleted(facilityCd) {
    const param = {
        facilityCd: facilityCd
    }
    return ApiHelper.get("/mstInfo/mstMedicineClassIncludeDeleted", param);
}

/**
 * 用法・用語マスタを取得
 * @param {*} facilityCd 施設CD
 */
export function sendRequestGetTakeMedicine(facilityCd) {
    return ApiHelper.get(`/pat-prescription/take_medicine/${facilityCd}`);
}

/**
 * 処方箋を保存
 * @param {*} ordPrescription 処方情報
 * @param {*} ordPersonalPrescription 処方詳細情報
 */
export function sendRequestSavePrescription(ordPrescription, ordPersonalPrescription) {
    const obj = {
        ordPrescription,
        ordPersonalPrescription
    }
    return ApiHelper.post("/pat-prescription/save", obj);
}

/**
 * 患者の保険一覧を取得
 * @param {*} patId 患者ID
 * @param {*} facilityCd 施設CD
 * @param {*} ordPrescriptionNo 処方箋CD
 */
export function sendRequestGetPatInsurance(patId, facilityCd, ordPrescriptionNo) {
    const obj = {
        patId,
        facilityCd,
        ordPrescriptionNo : ordPrescriptionNo != 0 ? ordPrescriptionNo: null
    }
    return ApiHelper.get("/pat-prescription/pat_insu_names", obj);
}

/**
 * 処方箋履歴一覧を取得
 * @param {*} data : 以下全てパラメータを含む
 * @param {*} patId : 患者ID
 * @param {*} facilityCd : 施設CD
 * @param {*} prescriptionType : 処方分類
 * @param {*} issueDateFrom : 交付日開始
 * @param {*} issueDateTo : 交付日終了
 * @param {*} issueState : 交付状況
 * @param {*} ordPrescriptionNo : 処方オーダー番号
 * @param {*} patientShareMode : 患者共有モード
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
        // add #12462 患者情報共有 Ji start
        patientShareMode: data.patientShareMode,
        // add #12462 患者情報共有 Ji end
    }
    return ApiHelper.post("/pat-prescription/search_ord_prescription", obj);
}

/**
 * 処方詳細を取得
 * @param {*} ordPrescriptionNo 処方箋CD
 */
export function sendRequestGetOrderPrescriptionDetail(ordPrescriptionNo) {
    const obj = {
        ordPrescriptionNo
    }
    return ApiHelper.get("/pat-prescription/prescription_details", obj);
}

/**
 * 処方箋を削除
 * @param {*} ordPrescriptionNo 処方箋CD
 */
export function sendRequestDeleteOrderPrescription(ordPrescriptionNo) {
    return ApiHelper.delete(`/pat-prescription/${ordPrescriptionNo}`);
}

/**
 * 施設の医師一覧を取得
 * @param {*} facilityCd 施設
 * @param {*} ordPrescriptionNo 処方箋CD
 */
export function sendRequestGetDoctorsAtFacility(facilityCd, ordPrescriptionNo) {
    const obj = {
        ordPrescriptionNo : ordPrescriptionNo != 0 ? ordPrescriptionNo: null
    }
    return ApiHelper.get(`/facilities/${facilityCd}/personal-user/job/doctor/prescription`, obj);
}

/**
 * 患者保険テーブルの保険情報を取得
 * @param {*} insuranceCd 保険CD
 */
export function sendRequestGetInsuInfoByCd(insuranceCd) {
    const obj = {
        insuranceCd
    }
    return ApiHelper.get("/pat-prescription/insu_info", obj);
}

// add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
/**
 * 施設名を取得
 * @param {*} facilityCd 施設コード
 */
export function sendRequestGetFacilityNameByCd(facilityCd) {
    const obj = {
        facilityCd
    }
    return ApiHelper.get("/pat-prescription/facility_name", obj);
}

/**
 * 処方一覧を取得
 */
// mod #12462 患者情報共有 Ji start
export function sendRequestGetprescriptionList(patIdList, issueDate, prescriptionTypeList, patientShareMode) {
    const obj = {
        patIdList,
        issueDate,
        prescriptionTypeList,
        patientShareMode
    }
    return ApiHelper.post("/pat-prescription/prescription-list", obj);
}
// mod #12462 患者情報共有 Ji end
// add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end

/**
 * 対象処方件数を取得（一括交付済み変更）
 */
export function sendRequestGetPatPrescriptionCount(patIdList, issueDate, facilityCd) {
    const obj = {
        patIdList,
        issueDate,
        facilityCd
    }
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
    }
    return ApiHelper.post("/pat-prescription/ord-prescription-no-list", obj);
}

/**
 * 交付状態変更（一括交付済み変更）
 */
export function updateIssueState (ordPrescriptionNoList, insuDrId, selectedPreDoctor, facilityCd) {
    const obj = {
        ordPrescriptionNoList,
        insuDrId,
        selectedPreDoctor,
        facilityCd
    }
    return ApiHelper.post("/pat-prescription/update-issue-state", obj);
}

/**
 * 一括処理オーダー 過去の処方を複製して登録
 */
export function sendRequestSaveCopyPrescription(ordPrescriptionNoList, insuDrId, issueState, issueDate, selectedPreDoctor) {
    const obj = {
        ordPrescriptionNoList,
        insuDrId,
        issueState,
        issueDate,
        selectedPreDoctor
    }
    return ApiHelper.post("/pat-prescription/copy-prescription", obj);
}
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
/**
 * 通用组品取得薬剤分类薬剤データ
 */
export function getMstListCompose(obj) {
    return ApiHelper.post("/master_maintenance/mst-list-compose", obj);
}
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end