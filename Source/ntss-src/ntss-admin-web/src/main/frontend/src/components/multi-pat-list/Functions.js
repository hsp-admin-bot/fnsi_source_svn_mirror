import store from "@/stores";
import { showConfirmDialog } from "@/functions/common/OnsenFunctions";
import $ from "@/compat/jquery";
import dayjs from "@/compat/date/dayjs";
import { createApp, defineComponent } from "@/compat/vue/runtime";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { normalizeGridDateInputValue } from "@/components/common/grid-date-input-display";
import { asKendoJQueryElement, findKendoGridCellByDataItemField, getKendoWidgetValue, setKendoWidgetValue } from "@/functions/common/KendoFunctions";
// add FNSI-改修内容 「測定日」と「目標体重指示開始日」表示IF不正 dou start
// add FNSI-改修内容 「測定日」と「目標体重指示開始日」表示IF不正 dou end
import { addition, courseSelector, dialysisDifficultySelector, diseaseSelector, implantSelector, infectionSelector, patListLayout, severitySelector, tabooAllergySelector, transportSelector, user, wardSelector } from "@/functions/mst/MstGetters.js";
import { KENDO_CATEGORY_COLUMNS, LAYOUT_ADDITION_ADDITIONKIND, LAYOUT_CATEGORY_ADDITION, LAYOUT_CATEGORY_BASICINFO, LAYOUT_CATEGORY_CHARGESTAFFINFO, LAYOUT_CATEGORY_DIFFICULTY_MAIN, LAYOUT_CATEGORY_DIFFICULTY_OTHER, LAYOUT_CATEGORY_IMPLANT_INFO, LAYOUT_CATEGORY_INFECT_INFO, LAYOUT_CATEGORY_MEDICALCAREINFO, LAYOUT_CATEGORY_MEDICAL_HST_INFO, LAYOUT_CATEGORY_OTHERCONTACTINFO, LAYOUT_CATEGORY_OTHERCONTACTKEYPERSONINFO, LAYOUT_CATEGORY_PATIENT_GROUP, LAYOUT_CATEGORY_PATMEMOINFO, LAYOUT_CATEGORY_PHYSICAL_INFO, LAYOUT_CATEGORY_PHYSICAL_INFO_CTR, LAYOUT_CATEGORY_PHYSICAL_INFO_DW, LAYOUT_CATEGORY_PHYSICAL_INFO_HEIGHT, LAYOUT_CATEGORY_SEVERITY, LAYOUT_CATEGORY_TABOO_ALLERGY_INFO, LAYOUT_CATEGORY_TITLES, LAYOUT_CATEGORY_TRANSPORT, LAYOUT_CATEGORY_VENDORCONTACTINFO, LAYOUT_ITEM_ALLERGY, LAYOUT_ITEM_BASICINFO_AGE, LAYOUT_ITEM_BASICINFO_BIRTHDAY, LAYOUT_ITEM_BASICINFO_BIRTHDAYDATEOBJECT, LAYOUT_ITEM_BASICINFO_BLOODABOCODE, LAYOUT_ITEM_BASICINFO_BLOODABONAME, LAYOUT_ITEM_BASICINFO_BLOODRHCODE, LAYOUT_ITEM_BASICINFO_BLOODRHNAME, LAYOUT_ITEM_BASICINFO_BLOODSEROVARCODE, LAYOUT_ITEM_BASICINFO_BLOODSEROVARNAME, LAYOUT_ITEM_BASICINFO_CONTACT_ADDRESS, LAYOUT_ITEM_BASICINFO_CONTACT_EMAIL, LAYOUT_ITEM_BASICINFO_CONTACT_FAX, LAYOUT_ITEM_BASICINFO_CONTACT_MEMO1, LAYOUT_ITEM_BASICINFO_CONTACT_MEMO2, LAYOUT_ITEM_BASICINFO_CONTACT_TEL1, LAYOUT_ITEM_BASICINFO_CONTACT_TEL2, LAYOUT_ITEM_BASICINFO_CONTACT_WORK_NAME, LAYOUT_ITEM_BASICINFO_CONTACT_WORK_TEL, LAYOUT_ITEM_BASICINFO_CONTACT_ZIPCD, LAYOUT_ITEM_BASICINFO_HOSPPATID, LAYOUT_ITEM_BASICINFO_INHOSPITALSTATE, LAYOUT_ITEM_BASICINFO_INOUT, LAYOUT_ITEM_BASICINFO_NAME, LAYOUT_ITEM_BASICINFO_NAMEALPHA, LAYOUT_ITEM_BASICINFO_NAMEKANA, LAYOUT_ITEM_BASICINFO_NATIONALITYCODE, LAYOUT_ITEM_BASICINFO_NATIONALITYNAME, LAYOUT_ITEM_BASICINFO_PATID, LAYOUT_ITEM_BASICINFO_SEXCODE, LAYOUT_ITEM_BASICINFO_SEXNAME, LAYOUT_ITEM_BREAST_DIA, LAYOUT_ITEM_CAUSE_DEATH_CODE, LAYOUT_ITEM_CAUSE_DEATH_NAME, LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_1, LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_2, LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_3, LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_1, LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_2, LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_3, LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_1, LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_2, LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_1, LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_2, LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_1, LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_2, LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_1, LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_2, LAYOUT_ITEM_CHEST_DIA, LAYOUT_ITEM_CTR, LAYOUT_ITEM_CTR_BREAST_DIA, LAYOUT_ITEM_CTR_CHEST_DIA, LAYOUT_ITEM_CTR_CTR, LAYOUT_ITEM_CTR_DW, LAYOUT_ITEM_CTR_EXAM_DATE, LAYOUT_ITEM_CTR_EXAM_TIME, LAYOUT_ITEM_CTR_ORDER_CLASS, LAYOUT_ITEM_CTR_TR_WEIGHT, LAYOUT_ITEM_CTR_WEIGHT, LAYOUT_ITEM_DIFFICULTY_MAIN, LAYOUT_ITEM_DIFFICULTY_OTHER, LAYOUT_ITEM_DISEASE_CD, LAYOUT_ITEM_DISEASE_DATE, LAYOUT_ITEM_DISEASE_NAME, LAYOUT_ITEM_DW, LAYOUT_ITEM_DW_BREAST_DIA, LAYOUT_ITEM_DW_CHEST_DIA, LAYOUT_ITEM_DW_CTR, LAYOUT_ITEM_DW_DW, LAYOUT_ITEM_DW_EXAM_DATE, LAYOUT_ITEM_DW_EXAM_TIME, LAYOUT_ITEM_DW_ORDER_CLASS, LAYOUT_ITEM_DW_TR_WEIGHT, LAYOUT_ITEM_EXAM_DATE, LAYOUT_ITEM_EXAM_TIME, LAYOUT_ITEM_HEIGHT, LAYOUT_ITEM_HEIGHT_EXAM_DATE, LAYOUT_ITEM_HEIGHT_EXAM_TIME, LAYOUT_ITEM_HEIGHT_HEIGHT, LAYOUT_ITEM_IMPLANT, LAYOUT_ITEM_INDICATOR_CDCODE, LAYOUT_ITEM_INDICATOR_CDNAME, LAYOUT_ITEM_INDICATOR_START_DATE, LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMCODE, LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMNAME, LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYCODE, LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYNAME, LAYOUT_ITEM_IS_DIABETESCODE, LAYOUT_ITEM_IS_DIABETESNAME, LAYOUT_ITEM_IS_DIAGNOSEDCODE, LAYOUT_ITEM_IS_DIAGNOSEDNAME, LAYOUT_ITEM_IS_NOTICE, LAYOUT_ITEM_IS_NOTICE_2, LAYOUT_ITEM_IS_NOTICE_3, LAYOUT_ITEM_KEY_SUFFIX_CHKBOX, LAYOUT_ITEM_KEY_SUFFIX_DATEOBJECT, LAYOUT_ITEM_KEY_SUFFIX_MSTNAME, LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOUNT, LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSECODE, LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSENAME, LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISSTARTDATE, LAYOUT_ITEM_MEDICALCAREINFO_DYALYSISHST, LAYOUT_ITEM_MEDICALCAREINFO_FACILITYCODE, LAYOUT_ITEM_MEDICALCAREINFO_FACILITYNAME, LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSECODE, LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSENAME, LAYOUT_ITEM_MEDICALCAREINFO_PAT_DIALYSIS_COUNT, LAYOUT_ITEM_MEDICALCAREINFO_PURIFICATIONCOUNT, LAYOUT_ITEM_MEDICALCAREINFO_WARDCODE, LAYOUT_ITEM_MEDICALCAREINFO_WARDNAME, LAYOUT_ITEM_MEMO, LAYOUT_ITEM_NEGATIVE_INFECTION, LAYOUT_ITEM_ORDER_CLASSNAME, LAYOUT_ITEM_OTHERCONTACTINFO_ADDRESS, LAYOUT_ITEM_OTHERCONTACTINFO_EMAIL, LAYOUT_ITEM_OTHERCONTACTINFO_FAX, LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAME, LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAME, LAYOUT_ITEM_OTHERCONTACTINFO_MEMO1, LAYOUT_ITEM_OTHERCONTACTINFO_MEMO2, LAYOUT_ITEM_OTHERCONTACTINFO_RELATION, LAYOUT_ITEM_OTHERCONTACTINFO_RELATIONCD, LAYOUT_ITEM_OTHERCONTACTINFO_TEL1, LAYOUT_ITEM_OTHERCONTACTINFO_TEL2, LAYOUT_ITEM_OTHERCONTACTINFO_WORKNAME, LAYOUT_ITEM_OTHERCONTACTINFO_WORKTEL, LAYOUT_ITEM_OTHERCONTACTINFO_ZIPCD, LAYOUT_ITEM_OUT_COME_DATE, LAYOUT_ITEM_PATMEMOINFO_CONTENT_1, LAYOUT_ITEM_PATMEMOINFO_CONTENT_10, LAYOUT_ITEM_PATMEMOINFO_CONTENT_11, LAYOUT_ITEM_PATMEMOINFO_CONTENT_12, LAYOUT_ITEM_PATMEMOINFO_CONTENT_13, LAYOUT_ITEM_PATMEMOINFO_CONTENT_14, LAYOUT_ITEM_PATMEMOINFO_CONTENT_15, LAYOUT_ITEM_PATMEMOINFO_CONTENT_16, LAYOUT_ITEM_PATMEMOINFO_CONTENT_17, LAYOUT_ITEM_PATMEMOINFO_CONTENT_18, LAYOUT_ITEM_PATMEMOINFO_CONTENT_19, LAYOUT_ITEM_PATMEMOINFO_CONTENT_2, LAYOUT_ITEM_PATMEMOINFO_CONTENT_20, LAYOUT_ITEM_PATMEMOINFO_CONTENT_3, LAYOUT_ITEM_PATMEMOINFO_CONTENT_4, LAYOUT_ITEM_PATMEMOINFO_CONTENT_5, LAYOUT_ITEM_PATMEMOINFO_CONTENT_6, LAYOUT_ITEM_PATMEMOINFO_CONTENT_7, LAYOUT_ITEM_PATMEMOINFO_CONTENT_8, LAYOUT_ITEM_PATMEMOINFO_CONTENT_9, LAYOUT_ITEM_PATMEMOINFO_TITLE_1, LAYOUT_ITEM_PATMEMOINFO_TITLE_10, LAYOUT_ITEM_PATMEMOINFO_TITLE_11, LAYOUT_ITEM_PATMEMOINFO_TITLE_12, LAYOUT_ITEM_PATMEMOINFO_TITLE_13, LAYOUT_ITEM_PATMEMOINFO_TITLE_14, LAYOUT_ITEM_PATMEMOINFO_TITLE_15, LAYOUT_ITEM_PATMEMOINFO_TITLE_16, LAYOUT_ITEM_PATMEMOINFO_TITLE_17, LAYOUT_ITEM_PATMEMOINFO_TITLE_18, LAYOUT_ITEM_PATMEMOINFO_TITLE_19, LAYOUT_ITEM_PATMEMOINFO_TITLE_2, LAYOUT_ITEM_PATMEMOINFO_TITLE_20, LAYOUT_ITEM_PATMEMOINFO_TITLE_3, LAYOUT_ITEM_PATMEMOINFO_TITLE_4, LAYOUT_ITEM_PATMEMOINFO_TITLE_5, LAYOUT_ITEM_PATMEMOINFO_TITLE_6, LAYOUT_ITEM_PATMEMOINFO_TITLE_7, LAYOUT_ITEM_PATMEMOINFO_TITLE_8, LAYOUT_ITEM_PATMEMOINFO_TITLE_9, LAYOUT_ITEM_POSITIVE_INFECTION, LAYOUT_ITEM_PRE_SCALE_LOWER, LAYOUT_ITEM_PRE_SCALE_UPPER, LAYOUT_ITEM_SEVERITYCODE, LAYOUT_ITEM_SEVERITYNAME, LAYOUT_ITEM_TABOO, LAYOUT_ITEM_TARGET_WEIGHT, LAYOUT_ITEM_TRANSPORTCODE, LAYOUT_ITEM_TRANSPORTNAME, LAYOUT_ITEM_UNCLEAR_INFECTION, LAYOUT_ITEM_VENDORCONTACTINFO_ADDRESS, LAYOUT_ITEM_VENDORCONTACTINFO_COMPANYNAME, LAYOUT_ITEM_VENDORCONTACTINFO_COMPANYTEL, LAYOUT_ITEM_VENDORCONTACTINFO_FAX, LAYOUT_ITEM_VENDORCONTACTINFO_MEMO1, LAYOUT_ITEM_VENDORCONTACTINFO_MEMO2, LAYOUT_ITEM_VENDORCONTACTINFO_WORKEREMAIL, LAYOUT_ITEM_VENDORCONTACTINFO_WORKERFIRSTNAME, LAYOUT_ITEM_VENDORCONTACTINFO_WORKERLASTNAME, LAYOUT_ITEM_VENDORCONTACTINFO_WORKERTEL, LAYOUT_ITEM_VENDORCONTACTINFO_ZIPCD, LAYOUT_PATIENTGROUP_PATIENTGROUP, NO_UPDDATE_FIELD_SUFFIX_LIST, PSEUDO_MST_LIST } from "./Definitions.js"

import {ApiHelper} from "@/apis/AxiosHelper";
import {deserializeJsonColumn, serializeJsonColumn} from "@/functions/common/CommonFunctions";
/*add FNSI-改修内容5237 任 start*/
import {MASTER_DELETE_DISPLAY} from "@/constants/TreatmentRecord";
/*add FNSI-改修内容5237 任 end*/
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
import { addPatNameSortToList } from "@/functions/SortFunctions";
import kendo from "@progress/kendo-ui";
// 引数で渡されたEventBusオブジェクトを格納
let eventBusObj = null;

const toKendoTemplate = (html) => {
  const kendo = globalThis.kendo || globalThis.$?.kendo || globalThis.jQuery?.kendo || null;
  return kendo?.template ? kendo.template(html) : (() => html);
};

