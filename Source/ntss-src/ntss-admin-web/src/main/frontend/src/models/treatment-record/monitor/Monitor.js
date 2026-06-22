import { CODES } from "@/constants/TreatmentRecord";
import {
  dateFormat,
  DATE_FORMAT,
  SHORT_TIME_FORMAT,
  date2UTC,
  parseDate
} from "@/functions/common/DateTimeUtils";
import MonitorItemsDefs from "@/models/treatment-record/monitor/monitor-items-defs.json";

export const MONITOR_ITEMS = MonitorItemsDefs.monitor_items_defs.monitor_items.map(
  e => {
    const step = 1 / 10 ** e.decimalFigure;
    let selectArray = new Array();
    // 選択肢が設定されている場合
    if (e.selectItem) {
      Object.entries(e.selectItem)
        .map(([key, value]) => (selectArray.push({cd: key, text: value})));
    }

    return {
      ...e,
      isNumber: [1, 2, 3].includes(e.dataType),
      isString: [0].includes(e.dataType),
      step: step,
      min: e.lower * step,
      max: e.upper * step,
      selectItem: e.selectItem ? selectArray : null
    };
  }
);

/**
 * 与えられたモニタ項目リストから画面表示用の項目を作成する.
 *
 * @param {*} monitorItemList モニタ項目リスト(sys_monitor_item のみ)
 * @returns 画面表示用モニタ項目のリスト
 */
export function createDispMonitorItem(monitorItemList) {
  return monitorItemList.map(item => new DispMonitorItem(
    item.moni_data_name,
    item.moni_data_short_name,
    item.data_type,
    item.decimal_figure,
    item.unit,
    item.upper,
    item.lower,
    item.moni_data_no,
    item.conv_item
  ));
}

/**
 * 与えられた個別表示モニタ項目情報から画面表示用の項目を作成する.
 *
 * @param {*} addMonitorItemList 個別表示モニタ項目情報
 * @returns 画面表示用モニタ項目のリスト
 */
export function createDispAddMonitorItem(addMonitorItemList) {
  return addMonitorItemList.map(item => new DispMonitorItem(
    item.vital_monitor_item_name,
    item.vital_monitor_item_name,
    0,
    null,
    null,
    null,
    null,
    // mod #10077 by zhangruixue 2023-12-8 --start
    // item.vital_monitor_item_name,
    item.vital_monitor_item_cd + 10000 + '',
    // mod #10077 by zhangruixue 2023-12-8 --end
    null
  ));
}

/* add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --start */
// 新規関数、createDispAdMonitorItem関数の拡張
/**
 * 与えられた個別表示モニタ項目情報から画面表示用の項目を作成する.
 *
 * @param {*} addMonitorItemList 個別表示モニタ項目情報
 * dataIndex -> vital_monitor_item_cd
 * @returns 画面表示用モニタ項目のリスト
 */
export function createDispAddMonitorItemToItemCd(addMonitorItemList) {
  return addMonitorItemList.map(item => new DispMonitorItem(
      item.vital_monitor_item_name,
      item.vital_monitor_item_name,
      0,
      null,
      null,
      null,
      null,
    // mod #10077 by zhangruixue 2023-12-8 --start
    //   item.vital_monitor_item_cd.toString(),
    item.vital_monitor_item_cd + 10000 + '',
    // mod #10077 by zhangruixue 2023-12-8 --start
      null
  ));
}
/* add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --end */

/**
 * 画面表示用項目
 */
