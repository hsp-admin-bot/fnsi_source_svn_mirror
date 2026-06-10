import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class SousaHani extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    sousaHani179,
    sousaHani181,
    sousaHani38,
    sousaHani21,
    sousaHani22,
    sousaHani39,
    sousaHani182,
    sousaHani183,
    sousaHani268,
    sousaHani269,
    sousaHani24,
    sousaHani25,
    sousaHani241,
    sousaHani168,
    sousaHani169,
    sousaHani171,
    sousaHani172,
    sousaHani174,
    sousaHani175,
    sousaHani177,
    sousaHani178,
    sousaHani391,
    sousaHani392,
    sousaHani394,
    sousaHani395,
    sousaHani383,
    sousaHani389,
    sousaHani379,
    sousaHani398,
    sousaHani369,
    sousaHani90,
    sousaHani91,
    sousaHani92,
    // FNSI-add 装置設定画面表示の修正 徐 start
    sousaHani472,
    sousaHani473,
    sousaHani474,
    sousaHani475,
    // FNSI-add 装置設定画面表示の修正 徐 end
    sousaHani336,
    sousaHani337,
    sousaHani185,
    sousaHani186,
    sousaHani396,
    sousaHani397,
    sousaHani384,
    sousaHani385,
    sousaHani386,
    sousaHani387
    // FNSI-add 装置設定画面表示の修正 徐 start
    // sousaHani472,
    // sousaHani473,
    // sousaHani474,
    // sousaHani475
    // FNSI-add 装置設定画面表示の修正 徐 end
  ) {
    super(receiveDate, treatClass);
    this.sousaHani179 = sousaHani179;
    this.sousaHani181 = sousaHani181;
    this.sousaHani38 = sousaHani38;
    this.sousaHani21 = sousaHani21;
    this.sousaHani22 = sousaHani22;
    this.sousaHani39 = sousaHani39;
    this.sousaHani182 = sousaHani182;
    this.sousaHani183 = sousaHani183;
    this.sousaHani268 = sousaHani268;
    this.sousaHani269 = sousaHani269;
    this.sousaHani24 = sousaHani24;
    this.sousaHani25 = sousaHani25;
    this.sousaHani241 = sousaHani241;
    this.sousaHani168 = sousaHani168;
    this.sousaHani169 = sousaHani169;
    this.sousaHani171 = sousaHani171;
    this.sousaHani172 = sousaHani172;
    this.sousaHani174 = sousaHani174;
    this.sousaHani175 = sousaHani175;
    this.sousaHani177 = sousaHani177;
    this.sousaHani178 = sousaHani178;
    this.sousaHani391 = sousaHani391;
    this.sousaHani392 = sousaHani392;
    this.sousaHani394 = sousaHani394;
    this.sousaHani395 = sousaHani395;
    this.sousaHani383 = sousaHani383;
    this.sousaHani389 = sousaHani389;
    this.sousaHani379 = sousaHani379;
    this.sousaHani398 = sousaHani398;
    this.sousaHani369 = sousaHani369;
    this.sousaHani90 = sousaHani90;
    this.sousaHani91 = sousaHani91;
    this.sousaHani92 = sousaHani92;
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.sousaHani472 = sousaHani472;
    this.sousaHani473 = sousaHani473;
    this.sousaHani474 = sousaHani474;
    this.sousaHani475 = sousaHani475;
    // FNSI-add 装置設定画面表示の修正 徐 end
    this.sousaHani336 = sousaHani336;
    this.sousaHani337 = sousaHani337;
    this.sousaHani185 = sousaHani185;
    this.sousaHani186 = sousaHani186;
    this.sousaHani396 = sousaHani396;
    this.sousaHani397 = sousaHani397;
    this.sousaHani384 = sousaHani384;
    this.sousaHani385 = sousaHani385;
    this.sousaHani386 = sousaHani386;
    this.sousaHani387 = sousaHani387;
    // FNSI-add 装置設定画面表示の修正 徐 start
    // this.sousaHani472 = sousaHani472;
    // this.sousaHani473 = sousaHani473;
    // this.sousaHani474 = sousaHani474;
    // this.sousaHani475 = sousaHani475;
    // FNSI-add 装置設定画面表示の修正 徐 end
  }

  /**
   * 装置設定の操作範囲アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "179",
        value: this.isNullOrUndefined(this.sousaHani179)
          ? ""
          : `${this.sousaHani179} ${this.getUnit("179")}`
      },
      {
        jsonKey: "181",
        value: this.isNullOrUndefined(this.sousaHani181)
          ? ""
          : `${this.sousaHani181} ${this.getUnit("181")}`
      },
      {
        jsonKey: "38",
        value: this.isNullOrUndefined(this.sousaHani38)
          ? ""
          : this.getAfterConversionValue("38", this.sousaHani38)
      },
      {
        jsonKey: "21",
        value: this.isNullOrUndefined(this.sousaHani21)
          ? ""
          : this.getAfterConversionValue("21", this.sousaHani21)
      },
      {
        jsonKey: "22",
        value: this.isNullOrUndefined(this.sousaHani22)
          ? ""
          : this.getAfterConversionValue("22", this.sousaHani22)
      },
      {
        jsonKey: "39",
        value: this.isNullOrUndefined(this.sousaHani39)
          ? ""
          : `${this.sousaHani39} ${this.getUnit("39")}`
      },
      {
        jsonKey: "182",
        value: this.isNullOrUndefined(this.sousaHani182)
          ? ""
          : `${this.sousaHani182} ${this.getUnit("182")}`
      },
      {
        jsonKey: "183",
        value: this.isNullOrUndefined(this.sousaHani183)
          ? ""
          : `${this.sousaHani183} ${this.getUnit("183")}`
      },
      {
        jsonKey: "268",
        value: this.isNullOrUndefined(this.sousaHani268)
          ? ""
          //mod FNSI 外結バッグ69 房 start
          //mod FNSI 不明追加 房 start
          : this.sousaHani268 === 1 ? "流量設定" : this.sousaHani268 === 2 ? "比率設定" : "不明"
          //mod FNSI 不明追加 房 end
          //mod FNSI 外結バッグ69 房 end
      },
      {
        jsonKey: "269",
        value: this.isNullOrUndefined(this.sousaHani269)
          ? ""
          : this.sousaHani269
      },
      {
        jsonKey: "24",
        value: this.isNullOrUndefined(this.sousaHani24)
          ? ""
          : `${this.sousaHani24} ${this.getUnit("24")}`
      },
      {
        jsonKey: "25",
        value: this.isNullOrUndefined(this.sousaHani25)
          ? ""
          : `${this.sousaHani25} ${this.getUnit("25")}`
      },
      {
        jsonKey: "241",
        value: this.isNullOrUndefined(this.sousaHani241)
          ? ""
          : this.getAfterConversionValue("241", this.sousaHani241)
      },
      {
        jsonKey: "168",
        value: this.isNullOrUndefined(this.sousaHani168)
          ? ""
          : `${this.sousaHani168} ${this.getUnit("168")}`
      },
      {
        jsonKey: "169",
        value: this.isNullOrUndefined(this.sousaHani169)
          ? ""
          : `${this.sousaHani169} ${this.getUnit("169")}`
      },
      {
        jsonKey: "171",
        value: this.isNullOrUndefined(this.sousaHani171)
          ? ""
          : `${this.sousaHani171} ${this.getUnit("171")}`
      },
      {
        jsonKey: "172",
        value: this.isNullOrUndefined(this.sousaHani172)
          ? ""
          : `${this.sousaHani172} ${this.getUnit("172")}`
      },
      {
        jsonKey: "174",
        value: this.isNullOrUndefined(this.sousaHani174)
          ? ""
          : `${this.sousaHani174} ${this.getUnit("174")}`
      },
      {
        jsonKey: "175",
        value: this.isNullOrUndefined(this.sousaHani175)
          ? ""
          : `${this.sousaHani175} ${this.getUnit("175")}`
      },
      {
        jsonKey: "177",
        value: this.isNullOrUndefined(this.sousaHani177)
          ? ""
          : `${this.sousaHani177} ${this.getUnit("177")}`
      },
      {
        jsonKey: "178",
        value: this.isNullOrUndefined(this.sousaHani178)
          ? ""
          : `${this.sousaHani178} ${this.getUnit("178")}`
      },
      {
        jsonKey: "391",
        value: this.isNullOrUndefined(this.sousaHani391)
          ? ""
          : `${this.sousaHani391} ${this.getUnit("391")}`
      },
      {
        jsonKey: "392",
        value: this.isNullOrUndefined(this.sousaHani392)
          ? ""
          : `${this.sousaHani392} ${this.getUnit("392")}`
      },
      {
        jsonKey: "394",
        value: this.isNullOrUndefined(this.sousaHani394)
          ? ""
          : `${this.sousaHani394} ${this.getUnit("394")}`
      },
      {
        jsonKey: "395",
        value: this.isNullOrUndefined(this.sousaHani395)
          ? ""
          : `${this.sousaHani395} ${this.getUnit("395")}`
      },
      {
        jsonKey: "383",
        value: this.isNullOrUndefined(this.sousaHani383)
          ? ""
          : `${this.sousaHani383} ${this.getUnit("383")}`
      },
      {
        jsonKey: "389",
        value: this.isNullOrUndefined(this.sousaHani389)
          ? ""
          : this.getAfterConversionValue("389", this.sousaHani389)
      },
      {
        jsonKey: "379",
        value: this.isNullOrUndefined(this.sousaHani379)
          ? ""
          : `${this.sousaHani379} ${this.getUnit("379")}`
      },
      {
        jsonKey: "398",
        value: this.isNullOrUndefined(this.sousaHani398)
          ? ""
          : `${this.sousaHani398} ${this.getUnit("398")}`
      },
      {
        jsonKey: "369",
        value: this.isNullOrUndefined(this.sousaHani369)
          ? ""
          : this.getAfterConversionValue("369", this.sousaHani369)
      },
      {
        jsonKey: "90",
        value: this.isNullOrUndefined(this.sousaHani90)
          ? ""
          : `${this.sousaHani90} ${this.getUnit("90")}`
      },
      {
        jsonKey: "91",
        value: this.isNullOrUndefined(this.sousaHani91)
          ? ""
          : `${this.sousaHani91} ${this.getUnit("91")}`
      },
      {
        jsonKey: "92",
        value: this.isNullOrUndefined(this.sousaHani92)
          ? ""
          : `${this.sousaHani92} ${this.getUnit("92")}`
      },
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "472",
        value: this.isNullOrUndefined(this.sousaHani472)
          ? ""
          : `${this.sousaHani472} ${this.getUnit("472")}`
      },
      {
        jsonKey: "473",
        value: this.isNullOrUndefined(this.sousaHani473)
          ? ""
          : `${this.sousaHani473} ${this.getUnit("473")}`
      },
      {
        jsonKey: "474",
        value: this.isNullOrUndefined(this.sousaHani474)
          ? ""
          : `${this.sousaHani474} ${this.getUnit("474")}`
      },
      {
        jsonKey: "475",
        value: this.isNullOrUndefined(this.sousaHani475)
          ? ""
          : `${this.sousaHani475} ${this.getUnit("475")}`
      },
      // FNSI-add 装置設定画面表示の修正 徐 end
      {
        jsonKey: "336",
        value: this.isNullOrUndefined(this.sousaHani336)
          ? ""
          : `${this.sousaHani336} ${this.getUnit("336")}`
      },
      {
        jsonKey: "337",
        value: this.isNullOrUndefined(this.sousaHani337)
          ? ""
          : `${this.sousaHani337} ${this.getUnit("337")}`
      },
      {
        jsonKey: "185",
        value: this.isNullOrUndefined(this.sousaHani185)
          ? ""
          : `${this.sousaHani185} ${this.getUnit("185")}`
      },
      {
        jsonKey: "186",
        value: this.isNullOrUndefined(this.sousaHani186)
          ? ""
          : `${this.sousaHani186} ${this.getUnit("186")}`
      },
      {
        jsonKey: "396",
        value: this.isNullOrUndefined(this.sousaHani396)
          ? ""
          : `${this.sousaHani396} ${this.getUnit("396")}`
      },
      {
        jsonKey: "397",
        value: this.isNullOrUndefined(this.sousaHani397)
          ? ""
          : `${this.sousaHani397} ${this.getUnit("397")}`
      },
      {
        jsonKey: "384",
        value: this.isNullOrUndefined(this.sousaHani384)
          ? ""
          : this.getAfterConversionValue("384", this.sousaHani384)
      },
      {
        jsonKey: "385",
        value: this.isNullOrUndefined(this.sousaHani385)
          ? ""
          : `${this.sousaHani385} ${this.getUnit("385")}`
      },
      {
        jsonKey: "386",
        value: this.isNullOrUndefined(this.sousaHani386)
          ? ""
          : `${this.sousaHani386} ${this.getUnit("386")}`
      },
      {
        jsonKey: "387",
        value: this.isNullOrUndefined(this.sousaHani387)
          ? ""
          : `${this.sousaHani387} ${this.getUnit("387")}`
      }
      // {
      //   jsonKey: "472",
      //   value: this.isNullOrUndefined(this.sousaHani472)
      //     ? ""
      //     : `${this.sousaHani472} ${this.getUnit("472")}`
      // },
      // {
      //   jsonKey: "473",
      //   value: this.isNullOrUndefined(this.sousaHani473)
      //     ? ""
      //     : `${this.sousaHani473} ${this.getUnit("473")}`
      // },
      // {
      //   jsonKey: "474",
      //   value: this.isNullOrUndefined(this.sousaHani474)
      //     ? ""
      //     : `${this.sousaHani474} ${this.getUnit("474")}`
      // },
      // {
      //   jsonKey: "475",
      //   value: this.isNullOrUndefined(this.sousaHani475)
      //     ? ""
      //     : `${this.sousaHani475} ${this.getUnit("475")}`
      // }
    ];
  }
}
