import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class PrimingAndHenketsu extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    primingAndHenketsu370,
    primingAndHenketsu371,
    primingAndHenketsu372
  ) {
    super(receiveDate, treatClass);
    this.primingAndHenketsu370 = primingAndHenketsu370;
    this.primingAndHenketsu371 = primingAndHenketsu371;
    this.primingAndHenketsu372 = primingAndHenketsu372;
  }

  /**
   * 装置設定のプライミング・返血アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "370",
        value: this.isNullOrUndefined(this.primingAndHenketsu370)
          ? ""
          : `${this.primingAndHenketsu370} ${this.getUnit("370")}`
      },
      {
        jsonKey: "371",
        value: this.isNullOrUndefined(this.primingAndHenketsu371)
          ? ""
          : `${this.primingAndHenketsu371} ${this.getUnit("371")}`
      },
      {
        jsonKey: "372",
        value: this.isNullOrUndefined(this.primingAndHenketsu372)
          ? ""
          : this.getAfterConversionValue("372", this.primingAndHenketsu372)
      }
    ];
  }
}
