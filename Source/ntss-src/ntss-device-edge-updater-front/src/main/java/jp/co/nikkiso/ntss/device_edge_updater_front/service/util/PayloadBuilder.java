package jp.co.nikkiso.ntss.device_edge_updater_front.service.util;

public class PayloadBuilder {
  
  /**
   * topic作成
   * @param kind
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  public static String BuildTopic(String kind, String facilityCd, Integer deviceEdgeNo) {
    StringBuilder sb = new StringBuilder(null == kind ? "" : kind);
    if(kind == null || kind.endsWith("/") == false) {
      sb.append("/");
    }
    sb.append(null == facilityCd ? "" : facilityCd)
    .append("/")
    .append(null == deviceEdgeNo ? "" : deviceEdgeNo);
    return sb.toString();
  }

  /**
   * ファイル更新用電文作成
   * シーケンスNo{TAB}識別子{TAB}バケット{TAB}ファイル名
   * @param manageNo
   * @param orderSubKind
   * @param bucket
   * @param fileName
   * @return
   */
  public static String BuildAppUpdatePayload(Long manageNo, Integer orderSubKind, String bucket, String fileName) {

    StringBuilder payload = new StringBuilder();
    payload.append(null == manageNo ? "" : manageNo).append("\t")
    .append(null == orderSubKind ? "" : orderSubKind).append("\t")
    .append(null == bucket ? "" : bucket).append("\t")
    .append(null == fileName ? "" : fileName);
    
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
}
