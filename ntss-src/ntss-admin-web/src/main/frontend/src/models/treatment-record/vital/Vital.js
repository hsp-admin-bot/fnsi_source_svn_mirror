import { CODES } from "@/constants/TreatmentRecord";
import {
  dateFormat,
  DATE_FORMAT,
  SHORT_TIME_FORMAT,
  date2UTC,
  parseDate
} from "@/functions/common/DateTimeUtils";

/**
 * データ種別→血圧区分の変換テーブル
 */
const bpClassTbl = {
  [CODES.VITAL_DATA_TYPE.BP_UNDER_DIALYSIS.cd]: CODES.BP_CLASS.NONE.cd,
  [CODES.VITAL_DATA_TYPE.TEMPERATURE.cd]: CODES.BP_CLASS.NONE.cd,
  [CODES.VITAL_DATA_TYPE.BP_BEFORE_DIALYSIS.cd]: CODES.BP_CLASS.BEFORE.cd,
  [CODES.VITAL_DATA_TYPE.BP_AFTER_DIALYSIS.cd]: CODES.BP_CLASS.AFTER.cd
};

/**
 * バイタル画面のバイタル情報を表現するクラス
 */
export class Vital {
  /**
   * コンストラクタ
   * @param {Number} bioMoniCtlNo 生体モニタリング番号
   * @param {String} dataType データ種別
   * @param {String} bpClass 血圧区分
   * @param {String} occurDate 発生日時
   * @param {String} updUserLastName 更新者姓
   * @param {String} updUserFirstName 更新者名
   * @param {JSON} monitorData モニタデータ
   * @param {Array} dispVitalItemList 表示項目リスト
   * @param {Boolean} isDel 削除フラグ
   */
  constructor(
    bioMoniCtlNo = null,
    dataType = null,
    bpClass = null,
    occurDate = null,
    updStaffId = null,
    updUserLastName = null,
    updUserFirstName = null,
    monitorData = {},
    dispVitalItemList = null,
    isDel = false,
  ) {
    // 生体モニタリング管理番号
    this.bioMoniCtlNo = bioMoniCtlNo;
    // データ種別
    this.dataType = dataType;
    // 血圧区分
    this.bpClass = bpClass;
    // 発生日時
    this.occurDate = occurDate;
    this._occurTime = occurDate
      ? dateFormat.format(new Date(occurDate), SHORT_TIME_FORMAT)
      : null; // 発生時間（DBには登録されない）
    // バイタルデータ
    if (monitorData != null && dispVitalItemList != null) {
      dispVitalItemList.forEach(e => {
        if (e.isNumber && monitorData[e.dataIndex] != null) {
          // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
          // monitorData[e.dataIndex] = Number(monitorData[e.dataIndex]);
          monitorData[e.dataIndex] = monitorData[e.dataIndex] == null ? null : String(monitorData[e.dataIndex]);
          // del #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
        }
      });
    }
    this.monitorData = monitorData;
    // 最高血圧
    this.bpMax = monitorData !== null ? monitorData[CODES.VITAL_MONITOR_KEY.BP_MAX.cd] : null;
    // 最低血圧
    this.bpMin = monitorData !== null ? monitorData[CODES.VITAL_MONITOR_KEY.BP_MIN.cd] : null;
    // 平均血圧
    this.bpAve = monitorData !== null ? monitorData[CODES.VITAL_MONITOR_KEY.BP_AVE.cd] : null;
    // 血糖値
    this.bloodSugarLevel = monitorData !== null ? monitorData[CODES.VITAL_MONITOR_KEY.BLOOD_SUGAR.cd] : null;
    // 脈拍
    this.pulse = monitorData !== null ? monitorData[CODES.VITAL_MONITOR_KEY.PULSE.cd] : null;
    // 体温
    this.temperature = monitorData !== null ? monitorData[CODES.VITAL_MONITOR_KEY.TEMPERATURE.cd] : null;
    // 更新者ID
    this.updStaffId = updStaffId;
    // 更新者名
    this.updUserLastName = updUserLastName;
    this.updUserFirstName = updUserFirstName;
    // 削除フラグ
    this.isDel = isDel;
    // 選択状態
    this.selected = false;

    // bioMoniCtlNoが未指定の場合は新規追加行とする
    this.isNew = bioMoniCtlNo === null;

    if (dataType) {
      this.bpClass = bpClassTbl[dataType];
    }

    // 血圧区分が未設定の場合初期値を設定
    if (this.bpClass === null) {
      this.bpClass = CODES.BP_CLASS.NONE.cd;
    }

    // 平均血圧再計算用に値を保存
    this.bpMaxOld = this.bpMax;
    this.bpMinOld = this.bpMin;

    // 修正比較用に初期値を保存
    this.initialData = {
      // 発生日時
      occurDate: this.occurDate,
      // 血圧区分
      bpClass: this.bpClass,
      // モニタ情報
      monitorData: this.monitorData ? JSON.stringify(this.exclusionNullValue(this.monitorData)) : {}
    };
  }

