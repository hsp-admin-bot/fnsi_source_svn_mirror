import { CODES } from "@/constants/TreatmentRecord";

/**
 * 処置選択ポップオーバー用のモデルクラス
 */
export class MstCompTreatment {
  constructor(
    cd = null,
    name = "",
    treatClass = CODES.TREATMENT_CLASS.NORMAL.cd,
    treatMedicineCd = null,
    amount = null,
    procedureCd = null
  ) {
    this.cd = cd;
    this.name = name;
    this.treatClass = treatClass;
    this.treatMedicine = {
      cd: treatMedicineCd,
      name: null,
      unit: null
    };
    this.amount = amount;
    this.procedure = {
      cd: procedureCd,
      name: null
    };
  }

  // 入力されているかどうかを返す
  isEmpty() {
    return this.cd === null && !this.name;
  }

  /**
   * 表示文字列取得.
   */
  get displayItems() {
    const unit = this.treatMedicine.unit ? this.treatMedicine.unit : "";
    const dispAmount = this.amount !== null ? `${this.amount} ${unit}` : "";
    return [
      this.name,
      this.treatMedicine.name
        ? `${this.treatMedicine.name} ${dispAmount}`
        : null,
      this.procedure.name
    ];
  }

  /**
   * 検索用文字列取得.
   */
  get searchText() {
    return this.displayItems.join(" ");
  }
}
