import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class KeihouJouhou extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    keihouJouhou180,
    keihouJouhou286,
    keihouJouhou335
  ) {
    super(receiveDate, treatClass);
    this.keihouJouhou180 = keihouJouhou180;
    this.keihouJouhou286 = keihouJouhou286;
    this.keihouJouhou335 = keihouJouhou335;
  }

  /**
   * 装置設定の警報情報アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "180",
        value: this.isNullOrUndefined(this.keihouJouhou180)
          ? ""
          : `${this.keihouJouhou180} ${this.getUnit("180")}`
      },
      {
        jsonKey: "286",
        value: this.isNullOrUndefined(this.keihouJouhou286)
          ? ""
          : this.keihouJouhou286
      },
      {
        jsonKey: "335",
        value: this.isNullOrUndefined(this.keihouJouhou335)
          ? ""
          : `${this.keihouJouhou335} ${this.getUnit("335")}`
      }
    ];
  }
}
