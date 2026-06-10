package jp.co.nikkiso.ntss.admin_web.service.weight.state;

import java.math.BigDecimal;

import jp.co.nikkiso.ntss.core.entity.MntWeightState;

public interface MntWeightStateService {

  MntWeightState selectByScaleCd(Long scaleCd);

  /**
   * 体重計マスタの内容をもとに体重計状態テーブルに情報を新規追加
   */
  int syncMaster(String facilityCd);

  int insert(MntWeightState param);

  int update(MntWeightState param);

  /**
   * IsConnectを更新
   */
  int updateIsConnect(Long scaleCd, String isConnect);

  /**
   * ScaleValueを更新
   */
  int updateScaleValue(Long scaleCd, BigDecimal scaleValue);

  // add FNSI-田中衡機の追加 徐 start
  /**
   * ScaleValueListの更新
   */
  int updateScaleValueList(Long scaleCd, String scaleValueList);
  // add FNSI-田中衡機の追加 徐 end

  /**
   * BarcodeValueを更新
   */
  int updateBarcodeValue(Long scaleCd, String barcodeValue);

  /**
   * cardReadValueを更新
   */
  int updateCardReadValue(Long scaleCd, String cardReadValue);

  /**
   * cardWriteValueを更新
   */
  int updateCardWriteValue(Long scaleCd, String cardWriteValue);

  /**
   * writeResultを更新
   */
  int updateWriteResult(Long scaleCd, int writeResult);

  /**
   * 印刷内容を取得
   */
  String selectPrintContent(Long weightScaleNo);

  /**
   * 印刷状態を更新
   */
  int updatePrintStatus(Long weightScaleNo, Integer status, String errorMessage);
}
