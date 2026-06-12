import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class MasterJouhou extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    // FNSI-add 装置設定画面表示の修正 徐 start
    masterJouhou164,
    masterJouhou165,
    masterJouhou166,
    masterJouhou167,
    masterJouhou170,
    masterJouhou173,
    masterJouhou176,
    masterJouhou390,
    masterJouhou393,
    masterJouhou467,
    masterJouhou188,
    masterJouhou189,
    masterJouhou187
    // masterJouhou467,
    // masterJouhou287,
    // masterJouhou164,
    // masterJouhou165,
    // masterJouhou166,
    // masterJouhou187,
    // masterJouhou188,
    // masterJouhou189,
    // masterJouhou167,
    // masterJouhou170,
    // masterJouhou390,
    // masterJouhou393,
    // masterJouhou173,
    // masterJouhou176
    // FNSI-add 装置設定画面表示の修正 徐 end
  ) {
    super(receiveDate, treatClass);
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.masterJouhou164 = masterJouhou164;
    this.masterJouhou165 = masterJouhou165;
    this.masterJouhou166 = masterJouhou166;
    this.masterJouhou167 = masterJouhou167;
    this.masterJouhou170 = masterJouhou170;
    this.masterJouhou173 = masterJouhou173;
    this.masterJouhou176 = masterJouhou176;
    this.masterJouhou390 = masterJouhou390;
    this.masterJouhou393 = masterJouhou393;
    this.masterJouhou467 = masterJouhou467;
    this.masterJouhou188 = masterJouhou188;
    this.masterJouhou189 = masterJouhou189;
    this.masterJouhou187 = masterJouhou187;
    // this.masterJouhou467 = masterJouhou467;
    // this.masterJouhou287 = masterJouhou287;
    // this.masterJouhou164 = masterJouhou164;
    // this.masterJouhou165 = masterJouhou165;
    // this.masterJouhou166 = masterJouhou166;
    // this.masterJouhou187 = masterJouhou187;
    // this.masterJouhou188 = masterJouhou188;
    // this.masterJouhou189 = masterJouhou189;
    // this.masterJouhou167 = masterJouhou167;
    // this.masterJouhou170 = masterJouhou170;
    // this.masterJouhou390 = masterJouhou390;
    // this.masterJouhou393 = masterJouhou393;
    // this.masterJouhou173 = masterJouhou173;
    // this.masterJouhou176 = masterJouhou176;
    // FNSI-add 装置設定画面表示の修正 徐 end
  }

  /**
   * 装置設定のマスタ情報アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "164",
        value: this.isNullOrUndefined(this.masterJouhou164)
          ? ""
          : `${this.masterJouhou164} ${this.getUnit("164")}`
      },
      {
        jsonKey: "165",
        value: this.isNullOrUndefined(this.masterJouhou165)
          ? ""
          : `${this.masterJouhou165} ${this.getUnit("165")}`
      },
      {
        jsonKey: "166",
        value: this.isNullOrUndefined(this.masterJouhou166)
          ? ""
          : `${this.masterJouhou166} ${this.getUnit("166")}`
      },
      {
        jsonKey: "167",
        value: this.isNullOrUndefined(this.masterJouhou167)
          ? ""
          : `${this.masterJouhou167} ${this.getUnit("167")}`
      },
      {
        jsonKey: "170",
        value: this.isNullOrUndefined(this.masterJouhou170)
          ? ""
          : `${this.masterJouhou170} ${this.getUnit("170")}`
      },
      {
        jsonKey: "173",
        value: this.isNullOrUndefined(this.masterJouhou173)
          ? ""
          : `${this.masterJouhou173} ${this.getUnit("173")}`
      },
      {
        jsonKey: "176",
        value: this.isNullOrUndefined(this.masterJouhou176)
          ? ""
          : `${this.masterJouhou176} ${this.getUnit("176")}`
      },
      {
        jsonKey: "390",
        value: this.isNullOrUndefined(this.masterJouhou390)
          ? ""
          : `${this.masterJouhou390} ${this.getUnit("390")}`
      },
      {
        jsonKey: "393",
        value: this.isNullOrUndefined(this.masterJouhou393)
          ? ""
          : `${this.masterJouhou393} ${this.getUnit("393")}`
      },
      {
        jsonKey: "467",
        value: this.isNullOrUndefined(this.masterJouhou467)
          ? ""
          : this.masterJouhou467
      },
      {
        jsonKey: "188",
        value: this.isNullOrUndefined(this.masterJouhou188)
          ? ""
          : `${this.masterJouhou188} ${this.getUnit("188")}`
      },
      {
        jsonKey: "189",
        value: this.isNullOrUndefined(this.masterJouhou189)
          ? ""
          : `${this.masterJouhou189} ${this.getUnit("189")}`
      },
      {
        jsonKey: "187",
        value: this.isNullOrUndefined(this.masterJouhou187)
          ? ""
          : `${this.masterJouhou187} ${this.getUnit("187")}`
      }
      // {
      //   jsonKey: "467",
      //   value: this.isNullOrUndefined(this.masterJouhou467)
      //     ? ""
      //     : this.masterJouhou467
      // },
      // {
      //   jsonKey: "287",
      //   value: this.isNullOrUndefined(this.masterJouhou287)
      //     ? ""
      //     : this.masterJouhou287
      // },
      // {
      //   jsonKey: "164",
      //   value: this.isNullOrUndefined(this.masterJouhou164)
      //     ? ""
      //     : `${this.masterJouhou164} ${this.getUnit("164")}`
      // },
      // {
      //   jsonKey: "165",
      //   value: this.isNullOrUndefined(this.masterJouhou165)
      //     ? ""
      //     : `${this.masterJouhou165} ${this.getUnit("165")}`
      // },
      // {
      //   jsonKey: "166",
      //   value: this.isNullOrUndefined(this.masterJouhou166)
      //     ? ""
      //     : `${this.masterJouhou166} ${this.getUnit("166")}`
      // },
      // {
      //   jsonKey: "187",
      //   value: this.isNullOrUndefined(this.masterJouhou187)
      //     ? ""
      //     : `${this.masterJouhou187} ${this.getUnit("187")}`
      // },
      // {
      //   jsonKey: "188",
      //   value: this.isNullOrUndefined(this.masterJouhou188)
      //     ? ""
      //     : `${this.masterJouhou188} ${this.getUnit("188")}`
      // },
      // {
      //   jsonKey: "189",
      //   value: this.isNullOrUndefined(this.masterJouhou189)
      //     ? ""
      //     : `${this.masterJouhou189} ${this.getUnit("189")}`
      // },
      // {
      //   jsonKey: "167",
      //   value: this.isNullOrUndefined(this.masterJouhou167)
      //     ? ""
      //     : `${this.masterJouhou167} ${this.getUnit("167")}`
      // },
      // {
      //   jsonKey: "170",
      //   value: this.isNullOrUndefined(this.masterJouhou170)
      //     ? ""
      //     : `${this.masterJouhou170} ${this.getUnit("170")}`
      // },
      // {
      //   jsonKey: "390",
      //   value: this.isNullOrUndefined(this.masterJouhou390)
      //     ? ""
      //     : `${this.masterJouhou390} ${this.getUnit("390")}`
      // },
      // {
      //   jsonKey: "393",
      //   value: this.isNullOrUndefined(this.masterJouhou393)
      //     ? ""
      //     : `${this.masterJouhou393} ${this.getUnit("393")}`
      // },
      // {
      //   jsonKey: "173",
      //   value: this.isNullOrUndefined(this.masterJouhou173)
      //     ? ""
      //     : `${this.masterJouhou173} ${this.getUnit("173")}`
      // },
      // {
      //   jsonKey: "176",
      //   value: this.isNullOrUndefined(this.masterJouhou176)
      //     ? ""
      //     : `${this.masterJouhou176} ${this.getUnit("176")}`
      // }
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }
}
