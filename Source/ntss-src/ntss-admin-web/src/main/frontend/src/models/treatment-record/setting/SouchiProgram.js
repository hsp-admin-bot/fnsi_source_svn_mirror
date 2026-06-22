import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";
import { Minutes } from "@/models/treatment-record/setting/Minutes";

export class SouchiProgram extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    souchi290,
    souchi311,
    souchi312,
    souchi291,
    souchi292,
    souchi293,
    souchi294,
    souchi295,
    souchi296,
    souchi297,
    souchi298,
    souchi299,
    souchi300,
    souchi301,
    souchi302,
    souchi303,
    souchi304,
    souchi305,
    souchi306,
    souchi307,
    souchi308,
    souchi309,
    souchi310,
    souchi313,
    souchi314,
    souchi315,
    souchi326,
    souchi328,
    souchi327,
    souchi316,
    souchi317,
    souchi318,
    souchi319,
    souchi320,
    souchi321,
    souchi322,
    souchi323,
    souchi324,
    souchi325,
    souchi329,
    souchi330,
    souchi340,
    souchi368,
    souchi367,
    souchi361,
    souchi341,
    souchi342,
    souchi343,
    souchi344,
    souchi345,
    souchi346,
    souchi347,
    souchi348,
    souchi349,
    souchi350,
    souchi362,
    souchi363,
    souchi184,
    souchi364,
    souchi351,
    souchi352,
    souchi353,
    souchi354,
    souchi355,
    souchi356,
    souchi357,
    souchi358,
    souchi359,
    souchi360,
    souchi365,
    souchi366,
    souchi16,
    souchi17,
    souchi18,
    souchi19,
    souchi252,
    souchi253,
    souchi250,
    souchi251
  ) {
    super(receiveDate, treatClass);
    this.souchi290 = souchi290;
    this.souchi311 = souchi311;
    this.souchi312 = souchi312;
    this.souchi291 = souchi291;
    this.souchi292 = souchi292;
    this.souchi293 = souchi293;
    this.souchi294 = souchi294;
    this.souchi295 = souchi295;
    this.souchi296 = souchi296;
    this.souchi297 = souchi297;
    this.souchi298 = souchi298;
    this.souchi299 = souchi299;
    this.souchi300 = souchi300;
    this.souchi301 = souchi301;
    this.souchi302 = souchi302;
    this.souchi303 = souchi303;
    this.souchi304 = souchi304;
    this.souchi305 = souchi305;
    this.souchi306 = souchi306;
    this.souchi307 = souchi307;
    this.souchi308 = souchi308;
    this.souchi309 = souchi309;
    this.souchi310 = souchi310;
    this.souchi313 = souchi313;
    this.souchi314 = souchi314;
    this.souchi315 = souchi315;
    this.souchi326 = souchi326;
    this.souchi328 = souchi328;
    this.souchi327 = souchi327;
    this.souchi316 = souchi316;
    this.souchi317 = souchi317;
    this.souchi318 = souchi318;
    this.souchi319 = souchi319;
    this.souchi320 = souchi320;
    this.souchi321 = souchi321;
    this.souchi322 = souchi322;
    this.souchi323 = souchi323;
    this.souchi324 = souchi324;
    this.souchi325 = souchi325;
    this.souchi329 = souchi329;
    this.souchi330 = souchi330;
    this.souchi340 = souchi340;
    this.souchi368 = souchi368;
    this.souchi367 = souchi367;
    this.souchi361 = souchi361;
    this.souchi341 = souchi341;
    this.souchi342 = souchi342;
    this.souchi343 = souchi343;
    this.souchi344 = souchi344;
    this.souchi345 = souchi345;
    this.souchi346 = souchi346;
    this.souchi347 = souchi347;
    this.souchi348 = souchi348;
    this.souchi349 = souchi349;
    this.souchi350 = souchi350;
    this.souchi362 = souchi362;
    this.souchi363 = souchi363;
    this.souchi184 = souchi184;
    this.souchi364 = souchi364;
    this.souchi351 = souchi351;
    this.souchi352 = souchi352;
    this.souchi353 = souchi353;
    this.souchi354 = souchi354;
    this.souchi355 = souchi355;
    this.souchi356 = souchi356;
    this.souchi357 = souchi357;
    this.souchi358 = souchi358;
    this.souchi359 = souchi359;
    this.souchi360 = souchi360;
    this.souchi365 = souchi365;
    this.souchi366 = souchi366;
    this.souchi16 = souchi16;
    this.souchi17 = souchi17;
    this.souchi18 = souchi18;
    this.souchi19 = souchi19;
    this.souchi252 = souchi252;
    this.souchi253 = souchi253;
    this.souchi250 = souchi250;
    this.souchi251 = souchi251;
  }

  /**
   * 装置設定の装置プログラムアコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "290",
        value: this.isNullOrUndefined(this.souchi290)
          ? ""
          : this.getAfterConversionValue("290", this.souchi290)
      },
      {
        jsonKey: "311",
        value: this.isNullOrUndefined(this.souchi311)
          ? ""
          : this.souchi311
      },
      {
        jsonKey: "312",
        value: this.isNullOrUndefined(this.souchi312)
          ? ""
          : this.souchi312
      },
      {
        jsonKey: "291",
        value: this.isNullOrUndefined(this.souchi291)
          ? ""
          : this.getAfterConversionValue("291", this.souchi291)
      },
      {
        jsonKey: "292",
        value: this.isNullOrUndefined(this.souchi292)
          ? ""
          : this.getAfterConversionValue("292", this.souchi292)
      },
      {
        jsonKey: "293",
        value: this.isNullOrUndefined(this.souchi293)
          ? ""
          : this.getAfterConversionValue("293", this.souchi293)
      },
      {
        jsonKey: "294",
        value: this.isNullOrUndefined(this.souchi294)
          ? ""
          : this.getAfterConversionValue("294", this.souchi294)
      },
      {
        jsonKey: "295",
        value: this.isNullOrUndefined(this.souchi295)
          ? ""
          : this.getAfterConversionValue("295", this.souchi295)
      },
      {
        jsonKey: "296",
        value: this.isNullOrUndefined(this.souchi296)
          ? ""
          : this.getAfterConversionValue("296", this.souchi296)
      },
      {
        jsonKey: "297",
        value: this.isNullOrUndefined(this.souchi297)
          ? ""
          : this.getAfterConversionValue("297", this.souchi297)
      },
      {
        jsonKey: "298",
        value: this.isNullOrUndefined(this.souchi298)
          ? ""
          : this.getAfterConversionValue("298", this.souchi298)
      },
      {
        jsonKey: "299",
        value: this.isNullOrUndefined(this.souchi299)
          ? ""
          : this.getAfterConversionValue("299", this.souchi299)
      },
      {
        jsonKey: "300",
        value: this.isNullOrUndefined(this.souchi300)
          ? ""
          : this.getAfterConversionValue("300", this.souchi300)
      },
      {
        jsonKey: "301",
        value: this.isNullOrUndefined(this.souchi301)
          ? ""
          : `${this.souchi301} ${this.getUnit("301")}`
      },
      {
        jsonKey: "302",
        value: this.isNullOrUndefined(this.souchi302)
          ? ""
          : `${this.souchi302} ${this.getUnit("302")}`
      },
      {
        jsonKey: "303",
        value: this.isNullOrUndefined(this.souchi303)
          ? ""
          : `${this.souchi303} ${this.getUnit("303")}`
      },
      {
        jsonKey: "304",
        value: this.isNullOrUndefined(this.souchi304)
          ? ""
          : `${this.souchi304} ${this.getUnit("304")}`
      },
      {
        jsonKey: "305",
        value: this.isNullOrUndefined(this.souchi305)
          ? ""
          : `${this.souchi305} ${this.getUnit("305")}`
      },
      {
        jsonKey: "306",
        value: this.isNullOrUndefined(this.souchi306)
          ? ""
          : `${this.souchi306} ${this.getUnit("306")}`
      },
      {
        jsonKey: "307",
        value: this.isNullOrUndefined(this.souchi307)
          ? ""
          : `${this.souchi307} ${this.getUnit("307")}`
      },
      {
        jsonKey: "308",
        value: this.isNullOrUndefined(this.souchi308)
          ? ""
          : `${this.souchi308} ${this.getUnit("308")}`
      },
      {
        jsonKey: "309",
        value: this.isNullOrUndefined(this.souchi309)
          ? ""
          : `${this.souchi309} ${this.getUnit("309")}`
      },
      {
        jsonKey: "310",
        value: this.isNullOrUndefined(this.souchi310)
          ? ""
          : `${this.souchi310} ${this.getUnit("310")}`
      },
      {
        jsonKey: "313",
        value: this.isNullOrUndefined(this.souchi313)
          ? ""
          : `${this.souchi313} ${this.getUnit("313")}`
      },
      {
        jsonKey: "314",
        value: this.isNullOrUndefined(this.souchi314)
          ? ""
          : `${this.souchi314} ${this.getUnit("314")}`
      },
      {
        jsonKey: "315",
        value: this.isNullOrUndefined(this.souchi315)
          ? ""
          : this.getAfterConversionValue("315", this.souchi315)
      },
      {
        jsonKey: "326",
        value: this.isNullOrUndefined(this.souchi326)
          ? ""
          : `${this.souchi326} ${this.getUnit("326")}`
      },
      {
        jsonKey: "328",
        value: this.isNullOrUndefined(this.souchi328)
          ? ""
          : this.souchi328
      },
      {
        jsonKey: "327",
        value: this.isNullOrUndefined(this.souchi327)
          ? ""
          : this.getAfterConversionValue("327", this.souchi327)
      },
      {
        jsonKey: "316",
        value: this.isNullOrUndefined(this.souchi316)
          ? ""
          : `${this.souchi316} ${this.getUnit("316")}`
      },
      {
        jsonKey: "317",
        value: this.isNullOrUndefined(this.souchi317)
          ? ""
          : `${this.souchi317} ${this.getUnit("317")}`
      },
      {
        jsonKey: "318",
        value: this.isNullOrUndefined(this.souchi318)
          ? ""
          : `${this.souchi318} ${this.getUnit("318")}`
      },
      {
        jsonKey: "319",
        value: this.isNullOrUndefined(this.souchi319)
          ? ""
          : `${this.souchi319} ${this.getUnit("319")}`
      },
      {
        jsonKey: "320",
        value: this.isNullOrUndefined(this.souchi320)
          ? ""
          : `${this.souchi320} ${this.getUnit("320")}`
      },
      {
        jsonKey: "321",
        value: this.isNullOrUndefined(this.souchi321)
          ? ""
          : `${this.souchi321} ${this.getUnit("321")}`
      },
      {
        jsonKey: "322",
        value: this.isNullOrUndefined(this.souchi322)
          ? ""
          : `${this.souchi322} ${this.getUnit("322")}`
      },
      {
        jsonKey: "323",
        value: this.isNullOrUndefined(this.souchi323)
          ? ""
          : `${this.souchi323} ${this.getUnit("323")}`
      },
      {
        jsonKey: "324",
        value: this.isNullOrUndefined(this.souchi324)
          ? ""
          : `${this.souchi324} ${this.getUnit("324")}`
      },
      {
        jsonKey: "325",
        value: this.isNullOrUndefined(this.souchi325)
          ? ""
          : `${this.souchi325} ${this.getUnit("325")}`
      },
      {
        jsonKey: "329",
        value: this.isNullOrUndefined(this.souchi329)
          ? ""
          : `${this.souchi329} ${this.getUnit("329")}`
      },
      {
        jsonKey: "330",
        value: this.isNullOrUndefined(this.souchi330)
          ? ""
          : `${this.souchi330} ${this.getUnit("330")}`
      },
      {
        jsonKey: "340",
        value: this.isNullOrUndefined(this.souchi340)
          ? ""
          : this.getAfterConversionValue("340", this.souchi340)
      },
      {
        jsonKey: "368",
        value: this.isNullOrUndefined(this.souchi368)
          ? ""
          : this.getAfterConversionValue("368", this.souchi368)
      },
      {
        jsonKey: "367",
        value: this.isNullOrUndefined(this.souchi367)
          ? ""
          : `${this.souchi367} ${this.getUnit("367")}`
      },
      {
        jsonKey: "361",
        value: this.isNullOrUndefined(this.souchi361)
          ? ""
          : this.souchi361
      },
      {
        jsonKey: "341",
        value: this.isNullOrUndefined(this.souchi341)
          ? ""
          : `${this.souchi341} ${this.getUnit("341")}`
      },
      {
        jsonKey: "342",
        value: this.isNullOrUndefined(this.souchi342)
          ? ""
          : `${this.souchi342} ${this.getUnit("342")}`
      },
      {
        jsonKey: "343",
        value: this.isNullOrUndefined(this.souchi343)
          ? ""
          : `${this.souchi343} ${this.getUnit("343")}`
      },
      {
        jsonKey: "344",
        value: this.isNullOrUndefined(this.souchi344)
          ? ""
          : `${this.souchi344} ${this.getUnit("344")}`
      },
      {
        jsonKey: "345",
        value: this.isNullOrUndefined(this.souchi345)
          ? ""
          : `${this.souchi345} ${this.getUnit("345")}`
      },
      {
        jsonKey: "346",
        value: this.isNullOrUndefined(this.souchi346)
          ? ""
          : `${this.souchi346} ${this.getUnit("346")}`
      },
      {
        jsonKey: "347",
        value: this.isNullOrUndefined(this.souchi347)
          ? ""
          : `${this.souchi347} ${this.getUnit("347")}`
      },
      {
        jsonKey: "348",
        value: this.isNullOrUndefined(this.souchi348)
          ? ""
          : `${this.souchi348} ${this.getUnit("348")}`
      },
      {
        jsonKey: "349",
        value: this.isNullOrUndefined(this.souchi349)
          ? ""
          : `${this.souchi349} ${this.getUnit("349")}`
      },
      {
        jsonKey: "350",
        value: this.isNullOrUndefined(this.souchi350)
          ? ""
          : `${this.souchi350} ${this.getUnit("350")}`
      },
      {
        jsonKey: "362",
        value: this.isNullOrUndefined(this.souchi362)
          ? ""
          : `${this.souchi362} ${this.getUnit("362")}`
      },
      {
        jsonKey: "363",
        value: this.isNullOrUndefined(this.souchi363)
          ? ""
          : `${this.souchi363} ${this.getUnit("363")}`
      },
      {
        jsonKey: "184",
        value: this.isNullOrUndefined(this.souchi184)
          ? ""
          : `${this.souchi184} ${this.getUnit("184")}`
      },
      {
        jsonKey: "364",
        value: this.isNullOrUndefined(this.souchi364)
          ? ""
          : this.souchi364
      },
      {
        jsonKey: "351",
        value: this.isNullOrUndefined(this.souchi351)
          ? ""
          : `${this.souchi351} ${this.getUnit("351")}`
      },
      {
        jsonKey: "352",
        value: this.isNullOrUndefined(this.souchi352)
          ? ""
          : `${this.souchi352} ${this.getUnit("352")}`
      },
      {
        jsonKey: "353",
        value: this.isNullOrUndefined(this.souchi353)
          ? ""
          : `${this.souchi353} ${this.getUnit("353")}`
      },
      {
        jsonKey: "354",
        value: this.isNullOrUndefined(this.souchi354)
          ? ""
          : `${this.souchi354} ${this.getUnit("354")}`
      },
      {
        jsonKey: "355",
        value: this.isNullOrUndefined(this.souchi355)
          ? ""
          : `${this.souchi355} ${this.getUnit("355")}`
      },
      {
        jsonKey: "356",
        value: this.isNullOrUndefined(this.souchi356)
          ? ""
          : `${this.souchi356} ${this.getUnit("356")}`
      },
      {
        jsonKey: "357",
        value: this.isNullOrUndefined(this.souchi357)
          ? ""
          : `${this.souchi357} ${this.getUnit("357")}`
      },
      {
        jsonKey: "358",
        value: this.isNullOrUndefined(this.souchi358)
          ? ""
          : `${this.souchi358} ${this.getUnit("358")}`
      },
      {
        jsonKey: "359",
        value: this.isNullOrUndefined(this.souchi359)
          ? ""
          : `${this.souchi359} ${this.getUnit("359")}`
      },
      {
        jsonKey: "360",
        value: this.isNullOrUndefined(this.souchi360)
          ? ""
          : `${this.souchi360} ${this.getUnit("360")}`
      },
      {
        jsonKey: "365",
        value: this.isNullOrUndefined(this.souchi365)
          ? ""
          : `${this.souchi365} ${this.getUnit("365")}`
      },
      {
        jsonKey: "366",
        value: this.isNullOrUndefined(this.souchi366)
          ? ""
          : `${this.souchi366} ${this.getUnit("366")}`
      },
      {
        jsonKey: "16",
        value: this.isNullOrUndefined(this.souchi16)
          ? ""
          : this.getAfterConversionValue("16", this.souchi16)
      },
      {
        jsonKey: "17",
        value: this.isNullOrUndefined(this.souchi17)
          ? ""
          : `${this.souchi17} ${this.getUnit("17")}`
      },
      {
        jsonKey: "18",
        value: this.isNullOrUndefined(this.souchi18)
          ? ""
          : new Minutes(this.souchi18).getHHmm()
      },
      {
        jsonKey: "19",
        value: this.isNullOrUndefined(this.souchi19)
          ? ""
          : this.getAfterConversionValue("19", this.souchi19)
      },
      {
        jsonKey: "252",
        value: this.isNullOrUndefined(this.souchi252)
          ? ""
          : `${this.souchi252} ${this.getUnit("252")}`
      },
      {
        jsonKey: "253",
        value: this.isNullOrUndefined(this.souchi253)
          ? ""
          : `${this.souchi253} ${this.getUnit("253")}`
      },
      {
        jsonKey: "250",
        value: this.isNullOrUndefined(this.souchi250)
          ? ""
          : `${this.souchi250} ${this.getUnit("250")}`
      },
      {
        jsonKey: "251",
        value: this.isNullOrUndefined(this.souchi251)
          ? ""
          : `${this.souchi251} ${this.getUnit("251")}`
      }
    ];
  }
}
