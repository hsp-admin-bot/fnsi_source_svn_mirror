package jp.co.nikkiso.ntss.admin_web.service.sysFacility;

import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @ClassName： SysFacilityServiceImpl
 * @Decscript: # 11871 iPhone側のメモリが大きいためにシステムが登録されている問題を処理する、新しいインタフェース
 * @Author: chamaojia
 * @Date: 2025/05/21
 */
@Service
public class SysFacilityServiceImpl implements SysFacilityService{
  @Autowired
  SysFacilityDao sysFacilityDao;

  @Override
  public SysFacility getSysFacilityByCd(String cd) {
    return sysFacilityDao.getSysFacilityByCd(cd);
  }

  @Override
  public List<SysFacility> getSysFacilityByCdList(List<String> cdList) {
    return sysFacilityDao.getSysFacilityByCdList(cdList);
  }

  @Override
  public SysFacility getSysFacilityByFacilityCd(String facilityCd) {
    return sysFacilityDao.getSysFacilityByFacilityCd(facilityCd);
  }
}
