import { LOG_REFERENCE_DATE, LOG_REFERENCE_DEVICE_NO, LOG_REFERENCE_DEVICE_SERIAL, LOG_REFERENCE_EC2, LOG_REFERENCE_FACILITY_NAME, LOG_REFERENCE_FUNC_ID, LOG_REFERENCE_GENERAL_PAT_ID, LOG_REFERENCE_INTERNAL_USER, LOG_REFERENCE_IP, LOG_REFERENCE_LOG_MESSAGE, LOG_REFERENCE_LOG_TYPE, LOG_REFERENCE_MACHINE_CD, LOG_REFERENCE_MACHINE_TYPE, LOG_REFERENCE_MODULE_NAME, LOG_REFERENCE_PAT_ID, LOG_REFERENCE_PAT_NAME, LOG_REFERENCE_SESSION_ID, LOG_REFERENCE_SUPPORT_MESSAGE, LOG_REFERENCE_TITLES, LOG_REFERENCE_USER } from "@/components/view-log/Definitions.js";
import customKendoFilter from "@/components/common/custom-form-tags/CustomKendoFilter";
export const createKendoColumns = (columns, displayColumns) => {
  return columns.map(({ cd, key }) => {
    return {
      editable: false,
      field: key,
      format: "",
      hidden: !displayColumns.find(col => col.cd.toString() === cd.toString()),
      title: LOG_REFERENCE_TITLES[key],
      width: "100px",
      filterCell: customKendoFilter
    };
  });
};
export const createColumns = (isMasterUser) => {
  const defaultCol = [
    { cd: 1, key: LOG_REFERENCE_DATE.key, name: LOG_REFERENCE_DATE.title, class1: "", class2: "" },
    { cd: 2, key: LOG_REFERENCE_IP.key, name: LOG_REFERENCE_IP.title, class1: "", class2: "" },
    { cd: 5, key: LOG_REFERENCE_FUNC_ID.key, name: LOG_REFERENCE_FUNC_ID.title, class1: "", class2: "" },
    { cd: 18, key: LOG_REFERENCE_USER.key, name: LOG_REFERENCE_USER.title, class1: "", class2: "" },
    { cd: 19, key: LOG_REFERENCE_GENERAL_PAT_ID.key, name: LOG_REFERENCE_GENERAL_PAT_ID.title, class1: "", class2: "" },
    { cd: 20, key: LOG_REFERENCE_PAT_NAME.key, name: LOG_REFERENCE_PAT_NAME.title, class1: "", class2: "" },
    { cd: 6, key: LOG_REFERENCE_LOG_MESSAGE.key, name: LOG_REFERENCE_LOG_MESSAGE.title, class1: "", class2: "" },
    { cd: 9, key: LOG_REFERENCE_SUPPORT_MESSAGE.key, name: LOG_REFERENCE_SUPPORT_MESSAGE.title, class1: "", class2: "" },
    // del FNSI-mongoDBに挿入、検索できることの対応 柏 start
    // add FNSI-ログ保存場所の追加 関 start
    // { cd: 21, key: LOG_REFERENCE_FILE_URL.key, name: LOG_REFERENCE_FILE_URL.title, class1: "", class2: "" },
    // add FNSI-ログ保存場所の追加 関 end
    // { cd: 22, key: LOG_REFERENCE_USER_NAME.key, name: LOG_REFERENCE_USER_NAME.title, class1: "", class2: "" },
    // del mongoDBに挿入、検索できることの対応 柏 end
  ];
  const advanceCol = [
    { cd: 1, key: LOG_REFERENCE_DATE.key, name: LOG_REFERENCE_DATE.title, class1: "", class2: "" },
    { cd: 2, key: LOG_REFERENCE_IP.key, name: LOG_REFERENCE_IP.title, class1: "", class2: "" },
    { cd: 11, key: LOG_REFERENCE_SESSION_ID.key, name: LOG_REFERENCE_SESSION_ID.title, class1: "", class2: "" },
    { cd: 21, key: LOG_REFERENCE_MODULE_NAME.key, name: LOG_REFERENCE_MODULE_NAME.title, class1: "", class2: "" },
    { cd: 5, key: LOG_REFERENCE_FUNC_ID.key, name: LOG_REFERENCE_FUNC_ID.title, class1: "", class2: "" },
    { cd: 18, key: LOG_REFERENCE_USER.key, name: LOG_REFERENCE_USER.title, class1: "", class2: "" },
    { cd: 7, key: LOG_REFERENCE_PAT_ID.key, name: LOG_REFERENCE_PAT_ID.title, class1: "", class2: "" },
    { cd: 19, key: LOG_REFERENCE_GENERAL_PAT_ID.key, name: LOG_REFERENCE_GENERAL_PAT_ID.title, class1: "", class2: "" },
    { cd: 20, key: LOG_REFERENCE_PAT_NAME.key, name: LOG_REFERENCE_PAT_NAME.title, class1: "", class2: "" },
    { cd: 6, key: LOG_REFERENCE_LOG_MESSAGE.key, name: LOG_REFERENCE_LOG_MESSAGE.title, class1: "", class2: "" },
    { cd: 9, key: LOG_REFERENCE_SUPPORT_MESSAGE.key, name: LOG_REFERENCE_SUPPORT_MESSAGE.title, class1: "", class2: "" },
    { cd: 10, key: LOG_REFERENCE_LOG_TYPE.key, name: LOG_REFERENCE_LOG_TYPE.title, class1: "", class2: "" },
    { cd: 12, key: LOG_REFERENCE_DEVICE_NO.key, name: LOG_REFERENCE_DEVICE_NO.title, class1: "", class2: "" },
    { cd: 13, key: LOG_REFERENCE_DEVICE_SERIAL.key, name: LOG_REFERENCE_DEVICE_SERIAL.title, class1: "", class2: "" },
    { cd: 14, key: LOG_REFERENCE_MACHINE_TYPE.key, name: LOG_REFERENCE_MACHINE_TYPE.title, class1: "", class2: "" },
    { cd: 15, key: LOG_REFERENCE_MACHINE_CD.key, name: LOG_REFERENCE_MACHINE_CD.title, class1: "", class2: "" },
    { cd: 16, key: LOG_REFERENCE_EC2.key, name: LOG_REFERENCE_EC2.title, class1: "", class2: "" },
    // del FNSI-mongoDBに挿入、検索できることの対応 柏 start
    // add FNSI-ログ保存場所の追加 関 start
    // { cd: 21, key: LOG_REFERENCE_FILE_URL.key, name: LOG_REFERENCE_FILE_URL.title, class1: "", class2: "" },
    // add FNSI-ログ保存場所の追加 関 end
    // { cd: 22, key: LOG_REFERENCE_USER_NAME.key, name: LOG_REFERENCE_USER_NAME.title, class1: "", class2: "" },
    // del FNSI-mongoDBに挿入、検索できることの対応 柏 end
    { cd: 23, key: LOG_REFERENCE_FACILITY_NAME.key, name: LOG_REFERENCE_FACILITY_NAME.title, class1: "", class2: "" },
    { cd: 24, key: LOG_REFERENCE_INTERNAL_USER.key, name: LOG_REFERENCE_INTERNAL_USER.title, class1: "", class2: "" },
  ];
  return isMasterUser ? advanceCol : defaultCol;
};
export const createDisplayColumns = (isMasterUser) => {
  const defaultList = [
    { cd: 1, key: LOG_REFERENCE_DATE.key, name: LOG_REFERENCE_DATE.title, class1: "", class2: "" },
    { cd: 2, key: LOG_REFERENCE_IP.key, name: LOG_REFERENCE_IP.title, class1: "", class2: "" },
    { cd: 5, key: LOG_REFERENCE_FUNC_ID.key, name: LOG_REFERENCE_FUNC_ID.title, class1: "", class2: "" },
    { cd: 18, key: LOG_REFERENCE_USER.key, name: LOG_REFERENCE_USER.title, class1: "", class2: "" },
    { cd: 19, key: LOG_REFERENCE_GENERAL_PAT_ID.key, name: LOG_REFERENCE_GENERAL_PAT_ID.title, class1: "", class2: "" },
    { cd: 20, key: LOG_REFERENCE_PAT_NAME.key, name: LOG_REFERENCE_PAT_NAME.title, class1: "", class2: "" },
    { cd: 6, key: LOG_REFERENCE_LOG_MESSAGE.key, name: LOG_REFERENCE_LOG_MESSAGE.title, class1: "", class2: "" },
    { cd: 9, key: LOG_REFERENCE_SUPPORT_MESSAGE.key, name: LOG_REFERENCE_SUPPORT_MESSAGE.title, class1: "", class2: "" },
    // del FNSI-mongoDBに挿入、検索できることの対応 柏 start
    // add FNSI-ログ保存場所の追加 関 start
    // { cd: 21, key: LOG_REFERENCE_FILE_URL.key, name: LOG_REFERENCE_FILE_URL.title, class1: "", class2: "" },
     // add FNSI-ログ保存場所の追加 関 end
    // { cd: 22, key: LOG_REFERENCE_USER_NAME.key, name: LOG_REFERENCE_USER_NAME.title, class1: "", class2: "" },
    // del FNSI-mongoDBに挿入、検索できることの対応 柏 end
  ];
  const masterList = [
    { cd: 1, key: LOG_REFERENCE_DATE.key, name: LOG_REFERENCE_DATE.title, class1: "", class2: "" },
    { cd: 2, key: LOG_REFERENCE_IP.key, name: LOG_REFERENCE_IP.title, class1: "", class2: "" },
    { cd: 11, key: LOG_REFERENCE_SESSION_ID.key, name: LOG_REFERENCE_SESSION_ID.title, class1: "", class2: "" },
    { cd: 21, key: LOG_REFERENCE_MODULE_NAME.key, name: LOG_REFERENCE_MODULE_NAME.title, class1: "", class2: "" },
    { cd: 5, key: LOG_REFERENCE_FUNC_ID.key, name: LOG_REFERENCE_FUNC_ID.title, class1: "", class2: "" },
    { cd: 18, key: LOG_REFERENCE_USER.key, name: LOG_REFERENCE_USER.title, class1: "", class2: "" },
    { cd: 7, key: LOG_REFERENCE_PAT_ID.key, name: LOG_REFERENCE_PAT_ID.title, class1: "", class2: "" },
    { cd: 19, key: LOG_REFERENCE_GENERAL_PAT_ID.key, name: LOG_REFERENCE_GENERAL_PAT_ID.title, class1: "", class2: "" },
    { cd: 20, key: LOG_REFERENCE_PAT_NAME.key, name: LOG_REFERENCE_PAT_NAME.title, class1: "", class2: "" },
    { cd: 6, key: LOG_REFERENCE_LOG_MESSAGE.key, name: LOG_REFERENCE_LOG_MESSAGE.title, class1: "", class2: "" },
    { cd: 9, key: LOG_REFERENCE_SUPPORT_MESSAGE.key, name: LOG_REFERENCE_SUPPORT_MESSAGE.title, class1: "", class2: "" },
    { cd: 10, key: LOG_REFERENCE_LOG_TYPE.key, name: LOG_REFERENCE_LOG_TYPE.title, class1: "", class2: "" },
    // del FNSI-mongoDBに挿入、検索できることの対応 柏 start
    // add FNSI-ログ保存場所の追加 関 start
    // { cd: 21, key: LOG_REFERENCE_FILE_URL.key, name: LOG_REFERENCE_FILE_URL.title, class1: "", class2: "" },
    // add FNSI-ログ保存場所の追加 関 end
    // { cd: 22, key: LOG_REFERENCE_USER_NAME.key, name: LOG_REFERENCE_USER_NAME.title, class1: "", class2: "" },
    // del FNSI-mongoDBに挿入、検索できることの対応 柏 end
    { cd: 23, key: LOG_REFERENCE_FACILITY_NAME.key, name: LOG_REFERENCE_FACILITY_NAME.title, class1: "", class2: "" },
    { cd: 24, key: LOG_REFERENCE_INTERNAL_USER.key, name: LOG_REFERENCE_INTERNAL_USER.title, class1: "", class2: "" },
  ]
  return isMasterUser ? masterList : defaultList;
};