export class DispMonitorItem {
  /**
   * コンストラクタ
   * @param {String} name モニタ項目名
   * @param {String} shortName モニタ項目略称
   * @param {Number} dataType データタイプ
   * @param {Number} decimalFigure 小数桁数
   * @param {String} unit 単位
   * @param {Number} upper 上限値
   * @param {Number} lower 下限値
   * @param {String} dataIndex データインデックス(モニタデータ番号)
   * @param {String} selectItem 選択肢
   */
  constructor(
    name = null,
    shortName = null,
    dataType = null,
    decimalFigure = null,
    unit = null,
    upper = null,
    lower = null,
    dataIndex = null,
    selectItem = null,
  ) {
    // モニタ項目名
    this.name = name;
    // モニタ項目略称
    this.shortName = shortName;
    // データタイプ
    this.dataType = dataType;
    // 単位
    this.unit = unit;
    // 上限値
    this.upper = upper;
    // 下限値
    this.lower = lower;
    // インデックス
    // モニタデータ番号
    this.dataIndex = dataIndex;

    // 選択肢
    // ※選択項目が登録されていない場合、nullを設定する.
    let selectArray = new Array();
    if (selectItem) {
      Object.entries(JSON.parse(selectItem))
        .map(([key, value]) => (selectArray.push({cd: key, text: value})));
    }
    this.selectItem = selectItem ? selectArray : null;

    // 小数点
    const step = 1 / 10 ** decimalFigure;
    // 数値か否か
    this.isNumber =  [1, 2, 3].includes(dataType);
    // 文字か否か
    this.isString = [0].includes(dataType);
    // 増減値
    this.step = step;
    // 下限値
    this.min = lower * step;
    // 上限値
    this.max = upper * step;
  }
}

/**
 * モニタ画面のモニタ情報を表現するクラス
 */
export class Monitor {
  constructor(
    bioMoniCtlNo = null,
    occurDate = null,
    isDel = false,
    monitorData = null,
    updStaffId = null,
    updUserLastName = null,
    updUserFirstName = null,
    defaultTime = null,
  ) {
    // 生体モニタリング管理番号
    this.bioMoniCtlNo = bioMoniCtlNo;
    // 発生日時
    this.occurDate = occurDate;
    this._occurTime = occurDate
      ? dateFormat.format(new Date(occurDate), SHORT_TIME_FORMAT)
      : null; // 発生時間（DBには登録されない）
    // 削除フラグ
    this.isDel = isDel;
    // 選択状態
    this.selected = false;
    // モニタ情報
    if (monitorData !== null) {
      MONITOR_ITEMS.forEach(e => {
        if (e.isNumber && monitorData[e.dataIndex] !== null && monitorData[e.dataIndex] !== undefined) {
          // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
          // monitorData[e.dataIndex] = Number(monitorData[e.dataIndex]);
          monitorData[e.dataIndex] = monitorData[e.dataIndex] == null ? null : Number(monitorData[e.dataIndex]).toFixed(e.decimalFigure);
          // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
          // 時間(unit:"時分")の初期化
          monitorData[e.dataIndex] = this.initializeTimeField(monitorData[e.dataIndex], e);

          // add FNSI-測定前の値は空欄とする 徐 start
          if (e.dataIndex == 38 || e.dataIndex == 68 || e.dataIndex == 79 || e.dataIndex == 88) {
            // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
            // monitorData[e.dataIndex] = monitorData[e.dataIndex] == -1 ? null : Number(monitorData[e.dataIndex]);
            monitorData[e.dataIndex] = monitorData[e.dataIndex] == -1 ? null : Number(monitorData[e.dataIndex]).toFixed(e.decimalFigure);
            // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
          }
          // add FNSI-測定前の値は空欄とする 徐 end
        } else if (e.isNumber){
          // JSONキーが存在しない場合
          monitorData[e.dataIndex] = null;
          // 時間(unit:"時分")の初期化
          monitorData[e.dataIndex] = this.initializeTimeField(monitorData[e.dataIndex], e);
        }
      });
      this.monitorData = monitorData;
    }
    // 更新者ID
    this.updStaffId = updStaffId;
    // 更新者名
    this.updUserLastName = updUserLastName;
    this.updUserFirstName = updUserFirstName;

    // bioMoniCtlNoが未指定の場合は新規追加行とする
    if (bioMoniCtlNo === null) {
      this.isNew = true;
      this.monitorData = MONITOR_ITEMS.reduce((o, c) => {
        o[c.dataIndex] = null;
        // 時間(unit:"時分")の初期化
        o[c.dataIndex] = this.initializeTimeField(o[c.dataIndex], c, defaultTime);
        return o;
      }, {});
    }

    // 修正比較用に初期値を保存
    this.initialData = {
      // 発生日時
      occurDate: this.occurDate,
      // モニタ情報
      monitorData: JSON.stringify(this.monitorData)
    };
  }

