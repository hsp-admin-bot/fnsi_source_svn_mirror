import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class DFas extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    dfas339,
    dfas333,
    dfas331,
    dfas334,
    dfas338,
    dfas332,
    // FNSI-add 装置設定画面表示の修正 徐 start
    dfas335,
    // FNSI-add 装置設定画面表示の修正 徐 end
    dfas373,
    dfas374,
    dfas377,
    dfas270,
    dfas376,
    dfas378
  ) {
    super(receiveDate, treatClass);
    this.dfas339 = dfas339;
    this.dfas333 = dfas333;
    this.dfas331 = dfas331;
    this.dfas334 = dfas334;
    this.dfas338 = dfas338;
    this.dfas332 = dfas332;
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.dfas335 = dfas335;
    // FNSI-add 装置設定画面表示の修正 徐 end
    this.dfas373 = dfas373;
    this.dfas374 = dfas374;
    this.dfas377 = dfas377;
    this.dfas270 = dfas270;
    this.dfas376 = dfas376;
    this.dfas378 = dfas378;
  }

  /**
   * 装置設定のD-FASアコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "339",
        value: this.isNullOrUndefined(this.dfas339)
          ? ""
          : this.getAfterConversionValue("339", this.dfas339)
      },
      {
        jsonKey: "333",
        value: this.isNullOrUndefined(this.dfas333)
          ? ""
          : `${this.dfas333} ${this.getUnit("333")}`
      },
      {
        jsonKey: "331",
        value: this.isNullOrUndefined(this.dfas331)
          ? ""
          : `${this.dfas331} ${this.getUnit("331")}`
      },
      {
        jsonKey: "334",
        value: this.isNullOrUndefined(this.dfas334)
          ? ""
          : `${this.dfas334} ${this.getUnit("334")}`
      },
      {
        jsonKey: "338",
        value: this.isNullOrUndefined(this.dfas338)
          ? ""
          : `${this.dfas338} ${this.getUnit("338")}`
      },
      {
        jsonKey: "332",
        value: this.isNullOrUndefined(this.dfas332)
          ? ""
          : `${this.dfas332} ${this.getUnit("332")}`
      },
      //mod FNSI 外結バッグ69 房 start
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "335",
        value: this.isNullOrUndefined(this.dfas335)
          ? ""
          : `${this.dfas335} ${this.getUnit("335")}`
      },
      // FNSI-add 装置設定画面表示の修正 徐 end
      //mod FNSI 外結バッグ69 房 end
      {
        jsonKey: "373",
        value: this.isNullOrUndefined(this.dfas373)
          ? ""
          : `${this.dfas373} ${this.getUnit("373")}`
      },
      {
        jsonKey: "374",
        value: this.isNullOrUndefined(this.dfas374)
          ? ""
          : `${this.dfas374} ${this.getUnit("374")}`
      },
      {
        jsonKey: "377",
        value: this.isNullOrUndefined(this.dfas377)
          ? ""
          : this.getAfterConversionValue("377", this.dfas377)
      },
      {
        jsonKey: "270",
        value: this.isNullOrUndefined(this.dfas270)
          ? ""
          : this.getAfterConversionValue("270", this.dfas270)
      },
      {
        jsonKey: "376",
        value: this.isNullOrUndefined(this.dfas376)
          ? ""
          : `${this.dfas376} ${this.getUnit("376")}`
      },
      {
        jsonKey: "378",
        value: this.isNullOrUndefined(this.dfas378)
          ? ""
          : this.getAfterConversionValue("378", this.dfas378)
      }
    ];
  }
}
