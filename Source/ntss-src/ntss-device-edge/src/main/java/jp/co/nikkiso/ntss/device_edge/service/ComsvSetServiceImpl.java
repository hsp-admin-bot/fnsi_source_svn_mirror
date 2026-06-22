package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.ComsvSetDao;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvSet;

/**
 * 通信サーバ設定サービス
 */
@Service
public class ComsvSetServiceImpl implements ComsvSetService {

  @Autowired
  ComsvSetDao comsvSetDao;

  //add redmine bug#5618 劉 start
  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;
  //add redmine bug#5618 劉 end

  @Override
  public ComsvSet selectComsvSet(String facilityCd, Integer deviceEdgeNo) {
    ComsvSet comsvSet = comsvSetDao.selectComsvSet(facilityCd, deviceEdgeNo);
    //add redmine bug#5618 劉 start
    FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, "2003");
    if (null != facilitySettingInfo) {
      comsvSet.setTreatmentJudgeTime(facilitySettingInfo.getValue());
    }
    //add redmine bug#5618 劉 end
    return comsvSet;
  }

}
