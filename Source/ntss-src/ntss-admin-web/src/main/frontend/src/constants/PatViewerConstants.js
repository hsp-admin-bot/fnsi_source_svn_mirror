/**
 * 患者経過総合ビューア用定数
 */

// 治療予定マーカーセルの長押し判定閾値(単位:ms)
export const LONG_CLICK_THRESHOLD = 500;

export const PATVIEWER_CURRENT_ROUTE_NAME = "pat-viewer";

// add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
const LIQUID_TEXT_1 = "I-HDFの予定はI-HDFの設定から算出して登録します。";
const LIQUID_TEXT_2 = "OHDF・OHFの予定は補液速度から算出して登録します。";
const LIQUID_TEXT_3 = "OHDF・OHFの予定は補液比率から算出して登録します。";
const LIQUID_TEXT_4 = "OHDF・OHFの予定は濾過率から算出して登録します。";
const LIQUID_TEXT_5 = "HDF・HF・AFBFの予定は補液量から算出して登録します。";
const LIQUID_TEXT_6 = "OHDF・OHFの予定は補液量から算出して登録します。";

export const LIQUID_AMOUNT_TEXT= {
    0: LIQUID_TEXT_1,
    1: LIQUID_TEXT_2 + "</br>" + LIQUID_TEXT_1,
    2: LIQUID_TEXT_3 + "</br>" + LIQUID_TEXT_1,
    3: LIQUID_TEXT_4 + "</br>" + LIQUID_TEXT_1
  };
export const LIQUID_SPEED_TEXT= {
    0: LIQUID_TEXT_5 + "</br>" + LIQUID_TEXT_6 + "</br>" + LIQUID_TEXT_1,
    1: LIQUID_TEXT_5 + "</br>" + LIQUID_TEXT_1,
    2: LIQUID_TEXT_5 + "</br>" + LIQUID_TEXT_3 + "</br>" + LIQUID_TEXT_1,
    3: LIQUID_TEXT_5 + "</br>" + LIQUID_TEXT_4 + "</br>" + LIQUID_TEXT_1,
  };
  // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end

// 接頭語
export const PREFIX = {
  TABOO_CLASS_PREFIX : "【禁忌】",
  ALLERGY_CLASS_PREFIX : "【ｱﾚﾙｷﾞｰ】",
  TABOO_ALLERGY_CLASS_PREFIX : "【禁忌・ｱﾚﾙｷﾞｰ】",
  CLASSIFICATION_PREFIX : "【分類不一致】",
  EXPIRED_PREFIX : "【期限切れ】",
  DELETED_PREFIX : "【削除済み】",
  INCLUDE_DELETED_PREFIX : "【削除済み含む】"
};

// 警告対象となる接頭語の配列
export const ALERT_PREFIXES = [
  PREFIX.TABOO_CLASS_PREFIX,
  PREFIX.ALLERGY_CLASS_PREFIX,
  PREFIX.TABOO_ALLERGY_CLASS_PREFIX,
  PREFIX.CLASSIFICATION_PREFIX,
  PREFIX.EXPIRED_PREFIX,
  PREFIX.DELETED_PREFIX,
  PREFIX.INCLUDE_DELETED_PREFIX
];
