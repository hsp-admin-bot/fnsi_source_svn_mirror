package jp.co.nikkiso.ntss.admin_web.service.ordmain;

import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.entity.OrdMain;

import java.util.List;
import java.util.Map;

public interface OrdMainDeleteService {
   OrdMainDeleteServiceImpl.DeleteTreatPlanResult deleteTreatPlanAndProcessDependencies(OrdMainDeleteServiceImpl.DeleteTreatPlanCommand data, List<OrdMain> ordMainList, List<Integer> weeksArray,
                                                                                              Map<String, List<Object>> resultAllChangeBeforeDataInfoList, IndscheduleChangeUserSelectedInfo userSelectedInfo,
                                                                                              UpdateScheduleListDataResponse checkResponse, WeekPatternResponse dataInfo, String flag);
}
