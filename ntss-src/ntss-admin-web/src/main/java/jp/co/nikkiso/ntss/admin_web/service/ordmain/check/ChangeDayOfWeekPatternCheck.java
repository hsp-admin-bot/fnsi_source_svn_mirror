package jp.co.nikkiso.ntss.admin_web.service.ordmain.check;

import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.service.changeWeekPattern.WeekPatternInfoService;
import jp.co.nikkiso.ntss.admin_web.service.changeWeekPattern.WeekPatternInfoServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.IndScheduleDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadPatternDao;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.dto.indSchedule.OrdNoAndConnectedTableKeyData;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.PatExamPattern;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentInstance;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.json.JSONArray;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Component
public class ChangeDayOfWeekPatternCheck {
  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  @Autowired
  private WeekPatternInfoService weekPatternInfoService;

  @Autowired
  private MstKurDao mstKurDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private IndScheduleServiceImpl indScheduleServiceImpl;

  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  private PatExamPatternDao patExamPatternDao;

  @Autowired
  private PatRadPatternDao patRadPatternDao;

  @Autowired
  private IndScheduleDao indScheduleDao;

  @Autowired
  private WeekPatternInfoServiceImpl weekPatternInfoServiceImpl;

  @Getter
  @Setter
  @AllArgsConstructor
  public static class OwnBedConflictResult {
    private boolean hasConflict;
    private List<TreatmentInstance> survivedList;
    private List<TreatmentInstance> bedUnsetList;

    public OwnBedConflictResult() {

    }
  }

  @Getter
  public static class BedKickInfo {
    private Long ordNo;
    private String treatDate;
    private Short treatWeek;
    private String kurName;
    private String bedName;

    public BedKickInfo(
      Long ordNo,
      String treatDate,
      Short treatWeek,
      String kurName,
      String bedName) {
      this.ordNo = ordNo;
      this.treatDate = treatDate;
      this.treatWeek = treatWeek;
      this.kurName = kurName;
      this.bedName = bedName;
    }
  }

  @Getter
  @AllArgsConstructor
  public static class BedConflictResult {
    private List<TreatmentInstance> selfConflictList;
    private List<TreatmentInstance> otherConflictList;
    private Boolean hasConflict;
  }

  @Getter
  @Setter
  public class DeleteLinkageCheckResult {
    private Map<String, List<String>> linkageMessage;
    private boolean hasPatEvent;
    private boolean hasExam;
    private boolean hasRad;
  }

  public UpdateScheduleListDataResponse validateDayOfWeekPatternChange(List<TreatmentInstance> weekMoveRuleList, List<Long> delOrdNoList,
                                                                       WeekPatternResponse weekResponse, IndscheduleChangeUserSelectedInfo indscheduleChangeUserSelectedInfo ) {

    // 処理変数定義
    String message = "";
    final String className = new Object() {}.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {}.getClass().getEnclosingMethod().getName();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    List<String> msgCdList = new ArrayList<>();

    UpdateScheduleListDataResponse responseInfo = new UpdateScheduleListDataResponse();

    SelectOptions options = SelectOptions.get();

    String facilityCd = weekResponse.getFacilityCd();
    List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, facilityCd, "0");

    String footerFlg =  weekResponse.getFooterFlg();

    List<Long> patIdList = new ArrayList<>();

    Long patId = weekResponse.getPatId();

    List<Integer> delWeekList = weekResponse.getDelWeekList();

    List<IndScheduleInfo> toBeOrdScheduleListAllForCheak = new ArrayList<>();

    List<IndScheduleInfo> beforeIndScheduleInfo = new ArrayList<>();

    List<TreatmentInstance> othFilteredList = new ArrayList<>();

    boolean hasPatEvent = false;
    boolean hasExam = false;
    boolean hasRad = false;
    boolean conflictMessageFlag = false;

