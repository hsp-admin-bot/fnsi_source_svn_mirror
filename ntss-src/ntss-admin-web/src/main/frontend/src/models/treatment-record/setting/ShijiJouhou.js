import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class ShijiJouhou extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    shijiJouhou15,
    shijiJouhou14,
    shijiJouhou41,
    shijiJouhou43,
    shijiJouhou28,
    shijiJouhou23,
    shijiJouhou27,
    shijiJouhou26,
    shijiJouhou388,
    shijiJouhou382,
    shijiJouhou380,
    shijiJouhou381,
    shijiJouhou29,  // IP使用選択
    shijiJouhou31,  // IPスタート
    shijiJouhou32,  // IPワンショットスタート
    shijiJouhou33,  // IPワンショット量
    shijiJouhou30,  // IP速度
    shijiJouhou180, // IP速度最大値
    shijiJouhou34,
    shijiJouhou35,
    shijiJouhou36,
    shijiJouhou37
  ) {
    super(receiveDate, treatClass);
    this.shijiJouhou15 = shijiJouhou15;
    this.shijiJouhou14 = shijiJouhou14;
    this.shijiJouhou41 = shijiJouhou41;
    this.shijiJouhou43 = shijiJouhou43;
    this.shijiJouhou28 = shijiJouhou28;
    this.shijiJouhou23 = shijiJouhou23;
    this.shijiJouhou27 = shijiJouhou27;
    this.shijiJouhou26 = shijiJouhou26;
    this.shijiJouhou388 = shijiJouhou388;
    this.shijiJouhou382 = shijiJouhou382;
    this.shijiJouhou380 = shijiJouhou380;
    this.shijiJouhou381 = shijiJouhou381;
    this.shijiJouhou29 = shijiJouhou29;
    this.shijiJouhou31 = shijiJouhou31;
    this.shijiJouhou32 = shijiJouhou32;
    this.shijiJouhou33 = shijiJouhou33;
    this.shijiJouhou30 = shijiJouhou30;
    this.shijiJouhou180 = shijiJouhou180;
    this.shijiJouhou34 = shijiJouhou34;
    this.shijiJouhou35 = shijiJouhou35;
    this.shijiJouhou36 = shijiJouhou36;
    this.shijiJouhou37 = shijiJouhou37;
  }

  /**
   * 装置設定の指示情報アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "15",
        value: this.isNullOrUndefined(this.shijiJouhou15)
          ? ""
          : this.getAfterConversionValue("15", this.shijiJouhou15)
      },
      {
        jsonKey: "14",
        value: this.isNullOrUndefined(this.shijiJouhou14)
          ? ""
          : `${this.shijiJouhou14} ${this.getUnit("14")}`
      },
      {
        jsonKey: "41",
        value: this.isNullOrUndefined(this.shijiJouhou41)
          ? ""
          : `${this.shijiJouhou41} ${this.getUnit("41")}`
      },
      {
        jsonKey: "43",
        value: this.isNullOrUndefined(this.shijiJouhou43)
          ? ""
          : `${this.shijiJouhou43} ${this.getUnit("43")}`
      },
      {
        jsonKey: "28",
        value: this.isNullOrUndefined(this.shijiJouhou28)
          ? ""
          : `${this.shijiJouhou28} ${this.getUnit("28")}`
      },
      {
        jsonKey: "23",
        value: this.isNullOrUndefined(this.shijiJouhou23)
          ? ""
          : this.getAfterConversionValue("23", this.shijiJouhou23)
      },
      {
        jsonKey: "27",
        value: this.isNullOrUndefined(this.shijiJouhou27)
          ? ""
          : `${this.shijiJouhou27} ${this.getUnit("27")}`
      },
      {
        jsonKey: "26",
        value: this.isNullOrUndefined(this.shijiJouhou26)
          ? ""
          : `${this.shijiJouhou26} ${this.getUnit("26")}`
      },
      {
        jsonKey: "388",
        value: this.isNullOrUndefined(this.shijiJouhou388)
          ? ""
          : this.getAfterConversionValue("388", this.shijiJouhou388)
      },
      {
        jsonKey: "382",
        value: this.isNullOrUndefined(this.shijiJouhou382)
          ? ""
          : `${this.shijiJouhou382} ${this.getUnit("382")}`
      },
      {
        jsonKey: "380",
        value: this.isNullOrUndefined(this.shijiJouhou380)
          ? ""
          : `${this.shijiJouhou380} ${this.getUnit("380")}`
      },
      {
        jsonKey: "381",
        value: this.isNullOrUndefined(this.shijiJouhou381)
          ? ""
          : `${this.shijiJouhou381} ${this.getUnit("381")}`
      },
      // IP使用選択
      {
        jsonKey: "29",
        value: this.isNullOrUndefined(this.shijiJouhou29)
          ? ""
          : this.getAfterConversionValue("29", this.shijiJouhou29)
      },
      // IPスタート
      {
        jsonKey: "31",
        value: this.isNullOrUndefined(this.shijiJouhou31)
          ? ""
          : this.getAfterConversionValue("31", this.shijiJouhou31)
      },
      // IP速度
      {
        jsonKey: "30",
        value: this.isNullOrUndefined(this.shijiJouhou30)
          ? ""
          : `${this.shijiJouhou30} ${this.getUnit("30")}`
      },
      // IP速度最大値
      {
        jsonKey: "180",
        value: this.isNullOrUndefined(this.shijiJouhou180)
          ? ""
          : `${this.shijiJouhou180} ${this.getUnit("180")}`
      },
      // IPワンショットスタート
      {
        jsonKey: "32",
        value: this.isNullOrUndefined(this.shijiJouhou32)
          ? ""
          : this.getAfterConversionValue("32", this.shijiJouhou32)
      },
      // IPワンショット量
      {
        jsonKey: "33",
        value: this.isNullOrUndefined(this.shijiJouhou33)
          ? ""
          : `${this.shijiJouhou33} ${this.getUnit("33")}`
      },
      {
        jsonKey: "34",
        value: this.isNullOrUndefined(this.shijiJouhou34)
          ? ""
          : this.getAfterConversionValue("34", this.shijiJouhou34)
      },
      {
        jsonKey: "35",
        value: this.isNullOrUndefined(this.shijiJouhou35)
          ? ""
          : `${this.shijiJouhou35} ${this.getUnit("35")}`
      },
      {
        jsonKey: "36",
        value: this.isNullOrUndefined(this.shijiJouhou36)
          ? ""
          : this.getAfterConversionValue("36", this.shijiJouhou36)
      },
      {
        jsonKey: "37",
        value: this.isNullOrUndefined(this.shijiJouhou37)
          ? ""
          : `${this.shijiJouhou37} ${this.getUnit("37")}`
      }
    ];
  }
}
