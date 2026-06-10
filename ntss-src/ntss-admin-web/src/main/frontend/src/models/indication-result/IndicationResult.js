/**
 * 予実リストのオーダー情報を表現するクラス
 */
import { CODES } from "@/constants/IndicationResult";
import {
  dateFormat
} from "@/functions/common/DateTimeUtils";

const DATE_FORMAT = "yyyy/MM/dd";
const SHORT_TIME_FORMAT = "hh:mm";

export class IndicationResult {
  constructor(
    ordNo,
    category,
    indRstType,
    treatmentCd,
    treatmentDate,
    treatmentName,
    kurCd,
    kurName,
    kurStartTime,
    startDate,
    endDate,
    bedName
    // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン start
    ,bedCd
    , treatmentNameMst
    , bedNameMst
    , kurNameMst
    // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン end
  ) {
    // オーダ番号
    this.ordNo = ordNo;
    // カテゴリ（1:血液浄化）← 仮でこうしておきます
    this.category = category;
    // 予実（1:予定、2:実績）
    this.indRstType = indRstType;
    // 透析日
    this.treatmentDate = treatmentDate;
    // 治療方法コード
    this.treatmentCd = treatmentCd;
    // 治療方法名
    this.treatmentName = treatmentName;
    // クールコード
    this.kurCd = kurCd;
    // クール名
    this.kurName = kurName;
    // クール開始時刻
    this.kurStartTime = kurStartTime;
    // 治療開始時刻Char
    this.startDateChar = startDate;
    // 治療開始時刻
    // mod 6275 予実リスト＞実績の表示時刻が間違っている 周安寧 start
    //this.startDate = new Date(startDate);
    this.startDate = (startDate === null ? null : new Date(startDate));
    // mod 6275 予実リスト＞実績の表示時刻が間違っている 周安寧 end
    // 治療終了時刻
    // mod 6275 予実リスト＞実績の表示時刻が間違っている 周安寧 start
    //this.endDate = new Date(endDate);
    this.endDate =  (endDate === null ? null : new Date(endDate));
    // mod 6275 予実リスト＞実績の表示時刻が間違っている 周安寧 end
    // ベッド名
    this.bedName = bedName;
    // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン start
    // ベッドコード
    this.bedCd = bedCd;
    this.treatmentNameMst = treatmentNameMst;
    this.bedNameMst = bedNameMst;
    this.kurNameMst = kurNameMst;
    // add FNSI-マスタ削除表示の対応課題--予実リスト 鄧シン end

    // 表示形式パターン
    this.pattern = 1;
  }

  /**
   * 予定レコードかどうか.
   */
  get isIndication() {
    return CODES.IND_RESULT_TYPE.INDICATION.cd === this.indRstType;
  }

  /**
   * 実績レコードかどうか.
   */
  get isResult() {
    return CODES.IND_RESULT_TYPE.RESULT.cd === this.indRstType;
  }

  /**
   * 過去予定かどうか.
   */
  get isPastIndication() {
    return this.isIndication && this.treatmentDate < dateFormat.format(new Date(), "yyyyMMdd");
  }

  /**
   * カテゴリ名称.
   */
  get categoryName() {
    const element = Object.values(CODES.CATEGORY).find(e => e.cd === this.category);
    return element ? element.text : "";
  }

  /**
   * 予実名称.
   */
  get indRstTypeName() {
    const element = Object.values(CODES.IND_RESULT_TYPE).find(e => e.cd === this.indRstType);
    return element ? element.text : "";
  }

  /**
   * 透析日を表示形式に変換する.
   */
  get treatDate() {
    if (!this.treatmentDate) {
      return ""
    }
    const d = new Date(
      Number(this.treatmentDate.substr(0, 4)),
      Number(this.treatmentDate.substr(4, 2) - 1),
      Number(this.treatmentDate.substr(6, 2)));
    return dateFormat.format(d, DATE_FORMAT);
  }

  /**
   * 治療時間を表示形式に変換する.
   */
  get treatTime() {
    // add redmine6274 yuqizheng start
    if(this.startDateChar == null || this.startDateChar == "null"){
      return "   ";
      // add redmine6274 yuqizheng ebd
    }
    else{
      const startTime = this.startDate
        ? dateFormat.format(this.startDate, SHORT_TIME_FORMAT)
        : "";

      const endTime = this.endDate
      // && CODES.IND_RESULT_TYPE.RESULT.cd === this.indRstType
        ? dateFormat.format(this.endDate, SHORT_TIME_FORMAT)
        : "";
      return startTime + " 〜 " + endTime;
    }
  }
}