  /**
   * フォーマットした発生時刻を取得する
   */
  get occurTime() {
    return this._occurTime;
  }

  /**
   * 発生日時を設定する.
   */
  set occurTime(timeValue) {
    this._occurTime = timeValue;
    this.occurDate = this.occurDate && timeValue ? parseDate(
      dateFormat.format(this.occurDate, DATE_FORMAT), timeValue) : this.occurDate;
  }

  /**
   * 発生日を取得する。
   */
  get occurDateString() {
    return this.occurDate
      ? dateFormat.format(this.occurDate, DATE_FORMAT)
      : "";
  }

  /**
   * 発生日を設定する。
   */
  set occurDateString(dateValue) {
    let date = new Date();
    if (this.occurDate && this.occurTime) {
      date.setFullYear((new Date(dateValue)).getFullYear(), (new Date(dateValue)).getMonth(), (new Date(dateValue)).getDate());
      this.occurDate =  parseDate(
        dateFormat.format(date, DATE_FORMAT),
        this.occurTime);
    } else {
      this.occurDate = new Date(dateValue);
    }
    //del FNSI-治療記録外結バッグ71 房 start
    // this.initialData.occurDate = this.occurDate;
    //del FNSI-治療記録外結バッグ71 房 end

  }

  /**
   * 発生時刻をUTCで取得する
   */
  get occurDateUTC() {
    return date2UTC(this.occurDate || new Date());
  }

  /**
   * 利用者名取得.
   * <p>
   * 更新者IDがnullの場合には、nullを返す.
   * 更新者IDがnullではない場合、姓名を半角スペースで結合した文字列を返す.
   * </p>
   */
  get updStaffName() {
    return this.updStaffId ? [this.updUserLastName, this.updUserFirstName].join(' ') : null;
  }

  /**
   * バリデーション.
   * <p>
   * 時刻以外のいずれかの項目が入力されている場合は時刻が必須
   * 編集行の場合：時刻必須
   * </p>
   */
  //mod FNSI修正 外結バッグ70 房 start
  validateRequiredTime() {
    // monitorDataをDBのデータ形式に変換してからvalidate
    const dbMonitorData = this.convertMonitorDataForDb(this.monitorData, "editValue");
    if (
      !this.occurTime &&
      Object.values(dbMonitorData).some(
        item => item !== null && item !== ""
      )
    ) {
      return false;
    }
    if (!this.isNew) {
      if (!this.occurTime) {
        return false;
      }
    }
    return true;
  }
  //mod FNSI修正 外結バッグ70 房 end

  /**
   * 入力値が変更されているか判定する.
   */
  isModified() {
    // monitorDataをDBのデータ形式に変換してから変更チェック
    const dbMonitorData = this.convertMonitorDataForDb(this.monitorData, "editValue");
    const dbInitialMonitorData = this.convertMonitorDataForDb(JSON.parse(this.initialData.monitorData), "initValue");
    return (
      (!this.isNew &&
        // mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
        this.dateConvert(this.occurDate ? this.occurDate : null) !==
        this.dateConvert(this.initialData.occurDate ? this.initialData.occurDate : null)) ||
        // mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
      JSON.stringify(dbMonitorData) !== JSON.stringify(dbInitialMonitorData)
    );
  }

  // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
  dateConvert(convertDate) {
    if (convertDate) {
      return dateFormat.format(convertDate, "yyyyMMddhhmm");
    } else {
      return "";
    }
  }
  // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end

