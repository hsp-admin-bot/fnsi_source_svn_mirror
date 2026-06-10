package jp.co.nikkiso.ntss.admin_web.strategy.patTreatmentPattern;

import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import static jp.co.nikkiso.ntss.admin_web.strategy.PatTreatmentPatternFactory.regist;

@Component
public class OHFtreatmentPattern implements PatTreatmentPatternStategy, InitializingBean {
  @Autowired
  PatTreatmentPatternDao patTreatmentPatternDao;

  @Override
  public void update(OrdMainOnly ord, String facilityCd, Integer code) {
    patTreatmentPatternDao.updatePatTreatmentPatternByPatIdsOHF(ord,facilityCd,code);
  }

  @Override
  public void afterPropertiesSet() throws Exception {
    regist("OHF",this);
  }
}
