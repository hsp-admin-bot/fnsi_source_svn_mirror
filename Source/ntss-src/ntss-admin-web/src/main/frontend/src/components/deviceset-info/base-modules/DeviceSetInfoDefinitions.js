/** 装置設定名称 D-FAS */
export const DEVICE_TYPE_DFAS = "dfas";
/** 装置設定名称 透析液濃度プログラム */
export const DEVICE_TYPE_DC = "dc";
/** 装置設定名称 Na注入プログラム */
export const DEVICE_TYPE_NA = "na";
/** 装置設定名称 透析量プログラム */
export const DEVICE_TYPE_DIA = "dia";
/** 装置設定名称 UFRプログラム */
export const DEVICE_TYPE_UFR = "ufr";
/** 装置設定名称 I-HDF */
export const DEVICE_TYPE_IHDF = "ihdf";
/** 装置設定名称 血流量・透析液流量プログラム */
export const DEVICE_TYPE_QBQD = "qbqd";
/** 装置設定名称 BV-UFC */
export const DEVICE_TYPE_BVUFC = "bvufc";
/** 装置設定名称 血圧計 */
export const DEVICE_TYPE_BP = "bp";
/** 装置設定名称 BV */
export const DEVICE_TYPE_BV = "bv";
/** 装置設定名称 操作範囲 */
export const DEVICE_TYPE_OPE = "ope";
/** 装置設定名称 プライミング */
export const DEVICE_TYPE_PRI = "pri";
/** 装置設定名称 警報点 */
export const DEVICE_TYPE_WAR = "war";
/** 装置設定名称 濃度プロ自動設定警報 */
export const DEVICE_TYPE_CPRO = "cpro";
/** 装置設定名称 ECUM専用設定 */
export const DEVICE_TYPE_ECUM = "ecum";
/** 装置設定名称 静的静脈圧 */
export const DEVICE_TYPE_IAP = "iap";

/** 装置設定値取得元 マスタ */
export const DATA_SOURCE_TYPE_MST = 1;
/** 装置設定値取得元 患者情報 */
export const DATA_SOURCE_TYPE_PAT = 2;
/** 装置設定値取得元 指示 */
export const DATA_SOURCE_TYPE_ORD = 3;
/** 装置設定値取得元 治療記録 */
export const DATA_SOURCE_TYPE_TREAT = 4;
/** 装置設定値取得元 条件送信 */
export const DATA_SOURCE_TYPE_SENDCOND = 5;
/** 装置設定値取得元 マスタ編集データ */
export const DATA_SOURCE_TYPE_MST_EDIT_RECORD = 6;

class DeviceSetInfoDefinition {
  /**
   * @constructor
   * @param {String} formName 装置設定値名称
   * @param {String} formLabel 装置設定値項目名
   */
  constructor(formName, formLabel, initValue) {
    this.formName = formName;
    this.formLabel = formLabel;
    this.initValue = initValue;
  }
}

/**
 * @classdesc 装置設定値(数値入力)情報定義クラス
 */
export class DeviceSetInfoDefinitionNumber extends DeviceSetInfoDefinition {
  /**
   * @constructor
   * @param {String} formName 装置設定値名称
   * @param {String} formLabel 装置設定値項目名
   * @param {Number} minValue 最小値
   * @param {Number} maxValue 最大値
   * @param {Number} digits 最大桁数
   * @param {Number} decimalDigits 小数桁数
   * @param {Number} initValue 初期値
   * @param {String} unitName 単位
   * @param {Number} step 小数0.1変化-鞠 redmine 6151,6152
   */
  constructor(
    formName,
    formLabel,
    minValue,
    maxValue,
    digits,
    decimalDigits,
    initValue,
    unitName = null,
    //add 鞠 6152
    step
  ) {
    super(formName, formLabel, initValue);
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.digits = digits;
    this.decimalDigits = decimalDigits;
    this.unitName = unitName;
    // mod 卓 7277
    if (step==null){
      this.step=(1 / Math.pow(10, decimalDigits));
    }else{
        //add 鞠 6152
      this.step = step
    }
  }
}

/**
 * @classdesc 装置設定値(ラジオボタン)情報定義クラス
 */
export class DeviceSetInfoDefinitionRadio extends DeviceSetInfoDefinition {
  /**
   * @constructor
   * @param {String} formName 装置設定値名称
   * @param {String} formLabel 装置設定値項目名
   * @param {Array} options 選択肢オブジェクト({ 値: 表示文字列 })の配列
   * @param {String} initValue 初期値
   */
  constructor(formName, formLabel, options, initValue) {
    super(formName, formLabel, initValue);
    // 選択肢オブジェクトを再作成
    this.options = options.map(option => {
      // TODO: valueは基本文字列だからこれでいいと思うが数値ならまずい
      const radioValue = Object.keys(option)[0];
      const displayString = option[radioValue];
      return { radioValue, displayString };
    });
  }
}

/**
 * @classdesc 装置設定値(時間入力)情報定義クラス
 */
export class DeviceSetInfoDefinitionTime extends DeviceSetInfoDefinition {
  /**
   * @constructor
   * @param {String} formName 装置設定値名称
   * @param {String} formLabel 装置設定値項目名
   * @param {String} minValue 最小時間 ※HH:mm
   * @param {String} maxValue 最大時間 ※HH:mm
   * @param {Number} initValue 初期値
   */
  constructor(formName, formLabel, minValue, maxValue, initValue) {
    super(formName, formLabel, initValue);
    this.minValue = minValue;
    this.maxValue = maxValue;
  }
}

/**
 * @classdesc 装置設定値(チェックボックス)情報定義クラス
 */
export class DeviceSetInfoDefinitionCheckbox extends DeviceSetInfoDefinition {
  /**
   * @constructor
   * @param {String} formName 装置設定値名称
   * @param {String} formLabel 装置設定値項目名
   * @param {String} displayString 表示文字列
   * @param {String} uncheckedValue 未チェック状態の値
   * @param {String} checkedValue チェック状態の値
   * @param {String} initValue 初期値
   */
  constructor(
    formName,
    formLabel,
    displayString,
    uncheckedValue,
    checkedValue,
    initValue
  ) {
    super(formName, formLabel, initValue);
    this.displayString = displayString;
    this.uncheckedValue = uncheckedValue;
    this.checkedValue = checkedValue;
  }
}

/**
 * @classdesc 装置設定値(プルダウン)情報定義クラス
 */
export class DeviceSetInfoDefinitionSelect extends DeviceSetInfoDefinition {
  /**
   * @constructor
   * @param {String} formName 装置設定値名称
   * @param {String} formLabel 装置設定値項目名
   * @param {Array} options 選択肢オブジェクト({ 値: 表示文字列 })の配列
   * @param {String} initValue 初期値
   */
  constructor(formName, formLabel, options, initValue) {
    super(formName, formLabel, initValue);
    // 選択肢オブジェクトを再作成
    this.options = options.map(option => {
      // TODO: valueは基本文字列だからこれでいいと思がが数値ならまずい
      const value = Object.keys(option)[0];
      const displayValue = option[value];
      return { value, displayValue };
    });
  }
}

/**
 * @description 装置設定値情報定義(D-FAS)
 */