const findElementByIdWithin = (root, id) => {
  if (!root || id === null || id === undefined || id === '') {
    return null;
  }
  const textId = String(id);
  if (root.id === textId) {
    return root;
  }
  const escapedId = (() => {
    try {
      return typeof CSS !== "undefined" && typeof CSS.escape === "function"
        ? CSS.escape(textId)
        : textId.replace(/([ #$%&'()*+,./:;<=>?@[\\\]^`{|}~])/g, "\\$1");
    } catch (_error) {
      return textId.replace(/([ #$%&'()*+,./:;<=>?@[\\\]^`{|}~])/g, "\\$1");
    }
  })();
  try {
    const found = root.querySelector?.(`#${escapedId}`);
    if (found) {
      return found;
    }
  } catch (_error) {
    // noop: Vue2/jquery selectors allowed field ids such as pat_unique$physical_info$exam_time.
  }
  return Array.from(root.querySelectorAll?.('[id]') || []).find(element => element.id === textId) || null;
};

/**
 * @description 必要なすべてのマスタを取得
 * @param {String} facilityCd 施設コード
 * @returns {Object} { <マスタ名>: <マスタオブジェクト配列> }
 */
export const getRequiredMst = async facilityCd => {
  const [
    mst_severity,
    mst_dialysis_difficulty,
    mst_transport,
    mst_course,
    mst_ward,
    mst_staff,
    mst_layout,
    mst_taboo_allergy,
    mst_infection,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    mst_addition,
    sysCountry,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    mst_implant,
    /*add FNSI-改修内容5237 任 start*/
    // mst_implant_del,
    /*add FNSI-改修内容5237 任 end*/
    mst_disease
  ] = await Promise.all([
    severitySelector(facilityCd),
    dialysisDifficultySelector(facilityCd),
    transportSelector(facilityCd),
    courseSelector(facilityCd),
    wardSelector(facilityCd),
    user(facilityCd),
    patListLayout(facilityCd),
    tabooAllergySelector(facilityCd),
    infectionSelector(facilityCd),
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    addition(facilityCd),
    ApiHelper.get("/mstInfo/sysCountry"),
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    implantSelector(facilityCd),
    /*add FNSI-改修内容5237 任 start*/
    // implantDel(facilityCd),
    /*add FNSI-改修内容5237 任 end*/
    diseaseSelector(facilityCd)
  ]).catch(error => {
    throw new Error(error);
  });

  // レイアウトマスタの表示項目デシリアライズ
  mst_layout.forEach(el => {
    el.dispItemInfo = JSON.parse(el.dispItemInfo);
    return el;
  });

  let mst_sysCountry = [];
  if (sysCountry && sysCountry.data) {
    mst_sysCountry = sysCountry.data;
  }

  // [2023/06/09 NKK古谷] 6119対応時のメモ：
  // 「診療情報」の「施設」はデータリスト画面で表示する必要がない項目なので、
  // 別途マスタ設定で無効になるようにしておく
  // 6119での対応としては念のため「診療情報」の「施設」のための処理は残しておくが、
  // 実際には全施設マスタのデータは取得しないダミー処理にしておく
  const mst_facility = [];
  return {
    mst_severity,
    mst_dialysis_difficulty,
    mst_transport,
    mst_course,
    mst_ward,
    mst_facility,
    mst_staff,
    mst_layout,
    mst_taboo_allergy,
    mst_infection,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    mst_addition,
    mst_sysCountry,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    mst_implant,
    mst_disease
  };
};

/**
 * @description 今日の治療予定患者数を取得
 * @param {Array} patIdList 調べたい患者IDの配列
 * @param {String} facilityCd 施設コード
 * @returns {Number}
 */
export const getTodayDialysisPatNum = async (patIdList, facilityCd) => {
  const { data: todayDialysisPatIdList } = await ApiHelper.post(
    "/patInfo/getPatIdByTreatDate",
    {
      treatDate: dayjs().format("YYYYMMDD"),
      facilityCd
    }
  ).catch(error => {
    throw new Error(error);
  });

  //
  return patIdList.reduce(
    (acc, curVal) => acc + (todayDialysisPatIdList.includes(curVal) ? 1 : 0),
    0
  );
};

/**
 *
 * @param {Array} layout レイアウトマスタのdisp_item_info
 * @returns {Array} kendo-grid-columnオブジェクト配列 [{ title, colums }, ...]
 */
export const createKendoColumns = layout => {
  return layout.map(({ category, items }) => {
    return {
      key: category,
      title: LAYOUT_CATEGORY_TITLES[category],
      columns: items.map(item => KENDO_CATEGORY_COLUMNS[category][item])
    };
  });
};

/**
 * @description kendo-grid-columnオブジェクトからfieldを得る
 * @param {String} categoryKey レイアウトカテゴリキー
 * @param {String} itemKey レイアウト項目キー
 * @returns {String} 'categoryKey$table$column($jsonKey($index))'
 */
const getKendoColumnField = (categoryKey, itemKey) => {
  return KENDO_CATEGORY_COLUMNS[categoryKey][itemKey].field;
};

/**
 * @description pat_personal_mainをkendo-grid data-source用に展開
 * @param {Object} pat_personal_mainオブジェクト ※JSONカラムはデシリアライズ済みであること
 * @param {Object} マスタ
 */
const mapPatPersonalMainToKendoFields = (
  {
    // 本人情報
    hosp_pat_id,
    pat_last_name,
    pat_first_name,
    pat_last_name_kana,
    pat_first_name_kana,
    pat_last_name_alpha,
    pat_first_name_alpha,
    in_out_class,
// add FNSI テンプレート：患者情報１全項目表示時、画面表示不正 dou start
    in_hospital_state,
// add FNSI テンプレート：患者情報１全項目表示時、画面表示不正 dou end
    pat_birthday,
    pat_sex,
    pat_blood_type_abo,
    pat_blood_type_rh,
    pat_blood_type_serovar,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    nationality,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    pat_contact_info: {
      zip_cd,
      address,
      tel1,
      tel2,
      fax,
      e_mail,
      // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
      work_name,
      work_tel,
      // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
      memo1,
      memo2
    },
    // 連絡先
    other_contact_info,
    // 連絡先(業者)
    vendor_contact_info,
    // 透析困難
    dial_diff_com_info,
    // 重症度
    severity_cd,
    // 搬送区分
    transport_cd
  },
  { mst_dialysis_difficulty, mst_severity, mst_transport, mst_sysCountry }
) => {
  // 連絡先(キーパーソン)を1つ作成
  const otherContactKeyPersonInfo = [];
  const hasKeyPersonList = other_contact_info.filter(
    el => el.is_key_person === "1"
  );
  for (let i = 0; i <= 0; i++) {
    const el = hasKeyPersonList[i];
    const categoryKey = LAYOUT_CATEGORY_OTHERCONTACTKEYPERSONINFO[i].key;
    const kendoFields = {
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAME.key
      )]: !el ? null : el.last_name,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAME.key
      )]: !el ? null : el.first_name,
      // [getKendoColumnField(categoryKey, LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAMEKANA.key)]: !el ? null : el.last_name_kana,
      // [getKendoColumnField(categoryKey, LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAMEKANA.key)]: !el ? null : el.first_name_kana,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_RELATIONCD.key
      )]: !el ? null : el.relation_cd,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_RELATION.key
      )]: !el ? null : el.relation_name,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_ZIPCD.key
      )]: !el ? null : el.zip_cd,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_ADDRESS.key
      )]: !el ? null : el.address,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_TEL1.key
      )]: !el ? null : el.tel1,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_TEL2.key
      )]: !el ? null : el.tel2,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_FAX.key
      )]: !el ? null : el.fax,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_EMAIL.key
      )]: !el ? null : el.e_mail,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_WORKNAME.key
      )]: !el ? null : el.work_name,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_WORKTEL.key
      )]: !el ? null : el.work_tel,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_MEMO1.key
      )]: !el ? null : el.memo1,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_MEMO2.key
      )]: !el ? null : el.memo2
    };
    otherContactKeyPersonInfo.push(kendoFields);
  }

  // 連絡先を3つ作成
  const otherContactInfo = [];
  // mod データリスト：連絡先表示不正 林峻峰 start
  // const hasNotKeyPersonList = other_contact_info.filter(
  //   el => el.is_key_person === "0"
  // );
  const hasNotKeyPersonList = JSON.parse(JSON.stringify(other_contact_info));
  // mod データリスト：連絡先表示不正 林峻峰 end
  //mod FutreNetWeb+SI課題管理 no.5216 劉全航 start
  if(hasKeyPersonList.length > 1){
    for(let i = 1;i <= hasKeyPersonList.length; i ++){
      hasNotKeyPersonList.push(hasKeyPersonList[i]);
    }
  }
  //mod FutreNetWeb+SI課題管理 no.5216 劉全航 end
  for (let i = 0; i <= 2; i++) {
    const el = hasNotKeyPersonList[i];
    const categoryKey = LAYOUT_CATEGORY_OTHERCONTACTINFO[i].key;
    const kendoFields = {
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAME.key
      )]: !el ? null : el.last_name,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAME.key
      )]: !el ? null : el.first_name,
      // [getKendoColumnField(categoryKey, LAYOUT_ITEM_OTHERCONTACTINFO_LASTNAMEKANA.key)]: !el ? null : el.last_name_kana,
      // [getKendoColumnField(categoryKey, LAYOUT_ITEM_OTHERCONTACTINFO_FIRSTNAMEKANA.key)]: !el ? null : el.first_name_kana,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_RELATIONCD.key
      )]: !el ? null : el.relation_cd,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_RELATION.key
      )]: !el ? null : el.relation_name,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_ZIPCD.key
      )]: !el ? null : el.zip_cd,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_ADDRESS.key
      )]: !el ? null : el.address,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_TEL1.key
      )]: !el ? null : el.tel1,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_TEL2.key
      )]: !el ? null : el.tel2,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_FAX.key
      )]: !el ? null : el.fax,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_EMAIL.key
      )]: !el ? null : el.e_mail,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_WORKNAME.key
      )]: !el ? null : el.work_name,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_WORKTEL.key
      )]: !el ? null : el.work_tel,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_MEMO1.key
      )]: !el ? null : el.memo1,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_OTHERCONTACTINFO_MEMO2.key
      )]: !el ? null : el.memo2
    };
    otherContactInfo.push(kendoFields);
  }

  // 連絡先(業者)を3つ作成
  const vendorContactInfo = [];
  for (let i = 0; i <= 2; i++) {
    const el = vendor_contact_info[i];
    const categoryKey = LAYOUT_CATEGORY_VENDORCONTACTINFO[i].key;
    const kendoFields = {
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_COMPANYNAME.key
      )]: !el ? null : el.company_name,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_ZIPCD.key
      )]: !el ? null : el.zip_cd,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_ADDRESS.key
      )]: !el ? null : el.address,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_COMPANYTEL.key
      )]: !el ? null : el.company_tel,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_FAX.key
      )]: !el ? null : el.fax,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_WORKERLASTNAME.key
      )]: !el ? null : el.worker_last_name,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_WORKERFIRSTNAME.key
      )]: !el ? null : el.worker_first_name,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_WORKERTEL.key
      )]: !el ? null : el.worker_tel,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_WORKEREMAIL.key
      )]: !el ? null : el.worker_e_mail,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_MEMO1.key
      )]: !el ? null : el.memo1,
      [getKendoColumnField(
        categoryKey,
        LAYOUT_ITEM_VENDORCONTACTINFO_MEMO2.key
      )]: !el ? null : el.memo2
    };
    vendorContactInfo.push(kendoFields);
  }

  // 主たる透析困難
  const difficultyMain = dial_diff_com_info.find(
    difficulty => difficulty.is_main === "1"
  );
  let difficultyMainCode = null;
  if (difficultyMain) {
    difficultyMainCode = difficultyMain.dial_diff_cd;
  }

  // その他の透析困難
  const difficultyOther = dial_diff_com_info.filter(
    difficulty => difficulty.is_dial_diff === "1"
  );
  let difficultyOtherNamesString = null;
  if (difficultyOther.length) {
    difficultyOtherNamesString = difficultyOther
      .map(difficulty =>
        mstCodeToName(mst_dialysis_difficulty, difficulty.dial_diff_cd)
      )
      .join("\n");
  }

  const kendoColumns = {
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_HOSPPATID.key
    )]: hosp_pat_id,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_NAME.key
      //mod 9251 nullを空文字列判定に変換します 張博 start
    )]: `${pat_last_name == null ? "" : pat_last_name} ${pat_first_name == null ? "" : pat_first_name}`,
      //mod 9251 nullを空文字列判定に変換します 張博 end
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_NAMEKANA.key
      //mod 9251 nullを空文字列判定に変換します 張博 start
    )]: `${pat_last_name_kana == null ? "" : pat_last_name_kana || ""} ${pat_first_name_kana == null ? "" : pat_first_name_kana || ""}`,
      //mod 9251 nullを空文字列判定に変換します 張博 end
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_NAMEALPHA.key
      //mod 9251 nullを空文字列判定に変換します 張博 start
    )]: `${pat_last_name_alpha == null ? "" : pat_last_name_alpha || ""} ${pat_first_name_alpha == null ? "" : pat_first_name_alpha || ""}`,
      //mod 9251 nullを空文字列判定に変換します 張博 end
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_INOUT.key
    )]: mstCodeToName(PSEUDO_MST_LIST.inout, in_out_class),
// add FNSI テンプレート：患者情報１全項目表示時、画面表示不正 dou start
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_INHOSPITALSTATE.key
    )]: in_hospital_state,
// add FNSI テンプレート：患者情報１全項目表示時、画面表示不正 dou end
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_BIRTHDAY.key
    )]: pat_birthday ? dayjs(pat_birthday).format("YYYY/MM/DD") : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_BIRTHDAYDATEOBJECT.key
    )]: pat_birthday ? dayjs(pat_birthday).toDate() : null,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_AGE.key
    )]: age(pat_birthday ? dayjs(pat_birthday).format("YYYYMMDD") : null),
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_SEXCODE.key
    )]: pat_sex,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_SEXNAME.key
    )]: mstCodeToName(PSEUDO_MST_LIST.sex, pat_sex),
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_BLOODABOCODE.key
    )]: pat_blood_type_abo,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_BLOODABONAME.key
    )]: mstCodeToName(PSEUDO_MST_LIST.bloodABO, pat_blood_type_abo),
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_BLOODRHCODE.key
    )]: pat_blood_type_rh,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_BLOODRHNAME.key
    )]: mstCodeToName(PSEUDO_MST_LIST.bloodRh, pat_blood_type_rh),
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_BLOODSEROVARCODE.key
    )]: pat_blood_type_serovar,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_BLOODSEROVARNAME.key
    )]: mstCodeToName(PSEUDO_MST_LIST.bloodSerovar, pat_blood_type_serovar),
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_NATIONALITYCODE.key
    )]: nationality ? nationality : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_NATIONALITYNAME.key
    )]: nationality ? mstCodeToName(mst_sysCountry, nationality, "countryCdAlpha3", "countryName") : "",
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_ZIPCD.key
    )]: zip_cd,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_ADDRESS.key
    )]: address,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_TEL1.key
    )]: tel1,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_TEL2.key
    )]: tel2,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_FAX.key
    )]: fax,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_EMAIL.key
    )]: e_mail,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_WORK_NAME.key
    )]: work_name,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_WORK_TEL.key
    )]: work_tel,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_MEMO1.key
    )]: memo1,
    [getKendoColumnField(
      LAYOUT_CATEGORY_BASICINFO.key,
      LAYOUT_ITEM_BASICINFO_CONTACT_MEMO2.key
    )]: memo2,
    ...otherContactKeyPersonInfo[0],
    ...otherContactInfo[0],
    ...otherContactInfo[1],
    ...otherContactInfo[2],
    ...vendorContactInfo[0],
    ...vendorContactInfo[1],
    ...vendorContactInfo[2],
    [getKendoColumnField(
      LAYOUT_CATEGORY_DIFFICULTY_MAIN.key,
      LAYOUT_ITEM_DIFFICULTY_MAIN.key
    )]: mstCodeToName(mst_dialysis_difficulty, difficultyMainCode),
    [getKendoColumnField(
      LAYOUT_CATEGORY_DIFFICULTY_OTHER.key,
      LAYOUT_ITEM_DIFFICULTY_OTHER.key
    )]: difficultyOtherNamesString,
    [getKendoColumnField(
      LAYOUT_CATEGORY_SEVERITY.key,
      LAYOUT_ITEM_SEVERITYCODE.key
    )]: severity_cd,
    [getKendoColumnField(
      LAYOUT_CATEGORY_SEVERITY.key,
      LAYOUT_ITEM_SEVERITYNAME.key
    )]: mstCodeToName(mst_severity, severity_cd),
    [getKendoColumnField(
      LAYOUT_CATEGORY_TRANSPORT.key,
      LAYOUT_ITEM_TRANSPORTCODE.key
    )]: transport_cd,
    [getKendoColumnField(
      LAYOUT_CATEGORY_TRANSPORT.key,
      LAYOUT_ITEM_TRANSPORTNAME.key
    )]: mstCodeToName(mst_transport, transport_cd)
  };
  return kendoColumns;
};

