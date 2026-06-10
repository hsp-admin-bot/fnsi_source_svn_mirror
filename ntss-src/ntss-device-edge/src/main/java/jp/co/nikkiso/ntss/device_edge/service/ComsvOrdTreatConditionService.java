package jp.co.nikkiso.ntss.device_edge.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdTreatCondition;

public interface ComsvOrdTreatConditionService {
  List<ComsvOrdTreatCondition> selectCondition(ComsvOrdTreatCondition param);

  int deleteCondition(ComsvOrdTreatCondition param);

  int insertCondition(ComsvOrdTreatCondition param);
}
