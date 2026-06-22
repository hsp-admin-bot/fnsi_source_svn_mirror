package jp.co.nikkiso.ntss.admin_web.strategy.ordMainTreatment;

import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.math.BigInteger;
import java.util.List;

import static jp.co.nikkiso.ntss.admin_web.strategy.OrdMainTreatmentFactory.register;

@Component
public class ECUMordMainTreatment implements OrdMainTreatmentStrategy, InitializingBean {
  @Autowired
  OrdMainDao ordMainDao;
  @Override
  public void update( Integer treatmentCd,OrdMainOnly ord, List<Long> ordNoList,
                     BigInteger indUserId, Long userId) {
    ordMainDao.updateByTreatmentCdOnlyForECUM(treatmentCd,ord,ordNoList,indUserId,userId);
  }

  @Override
  public void afterPropertiesSet() throws Exception {
    register("ECUM",this);
  }
}
