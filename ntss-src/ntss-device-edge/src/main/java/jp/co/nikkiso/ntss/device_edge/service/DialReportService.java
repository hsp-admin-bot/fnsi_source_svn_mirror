package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.device_edge.response.dialReport.PastOrderNoResponse;

/**
 * 透析レポート作成サービス
 * @author ntss
 *
 */
public interface DialReportService {

  /**
   * 透析レポート作成
   * @param ordNo オーダー番号
   * @return BASE64エンコード文字列で構成された画像データ
   */
  public String getDialReport(Long ordNo);

  /**
   * 指定したオーダー番号より直近、または同曜日過去3回分のオーダー番号を取得
   * @param ordNo オーダー番号
   * @return
   */
  public PastOrderNoResponse getPatDialInfo(Long ordNo);
}
