package jp.co.nikkiso.ntss.admin_web.service.changeWeekPattern;

import jp.co.nikkiso.ntss.admin_web.service.ordmain.OrdMainDeleteService;
import jp.co.nikkiso.ntss.admin_web.service.ordmain.OrdMainDeleteServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternDelta;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternFieldEnum;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternJsonbField;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternKey;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainWeekPatternResponse;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleService;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpdateModeEnum;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.model.PatTreatmentPatternUpsert;
import jp.co.nikkiso.ntss.admin_web.service.patTreatmentPattern.service.PatTreatmentPatternService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatTreatmentPatternUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatRadPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatExamPattern;
import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.TreatmentInstanceSourceDto;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentInstance;
import jp.co.nikkiso.ntss.core.entity.custom.WeekChangeInfo;
import org.apache.commons.lang3.SerializationUtils;
import org.json.JSONObject;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.sql.Timestamp;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class WeekPatternInfoServiceImpl implements WeekPatternInfoService {

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private PatTreatmentPatternDao patTreatmentPatternDao;

  @Autowired
  private PatExamPatternDao patExamPatternDao;

  @Autowired
  private PatRadPatternDao patRadPatternDao;

  @Autowired
  private IndScheduleService indScheduleService;

  @Autowired
  private OrdMainDeleteService ordMainDeleteService;

  @Autowired
  PatTreatmentPatternUtils patTreatmentPatternUtils;

  @Autowired
  WeekPatternCopyService weekPatternCopyService;

  @Autowired
  OrdScheduleDao ordScheduleDao;

  @Autowired
  PatTreatmentPatternService patTreatmentPatternService;

  @Transactional
  @Override
  public OrdMainWeekPatternResponse processWeekdayPatternChange(ApiEntityOrdMain.ValiWeekPattern bodyData, UpdateScheduleListDataResponse scheduleResponse,
                                                                WeekPatternResponse weekResponse, IndscheduleChangeUserSelectedInfo userSelectedInfo, List<OrdMain> delOrdMainList,
                                                                List<TreatmentInstance> treatmentInstanceList) {

    OrdMainWeekPatternResponse response = new OrdMainWeekPatternResponse();

    Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>(); // 連携用、イベントログ用
    Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>();

    Long indUser = Long.parseLong(bodyData.getInd_user());
    Long updUser =  Long.parseLong(bodyData.getUpd_user());
    String facilityCd = bodyData.getFacility_cd();
    Long patId = Long.parseLong(bodyData.getPat_id());

    List<Long> updateOrdNoList = new ArrayList<>();

    List<OrdMain> nextOrdMainList = new ArrayList<>();
    //copy
    WeekPatternCopyServiceImpl.CopyPlanResult copyResult = weekPatternCopyService.weekPatternCopy(treatmentInstanceList, weekResponse, facilityCd, patId, indUser, updUser);
    if (copyResult.getOrdMainList() != null && !copyResult.getOrdMainList().isEmpty()) {
      updateOrdNoList.addAll(copyResult.getOrdMainList().stream().map(OrdMain::getOrdNo).collect(Collectors.toList()));

      ordScheduleDao.bulkUpdateByOrdMainIndCondInfo(facilityCd, updateOrdNoList);

      nextOrdMainList.addAll(copyResult.getOrdMainList());

      List<Object> objectList = new ArrayList<>(copyResult.getOrdMainList());
      resultAllChangedDataInfoList
        .computeIfAbsent("ord_main", k -> new ArrayList<>())
        .addAll(objectList);
    }

    //update
    scheduleResponse = indScheduleService.updateIndSchedule2(
      bodyData.getFacility_cd(),
      scheduleResponse.getBeforeIndScheduleInfo(),
      Collections.emptyList(),
      userSelectedInfo,
      weekResponse,
      scheduleResponse,
      delOrdMainList,
      indUser,
      updUser
    );

    // changed
    Map<String, List<Object>> changedMap =
      scheduleResponse.getResultAllChangedDataInfoList();

    if (changedMap != null && !changedMap.isEmpty()) {
      changedMap.forEach((k, v) ->
        resultAllChangedDataInfoList
          .computeIfAbsent(k, key -> new ArrayList<>())
          .addAll(v)
      );
    }

    // before
    Map<String, List<Object>> beforeMap =
      scheduleResponse.getResultAllChangeBeforeDataInfoList();

    if (beforeMap != null && !beforeMap.isEmpty()) {
      beforeMap.forEach((k, v) ->
        resultAllChangeBeforeDataInfoList
          .computeIfAbsent(k, key -> new ArrayList<>())
          .addAll(v)
      );
    }

    // next call
    nextOrdMainList.addAll(scheduleResponse.getDoCallNextPatOrdMainList());

    response.setDoCallNextPatOrdMainList(nextOrdMainList);


    //delete
    List<OrdMain> safeDelOrdMainList = delOrdMainList != null ? delOrdMainList : Collections.emptyList();

    OrdMainDeleteServiceImpl.DeleteTreatPlanCommand data = new OrdMainDeleteServiceImpl.DeleteTreatPlanCommand();
    data.setPatId(Long.parseLong(bodyData.getPat_id()));
    data.setFacilityCd(bodyData.getFacility_cd());
    data.setIndUserId(indUser);
    data.setUpdUserId(updUser);
    data.setDeadline(bodyData.getIs_deadline());

    List<Long> indKurCdList = safeDelOrdMainList.stream()
      .map(OrdMain::getIndKurCd)
      .filter(Objects::nonNull)
      .map(Long::valueOf)
      .distinct()
      .toList();

    List<Integer> treatCdList = safeDelOrdMainList.stream()
      .map(OrdMain::getIndTreatmentCd)
      .filter(Objects::nonNull)
      .distinct()
      .toList();

    data.setIndKurCdList(indKurCdList);
    data.setTreatCdList(treatCdList);

    OrdMainDeleteServiceImpl.DeleteTreatPlanResult result = new OrdMainDeleteServiceImpl.DeleteTreatPlanResult();

    if (!safeDelOrdMainList.isEmpty() || (weekResponse.getDelWeekList() != null && !weekResponse.getDelWeekList().isEmpty())) {
      result = ordMainDeleteService.deleteTreatPlanAndProcessDependencies(
        data,
        safeDelOrdMainList,
        weekResponse.getDelWeekList(),
        resultAllChangeBeforeDataInfoList,
        userSelectedInfo,
        scheduleResponse,
        weekResponse,
        "weekChange"
      );

      List<OrdMain> beforeList = safeDelOrdMainList.stream()
        .map(o -> {
          OrdMain copy = new OrdMain();
          BeanUtils.copyProperties(o, copy);
          return copy;
        })
        .collect(Collectors.toList());

      resultAllChangeBeforeDataInfoList
        .computeIfAbsent("ord_main", k -> new ArrayList<>())
        .addAll(beforeList);

//      safeDelOrdMainList.forEach(o -> o.setIsDel("1"));
//
//      resultAllChangedDataInfoList
//        .computeIfAbsent("ord_main", k -> new ArrayList<>())
//        .addAll(safeDelOrdMainList);
    }

    // パターン更新
    boolean patternResult = changeWeekdayPattern(facilityCd, treatmentInstanceList, weekResponse, userSelectedInfo, indUser, updUser);

    boolean scheduleFailed = !scheduleResponse.isSuccess;
    boolean copyFailed = !copyResult.isSuccess();

    boolean hasDelete = delOrdMainList != null && !delOrdMainList.isEmpty();
    boolean deleteFailed = hasDelete && !result.isSuccess();

    boolean patternFailed = !patternResult;

    boolean hasError = scheduleFailed || copyFailed || deleteFailed || patternFailed;

    if (hasError) {
      HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
      response.setBody("レコードの更新に失敗しました。");
      response.setHeaders(null);
      response.setStatus(status);
      response.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
      return response;
    }else {
      response.setStatus(HttpStatus.OK);
      response.setResultAllChangedDataInfoList(resultAllChangedDataInfoList);
      response.setResultAllChangeBeforeDataInfoList(resultAllChangeBeforeDataInfoList);
      response.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.SUCCESS.toString());
      return response;
    }
  }

  @Transactional
  @Override
  public List<TreatmentInstance> expandAndMergeOrdMainAndPatternToTreatmentInstances(WeekPatternResponse weekPatternResponse, String startDate, String endDate,
                                                                                     List<Long> ownOrdNoList, List<Integer> bedList, List<Long> ownCtlNoList, List<Integer> patternBedList) {

    List<TreatmentInstance> mergedTreatmentInstanceList = new ArrayList<>();

    String facilityCd = weekPatternResponse.getFacilityCd();

    Long patId = weekPatternResponse.getPatId();

    Integer treatmentCd = weekPatternResponse.getTreatmentCd();

    if ((ownOrdNoList == null || ownOrdNoList.isEmpty())
      && (bedList == null || bedList.isEmpty())) {
      startDate = weekPatternResponse.getWeekChangeStartDate();
      endDate = weekPatternResponse.getWeekChangeEndDate();
    }
    // 移動先ordmain検索
    List<TreatmentInstanceSourceDto> ordMainSourceList =
      Optional.ofNullable(
        ordMainDao.selectOrdMainMoveTargetList(facilityCd, patId, startDate, endDate, treatmentCd, ownOrdNoList, bedList)
      ).orElse(Collections.emptyList());

    // ordMain → TreatmentInstance に変換してリスト化
    List<TreatmentInstance> ordMainInstanceList =
      Optional.ofNullable(ordMainSourceList)
        .orElse(Collections.emptyList())
        .stream()
        .map(this::convertOrdMainToTreatmentInstance)
        .collect(Collectors.toList());

    mergedTreatmentInstanceList.addAll(ordMainInstanceList);

    if (!weekPatternResponse.getIsEndDateUnset()) {
      // 移動先pattern検索
      List<TreatmentInstanceSourceDto> patPatternMoveTargetList =
        Optional.ofNullable(
          patTreatmentPatternDao.selectPatTreatmentPatternMoveTargetList(facilityCd, patId, treatmentCd, patternBedList)
        ).orElse(Collections.emptyList());

      if (ownCtlNoList != null && !ownCtlNoList.isEmpty()
        && patternBedList != null && !patternBedList.isEmpty()) {

        patPatternMoveTargetList = Optional.ofNullable(patPatternMoveTargetList).orElse(Collections.emptyList()).
          stream().filter(i ->
          !(ownCtlNoList.contains(i.getCtlNo())
            && Objects.equals(patId, i.getPatId())))
          .collect(Collectors.toList());
      }
      // patternを展開したordMainをTreatmentInstanceに変換し、リスト化する
      List<TreatmentInstance> expandedTreatmentInstanceList = expandPatternToTreatmentInstances(patPatternMoveTargetList);
      mergedTreatmentInstanceList.addAll(expandedTreatmentInstanceList);
    }

    return mergedTreatmentInstanceList;
  }
  public List<TreatmentInstance> expandPatternToTreatmentInstances(
    List<TreatmentInstanceSourceDto> patternList
  ) {
    if (patternList == null || patternList.isEmpty()) {
      return Collections.emptyList();
    }

    // ① sch_ext_end_dateを基準日とする
    String startYmd = patternList.get(0).getSchExtEndDate();
    if (startYmd == null || startYmd.length() != 8) {
      return Collections.emptyList();
    }

    DateTimeFormatter fmt = DateTimeFormatter.BASIC_ISO_DATE;

    LocalDate schExtEndDateDB = LocalDate.parse(startYmd, fmt);

    LocalDate systemDate = LocalDate.now();

    LocalDate schExtEndDate =
      systemDate
        .plusYears(1)
        .plusMonths(1)
        .with(TemporalAdjusters.lastDayOfMonth());

    LocalDate baseMonthFirst;
    if (!schExtEndDate.isBefore(schExtEndDateDB)) {
      baseMonthFirst =
        schExtEndDate
          .plusMonths(1)
          .withDayOfMonth(1);
    } else {
      baseMonthFirst = schExtEndDateDB;
    }

    LocalDate endDate =
      baseMonthFirst
        .plusWeeks(2)
        .with(TemporalAdjusters.dayOfWeekInMonth(2, DayOfWeek.SUNDAY));

    LocalDate startDate =
      LocalDate.parse(startYmd, DateTimeFormatter.BASIC_ISO_DATE)
        .plusDays(1);

    List<TreatmentInstance> result = new ArrayList<>();

    // ② patternごとに展開する
    for (TreatmentInstanceSourceDto pattern : patternList) {
      Short treatWeek = pattern.getTreatWeek();
      if (treatWeek == null) {
        continue;
      }

      DayOfWeek targetDay = convertToDayOfWeek(treatWeek);

      // ③ 曜日条件に一致する最初の日付を取得する
      LocalDate firstMatch =
        startDate.with(TemporalAdjusters.nextOrSame(targetDay));

      // ④ 曜日制約を維持しつつ、treatType に応じて治療日を展開する
      for (LocalDate d = firstMatch; !d.isAfter(endDate); ) {

        result.add(createTreatmentInstance(pattern, pattern.getPatId(), d));

        Integer treatType = pattern.getTreatType();

        if (treatType == null || treatType == 1) {
          // 通常：毎週（同一曜日）
          d = d.plusWeeks(1);

        } else if (treatType == 2) {
          // 隔日：曜日制約があるため、実質は隔週（同一曜日）
          d = d.plusWeeks(2);

        } else if (treatType == 3) {
          // 隔週：2週間ごと（同一曜日）
          d = d.plusWeeks(2);

        } else {
          break;
        }
      }
    }
    return result;
  }
  private DayOfWeek convertToDayOfWeek(short treatWeek) {
    switch (treatWeek) {
      case 1: return DayOfWeek.MONDAY;
      case 2: return DayOfWeek.TUESDAY;
      case 3: return DayOfWeek.WEDNESDAY;
      case 4: return DayOfWeek.THURSDAY;
      case 5: return DayOfWeek.FRIDAY;
      case 6: return DayOfWeek.SATURDAY;
      case 7: return DayOfWeek.SUNDAY;
      default:
        throw new IllegalArgumentException("Invalid treatWeek: " + treatWeek);
    }
  }
  private TreatmentInstance createTreatmentInstance(
    TreatmentInstanceSourceDto src,
    Long patId,
    LocalDate date
  ) {
    TreatmentInstance instance = new TreatmentInstance();

    instance.setPatId(patId);
    instance.setOrdNo(src.getCtlNo());
    instance.setIndTreatmentCd(src.getIndTreatmentCd());
    instance.setTreatWeek(src.getTreatWeek().intValue());
    instance.setBedCd(src.getIndBedCd());
    instance.setKurCd(src.getIndKurCd());

    instance.setTreatDate(date.format(DateTimeFormatter.BASIC_ISO_DATE));

    instance.setStart(src.getTreatStartTime());
    instance.setTreatTime(src.getTreatTime());
    instance.setKurName(src.getKurName());
    instance.setBedName(src.getBedName());
    instance.setSource(TreatmentInstance.Source.PAT_TREATMENT_PATTERN);

    return instance;
  }
  @Transactional
  @Override
  public List<TreatmentInstance> createMoveRuleContextFromTreatmentInstances(WeekPatternResponse weekPatternResponse, List<TreatmentInstance> treatmentInstanceList) {

    List<OrdMain> doCallNextPatOrdMainList = new ArrayList<>();

    String facilityCd = weekPatternResponse.getFacilityCd();

    Long patId = weekPatternResponse.getPatId();

    Integer treatmentCd = weekPatternResponse.getTreatmentCd();

    String indTreatStartDate = weekPatternResponse.getWeekChangeStartDate();

    String endDate = weekPatternResponse.getWeekChangeEndDate();

    List<Integer> srcWeek = new ArrayList<>(weekPatternResponse.getFromWeekList());

    srcWeek.addAll(weekPatternResponse.getDelWeekList());

    List<OrdMain> ordMainList = this.selectMoveTarget(
      patId, facilityCd, indTreatStartDate, endDate, "0", treatmentCd, srcWeek, false
    );
    // 次患者
    List<OrdMain> beforeOrdMainList = ordMainList.stream().map(SerializationUtils::clone).collect(Collectors.toList());

    doCallNextPatOrdMainList.addAll(beforeOrdMainList);

    Map<Integer, List<Integer>> fromWeekToValues = weekPatternResponse.getFromWeekCandidatesMap();

    List<String> firstDateList = new ArrayList<>();
    List<Integer> firstWeekList = new ArrayList<>();

    calcDatesAndWeeksUntilWeekend(indTreatStartDate, endDate, firstDateList, firstWeekList);

    List<TreatmentInstance> treatmentInstanceCopyList = new ArrayList<>();

    for (TreatmentInstance treatmentInstance : treatmentInstanceList) {

      Integer treatWeek = treatmentInstance.getTreatWeek().intValue();
      List<Integer> rawToWeekList = fromWeekToValues.get(treatWeek);

      if (rawToWeekList == null || rawToWeekList.isEmpty()) {
        continue;
      }

      // ② 第1週の特殊処理
      List<Integer> toWeekList;
      if (firstDateList.contains(treatmentInstance.getTreatDate())) {
        toWeekList = rawToWeekList.stream()
          .filter(Objects::nonNull)
          .filter(w -> firstWeekList != null && firstWeekList.contains(w))
          .distinct()
          .collect(Collectors.toList());
      } else {
        toWeekList = rawToWeekList;
      }

      if (toWeekList.isEmpty()) {
        continue;
      }

      // ③ 自身曜日を含む場合
      if (toWeekList.contains(treatWeek)) {

        List<Integer> addWeekList = toWeekList.stream()
          .filter(w -> !Objects.equals(w, treatWeek))
          .collect(Collectors.toList());

        for (Integer toWeek : addWeekList) {
          createCopyIfInRange(
            treatmentInstance, toWeek, indTreatStartDate, endDate,
            facilityCd, treatmentInstanceCopyList
          );
        }

        treatmentInstance.setChangeType(TreatmentInstance.ChangeType.MOVE);
        continue;
      }

      // ④ 自身曜日を含まない場合（最小値は MOVE、その他は COPY）
      int minToWeek = Collections.min(toWeekList);

      TreatmentInstance base = new TreatmentInstance(treatmentInstance);

      for (Integer toWeek : toWeekList) {

        String toTreatDate = getDateOfWeek(base.getTreatDate(), toWeek);

        if (TreatmentInstance.Source.ORD_MAIN.equals(base.getSource())
          && !isInRange(toTreatDate, indTreatStartDate, endDate)) {
          // 移動後の日付がスケジュール延長最終日を超える場合、データを削除する
          treatmentInstance.setBeforeIndScheduleInfo(
            buildChangeBefore(treatmentInstance, treatmentInstance.getTreatDate(), facilityCd)
          );
          treatmentInstance.setAfterIndScheduleInfo(
            buildChangeAfter(treatmentInstance, null, facilityCd)
          );
          treatmentInstance.setChangeType(TreatmentInstance.ChangeType.DELETE);
          continue;
        }

        if (toWeek.equals(minToWeek)) {

          TreatmentInstance target = treatmentInstance;

          IndScheduleInfo before =
            buildChangeBefore(base, base.getTreatDate(), facilityCd);

          target.setChangeType(TreatmentInstance.ChangeType.MOVE);
          target.setBedCd(base.getBedCd());
          target.setMoveBeforeTreatDate(base.getTreatDate());
          target.setTreatDate(toTreatDate);
          target.setTreatWeek(toWeek);
          target.setBeforeIndScheduleInfo(before);
          target.setAfterIndScheduleInfo(
            buildChangeAfter(target, toTreatDate, facilityCd)
          );

        } else {

          TreatmentInstance copy = new TreatmentInstance(base);
          copy.setTreatDate(toTreatDate);
          copy.setTreatWeek(toWeek);
          copy.setChangeType(TreatmentInstance.ChangeType.COPY);
          copy.setAfterIndScheduleInfo(
            buildChangeAfter(copy, toTreatDate, facilityCd)
          );

          treatmentInstanceCopyList.add(copy);
        }
      }
    }
    treatmentInstanceList.addAll(treatmentInstanceCopyList);
    return treatmentInstanceList;
  }

  /**
   * 治療開始日から、週末（日曜日）または指定終了日までの
   * 日付および曜日を算出する。
   *
   * indTreatStartDate を起点とし、その週の日曜日を週末として取得する。
   * ただし、日曜日が endDate を超える場合は endDate を終了日とする。
   * 開始日から終了日まで（開始日・終了日を含む）の
   * 日付（yyyyMMdd）と対応する曜日をリストに追加する。
   *
   * @param indTreatStartDate 治療開始日（yyyyMMdd）
   * @param endDate           計算対象の終了日（yyyyMMdd）
   * @param firstDateList     出力用：日付リスト（yyyyMMdd）
   * @param firstWeekList     出力用：曜日リスト（1=月曜日 ～ 7=日曜日）
   */
  public void calcDatesAndWeeksUntilWeekend(

    String indTreatStartDate,
    String endDate,
    List<String> firstDateList,
    List<Integer> firstWeekList
  ) {
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");

    LocalDate startDate = LocalDate.parse(indTreatStartDate, formatter);
    LocalDate end = LocalDate.parse(endDate, formatter);

    LocalDate sunday = startDate.with(DayOfWeek.SUNDAY);
    LocalDate actualEnd = sunday.isBefore(end) ? sunday : end;

    for (LocalDate d = startDate; !d.isAfter(actualEnd); d = d.plusDays(1)) {
      firstDateList.add(d.format(formatter));
      firstWeekList.add((Integer) d.getDayOfWeek().getValue());
    }
  }

  /**
   * 基準日から指定された曜日の日付を取得する。
   * treatDateStr を基準日とし、同一週内に存在する
   * 指定曜日（toWeek）の日付を算出する。
   *
   * 基準日の曜日と指定曜日の差分が 7 日以上となる場合は、
   * 同一週とみなさず null を返却する。
   *
   * @param treatDateStr 基準日（yyyyMMdd）
   * @param toWeek       取得対象の曜日（1=月曜日 ～ 7=日曜日）
   * @return 指定曜日の日付（yyyyMMdd）。同一週内に存在しない場合は null
   */
  public static String getDateOfWeek(String treatDateStr, int toWeek) {
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    LocalDate treatDate = LocalDate.parse(treatDateStr, formatter);

    DayOfWeek targetDay = DayOfWeek.of(toWeek);

    DayOfWeek treatDayOfWeek = treatDate.getDayOfWeek();

    int dayDiff = targetDay.getValue() - treatDayOfWeek.getValue();

    LocalDate resultDate = treatDate.plusDays(dayDiff);

    if (Math.abs(dayDiff) >= 7) {
      return null;
    }

    return resultDate.format(formatter);
  }

  @Override
  public List<OrdMain> selectMoveTarget(
    Long pat_id,
    String facility_cd,
    String dialysis_date_from,
    String dialysis_date_to,
    String rst_dialysis_state,
    Integer treatment_cd,
    List<Integer> treat_week,
    boolean hasIndKurCd) {
    return ordMainDao.selectMoveTarget(pat_id, facility_cd, dialysis_date_from, dialysis_date_to, rst_dialysis_state, treatment_cd, treat_week,hasIndKurCd);
  }

  public IndScheduleInfo buildChangeBefore(TreatmentInstance treatmentInstance, String treatDate, String facilityCd) {
    IndScheduleInfo info = new IndScheduleInfo();
    info.setOrdNo(treatmentInstance.getOrdNo());
    info.setFacilityCd(facilityCd);
    info.setPatId(treatmentInstance.getPatId());
    info.setIndBedCd(treatmentInstance.getBedCd() != null ? treatmentInstance.getBedCd().longValue() : 0L);
    info.setIndKurCd(treatmentInstance.getKurCd() != null ? treatmentInstance.getKurCd() .longValue() : 0L);
    info.setTreatDate(treatDate);
    return info;
  }
  public IndScheduleInfo buildChangeAfter(TreatmentInstance treatmentInstance, String treatDate, String facilityCd) {
    IndScheduleInfo info = new IndScheduleInfo();
    info.setFacilityCd(facilityCd);
    info.setIndBedCd(treatmentInstance.getBedCd() != null ? treatmentInstance.getBedCd().longValue() : 0L);
    info.setIndKurCd(treatmentInstance.getKurCd()  != null ? treatmentInstance.getKurCd() .longValue() : 0L);
    info.setTreatDate(treatDate);
    info.setOrdNo(null);
    return info;
  }

  /**
   * ORD_MAIN の検索結果を TreatmentInstance に変換する
   */
  private TreatmentInstance convertOrdMainToTreatmentInstance(
    TreatmentInstanceSourceDto dto) {

    TreatmentInstance instance = new TreatmentInstance();

    instance.setPatId(dto.getPatId());
    instance.setOrdNo(dto.getOrdNo());

    instance.setIndTreatmentCd(dto.getIndTreatmentCd());
    instance.setKurCd(dto.getIndKurCd());
    instance.setBedCd(dto.getIndBedCd());

    instance.setTreatWeek(dto.getTreatWeek().intValue());

    instance.setTreatDate(dto.getTreatDate());

    instance.setStart(dto.getTreatStartTime());
    instance.setTreatTime(dto.getTreatTime());
    instance.setKurName(dto.getKurName());
    instance.setBedName(dto.getBedName());
    instance.setIndMediInfo(dto.getIndMediInfo());

    instance.setSource(TreatmentInstance.Source.ORD_MAIN);

    instance.setRstDialysisState(dto.getRstDialysisState());

    instance.setTreatType(dto.getTreatType());

    return instance;
  }

  /**
   * 指定された日付が処理対象期間内かを判定する。
   *
   * @param targetDate 判定対象日（yyyyMMdd）
   * @param startDate  処理開始日（yyyyMMdd）
   * @param endDate    処理終了日（yyyyMMdd）
   * @return 対象期間内の場合 true
   */
  public boolean isInRange(
    String targetDate,
    String startDate,
    String endDate
  ) {
    if (targetDate == null) {
      return false;
    }
    return startDate.compareTo(targetDate) <= 0
      && targetDate.compareTo(endDate) <= 0;
  }

  /**
   * 指定曜日への移動が処理対象期間内の場合に、COPYデータを作成する。
   *
   * <p>
   * 移動先曜日から治療日を算出し、対象期間内であれば
   * 元データを元に COPY データを作成する。
   * </p>
   *
   * @param base                    元となる治療データ
   * @param toWeek                  移動先曜日
   * @param indTreatStartDate       処理開始日（yyyyMMdd）
   * @param endDate                 処理終了日（yyyyMMdd）
   * @param facilityCd              施設コード
   * @param treatmentInstanceCopies COPYデータ格納先
   */
  private void createCopyIfInRange(
    TreatmentInstance base,
    int toWeek,
    String indTreatStartDate,
    String endDate,
    String facilityCd,
    List<TreatmentInstance> treatmentInstanceCopies
  ) {
    String toTreatDate = getDateOfWeek(base.getTreatDate(), toWeek);

    if (TreatmentInstance.Source.ORD_MAIN.equals(base.getSource()) && !isInRange(toTreatDate, indTreatStartDate, endDate)) {
      return;
    }

    TreatmentInstance copy = new TreatmentInstance(base);
    copy.setTreatDate(toTreatDate);
    copy.setTreatWeek(toWeek);
    copy.setChangeType(TreatmentInstance.ChangeType.COPY);
    copy.setAfterIndScheduleInfo(
      buildChangeAfter(base, toTreatDate, facilityCd)
    );
    copy.setSource(base.getSource());

    treatmentInstanceCopies.add(copy);
  }

  public void processWeekChangeLinkedPatterns(
    List<OrdMain> delOrdMainList,
    List<Integer> weekdayChangeDelWeekList,
    Long patId,
    String facilitySetting1007SelectedVal,
    String facilitySetting1008SelectedVal,
    String facilityCd,
    Long indUserId,
    Long updUserId,
    String flag) {

    List<Integer> delWeekList = new ArrayList<>();

    if (Objects.equals("weekChange",flag)) {
      delWeekList = weekdayChangeDelWeekList;
    } else if (Objects.equals("indDelete",flag)) {
      if (!CollectionUtils.isEmpty(delOrdMainList)) {
        delWeekList = delOrdMainList.stream().map(i -> i.getTreatWeek().intValue()).distinct().collect(Collectors.toList());
      }
    }

    if (CollectionUtils.isEmpty(delWeekList)) {
      return;
    }

    if (!Objects.equals("3", facilitySetting1007SelectedVal)) {
      patExamPatternDao.deleteExamPatternByExamWeekList(
        facilityCd, patId, delWeekList, indUserId, updUserId);
    }
    if (!Objects.equals("3", facilitySetting1008SelectedVal)) {
      patRadPatternDao.deleteRadPatternByRadWeekList(
        facilityCd, patId, delWeekList, indUserId, updUserId);
    }
  }

  private <T> List<WeekChangeInfo> generateWeekChangeScheduleList(
    List<WeekChangeInfo> changeList,
    List<T> examPatternList,
    Function<T, Integer> getExamWeek,
    Function<T, Integer> getExamPattern,
    Function<T, Long> getExamPatternCd,
    Function<T, Timestamp> getRegExamDate,
    Function<T, Long> getPatId
  ) {
    List<WeekChangeInfo> resultList = new ArrayList<>();

    for (WeekChangeInfo change : changeList) {
      Integer oldWeek = change.getOldTreatWeek();
      Integer newWeek = change.getNewTreatWeek();

      List<T> matchedPatterns = examPatternList.stream()
        .filter(p -> Objects.equals(getExamWeek.apply(p), oldWeek))
        .collect(Collectors.toList());

      if (matchedPatterns.isEmpty()) continue;

      for (T pattern : matchedPatterns) {
        LocalDate baseDate = getRegExamDate.apply(pattern).toLocalDateTime().toLocalDate();
        int year = baseDate.getYear();
        int month = baseDate.getMonthValue();

        LocalDate newScheduleDate = getScheduleDateByPattern(
          getExamPattern.apply(pattern),
          year,
          month,
          newWeek
        );

        WeekChangeInfo r = new WeekChangeInfo();
        r.setPatId(getPatId.apply(pattern));
        r.setOldTreatWeek(oldWeek);
        r.setNewTreatWeek(newWeek);
        r.setTreatWeek(newWeek);
        r.setPatternCd(getExamPatternCd.apply(pattern));
        r.setRegScheduleDate(Timestamp.valueOf(newScheduleDate.atStartOfDay()));
        r.setPatternCategory(getExamPattern.apply(pattern));
        resultList.add(r);
      }
    }

    return resultList;
  }

  private LocalDate getScheduleDateByPattern(Integer patternCd, int year, int month, int targetWeekday) {
    LocalDate firstDay = LocalDate.of(year, month, 1);

    while (firstDay.getDayOfWeek().getValue() != targetWeekday) {
      firstDay = firstDay.plusDays(1);
    }

    switch (patternCd) {
      case 2:
        return firstDay; //第1週
      case 3:
        return firstDay.plusWeeks(1); //第2週
      case 4:
        return firstDay.plusWeeks(2); //第3週
      case 5:
        return firstDay.plusWeeks(3); //第4週
      case 6: //月2：第1週、第3週→第1個を取る
        return firstDay;
      case 7: //月2：第2週、第4週→第2週を取る
        return firstDay.plusWeeks(1);
      case 9: //隔週
        return firstDay;
      default:
        return firstDay;
    }
  }
  // 曜日無期限変更パターン更新
  private boolean changeWeekdayPattern(
    String facilityCd,
    List<TreatmentInstance> treatmentInstanceList,
    WeekPatternResponse weekPatternDataInfo,
    IndscheduleChangeUserSelectedInfo userSelectedInfo,
    Long indUser,
    Long updUser
  ) {
    if (Boolean.TRUE.equals(weekPatternDataInfo.getIsEndDateUnset())) {
      return true;
    }

    try {
      // ① 変更範囲内削除
      Map<PatTreatmentPatternService.RESULT_TYPE, List<PatTreatmentPattern>> deleteResponse =
        deletePatterns(facilityCd, treatmentInstanceList, weekPatternDataInfo);

      // ② 変更範囲内挿入
      insertPatterns(facilityCd, treatmentInstanceList, weekPatternDataInfo, deleteResponse);

      // ③ 変更範囲外更新（other pattern bed = 0）
      updateOtherPatientBeds(facilityCd, treatmentInstanceList, weekPatternDataInfo);

      // ④ 一般検査・一般撮影パターン移動
      moveExamAndRadActualByWeekPatternChange(weekPatternDataInfo, facilityCd, userSelectedInfo, indUser, updUser);
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  private Map<PatTreatmentPatternService.RESULT_TYPE, List<PatTreatmentPattern>> deletePatterns(
    String facilityCd,
    List<TreatmentInstance> treatmentInstanceList,
    WeekPatternResponse weekPatternDataInfo
  ) {

    Long patId = weekPatternDataInfo.getPatId();
    Integer treatmentCd = weekPatternDataInfo.getTreatmentCd();

    List<TreatmentInstance> patPatternInstances =
      treatmentInstanceList.stream()
        .filter(i ->
          i.getSource() == TreatmentInstance.Source.PAT_TREATMENT_PATTERN
            && Objects.equals(i.getPatId(), patId)
        )
        .collect(Collectors.toList());

    List<TreatmentInstance> delPatternList =
      patPatternInstances.stream()
        .filter(i -> i.getChangeType() == TreatmentInstance.ChangeType.MOVE)
        .collect(Collectors.toList());

    List<Long> indKurCds =
      delPatternList.stream()
        .map(TreatmentInstance::getKurCd)
        .map(k -> k == null ? 0L : k.longValue())
        .distinct()
        .collect(Collectors.toList());

    PatTreatmentPatternKey key = new PatTreatmentPatternKey(
      patId,
      facilityCd,
      List.of(treatmentCd),
      indKurCds,
      weekPatternDataInfo.getFromWeekList(),
      null,
      new HashMap<>()
    );

    PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();
    delta.getDeletes().add(key);

    return patTreatmentPatternService.applyPatTreatmentPatterns(delta);
  }
  private void insertPatterns(
    String facilityCd,
    List<TreatmentInstance> treatmentInstanceList,
    WeekPatternResponse weekPatternDataInfo,
    Map<PatTreatmentPatternService.RESULT_TYPE, List<PatTreatmentPattern>> responseMap
  ) {

    Long patId = weekPatternDataInfo.getPatId();

    List<TreatmentInstance> basePatternList =
      treatmentInstanceList.stream()
        .filter(i ->
          i.getSource() == TreatmentInstance.Source.PAT_TREATMENT_PATTERN
            && Objects.equals(i.getPatId(), patId)
        )
        .collect(Collectors.toList());

    Map<Long, List<Integer>> ordNoTreatWeekMap =
      basePatternList.stream()
        .filter(i -> i.getOrdNo() != null && i.getTreatWeek() != null)
        .collect(Collectors.groupingBy(
          TreatmentInstance::getOrdNo,
          Collectors.mapping(
            TreatmentInstance::getTreatWeek,
            Collectors.collectingAndThen(Collectors.toSet(), s -> s.stream().sorted().toList())
          )
        ));

    Map<String, TreatmentInstance> basePatternMap =
      basePatternList.stream()
        .filter(i ->
          i.getIndTreatmentCd() != null
            && i.getKurCd() != null
            && i.getTreatWeek() != null
            && i.getOrdNo() != null
        )
        .collect(Collectors.toMap(
          i -> i.getIndTreatmentCd()
            + "_" + i.getKurCd()
            + "_" + i.getTreatWeek()
            + "_" + i.getOrdNo(),
          Function.identity(),
          (a, b) -> a
        ));

    PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();

    for (List<PatTreatmentPattern> patternList : responseMap.values()) {
      if (patternList == null || patternList.isEmpty()) continue;

      for (PatTreatmentPattern pattern : patternList) {

        List<Integer> treatWeeks = ordNoTreatWeekMap.get(pattern.getCtlNo());
        if (treatWeeks == null) continue;

        for (Integer treatWeek : treatWeeks) {

          PatTreatmentPatternKey insKey = new PatTreatmentPatternKey(
            pattern.getPatId(),
            facilityCd,
            List.of(pattern.getIndTreatmentCd()),
            List.of(pattern.getIndKurCd()),
            List.of(treatWeek),
            null,
            Map.of()
          );

          PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(insKey);

          upsert.setIndTreatmentCd(pattern.getIndTreatmentCd());
          upsert.setIndKurCd(Long.valueOf(pattern.getIndKurCd()));
          upsert.setTreatType(pattern.getTreatType());
          upsert.setIndTreatStartDate(pattern.getIndTreatStartDate());

          addOverwrite(upsert, PatTreatmentPatternFieldEnum.IND_COND_INFO, pattern.getIndCondInfo());
          addOverwrite(upsert, PatTreatmentPatternFieldEnum.IND_MEDI_INFO, pattern.getIndMediInfo());
          addOverwrite(upsert, PatTreatmentPatternFieldEnum.IND_EQUIP_INFO, pattern.getIndEquipInfo());
          addOverwrite(upsert, PatTreatmentPatternFieldEnum.IND_COMMENT_INFO, pattern.getIndIndCommentInfo());
          addOverwrite(upsert, PatTreatmentPatternFieldEnum.IND_DEVICE_SET_INFO, pattern.getIndDeviceSetInfo());

          String key =
            pattern.getIndTreatmentCd()
              + "_" + pattern.getIndKurCd()
              + "_" + treatWeek
              + "_" + pattern.getCtlNo();

          int bedCd = Optional.ofNullable(basePatternMap.get(key))
            .map(TreatmentInstance::getBedCd)
            .orElse(0);

          JSONObject schJson = Optional.ofNullable(pattern.getIndSchInfo())
            .map(JSONObject::new)
            .orElseGet(JSONObject::new);

          schJson.put("ind_bed_cd", bedCd);

          addOverwrite(upsert, PatTreatmentPatternFieldEnum.IND_SCH_INFO, schJson.toString());

          delta.getInserts().add(upsert);
        }
      }
    }

    patTreatmentPatternService.applyPatTreatmentPatterns(delta);
  }

  private void addOverwrite(
    PatTreatmentPatternUpsert upsert,
    PatTreatmentPatternFieldEnum field,
    String jsonValue
  ) {
    if (jsonValue == null) {
      return;
    }

    upsert.addJsonbUpdate(
      field,
      new PatTreatmentPatternJsonbField(
        PatTreatmentPatternUpdateModeEnum.OVERWRITE,
        jsonValue
      )
    );
  }

  private void updateOtherPatientBeds(
    String facilityCd,
    List<TreatmentInstance> treatmentInstanceList,
    WeekPatternResponse weekPatternDataInfo
  ) {

    Long patId = weekPatternDataInfo.getPatId();

    List<TreatmentInstance> targets =
      treatmentInstanceList.stream()
        .filter(i ->
          i.getSource() == TreatmentInstance.Source.PAT_TREATMENT_PATTERN
            && !Objects.equals(i.getPatId(), patId)
            && (i.getBedCd() == null || i.getBedCd() == 0)
        )
        .collect(Collectors.toList());

    if (targets.isEmpty()) return;

    PatTreatmentPatternDelta delta = new PatTreatmentPatternDelta();

    for (TreatmentInstance oth : targets) {

      PatTreatmentPatternKey key = new PatTreatmentPatternKey(
        oth.getPatId(),
        facilityCd,
        List.of(oth.getIndTreatmentCd()),
        List.of(
          oth.getKurCd() == null ? 0L : oth.getKurCd().longValue()
        ),
        List.of(oth.getTreatWeek()),
        null,
        Map.of()
      );

      JSONObject json = new JSONObject();
      json.put("ind_bed_cd", 0);

      PatTreatmentPatternUpsert upsert = new PatTreatmentPatternUpsert(key);
      upsert.addJsonbUpdate(
        PatTreatmentPatternFieldEnum.IND_SCH_INFO,
        new PatTreatmentPatternJsonbField(
          PatTreatmentPatternUpdateModeEnum.MERGE,
          json.toString()
        )
      );

      delta.getUpdates().add(upsert);
    }

    patTreatmentPatternService.applyPatTreatmentPatterns(delta);
  }
  private void moveExamAndRadActualByWeekPatternChange(
    WeekPatternResponse weekPatternDataInfo,
    String facilityCd,
    IndscheduleChangeUserSelectedInfo indscheduleChangeUserSelectedInfo,
    Long indUserId,
    Long updUserId) {

    Long patId = weekPatternDataInfo.getPatId();

    Map<Integer, Integer> changeWeekMap = weekPatternDataInfo.getChangeWeekMap();

    List<WeekChangeInfo> changeList = changeWeekMap.entrySet().stream().filter(e -> !Objects.equals(e.getValue(), e.getKey()))
      .map(e -> {
        WeekChangeInfo info = new WeekChangeInfo();
        info.setOldTreatWeek(e.getKey());
        info.setNewTreatWeek(e.getValue());
        return info;
      })
      .collect(Collectors.toList());

    List<Integer> oldWeekList = new ArrayList<>(changeWeekMap.keySet());

    List<Integer> delWeekList = changeList.stream()
      .map(WeekChangeInfo::getOldTreatWeek)
      .collect(Collectors.toList());

    if (indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal() != null) {
      switch (indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal()) {
        case "1":
          if (CollectionUtils.isEmpty(oldWeekList) || CollectionUtils.isEmpty(changeList)) {
            break;
          }

          List<PatExamPattern> patternList = patExamPatternDao.selectExamPatternByExamWeekList(facilityCd, patId, oldWeekList);

          if (CollectionUtils.isEmpty(patternList)) {
            break;
          }

          List<WeekChangeInfo> updatedWeekChangeList = generateWeekChangeScheduleList(
            changeList,
            patternList,
            PatExamPattern::getExamWeek,
            PatExamPattern::getExamPattern,
            PatExamPattern::getExamPatternCd,
            PatExamPattern::getRegExamDate,
            PatExamPattern::getPatId
          );

          if (!CollectionUtils.isEmpty(updatedWeekChangeList)) {
            patExamPatternDao.updateExamWeekByChangeWeek(
              facilityCd, patId, updatedWeekChangeList, indUserId, updUserId
            );
          }
          break;
        case "2":
          if (!CollectionUtils.isEmpty(delWeekList)) {
            patExamPatternDao.deleteExamPatternByExamWeekList(
              facilityCd, patId, delWeekList, indUserId, updUserId
            );
          }
          break;
        default:
          break;
      }
    }
    if (indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal() != null) {
      switch (indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal()) {
        case "1":
          if (CollectionUtils.isEmpty(oldWeekList) || CollectionUtils.isEmpty(changeList)) {
            break;
          }

          List<PatRadPattern> patternList = patRadPatternDao.selectRadPatternByRadWeekList(facilityCd, patId, oldWeekList);

          if (CollectionUtils.isEmpty(patternList)) {
            break;
          }

          List<WeekChangeInfo> updatedWeekChangeList = generateWeekChangeScheduleList(
            changeList,
            patternList,
            PatRadPattern::getRadWeek,
            PatRadPattern::getRadPattern,
            PatRadPattern::getRadPatternCd,
            PatRadPattern::getRegRadDate,
            PatRadPattern::getPatId
          );
          if (!CollectionUtils.isEmpty(updatedWeekChangeList)) {
            patRadPatternDao.updateRadWeekByChangeWeek(
              facilityCd, patId, updatedWeekChangeList, indUserId, updUserId
            );
          }
          break;
        case "2":
          if (!CollectionUtils.isEmpty(delWeekList)) {
            patRadPatternDao.deleteRadPatternByRadWeekList(
              facilityCd, patId, delWeekList, indUserId, updUserId
            );
          }
          break;
        default:
          break;
      }
    }
  }
}
