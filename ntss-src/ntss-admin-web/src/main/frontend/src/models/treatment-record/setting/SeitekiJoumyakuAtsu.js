import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class SeitekiJoumyakuAtsu extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    joumyakuAtsu468,
    joumyakuAtsu469,
    joumyakuAtsu470,
    joumyakuAtsu471
  ) {
    super(receiveDate, treatClass);
    this.joumyakuAtsu468 = joumyakuAtsu468;
    this.joumyakuAtsu469 = joumyakuAtsu469;
    this.joumyakuAtsu470 = joumyakuAtsu470;
    this.joumyakuAtsu471 = joumyakuAtsu471;
  }

  /**
   * 装置設定の静的静脈圧アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "468",
        value: this.isNullOrUndefined(this.joumyakuAtsu468)
          ? ""
          : `${this.joumyakuAtsu468} ${this.getUnit("468")}`
      },
      {
        jsonKey: "469",
        value: this.isNullOrUndefined(this.joumyakuAtsu469)
          ? ""
          : this.joumyakuAtsu469
      },
      {
        jsonKey: "470",
        value: this.isNullOrUndefined(this.joumyakuAtsu470)
          ? ""
          : this.getAfterConversionValue("470", this.joumyakuAtsu470)
      },
      {
        jsonKey: "471",
        value: this.isNullOrUndefined(this.joumyakuAtsu471)
          ? ""
          : this.getAfterConversionValue("471", this.joumyakuAtsu471)
      }
    ];
  }
}
