package jp.co.nikkiso.ntss.device_edge.service;


/**
 * 透析レポート作成サービス
 * @author ntss
 *
 */
public interface VAService {

  /**
   * VA画像取得
   * @param ordNo オーダー番号
   * @return BASE64エンコード文字列で構成された圧縮された画像データ
   */
  public String getVAImage(Long ordNo);
}
