import { OrdTreatConditionBase } from "@/models/treatment-record/setting/OrdTreatConditionBase";

export class KeihouTen extends OrdTreatConditionBase {
  constructor(
    receiveDate,
    treatClass,
    keihouTen240,
    keihouTen100,
    keihouTen101,
    // FNSI-add 装置設定画面表示の修正 徐 start
    keihouTen106,
    keihouTen107,
    keihouTen102,
    keihouTen103,
    keihouTen104,
    keihouTen105,
    keihouTen110,
    keihouTen111,
    keihouTen108,
    keihouTen109,
    keihouTen152,
    keihouTen153,
    keihouTen158,
    keihouTen159,
    keihouTen154,
    keihouTen155,
    keihouTen156,
    keihouTen157,
    keihouTen162,
    keihouTen163,
    keihouTen160,
    keihouTen161,
    keihouTen112,
    keihouTen113,
    keihouTen118,
    keihouTen119,
    keihouTen120,
    keihouTen121,
    keihouTen114,
    keihouTen115,
    keihouTen122,
    keihouTen123,
    keihouTen116,
    keihouTen117,
    keihouTen124,
    keihouTen125,
    keihouTen128,
    keihouTen129,
    keihouTen136,
    keihouTen137,
    keihouTen140,
    keihouTen141,
    keihouTen130,
    keihouTen131,
    keihouTen142,
    keihouTen143,
    keihouTen132,
    keihouTen133,
    keihouTen144,
    keihouTen145,
    keihouTen126,
    keihouTen127,
    keihouTen134,
    keihouTen135,
    keihouTen138,
    keihouTen139,
    keihouTen146,
    keihouTen147,
    keihouTen150,
    keihouTen151,
    keihouTen148,
    keihouTen149,
    keihouTen254,
    keihouTen255,
    keihouTen256,
    keihouTen257,
    keihouTen242,
    keihouTen243,
    keihouTen244,
    keihouTen245,
    keihouTen246,
    keihouTen247
    // keihouTen102,
    // keihouTen103,
    // keihouTen104,
    // keihouTen105,
    // keihouTen152,
    // keihouTen153,
    // keihouTen154,
    // keihouTen155,
    // keihouTen156,
    // keihouTen157,
    // keihouTen112,
    // keihouTen113,
    // keihouTen114,
    // keihouTen115,
    // keihouTen116,
    // keihouTen117,
    // keihouTen128,
    // keihouTen129,
    // keihouTen130,
    // keihouTen131,
    // keihouTen132,
    // keihouTen133,
    // keihouTen126,
    // keihouTen127,
    // keihouTen146,
    // keihouTen147,
    // keihouTen148,
    // keihouTen149,
    // keihouTen106,
    // keihouTen107,
    // keihouTen158,
    // keihouTen159,
    // keihouTen118,
    // keihouTen119,
    // keihouTen136,
    // keihouTen137,
    // keihouTen134,
    // keihouTen135,
    // keihouTen150,
    // keihouTen151,
    // keihouTen110,
    // keihouTen111,
    // keihouTen162,
    // keihouTen163,
    // keihouTen120,
    // keihouTen121,
    // keihouTen122,
    // keihouTen123,
    // keihouTen124,
    // keihouTen125,
    // keihouTen140,
    // keihouTen141,
    // keihouTen142,
    // keihouTen143,
    // keihouTen144,
    // keihouTen145,
    // keihouTen138,
    // keihouTen139,
    // keihouTen108,
    // keihouTen109,
    // keihouTen160,
    // keihouTen161,
    // keihouTen254,
    // keihouTen255,
    // keihouTen256,
    // keihouTen257,
    // keihouTen242,
    // keihouTen243,
    // keihouTen244,
    // keihouTen245,
    // keihouTen246,
    // keihouTen247
    // FNSI-add 装置設定画面表示の修正 徐 end
  ) {
    super(receiveDate, treatClass);
    this.keihouTen240 = keihouTen240;
    this.keihouTen100 = keihouTen100;
    this.keihouTen101 = keihouTen101;
    // FNSI-add 装置設定画面表示の修正 徐 strat
    this.keihouTen106 = keihouTen106;
    this.keihouTen107 = keihouTen107;
    this.keihouTen102 = keihouTen102;
    this.keihouTen103 = keihouTen103;
    this.keihouTen104 = keihouTen104;
    this.keihouTen105 = keihouTen105;
    this.keihouTen110 = keihouTen110;
    this.keihouTen111 = keihouTen111;
    this.keihouTen108 = keihouTen108;
    this.keihouTen109 = keihouTen109;
    this.keihouTen152 = keihouTen152;
    this.keihouTen153 = keihouTen153;
    this.keihouTen158 = keihouTen158;
    this.keihouTen159 = keihouTen159;
    this.keihouTen154 = keihouTen154;
    this.keihouTen155 = keihouTen155;
    this.keihouTen156 = keihouTen156;
    this.keihouTen157 = keihouTen157;
    this.keihouTen162 = keihouTen162;
    this.keihouTen163 = keihouTen163;
    this.keihouTen160 = keihouTen160;
    this.keihouTen161 = keihouTen161;
    this.keihouTen112 = keihouTen112;
    this.keihouTen113 = keihouTen113;
    this.keihouTen118 = keihouTen118;
    this.keihouTen119 = keihouTen119;
    this.keihouTen120 = keihouTen120;
    this.keihouTen121 = keihouTen121;
    this.keihouTen114 = keihouTen114;
    this.keihouTen115 = keihouTen115;
    this.keihouTen122 = keihouTen122;
    this.keihouTen123 = keihouTen123;
    this.keihouTen116 = keihouTen116;
    this.keihouTen117 = keihouTen117;
    this.keihouTen124 = keihouTen124;
    this.keihouTen125 = keihouTen125;
    this.keihouTen128 = keihouTen128;
    this.keihouTen129 = keihouTen129;
    this.keihouTen136 = keihouTen136;
    this.keihouTen137 = keihouTen137;
    this.keihouTen140 = keihouTen140;
    this.keihouTen141 = keihouTen141;
    this.keihouTen130 = keihouTen130;
    this.keihouTen131 = keihouTen131;
    this.keihouTen142 = keihouTen142;
    this.keihouTen143 = keihouTen143;
    this.keihouTen132 = keihouTen132;
    this.keihouTen133 = keihouTen133;
    this.keihouTen144 = keihouTen144;
    this.keihouTen145 = keihouTen145;
    this.keihouTen126 = keihouTen126;
    this.keihouTen127 = keihouTen127;
    this.keihouTen134 = keihouTen134;
    this.keihouTen135 = keihouTen135;
    this.keihouTen138 = keihouTen138;
    this.keihouTen139 = keihouTen139;
    this.keihouTen146 = keihouTen146;
    this.keihouTen147 = keihouTen147;
    this.keihouTen150 = keihouTen150;
    this.keihouTen151 = keihouTen151;
    this.keihouTen148 = keihouTen148;
    this.keihouTen149 = keihouTen149;
    this.keihouTen254 = keihouTen254;
    this.keihouTen255 = keihouTen255;
    this.keihouTen256 = keihouTen256;
    this.keihouTen257 = keihouTen257;
    this.keihouTen242 = keihouTen242;
    this.keihouTen243 = keihouTen243;
    this.keihouTen244 = keihouTen244;
    this.keihouTen245 = keihouTen245;
    this.keihouTen246 = keihouTen246;
    this.keihouTen247 = keihouTen247;
    // this.keihouTen102 = keihouTen102;
    // this.keihouTen103 = keihouTen103;
    // this.keihouTen104 = keihouTen104;
    // this.keihouTen105 = keihouTen105;
    // this.keihouTen152 = keihouTen152;
    // this.keihouTen153 = keihouTen153;
    // this.keihouTen154 = keihouTen154;
    // this.keihouTen155 = keihouTen155;
    // this.keihouTen156 = keihouTen156;
    // this.keihouTen157 = keihouTen157;
    // this.keihouTen112 = keihouTen112;
    // this.keihouTen113 = keihouTen113;
    // this.keihouTen114 = keihouTen114;
    // this.keihouTen115 = keihouTen115;
    // this.keihouTen116 = keihouTen116;
    // this.keihouTen117 = keihouTen117;
    // this.keihouTen128 = keihouTen128;
    // this.keihouTen129 = keihouTen129;
    // this.keihouTen130 = keihouTen130;
    // this.keihouTen131 = keihouTen131;
    // this.keihouTen132 = keihouTen132;
    // this.keihouTen133 = keihouTen133;
    // this.keihouTen126 = keihouTen126;
    // this.keihouTen127 = keihouTen127;
    // this.keihouTen146 = keihouTen146;
    // this.keihouTen147 = keihouTen147;
    // this.keihouTen148 = keihouTen148;
    // this.keihouTen149 = keihouTen149;
    // this.keihouTen106 = keihouTen106;
    // this.keihouTen107 = keihouTen107;
    // this.keihouTen158 = keihouTen158;
    // this.keihouTen159 = keihouTen159;
    // this.keihouTen118 = keihouTen118;
    // this.keihouTen119 = keihouTen119;
    // this.keihouTen136 = keihouTen136;
    // this.keihouTen137 = keihouTen137;
    // this.keihouTen134 = keihouTen134;
    // this.keihouTen135 = keihouTen135;
    // this.keihouTen150 = keihouTen150;
    // this.keihouTen151 = keihouTen151;
    // this.keihouTen110 = keihouTen110;
    // this.keihouTen111 = keihouTen111;
    // this.keihouTen162 = keihouTen162;
    // this.keihouTen163 = keihouTen163;
    // this.keihouTen120 = keihouTen120;
    // this.keihouTen121 = keihouTen121;
    // this.keihouTen122 = keihouTen122;
    // this.keihouTen123 = keihouTen123;
    // this.keihouTen124 = keihouTen124;
    // this.keihouTen125 = keihouTen125;
    // this.keihouTen140 = keihouTen140;
    // this.keihouTen141 = keihouTen141;
    // this.keihouTen142 = keihouTen142;
    // this.keihouTen143 = keihouTen143;
    // this.keihouTen144 = keihouTen144;
    // this.keihouTen145 = keihouTen145;
    // this.keihouTen138 = keihouTen138;
    // this.keihouTen139 = keihouTen139;
    // this.keihouTen108 = keihouTen108;
    // this.keihouTen109 = keihouTen109;
    // this.keihouTen160 = keihouTen160;
    // this.keihouTen161 = keihouTen161;
    // this.keihouTen254 = keihouTen254;
    // this.keihouTen255 = keihouTen255;
    // this.keihouTen256 = keihouTen256;
    // this.keihouTen257 = keihouTen257;
    // this.keihouTen242 = keihouTen242;
    // this.keihouTen243 = keihouTen243;
    // this.keihouTen244 = keihouTen244;
    // this.keihouTen245 = keihouTen245;
    // this.keihouTen246 = keihouTen246;
    // this.keihouTen247 = keihouTen247;
    // FNSI-add 装置設定画面表示の修正 徐 end
  }