    if (weekMoveRuleList != null && !weekMoveRuleList.isEmpty()) {

      List<TreatmentInstance> ownFilteredList =
        Optional.ofNullable(weekMoveRuleList)
          .orElse(Collections.emptyList())
          .stream()
          .collect(Collectors.toList());

      // 範囲内における治療開始日時と治療終了日時を基に計算する
      calcAndResetStartEnd(ownFilteredList, mstKurList);

      // 範囲外予定の検索条件を作成する
      List<Long> ownOrdNoList =
        ownFilteredList.stream()
          .filter(i -> i.getSource() == TreatmentInstance.Source.ORD_MAIN)
          .map(TreatmentInstance::getOrdNo)
          .distinct()
          .collect(Collectors.toList());

      List<Integer> bedList =
        ownFilteredList.stream()
          .filter(i -> i.getSource() == TreatmentInstance.Source.ORD_MAIN)
          .map(TreatmentInstance::getBedCd)
          .distinct()
          .collect(Collectors.toList());

      List<Long> ownCtlNoList =
        ownFilteredList.stream()
          .filter(i -> i.getSource() == TreatmentInstance.Source.PAT_TREATMENT_PATTERN)
          .map(TreatmentInstance::getOrdNo)
          .distinct()
          .collect(Collectors.toList());

      List<Integer> patternBedList =
        ownFilteredList.stream()
          .filter(i -> i.getSource() == TreatmentInstance.Source.PAT_TREATMENT_PATTERN)
          .map(TreatmentInstance::getBedCd)
          .distinct()
          .collect(Collectors.toList());

      // 範囲外予定の検索範囲を算出する
      Map<String, String> dateRange = calcMinMaxDateString(ownFilteredList);

      String startDate = dateRange.get("minDate");
      String endDate = dateRange.get("maxDate");

      List<TreatmentInstance> othTreatmentInstanceList =
        weekPatternInfoService
          .expandAndMergeOrdMainAndPatternToTreatmentInstances(
            weekResponse,
            startDate,
            endDate,
            ownOrdNoList,
            bedList,
            ownCtlNoList,
            patternBedList
          );

      // 範囲外で、ベッドおよび KUR が 0 ではないデータを抽出する
      othFilteredList =
        Optional.ofNullable(othTreatmentInstanceList)
          .orElse(Collections.emptyList())
          .stream()
          .filter(i -> i.getBedCd() != null && i.getBedCd().intValue() != 0)
          .filter(i -> i.getKurCd() != null && i.getKurCd().intValue() != 0)
          .filter(i -> !(Objects.equals(i.getPatId(), patId) && delWeekList.contains(i.getTreatWeek())))
          .collect(Collectors.toList());

      if (othFilteredList != null) {
        for (TreatmentInstance treatmentInstance : othFilteredList) {
          treatmentInstance.setBeforeIndScheduleInfo(
            weekPatternInfoServiceImpl.buildChangeBefore(treatmentInstance, treatmentInstance.getTreatDate(), facilityCd));

          treatmentInstance.setAfterIndScheduleInfo(
            weekPatternInfoServiceImpl.buildChangeAfter(treatmentInstance, treatmentInstance.getTreatDate(), facilityCd)
          );
        }
      }
      // 範囲外における治療開始日時と治療終了日時を基に計算する
      calcAndResetStartEnd(othFilteredList, mstKurList);

      patIdList.addAll(ownFilteredList.stream()
        .map(TreatmentInstance::getPatId)
        .collect(Collectors.toList()));

      patIdList.addAll(othFilteredList.stream()
        .map(TreatmentInstance::getPatId)
        .collect(Collectors.toList()));

      Map<Long, String> patNameMap;

      if (patIdList.isEmpty()) {
        patNameMap = Collections.emptyMap();
      } else {
        List<PatPersonalMain> patPersonalMainList =
          patPersonalMainDao.selectByIdListFacilityCd(
            patIdList,
            weekResponse.getFacilityCd()
          );

        patNameMap =
          Optional.ofNullable(patPersonalMainList)
            .orElse(Collections.emptyList())
            .stream()
            .collect(Collectors.toMap(
              PatPersonalMain::getPat_id,
              p -> p.getPat_last_name() + p.getPat_first_name(),
              (v1, v2) -> v1
            ));
      }

      List<TreatmentInstance> rstOwnFilteredList = Optional.ofNullable(othTreatmentInstanceList)
        .orElse(Collections.emptyList())
        .stream()
        .filter(i -> !Objects.equals(i.getRstDialysisState(), "0") && Objects.equals(i.getSource()
          ,TreatmentInstance.Source.ORD_MAIN) && Objects.equals(i.getPatId() ,patId))
        .collect(Collectors.toList());

      ownFilteredList.addAll(rstOwnFilteredList);
      if (checkSameDaySameKurTreatmentDuplicate(ownFilteredList)) {
        message += "同日、同クール、同治療方法の予定が存在するため登録できません。";
        eventLogMessage.setLogMessage(className + "." + methodName + message);
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        responseInfo.setMessage(message);
        responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        responseInfo.setMsgCd("00400016");
        return responseInfo;
      }

      String conflictMessage = "";
      List<TreatmentInstance> bedUnsetList = new ArrayList<>();
      // 変更範囲内の競合実績チェック
      List<TreatmentInstance> rstOthFilteredList = Optional.ofNullable(othTreatmentInstanceList)
        .orElse(Collections.emptyList())
        .stream()
        .filter(i -> !Objects.equals(i.getRstDialysisState(), "0") && Objects.equals(i.getSource() ,TreatmentInstance.Source.ORD_MAIN))
        .collect(Collectors.toList());

      OwnBedConflictResult rstResult = new OwnBedConflictResult();
      if (rstOthFilteredList != null && !rstOthFilteredList.isEmpty()) {
         rstResult = detectMovedVsRstUnmovedConflicts(weekMoveRuleList, rstOthFilteredList);
        bedUnsetList.addAll(rstResult.getBedUnsetList());
      }

      // 変更範囲内の競合チェック
      OwnBedConflictResult result = resolveOwnBedConflict((bedUnsetList != null && !bedUnsetList.isEmpty()) ? rstResult.getSurvivedList() : weekMoveRuleList, facilityCd);

      bedUnsetList.addAll(result.getBedUnsetList());

      // 範囲外の競合チェック
      if (!CollectionUtils.isEmpty(result.getSurvivedList())
        && !CollectionUtils.isEmpty(othFilteredList)) {

        BedConflictResult conflictResult = detectMovedVsUnmovedConflicts(result.getSurvivedList(), othFilteredList);

        if (conflictResult.hasConflict) {
          if (footerFlg == null) {

            message += "競合する予定。";
            msgCdList.add("00400015");
            responseInfo.setMsgCdList(msgCdList);

          }else if (footerFlg != null) {

            if ("1".equals(footerFlg)) {
              conflictResult.getOtherConflictList()
                .forEach(ti -> {
                  ti.setBedCd(0);
                  bedUnsetList.add(ti);
                });
            }else if ("2".equals(footerFlg)) {
              conflictResult.getSelfConflictList()
                .forEach(ti -> {
                  ti.setBedCd(0);
                  if (ti.getAfterIndScheduleInfo() == null) {
                    ti.setAfterIndScheduleInfo(new IndScheduleInfo());
                  }
                  ti.getAfterIndScheduleInfo().setIndBedCd(0L);

                  bedUnsetList.add(ti);
                });
            }
          }
        }
      }
      // 競合メッセージを作成する
      if (bedUnsetList != null && !bedUnsetList.isEmpty()) {
        conflictMessageFlag = true;

        Map<Integer, String> weekMap = Map.of(
          1, "月", 2, "火", 3, "水", 4, "木", 5, "金", 6, "土", 7, "日"
        );

        List<TreatmentInstance> ordMainBedUnsetList =
          bedUnsetList.stream()
            .filter(ti -> isOnOrBeforeEndDate(ti.getTreatDate(), weekResponse.getWeekChangeEndDate()))
            .collect(Collectors.toList());

        List<TreatmentInstance> patternBedUnsetList =
          bedUnsetList.stream()
            .filter(ti -> ti.getSource() == TreatmentInstance.Source.PAT_TREATMENT_PATTERN)
            .collect(Collectors.toList());

        if(ordMainBedUnsetList != null && !ordMainBedUnsetList.isEmpty()) {
          ordMainBedUnsetList.sort(
            Comparator
              // ① 治療日昇順（無効日付は最後）
              .comparing(
                (TreatmentInstance ti) -> {
                  String d = ti.getTreatDate();
                  return (d == null || d.length() != 8 || "00000000".equals(d))
                    ? "99999999"
                    : d;
                }
              )
              // ② 同一日の KUR 昇順
              .thenComparing(
                ti -> Optional.ofNullable(ti.getKurName()).orElse("")
              )
          );

          conflictMessage = ordMainBedUnsetList.stream()
            .map(ti -> buildMessage(ti, patNameMap, weekMap, true))
            .filter(Objects::nonNull)
            .distinct()
            .collect(Collectors.joining("\n"));
        }

        if (patternBedUnsetList != null && !patternBedUnsetList.isEmpty()) {

          patternBedUnsetList.sort(
            Comparator
              // 曜日順（月→日）
              .comparing(
                (TreatmentInstance ti) ->
                  Optional.ofNullable(ti.getTreatWeek()).orElse(9)
              )
              // ② KUR
              .thenComparing(
                ti -> Optional.ofNullable(ti.getKurName()).orElse("")
              )
          );

          String patternMessage =
            patternBedUnsetList.stream()
              .map(ti -> buildMessage(ti, patNameMap, weekMap, false))
              .filter(Objects::nonNull)
              .distinct()
              .collect(Collectors.joining("\n"));

          if (!patternMessage.isEmpty()) {
            if (!conflictMessage.isEmpty()) {
              conflictMessage += "\n";
            }
            conflictMessage += patternMessage;
          }
        }

        responseInfo.setConflictMessage(conflictMessage);
      }

      List<IndScheduleInfo> toBeOrdScheduleListGo = new ArrayList<>();

      List<TreatmentInstance> movedList =
        Optional.ofNullable(weekMoveRuleList)
          .orElseGet(Collections::emptyList)
          .stream()
          .filter(i -> i.getChangeType() == TreatmentInstance.ChangeType.MOVE &&
            i.getSource() != TreatmentInstance.Source.PAT_TREATMENT_PATTERN)
          .collect(Collectors.toList());

      for (TreatmentInstance item : movedList) {
        IndScheduleInfo indScheduleInfoGo = new IndScheduleInfo();

        if (item.getBeforeIndScheduleInfo() == null || item.getAfterIndScheduleInfo() == null) {
          continue;
        }
        indScheduleInfoGo.setFacilityCd(item.getBeforeIndScheduleInfo().getFacilityCd());
        Long ordNo = item.getBeforeIndScheduleInfo().getOrdNo();
        indScheduleInfoGo.setOrdNo(ordNo);
        indScheduleInfoGo.setPatId(item.getBeforeIndScheduleInfo().getPatId());
        indScheduleInfoGo.setOldTreatDate(item.getBeforeIndScheduleInfo().getTreatDate());
        indScheduleInfoGo.setTreatDate(item.getAfterIndScheduleInfo().getTreatDate());
        indScheduleInfoGo.setIndKurCd(item.getAfterIndScheduleInfo().getIndKurCd());
        indScheduleInfoGo.setIndBedCd(item.getBedCd() == null
          ? null
          : item.getBedCd().longValue());
        indScheduleInfoGo.setIndTreatmentCd(item.getIndTreatmentCd());
        indScheduleInfoGo.setIndTreatmentTime(item.getTreatTime());
        indScheduleInfoGo.setTreatWeek(item.getBeforeIndScheduleInfo().getTreatWeek());
        toBeOrdScheduleListGo.add(indScheduleInfoGo);

        beforeIndScheduleInfo.add(item.getBeforeIndScheduleInfo());
      }

      Map<String, List<IndScheduleInfo>> toBeOrdScheduleListGoMap = indScheduleServiceImpl.complementIndScheduleInfo(facilityCd, toBeOrdScheduleListGo, mstKurList);
      toBeOrdScheduleListGo = toBeOrdScheduleListGoMap.get("indScheduleInfoList");

      toBeOrdScheduleListAllForCheak.addAll(toBeOrdScheduleListGo);

      for(IndScheduleInfo toBeOrdSchedule : toBeOrdScheduleListAllForCheak){
        if(hasPatEvent && hasExam && hasRad) break;
        if(!hasPatEvent){
          int hasPatEventCount = 0;
          if(toBeOrdSchedule.getConnectedPatEventCdList() != null) hasPatEventCount = toBeOrdSchedule.getConnectedPatEventCdList().size();
          if(hasPatEventCount > 0) hasPatEvent = true;
        }
        if(!hasExam){
          int hasExamCount = 0;
          if(toBeOrdSchedule.getConnectedExamMainCdList() != null) hasExamCount = toBeOrdSchedule.getConnectedExamMainCdList().size();
          if(hasExamCount > 0) hasExam = true;
        }
        if(!hasRad){
          int hasRadCount = 0;
          if(toBeOrdSchedule.getConnectedRadResultCdList() != null) hasRadCount = toBeOrdSchedule.getConnectedRadResultCdList().size();
          if(hasRadCount > 0) hasRad = true;
        }
      }

      if(hasPatEvent || hasExam || hasRad) {
        boolean isChangeDay = false;
        for (int i = 0; i < toBeOrdScheduleListAllForCheak.size(); i++){
          if(!Objects.equals(toBeOrdScheduleListAllForCheak.get(i).getTreatDate(),toBeOrdScheduleListAllForCheak.get(i).getOldTreatDate())){
            isChangeDay = true;
            break;
          }
        }
        if(isChangeDay){
          List<FacilitySettingInfo> facilitySettingInfoList = mstFacilitySettingDao.selectFacilitySetting(facilityCd, null);
          Map<String, FacilitySettingInfo> facilitySettingInfoListMap = facilitySettingInfoList.stream().collect(Collectors.toMap(o -> o.getFacilitySettingNo(), o -> o));
          // 患者イベント
          if(hasPatEvent){
            if(!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getFacilitySetting3005SelectedVal())){
              if("4".equals(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.PAT_EVENT_CHANGE).getValue())){
                message += " 患者イベントの処理を選択してください";
                msgCdList.add("70000032");
              }else{
                indscheduleChangeUserSelectedInfo.setFacilitySetting3005SelectedVal(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.PAT_EVENT_CHANGE).getValue());
              }
            }
          }
          // 一般検査
          if(hasExam){
            if(!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal())){
              if("4".equals(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE).getValue())){
                message += " 一般検査の処理を選択してください";
                msgCdList.add("70000030");
              }else{
                indscheduleChangeUserSelectedInfo.setFacilitySetting1007SelectedVal(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE).getValue());
              }
            }
          }
          // X線検査
          if(hasRad){
            if(!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal())){
              if("4".equals(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE).getValue())){
                message += " X線検査の処理を選択してください";
                msgCdList.add("70000031");
              }else{
                indscheduleChangeUserSelectedInfo.setFacilitySetting1008SelectedVal(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE).getValue());
              }
            }
          }
          if(hasExam){
            // 検査依頼変更締切り有無 1015
            String examChangeOnOffWithOrder = facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.EXAM_CHANGE_ON_OFF_WITH_ORDER).getValue();
            if(examChangeOnOffWithOrder.equals("1")){
              // 検査依頼変更締切り日数 1011
              String examScheduleChangeLimitDay = facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_DAY).getValue();
              // 検査依頼変更締切り時間 1012
              String examScheduleChangeLimitTime = facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_TIME).getValue();

              List<IndScheduleInfo> indScheduleInfoList = toBeOrdScheduleListAllForCheak.stream().filter(i -> i.getConnectedExamMainCdList() != null
                && i.getConnectedExamMainCdList().size() > 0).collect(Collectors.toList());

              if (indScheduleInfoList != null && indScheduleInfoList.size() > 0) {
                boolean hasExamDeadLineRecords = checkOverDeadLine(indScheduleInfoList, examScheduleChangeLimitDay, examScheduleChangeLimitTime);
                if(hasExamDeadLineRecords){
                  if(!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getExamDeadlineSelectedVal())
                    && !"3".equals(indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal())){
                    message += " 一般検査の締切日が過ぎている予定移動があります";
                    msgCdList.add("70000033");
                  }
                }
              }
            }
          }
          if(hasRad){
            // 放射線検査依頼変更締切り有無 1016
            String radChangeOnOffWithOrder = facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.RAD_CHANGE_ON_OFF_WITH_ORDER).getValue();
            if(radChangeOnOffWithOrder.equals("1")){
              // 放射線検査依頼変更締切り日数 1013
              String radScheduleChangeLimitDay = facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_DAY).getValue();
              // 放射線検査依頼変更締切り時間 1014
              String radScheduleChangeLimitTime = facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_TIME).getValue();

              List<IndScheduleInfo> indScheduleInfoList = toBeOrdScheduleListAllForCheak.stream().filter(i -> i.getConnectedRadResultCdList() != null
                && i.getConnectedRadResultCdList().size() > 0).collect(Collectors.toList());

              if (indScheduleInfoList != null && indScheduleInfoList.size() > 0) {
                boolean hasRadDeadLineRecords = checkOverDeadLine(indScheduleInfoList, radScheduleChangeLimitDay, radScheduleChangeLimitTime);
                if(hasRadDeadLineRecords){
                  if(!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getRadDeadlineSelectedVal())
                    && !"3".equals(indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal())){
                    message += " 放射線検査の締切日が過ぎている予定移動があります";
                    msgCdList.add("70000034");
                  }
                }
              }
            }
          }
        }
      }
    }
    // 無期限変更時、一般撮影（X線）のパターンのみの場合にチェック
    if (weekResponse.getIsEndDateUnset() != null && !weekResponse.getIsEndDateUnset()
      && (!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal()) || !StringUtils.hasText(indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal()))) {

      List<FacilitySettingInfo> facilitySettingInfoList = mstFacilitySettingDao.selectFacilitySetting(facilityCd, null);
      Map<String, FacilitySettingInfo> facilitySettingInfoListMap = facilitySettingInfoList.stream().collect(Collectors.toMap(o -> o.getFacilitySettingNo(), o -> o));

      // 一般検査
      if(!msgCdList.contains("70000030")) {
        if (!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal())) {
          List<Integer> moveChangeWeekList =
            new ArrayList<>(
              Optional.ofNullable(weekResponse.getFromWeekList())
                .orElse(Collections.emptyList())
            );

          moveChangeWeekList.addAll(
            Optional.ofNullable(weekResponse.getDelWeekList())
              .orElse(Collections.emptyList())
          );

          List<PatExamPattern> patternList = patExamPatternDao.selectExamPatternByExamWeekList(facilityCd, weekResponse.getPatId(), moveChangeWeekList);

          if(patternList != null && !patternList.isEmpty()) {
            hasExam = true;
            if("4".equals(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE).getValue())){
              message += " 一般検査の処理を選択してください";
              msgCdList.add("70000030");
            }else{
              indscheduleChangeUserSelectedInfo.setFacilitySetting1007SelectedVal(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE).getValue());
            }
          }
        }
      }

      // X線検査
      if(!msgCdList.contains("70000031")) {
        if (!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal())) {

          List<PatRadPattern> patternList = patRadPatternDao.selectRadPatternByRadWeekList(facilityCd, weekResponse.getPatId(), weekResponse.getFromWeekList());

          if(patternList != null && !patternList.isEmpty()) {
            hasRad = true;
            if("4".equals(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE).getValue())){
              message += " X線検査の処理を選択してください";
              msgCdList.add("70000031");
            }else{
              indscheduleChangeUserSelectedInfo.setFacilitySetting1008SelectedVal(facilitySettingInfoListMap.get(CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE).getValue());
            }
          }
        }
      }
    }
    //連動メッセージ処理の中止
    if (delOrdNoList != null && !delOrdNoList.isEmpty()) {

      DeleteLinkageCheckResult checkResult = checkDeleteLinkageMessage(facilityCd, msgCdList, delOrdNoList, indscheduleChangeUserSelectedInfo);

      if (checkResult.getLinkageMessage() != null && !checkResult.getLinkageMessage() .isEmpty()) {
        Map.Entry<String, List<String>> entry = checkResult.getLinkageMessage() .entrySet().iterator().next();

        String msg = entry.getKey();

        if (StringUtils.hasText(msg)) {
          message += msg;
        }
      }
      hasPatEvent |= checkResult.hasPatEvent;
      hasRad      |= checkResult.hasRad;
      hasExam     |= checkResult.hasExam;
    }
    if(StringUtils.hasText(message)){
      message = " 選択必要な内容があります。" + message;
      eventLogMessage.setLogMessage(className + "." + methodName + message);
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      responseInfo.setMessage(message);
      responseInfo.setMsgCdList(msgCdList);
      responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.WARN.toString());

      return responseInfo;
    }

    // 指定された期間内に、複数の透析パターンの予定が存在するかをチェックする。
    // 複数存在する場合は、警告メッセージ（00200030）を表示する。
    if (hasMultipleTreatTypes(weekMoveRuleList)) {
      msgCdList.add("00200030");
    }
    if (hasMedicationIntervalCrossMonth(weekMoveRuleList)) {
      message += "投与間隔月１のものが月を跨いだ、ご確認ください。";
      msgCdList.add("13000044");
    }
    if (conflictMessageFlag) {
      msgCdList.add("00400017");
    }
    if ("1".equals(footerFlg)) {
      List<IndScheduleInfo> toBeOrdScheduleListGo = new ArrayList<>();

      for (TreatmentInstance item : othFilteredList) {
        IndScheduleInfo indScheduleInfoGo = new IndScheduleInfo();

        if (item.getBeforeIndScheduleInfo() == null || item.getAfterIndScheduleInfo() == null) {
          continue;
        }
        indScheduleInfoGo.setFacilityCd(item.getBeforeIndScheduleInfo().getFacilityCd());
        Long ordNo = item.getBeforeIndScheduleInfo().getOrdNo();
        indScheduleInfoGo.setOrdNo(ordNo);
        indScheduleInfoGo.setPatId(item.getBeforeIndScheduleInfo().getPatId());
        indScheduleInfoGo.setOldTreatDate(item.getBeforeIndScheduleInfo().getTreatDate());
        indScheduleInfoGo.setTreatDate(item.getAfterIndScheduleInfo().getTreatDate());
        indScheduleInfoGo.setIndKurCd(item.getAfterIndScheduleInfo().getIndKurCd());
        indScheduleInfoGo.setIndBedCd(item.getBedCd() == null
          ? null
          : item.getBedCd().longValue());
        indScheduleInfoGo.setIndTreatmentCd(item.getAfterIndScheduleInfo().getIndTreatmentCd());
        indScheduleInfoGo.setIndTreatmentTime(item.getAfterIndScheduleInfo().getIndTreatmentTime());
        indScheduleInfoGo.setTreatWeek(item.getBeforeIndScheduleInfo().getTreatWeek());
        toBeOrdScheduleListGo.add(indScheduleInfoGo);

        beforeIndScheduleInfo.add(item.getBeforeIndScheduleInfo());
      }
      toBeOrdScheduleListAllForCheak.addAll(toBeOrdScheduleListGo);
    }

    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    responseInfo.setHasExam(hasExam);
    responseInfo.setHasRad(hasRad);
    responseInfo.setHasPatEvent(hasPatEvent);
    responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.SUCCESS.toString());
    responseInfo.setToBeOrdScheduleListAllForCheak(toBeOrdScheduleListAllForCheak);
    responseInfo.setMessage(message);
    responseInfo.setMsgCdList(msgCdList);
    responseInfo.setBeforeIndScheduleInfo(beforeIndScheduleInfo);
    return responseInfo;
  }
  /**
   * 同一日・同一クール・同一治療内容の重複有無をチェックする。
   *
   * 週移動対象の治療リストから、削除（DELETE）以外のデータを対象とし、
   * 治療日・クールコード・個別治療コードがすべて一致する
   * データが複数存在するかを判定する。
   *
   * 重複が存在する場合は true、存在しない場合は false を返却する。
   *
   * @param weekMoveRuleList 週移動ルール適用後の治療インスタンス一覧
   * @return 同一日・同一クール・同一治療の重複がある場合 true、ない場合 false
   */
  public Boolean checkSameDaySameKurTreatmentDuplicate(
    List<TreatmentInstance> weekMoveRuleList
  ) {
    if (weekMoveRuleList == null || weekMoveRuleList.size() <= 1) {

      return false;
    }

    Set<String> seenKeys = new HashSet<>();

    List<TreatmentInstance> moveList = weekMoveRuleList.stream().filter(i -> !Objects.equals(i.getChangeType(), TreatmentInstance.ChangeType.DELETE)).collect(Collectors.toList());

    for (TreatmentInstance ti : moveList) {
      if (ti == null) {
        continue;
      }

      String treatDate = ti.getTreatDate();
      Integer kurCd = ti.getKurCd();
      Integer indTreatmentCd = ti.getIndTreatmentCd();

      if (treatDate == null || kurCd == null || indTreatmentCd == null) {
        continue;
      }

      String key = treatDate + "_" + kurCd + "_" + indTreatmentCd;

      if (!seenKeys.add(key)) {
        return true;
      }
    }

    return false;
  }

  /**
   * 治療日の変更後に、開始日時・終了日時を再計算して設定する。
   * 週移動ルール適用後の治療インスタンス一覧を対象とし、
   * 治療日・開始時刻・治療時間・クールコードが設定されているデータについて、
   * クールマスタ情報を用いて終了日時を算出する。
   *
   * 終了日時が正常に算出できた場合は、
   * 開始日時（治療日＋開始時刻）および終了日時を再設定する。
   *
   * 必須項目が未設定、またはクールコードが不正（null / 0）の場合は
   * 処理対象外とする。
   *
   * @param weekMoveRuleList 週移動ルール適用後の治療インスタンス一覧
   * @param mstKurList       クールマスタ一覧（終了日時算出用）
   */
  public static void calcAndResetStartEnd(
    List<TreatmentInstance> weekMoveRuleList,
    List<MstKur> mstKurList
  ) {
    if (weekMoveRuleList == null || weekMoveRuleList.isEmpty()) {
      return;
    }

    for (TreatmentInstance ti : weekMoveRuleList) {

      if (ti.getTreatDate() == null
        || ti.getStart() == null
        || ti.getTreatTime() == null
        || ti.getKurCd() == null
        || ti.getKurCd() == 0) {
        continue;
      }

      String endDateTime =
        calcTreatEndDateTimeString(
          ti.getTreatDate(),
          ti.getStart(),
          ti.getTreatTime(),
          ti.getKurCd(),
          mstKurList
        );

      if (endDateTime == null) {
        continue;
      }

      String startDateTime =
        ti.getTreatDate() + ti.getStart();

      ti.setStart(startDateTime);
      ti.setEnd(endDateTime);
    }
  }

  /**
   * 治療開始日時と治療時間から終了日時を算出する。
   *
   * クールマスタの終了時刻を基準に、
   * 実際に設定可能な終了日時を計算する。
   *
   * @param treatDate  治療開始日（yyyyMMdd）
   * @param startTime  開始時刻（HHmmss）
   * @param treatTime  治療時間（分）
   * @param startKurCd 開始クールコード
   * @param mstKurList クールマスタ一覧
   * @return 終了日時（yyyyMMddHHmmss）算出不可の場合は null
   */
  public static String calcTreatEndDateTimeString(
    String treatDate,
    String startTime,
    String treatTime,
    Integer startKurCd,
    List<MstKur> mstKurList
  ) {
    if (treatDate == null
      || startTime == null
      || startKurCd == null
      || startKurCd == 0
      || treatTime == null
      || !treatTime.matches("\\d+")
      || Integer.parseInt(treatTime) <= 0
      || mstKurList == null
      || mstKurList.isEmpty()) {
      return null;
    }

    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("yyyyMMdd");
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HHmmss");
    DateTimeFormatter outFmt  = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    int treatMinutes = Integer.parseInt(treatTime);

    LocalDate startDate = LocalDate.parse(treatDate, dateFmt);
    LocalTime startLocalTime = LocalTime.parse(startTime, timeFmt);
    LocalDateTime startDateTime =
      LocalDateTime.of(startDate, startLocalTime);

    LocalDateTime realEndDateTime =
      startDateTime.plusMinutes(treatMinutes);

    List<MstKur> sortedKurList = mstKurList.stream()
      .sorted(Comparator.comparing(MstKur::getKurCd))
      .toList();

    LocalDateTime lastFullKurEndDateTime = null;

    long maxDays =
      ChronoUnit.DAYS.between(
        startDateTime.toLocalDate(),
        realEndDateTime.toLocalDate()
      );

    for (int day = 0; day <= maxDays; day++) {
      LocalDate currentDate = startDate.plusDays( day);

      for (MstKur kur : sortedKurList) {

        if (day == 0 && kur.getKurCd() < startKurCd) {
          continue;
        }

        LocalTime kurEndTime =
          LocalTime.parse(kur.getKurEndTime(), timeFmt);

        LocalDateTime kurEndDateTime =
          LocalDateTime.of(currentDate, kurEndTime);

        if (!realEndDateTime.isBefore(kurEndDateTime)) {
          lastFullKurEndDateTime = kurEndDateTime;
        } else {
          return (lastFullKurEndDateTime == null
            ? kurEndDateTime
            : lastFullKurEndDateTime
          ).format(outFmt);
        }
      }
    }

    return lastFullKurEndDateTime == null
      ? null
      : lastFullKurEndDateTime.format(outFmt);
  }

  /**
   * 同一ベッド内の時間重複を判定し、使用可能な治療データを抽出する。
   *
   * ベッドごとに開始・終了時間の重複を判定し、
   * 重複しないデータを採用、重複するデータはベッド未設定対象とする。
   *
   * @param weekMoveRuleList 週移動ルール適用後の治療インスタンス一覧
   * @return ベッド競合判定結果
   */
  public OwnBedConflictResult resolveOwnBedConflict(
    List<TreatmentInstance> weekMoveRuleList,
    String facilityCd
  ) {

    OwnBedConflictResult result = new OwnBedConflictResult();

    if (weekMoveRuleList == null || weekMoveRuleList.isEmpty()) {
      result.setHasConflict(false);
      result.setSurvivedList(Collections.emptyList());
      return result;
    }

    List<TreatmentInstance> moveList =
      weekMoveRuleList.stream()
        .filter(i ->
          i.getChangeType() != TreatmentInstance.ChangeType.DELETE
            && i.getStart() != null
            && i.getEnd() != null
        )
        .collect(Collectors.toList());

    Map<Integer, List<TreatmentInstance>> bedMap =
      moveList.stream()
        .filter(t -> t.getBedCd() != null && t.getBedCd() != 0)
        .collect(Collectors.groupingBy(TreatmentInstance::getBedCd));

    List<TreatmentInstance> bedUnsetList = new ArrayList<>();

    List<TreatmentInstance> survivedList = new ArrayList<>();

    for (List<TreatmentInstance> bedList : bedMap.values()) {

      bedList.sort(
        Comparator
          .comparing(TreatmentInstance::getStart)
          .thenComparing(TreatmentInstance::getEnd)
      );

      List<TreatmentInstance> accepted = new ArrayList<>();

      for (TreatmentInstance current : bedList) {

        boolean conflict = false;

        // パターンの重複判定：ベッド未登録、または保持対象の展開データは除外する
        Integer treatWeek = current.getTreatWeek();
        boolean isPatternSource =
          TreatmentInstance.Source.PAT_TREATMENT_PATTERN.equals(current.getSource());

        boolean existsAcceptedPatternWeek =
          accepted.stream()
            .anyMatch(i ->
              TreatmentInstance.Source.PAT_TREATMENT_PATTERN.equals(i.getSource())
                && Objects.equals(i.getTreatWeek(), treatWeek)
            );

        boolean existsBedUnsetListPatternWeek =
          bedUnsetList.stream()
            .anyMatch(i ->
              TreatmentInstance.Source.PAT_TREATMENT_PATTERN.equals(i.getSource())
                && Objects.equals(i.getTreatWeek(), treatWeek)
            );

        if (isPatternSource && (existsAcceptedPatternWeek || existsBedUnsetListPatternWeek)) {
          continue;
        }

        for (TreatmentInstance exist : accepted) {
          if (isOverlap(current, exist)) {
            conflict = true;
            break;
          }
        }

        if (conflict) {
          current.setBedCd(0);
          bedUnsetList.add(current);
          // 自身への変更によるベッド移動時の条件更新データ作成
          if (current.getBeforeIndScheduleInfo() == null && current.getAfterIndScheduleInfo() == null) {

            IndScheduleInfo before = new IndScheduleInfo();
            before.setFacilityCd(facilityCd);
            before.setOrdNo(current.getOrdNo());
            before.setPatId(current.getPatId());
            before.setTreatDate(current.getTreatDate());
            before.setIndKurCd(current.getKurCd() != null ? current.getKurCd().longValue() : null);
            before.setIndBedCd(current.getBedCd() != null ? current.getBedCd().longValue() : null);

            current.setBeforeIndScheduleInfo(before);

            IndScheduleInfo after = new IndScheduleInfo();
            after.setFacilityCd(facilityCd);
            after.setTreatDate(current.getTreatDate());
            after.setIndKurCd(current.getKurCd() != null ? current.getKurCd().longValue() : null);
            after.setIndBedCd(0L);
            after.setOrdNo(current.getOrdNo());
            after.setPatId(current.getPatId());

            current.setAfterIndScheduleInfo(after);
          }
        } else {
          accepted.add(current);
        }
      }

      survivedList.addAll(accepted);
    }
    result.setSurvivedList(survivedList);
    result.setBedUnsetList(bedUnsetList);
    return result;
  }

  private boolean isOverlap(TreatmentInstance a, TreatmentInstance b) {
    return a.getStart().compareTo(b.getEnd()) < 0
      && b.getStart().compareTo(a.getEnd()) < 0;
  }

  /**
   * 治療データ一覧から対象期間の最小日付・最大日付を算出する。
   *
   * 開始日時から3日前を最小日付、終了日時を最大日付として取得する。
   *
   * @param weekMoveRuleList 治療インスタンス一覧
   * @return 最小日付（minDate）・最大日付（maxDate）を持つMap（yyyyMMdd）
   */

  public Map<String, String> calcMinMaxDateString(
    List<TreatmentInstance> weekMoveRuleList
  ) {
    DateTimeFormatter inFmt  = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    DateTimeFormatter outFmt = DateTimeFormatter.ofPattern("yyyyMMdd");

    LocalDate minDate = null;
    LocalDate maxDate = null;

    for (TreatmentInstance ti : weekMoveRuleList) {

      if (ti.getStart() == null || ti.getEnd() == null) {
        continue;
      }
      LocalDate from =
        LocalDateTime.parse(ti.getStart(), inFmt)
          .toLocalDate()
          .minusDays(3);

      LocalDate to =
        LocalDateTime.parse(ti.getEnd(), inFmt)
          .toLocalDate();

      if (minDate == null || from.isBefore(minDate)) {
        minDate = from;
      }

      if (maxDate == null || to.isAfter(maxDate)) {
        maxDate = to;
      }
    }

    Map<String, String> result = new HashMap<>();
    result.put("minDate", minDate == null ? null : minDate.format(outFmt));
    result.put("maxDate", maxDate == null ? null : maxDate.format(outFmt));

    return result;
  }

  /**
   * 移動データと未移動データ間のベッド時間重複を判定する。
   *
   * 同一ベッドにおいて、移動後データと未移動データの
   * 開始・終了時間が重複しているかをチェックする。
   *
   * @param movedList   移動後の治療インスタンス一覧
   * @param unmovedList 未移動の治療インスタンス一覧
   * @return ベッド競合判定結果
   */

  public BedConflictResult detectMovedVsUnmovedConflicts(
    List<TreatmentInstance> movedList,
    List<TreatmentInstance> unmovedList
  ) {

    if (CollectionUtils.isEmpty(movedList)
      || CollectionUtils.isEmpty(unmovedList)) {
      return new BedConflictResult(
        Collections.emptyList(),
        Collections.emptyList(),
        false
      );
    }

    Map<Integer, List<TreatmentInstance>> unmovedByBed =
      unmovedList.stream()
        .filter(t -> t.getBedCd() != null && t.getBedCd() != 0)
        .filter(t -> t.getStart() != null && t.getEnd() != null)
        .collect(Collectors.groupingBy(TreatmentInstance::getBedCd));

    List<TreatmentInstance> selfConflictList = new ArrayList<>();
    List<TreatmentInstance> otherConflictList = new ArrayList<>();

    for (TreatmentInstance moved : movedList) {

      if (moved.getBedCd() == null || moved.getBedCd() == 0
        || moved.getStart() == null || moved.getEnd() == null) {
        continue;
      }

      List<TreatmentInstance> candidates =
        unmovedByBed.get(moved.getBedCd());

      if (CollectionUtils.isEmpty(candidates)) {
        continue;
      }

      for (TreatmentInstance unmoved : candidates) {

        if (!isOverlap(moved, unmoved)) {
          continue;
        }
        selfConflictList.add(moved);

        if (!otherConflictList.contains(unmoved)) {
          otherConflictList.add(unmoved);
        }
      }
    }
    boolean hasConflict =
      otherConflictList != null && !otherConflictList.isEmpty();

    return new BedConflictResult(selfConflictList, otherConflictList, hasConflict);
  }
  public OwnBedConflictResult detectMovedVsRstUnmovedConflicts(
    List<TreatmentInstance> movedList,
    List<TreatmentInstance> unmovedList
  ) {

    if (CollectionUtils.isEmpty(movedList)
      || CollectionUtils.isEmpty(unmovedList)) {
      return new OwnBedConflictResult(
        false,
        Collections.emptyList(),
        Collections.emptyList()
      );
    }

    Map<Integer, List<TreatmentInstance>> unmovedByBed =
      unmovedList.stream()
        .filter(t -> t.getBedCd() != null && t.getBedCd() != 0)
        .filter(t -> t.getStart() != null && t.getEnd() != null)
        .collect(Collectors.groupingBy(TreatmentInstance::getBedCd));

    List<TreatmentInstance> bedUnsetList = new ArrayList<>();

    List<TreatmentInstance> survivedList = new ArrayList<>();

    for (TreatmentInstance moved : movedList) {

      if (moved.getBedCd() == null || moved.getBedCd() == 0
        || moved.getStart() == null || moved.getEnd() == null) {
        continue;
      }

      List<TreatmentInstance> candidates =
        unmovedByBed.get(moved.getBedCd());

      if (CollectionUtils.isEmpty(candidates)) {
        continue;
      }

      for (TreatmentInstance unmoved : candidates) {

        if (!isOverlap(moved, unmoved)) {
          survivedList.add(moved);
          continue;
        }

        moved.setBedCd(0);
        bedUnsetList.add(moved);
        break;
      }
    }

    boolean hasConflict = !bedUnsetList.isEmpty();

    return new OwnBedConflictResult(
      hasConflict,
      survivedList,
      bedUnsetList
    );
  }

  private static String buildMessage(
    TreatmentInstance ti,
    Map<Long, String> patNameMap,
    Map<Integer, String> weekMap,
    boolean withTreatDate
  ) {
    StringBuilder sb = new StringBuilder();

    sb.append(patNameMap.get(ti.getPatId())).append(":");

    if (withTreatDate) {
      String treatDate = Optional.ofNullable(ti.getTreatDate()).orElse("");
      if (treatDate.length() == 8 && !"00000000".equals(treatDate)) {
        sb.append(
          treatDate.substring(0, 4)).append("/")
          .append(treatDate.substring(4, 6)).append("/")
          .append(treatDate.substring(6, 8))
          .append(" ");
      }
    }

    String weekPart = weekMap.getOrDefault(ti.getTreatWeek(), "");
    if (!weekPart.isEmpty()) {
      sb.append("(").append(weekPart).append(") ");
    }

    sb.append(Optional.ofNullable(ti.getKurName()).orElse(""));
    sb.append(Optional.ofNullable(ti.getBedName()).orElse(""));

    return sb.toString();
  }



  public DeleteLinkageCheckResult checkDeleteLinkageMessage(
    String facilityCd,
    List<String> msgCdList,
    List<Long> delOrdNoList,
    IndscheduleChangeUserSelectedInfo userSelectedInfo) {

    DeleteLinkageCheckResult result = new DeleteLinkageCheckResult();

    Map<String, List<String>> linkageMessage = new HashMap<>();

    boolean hasPatEvent = false;
    boolean hasExam = false;
    boolean hasRad = false;

    StringBuilder messageBuilder = new StringBuilder();

    if (msgCdList == null) {
      msgCdList = new ArrayList<>();
    }

    if (facilityCd == null || userSelectedInfo == null) {
      linkageMessage.put("", msgCdList);
      result.setLinkageMessage(linkageMessage);
      return result;
    }

    List<FacilitySettingInfo> settingList = mstFacilitySettingDao.selectFacilitySetting(facilityCd, null);
    Map<String, FacilitySettingInfo> settingMap = settingList == null ? Collections.emptyMap()
      : settingList.stream().collect(Collectors.toMap(FacilitySettingInfo::getFacilitySettingNo, Function.identity()));

    if (!msgCdList.contains("70000032")) {
      List<OrdNoAndConnectedTableKeyData> patEvents = indScheduleDao.selectConnectedPatEventByOrdNoList(facilityCd, delOrdNoList);
      if (isNotEmpty(patEvents)) {
        hasPatEvent = true;
        if ( !StringUtils.hasText(userSelectedInfo.getFacilitySetting3005SelectedVal())) {
          if ("4".equals(getSettingValue(settingMap, CoreConstant.FacilitySettingNo.PAT_EVENT_CHANGE))) {
            messageBuilder.append(" 患者イベントの処理を選択してください");
            msgCdList.add("70000032");
          } else {
            userSelectedInfo.setFacilitySetting3005SelectedVal(getSettingValue(settingMap, CoreConstant.FacilitySettingNo.PAT_EVENT_CHANGE));
          }
        }
      }
    }
    List<OrdNoAndConnectedTableKeyData> examList = new ArrayList<>();
    if (!msgCdList.contains("70000030")) {
      examList = indScheduleDao.selectConnectedExamMainCdByOrdNoList(facilityCd, delOrdNoList);
      if (isNotEmpty(examList)) {
        hasExam = true;
        if (!StringUtils.hasText(userSelectedInfo.getFacilitySetting1007SelectedVal())) {
          if ("4".equals(getSettingValue(settingMap, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE))) {
            messageBuilder.append(" 一般検査の処理を選択してください");
            msgCdList.add("70000030");
          } else {
            userSelectedInfo.setFacilitySetting1007SelectedVal(getSettingValue(settingMap, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE));
          }
        }
      }
    }

    if (!msgCdList.contains("70000033")
      && "1".equals(getSettingValue(settingMap, CoreConstant.FacilitySettingNo.EXAM_CHANGE_ON_OFF_WITH_ORDER))) {

      List<OrdNoAndConnectedTableKeyData> examDeadlineList =
        (examList != null && !examList.isEmpty())
          ? examList
          : indScheduleDao.selectConnectedExamMainCdByOrdNoList(facilityCd, delOrdNoList);

      if (isNotEmpty(examDeadlineList)) {
        hasExam = true;
        boolean deadlinePassed = checkDeleteOverDeadLine(
          examDeadlineList,
          getSettingValue(settingMap, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_DAY),
          getSettingValue(settingMap, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_TIME)
        );
        if (deadlinePassed
          && !StringUtils.hasText(userSelectedInfo.getExamDeadlineSelectedVal())
          && !"3".equals(userSelectedInfo.getFacilitySetting1007SelectedVal())) {
          messageBuilder.append(" 一般検査の締切日が過ぎている予定移動があります");
          msgCdList.add("70000033");
        }
      }
    }

    List<OrdNoAndConnectedTableKeyData> radList = new ArrayList<>();
    if (!msgCdList.contains("70000031")) {
      radList = indScheduleDao.selectConnectedRadResultCdByOrdNoList(facilityCd, delOrdNoList);
      if (isNotEmpty(radList)) {
        hasRad = true;
        if (!StringUtils.hasText(userSelectedInfo.getFacilitySetting1008SelectedVal())) {
          if ("4".equals(getSettingValue(settingMap, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE))) {
            messageBuilder.append(" X線検査の処理を選択してください");
            msgCdList.add("70000031");
          } else {
            userSelectedInfo.setFacilitySetting1008SelectedVal(getSettingValue(settingMap, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE));
          }
        }
      }
    }

    if (!msgCdList.contains("70000034")
      && "1".equals(getSettingValue(settingMap, CoreConstant.FacilitySettingNo.RAD_CHANGE_ON_OFF_WITH_ORDER))) {

      List<OrdNoAndConnectedTableKeyData> radDeadlineList =
        (radList != null && !radList.isEmpty())
          ? radList
          : indScheduleDao.selectConnectedRadResultCdByOrdNoList(facilityCd, delOrdNoList);

      if (isNotEmpty(radDeadlineList)) {
        hasRad = true;
        boolean deadlinePassed = checkDeleteOverDeadLine(
          radDeadlineList,
          getSettingValue(settingMap, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_DAY),
          getSettingValue(settingMap, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_TIME)
        );
        if (deadlinePassed
          && !StringUtils.hasText(userSelectedInfo.getRadDeadlineSelectedVal())
          && !"3".equals(userSelectedInfo.getFacilitySetting1008SelectedVal())) {
          messageBuilder.append(" 放射線検査の締切日が過ぎている予定移動があります");
          msgCdList.add("70000034");
        }
      }
    }

    if (messageBuilder.length() > 0) {
      linkageMessage.put(messageBuilder.toString(), msgCdList);
    }

    result.setLinkageMessage(linkageMessage);
    result.setHasExam(hasExam);
    result.setHasRad(hasRad);
    result.setHasPatEvent(hasPatEvent);
    return result;
  }

  private boolean checkDeleteOverDeadLine(List<OrdNoAndConnectedTableKeyData> connectedOrdMainExamMainCdList,
                                          String scheduleChangeLimitDay, String scheduleChangeLimitTime) {

    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

    LocalDate today = LocalDate.now();
    LocalDate deadline = today.plusDays(Long.parseLong(scheduleChangeLimitDay));

    LocalTime limitTime = LocalTime.parse(scheduleChangeLimitTime, timeFormatter);

    boolean hasExpiredRecords = connectedOrdMainExamMainCdList.stream()
      .anyMatch(indScheduleInfo -> {

        String datePart = indScheduleInfo.getTreatDate().substring(0, 10);
        LocalDate date = LocalDate.parse(datePart);

        boolean isBeforeDeadline = date.isBefore(deadline)
          || (date.equals(deadline) && LocalTime.now().isAfter(limitTime));
        return isBeforeDeadline;
      });
    return hasExpiredRecords;
  }

  /**
   * weekMoveRuleList において、
   * 「MOVE かつ 投薬間隔が月単位で、治療日が月をまたぐ（年跨ぎ含む）」
   * データが存在するかを判定する。
   */
  private boolean hasMedicationIntervalCrossMonth(
    List<TreatmentInstance> weekMoveRuleList
  ) {

    if (weekMoveRuleList == null || weekMoveRuleList.isEmpty()) {
      return false;
    }

    for (TreatmentInstance ti : weekMoveRuleList) {

      if (ti.getChangeType() != TreatmentInstance.ChangeType.MOVE) {
        continue;
      }

      String afterTreatDate  = ti.getTreatDate();
      String beforeTreatDate = ti.getMoveBeforeTreatDate();

      if (ObjectUtils.isEmpty(afterTreatDate)
        || ObjectUtils.isEmpty(beforeTreatDate)) {
        continue;
      }

      if (hasMedicationIntervalCrossMonth(
        ti.getIndMediInfo(),
        beforeTreatDate,
        afterTreatDate)) {
        return true;
      }
    }

    return false;
  }

  /**
   * 投薬間隔が月単位の場合に、2つの治療日が月をまたいでいるか（年跨ぎ含む）を判定する。
   *
   * @return true  : 月をまたぐ
   *         false : 同一月 ／ 対象外
   */
  private boolean hasMedicationIntervalCrossMonth(
    String indMediInfo,
    String fromTreatDate,
    String toTreatDate
  ) {

    if (ObjectUtils.isEmpty(indMediInfo)
      || ObjectUtils.isEmpty(fromTreatDate)
      || ObjectUtils.isEmpty(toTreatDate)) {
      return false;
    }

    if (!hasMonthlyMedicationInterval(indMediInfo)) {
      return false;
    }

    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");

    LocalDate from = LocalDate.parse(fromTreatDate, formatter);
    LocalDate to   = LocalDate.parse(toTreatDate, formatter);

    return from.getYear()  != to.getYear()
      || from.getMonthValue() != to.getMonthValue();
  }

  private boolean hasMonthlyMedicationInterval(String indMediInfo) {

    JSONArray list = new JSONArray(
      ObjectUtils.isEmpty(indMediInfo) ? "[]" : indMediInfo
    );

    for (int i = 0; i < list.length(); i++) {
      int interval = list.getJSONObject(i).getInt("date_interval");

      if (interval == 5 || interval == 8
        || interval == 9 || interval == 10) {
        return true;
      }
    }
    return false;
  }

  // チェック：一般検査・一般撮影検査の締切日を過ぎているか
  public boolean checkOverDeadLine(List<IndScheduleInfo> indScheduleInfoList, String scheduleChangeLimitDay, String scheduleChangeLimitTime){
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

    LocalDate today = LocalDate.now();
    LocalDate deadline = today.plusDays(Long.parseLong(scheduleChangeLimitDay));

    LocalTime limitTime = LocalTime.parse(scheduleChangeLimitTime, timeFormatter);

    List<IndScheduleInfo> indScheduleInfoOverDayList = indScheduleInfoList.stream().filter(o -> !o.getTreatDate().equals(o.getOldTreatDate())).collect(Collectors.toList());
    boolean hasExpiredRecords = indScheduleInfoOverDayList.stream()
      .anyMatch(indScheduleInfo -> {
        LocalDate date = LocalDate.parse(indScheduleInfo.getTreatDate(), dateFormatter);
        boolean isBeforeDeadline = date.isBefore(deadline)
          || (date.equals(deadline) && LocalTime.now().isAfter(limitTime));

        if (!isBeforeDeadline) {
          LocalDate oldDate = LocalDate.parse(indScheduleInfo.getOldTreatDate(), dateFormatter);
          isBeforeDeadline = oldDate.isBefore(deadline)
            || (oldDate.equals(deadline) && LocalTime.now().isAfter(limitTime));
        }
        return isBeforeDeadline;
      });
    return hasExpiredRecords;
  }


  private String getSettingValue(Map<String, FacilitySettingInfo> settingMap, String key) {
    FacilitySettingInfo info = settingMap.get(key);
    return info != null ? info.getValue() : "";
  }

  private boolean isNotEmpty(List<?> list) {
    return list != null && !list.isEmpty();
  }

  private boolean hasMultipleTreatTypes(List<TreatmentInstance> weekMoveRuleList) {
    if (weekMoveRuleList == null || weekMoveRuleList.isEmpty()) {
      return false;
    }

    Set<Integer> treatTypeSet = new HashSet<>();

    for (TreatmentInstance item : weekMoveRuleList) {
      Integer treatType = item.getTreatType();

      if (treatType == null) {
        continue;
      }

      treatTypeSet.add(treatType);
      if (treatTypeSet.size() > 1) {
        return true;
      }
    }
    return false;
  }

  private boolean isOnOrBeforeEndDate(String treatDate, String endDate) {
    return treatDate != null
      && treatDate.length() == 8
      && !"00000000".equals(treatDate)
      && treatDate.compareTo(endDate) <= 0;
  }
}
