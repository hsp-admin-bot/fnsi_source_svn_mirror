import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class IHdf extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    // FNSI-add 装置設定画面表示の修正 徐 start
    iHdf432,
    iHdf200,
    iHdf201,
    iHdf205,
    iHdf433,
    iHdf203,
    iHdf202,
    iHdf204,
    iHdf434,
    iHdf435,
    iHdf451,
    iHdf436,
    iHdf452,
    iHdf437,
    iHdf453,
    iHdf438,
    iHdf454,
    iHdf439,
    iHdf455,
    iHdf440,
    iHdf456,
    iHdf441,
    iHdf457,
    iHdf442,
    iHdf458,
    iHdf443,
    iHdf459,
    iHdf444,
    iHdf460,
    iHdf445,
    iHdf461,
    iHdf446,
    iHdf462,
    iHdf447,
    iHdf463,
    iHdf448,
    iHdf464,
    iHdf449,
    iHdf465,
    iHdf450,
    iHdf466
    // iHdf200,
    // iHdf201,
    // iHdf202,
    // iHdf203,
    // iHdf204,
    // iHdf205,
    // iHdf432,
    // iHdf433,
    // iHdf434,
    // iHdf435,
    // iHdf436,
    // iHdf437,
    // iHdf438,
    // iHdf439,
    // iHdf440,
    // iHdf441,
    // iHdf442,
    // iHdf443,
    // iHdf444,
    // iHdf445,
    // iHdf446,
    // iHdf447,
    // iHdf448,
    // iHdf449,
    // iHdf450,
    // iHdf451,
    // iHdf452,
    // iHdf453,
    // iHdf454,
    // iHdf455,
    // iHdf456,
    // iHdf457,
    // iHdf458,
    // iHdf459,
    // iHdf460,
    // iHdf461,
    // iHdf462,
    // iHdf463,
    // iHdf464,
    // iHdf465,
    // iHdf466
    // FNSI-add 装置設定画面表示の修正 徐 end
  ) {
    super(receiveDate, treatClass);
    // FNSI-add 装置設定画面表示の修正 徐 start
    this.iHdf432 = iHdf432;
    this.iHdf200 = iHdf200;
    this.iHdf201 = iHdf201;
    this.iHdf205 = iHdf205;
    this.iHdf433 = iHdf433;
    this.iHdf203 = iHdf203;
    this.iHdf202 = iHdf202;
    this.iHdf204 = iHdf204;
    this.iHdf434 = iHdf434;
    this.iHdf435 = iHdf435;
    this.iHdf451 = iHdf451;
    this.iHdf436 = iHdf436;
    this.iHdf452 = iHdf452;
    this.iHdf437 = iHdf437;
    this.iHdf453 = iHdf453;
    this.iHdf438 = iHdf438;
    this.iHdf454 = iHdf454;
    this.iHdf439 = iHdf439;
    this.iHdf455 = iHdf455;
    this.iHdf440 = iHdf440;
    this.iHdf456 = iHdf456;
    this.iHdf441 = iHdf441;
    this.iHdf457 = iHdf457;
    this.iHdf442 = iHdf442;
    this.iHdf458 = iHdf458;
    this.iHdf443 = iHdf443;
    this.iHdf459 = iHdf459;
    this.iHdf444 = iHdf444;
    this.iHdf460 = iHdf460;
    this.iHdf445 = iHdf445;
    this.iHdf461 = iHdf461;
    this.iHdf446 = iHdf446;
    this.iHdf462 = iHdf462;
    this.iHdf447 = iHdf447;
    this.iHdf463 = iHdf463;
    this.iHdf448 = iHdf448;
    this.iHdf464 = iHdf464;
    this.iHdf449 = iHdf449;
    this.iHdf465 = iHdf465;
    this.iHdf450 = iHdf450;
    this.iHdf466 = iHdf466;
    // this.iHdf200 = iHdf200;
    // this.iHdf201 = iHdf201;
    // this.iHdf202 = iHdf202;
    // this.iHdf203 = iHdf203;
    // this.iHdf204 = iHdf204;
    // this.iHdf205 = iHdf205;
    // this.iHdf432 = iHdf432;
    // this.iHdf433 = iHdf433;
    // this.iHdf434 = iHdf434;
    // this.iHdf435 = iHdf435;
    // this.iHdf436 = iHdf436;
    // this.iHdf437 = iHdf437;
    // this.iHdf438 = iHdf438;
    // this.iHdf439 = iHdf439;
    // this.iHdf440 = iHdf440;
    // this.iHdf441 = iHdf441;
    // this.iHdf442 = iHdf442;
    // this.iHdf443 = iHdf443;
    // this.iHdf444 = iHdf444;
    // this.iHdf445 = iHdf445;
    // this.iHdf446 = iHdf446;
    // this.iHdf447 = iHdf447;
    // this.iHdf448 = iHdf448;
    // this.iHdf449 = iHdf449;
    // this.iHdf450 = iHdf450;
    // this.iHdf451 = iHdf451;
    // this.iHdf452 = iHdf452;
    // this.iHdf453 = iHdf453;
    // this.iHdf454 = iHdf454;
    // this.iHdf455 = iHdf455;
    // this.iHdf456 = iHdf456;
    // this.iHdf457 = iHdf457;
    // this.iHdf458 = iHdf458;
    // this.iHdf459 = iHdf459;
    // this.iHdf460 = iHdf460;
    // this.iHdf461 = iHdf461;
    // this.iHdf462 = iHdf462;
    // this.iHdf463 = iHdf463;
    // this.iHdf464 = iHdf464;
    // this.iHdf465 = iHdf465;
    // this.iHdf466 = iHdf466;
    // FNSI-add 装置設定画面表示の修正 徐 end
  }

  /**
   * 装置設定のI-HDFアコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "432",
        value: this.isNullOrUndefined(this.iHdf432)
          ? ""
          : this.getAfterConversionValue("432", this.iHdf432)
      },
      {
        jsonKey: "200",
        value: this.isNullOrUndefined(this.iHdf200)
          ? ""
          : `${this.iHdf200} ${this.getUnit("200")}`
      },
      {
        jsonKey: "201",
        value: this.isNullOrUndefined(this.iHdf201)
          ? ""
          : `${this.iHdf201} ${this.getUnit("201")}`
      },
      {
        jsonKey: "205",
        value: this.isNullOrUndefined(this.iHdf205)
          ? ""
          : `${this.iHdf205} ${this.getUnit("205")}`
      },
      {
        jsonKey: "433",
        value: this.isNullOrUndefined(this.iHdf433)
          ? ""
          : `${this.iHdf433} ${this.getUnit("433")}`
      },
      {
        jsonKey: "203",
        value: this.isNullOrUndefined(this.iHdf203)
          ? ""
          : `${this.iHdf203} ${this.getUnit("203")}`
      },
      {
        jsonKey: "202",
        value: this.isNullOrUndefined(this.iHdf202)
          ? ""
          : `${this.iHdf202} ${this.getUnit("202")}`
      },
      {
        jsonKey: "204",
        value: this.isNullOrUndefined(this.iHdf204)
          ? ""
          : `${this.iHdf204} ${this.getUnit("204")}`
      },
      {
        jsonKey: "434",
        value: this.isNullOrUndefined(this.iHdf434)
          ? ""
          : `${this.iHdf434} ${this.getUnit("434")}`
      },
      {
        jsonKey: "435",
        value: this.isNullOrUndefined(this.iHdf435)
          ? ""
          : `${this.iHdf435} ${this.getUnit("435")}`
      },
      {
        jsonKey: "451",
        value: this.isNullOrUndefined(this.iHdf451)
          ? ""
          : `${this.iHdf451} ${this.getUnit("451")}`
      },
      {
        jsonKey: "436",
        value: this.isNullOrUndefined(this.iHdf436)
          ? ""
          : `${this.iHdf436} ${this.getUnit("436")}`
      },
      {
        jsonKey: "452",
        value: this.isNullOrUndefined(this.iHdf452)
          ? ""
          : `${this.iHdf452} ${this.getUnit("452")}`
      },
      {
        jsonKey: "437",
        value: this.isNullOrUndefined(this.iHdf437)
          ? ""
          : `${this.iHdf437} ${this.getUnit("437")}`
      },
      {
        jsonKey: "453",
        value: this.isNullOrUndefined(this.iHdf453)
          ? ""
          : `${this.iHdf453} ${this.getUnit("453")}`
      },
      {
        jsonKey: "438",
        value: this.isNullOrUndefined(this.iHdf438)
          ? ""
          : `${this.iHdf438} ${this.getUnit("438")}`
      },
      {
        jsonKey: "454",
        value: this.isNullOrUndefined(this.iHdf454)
          ? ""
          : `${this.iHdf454} ${this.getUnit("454")}`
      },
      {
        jsonKey: "439",
        value: this.isNullOrUndefined(this.iHdf439)
          ? ""
          : `${this.iHdf439} ${this.getUnit("439")}`
      },
      {
        jsonKey: "455",
        value: this.isNullOrUndefined(this.iHdf455)
          ? ""
          : `${this.iHdf455} ${this.getUnit("455")}`
      },
      {
        jsonKey: "440",
        value: this.isNullOrUndefined(this.iHdf440)
          ? ""
          : `${this.iHdf440} ${this.getUnit("440")}`
      },
      {
        jsonKey: "456",
        value: this.isNullOrUndefined(this.iHdf456)
          ? ""
          : `${this.iHdf456} ${this.getUnit("456")}`
      },
      {
        jsonKey: "441",
        value: this.isNullOrUndefined(this.iHdf441)
          ? ""
          : `${this.iHdf441} ${this.getUnit("441")}`
      },
      {
        jsonKey: "457",
        value: this.isNullOrUndefined(this.iHdf457)
          ? ""
          : `${this.iHdf457} ${this.getUnit("457")}`
      },
      {
        jsonKey: "442",
        value: this.isNullOrUndefined(this.iHdf442)
          ? ""
          : `${this.iHdf442} ${this.getUnit("442")}`
      },
      {
        jsonKey: "458",
        value: this.isNullOrUndefined(this.iHdf458)
          ? ""
          : `${this.iHdf458} ${this.getUnit("458")}`
      },
      {
        jsonKey: "443",
        value: this.isNullOrUndefined(this.iHdf443)
          ? ""
          : `${this.iHdf443} ${this.getUnit("443")}`
      },
      {
        jsonKey: "459",
        value: this.isNullOrUndefined(this.iHdf459)
          ? ""
          : `${this.iHdf459} ${this.getUnit("459")}`
      },
      {
        jsonKey: "444",
        value: this.isNullOrUndefined(this.iHdf444)
          ? ""
          : `${this.iHdf444} ${this.getUnit("444")}`
      },
      {
        jsonKey: "460",
        value: this.isNullOrUndefined(this.iHdf460)
          ? ""
          : `${this.iHdf460} ${this.getUnit("460")}`
      },
      {
        jsonKey: "445",
        value: this.isNullOrUndefined(this.iHdf445)
          ? ""
          : `${this.iHdf445} ${this.getUnit("445")}`
      },
      {
        jsonKey: "461",
        value: this.isNullOrUndefined(this.iHdf461)
          ? ""
          : `${this.iHdf461} ${this.getUnit("461")}`
      },
      {
        jsonKey: "446",
        value: this.isNullOrUndefined(this.iHdf446)
          ? ""
          : `${this.iHdf446} ${this.getUnit("446")}`
      },
      {
        jsonKey: "462",
        value: this.isNullOrUndefined(this.iHdf462)
          ? ""
          : `${this.iHdf462} ${this.getUnit("462")}`
      },
      {
        jsonKey: "447",
        value: this.isNullOrUndefined(this.iHdf447)
          ? ""
          : `${this.iHdf447} ${this.getUnit("447")}`
      },
      {
        jsonKey: "463",
        value: this.isNullOrUndefined(this.iHdf463)
          ? ""
          : `${this.iHdf463} ${this.getUnit("463")}`
      },
      {
        jsonKey: "448",
        value: this.isNullOrUndefined(this.iHdf448)
          ? ""
          : `${this.iHdf448} ${this.getUnit("448")}`
      },
      {
        jsonKey: "464",
        value: this.isNullOrUndefined(this.iHdf464)
          ? ""
          : `${this.iHdf464} ${this.getUnit("464")}`
      },
      {
        jsonKey: "449",
        value: this.isNullOrUndefined(this.iHdf449)
          ? ""
          : `${this.iHdf449} ${this.getUnit("449")}`
      },
      {
        jsonKey: "465",
        value: this.isNullOrUndefined(this.iHdf465)
          ? ""
          : `${this.iHdf465} ${this.getUnit("465")}`
      },
      {
        jsonKey: "450",
        value: this.isNullOrUndefined(this.iHdf450)
          ? ""
          : `${this.iHdf450} ${this.getUnit("450")}`
      },
      {
        jsonKey: "466",
        value: this.isNullOrUndefined(this.iHdf466)
          ? ""
          : `${this.iHdf466} ${this.getUnit("466")}`
      }
      // {
      //   jsonKey: "200",
      //   value: this.isNullOrUndefined(this.iHdf200)
      //     ? ""
      //     : `${this.iHdf200} ${this.getUnit("200")}`
      // },
      // {
      //   jsonKey: "201",
      //   value: this.isNullOrUndefined(this.iHdf201)
      //     ? ""
      //     : `${this.iHdf201} ${this.getUnit("201")}`
      // },
      // {
      //   jsonKey: "202",
      //   value: this.isNullOrUndefined(this.iHdf202)
      //     ? ""
      //     : `${this.iHdf202} ${this.getUnit("202")}`
      // },
      // {
      //   jsonKey: "203",
      //   value: this.isNullOrUndefined(this.iHdf203)
      //     ? ""
      //     : `${this.iHdf203} ${this.getUnit("203")}`
      // },
      // {
      //   jsonKey: "204",
      //   value: this.isNullOrUndefined(this.iHdf204)
      //     ? ""
      //     : `${this.iHdf204} ${this.getUnit("204")}`
      // },
      // {
      //   jsonKey: "205",
      //   value: this.isNullOrUndefined(this.iHdf205)
      //     ? ""
      //     : `${this.iHdf205} ${this.getUnit("205")}`
      // },
      // {
      //   jsonKey: "432",
      //   value: this.isNullOrUndefined(this.iHdf432)
      //     ? ""
      //     : this.getAfterConversionValue("432", this.iHdf432)
      // },
      // {
      //   jsonKey: "433",
      //   value: this.isNullOrUndefined(this.iHdf433)
      //     ? ""
      //     : `${this.iHdf433} ${this.getUnit("433")}`
      // },
      // {
      //   jsonKey: "434",
      //   value: this.isNullOrUndefined(this.iHdf434)
      //     ? ""
      //     : `${this.iHdf434} ${this.getUnit("434")}`
      // },
      // {
      //   jsonKey: "435",
      //   value: this.isNullOrUndefined(this.iHdf435)
      //     ? ""
      //     : `${this.iHdf435} ${this.getUnit("435")}`
      // },
      // {
      //   jsonKey: "436",
      //   value: this.isNullOrUndefined(this.iHdf436)
      //     ? ""
      //     : `${this.iHdf436} ${this.getUnit("436")}`
      // },
      // {
      //   jsonKey: "437",
      //   value: this.isNullOrUndefined(this.iHdf437)
      //     ? ""
      //     : `${this.iHdf437} ${this.getUnit("437")}`
      // },
      // {
      //   jsonKey: "438",
      //   value: this.isNullOrUndefined(this.iHdf438)
      //     ? ""
      //     : `${this.iHdf438} ${this.getUnit("438")}`
      // },
      // {
      //   jsonKey: "439",
      //   value: this.isNullOrUndefined(this.iHdf439)
      //     ? ""
      //     : `${this.iHdf439} ${this.getUnit("439")}`
      // },
      // {
      //   jsonKey: "440",
      //   value: this.isNullOrUndefined(this.iHdf440)
      //     ? ""
      //     : `${this.iHdf440} ${this.getUnit("440")}`
      // },
      // {
      //   jsonKey: "441",
      //   value: this.isNullOrUndefined(this.iHdf441)
      //     ? ""
      //     : `${this.iHdf441} ${this.getUnit("441")}`
      // },
      // {
      //   jsonKey: "442",
      //   value: this.isNullOrUndefined(this.iHdf442)
      //     ? ""
      //     : `${this.iHdf442} ${this.getUnit("442")}`
      // },
      // {
      //   jsonKey: "443",
      //   value: this.isNullOrUndefined(this.iHdf443)
      //     ? ""
      //     : `${this.iHdf443} ${this.getUnit("443")}`
      // },
      // {
      //   jsonKey: "444",
      //   value: this.isNullOrUndefined(this.iHdf444)
      //     ? ""
      //     : `${this.iHdf444} ${this.getUnit("444")}`
      // },
      // {
      //   jsonKey: "445",
      //   value: this.isNullOrUndefined(this.iHdf445)
      //     ? ""
      //     : `${this.iHdf445} ${this.getUnit("445")}`
      // },
      // {
      //   jsonKey: "446",
      //   value: this.isNullOrUndefined(this.iHdf446)
      //     ? ""
      //     : `${this.iHdf446} ${this.getUnit("446")}`
      // },
      // {
      //   jsonKey: "447",
      //   value: this.isNullOrUndefined(this.iHdf447)
      //     ? ""
      //     : `${this.iHdf447} ${this.getUnit("447")}`
      // },
      // {
      //   jsonKey: "448",
      //   value: this.isNullOrUndefined(this.iHdf448)
      //     ? ""
      //     : `${this.iHdf448} ${this.getUnit("448")}`
      // },
      // {
      //   jsonKey: "449",
      //   value: this.isNullOrUndefined(this.iHdf449)
      //     ? ""
      //     : `${this.iHdf449} ${this.getUnit("449")}`
      // },
      // {
      //   jsonKey: "450",
      //   value: this.isNullOrUndefined(this.iHdf450)
      //     ? ""
      //     : `${this.iHdf450} ${this.getUnit("450")}`
      // },
      // {
      //   jsonKey: "451",
      //   value: this.isNullOrUndefined(this.iHdf451)
      //     ? ""
      //     : `${this.iHdf451} ${this.getUnit("451")}`
      // },
      // {
      //   jsonKey: "452",
      //   value: this.isNullOrUndefined(this.iHdf452)
      //     ? ""
      //     : `${this.iHdf452} ${this.getUnit("452")}`
      // },
      // {
      //   jsonKey: "453",
      //   value: this.isNullOrUndefined(this.iHdf453)
      //     ? ""
      //     : `${this.iHdf453} ${this.getUnit("453")}`
      // },
      // {
      //   jsonKey: "454",
      //   value: this.isNullOrUndefined(this.iHdf454)
      //     ? ""
      //     : `${this.iHdf454} ${this.getUnit("454")}`
      // },
      // {
      //   jsonKey: "455",
      //   value: this.isNullOrUndefined(this.iHdf455)
      //     ? ""
      //     : `${this.iHdf455} ${this.getUnit("455")}`
      // },
      // {
      //   jsonKey: "456",
      //   value: this.isNullOrUndefined(this.iHdf456)
      //     ? ""
      //     : `${this.iHdf456} ${this.getUnit("456")}`
      // },
      // {
      //   jsonKey: "457",
      //   value: this.isNullOrUndefined(this.iHdf457)
      //     ? ""
      //     : `${this.iHdf457} ${this.getUnit("457")}`
      // },
      // {
      //   jsonKey: "458",
      //   value: this.isNullOrUndefined(this.iHdf458)
      //     ? ""
      //     : `${this.iHdf458} ${this.getUnit("458")}`
      // },
      // {
      //   jsonKey: "459",
      //   value: this.isNullOrUndefined(this.iHdf459)
      //     ? ""
      //     : `${this.iHdf459} ${this.getUnit("459")}`
      // },
      // {
      //   jsonKey: "460",
      //   value: this.isNullOrUndefined(this.iHdf460)
      //     ? ""
      //     : `${this.iHdf460} ${this.getUnit("460")}`
      // },
      // {
      //   jsonKey: "461",
      //   value: this.isNullOrUndefined(this.iHdf461)
      //     ? ""
      //     : `${this.iHdf461} ${this.getUnit("461")}`
      // },
      // {
      //   jsonKey: "462",
      //   value: this.isNullOrUndefined(this.iHdf462)
      //     ? ""
      //     : `${this.iHdf462} ${this.getUnit("462")}`
      // },
      // {
      //   jsonKey: "463",
      //   value: this.isNullOrUndefined(this.iHdf463)
      //     ? ""
      //     : `${this.iHdf463} ${this.getUnit("463")}`
      // },
      // {
      //   jsonKey: "464",
      //   value: this.isNullOrUndefined(this.iHdf464)
      //     ? ""
      //     : `${this.iHdf464} ${this.getUnit("464")}`
      // },
      // {
      //   jsonKey: "465",
      //   value: this.isNullOrUndefined(this.iHdf465)
      //     ? ""
      //     : `${this.iHdf465} ${this.getUnit("465")}`
      // },
      // {
      //   jsonKey: "466",
      //   value: this.isNullOrUndefined(this.iHdf466)
      //     ? ""
      //     : `${this.iHdf466} ${this.getUnit("466")}`
      // }
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }
}
