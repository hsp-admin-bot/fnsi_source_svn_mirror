import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class TaijuuJouhou extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    // FNSI-add 装置設定画面表示の修正 徐 start
    taijuuJouhou40,
    taijuuJouhou20,
    taijuuJouhou44
    // taijuuJouhou20,
    // taijuuJouhou40,
    // taijuuJouhou285,
    // taijuuJouhou283,
    // taijuuJouhou284
    // FNSI-add 装置設定画面表示の修正 徐 end
  ) {
    super(receiveDate, treatClass);
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.taijuuJouhou40 = taijuuJouhou40;
    this.taijuuJouhou20 = taijuuJouhou20;
    this.taijuuJouhou44 = taijuuJouhou44;
    // this.taijuuJouhou20 = taijuuJouhou20;
    // this.taijuuJouhou40 = taijuuJouhou40;
    // this.taijuuJouhou285 = taijuuJouhou285;
    // this.taijuuJouhou283 = taijuuJouhou283;
    // this.taijuuJouhou284 = taijuuJouhou284;
    // FNSI-add 装置設定画面表示の修正 徐 end
  }

  /**
   * 装置設定の体重情報アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "40",
        value: this.isNullOrUndefined(this.taijuuJouhou40)
          ? ""
          : `${this.taijuuJouhou40} ${this.getUnit("40")}`
      },
      {
        jsonKey: "20",
        value: this.isNullOrUndefined(this.taijuuJouhou20)
          ? ""
          : `${this.taijuuJouhou20} ${this.getUnit("20")}`
      },
      {
        jsonKey: "44",
        value: this.isNullOrUndefined(this.taijuuJouhou44)
          ? ""
          : `${this.taijuuJouhou44} ${this.getUnit("44")}`
      }
      // {
      //   jsonKey: "20",
      //   value: this.isNullOrUndefined(this.taijuuJouhou20)
      //     ? ""
      //     : `${this.taijuuJouhou20} ${this.getUnit("20")}`
      // },
      // {
      //   jsonKey: "40",
      //   value: this.isNullOrUndefined(this.taijuuJouhou40)
      //     ? ""
      //     : `${this.taijuuJouhou40} ${this.getUnit("40")}`
      // },
      // {
      //   jsonKey: "285",
      //   value: this.isNullOrUndefined(this.taijuuJouhou285) ? "" : this.taijuuJouhou285
      // },
      // {
      //   jsonKey: "283",
      //   value: this.isNullOrUndefined(this.taijuuJouhou283) ? "" : this.taijuuJouhou283
      // },
      // {
      //   jsonKey: "284",
      //   value: this.isNullOrUndefined(this.taijuuJouhou284) ? "" : this.taijuuJouhou284
      // }
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }
}
