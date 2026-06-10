package jp.co.nikkiso.ntss.admin_web.strategy.ordMainTreatment;

import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.math.BigInteger;
import java.util.List;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.admin_web.strategy.OrdMainTreatmentFactory.register;

@Component
public class IHDFordMainTreatment implements OrdMainTreatmentStrategy, InitializingBean {
  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  MstDialyzerDao mstDialyzerDao;

  @Override
  public void update(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
                     BigInteger indUserId, Long userId) {
    // get mst_dialyzer dialyzer_type = 1
    List<MstDialyzer> mstDialyzers = mstDialyzerDao.selectByFacillityCd(ord.getFacilityCd());
    List<String> dialyzerCds = mstDialyzers.stream()
      .filter(item -> "1".equals(item.getDialyzerType()))
      .map(vo -> {
        return String.valueOf(vo.getDialyzerCd());
      }).collect(Collectors.toList());
    ord.setDialyzerTypeList(dialyzerCds);

    ordMainDao.updateByTreatmentCdOnlyForIHDF(treatmentCd,ord,ordNoList,indUserId,userId);
  }

  @Override
  public void afterPropertiesSet() throws Exception {
    register("IHDF",this);
  }
}
