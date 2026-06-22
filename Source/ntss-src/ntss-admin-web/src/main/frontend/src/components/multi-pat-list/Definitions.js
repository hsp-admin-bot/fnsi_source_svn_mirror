/**
 * @classdesc レイアウトカテゴリ定義クラス
 */
class LayoutCategory {
  /**
   * @constructor
   * @param {String} title レイアウトカテゴリ名称
   * @param {String} key レイアウトカテゴリキー
   */
  constructor(title, key) {
    this.title = title;
    this.key = key;
  }

  keyTitle() {
    return {
      [this.key]: this.title
    };
  }
}

class LayoutCategoryList {
  constructor(title, key, num) {
    this.title = title;
    this.key = key;
    this.num = num;

    const array = [];
    for (let i = 1; array.length < num; i++) {
      array.push({ title: `${title}`, key: `${key}_${i}` });
    }
    this.categories = array;
  }

  keyTitle() {
    const keyTitle = {};
    this.categories.forEach(category => {
      keyTitle[category.key] = category.title;
    });
    return keyTitle;
  }
}

class LayoutCategoryArray {
  constructor(title, key, num) {
    this.title = title;
    this.key = key;
    this.num = num;

    const array = [];
    for (let i = 1; array.length < num; i++) {
      array.push({ title: `${title}${i}`, key: `${key}_${i}` });
    }
    this.categories = array;
  }

  keyTitle() {
    const keyTitle = {};
    this.categories.forEach(category => {
      keyTitle[category.key] = category.title;
    });
    return keyTitle;
  }
}


const layoutCategoryOtherContactKeyPersonInfo = new LayoutCategoryList(
  "連絡先(キーパーソン)",
  "other_contact_key_person_info",
  1
);
const layoutCategoryOtherContactInfo = new LayoutCategoryArray(
  "連絡先",
  "other_contact_info",
  3
);
const layoutCategoryVendorContactInfo = new LayoutCategoryArray(
  "連絡先(業者)",
  "vendor_contact_info",
  3
);

/** レイアウトカテゴリ 本人情報 */
export const LAYOUT_CATEGORY_BASICINFO = new LayoutCategory(
  "本人情報",
  "basic_info"
);
/** レイアウトカテゴリ 連絡先(キーパーソン)) */
export const LAYOUT_CATEGORY_OTHERCONTACTKEYPERSONINFO =
  layoutCategoryOtherContactKeyPersonInfo.categories;
/** レイアウトカテゴリ 連絡先 */
export const LAYOUT_CATEGORY_OTHERCONTACTINFO =
  layoutCategoryOtherContactInfo.categories;
/** レイアウトカテゴリ 連絡先(業者) */
export const LAYOUT_CATEGORY_VENDORCONTACTINFO =
  layoutCategoryVendorContactInfo.categories;
