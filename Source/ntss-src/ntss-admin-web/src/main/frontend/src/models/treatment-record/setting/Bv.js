import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class Bv extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    bv267,
    bv260,
    bv261,
    bv262,
    bv277,
    bv278,
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
    bv476,
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
    bv258,
    bv259,
    bv263,
    bv264,
    bv265,
    bv266,
    bv281
  ) {
    super(receiveDate, treatClass);
    this.bv267 = bv267;
    this.bv260 = bv260;
    this.bv261 = bv261;
    this.bv262 = bv262;
    this.bv277 = bv277;
    this.bv278 = bv278;
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
    this.bv476 = bv476,
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
    this.bv258 = bv258;
    //mod FNSI 外結バッグ69 房 start
    this.bv259 = bv259 == -1 ? "" : bv259;
    this.bv263 = bv263 == -1 ? "" : bv263;
    this.bv264 = bv264 == -1 ? "" : bv264;
    this.bv265 = bv265 == -1 ? "" : bv265;
    this.bv266 = bv266 == -1 ? "" : bv266;
    //mod FNSI 外結バッグ69 房 end
    this.bv281 = bv281;
  }

  /**
   * 装置設定のBVアコーディオンに表示するデータ
   */
  /*
  // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 start
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "267",
        value: this.isNullOrUndefined(this.bv267)
          ? ""
          : this.getAfterConversionValue("267", this.bv267)
      },
      {
        jsonKey: "260",
        value: this.isNullOrUndefined(this.bv260)
          ? ""
          : `${this.bv260} ${this.getUnit("260")}`
      },
      {
        jsonKey: "261",
        value: this.isNullOrUndefined(this.bv261)
          ? ""
          : `${this.bv261} ${this.getUnit("261")}`
      },
      {
        jsonKey: "262",
        value: this.isNullOrUndefined(this.bv262)
          ? ""
          : `${this.bv262} ${this.getUnit("262")}`
      },
      {
        jsonKey: "277",
        value: this.isNullOrUndefined(this.bv277)
          ? ""
          : `${this.bv277} ${this.getUnit("277")}`
      },
      {
        jsonKey: "278",
        value: this.isNullOrUndefined(this.bv278)
          ? ""
          : `${this.bv278} ${this.getUnit("278")}`
      },
      {
        jsonKey: "258",
        value: this.isNullOrUndefined(this.bv258)
          ? ""
          : this.getAfterConversionValue("258", this.bv258)
      },
      {
        jsonKey: "259",
        value: this.isNullOrUndefined(this.bv259)
          ? ""
          : this.bv259
      },
      {
        jsonKey: "263",
        value: this.isNullOrUndefined(this.bv263)
          ? ""
          : this.bv263
      },
      {
        jsonKey: "264",
        value: this.isNullOrUndefined(this.bv264)
          ? ""
          : this.bv264
      },
      {
        jsonKey: "265",
        value: this.isNullOrUndefined(this.bv265)
          ? ""
          : this.bv265
      },
      {
        jsonKey: "266",
        value: this.isNullOrUndefined(this.bv266)
          ? ""
          : this.bv266
      },
      {
        jsonKey: "281",
        value: this.isNullOrUndefined(this.bv281)
          ? ""
          : `${this.bv281} ${this.getUnit("281")}`
      }
    ];
  }
  */
  getValueWithJsonKey(so2Count) {
    const bvData = [
      {
        jsonKey: "267",
        value: this.isNullOrUndefined(this.bv267)
          ? ""
          : this.getAfterConversionValue("267", this.bv267)
      },
      {
        jsonKey: "260",
        value: this.isNullOrUndefined(this.bv260)
          ? ""
          : `${this.bv260} ${this.getUnit("260")}`
      },
      {
        jsonKey: "261",
        value: this.isNullOrUndefined(this.bv261)
          ? ""
          : `${this.bv261} ${this.getUnit("261")}`
      },
      {
        jsonKey: "262",
        value: this.isNullOrUndefined(this.bv262)
          ? ""
          : `${this.bv262} ${this.getUnit("262")}`
      },
      {
        jsonKey: "277",
        value: this.isNullOrUndefined(this.bv277)
          ? ""
          : `${this.bv277} ${this.getUnit("277")}`
      },
      {
        jsonKey: "278",
        value: this.isNullOrUndefined(this.bv278)
          ? ""
          : `${this.bv278} ${this.getUnit("278")}`
      },
      {
        jsonKey: "476",
        value: this.isNullOrUndefined(this.bv476)
          ? ""
          : `${this.bv476} ${this.getUnit("476")}`
      },
      {
        jsonKey: "258",
        value: this.isNullOrUndefined(this.bv258)
          ? ""
          : this.getAfterConversionValue("258", this.bv258)
      },
      {
        jsonKey: "259",
        value: this.isNullOrUndefined(this.bv259)
          ? ""
          : this.bv259
      },
      {
        jsonKey: "263",
        value: this.isNullOrUndefined(this.bv263)
          ? ""
          : this.bv263
      },
      {
        jsonKey: "264",
        value: this.isNullOrUndefined(this.bv264)
          ? ""
          : this.bv264
      },
      {
        jsonKey: "265",
        value: this.isNullOrUndefined(this.bv265)
          ? ""
          : this.bv265
      },
      {
        jsonKey: "266",
        value: this.isNullOrUndefined(this.bv266)
          ? ""
          : this.bv266
      },
      {
        jsonKey: "281",
        value: this.isNullOrUndefined(this.bv281)
          ? ""
          : `${this.bv281} ${this.getUnit("281")}`
      }
    ];

    if ( so2Count == 0 ) {
      let index  = bvData.findIndex(so2 => {
        return so2.jsonKey === "476"
      });
      if ( index > 0 ) {
        bvData.splice(index, 1);
      }
    }
    return bvData;
  }
  // #11124 2025.08.26 mod 酸素飽和度対応 TDC高村 start
}
