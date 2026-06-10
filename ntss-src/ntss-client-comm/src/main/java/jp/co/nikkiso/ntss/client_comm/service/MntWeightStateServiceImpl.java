package jp.co.nikkiso.ntss.client_comm.service;

import java.math.BigDecimal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntWeightStateDao;
import jp.co.nikkiso.ntss.core.entity.MntWeightState;

@Service
public class MntWeightStateServiceImpl implements MntWeightStateService {

  @Autowired
  MntWeightStateDao mntWeightStateDao;

  @Override
  public MntWeightState selectByScaleCd(Long scaleCd) {
    return mntWeightStateDao.selectByWeightCd(scaleCd);
  }

  @Override
  @Transactional
  public int insert(MntWeightState param) {
    return mntWeightStateDao.insert(param);
  }

  @Override
  @Transactional
  public int update(MntWeightState param) {
    return mntWeightStateDao.update(param);
  }

  /**
   * IsConnectを更新
   */
  @Override
  @Transactional
  public int updateIsConnect(Long scaleCd, String isConnect) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setIsConnect(isConnect);
    return mntWeightStateDao.update(state);
  }

  /**
   * ScaleValueを更新
   */
  @Override
  @Transactional
  public int updateScaleValue(Long scaleCd, BigDecimal scaleValue) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setScaleValue(scaleValue);
    return mntWeightStateDao.update(state);
  }

  /**
   * BarcodeValueを更新
   */
  @Override
  @Transactional
  public int updateBarcodeValue(Long scaleCd, String barcodeValue) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setBarcodeValue(barcodeValue);
    return mntWeightStateDao.update(state);
  }

  /**
   * cardReadValueを更新
   */
  @Override
  @Transactional
  public int updateCardReadValue(Long scaleCd, String cardReadValue) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setCardReadValue(cardReadValue);
    return mntWeightStateDao.update(state);
  }

  /**
   * cardWriteValueを更新
   */
  @Override
  @Transactional
  public int updateCardWriteValue(Long scaleCd, String cardWriteValue) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setCardWriteValue(cardWriteValue);
    return mntWeightStateDao.update(state);
  }

  /**
   * writeResultを更新
   */
  @Override
  @Transactional
  public int updateWriteResult(Long scaleCd, int writeResult) {
    MntWeightState state = mntWeightStateDao.selectByWeightCd(scaleCd);
    state.setWriteResult(writeResult);
    return mntWeightStateDao.update(state);
  }

}
