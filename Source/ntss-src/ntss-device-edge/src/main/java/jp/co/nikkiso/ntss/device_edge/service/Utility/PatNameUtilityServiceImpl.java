package jp.co.nikkiso.ntss.device_edge.service.Utility;

import java.util.Objects;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;

@Service
public class PatNameUtilityServiceImpl implements PatNameUtilityService {

  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public PatNameInfo fetchPatName(Long patId) {
    String patLastName = "", patFirstName = "";
    boolean isSuccess;
    if (Objects.isNull(patId)) {
      // ？？？？患者
      patLastName = "？？？？患者";
      patFirstName = "";
      isSuccess = false;
    } else {
      // 通常患者
      PatPersonalMain pat = patPersonalMainDao.selectById(patId);
      if (Objects.isNull(pat)) {
        patLastName = "";
        patFirstName = "";
        isSuccess = false;
      } else {
        patLastName = pat.getPat_last_name();
        patFirstName = pat.getPat_first_name();
        isSuccess = true;
      }
    }
    PatNameInfo ret = new PatNameInfo(isSuccess, patFirstName, patLastName);
    return ret;
  }

}
