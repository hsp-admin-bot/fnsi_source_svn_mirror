package jp.co.nikkiso.ntss.core.logger;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;
@Getter
@Setter
public class EventLogAPI {

	/** * 日付 */
	private Date date;

	/** * ログタイプ */
	private String logType;

	/** * 施設コード */
	private String facilityCd;

	/** * 利用者ID */
	private String userId;

	/** * クライアントIP */
	private String clientIp;

	/** * セッションID */
	private String sessionId;

	/** * デバイスエッジNo */
	private String deviceEdgeNo;

	/** * デバイスエッジ製造番号 */
	private String deviceEdgeSerialNo;

	/** * 型式 */
	private String machineType;

	/** * 型式コード */
	private String machineTypeCd;

	/** * EC2識別 */
	private String ec2Identification;

	/** * サービス名 */
	private String serviceName;

	/** * 機能コード */
	private String functionCd;

	/** * 内部患者ID */
	private String patId;

	/** * SQL名 */
	private String sqlIdentification;

	/** * ログ内容 */
	private String logMessage;

	/** * 対応内容 */
	private String supportMessage;

	/** * 院内表示用の患者ID */
	private String patName;

	/** * 患者名 */
	private String hospPatId;

	//update FNSI-mongoDBに挿入、検索できることの対応 start
	private String facilityName;
	private String functionName;
	private String user;
	//update FNSI-mongoDBに挿入、検索できることの対応 end
  // add FNSI-ログ保存場所の追加 関 start
	private String fileUrl;

  // add FNSI-ログ保存場所の追加 関 end
	public EventLogAPI(Date date, String logType, String facilityCd, String userId, String clientIp, String sessionId,
			String deviceEdgeNo, String deviceEdgeSerialNo, String machineType, String machineTypeCd,
			String ec2Identification, String serviceName, String functionCd, String patId, String sqlIdentification,
			String logMessage, String supportMessage) {
		super();
		this.date = date;
		this.logType = logType;
		this.facilityCd = facilityCd;
		this.userId = userId;
		this.clientIp = clientIp;
		this.sessionId = sessionId;
		this.deviceEdgeNo = deviceEdgeNo;
		this.deviceEdgeSerialNo = deviceEdgeSerialNo;
		this.machineType = machineType;
		this.machineTypeCd = machineTypeCd;
		this.ec2Identification = ec2Identification;
		this.serviceName = serviceName;
		this.functionCd = functionCd;
		this.patId = patId;
		this.sqlIdentification = sqlIdentification;
		this.logMessage = logMessage;
		this.supportMessage = supportMessage;
	}

  // add FNSI-ログ保存場所の追加 xiebzh start
  public EventLogAPI() {

  }
  // add FNSI-ログ保存場所の追加 xiebzh end
}
