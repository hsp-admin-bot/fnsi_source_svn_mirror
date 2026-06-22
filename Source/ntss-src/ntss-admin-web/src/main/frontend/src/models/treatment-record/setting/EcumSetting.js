import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";
import { Minutes } from "@/models/treatment-record/setting/Minutes";

export class EcumSetting extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    souchi16,
    souchi17,
    souchi18,
    souchi19
  ) {
    super(receiveDate, treatClass);
    this.souchi16 = souchi16;
    this.souchi17 = souchi17;
    this.souchi18 = souchi18;
    this.souchi19 = souchi19;
  }

  getValueWithJsonKey() {
    return [
      {
        jsonKey: "16",
        value: this.isNullOrUndefined(this.souchi16)
          ? ""
          : this.getAfterConversionValue("16", this.souchi16)
      },
      {
        jsonKey: "17",
        value: this.isNullOrUndefined(this.souchi17)
          ? ""
          : `${this.souchi17} ${this.getUnit("17")}`
      },
      {
        jsonKey: "18",
        value: this.isNullOrUndefined(this.souchi18)
          ? ""
          : new Minutes(this.souchi18).getHHmm()
      },
      {
        jsonKey: "19",
        value: this.isNullOrUndefined(this.souchi19)
          ? ""
          : this.getAfterConversionValue("19", this.souchi19)
      }
    ];
  }
}
