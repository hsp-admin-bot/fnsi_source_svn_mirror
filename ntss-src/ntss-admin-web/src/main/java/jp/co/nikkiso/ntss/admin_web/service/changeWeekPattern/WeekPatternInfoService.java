package jp.co.nikkiso.ntss.admin_web.service.changeWeekPattern;

import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainWeekPatternResponse;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentInstance;

import java.util.List;

public interface WeekPatternInfoService {
  /**
   * 曜日移動するord_noを取得
   * @param pat_id 患者ID
   * @param facility_cd 施設コード
   * @param dialysis_date_from 開始日
   * @param dialysis_date_to 終了日
   * @param rst_dialysis_state 状態
   * @param treatment_cd 治療方法コード
   * @param treat_week 曜日Noのリスト
   * @return
   */
  List<OrdMain> selectMoveTarget(
    Long pat_id,
    String facility_cd,
    String dialysis_date_from,
    String dialysis_date_to,
    String rst_dialysis_state,
    Integer treatment_cd,
    List<Integer> treat_week,
    boolean hasIndKurCd);

  List<TreatmentInstance> createMoveRuleContextFromTreatmentInstances(WeekPatternResponse weekPatternResponse, List<TreatmentInstance> treatmentInstanceList);

  List<TreatmentInstance> expandAndMergeOrdMainAndPatternToTreatmentInstances(WeekPatternResponse weekPatternResponse, String startDate, String endDate,
                                                                              List<Long> ownOrdNoList, List<Integer> bedList, List<Long> ownCtlNoList, List<Integer> patternBedList);

  OrdMainWeekPatternResponse processWeekdayPatternChange(ApiEntityOrdMain.ValiWeekPattern bodyData, UpdateScheduleListDataResponse response,
                                                         WeekPatternResponse weekResponse, IndscheduleChangeUserSelectedInfo userSelectedInfo, List<OrdMain> delOrdMainList,
                                                         List<TreatmentInstance> treatmentInstanceList);
}
