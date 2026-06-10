package jp.co.nikkiso.ntss.client_comm.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;


/**
 * MstFacility取得サービス
 */
@Service
public class MstFacilityServiceImpl implements MstFacilityService{

  @Autowired
  private MstFacilityDao mstFacilityDao;

  @Override
  public MstFacility findByFacility(String facilityCd) {
    return mstFacilityDao.selectByCd(facilityCd);
  }
}
