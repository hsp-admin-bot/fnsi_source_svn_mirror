package jp.co.nikkiso.ntss.admin_web.strategy.ordMainTreatment;

import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;

import java.math.BigInteger;
import java.util.List;

public interface OrdMainTreatmentStrategy {
  void update(Integer treatmentCd, OrdMainOnly ord, List<Long> ordNoList,
              BigInteger indUserId, Long userId);
}
