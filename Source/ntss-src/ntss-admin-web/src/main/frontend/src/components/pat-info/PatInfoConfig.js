export const PAT_CARD_LIST = {
  uriSameHospId: `/patInfo/getSameHospPatIdCnt`,
  uriSameName: `/patInfo/getSameNamePatInfoList`,
  uriUpdateIsSame: `/patInfo/updateIsSame`,
  urigetFacilitySettingValue: `/facilitySetting/getFacilitySettingValue`,
  urigetFacilityList: `/patInfo/getFacilityList`,
  urigetNewPatFacility: `/patInfo/getNewPatFacility`
}

export const PAT_HEADER = {
  // 禁忌・アレルギー区分定数
  CLASS_TABOO: "1",               // 禁忌
  CLASS_ALLERGY: "2",             // アレルギー

  // 禁忌・アレルギー詳細区分定数
  CLASS_MEDICINE: "1",            // 薬剤
  // add 9987 by kangjie 20231215 start
  CLASS_MEDICINMIX:"2",           // 調製薬剤
  // add 9987 by kangjie 20231215 end
  CLASS_EQUIPMENT: "3",           // 医療材料
  CLASS_DIALYZER: "4",            // ダイアライザ
  CLASS_GENERIC_MEDICINE: "6",    // 一般名処方
  CLASS_FREEWORD: "5",            // フリーワード

  DELETED: "【削除済み】"
}

export const MENU_BAR = {
  uriDeletePatInfo: `/patInfo/deletePatInfo`,
  uriCopyPatInfo: `/patInfo/copyPatInfo`,
  uriGetCardAppPort: `/card_state/get_card_app_ports`
}

export const CREATE_CONTENT = {
  JSON_EMPTY_ARRAY: "[]"
}