  /**
   * 装置設定の警報点アコーディオンに表示するデータ
   */
  getValueWithJsonKey() {
    return [
      {
        jsonKey: "240",
        value: this.isNullOrUndefined(this.keihouTen240)
          ? ""
          //mod FNSI 外結バッグ69 房 start
          //mod FNSI 不明追加 房 start
          : this.keihouTen240 === 0 ? "TMP自動追従" : this.keihouTen240 === 1 ? "TMP自動設定" : this.keihouTen240 === 2 ? "透析液圧" : "不明"
        //mod FNSI 不明追加 房 end
        //mod FNSI 外結バッグ69 房 end
      },
      {
        jsonKey: "100",
        value: this.isNullOrUndefined(this.keihouTen100)
          ? ""
          : `${this.keihouTen100} ${this.getUnit("100")}`
      },
      {
        jsonKey: "101",
        value: this.isNullOrUndefined(this.keihouTen101)
          ? ""
          : `${this.keihouTen101} ${this.getUnit("101")}`
      },
      // FNSI-add 装置設定画面表示の修正 徐 start
      {
        jsonKey: "106",
        value: this.isNullOrUndefined(this.keihouTen106)
          ? ""
          : `${this.keihouTen106} ${this.getUnit("106")}`
      },
      {
        jsonKey: "107",
        value: this.isNullOrUndefined(this.keihouTen107)
          ? ""
          : `${this.keihouTen107} ${this.getUnit("107")}`
      },
      {
        jsonKey: "102",
        value: this.isNullOrUndefined(this.keihouTen102)
          ? ""
          : `${this.keihouTen102} ${this.getUnit("102")}`
      },
      {
        jsonKey: "103",
        value: this.isNullOrUndefined(this.keihouTen103)
          ? ""
          : `${this.keihouTen103} ${this.getUnit("103")}`
      },
      {
        jsonKey: "104",
        value: this.isNullOrUndefined(this.keihouTen104)
          ? ""
          : `${this.keihouTen104} ${this.getUnit("104")}`
      },
      {
        jsonKey: "105",
        value: this.isNullOrUndefined(this.keihouTen105)
          ? ""
          : `${this.keihouTen105} ${this.getUnit("105")}`
      },
      {
        jsonKey: "110",
        value: this.isNullOrUndefined(this.keihouTen110)
          ? ""
          : `${this.keihouTen110} ${this.getUnit("110")}`
      },
      {
        jsonKey: "111",
        value: this.isNullOrUndefined(this.keihouTen111)
          ? ""
          : `${this.keihouTen111} ${this.getUnit("111")}`
      },
      {
        jsonKey: "108",
        value: this.isNullOrUndefined(this.keihouTen108)
          ? ""
          : `${this.keihouTen108} ${this.getUnit("108")}`
      },
      {
        jsonKey: "109",
        value: this.isNullOrUndefined(this.keihouTen109)
          ? ""
          : `${this.keihouTen109} ${this.getUnit("109")}`
      },
      {
        jsonKey: "152",
        value: this.isNullOrUndefined(this.keihouTen152)
          ? ""
          : `${this.keihouTen152} ${this.getUnit("152")}`
      },
      {
        jsonKey: "153",
        value: this.isNullOrUndefined(this.keihouTen153)
          ? ""
          : `${this.keihouTen153} ${this.getUnit("153")}`
      },
      {
        jsonKey: "158",
        value: this.isNullOrUndefined(this.keihouTen158)
          ? ""
          : `${this.keihouTen158} ${this.getUnit("158")}`
      },
      {
        jsonKey: "159",
        value: this.isNullOrUndefined(this.keihouTen159)
          ? ""
          : `${this.keihouTen159} ${this.getUnit("159")}`
      },
      {
        jsonKey: "154",
        value: this.isNullOrUndefined(this.keihouTen154)
          ? ""
          : `${this.keihouTen154} ${this.getUnit("154")}`
      },
      {
        jsonKey: "155",
        value: this.isNullOrUndefined(this.keihouTen155)
          ? ""
          : `${this.keihouTen155} ${this.getUnit("155")}`
      },
      {
        jsonKey: "156",
        value: this.isNullOrUndefined(this.keihouTen156)
          ? ""
          : `${this.keihouTen156} ${this.getUnit("156")}`
      },
      {
        jsonKey: "157",
        value: this.isNullOrUndefined(this.keihouTen157)
          ? ""
          : `${this.keihouTen157} ${this.getUnit("157")}`
      },
      {
        jsonKey: "162",
        value: this.isNullOrUndefined(this.keihouTen162)
          ? ""
          : `${this.keihouTen162} ${this.getUnit("162")}`
      },
      {
        jsonKey: "163",
        value: this.isNullOrUndefined(this.keihouTen163)
          ? ""
          : `${this.keihouTen163} ${this.getUnit("163")}`
      },
      {
        jsonKey: "160",
        value: this.isNullOrUndefined(this.keihouTen160)
          ? ""
          : `${this.keihouTen160} ${this.getUnit("160")}`
      },
      {
        jsonKey: "161",
        value: this.isNullOrUndefined(this.keihouTen161)
          ? ""
          : `${this.keihouTen161} ${this.getUnit("161")}`
      },
      {
        jsonKey: "112",
        value: this.isNullOrUndefined(this.keihouTen112)
          ? ""
          : `${this.keihouTen112} ${this.getUnit("112")}`
      },
      {
        jsonKey: "113",
        value: this.isNullOrUndefined(this.keihouTen113)
          ? ""
          : `${this.keihouTen113} ${this.getUnit("113")}`
      },
      {
        jsonKey: "118",
        value: this.isNullOrUndefined(this.keihouTen118)
          ? ""
          : `${this.keihouTen118} ${this.getUnit("118")}`
      },
      {
        jsonKey: "119",
        value: this.isNullOrUndefined(this.keihouTen119)
          ? ""
          : `${this.keihouTen119} ${this.getUnit("119")}`
      },
      {
        jsonKey: "120",
        value: this.isNullOrUndefined(this.keihouTen120)
          ? ""
          : `${this.keihouTen120} ${this.getUnit("120")}`
      },
      {
        jsonKey: "121",
        value: this.isNullOrUndefined(this.keihouTen121)
          ? ""
          : `${this.keihouTen121} ${this.getUnit("121")}`
      },
      {
        jsonKey: "114",
        value: this.isNullOrUndefined(this.keihouTen114)
          ? ""
          : `${this.keihouTen114} ${this.getUnit("114")}`
      },
      {
        jsonKey: "115",
        value: this.isNullOrUndefined(this.keihouTen115)
          ? ""
          : `${this.keihouTen115} ${this.getUnit("115")}`
      },
      {
        jsonKey: "122",
        value: this.isNullOrUndefined(this.keihouTen122)
          ? ""
          : `${this.keihouTen122} ${this.getUnit("122")}`
      },
      {
        jsonKey: "123",
        value: this.isNullOrUndefined(this.keihouTen123)
          ? ""
          : `${this.keihouTen123} ${this.getUnit("123")}`
      },
      {
        jsonKey: "116",
        value: this.isNullOrUndefined(this.keihouTen116)
          ? ""
          : `${this.keihouTen116} ${this.getUnit("116")}`
      },
      {
        jsonKey: "117",
        value: this.isNullOrUndefined(this.keihouTen117)
          ? ""
          : `${this.keihouTen117} ${this.getUnit("117")}`
      },
      {
        jsonKey: "124",
        value: this.isNullOrUndefined(this.keihouTen124)
          ? ""
          : `${this.keihouTen124} ${this.getUnit("124")}`
      },
      {
        jsonKey: "125",
        value: this.isNullOrUndefined(this.keihouTen125)
          ? ""
          : `${this.keihouTen125} ${this.getUnit("125")}`
      },
      {
        jsonKey: "128",
        value: this.isNullOrUndefined(this.keihouTen128)
          ? ""
          : `${this.keihouTen128} ${this.getUnit("128")}`
      },
      {
        jsonKey: "129",
        value: this.isNullOrUndefined(this.keihouTen129)
          ? ""
          : `${this.keihouTen129} ${this.getUnit("129")}`
      },
      {
        jsonKey: "136",
        value: this.isNullOrUndefined(this.keihouTen136)
          ? ""
          : `${this.keihouTen136} ${this.getUnit("136")}`
      },
      {
        jsonKey: "137",
        value: this.isNullOrUndefined(this.keihouTen137)
          ? ""
          : `${this.keihouTen137} ${this.getUnit("137")}`
      },
      {
        jsonKey: "140",
        value: this.isNullOrUndefined(this.keihouTen140)
          ? ""
          : `${this.keihouTen140} ${this.getUnit("140")}`
      },
      {
        jsonKey: "141",
        value: this.isNullOrUndefined(this.keihouTen141)
          ? ""
          : `${this.keihouTen141} ${this.getUnit("141")}`
      },
      {
        jsonKey: "130",
        value: this.isNullOrUndefined(this.keihouTen130)
          ? ""
          : `${this.keihouTen130} ${this.getUnit("130")}`
      },
      {
        jsonKey: "131",
        value: this.isNullOrUndefined(this.keihouTen131)
          ? ""
          : `${this.keihouTen131} ${this.getUnit("131")}`
      },
      {
        jsonKey: "142",
        value: this.isNullOrUndefined(this.keihouTen142)
          ? ""
          : `${this.keihouTen142} ${this.getUnit("142")}`
      },
      {
        jsonKey: "143",
        value: this.isNullOrUndefined(this.keihouTen143)
          ? ""
          : `${this.keihouTen143} ${this.getUnit("143")}`
      },
      {
        jsonKey: "132",
        value: this.isNullOrUndefined(this.keihouTen132)
          ? ""
          : `${this.keihouTen132} ${this.getUnit("132")}`
      },
      {
        jsonKey: "133",
        value: this.isNullOrUndefined(this.keihouTen133)
          ? ""
          : `${this.keihouTen133} ${this.getUnit("133")}`
      },
      {
        jsonKey: "144",
        value: this.isNullOrUndefined(this.keihouTen144)
          ? ""
          : `${this.keihouTen144} ${this.getUnit("144")}`
      },
      {
        jsonKey: "145",
        value: this.isNullOrUndefined(this.keihouTen145)
          ? ""
          : `${this.keihouTen145} ${this.getUnit("145")}`
      },
      {
        jsonKey: "126",
        value: this.isNullOrUndefined(this.keihouTen126)
          ? ""
          : `${this.keihouTen126} ${this.getUnit("126")}`
      },
      {
        jsonKey: "127",
        value: this.isNullOrUndefined(this.keihouTen127)
          ? ""
          : `${this.keihouTen127} ${this.getUnit("127")}`
      },
      {
        jsonKey: "134",
        value: this.isNullOrUndefined(this.keihouTen134)
          ? ""
          : `${this.keihouTen134} ${this.getUnit("134")}`
      },
      {
        jsonKey: "135",
        value: this.isNullOrUndefined(this.keihouTen135)
          ? ""
          : `${this.keihouTen135} ${this.getUnit("135")}`
      },
      {
        jsonKey: "138",
        value: this.isNullOrUndefined(this.keihouTen138)
          ? ""
          : `${this.keihouTen138} ${this.getUnit("138")}`
      },
      {
        jsonKey: "139",
        value: this.isNullOrUndefined(this.keihouTen139)
          ? ""
          : `${this.keihouTen139} ${this.getUnit("139")}`
      },
      {
        jsonKey: "146",
        value: this.isNullOrUndefined(this.keihouTen146)
          ? ""
          : `${this.keihouTen146} ${this.getUnit("146")}`
      },
      {
        jsonKey: "147",
        value: this.isNullOrUndefined(this.keihouTen147)
          ? ""
          : `${this.keihouTen147} ${this.getUnit("147")}`
      },
      {
        jsonKey: "150",
        value: this.isNullOrUndefined(this.keihouTen150)
          ? ""
          : `${this.keihouTen150} ${this.getUnit("150")}`
      },
      {
        jsonKey: "151",
        value: this.isNullOrUndefined(this.keihouTen151)
          ? ""
          : `${this.keihouTen151} ${this.getUnit("151")}`
      },
      {
        jsonKey: "148",
        value: this.isNullOrUndefined(this.keihouTen148)
          ? ""
          : `${this.keihouTen148} ${this.getUnit("148")}`
      },
      {
        jsonKey: "149",
        value: this.isNullOrUndefined(this.keihouTen149)
          ? ""
          : `${this.keihouTen149} ${this.getUnit("149")}`
      },
      {
        jsonKey: "254",
        value: this.isNullOrUndefined(this.keihouTen254)
          ? ""
          : `${this.keihouTen254} ${this.getUnit("254")}`
      },
      {
        jsonKey: "255",
        value: this.isNullOrUndefined(this.keihouTen255)
          ? ""
          : `${this.keihouTen255} ${this.getUnit("255")}`
      },
      {
        jsonKey: "256",
        value: this.isNullOrUndefined(this.keihouTen256)
          ? ""
          : `${this.keihouTen256} ${this.getUnit("256")}`
      },
      {
        jsonKey: "257",
        value: this.isNullOrUndefined(this.keihouTen257)
          ? ""
          : `${this.keihouTen257} ${this.getUnit("257")}`
      },
      {
        jsonKey: "242",
        value: this.isNullOrUndefined(this.keihouTen242)
          ? ""
          : this.getAfterConversionValue("242", this.keihouTen242)
      },
      {
        jsonKey: "243",
        value: this.isNullOrUndefined(this.keihouTen243)
          ? ""
          : this.getAfterConversionValue("243", this.keihouTen243)
      },
      {
        jsonKey: "244",
        value: this.isNullOrUndefined(this.keihouTen244)
          ? ""
          : this.getAfterConversionValue("244", this.keihouTen244)
      },
      {
        jsonKey: "245",
        value: this.isNullOrUndefined(this.keihouTen245)
          ? ""
          : this.getAfterConversionValue("245", this.keihouTen245)
      },
      {
        jsonKey: "246",
        value: this.isNullOrUndefined(this.keihouTen246)
          ? ""
          : this.getAfterConversionValue("246", this.keihouTen246)
      },
      {
        jsonKey: "247",
        value: this.isNullOrUndefined(this.keihouTen247)
          ? ""
          : this.getAfterConversionValue("247", this.keihouTen247)
      }
      // {
      //   jsonKey: "102",
      //   value: this.isNullOrUndefined(this.keihouTen102)
      //     ? ""
      //     : `${this.keihouTen102} ${this.getUnit("102")}`
      // },
      // {
      //   jsonKey: "103",
      //   value: this.isNullOrUndefined(this.keihouTen103)
      //     ? ""
      //     : `${this.keihouTen103} ${this.getUnit("103")}`
      // },
      // {
      //   jsonKey: "104",
      //   value: this.isNullOrUndefined(this.keihouTen104)
      //     ? ""
      //     : `${this.keihouTen104} ${this.getUnit("104")}`
      // },
      // {
      //   jsonKey: "105",
      //   value: this.isNullOrUndefined(this.keihouTen105)
      //     ? ""
      //     : `${this.keihouTen105} ${this.getUnit("105")}`
      // },
      // {
      //   jsonKey: "152",
      //   value: this.isNullOrUndefined(this.keihouTen152)
      //     ? ""
      //     : `${this.keihouTen152} ${this.getUnit("152")}`
      // },
      // {
      //   jsonKey: "153",
      //   value: this.isNullOrUndefined(this.keihouTen153)
      //     ? ""
      //     : `${this.keihouTen153} ${this.getUnit("153")}`
      // },
      // {
      //   jsonKey: "154",
      //   value: this.isNullOrUndefined(this.keihouTen154)
      //     ? ""
      //     : `${this.keihouTen154} ${this.getUnit("154")}`
      // },
      // {
      //   jsonKey: "155",
      //   value: this.isNullOrUndefined(this.keihouTen155)
      //     ? ""
      //     : `${this.keihouTen155} ${this.getUnit("155")}`
      // },
      // {
      //   jsonKey: "156",
      //   value: this.isNullOrUndefined(this.keihouTen156)
      //     ? ""
      //     : `${this.keihouTen156} ${this.getUnit("156")}`
      // },
      // {
      //   jsonKey: "157",
      //   value: this.isNullOrUndefined(this.keihouTen157)
      //     ? ""
      //     : `${this.keihouTen157} ${this.getUnit("157")}`
      // },
      // {
      //   jsonKey: "112",
      //   value: this.isNullOrUndefined(this.keihouTen112)
      //     ? ""
      //     : `${this.keihouTen112} ${this.getUnit("112")}`
      // },
      // {
      //   jsonKey: "113",
      //   value: this.isNullOrUndefined(this.keihouTen113)
      //     ? ""
      //     : `${this.keihouTen113} ${this.getUnit("113")}`
      // },
      // {
      //   jsonKey: "114",
      //   value: this.isNullOrUndefined(this.keihouTen114)
      //     ? ""
      //     : `${this.keihouTen114} ${this.getUnit("114")}`
      // },
      // {
      //   jsonKey: "115",
      //   value: this.isNullOrUndefined(this.keihouTen115)
      //     ? ""
      //     : `${this.keihouTen115} ${this.getUnit("115")}`
      // },
      // {
      //   jsonKey: "116",
      //   value: this.isNullOrUndefined(this.keihouTen116)
      //     ? ""
      //     : `${this.keihouTen116} ${this.getUnit("116")}`
      // },
      // {
      //   jsonKey: "117",
      //   value: this.isNullOrUndefined(this.keihouTen117)
      //     ? ""
      //     : `${this.keihouTen117} ${this.getUnit("117")}`
      // },
      // {
      //   jsonKey: "128",
      //   value: this.isNullOrUndefined(this.keihouTen128)
      //     ? ""
      //     : `${this.keihouTen128} ${this.getUnit("128")}`
      // },
      // {
      //   jsonKey: "129",
      //   value: this.isNullOrUndefined(this.keihouTen129)
      //     ? ""
      //     : `${this.keihouTen129} ${this.getUnit("129")}`
      // },
      // {
      //   jsonKey: "130",
      //   value: this.isNullOrUndefined(this.keihouTen130)
      //     ? ""
      //     : `${this.keihouTen130} ${this.getUnit("130")}`
      // },
      // {
      //   jsonKey: "131",
      //   value: this.isNullOrUndefined(this.keihouTen131)
      //     ? ""
      //     : `${this.keihouTen131} ${this.getUnit("131")}`
      // },
      // {
      //   jsonKey: "132",
      //   value: this.isNullOrUndefined(this.keihouTen132)
      //     ? ""
      //     : `${this.keihouTen132} ${this.getUnit("132")}`
      // },
      // {
      //   jsonKey: "133",
      //   value: this.isNullOrUndefined(this.keihouTen133)
      //     ? ""
      //     : `${this.keihouTen133} ${this.getUnit("133")}`
      // },
      // {
      //   jsonKey: "126",
      //   value: this.isNullOrUndefined(this.keihouTen126)
      //     ? ""
      //     : `${this.keihouTen126} ${this.getUnit("126")}`
      // },
      // {
      //   jsonKey: "127",
      //   value: this.isNullOrUndefined(this.keihouTen127)
      //     ? ""
      //     : `${this.keihouTen127} ${this.getUnit("127")}`
      // },
      // {
      //   jsonKey: "146",
      //   value: this.isNullOrUndefined(this.keihouTen146)
      //     ? ""
      //     : `${this.keihouTen146} ${this.getUnit("146")}`
      // },
      // {
      //   jsonKey: "147",
      //   value: this.isNullOrUndefined(this.keihouTen147)
      //     ? ""
      //     : `${this.keihouTen147} ${this.getUnit("147")}`
      // },
      // {
      //   jsonKey: "148",
      //   value: this.isNullOrUndefined(this.keihouTen148)
      //     ? ""
      //     : `${this.keihouTen148} ${this.getUnit("148")}`
      // },
      // {
      //   jsonKey: "149",
      //   value: this.isNullOrUndefined(this.keihouTen149)
      //     ? ""
      //     : `${this.keihouTen149} ${this.getUnit("149")}`
      // },
      // {
      //   jsonKey: "106",
      //   value: this.isNullOrUndefined(this.keihouTen106)
      //     ? ""
      //     : `${this.keihouTen106} ${this.getUnit("106")}`
      // },
      // {
      //   jsonKey: "107",
      //   value: this.isNullOrUndefined(this.keihouTen107)
      //     ? ""
      //     : `${this.keihouTen107} ${this.getUnit("107")}`
      // },
      // {
      //   jsonKey: "158",
      //   value: this.isNullOrUndefined(this.keihouTen158)
      //     ? ""
      //     : `${this.keihouTen158} ${this.getUnit("158")}`
      // },
      // {
      //   jsonKey: "159",
      //   value: this.isNullOrUndefined(this.keihouTen159)
      //     ? ""
      //     : `${this.keihouTen159} ${this.getUnit("159")}`
      // },
      // {
      //   jsonKey: "118",
      //   value: this.isNullOrUndefined(this.keihouTen118)
      //     ? ""
      //     : `${this.keihouTen118} ${this.getUnit("118")}`
      // },
      // {
      //   jsonKey: "119",
      //   value: this.isNullOrUndefined(this.keihouTen119)
      //     ? ""
      //     : `${this.keihouTen119} ${this.getUnit("119")}`
      // },
      // {
      //   jsonKey: "136",
      //   value: this.isNullOrUndefined(this.keihouTen136)
      //     ? ""
      //     : `${this.keihouTen136} ${this.getUnit("136")}`
      // },
      // {
      //   jsonKey: "137",
      //   value: this.isNullOrUndefined(this.keihouTen137)
      //     ? ""
      //     : `${this.keihouTen137} ${this.getUnit("137")}`
      // },
      // {
      //   jsonKey: "134",
      //   value: this.isNullOrUndefined(this.keihouTen134)
      //     ? ""
      //     : `${this.keihouTen134} ${this.getUnit("134")}`
      // },
      // {
      //   jsonKey: "135",
      //   value: this.isNullOrUndefined(this.keihouTen135)
      //     ? ""
      //     : `${this.keihouTen135} ${this.getUnit("135")}`
      // },
      // {
      //   jsonKey: "150",
      //   value: this.isNullOrUndefined(this.keihouTen150)
      //     ? ""
      //     : `${this.keihouTen150} ${this.getUnit("150")}`
      // },
      // {
      //   jsonKey: "151",
      //   value: this.isNullOrUndefined(this.keihouTen151)
      //     ? ""
      //     : `${this.keihouTen151} ${this.getUnit("151")}`
      // },
      // {
      //   jsonKey: "110",
      //   value: this.isNullOrUndefined(this.keihouTen110)
      //     ? ""
      //     : `${this.keihouTen110} ${this.getUnit("110")}`
      // },
      // {
      //   jsonKey: "111",
      //   value: this.isNullOrUndefined(this.keihouTen111)
      //     ? ""
      //     : `${this.keihouTen111} ${this.getUnit("111")}`
      // },
      // {
      //   jsonKey: "162",
      //   value: this.isNullOrUndefined(this.keihouTen162)
      //     ? ""
      //     : `${this.keihouTen162} ${this.getUnit("162")}`
      // },
      // {
      //   jsonKey: "163",
      //   value: this.isNullOrUndefined(this.keihouTen163)
      //     ? ""
      //     : `${this.keihouTen163} ${this.getUnit("163")}`
      // },
      // {
      //   jsonKey: "120",
      //   value: this.isNullOrUndefined(this.keihouTen120)
      //     ? ""
      //     : `${this.keihouTen120} ${this.getUnit("120")}`
      // },
      // {
      //   jsonKey: "121",
      //   value: this.isNullOrUndefined(this.keihouTen121)
      //     ? ""
      //     : `${this.keihouTen121} ${this.getUnit("121")}`
      // },
      // {
      //   jsonKey: "122",
      //   value: this.isNullOrUndefined(this.keihouTen122)
      //     ? ""
      //     : `${this.keihouTen122} ${this.getUnit("122")}`
      // },
      // {
      //   jsonKey: "123",
      //   value: this.isNullOrUndefined(this.keihouTen123)
      //     ? ""
      //     : `${this.keihouTen123} ${this.getUnit("123")}`
      // },
      // {
      //   jsonKey: "124",
      //   value: this.isNullOrUndefined(this.keihouTen124)
      //     ? ""
      //     : `${this.keihouTen124} ${this.getUnit("124")}`
      // },
      // {
      //   jsonKey: "125",
      //   value: this.isNullOrUndefined(this.keihouTen125)
      //     ? ""
      //     : `${this.keihouTen125} ${this.getUnit("125")}`
      // },
      // {
      //   jsonKey: "140",
      //   value: this.isNullOrUndefined(this.keihouTen140)
      //     ? ""
      //     : `${this.keihouTen140} ${this.getUnit("140")}`
      // },
      // {
      //   jsonKey: "141",
      //   value: this.isNullOrUndefined(this.keihouTen141)
      //     ? ""
      //     : `${this.keihouTen141} ${this.getUnit("141")}`
      // },
      // {
      //   jsonKey: "142",
      //   value: this.isNullOrUndefined(this.keihouTen142)
      //     ? ""
      //     : `${this.keihouTen142} ${this.getUnit("142")}`
      // },
      // {
      //   jsonKey: "143",
      //   value: this.isNullOrUndefined(this.keihouTen143)
      //     ? ""
      //     : `${this.keihouTen143} ${this.getUnit("143")}`
      // },
      // {
      //   jsonKey: "144",
      //   value: this.isNullOrUndefined(this.keihouTen144)
      //     ? ""
      //     : `${this.keihouTen144} ${this.getUnit("144")}`
      // },
      // {
      //   jsonKey: "145",
      //   value: this.isNullOrUndefined(this.keihouTen145)
      //     ? ""
      //     : `${this.keihouTen145} ${this.getUnit("145")}`
      // },
      // {
      //   jsonKey: "138",
      //   value: this.isNullOrUndefined(this.keihouTen138)
      //     ? ""
      //     : `${this.keihouTen138} ${this.getUnit("138")}`
      // },
      // {
      //   jsonKey: "139",
      //   value: this.isNullOrUndefined(this.keihouTen139)
      //     ? ""
      //     : `${this.keihouTen139} ${this.getUnit("139")}`
      // },
      // {
      //   jsonKey: "108",
      //   value: this.isNullOrUndefined(this.keihouTen108)
      //     ? ""
      //     : `${this.keihouTen108} ${this.getUnit("108")}`
      // },
      // {
      //   jsonKey: "109",
      //   value: this.isNullOrUndefined(this.keihouTen109)
      //     ? ""
      //     : `${this.keihouTen109} ${this.getUnit("109")}`
      // },
      // {
      //   jsonKey: "160",
      //   value: this.isNullOrUndefined(this.keihouTen160)
      //     ? ""
      //     : `${this.keihouTen160} ${this.getUnit("160")}`
      // },
      // {
      //   jsonKey: "161",
      //   value: this.isNullOrUndefined(this.keihouTen161)
      //     ? ""
      //     : `${this.keihouTen161} ${this.getUnit("161")}`
      // },
      // {
      //   jsonKey: "254",
      //   value: this.isNullOrUndefined(this.keihouTen254)
      //     ? ""
      //     : `${this.keihouTen254} ${this.getUnit("254")}`
      // },
      // {
      //   jsonKey: "255",
      //   value: this.isNullOrUndefined(this.keihouTen255)
      //     ? ""
      //     : `${this.keihouTen255} ${this.getUnit("255")}`
      // },
      // {
      //   jsonKey: "256",
      //   value: this.isNullOrUndefined(this.keihouTen256)
      //     ? ""
      //     : `${this.keihouTen256} ${this.getUnit("256")}`
      // },
      // {
      //   jsonKey: "257",
      //   value: this.isNullOrUndefined(this.keihouTen257)
      //     ? ""
      //     : `${this.keihouTen257} ${this.getUnit("257")}`
      // },
      // {
      //   jsonKey: "242",
      //   value: this.isNullOrUndefined(this.keihouTen242)
      //     ? ""
      //     : this.getAfterConversionValue("242", this.keihouTen242)
      // },
      // {
      //   jsonKey: "243",
      //   value: this.isNullOrUndefined(this.keihouTen243)
      //     ? ""
      //     : this.getAfterConversionValue("243", this.keihouTen243)
      // },
      // {
      //   jsonKey: "244",
      //   value: this.isNullOrUndefined(this.keihouTen244)
      //     ? ""
      //     : this.getAfterConversionValue("244", this.keihouTen244)
      // },
      // {
      //   jsonKey: "245",
      //   value: this.isNullOrUndefined(this.keihouTen245)
      //     ? ""
      //     : this.getAfterConversionValue("245", this.keihouTen245)
      // },
      // {
      //   jsonKey: "246",
      //   value: this.isNullOrUndefined(this.keihouTen246)
      //     ? ""
      //     : this.getAfterConversionValue("246", this.keihouTen246)
      // },
      // {
      //   jsonKey: "247",
      //   value: this.isNullOrUndefined(this.keihouTen247)
      //     ? ""
      //     : this.getAfterConversionValue("247", this.keihouTen247)
      // }
      // FNSI-add 装置設定画面表示の修正 徐 end
    ];
  }
}
