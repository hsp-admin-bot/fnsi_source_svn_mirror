package jp.co.nikkiso.ntss.client_comm.service;

import java.math.BigDecimal;

import jp.co.nikkiso.ntss.core.entity.MntWeightState;

public interface MntWeightStateService {

  MntWeightState selectByScaleCd(Long scaleCd);
  int insert(MntWeightState param);
  int update(MntWeightState param);
  
  int updateIsConnect(Long scaleCd, String isConnect);
  int updateScaleValue(Long scaleCd, BigDecimal scaleValue);
  int updateBarcodeValue(Long scaleCd, String barcodeValue);
  int updateCardReadValue(Long scaleCd, String cardReadValue);
  int updateCardWriteValue(Long scaleCd, String cardWriteValue);
  int updateWriteResult(Long scaleCd, int writeResult);
}
