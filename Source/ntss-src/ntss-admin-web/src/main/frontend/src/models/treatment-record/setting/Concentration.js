import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class Concentration extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    souchi252,
    souchi253,
    souchi250,
    souchi251
  ) {
    super(receiveDate, treatClass);
    this.souchi252 = souchi252;
    this.souchi253 = souchi253;
    this.souchi250 = souchi250;
    this.souchi251 = souchi251;
  }

  getValueWithJsonKey() {
    return [
      {
        jsonKey: "252",
        value: this.isNullOrUndefined(this.souchi252)
          ? ""
          : `${this.souchi252} ${this.getUnit("252")}`
      },
      {
        jsonKey: "253",
        value: this.isNullOrUndefined(this.souchi253)
          ? ""
          : `${this.souchi253} ${this.getUnit("253")}`
      },
      {
        jsonKey: "250",
        value: this.isNullOrUndefined(this.souchi250)
          ? ""
          : `${this.souchi250} ${this.getUnit("250")}`
      },
      {
        jsonKey: "251",
        value: this.isNullOrUndefined(this.souchi251)
          ? ""
          : `${this.souchi251} ${this.getUnit("251")}`
      }
    ];
  }
}