/** レイアウトカテゴリ 患者メモ */
export const LAYOUT_CATEGORY_PATMEMOINFO = new LayoutCategory(
  "患者メモ",
  "pat_memo_info"
);
/** レイアウトカテゴリ 透析困難(主) */
export const LAYOUT_CATEGORY_DIFFICULTY_MAIN = new LayoutCategory(
  "透析困難(主)",
  "difficulty_main"
);
/** レイアウトカテゴリ 透析困難 */
export const LAYOUT_CATEGORY_DIFFICULTY_OTHER = new LayoutCategory(
  "透析困難",
  "difficulty_other"
);
/** レイアウトカテゴリ 重症度 */
export const LAYOUT_CATEGORY_SEVERITY = new LayoutCategory(
  "重症度",
  "severity"
);
/** レイアウトカテゴリ 搬送区分 */
export const LAYOUT_CATEGORY_TRANSPORT = new LayoutCategory(
  "搬送区分",
  "transport"
);
/** レイアウトカテゴリ 診療情報 */
export const LAYOUT_CATEGORY_MEDICALCAREINFO = new LayoutCategory(
  "診療情報",
  "medical_care_info"
);
/** レイアウトカテゴリ 担当者 */
export const LAYOUT_CATEGORY_CHARGESTAFFINFO = new LayoutCategory(
  "担当者",
  "charge_staff_info"
);
/** レイアウトカテゴリ 禁忌・アレルギー */
export const LAYOUT_CATEGORY_TABOO_ALLERGY_INFO = new LayoutCategory(
  "禁忌・アレルギー",
  "taboo_allergy_info"
);
/** レイアウトカテゴリ 感染症 */
export const LAYOUT_CATEGORY_INFECT_INFO = new LayoutCategory(
  "感染症",
  "infect_info"
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
/** レイアウトカテゴリ 患者グループ */
export const LAYOUT_CATEGORY_PATIENT_GROUP = new LayoutCategory(
  "患者グループ",
  "patient_group"
);
/** レイアウトカテゴリ 加算・管理料 */
export const LAYOUT_CATEGORY_ADDITION = new LayoutCategory(
  "加算・管理料",
  "addition"
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
/** レイアウトカテゴリ インプラント */
export const LAYOUT_CATEGORY_IMPLANT_INFO = new LayoutCategory(
  "インプラント",
  "implant_info"
);
/** レイアウトカテゴリ 既往歴 */
export const LAYOUT_CATEGORY_MEDICAL_HST_INFO = new LayoutCategory(
  "既往歴",
  "medical_hst_info"
);
/** レイアウトカテゴリ 身体情報(追加登録) */
export const LAYOUT_CATEGORY_PHYSICAL_INFO = new LayoutCategory(
  "身体情報(追加登録)",
  "physical_info"
);
/** レイアウトカテゴリ 身体情報(最新：身長) */
export const LAYOUT_CATEGORY_PHYSICAL_INFO_HEIGHT = new LayoutCategory(
  "身体情報(最新：身長)",
  "physical_info_height"
);
/** レイアウトカテゴリ 身体情報(最新：DW) */
export const LAYOUT_CATEGORY_PHYSICAL_INFO_DW = new LayoutCategory(
  "身体情報(最新：DW)",
  "physical_info_dw"
);
/** レイアウトカテゴリ 身体情報(最新：CTR) */
export const LAYOUT_CATEGORY_PHYSICAL_INFO_CTR = new LayoutCategory(
  "身体情報(最新：CTR)",
  "physical_info_ctr"
);

export const LAYOUT_CATEGORY_CARD_CREATION = new LayoutCategory(
  "カード作成",
  "card_creation"
);

/**
 * @field {Object} レイアウトカテゴリキーとタイトルの対応
 */
export const LAYOUT_CATEGORY_TITLES = {
  ...LAYOUT_CATEGORY_BASICINFO.keyTitle(),
  ...layoutCategoryOtherContactKeyPersonInfo.keyTitle(),
  ...layoutCategoryOtherContactInfo.keyTitle(),
  ...layoutCategoryVendorContactInfo.keyTitle(),
  ...LAYOUT_CATEGORY_PATMEMOINFO.keyTitle(),
  ...LAYOUT_CATEGORY_DIFFICULTY_MAIN.keyTitle(),
  ...LAYOUT_CATEGORY_DIFFICULTY_OTHER.keyTitle(),
  ...LAYOUT_CATEGORY_SEVERITY.keyTitle(),
  ...LAYOUT_CATEGORY_TRANSPORT.keyTitle(),
  ...LAYOUT_CATEGORY_MEDICALCAREINFO.keyTitle(),
  ...LAYOUT_CATEGORY_CHARGESTAFFINFO.keyTitle(),
  ...LAYOUT_CATEGORY_TABOO_ALLERGY_INFO.keyTitle(),
  ...LAYOUT_CATEGORY_INFECT_INFO.keyTitle(),
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
  ...LAYOUT_CATEGORY_PATIENT_GROUP.keyTitle(),
  ...LAYOUT_CATEGORY_ADDITION.keyTitle(),
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
  ...LAYOUT_CATEGORY_IMPLANT_INFO.keyTitle(),
  ...LAYOUT_CATEGORY_MEDICAL_HST_INFO.keyTitle(),
  ...LAYOUT_CATEGORY_PHYSICAL_INFO.keyTitle(),
  ...LAYOUT_CATEGORY_PHYSICAL_INFO_HEIGHT.keyTitle(),
  ...LAYOUT_CATEGORY_PHYSICAL_INFO_DW.keyTitle(),
  ...LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.keyTitle(),
  ...LAYOUT_CATEGORY_CARD_CREATION.keyTitle()
};

/**
 * @classdesc レイアウト項目定義クラス
 */
class LayoutItem {
  /**
   * @constructor
   * @param {String} title レイアウト項目名称
   * @param {String} key レイアウト項目キー
   */
  constructor(title, key) {
    this.title = title;
    this.key = key;
  }
}

export const LAYOUT_ITEM_KEY_SUFFIX_MSTNAME = "_MstName";
export const LAYOUT_ITEM_KEY_SUFFIX_DATEOBJECT = "_DateObject";
// add データリストの患者情報修正 陳 start
export const LAYOUT_ITEM_KEY_SUFFIX_CHKBOX = "_chkbox";
// add データリストの患者情報修正 陳 end
export const NO_UPDDATE_FIELD_SUFFIX_LIST = [
  LAYOUT_ITEM_KEY_SUFFIX_MSTNAME,
  LAYOUT_ITEM_KEY_SUFFIX_DATEOBJECT
];

/* レイアウトカテゴリ 本人情報 */
// mod データリストレイアウトマスタコンテンツの変更  王 start
/** レイアウト項目 本人情報-pat_id */
export const LAYOUT_ITEM_BASICINFO_PATID = new LayoutItem(
  "pat_id",
  "pat_id"
);
/** レイアウト項目 本人情報-患者ID */
export const LAYOUT_ITEM_BASICINFO_HOSPPATID = new LayoutItem(
  "ID",
  "hosp_pat_id"
);
/** レイアウト項目 本人情報-患者名 */
export const LAYOUT_ITEM_BASICINFO_NAME = new LayoutItem(
  "患者名",
  "pat_name"
);
// mod データリストレイアウトマスタコンテンツの変更  王 end
/** レイアウト項目 本人情報-患者名(カナ) */
export const LAYOUT_ITEM_BASICINFO_NAMEKANA = new LayoutItem(
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  // "患者名(カナ)",
  "フリガナ",
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  "pat_name_kana"
);
/** レイアウト項目 本人情報-患者名(英語) */
export const LAYOUT_ITEM_BASICINFO_NAMEALPHA = new LayoutItem(
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  // "患者名(英語)",
  "英語表記",
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  "pat_name_alpha"
);
/** レイアウト項目 本人情報-入外 */
export const LAYOUT_ITEM_BASICINFO_INOUT = new LayoutItem(
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  // "入外",
  "入外区分",
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  "in_out_class"
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
/** レイアウト項目 本人情報-在院状態 */
export const LAYOUT_ITEM_BASICINFO_INHOSPITALSTATE = new LayoutItem(
  "在院状態",
  "in_hospital_state"
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
/** レイアウト項目 本人情報-生年月日 */
export const LAYOUT_ITEM_BASICINFO_BIRTHDAY = new LayoutItem(
  "生年月日",
  "pat_birthday"
);
/** レイアウト項目 本人情報-生年月日オブジェクト(非表示) */
export const LAYOUT_ITEM_BASICINFO_BIRTHDAYDATEOBJECT = new LayoutItem(
  "生年月日オブジェクト",
  `${LAYOUT_ITEM_BASICINFO_BIRTHDAY.key}${LAYOUT_ITEM_KEY_SUFFIX_DATEOBJECT}`
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
/** レイアウト項目 本人情報-年齢 */
export const LAYOUT_ITEM_BASICINFO_AGE = new LayoutItem(
  "年齢",
  "pat_age"
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
/** レイアウト項目 本人情報-性別コード(非表示) */
export const LAYOUT_ITEM_BASICINFO_SEXCODE = new LayoutItem(
  "性別コード",
  "pat_sex"
);
/** レイアウト項目 本人情報-性別 */
export const LAYOUT_ITEM_BASICINFO_SEXNAME = new LayoutItem(
  "性別",
  `${LAYOUT_ITEM_BASICINFO_SEXCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 本人情報-血液型ABO(非表示) */
export const LAYOUT_ITEM_BASICINFO_BLOODABOCODE = new LayoutItem(
  "血液型(ABO)コード",
  "pat_blood_type_abo"
);
/** レイアウト項目 本人情報-血液型ABO */
export const LAYOUT_ITEM_BASICINFO_BLOODABONAME = new LayoutItem(
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  // "血液型(ABO)",
  "血液型・ABO型",
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  `${LAYOUT_ITEM_BASICINFO_BLOODABOCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 本人情報-血液型RH(非表示) */
export const LAYOUT_ITEM_BASICINFO_BLOODRHCODE = new LayoutItem(
  "血液型(RH)コード",
  "pat_blood_type_rh"
);
/** レイアウト項目 本人情報-血液型RH */
export const LAYOUT_ITEM_BASICINFO_BLOODRHNAME = new LayoutItem(
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  // "血液型(RH)",
  "血液型・Rh型",
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  `${LAYOUT_ITEM_BASICINFO_BLOODRHCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 本人情報-血液型亜型(非表示) */
export const LAYOUT_ITEM_BASICINFO_BLOODSEROVARCODE = new LayoutItem(
  "血液型(亜型)コード",
  "pat_blood_type_serovar"
);
/** レイアウト項目 本人情報-血液型亜型 */
export const LAYOUT_ITEM_BASICINFO_BLOODSEROVARNAME = new LayoutItem(
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  // "血液型(亜型)",
  "血液型・亜型",
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  `${LAYOUT_ITEM_BASICINFO_BLOODSEROVARCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
/** レイアウト項目 本人情報-国籍 */
export const LAYOUT_ITEM_BASICINFO_NATIONALITYCODE = new LayoutItem(
  "国籍コード",
  "nationality"
);
export const LAYOUT_ITEM_BASICINFO_NATIONALITYNAME = new LayoutItem(
  "国籍",
  `${LAYOUT_ITEM_BASICINFO_NATIONALITYCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
/** レイアウト項目 本人情報-連絡先-郵便番号 */
// mod データリストレイアウトマスタコンテンツの変更  王 start
export const LAYOUT_ITEM_BASICINFO_CONTACT_ZIPCD = new LayoutItem(
  "郵便番号（ハイフンなし）",
  "zip_cd"
);
// mod データリストレイアウトマスタコンテンツの変更  王 end
/** レイアウト項目 本人情報-連絡先-住所 */
export const LAYOUT_ITEM_BASICINFO_CONTACT_ADDRESS = new LayoutItem(
  "住所",
  "address"
);
/** レイアウト項目 本人情報-連絡先-電話番号 */
export const LAYOUT_ITEM_BASICINFO_CONTACT_TEL1 = new LayoutItem(
  "電話番号",
  "tel1"
);
/** レイアウト項目 本人情報-連絡先-電話番号2 */
export const LAYOUT_ITEM_BASICINFO_CONTACT_TEL2 = new LayoutItem(
  "電話番号2",
  "tel2"
);
/** レイアウト項目 本人情報-連絡先-FAX */
export const LAYOUT_ITEM_BASICINFO_CONTACT_FAX = new LayoutItem("FAX", "fax");
/** レイアウト項目 本人情報-連絡先-Email */
export const LAYOUT_ITEM_BASICINFO_CONTACT_EMAIL = new LayoutItem(
  "Email",
  "e_mail"
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
/** レイアウト項目 本人情報-連絡先-勤務先名 */
export const LAYOUT_ITEM_BASICINFO_CONTACT_WORK_NAME = new LayoutItem(
  "勤務先名",
  "work_name"
);
/** レイアウト項目 本人情報-連絡先-勤務先電話番号 */
export const LAYOUT_ITEM_BASICINFO_CONTACT_WORK_TEL = new LayoutItem(
  "勤務先電話番号",
  "work_tel"
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
/** レイアウト項目 本人情報-連絡先-メモ1 */
export const LAYOUT_ITEM_BASICINFO_CONTACT_MEMO1 = new LayoutItem(
  "メモ1",
  "memo1"
);
/** レイアウト項目 本人情報-連絡先-メモ2 */
export const LAYOUT_ITEM_BASICINFO_CONTACT_MEMO2 = new LayoutItem(
  "メモ2",
  "memo2"
);

/* レイアウトカテゴリ 連絡先 */
/** レイアウト項目 連絡先-氏名(姓) */
export const LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAME = new LayoutItem(
  "氏名(姓)",
  "last_name"
);
/** レイアウト項目 連絡先-氏名(名) */
export const LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAME = new LayoutItem(
  "氏名(名)",
  "first_name"
);
/** レイアウト項目 連絡先-フリガナ(姓) */
// export const LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAMEKANA = new LayoutItem('フリガナ(姓)', 'last_name_kana');
/** レイアウト項目 連絡先-フリガナ(名) */
// export const LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAMEKANA = new LayoutItem('フリガナ(名)', 'first_name_kana');
/** レイアウト項目 連絡先-続柄コード(非表示) */
export const LAYOUT_ITEM_OTHERCONTACTINFO_RELATIONCD = new LayoutItem(
  "続柄コード",
  "relation_cd"
);
/** レイアウト項目 連絡先-続柄 */
export const LAYOUT_ITEM_OTHERCONTACTINFO_RELATION = new LayoutItem(
  "続柄",
  "relation_name"
);
/** レイアウト項目 連絡先-郵便番号 */
export const LAYOUT_ITEM_OTHERCONTACTINFO_ZIPCD = new LayoutItem(
  "郵便番号",
  "zip_cd"
);
/** レイアウト項目 連絡先-住所 */
export const LAYOUT_ITEM_OTHERCONTACTINFO_ADDRESS = new LayoutItem(
  "住所",
  "address"
);
/** レイアウト項目 連絡先-電話番号 */
export const LAYOUT_ITEM_OTHERCONTACTINFO_TEL1 = new LayoutItem(
  "電話番号",
  "tel1"
);
/** レイアウト項目 連絡先-電話番号2 */
export const LAYOUT_ITEM_OTHERCONTACTINFO_TEL2 = new LayoutItem(
  "電話番号2",
  "tel2"
);
/** レイアウト項目 連絡先-FAX */
export const LAYOUT_ITEM_OTHERCONTACTINFO_FAX = new LayoutItem("FAX", "fax");
/** レイアウト項目 連絡先-Email */
export const LAYOUT_ITEM_OTHERCONTACTINFO_EMAIL = new LayoutItem(
  "Email",
  "e_mail"
);
/** レイアウト項目 連絡先-勤務先 */
export const LAYOUT_ITEM_OTHERCONTACTINFO_WORKNAME = new LayoutItem(
  "勤務先",
  "work_name"
);
/** レイアウト項目 連絡先-勤務先電話番号 */
export const LAYOUT_ITEM_OTHERCONTACTINFO_WORKTEL = new LayoutItem(
  "勤務先電話番号",
  "work_tel"
);
/** レイアウト項目 連絡先-メモ1 */
export const LAYOUT_ITEM_OTHERCONTACTINFO_MEMO1 = new LayoutItem(
  "メモ1",
  "memo1"
);
/** レイアウト項目 連絡先-メモ2 */
export const LAYOUT_ITEM_OTHERCONTACTINFO_MEMO2 = new LayoutItem(
  "メモ2",
  "memo2"
);

/* レイアウトカテゴリ 連絡先(業者) */
/** レイアウト項目 連絡先(業者)-会社名 */
export const LAYOUT_ITEM_VENDORCONTACTINFO_COMPANYNAME = new LayoutItem(
  "会社名",
  "company_name"
);
/** レイアウト項目 連絡先(業者)-郵便番号 */
export const LAYOUT_ITEM_VENDORCONTACTINFO_ZIPCD = new LayoutItem(
  "郵便番号",
  "zip_cd"
);
/** レイアウト項目 連絡先(業者)-住所 */
export const LAYOUT_ITEM_VENDORCONTACTINFO_ADDRESS = new LayoutItem(
  "住所",
  "address"
);
/** レイアウト項目 連絡先(業者)-代表電話番号 */
export const LAYOUT_ITEM_VENDORCONTACTINFO_COMPANYTEL = new LayoutItem(
  "代表電話番号",
  "company_tel"
);
/** レイアウト項目 連絡先(業者)-代表Fax */
export const LAYOUT_ITEM_VENDORCONTACTINFO_FAX = new LayoutItem(
  "代表Fax",
  "fax"
);
/** レイアウト項目 連絡先(業者)-担当者名(姓) */
export const LAYOUT_ITEM_VENDORCONTACTINFO_WORKERLASTNAME = new LayoutItem(
  "担当者名(姓)",
  "worker_last_name"
);
/** レイアウト項目 連絡先(業者)-担当者名(名) */
export const LAYOUT_ITEM_VENDORCONTACTINFO_WORKERFIRSTNAME = new LayoutItem(
  "担当者名(名)",
  "worker_first_name"
);
/** レイアウト項目 連絡先(業者)-電話番号 */
export const LAYOUT_ITEM_VENDORCONTACTINFO_WORKERTEL = new LayoutItem(
  "電話番号",
  "worker_tel"
);
/** レイアウト項目 連絡先(業者)-Email */
export const LAYOUT_ITEM_VENDORCONTACTINFO_WORKEREMAIL = new LayoutItem(
  "Email",
  "worker_e_mail"
);
/** レイアウト項目 連絡先(業者)-メモ1 */
export const LAYOUT_ITEM_VENDORCONTACTINFO_MEMO1 = new LayoutItem(
  "メモ1",
  "memo1"
);
/** レイアウト項目 連絡先(業者)-メモ2 */
export const LAYOUT_ITEM_VENDORCONTACTINFO_MEMO2 = new LayoutItem(
  "メモ2",
  "memo2"
);

/* レイアウトカテゴリ 患者メモ */
/** レイアウト項目 患者メモ-タイトル1 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_1 = new LayoutItem(
  "タイトル1",
  "title$0"
);
/** レイアウト項目 患者メモ-内容1 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_1 = new LayoutItem(
  "内容1",
  "content$0"
);
/** レイアウト項目 患者メモ-タイトル2 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_2 = new LayoutItem(
  "タイトル2",
  "title$1"
);
/** レイアウト項目 患者メモ-内容2 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_2 = new LayoutItem(
  "内容2",
  "content$1"
);
/** レイアウト項目 患者メモ-タイトル3 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_3 = new LayoutItem(
  "タイトル3",
  "title$2"
);
/** レイアウト項目 患者メモ-内容3 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_3 = new LayoutItem(
  "内容3",
  "content$2"
);
/** レイアウト項目 患者メモ-タイトル4 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_4 = new LayoutItem(
  "タイトル4",
  "title$3"
);
/** レイアウト項目 患者メモ-内容4 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_4 = new LayoutItem(
  "内容4",
  "content$3"
);
/** レイアウト項目 患者メモ-タイトル5 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_5 = new LayoutItem(
  "タイトル5",
  "title$4"
);
/** レイアウト項目 患者メモ-内容5 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_5 = new LayoutItem(
  "内容5",
  "content$4"
);
/** レイアウト項目 患者メモ-タイトル6 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_6 = new LayoutItem(
  "タイトル6",
  "title$5"
);
/** レイアウト項目 患者メモ-内容6 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_6 = new LayoutItem(
  "内容6",
  "content$5"
);
/** レイアウト項目 患者メモ-タイトル7 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_7 = new LayoutItem(
  "タイトル7",
  "title$6"
);
/** レイアウト項目 患者メモ-内容7 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_7 = new LayoutItem(
  "内容7",
  "content$6"
);
/** レイアウト項目 患者メモ-タイトル8 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_8 = new LayoutItem(
  "タイトル8",
  "title$7"
);
/** レイアウト項目 患者メモ-内容8 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_8 = new LayoutItem(
  "内容8",
  "content$7"
);
/** レイアウト項目 患者メモ-タイトル9 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_9 = new LayoutItem(
  "タイトル9",
  "title$8"
);
/** レイアウト項目 患者メモ-内容9 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_9 = new LayoutItem(
  "内容9",
  "content$8"
);
/** レイアウト項目 患者メモ-タイトル10 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_10 = new LayoutItem(
  "タイトル10",
  "title$9"
);
/** レイアウト項目 患者メモ-内容10 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_10 = new LayoutItem(
  "内容10",
  "content$9"
);
/** レイアウト項目 患者メモ-タイトル11 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_11 = new LayoutItem(
  "タイトル11",
  "title$10"
);
/** レイアウト項目 患者メモ-内容11 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_11 = new LayoutItem(
  "内容11",
  "content$10"
);
/** レイアウト項目 患者メモ-タイトル12 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_12 = new LayoutItem(
  "タイトル12",
  "title$11"
);
/** レイアウト項目 患者メモ-内容12 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_12 = new LayoutItem(
  "内容12",
  "content$11"
);
/** レイアウト項目 患者メモ-タイトル13 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_13 = new LayoutItem(
  "タイトル13",
  "title$12"
);
/** レイアウト項目 患者メモ-内容13 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_13 = new LayoutItem(
  "内容13",
  "content$12"
);
/** レイアウト項目 患者メモ-タイトル14 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_14 = new LayoutItem(
  "タイトル14",
  "title$13"
);
/** レイアウト項目 患者メモ-内容14 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_14 = new LayoutItem(
  "内容14",
  "content$13"
);
/** レイアウト項目 患者メモ-タイトル15 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_15 = new LayoutItem(
  "タイトル15",
  "title$14"
);
/** レイアウト項目 患者メモ-内容15 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_15 = new LayoutItem(
  "内容15",
  "content$14"
);
/** レイアウト項目 患者メモ-タイトル16 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_16 = new LayoutItem(
  "タイトル16",
  "title$15"
);
/** レイアウト項目 患者メモ-内容16 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_16 = new LayoutItem(
  "内容16",
  "content$15"
);
/** レイアウト項目 患者メモ-タイトル17 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_17 = new LayoutItem(
  "タイトル17",
  "title$16"
);
/** レイアウト項目 患者メモ-内容17 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_17 = new LayoutItem(
  "内容17",
  "content$16"
);
/** レイアウト項目 患者メモ-タイトル18 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_18 = new LayoutItem(
  "タイトル18",
  "title$17"
);
/** レイアウト項目 患者メモ-内容18 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_18 = new LayoutItem(
  "内容18",
  "content$17"
);
/** レイアウト項目 患者メモ-タイトル19 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_19 = new LayoutItem(
  "タイトル19",
  "title$18"
);
/** レイアウト項目 患者メモ-内容19 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_19 = new LayoutItem(
  "内容19",
  "content$18"
);
/** レイアウト項目 患者メモ-タイトル20 */
export const LAYOUT_ITEM_PATMEMOINFO_TITLE_20 = new LayoutItem(
  "タイトル20",
  "title$19"
);
/** レイアウト項目 患者メモ-内容20 */
export const LAYOUT_ITEM_PATMEMOINFO_CONTENT_20 = new LayoutItem(
  "内容20",
  "content$19"
);

/* レイアウトカテゴリ 透析困難(主) */
/** レイアウト項目 透析困難(主) */
export const LAYOUT_ITEM_DIFFICULTY_MAIN = new LayoutItem(
  "透析困難(主)",
  "difficulty_main"
);

/* レイアウトカテゴリ 透析困難 */
/** レイアウト項目 透析困難 */
export const LAYOUT_ITEM_DIFFICULTY_OTHER = new LayoutItem(
  "透析困難",
  "difficulty_other"
);

/* レイアウトカテゴリ 重症度 */
/** レイアウト項目 重症度-重症度コード(非表示) */
export const LAYOUT_ITEM_SEVERITYCODE = new LayoutItem(
  "重症度コード",
  "severity_cd"
);
/** レイアウト項目 重症度 */
export const LAYOUT_ITEM_SEVERITYNAME = new LayoutItem(
  "重症度",
  `${LAYOUT_ITEM_SEVERITYCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);

/* レイアウトカテゴリ 搬送区分 */
/** レイアウト項目 搬送区分-搬送区分コード(非表示) */
export const LAYOUT_ITEM_TRANSPORTCODE = new LayoutItem(
  "搬送区分コード",
  "transport_cd"
);
/** レイアウト項目 搬送区分 */
export const LAYOUT_ITEM_TRANSPORTNAME = new LayoutItem(
  "搬送区分",
  `${LAYOUT_ITEM_TRANSPORTCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);

/* レイアウトカテゴリ 診療情報 */
/** レイアウト項目 診療情報-診療科コード(非表示) */
export const LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSECODE = new LayoutItem(
  "診療科コード",
  "main_course_cd"
);
/** レイアウト項目 診療情報-診療科 */
export const LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSENAME = new LayoutItem(
  "診療科",
  `${LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSECODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 診療情報-透析実施科コード(非表示) */
export const LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSECODE = new LayoutItem(
  "透析実施科コード",
  "dialysis_course_cd"
);
/** レイアウト項目 診療情報-透析実施科 */
export const LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSENAME = new LayoutItem(
  "透析実施科",
  `${LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSECODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 診療情報-病棟コード(非表示) */
export const LAYOUT_ITEM_MEDICALCAREINFO_WARDCODE = new LayoutItem(
  "病棟コード",
  "ward_cd"
);
/** レイアウト項目 診療情報-病棟 */
export const LAYOUT_ITEM_MEDICALCAREINFO_WARDNAME = new LayoutItem(
  "病棟",
  `${LAYOUT_ITEM_MEDICALCAREINFO_WARDCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 診療情報-自施設通算透析回数 */
export const LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOUNT = new LayoutItem(
  "自施設通算透析回数",
  "dialysis_count"
);
/** レイアウト項目 診療情報-患者通算透析回数 */
export const LAYOUT_ITEM_MEDICALCAREINFO_PAT_DIALYSIS_COUNT = new LayoutItem(
  "患者通算透析回数",
  "pat_dialysis_count"
);
/** レイアウト項目 診療情報-自施設通算特殊浄化回数 */
export const LAYOUT_ITEM_MEDICALCAREINFO_PURIFICATIONCOUNT = new LayoutItem(
  "自施設通算特殊浄化回数",
  "purification_count"
);
/** レイアウト項目 診療情報-導入日 */
export const LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISSTARTDATE = new LayoutItem(
  "導入日",
  "dialysis_start_date"
);
/** レイアウト項目 診療情報-導入施設 */
/*add FNSI-改修内容5202 任 start*/
/*export const LAYOUT_ITEM_MEDICALCAREINFO_FACILITYNAME = new LayoutItem(
  "導入施設",
  "facility_cd"
);*/
export const LAYOUT_ITEM_MEDICALCAREINFO_FACILITYCODE = new LayoutItem(
  "導入施設コード",
  "facility_cd"
);
/*add FNSI-改修内容5202 任 end*/
/*add FNSI-改修内容5202 任 start*/
export const LAYOUT_ITEM_MEDICALCAREINFO_FACILITYNAME = new LayoutItem(
  "施設",
  `${LAYOUT_ITEM_MEDICALCAREINFO_FACILITYCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/*add FNSI-改修内容5202 任 end*/
/** レイアウト項目 診療情報-透析歴 */
export const LAYOUT_ITEM_MEDICALCAREINFO_DYALYSISHST = new LayoutItem(
  "透析歴",
  "dyalysis_hst"
);

/* レイアウトカテゴリ 担当者 */
/** レイアウト項目 担当者-主治医①コード(非表示) */
export const LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_1 = new LayoutItem(
  "主治医①コード",
  "staff_cd$is_main$1"
);
/** レイアウト項目 担当者-主治医① */
// export const LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_1 = new LayoutItem(
//   "主治医①",
//   `${LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_1.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
// );
export const LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_1 = new LayoutItem(
  "主治医",
  `${LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_1.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 担当者-主治医②コード(非表示) */
export const LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_2 = new LayoutItem(
  "主治医②コード",
  "staff_cd$is_main$2"
);
/** レイアウト項目 担当者-主治医② */
export const LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_2 = new LayoutItem(
  "主治医②",
  `${LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_2.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 担当者-担当①コード(非表示) */
export const LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_1 = new LayoutItem(
  "担当①コード",
  "staff_cd$is_charge$1"
);
/** レイアウト項目 担当者-担当① */
// export const LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_1 = new LayoutItem(
//   "担当①",
//   `${LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_1.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
// );
export const LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_1 = new LayoutItem(
  "担当",
  `${LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_1.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 担当者-担当②コード(非表示) */
export const LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_2 = new LayoutItem(
  "担当②コード",
  "staff_cd$is_charge$2"
);
/** レイアウト項目 担当者-担当② */
export const LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_2 = new LayoutItem(
  "担当②",
  `${LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_2.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 担当者-担当③コード(非表示) */
export const LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_3 = new LayoutItem(
  "担当③コード",
  "staff_cd$is_charge$3"
);
/** レイアウト項目 担当者-担当③ */
export const LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_3 = new LayoutItem(
  "担当③",
  `${LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_3.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 担当者-穿刺①コード(非表示) */
export const LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_1 = new LayoutItem(
  "穿刺①コード",
  "staff_cd$is_puncture$1"
);
/** レイアウト項目 担当者-穿刺① */
// export const LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_1 = new LayoutItem(
//   "穿刺①",
//   `${LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_1.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
// );
export const LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_1 = new LayoutItem(
  "穿刺",
  `${LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_1.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 担当者-穿刺②コード(非表示) */
export const LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_2 = new LayoutItem(
  "穿刺②コード",
  "staff_cd$is_puncture$2"
);
/** レイアウト項目 担当者-穿刺② */
export const LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_2 = new LayoutItem(
  "穿刺②",
  `${LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_2.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);

/* レイアウトカテゴリ 禁忌・アレルギー */
/** レイアウト項目 禁忌 */
export const LAYOUT_ITEM_TABOO = new LayoutItem("禁忌", "taboo");
/** レイアウト項目 アレルギー */
export const LAYOUT_ITEM_ALLERGY = new LayoutItem("アレルギー", "allergy");

/* レイアウトカテゴリ 感染症 */
/** レイアウト項目 感染症(+) */
export const LAYOUT_ITEM_POSITIVE_INFECTION = new LayoutItem(
  "感染症(+)",
  "positive_infection"
);
/** レイアウト項目 感染症(-) */
export const LAYOUT_ITEM_NEGATIVE_INFECTION = new LayoutItem(
  "感染症(-)",
  "negative_infection"
);
/** レイアウト項目 感染症(不明) */
export const LAYOUT_ITEM_UNCLEAR_INFECTION = new LayoutItem(
  "感染症(不明)",
  "unclear_infection"
);
// mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
/** レイアウト項目 感染症 */
//export const LAYOUT_ITEM_INFECTION = new LayoutItem("感染症", "infection");
/** 患者グループ 患者グループ */
export const LAYOUT_PATIENTGROUP_PATIENTGROUP = new LayoutItem("患者グループ", "patientGroup");
/** 加算・管理科 加算・管理科 */
export const LAYOUT_ADDITION_ADDITIONKIND = new LayoutItem("加算・管理料", "additionKind");
// mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end

/* レイアウトカテゴリ インプラント */
/** レイアウト項目 インプラント */
export const LAYOUT_ITEM_IMPLANT = new LayoutItem("インプラント", "implant");

/* レイアウトカテゴリ 既往歴 */
/** レイアウト項目 透析導入原疾患 */
export const LAYOUT_ITEM_DISEASE_CD = new LayoutItem(
  "透析導入原疾患コード",
  "disease_cd"
);
export const LAYOUT_ITEM_DISEASE_NAME = new LayoutItem(
  "透析導入原疾患",
  `${LAYOUT_ITEM_DISEASE_CD.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 生検確認有無 */
export const LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYCODE = new LayoutItem(
  "生検確認有無コード",
  "is_confirmation_biopsy"
);
export const LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYNAME = new LayoutItem(
  "生検確認有無",
  `${LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 透析導入原疾患発症日 */
export const LAYOUT_ITEM_DISEASE_DATE = new LayoutItem(
  "透析導入原疾患発症日",
  "disease_date"
);
/** レイアウト項目 死亡日 */
export const LAYOUT_ITEM_OUT_COME_DATE = new LayoutItem(
  "死亡日",
  "out_come_date"
);
/** レイアウト項目 死因 */
export const LAYOUT_ITEM_CAUSE_DEATH_CODE = new LayoutItem("死因コード", "cause_death");
export const LAYOUT_ITEM_CAUSE_DEATH_NAME = new LayoutItem(
  "死因",
  `${LAYOUT_ITEM_CAUSE_DEATH_CODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 確診有無コード(非表示) */
export const LAYOUT_ITEM_IS_DIAGNOSEDCODE = new LayoutItem(
  "確診有無コード",
  "is_diagnosed"
);
/** レイアウト項目 確診有無 */
export const LAYOUT_ITEM_IS_DIAGNOSEDNAME = new LayoutItem(
  "確診有無",
  `${LAYOUT_ITEM_IS_DIAGNOSEDCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 糖尿病患者コード(非表示) */
export const LAYOUT_ITEM_IS_DIABETESCODE = new LayoutItem(
  "糖尿病患者コード",
  "is_diabetes"
);
/** レイアウト項目 糖尿病患者 */
export const LAYOUT_ITEM_IS_DIABETESNAME = new LayoutItem(
  "糖尿病患者",
  `${LAYOUT_ITEM_IS_DIABETESCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 血糖検査コード(非表示) */
export const LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMCODE = new LayoutItem(
  "血糖検査コード",
  "is_blood_suger_exam"
);
/** レイアウト項目 血糖検査 */
export const LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMNAME = new LayoutItem(
  "血糖検査",
  `${LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 主病名① */
// export const LAYOUT_ITEM_IS_NOTICE = new LayoutItem("主病名①", "is_notice");
export const LAYOUT_ITEM_IS_NOTICE = new LayoutItem("主病名", "is_notice");
/** レイアウト項目 主病名② */
export const LAYOUT_ITEM_IS_NOTICE_2 = new LayoutItem("主病名②", "is_notice_2");
/** レイアウト項目 主病名③ */
export const LAYOUT_ITEM_IS_NOTICE_3 = new LayoutItem("主病名③", "is_notice_3");

/* レイアウトカテゴリ 身体情報(追加登録) */

// mod データリストレイアウトマスタコンテンツの変更  王 start
/** レイアウト項目 検査日時 */
export const LAYOUT_ITEM_INSPECTION_DATE_TIME = new LayoutItem("検査日時", "inspection_date_time");
/** レイアウト項目 検査時体重 */
export const LAYOUT_ITEM_WEIGHT_AT_TIME_INSPECTION = new LayoutItem("検査時体重", "weight_at_time_inspection");
/** レイアウト項目 身長 */
export const LAYOUT_ITEM_STATURE = new LayoutItem("身長", "stature");
/** レイアウト項目 CTR・心横径・胸郭横径 */
export const LAYOUT_ITEM_CTR_CARDIAC_LATERAL_DIAMETER = new LayoutItem("CTR・心横径・胸郭横径", "ctr_cardiac_lateral_diameter_chest_lateral_diameter");
/** レイアウト項目 DW・目標体重 */
export const LAYOUT_ITEM_DW_TARGET_WEIGHT = new LayoutItem("DW・目標体重", "dw_target_weight");
/** レイアウト項目 前体重許容上限 */
export const LAYOUT_ITEM_PREVIOUS_WEIGHT_ALLOWANCE_LIMIT = new LayoutItem("前体重許容上限", "previous_weight_allowance_limit");
/** レイアウト項目 前体重許容下限 */
export const LAYOUT_ITEM_PRE_WEIGHT_TOLERANCE_LOWER_LIMIT = new LayoutItem("前体重許容下限", "pre_weight_tolerance_lower_limit");
/** レイアウト項目 メモ */
export const layout_item_MEMORANDUM = new LayoutItem("メモ", "memorandum");
// mod データリストレイアウトマスタコンテンツの変更  王 end

/** レイアウト項目 検査日 */
export const LAYOUT_ITEM_EXAM_DATE = new LayoutItem("検査日", "exam_date");
/** レイアウト項目 検査時刻 */
export const LAYOUT_ITEM_EXAM_TIME = new LayoutItem("検査時刻", "exam_time");
/** レイアウト項目 測定区分コード(非表示) */
export const LAYOUT_ITEM_ORDER_CLASSCODE = new LayoutItem(
  "測定区分コード",
  "order_class"
);
/** レイアウト項目 測定区分 */
export const LAYOUT_ITEM_ORDER_CLASSNAME = new LayoutItem(
  "検査タイミング",
  `${LAYOUT_ITEM_ORDER_CLASSCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
/** レイアウト項目 身長 */
export const LAYOUT_ITEM_HEIGHT = new LayoutItem("身長", "height");
/** レイアウト項目 測定時の体重 */
export const LAYOUT_ITEM_CTR_WEIGHT = new LayoutItem(
  "検査時体重",
  "ctr_weight"
);
/** レイアウト項目 心横径 */
export const LAYOUT_ITEM_BREAST_DIA = new LayoutItem("心横径", "breast_dia");
/** レイアウト項目 胸郭横径 */
export const LAYOUT_ITEM_CHEST_DIA = new LayoutItem("胸郭横径", "chest_dia");
/** レイアウト項目 CTR */
export const LAYOUT_ITEM_CTR = new LayoutItem("CTR", "ctr");
/** レイアウト項目 DW */
export const LAYOUT_ITEM_DW = new LayoutItem("DW", "dw");
/** レイアウト項目 目標体重 */
export const LAYOUT_ITEM_TARGET_WEIGHT = new LayoutItem(
  "目標体重",
  "target_weight"
);
/** レイアウト項目 目標体重指示開始日 */
export const LAYOUT_ITEM_INDICATOR_START_DATE = new LayoutItem(
  "目標体重指示開始日",
  "indicator_start_date"
);
/** レイアウト項目 指示者コード(非表示) */
export const LAYOUT_ITEM_INDICATOR_CDCODE = new LayoutItem(
  "指示者コード",
  "indicator_cd"
);
/** レイアウト項目 指示者 */
export const LAYOUT_ITEM_INDICATOR_CDNAME = new LayoutItem(
  "指示者",
  `${LAYOUT_ITEM_INDICATOR_CDCODE.key}${LAYOUT_ITEM_KEY_SUFFIX_MSTNAME}`
);
// add データリストの患者情報修正 陳 start
/** レイアウト項目 メモ */
export const LAYOUT_ITEM_PRE_SCALE_UPPER = new LayoutItem("前体重許容上限", "pre_scale_upper");
/** レイアウト項目 メモ */
export const LAYOUT_ITEM_PRE_SCALE_LOWER = new LayoutItem("前体重許容下限", "pre_scale_lower");
// add データリストの患者情報修正 陳 end
/** レイアウト項目 メモ */
export const LAYOUT_ITEM_MEMO = new LayoutItem("メモ", "memo");

/* レイアウトカテゴリ 身体情報(最新：身長) */
/** レイアウト項目 測定日 */
export const LAYOUT_ITEM_HEIGHT_EXAM_DATE = new LayoutItem(
  "測定日",
  "exam_date"
);
/** レイアウト項目 測定時刻 */
export const LAYOUT_ITEM_HEIGHT_EXAM_TIME = new LayoutItem(
  "測定時刻",
  "exam_time"
);
/** レイアウト項目 身長 */
export const LAYOUT_ITEM_HEIGHT_HEIGHT = new LayoutItem("身長", "height");

/* レイアウトカテゴリ 身体情報(最新：DW) */
/** レイアウト項目 測定日 */
export const LAYOUT_ITEM_DW_EXAM_DATE = new LayoutItem("測定日", "exam_date");
/** レイアウト項目 測定時刻 */
export const LAYOUT_ITEM_DW_EXAM_TIME = new LayoutItem("測定時刻", "exam_time");
/** レイアウト項目 測定区分 */
export const LAYOUT_ITEM_DW_ORDER_CLASS = new LayoutItem(
  "測定区分",
  "order_class"
);
/** レイアウト項目 測定時の体重 */
export const LAYOUT_ITEM_DW_TR_WEIGHT = new LayoutItem(
  "測定時の体重",
  "tr_weight"
);
/** レイアウト項目 心横径 */
export const LAYOUT_ITEM_DW_BREAST_DIA = new LayoutItem("心横径", "breast_dia");
/** レイアウト項目 胸郭横径 */
export const LAYOUT_ITEM_DW_CHEST_DIA = new LayoutItem("胸郭横径", "chest_dia");
/** レイアウト項目 CTR */
export const LAYOUT_ITEM_DW_CTR = new LayoutItem("CTR", "ctr");
/** レイアウト項目 DW */
export const LAYOUT_ITEM_DW_DW = new LayoutItem("DW", "dw");

/* レイアウトカテゴリ 身体情報(最新：CTR) */
/** レイアウト項目 測定日 */
export const LAYOUT_ITEM_CTR_EXAM_DATE = new LayoutItem("測定日", "exam_date");
/** レイアウト項目 測定時刻 */
export const LAYOUT_ITEM_CTR_EXAM_TIME = new LayoutItem(
  "測定時刻",
  "exam_time"
);
/** レイアウト項目 測定区分 */
export const LAYOUT_ITEM_CTR_ORDER_CLASS = new LayoutItem(
  "測定区分",
  "order_class"
);
/** レイアウト項目 測定時の体重 */
export const LAYOUT_ITEM_CTR_TR_WEIGHT = new LayoutItem(
  "測定時の体重",
  "tr_weight"
);
/** レイアウト項目 心横径 */
export const LAYOUT_ITEM_CTR_BREAST_DIA = new LayoutItem(
  "心横径",
  "breast_dia"
);
/** レイアウト項目 胸郭横径 */
export const LAYOUT_ITEM_CTR_CHEST_DIA = new LayoutItem(
  "胸郭横径",
  "chest_dia"
);
/** レイアウト項目 カード作成 */
export const LAYOUT_ITEM_CARD_CREATION = new LayoutItem(
  "カード作成",
  "card_creation"
);
/** レイアウト項目 CTR */
export const LAYOUT_ITEM_CTR_CTR = new LayoutItem("CTR", "ctr");
/** レイアウト項目 DW */
export const LAYOUT_ITEM_CTR_DW = new LayoutItem("DW", "dw");

/**
 * @description kendo-grid-columnオブジェクト定義用内部関数
 * @param {Array} layoutItemDefs レイアウト項目定義配列
 * @param {String} table 項目の参照テーブル名(pat_personal_main/pat_main/pat_unique)
 * @param {String} jsonColumn JSON項目の参照カラム名 ※JSON項目の場合のみ指定
 * @param {Number} jsonArrayIndex JSON配列項目の要素番号 ※JSON配列項目の場合のみ指定
 * @returns {Object} kendo-grid-columnオブジェクト
 *   {
 *     <レイアウト項目キー>: {
 *       title: <layoutItemDef.title>,
 *       field: <table($jsonColumn)$layoutItemDef.key($jsonArrayIndex)>
 *     }
 *   }
 */
const defineKendoColumns = (
  layoutItemDefs,
  table,
  jsonColumn,
  jsonArrayIndex
) => {
  const kendoColumns = {};
  // ソート不可のタイトル一覧
  const unsortableTitles = ["検査タイミング", "検査日", "検査時刻", "目標体重", "指示者"];
  layoutItemDefs.forEach(({ title, key: itemKey }) => {
    kendoColumns[itemKey] = {
      title,
      field: `${table}${jsonColumn ? `$${jsonColumn}` : ""}$${itemKey}${
        jsonArrayIndex >= 0 ? `$${jsonArrayIndex}` : ""
      }`,
      ...(unsortableTitles.includes(title) ? { sortable: false } : {})
    };
  });
  return kendoColumns;
};

const PAT_PERSONAL_MAIN = "pat_personal_main";
const PAT_MAIN = "pat_main";
const PAT_UNIQUE = "pat_unique";

const kendoColumnsBasicInfo = defineKendoColumns(
  [
    LAYOUT_ITEM_BASICINFO_PATID,
    LAYOUT_ITEM_BASICINFO_HOSPPATID,
    LAYOUT_ITEM_BASICINFO_NAME,
    LAYOUT_ITEM_BASICINFO_NAMEKANA,
    LAYOUT_ITEM_BASICINFO_NAMEALPHA,
    LAYOUT_ITEM_BASICINFO_INOUT,
// add FNSI テンプレート：患者情報１全項目表示時、画面表示不正 dou start
    LAYOUT_ITEM_BASICINFO_INHOSPITALSTATE,
// add FNSI テンプレート：患者情報１全項目表示時、画面表示不正 dou end
    LAYOUT_ITEM_BASICINFO_BIRTHDAY,
    LAYOUT_ITEM_BASICINFO_BIRTHDAYDATEOBJECT,
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    LAYOUT_ITEM_BASICINFO_AGE,
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    LAYOUT_ITEM_BASICINFO_SEXCODE,
    LAYOUT_ITEM_BASICINFO_SEXNAME,
    LAYOUT_ITEM_BASICINFO_BLOODABOCODE,
    LAYOUT_ITEM_BASICINFO_BLOODABONAME,
    LAYOUT_ITEM_BASICINFO_BLOODRHCODE,
    LAYOUT_ITEM_BASICINFO_BLOODRHNAME,
    LAYOUT_ITEM_BASICINFO_BLOODSEROVARCODE,
    LAYOUT_ITEM_BASICINFO_BLOODSEROVARNAME,
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    LAYOUT_ITEM_BASICINFO_NATIONALITYCODE,
    LAYOUT_ITEM_BASICINFO_NATIONALITYNAME
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
  ],
  PAT_PERSONAL_MAIN
);

const PAT_CONTACT_INFO = "pat_contact_info";
const kendoColumnsBasicInfoContact = defineKendoColumns(
  [
    LAYOUT_ITEM_BASICINFO_CONTACT_ZIPCD,
    LAYOUT_ITEM_BASICINFO_CONTACT_ADDRESS,
    LAYOUT_ITEM_BASICINFO_CONTACT_TEL1,
    LAYOUT_ITEM_BASICINFO_CONTACT_TEL2,
    LAYOUT_ITEM_BASICINFO_CONTACT_FAX,
    LAYOUT_ITEM_BASICINFO_CONTACT_EMAIL,
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    LAYOUT_ITEM_BASICINFO_CONTACT_WORK_NAME,
    LAYOUT_ITEM_BASICINFO_CONTACT_WORK_TEL,
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    LAYOUT_ITEM_BASICINFO_CONTACT_MEMO1,
    LAYOUT_ITEM_BASICINFO_CONTACT_MEMO2
  ],
  PAT_PERSONAL_MAIN,
  PAT_CONTACT_INFO
);

const OTHER_CONTACT_KEYPERSON_INFO = "other_contact_key_person_info";
let kendoCategoryColumnsOtherContactKeyPerson = {};
for (let i = 0; i <= 0; i++) {
  const kendoColumnsOtherContactKeyPerson = defineKendoColumns(
    [
      LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAME,
      LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAME,
      // LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAMEKANA,
      // LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAMEKANA,
      LAYOUT_ITEM_OTHERCONTACTINFO_RELATIONCD,
      LAYOUT_ITEM_OTHERCONTACTINFO_RELATION,
      LAYOUT_ITEM_OTHERCONTACTINFO_ZIPCD,
      LAYOUT_ITEM_OTHERCONTACTINFO_ADDRESS,
      LAYOUT_ITEM_OTHERCONTACTINFO_TEL1,
      LAYOUT_ITEM_OTHERCONTACTINFO_TEL2,
      LAYOUT_ITEM_OTHERCONTACTINFO_FAX,
      LAYOUT_ITEM_OTHERCONTACTINFO_EMAIL,
      LAYOUT_ITEM_OTHERCONTACTINFO_WORKNAME,
      LAYOUT_ITEM_OTHERCONTACTINFO_WORKTEL,
      LAYOUT_ITEM_OTHERCONTACTINFO_MEMO1,
      LAYOUT_ITEM_OTHERCONTACTINFO_MEMO2
    ],
    PAT_PERSONAL_MAIN,
    OTHER_CONTACT_KEYPERSON_INFO,
    i
  );
  kendoCategoryColumnsOtherContactKeyPerson = {
    ...kendoCategoryColumnsOtherContactKeyPerson,
    [LAYOUT_CATEGORY_OTHERCONTACTKEYPERSONINFO[i].key]: {
      ...kendoColumnsOtherContactKeyPerson
    }
  };
}

const OTHER_CONTACT_INFO = "other_contact_info";
let kendoCategoryColumnsOtherContact = {};
for (let i = 0; i <= 2; i++) {
  const kendoColumnsOtherContact = defineKendoColumns(
    [
      LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAME,
      LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAME,
      // LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAMEKANA,
      // LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAMEKANA,
      LAYOUT_ITEM_OTHERCONTACTINFO_RELATIONCD,
      LAYOUT_ITEM_OTHERCONTACTINFO_RELATION,
      LAYOUT_ITEM_OTHERCONTACTINFO_ZIPCD,
      LAYOUT_ITEM_OTHERCONTACTINFO_ADDRESS,
      LAYOUT_ITEM_OTHERCONTACTINFO_TEL1,
      LAYOUT_ITEM_OTHERCONTACTINFO_TEL2,
      LAYOUT_ITEM_OTHERCONTACTINFO_FAX,
      LAYOUT_ITEM_OTHERCONTACTINFO_EMAIL,
      LAYOUT_ITEM_OTHERCONTACTINFO_WORKNAME,
      LAYOUT_ITEM_OTHERCONTACTINFO_WORKTEL,
      LAYOUT_ITEM_OTHERCONTACTINFO_MEMO1,
      LAYOUT_ITEM_OTHERCONTACTINFO_MEMO2
    ],
    PAT_PERSONAL_MAIN,
    OTHER_CONTACT_INFO,
    i
  );
  kendoCategoryColumnsOtherContact = {
    ...kendoCategoryColumnsOtherContact,
    [LAYOUT_CATEGORY_OTHERCONTACTINFO[i].key]: {
      ...kendoColumnsOtherContact
    }
  };
}

const VENDOR_CONTACT_INFO = "vendor_contact_info";
let kendoCategoryColumnsVendorContact = {};
for (let i = 0; i <= 2; i++) {
  const kendoColumnsVendorContact = defineKendoColumns(
    [
      LAYOUT_ITEM_VENDORCONTACTINFO_COMPANYNAME,
      LAYOUT_ITEM_VENDORCONTACTINFO_ZIPCD,
      LAYOUT_ITEM_VENDORCONTACTINFO_ADDRESS,
      LAYOUT_ITEM_VENDORCONTACTINFO_COMPANYTEL,
      LAYOUT_ITEM_VENDORCONTACTINFO_FAX,
      LAYOUT_ITEM_VENDORCONTACTINFO_WORKERLASTNAME,
      LAYOUT_ITEM_VENDORCONTACTINFO_WORKERFIRSTNAME,
      LAYOUT_ITEM_VENDORCONTACTINFO_WORKERTEL,
      LAYOUT_ITEM_VENDORCONTACTINFO_WORKEREMAIL,
      LAYOUT_ITEM_VENDORCONTACTINFO_MEMO1,
      LAYOUT_ITEM_VENDORCONTACTINFO_MEMO2
    ],
    PAT_PERSONAL_MAIN,
    VENDOR_CONTACT_INFO,
    i
  );
  kendoCategoryColumnsVendorContact = {
    ...kendoCategoryColumnsVendorContact,
    [LAYOUT_CATEGORY_VENDORCONTACTINFO[i].key]: {
      ...kendoColumnsVendorContact
    }
  };
}

const PAT_MEMO_INFO = "pat_memo_info";
const kendoColumnsPatMemoInfo = defineKendoColumns(
  [
    LAYOUT_ITEM_PATMEMOINFO_TITLE_1,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_1,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_2,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_2,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_3,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_3,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_4,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_4,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_5,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_5,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_6,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_6,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_7,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_7,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_8,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_8,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_9,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_9,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_10,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_10,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_11,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_11,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_12,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_12,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_13,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_13,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_14,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_14,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_15,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_15,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_16,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_16,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_17,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_17,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_18,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_18,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_19,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_19,
    LAYOUT_ITEM_PATMEMOINFO_TITLE_20,
    LAYOUT_ITEM_PATMEMOINFO_CONTENT_20
  ],
  PAT_MAIN,
  PAT_MEMO_INFO
);

const kendoColumnsDifficultyMain = defineKendoColumns(
  [LAYOUT_ITEM_DIFFICULTY_MAIN],
  PAT_PERSONAL_MAIN
);
const kendoColumnsDifficultyOther = defineKendoColumns(
  [LAYOUT_ITEM_DIFFICULTY_OTHER],
  PAT_PERSONAL_MAIN
);
const kendoColumnsSeverity = defineKendoColumns(
  [LAYOUT_ITEM_SEVERITYCODE, LAYOUT_ITEM_SEVERITYNAME],
  PAT_PERSONAL_MAIN
);
const kendoColumnsTransport = defineKendoColumns(
  [LAYOUT_ITEM_TRANSPORTCODE, LAYOUT_ITEM_TRANSPORTNAME],
  PAT_PERSONAL_MAIN
);

const MEDICAL_CARE_INFO = "medical_care_info";
const kendoColumnsMedicalCareInfo = defineKendoColumns(
  [
    LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSECODE,
    LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSENAME,
    LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSECODE,
    LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSENAME,
    LAYOUT_ITEM_MEDICALCAREINFO_WARDCODE,
    LAYOUT_ITEM_MEDICALCAREINFO_WARDNAME,
    LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOUNT,
    LAYOUT_ITEM_MEDICALCAREINFO_PAT_DIALYSIS_COUNT,
    LAYOUT_ITEM_MEDICALCAREINFO_PURIFICATIONCOUNT,
    LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISSTARTDATE,
    /*add FNSI-改修内容5202 任 start*/
    LAYOUT_ITEM_MEDICALCAREINFO_FACILITYCODE,
    /*add FNSI-改修内容5202 任 end*/
    LAYOUT_ITEM_MEDICALCAREINFO_FACILITYNAME,
    LAYOUT_ITEM_MEDICALCAREINFO_DYALYSISHST
  ],
  PAT_MAIN,
  MEDICAL_CARE_INFO
);

const CHARGE_STAFF_INFO = "charge_staff_info";
const kendoColumnsChargeStaffInfo = defineKendoColumns(
  [
    LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_1,
    LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_1,
    LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_2,
    LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_2,
    LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_1,
    LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_1,
    LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_2,
    LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_2,
    LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_3,
    LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_3,
    LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_1,
    LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_1,
    LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_2,
    LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_2
  ],
  PAT_MAIN,
  CHARGE_STAFF_INFO
);

const CHARGE_TABOO_ALLERGY_INFO = "taboo_allergy_info";
const kendoColumnsTabooAllergyInfo = defineKendoColumns(
  [LAYOUT_ITEM_TABOO, LAYOUT_ITEM_ALLERGY],
  PAT_MAIN,
  CHARGE_TABOO_ALLERGY_INFO
);

const CHARGE_INFECT_INFO = "infect_info";
const kendoColumnsInfectInfo = defineKendoColumns(
  [
    LAYOUT_ITEM_POSITIVE_INFECTION,
    LAYOUT_ITEM_NEGATIVE_INFECTION,
    LAYOUT_ITEM_UNCLEAR_INFECTION
// delete FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    // LAYOUT_ITEM_INFECTION
// delete FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
  ],
  PAT_MAIN,
  CHARGE_INFECT_INFO
);

// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
const kendoColumnsPatientGroup = defineKendoColumns(
  [LAYOUT_PATIENTGROUP_PATIENTGROUP],
  PAT_MAIN
);

const kendoColumnsAddition = defineKendoColumns(
  [LAYOUT_ADDITION_ADDITIONKIND],
  PAT_MAIN
);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end

const kendoColumnsImplantInfo = defineKendoColumns(
  [LAYOUT_ITEM_IMPLANT],
  PAT_MAIN
);

const CHARGE_MEDICAL_HST_INFO = "medical_hst_info";
const kendoColumnsMedicalHstInfo = defineKendoColumns(
  [
    LAYOUT_ITEM_DISEASE_CD,
    LAYOUT_ITEM_DISEASE_NAME,
    LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYCODE,
    LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYNAME,
    LAYOUT_ITEM_DISEASE_DATE,
    LAYOUT_ITEM_OUT_COME_DATE,
    LAYOUT_ITEM_CAUSE_DEATH_CODE,
    LAYOUT_ITEM_CAUSE_DEATH_NAME,
    LAYOUT_ITEM_IS_DIAGNOSEDCODE,
    LAYOUT_ITEM_IS_DIAGNOSEDNAME
  ],
  PAT_UNIQUE,
  CHARGE_MEDICAL_HST_INFO
);

const kendoColumnsMedicalHstContact = defineKendoColumns(
  [
    LAYOUT_ITEM_IS_DIABETESCODE,
    LAYOUT_ITEM_IS_DIABETESNAME,
    LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMCODE,
    LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMNAME
  ],
  PAT_MAIN
);

const kendoColumnsMedicalHstInfo2 = defineKendoColumns(
  [LAYOUT_ITEM_IS_NOTICE, LAYOUT_ITEM_IS_NOTICE_2, LAYOUT_ITEM_IS_NOTICE_3],
  PAT_UNIQUE,
  CHARGE_MEDICAL_HST_INFO
);

const CHARGE_PHYSICAL_INFO = "physical_info";
const kendoColumnsPhysicalInfo = defineKendoColumns(
  [
    LAYOUT_ITEM_EXAM_DATE,
    LAYOUT_ITEM_EXAM_TIME,
    LAYOUT_ITEM_ORDER_CLASSCODE,
    LAYOUT_ITEM_ORDER_CLASSNAME,
    LAYOUT_ITEM_HEIGHT,
    LAYOUT_ITEM_CTR_WEIGHT,
    LAYOUT_ITEM_BREAST_DIA,
    LAYOUT_ITEM_CHEST_DIA,
    LAYOUT_ITEM_CTR,
    LAYOUT_ITEM_DW,
    LAYOUT_ITEM_TARGET_WEIGHT,
    LAYOUT_ITEM_INDICATOR_START_DATE,
    LAYOUT_ITEM_INDICATOR_CDCODE,
    LAYOUT_ITEM_INDICATOR_CDNAME,
// add データリストの患者情報修正 陳 start
    LAYOUT_ITEM_PRE_SCALE_UPPER,
    LAYOUT_ITEM_PRE_SCALE_LOWER,
// add データリストの患者情報修正 陳 end
    LAYOUT_ITEM_MEMO,
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang start
    LAYOUT_ITEM_INSPECTION_DATE_TIME
    // add #11708 データリスト患者情報1の身体情報系データを含むレイアウトが画面表示しない。 fang end
  ],
  PAT_UNIQUE,
  CHARGE_PHYSICAL_INFO
);

const CHARGE_PHYSICAL_INFO_HEIGHT = "physical_info_height";
const kendoColumnsPhysicalInfoHeight = defineKendoColumns(
  [
    LAYOUT_ITEM_HEIGHT_EXAM_DATE,
    LAYOUT_ITEM_HEIGHT_EXAM_TIME,
    LAYOUT_ITEM_HEIGHT_HEIGHT
  ],
  PAT_UNIQUE,
  CHARGE_PHYSICAL_INFO_HEIGHT
);

const CHARGE_PHYSICAL_INFO_DW = "physical_info_dw";
const kendoColumnsPhysicalInfoDw = defineKendoColumns(
  [
    LAYOUT_ITEM_DW_EXAM_DATE,
    LAYOUT_ITEM_DW_EXAM_TIME,
    LAYOUT_ITEM_DW_ORDER_CLASS,
    LAYOUT_ITEM_DW_TR_WEIGHT,
    LAYOUT_ITEM_DW_BREAST_DIA,
    LAYOUT_ITEM_DW_CHEST_DIA,
    LAYOUT_ITEM_DW_CTR,
    LAYOUT_ITEM_DW_DW
  ],
  PAT_UNIQUE,
  CHARGE_PHYSICAL_INFO_DW
);

const CHARGE_PHYSICAL_INFO_CTR = "physical_info_ctr";
const kendoColumnsPhysicalInfoCtr = defineKendoColumns(
  [
    LAYOUT_ITEM_CTR_EXAM_DATE,
    LAYOUT_ITEM_CTR_EXAM_TIME,
    LAYOUT_ITEM_CTR_ORDER_CLASS,
    LAYOUT_ITEM_CTR_TR_WEIGHT,
    LAYOUT_ITEM_CTR_BREAST_DIA,
    LAYOUT_ITEM_CTR_CHEST_DIA,
    LAYOUT_ITEM_CTR_CTR,
    LAYOUT_ITEM_CTR_DW
  ],
  PAT_UNIQUE,
  CHARGE_PHYSICAL_INFO_CTR
);

const CARD_CREATION = "card_creation";
const kendoColumnsCardCreation = defineKendoColumns(
  [
    LAYOUT_ITEM_CARD_CREATION
  ],
  CARD_CREATION,
);

export const KENDO_CATEGORY_COLUMNS = {
  [LAYOUT_CATEGORY_BASICINFO.key]: {
    ...kendoColumnsBasicInfo,
    ...kendoColumnsBasicInfoContact
  },
  ...kendoCategoryColumnsOtherContactKeyPerson,
  ...kendoCategoryColumnsOtherContact,
  ...kendoCategoryColumnsVendorContact,
  [LAYOUT_CATEGORY_PATMEMOINFO.key]: {
    ...kendoColumnsPatMemoInfo
  },
  [LAYOUT_CATEGORY_DIFFICULTY_MAIN.key]: {
    ...kendoColumnsDifficultyMain
  },
  [LAYOUT_CATEGORY_DIFFICULTY_OTHER.key]: {
    ...kendoColumnsDifficultyOther
  },
  [LAYOUT_CATEGORY_SEVERITY.key]: {
    ...kendoColumnsSeverity
  },
  [LAYOUT_CATEGORY_TRANSPORT.key]: {
    ...kendoColumnsTransport
  },
  [LAYOUT_CATEGORY_MEDICALCAREINFO.key]: {
    ...kendoColumnsMedicalCareInfo
  },
  [LAYOUT_CATEGORY_CHARGESTAFFINFO.key]: {
    ...kendoColumnsChargeStaffInfo
  },
  [LAYOUT_CATEGORY_TABOO_ALLERGY_INFO.key]: {
    ...kendoColumnsTabooAllergyInfo
  },
  [LAYOUT_CATEGORY_INFECT_INFO.key]: {
    ...kendoColumnsInfectInfo
  },
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
  [LAYOUT_CATEGORY_PATIENT_GROUP.key]: {
    ...kendoColumnsPatientGroup
  },
  [LAYOUT_CATEGORY_ADDITION.key]: {
    ...kendoColumnsAddition
  },
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
  [LAYOUT_CATEGORY_IMPLANT_INFO.key]: {
    ...kendoColumnsImplantInfo
  },
  [LAYOUT_CATEGORY_MEDICAL_HST_INFO.key]: {
    ...kendoColumnsMedicalHstInfo,
    ...kendoColumnsMedicalHstContact,
    ...kendoColumnsMedicalHstInfo2
  },
  [LAYOUT_CATEGORY_PHYSICAL_INFO.key]: {
    ...kendoColumnsPhysicalInfo
  },
  [LAYOUT_CATEGORY_PHYSICAL_INFO_HEIGHT.key]: {
    ...kendoColumnsPhysicalInfoHeight
  },
  [LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key]: {
    ...kendoColumnsPhysicalInfoDw
  },
  [LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key]: {
    ...kendoColumnsPhysicalInfoCtr
  },
  [LAYOUT_CATEGORY_CARD_CREATION.key]: {
    ...kendoColumnsCardCreation
  }
};

class CodeTypeColumn {
  constructor(code, name) {
    this.code = code;
    this.name = name;
  }
}
const PSEUDO_MST_INOUT = [
  new CodeTypeColumn(0, "外来"),
  new CodeTypeColumn(1, "入院"),
  new CodeTypeColumn(2, "死亡"),
  new CodeTypeColumn(3, "－")
];
const PSEUDO_MST_SEX = [
  new CodeTypeColumn(0, "不明"),
  new CodeTypeColumn(1, "男性"),
  new CodeTypeColumn(2, "女性")
];
const PSEUDO_MST_BLOODABO = [
  new CodeTypeColumn(0, "不明"),
  new CodeTypeColumn(1, "A型"),
  new CodeTypeColumn(2, "B型"),
  new CodeTypeColumn(3, "O型"),
  new CodeTypeColumn(4, "AB型")
];
const PSEUDO_MST_BLOODRH = [
  new CodeTypeColumn(0, "不明"),
  new CodeTypeColumn(1, "Rh+"),
  new CodeTypeColumn(2, "Rh-")
];
const PSEUDO_MST_BLOODSEROVAR = [
  new CodeTypeColumn(0, "不明"),
  new CodeTypeColumn(11, "A1"),
  new CodeTypeColumn(12, "Aint"),
  new CodeTypeColumn(13, "A2"),
  new CodeTypeColumn(14, "A3"),
  new CodeTypeColumn(15, "Ax"),
  new CodeTypeColumn(16, "Am"),
  new CodeTypeColumn(17, "Ael"),
  new CodeTypeColumn(18, "Aend"),
  new CodeTypeColumn(21, "B1"),
  new CodeTypeColumn(22, "Bint"),
  new CodeTypeColumn(23, "B2"),
  new CodeTypeColumn(24, "B3"),
  new CodeTypeColumn(25, "Bx"),
  new CodeTypeColumn(26, "Bm"),
  new CodeTypeColumn(27, "Bel"),
  new CodeTypeColumn(28, "Bend"),
  new CodeTypeColumn(31, "Oh"),
  new CodeTypeColumn(32, "Ah"),
  new CodeTypeColumn(33, "Bh"),
  new CodeTypeColumn(34, "Om"),
  new CodeTypeColumn(35, "Am"),
  new CodeTypeColumn(36, "Bm"),
  new CodeTypeColumn(400, "不明　不明"),
  new CodeTypeColumn(401, "不明　B1"),
  new CodeTypeColumn(402, "不明　Bint"),
  new CodeTypeColumn(403, "不明　B2"),
  new CodeTypeColumn(404, "不明　B3"),
  new CodeTypeColumn(405, "不明　Bx"),
  new CodeTypeColumn(406, "不明　Bm"),
  new CodeTypeColumn(407, "不明　Bel"),
  new CodeTypeColumn(408, "不明　Bend"),
  new CodeTypeColumn(410, "A1　不明"),
  new CodeTypeColumn(411, "A1　B1"),
  new CodeTypeColumn(412, "A1　Bint"),
  new CodeTypeColumn(413, "A1　B2"),
  new CodeTypeColumn(414, "A1　B3"),
  new CodeTypeColumn(415, "A1　Bx"),
  new CodeTypeColumn(416, "A1　Bm"),
  new CodeTypeColumn(417, "A1　Bel"),
  new CodeTypeColumn(418, "A1　Bend"),
  new CodeTypeColumn(420, "Aint　不明"),
  new CodeTypeColumn(421, "Aint　B1"),
  new CodeTypeColumn(422, "Aint　Bint"),
  new CodeTypeColumn(423, "Aint　B2"),
  new CodeTypeColumn(424, "Aint　B3"),
  new CodeTypeColumn(425, "Aint　Bx"),
  new CodeTypeColumn(426, "Aint　Bm"),
  new CodeTypeColumn(427, "Aint　Bel"),
  new CodeTypeColumn(428, "Aint　Bend"),
  new CodeTypeColumn(430, "A2　不明"),
  new CodeTypeColumn(431, "A2　B1"),
  new CodeTypeColumn(432, "A2　Bint"),
  new CodeTypeColumn(433, "A2　B2"),
  new CodeTypeColumn(434, "A2　B3"),
  new CodeTypeColumn(435, "A2　Bx"),
  new CodeTypeColumn(436, "A2　Bm"),
  new CodeTypeColumn(437, "A2　Bel"),
  new CodeTypeColumn(438, "A2　Bend"),
  new CodeTypeColumn(440, "A3　不明"),
  new CodeTypeColumn(441, "A3　B1"),
  new CodeTypeColumn(442, "A3　Bint"),
  new CodeTypeColumn(443, "A3　B2"),
  new CodeTypeColumn(444, "A3　B3"),
  new CodeTypeColumn(445, "A3　Bx"),
  new CodeTypeColumn(446, "A3　Bm"),
  new CodeTypeColumn(447, "A3　Bel"),
  new CodeTypeColumn(448, "A3　Bend"),
  new CodeTypeColumn(450, "Ax　不明"),
  new CodeTypeColumn(451, "Ax　B1"),
  new CodeTypeColumn(452, "Ax　Bint"),
  new CodeTypeColumn(453, "Ax　B2"),
  new CodeTypeColumn(454, "Ax　B3"),
  new CodeTypeColumn(455, "Ax　Bx"),
  new CodeTypeColumn(456, "Ax　Bm"),
  new CodeTypeColumn(457, "Ax　Bel"),
  new CodeTypeColumn(458, "Ax　Bend"),
  new CodeTypeColumn(460, "Am　不明"),
  new CodeTypeColumn(461, "Am　B1"),
  new CodeTypeColumn(462, "Am　Bint"),
  new CodeTypeColumn(463, "Am　B2"),
  new CodeTypeColumn(464, "Am　B3"),
  new CodeTypeColumn(465, "Am　Bx"),
  new CodeTypeColumn(466, "Am　Bm"),
  new CodeTypeColumn(467, "Am　Bel"),
  new CodeTypeColumn(468, "Am　Bend"),
  new CodeTypeColumn(470, "Ael　不明"),
  new CodeTypeColumn(471, "Ael　B1"),
  new CodeTypeColumn(472, "Ael　Bint"),
  new CodeTypeColumn(473, "Ael　B2"),
  new CodeTypeColumn(474, "Ael　B3"),
  new CodeTypeColumn(475, "Ael　Bx"),
  new CodeTypeColumn(476, "Ael　Bm"),
  new CodeTypeColumn(477, "Ael　Bel"),
  new CodeTypeColumn(478, "Ael　Bend"),
  new CodeTypeColumn(480, "Aend　不明"),
  new CodeTypeColumn(481, "Aend　B1"),
  new CodeTypeColumn(482, "Aend　Bint"),
  new CodeTypeColumn(483, "Aend　B2"),
  new CodeTypeColumn(484, "Aend　B3"),
  new CodeTypeColumn(485, "Aend　Bx"),
  new CodeTypeColumn(486, "Aend　Bm"),
  new CodeTypeColumn(487, "Aend　Bel"),
  new CodeTypeColumn(488, "Aend　Bend")
];

const PSEUDO_MST_IS_DIAGNOSED = [
  new CodeTypeColumn("0", "なし"),
  new CodeTypeColumn("1", "あり")
];

const PSEUDO_MST_IS_CONFIRMATION = [
  new CodeTypeColumn("0", "なし"),
  new CodeTypeColumn("1", "あり")
];

const PSEUDO_MST_CHECK = [
  new CodeTypeColumn("0", ""),
  new CodeTypeColumn("1", "◯")
];

const PSEUDO_MST_ORDER_CLASS = [
  new CodeTypeColumn(1, "透析前"),
  new CodeTypeColumn(2, "透析後"),
  new CodeTypeColumn(3, "その他")
];

export const PSEUDO_MST_LIST = {
  inout: PSEUDO_MST_INOUT,
  sex: PSEUDO_MST_SEX,
  bloodABO: PSEUDO_MST_BLOODABO,
  bloodRh: PSEUDO_MST_BLOODRH,
  bloodSerovar: PSEUDO_MST_BLOODSEROVAR,
  isDiagnosed: PSEUDO_MST_IS_DIAGNOSED,
  mstCheck: PSEUDO_MST_CHECK,
  orderClass: PSEUDO_MST_ORDER_CLASS,
  isConfirmation: PSEUDO_MST_IS_CONFIRMATION
};
