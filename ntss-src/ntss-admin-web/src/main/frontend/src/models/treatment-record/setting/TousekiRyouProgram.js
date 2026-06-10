import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class TousekiRyouProgram extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    tousekiRyou282,
    // FNSI-add 装置設定画面表示の修正 徐 start
    tousekiRyou284,
    tousekiRyou283,
    tousekiRyou285,
    tousekiRyou286,
    tousekiRyou287,
    // FNSI-add 装置設定画面表示の修正 徐 end
    tousekiRyou288
 ) {
    super(receiveDate, treatClass);
    this.tousekiRyou282 = tousekiRyou282;
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.tousekiRyou284 = tousekiRyou284;
    this.tousekiRyou283 = tousekiRyou283;
    this.tousekiRyou285 = tousekiRyou285;
    this.tousekiRyou286 = tousekiRyou286;
    this.tousekiRyou287 = tousekiRyou287;
    // FNSI-add 装置設定画面表示の修正 徐 end
    this.tousekiRyou288 = tousekiRyou288;
 }

  /**
   * 装置設定の透析量プログラムアコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "282",
        value: this.isNullOrUndefined(this.tousekiRyou282)
          ? ""
          : this.getAfterConversionValue("282", this.tousekiRyou282)
      },
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "284",
        value: this.isNullOrUndefined(this.tousekiRyou284)
          ? ""
          : this.tousekiRyou284
      },
      {
        jsonKey: "283",
        value: this.isNullOrUndefined(this.tousekiRyou283)
          ? "" 
          : this.tousekiRyou283
      },
      {
        jsonKey: "285",
        value: this.isNullOrUndefined(this.tousekiRyou285)
          ? ""
          : this.tousekiRyou285
      },
      
      {
        jsonKey: "286",
        value: this.isNullOrUndefined(this.tousekiRyou286)
          ? ""
          : this.tousekiRyou286
      },
      {
        jsonKey: "287",
        value: this.isNullOrUndefined(this.tousekiRyou287)
          ? ""
          : this.tousekiRyou287
      },
      // FNSI-add 装置設定画面表示の修正 徐 end
      {
        jsonKey: "288",
        value: this.isNullOrUndefined(this.tousekiRyou288)
          ? ""
          : this.tousekiRyou288
      }
    ];
  }
}
