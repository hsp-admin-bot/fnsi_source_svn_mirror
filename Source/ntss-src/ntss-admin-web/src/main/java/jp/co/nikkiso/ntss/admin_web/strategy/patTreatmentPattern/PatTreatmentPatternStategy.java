package jp.co.nikkiso.ntss.admin_web.strategy.patTreatmentPattern;

import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;

public interface PatTreatmentPatternStategy {
  void update(OrdMainOnly ord, String facilityCd, Integer code);
}
