package jp.co.nikkiso.ntss.admin_web.strategy.patTreatmentPattern;

import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.admin_web.strategy.PatTreatmentPatternFactory.regist;

@Component
public class IHDFtreatmentPattern implements PatTreatmentPatternStategy, InitializingBean {
  @Autowired
  PatTreatmentPatternDao patTreatmentPatternDao;
  @Autowired
  MstDialyzerDao mstDialyzerDao;

  @Override
  public void update(OrdMainOnly ord, String facilityCd, Integer code) {
    // get mst_dialyzer dialyzer_type = 1
    List<MstDialyzer> mstDialyzers = mstDialyzerDao.selectByFacillityCd(ord.getFacilityCd());
    List<String> dialyzerCds = mstDialyzers.stream()
      .filter(item -> "1".equals(item.getDialyzerType()))
      .map(vo -> {
        return String.valueOf(vo.getDialyzerCd());
      }).collect(Collectors.toList());
    ord.setDialyzerTypeList(dialyzerCds);
    patTreatmentPatternDao.updatePatTreatmentPatternByPatIdsIHDF(ord,facilityCd,code);
  }

  @Override
  public void afterPropertiesSet() throws Exception {
    regist("IHDF",this);
  }
}
