package jp.co.nikkiso.ntss.monitoring.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstMoniItemDao;
import jp.co.nikkiso.ntss.core.entity.MstMoniItem;
import jp.co.nikkiso.ntss.monitoring.util.Utilities;

@Service
public class MstMoniItemServiceImpl implements MstMoniItemService {
  
  @Autowired
  MstMoniItemDao mstMoniItemDao;

  @Override
  public List<MstMoniItem> Select(String facility_cd, String model, String moni_no) {
    
    if(moni_no != null && Utilities.isNumber(moni_no)) {
      return mstMoniItemDao.selectByFacilityModelMoniNo(facility_cd, model, Integer.parseInt(moni_no));
    }else if(model != null ) {
      return mstMoniItemDao.selectByFacilityModel(facility_cd, model);
    }
    
    return mstMoniItemDao.selectByFacility(facility_cd);
  }

}
