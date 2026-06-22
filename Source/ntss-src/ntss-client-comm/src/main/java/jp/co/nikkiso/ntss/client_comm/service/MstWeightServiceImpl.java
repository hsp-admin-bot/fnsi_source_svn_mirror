package jp.co.nikkiso.ntss.client_comm.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstWeightDao;
import jp.co.nikkiso.ntss.core.dao.MstWeightScaleDao;
import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.core.entity.MstWeightScale;

@Service
public class MstWeightServiceImpl implements MstWeightService {

  @Autowired
  MstWeightDao mstWeightDao;

  @Autowired
  MstWeightScaleDao mstWeightScaleDao;

  @Override
  public List<MstWeight> mstWeightSelectByFacilityCd(String facilityCd){
    return mstWeightDao.selectByFacility(facilityCd);
  }

  @Override
  public MstWeight mstWeightSelectByScaleCd(Long weightCd) {
    return mstWeightDao.selectByWeightCd(weightCd);
  }

  @Override
  public MstWeight mstWeightSelectByFacilityCdWeightNo(String facilityCd, int weightNo) {
    return mstWeightDao.selectByFacilityWeightNo(facilityCd, weightNo);
  }

  @Override
  @Transactional
  public int mstWeightInsert(MstWeight param) {
    return mstWeightDao.insert(param);
  }

  @Override
  @Transactional
  public int mstWeightUpdate(MstWeight param) {
    return mstWeightDao.update(param);
  }

  @Override
  @Transactional
  public int mstWeightUpdateCheckContent(Long weightCd, String checkContent) {
    MstWeight param = mstWeightDao.selectByWeightCd(weightCd);
    param.setCheckContent(checkContent);
    return mstWeightDao.update(param);
  }

  @Override
  @Transactional
  public int mstWeightUpdatePrintSetting(Long weightCd, String printSetting) {
    MstWeight param = mstWeightDao.selectByWeightCd(weightCd);
    param.setPrintSetting(printSetting);
    return mstWeightDao.update(param);
  }

  @Override
  @Transactional
  public int mstWeightUpdateColorSetting(Long weightCd, String colorSetting) {
    MstWeight param = mstWeightDao.selectByWeightCd(weightCd);
    param.setColorSetting(colorSetting);
    return mstWeightDao.update(param);
  }

  @Override
  @Transactional
  public int mstWeightUpdateAudioSetting(Long weightCd, String audioSetting) {
    MstWeight param = mstWeightDao.selectByWeightCd(weightCd);
    param.setAudioSetting(audioSetting);
    return mstWeightDao.update(param);
  }

  @Override
  public MstWeightScale mstWeightScaleSelectByFacility(String facilityCd) {
    return mstWeightScaleDao.selectByFacility(facilityCd);
  }

  @Override
  @Transactional
  public int mstWeightScaleInsert(MstWeightScale param) {
    return mstWeightScaleDao.insert(param);
  }

  @Override
  @Transactional
  public int mstWeightScaleUpdate(MstWeightScale param) {
    return mstWeightScaleDao.update(param);
  }

}
