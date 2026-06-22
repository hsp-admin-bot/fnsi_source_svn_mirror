package jp.co.nikkiso.ntss.admin_web.service.changeWeekPattern;

import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentInstance;

import java.util.List;

public interface WeekPatternCopyService {
  WeekPatternCopyServiceImpl.CopyPlanResult weekPatternCopy(List<TreatmentInstance> treatmentInstanceList,
                                                            WeekPatternResponse weekResponse,
                                                            String facilityCd,
                                                            Long patId,
                                                            Long ind_user_id,
                                                            Long upd_user_id);
}
