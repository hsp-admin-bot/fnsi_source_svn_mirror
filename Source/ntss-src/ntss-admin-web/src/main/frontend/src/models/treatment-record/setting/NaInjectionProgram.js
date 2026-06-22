import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class NaInjectionProgram extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    souchi315,
    souchi326,
    souchi328,
    souchi327,
    souchi329,
    souchi316,
    souchi317,
    souchi318,
    souchi319,
    souchi320,
    souchi321,
    souchi322,
    souchi323,
    souchi324,
    souchi325,
    souchi330,
    souchi184
  ) {
    super(receiveDate, treatClass);
    this.souchi315 = souchi315;
    this.souchi326 = souchi326;
    this.souchi328 = souchi328;
    this.souchi327 = souchi327;
    this.souchi329 = souchi329;
    this.souchi316 = souchi316;
    this.souchi317 = souchi317;
    this.souchi318 = souchi318;
    this.souchi319 = souchi319;
    this.souchi320 = souchi320;
    this.souchi321 = souchi321;
    this.souchi322 = souchi322;
    this.souchi323 = souchi323;
    this.souchi324 = souchi324;
    this.souchi325 = souchi325;
    this.souchi330 = souchi330;
    this.souchi184 = souchi184;
  }

  getValueWithJsonKey() {
    return [
      {
        jsonKey: "315",
        value: this.isNullOrUndefined(this.souchi315)
          ? ""
          : this.getAfterConversionValue("315", this.souchi315)
      },
      {
        jsonKey: "326",
        value: this.isNullOrUndefined(this.souchi326)
          ? ""
          : `${this.souchi326} ${this.getUnit("326")}`
      },
      {
        jsonKey: "328",
        value: this.isNullOrUndefined(this.souchi328)
          ? ""
          : this.souchi328
      },
      {
        jsonKey: "327",
        value: this.isNullOrUndefined(this.souchi327)
          ? ""
          : this.getAfterConversionValue("327", this.souchi327)
      },
      {
        jsonKey: "329",
        value: this.isNullOrUndefined(this.souchi329)
          ? ""
          : `${this.souchi329} ${this.getUnit("329")}`
      },
      {
        jsonKey: "316",
        value: this.isNullOrUndefined(this.souchi316)
          ? ""
          : `${this.souchi316} ${this.getUnit("316")}`
      },
      {
        jsonKey: "317",
        value: this.isNullOrUndefined(this.souchi317)
          ? ""
          : `${this.souchi317} ${this.getUnit("317")}`
      },
      {
        jsonKey: "318",
        value: this.isNullOrUndefined(this.souchi318)
          ? ""
          : `${this.souchi318} ${this.getUnit("318")}`
      },
      {
        jsonKey: "319",
        value: this.isNullOrUndefined(this.souchi319)
          ? ""
          : `${this.souchi319} ${this.getUnit("319")}`
      },
      {
        jsonKey: "320",
        value: this.isNullOrUndefined(this.souchi320)
          ? ""
          : `${this.souchi320} ${this.getUnit("320")}`
      },
      {
        jsonKey: "321",
        value: this.isNullOrUndefined(this.souchi321)
          ? ""
          : `${this.souchi321} ${this.getUnit("321")}`
      },
      {
        jsonKey: "322",
        value: this.isNullOrUndefined(this.souchi322)
          ? ""
          : `${this.souchi322} ${this.getUnit("322")}`
      },
      {
        jsonKey: "323",
        value: this.isNullOrUndefined(this.souchi323)
          ? ""
          : `${this.souchi323} ${this.getUnit("323")}`
      },
      {
        jsonKey: "324",
        value: this.isNullOrUndefined(this.souchi324)
          ? ""
          : `${this.souchi324} ${this.getUnit("324")}`
      },
      {
        jsonKey: "325",
        value: this.isNullOrUndefined(this.souchi325)
          ? ""
          : `${this.souchi325} ${this.getUnit("325")}`
      },
      {
        jsonKey: "330",
        value: this.isNullOrUndefined(this.souchi330)
          ? ""
          : `${this.souchi330} ${this.getUnit("330")}`
      },
      {
        jsonKey: "184",
        value: this.isNullOrUndefined(this.souchi184)
          ? ""
          : `${this.souchi184} ${this.getUnit("184")}`
      }
    ];
  }
}