  /**
   * フォーマットした発生時刻を取得する
   */
  get occurTime() {
    return this._occurTime;
  }

  /**
   * フォーマットした発生日を取得する
   */
  get occurDateCalendar() {
    return this.occurDate
      ? dateFormat.format(this.occurDate, DATE_FORMAT)
      : "";
  }

  /**
   * 発生日を設定する
   */
  set occurDateCalendar(valueDate) {
    let date = new Date();
    if (this.occurDate && this.occurTime) {
      date.setFullYear((new Date(valueDate)).getFullYear(), (new Date(valueDate)).getMonth(), (new Date(valueDate)).getDate());
      this.occurDate =  parseDate(
        dateFormat.format(date, DATE_FORMAT),
        this.occurTime);
    } else {
      this.occurDate = new Date(valueDate);
    }
    //del FNSI-治療記録外結バッグ71 房 start
    // this.initialData.occurDate = this.occurDate;
    //del FNSI-治療記録外結バッグ71 房 end
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
   * 血圧区分名称を取得する
   */
  get bpClassName() {
    const result = Object.values(CODES.BP_CLASS).find(
      c => c.cd === this.bpClass
    );
    return result ? result.text : "";
  }

  /**
   * 発生時刻をUTCで取得する
   */
  get occurDateUTC() {
    return date2UTC(this.occurDate || new Date());
  }

  /**
   * 血圧区分が前血圧かどうか.
   */
  get isBpBefore() {
    return this.bpClass === CODES.BP_CLASS.BEFORE.cd;
  }

  /**
   * 血圧区分が後血圧かどうか.
   */
  get isBpAfter() {
    return this.bpClass === CODES.BP_CLASS.AFTER.cd;
  }

  /**
   * 血圧区分が未入力かどうか.
   */
  get isBpNone() {
    return this.bpClass === CODES.BP_CLASS.NONE.cd;
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
   * 時刻が入力されている場合は時刻と血圧区分以外の項目のいずれかが必須
   * </p>
   */
  //mod FNSI修正 外結バッグ70 房 start
  validateRequiredBlood() {
    if (this.occurTime &&
        Object.values(this.monitorData).every(item => item === null)
    ) {
      return false;
    }
    return true;
  }
  //mod FNSI修正 外結バッグ70 房 end

  /**
   * バリデーション.
   * <p>
   * 時刻以外のいずれかの項目が入力されている場合は時刻が必須
   * 編集行の場合：時刻必須
   * </p>
   */
  validateRequiredTime() {
    if (
      !this.occurTime &&
      (Object.values(this.monitorData).some(
        item => item !== null && item !== ""
      ) || !this.isBpNone)
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

  /**
   * 平均血圧を計算して設定する.
   */
  reCalcBpAve() {
    // 最高血圧
    const bpMax = this.monitorData[CODES.VITAL_MONITOR_KEY.BP_MAX.cd];
    // 最低血圧
    const bpMin = this.monitorData[CODES.VITAL_MONITOR_KEY.BP_MIN.cd];
    if (bpMax !== this.bpMaxOld || bpMin !== this.bpMinOld) {
      if (bpMax && bpMin) {
        // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
        // this.bpAve = Math.floor(bpMin + (bpMax - bpMin) / 3);
        const min = Number(bpMin);
        const max = Number(bpMax);

        if (!Number.isFinite(min) || !Number.isFinite(max)) {
          this.bpAve = '';
        } else {
          this.bpAve = Math.floor((max - min) / 3 + min).toString();
        }
        // mod #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end
      } else {
        this.bpAve = null;
      }
      this.monitorData[CODES.VITAL_MONITOR_KEY.BP_AVE.cd] = this.bpAve;
      this.bpMaxOld = bpMax;
      this.bpMinOld = bpMin;
      // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
      this.monitorData = JSON.parse(JSON.stringify(this.monitorData));
      // add 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
    }
  }

  /**
   * 血圧区分をリセットする.
   */
  resetBpClass() {
    this.bpClass = CODES.BP_CLASS.NONE.cd;
    // 未変更扱いにする
    this.initialData.bpClass = CODES.BP_CLASS.NONE.cd;
  }

  /**
   * 入力値が変更されているか判定する.
   */
  isModified() {
    return (
      // mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 start
      (!this.isNew && this.dateConvert(this.occurDate) !== this.dateConvert(this.initialData.occurDate)) ||
      // mod 6827 入力欄の編集済み表現不正（治療記録＞バイタル） 房 end
      this.bpClass !== this.initialData.bpClass ||
      JSON.stringify(this.exclusionNullValue(this.monitorData)) !== this.initialData.monitorData
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
   * 保存対象かどうか判定する.
   */
  isSaveRequired() {
    return this.isModified() || (this.dataType === null && !this.isNew) || this.isDel;
  }

  /**
   * ord_mainのレコードかどうか.
   */
  isOrdMainRecord() {
    return this.dataType === null && !this.isNew;
  }

  /**
   * 保存用のJSONを返す.
   * json内は下記の通り
   * {
   *  bio_moni_ctl_no: 0 or 更新対象の生体モニタリング番号
   *  ord_no:オーダ番号
   *  occur_date:治療開始日時 + 画面で入力された時分
   *  pat_id:患者ID
   *  data_type:データ種別
   *  monitor_data:json
   *  is_del:"0" or "1"
   * }
   * @param {*} patId 患者ID
   * @param {*} ordNo オーダ番号
   */
  toJsonForSave(patId, ordNo) {
    // 新規登録の場合
    // 発生日を設定する
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
      data_type: this.bpClass,
      // モニタデータ
      monitor_data: JSON.stringify(this.exclusionNullValue(this.monitorData)),
      // 削除フラグ
      is_del: this.isDel ? CODES.IS_DEL.DELETE.cd : CODES.IS_DEL.NOT_DELETE.cd
    };
  }

  /**
   * 削除用のJSONを返す.
   */
  toJsonForDelete() {

    return {
      // 生体モニタリング番号
      bio_moni_ctl_no: this.bioMoniCtlNo,
      // 発生日時
      occur_date: this.occurDate ? dateFormat.utc2Jst(date2UTC(this.occurDate)) : null,
      // データ種別
      data_type: this.bpClass,
      // モニタデータ
      monitor_data: JSON.stringify(this.exclusionNullValue(JSON.parse(this.initialData.monitorData))),
      // 削除フラグ
      is_del: this.selected ? CODES.IS_DEL.DELETE.cd : this.isDel ? CODES.IS_DEL.DELETE.cd : CODES.IS_DEL.NOT_DELETE.cd
    };
  }

  /**
   * JSON内から値がnull及び空文字の項目を除外する.
   * @param {*} vitalData バイタルデータ
   */
  exclusionNullValue(vitalData) {
    // 保存データ格納用
    let saveMonitorData = {};
    // 値がnullの項目を除外
    Object.keys(vitalData).forEach(key => {
      if (vitalData[key] !== null && vitalData[key] !== "") {
        saveMonitorData[key] = vitalData[key].toString();
      }
    });
    return saveMonitorData;
  }
}

// add #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm start
/**
 * Graph用のVitalデータを整合する(number)
 */
export function cloneVitalForGraph(vital) {
  if (!vital) return vital;

  const v = Object.assign(new Vital(), vital);

  if (vital.monitorData) {
    v.monitorData = { ...vital.monitorData };

    Object.keys(v.monitorData).forEach(key => {
      const val = v.monitorData[key];
      if (val !== null && val !== '' && !isNaN(val)) {
        v.monitorData[key] = Number(val);
      }
    });
  }

  convertToNumber(v, [
    'bpMax',
    'bpMaxOld',
    'bpMin',
    'bpMinOld',
    'bpAve',
    'bloodSugarLevel',
    'pulse',
    'temperature'
  ]);

  return v;
}

function convertToNumber(obj, fields) {
  fields.forEach(field => {
    const val = obj[field];
    if (val !== null && val !== '' && !isNaN(val)) {
      obj[field] = Number(val);
    }
  });
}
// add #12448 治療記録のモニタを編集すると小数点以下が表示されない zkm end

/**
 * 与えられたモニタ項目リストから画面表示用の項目を作成する.
 *
 * @param {*} vitalItemList モニタ項目リスト(sys_monitor_item のみ)
 * @returns 画面表示用モニタ項目のリスト
 */
export function createDispVitalItem(vitalItemList) {
  return vitalItemList.map(item => new DispVitalItem(
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
  return addMonitorItemList.map(item => new DispVitalItem(
    item.vital_monitor_item_name,
    item.vital_monitor_item_name,
    0,
    null,
    null,
    null,
    null,
    // mod #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 start
    // mod #10077 by zhangruixue 2023-12-8 --start
    // item.vital_monitor_item_name,
    // item.vital_monitor_item_cd,
    item.vital_monitor_item_cd + 10000 + '',
    // mod #10077 by zhangruixue 2023-12-8 --start
    // add #8391 バイタル・モニタ項目追加マスタで追加した項目をトレンドグラフモニタ，帳票グラフに追加しても透析記録用紙に表示されない 姜 end
    null
  ));
}

/**
 * 画面表示用項目
 */
export class DispVitalItem {
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
