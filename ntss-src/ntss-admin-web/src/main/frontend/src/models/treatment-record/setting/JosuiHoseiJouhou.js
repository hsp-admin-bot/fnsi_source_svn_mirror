import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

/**
 * 除水補正情報のmodelクラス
 * - ord_treat_condition.treat_conditionの以下項目を保持します
 * - ～名と書かれている項目：String、それ以外：Number
 *  "42": 補正値の合計,
 *  "45": 除水補正項目名１,
 *  "53": 除水補正値１,
 *  "54": 除水補正項目名２,
 *  "62": 除水補正値２,
 *  "63": 除水補正項目名３,
 *  "71": 除水補正値３,
 *  "72": 除水補正項目名４,
 *  "80": 除水補正値４,
 *  "81": 除水補正項目名５,
 *  "89": 除水補正値５
 */
export class JosuiHoseiJouhou extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    // FNSI-add 装置設定画面表示の修正 徐 start
    josuiHoseiJouhou42,
    josuiHoseiJouhou45,
    josuiHoseiJouhou53,
    josuiHoseiJouhou54,
    josuiHoseiJouhou62,
    josuiHoseiJouhou63,
    josuiHoseiJouhou71,
    josuiHoseiJouhou72,
    josuiHoseiJouhou80,
    josuiHoseiJouhou81,
    josuiHoseiJouhou89
    // josuiHoseiJouhou44,
    // josuiHoseiJouhou42,
    // josuiHoseiJouhou45,
    // josuiHoseiJouhou53,
    // josuiHoseiJouhou54,
    // josuiHoseiJouhou62,
    // josuiHoseiJouhou63,
    // josuiHoseiJouhou71,
    // josuiHoseiJouhou72,
    // josuiHoseiJouhou80,
    // josuiHoseiJouhou81,
    // josuiHoseiJouhou89
    // FNSI-add 装置設定画面表示の修正 徐 end
  ) {
    super(receiveDate, treatClass);
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.josuiHoseiJouhou42 = josuiHoseiJouhou42;
    this.josuiHoseiJouhou45 = josuiHoseiJouhou45;
    this.josuiHoseiJouhou53 = josuiHoseiJouhou53;
    this.josuiHoseiJouhou54 = josuiHoseiJouhou54;
    this.josuiHoseiJouhou62 = josuiHoseiJouhou62;
    this.josuiHoseiJouhou63 = josuiHoseiJouhou63;
    this.josuiHoseiJouhou71 = josuiHoseiJouhou71;
    this.josuiHoseiJouhou72 = josuiHoseiJouhou72;
    this.josuiHoseiJouhou80 = josuiHoseiJouhou80;
    this.josuiHoseiJouhou81 = josuiHoseiJouhou81;
    this.josuiHoseiJouhou89 = josuiHoseiJouhou89;
    // this.josuiHoseiJouhou44 = josuiHoseiJouhou44;
    // this.josuiHoseiJouhou42 = josuiHoseiJouhou42;
    // this.josuiHoseiJouhou45 = josuiHoseiJouhou45;
    // this.josuiHoseiJouhou53 = josuiHoseiJouhou53;
    // this.josuiHoseiJouhou54 = josuiHoseiJouhou54;
    // this.josuiHoseiJouhou62 = josuiHoseiJouhou62;
    // this.josuiHoseiJouhou63 = josuiHoseiJouhou63;
    // this.josuiHoseiJouhou71 = josuiHoseiJouhou71;
    // this.josuiHoseiJouhou72 = josuiHoseiJouhou72;
    // this.josuiHoseiJouhou80 = josuiHoseiJouhou80;
    // this.josuiHoseiJouhou81 = josuiHoseiJouhou81;
    // this.josuiHoseiJouhou89 = josuiHoseiJouhou89;
    // FNSI-add 装置設定画面表示の修正 徐 end
  }

  /**
   * 装置設定の除水補正情報アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "42",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou42)
          ? ""
          : `${this.josuiHoseiJouhou42} ${this.getUnit("42")}`
      },
      {
        jsonKey: "45",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou45)
          ? ""
          : this.josuiHoseiJouhou45
      },
      {
        jsonKey: "53",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou53)
          ? ""
          : `${this.josuiHoseiJouhou53} ${this.getUnit("53")}`
      },
      {
        jsonKey: "54",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou54)
          ? ""
          : this.josuiHoseiJouhou54
      },
      {
        jsonKey: "62",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou62)
          ? ""
          : `${this.josuiHoseiJouhou62} ${this.getUnit("62")}`
      },
      {
        jsonKey: "63",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou63)
          ? ""
          : this.josuiHoseiJouhou63
      },
      {
        jsonKey: "71",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou71)
          ? ""
          : `${this.josuiHoseiJouhou71} ${this.getUnit("71")}`
      },
      {
        jsonKey: "72",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou72)
          ? ""
          : this.josuiHoseiJouhou72
      },
      {
        jsonKey: "80",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou80)
          ? ""
          : `${this.josuiHoseiJouhou80} ${this.getUnit("80")}`
      },
      {
        jsonKey: "81",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou81)
          ? ""
          : this.josuiHoseiJouhou81
      },
      {
        jsonKey: "89",
        value: this.isNullOrUndefined(this.josuiHoseiJouhou89)
          ? ""
          : `${this.josuiHoseiJouhou89} ${this.getUnit("89")}`
      }
      // {
      //   jsonKey: "44",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou44)
      //     ? ""
      //     : `${this.josuiHoseiJouhou44} ${this.getUnit("44")}`
      // },
      // {
      //   jsonKey: "42",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou42)
      //     ? ""
      //     : `${this.josuiHoseiJouhou42} ${this.getUnit("42")}`
      // },
      // {
      //   jsonKey: "45",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou45)
      //     ? ""
      //     : this.josuiHoseiJouhou45
      // },
      // {
      //   jsonKey: "53",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou53)
      //     ? ""
      //     : `${this.josuiHoseiJouhou53} ${this.getUnit("53")}`
      // },
      // {
      //   jsonKey: "54",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou54)
      //     ? ""
      //     : this.josuiHoseiJouhou54
      // },
      // {
      //   jsonKey: "62",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou62)
      //     ? ""
      //     : `${this.josuiHoseiJouhou62} ${this.getUnit("62")}`
      // },
      // {
      //   jsonKey: "63",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou63)
      //     ? ""
      //     : this.josuiHoseiJouhou63
      // },
      // {
      //   jsonKey: "71",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou71)
      //     ? ""
      //     : `${this.josuiHoseiJouhou71} ${this.getUnit("71")}`
      // },
      // {
      //   jsonKey: "72",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou72)
      //     ? ""
      //     : this.josuiHoseiJouhou72
      // },
      // {
      //   jsonKey: "80",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou80)
      //     ? ""
      //     : `${this.josuiHoseiJouhou80} ${this.getUnit("80")}`
      // },
      // {
      //   jsonKey: "81",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou81)
      //     ? ""
      //     : this.josuiHoseiJouhou81
      // },
      // {
      //   jsonKey: "89",
      //   value: this.isNullOrUndefined(this.josuiHoseiJouhou89)
      //     ? ""
      //     : `${this.josuiHoseiJouhou89} ${this.getUnit("89")}`
      // }
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }
  
  /**
   * 装置設定の除水補正情報 モーダルに表示するデータ
   * - ord_main.rst_off_water_info のjson形式に変換する
   */
  getDataForModal() {
    const getValue = (value) => this.isNullOrUndefined(value) ? "" : value;
    return {
      "name_1": getValue(this.josuiHoseiJouhou45),
      "name_2": getValue(this.josuiHoseiJouhou54),
      "name_3": getValue(this.josuiHoseiJouhou63),
      "name_4": getValue(this.josuiHoseiJouhou72),
      "name_5": getValue(this.josuiHoseiJouhou81),
      "weight_1": getValue(this.josuiHoseiJouhou53),
      "weight_2": getValue(this.josuiHoseiJouhou62),
      "weight_3": getValue(this.josuiHoseiJouhou71),
      "weight_4": getValue(this.josuiHoseiJouhou80),
      "weight_5": getValue(this.josuiHoseiJouhou89)
    };
  }
}