const mapPatMainToKendoFields = (
  {
    pat_memo_info,
    charge_staff_info,
    taboo_allergy_info,
    infect_info,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    addition_info,
    pat_group_info,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    implant_info,
    medical_care_info: {
      main_course_cd,
      dialysis_course_cd,
      ward_cd,
      dialysis_count,
      purification_count,
      // add FNSI-患者通算透析回数 じょはく start
      pat_dialysis_count,
      // add FNSI-患者通算透析回数 じょはく end
      dialysis_start_date,
      facility_cd
    }
  },
  {
    mst_staff,
    mst_taboo_allergy,
    mst_infection,
    mst_implant,
    /*add FNSI-改修内容5237 任 start*/
    mst_implant_del,
    /*add FNSI-改修内容5237 任 end*/
    mst_facility,
    mst_course,
    mst_ward,
    mst_addition
  }
) => {
  /* 担当者作成(主治医2個、担当者3個、穿刺2個) */
  const doctorFields = [];
  const REQUIRED_NUM_DOCTOR = 2;
  const chargeFields = [];
  const REQUIRED_NUM_CHARGE = 3;
  const punctureFields = [];
  const REQUIRED_NUM_PUNCTURE = 2;

  // field作成関数
  const createStaffField = (itemKeyStaffCode, itemKeyStaffName, staffCode) => {
    return {
      [getKendoColumnField(
        LAYOUT_CATEGORY_CHARGESTAFFINFO.key,
        itemKeyStaffCode
      )]: staffCode === null ? null : staffCode,
      [getKendoColumnField(
        LAYOUT_CATEGORY_CHARGESTAFFINFO.key,
        itemKeyStaffName
      )]:
        staffCode === null
          ? ""
          : mstCodeToName(mst_staff, staffCode, "userId", "userName")
    };
  };
  // 主治医field作成関数
  const createDoctorField = (staffCode, number) => {
    let itemKeyStaffCode, itemKeyStaffName;
    if (number === 0) {
      itemKeyStaffCode = LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_1.key;
      itemKeyStaffName = LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_1.key;
    } else {
      itemKeyStaffCode = LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_2.key;
      itemKeyStaffName = LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_2.key;
    }
    return createStaffField(itemKeyStaffCode, itemKeyStaffName, staffCode);
  };
  // 担当者Field作成関数
  const createChargeField = (staffCode, number) => {
    let itemKeyStaffCode, itemKeyStaffName;
    if (number === 0) {
      itemKeyStaffCode = LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_1.key;
      itemKeyStaffName = LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_1.key;
    } else if (number === 1) {
      itemKeyStaffCode = LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_2.key;
      itemKeyStaffName = LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_2.key;
    } else {
      itemKeyStaffCode = LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_3.key;
      itemKeyStaffName = LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_3.key;
    }
    return createStaffField(itemKeyStaffCode, itemKeyStaffName, staffCode);
  };
  // 穿刺Field作成関数
  const createPunctureField = (staffCode, number) => {
    let itemKeyStaffCode, itemKeyStaffName;
    if (number === 0) {
      itemKeyStaffCode = LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_1.key;
      itemKeyStaffName = LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_1.key;
    } else {
      itemKeyStaffCode = LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_2.key;
      itemKeyStaffName = LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_2.key;
    }
    return createStaffField(itemKeyStaffCode, itemKeyStaffName, staffCode);
  };
  /*add FNSI-改修内容5237 任 start*/
  let mainCd = '';
  let mainName = '';
  let chargeCd = '';
  let chargeName = '';
  let punctureCd = '';
  let punctureName = '';
  /*add FNSI-改修内容5237 任 end*/
  // mod #11718 【#11600持ち越し】データリスト画面不正② fang start
  if(charge_staff_info && charge_staff_info.length > 0) {
    for (const staff of charge_staff_info) {
      /*add FNSI-改修内容5237 任 start*/
      if(staff.is_main === "1"){
        if (mainCd) {
          mainCd = mainCd + "\n" + staff.staff_cd;
        } else {
          mainCd = staff.staff_cd;
        }
        let name = staff.staff_cd === null
          ? ""
          : mstCodeToName(mst_staff, staff.staff_cd, "userId", "userName");
        if (mainName) {
          mainName = mainName + "\n" + name;
        } else {
          mainName = name;
        }
      }
      if(staff.is_charge === "1"){
        if (chargeCd) {
          chargeCd = chargeCd + "\n" + staff.staff_cd;
        } else {
          chargeCd = staff.staff_cd;
        }
        let name = staff.staff_cd === null
          ? ""
          : mstCodeToName(mst_staff, staff.staff_cd, "userId", "userName");
        if (chargeName) {
          chargeName = chargeName + "\n" + name;
        } else {
          chargeName = name;
        }
      }
      if(staff.is_puncture === "1"){
        if (punctureCd) {
          punctureCd = punctureCd + "\n" + staff.staff_cd;
        } else {
          punctureCd = staff.staff_cd;
        }
        let name = staff.staff_cd === null
          ? ""
          : mstCodeToName(mst_staff, staff.staff_cd, "userId", "userName");
        if (punctureName) {
          punctureName = punctureName + "\n" + name;
        } else {
          punctureName = name;
        }
      }
      /*add FNSI-改修内容5237 任 end*/
      if (staff.is_main === "1" && doctorFields.length < REQUIRED_NUM_DOCTOR) {
        // 主治医追加
        doctorFields.push(createDoctorField(staff.staff_cd, doctorFields.length));
      }

      if (staff.is_charge === "1" && chargeFields.length < REQUIRED_NUM_CHARGE) {
        // 担当者追加
        chargeFields.push(createChargeField(staff.staff_cd, chargeFields.length));
      }

      if (
        staff.is_puncture === "1" &&
        punctureFields.length < REQUIRED_NUM_PUNCTURE
      ) {
        // 穿刺追加
        punctureFields.push(
          createPunctureField(staff.staff_cd, punctureFields.length)
        );
      }

      if (
        doctorFields.length === REQUIRED_NUM_DOCTOR &&
        chargeFields.length === REQUIRED_NUM_CHARGE &&
        punctureFields.length === REQUIRED_NUM_PUNCTURE
      ) {
        // 規定の数作り終えたら抜ける
        break;
      }
    }
  }
  // mod #11718 【#11600持ち越し】データリスト画面不正② fang end

  // 不足分を作成
  for (let i = doctorFields.length; i < REQUIRED_NUM_DOCTOR; i++) {
    doctorFields.push(createDoctorField(null, i));
  }
  for (let i = chargeFields.length; i < REQUIRED_NUM_CHARGE; i++) {
    chargeFields.push(createChargeField(null, i));
  }
  for (let i = punctureFields.length; i < REQUIRED_NUM_PUNCTURE; i++) {
    punctureFields.push(createPunctureField(null, i));
  }

  // 禁忌・アレルギー
  const encodeTabooAllergyInfo = taboo_allergy_info.map(item => {
    const deepCopy = { ...item };
    if (deepCopy.category_class !== "0") {
      // 禁忌・アレルギー以外は未登録へ
      deepCopy.taboo_allergy_cd = null;
    }
    return deepCopy;
  });
  // 禁忌
  const taboo = encodeTabooAllergyInfo.filter(
    item => item.taboo_allergy_class === "1"
  );
  let tabooNamesString = null;
  if (taboo.length) {
    // mod FNSI-改修内容禁忌・アレルギー表示不正 付 start
    tabooNamesString = taboo
      // .map(item => mstCodeToName(mst_taboo_allergy, item.taboo_allergy_cd)).map(item => mstCodeToName(mst_taboo_allergy, item.taboo_allergy_cd))
      .map(item => {
        if (item.taboo_allergy_cd == null) {
          return item?.content;
        } else {
          return mstCodeToName(mst_taboo_allergy, item.taboo_allergy_cd);
        }
      })
      .join("\n");
    // mod FNSI-改修内容禁忌・アレルギー表示不正 付 end
  }
  // アレルギー
  const allergy = encodeTabooAllergyInfo.filter(
    item => item.taboo_allergy_class === "2"
  );
  let allergyNamesString = null;
  if (allergy.length) {
    // mod FNSI-改修内容禁忌・アレルギー表示不正 付 start
    allergyNamesString = allergy
      // .map(item => mstCodeToName(mst_taboo_allergy, item.taboo_allergy_cd)).map(item => mstCodeToName(mst_taboo_allergy, item.taboo_allergy_cd))
      .map(item => {
        if (item.taboo_allergy_cd == null) {
          return item?.content;
        } else {
          return mstCodeToName(mst_taboo_allergy, item.taboo_allergy_cd);
        }
      })
      .join("\n");
    // mod FNSI-改修内容禁忌・アレルギー表示不正 付 end
  }

  // 感染症(+)
  const positiveInfection = infect_info.filter(
    infectInfo => infectInfo.infect === "2"
  );
  let positiveInfectionNamesString = null;
  if (positiveInfection.length) {
    positiveInfectionNamesString = positiveInfection
      .map(infect => mstCodeToName(mst_infection, infect.infection_cd))
      .join("\n");
  }
  // 感染症(-)
  const negativeInfection = infect_info.filter(
    infectInfo => infectInfo.infect === "1"
  );
  let negativeInfectionNamesString = null;
  if (negativeInfection.length) {
    negativeInfectionNamesString = negativeInfection
      .map(infect => mstCodeToName(mst_infection, infect.infection_cd))
      .join("\n");
  }
  // 感染症(不明)
  const unclearInfection = infect_info.filter(
    infectInfo => infectInfo.infect === "0"
  );
  let unclearInfectionNamesString = null;
  if (unclearInfection.length) {
    unclearInfectionNamesString = unclearInfection
      .map(infect => mstCodeToName(mst_infection, infect.infection_cd))
      .join("\n");
  }
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
  // // 感染症
  // let infectInfoNamesString = null;
  // if (infect_info.length) {
  //   infectInfoNamesString = infect_info
  //     .map(infect => mstCodeToName(mst_infection, infect.infection_cd))
  //     .join("\n");
  // }

  // 患者グループ
  let patGroupNamesString = null;
  //No.7167 upd Paging Optimization runtime by ztc start
  if (pat_group_info != null && pat_group_info.length) {
    //No.7167 upd Paging Optimization runtime by ztc end
    /*mod FNSI-改修内容5195 任 start*/
    /*patGroupNamesString = pat_group_info
      .map(item => item.name).join("\n");*/
    patGroupNamesString = pat_group_info
      .map(item => item).join("\n");
    /*mod FNSI-改修内容5195 任 end*/
  }

  // 加算・管理科
  let additionNamesString = null;
  if (addition_info.length) {
    additionNamesString = addition_info
      // .map(item => item.name).join("\n");
    .map(item => {
      let name = mst_addition.find(x => x.additionCd == item.cd);
      // mod データリスト：加算・管理料表示不正
      // if (name) {
      if (name && item.is_enable === '1') {
        return name.additionName;
      }
    })
    // add 11528 【たくしん会】データリスト並び順不正 zkm start
    .filter(name => undefined !== name)
    // add 11528 【たくしん会】データリスト並び順不正 zkm end
    .join("\n");
  }
  // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end

  // インプラント
  let implantNamesString = null;
  /*mod FNSI-改修内容5237 任 start*/
  /*if (implant_info.length) {
    implantNamesString = implant_info
      .map(item => mstCodeToName(mst_implant, item.implant_cd))
      .join("\n");
  }*/
  if (implant_info.length) {
    implantNamesString = implant_info
      .map(item => mstCodeToNameImplant(mst_implant,mst_implant_del, item.implant_cd))
      .join("\n");
  }
  /*mod FNSI-改修内容5237 任 end*/

  // 透析歴計算
  const dialHstYear = dayjs().diff(dialysis_start_date, "years");
  const dialHstMonth = dayjs().diff(dialysis_start_date, "months") % 12;
  const dialHst = `${!dialHstYear ? 0 : dialHstYear}年 ${!dialHstMonth ? 0 : dialHstMonth
    }ヶ月`;
  const kendoFields = {
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_1.key
    )]: pat_memo_info[0]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_1.key
    )]: pat_memo_info[0]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_2.key
    )]: pat_memo_info[1]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_2.key
    )]: pat_memo_info[1]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_3.key
    )]: pat_memo_info[2]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_3.key
    )]: pat_memo_info[2]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_4.key
    )]: pat_memo_info[3]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_4.key
    )]: pat_memo_info[3]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_5.key
    )]: pat_memo_info[4]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_5.key
    )]: pat_memo_info[4]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_6.key
    )]: pat_memo_info[5]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_6.key
    )]: pat_memo_info[5]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_7.key
    )]: pat_memo_info[6]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_7.key
    )]: pat_memo_info[6]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_8.key
    )]: pat_memo_info[7]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_8.key
    )]: pat_memo_info[7]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_9.key
    )]: pat_memo_info[8]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_9.key
    )]: pat_memo_info[8]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_10.key
    )]: pat_memo_info[9]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_10.key
    )]: pat_memo_info[9]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_11.key
    )]: pat_memo_info[10]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_11.key
    )]: pat_memo_info[10]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_12.key
    )]: pat_memo_info[11]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_12.key
    )]: pat_memo_info[11]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_13.key
    )]: pat_memo_info[12]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_13.key
    )]: pat_memo_info[12]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_14.key
    )]: pat_memo_info[13]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_14.key
    )]: pat_memo_info[13]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_15.key
    )]: pat_memo_info[14]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_15.key
    )]: pat_memo_info[14]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_16.key
    )]: pat_memo_info[15]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_16.key
    )]: pat_memo_info[15]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_17.key
    )]: pat_memo_info[16]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_17.key
    )]: pat_memo_info[16]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_18.key
    )]: pat_memo_info[17]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_18.key
    )]: pat_memo_info[17]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_19.key
    )]: pat_memo_info[18]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_19.key
    )]: pat_memo_info[18]?.content,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_TITLE_20.key
    )]: pat_memo_info[19]?.title,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATMEMOINFO.key,
      LAYOUT_ITEM_PATMEMOINFO_CONTENT_20.key
    )]: pat_memo_info[19]?.content,
    /*add FNSI-改修内容5237 任 start*/
    [getKendoColumnField(
      LAYOUT_CATEGORY_CHARGESTAFFINFO.key,
      LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORCODE_1.key
    )]: mainCd,
    [getKendoColumnField(
      LAYOUT_CATEGORY_CHARGESTAFFINFO.key,
      LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_1.key
    )]:mainName,
    [getKendoColumnField(
      LAYOUT_CATEGORY_CHARGESTAFFINFO.key,
      LAYOUT_ITEM_CHARGESTAFFINFO_CHARGECODE_1.key
    )]: chargeCd,
    [getKendoColumnField(
      LAYOUT_CATEGORY_CHARGESTAFFINFO.key,
      LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_1.key
    )]:chargeName,
    [getKendoColumnField(
      LAYOUT_CATEGORY_CHARGESTAFFINFO.key,
      LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURECODE_1.key
    )]: punctureCd,
    [getKendoColumnField(
      LAYOUT_CATEGORY_CHARGESTAFFINFO.key,
      LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_1.key
    )]:punctureName,
    /*add FNSI-改修内容5237 任 end*/
    /*del FNSI-改修内容5237 任 start*/
    /*...doctorFields[0],
    ...doctorFields[1],
    ...chargeFields[0],
    ...chargeFields[1],
    ...chargeFields[2],
    ...punctureFields[0],
    ...punctureFields[1],*/
    /*del FNSI-改修内容5237 任 end*/
    [getKendoColumnField(
      LAYOUT_CATEGORY_TABOO_ALLERGY_INFO.key,
      LAYOUT_ITEM_TABOO.key
    )]: tabooNamesString,
    [getKendoColumnField(
      LAYOUT_CATEGORY_TABOO_ALLERGY_INFO.key,
      LAYOUT_ITEM_ALLERGY.key
    )]: allergyNamesString,
    [getKendoColumnField(
      LAYOUT_CATEGORY_INFECT_INFO.key,
      LAYOUT_ITEM_POSITIVE_INFECTION.key
    )]: positiveInfectionNamesString,
    [getKendoColumnField(
      LAYOUT_CATEGORY_INFECT_INFO.key,
      LAYOUT_ITEM_NEGATIVE_INFECTION.key
    )]: negativeInfectionNamesString,
    [getKendoColumnField(
      LAYOUT_CATEGORY_INFECT_INFO.key,
      LAYOUT_ITEM_UNCLEAR_INFECTION.key
    )]: unclearInfectionNamesString,
    // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    // [getKendoColumnField(
    //   LAYOUT_CATEGORY_INFECT_INFO.key,
    //   LAYOUT_ITEM_INFECTION.key
    // )]: infectInfoNamesString,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PATIENT_GROUP.key,
      LAYOUT_PATIENTGROUP_PATIENTGROUP.key
    )]: patGroupNamesString,
    [getKendoColumnField(
      LAYOUT_CATEGORY_ADDITION.key,
      LAYOUT_ADDITION_ADDITIONKIND.key
    )]: additionNamesString,
    // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
    [getKendoColumnField(
      LAYOUT_CATEGORY_IMPLANT_INFO.key,
      LAYOUT_ITEM_IMPLANT.key
    )]: implantNamesString,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSECODE.key
    )]: main_course_cd,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSENAME.key
    )]: mstCodeToName(mst_course, main_course_cd),
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSECODE.key
    )]: dialysis_course_cd,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSENAME.key
    )]: mstCodeToName(mst_course, dialysis_course_cd),
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_WARDCODE.key
    )]: ward_cd,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_WARDNAME.key
    )]: mstCodeToName(mst_ward, ward_cd),
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOUNT.key
    )]: dialysis_count,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_PAT_DIALYSIS_COUNT.key
    )]: pat_dialysis_count,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_PURIFICATIONCOUNT.key
    )]: purification_count,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISSTARTDATE.key
    )]: dialysis_start_date
        ? dayjs(dialysis_start_date).format("YYYY/MM/DD")
        : null,
    /*add FNSI-改修内容5202 任 start*/
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_FACILITYCODE.key
    )]: facility_cd ? facility_cd : null,
    /*add FNSI-改修内容5202 任 end*/
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_FACILITYNAME.key
    )]: mstCodeToName(mst_facility, facility_cd, "facilityCd", "facilityName"),
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICALCAREINFO.key,
      LAYOUT_ITEM_MEDICALCAREINFO_DYALYSISHST.key
    )]: dialHst
  };
  return kendoFields;
};

