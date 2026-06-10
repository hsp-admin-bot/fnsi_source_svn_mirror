/**
 * ログメッセージ情報を表現するクラス
 */
export class LogMessage {
  /**
    * コンストラクタ
    * 
    * 以下の項目はサーバ側にて設定します.
    *  ・施設コード : サインインしているユーザが属している施設
    *  ・利用者ID : サインインしているユーザID
    *  ・クライアントIP : 接続元のIP（Javascriptでは取得出来ない為,HttpServletRequestから取得）
    *  ・セッションID : サーバ側で管理しているセッションIDを設定
    *  ・SQL名 : 必要に応じてサーバ側で設定
    */
  constructor(
    deviceEdgeNo,
    deviceEdgeSerialNo,
    machineType,
    machineTypeCd,
    serviceName,
    functionCd,
    patId,
    logMessage,
    supportMessage
  ) {
    this.deviceEdgeNo = deviceEdgeNo;
    this.deviceEdgeSerialNo = deviceEdgeSerialNo;
    this.machineType = machineType;
    this.machineTypeCd = machineTypeCd;
    this.serviceName = serviceName;
    this.functionCd = functionCd;
    this.patId = patId;
    this.logMessage = logMessage;
    this.supportMessage = supportMessage;
  }
}
