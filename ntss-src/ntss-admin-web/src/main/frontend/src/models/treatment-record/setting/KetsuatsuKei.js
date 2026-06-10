import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class KetsuatsuKei extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    ketsuatsuKei211,
    ketsuatsuKei212,
    ketsuatsuKei213,
    ketsuatsuKei214,
    ketsuatsuKei215,
    ketsuatsuKei216,
    ketsuatsuKei217,
    ketsuatsuKei218,
    // FNSI-add 装置設定画面表示の修正 徐 start
    ketsuatsuKei219,
    ketsuatsuKei227,
    ketsuatsuKei220,
    ketsuatsuKei228,
    ketsuatsuKei221,
    ketsuatsuKei229,
    ketsuatsuKei222,
    ketsuatsuKei230,
    ketsuatsuKei223,
    ketsuatsuKei231,
    ketsuatsuKei224,
    ketsuatsuKei232,
    ketsuatsuKei225,
    ketsuatsuKei233,
    ketsuatsuKei226,
    ketsuatsuKei234,
    // ketsuatsuKei227,
    // ketsuatsuKei219,
    // ketsuatsuKei228,
    // ketsuatsuKei220,
    // ketsuatsuKei229,
    // ketsuatsuKei221,
    // ketsuatsuKei230,
    // ketsuatsuKei222,
    // ketsuatsuKei231,
    // ketsuatsuKei223,
    // ketsuatsuKei232,
    // ketsuatsuKei224,
    // ketsuatsuKei233,
    // ketsuatsuKei225,
    // ketsuatsuKei234,
    // ketsuatsuKei226,
    // FNSI-add 装置設定画面表示の修正 徐 end
    ketsuatsuKei191,
    ketsuatsuKei190,
    ketsuatsuKei192,
    ketsuatsuKei193,
    ketsuatsuKei195,
    ketsuatsuKei239,
    ketsuatsuKei194,
    ketsuatsuKei235,
    ketsuatsuKei236,
    ketsuatsuKei237,
    ketsuatsuKei238
  ) {
    super(receiveDate, treatClass);
    this.ketsuatsuKei211 = ketsuatsuKei211;
    this.ketsuatsuKei212 = ketsuatsuKei212;
    this.ketsuatsuKei213 = ketsuatsuKei213;
    this.ketsuatsuKei214 = ketsuatsuKei214;
    this.ketsuatsuKei215 = ketsuatsuKei215;
    this.ketsuatsuKei216 = ketsuatsuKei216;
    this.ketsuatsuKei217 = ketsuatsuKei217;
    this.ketsuatsuKei218 = ketsuatsuKei218;
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.ketsuatsuKei219 = ketsuatsuKei219;
    this.ketsuatsuKei227 = ketsuatsuKei227;
    this.ketsuatsuKei220 = ketsuatsuKei220;
    this.ketsuatsuKei228 = ketsuatsuKei228;
    this.ketsuatsuKei221 = ketsuatsuKei221;
    this.ketsuatsuKei229 = ketsuatsuKei229;
    this.ketsuatsuKei222 = ketsuatsuKei222;
    this.ketsuatsuKei230 = ketsuatsuKei230;
    this.ketsuatsuKei223 = ketsuatsuKei223;
    this.ketsuatsuKei231 = ketsuatsuKei231;
    this.ketsuatsuKei224 = ketsuatsuKei224;
    this.ketsuatsuKei232 = ketsuatsuKei232;
    this.ketsuatsuKei225 = ketsuatsuKei225;
    this.ketsuatsuKei233 = ketsuatsuKei233;
    this.ketsuatsuKei226 = ketsuatsuKei226;
    this.ketsuatsuKei234 = ketsuatsuKei234;
    // this.ketsuatsuKei227 = ketsuatsuKei227;
    // this.ketsuatsuKei219 = ketsuatsuKei219;
    // this.ketsuatsuKei228 = ketsuatsuKei228;
    // this.ketsuatsuKei220 = ketsuatsuKei220;
    // this.ketsuatsuKei229 = ketsuatsuKei229;
    // this.ketsuatsuKei221 = ketsuatsuKei221;
    // this.ketsuatsuKei230 = ketsuatsuKei230;
    // this.ketsuatsuKei222 = ketsuatsuKei222;
    // this.ketsuatsuKei231 = ketsuatsuKei231;
    // this.ketsuatsuKei223 = ketsuatsuKei223;
    // this.ketsuatsuKei232 = ketsuatsuKei232;
    // this.ketsuatsuKei224 = ketsuatsuKei224;
    // this.ketsuatsuKei233 = ketsuatsuKei233;
    // this.ketsuatsuKei225 = ketsuatsuKei225;
    // this.ketsuatsuKei234 = ketsuatsuKei234;
    // this.ketsuatsuKei226 = ketsuatsuKei226;
    // FNSI-add 装置設定画面表示の修正 徐 end
    this.ketsuatsuKei191 = ketsuatsuKei191;
    this.ketsuatsuKei190 = ketsuatsuKei190;
    this.ketsuatsuKei192 = ketsuatsuKei192;
    this.ketsuatsuKei193 = ketsuatsuKei193;
    this.ketsuatsuKei195 = ketsuatsuKei195;
    this.ketsuatsuKei239 = ketsuatsuKei239;
    this.ketsuatsuKei194 = ketsuatsuKei194;
    this.ketsuatsuKei235 = ketsuatsuKei235;
    this.ketsuatsuKei236 = ketsuatsuKei236;
    this.ketsuatsuKei237 = ketsuatsuKei237;
    this.ketsuatsuKei238 = ketsuatsuKei238;
  }

  /**
   * 装置設定の血圧計アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "211",
        value: this.isNullOrUndefined(this.ketsuatsuKei211)
          ? ""
          : `${this.ketsuatsuKei211} ${this.getUnit("211")}`
      },
      {
        jsonKey: "212",
        value: this.isNullOrUndefined(this.ketsuatsuKei212)
          ? ""
          : `${this.ketsuatsuKei212} ${this.getUnit("212")}`
      },
      {
        jsonKey: "213",
        value: this.isNullOrUndefined(this.ketsuatsuKei213)
          ? ""
          : `${this.ketsuatsuKei213} ${this.getUnit("213")}`
      },
      {
        jsonKey: "214",
        value: this.isNullOrUndefined(this.ketsuatsuKei214)
          ? ""
          : `${this.ketsuatsuKei214} ${this.getUnit("214")}`
      },
      {
        jsonKey: "215",
        value: this.isNullOrUndefined(this.ketsuatsuKei215)
          ? ""
          : `${this.ketsuatsuKei215} ${this.getUnit("215")}`
      },
      {
        jsonKey: "216",
        value: this.isNullOrUndefined(this.ketsuatsuKei216)
          ? ""
          : `${this.ketsuatsuKei216} ${this.getUnit("216")}`
      },
      {
        jsonKey: "217",
        value: this.isNullOrUndefined(this.ketsuatsuKei217)
          ? ""
          : `${this.ketsuatsuKei217} ${this.getUnit("217")}`
      },
      {
        jsonKey: "218",
        value: this.isNullOrUndefined(this.ketsuatsuKei218)
          ? ""
          : `${this.ketsuatsuKei218} ${this.getUnit("218")}`
      },
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "219",
        value: this.isNullOrUndefined(this.ketsuatsuKei219)
          ? ""
          : this.getAfterConversionValue("219", this.ketsuatsuKei219)
      },
      {
        jsonKey: "227",
        value: this.isNullOrUndefined(this.ketsuatsuKei227)
          ? ""
          : `${this.ketsuatsuKei227} ${this.getUnit("227")}`
      },
      {
        jsonKey: "220",
        value: this.isNullOrUndefined(this.ketsuatsuKei220)
          ? ""
          : this.getAfterConversionValue("220", this.ketsuatsuKei220)
      },
      {
        jsonKey: "228",
        value: this.isNullOrUndefined(this.ketsuatsuKei228)
          ? ""
          : `${this.ketsuatsuKei228} ${this.getUnit("228")}`
      },
      {
        jsonKey: "221",
        value: this.isNullOrUndefined(this.ketsuatsuKei221)
          ? ""
          : this.getAfterConversionValue("221", this.ketsuatsuKei221)
      },
      {
        jsonKey: "229",
        value: this.isNullOrUndefined(this.ketsuatsuKei229)
          ? ""
          : `${this.ketsuatsuKei229} ${this.getUnit("229")}`
      },
      {
        jsonKey: "222",
        value: this.isNullOrUndefined(this.ketsuatsuKei222)
          ? ""
          : this.getAfterConversionValue("222", this.ketsuatsuKei222)
      },
      {
        jsonKey: "230",
        value: this.isNullOrUndefined(this.ketsuatsuKei230)
          ? ""
          : `${this.ketsuatsuKei230} ${this.getUnit("230")}`
      },
      {
        jsonKey: "223",
        value: this.isNullOrUndefined(this.ketsuatsuKei223)
          ? ""
          : this.getAfterConversionValue("223", this.ketsuatsuKei223)
      },
      {
        jsonKey: "231",
        value: this.isNullOrUndefined(this.ketsuatsuKei231)
          ? ""
          : `${this.ketsuatsuKei231} ${this.getUnit("231")}`
      },
      {
        jsonKey: "224",
        value: this.isNullOrUndefined(this.ketsuatsuKei224)
          ? ""
          : this.getAfterConversionValue("224", this.ketsuatsuKei224)
      },
      {
        jsonKey: "232",
        value: this.isNullOrUndefined(this.ketsuatsuKei232)
          ? ""
          : `${this.ketsuatsuKei232} ${this.getUnit("232")}`
      },
      {
        jsonKey: "225",
        value: this.isNullOrUndefined(this.ketsuatsuKei225)
          ? ""
          : this.getAfterConversionValue("225", this.ketsuatsuKei225)
      },
      {
        jsonKey: "233",
        value: this.isNullOrUndefined(this.ketsuatsuKei233)
          ? ""
          : `${this.ketsuatsuKei233} ${this.getUnit("233")}`
      },
      {
        jsonKey: "226",
        value: this.isNullOrUndefined(this.ketsuatsuKei226)
          ? ""
          : this.getAfterConversionValue("226", this.ketsuatsuKei226)
      },
      {
        jsonKey: "234",
        value: this.isNullOrUndefined(this.ketsuatsuKei234)
          ? ""
          : `${this.ketsuatsuKei234} ${this.getUnit("234")}`
      },
      // {
      //   jsonKey: "227",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei227)
      //     ? ""
      //     : `${this.ketsuatsuKei227} ${this.getUnit("227")}`
      // },
      // {
      //   jsonKey: "219",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei219)
      //     ? ""
      //     : this.getAfterConversionValue("219", this.ketsuatsuKei219)
      // },
      // {
      //   jsonKey: "228",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei228)
      //     ? ""
      //     : `${this.ketsuatsuKei228} ${this.getUnit("228")}`
      // },
      // {
      //   jsonKey: "220",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei220)
      //     ? ""
      //     : this.getAfterConversionValue("220", this.ketsuatsuKei220)
      // },
      // {
      //   jsonKey: "229",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei229)
      //     ? ""
      //     : `${this.ketsuatsuKei229} ${this.getUnit("229")}`
      // },
      // {
      //   jsonKey: "221",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei221)
      //     ? ""
      //     : this.getAfterConversionValue("221", this.ketsuatsuKei221)
      // },
      // {
      //   jsonKey: "230",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei230)
      //     ? ""
      //     : `${this.ketsuatsuKei230} ${this.getUnit("230")}`
      // },
      // {
      //   jsonKey: "222",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei222)
      //     ? ""
      //     : this.getAfterConversionValue("222", this.ketsuatsuKei222)
      // },
      // {
      //   jsonKey: "231",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei231)
      //     ? ""
      //     : `${this.ketsuatsuKei231} ${this.getUnit("231")}`
      // },
      // {
      //   jsonKey: "223",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei223)
      //     ? ""
      //     : this.getAfterConversionValue("223", this.ketsuatsuKei223)
      // },
      // {
      //   jsonKey: "232",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei232)
      //     ? ""
      //     : `${this.ketsuatsuKei232} ${this.getUnit("232")}`
      // },
      // {
      //   jsonKey: "224",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei224)
      //     ? ""
      //     : this.getAfterConversionValue("224", this.ketsuatsuKei224)
      // },
      // {
      //   jsonKey: "233",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei233)
      //     ? ""
      //     : `${this.ketsuatsuKei233} ${this.getUnit("233")}`
      // },
      // {
      //   jsonKey: "225",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei225)
      //     ? ""
      //     : this.getAfterConversionValue("225", this.ketsuatsuKei225)
      // },
      // {
      //   jsonKey: "234",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei234)
      //     ? ""
      //     : `${this.ketsuatsuKei234} ${this.getUnit("234")}`
      // },
      // {
      //   jsonKey: "226",
      //   value: this.isNullOrUndefined(this.ketsuatsuKei226)
      //     ? ""
      //     : this.getAfterConversionValue("226", this.ketsuatsuKei226)
      // },
      // FNSI-add 装置設定画面表示の修正 徐 end
      {
        jsonKey: "191",
        value: this.isNullOrUndefined(this.ketsuatsuKei191)
          ? ""
          : this.getAfterConversionValue("191", this.ketsuatsuKei191)
      },
      {
        jsonKey: "190",
        value: this.isNullOrUndefined(this.ketsuatsuKei190)
          ? ""
          : `${this.ketsuatsuKei190} ${this.getUnit("190")}`
      },
      {
        jsonKey: "192",
        value: this.isNullOrUndefined(this.ketsuatsuKei192)
          ? ""
          : `${this.ketsuatsuKei192} ${this.getUnit("192")}`
      },
      {
        jsonKey: "193",
        value: this.isNullOrUndefined(this.ketsuatsuKei193)
          ? ""
          : this.getAfterConversionValue("193", this.ketsuatsuKei193)
      },
      {
        jsonKey: "195",
        value: this.isNullOrUndefined(this.ketsuatsuKei195)
          ? ""
          //mod FNSI 不明追加 房 start
           //: this.ketsuatsuKei195
          //FNSI 7199-mod 血圧測定方法選択の転換 ljx start
          //: (this.ketsuatsuKei195 === 1 || this.ketsuatsuKei195 === 2) ? this.ketsuatsuKei195 : "不明"
          : (this.ketsuatsuKei195 === 1 || this.ketsuatsuKei195 === 2) ? this.getAfterConversionValue("195", this.ketsuatsuKei195) : "不明"
        //FNSI 7199-mod 血圧測定方法選択の転換 ljx end
        //mod FNSI 不明追加 房 end
      },
      {
        jsonKey: "239",
        value: this.isNullOrUndefined(this.ketsuatsuKei239)
          ? ""
          : this.getAfterConversionValue("239", this.ketsuatsuKei239)
      },
      {
        jsonKey: "194",
        value: this.isNullOrUndefined(this.ketsuatsuKei194)
          ? ""
          : this.getAfterConversionValue("194", this.ketsuatsuKei194)
      },
      {
        jsonKey: "235",
        value: this.isNullOrUndefined(this.ketsuatsuKei235)
          ? ""
          : `${this.ketsuatsuKei235} ${this.getUnit("235")}`
      },
      {
        jsonKey: "236",
        value: this.isNullOrUndefined(this.ketsuatsuKei236)
          ? ""
          : `${this.ketsuatsuKei236} ${this.getUnit("236")}`
      },
      {
        jsonKey: "237",
        value: this.isNullOrUndefined(this.ketsuatsuKei237)
          ? ""
          : this.getAfterConversionValue("237", this.ketsuatsuKei237)
      },
      {
        jsonKey: "238",
        value: this.isNullOrUndefined(this.ketsuatsuKei238)
          ? ""
          : this.getAfterConversionValue("238", this.ketsuatsuKei238)
      }
    ];
  }
}
