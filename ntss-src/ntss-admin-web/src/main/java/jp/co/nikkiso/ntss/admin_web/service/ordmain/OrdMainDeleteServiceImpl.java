package jp.co.nikkiso.ntss.admin_web.service.ordmain;

import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternDelta;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.service.PatTreatmentPatternService;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternJsonbField;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternKey;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import jp.co.nikkiso.ntss.core.entity.custom.EquipCodeAndType;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class OrdMainDeleteServiceImpl implements OrdMainDeleteService {

  @Autowired
  private OrdMainServiceImpl ordMainServiceImpl;

  @Autowired
  private IndScheduleServiceImpl indScheduleServiceImpl;

  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;

  @Autowired
  private PatTreatmentPatternService patTreatmentPatternService;

  // add #12648 終了日未設定の予定作成をすべて中止してもsch_ext_end_dateがnullにならない 関 start
  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private PatExamPatternDao patExamPatternDao;

  @Autowired
  private PatRadPatternDao patRadPatternDao;

  @Autowired
  private PatTreatmentPatternDao patTreatmentPatternDao;
  // add #12648 終了日未設定の予定作成をすべて中止してもsch_ext_end_dateがnullにならない 関 end

  @Getter
  @Setter
  public static class DeleteTreatPlanResult {
    private int deletedOrdMainCount;
    private boolean success;
    private List<Long> ordNolist;
  }

  @Getter
  @Setter
  public static class DeleteTreatPlanCommand {
    private Long patId;
    private List<Integer> treatCdList;
    private String facilityCd;
    private List<Long> indKurCdList;
    private Long indUserId;
    private Long updUserId;
    private boolean isDeadline;
  }

  public DeleteTreatPlanResult deleteTreatPlanAndProcessDependencies(DeleteTreatPlanCommand data, List<OrdMain> ordMainList, List<Integer> weeksArray,
                                                                     Map<String, List<Object>> resultAllChangeBeforeDataInfoList, IndscheduleChangeUserSelectedInfo userSelectedInfo,
                                                                     UpdateScheduleListDataResponse checkResponse, WeekPatternResponse dataInfo, String flag){

    DeleteTreatPlanResult result = new DeleteTreatPlanResult();

    List<Long> ordNoList = Optional.ofNullable(ordMainList)
      .orElse(Collections.emptyList()).stream().map(item -> item.getOrdNo()).distinct().collect(Collectors.toList());

    // チェックリストの削除処理
    ordMainServiceImpl.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_DELETE, ordNoList);

    indScheduleServiceImpl.processChangeDependentExamAndRad(dataInfo, data.getFacilityCd(), checkResponse,
      userSelectedInfo, new ArrayList<>(), new HashMap<>(), resultAllChangeBeforeDataInfoList, ordMainList, data.getIndUserId(), data.getUpdUserId(), flag);

    // OrdMain関連データの削除処理
    int ordCount = ordMainServiceImpl.batchDeleteByOrdNo(ordNoList);
    result.setDeletedOrdMainCount(ordCount);

    result.setOrdNolist(ordNoList);

    //save
    this.ordMaterialSaveService.deleteBatchByCondition(
      data.getFacilityCd(),
      data.getPatId().toString(),
      ordNoList,
      null,
      Collections.singletonList("1"),
      new ArrayList<EquipCodeAndType>()
    );

    if (!data.isDeadline()) {
      // 患者治療パターン治療予定中止
      PatTreatmentPatternKey key = new PatTreatmentPatternKey(
        data.getPatId(),
        data.getFacilityCd(),
        data.getTreatCdList(),
        data.getIndKurCdList(),
        weeksArray,
        null,
        new HashMap<>()
      );

      PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();
      delta.getDeletes().add(key);

      patTreatmentPatternService.applyPatTreatmentPatterns(delta);

      // add #12648 終了日未設定の予定作成をすべて中止してもsch_ext_end_dateがnullにならない 関 start
      // indDelete / weekChange とも「全てのパターンが存在しない」場合のみ sch_ext_end_date をクリアする
      clearSchExtEndDateIfNoPatterns(data.getPatId());
      // add #12648 終了日未設定の予定作成をすべて中止してもsch_ext_end_dateがnullにならない 関 end
    }
    result.setSuccess(true);
    return result;
  }

  /**
   * add #12648
   * 無期限(isDeadline=false)の予定について、患者に紐づく各種パターンが存在しない場合のみ
   * sch_ext_end_date をクリアする。
   *
   * 判定条件は既存ロジック(例: PatTreatmentPatternUtils)に合わせ、exam/rad は OR 条件。
   * ただし pat_treatment_pattern が残っている場合はクリアしない。
   */
  private void clearSchExtEndDateIfNoPatterns(Long patId) {
    if (patId == null) return;

    Long patternCount = patTreatmentPatternDao.selectCountByPatId(patId);
    int examCount = patExamPatternDao.selectPatExamPatternByPatId(patId);
    List<PatRadPattern> patRadPatternList = patRadPatternDao.selectPatRadPatternByPatId(patId);

    boolean hasNoTreatmentPattern = patternCount == null || patternCount <= 0;
    boolean hasNoExamPattern = examCount <= 0;
    boolean hasNoRadPattern = patRadPatternList == null || patRadPatternList.isEmpty();

    // 既存ロジック(例: PatTreatmentPatternUtils)に合わせ、exam/rad は OR 条件で判定する
    // ただし pat_treatment_pattern が残っている場合はクリアしない
    if (hasNoTreatmentPattern && (hasNoExamPattern || hasNoRadPattern)) {
      patMainDao.updateSchExtEndDate(patId, null);
    }
  }
}
