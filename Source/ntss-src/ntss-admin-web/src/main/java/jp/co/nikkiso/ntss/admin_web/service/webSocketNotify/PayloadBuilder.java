package jp.co.nikkiso.ntss.admin_web.service.webSocketNotify;

public class PayloadBuilder {

  /**
   * デバイスエッジ向けtopic作成
   * @param kind
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  public static String BuildTopic(String kind, String facilityCd, Integer deviceEdgeNo) {
    StringBuilder sb = new StringBuilder(null == kind ? "" : kind);
    if (kind == null || kind.endsWith("/") == false) {
      sb.append("/");
    }
    sb.append(null == facilityCd ? "" : facilityCd)
        .append("/")
        .append(null == deviceEdgeNo ? "" : deviceEdgeNo);
    return sb.toString();
  }

  /**
   * 体重計アプリ向けtopic作成
   * @param kind
   * @param facilityCd
   * @param weightNo
   * @return
   */
  public static String BuildWeightTopic(String kind, String facilityCd, Integer weightNo) {
    StringBuilder sb = new StringBuilder(null == kind ? "" : kind);
    if (kind == null || kind.endsWith("/") == false) {
      sb.append("/");
    }
    sb.append(null == facilityCd ? "" : facilityCd)
        .append("/")
        .append(null == weightNo ? "" : weightNo);
    return sb.toString();
  }

  /**
   * ファイル更新用電文作成
   * シーケンスNo{TAB}識別子{TAB}バケット{TAB}ファイル名{TAB}予定日時
   * @param manageNo
   * @param orderSubKind
   * @param bucket
   * @param fileName
   * @param planDate
   * @return
   */
  public static String BuildAppUpdatePayload(Long manageNo, Short orderSubKind, String bucket, String fileName, String planDate) {

    StringBuilder payload = new StringBuilder();
    payload.append(null == manageNo ? "" : manageNo).append("\t")
        .append(null == orderSubKind ? "" : orderSubKind).append("\t")
        .append(null == bucket ? "" : bucket).append("\t")
        .append(null == fileName ? "" : fileName)
        .append(null == planDate ? "" : "\t" + planDate);

    return payload.toString();
  }

  /**
   * Confファイル差し替え用電文作成
   * シーケンスNo{TAB}バケット{TAB}ファイル名
   * @param manageNo
   * @param bucket
   * @param fileName
   * @return
   */
  public static String BuildConfUpdatePayload(Long manageNo, String bucket, String fileName) {

    StringBuilder payload = new StringBuilder();
    payload.append(null == manageNo ? "" : manageNo).append("\t")
        .append(null == bucket ? "" : bucket).append("\t")
        .append(null == fileName ? "" : fileName);

    return payload.toString();
  }

  /**
   * アプリ差し戻し用電文作成
   * シーケンスNo
   * @param manageNo
   * @return
   */
  public static String BuildAppRestorePayload(Long manageNo) {

    StringBuilder payload = new StringBuilder();
    payload.append(null == manageNo ? "" : manageNo);

    return payload.toString();
  }

  /**
   * ログ収集指示用電文作成
   * シーケンスNo
   * @param manageNo
   * @return
   */
  public static String BuildGatherPayload(Long manageNo) {

    StringBuilder payload = new StringBuilder();
    payload.append(null == manageNo ? "" : manageNo);

    return payload.toString();
  }

  /**
   * 再起動や停止などの指示用電文作成
   * シーケンスNo
   * @param manageNo
   * @return
   */
  public static String BuildServiceControlPayload(Long manageNo) {

    StringBuilder payload = new StringBuilder();
    payload.append(null == manageNo ? "" : manageNo);

    return payload.toString();
  }

  /**
   * 予定キャンセル指示用電文作成
   * シーケンスNo
   * @param manageNo
   * @return
   */
  public static String BuildPlanCancelPayload(Long manageNo) {

    StringBuilder payload = new StringBuilder();
    payload.append(null == manageNo ? "" : manageNo);

    return payload.toString();
  }

  /**
   * 条件送信用電文作成
   * 装置番号{TAB}オーダー番号{TAB}条件送信指示管理番号{TAB}治療番号と指示情報から作成されたSHA256ハッシュ
   * @param ordNo
   * @param hash
   * @return
   */
  public static String BuildSendConditionPayload(String machineInfo, Long ordNo, Long weightScaleNo, String hash) {

    StringBuilder payload = new StringBuilder();
    payload
        .append(null == machineInfo ? "" : machineInfo).append("\t")
        .append(null == ordNo ? "" : ordNo).append("\t")
        .append(null == weightScaleNo ? "" : weightScaleNo).append("\t")
        .append(null == hash ? "" : hash);

    return payload.toString();
  }

  /**
   * 通信サーバー指示向け
   * 装置番号{TAB}オーダー番号
   * @param machineNo
   * @param ordNo
   * @return
   */
  public static String BuildMachineAndOrdNoPayload(Long machineNo, Long ordNo) {

    StringBuilder payload = new StringBuilder();
    payload
        .append(null == machineNo ? "" : machineNo).append("\t")
        .append(null == ordNo ? "" : ordNo);

    return payload.toString();
  }
}