export const valueInfoDfas = {
  pat: {
    B: {
      1: new DeviceSetInfoDefinitionRadio(
        "IPラインプライミング使用選択",
        "IPプライミング",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "1"
      ),
      5: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"プライミング時のBP速度",*/
        "プライミング(中空糸型)血液ポンプ速度",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "血液ポンプ速度",
        40,
        600,
        3,
        0,
        300,
        "mL/min"
      ),
      7: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"送液最大時間",*/
        "プライミング(中空糸型)送液最大時間",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "送液最大時間",
        15,
        120,
        3,
        0,
        60,
        "sec"
      ),
      8: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"回路洗浄送液量",*/
        "プライミング(中空糸型)血液回路内洗浄置換②使用液量",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "血液回路内洗浄置換②使用液量",
        200,
        1500,
        4,
        0,
        200,
        "mL"
      ),
      9: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"気泡抜き実行回数",*/
        "プライミング(中空糸型)気泡抜き動作実行回数",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "気泡抜き動作実行回数",
        0,
        5,
        1,
        0,
        0,
        "回"
      ),
      10: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"気泡抜き圧力上限",*/
        "プライミング(中空糸型)気泡抜き動作加圧時圧力上限",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "気泡抜き動作加圧時圧力上限",
        50,
        200,
        3,
        0,
        150,
        "mmHg"
      ),
      11: new DeviceSetInfoDefinitionNumber(
        "除水ポンプ速度",
        "",
        0.05,
        0.2,
        3,
        1,
        0.2,
        "mmHg"
      ),
      59: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"積層 プライミング時のBP速度",*/
        "プライミング(積層型)血液ポンプ速度",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "血液ポンプ速度",
        40,
        600,
        3,
        0,
        150,
        "mL/min"
      ),
      54: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"積層 送液最大時間",*/
        "プライミング(積層型)送液最大時間",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "送液最大時間",
        15,
        120,
        3,
        0,
        60,
        "sec"
      ),
      55: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"積層 回路内洗浄送液量",*/
        "プライミング(積層型)血液回路内洗浄置換②使用液量",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "血液回路内洗浄置換②使用液量",
        200,
        1500,
        4,
        0,
        200,
        "mL"
      ),
      56: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"積層 気泡抜き動作実行回数",*/
        "プライミング(積層型)気泡抜き動作実行回数",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "気泡抜き動作実行回数",
        0,
        5,
        1,
        0,
        0,
        "回"
      ),
      57: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"積層 気泡抜き圧力上限",*/
        "プライミング(積層型)気泡抜き動作加圧時圧力上限",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "気泡抜き動作加圧時圧力上限",
        50,
        200,
        3,
        0,
        150,
        "mmHg"
      ),
      58: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"積層 除水ポンプ速度",*/
        "プライミング(積層型)除水ポンプ速度",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "除水ポンプ速度",
        0.05,
        0.5,
        3,
        2,
        0.2,
        "L/h"
      )
    }
  },
  dev: {
    A: {
      339: new DeviceSetInfoDefinitionSelect(
        "脱血方法選択",
        "脱血方法",
        [
          { 0: "同時脱血" },
          { 1: "片側脱血(除水あり)" },
          { 2: "片側脱血(除水なし)" }
        ],
        "2"
      ),
      333: new DeviceSetInfoDefinitionNumber(
        "脱血速度",
        "脱血速度",
        0,
        600,
        3,
        0,
        100,
        "mL/min"
      ),
      331: new DeviceSetInfoDefinitionNumber(
        "同時脱血　脱血量",
        "同時脱血脱血量",
        30,
        300,
        3,
        0,
        150,
        "mL"
      ),
      334: new DeviceSetInfoDefinitionNumber(
        "片側脱血(除水なし) 脱血量",
        "片側脱血(除水なし) 脱血量",
        0,
        200,
        3,
        0,
        150,
        "mL"
      ),
      338: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"片側脱血（除水あり）  脱血量",*/
        "片側脱血（除水あり）脱血量",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "片側脱血（除水あり）脱血量",
        0,
        150,
        3,
        0,
        50,
        "mL"
      ),
      332: new DeviceSetInfoDefinitionNumber(
        "片側脱血への切替え透析液圧",
        "片側脱血への切替え透析液圧",
        -250,
        50,
        3,
        0,
        -200,
        "mmHg"
      ),
      373: new DeviceSetInfoDefinitionNumber(
        "静脈側返血速度",
        "静脈側返血速度",
        0,
        600,
        3,
        0,
        100,
        "mL/min"
      ),
      374: new DeviceSetInfoDefinitionNumber(
        "静脈側最大返血量",
        "静脈側最大返血量",
        50,
        500,
        3,
        0,
        250,
        "mL"
      ),
      377: new DeviceSetInfoDefinitionRadio(
        "静脈側返血　血液判別器使用選択",
        "静脈側返血血液判別器使用選択",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "0"
      ),
      270: new DeviceSetInfoDefinitionRadio(
        "D-FAS 返血 動脈側返血使用選択",
        "動脈側返血使用選択",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "0"
      ),
      376: new DeviceSetInfoDefinitionNumber(
        "動脈側最大返血量",
        "動脈側最大返血量",
        10,
        100,
        3,
        0,
        30,
        "mL"
      ),
      378: new DeviceSetInfoDefinitionRadio(
        "動脈側返血　血液判別器使用選択",
        "動脈側返血 血液判別器使用選択",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "0"
      )
    },
    B: {
      36: new DeviceSetInfoDefinitionRadio(
        "治療開始時血流量使用有無",
        "治療開始時血流量",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "1"
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(透析液濃度プログラム)
 */
export const valueInfoDc = {
  dev: {
    A: {
      340: new DeviceSetInfoDefinitionSelect(
        "濃度プログラム電源ＳＷ",
        "",
        [
          { 0: "切り" },
          // mod FNSI-濃度プログラムの修正 楊 start
          // { 1: "入り[B,A共通ステップ]" },
          // { 2: "入り[B,A別ステップ]" },
          // { 3: "入り[B,A別コース]" }
          { 2: "入り［ステップ］" },
          { 3: "入り［コース］" },
          // mod FNSI-濃度プログラムの修正 楊 end
        ],
        "0"
      ),
      368: new DeviceSetInfoDefinitionRadio(
        "濃度プログラム　除水プロとの連動選択",
        "",
        [{ 0: "OFF" }, { 1: "ON" }],
        "0"
      ),
      367: new DeviceSetInfoDefinitionNumber(
        "濃度プログラム切替時間",
        "",
        1,
        99,
        2,
        0,
        30
      ),
      361: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラムステップ切替無し　コース",
        "",
        0.0,
        2.0,
        2,
        1,
        2.0,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      341: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定１",
        "",
        12.5,
        15.5,
        3,
        1,
        14.0,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      342: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定２",
        "",
        12.5,
        15.5,
        3,
        1,
        14.0,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      343: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定３",
        "",
        12.5,
        15.5,
        3,
        1,
        14.0,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      344: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定４",
        "",
        12.5,
        15.5,
        3,
        1,
        14.0,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      345: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定５",
        "",
        12.5,
        15.5,
        3,
        1,
        14.0,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      346: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定６",
        "",
        12.5,
        15.5,
        3,
        1,
        13.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      347: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定７",
        "",
        12.5,
        15.5,
        3,
        1,
        13.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      348: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定８",
        "",
        12.5,
        15.5,
        3,
        1,
        13.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      349: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定９",
        "",
        12.5,
        15.5,
        3,
        1,
        13.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      350: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム設定１０",
        "",
        12.5,
        15.5,
        3,
        1,
        13.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      362: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム開始数値",
        "",
        12.5,
        15.5,
        3,
        1,
        13.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      363: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム終了数値",
        "",
        12.5,
        15.5,
        3,
        1,
        15.0,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      364: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラムステップ切替無し　コース",
        "",
        0.0,
        2.0,
        2,
        1,
        2.0,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.1
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      351: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定１",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      352: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定２",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      353: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定３",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      354: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定４",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      355: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定５",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      356: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定６",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      357: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定７",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      358: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定８",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      359: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定９",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      360: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム設定１０",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      365: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム開始数値",
        "",
        1.5,
        7.0,
        3,
        2,
        2.5,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      ),
      366: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム終了数値",
        "",
        1.5,
        7.0,
        3,
        2,
        3.0,
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy start
        null,
        0.01
        // mod redmine 6150 濃度プログラム▲▼キーの変化量が小数 宋qy end
      )
    },
    B: {
      20: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程1のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      21: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程2のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      22: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程3のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      23: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程4のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      24: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程5のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      25: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程6のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      26: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程7のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      27: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程8のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      28: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程9のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      29: new DeviceSetInfoDefinitionNumber(
        "A液濃度プログラム工程10のA液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      10: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程1のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      11: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程2のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      12: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程3のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      13: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程4のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      14: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程5のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      15: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程6のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      16: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程7のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      17: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程8のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      18: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程9のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      ),
      19: new DeviceSetInfoDefinitionNumber(
        "B液濃度プログラム工程10のB液濃度",
        "",
        0,
        30,
        2,
        0,
        0
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(Na注入プログラム)
 */
//6152Ｎａ注入プログラムvalueInfoNa最小桁はコースが0.1,小数桁数設定1
export const valueInfoNa = {
  dev: {
    A: {
      315: new DeviceSetInfoDefinitionSelect(
        "Ｎａ注入プログラム電源ＳＷ",
        "",
        [{ 0: "切り" }, { 1: "入り[ステップ]" }, { 2: "入り[コース]" }],
        "0"
      ),
      326: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム切替時間",
        "",
        1,
        99,
        2,
        0,
        30,
        "分"
      ),
      328: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラムコース",
        "",
        0.0,
        2.0,
        2,
        1,
        1.0,
        //add 鞠 6152 Naプログラム▲▼キーの変化量が0.1 start
        null,
        0.1,
        //add 鞠 6152 Naプログラム▲▼キーの変化量が0.1 end
      ),
      327: new DeviceSetInfoDefinitionRadio(
        "Ｎａ注入プログラム　除水プロとの連動選択",
        "",
        [{ 0: "OFF" }, { 1: "ON" }],
        "0"
      ),
      316: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定１",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      317: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定２",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      318: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定３",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      319: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定４",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      320: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定５",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      321: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定６",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      322: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定７",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      323: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定８",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      324: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定９",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      325: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム設定１０",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      329: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム開始数値",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      330: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入プログラム終了数値",
        "",
        0,
        50,
        2,
        0,
        0
      ),
      184: new DeviceSetInfoDefinitionNumber(
        "Ｎａ注入濃度操作範囲上限",
        "",
        0,
        50,
        2,
        0,
        // mod redmine 6051 Na注入濃度最大値の初期値が50 宋qy start
        50,
        // mod redmine 6051 Na注入濃度最大値の初期値が50 宋qy end
        "mEq/L"
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(UFRプログラム)
 */
//6151除水プログラムvalueInfoUfr最小桁はコースが0.1,小数桁数設定1
export const valueInfoUfr = {
  dev: {
    A: {
      290: new DeviceSetInfoDefinitionSelect(
        "除水プログラム電源ＳＷ",
        "",
        [{ 0: "切り" }, { 1: "入り[ステップ]" }, { 2: "入り[コース]" }],
        "0"
      ),
      311: new DeviceSetInfoDefinitionNumber(
        "除水プログラム最終工程",
        "",
        1,
        10,
        2,
        0,
        10
      ),
      312: new DeviceSetInfoDefinitionNumber(
        "除水プログラムコース",
        "",
        0.0,
        2.0,
        2,
        1,
        1.0,
        //add 6151 鞠 start
        null,
        0.1
        //add 6151 鞠 end
      ),
      291: new DeviceSetInfoDefinitionSelect(
        "治療モード１",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      292: new DeviceSetInfoDefinitionSelect(
        "治療モード２",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      293: new DeviceSetInfoDefinitionSelect(
        "治療モード３",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      294: new DeviceSetInfoDefinitionSelect(
        "治療モード４",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      295: new DeviceSetInfoDefinitionSelect(
        "治療モード５",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      296: new DeviceSetInfoDefinitionSelect(
        "治療モード６",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      297: new DeviceSetInfoDefinitionSelect(
        "治療モード７",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      298: new DeviceSetInfoDefinitionSelect(
        "治療モード８",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      299: new DeviceSetInfoDefinitionSelect(
        "治療モード９",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      300: new DeviceSetInfoDefinitionSelect(
        "治療モード１０",
        "",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      301: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数１",
        "",
        0,
        200,
        3,
        0,
        200
      ),
      302: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数２",
        "",
        0,
        200,
        3,
        0,
        150
      ),
      303: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数３",
        "",
        0,
        200,
        3,
        0,
        100
      ),
      304: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数４",
        "",
        0,
        200,
        3,
        0,
        50
      ),
      305: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数５",
        "",
        0,
        200,
        3,
        0,
        0
      ),
      306: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数６",
        "",
        0,
        200,
        3,
        0,
        0
      ),
      307: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数７",
        "",
        0,
        200,
        3,
        0,
        50
      ),
      308: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数８",
        "",
        0,
        200,
        3,
        0,
        100
      ),
      309: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数９",
        "",
        0,
        200,
        3,
        0,
        150
      ),
      310: new DeviceSetInfoDefinitionNumber(
        "除水プログラム指数１０",
        "",
        0,
        200,
        3,
        0,
        200
      ),
      313: new DeviceSetInfoDefinitionNumber(
        "除水プログラム開始数値",
        "",
        0,
        200,
        3,
        0,
        100
      ),
      314: new DeviceSetInfoDefinitionNumber(
        "除水プログラム終了数値",
        "",
        0,
        200,
        3,
        0,
        100
      )
    },
    B: {
      0: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程1の指数",
        "",
        0,
        50,
        2,
        1,
        50
      ),
      1: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程2の指数",
        "",
        0,
        50,
        2,
        1,
        38
      ),
      2: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程3の指数",
        "",
        0,
        50,
        2,
        1,
        25
      ),
      3: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程4の指数",
        "",
        0,
        50,
        2,
        1,
        13
      ),
      4: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程5の指数",
        "",
        0,
        50,
        2,
        1,
        0
      ),
      5: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程6の指数",
        "",
        0,
        50,
        2,
        1,
        0
      ),
      6: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程7の指数",
        "",
        0,
        50,
        2,
        1,
        13
      ),
      7: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程8の指数",
        "",
        0,
        50,
        2,
        1,
        25
      ),
      8: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程9の指数",
        "",
        0,
        50,
        2,
        1,
        38
      ),
      9: new DeviceSetInfoDefinitionNumber(
        "除水プログラム工程10の指数",
        "",
        0,
        50,
        2,
        1,
        50
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(I-HDF)
 */
export const valueInfoIhdf = {
  dev: {
    A: {
      201: new DeviceSetInfoDefinitionNumber(
        "I-HDF 補液速度",
        "",
        40,
        300,
        3,
        0,
        100
      ),
      203: new DeviceSetInfoDefinitionNumber(
        "I-HDF 補液開始時間",
        "",
        0,
        240,
        3,
        0,
        30
      ),
      200: new DeviceSetInfoDefinitionNumber(
        "I-HDF 補液量設定",
        "",
        10,
        500,
        3,
        0,
        200
      ),
      204: new DeviceSetInfoDefinitionNumber(
        "I-HDF 除水再開時間",
        "",
        0,
        10,
        2,
        0,
        0
      ),
      202: new DeviceSetInfoDefinitionNumber(
        "I-HDF 補液周期",
        "",
        10,
        60,
        2,
        0,
        30
      ),
      205: new DeviceSetInfoDefinitionNumber(
        "I-HDF 総補液量上限",
        "",
        1.0,
        2.0,
        3,
        2,
        1.5
      ),
      432: new DeviceSetInfoDefinitionRadio(
        "I-HDFプログラム使用選択",
        "",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "0"
      ),
      433: new DeviceSetInfoDefinitionNumber(
        "予定補液回数",
        "",
        1,
        16,
        2,
        0,
        7
      ),
      434: new DeviceSetInfoDefinitionNumber(
        "補液バランス制限",
        "",
        0,
        400,
        3,
        0,
        0,
        'mL'
      ),
      435: new DeviceSetInfoDefinitionNumber("補液量01", "", 0, 500, 3, 0, 0),
      436: new DeviceSetInfoDefinitionNumber("補液量02", "", 0, 500, 3, 0, 0),
      437: new DeviceSetInfoDefinitionNumber("補液量03", "", 0, 500, 3, 0, 0),
      438: new DeviceSetInfoDefinitionNumber("補液量04", "", 0, 500, 3, 0, 0),
      439: new DeviceSetInfoDefinitionNumber("補液量05", "", 0, 500, 3, 0, 0),
      440: new DeviceSetInfoDefinitionNumber("補液量06", "", 0, 500, 3, 0, 0),
      441: new DeviceSetInfoDefinitionNumber("補液量07", "", 0, 500, 3, 0, 0),
      442: new DeviceSetInfoDefinitionNumber("補液量08", "", 0, 500, 3, 0, 0),
      443: new DeviceSetInfoDefinitionNumber("補液量09", "", 0, 500, 3, 0, 0),
      444: new DeviceSetInfoDefinitionNumber("補液量10", "", 0, 500, 3, 0, 0),
      445: new DeviceSetInfoDefinitionNumber("補液量11", "", 0, 500, 3, 0, 0),
      446: new DeviceSetInfoDefinitionNumber("補液量12", "", 0, 500, 3, 0, 0),
      447: new DeviceSetInfoDefinitionNumber("補液量13", "", 0, 500, 3, 0, 0),
      448: new DeviceSetInfoDefinitionNumber("補液量14", "", 0, 500, 3, 0, 0),
      449: new DeviceSetInfoDefinitionNumber("補液量15", "", 0, 500, 3, 0, 0),
      450: new DeviceSetInfoDefinitionNumber("補液量16", "", 0, 500, 3, 0, 0),
      451: new DeviceSetInfoDefinitionNumber("回収量01", "", 0, 500, 3, 0, 0),
      452: new DeviceSetInfoDefinitionNumber("回収量02", "", 0, 500, 3, 0, 0),
      453: new DeviceSetInfoDefinitionNumber("回収量03", "", 0, 500, 3, 0, 0),
      454: new DeviceSetInfoDefinitionNumber("回収量04", "", 0, 500, 3, 0, 0),
      455: new DeviceSetInfoDefinitionNumber("回収量05", "", 0, 500, 3, 0, 0),
      456: new DeviceSetInfoDefinitionNumber("回収量06", "", 0, 500, 3, 0, 0),
      457: new DeviceSetInfoDefinitionNumber("回収量07", "", 0, 500, 3, 0, 0),
      458: new DeviceSetInfoDefinitionNumber("回収量08", "", 0, 500, 3, 0, 0),
      459: new DeviceSetInfoDefinitionNumber("回収量09", "", 0, 500, 3, 0, 0),
      460: new DeviceSetInfoDefinitionNumber("回収量10", "", 0, 500, 3, 0, 0),
      461: new DeviceSetInfoDefinitionNumber("回収量11", "", 0, 500, 3, 0, 0),
      462: new DeviceSetInfoDefinitionNumber("回収量12", "", 0, 500, 3, 0, 0),
      463: new DeviceSetInfoDefinitionNumber("回収量13", "", 0, 500, 3, 0, 0),
      464: new DeviceSetInfoDefinitionNumber("回収量14", "", 0, 500, 3, 0, 0),
      465: new DeviceSetInfoDefinitionNumber("回収量15", "", 0, 500, 3, 0, 0),
      466: new DeviceSetInfoDefinitionNumber("回収量16", "", 0, 500, 3, 0, 0),
      // add FNSI-FutreNetWeb+SI課題管理No.5255 李 start
      // mod #11166 I-HDFが保存できない zhangyue start
      // 467: new DeviceSetInfoDefinitionNumber("TMPゼロ補正開始時間", "", 0, 30, 2, 0, 0),
      // 468: new DeviceSetInfoDefinitionNumber("TMPゼロ補正時間", "", 120, 600, 10, 0, 0),
      // 469: new DeviceSetInfoDefinitionNumber("計算用I-HDF時間", "", 0, 0, 0, 0, 0)
      1001: new DeviceSetInfoDefinitionNumber("TMPゼロ補正開始時間", "", 0, 30, 10, 0, 0),
      1002: new DeviceSetInfoDefinitionNumber("TMPゼロ補正時間", "", 120, 600, 190, 0, 0),
      // mod #11166 I-HDFが保存できない zhangyue end
      // add FNSI-FutreNetWeb+SI課題管理No.5255 李 end
    }
  }
};

/**
 * @description 装置設定値情報定義(血流量・透析液流量プログラム)
 */
export const valueInfoQbqd = {
  dev: {
    A: {
      430: new DeviceSetInfoDefinitionRadio(
        "QBプログラム電源",
        "QBプログラム",
        [{ 0: "切" }, { 1: "入" }],
        "0"
      ),
      429: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム最大ステップ数",
        "ステップ数",
        2,
        10,
        2,
        0,
        3
      ),
      400: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量1",
        "",
        40,
        600,
        3,
        0,
        100
      ),
      401: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量2",
        "",
        40,
        600,
        3,
        0,
        160
      ),
      402: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量3",
        "",
        40,
        600,
        3,
        0,
        220
      ),
      403: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量4",
        "",
        40,
        600,
        3,
        0,
        220
      ),
      404: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量5",
        "",
        40,
        600,
        3,
        0,
        220
      ),
      405: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量6",
        "",
        40,
        600,
        3,
        0,
        220
      ),
      406: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量7",
        "",
        40,
        600,
        3,
        0,
        220
      ),
      407: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量8",
        "",
        40,
        600,
        3,
        0,
        220
      ),
      408: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量9",
        "",
        40,
        600,
        3,
        0,
        220
      ),
      409: new DeviceSetInfoDefinitionNumber(
        "QBプログラム血流量10",
        "",
        40,
        600,
        3,
        0,
        220
      ),
      431: new DeviceSetInfoDefinitionRadio(
        "QDプログラム電源",
        "QDプログラム",
        [{ 0: "切" }, { 1: "入" }],
        "0"
      ),
      410: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量1",
        "",
        100,
        700,
        3,
        0,
        200
      ),
      411: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量2",
        "",
        100,
        700,
        3,
        0,
        400
      ),
      412: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量3",
        "",
        100,
        700,
        3,
        0,
        600
      ),
      413: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量4",
        "",
        100,
        700,
        3,
        0,
        600
      ),
      414: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量5",
        "",
        100,
        700,
        3,
        0,
        600
      ),
      415: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量6",
        "",
        100,
        700,
        3,
        0,
        600
      ),
      416: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量7",
        "",
        100,
        700,
        3,
        0,
        600
      ),
      417: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量8",
        "",
        100,
        700,
        3,
        0,
        600
      ),
      418: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量9",
        "",
        100,
        700,
        3,
        0,
        600
      ),
      419: new DeviceSetInfoDefinitionNumber(
        "QDプログラム透析液流量10",
        "",
        100,
        700,
        3,
        0,
        600
      ),
      420: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム切替時間1",
        "",
        1,
        240,
        3,
        0,
        60
      ),
      421: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム切替時間2",
        "",
        1,
        240,
        3,
        0,
        60
      ),
      422: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム切替時間3",
        "",
        1,
        240,
        3,
        0,
        60
      ),
      423: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム切替時間4",
        "",
        1,
        240,
        3,
        0,
        60
      ),
      424: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム切替時間5",
        "",
        1,
        240,
        3,
        0,
        60
      ),
      425: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム切替時間6",
        "",
        1,
        240,
        3,
        0,
        60
      ),
      426: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム切替時間7",
        "",
        1,
        240,
        3,
        0,
        60
      ),
      427: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム切替時間8",
        "",
        1,
        240,
        3,
        0,
        60
      ),
      428: new DeviceSetInfoDefinitionNumber(
        "QB、QDプログラム切替時間9",
        "",
        1,
        240,
        3,
        0,
        60
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(BV-UFC)
 */
export const valueInfoBvufc = {
  dev: {
    A: {
      196: new DeviceSetInfoDefinitionRadio(
        "BV-UFC使用選択",
        "BV-UFC使用選択",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "0"
      ),
      197: new DeviceSetInfoDefinitionNumber(
        "UFC期間除水速度上限",
        "UFC期間除水速度上限",
        0,
        4.0,
        3,
        2,
        2.0,
        "L/h"
      ),
      198: new DeviceSetInfoDefinitionNumber(
        "UFC期間除水速度下限",
        "UFC期間除水速度下限",
        0,
        4.0,
        3,
        2,
        1.0,
        "L/h"
      ),
      199: new DeviceSetInfoDefinitionNumber(
        "開始期間 時間",
        "開始期間 時間",
        5,
        60,
        2,
        0,
        10,
        "分"
      ),
      206: new DeviceSetInfoDefinitionNumber(
        "開始期間 除水速度倍率",
        "開始期間 除水速度倍率",
        0.0,
        2.0,
        3,
        2,
        1.0
      ),
      207: new DeviceSetInfoDefinitionNumber(
        "固定倍率除水期間 時間",
        "固定倍率除水期間 時間",
        0,
        240,
        3,
        0,
        60,
        "分"
      ),
      208: new DeviceSetInfoDefinitionNumber(
        "固定倍率除水期間 除水速度倍率",
        "固定倍率除水期間 除水速度倍率",
        0.0,
        2.5,
        3,
        2,
        1.3
      ),
      209: new DeviceSetInfoDefinitionNumber(
        "固定倍率除水終了条件　最高血圧",
        "固定倍率除水終了条件　最高血圧",
        0,
        250,
        3,
        0,
        0,
        "mmHg"
      ),
      210: new DeviceSetInfoDefinitionNumber(
        "固定倍率除水終了条件　脈拍",
        "固定倍率除水終了条件　脈拍",
        0,
        200,
        3,
        0,
        0,
        "bpm"
      ),
      248: new DeviceSetInfoDefinitionNumber(
        "固定倍率除水終了条件　ΔBV",
        "固定倍率除水終了条件　ΔBV",
        -30.0,
        0.0,
        3,
        1,
        0.0,
        "%"
      ),
      249: new DeviceSetInfoDefinitionNumber(
        "終了前期間 時間",
        "終了前期間 時間",
        0,
        180,
        3,
        0,
        20,
        "分"
      ),
      271: new DeviceSetInfoDefinitionNumber(
        "開始時ΔBV基準値 ",
        "開始時ΔBV基準値 ",
        -10.0,
        10.0,
        3,
        1,
        0.0,
        "%"
      ),
      272: new DeviceSetInfoDefinitionNumber(
        "ΔBV基準線　指数1",
        "ΔBV基準線　指数1",
        0,
        200,
        3,
        0,
        50
      ),
      273: new DeviceSetInfoDefinitionNumber(
        "ΔBV基準線　指数2",
        "ΔBV基準線　指数2",
        0,
        200,
        3,
        0,
        80
      ),
      274: new DeviceSetInfoDefinitionNumber(
        "ΔBV基準線　指数3",
        "ΔBV基準線　指数3",
        0,
        200,
        3,
        0,
        95
      ),
      275: new DeviceSetInfoDefinitionNumber(
        "終了時ΔBV基準値 ",
        "終了時ΔBV基準値 ",
        -30.0,
        0.0,
        3,
        1,
        -4.0,
        "%"
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(血圧計)
 */
export const valueInfoBp = {
  dev: {
    A: {
      211: new DeviceSetInfoDefinitionNumber(
        "最高血圧上限",
        "",
        0,
        250,
        3,
        0,
        200,
        "mmHg"
      ),
      212: new DeviceSetInfoDefinitionNumber(
        "最高血圧下限",
        "",
        0,
        250,
        3,
        0,
        80,
        "mmHg"
      ),
      213: new DeviceSetInfoDefinitionNumber(
        "最低血圧上限",
        "",
        0,
        200,
        3,
        0,
        160,
        "mmHg"
      ),
      214: new DeviceSetInfoDefinitionNumber(
        "最低血圧下限",
        "",
        0,
        200,
        3,
        0,
        50,
        "mmHg"
      ),
      215: new DeviceSetInfoDefinitionNumber(
        "平均血圧上限",
        "",
        0,
        235,
        3,
        0,
        180,
        "mmHg"
      ),
      216: new DeviceSetInfoDefinitionNumber(
        "平均血圧下限",
        "",
        0,
        235,
        3,
        0,
        60,
        "mmHg"
      ),
      217: new DeviceSetInfoDefinitionNumber(
        "脈拍数上限",
        "",
        0,
        240,
        3,
        0,
        170,
        "bpm"
      ),
      218: new DeviceSetInfoDefinitionNumber(
        "脈拍数下限",
        "",
        0,
        240,
        3,
        0,
        50,
        "bpm"
      ),
      227: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"最高血圧上限警報  BP  速度",*/
        "血液ポンプ上限値警報時",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        40,
        600,
        3,
        0,
        100,
        "mL/min"
      ),
      219: new DeviceSetInfoDefinitionCheckbox(
        "最高血圧上限警報　BP　動作選択",
        "",
        "動作",
        "0",
        "1",
        "0"
      ),
      228: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"最高血圧下限警報  BP  速度",*/
        "血液ポンプ下限値警報時",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        40,
        600,
        3,
        0,
        100,
        "mL/min"
      ),
      220: new DeviceSetInfoDefinitionCheckbox(
        "最高血圧下限警報　BP　動作選択",
        "",
        "動作",
        "0",
        "1",
        "0"
      ),
      229: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"最高血圧上限警報  除水  速度",*/
        "除水ポンプ上限値警報時",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0.0,
        4.0,
        3,
        2,
        0.1,
        "L/h"
      ),
      221: new DeviceSetInfoDefinitionCheckbox(
        "最高血圧上限警報　除水　動作選択",
        "",
        "動作",
        "0",
        "1",
        "0"
      ),
      230: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"最高血圧下限警報  除水  速度",*/
        "除水ポンプ下限値警報時",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0.0,
        4.0,
        3,
        2,
        0.1,
        "L/h"
      ),
      222: new DeviceSetInfoDefinitionCheckbox(
        "最高血圧下限警報　除水　動作選択",
        "",
        "動作",
        "0",
        "1",
        "0"
      ),
      231: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"最高血圧上限警報  Na注入  速度",*/
        "Na注入ポンプ上限値警報時",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        50,
        2,
        0,
        0,
        "mEq/L"
      ),
      223: new DeviceSetInfoDefinitionCheckbox(
        "最高血圧上限警報　Na注入　動作選択",
        "",
        "動作",
        "0",
        "1",
        "0"
      ),
      232: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"最高血圧下限警報  Na注入  速度",*/
        "Na注入ポンプ下限値警報時",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        50,
        2,
        0,
        0,
        "mEq/L"
      ),
      224: new DeviceSetInfoDefinitionCheckbox(
        "最高血圧下限警報　Na注入　動作選択",
        "",
        "動作",
        "0",
        "1",
        "0"
      ),
      233: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"最高血圧上限警報  補液  速度",*/
        "補液ポンプ上限値警報時",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0.0,
        6.0,
        3,
        2,
        0.0,
        "L/h"
      ),
      225: new DeviceSetInfoDefinitionCheckbox(
        "最高血圧上限警報　補液　動作選択",
        "",
        "動作",
        "0",
        "1",
        "0"
      ),
      234: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"最高血圧下限警報  補液  速度",*/
        "補液ポンプ下限値警報時",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0.0,
        6.0,
        3,
        2,
        0.0,
        "L/h"
      ),
      226: new DeviceSetInfoDefinitionCheckbox(
        "最高血圧下限警報　補液　動作選択",
        "",
        "動作",
        "0",
        "1",
        "0"
      ),
      191: new DeviceSetInfoDefinitionRadio(
        "血圧ｶﾌ選択",
        "カフ選択",
        [{ 0: "成人" }, { 1: "幼児" }],
        "0"
      ),
      190: new DeviceSetInfoDefinitionNumber(
        "血圧自動測定間隔",
        "血圧自動測定間隔",
        0,
        180,
        3,
        0,
        30,
        "min"
      ),
      192: new DeviceSetInfoDefinitionNumber(
        "昇圧値",
        "昇圧値",
        80,
        220,
        3,
        0,
        180,
        "mmHg"
      ),
      193: new DeviceSetInfoDefinitionRadio(
        "昇圧方法選択",
        "昇圧方法",
        [{ 0: "手動" }, { 1: "自動" }, { 2: "スマート昇圧" }],
        "1"
      ),
      195: new DeviceSetInfoDefinitionRadio(
        "血圧測定方法選択",
        "血圧測定方法選択",
        [{ 1: "降圧測定" }, { 2: "昇圧測定" }],
        "1"
      ),
      239: new DeviceSetInfoDefinitionRadio(
        "高速測定選択",
        "高速測定使用選択",
        [{ 0: "なし" }, { 1: "あり" }],
        "1"
      ),
      194: new DeviceSetInfoDefinitionRadio(
        "血圧連続測定動作選択",
        "血圧連続測定動作選択",
        [{ 0: "12分" }, { 1: "5分" }],
        "0"
      ),
      235: new DeviceSetInfoDefinitionNumber(
        "警報連動測定開始時刻",
        "警報連動測定開始時間",
        0,
        120,
        3,
        0,
        0,
        "min"
      ),
      236: new DeviceSetInfoDefinitionNumber(
        "治療条件連動測定時刻",
        "治療条件連動測定時間",
        0,
        120,
        3,
        0,
        0,
        "min"
      ),
      237: new DeviceSetInfoDefinitionRadio(
        "血圧測定自動停止(警報発生)",
        "静脈圧警報発生時の血圧測定",
        [{ 0: "継続" }, { 1: "中断・終了" }],
        "0"
      ),
      238: new DeviceSetInfoDefinitionRadio(
        "血圧測定自動停止(条件変更)",
        "血流量または除水速度変更時の血圧測定",
        [{ 0: "継続" }, { 1: "中断・終了" }],
        "0"
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(BV)
 */
export const valueInfoBv = {
  dev: {
    A: {
      267: new DeviceSetInfoDefinitionRadio(
        "ブラッドボリューム計使用の選択",
        "ブラッドボリューム計使用の選択",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "1"
      ),
      260: new DeviceSetInfoDefinitionNumber(
        "ΔＢＶ低下警報点１",
        "ΔＢＶ低下警報点１",
        -100.0,
        0.0,
        4,
        1,
        -20.0,
        "%"
      ),
      261: new DeviceSetInfoDefinitionNumber(
        "ΔＢＶ低下警報点２",
        "ΔＢＶ低下警報点２",
        -100.0,
        0.0,
        4,
        1,
        -40.0,
        "%"
      ),
      262: new DeviceSetInfoDefinitionNumber(
        "ΔＢＶ変化率警報点",
        "ΔＢＶ変化率警報点",
        -50.0,
        0.0,
        3,
        1,
        -10.0,
        "%/min"
      ),
      277: new DeviceSetInfoDefinitionNumber(
        "ΔＢＶ除水低下速度",
        "ΔＢＶ除水低下速度",
        0.0,
        2.0,
        3,
        2,
        0.0,
        "L/h"
      ),
      278: new DeviceSetInfoDefinitionNumber(
        "ΔＢＶ除水低下遅延時間",
        "ΔＢＶ除水低下遅延時間",
        0,
        30,
        2,
        0,
        5,
        "min"
      ),
      // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
      476: new DeviceSetInfoDefinitionNumber(
        "ΔSO2低下報知点",
        "ΔSO2低下報知点",
        -30.0,
        0.0,
        3,
        1,
        0.0,
        "%"
      ),
      // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
      258: new DeviceSetInfoDefinitionRadio(
        "アクセス再循環測定使用選択",
        "アクセス再循環測定使用選択",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "0"
      ),
      259: new DeviceSetInfoDefinitionTime(
        "自動測定1",
        "自動測定1",
        "00:00",
        "09:59",
        0
      ),
      263: new DeviceSetInfoDefinitionTime(
        "自動測定2",
        "自動測定2",
        "00:00",
        "09:59",
        0
      ),
      264: new DeviceSetInfoDefinitionTime(
        "自動測定3",
        "自動測定3",
        "00:00",
        "09:59",
        0
      ),
      265: new DeviceSetInfoDefinitionTime(
        "自動測定4",
        "自動測定4",
        "00:00",
        "09:59",
        0
      ),
      266: new DeviceSetInfoDefinitionTime(
        "自動測定5",
        "自動測定5",
        "00:00",
        "09:59",
        0
      ),
      281: new DeviceSetInfoDefinitionNumber(
        "再循環率報知",
        "再循環率報知",
        0,
        100,
        3,
        0,
        0,
        "%"
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(操作範囲)
 */
export const valueInfoOpe = {
  dev: {
    A: {
      // del MC対象のため、一時コメントアウト 趙 start
      /* add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 start */
      // 476: new DeviceSetInfoDefinitionRadio(
      //   "条件送信時血流量",
      //   "条件送信時血流量",
      //   [{ 0: "切り" }, { 1: "入り" }],
      //   "0"
      // ),
      // 477: new DeviceSetInfoDefinitionNumber(
      //   "条件送信時血流量",
      //   "条件送信時血流量",
      //   0,
      //   500,
      //   3,
      //   0,
      //   100,
      //   "mL/min"
      // ),
      /* add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 end */
      // del MC対象のため、一時コメントアウト 趙 end
      179: new DeviceSetInfoDefinitionNumber(
        "血流量操作範囲上限",
        "血流量操作範囲上限",
        40,
        600,
        3,
        0,
        300,
        "mL/min"
      ),
      181: new DeviceSetInfoDefinitionNumber(
        "除水速度操作範囲上限",
        "除水速度操作範囲上限",
        0.0,
        4.0,
        3,
        2,
        2.0,
        "L/h"
      ),
      38: new DeviceSetInfoDefinitionRadio(
        "クリップ式気泡検出器切りＳＷ",
        "動脈側気泡検出器",
        [{ 0: "切り" }, { 1: "入り" }],
        "1"
      ),
      21: new DeviceSetInfoDefinitionRadio(
        "除水計算選択",
        "除水計算選択",
        [{ 0: "透析時間" }, { 1: "設定時刻" }],
        "0"
      ),
      22: new DeviceSetInfoDefinitionRadio(
        "除水計算優先項目選択",
        "除水計算優先項目選択",
        [{ 0: "除水速度算出" }, { 1: "除水量設定算出" }],
        "0"
      ),
      39: new DeviceSetInfoDefinitionNumber(
        "除水開始遅延時間",
        "除水開始遅延時間",
        0,
        30,
        2,
        0,
        0,
        "分"
      ),
      182: new DeviceSetInfoDefinitionNumber(
        "透析液温度操作範囲上限",
        "透析液温度操作範囲",
        33.0,
        40.0,
        3,
        1,
        40.0,
        "℃"
      ),
      183: new DeviceSetInfoDefinitionNumber(
        "透析液温度操作範囲下限",
        "透析液温度操作範囲",
        33.0,
        40.0,
        3,
        1,
        33.0,
        "℃"
      ),
      268: new DeviceSetInfoDefinitionRadio(
        "透析液流量　設定方法",
        "透析液流量　設定方法",
        [{ 1: "流量設定" }, { 2: "比率設定" }],
        "1"
      ),
      269: new DeviceSetInfoDefinitionNumber(
        "透析液流量　比率設定",
        "透析液流量　比率設定",
        1.0,
        3.0,
        2,
        1,
        2.0
      ),
      24: new DeviceSetInfoDefinitionNumber(
        "シングルニードル切替圧上限",
        "シングルニードル切替圧",
        0,
        400,
        3,
        0,
        200,
        "mmHg"
      ),
      25: new DeviceSetInfoDefinitionNumber(
        "シングルニードル切替圧下限",
        "シングルニードル切替圧",
        0,
        400,
        3,
        0,
        100,
        "mmHg"
      ),
      241: new DeviceSetInfoDefinitionRadio(
        "ＴＭＰゼロ補正の選択",
        "ＴＭＰゼロ補正の選択",
        [{ 0: "あり" }, { 1: "なし" }],
        "0"
      ),
      168: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報上限HD",
        "HD",
        0,
        100,
        3,
        0,
        50,
        "mmHg"
      ),
      169: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報下限HD",
        "HD",
        -100,
        0,
        3,
        0,
        -50,
        "mmHg"
      ),
      171: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報上限ECUM",
        "ECUM",
        0,
        100,
        3,
        0,
        50,
        "mmHg"
      ),
      172: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報下限ECUM",
        "ECUM",
        -100,
        0,
        3,
        0,
        -50,
        "mmHg"
      ),
      174: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報上限HDF",
        "HDF",
        0,
        100,
        3,
        0,
        50,
        "mmHg"
      ),
      175: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報下限HDF",
        "HDF",
        -100,
        0,
        3,
        0,
        -50,
        "mmHg"
      ),
      177: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報上限HF",
        "HF",
        0,
        100,
        3,
        0,
        50,
        "mmHg"
      ),
      178: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報下限HF",
        "HF",
        -100,
        0,
        3,
        0,
        -50,
        "mmHg"
      ),
      391: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報上限OHDF",
        "OHDF",
        0,
        100,
        3,
        0,
        50,
        "mmHg"
      ),
      392: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報下限OHDF",
        "OHDF",
        -100,
        0,
        3,
        0,
        -50,
        "mmHg"
      ),
      394: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報上限OHF",
        "OHF",
        0,
        100,
        3,
        0,
        50,
        "mmHg"
      ),
      395: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報下限OHF",
        "OHF",
        -100,
        0,
        3,
        0,
        -50,
        "mmHg"
      ),
      383: new DeviceSetInfoDefinitionNumber(
        "補液量設定値制限（OHDF・OHF用）",
        "補液量設定値制限（OHDF・OHF用）",
        0.0,
        240.0,
        4,
        1,
        1.0,
        "L"
      ),
      389: new DeviceSetInfoDefinitionRadio(
        "OHDF/OHF補液計算優先項目選択",
        "補液計算優先項目",
        [
          { 0: "補液速度算出" },
          { 1: "補液量設定算出" },
          { 2: "補液比率" },
          { 3: "濾過率から算出" }
        ],
        "0"
      ),
      379: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"前補液  OHDF/OHF  補液速度比率",*/
        "OHDF/OHF　補液速度比率　前補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        999,
        3,
        0,
        20,
        "%"
      ),
      398: new DeviceSetInfoDefinitionNumber(
        "補液開始遅延時間",
        "補液開始遅延時間",
        0,
        60,
        2,
        0,
        0,
        "分"
      ),
      369: new DeviceSetInfoDefinitionRadio(
        "DP=Qd+Qs(補液速度加算)",
        "DP=Qd+Qs(補液速度加算)",
        [{ 1: "使用しない" }, { 2: "使用する" }],
        "1"
      ),
      90: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"前補液  濾過率",*/
        "濾過率　前補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        70,
        2,
        0,
        50,
        "%"
      ),
      91: new DeviceSetInfoDefinitionNumber(
        "ヘマトクリット（Ht）",
        "ヘマトクリット(Ht) / 検査日時",
        0,
        60,
        2,
        0,
        33,
        "%"
      ),
      92: new DeviceSetInfoDefinitionNumber(
        "総タンパク(TP)",
        "総タンパク(TP) / 検査日時",
        0.0,
        9.0,
        2,
        1,
        6.5,
        "g/dL"
      ),
      336: new DeviceSetInfoDefinitionNumber(
        "補液速度",
        "補液速度",
        40,
        300,
        3,
        0,
        100,
        "mL/min"
      ),
      337: new DeviceSetInfoDefinitionNumber(
        "補液量",
        "補液量",
        10,
        500,
        3,
        0,
        100,
        "mL"
      ),
      185: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"補液速度操作範囲上限（HDF）",*/
        "速度操作範囲上限（HDF）前補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "速度操作範囲上限（HDF）",
        0.1,
        6.0,
        3,
        2,
        6.0,
        "L/h"
      ),
      186: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"補液速度操作範囲上限（HF）",*/
        "速度操作範囲上限（HF）前補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "速度操作範囲上限（HF）",
        0.1,
        6.0,
        3,
        2,
        6.0,
        "L/h"
      ),
      396: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"補液速度操作範囲上限（OHDF）",*/
        "速度操作範囲上限（OHDF)　前補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "速度操作範囲上限（OHDF）",
        0.1,
        24.0,
        4,
        2,
        12.0,
        "L/h"
      ),
      397: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"補液速度操作範囲上限（OHF）",*/
        "速度操作範囲上限（OHF)　前補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "速度操作範囲上限（OHF）",
        0.1,
        24.0,
        4,
        2,
        12.0,
        "L/h"
      ),
      384: new DeviceSetInfoDefinitionRadio(
        "AFBF　補液比率使用選択",
        "AFBF　補液比率使用選択",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "1"
      ),
      385: new DeviceSetInfoDefinitionNumber(
        "AFBF　補液比率",
        "AFBF　補液比率",
        10.0,
        20.0,
        3,
        1,
        13.0,
        "%"
      ),
      386: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"補液速度設定範囲上限（AFBF）",*/
        "補液速度設定範囲（AFBF）　上限",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "速度操作範囲",
        0.0,
        6.0,
        3,
        2,
        2.5,
        "L/h"
      ),
      387: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"補液速度設定範囲下限（AFBF）",*/
        "補液速度設定範囲（AFBF）　下限",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "速度操作範囲",
        0.0,
        6.0,
        3,
        2,
        1.0,
        "L/h"
      ),
      472: new DeviceSetInfoDefinitionNumber(
        "TMP閾値 速度低下",
        "TMP閾値 速度低下",
        0,
        500,
        3,
        0,
        0,
        "mmHg"
      ),
      473: new DeviceSetInfoDefinitionNumber(
        "TMP閾値 速度復帰",
        "TMP閾値 速度復帰",
        0,
        500,
        3,
        0,
        0,
        "mmHg"
      ),
      474: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"補液量 速度低下",*/
        "速度変化率　速度低下",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "補液量 速度低下",
        0,
        100,
        3,
        0,
        5,
        "%"
      ),
      475: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"補液量 速度復帰",*/
        "速度変化率　速度復帰",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "補液量 速度復帰",
        0,
        100,
        3,
        0,
        5,
        "%"
      )
    },
    B: {
      37: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報上限（HD+補液）",
        "HD+補液",
        0,
        100,
        3,
        0,
        50,
        "mmHg"
      ),
      38: new DeviceSetInfoDefinitionNumber(
        "ＴＭＰゼロ補正警報下限（HD+補液）",
        "HD+補液",
        -100,
        0,
        3,
        0,
        -50,
        "mmHg"
      ),
      39: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  OHDF/OHF  補液速度比率",*/
        "OHDF/OHF　補液速度比率　後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        50,
        2,
        0,
        20,
        "%"
      ),
      40: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  濾過率",*/
        "濾過率　後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        50,
        2,
        0,
        40,
        "%"
      ),
      30: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"前補液 補液速度操作範囲上限（HD+補液）",*/
        "速度操作範囲上限（HD+補液)　前補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "速度操作範囲上限（HD+補液）",
        0.1,
        18.0,
        4,
        2,
        12.0,
        "L/h"
      ),
      31: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  補液速度操作範囲上限（HDF）",*/
        "速度操作範囲上限（HDF）後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "後補液　補液速度操作範囲上限（HDF）",
        0.1,
        6.0,
        3,
        2,
        6.0,
        "L/h"
      ),
      32: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  補液速度操作範囲上限（HF）",*/
        "速度操作範囲上限（HF）　後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "後補液　補液速度操作範囲上限（HF）",
        0.1,
        6.0,
        3,
        2,
        6.0,
        "L/h"
      ),
      33: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  補液速度操作範囲上限（HD+補液）",*/
        "速度操作範囲上限（HD+補液)　後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "後補液　補液速度操作範囲上限（HD+補液）",
        0.1,
        18.0,
        4,
        2,
        6.0,
        "L/h"
      ),
      34: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  補液速度操作範囲上限（OHDF）",*/
        "速度操作範囲上限（OHDF)　後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "後補液　補液速度操作範囲上限（OHDF）",
        0.1,
        12.0,
        4,
        2,
        6.0,
        "L/h"
      ),
      35: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  補液速度操作範囲上限（OHF）",*/
        "速度操作範囲上限（OHF)　後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "後補液　補液速度操作範囲上限（OHF）",
        0.1,
        12.0,
        4,
        2,
        6.0,
        "L/h"
      )
    },
    C: {
      91: new DeviceSetInfoDefinitionNumber(
        "検査日時(ヘマトクリット（Ht）)",
        "",
        "",
        "",
        "",
        "",
        "-",
        ""
      ),
      92: new DeviceSetInfoDefinitionNumber(
        "検査日時(総タンパク(TP))",
        "",
        "",
        "",
        "",
        "",
        "-",
        ""
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(プライミング)
 */
export const valueInfoPri = {
  dev: {
    A: {
      370: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"自動回収  使用液量",*/
        "返血機能使用液量",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        10,
        999,
        3,
        0,
        200,
        "mL"
      ),
      371: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"自動回収  流速",*/
        "返血機能流速",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        600,
        3,
        0,
        100,
        "mL/min"
      ),
      372: new DeviceSetInfoDefinitionRadio(
        "自動回収　血液判別器による終了選択",
        "",
        [{ 0: "OFF" }, { 1: "ON" }],
        "0"
      )
    }
  },
  pat: {
    A: {
      228: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"プライミング補助液交換量",*/
        "プライミング補助液交換量液量",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        2000,
        4,
        0,
        800,
        "mL"
      ),
      230: new DeviceSetInfoDefinitionNumber(
        "プライミング補助間欠動作停止時間",
        "",
        0.5,
        9.9,
        2,
        1,
        1.0,
        "sec"
      ),
      229: new DeviceSetInfoDefinitionNumber(
        "プライミング補助間欠動作動作時間",
        "",
        0.5,
        9.9,
        2,
        1,
        2.0,
        "sec"
      ),
      223: new DeviceSetInfoDefinitionNumber(
        "プライミング補助気泡抜き液量",
        "",
        0,
        2000,
        4,
        0,
        400,
        "mL"
      ),
      227: new DeviceSetInfoDefinitionRadio(
        "プライミング補助気泡抜き間欠動作選択",
        "",
        [{ 0: "連続" }, { 1: "間欠" }],
        "0"
      ),
      224: new DeviceSetInfoDefinitionNumber(
        "プライミング補助気泡抜き流速",
        "",
        0,
        600,
        3,
        0,
        300,
        "mL/min"
      ),
      221: new DeviceSetInfoDefinitionNumber(
        "プライミング補助静脈充填液量",
        "",
        0,
        2000,
        4,
        0,
        400,
        "mL"
      ),
      226: new DeviceSetInfoDefinitionRadio(
        "プライミング補助静脈充填後継続の有無",
        "",
        [{ 0: "継続しない" }, { 1: "継続する" }],
        "0"
      ),
      222: new DeviceSetInfoDefinitionNumber(
        "プライミング補助静脈充填流速",
        "",
        0,
        600,
        3,
        0,
        100,
        "mL/min"
      ),
      219: new DeviceSetInfoDefinitionNumber(
        "プライミング補助動脈充填液量",
        "",
        0,
        2000,
        4,
        0,
        200,
        "mL"
      ),
      225: new DeviceSetInfoDefinitionRadio(
        "プライミング補助動脈充填後継続の有無",
        "",
        [{ 0: "継続しない" }, { 1: "継続する" }],
        "0"
      ),
      220: new DeviceSetInfoDefinitionNumber(
        "プライミング補助動脈充填流速",
        "",
        0,
        600,
        3,
        0,
        100,
        "mL/min"
      ),
      231: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"自動プライミング開始時間",*/
        "自動プライミング透析開始前",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        1439,
        4,
        0,
        420,
        "min"
      ),
      237: new DeviceSetInfoDefinitionNumber(
        "自動プライミング循環時間",
        "",
        0,
        999,
        3,
        0,
        300,
        "sec"
      ),
      236: new DeviceSetInfoDefinitionNumber(
        "自動プライミング循環流速",
        "",
        0,
        600,
        3,
        0,
        400,
        "mL/min"
      ),
      238: new DeviceSetInfoDefinitionNumber(
        "自動プライミング総量",
        "",
        0,
        2000,
        4,
        0,
        600,
        "mL"
      ),
      233: new DeviceSetInfoDefinitionNumber(
        "自動プライミング送液液量",
        "",
        0,
        999,
        3,
        0,
        250,
        "mL"
      ),
      234: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"自動プライミング送液流速1回目",*/
        "自動プライミング送液1回目",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        600,
        3,
        0,
        250,
        "mL/min"
      ),
      235: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"自動プライミング送液流速2回目以降",*/
        "自動プライミング送液2回目以降",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        600,
        3,
        0,
        400,
        "mL/min"
      ),
      232: new DeviceSetInfoDefinitionNumber(
        "自動プライミング落差時間",
        "",
        0,
        999,
        3,
        0,
        40,
        "sec"
      )
    },

    B: {
      32: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"動脈チャンバ液面作成時間",*/
        "オンラインプライミング動脈チャンバ液面作成時間前補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        90,
        600,
        3,
        0,
        90,
        "sec"
      ),
      33: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"循環洗浄時間",*/
        "オンラインプライミング循環洗浄時間前補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        3,
        10,
        2,
        0,
        3,
        "min"
      ),
      51: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  ダイアライザー気泡抜き時間",*/
        "オンラインプライミングダイアライザ気泡抜き時間後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        2,
        10,
        2,
        0,
        2,
        "min"
      ),
      52: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  動脈チャンバ液面作成時間",*/
        "オンラインプライミング動脈チャンバ液面作成時間後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        60,
        120,
        3,
        0,
        60,
        "sec"
      ),
      53: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"後補液  循環洗浄時間",*/
        "オンラインプライミング循環洗浄時間後補液",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        3,
        10,
        2,
        0,
        3,
        "min"
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(警報点)
 */
