import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class KetsuryuuRyouAndTousekiEkiRyuuRyouProgram extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    // FNSI-add 装置設定画面表示の修正 徐 start
    ryuuRyou431,
    ryuuRyou430,
    ryuuRyou429,
    ryuuRyou410,
    ryuuRyou411,
    ryuuRyou412,
    ryuuRyou413,
    ryuuRyou414,
    ryuuRyou415,
    ryuuRyou416,
    ryuuRyou417,
    ryuuRyou418,
    ryuuRyou419,
    ryuuRyou400,
    ryuuRyou401,
    ryuuRyou402,
    ryuuRyou403,
    ryuuRyou404,
    ryuuRyou405,
    ryuuRyou406,
    ryuuRyou407,
    ryuuRyou408,
    ryuuRyou409,
    ryuuRyou420,
    ryuuRyou421,
    ryuuRyou422,
    ryuuRyou423,
    ryuuRyou424,
    ryuuRyou425,
    ryuuRyou426,
    ryuuRyou427,
    ryuuRyou428
    // ryuuRyou430,
    // ryuuRyou429,
    // ryuuRyou400,
    // ryuuRyou401,
    // ryuuRyou402,
    // ryuuRyou403,
    // ryuuRyou404,
    // ryuuRyou405,
    // ryuuRyou406,
    // ryuuRyou407,
    // ryuuRyou408,
    // ryuuRyou409,
    // ryuuRyou431,
    // ryuuRyou410,
    // ryuuRyou411,
    // ryuuRyou412,
    // ryuuRyou413,
    // ryuuRyou414,
    // ryuuRyou415,
    // ryuuRyou416,
    // ryuuRyou417,
    // ryuuRyou418,
    // ryuuRyou419,
    // ryuuRyou420,
    // ryuuRyou421,
    // ryuuRyou422,
    // ryuuRyou423,
    // ryuuRyou424,
    // ryuuRyou425,
    // ryuuRyou426,
    // ryuuRyou427,
    // ryuuRyou428
    // FNSI-add 装置設定画面表示の修正 徐 end
  ) {
    super(receiveDate, treatClass);
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.ryuuRyou431 = ryuuRyou431;
    this.ryuuRyou430 = ryuuRyou430;
    this.ryuuRyou429 = ryuuRyou429;
    this.ryuuRyou410 = ryuuRyou410;
    this.ryuuRyou411 = ryuuRyou411;
    this.ryuuRyou412 = ryuuRyou412;
    this.ryuuRyou413 = ryuuRyou413;
    this.ryuuRyou414 = ryuuRyou414;
    this.ryuuRyou415 = ryuuRyou415;
    this.ryuuRyou416 = ryuuRyou416;
    this.ryuuRyou417 = ryuuRyou417;
    this.ryuuRyou418 = ryuuRyou418;
    this.ryuuRyou419 = ryuuRyou419;
    this.ryuuRyou400 = ryuuRyou400;
    this.ryuuRyou401 = ryuuRyou401;
    this.ryuuRyou402 = ryuuRyou402;
    this.ryuuRyou403 = ryuuRyou403;
    this.ryuuRyou404 = ryuuRyou404;
    this.ryuuRyou405 = ryuuRyou405;
    this.ryuuRyou406 = ryuuRyou406;
    this.ryuuRyou407 = ryuuRyou407;
    this.ryuuRyou408 = ryuuRyou408;
    this.ryuuRyou409 = ryuuRyou409;
    this.ryuuRyou420 = ryuuRyou420;
    this.ryuuRyou421 = ryuuRyou421;
    this.ryuuRyou422 = ryuuRyou422;
    this.ryuuRyou423 = ryuuRyou423;
    this.ryuuRyou424 = ryuuRyou424;
    this.ryuuRyou425 = ryuuRyou425;
    this.ryuuRyou426 = ryuuRyou426;
    this.ryuuRyou427 = ryuuRyou427;
    this.ryuuRyou428 = ryuuRyou428;
    // this.ryuuRyou430 = ryuuRyou430;
    // this.ryuuRyou429 = ryuuRyou429;
    // this.ryuuRyou400 = ryuuRyou400;
    // this.ryuuRyou401 = ryuuRyou401;
    // this.ryuuRyou402 = ryuuRyou402;
    // this.ryuuRyou403 = ryuuRyou403;
    // this.ryuuRyou404 = ryuuRyou404;
    // this.ryuuRyou405 = ryuuRyou405;
    // this.ryuuRyou406 = ryuuRyou406;
    // this.ryuuRyou407 = ryuuRyou407;
    // this.ryuuRyou408 = ryuuRyou408;
    // this.ryuuRyou409 = ryuuRyou409;
    // this.ryuuRyou431 = ryuuRyou431;
    // this.ryuuRyou410 = ryuuRyou410;
    // this.ryuuRyou411 = ryuuRyou411;
    // this.ryuuRyou412 = ryuuRyou412;
    // this.ryuuRyou413 = ryuuRyou413;
    // this.ryuuRyou414 = ryuuRyou414;
    // this.ryuuRyou415 = ryuuRyou415;
    // this.ryuuRyou416 = ryuuRyou416;
    // this.ryuuRyou417 = ryuuRyou417;
    // this.ryuuRyou418 = ryuuRyou418;
    // this.ryuuRyou419 = ryuuRyou419;
    // this.ryuuRyou420 = ryuuRyou420;
    // this.ryuuRyou421 = ryuuRyou421;
    // this.ryuuRyou422 = ryuuRyou422;
    // this.ryuuRyou423 = ryuuRyou423;
    // this.ryuuRyou424 = ryuuRyou424;
    // this.ryuuRyou425 = ryuuRyou425;
    // this.ryuuRyou426 = ryuuRyou426;
    // this.ryuuRyou427 = ryuuRyou427;
    // this.ryuuRyou428 = ryuuRyou428;
    // FNSI-add 装置設定画面表示の修正 徐 end
  }

  /**
   * 装置設定の血流量・透析液流量プログラムアコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "431",
        value: this.isNullOrUndefined(this.ryuuRyou431)
          ? ""
          : this.getAfterConversionValue("431", this.ryuuRyou431)
      },
      {
        jsonKey: "430",
        value: this.isNullOrUndefined(this.ryuuRyou430)
          ? ""
          : this.getAfterConversionValue("430", this.ryuuRyou430)
      },
      {
        jsonKey: "429",
        value: this.isNullOrUndefined(this.ryuuRyou429)
          ? ""
          : this.ryuuRyou429
      },
      {
        jsonKey: "410",
        value: this.isNullOrUndefined(this.ryuuRyou410)
          ? ""
          : `${this.ryuuRyou410} ${this.getUnit("410")}`
      },
      {
        jsonKey: "411",
        value: this.isNullOrUndefined(this.ryuuRyou411)
          ? ""
          : `${this.ryuuRyou411} ${this.getUnit("411")}`
      },
      {
        jsonKey: "412",
        value: this.isNullOrUndefined(this.ryuuRyou412)
          ? ""
          : `${this.ryuuRyou412} ${this.getUnit("412")}`
      },
      {
        jsonKey: "413",
        value: this.isNullOrUndefined(this.ryuuRyou413)
          ? ""
          : `${this.ryuuRyou413} ${this.getUnit("413")}`
      },
      {
        jsonKey: "414",
        value: this.isNullOrUndefined(this.ryuuRyou414)
          ? ""
          : `${this.ryuuRyou414} ${this.getUnit("414")}`
      },
      {
        jsonKey: "415",
        value: this.isNullOrUndefined(this.ryuuRyou415)
          ? ""
          : `${this.ryuuRyou415} ${this.getUnit("415")}`
      },
      {
        jsonKey: "416",
        value: this.isNullOrUndefined(this.ryuuRyou416)
          ? ""
          : `${this.ryuuRyou416} ${this.getUnit("416")}`
      },
      {
        jsonKey: "417",
        value: this.isNullOrUndefined(this.ryuuRyou417)
          ? ""
          : `${this.ryuuRyou417} ${this.getUnit("417")}`
      },
      {
        jsonKey: "418",
        value: this.isNullOrUndefined(this.ryuuRyou418)
          ? ""
          : `${this.ryuuRyou418} ${this.getUnit("418")}`
      },
      {
        jsonKey: "419",
        value: this.isNullOrUndefined(this.ryuuRyou419)
          ? ""
          : `${this.ryuuRyou419} ${this.getUnit("419")}`
      },
      {
        jsonKey: "400",
        value: this.isNullOrUndefined(this.ryuuRyou400)
          ? ""
          : `${this.ryuuRyou400} ${this.getUnit("400")}`
      },
      {
        jsonKey: "401",
        value: this.isNullOrUndefined(this.ryuuRyou401)
          ? ""
          : `${this.ryuuRyou401} ${this.getUnit("401")}`
      },
      {
        jsonKey: "402",
        value: this.isNullOrUndefined(this.ryuuRyou402)
          ? ""
          : `${this.ryuuRyou402} ${this.getUnit("402")}`
      },
      {
        jsonKey: "403",
        value: this.isNullOrUndefined(this.ryuuRyou403)
          ? ""
          : `${this.ryuuRyou403} ${this.getUnit("403")}`
      },
      {
        jsonKey: "404",
        value: this.isNullOrUndefined(this.ryuuRyou404)
          ? ""
          : `${this.ryuuRyou404} ${this.getUnit("404")}`
      },
      {
        jsonKey: "405",
        value: this.isNullOrUndefined(this.ryuuRyou405)
          ? ""
          : `${this.ryuuRyou405} ${this.getUnit("405")}`
      },
      {
        jsonKey: "406",
        value: this.isNullOrUndefined(this.ryuuRyou406)
          ? ""
          : `${this.ryuuRyou406} ${this.getUnit("406")}`
      },
      {
        jsonKey: "407",
        value: this.isNullOrUndefined(this.ryuuRyou407)
          ? ""
          : `${this.ryuuRyou407} ${this.getUnit("407")}`
      },
      {
        jsonKey: "408",
        value: this.isNullOrUndefined(this.ryuuRyou408)
          ? ""
          : `${this.ryuuRyou408} ${this.getUnit("408")}`
      },
      {
        jsonKey: "409",
        value: this.isNullOrUndefined(this.ryuuRyou409)
          ? ""
          : `${this.ryuuRyou409} ${this.getUnit("409")}`
      },
      // {
      //   jsonKey: "430",
      //   value: this.isNullOrUndefined(this.ryuuRyou430)
      //     ? ""
      //     : this.getAfterConversionValue("430", this.ryuuRyou430)
      // },
      // {
      //   jsonKey: "429",
      //   value: this.isNullOrUndefined(this.ryuuRyou429)
      //     ? ""
      //     : this.ryuuRyou429
      // },
      // {
      //   jsonKey: "400",
      //   value: this.isNullOrUndefined(this.ryuuRyou400)
      //     ? ""
      //     : `${this.ryuuRyou400} ${this.getUnit("400")}`
      // },
      // {
      //   jsonKey: "401",
      //   value: this.isNullOrUndefined(this.ryuuRyou401)
      //     ? ""
      //     : `${this.ryuuRyou401} ${this.getUnit("401")}`
      // },
      // {
      //   jsonKey: "402",
      //   value: this.isNullOrUndefined(this.ryuuRyou402)
      //     ? ""
      //     : `${this.ryuuRyou402} ${this.getUnit("402")}`
      // },
      // {
      //   jsonKey: "403",
      //   value: this.isNullOrUndefined(this.ryuuRyou403)
      //     ? ""
      //     : `${this.ryuuRyou403} ${this.getUnit("403")}`
      // },
      // {
      //   jsonKey: "404",
      //   value: this.isNullOrUndefined(this.ryuuRyou404)
      //     ? ""
      //     : `${this.ryuuRyou404} ${this.getUnit("404")}`
      // },
      // {
      //   jsonKey: "405",
      //   value: this.isNullOrUndefined(this.ryuuRyou405)
      //     ? ""
      //     : `${this.ryuuRyou405} ${this.getUnit("405")}`
      // },
      // {
      //   jsonKey: "406",
      //   value: this.isNullOrUndefined(this.ryuuRyou406)
      //     ? ""
      //     : `${this.ryuuRyou406} ${this.getUnit("406")}`
      // },
      // {
      //   jsonKey: "407",
      //   value: this.isNullOrUndefined(this.ryuuRyou407)
      //     ? ""
      //     : `${this.ryuuRyou407} ${this.getUnit("407")}`
      // },
      // {
      //   jsonKey: "408",
      //   value: this.isNullOrUndefined(this.ryuuRyou408)
      //     ? ""
      //     : `${this.ryuuRyou408} ${this.getUnit("408")}`
      // },
      // {
      //   jsonKey: "409",
      //   value: this.isNullOrUndefined(this.ryuuRyou409)
      //     ? ""
      //     : `${this.ryuuRyou409} ${this.getUnit("409")}`
      // },
      // {
      //   jsonKey: "431",
      //   value: this.isNullOrUndefined(this.ryuuRyou431)
      //     ? ""
      //     : this.getAfterConversionValue("431", this.ryuuRyou431)
      // },
      // {
      //   jsonKey: "410",
      //   value: this.isNullOrUndefined(this.ryuuRyou410)
      //     ? ""
      //     : `${this.ryuuRyou410} ${this.getUnit("410")}`
      // },
      // {
      //   jsonKey: "411",
      //   value: this.isNullOrUndefined(this.ryuuRyou411)
      //     ? ""
      //     : `${this.ryuuRyou411} ${this.getUnit("411")}`
      // },
      // {
      //   jsonKey: "412",
      //   value: this.isNullOrUndefined(this.ryuuRyou412)
      //     ? ""
      //     : `${this.ryuuRyou412} ${this.getUnit("412")}`
      // },
      // {
      //   jsonKey: "413",
      //   value: this.isNullOrUndefined(this.ryuuRyou413)
      //     ? ""
      //     : `${this.ryuuRyou413} ${this.getUnit("413")}`
      // },
      // {
      //   jsonKey: "414",
      //   value: this.isNullOrUndefined(this.ryuuRyou414)
      //     ? ""
      //     : `${this.ryuuRyou414} ${this.getUnit("414")}`
      // },
      // {
      //   jsonKey: "415",
      //   value: this.isNullOrUndefined(this.ryuuRyou415)
      //     ? ""
      //     : `${this.ryuuRyou415} ${this.getUnit("415")}`
      // },
      // {
      //   jsonKey: "416",
      //   value: this.isNullOrUndefined(this.ryuuRyou416)
      //     ? ""
      //     : `${this.ryuuRyou416} ${this.getUnit("416")}`
      // },
      // {
      //   jsonKey: "417",
      //   value: this.isNullOrUndefined(this.ryuuRyou417)
      //     ? ""
      //     : `${this.ryuuRyou417} ${this.getUnit("417")}`
      // },
      // {
      //   jsonKey: "418",
      //   value: this.isNullOrUndefined(this.ryuuRyou418)
      //     ? ""
      //     : `${this.ryuuRyou418} ${this.getUnit("418")}`
      // },
      // {
      //   jsonKey: "419",
      //   value: this.isNullOrUndefined(this.ryuuRyou419)
      //     ? ""
      //     : `${this.ryuuRyou419} ${this.getUnit("419")}`
      // },
      // FNSI-add 装置設定画面表示の修正 徐 end
      {
        jsonKey: "420",
        value: this.isNullOrUndefined(this.ryuuRyou420)
          ? ""
          : `${this.ryuuRyou420} ${this.getUnit("420")}`
      },
      {
        jsonKey: "421",
        value: this.isNullOrUndefined(this.ryuuRyou421)
          ? ""
          : `${this.ryuuRyou421} ${this.getUnit("421")}`
      },
      {
        jsonKey: "422",
        value: this.isNullOrUndefined(this.ryuuRyou422)
          ? ""
          : `${this.ryuuRyou422} ${this.getUnit("422")}`
      },
      {
        jsonKey: "423",
        value: this.isNullOrUndefined(this.ryuuRyou423)
          ? ""
          : `${this.ryuuRyou423} ${this.getUnit("423")}`
      },
      {
        jsonKey: "424",
        value: this.isNullOrUndefined(this.ryuuRyou424)
          ? ""
          : `${this.ryuuRyou424} ${this.getUnit("424")}`
      },
      {
        jsonKey: "425",
        value: this.isNullOrUndefined(this.ryuuRyou425)
          ? ""
          : `${this.ryuuRyou425} ${this.getUnit("425")}`
      },
      {
        jsonKey: "426",
        value: this.isNullOrUndefined(this.ryuuRyou426)
          ? ""
          : `${this.ryuuRyou426} ${this.getUnit("426")}`
      },
      {
        jsonKey: "427",
        value: this.isNullOrUndefined(this.ryuuRyou427)
          ? ""
          : `${this.ryuuRyou427} ${this.getUnit("427")}`
      },
      {
        jsonKey: "428",
        value: this.isNullOrUndefined(this.ryuuRyou428)
          ? ""
          : `${this.ryuuRyou428} ${this.getUnit("428")}`
      }
    ];
  }
}
