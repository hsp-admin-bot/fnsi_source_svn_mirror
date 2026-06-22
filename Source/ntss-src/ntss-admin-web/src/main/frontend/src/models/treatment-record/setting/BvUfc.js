import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class BvUfc extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    // FNSI-add 装置設定画面表示の修正 徐 start
    bvUfc196,
    bvUfc199,
    bvUfc206,
    bvUfc207,
    bvUfc208,
    bvUfc249,
    bvUfc197,
    bvUfc198,
    bvUfc209,
    bvUfc210,
    bvUfc248,
    bvUfc271,
    bvUfc272,
    bvUfc273,
    bvUfc274,
    bvUfc275
    // bvUfc196,
    // bvUfc197,
    // bvUfc198,
    // bvUfc199,
    // bvUfc206,
    // bvUfc207,
    // bvUfc208,
    // bvUfc209,
    // bvUfc210,
    // bvUfc248,
    // bvUfc249,
    // bvUfc271,
    // bvUfc272,
    // bvUfc273,
    // bvUfc274,
    // bvUfc275
    // FNSI-add 装置設定画面表示の修正 徐 end
  ) {
    super(receiveDate, treatClass);
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.bvUfc196 = bvUfc196;
    this.bvUfc199 = bvUfc199;
    this.bvUfc206 = bvUfc206;
    this.bvUfc207 = bvUfc207;
    this.bvUfc208 = bvUfc208;
    this.bvUfc249 = bvUfc249;
    this.bvUfc197 = bvUfc197;
    this.bvUfc198 = bvUfc198;
    this.bvUfc209 = bvUfc209;
    this.bvUfc210 = bvUfc210;
    this.bvUfc248 = bvUfc248;
    this.bvUfc271 = bvUfc271;
    this.bvUfc272 = bvUfc272;
    this.bvUfc273 = bvUfc273;
    this.bvUfc274 = bvUfc274;
    this.bvUfc275 = bvUfc275;
    // this.bvUfc196 = bvUfc196;
    // this.bvUfc197 = bvUfc197;
    // this.bvUfc198 = bvUfc198;
    // this.bvUfc199 = bvUfc199;
    // this.bvUfc206 = bvUfc206;
    // this.bvUfc207 = bvUfc207;
    // this.bvUfc208 = bvUfc208;
    // this.bvUfc209 = bvUfc209;
    // this.bvUfc210 = bvUfc210;
    // this.bvUfc248 = bvUfc248;
    // this.bvUfc249 = bvUfc249;
    // this.bvUfc271 = bvUfc271;
    // this.bvUfc272 = bvUfc272;
    // this.bvUfc273 = bvUfc273;
    // this.bvUfc274 = bvUfc274;
    // this.bvUfc275 = bvUfc275;
    // FNSI-add 装置設定画面表示の修正 徐 end
  }

  /**
   * 装置設定のBV-UFCアコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "196",
        value: this.isNullOrUndefined(this.bvUfc196)
          ? ""
          : this.getAfterConversionValue("196", this.bvUfc196)
      },
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "199",
        value: this.isNullOrUndefined(this.bvUfc199)
          ? ""
          : `${this.bvUfc199} ${this.getUnit("199")}`
      },
      {
        jsonKey: "206",
        value: this.isNullOrUndefined(this.bvUfc206) ? "" : this.bvUfc206
      },
      {
        jsonKey: "207",
        value: this.isNullOrUndefined(this.bvUfc207)
          ? ""
          : `${this.bvUfc207} ${this.getUnit("207")}`
      },
      {
        jsonKey: "208",
        value: this.isNullOrUndefined(this.bvUfc208) ? "" : this.bvUfc208
      },
      {
        jsonKey: "249",
        value: this.isNullOrUndefined(this.bvUfc249)
          ? ""
          : `${this.bvUfc249} ${this.getUnit("249")}`
      },
      {
        jsonKey: "197",
        value: this.isNullOrUndefined(this.bvUfc197)
          ? ""
          : `${this.bvUfc197} ${this.getUnit("197")}`
      },
      {
        jsonKey: "198",
        value: this.isNullOrUndefined(this.bvUfc198)
          ? ""
          : `${this.bvUfc198} ${this.getUnit("198")}`
      },
      {
        jsonKey: "209",
        value: this.isNullOrUndefined(this.bvUfc209)
          ? ""
          : `${this.bvUfc209} ${this.getUnit("209")}`
      },
      {
        jsonKey: "210",
        value: this.isNullOrUndefined(this.bvUfc210)
          ? ""
          : `${this.bvUfc210} ${this.getUnit("210")}`
      },
      {
        jsonKey: "248",
        value: this.isNullOrUndefined(this.bvUfc248)
          ? ""
          : `${this.bvUfc248} ${this.getUnit("248")}`
      },
      // {
      //   jsonKey: "197",
      //   value: this.isNullOrUndefined(this.bvUfc197)
      //     ? ""
      //     : `${this.bvUfc197} ${this.getUnit("197")}`
      // },
      // {
      //   jsonKey: "198",
      //   value: this.isNullOrUndefined(this.bvUfc198)
      //     ? ""
      //     : `${this.bvUfc198} ${this.getUnit("198")}`
      // },
      // {
      //   jsonKey: "199",
      //   value: this.isNullOrUndefined(this.bvUfc199)
      //     ? ""
      //     : `${this.bvUfc199} ${this.getUnit("199")}`
      // },
      // {
      //   jsonKey: "206",
      //   value: this.isNullOrUndefined(this.bvUfc206) ? "" : this.bvUfc206
      // },
      // {
      //   jsonKey: "207",
      //   value: this.isNullOrUndefined(this.bvUfc207)
      //     ? ""
      //     : `${this.bvUfc207} ${this.getUnit("207")}`
      // },
      // {
      //   jsonKey: "208",
      //   value: this.isNullOrUndefined(this.bvUfc208) ? "" : this.bvUfc208
      // },
      // {
      //   jsonKey: "209",
      //   value: this.isNullOrUndefined(this.bvUfc209)
      //     ? ""
      //     : `${this.bvUfc209} ${this.getUnit("209")}`
      // },
      // {
      //   jsonKey: "210",
      //   value: this.isNullOrUndefined(this.bvUfc210)
      //     ? ""
      //     : `${this.bvUfc210} ${this.getUnit("210")}`
      // },
      // {
      //   jsonKey: "248",
      //   value: this.isNullOrUndefined(this.bvUfc248)
      //     ? ""
      //     : `${this.bvUfc248} ${this.getUnit("248")}`
      // },
      // {
      //   jsonKey: "249",
      //   value: this.isNullOrUndefined(this.bvUfc249)
      //     ? ""
      //     : `${this.bvUfc249} ${this.getUnit("249")}`
      // },
      // FNSI-add 装置設定画面表示の修正 徐 end
      {
        jsonKey: "271",
        value: this.isNullOrUndefined(this.bvUfc271)
          ? ""
          : `${this.bvUfc271} ${this.getUnit("271")}`
      },
      {
        jsonKey: "272",
        value: this.isNullOrUndefined(this.bvUfc272) ? "" : this.bvUfc272
      },
      {
        jsonKey: "273",
        value: this.isNullOrUndefined(this.bvUfc273) ? "" : this.bvUfc273
      },
      {
        jsonKey: "274",
        value: this.isNullOrUndefined(this.bvUfc274) ? "" : this.bvUfc274
      },
      {
        jsonKey: "275",
        value: this.isNullOrUndefined(this.bvUfc275)
          ? ""
          : `${this.bvUfc275} ${this.getUnit("275")}`
      }
    ];
  }
}
