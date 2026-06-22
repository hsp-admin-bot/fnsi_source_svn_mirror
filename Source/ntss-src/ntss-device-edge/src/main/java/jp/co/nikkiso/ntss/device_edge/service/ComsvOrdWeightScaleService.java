package jp.co.nikkiso.ntss.device_edge.service;

public interface ComsvOrdWeightScaleService {

  /**
   * 条件送信結果の書き込み
   * @param facility_cd 施設コード
   * @param weight_scale_no 体重測定番号
   * @param weight_scale_status ステータス
   * @param message メッセージ
   * @return
   */
  boolean updateSendCondStatus(String facilityCd, Long weightScaleNo, Integer weightScaleStatus, String message);
}