const ISO_EXAM_DATE_FORMAT = "YYYY-MM-DDTHH:mm:ss.SSSZ";
const DATE_ONLY_EXAM_FORMAT = "YYYY-MM-DD";

/** 身体情報(DW/CTR等): ISO 形式でパース失敗時は YYYY-MM-DD を試し、それでも無効なら空白 */
const formatPhysicalExamDateDay = (dateValue, primaryFormat = ISO_EXAM_DATE_FORMAT) => {
  if (dateValue == null || dateValue === "") {
    return null;
  }
  const primary = dayjs(dateValue, primaryFormat);
  if (primary.isValid()) {
    const formatted = primary.format("YYYY/MM/DD");
    return formatted === "Invalid Date" ? "" : formatted;
  }
  const fallback = dayjs(dateValue, DATE_ONLY_EXAM_FORMAT);
  if (fallback.isValid()) {
    const formatted = fallback.format("YYYY/MM/DD");
    return formatted === "Invalid Date" ? "" : formatted;
  }
  return "";
};

const formatPhysicalExamDateTime = (dateValue, primaryFormat = ISO_EXAM_DATE_FORMAT) => {
  if (dateValue == null || dateValue === "" || !String(dateValue).match(/T/)) {
    return null;
  }
  const primary = dayjs(dateValue, primaryFormat);
  if (primary.isValid()) {
    const formatted = primary.format("HH:mm");
    return formatted === "Invalid Date" ? "" : formatted;
  }
  const fallback = dayjs(dateValue, DATE_ONLY_EXAM_FORMAT);
  if (fallback.isValid()) {
    const formatted = fallback.format("HH:mm");
    return formatted === "Invalid Date" ? "" : formatted;
  }
  return "";
};

const mapPatUniqueToKendoFileds = (
  //mod FNSI-6478 劉全航 start
  // { is_diabetes, is_blood_suger_exam, medical_hst_info, physical_info },
  { is_diabetes, is_blood_suger_exam, medical_hst_info, physical_info, unSavedPatInfo },
  //mod FNSI-6478 劉全航 end
  { mst_disease, mst_staff },
  selectDoctor
) => {
  const parseDate = dateStr => new Date(dateStr);
  physical_info.sort((a, b) => {
    if (b.exam_date !== a.exam_date) {
      return parseDate(b.exam_date) - parseDate(a.exam_date);
    } else if (b.ctl_no !== a.ctl_no) {
      return b.ctl_no - a.ctl_no;
    }
  });
  // mod #11718 【#11600持ち越し】データリスト画面不正② fang start
  let primaryDisease = null;
  let dieDisease = null;
  let isConfirmationBiopsy = null;
  let diseaseDate = null;
  let physicalHeightDay = null;
  let physicalHeightTime = null;
  let isDiagnosed = null;
  let dieDate = null;
  let diseaseNewName = '';
  let diseaseNameList = null;
  let newestPhysicalHeight = null;
  if (medical_hst_info && medical_hst_info.length > 0) {
    // 既往歴
    // 原疾患レコード
    const primaryDiseaseRecord = medical_hst_info.find(
      record => record.is_dialysis_underlying_disease === "1"
    );
    // 死亡レコード
    const dieRecord = medical_hst_info.find(record => record.out_come === "10");
    // mod 11528 【たくしん会】データリスト並び順不正 zkm start
    // let dieDate;
    if (dieRecord) {
      dieDate = dayjs(dieRecord.die_date, "YYYYMMDD").format("YYYY年MM月DD日");
    }
    // mod 11528 【たくしん会】データリスト並び順不正 zkm end

    // 治療中(主病名)レコード
    const mainDiseaseRecords = medical_hst_info.filter(
      record => record.out_come === "1" && record.is_main_disease === "1"
    );

    diseaseNameList = mainDiseaseRecords.map(record => {
      // const disease = mst_disease.find(mst => mst.code === record.disease_cd);
      const disease = mst_disease.find(mst => mst.code == record.disease_cd);
      return disease ? disease.name : null;
    });
    /*add FNSI-改修内容5237 任 start*/
    diseaseNameList.forEach(item => {
      if (diseaseNewName) {
        diseaseNewName = diseaseNewName + "\n" + item;
      } else {
        diseaseNewName = item;
      }
    })
    /*add FNSI-改修内容5237 任 end*/

    // let primaryDiseaseName = null;
    primaryDisease = primaryDiseaseRecord ? primaryDiseaseRecord.disease_cd : "";
    // let isPrimaryDiseaseSetting = primaryDiseaseRecord ? false : true;
    dieDisease = dieRecord ? dieRecord.disease_cd : "";
    // let dieDiseaseName = null;
    // let isDieDiseaseSetting = dieRecord ? false : true;
    // for (const mst of mst_disease) {
    //   if (
    //     !isPrimaryDiseaseSetting &&
    //     mst.code === primaryDiseaseRecord.disease_cd
    //   ) {
    //     primaryDiseaseName = mst.name;
    //     isPrimaryDiseaseSetting = true;
    //   }
    //
    //   if (!isDieDiseaseSetting && mst.code === dieRecord.disease_cd) {
    //     dieDiseaseName = mst.name;
    //     isDieDiseaseSetting = true;
    //   }
    //   if (isPrimaryDiseaseSetting && isDieDiseaseSetting) {
    //     break;
    //   }
    // }
    const PDRecord = primaryDiseaseRecord;
    isConfirmationBiopsy = PDRecord
      ? PDRecord.is_confirmation_biopsy
      : null;
    // mod 11528 【たくしん会】データリスト並び順不正 zkm start
    // const diseaseDate = PDRecord ? dayjs(PDRecord.disease_date).format("YYYY/MM/DD") : null;
    diseaseDate = PDRecord && null != PDRecord.disease_date ? dayjs(PDRecord.disease_date).format("YYYY/MM/DD") : null;
    // mod 11528 【たくしん会】データリスト並び順不正 zkm end
    const year = dieRecord
      ? dieRecord.diagnosis_year
        ? `${dieRecord.diagnosis_year}年`
        : ""
      : "";
    const month = dieRecord
      ? dieRecord.diagnosis_month
        ? `${dieRecord.diagnosis_month}月`
        : ""
      : "";
    const day = dieRecord
      ? dieRecord.diagnosis_day
        ? `${dieRecord.diagnosis_day}日`
        : ""
      : "";
    const date = `${year}${month}${day}`;
    isDiagnosed = dieRecord ? dieRecord.is_diagnosed : null;

    // 最新の身体情報(身長)
    newestPhysicalHeight = physical_info.find(item => item.height !== null);
    if (newestPhysicalHeight) {
      const date = newestPhysicalHeight.exam_date;
      const format = "YYYY-MM-DDTHH:mm:ss.SSSZ";

      physicalHeightDay = date ? dayjs(date, format).format("YYYY/MM/DD") : null;
      const time = date ? date.match(/T/) : null;
      if (time) {
        physicalHeightTime = dayjs(date, format).format("HH:mm");
      }
    }
  }
  // 最新の身体情報(DW)
  const newestPhysicalDw = physical_info.find(item => item.dw !== null);
  let physicalDwDay = null;
  let physicalDwTime = null;
  if (newestPhysicalDw) {
    const date = newestPhysicalDw.exam_date;
    const format = "YYYY-MM-DDTHH:mm:ss.SSSZ";

    physicalDwDay = date ? dayjs(date, format).format("YYYY/MM/DD") : null;
    const time = date ? date.match(/T/) : null;
    if (time) {
      physicalDwTime = dayjs(date, format).format("HH:mm");
    }
  }
  // 最新の身体情報(CTR)
  const newestPhysicalCtr = physical_info.find(item => item.ctr !== null);
  let physicalCtrDay = null;
  let physicalCtrTime = null;
  if (newestPhysicalCtr) {
    const date = newestPhysicalCtr.exam_date;
    const format = "YYYY-MM-DDTHH:mm:ss.SSSZ";

    physicalCtrDay = date ? dayjs(date, format).format("YYYY/MM/DD") : null;
    const time = date ? date.match(/T/) : null;
    if (time) {
      physicalCtrTime = dayjs(date, format).format("HH:mm");
    }
  }

  const kendoColumns = {
    // 既往歴
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_DISEASE_CD.key
    )]: primaryDisease
      ? primaryDisease
      : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_DISEASE_NAME.key
    )]: primaryDisease
      ? mstCodeToName(mst_disease, primaryDisease)
      : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYCODE.key
    )]: isConfirmationBiopsy
      ? isConfirmationBiopsy
      : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYNAME.key
    )]: isConfirmationBiopsy
    ? mstCodeToName(PSEUDO_MST_LIST.isConfirmation, isConfirmationBiopsy)
    : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_DISEASE_DATE.key
    )]: diseaseDate,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_OUT_COME_DATE.key
      // mod 11528 【たくしん会】データリスト並び順不正 zkm start
      // )]: date,
    )]: dieDate,
    // mod 11528 【たくしん会】データリスト並び順不正 zkm end
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_CAUSE_DEATH_CODE.key
    )]: dieDisease,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_CAUSE_DEATH_NAME.key
    )]: dieDisease
      ? mstCodeToName(mst_disease, dieDisease)
      : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_DIAGNOSEDCODE.key
    )]: isDiagnosed,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_DIAGNOSEDNAME.key
    )]: isDiagnosed
        ? mstCodeToName(PSEUDO_MST_LIST.isDiagnosed, isDiagnosed)
        : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_DIABETESCODE.key
    )]: is_diabetes,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_DIABETESNAME.key
    )]: mstCodeToName(PSEUDO_MST_LIST.mstCheck, is_diabetes),
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMCODE.key
    )]: is_blood_suger_exam,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMNAME.key
    )]: mstCodeToName(PSEUDO_MST_LIST.mstCheck, is_blood_suger_exam),
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_NOTICE.key
    )]: diseaseNewName,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_NOTICE_2.key
    )]: diseaseNameList && diseaseNameList.length > 0 && diseaseNameList[1] ? diseaseNameList[1] : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_MEDICAL_HST_INFO.key,
      LAYOUT_ITEM_IS_NOTICE_3.key
    )]: diseaseNameList && diseaseNameList.length > 1 && diseaseNameList[2] ? diseaseNameList[2] : null,
    // 身体情報(最新：身長)
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_HEIGHT.key,
      LAYOUT_ITEM_HEIGHT_EXAM_DATE.key
    )]: physicalHeightDay,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_HEIGHT.key,
      LAYOUT_ITEM_HEIGHT_EXAM_TIME.key
    )]: physicalHeightTime,
    /*mod FNSI-改修内容5237 任 start*/
    /*[getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_HEIGHT.key,
      LAYOUT_ITEM_HEIGHT_HEIGHT.key
    )]: newestPhysicalHeight ? newestPhysicalHeight.height : null,*/
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_HEIGHT.key,
      LAYOUT_ITEM_HEIGHT_HEIGHT.key
    )]: newestPhysicalHeight ? mstDecimal(newestPhysicalHeight.height,1) : null,
    /*mod FNSI-改修内容5237 任 end*/
    // 身体情報(最新：DW)
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key,
      LAYOUT_ITEM_DW_EXAM_DATE.key
    )]: physicalDwDay,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key,
      LAYOUT_ITEM_DW_EXAM_TIME.key
    )]: physicalDwTime,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key,
      LAYOUT_ITEM_DW_ORDER_CLASS.key
    )]: newestPhysicalDw
        ? mstCodeToName(
          PSEUDO_MST_LIST.orderClass,
          newestPhysicalDw.order_class
        )
        : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key,
      LAYOUT_ITEM_DW_TR_WEIGHT.key
    )]: newestPhysicalDw ? mstDecimal(newestPhysicalDw.ctr_weight,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key,
      LAYOUT_ITEM_DW_BREAST_DIA.key
    )]: newestPhysicalDw ? mstDecimal(newestPhysicalDw.breast_dia,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key,
      LAYOUT_ITEM_DW_CHEST_DIA.key
    )]: newestPhysicalDw ? mstDecimal(newestPhysicalDw.chest_dia,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key,
      LAYOUT_ITEM_DW_CTR.key
    )]: newestPhysicalDw ? mstDecimal(newestPhysicalDw.ctr,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key,
      LAYOUT_ITEM_DW_DW.key
    )]: newestPhysicalDw ? mstDecimal(newestPhysicalDw.dw,2) : null,
    // 身体情報(最新：CTR)
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key,
      LAYOUT_ITEM_CTR_EXAM_DATE.key
    )]: physicalCtrDay,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key,
      LAYOUT_ITEM_CTR_EXAM_TIME.key
    )]: physicalCtrTime,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key,
      LAYOUT_ITEM_CTR_ORDER_CLASS.key
    )]: newestPhysicalCtr
        ? mstCodeToName(
          PSEUDO_MST_LIST.orderClass,
          newestPhysicalCtr.order_class
        )
        : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key,
      LAYOUT_ITEM_CTR_TR_WEIGHT.key
    )]: newestPhysicalCtr ? mstDecimal(newestPhysicalCtr.ctr_weight,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key,
      LAYOUT_ITEM_CTR_BREAST_DIA.key
    )]: newestPhysicalCtr ? mstDecimal(newestPhysicalCtr.breast_dia,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key,
      LAYOUT_ITEM_CTR_CHEST_DIA.key
    )]: newestPhysicalCtr ? mstDecimal(newestPhysicalCtr.chest_dia,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key,
      LAYOUT_ITEM_CTR_CTR.key
    )]: newestPhysicalCtr ? mstDecimal(newestPhysicalCtr.ctr,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key,
      LAYOUT_ITEM_CTR_DW.key
    )]: newestPhysicalCtr ? mstDecimal(newestPhysicalCtr.dw,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO.key,
      LAYOUT_ITEM_INDICATOR_CDCODE.key
    )]: selectDoctor ? selectDoctor : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO.key,
      //mod FNSI-6478 劉全航 start
      LAYOUT_ITEM_DW_DW.key
    )]: unSavedPatInfo ? mstDecimal(unSavedPatInfo.data.dw,2) : null,
    [getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO.key,
      //mod FNSI-6478 劉全航 end
      LAYOUT_ITEM_INDICATOR_CDNAME.key
    )]: selectDoctor ? mstCodeToName(mst_staff, selectDoctor, "userId", "userName") : ""
  };
  // mod #11718 【#11600持ち越し】データリスト画面不正② fang end
  return kendoColumns;
};

