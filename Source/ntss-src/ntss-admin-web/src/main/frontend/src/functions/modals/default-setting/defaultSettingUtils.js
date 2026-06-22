/**
 * デフォルト設定の日付計算ユーティリティ
 */
import dayjs from "@/compat/date/dayjs";
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
      ret = dayjs().subtract(3, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_ONE_YEAR.value:
      ret = dayjs().subtract(1, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_SIX_MONTH.value:
      ret = dayjs().subtract(6, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_THREE_MONTH.value:
      ret = dayjs().subtract(3, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_ONE_MONTH.value:
      ret = dayjs().subtract(1, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_TWO_WEEK.value:
      ret = dayjs().subtract(14, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_ONE_WEEK.value:
      ret = dayjs().subtract(7, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.FIRSTDAY_OF_WEEK.value:
      ret = dayjs().startOf('week').add(1, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_FIVE_YEAR.value:
      ret = dayjs().subtract(5, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.BEFORE_TEN_YEAR.value:
      ret = dayjs().subtract(10, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.TODAY.value:
      ret = dayjs().format(DATE_FORMAT);
      break;
    case DATE_CHOICES.TOMMOROW.value:
      ret = dayjs().add(1, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.DAY_AFTER_TOMMOROW.value:
      ret = dayjs().add(2, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.LASTDAY_OF_WEEK.value:
      ret = dayjs().endOf('week').add(1, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.NEXT_MONDAY.value:
      ret = dayjs().add(7, 'days').startOf('week').add(1, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_ONE_WEEK.value:
      ret = dayjs().add(7, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_TWO_WEEK.value:
      ret = dayjs().add(14, 'days').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_ONE_MONTH.value:
      ret = dayjs().add(1, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_THREE_MONTH.value:
      ret = dayjs().add(3, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_SIX_MONTH.value:
      ret = dayjs().add(6, 'months').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_ONE_YEAR.value:
      ret = dayjs().add(1, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_THREE_YEAR.value:
      ret = dayjs().add(3, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_FIVE_YEAR.value:
      ret = dayjs().add(5, 'years').format(DATE_FORMAT);
      break;
    case DATE_CHOICES.AFTER_TEN_YEAR.value:
      ret = dayjs().add(10, 'years').format(DATE_FORMAT);
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
  const currentTime = dayjs().format("HHmmss");
  return mstKur
    .filter(({ kurStartTime, kurEndTime }) => 
      currentTime >= kurStartTime && currentTime <= kurEndTime
    )
    .map(item => item.kurCd);
}

/**
 * デフォルト設定のカテゴリコードが有効かどうかを判定する
 *
 * @param {string} settingValue - カテゴリコード（形式: "サブカテゴリCd-カテゴリCd"）
 * @param {Array<Object>} mstCategoryRecords - カテゴリマスタ一覧
 * @param {Array<Object>} mstSubCategoryRecords - サブカテゴリマスタ一覧
 *
 * @returns {boolean}
 *  true: 有効
 *  false: 無効
 */
export function isValidDefaultCategory(settingValue, mstCategoryRecords, mstSubCategoryRecords) {
  if (!settingValue) return false;

  const AnyCategoryCd = "0";
  const AnySubCategoryCd = "0";
  const CategoryCdDelimiter = "-";

  // フォーマットチェック
  if (!settingValue.includes(CategoryCdDelimiter)) return false;

  const [subCategoryCd, categoryCd] = settingValue.split(CategoryCdDelimiter);

  if (!subCategoryCd || !categoryCd) return false;

  let categoryExistFlg = true;
  let subCategoryExistFlg = true;

  // カテゴリ存在チェック
  if (categoryCd !== AnyCategoryCd) {
    categoryExistFlg = mstCategoryRecords.some(rec => rec.categoryCd == categoryCd);
  }

  // サブカテゴリ存在チェック
  if (subCategoryCd !== AnySubCategoryCd) {
    subCategoryExistFlg = mstSubCategoryRecords.some(rec => rec.subCategoryCd == subCategoryCd);
  }

  // 「カテゴリ指定 + サブカテゴリ全」
  if (categoryCd !== AnyCategoryCd && subCategoryCd === AnySubCategoryCd) {
    subCategoryExistFlg = mstSubCategoryRecords.some(rec => rec.categoryCd == categoryCd);
  }

  return categoryExistFlg && subCategoryExistFlg;
}
