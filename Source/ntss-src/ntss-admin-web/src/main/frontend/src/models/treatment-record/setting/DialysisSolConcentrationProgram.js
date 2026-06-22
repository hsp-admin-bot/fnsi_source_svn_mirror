import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class DialysisSolConcentrationProgram extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    souchi340,
    souchi368,
    souchi364,
    souchi365,
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
    souchi366,
    souchi367,
    souchi361,
    souchi362,
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
    souchi363
  ) {
    super(receiveDate, treatClass);
    this.souchi340 = souchi340;
    this.souchi368 = souchi368;
    this.souchi364 = souchi364;
    this.souchi365 = souchi365;
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
    this.souchi366 = souchi366;
    this.souchi367 = souchi367;
    this.souchi361 = souchi361;
    this.souchi362 = souchi362;
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
    this.souchi363 = souchi363;
  }

  getValueWithJsonKey() {
    return [
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
        jsonKey: "364",
        value: this.isNullOrUndefined(this.souchi364)
          ? ""
          : this.souchi364
      },
      {
        jsonKey: "365",
        value: this.isNullOrUndefined(this.souchi365)
          ? ""
          : `${this.souchi365} ${this.getUnit("365")}`
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
        jsonKey: "366",
        value: this.isNullOrUndefined(this.souchi366)
          ? ""
          : `${this.souchi366} ${this.getUnit("366")}`
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
        jsonKey: "362",
        value: this.isNullOrUndefined(this.souchi362)
          ? ""
          : `${this.souchi362} ${this.getUnit("362")}`
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
        jsonKey: "363",
        value: this.isNullOrUndefined(this.souchi363)
          ? ""
          : `${this.souchi363} ${this.getUnit("363")}`
      }
    ];
  }
}