/**
 * @description 患者情報をkendo-gridのdata-source用にマップ
 * @param {Array} patList 患者リスト [{ pat_personal_main, pat_main, pat_unique }, ...]
 * @param {Object} mstList 必要なマスタを全て格納したオブジェクト
 * @returns {Array} kendo-gridのdata-source用オブジェクト配列
 *   [
 *     {
 *       basic_info$pat_personal_main$pat_name: '患者1',
 *       ...
 *       basic_info$pat_personal_main$pat_contact_info$zip_cd: '1234567',
 *       ...
 *       other_contact_info$pat_personal_main$other_contact_info$memo1$0: '緊急連絡先1メモ',
 *       ...
 *     },
 *     ...
 *   ]
 */
// mod FNSI-改修内容 入外区分が入院の場合、患者名は紫色にする。同姓同名患者の場合はそれが判断可能にする。 dou start
// export const mapPatInfoToKendoDataSource = (patList, mstList, selectDoctor) => {
//   // mod データリストの患者情報修正 陳 start
//   //  return patList.map(({ pat_personal_main, pat_main, pat_unique }) => {
//   return patList.map(({ pat_personal_main, pat_main, pat_unique, ord_mains }) => {
//     // mod データリストの患者情報修正 陳 end
//     const patPersonalMain = mapPatPersonalMainToKendoFields(
//       pat_personal_main,
//       mstList
//     );
//     const patMain = mapPatMainToKendoFields(pat_main, mstList);
//     const patUnique = mapPatUniqueToKendoFileds(
//       {
//         ...pat_unique,
//         is_diabetes: pat_main.is_diabetes,
//         is_blood_suger_exam: pat_main.is_blood_suger_exam
//       },
//       mstList,
//       selectDoctor
//     );
//     // add データリストの患者情報修正 陳 start
//     const ordMains = ord_mains;
//     // add データリストの患者情報修正 陳 end
//     return {
//       pat_id: pat_personal_main.pat_id,
//       ...patPersonalMain,
//       ...patMain,
//       ...patUnique,
//       // add データリストの患者情報修正 陳 start
//       ordMains
//       // add データリストの患者情報修正 陳 end
//     };
//   });
export const mapPatInfoToKendoDataSource = (patList, mstList, isInOutList, isSameList, unSavedDataList = null) => {
  let sameList = [];
  let inOutList = [];
  return [
    patList.map(({ pat_personal_main, pat_main, pat_unique, ord_mains }) => {
      // 患者名ソート用文字列セット
      pat_personal_main = addPatNameSortToList(pat_personal_main);
      
      let isSame = isSameList.some(y => y == pat_personal_main.pat_id);
      let isInOut = isInOutList.some(y => y == pat_personal_main.pat_id);
      //mod FNSI-6478 劉全航 start
      if(unSavedDataList.length > 0){
        let unSavedPatInfo = unSavedDataList.find(o => o.patId === pat_personal_main.pat_id);
        pat_unique.unSavedPatInfo = unSavedPatInfo;
      }else{
        pat_unique.unSavedPatInfo = null;
      }
      //mod FNSI-6478 劉全航 end
      if (isSame) {
        //mod 9251 nullを空文字列判定に変換します 張博 start
        sameList.push((pat_personal_main.pat_last_name == null ? "" : pat_personal_main.pat_last_name)
                      + ' ' + (pat_personal_main.pat_first_name == null ? "" : pat_personal_main.pat_first_name));
        //mod 9251 nullを空文字列判定に変換します 張博 end
      }
      if (isInOut) {
        inOutList.push(pat_personal_main.hosp_pat_id);
      }
      const patPersonalMain = mapPatPersonalMainToKendoFields(
        pat_personal_main,
        mstList
      );
      const patMain = mapPatMainToKendoFields(pat_main, mstList);
      const patUnique = mapPatUniqueToKendoFileds(
        {
          ...pat_unique,
          is_diabetes: pat_main.is_diabetes,
          is_blood_suger_exam: pat_main.is_blood_suger_exam
        },
        mstList
      );
      const ordMains = ord_mains;
      return {
        pat_id: pat_personal_main.pat_id,
        ...patPersonalMain,
        ...patMain,
        ...patUnique,
        ordMains,
        patNameSort: pat_personal_main.patNameSort
      };
    }),
    sameList,
    inOutList
  ]
// mod FNSI-改修内容 入外区分が入院の場合、患者名は紫色にする。同姓同名患者の場合はそれが判断可能にする。 dou end
};

/**
 * @description kendo-grid必須入力リスト
 * @summary   例: 下記の形で格納
 * getKendoColumnField(
 *  LAYOUT_CATEGORY_BASICINFO.key,
 *  LAYOUT_ITEM_BASICINFO_CONTACT_MEMO1.key
 * )
 */
export const requiredList = [];

/**
 * @description kendo-grid-カラム内のみ必須入力リスト
 * @summary   例: 下記の形で格納
 * {
 *    column: physical_info
 *    jsonky: getKendoColumnField(
 *      LAYOUT_CATEGORY_BASICINFO.key,
 *      LAYOUT_ITEM_BASICINFO_CONTACT_MEMO1.key
 *    )
 * }
 */
export const columnInfoRequiredList = [
  {
    column: "physical_info",
    jsonKey: getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO.key,
      LAYOUT_ITEM_EXAM_DATE.key
    )
  },
  // {
  //   column: "physical_info",
  //   jsonKey: getKendoColumnField(
  //     LAYOUT_CATEGORY_PHYSICAL_INFO.key,
  //     LAYOUT_ITEM_INDICATOR_START_DATE.key
  //   )
  // },
  {
    column: "physical_info",
    jsonKey: getKendoColumnField(
      LAYOUT_CATEGORY_PHYSICAL_INFO.key,
      LAYOUT_ITEM_INDICATOR_CDNAME.key
    )
  }
];

/**
 * @description kendo-grid-columnのeditor(表示日付field用日付入力)
 * @param {String} categoryKey レイアウトカテゴリキー
 * @param {String} itemKey レイアウト項目キー
 * @returns {Function} editor関数
 */
