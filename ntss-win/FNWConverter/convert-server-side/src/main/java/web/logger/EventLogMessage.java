package web.logger;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.util.ObjectUtils;

import java.util.Arrays;
import java.util.stream.Collectors;

/**
 * ログメッセージクラス
 */
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class EventLogMessage {

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 利用者ID
   */
  private String userId;

  /**
   * クライアントIP
   */
  private String clientIp;

  /**
   * セッションID
   */
  private String sessionId;

  /**
   * デバイスエッジNo
   */
  private String deviceEdgeNo;

  /**
   * デバイスエッジ製造番号
   */
  private String deviceEdgeSerialNo;

  /**
   * 型式
   */
  private String machineType;

  /**
   * 型式コード
   */
  private String machineTypeCd;

  /**
   * EC2識別
   */
  private String ec2Identification;

  /**
   * サービス名
   */
  private String serviceName;

  /**
   * 機能コード
   */
  private String functionCd;

  /**
   * 内部患者ID
   */
  private String patId;

  /**
   * SQL名
   */
  private String sqlIdentification;

  /**
   * ログ内容
   */
  private String logMessage;

  /**
   * 対応内容
   */
  private String supportMessage;

  /**
   * invokeクラス
   */
  private String invokeClass;

  /**
   * 機能名
   */
  private String functionName;

  /**
   * ログメッセージ取得
   * @return ログメッセージ
   * @param logLevel ログ種別
   */
  public String buildLogMessage(LogLevel logLevel) {
    if (facilityCd != null) facilityCd = facilityCd.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (userId != null) userId = userId.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (clientIp != null) clientIp = clientIp.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (sessionId != null) sessionId = sessionId.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (deviceEdgeNo != null) deviceEdgeNo = deviceEdgeNo.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (deviceEdgeSerialNo != null) deviceEdgeSerialNo = deviceEdgeSerialNo.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (machineType != null) machineType = machineType.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (machineTypeCd != null) machineTypeCd = machineTypeCd.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (ec2Identification != null) ec2Identification= ec2Identification.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (serviceName != null) serviceName = serviceName.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (functionCd != null) functionCd = functionCd.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (functionName != null) functionName = functionName.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (patId != null) patId = patId.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (sqlIdentification != null) sqlIdentification = sqlIdentification.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (logMessage != null) logMessage = logMessage.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (supportMessage != null) supportMessage = supportMessage.replaceAll("\"", "\'").replaceAll("\n", " ");
    if (invokeClass != null) invokeClass = invokeClass.replaceAll("\"", "\'").replaceAll("\n", " ");

    return Arrays.asList(
      logLevel.getLevel(),
      facilityCd,
      userId,
      clientIp,
      sessionId,
      deviceEdgeNo,
      deviceEdgeSerialNo,
      machineType,
      machineTypeCd,
      ec2Identification,
      serviceName,
      functionCd,
      patId,
      sqlIdentification,
      logMessage,
      supportMessage,
      invokeClass,
      functionName
    ).stream()
      .map(value -> ObjectUtils.isEmpty(value) ? "" : value)
      .collect(Collectors.joining("\",\"", "\"", "\""));
  }
}
