/**
 * デフォルト設定の日付計算ユーティリティ
 */
import moment from "moment";
import { DATE_CHOICES } from "@/constants/defaultSettingConstants";

export const DATE_FORMAT = "YYYY-MM-DD";

/**
 * 本日日付を基準に一定期間前/後の日付を返却する.
 * 定数定義に存在しない期間を指定された場合は当日日付を返却する.
 * @param {*} dateChoice
 */
export function calcTargetDate(dateChoice) {
  let ret = null;
  switch (dateChoice) {
    case DATE_CHOICES.BEFORE_THREE_YEAR.value:
      ret = moment().subtract(3, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_ONE_YEAR.value:
      ret = moment().subtract(1, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_SIX_MONTH.value:
      ret = moment().subtract(6, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_THREE_MONTH.value:
      ret = moment().subtract(3, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_ONE_MONTH.value:
      ret = moment().subtract(1, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_TWO_WEEK.value:
      ret = moment().subtract(14, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_ONE_WEEK.value:
      ret = moment().subtract(7, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.FIRSTDAY_OF_WEEK.value:
      ret = moment().startOf('week').add(1, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_FIVE_YEAR.value:
      ret = moment().subtract(5, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_TEN_YEAR.value:
      ret = moment().subtract(10, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.TODAY.value:
      ret = moment().format(DATE_FORMAT);
      break;
    case DATE_CHOICES.TOMMOROW.value:
      ret = moment().add(1, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.DAY_AFTER_TOMMOROW.value:
      ret = moment().add(2, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.LASTDAY_OF_WEEK.value:
      ret = moment().endOf('week').add(1, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.NEXT_MONDAY.value:
      ret = moment().add(7, 'days').startOf('week').add(1, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_ONE_WEEK.value:
      ret = moment().add(7, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_TWO_WEEK.value:
      ret = moment().add(14, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_ONE_MONTH.value:
      ret = moment().add(1, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_THREE_MONTH.value:
      ret = moment().add(3, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_SIX_MONTH.value:
      ret = moment().add(6, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_ONE_YEAR.value:
      ret = moment().add(1, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_THREE_YEAR.value:
      ret = moment().add(3, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_FIVE_YEAR.value:
      ret = moment().add(5, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_TEN_YEAR.value:
      ret = moment().add(10, 'years').format(DATE_FORMAT);
      break;
  }

  return ret;
}

/**
 * 現在の時刻に基づいてmstKurをフィルタリングしkur_cdの配列を返す
 * @param {Array} mstKur - フィルタリング対象のクールマスタ
 * @returns {Array} - 現在時刻の範囲内にあるkur_cdの配列
 */
export function getKurCds(mstKur) {
  const currentTime = moment().format("HHmmss");
  return mstKur
    .filter(({ kurStartTime, kurEndTime }) => 
      currentTime >= kurStartTime && currentTime <= kurEndTime
    )
    .map(item => item.kurCd);
}