// mod データリストの患者情報修正 陳 start
const editorDateInput = (categoryKey, itemKey, maxDate, minDate) => (container, options) => {
  // mod データリストの患者情報修正 陳 end
  const dateDisplayField = getKendoColumnField(categoryKey, itemKey);
  // kendoDateInputの処理に必要なDateオブジェクト格納先として指定するfield
  const dateObjField = `${dateDisplayField}${LAYOUT_ITEM_KEY_SUFFIX_DATEOBJECT}`;
  const required = requiredList.includes(`${options.field}`) ? "required" : "";
  // mod FNSI-改修内容 「測定日」と「目標体重指示開始日」表示IF不正 dou start

  // デスクトップ、iOSの場合は、処理で補正したHTML5のカレンダーを表示
  let nowData;
  let hasInitValue = true;
  const editedData = options.model.get(dateDisplayField);
  let nowDtatString;
  if (editedData) {
    nowData = new Date(editedData);
  } else {
    nowData = new Date();
    hasInitValue = false;
  }
  nowDtatString = ('000' + nowData.getFullYear()).slice(-4) + "-" + ('0' + (nowData.getMonth() + 1)).slice(-2) + "-" + ('0' + nowData.getDate()).slice(-2);
  // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
  if (!editedData) {
    nowDtatString = "";
  }
  // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
  // $(`<input type="date" id="displayedDummyEditor" validationMessage="必須入力" ${required} class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${dateObjField}" style="display: none;"/>`)
  // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
  //#10715：日付IF修正20240910検証NG対応：村上Start
  const containerEl = container?.[0] || container?.get?.(0) || container;
  const ownerDocument = containerEl?.ownerDocument || document;
  const editorRow = ownerDocument.createElement("span");
  editorRow.className = "ntss-grid-date-editor-row";
  $(editorRow).appendTo(container);
  $(`<span class="ntss-grid-date-input-host" style="position:relative"><input type="date" style="width:8em" id="displayedDummyEditor" validationMessage="必須入力" ${required} class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${dateObjField}" style="display: none;"/><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:75%;top:5px;color: #212529;z-index:9999999"></span></span>`)
    .appendTo(editorRow);
  //#10715：日付IF修正20240910検証NG対応：村上End
  // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
  //#10715：日付IF修正20240910検証NG対応：村上Start
  const displayedEditor = containerEl?.querySelector?.("#displayedDummyEditor");
  const hiddenEditor = containerEl?.querySelector?.("#hiddenDateInputEditor");
  const cleartag = containerEl?.querySelector?.("#clear");
  const displayedEditorJq = displayedEditor ? $(displayedEditor) : $();
  const hiddenEditorJq = hiddenEditor ? $(hiddenEditor) : $();
  const editorCell = containerEl?.closest?.('td');
  let calendarVm = null;

  const resolveGridRoot = () => {
    return containerEl?.closest?.('#kendo')
      || ownerDocument.getElementById?.('kendo')
      || containerEl?.closest?.('.k-grid')
      || null;
  };

  const resolveKendoGrid = () => {
    const gridRoot = resolveGridRoot();
    if (!gridRoot) {
      return null;
    }
    const gridHost = gridRoot.classList?.contains?.('k-grid')
      ? gridRoot
      : (gridRoot.querySelector?.('.k-grid') || gridRoot);
    const gridJq = $(gridHost);
    return gridJq.data('kendoGrid') || globalThis.kendo?.widgetInstance?.(gridJq) || null;
  };

  const resolveSaveContainerCell = () => {
    if (editorCell?.getAttribute?.('data-field') === dateDisplayField) {
      return editorCell;
    }
    const gridRoot = resolveGridRoot();
    const grid = resolveKendoGrid();
    const uid = options.model?.uid;
    if (gridRoot && uid != null) {
      const escapedField = String(dateDisplayField).replace(/"/g, '\\"');
      const escapedUid = String(uid).replace(/"/g, '\\"');
      const rows = gridRoot.querySelectorAll(`tr[data-uid="${escapedUid}"]`);
      for (const row of rows) {
        const cell = row.querySelector(`td[data-field="${escapedField}"]`);
        if (cell) {
          return cell;
        }
      }
    }
    return findKendoGridCellByDataItemField(grid || gridRoot, options.model, dateDisplayField)
      || editorCell
      || null;
  };

  // hidden の *_DateObject は isNoUpdateField のため editCell が走らず編集色が付かない。
  // MultiPatList.triggerSave と同様に表示用 field のセルで save を発火する。
  const triggerDisplayFieldSave = (formattedValue) => {
    const saveValue = formattedValue === '' ? null : formattedValue;
    const containerCell = resolveSaveContainerCell();
    const container = asKendoJQueryElement(containerCell);
    const grid = resolveKendoGrid();
    if (!grid || !container) {
      hiddenEditorJq.trigger('change');
      return;
    }
    grid.trigger('save', {
      container,
      model: options.model,
      values: { [dateDisplayField]: saveValue }
    });
    requestAnimationFrame(() => {
      if (grid?._editContainer) {
        grid.editable?.end?.();
        grid.closeCell();
      }
    });
  };

  const commitDateValue = (rawValue) => {
    let nextValue = rawValue || '';
    if (!nextValue) {
      if (hiddenEditor) { hiddenEditor.value = ''; }
      if (displayedEditor) { displayedEditor.value = ''; }
      options.model.set(dateDisplayField, '');
      calendarVm?.setSilently?.('');
      triggerDisplayFieldSave('');
      return;
    }
    const normalizedDate = dayjs(nextValue);
    if (!normalizedDate.isValid()) {
      if (hiddenEditor) { hiddenEditor.value = ''; }
      if (displayedEditor) { displayedEditor.value = ''; }
      options.model.set(dateDisplayField, '');
      calendarVm?.setSilently?.('');
      triggerDisplayFieldSave('');
      return;
    }
    let formattedValue = normalizedDate.format('YYYY/MM/DD');
    if (maxDate && normalizedDate.unix() > dayjs().unix()) {
      formattedValue = dayjs().format('YYYY/MM/DD');
    } else if (minDate && normalizedDate.unix() < dayjs().unix()) {
      formattedValue = dayjs().format('YYYY/MM/DD');
    }
    const isoValue = dayjs(formattedValue, 'YYYY/MM/DD', true).format('YYYY-MM-DD');
    if (hiddenEditor) { hiddenEditor.value = formattedValue; }
    if (displayedEditor) { displayedEditor.value = isoValue; }
    options.model.set(dateDisplayField, formattedValue);
    calendarVm?.setSilently?.(isoValue);
    triggerDisplayFieldSave(formattedValue);
  };

  cleartag?.addEventListener("mousedown", function() {
    if (displayedEditor) {
      displayedEditor.value = "";
    }
    commitDateValue('');
  });
  //#10715：日付IF修正20240910検証NG対応：村上End
  displayedEditor?.addEventListener("blur", function (ev) {
    if (editorRow.contains(ev.relatedTarget)) {
      return;
    }

    let resultData;
    const dayData = new Date(ev.target.value);
    // 初期と編集後の値が空欄の場合、更新レコードとして判断しない
    if (ev.target.value === "" && !hasInitValue) {
      resultData = "";
      nowDtatString = "";
      hasInitValue = true;
    } else {
      resultData = ('000' + dayData.getFullYear()).slice(-4) + "/" + ('0' + (dayData.getMonth() + 1)).slice(-2) + "/" + ('0' + dayData.getDate()).slice(-2);
    }

    // 変更前の値と比較し、同じ値の場合は処理しない。又は、初期値がない場合、必ず処理する。
    if (!hasInitValue || nowDtatString != resultData) {
      hasInitValue = true;
      nowDtatString = ev.target.value || '';
      commitDateValue(ev.target.value);
    }
    // mod FNSI-改修内容 「測定日」と「目標体重指示開始日」表示IF不正 dou end

  });

  const initialCalendarValue = normalizeGridDateInputValue(nowDtatString) || '';
  const disableDatesBefore = options.field === "pat_unique$physical_info$indicator_start_date"
    ? String(options.model?.pat_unique$physical_info$exam_date || options.model?.get?.("pat_unique$physical_info$exam_date") || "").replace(/\//g, "")
    : "";

  const calendarMountRoot = ownerDocument.createElement("span");
  calendarMountRoot.className = "ntss-grid-date-editor-calendar";
  $(calendarMountRoot).appendTo(editorRow);

  const GridEditorCalendarBridge = defineComponent({
    name: "GridEditorCalendarBridge",
    components: { commonCalender },
    props: {
      disableDatesBefore: {
        type: String,
        default: ""
      },
      initialValue: {
        type: String,
        default: ""
      }
    },
    data() {
      return {
        currentValue: this.initialValue || ""
      };
    },
    methods: {
      handleInput(value) {
        this.currentValue = value || "";
        commitDateValue(value);
      },
      setSilently(value) {
        this.currentValue = normalizeGridDateInputValue(value) || "";
        this.$refs.calendar?.setSilently?.(value);
      }
    },
    template: '<common-calender ref="calendar" :value="currentValue" :disable-dates-before="disableDatesBefore" @input="handleInput" />'
  });

  const calendarApp = createApp(GridEditorCalendarBridge, {
    disableDatesBefore,
    initialValue: initialCalendarValue
  });
  calendarVm = calendarApp.mount(calendarMountRoot);
  calendarVm?.setSilently?.(initialCalendarValue);

};

/** Grid セル editor の container から kendoGrid インスタンスを取得する */
const resolveKendoGridFromEditorContainer = (container) => {
  const containerEl = container?.[0] || container?.get?.(0) || container;
  const ownerDocument = containerEl?.ownerDocument || document;
  const gridRoot = containerEl?.closest?.("#kendo")
    || ownerDocument.getElementById?.("kendo")
    || containerEl?.closest?.(".k-grid")
    || null;
  if (!gridRoot) {
    return null;
  }
  const gridHost = gridRoot.classList?.contains?.("k-grid")
    ? gridRoot
    : (gridRoot.querySelector?.(".k-grid") || gridRoot);
  const gridJq = $(gridHost);
  return gridJq.data("kendoGrid") || globalThis.kendo?.widgetInstance?.(gridJq) || null;
};

/** DropDown 等 editor 終了時に Grid のインライン編集を閉じる */
const closeKendoGridEditorFromContainer = (container) => {
  requestAnimationFrame(() => {
    const grid = resolveKendoGridFromEditorContainer(container);
    if (!grid?._editContainer) {
      return;
    }
    grid.editable?.end?.();
    grid.closeCell();
  });
};

/**
 * @description kendo-grid-columnのeditor(マスタ名称field用ドロップダウン)
 * @param {Array} mst 表示するマスタのオブジェクト配列
 * @param {String} categoryKey レイアウトカテゴリキー
 * @param {String} itemKey レイアウト項目キー
 * @param {Boolean} isPseudo 疑似マスタフラグ ※性別、血液型等はtrue
 * @param {String} dataValueField マスタオブジェクトのマスタコードプロパティのキー名
 * @param {String} dataTextField マスタオブジェクトのマスタ名称プロパティのキー名
 * @returns {Function} editor関数
 */
const editorDropDown = (
  mst,
  categoryKey,
  itemKey,
  isPseudo = false,
  dataValueField = "code",
  dataTextField = "name"
) => (container, options) => {
  const mstNameField = getKendoColumnField(categoryKey, itemKey);
  // マスタの場合にドロップダウンの値格納先として指定するマスタコードfield
  // ※画面に表示されるマスタ名称fieldは'<mst_code>_MstName'になっているので'_MstName'を除去して得られる
  const mstCodeField = mstNameField.replace(
    LAYOUT_ITEM_KEY_SUFFIX_MSTNAME,
    ""
  );
  // add bug #5198 修正 chen start
  let mstTmp = [];
  if (mstCodeField === "pat_personal_main$pat_blood_type_serovar") {
    mst.forEach(item => {
      if (item.code === 0 && options["model"]["pat_personal_main$pat_blood_type_abo"] !== 4) {
        mstTmp.push(item);
      }
      if (options["model"]["pat_personal_main$pat_blood_type_abo"] === 1) {
        if (item.code === 11 || item.code === 12 || item.code === 13 || item.code === 14
          || item.code === 15 || item.code === 16 || item.code === 17 || item.code === 18) {
          mstTmp.push(item);
        }
      }
      if (options["model"]["pat_personal_main$pat_blood_type_abo"] === 2) {
        if (item.code === 21 || item.code === 22 || item.code === 23 || item.code === 24
          || item.code === 25 || item.code === 26 || item.code === 27 || item.code === 28) {
          mstTmp.push(item);
        }
      }
      if (options["model"]["pat_personal_main$pat_blood_type_abo"] === 3) {
        if (item.code === 31 || item.code === 32 || item.code === 33
          || item.code === 34 || item.code === 35 || item.code === 36) {
          mstTmp.push(item);
        }
      }
      if (options["model"]["pat_personal_main$pat_blood_type_abo"] === 4) {
        if (item.code > 399 && item.code < 499) {
          mstTmp.push(item);
        }
      }
    });
  } else {
    mstTmp = mst;
  }
  // add bug #5198 修正 chen end
  // 「未登録」を選択肢に追加
  const dataSource = isPseudo
    ? mstTmp
    : [{ [dataValueField]: null, [dataTextField]: "未登録" }, ...mst];
  const required = requiredList.includes(`${options.field}`) ? "required" : "";

  $(`<input name="${mstCodeField}" validationMessage="必須入力" ${required} />`)
    .appendTo(container)
    .kendoDropDownList({
      dataTextField,
      dataValueField,
      dataSource,
      filter: "contains",
      // 値がnullのときの動作変更オプション
      // https://docs.telerik.com/kendo-ui/api/javascript/ui/dropdownlist/configuration/valueprimitive#valueprimitive
      valuePrimitive: true,
      virtual: dataSource.length > 200 ? {
        valueMapper: function(options) {
          const index = dataSource.findIndex((item) => {
            return item?.[dataValueField] === options.value;
          });
          options.success(index);
        }
      } : false,
      select(e) {
        const mstName = e.dataItem[dataTextField];
        const mstCode = e.dataItem[dataValueField];
        options.model.set(mstCodeField, mstCode);
        // マスタ名称fieldを強制変更 ※セルの変更と見做されkendo-gridのsaveが発火するので注意
        options.model.set(mstNameField, mstName);
      },
      close() {
        closeKendoGridEditorFromContainer(container);
      }
    });
};

/**
 * @description kendo-grid-columnのeditor(マスタ名称field用ドロップダウン)
 * @param {Array} mst 表示するマスタのオブジェクト配列
 * @param {String} categoryKey レイアウトカテゴリキー
 * @param {String} itemKey レイアウト項目キー
 * @param {String} dataValueField マスタオブジェクトのマスタコードプロパティのキー名
 * @param {String} dataTextField マスタオブジェクトのマスタ名称プロパティのキー名
 * @returns {Function} editor関数
 */
const editorNumeric = (min, max, decimals = 0) => (container, options) => {
  const required = requiredList.includes(`${options.field}`) ? "required" : "";
  const step = decimals === 0 ? 1 : 1 / Math.pow(10, decimals);
  $(
    `<input id="hoge" name="${options.field}" class="k-numeric" validationMessage="必須入力" ${required} />`
  )
    .appendTo(container)
    .kendoNumericTextBox({
      decimals,
      step,
      spin() {
        let value = getKendoWidgetValue(this);
        if (value > max) {
          value = min;
        } else if (value < min) {
          value = max;
        }
        options.model.set(options.field, value?.toFixed(decimals) || null);
      },
      change() {
        let value = getKendoWidgetValue(this);
        if (value > max) {
          value = max;
        } else if (value < min) {
          value = min;
        }
        options.model.set(options.field, value?.toFixed(decimals) || null);
      }
    });
  // マウスホイールで値変更したいならこんな感じで頑張る
  // .on('mousewheel', function() {
  //   const value = Number(this.value);
  // });
};
const numberTemplate = (field, step) => (options) => {
  const val = options["pat_unique$physical_info$" + field];
  if (typeof val === 'string') {
    return val;
  }
  return (val || val === 0)? `${parseFloat(val)?.toFixed(step)}` : '';
};
// add データリストの患者情報修正 陳 start
/**
 * @description kendo-grid-columnのeditor(マスタ名称field用ドロップダウン)
 * @param {Array} mst 表示するマスタのオブジェクト配列
 * @param {String} categoryKey レイアウトカテゴリキー
 * @param {String} itemKey レイアウト項目キー
 * @param {String} dataValueField マスタオブジェクトのマスタコードプロパティのキー名
 * @param {String} dataTextField マスタオブジェクトのマスタ名称プロパティのキー名
 * @returns {Function} editor関数
 */
const editorChkNumeric = (min, max, decimals = 0) => (container, options) => {
  const required = requiredList.includes(`${options.field}`) ? "required" : "";
  const chkObjField = `${options.field}${LAYOUT_ITEM_KEY_SUFFIX_CHKBOX}`;
  const flg = options.model.get(chkObjField);
  let numtext = options.model.get(options.field);
  const step = decimals === 0 ? 1 : 1 / Math.pow(10, decimals);
  $(
    `<label class="checkbox" style="white-space: normal; margin-right: 5px;">
      <input id="numchk" type="checkbox" class="checkbox__input" value="●" name="${chkObjField}" validationMessage="必須入力" ${required} />
      <span class="checkbox__checkmark"></span>
    </label>`
  )
    .appendTo(container);
  $(
    `<input id="numtextbox" name="${options.field}" class="k-numeric" validationMessage="必須入力" ${required} style="width: 84%;"/>`
  )
    .appendTo(container)
    .kendoNumericTextBox({
      decimals,
      step,
      placeholder: "DWと同じ",
      spin(event) {
        const isChkEnabled = options.model.get(chkObjField);
        let value = getKendoWidgetValue(this);
        if (value == null && isChkEnabled) {
          const nativeEvent = event?.event || event;
          const spinButton = nativeEvent?.target?.closest?.(".k-spinner-increase, .k-spinner-decrease");
          const isIncrease = spinButton?.classList?.contains("k-spinner-increase");
          value = isIncrease ? min + step : min;
        }
        if (value > max) {
          value = min;
        } else if (value < min) {
          value = max;
        }
        if (typeof value === "number") {
          value = Number(value.toFixed(decimals));
          setKendoWidgetValue(this, value);
        }
        options.model.set(options.field, value);
      },
      change() {
        const isChkEnabled = options.model.get(chkObjField);
        let value = getKendoWidgetValue(this);
        if (value > max) {
          value = max;
        } else if (value < min) {
          value = min;
        }
        if (typeof value === "number") {
          value = Number(value.toFixed(decimals));
          setKendoWidgetValue(this, value);
        } else if (isChkEnabled && value == null) {
          value = "DWと同じ";
        }
        options.model.set(options.field, value);
      }
    });
  let numtextbox = $(container).find("#numtextbox").data("kendoNumericTextBox");
  if (numtext != null) {
    if (flg) {
      numtextbox.enable();
      if (numtext == null) {
        numtextbox.element.get(0).parentElement.children[0].placeholder = "DWと同じ";
        options.model.set(options.field, "DWと同じ");
      }
    } else {
      numtextbox.enable(false);
      numtextbox.value(null);
      numtextbox.element.get(0).parentElement.children[0].placeholder = "";
      options.model.set(options.field, null);
    }
  } else {
    numtextbox.enable(false);
    numtextbox.element.get(0).parentElement.children[0].placeholder = "";
  }
  $(container).find("#numchk").change(function () {
    if (this.checked) {
      numtextbox.enable();
      numtextbox.placeholder = "DWと同じ";
      this.parentElement.parentElement.children[1].children[0].children[0].placeholder = "DWと同じ";
      options.model.set(options.field, "DWと同じ");
    } else {
      numtextbox.enable(false);
      numtextbox.value(null);
      this.parentElement.parentElement.children[1].children[0].children[0].placeholder = "";
      options.model.set(options.field, null);
    }
    options.model.set(chkObjField, this.checked);
  });
};
// add データリストの患者情報修正 陳 end

const editorCustomText = attr => (container, options) => {
  const required = requiredList.includes(`${options.field}`) ? "required" : "";

  $(
    `<input name="${options.field}" class="k-input k-textbox" ${attr} validationMessage="必須入力" ${required} />`
  ).appendTo(container);
};

const editorTextArea = () => (container, options) => {
  const required = requiredList.includes(`${options.field}`) ? "required" : "";
  $(
    `<textarea name="${options.field
    }" class="k-textarea resize-obs-target" validationMessage="必須入力" ${required} style="width:${container.width()}px;height:${container.height()}px;max-height: 65vh;resize: vertical;font-size: inherit;min-height: calc(.75rem + 6em) !important;"></textarea>`
  ).appendTo(container);
  const resizeObserver = new ResizeObserver(entries => {
    // テキストエリアのリサイズに応じてkendo-gridをリサイズする
    if (eventBusObj) {
      eventBusObj.$emit("resizeToFitTextArea");
    }
  });
  const resizeTarget = (container?.[0] || container?.get?.(0) || container)?.querySelector?.('.resize-obs-target');
  if (resizeTarget) {
    resizeObserver.observe(resizeTarget);
  }
};

const editorTimeInput = () => (container, options) => {
  const required = requiredList.includes(`${options.field}`) ? "required" : "";
  //#10715:日付IF修正Start
  $(
    `<span style="position:relative"><input type="time" id="${options.field}" name="${options.field}" class="time-wrapper" style="width: 7em;" value="00:00" /><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:65%;top:5px;color: #212529;z-index:9999999"/></span></span>`
  ).appendTo(container);

  const containerEl = container?.[0] || container?.get?.(0) || container;
  const idtag = findElementByIdWithin(containerEl, options.field);
  const idtagJq = idtag ? $(idtag) : $();
  const cleartag = findElementByIdWithin(containerEl, "clear");
  cleartag?.addEventListener("mousedown", function() {
    if (idtag) { idtag.value = ''; }
    options.model.set(options.field, "");
    idtagJq.trigger('change');
  });
  cleartag?.addEventListener("touchstart", function() {
    if (idtag) { idtag.value = ""; }
    options.model.set(options.field, "");
    idtagJq.trigger('change');
  });
  //#10715:日付IF修正End
};

export class KendoDisplayProperty {
  constructor(width, editable, editor, headerAttributes, headerTemplates, template, encoded) {
    this.width = `${width}px`;
    this.editable = editable;
    this.editor = editor;
    this.headerAttributes = headerAttributes;
    this.headerTemplate = headerTemplates;
    this.template = template;
    this.encoded = encoded;
  }
}

/**
 * @description kendo-grid-columnのfieldに応じた表示用属性を取得
 * @param {String} categoryKey レイアウトカテゴリキー
 * @param {String} itemKey レイアウト項目キー
 * @param {Object} 必要なマスタを全て格納したオブジェクト
 * @returns {Object} { width, editable, editor }
 */
const getKendoDisplayProperty = (
  categoryKey,
  itemKey,
  { mst_severity, mst_transport, mst_course,mst_facility, mst_ward, mst_staff, mst_sysCountry, mst_disease },
  tmpEventBusObj
) => {
  // デフォルト属性値
  let width = 200;
  let editable = () => true;
  let editor = undefined;
  let headerTemplates;
  let headerAttributes = {};
  let template = null;
  // グリッド内で改行許容
  const encoded = true;

  const notEditable = () => [() => false, { class: "k-header-disabled" }];
  eventBusObj = tmpEventBusObj;

  // 属性を変更したい項目を対応するカテゴリ-項目以下に定義する
  switch (categoryKey) {
    case LAYOUT_CATEGORY_BASICINFO.key:
      switch (itemKey) {
        // mod bug #5193 修正 chen start
        case LAYOUT_ITEM_BASICINFO_NAME.key:
        case LAYOUT_ITEM_BASICINFO_NAMEKANA.key:
        case LAYOUT_ITEM_BASICINFO_NAMEALPHA.key:
        case LAYOUT_ITEM_BASICINFO_PATID.key:
        case LAYOUT_ITEM_BASICINFO_INHOSPITALSTATE.key:
          [editable, headerAttributes] = notEditable();
          break;
        // mod bug #5193 修正 chen end
        case LAYOUT_ITEM_BASICINFO_INOUT.key:
          width = 150;
          [editable, headerAttributes] = notEditable();
          break;

        case LAYOUT_ITEM_BASICINFO_BIRTHDAY.key:
          width = 250;
          // mod データリストの患者情報修正 陳 start
          editor = editorDateInput(categoryKey, itemKey, false, false);
          // mod データリストの患者情報修正 陳 end
          break;

        // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
        case LAYOUT_ITEM_BASICINFO_AGE.key:
          [editable, headerAttributes] = notEditable();
          break;
        // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end

        case LAYOUT_ITEM_BASICINFO_SEXNAME.key:
          width = 150;
          editor = editorDropDown(
            PSEUDO_MST_LIST.sex,
            categoryKey,
            itemKey,
            true
          );
          break;

        case LAYOUT_ITEM_BASICINFO_BLOODABONAME.key:
          width = 150;
          editor = editorDropDown(
            PSEUDO_MST_LIST.bloodABO,
            categoryKey,
            itemKey,
            true
          );
          break;

        case LAYOUT_ITEM_BASICINFO_BLOODRHNAME.key:
          width = 150;
          editor = editorDropDown(
            PSEUDO_MST_LIST.bloodRh,
            categoryKey,
            itemKey,
            true
          );
          break;

        case LAYOUT_ITEM_BASICINFO_BLOODSEROVARNAME.key:
          width = 170;
          editor = editorDropDown(
            PSEUDO_MST_LIST.bloodSerovar,
            categoryKey,
            itemKey,
            true
          );
          break;

        // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
        case LAYOUT_ITEM_BASICINFO_NATIONALITYNAME.key:
          editor = editorDropDown(
            mst_sysCountry,
            categoryKey,
            itemKey,
            true,
            "countryCdAlpha3",
            "countryName"
          );
          break;
        // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end

        case LAYOUT_ITEM_BASICINFO_CONTACT_ZIPCD.key:
          editor = editorCustomText('maxlength="7"');
          break;

        // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
        case LAYOUT_ITEM_BASICINFO_CONTACT_WORK_NAME.key:
          [editable, headerAttributes] = notEditable();
          break;

        case LAYOUT_ITEM_BASICINFO_CONTACT_WORK_TEL.key:
          [editable, headerAttributes] = notEditable();
          break;
        // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end

        case LAYOUT_ITEM_BASICINFO_CONTACT_MEMO1.key:
        case LAYOUT_ITEM_BASICINFO_CONTACT_MEMO2.key:
        case LAYOUT_ITEM_BASICINFO_CONTACT_ADDRESS.key:
          editor = editorTextArea();
          break;
      }
      break;

    case LAYOUT_CATEGORY_OTHERCONTACTKEYPERSONINFO[0].key:
      // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
      [editable, headerAttributes] = notEditable();
      // switch (itemKey) {
      //   case LAYOUT_ITEM_OTHERCONTACTINFO_MEMO1.key:
      //   case LAYOUT_ITEM_OTHERCONTACTINFO_MEMO2.key:
      //   case LAYOUT_ITEM_OTHERCONTACTINFO_ADDRESS.key:
      //     editor = editorTextArea();
      //     break;
      // }
      // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
      break;

    case LAYOUT_CATEGORY_OTHERCONTACTINFO[0].key:
    case LAYOUT_CATEGORY_OTHERCONTACTINFO[1].key:
    case LAYOUT_CATEGORY_OTHERCONTACTINFO[2].key:
      // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
      [editable, headerAttributes] = notEditable();
      // switch (itemKey) {
      //   case LAYOUT_ITEM_OTHERCONTACTINFO_MEMO1.key:
      //   case LAYOUT_ITEM_OTHERCONTACTINFO_MEMO2.key:
      //   case LAYOUT_ITEM_OTHERCONTACTINFO_ADDRESS.key:
      //     editor = editorTextArea();
      //     break;
      // }
      // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
      break;

    case LAYOUT_CATEGORY_VENDORCONTACTINFO[0].key:
    case LAYOUT_CATEGORY_VENDORCONTACTINFO[1].key:
    case LAYOUT_CATEGORY_VENDORCONTACTINFO[2].key:
      // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
      [editable, headerAttributes] = notEditable();
      // switch (itemKey) {
      //   case LAYOUT_ITEM_VENDORCONTACTINFO_MEMO1.key:
      //   case LAYOUT_ITEM_VENDORCONTACTINFO_MEMO2.key:
      //   case LAYOUT_ITEM_VENDORCONTACTINFO_ADDRESS.key:
      //     editor = editorTextArea();
      //     break;
      // }
      // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
      break;

    case LAYOUT_CATEGORY_DIFFICULTY_MAIN.key:
      switch (itemKey) {
        case LAYOUT_ITEM_DIFFICULTY_MAIN.key:
          width = 300;
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;

    case LAYOUT_CATEGORY_DIFFICULTY_OTHER.key:
      switch (itemKey) {
        case LAYOUT_ITEM_DIFFICULTY_OTHER.key:
          width = 300;
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;

    case LAYOUT_CATEGORY_SEVERITY.key:
      switch (itemKey) {
        case LAYOUT_ITEM_SEVERITYNAME.key:
          width = 300;
          editor = editorDropDown(mst_severity, categoryKey, itemKey);
          break;
      }
      break;

    case LAYOUT_CATEGORY_TRANSPORT.key:
      switch (itemKey) {
        case LAYOUT_ITEM_TRANSPORTNAME.key:
          width = 300;
          editor = editorDropDown(mst_transport, categoryKey, itemKey);
          break;
      }
      break;

    case LAYOUT_CATEGORY_PATMEMOINFO.key:
      switch (itemKey) {
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_1.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_2.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_3.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_4.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_5.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_6.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_7.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_8.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_9.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_10.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_11.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_12.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_13.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_14.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_15.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_16.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_17.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_18.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_19.key:
        case LAYOUT_ITEM_PATMEMOINFO_CONTENT_20.key:
          editor = editorTextArea();
          break;
      }
      break;

    case LAYOUT_CATEGORY_MEDICALCAREINFO.key:
      switch (itemKey) {
        case LAYOUT_ITEM_MEDICALCAREINFO_MAINCOURSENAME.key:
        case LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOURSENAME.key:
          width = 300;
          editor = editorDropDown(mst_course, categoryKey, itemKey);
          break;
        /*add FNSI-改修内容5202 任 start*/
        case LAYOUT_ITEM_MEDICALCAREINFO_FACILITYNAME.key:
          width = 300;
          editor = editorDropDown(mst_facility, categoryKey, itemKey, true,"facilityCd","facilityName");
          break;
        /*add FNSI-改修内容5202 任 end*/
        case LAYOUT_ITEM_MEDICALCAREINFO_WARDNAME.key:
          width = 300;
          editor = editorDropDown(mst_ward, categoryKey, itemKey);
          break;
        case LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISCOUNT.key:
        case LAYOUT_ITEM_MEDICALCAREINFO_PAT_DIALYSIS_COUNT.key:
        case LAYOUT_ITEM_MEDICALCAREINFO_PURIFICATIONCOUNT.key:
          width = 250;
          editor = editorNumeric(0, 10000);
          break;
        /*add FNSI-改修内容5202 任 start*/
        case LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISSTARTDATE.key:
          width = 250;
          editor = editorDateInput(categoryKey, itemKey, false, false);
          break;
        /*add FNSI-改修内容5202 任 end*/
        // del FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
        // case LAYOUT_ITEM_MEDICALCAREINFO_DIALYSISSTARTDATE.key:
        // case LAYOUT_ITEM_MEDICALCAREINFO_FACILITYNAME.key:
        // case LAYOUT_ITEM_MEDICALCAREINFO_DYALYSISHST.key:
        //   [editable, headerAttributes] = notEditable();
        //   break;
        // del FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
      }
      break;

    case LAYOUT_CATEGORY_CHARGESTAFFINFO.key:
      // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
      [editable, headerAttributes] = notEditable();
      // switch (itemKey) {
      //   case LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_1.key:
      //   case LAYOUT_ITEM_CHARGESTAFFINFO_DOCTORNAME_2.key:
      //   case LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_1.key:
      //   case LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_2.key:
      //   case LAYOUT_ITEM_CHARGESTAFFINFO_CHARGENAME_3.key:
      //   case LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_1.key:
      //   case LAYOUT_ITEM_CHARGESTAFFINFO_PUNCTURENAME_2.key:
      //     editor = editorDropDown(
      //       mst_staff,
      //       categoryKey,
      //       itemKey,
      //       false,
      //       "userId",
      //       "userName"
      //     );
      //     break;
      // }
      // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
      break;

    case LAYOUT_CATEGORY_TABOO_ALLERGY_INFO.key:
      switch (itemKey) {
        case LAYOUT_ITEM_TABOO.key:
        case LAYOUT_ITEM_ALLERGY.key:
          width = 300;
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;

    case LAYOUT_CATEGORY_INFECT_INFO.key:
      switch (itemKey) {
        case LAYOUT_ITEM_POSITIVE_INFECTION.key:
        case LAYOUT_ITEM_NEGATIVE_INFECTION.key:
        case LAYOUT_ITEM_UNCLEAR_INFECTION.key:
          // del FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
          // case LAYOUT_ITEM_INFECTION.key:
          // del FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
          width = 300;
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;

    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    case LAYOUT_CATEGORY_PATIENT_GROUP.key:
      switch (itemKey) {
        case LAYOUT_PATIENTGROUP_PATIENTGROUP.key:
          width = 300;
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;

    case LAYOUT_CATEGORY_ADDITION.key:
      switch (itemKey) {
        case LAYOUT_ADDITION_ADDITIONKIND.key:
          width = 300;
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end

    case LAYOUT_CATEGORY_IMPLANT_INFO.key:
      switch (itemKey) {
        case LAYOUT_ITEM_IMPLANT.key:
          width = 300;
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;

    case LAYOUT_CATEGORY_MEDICAL_HST_INFO.key:
      switch (itemKey) {
        // del FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
        // case LAYOUT_ITEM_DISEASE_CD.key:
        // case LAYOUT_ITEM_IS_CONFIRMATION_BIOPSY.key:
        // case LAYOUT_ITEM_DISEASE_DATE.key:
        // case LAYOUT_ITEM_OUT_COME_DATE.key:
        // case LAYOUT_ITEM_CAUSE_DEATH.key:
        // del FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
        case LAYOUT_ITEM_DISEASE_DATE.key:
          width = 300;
          editor = editorDateInput(categoryKey, itemKey, false, false);
          break;
        case LAYOUT_ITEM_CAUSE_DEATH_NAME.key:
          editor = editorDropDown(
            mst_disease,
            categoryKey,
            itemKey,
            true
          );
          break;
        case LAYOUT_ITEM_OUT_COME_DATE.key:
          [editable, headerAttributes] = notEditable();
          break;
        case LAYOUT_ITEM_IS_CONFIRMATION_BIOPSYNAME.key:
          editor = editorDropDown(
            PSEUDO_MST_LIST.isConfirmation,
            categoryKey,
            itemKey,
            true
          );
          break;
        case LAYOUT_ITEM_DISEASE_NAME.key:
          editor = editorDropDown(
            mst_disease,
            categoryKey,
            itemKey,
            true
          );
          break;

        case LAYOUT_ITEM_IS_NOTICE.key:
        case LAYOUT_ITEM_IS_NOTICE_2.key:
        case LAYOUT_ITEM_IS_NOTICE_3.key:
          [editable, headerAttributes] = notEditable();
          break;

        case LAYOUT_ITEM_IS_DIAGNOSEDNAME.key:
          editor = editorDropDown(
            PSEUDO_MST_LIST.isDiagnosed,
            categoryKey,
            itemKey,
            true
          );
          break;

        case LAYOUT_ITEM_IS_DIABETESNAME.key:
        case LAYOUT_ITEM_IS_BLOOD_SUGER_EXAMNAME.key:
          editor = editorDropDown(
            PSEUDO_MST_LIST.mstCheck,
            categoryKey,
            itemKey,
            true
          );
          break;
      }
      break;

    case LAYOUT_CATEGORY_PHYSICAL_INFO_HEIGHT.key:
      switch (itemKey) {
        case LAYOUT_ITEM_HEIGHT_EXAM_DATE.key:
        case LAYOUT_ITEM_HEIGHT_EXAM_TIME.key:
        case LAYOUT_ITEM_HEIGHT_HEIGHT.key:
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;

    case LAYOUT_CATEGORY_PHYSICAL_INFO_DW.key:
      switch (itemKey) {
        case LAYOUT_ITEM_DW_EXAM_DATE.key:
        case LAYOUT_ITEM_DW_EXAM_TIME.key:
        case LAYOUT_ITEM_DW_ORDER_CLASS.key:
        case LAYOUT_ITEM_DW_TR_WEIGHT.key:
        case LAYOUT_ITEM_DW_BREAST_DIA.key:
        case LAYOUT_ITEM_DW_CHEST_DIA.key:
        case LAYOUT_ITEM_DW_CTR.key:
        case LAYOUT_ITEM_DW_DW.key:
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;

    case LAYOUT_CATEGORY_PHYSICAL_INFO_CTR.key:
      switch (itemKey) {
        case LAYOUT_ITEM_CTR_EXAM_DATE.key:
        case LAYOUT_ITEM_CTR_EXAM_TIME.key:
        case LAYOUT_ITEM_CTR_ORDER_CLASS.key:
        case LAYOUT_ITEM_CTR_TR_WEIGHT.key:
        case LAYOUT_ITEM_CTR_BREAST_DIA.key:
        case LAYOUT_ITEM_CTR_CHEST_DIA.key:
        case LAYOUT_ITEM_CTR_CTR.key:
        case LAYOUT_ITEM_CTR_DW.key:
          [editable, headerAttributes] = notEditable();
          break;
      }
      break;

    case LAYOUT_CATEGORY_PHYSICAL_INFO.key:
      editable = () => {
        // 編集権限：患者情報ON
        return getAuthorized('PatInfo', 'default_authority');
      };
      headerAttributes = getAuthorized('PatInfo', 'default_authority') ? null : { class: "k-header-disabled" };

      switch (itemKey) {
        case LAYOUT_ITEM_EXAM_DATE.key: // 検査日
          if (getAuthorized("PatInfo", "default_authority")) {
            width = 280;
            headerTemplates = toKendoTemplate('<div class="multi-pat-header-row"><label>検査日</label><div id="header-exam-date-wrapper"></div><div id="header-exam-calendar-wrapper"></div></div>');
          }
          // add データリストの患者情報修正 陳 start
          editor = editorDateInput(categoryKey, itemKey, false, false);
          break;
        // add データリストの患者情報修正 陳 end
        case LAYOUT_ITEM_INDICATOR_START_DATE.key:
          editable = (dataItem) => {
            return dataItem.pat_unique$physical_info$target_weight_chkbox && getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card');
          };
          headerAttributes = getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card') ? null : { class: "k-header-disabled" };
          editor = editorDateInput(categoryKey, itemKey, false, true);
          break;

        case LAYOUT_ITEM_EXAM_TIME.key: // 検査時刻
          if (getAuthorized("PatInfo", "default_authority")) {
            width = 280;
            headerTemplates = toKendoTemplate('<div class="multi-pat-header-row"><label>検査時刻</label><div id="header-exam-time-wrapper"></div></div>');
          }
          editor = editorTimeInput();
          break;

        case LAYOUT_ITEM_ORDER_CLASSNAME.key: // 検査タイミング
          if (getAuthorized("PatInfo", "default_authority")) {
            width = 300;
            headerTemplates = toKendoTemplate('<div class="userCategory multi-pat-header-row"><label for="header-order-classname">検査タイミング</label><div id="header-order-classname"></div></div>');
          }
          editor = editorDropDown(
            PSEUDO_MST_LIST.orderClass,
            categoryKey,
            itemKey,
            true
          );
          break;
        case LAYOUT_ITEM_INDICATOR_CDNAME.key:
          editor = editorDropDown(
            mst_staff,
            categoryKey,
            itemKey,
            false,
            "userId",
            "userName"
          );
          break;

        case LAYOUT_ITEM_HEIGHT.key:
          editor = editorNumeric(0, 300, 1);
          template = numberTemplate(itemKey, 1);
          break;
        case LAYOUT_ITEM_CTR_WEIGHT.key:
          editor = editorNumeric(0, 300, 2);
          template = numberTemplate(itemKey, 2);
          break;
        case LAYOUT_ITEM_DW.key:
          editable = () => {
            return getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card');
          };
          headerAttributes = getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card') ? null : { class: "k-header-disabled" };
          editor = editorNumeric(0, 300, 2);
          template = numberTemplate(itemKey, 2);
          break;
        // add データリストの患者情報修正 陳 start
        case LAYOUT_ITEM_TARGET_WEIGHT.key:
          editable = () => {
            return getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card');
          };
          headerAttributes = getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card') ? null : { class: "k-header-disabled" };
          editor = editorChkNumeric(0, 300, 2);
          template = numberTemplate(itemKey, 2);
          if (getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card')) {
            headerTemplates = toKendoTemplate(
              `<div class="multi-pat-header-row"><label class="checkbox">
                <input type="checkbox" class="checkbox__input" id="target-weight-check-all" />
                <span class="checkbox__checkmark"></span>
              </label>
              <label for="check-all">目標体重</label></div>`
            );
          }
          break;
        // add データリストの患者情報修正 陳 end
        case LAYOUT_ITEM_BREAST_DIA.key:
        case LAYOUT_ITEM_CHEST_DIA.key:
          editor = editorNumeric(0, 9999.99, 2);
          template = numberTemplate(itemKey, 2);
          break;
        case LAYOUT_ITEM_CTR.key:
          editor = editorNumeric(0, 100, 2);
          template = numberTemplate(itemKey, 2);
          break;
        // add データリストの患者情報修正 陳 start
        case LAYOUT_ITEM_PRE_SCALE_UPPER.key:
        case LAYOUT_ITEM_PRE_SCALE_LOWER.key:
          editor = editorNumeric(0, 300, 2);
          template = numberTemplate(itemKey, 2);
          break;
        // add データリストの患者情報修正 陳 end

        case LAYOUT_ITEM_MEMO.key:
          editor = editorTextArea();
          break;
      }

      break;
  }

  return new KendoDisplayProperty(
    width,
    editable,
    editor,
    headerAttributes,
    headerTemplates,
    template,
    encoded
  );
};

/**
 * @description kendo-grid-columnのfieldに応じた表示用属性を取得
 * @param {String} categoryKey レイアウトカテゴリキー
 * @param {String} itemKey レイアウト項目キー
 * @param {Object} doctorList 指示者候補を格納したオブジェクト
 * @returns {Object} { width, editable, editor }
 */
const getKendoDisplayPropertyIndUser = (
  categoryKey,
  itemKey,
  doctorList
) => {
  // デフォルト属性値
  const width = 200;
  const editable = (dataItem) => {
    return (dataItem.pat_unique$physical_info$target_weight_chkbox || dataItem.pat_unique$physical_info$dw) &&
      getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card');
  };
  let editor;
  let headerAttributes;
  let headerTemplates;
  // グリッド内で改行許容
  const encoded = true;

  // 属性を変更したい項目を対応するカテゴリ-項目以下に定義する
  editor = editorDropDown(
    doctorList,
    categoryKey,
    itemKey,
    false,
    "userId",
    "userName"
  );
  headerAttributes = getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card') ? null : { class: "k-header-disabled" };

  if (getAuthorized('PatInfo', 'default_authority') && getAuthorized('PatInfo', 'item_physical_info_card')) {
    headerTemplates = toKendoTemplate("<div class='userCategory multi-pat-header-row'><label for='user-category'>指示者</label><div id='user-category'/></div></div>");
  }
  return new KendoDisplayProperty(
    width,
    editable,
    editor,
    headerAttributes,
    headerTemplates,
    encoded
  );
};

/**
 * @description kendo-gridオブジェクトに必要なプロパティをマップ
 * @param {Object} column kendo-gridオブジェクト
 * @param {String} categoryKey レイアウトカテゴリキー
 * @param {String} itemKey レイアウト項目キー
 * @param {Object} mstList 必要なマスタを全て格納したオブジェクト
 */
export const mapKendoDisplayProperty = (
  column,
  categoryKey,
  itemKey,
  mstList,
  tmpEventBusObj
) => {
  const props = getKendoDisplayProperty(categoryKey, itemKey, mstList, tmpEventBusObj);
  return { ...column, ...props };
};

/**
 * @description kendo-gridオブジェクトに必要なプロパティをマップ(指示者用)
 * @param {Object} column kendo-gridオブジェクト
 * @param {String} categoryKey レイアウトカテゴリキー
 * @param {String} itemKey レイアウト項目キー
 * @param {Object} doctorList 指示者候補を格納したオブジェクト
 * @param {Object} selectDoctor 指示者選択なし時にデフォルトで選択するユーザID
 */
export const mapKendoDisplayPropertyIndUser = (
  column,
  categoryKey,
  itemKey,
  doctorList,
  selectDoctor
) => {
  const props = getKendoDisplayPropertyIndUser(categoryKey, itemKey, doctorList, selectDoctor);
  return { ...column, ...props };
};

/**
 * @description 更新対象のfieldかどうか
 * @param {String} field
 * @returns {Boolean}
 */
export const isNoUpdateField = field => {
  return NO_UPDDATE_FIELD_SUFFIX_LIST.some(suffix =>
    field.includes(suffix)
  );
};

/**
 * @description 更新用に編集値を変換
 * @param {String} table テーブル名
 * @param {String} column カラム名
 * @param {String} jsonKey JSONキー名
 * @param {any} value 変換する値
 * @returns {any} 変換後の値
 */
export const convertToUpdateValue = (table, column, jsonKey, value) => {
  switch (table) {
    case "pat_personal_main":
      switch (column) {
        case LAYOUT_ITEM_BASICINFO_BIRTHDAY.key:
          value = dayjs(value, "YYYY/MM/DD").format("YYYYMMDD");
          break;
        case "json":
          switch (jsonKey) {
            default:
              break;
          }
      }
      break;
    case "pat_main":
      break;
    case "pat_unique":
      switch (column) {
        case LAYOUT_CATEGORY_PHYSICAL_INFO.key:
          switch (jsonKey) {
            case LAYOUT_ITEM_INDICATOR_START_DATE.key:
              value = dayjs(value, "YYYY/MM/DD").format("YYYYMMDD");
              break;
          }
          break;
      }
      break;
  }

  return value;
};

// デシリアライズ対象のJSONカラム名
const JSON_COLUMNS_PAT_PERSONAL = [
  "pat_contact_info",
  "other_contact_info",
  "vendor_contact_info",
  "dial_diff_com_info"
];
const JSON_COLUMNS_PAT_MAIN = [
  "pat_memo_info",
  "charge_staff_info",
  "taboo_allergy_info",
  "infect_info",
  // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
  "pat_group_info",
  "addition_info",
  // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
  "implant_info",
  "medical_care_info",
  "acceptance_status_info"
];
const JSON_COLUMNS_PAT_UNIQUE = [
  "medical_hst_info",
  "in_out_visit_history_info",
  "physical_info"
];
// add データリストの患者情報修正 陳 start
const JSON_COLUMNS_ORD_MAINS = [
  "rstWeightInfo"
];
// add データリストの患者情報修正 陳 end

/**
 * @description マルチ患者取得
 * @param {Array} patIdList 患者一覧のpat_id配列
 * @returns {Array} 患者情報オブジェクト配列({ pat_personal_main, pat_main, pat_unique })
 */
export const getPatRecords = async patIdList => {
  if (!patIdList.length) {
    return [];
  }
  const uri = "/patInfo/getPatByIdList/" + "2";
  const { data: rawPatInfo } = await ApiHelper.post(uri, { patIdList }).catch(
    () => {
      throw new Error(`[マルチ患者情報] API: ${uri}の実行に失敗しました。`);
    }
  );
  const deserializedPatInfo = {
    // 取得直後はJSONなのでデシリアライズ
    pat_personal_main: JSON.parse(rawPatInfo.pat_personal_main),
    pat_main: JSON.parse(rawPatInfo.pat_main),
    pat_unique: JSON.parse(rawPatInfo.pat_unique),
    // add データリストの患者情報修正 陳 start
    ord_mains: JSON.parse(rawPatInfo.ord_main)
    // add データリストの患者情報修正 陳 end
  };
  // これを→{ pat_personal_main: [pat1, ...], pat_main: [pat1, ...], pat_unique: [pat1, ...] }
  // こうする→[(pat1:){ pat_personal_main, pat_main, pat_unique }, ...]
  const patList = patIdList.map(id => {
    const pat_personal_main = deserializedPatInfo.pat_personal_main.find(
      el => el.pat_id === id
    );
    const pat_main = deserializedPatInfo.pat_main.find(el => el.pat_id === id);
    const pat_unique = deserializedPatInfo.pat_unique.find(
      el => el.pat_id === id
    );
    // add データリストの患者情報修正 陳 start
    const ord_mains = [];
    deserializedPatInfo.ord_mains.forEach(el => {
      if (el.patId === id) {
        ord_mains.push(deserializeJsonColumn(el, JSON_COLUMNS_ORD_MAINS))
      }
    });
    // add データリストの患者情報修正 陳 end
    return {
      // JSONカラムはデシリアライズ
      pat_personal_main: deserializeJsonColumn(
        pat_personal_main,
        JSON_COLUMNS_PAT_PERSONAL
      ),
      pat_main: deserializeJsonColumn(pat_main, JSON_COLUMNS_PAT_MAIN),
      pat_unique: deserializeJsonColumn(pat_unique, JSON_COLUMNS_PAT_UNIQUE),
      // add データリストの患者情報修正 陳 start
      ord_mains: ord_mains
      // add データリストの患者情報修正 陳 end
    };
  });
  return patList;
};

/**
 * @description マルチ患者更新
 * @param {Array} patRecords 患者情報オブジェクト配列({ pat_personal_main, pat_main, pat_unique })
 */
export const updatePatRecords = async patRecords => {
  const uri = "/patInfo/updatePatByList";
  const patRecordsJson = patRecords.map(record => {
    return {
      pat_id: `${record.pat_personal_main.pat_id}`,
      save_physical_item: JSON.stringify(record.save_physical_item),
      // dw_edit_mode: record.dw_edit_mode,
      dw_log_info: JSON.stringify(record.dw_log_info),
      pat_personal_main: JSON.stringify(
        serializeJsonColumn(record.pat_personal_main, JSON_COLUMNS_PAT_PERSONAL)
      ),
      pat_main: JSON.stringify(
        serializeJsonColumn(record.pat_main, JSON_COLUMNS_PAT_MAIN)
      ),
      pat_unique: JSON.stringify(
        serializeJsonColumn(record.pat_unique, JSON_COLUMNS_PAT_UNIQUE)
      ),
      is_changed_next_pat_info: JSON.stringify(
        Object.prototype.hasOwnProperty.call(record, "is_changed_next_pat_info")
          ? record.is_changed_next_pat_info
          : false
      )
    };
  });

  await ApiHelper.put(uri, patRecordsJson).catch(() => {
    throw new Error(`[マルチ患者情報] API: ${uri} 患者更新に失敗しました。`);
  });
};

/**
 * @description マスタコード→名称変換
 * @param {Array} mst 対象のマスタオブジェクト配列
 * @param {Number} code 変換するコード
 * @param {String} codeString マスタオブジェクトのコードのキー名
 * @param {String} nameString マスタオブジェクトの名称のキー名
 * @returns {String} マスタ名称 ※コードがnull: '未登録'、コードがマスタに存在しない: '不明'
 */
const mstCodeToName = (mst, code, codeString = "code", nameString = "name") => {
  if (code === null) {
    return "未登録";
  }

  // mod データリスト表示不正について、対応する。 dengshen start
  // const target = mst.find(el => el[codeString] === code);
  const target = mst.find(el => el[codeString] == code);
  // mod データリスト表示不正について、対応する。 dengshen end
  if (!target) {
    return "不明";
  }
  return target[nameString];
};
/*add FNSI-改修内容5237 任 start*/
const mstCodeToNameImplant = (mst, mst_del,code, codeString = "code", nameString = "name") => {
  if (code === null) {
    return "未登録";
  }

  const target = mst.find(el => el[codeString] === code);
  if (!target) {
    if (mst_del && mst_del.data) {
      const targetDel = mst_del.data.find(el => el[codeString] === code);
      if (!targetDel) {
        return "不明";
      } else {
        return MASTER_DELETE_DISPLAY.DELETED + targetDel[nameString];
      }
    } else {
      return "";
    }
  }
  return target[nameString];
};

const mstDecimal = (value,length) => {
  if (!value) {
    return "";
  }
  let resultFigure;
  let num = '1';
  for(let i = 0;i<length;i++){
    num += '0';
  }
  let f_x = Math.round(value * parseInt(num)) / parseInt(num);
  let s_x = f_x.toString();
  let pos_decimal = s_x.indexOf('.');
  if (pos_decimal < 0) {
    pos_decimal = s_x.length;
    s_x += '.';
  }
  while (s_x.length <= pos_decimal + length) {
    s_x += '0';
  }
  resultFigure = s_x;
  return resultFigure;
};
/*add FNSI-改修内容5237 任 end*/

// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
/**
 * @description 誕生日から算出した年齢
 */
const age = (birthday) => {
  const age = dayjs().diff(birthday, "years");
  return age > 0 ? age : "不明";
};
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end

export const isSingleColumnCategory = categoryKey => {
  const singleColumnCategories = [
    LAYOUT_CATEGORY_DIFFICULTY_MAIN.key,
    LAYOUT_CATEGORY_DIFFICULTY_OTHER.key,
    LAYOUT_CATEGORY_SEVERITY.key,
    LAYOUT_CATEGORY_TRANSPORT.key,
    LAYOUT_CATEGORY_IMPLANT_INFO.key,
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
    LAYOUT_CATEGORY_ADDITION.key,
    LAYOUT_CATEGORY_PATIENT_GROUP.key
    // add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
  ];
  return singleColumnCategories.includes(categoryKey);
};

export const isIndUserColumn = itemKey => {
  const indUserColumns = [
    LAYOUT_ITEM_INDICATOR_CDNAME.key
  ];
  return indUserColumns.includes(itemKey);
};

/**
 * @description マスタを取得
 * @param {String} facilityCd 施設コード
 * @returns {Object} { <マスタ名>: <マスタオブジェクト配列> }
 */
export const getMstLayout = async facilityCd => {
  // データリストレイアウトマスタ取得
  const mst_layout = await patListLayout(facilityCd);

  // レイアウトマスタの表示項目デシリアライズ
  mst_layout.forEach(el => {
    el.dispItemInfo = JSON.parse(el.dispItemInfo);
    return el;
  });
  
  return { mst_layout };
};

/**
 * @description ユーザーの職種で表示設定ONのデータリストレイアウトマスタを抽出
 * @param {String} userJobCd 職種コード
 * @param {Object} layoutList データリストレイアウトマスタ
 * @returns {Object} 職種でフィルタ後のデータリストレイアウトマスタ
 */
export const filterLayoutMstByJob = (userJobCd, layoutList) => {
  const _jobCd = parseInt(userJobCd);
  // NOTE: データリストレイアウトマスタの職種（occupations）は、「-1：未登録」としている
  const jobCd = isNaN(_jobCd) ? -1 : _jobCd;
  
  let layoutMst = layoutList
    .filter(item => !!item.occupations)
    .map(item => {
      item.occupations = JSON.parse(item.occupations);
      return item;
    });

  if (layoutMst.length > 0) {
    layoutMst = layoutMst.filter(item => item.occupations.includes(jobCd));
  } else {
    layoutMst = null;
  }

  return layoutMst;
}

/**
 * 患者情報1で変更がある場合のみ破棄確認を表示し、結果を返す
 * @returns {Promise<number>} 0: Cancel, 1: OK or 変更なし
 */
export const confirmAllowDiscardChangesInMultiPatList = async () => {
  const isDataChanged = store.getters["data-list/getIsDataChanged"];
  const title = DIALOG_MESSAGES[13000004].title;
  const message = messageFormat(DIALOG_MESSAGES[13000004].message);

  // 変更なしなら破棄確認を出さず 1 を返す
  if (!isDataChanged) {
    return 1;
  }

  const answer = await showConfirmDialog({ title, message });
  if (answer === 1) {
    await store.dispatch("data-list/setIsDataChanged", false);  // 変更フラグ クリア
  }
  return answer;
}