export const valueInfoWar = {
  dev: {
    A: {
      240: new DeviceSetInfoDefinitionRadio(
        "ＴＭＰ監視モード",
        "",
        [{ 0: "TMP自動追従" }, { 1: "TMP自動設定" }, { 2: "透析液圧" }],
        "0"
      ),
      100: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧自動設定警報幅上限HD/ECUM",*/
        "HD/ECUM 静脈圧 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        50
      ),
      101: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧自動設定警報幅下限HD/ECUM",*/
        "HD/ECUM 静脈圧 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -30
      ),
      102: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧自動設定警報限界上限",*/
        "HD/ECUM 静脈圧 自動設定警報限界値上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        500,
        3,
        0,
        300
      ),
      103: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧自動設定警報限界下限",*/
        "HD/ECUM 静脈圧 自動設定警報限界値下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        500,
        3,
        0,
        10
      ),
      104: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧固定警報上限",*/
        "HD/ECUM 静脈圧 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        500,
        3,
        0,
        300
      ),
      105: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧固定警報下限",*/
        "HD/ECUM 静脈圧 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        500,
        3,
        0,
        -50
      ),
      152: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧自動設定警報幅上限HD/ECUM",*/
        "HD/ECUM ダイアライザ入口圧 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        50
      ),
      153: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧自動設定警報幅下限HD/ECUM",*/
        "HD/ECUM ダイアライザ入口圧 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -50
      ),
      154: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧自動設定警報限界上限",*/
        "HD/ECUM ダイアライザ入口圧 自動設定警報限界値上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        600,
        3,
        0,
        300
      ),
      155: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧自動設定警報限界下限",*/
        "HD/ECUM ダイアライザ入口圧 自動設定警報限界値下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        600,
        3,
        0,
        0
      ),
      156: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧固定警報上限",*/
        "HD/ECUM ダイアライザ入口圧 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        600,
        3,
        0,
        300
      ),
      157: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧固定警報下限",*/
        "HD/ECUM ダイアライザ入口圧 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        600,
        3,
        0,
        -50
      ),
      112: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報幅上限HD/ECUM",*/
        "HD/ECUM 液圧 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        50
      ),
      113: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報幅下限HD/ECUM",*/
        "HD/ECUM 液圧 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -50
      ),
      114: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報限界上限",*/
        "HD/ECUM 液圧 自動設定警報限界値上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        400,
        3,
        0,
        300
      ),
      115: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報限界下限",*/
        "HD/ECUM 液圧 自動設定警報限界値下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        400,
        3,
        0,
        -300
      ),
      116: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧固定警報上限",*/
        "HD/ECUM 液圧 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        400,
        3,
        0,
        300
      ),
      117: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧固定警報下限",*/
        "HD/ECUM 液圧 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        400,
        3,
        0,
        -300
      ),
      128: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報幅上限HD/ECUM",*/
        "HD/ECUM ＴＭＰ 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        50
      ),
      129: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報幅下限HD/ECUM",*/
        "HD/ECUM ＴＭＰ 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -50
      ),
      130: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報限界上限",*/
        "HD/ECUM ＴＭＰ 自動設定警報限界値上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -100,
        500,
        3,
        0,
        500
      ),
      131: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報限界下限",*/
        "HD/ECUM ＴＭＰ 自動設定警報限界値下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -100,
        500,
        3,
        0,
        -30
      ),
      132: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ固定警報上限",*/
        "HD/ECUM ＴＭＰ 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -100,
        500,
        3,
        0,
        500
      ),
      133: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ固定警報下限",*/
        "HD/ECUM ＴＭＰ 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -100,
        500,
        3,
        0,
        -30
      ),
      126: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動追従警報幅上限HD/ECUM",*/
        "HD/ECUM ＴＭＰ 自動追従警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        20
      ),
      127: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動追従警報幅下限HD/ECUM",*/
        "HD/ECUM ＴＭＰ 自動追従警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -20
      ),
      146: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー差圧自動設定警報幅上限HD/ECUM",*/
        "HD/ECUM 差圧 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        20
      ),
      147: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー差圧自動設定警報幅下限HD/ECUM",*/
        "HD/ECUM 差圧 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -20
      ),
      148: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー差圧固定警報上限",*/
        "HD/ECUM 差圧 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        400,
        3,
        0,
        80
      ),
      149: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー差圧固定警報下限",*/
        "HD/ECUM 差圧 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        400,
        3,
        0,
        0
      ),
      106: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧自動設定警報幅上限HDF/HF",*/
        "HDF/HF 静脈圧 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        70
      ),
      107: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧自動設定警報幅下限HDF/HF",*/
        "HDF/HF 静脈圧 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -70
      ),
      158: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧自動設定警報幅上限HDF/HF",*/
        "HDF/HF ダイアライザ入口圧 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        70
      ),
      159: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧自動設定警報幅下限HDF/HF",*/
        "HDF/HF ダイアライザ入口圧 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -70
      ),
      118: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報幅上限HDF/HF",*/
        "HDF/HF 液圧 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        70
      ),
      119: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報幅下限HDF/HF",*/
        "HDF/HF 液圧 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -70
      ),
      136: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報幅上限HDF/HF",*/
        "HDF/HF ＴＭＰ 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        70
      ),
      137: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報幅下限HDF/HF",*/
        "HDF/HF ＴＭＰ 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -70
      ),
      134: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動追従警報幅上限HDF/HF",*/
        "HDF/HF ＴＭＰ 自動追従警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        50
      ),
      135: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動追従警報幅下限HDF/HF",*/
        "HDF/HF ＴＭＰ 自動追従警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -50
      ),
      150: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー差圧自動設定警報幅上限HDF/HF",*/
        "HDF/HF 差圧 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        50
      ),
      151: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー差圧自動設定警報幅下限HDF/HF",*/
        "HDF/HF 差圧 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -50
      ),
      110: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧固定警報上限ＳＮ",*/
        "シングルニードル 静脈圧 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        500,
        3,
        0,
        400
      ),
      111: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧固定警報下限ＳＮ",*/
        "シングルニードル 静脈圧 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        500,
        3,
        0,
        -50
      ),
      162: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧固定警報上限ＳＮ",*/
        "シングルニードル ダイアライザ入口圧 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        600,
        3,
        0,
        500
      ),
      163: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧固定警報下限ＳＮ",*/
        "シングルニードル ダイアライザ入口圧 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        600,
        3,
        0,
        -50
      ),
      120: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報幅上限ＳＮ",*/
        "シングルニードル 液圧 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        70
      ),
      121: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報幅下限ＳＮ",*/
        "シングルニードル 液圧 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -70
      ),
      122: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報限界上限ＳＮ",*/
        "シングルニードル 液圧 自動設定警報限界値上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        400,
        3,
        0,
        300
      ),
      123: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧自動設定警報限界下限ＳＮ",*/
        "シングルニードル 液圧 自動設定警報限界値下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        400,
        3,
        0,
        -300
      ),
      124: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧固定警報上限ＳＮ",*/
        "シングルニードル 液圧 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        400,
        3,
        0,
        300
      ),
      125: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"液圧固定警報下限ＳＮ",*/
        "シングルニードル 液圧 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        400,
        3,
        0,
        -300
      ),
      140: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報幅上限ＳＮ",*/
        "シングルニードル ＴＭＰ 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        70
      ),
      141: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報幅下限ＳＮ",*/
        "シングルニードル ＴＭＰ 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -70
      ),
      142: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報限界上限ＳＮ",*/
        "シングルニードル ＴＭＰ 自動設定警報限界値上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -100,
        500,
        3,
        0,
        500
      ),
      143: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動設定警報限界下限ＳＮ",*/
        "シングルニードル ＴＭＰ 自動設定警報限界値下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -100,
        500,
        3,
        0,
        -30
      ),
      144: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ固定警報上限ＳＮ",*/
        "シングルニードル ＴＭＰ 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -100,
        500,
        3,
        0,
        500
      ),
      145: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ固定警報下限ＳＮ",*/
        "シングルニードル ＴＭＰ 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -100,
        500,
        3,
        0,
        -30
      ),
      138: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動追従警報幅上限ＳＮ",*/
        "シングルニードル ＴＭＰ 自動追従警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        400,
        3,
        0,
        50
      ),
      139: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ＴＭＰ自動追従警報幅下限ＳＮ",*/
        "シングルニードル ＴＭＰ 自動追従警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -400,
        0,
        3,
        0,
        -50
      ),
      108: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧固定警報上限準備回収",*/
        "準備回収 静脈圧 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        500,
        3,
        0,
        400
      ),
      109: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"静脈圧固定警報下限準備回収",*/
        "準備回収 静脈圧 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        500,
        3,
        0,
        -200
      ),
      160: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧固定警報上限準備回収",*/
        "準備回収 ダイアライザ入口圧 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        600,
        3,
        0,
        500
      ),
      161: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"ダイアライザー入口圧固定警報下限準備回収",*/
        "準備回収 ダイアライザ入口圧 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -200,
        600,
        3,
        0,
        -200
      ),
      254: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"Ｎａ濃度自動設定警報幅上限",*/
        "準備回収 Ｎａ濃度 自動設定警報幅上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        0,
        50,
        2,
        0,
        5
      ),
      255: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"Ｎａ濃度自動設定警報幅下限",*/
        "準備回収 Ｎａ濃度 自動設定警報幅下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        -50,
        0,
        2,
        0,
        -5
      ),
      256: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"Ｎａ濃度固定警報上限",*/
        "準備回収 Ｎａ濃度 固定警報点上限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        100,
        200,
        3,
        0,
        190
      ),
      257: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"Ｎａ濃度固定警報下限",*/
        "準備回収 Ｎａ濃度 固定警報点下限値",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "",
        100,
        200,
        3,
        0,
        120
      ),
      242: new DeviceSetInfoDefinitionRadio(
        "静脈圧自動設定警報監視有無",
        "",
        [{ 0: "無" }, { 1: "有" }],
        "1"
      ),
      243: new DeviceSetInfoDefinitionRadio(
        "ダイアライザー血液入口圧自動設定警報監視有無",
        "",
        [{ 0: "無" }, { 1: "有" }],
        "1"
      ),
      244: new DeviceSetInfoDefinitionRadio(
        "透析液圧自動設定警報監視有無",
        "",
        [{ 0: "無" }, { 1: "有" }],
        "1"
      ),
      245: new DeviceSetInfoDefinitionRadio(
        "ＴＭＰ自動設定警報監視有無",
        "",
        [{ 0: "無" }, { 1: "有" }],
        "1"
      ),
      246: new DeviceSetInfoDefinitionRadio(
        "差圧自動設定警報監視有無",
        "",
        [{ 0: "無" }, { 1: "有" }],
        "1"
      ),
      247: new DeviceSetInfoDefinitionRadio(
        "Ｎａ濃度自動設定警報監視有無",
        "",
        [{ 0: "無" }, { 1: "有" }],
        "1"
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(ECUM)
 */
export const valueInfoEcum = {
  dev: {
    A: {
      16: new DeviceSetInfoDefinitionRadio(
        "ＥＣＵＭ選択",
        "ECUM選択",
        [{ 0: "HD" }, { 1: "ECUM" }],
        "0"
      ),
      17: new DeviceSetInfoDefinitionNumber(
        "ＥＣＵＭ量",
        "ECUM量",
        0.0,
        31.93,
        4,
        2,
        0.0,
        "L"
      ),
      18: new DeviceSetInfoDefinitionTime(
        "ＥＣＵＭ時間",
        "ECUM時間",
        "00:00",
        "07:59",
        30
      ),
      19: new DeviceSetInfoDefinitionRadio(
        "ＥＣＵＭ時間カウント選択",
        "ECUM時間カウント選択",
        [{ 1: "透析時間に含む" }, { 0: "含まない" }],
        "0"
      )
    }
  }
};

/**c
 * @description 装置設定値情報定義(濃度プロ自動設定警報)
 */
export const valueInfoCpro = {
  dev: {
    A: {
      252: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム自動設定警報幅上限",
        "",
        0.0,
        9.9,
        2,
        1,
        5.0,
        "%",
        0.1
      ),
      253: new DeviceSetInfoDefinitionNumber(
        "Ｂ液濃度プログラム自動設定警報幅下限",
        "",
        -9.9,
        0.0,
        2,
        1,
        -5.0,
        "%"
      ),
      250: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム自動設定警報幅上限",
        "",
        0.0,
        9.9,
        2,
        1,
        5.0,
        "%"
      ),
      251: new DeviceSetInfoDefinitionNumber(
        "透析液濃度プログラム自動設定警報幅下限",
        "",
        -9.9,
        0.0,
        2,
        1,
        -5.0,
        "%"
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(透析量プログラム)
 */
export const valueInfoDia = {
  dev: {
    A: {
      282: new DeviceSetInfoDefinitionRadio(
        "透析量プログラム使用選択",
        "",
        [{ 0: "使用しない" }, { 1: "使用する" }],
        "0"
      ),
      288: new DeviceSetInfoDefinitionNumber(
        "目標Kt/V",
        "目標Kt/V",
        0.01,
        3.0,
        3,
        2,
        null
      )
    }
  }
};

/**
 * @description 装置設定値情報定義(静的静脈圧)
 */
export const valueInfoIap = {
  dev: {
    A: {
      468: new DeviceSetInfoDefinitionNumber(
        "VA確認報知基準値(静的静脈圧)",
        "VA確認報知基準値(静的静脈圧)",
        0,
        200,
        3,
        0,
        80,
        "mmHg"
      ),
      469: new DeviceSetInfoDefinitionNumber(
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 start */
        /*"VA確認報知基準値(アクセス内圧力比率)",*/
        "VA確認報知基準値(IAP ratio)",
        /*mod FNSI-改修内容装置設定ポップアップメッセージ改修 趙慧敏 end */
        "VA確認報知基準値(IAP ratio)",
        0.0,
        2.0,
        1,
        2,
        0.5,
        "%"
      ),
      470: new DeviceSetInfoDefinitionRadio(
        "静的静脈圧記録 自動実施選択",
        "静的静脈圧記録 自動実施選択",
        [{ 1: "実施しない" }, { 2: "脱血時" }, { 3: "返血時" }],
        "1"
      ),
      471: new DeviceSetInfoDefinitionRadio(
        "血圧測定 自動実施選択",
        "血圧測定 自動実施選択",
        [{ 0: "実施しない" }, { 1: "実施する" }],
        "0"
      )
    }
  }
};

export const defaultDeviceInfo = {
  [DEVICE_TYPE_OPE]: {
    dev: {
      A: {
        // del MC対象のため、一時コメントアウト 趙 start
        /* add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 start */
        // 476: null,
        // 477: null,
        /* add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 end */
        // del MC対象のため、一時コメントアウト 趙 end
        179: null,
        181: null,
        38: null,
        21: null,
        22: null,
        39: null,
        182: null,
        183: null,
        268: null,
        269: null,
        24: null,
        25: null,
        241: null,
        168: null,
        169: null,
        171: null,
        172: null,
        174: null,
        175: null,
        177: null,
        178: null,
        391: null,
        392: null,
        394: null,
        395: null,
        383: null,
        389: null,
        379: null,
        398: null,
        369: null,
        90: null,
        91: null,
        92: null,
        336: null,
        337: null,
        185: null,
        186: null,
        396: null,
        397: null,
        384: null,
        385: null,
        386: null,
        387: null,
        472: null,
        473: null,
        474: null,
        475: null
      },

      B: {
        37: null,
        38: null,
        39: null,
        40: null,
        30: null,
        31: null,
        32: null,
        33: null,
        34: null,
        35: null
      },

      C: {
        91: null,
        92: null
      }
    }
  },

  [DEVICE_TYPE_BP]: {
    dev: {
      A: {
        211: null,
        212: null,
        213: null,
        214: null,
        215: null,
        216: null,
        217: null,
        218: null,
        227: null,
        219: null,
        228: null,
        220: null,
        229: null,
        221: null,
        230: null,
        222: null,
        231: null,
        223: null,
        232: null,
        224: null,
        233: null,
        225: null,
        234: null,
        226: null,
        191: null,
        190: null,
        192: null,
        193: null,
        195: null,
        239: null,
        194: null,
        235: null,
        236: null,
        237: null,
        238: null
      }
    }
  },

  [DEVICE_TYPE_WAR]: {
    dev: {
      A: {
        240: null,
        100: null,
        101: null,
        102: null,
        103: null,
        104: null,
        105: null,
        152: null,
        153: null,
        154: null,
        155: null,
        156: null,
        157: null,
        112: null,
        113: null,
        114: null,
        115: null,
        116: null,
        117: null,
        128: null,
        129: null,
        130: null,
        131: null,
        132: null,
        133: null,
        126: null,
        127: null,
        146: null,
        147: null,
        148: null,
        149: null,
        106: null,
        107: null,
        158: null,
        159: null,
        118: null,
        119: null,
        136: null,
        137: null,
        134: null,
        135: null,
        150: null,
        151: null,
        110: null,
        111: null,
        162: null,
        163: null,
        120: null,
        121: null,
        122: null,
        123: null,
        124: null,
        125: null,
        140: null,
        141: null,
        142: null,
        143: null,
        144: null,
        145: null,
        138: null,
        139: null,
        108: null,
        109: null,
        160: null,
        161: null,
        254: null,
        255: null,
        256: null,
        257: null,
        242: null,
        243: null,
        244: null,
        245: null,
        246: null,
        247: null
      }
    }
  },

  [DEVICE_TYPE_BV]: {
    dev: {
      A: {
        267: null,
        260: null,
        261: null,
        262: null,
        277: null,
        278: null,
        // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
        476: null,
        // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
        258: null,
        259: null,
        263: null,
        264: null,
        265: null,
        266: null,
        281: null
      }
    }
  },

  [DEVICE_TYPE_PRI]: {
    dev: {
      A: {
        370: null,
        371: null,
        372: null
      }
    },

    pat: {
      A: {
        228: null,
        230: null,
        229: null,
        223: null,
        227: null,
        224: null,
        221: null,
        226: null,
        222: null,
        219: null,
        225: null,
        220: null,
        231: null,
        237: null,
        236: null,
        238: null,
        233: null,
        234: null,
        235: null,
        232: null
      },

      B: {
        32: null,
        33: null,
        51: null,
        52: null,
        53: null
      }
    }
  },

  [DEVICE_TYPE_DFAS]: {
    dev: {
      A: {
        339: null,
        333: null,
        331: null,
        334: null,
        338: null,
        332: null,
        373: null,
        374: null,
        377: null,
        270: null,
        376: null,
        378: null
      },

      B: {
        36: null
      }
    },

    pat: {
      B: {
        1: null,
        5: null,
        7: null,
        8: null,
        9: null,
        10: null,
        11: null,
        59: null,
        54: null,
        55: null,
        56: null,
        57: null,
        58: null
      }
    }
  },

  [DEVICE_TYPE_ECUM]: {
    dev: {
      A: {
        16: null,
        17: null,
        18: null,
        19: null
      }
    }
  },

  [DEVICE_TYPE_CPRO]: {
    dev: {
      A: {
        252: null,
        253: null,
        250: null,
        251: null
      }
    }
  },
  [DEVICE_TYPE_UFR]: {
    dev: {
      A: {
        290: null,
        311: null,
        312: null,
        291: null,
        292: null,
        293: null,
        294: null,
        295: null,
        296: null,
        297: null,
        298: null,
        299: null,
        300: null,
        301: null,
        302: null,
        303: null,
        304: null,
        305: null,
        306: null,
        307: null,
        308: null,
        309: null,
        310: null,
        313: null,
        314: null
      },

      B: {
        // 301-310 の4分の1
        0: null,
        1: null,
        2: null,
        3: null,
        4: null,
        5: null,
        6: null,
        7: null,
        8: null,
        9: null
      }
    }
  },

  [DEVICE_TYPE_NA]: {
    dev: {
      A: {
        315: null,
        326: null,
        328: null,
        327: null,
        316: null,
        317: null,
        318: null,
        319: null,
        320: null,
        321: null,
        322: null,
        323: null,
        324: null,
        325: null,
        329: null,
        330: null,
        184: null
      }
    }
  },

  [DEVICE_TYPE_DC]: {
    dev: {
      A: {
        340: null,
        368: null,
        367: null,
        361: null,
        341: null,
        342: null,
        343: null,
        344: null,
        345: null,
        346: null,
        347: null,
        348: null,
        349: null,
        350: null,
        362: null,
        363: null,
        364: null,
        351: null,
        352: null,
        353: null,
        354: null,
        355: null,
        356: null,
        357: null,
        358: null,
        359: null,
        360: null,
        365: null,
        366: null
      },

      B: {
        20: null,
        21: null,
        22: null,
        23: null,
        24: null,
        25: null,
        26: null,
        27: null,
        28: null,
        29: null,
        10: null,
        11: null,
        12: null,
        13: null,
        14: null,
        15: null,
        16: null,
        17: null,
        18: null,
        19: null
      }
    }
  },

  [DEVICE_TYPE_QBQD]: {
    dev: {
      A: {
        430: null,
        429: null,
        400: null,
        401: null,
        402: null,
        403: null,
        404: null,
        405: null,
        406: null,
        407: null,
        408: null,
        409: null,
        431: null,
        410: null,
        411: null,
        412: null,
        413: null,
        414: null,
        415: null,
        416: null,
        417: null,
        418: null,
        419: null,
        420: null,
        421: null,
        422: null,
        423: null,
        424: null,
        425: null,
        426: null,
        427: null,
        428: null
      }
    }
  },

  [DEVICE_TYPE_IHDF]: {
    dev: {
      A: {
        201: null,
        203: null,
        200: null,
        204: null,
        202: null,
        205: null,
        432: null,
        433: null,
        434: null,
        435: null,
        436: null,
        437: null,
        438: null,
        439: null,
        440: null,
        441: null,
        442: null,
        443: null,
        444: null,
        445: null,
        446: null,
        447: null,
        448: null,
        449: null,
        450: null,
        451: null,
        452: null,
        453: null,
        454: null,
        455: null,
        456: null,
        457: null,
        458: null,
        459: null,
        460: null,
        461: null,
        462: null,
        463: null,
        464: null,
        465: null,
        466: null
      }
    }
  },

  [DEVICE_TYPE_BVUFC]: {
    dev: {
      A: {
        196: null,
        197: null,
        198: null,
        199: null,
        206: null,
        207: null,
        208: null,
        209: null,
        210: null,
        248: null,
        249: null,
        271: null,
        272: null,
        273: null,
        274: null,
        275: null
      }
    }
  },

  [DEVICE_TYPE_DIA]: {
    dev: {
      A: {
        282: null,
        288: null
      }
    }
  }
};

export const defaultMstDeviceInfo = {
  pat: {
    [DEVICE_TYPE_OPE]: {
      dev: {
        A: {
          // del MC対象のため、一時コメントアウト 趙 start
          /* add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 start */
          // 476: null,
          // 477: null,
          /* add FNSI-No.ies477 操作範囲に表示項目を追加する 趙 end */
          // del MC対象のため、一時コメントアウト 趙 end
          179: null,
          181: null,
          38: null,
          21: null,
          22: null,
          39: null,
          182: null,
          183: null,
          268: null,
          269: null,
          24: null,
          25: null,
          241: null,
          168: null,
          169: null,
          171: null,
          172: null,
          174: null,
          175: null,
          177: null,
          178: null,
          391: null,
          392: null,
          394: null,
          395: null,
          383: null,
          389: null,
          379: null,
          398: null,
          369: null,
          90: null,
          91: null,
          92: null,
          336: null,
          337: null,
          185: null,
          186: null,
          396: null,
          397: null,
          384: null,
          385: null,
          386: null,
          387: null,
          472: null,
          473: null,
          474: null,
          475: null
        },

        B: {
          37: null,
          38: null,
          39: null,
          40: null,
          30: null,
          31: null,
          32: null,
          33: null,
          34: null,
          35: null
        },

        C: {
          91: null,
          92: null
        }
      }
    },

    [DEVICE_TYPE_BP]: {
      dev: {
        A: {
          211: null,
          212: null,
          213: null,
          214: null,
          215: null,
          216: null,
          217: null,
          218: null,
          227: null,
          219: null,
          228: null,
          220: null,
          229: null,
          221: null,
          230: null,
          222: null,
          231: null,
          223: null,
          232: null,
          224: null,
          233: null,
          225: null,
          234: null,
          226: null,
          191: null,
          190: null,
          192: null,
          193: null,
          195: null,
          239: null,
          194: null,
          235: null,
          236: null,
          237: null,
          238: null
        }
      }
    },

    [DEVICE_TYPE_WAR]: {
      dev: {
        A: {
          240: null,
          100: null,
          101: null,
          102: null,
          103: null,
          104: null,
          105: null,
          152: null,
          153: null,
          154: null,
          155: null,
          156: null,
          157: null,
          112: null,
          113: null,
          114: null,
          115: null,
          116: null,
          117: null,
          128: null,
          129: null,
          130: null,
          131: null,
          132: null,
          133: null,
          126: null,
          127: null,
          146: null,
          147: null,
          148: null,
          149: null,
          106: null,
          107: null,
          158: null,
          159: null,
          118: null,
          119: null,
          136: null,
          137: null,
          134: null,
          135: null,
          150: null,
          151: null,
          110: null,
          111: null,
          162: null,
          163: null,
          120: null,
          121: null,
          122: null,
          123: null,
          124: null,
          125: null,
          140: null,
          141: null,
          142: null,
          143: null,
          144: null,
          145: null,
          138: null,
          139: null,
          108: null,
          109: null,
          160: null,
          161: null,
          254: null,
          255: null,
          256: null,
          257: null,
          242: null,
          243: null,
          244: null,
          245: null,
          246: null,
          247: null
        }
      }
    },

    [DEVICE_TYPE_BV]: {
      dev: {
        A: {
          267: null,
          260: null,
          261: null,
          262: null,
          277: null,
          278: null,
          // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
          476: null,
          // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
          258: null,
          259: null,
          263: null,
          264: null,
          265: null,
          266: null,
          281: null
        }
      }
    },

    [DEVICE_TYPE_PRI]: {
      dev: {
        A: {
          370: null,
          371: null,
          372: null
        }
      },

      pat: {
        A: {
          228: null,
          230: null,
          229: null,
          223: null,
          227: null,
          224: null,
          221: null,
          226: null,
          222: null,
          219: null,
          225: null,
          220: null,
          231: null,
          237: null,
          236: null,
          238: null,
          233: null,
          234: null,
          235: null,
          232: null
        },

        B: {
          32: null,
          33: null,
          51: null,
          52: null,
          53: null
        }
      }
    },

    [DEVICE_TYPE_DFAS]: {
      dev: {
        A: {
          339: null,
          333: null,
          331: null,
          334: null,
          338: null,
          332: null,
          373: null,
          374: null,
          377: null,
          270: null,
          376: null,
          378: null
        },

        B: {
          36: null
        }
      },

      pat: {
        B: {
          1: null,
          5: null,
          7: null,
          8: null,
          9: null,
          10: null,
          11: null,
          59: null,
          54: null,
          55: null,
          56: null,
          57: null,
          58: null
        }
      }
    },

    [DEVICE_TYPE_ECUM]: {
      dev: {
        A: {
          16: null,
          17: null,
          18: null,
          19: null
        }
      }
    },

    [DEVICE_TYPE_CPRO]: {
      dev: {
        A: {
          252: null,
          253: null,
          250: null,
          251: null
        }
      }
    },

    [DEVICE_TYPE_IAP]: {
      dev: {
        A: {
          468: null,
          469: null,
          470: null,
          471: null
        }
      }
    }
  },

  ord: {
    [DEVICE_TYPE_UFR]: {
      dev: {
        A: {
          290: null,
          311: null,
          312: null,
          291: null,
          292: null,
          293: null,
          294: null,
          295: null,
          296: null,
          297: null,
          298: null,
          299: null,
          300: null,
          301: null,
          302: null,
          303: null,
          304: null,
          305: null,
          306: null,
          307: null,
          308: null,
          309: null,
          310: null,
          313: null,
          314: null
        },

        B: {
          0: null,
          1: null,
          2: null,
          3: null,
          4: null,
          5: null,
          6: null,
          7: null,
          8: null,
          9: null
        }
      }
    },

    [DEVICE_TYPE_NA]: {
      dev: {
        A: {
          315: "0",
          326: 30,
          328: 1,
          327: "0",
          316: 0,
          317: 0,
          318: 0,
          319: 0,
          320: 0,
          321: 0,
          322: 0,
          323: 0,
          324: 0,
          325: 0,
          329: 0,
          330: 0,
          184: 50
        }
      }
    },

    [DEVICE_TYPE_DC]: {
      dev: {
        A: {
          340: "0",
          368: "0",
          367: 30,
          361: 2,
          341: 14,
          342: 14,
          343: 14,
          344: 14,
          345: 14,
          346: 13.5,
          347: 13.5,
          348: 13.5,
          349: 13.5,
          350: 13.5,
          362: 13.5,
          363: 15,
          364: 2,
          351: 2.5,
          352: 2.5,
          353: 2.5,
          354: 2.5,
          355: 2.5,
          356: 2.5,
          357: 2.5,
          358: 2.5,
          359: 2.5,
          360: 2.5,
          365: 2.5,
          366: 3
        },

        B: {
          20: 0,
          21: 0,
          22: 0,
          23: 0,
          24: 0,
          25: 0,
          26: 0,
          27: 0,
          28: 0,
          29: 0,
          10: 0,
          11: 0,
          12: 0,
          13: 0,
          14: 0,
          15: 0,
          16: 0,
          17: 0,
          18: 0,
          19: 0
        }
      }
    },

    [DEVICE_TYPE_QBQD]: {
      dev: {
        A: {
          430: null,
          429: null,
          400: null,
          401: null,
          402: null,
          403: null,
          404: null,
          405: null,
          406: null,
          407: null,
          408: null,
          409: null,
          431: null,
          410: null,
          411: null,
          412: null,
          413: null,
          414: null,
          415: null,
          416: null,
          417: null,
          418: null,
          419: null,
          420: null,
          421: null,
          422: null,
          423: null,
          424: null,
          425: null,
          426: null,
          427: null,
          428: null
        }
      }
    },

    [DEVICE_TYPE_IHDF]: {
      dev: {
        A: {
          201: 100,
          203: 30,
          200: 200,
          204: 0,
          202: 30,
          205: 1.5,
          432: "0",
          433: 7,
          434: 0,
          435: 0,
          436: 0,
          437: 0,
          438: 0,
          439: 0,
          440: 0,
          441: 0,
          442: 0,
          443: 0,
          444: 0,
          445: 0,
          446: 0,
          447: 0,
          448: 0,
          449: 0,
          450: 0,
          451: 0,
          452: 0,
          453: 0,
          454: 0,
          455: 0,
          456: 0,
          457: 0,
          458: 0,
          459: 0,
          460: 0,
          461: 0,
          462: 0,
          463: 0,
          464: 0,
          465: 0,
          466: 0,
          // mod #11166 I-HDFが保存できない zhangyue start
          // 467: 10,
          // 468: 190,
          // 469: 0
          1001: 10,
          1002: 190,
          // mod #11166 I-HDFが保存できない zhangyue end
        }
      }
    },

    [DEVICE_TYPE_BVUFC]: {
      dev: {
        A: {
          196: null,
          197: null,
          198: null,
          199: null,
          206: null,
          207: null,
          208: null,
          209: null,
          210: null,
          248: null,
          249: null,
          271: null,
          272: null,
          273: null,
          274: null,
          275: null
        }
      }
    },

    [DEVICE_TYPE_DIA]: {
      dev: {
        A: {
          282: null,
          288: null
        }
      }
    }
  }
};
