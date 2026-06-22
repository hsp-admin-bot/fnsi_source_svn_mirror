/**
 * 利用者権限コード定義
 */
export const AUTHORITY_CODES = {
  // 施設-代行編集
  FCL_PEDIT: "012",
  // 施設-編集
  FCL_EDIT: "013",

  // 患者情報-閲覧
  PAT_VIEW: "021",
  // 患者情報-代行編集
  PAT_PEDIT: "022",
  // 患者情報-編集
  PAT_EDIT: "023",

  // 患者イベント-閲覧
  PAT_EVENT_VIEW: "031",
  // 患者イベント-代行編集
  PAT_EVENT_PEDIT: "032",
  // 患者イベント-編集
  PAT_EVENT_EDIT: "033",

  // 患者別装置設定-閲覧
  PAT_DEVSET_VIEW: "041",
  // 患者別装置設定-代行編集
  PAT_DEVSET_PEDIT: "042",
  // 患者別装置設定-編集
  PAT_DEVSET_EDIT: "043",

  // 治療指示-閲覧
  IND_VIEW: "051",
  // 治療指示-代行編集
  IND_PEDIT: "052",
  // 治療指示-編集
  IND_EDIT: "053",

  // 治療指示受け・承認-閲覧
  IND_RECEIVE_VIEW: "061",
  // 治療指示受け・承認-代行編集
  IND_RECEIVE_PEDIT: "062",
  // 治療指示受け・承認-編集
  IND_RECEIVE_EDIT: "063",

  // 検査・一般撮影指示-閲覧
  IND_EXAM_VIEW: "071",
  // 検査・一般撮影指示-代行編集
  IND_EXAM_PEDIT: "072",
  // 検査・一般撮影指示-編集
  IND_EXAM_EDIT: "073",

  // 処方-閲覧
  PRESCRIPTION_VIEW: "081",
  // 処方-代行編集
  PRESCRIPTION_PEDIT: "082",
  // 処方-編集
  PRESCRIPTION_EDIT: "083",

  // 治療記録-閲覧
  RST_VIEW: "091",
  // 治療記録-代行編集
  RST_PEDIT: "092",
  // 治療記録-編集
  RST_EDIT: "093",

  // 検査結果-閲覧
  RST_EXAM_VIEW: "101",
  // 検査結果-代行編集s
  RST_EXAM_PEDIT: "102",
  // 検査結果-編集
  RST_EXAM_EDIT: "103",

  // 機器保守-閲覧
  DEV_VIEW: "111",
  // 機器保守-代行編集
  DEV_PEDIT: "112",
  // 機器保守-編集
  DEV_EDIT: "113",

  // add FNSI 権限 start -- Sanjingye Sun 20201228
  // スケジュール - 移動
  SCHE_MOVE: "133",
  // add FNSI 権限 end -- Sanjingye Sun 20201228

  // 患者削除
  DEL_PAT: "991",
  //患者イベント削除
  DEL_PAT_EVENT: "992",
  //治療実績削除
  DEL_RST: "993",
  // 検査結果削除
  DEL_EXAM: "994",
  //処方箋削除
  DEL_PRESCRIPTION: "995",
  // 施設-閲覧
  FCL_VIEW: "011",
  // mod #12462 患者情報共有 関 start
  // 患者共有
  PATIENT_SHARE: "143",
  // mod #12462 患者情報共有 関 end
};
