import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class DiversionProgram extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    souchi290,
    souchi311,
    souchi312,
    souchi313,
    souchi291,
    souchi301,
    souchi292,
    souchi302,
    souchi293,
    souchi303,
    souchi294,
    souchi304,
    souchi295,
    souchi305,
    souchi296,
    souchi306,
    souchi297,
    souchi307,
    souchi298,
    souchi308,
    souchi299,
    souchi309,
    souchi300,
    souchi310,
    souchi314
  ) {
    super(receiveDate, treatClass);
    this.souchi290 = souchi290;
    this.souchi311 = souchi311;
    this.souchi312 = souchi312;
    this.souchi313 = souchi313;
    this.souchi291 = souchi291;
    this.souchi301 = souchi301;
    this.souchi292 = souchi292;
    this.souchi302 = souchi302;
    this.souchi293 = souchi293;
    this.souchi303 = souchi303;
    this.souchi294 = souchi294;
    this.souchi304 = souchi304;
    this.souchi295 = souchi295;
    this.souchi305 = souchi305;
    this.souchi296 = souchi296;
    this.souchi306 = souchi306;
    this.souchi297 = souchi297;
    this.souchi307 = souchi307;
    this.souchi298 = souchi298;
    this.souchi308 = souchi308;
    this.souchi299 = souchi299;
    this.souchi309 = souchi309;
    this.souchi300 = souchi300;
    this.souchi310 = souchi310;
    this.souchi314 = souchi314;
  }

  getValueWithJsonKey() {
    return [
      {
        jsonKey: "290",
        value: this.isNullOrUndefined(this.souchi290)
          ? ""
          : this.getAfterConversionValue("290", this.souchi290)
      },
      {
        jsonKey: "311",
        value: this.isNullOrUndefined(this.souchi311)
          ? ""
          : this.souchi311
      },
      {
        jsonKey: "312",
        value: this.isNullOrUndefined(this.souchi312)
          ? ""
          : this.souchi312
      },
      {
        jsonKey: "313",
        value: this.isNullOrUndefined(this.souchi313)
          ? ""
          : `${this.souchi313} ${this.getUnit("313")}`
      },
      {
        jsonKey: "291",
        value: this.isNullOrUndefined(this.souchi291)
          ? ""
          : this.getAfterConversionValue("291", this.souchi291)
      },
      {
        jsonKey: "301",
        value: this.isNullOrUndefined(this.souchi301)
          ? ""
          : `${this.souchi301} ${this.getUnit("301")}`
      },
      {
        jsonKey: "292",
        value: this.isNullOrUndefined(this.souchi292)
          ? ""
          : this.getAfterConversionValue("292", this.souchi292)
      },
      {
        jsonKey: "302",
        value: this.isNullOrUndefined(this.souchi302)
          ? ""
          : `${this.souchi302} ${this.getUnit("302")}`
      },
      {
        jsonKey: "293",
        value: this.isNullOrUndefined(this.souchi293)
          ? ""
          : this.getAfterConversionValue("293", this.souchi293)
      },
      {
        jsonKey: "303",
        value: this.isNullOrUndefined(this.souchi303)
          ? ""
          : `${this.souchi303} ${this.getUnit("303")}`
      },
      {
        jsonKey: "294",
        value: this.isNullOrUndefined(this.souchi294)
          ? ""
          : this.getAfterConversionValue("294", this.souchi294)
      },
      {
        jsonKey: "304",
        value: this.isNullOrUndefined(this.souchi304)
          ? ""
          : `${this.souchi304} ${this.getUnit("304")}`
      },
      {
        jsonKey: "295",
        value: this.isNullOrUndefined(this.souchi295)
          ? ""
          : this.getAfterConversionValue("295", this.souchi295)
      },
      {
        jsonKey: "305",
        value: this.isNullOrUndefined(this.souchi305)
          ? ""
          : `${this.souchi305} ${this.getUnit("305")}`
      },
      {
        jsonKey: "296",
        value: this.isNullOrUndefined(this.souchi296)
          ? ""
          : this.getAfterConversionValue("296", this.souchi296)
      },
      {
        jsonKey: "306",
        value: this.isNullOrUndefined(this.souchi306)
          ? ""
          : `${this.souchi306} ${this.getUnit("306")}`
      },
      {
        jsonKey: "297",
        value: this.isNullOrUndefined(this.souchi297)
          ? ""
          : this.getAfterConversionValue("297", this.souchi297)
      },
      {
        jsonKey: "307",
        value: this.isNullOrUndefined(this.souchi307)
          ? ""
          : `${this.souchi307} ${this.getUnit("307")}`
      },
      {
        jsonKey: "298",
        value: this.isNullOrUndefined(this.souchi298)
          ? ""
          : this.getAfterConversionValue("298", this.souchi298)
      },
      {
        jsonKey: "308",
        value: this.isNullOrUndefined(this.souchi308)
          ? ""
          : `${this.souchi308} ${this.getUnit("308")}`
      },
      {
        jsonKey: "299",
        value: this.isNullOrUndefined(this.souchi299)
          ? ""
          : this.getAfterConversionValue("299", this.souchi299)
      },
      {
        jsonKey: "309",
        value: this.isNullOrUndefined(this.souchi309)
          ? ""
          : `${this.souchi309} ${this.getUnit("309")}`
      },
      {
        jsonKey: "300",
        value: this.isNullOrUndefined(this.souchi300)
          ? ""
          : this.getAfterConversionValue("300", this.souchi300)
      },
      {
        jsonKey: "310",
        value: this.isNullOrUndefined(this.souchi310)
          ? ""
          : `${this.souchi310} ${this.getUnit("310")}`
      },
      {
        jsonKey: "314",
        value: this.isNullOrUndefined(this.souchi314)
          ? ""
          : `${this.souchi314} ${this.getUnit("314")}`
      }
    ];
  }
}
