class LogReference {
  /**
   * @constructor
   * @param {String} title カテゴリ名
   * @param {String} key カテゴリキー
   */
  constructor(title, key) {
    this.title = title;
    this.key = key;
  }
}
export const LOG_REFERENCE_DATE = new LogReference(
  "日時",
  "date"
);
export const LOG_REFERENCE_LOG_TYPE = new LogReference(
  "ログ種別",
  "logType"
);
export const LOG_REFERENCE_IP = new LogReference(
  "クライアントIP",
  "clientIp"
);
export const LOG_REFERENCE_FUNC_ID = new LogReference(
  "機能名",
  "functionName"
);
export const LOG_REFERENCE_PAT_ID = new LogReference(
  "内部患者ID",
  "patId"
);
export const LOG_REFERENCE_GENERAL_PAT_ID = new LogReference(
  "患者ID",
  "hospPatId"
);
export const LOG_REFERENCE_PAT_NAME = new LogReference(
  "患者名",
  "patName"
);
export const LOG_REFERENCE_SQL = new LogReference(
  "SQL名",
  "sqlIdentification"
);
export const LOG_REFERENCE_LOG_MESSAGE = new LogReference(
  "ログ内容",
  "logMessage"
);
export const LOG_REFERENCE_SUPPORT_MESSAGE = new LogReference(
  "対応内容",
  "supportMessage"
);
export const LOG_REFERENCE_USER_ID = new LogReference(
  "利用者ID",
  "userId"
);
export const LOG_REFERENCE_USER_NAME = new LogReference(
  "利用者名",
  "userName"
);
export const LOG_REFERENCE_SESSION_ID = new LogReference(
  "セッションID",
  "sessionId"
);
export const LOG_REFERENCE_DEVICE_NO = new LogReference(
  "デバイスエッジNo",
  "deviceEdgeNo"
);
export const LOG_REFERENCE_DEVICE_SERIAL = new LogReference(
  "デバイスエッジ製造番号",
  "deviceEdgeSerialNo"
);
export const LOG_REFERENCE_MACHINE_TYPE = new LogReference(
  "型式",
  "machineType"
);
export const LOG_REFERENCE_MACHINE_CD = new LogReference(
  "型式コード",
  "machineTypeCd"
);
export const LOG_REFERENCE_EC2 = new LogReference(
  "EC2識別",
  "ec2Identification"
);
export const LOG_REFERENCE_SERVICE_NAME = new LogReference(
  "サービス名",
  "serviceName"
);
export const LOG_REFERENCE_USER = new LogReference(
  "利用者",
  "user"
);
export const LOG_REFERENCE_MODULE_NAME = new LogReference(
  "モジュール名",
  // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm start
  // "moduleName"
  "serviceName"
  // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm end
);
// add FNSI-ログ保存場所の追加 関 start
export const LOG_REFERENCE_FILE_URL = new LogReference(
  "ログ保存場所",
  "fileUrl"
);
// end FNSI-ログ保存場所の追加 関 start

export const LOG_REFERENCE_FACILITY_NAME = new LogReference(
  "施設名",
  "facilityName"
);
export const LOG_REFERENCE_INTERNAL_USER = new LogReference(
  "内部利用者ID",
  // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm start
  // "username"
  "userId"
  // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm end
);
export const LOG_REFERENCE_TITLES = {
  [LOG_REFERENCE_DATE.key]: LOG_REFERENCE_DATE.title,
  [LOG_REFERENCE_LOG_TYPE.key]: LOG_REFERENCE_LOG_TYPE.title,
  [LOG_REFERENCE_IP.key]: LOG_REFERENCE_IP.title,
  [LOG_REFERENCE_FUNC_ID.key]: LOG_REFERENCE_FUNC_ID.title,
  [LOG_REFERENCE_PAT_ID.key]: LOG_REFERENCE_PAT_ID.title,
  [LOG_REFERENCE_GENERAL_PAT_ID.key]: LOG_REFERENCE_GENERAL_PAT_ID.title,
  [LOG_REFERENCE_PAT_NAME.key]: LOG_REFERENCE_PAT_NAME.title,
  [LOG_REFERENCE_SQL.key]: LOG_REFERENCE_SQL.title,
  [LOG_REFERENCE_LOG_MESSAGE.key]: LOG_REFERENCE_LOG_MESSAGE.title,
  [LOG_REFERENCE_SUPPORT_MESSAGE.key]: LOG_REFERENCE_SUPPORT_MESSAGE.title,
  [LOG_REFERENCE_USER_ID.key]: LOG_REFERENCE_USER_ID.title,
  [LOG_REFERENCE_USER_NAME.key]: LOG_REFERENCE_USER_NAME.title,
  [LOG_REFERENCE_SESSION_ID.key]: LOG_REFERENCE_SESSION_ID.title,
  [LOG_REFERENCE_DEVICE_NO.key]: LOG_REFERENCE_DEVICE_NO.title,
  [LOG_REFERENCE_DEVICE_SERIAL.key]: LOG_REFERENCE_DEVICE_SERIAL.title,
  [LOG_REFERENCE_MACHINE_TYPE.key]: LOG_REFERENCE_MACHINE_TYPE.title,
  [LOG_REFERENCE_MACHINE_CD.key]: LOG_REFERENCE_MACHINE_CD.title,
  [LOG_REFERENCE_EC2.key]: LOG_REFERENCE_EC2.title,
  [LOG_REFERENCE_SERVICE_NAME.key]: LOG_REFERENCE_SERVICE_NAME.title,
  [LOG_REFERENCE_USER.key]: LOG_REFERENCE_USER.title,
  [LOG_REFERENCE_MODULE_NAME.key]: LOG_REFERENCE_MODULE_NAME.title,
  // add FNSI-ログ保存場所の追加 関 start
  [LOG_REFERENCE_FILE_URL.key]: LOG_REFERENCE_FILE_URL.title,
  // add FNSI-ログ保存場所の追加 関 end
}