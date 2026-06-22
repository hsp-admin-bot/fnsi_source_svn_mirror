/**
 * 予実リストのオーダー情報を表現するクラス
 */

export class PrescriptionResult {
  constructor(
    ordPrescriptionNo,
    prescriptionDetail,
    count,
    issueState,
    prescriptionType,
    treatDate,
    type
  ) {
    this.ordPrescriptionNo = ordPrescriptionNo;
    this.prescriptionDetail = prescriptionDetail;
    this.count = count;
    this.issueState = issueState;
    this.prescriptionType = prescriptionType;
    this.treatDate = treatDate;
    this.type = type;
    this.pattern = 1;
  }
}
