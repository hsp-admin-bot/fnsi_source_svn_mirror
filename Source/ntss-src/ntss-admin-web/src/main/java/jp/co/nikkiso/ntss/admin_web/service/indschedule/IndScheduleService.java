package jp.co.nikkiso.ntss.admin_web.service.indschedule;

import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.json.JSONException;

import java.util.List;

public interface IndScheduleService {

  // mod #11716 曜日パターン変更の不正 関 start
  public UpdateScheduleListDataResponse updateIndSchedule2(
    String facilityCd,
    List<IndScheduleInfo> beforeIndScheduleInfoList,
    List<IndScheduleInfo> afterIndScheduleInfoList,
    IndscheduleChangeUserSelectedInfo indscheduleChangeUserSelectedInfo,
    WeekPatternResponse weekPatternDataInfo,
    UpdateScheduleListDataResponse checkResponse,
    List<OrdMain> delOrdMainList,
    Long indUserId,
    Long updUserId
  ) throws JSONException, ArrayIndexOutOfBoundsException;
  // mod #11716 曜日パターン変更の不正 関 end

  public List<IndHistory> createIndHistoryForIndSchedule(String facilityCd,
    List<OrdMain> beforeOrdMainList,
    List<OrdMain> afterOrdMainList);

}