  /**
   * 保存用のJSONを返す.
   * @param {*} patId 患者ID
   * @param {*} ordNo オーダ番号
   */
  toJsonForSave(patId, ordNo) {
    // monitorDataをDBのデータ形式に変換してからsave
    const dbMonitorData = this.convertMonitorDataForDb(this.monitorData, "editValue");
    return {
      // 生体モニタリング番号
      bio_moni_ctl_no: this.bioMoniCtlNo ? this.bioMoniCtlNo : 0,
      // オーダ番号
      ord_no: ordNo,
      // 患者ID
      pat_id: patId,
      // 発生日時
      occur_date: this.occurDate ? dateFormat.utc2Jst(date2UTC(this.occurDate)) : null,
      // データ種別
      data_type: CODES.VITAL_DATA_TYPE.MONITOR.cd,
      // モニタデータ
      monitor_data: JSON.stringify(this.exclusionNullValue(dbMonitorData)),
      // 削除フラグ
      is_del: this.isDel ? CODES.IS_DEL.DELETE.cd : CODES.IS_DEL.NOT_DELETE.cd
    };
  }

  /**
   * 削除用のJSONを返す.
   */
  toJsonForDelete() {
    // monitorDataをDBのデータ形式に変換してからdelete
    const dbInitialMonitorData = this.convertMonitorDataForDb(JSON.parse(this.initialData.monitorData), "initValue");
    return {
      // 生体モニタリング番号
      bio_moni_ctl_no: this.bioMoniCtlNo,
      // 発生日時
      occur_date: this.occurDate ? dateFormat.utc2Jst(date2UTC(this.occurDate)) : null,
      // データ種別
      data_type: CODES.VITAL_DATA_TYPE.MONITOR.cd,
      // モニタデータ（取得時）
      monitor_data: JSON.stringify(this.exclusionNullValue(dbInitialMonitorData)),
      // 削除フラグ
      is_del: this.selected ? CODES.IS_DEL.DELETE.cd : this.isDel ? CODES.IS_DEL.DELETE.cd : CODES.IS_DEL.NOT_DELETE.cd
    };
  }

  /**
   * 保存対象かどうか判定する.
   */
  isSaveRequired() {
    return this.isModified() || this.isOrdMonitorRecord || this.isDel;
  }

  /**
   * JSON内から値がnullの項目を除外する.
   * @param {*} monitorData モニタデータ
   */
  exclusionNullValue(monitorData) {
    const monitorDataForSave = { ...monitorData };
    // 保存データ格納用
    let saveMonitorData = {};
    // 値がnullの項目を除外
    Object.keys(monitorDataForSave).forEach(key => {
      if (monitorDataForSave[key] !== null && monitorDataForSave[key] !== "") {
        saveMonitorData[key] = monitorDataForSave[key].toString();
      }
    });
    return saveMonitorData;
  }
  
  /** 
  * 時間(unit:"時分")の初期化 
  * - CustomInputTimeSpecialのIFに合わせてオブジェクト{initValue, editValue}で保持する
  * - ※保存の前にDBのデータ形式に変換する
  * @param defaultTime 経過時間のデフォルト値 
  */
  initializeTimeField(record, e, defaultTime) {
    if (e.dataType === 3 && e.unit === "時分") {
      record = {
        initValue: record,
        editValue: defaultTime != null ? defaultTime : record
      };
    }
    return record;
  }
  
  /**
   * monitorData をDBのデータ形式に変換 ※経過時間がオブジェクト形式{initValue、editValue}のため変換必要
   * - 指定のプロパティが存在するオブジェクトの値は、指定のプロパティの値で更新する
   * - それ以外はそのままの値を保持する
   * @param monitorData 変換対象のモニタデータ
   * @param property 変換対象のプロパティ：initValue、editValue
   * @return 変換後のモニタデータ
   */
  convertMonitorDataForDb(monitorData, property) {
    const dbData = Object.keys(monitorData).reduce((acc, key) => {
      const value = monitorData[key];
      // 値がオブジェクトで指定のプロパティが存在する場合
      if (value && typeof value === "object" && property in value) {
        // `editValue` でオブジェクトを更新
        acc[key] = value[property];
      } else {
        // それ以外の場合は元の値をそのまま設定
        acc[key] = value;
      }
      return acc;
    }, {});
    return dbData;
  }
}
