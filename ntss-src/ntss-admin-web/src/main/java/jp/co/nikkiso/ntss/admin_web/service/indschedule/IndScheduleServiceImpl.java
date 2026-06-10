package jp.co.nikkiso.ntss.admin_web.service.indschedule;

import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.service.IndHistoryMakeService;
import jp.co.nikkiso.ntss.admin_web.service.changeWeekPattern.WeekPatternInfoServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.patEvent.PatEventService;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PatTreatmentPatternUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.api.response.scheduleList.WeekPatternResponse;
import jp.co.nikkiso.ntss.core.dao.BbsInfoDao;
import jp.co.nikkiso.ntss.core.dao.IndScheduleDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dto.indSchedule.OrdNoAndConnectedTableKeyData;
import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveDto;
import jp.co.nikkiso.ntss.core.entity.BbsInfo;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import org.json.JSONException;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.function.BiConsumer;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class IndScheduleServiceImpl implements IndScheduleService{

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  @Autowired
  private IndScheduleDao indScheduleDao;

  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private OrdScheduleDao ordScheduleDao;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;


  @Autowired
  TreatmentRecordService treatmentRecordService;

  @Resource
  private OrdChecklistDao ordChecklistDao;

  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;

  @Autowired
  private IndHistoryMakeService indHistoryMakeService;

  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
  @Autowired
  private SendConditionCancelService sendConditionCancelService;
  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
  // add #11716 曜日パターン変更の不正 関 start
  @Autowired
  PatTreatmentPatternUtils patTreatmentPatternUtils;

  @Autowired
  private PatEventService patEventService;

  @Autowired
  private BbsInfoDao bbsInfoDao;

  @Autowired
  private PatEventDao patEventDao;

  @Autowired
  WeekPatternInfoServiceImpl weekPatternInfoServiceImpl;

  // add #11716 曜日パターン変更の不正 関 end

  /**
   *
   * @param facilityCd
   * @param beforeIndScheduleInfoList
   * @param afterIndScheduleInfoList
   * @param indscheduleChangeUserSelectedInfo
   * @param indUserId
   * @param updUserId
   *
   * message
   *          22020005:治療中患者のスケジュール変更はできません。
   *          70000001:移動後同一患者・同一治療日・同一クール・同一治療方法のデータが作成されるため、変更できません。※行き方向
   *          70000008:移動後他患者の治療予定データと重複が発生します。
   *          70000032:患者イベントの処理を選択してください
   *          70000030:一般検査の処理を選択してください
   *          70000031:X線検査の処理を選択してください
   *          70000033:一般検査の締切日が過ぎている予定移動があります
   *          12000060:実績反映しますか
   *          12000212:他の予定と重複するためスケジュール変更できません。（移動後入れ替えの予定で重複するためスケジュール変更できません。）
   * @return
   * @throws JSONException
   * @throws ArrayIndexOutOfBoundsException
   */
  // mod #11716 曜日パターン変更の不正 関 start
  @Override
  @Transactional
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
  ) throws JSONException, ArrayIndexOutOfBoundsException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    final String className = new Object() {}.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {}.getClass().getEnclosingMethod().getName();
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
    String message = "";

    UpdateScheduleListDataResponse responseInfo = new UpdateScheduleListDataResponse();

    Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>(); // 連携用、イベントログ用o

    Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>(); // 連携用、イベントログ用

    List<OrdMain> doCallNextPatOrdMainList = new ArrayList<>();

    List<IndScheduleInfo> toBeOrdScheduleListAllForCheak = checkResponse.getToBeOrdScheduleListAllForCheak();

    // 治療予定の移動
//    MODE_SCHEDULE_MOVE updateMode;
//    if(indScheduleInfoListGo.size() == 1){
//      updateMode = MODE_SCHEDULE_MOVE.OTHER_ONE_ORDER;
//    } else if(indScheduleInfoListBack.size() == 0){
//      updateMode = MODE_SCHEDULE_MOVE.MULTI_FROM_SCHEDULE_LIST;
//    } else if(indScheduleInfoListGo.stream()
//      .map(om -> Arrays.asList(om.getIndKurCd(), om.getIndTreatStartTime(), om.getIndBedCd()))
//      .distinct()
//      .limit(2)
//      .count() <= 1){
//      updateMode = MODE_SCHEDULE_MOVE.MULTI_FROM_PAT_VIEWER;
//    } else {
//      updateMode = MODE_SCHEDULE_MOVE.OTHER_ONE_ORDER;
//
//      eventLogMessage.setLogMessage(className + "." + methodName + "不明な画面からの処理");
//      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
//    }

//    switch (updateMode){
//      case MULTI_FROM_PAT_VIEWER:
//        // 患者経過総合ビュアーからの操作
//
//        break;
//      case MULTI_FROM_SCHEDULE_LIST:
//        // スケジュール表からの操作
//        break;
//      case OTHER_ONE_ORDER:
//      default:
//        // その他の操作
//        break;
//    }

    // 既に登録されているベッドを落とす を選択した場合
    if(checkResponse.getDupulicateOrdScheduleListAll() != null && checkResponse.getDupulicateOrdScheduleListAll().size() > 0){
      List<IndScheduleInfo> dupulicateOrdScheduleListAll = checkResponse.getDupulicateOrdScheduleListAll();

      if(indscheduleChangeUserSelectedInfo.getDupulicateUpdateMode().equals("1")){
        for(IndScheduleInfo dupulicateOrdSchedule : dupulicateOrdScheduleListAll){
          dupulicateOrdSchedule.setIndBedCd(0L);
        }
        toBeOrdScheduleListAllForCheak.addAll(dupulicateOrdScheduleListAll);
      }
    }
    if (toBeOrdScheduleListAllForCheak != null && !toBeOrdScheduleListAllForCheak.isEmpty()) {
      List<Long> ordNoList = toBeOrdScheduleListAllForCheak.stream().map(item -> item.getOrdNo()).distinct().collect(Collectors.toList());
      doCallNextPatOrdMainList.addAll(ordMainDao.selectByOrdNoList(ordNoList));
      //add #10412 次患者更新関連全体見直し対応 朴 end

      // 利用者情報取得
      MstPersonalUser updUser = mstPersonalUserDao.selectById(updUserId);
      // 指示者情報取得
      MstPersonalUser indUser;
      if(Objects.equals(updUserId, indUserId)){
        indUser = updUser;
      } else {
        indUser = mstPersonalUserDao.selectById(indUserId);
      }
      // ord_mainの更新
      int updatedCount;
      this.addToMapList(resultAllChangeBeforeDataInfoList, "ord_main", doCallNextPatOrdMainList); // 変更前データ退避
      List<OrdMain> updatedOrdMainList = indScheduleDao.updateOrdMainIndScheduleInfoByIndSchdueInfoList(facilityCd, toBeOrdScheduleListAllForCheak, indUser, updUser, indscheduleChangeUserSelectedInfo.getUpdateRst());
      this.addToMapList(resultAllChangedDataInfoList, "ord_main", updatedOrdMainList); // 変更後データ退避

      // ord_scheduleの更新
      if(updatedOrdMainList != null && updatedOrdMainList.size() > 0){
        // Mainデータの更新
        List<OrdSchedule> ordScheduleListBefore = indScheduleDao.selectForUpdateOrdScheduleMainDataByIndSchdueInfoList(facilityCd, toBeOrdScheduleListAllForCheak);
        this.addToMapList(resultAllChangeBeforeDataInfoList, "ord_schedule", ordScheduleListBefore); // 変更前データ退避

        List<OrdSchedule> updatedOrdSchedules = ordScheduleDao.bulkUpdateByOrdMainIndCondInfo(facilityCd, ordNoList);
        this.addToMapList(resultAllChangedDataInfoList, "ord_schedule", updatedOrdSchedules); // 変更後データ退避
      }

      // 指示受け承認情報の更新
      List<PatIndApprove> patIndApproveListBefore = indScheduleDao.selectForUpdatePatIndApproveByIndSchdueInfoList(facilityCd, toBeOrdScheduleListAllForCheak);
      this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_ind_approve", patIndApproveListBefore); // 変更前データ退避

      // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
      List<Long> ordNos = Optional.ofNullable(doCallNextPatOrdMainList)
        .orElse(Collections.emptyList())
        .parallelStream()
        .filter(item -> item != null && ("1".equals(item.getRstDialysisState()) || "2".equals(item.getRstDialysisState())))
        .map(OrdMain::getOrdNo)
        .filter(Objects::nonNull)
        .collect(Collectors.toList());

      if (ordNos != null && !ordNos.isEmpty()) {
        sendConditionCancelService.resetPatIndApprove(ordNos);
      }
      // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

      List<PatIndApprove> patIndApproveList = indScheduleDao.updatePatIndApproveByIndSchdueInfoList(facilityCd, toBeOrdScheduleListAllForCheak);
      this.addToMapList(resultAllChangedDataInfoList, "pat_ind_approve", patIndApproveList); // 変更後データ退避

      processChangeDependentExamAndRad(weekPatternDataInfo, facilityCd, checkResponse,
        indscheduleChangeUserSelectedInfo, toBeOrdScheduleListAllForCheak, resultAllChangedDataInfoList, resultAllChangeBeforeDataInfoList, delOrdMainList, indUserId, updUserId, "");

      //スケジュールされた移動 for ord_checklist
      List<Long> checkListOrdNoList = new ArrayList<>();
      for(OrdMain before : doCallNextPatOrdMainList){
        String beforeTreadDate = before.getTreatDate();
        for(OrdMain after : updatedOrdMainList){
          if(before.getOrdNo().equals(after.getOrdNo()) && !beforeTreadDate.equals(after.getTreatDate())){
            checkListOrdNoList.add(before.getOrdNo());
            break;
          }
        }
      }
      if(!checkListOrdNoList.isEmpty()){
        ordChecklistDao.deleteByOrdNoAndFacilityCdBatch(checkListOrdNoList, facilityCd);
      }

      //materialSave
      if(updatedOrdMainList != null && !updatedOrdMainList.isEmpty()){
        ordMaterialSaveService.updMaterialSaveBaseDateByOrdMain(updatedOrdMainList);
        // add #12250 ord_material_saveの処理を2回重複実行している zkm start
        this.ordMaterialSaveService.deleteBatchByCondition(
          facilityCd,
          null,
          updatedOrdMainList.stream().map(OrdMain::getOrdNo).toList(),
          null,
          List.of(OrdMaterialSaveDto.RST_CLASS),
          new ArrayList<>()
        );
        // add #12250 ord_material_saveの処理を2回重複実行している zkm end
      }

    }

    responseInfo.setResultAllChangeBeforeDataInfoList(resultAllChangeBeforeDataInfoList);
    responseInfo.setResultAllChangedDataInfoList(resultAllChangedDataInfoList);

    //次患者更新関連全体見直し対応
    responseInfo.setDoCallNextPatOrdMainList(doCallNextPatOrdMainList);
    if(doCallNextPatOrdMainList != null && !doCallNextPatOrdMainList.isEmpty()){
      List<OrdMain> doCallOrdMainList = doCallNextPatOrdMainList.stream().filter(ordMain ->
        "1".equals(ordMain.getRstDialysisState()) || "2".equals(ordMain.getRstDialysisState())).collect(Collectors.toList());

      if(doCallOrdMainList != null && !doCallOrdMainList.isEmpty()){

        Map<Long, OrdMain> ordMainMap = doCallOrdMainList.stream().collect(Collectors.toMap(OrdMain::getOrdNo, o -> o));

        responseInfo.setHasDoCancel(true);
        //BeforeかAfterを判断して配信画面に行きます
        for (IndScheduleInfo info : beforeIndScheduleInfoList) {
          OrdMain ordMain = ordMainMap.get(info.getOrdNo());
          if(ordMain != null) {
            responseInfo.setDoCancelGoSendordNo(ordMain.getOrdNo());
            responseInfo.setBeforOrAfterFlag("1");
            break;
          }
          else {
            responseInfo.setDoCancelGoSendordNo(doCallOrdMainList.get(0).getOrdNo());
            responseInfo.setBeforOrAfterFlag("2");
            break;
          }
        }
      }
    }
    responseInfo.setHasRad(checkResponse.isHasRad());
    responseInfo.setHasExam(checkResponse.isHasExam());
    responseInfo.setHasPatEvent(checkResponse.isHasPatEvent());
    responseInfo.setMessage(message);
    responseInfo.setPROC_RESULT(PROC_RESULT.SUCCESS.toString());

    return responseInfo;
  }
  // mod #11716 曜日パターン変更の不正 関 end
  @Override
  public List<IndHistory> createIndHistoryForIndSchedule(String facilityCd,
                                            List<OrdMain> beforeOrdMainList,
                                            List<OrdMain> afterOrdMainList){

    Map<Long, OrdMain> afterOrdMainMap = afterOrdMainList.stream().collect(Collectors.toMap(OrdMain::getOrdNo, o -> o));

    List<IndHistory> historyListResult = new ArrayList<>();
    for (OrdMain beforeOrd : beforeOrdMainList) {
      // 更新後治療情報スケジュール編集情報データの作成
      ApiEntityOrdMain.ValiUpdateIndSchedule updBodyData = new ApiEntityOrdMain.ValiUpdateIndSchedule();
      // ログ出力時現行仕様表示部
      updBodyData.setFacility_cd(facilityCd);
      updBodyData.setPat_id(beforeOrd.getPatId().toString());
      updBodyData.setInd_start_date(beforeOrd.getTreatDate());
      updBodyData.setInd_end_date(beforeOrd.getTreatDate());
      updBodyData.setWeek_pattern(beforeOrd.getTreatWeek().toString());
      updBodyData.setInd_kur_cd(beforeOrd.getIndKurCd() != null ?beforeOrd.getIndKurCd().toString() : null);
      updBodyData.setInd_treatment_cd(beforeOrd.getIndTreatmentCd().toString());

      // 更新後データ(更新後開始日は未定)
      updBodyData.setEdit_ind_kur_cd(afterOrdMainMap.get(beforeOrd.getOrdNo()) != null ? afterOrdMainMap.get(beforeOrd.getOrdNo()).getIndKurCd().toString() : null);
      updBodyData.setEdit_ind_treat_date(afterOrdMainMap.get(beforeOrd.getOrdNo()) != null ? afterOrdMainMap.get(beforeOrd.getOrdNo()).getTreatDate() : null);
      updBodyData.setEdit_ind_bed_cd(afterOrdMainMap.get(beforeOrd.getOrdNo()) != null ? afterOrdMainMap.get(beforeOrd.getOrdNo()).getIndBedCd().toString() : null);
      updBodyData.setInd_user_id(afterOrdMainMap.get(beforeOrd.getOrdNo()) != null ? afterOrdMainMap.get(beforeOrd.getOrdNo()).getUpIndUserId().toString() : null);
      updBodyData.setUpd_user_id(afterOrdMainMap.get(beforeOrd.getOrdNo()) != null ? afterOrdMainMap.get(beforeOrd.getOrdNo()).getUpUserId().toString() : null);
      updBodyData.setIs_deadline("");

      String startTime = afterOrdMainMap.get(beforeOrd.getOrdNo()) != null ? afterOrdMainMap.get(beforeOrd.getOrdNo()).getIndTreatStartTime(): null;
      //該当する曜日を取得
      Integer weekNum = beforeOrd.getTreatWeek().intValue();
      List<Integer> weeksArray = Arrays.asList(weekNum);
      List<OrdMain> ordMainList = Arrays.asList(beforeOrd);

      //値がnullの場合はnullセット
      if (Objects.isNull(startTime)) {
        updBodyData.setEdit_ind_treat_start_time(null);
      }
      //文字列→時刻表記に変換して取得(nullの場合は"未登録"に変換)
      else {
        // 治療開始時刻 HHmm形式⇒HH:mm形式
        SimpleDateFormat treatTimeFormat = new SimpleDateFormat("HHmm");
        Date treatTimeDate = null;
        try {
          treatTimeDate = treatTimeFormat.parse(startTime);
        } catch (ParseException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
        updBodyData.setEdit_ind_treat_start_time(new SimpleDateFormat("HH:mm").format(treatTimeDate));
      }

      // 設定パラメータを作成
      String paramTarget = "クール,治療開始時刻,ベッド,治療日";
      List<IndHistory> historyListParamS = indHistoryMakeService.createScheduleHistoryBatch(updBodyData, "2", weeksArray, ordMainList, paramTarget);
      if(historyListParamS != null && !historyListParamS.isEmpty()){
        historyListResult.addAll(historyListParamS);
      }
    }
    return historyListResult;
  }
  /**
   * 日付(yyyymmdd)、開始時刻(HHmmss||HHmm)、経過時間（分）より終了日時を取得
   *
   * @param facilityCd
   * @param indScheduleInfoList
   * @param mstKurList
   * @return Map<String,List<IndScheduleInfo>>
   * @description returning Map indScheduleInfoPriorityDownList and indScheduleInfoList
   */
  public Map<String,List<IndScheduleInfo>> complementIndScheduleInfo(String facilityCd, List<IndScheduleInfo> indScheduleInfoList, List<MstKur> mstKurList) {
    Map<String,List<IndScheduleInfo>> retMap = new HashMap<>();
    List<IndScheduleInfo> indScheduleInfoPriorityDownList = new ArrayList<>();
    if(indScheduleInfoList == null || indScheduleInfoList.isEmpty()){
      retMap.put("indScheduleInfoPriorityDownList",indScheduleInfoPriorityDownList);
      retMap.put("indScheduleInfoList",indScheduleInfoList);
      return retMap;
    }
    SelectOptions selectOptions = SelectOptions.get();
    MstTreatment params = new MstTreatment();
    params.setFacilityCd(facilityCd);
    List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectAll(selectOptions,params);
    List<Integer> indTreatmentPriorityList = mstTreatmentList.stream().map(e -> e.getTreatmentCd()).collect(Collectors.toList());

    List<Long> connectedOrdNoList = indScheduleInfoList.stream().map(o -> o.getOrdNo()).collect(Collectors.toList());
    List<OrdNoAndConnectedTableKeyData> connectedPatEventList = indScheduleDao.selectConnectedPatEventByOrdNoList(facilityCd, connectedOrdNoList);
    Map<Long, List<OrdNoAndConnectedTableKeyData>> connectedPatEventListMap = connectedPatEventList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.toList()));

    List<OrdNoAndConnectedTableKeyData> connectedOrdMainExamMainCdList = indScheduleDao.selectConnectedExamMainCdByOrdNoList(facilityCd, connectedOrdNoList);
    Map<Long, List<Long>> connectedOrdMainExamMainCdListMap = connectedOrdMainExamMainCdList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.mapping(OrdNoAndConnectedTableKeyData::getKey, Collectors.toList())));

    List<OrdNoAndConnectedTableKeyData> connectedOrdMainRadResultCdList = indScheduleDao.selectConnectedRadResultCdByOrdNoList(facilityCd, connectedOrdNoList);
    Map<Long, List<Long>> connectedOrdMainRadResultCdListMap = connectedOrdMainRadResultCdList.stream().collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo, Collectors.mapping(OrdNoAndConnectedTableKeyData::getKey, Collectors.toList())));

    Comparator<IndScheduleInfo> comparator = new IndScheduleInfoComparator(indTreatmentPriorityList);
    Collections.sort(indScheduleInfoList, comparator);

    DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    DateTimeFormatter dateFormatDay = DateTimeFormatter.ofPattern("yyyyMMdd");
    DateTimeFormatter timeFormat = DateTimeFormatter.ofPattern("HHmmss");
    List<MstKur> finalMstKurList = mstKurList.stream().sorted(Comparator.comparing(MstKur::getKurStandardStartTime)).collect(Collectors.toList());
    Map<Long, MstKur> finalMstKurListMap = finalMstKurList.stream().collect(Collectors.toMap(o -> Long.valueOf(o.getKurCd()), o -> o));

    Set<String> uniqueKeys = new HashSet<>();
    indScheduleInfoList.forEach(indScheduleInfo ->
      {
        String key = indScheduleInfo.getPatId() + "-" + indScheduleInfo.getTreatDate() + "-" + indScheduleInfo.getIndKurCd() + "-" + indScheduleInfo.getIndBedCd();

        if (!uniqueKeys.add(key)) {
          indScheduleInfo.setIndBedCd(0L);
          indScheduleInfoPriorityDownList.add(indScheduleInfo);
        }

        Long indKurCd = indScheduleInfo.getIndKurCd();

        // クールが指定されている場合は、計算項目を設定する
        if(indKurCd > 0){
          String kurStandardStartTime = finalMstKurListMap.get(indScheduleInfo.getIndKurCd()).getKurStandardStartTime();

          String tmpTime = indScheduleInfo.getIndTreatStartTime();
          if (!StringUtils.isEmpty(tmpTime)) {
            tmpTime = tmpTime + "00";
          } else {
            tmpTime = kurStandardStartTime;
          }

          // 指示：治療開始時刻 ← クール標準開始時刻で再設定
          indScheduleInfo.setIndTreatStartTime(tmpTime.substring(0, 4));
          // Mst項目：クール内標準治療開始時刻
          indScheduleInfo.setKurStandardStartTime(kurStandardStartTime);

          // 計算項目：治療開始日時 = 治療日 + 指示：治療開始時刻(or クール内標準治療開始時刻)
          String treatDate = indScheduleInfo.getTreatDate();
          indScheduleInfo.setTreatStartDateTime(treatDate+ tmpTime);

          // 計算項目：治療終了日時 = 治療日 + 指示：治療開始時刻(or クール内標準治療開始時刻) + 指示：治療時間
          LocalDateTime endDateTime = LocalDateTime.parse(treatDate + tmpTime, dateFormat);
          if(indScheduleInfo.getIndTreatmentTime() != null) {
            endDateTime = LocalDateTime.parse(treatDate + tmpTime, dateFormat).plusMinutes(Long.parseLong(indScheduleInfo.getIndTreatmentTime()));
          }
          indScheduleInfo.setTreatEndDateTime(endDateTime.format(dateFormat));

          // 計算項目：開始クール治療日 = 治療日
          indScheduleInfo.setFirstKurTreatDate(treatDate);

          // 計算項目：開始クール治療時間 = 治療日 + クール内標準治療開始時刻
          indScheduleInfo.setFirstKurTreatDateTime(treatDate + kurStandardStartTime);
          LocalDateTime treatStartDateTime = LocalDateTime.parse(indScheduleInfo.getTreatStartDateTime(), dateFormat);

          // 計算項目：最終クール治療時間 = 治療日 + クール内標準治療開始時刻
          for (int i = 0; i < finalMstKurList.size(); i++) {
            LocalDateTime currentKurStartDateTime = null;
            LocalDateTime nextKurStartDateTime = null;
            currentKurStartDateTime = endDateTime.with(LocalTime.parse(finalMstKurList.get(i).getKurStartTime(), timeFormat));
            if (i == finalMstKurList.size() - 1) {
              // i = 0 の場合、前日の最終クールを取得する
              LocalDateTime tomorrowDateTime = endDateTime.plusDays(1);
              nextKurStartDateTime = tomorrowDateTime.with(LocalTime.parse(finalMstKurList.get(0).getKurStartTime(), timeFormat));
            } else {
              nextKurStartDateTime = endDateTime.with(LocalTime.parse(finalMstKurList.get(i + 1).getKurStartTime(), timeFormat));
            }

            LocalDateTime currentKurStandardStartDateTime = null;
            // 終了日時＞＝現クール開始時刻（＝含む）
            // 終了日時＜次クール開始時刻
            if ((endDateTime.isAfter(currentKurStartDateTime) || endDateTime.equals(currentKurStartDateTime))
            && endDateTime.isBefore(nextKurStartDateTime)) {
              if(treatStartDateTime.isAfter(currentKurStartDateTime) || treatStartDateTime.equals(currentKurStartDateTime)){
                currentKurStandardStartDateTime = endDateTime.with(LocalTime.parse(finalMstKurList.get(i).getKurStandardStartTime(), timeFormat));
              } else {
                if (i == 0) {
                  // i = 0 の場合、前日の最終クールを取得する
                  LocalDateTime yesterdayDateTime = endDateTime.minusDays(1);
                  currentKurStandardStartDateTime = yesterdayDateTime.with(LocalTime.parse(finalMstKurList.get(finalMstKurList.size() - 1).getKurStandardStartTime(), timeFormat));
                } else {
                  // 最初クール以外の場合は前のクールの情報を取得する
                  currentKurStandardStartDateTime = endDateTime.with(LocalTime.parse(finalMstKurList.get(i - 1).getKurStandardStartTime(), timeFormat));
                }
              }
              // 計算項目：最終クール治療日 = （治療日 + クール内標準治療開始時刻）のyyyyMMdd
              indScheduleInfo.setLastKurTreatDate(currentKurStandardStartDateTime.format(dateFormatDay));
              // 計算項目：最終クール治療時間 = 治療日 + クール内標準治療開始時刻
              indScheduleInfo.setLastKurTreatDateTime(currentKurStandardStartDateTime.format(dateFormat));
              break;
            }
          }
        } else{
          // 指示：治療開始時刻 ← クール標準開始時刻で再設定
          indScheduleInfo.setIndTreatStartTime(null);
          // Mst項目：クール内標準治療開始時刻
          indScheduleInfo.setKurStandardStartTime(null);
          // 計算項目：治療開始日時 = 治療日 + 指示：治療開始時刻(or クール内標準治療開始時刻)
          indScheduleInfo.setTreatStartDateTime(null);
          // 計算項目：治療終了日時 = 治療日 + 指示：治療開始時刻(or クール内標準治療開始時刻) + 指示：治療時間
          indScheduleInfo.setTreatEndDateTime(null);
          // 計算項目：開始クール治療日 = 治療日
          indScheduleInfo.setFirstKurTreatDate(null);
          // 計算項目：開始クール治療時間 = 治療日 + クール内標準治療開始時刻
          indScheduleInfo.setFirstKurTreatDateTime(null);
          // 計算項目：最終クール治療日 = （治療日 + クール内標準治療開始時刻）のyyyyMMdd
          indScheduleInfo.setLastKurTreatDate(null);
          // 計算項目：最終クール治療時間 = 治療日 + クール内標準治療開始時刻
          indScheduleInfo.setLastKurTreatDateTime(null);
        }

        List<OrdNoAndConnectedTableKeyData> connectedPatEventListForOrdNo = connectedPatEventListMap.getOrDefault(indScheduleInfo.getOrdNo(), Collections.emptyList());
        // Connected項目：患者イベント主キーリスト(PatEventCdList)
        indScheduleInfo.setConnectedPatEventCdList(connectedPatEventListForOrdNo.stream().map(o -> o.getKey()).collect(Collectors.toList()));
        // Connected項目：掲示板主キーリスト(BBSCtlNoList)
        indScheduleInfo.setConnectedBbsCtlNoList(
          connectedPatEventListForOrdNo.stream()
            .filter(o -> o.getData() != null && (Long)o.getData() > 0)
            .map(o -> (Long)o.getData())
            .collect(Collectors.toList())
        );
        // Connected項目：一般検査主キーリスト(examMainCdList)
        indScheduleInfo.setConnectedExamMainCdList(connectedOrdMainExamMainCdListMap.getOrDefault(indScheduleInfo.getOrdNo(), Collections.emptyList()));
        // Connected項目：X線検査依頼主キーリスト(radResultCdList)
        indScheduleInfo.setConnectedRadResultCdList(connectedOrdMainRadResultCdListMap.getOrDefault(indScheduleInfo.getOrdNo(), Collections.emptyList()));

      }
    );
    retMap.put("indScheduleInfoPriorityDownList",indScheduleInfoPriorityDownList);
    retMap.put("indScheduleInfoList",indScheduleInfoList);
    return retMap;
  }

  private void addToMapList(Map<String, List<Object>> map, String key, Object value) {
    // Map内存在しない場合は新規で入れる
    if (!map.containsKey(key)) {
      List<Object> list = new ArrayList<>();
      list.addAll((List<?>) value);
      map.put(key, list);
    } else {
      // Map内既に存在するのであれば、既存リストへデータマージ
      List<Object> list = map.get(key);
      list.addAll((List<?>) value);
      list.stream().distinct().collect(Collectors.toList());
    }
  }

  /**
   * スケジュール更新モード
   */
  public enum MODE_SCHEDULE_MOVE {
    /**
     * クール・ベッド・治療開始時刻の変更
     */
    MULTI_FROM_PAT_VIEWER,
    /**
     * スケジュール表
     */
    MULTI_FROM_SCHEDULE_LIST,
    /**
     * その他(１オーダー)
     */
    OTHER_ONE_ORDER,
  }

  /**
   * 戻り値
   */
  public enum PROC_RESULT {
    /**
     * 正常終了
     */
    SUCCESS,
    /**
     * パラメータ異常
     */
    PARAM_ERR,
    /**
     * 異常終了
     */
    ERROR,
    /**
     * 警告(処理未実施)
     */
    WARN,
  }

  public class IndScheduleInfoComparator implements Comparator<IndScheduleInfo> {
    private List<Integer> indTreatmentPriorityList;

    public IndScheduleInfoComparator(List<Integer> indTreatmentPriorityList) {
      this.indTreatmentPriorityList = indTreatmentPriorityList;
    }

    @Override
    public int compare(IndScheduleInfo info1, IndScheduleInfo info2) {
      // treatDateによる比較
      int compareByDate = info1.getTreatDate().compareTo(info2.getTreatDate());
      if (compareByDate != 0) {
        return compareByDate;
      }

      // indKurCdによる比較
      int compareByKurCd = info1.getIndKurCd().compareTo(info2.getIndKurCd());
      if (compareByKurCd != 0) {
        return compareByKurCd;
      }

      // indBedCdによる比較
      int compareByBedCd = info1.getIndBedCd().compareTo(info2.getIndBedCd());
      if (compareByBedCd != 0) {
        return compareByBedCd;
      }

      // indTreatmentCdの優先度リストによる比較
      int priorityIndex1 = indTreatmentPriorityList.indexOf(info1.getIndTreatmentCd());
      int priorityIndex2 = indTreatmentPriorityList.indexOf(info2.getIndTreatmentCd());
      return Integer.compare(priorityIndex1, priorityIndex2);
    }
  }
  /**
   * facilityCd 施設コード
   * delOrdNoList 削除予定のordno
   * delOrdMainList 削除予定のordmain情報
   * resultMapKey 処理区分
   * selectOrdNoRelatedExamOrRad ordnoに関連する検査予定を検索
   * deleteExamOrRadInfo 検査予定削除
   * addDeletedScheduleToResult 削除済予定結果追加
   * */
  private <T> void processAndDeleteConnectedData(
    String facilityCd,
    List<OrdMain> delOrdMainList,
    String resultMapKey,
    Function<List<Long>, List<OrdNoAndConnectedTableKeyData>> selectOrdNoRelatedExamOrRad,
    BiFunction<String, List<IndScheduleInfo>, List<T>> deleteExamOrRadInfo,
    BiConsumer<List<T>, Map<String, List<Object>>> addDeletedScheduleToResult,
    Map<String, List<Object>> resultAllChangedDataInfoList
  ) {
    if (delOrdMainList == null || delOrdMainList.isEmpty()) {
      return;
    }

    List<Long> delOrdNoList = Optional.ofNullable(delOrdMainList)
      .orElseGet(Collections::emptyList)
      .stream()
      .map(i -> i.getOrdNo())
      .collect(Collectors.toList());

    List<OrdNoAndConnectedTableKeyData> connectedDataList = selectOrdNoRelatedExamOrRad.apply(delOrdNoList);
    if (connectedDataList == null || connectedDataList.isEmpty()) {
      return;
    }

    Map<Long, List<OrdNoAndConnectedTableKeyData>> groupedMap = connectedDataList.stream()
      .collect(Collectors.groupingBy(OrdNoAndConnectedTableKeyData::getOrdNo));

    List<IndScheduleInfo> indInfoDelList = new ArrayList<>();
    for (OrdMain ordMain : delOrdMainList) {
      List<OrdNoAndConnectedTableKeyData> relatedData = groupedMap.getOrDefault(ordMain.getOrdNo(), Collections.emptyList());
      if (!relatedData.isEmpty()) {
        IndScheduleInfo info = new IndScheduleInfo();
        info.setFacilityCd(facilityCd);

        info.setTreatDate(ordMain.getTreatDate());

        List<Long> keys = relatedData.stream().map(OrdNoAndConnectedTableKeyData::getKey).collect(Collectors.toList());

        setConnectedKeyList(info, resultMapKey, keys);

        indInfoDelList.add(info);
      }
    }

    if (!indInfoDelList.isEmpty()) {
      List<T> deletedList = deleteExamOrRadInfo.apply(facilityCd, indInfoDelList);
      if (deletedList != null && !deletedList.isEmpty()) {
        deletedList.forEach(item -> {
          try {
            item.getClass().getMethod("setIsDel", String.class).invoke(item, "1");
          } catch (Exception e) {
          }
        });
      }
      addDeletedScheduleToResult.accept(deletedList, resultAllChangedDataInfoList);
    }
  }
  private void setConnectedKeyList(IndScheduleInfo info, String resultMapKey, List<Long> keys) {
    try {
      if ("pat_exam_main".equals(resultMapKey)) {
        info.setConnectedExamMainCdList(keys);
      } else if ("pat_rad_main".equals(resultMapKey)) {
        info.setConnectedRadResultCdList(keys);
      }
    } catch (Exception e) {
    }
  }
  public void deleteRelatedPatEvents(
    String facilityCd,
    Long patId,
    List<OrdMain> delOrdMainList,
    PatEventService patEventService,
    PatEventDao patEventDao
  ) {
    List<PatEvent> allEventsToDelete = new ArrayList<>();

    // 1. 実績リンク：ordNo に紐づくイベント
    List<Long> ordNos = delOrdMainList.stream()
      .map(OrdMain::getOrdNo)
      .filter(Objects::nonNull)
      .collect(Collectors.toList());

    if (!ordNos.isEmpty()) {
      List<PatEvent> ordLinkedEvents = patEventService.selectByOrdNos(facilityCd, patId, ordNos);
      if (ordLinkedEvents != null && !ordLinkedEvents.isEmpty()) {
        Map<Long, List<PatEvent>> ordMap = ordLinkedEvents.stream()
          .filter(e -> e.getOrdNo() != null)
          .collect(Collectors.groupingBy(PatEvent::getOrdNo));

        List<PatEvent> matchedEvents = ordNos.stream()
          .flatMap(ordNo -> ordMap.getOrDefault(ordNo, Collections.emptyList()).stream())
          .collect(Collectors.toList());

        allEventsToDelete.addAll(matchedEvents);
      }
    }

    // 2. 治療日関連（ordNo が null または 0 のイベント）
    List<String> treatDates = delOrdMainList.stream()
      .map(OrdMain::getTreatDate)
      .filter(Objects::nonNull)
      .distinct()
      .collect(Collectors.toList());

    if (!treatDates.isEmpty()) {
      List<PatEvent> dateLinkedEvents = patEventDao.selectByPatIdAndEventStartDates(facilityCd, patId, treatDates);
      if (dateLinkedEvents != null && !dateLinkedEvents.isEmpty()) {
        List<PatEvent> filtered = dateLinkedEvents.stream()
          .filter(e -> e.getOrdNo() == null || e.getOrdNo() == 0)
          .collect(Collectors.toList());

        allEventsToDelete.addAll(filtered);
      }
    }

    // 3. 削除処理
    if (!allEventsToDelete.isEmpty()) {
      deletePatEvents(allEventsToDelete, facilityCd, patId);
    }
  }
  private void deletePatEvents(List<PatEvent> events, String facilityCd, Long patId) {
    if (events == null || events.isEmpty()) return;

    List<Long> delBbsCtlNos = events.stream()
      .map(PatEvent::getBbsCtlNo)
      .filter(bbsCtlNo -> bbsCtlNo != null && bbsCtlNo != 0)
      .distinct()
      .collect(Collectors.toList());

    if (!delBbsCtlNos.isEmpty()) {
      bbsInfoDao.updateIsDispToZeroByList(facilityCd, delBbsCtlNos);
    }

    List<Long> delPatEventCds = events.stream()
      .map(PatEvent::getPatEventCd)
      .filter(patEventCd -> patEventCd != null && patEventCd != 0)
      .distinct()
      .collect(Collectors.toList());

    if (!delPatEventCds.isEmpty()) {
      patEventDao.updateIsDelToZeroByList(facilityCd, patId, delPatEventCds);
    }
  }
  public void processChangeDependentExamAndRad(WeekPatternResponse weekPatternDataInfo, String facilityCd, UpdateScheduleListDataResponse checkResponse,
                                                IndscheduleChangeUserSelectedInfo indscheduleChangeUserSelectedInfo, List<IndScheduleInfo> toBeOrdScheduleListAllForCheak,
                                                Map<String, List<Object>> resultAllChangedDataInfoList, Map<String, List<Object>> resultAllChangeBeforeDataInfoList,
                                               List<OrdMain> delOrdMainList, Long indUserId, Long updUserId, String flag) {

    EventLogMessage eventLogMessage = new EventLogMessage();

    String message = "";

    final String className = new Object() {}.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {}.getClass().getEnclosingMethod().getName();

    List<IndScheduleInfo> filteredList;

    boolean hasWeekPatternCondition =
      weekPatternDataInfo != null
        && weekPatternDataInfo.getTreatmentCd() != null
        && weekPatternDataInfo.getPatId() != null;

    if (hasWeekPatternCondition) {
      filteredList =
        toBeOrdScheduleListAllForCheak.stream()
          .filter(i ->
            Objects.equals(i.getIndTreatmentCd(), weekPatternDataInfo.getTreatmentCd())
              && Objects.equals(i.getPatId(), weekPatternDataInfo.getPatId())
          )
          .collect(Collectors.toList());
    } else {
      filteredList = toBeOrdScheduleListAllForCheak;
    }

    // 患者イベントの連動処理
    if (checkResponse.isHasPatEvent() && indscheduleChangeUserSelectedInfo.getFacilitySetting3005SelectedVal() != null) {

      List<BbsInfo> bbsInfoListBefore;
      List<PatEvent> patEventListBefore;
      List<BbsInfo> bbsInfoList;
      List<PatEvent> patEventList;

      switch (indscheduleChangeUserSelectedInfo.getFacilitySetting3005SelectedVal()) {
        case "1":
          // BBSの更新
          if (filteredList != null && !filteredList.isEmpty()) {
            bbsInfoListBefore = indScheduleDao.selectForUpdateBbsInfoByIndSchdueInfoList(facilityCd, filteredList);
            this.addToMapList(resultAllChangeBeforeDataInfoList, "bbs_info", bbsInfoListBefore); // 変更前データ退避

            bbsInfoList = indScheduleDao.updateBbsInfoByIndSchdueInfoList(facilityCd, filteredList);
            this.addToMapList(resultAllChangedDataInfoList, "bbs_info", bbsInfoList); // 変更後データ退避

            // 患者イベントの更新
            patEventListBefore = indScheduleDao.selectForUpdatePatEventByIndSchdueInfoList(facilityCd, filteredList);
            this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_event", patEventListBefore); // 変更前データ退避

            patEventList = indScheduleDao.updatePatEventByIndSchdueInfoList(facilityCd, filteredList);
            this.addToMapList(resultAllChangedDataInfoList, "pat_event", patEventList); // 変更後データ退避
          }

          deleteRelatedPatEvents(facilityCd, weekPatternDataInfo.getPatId(), delOrdMainList, patEventService, patEventDao);
          break;
        case "2":
          // BBSの更新
          if (filteredList != null && !filteredList.isEmpty()) {
            bbsInfoListBefore = indScheduleDao.selectForUpdateBbsInfoToDeleteByIndSchdueInfoList(facilityCd, filteredList);
            this.addToMapList(resultAllChangeBeforeDataInfoList, "bbs_info", bbsInfoListBefore); // 変更前データ退避

            bbsInfoList = indScheduleDao.updateBbsInfoToDeleteByIndSchdueInfoList(facilityCd, filteredList);
            this.addToMapList(resultAllChangedDataInfoList, "bbs_info", bbsInfoList); // 変更後データ退避

            // 患者イベントの更新
            patEventListBefore = indScheduleDao.selectForUpdatePatEventToDeleteByIndSchdueInfoList(facilityCd, filteredList);
            this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_event", patEventListBefore); // 変更前データ退避

            patEventList = indScheduleDao.updatePatEventToDeleteByIndSchdueInfoList(facilityCd, filteredList);
            this.addToMapList(resultAllChangedDataInfoList, "pat_event", patEventList); // 変更後データ退避
          }

          deleteRelatedPatEvents(facilityCd, weekPatternDataInfo.getPatId(), delOrdMainList, patEventService, patEventDao);

          break;
        case "3":
          break;
        case "4":
          // あり得ないケース
        default:
          // あり得ないケース
          message = " 処理中異常が発生しました。 indscheduleChangeUserSelectedInfo.getFacilitySetting3005SelectedVal():" + indscheduleChangeUserSelectedInfo.getFacilitySetting3005SelectedVal();
          eventLogMessage.setLogMessage(className + "." + methodName + message);
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          break;
      }
    }

    // 一般検査依頼の連動処理
    if(checkResponse.isHasExam() && indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal() != null){
      List<PatExamMain> patExamMainListBefore;
      List<PatExamMain> patExamMainList;
      switch (indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal()){
        case "1":
          // 既存マージ分
          if (filteredList != null && !filteredList.isEmpty()) {
            patExamMainListBefore = indScheduleDao.selectForUpdatePatExamMainByIndSchdueInfoList(facilityCd, filteredList);
            this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_exam_main", patExamMainListBefore); // 変更前データ退避

            List<PatExamMain> patExamMainUList = indScheduleDao.updatePatExamMainByIndSchdueInfoList(facilityCd, filteredList);

            // 新規作成分 ※変更前データは退避しない
            List<PatExamMain> patExamMainCList = indScheduleDao.insertPatExamMainByIndSchdueInfoList(facilityCd, filteredList);

            // 削除・hst退避分 ※変更前データは退避しない
            List<PatExamMain> patExamMainDList = indScheduleDao.deletePatExamMainToHistoryByIndSchdueInfoList(facilityCd, filteredList);
            for (PatExamMain patExamMain : patExamMainDList) {
              patExamMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
            }

            this.addToMapList(resultAllChangedDataInfoList, "pat_exam_main", patExamMainDList); // 変更後データ退避
            this.addToMapList(resultAllChangedDataInfoList, "pat_exam_main", patExamMainCList); // 変更後データ退避
            this.addToMapList(resultAllChangedDataInfoList, "pat_exam_main", patExamMainUList); // 変更後データ退避
          }

          if (delOrdMainList !=null && !delOrdMainList.isEmpty()) {
            processAndDeleteConnectedData(
              facilityCd,
              delOrdMainList,
              "pat_exam_main",
              (delOrdNos) -> indScheduleDao.selectConnectedExamMainCdByOrdNoList(facilityCd, delOrdNos),
              (fc, indInfoList) -> indScheduleDao.deletePatExamMainToHistoryByIndSchdueInfoList(fc, indInfoList),
              (deletedList, resultMap) -> this.addToMapList(resultMap, "pat_exam_main", (List<Object>)(List<?>) deletedList),
              resultAllChangedDataInfoList
            );
          }

          break;
        case "2":
          // 削除・hst退避分 ※変更前データは退避しない
          if (filteredList != null && !filteredList.isEmpty()) {
            patExamMainList = indScheduleDao.deletePatExamMainToHistoryByIndSchdueInfoList(facilityCd, filteredList);
            for (PatExamMain patExamMain : patExamMainList) {
              patExamMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
            }
            this.addToMapList(resultAllChangedDataInfoList, "pat_exam_main", patExamMainList); // 変更後データ退避
          }

          if (delOrdMainList !=null && !delOrdMainList.isEmpty()) {
            processAndDeleteConnectedData(
              facilityCd,
              delOrdMainList,
              "pat_exam_main",
              (delOrdNos) -> indScheduleDao.selectConnectedExamMainCdByOrdNoList(facilityCd, delOrdNos),
              (fc, indInfoList) -> indScheduleDao.deletePatExamMainToHistoryByIndSchdueInfoList(fc, indInfoList),
              (deletedList, resultMap) -> this.addToMapList(resultMap, "pat_exam_main", (List<Object>)(List<?>) deletedList),
              resultAllChangedDataInfoList
            );
          }

          break;
        case "3":
          break;
        case "4":
          // あり得ないケース
        default:
          // あり得ないケース
          message = " 処理中異常が発生しました。 indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal():" + indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal();
          eventLogMessage.setLogMessage(className + "." + methodName + message);
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          break;
      }
    }

    // 放射線検査依頼の連動処理
    if(checkResponse.isHasRad()&& indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal() != null){
      List<PatRadMain> patRadMainListBefore;
      List<PatRadMain> patRadMainList;
      switch (indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal()){
        case "1":
          // 既存マージ分
          // 新規作成分 ※変更前データは退避しない
          if (filteredList != null && !filteredList.isEmpty()) {
            List<PatRadMain> patRadMainCList = indScheduleDao.insertPatRadMainByIndSchdueInfoList(facilityCd, filteredList);

            // 削除・hst退避分 ※変更前データは退避しない
            List<PatRadMain> patRadMainDList = indScheduleDao.deletePatRadMainToHistoryByIndSchdueInfoList(facilityCd, filteredList);
            for (PatRadMain patRadMain : patRadMainDList) {
              patRadMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
            }
            this.addToMapList(resultAllChangedDataInfoList, "pat_rad_main", patRadMainDList); // 変更後データ退避
            this.addToMapList(resultAllChangedDataInfoList, "pat_rad_main", patRadMainCList); // 変更後データ退避
          }

          if (delOrdMainList !=null && !delOrdMainList.isEmpty()) {
            processAndDeleteConnectedData(
              facilityCd,
              delOrdMainList,
              "pat_rad_main",
              (delOrdNos) -> indScheduleDao.selectConnectedRadResultCdByOrdNoList(facilityCd, delOrdNos),
              (fc, indInfoList) -> indScheduleDao.deletePatRadMainToHistoryByIndSchdueInfoList(fc, indInfoList),
              (deletedList, resultMap) -> this.addToMapList(resultMap, "pat_rad_main", (List<Object>)(List<?>) deletedList),
              resultAllChangedDataInfoList
            );
          }

          break;
        case "2":
          // 削除・hst退避分 ※変更前データは退避しない
          if (filteredList != null && !filteredList.isEmpty()) {
            patRadMainList = indScheduleDao.deletePatRadMainToHistoryByIndSchdueInfoList(facilityCd, filteredList);
            for (PatRadMain patRadMain : patRadMainList) {
              patRadMain.setIsDel("1"); // リストに追加する前にdelフラグを立てる
            }
            this.addToMapList(resultAllChangedDataInfoList, "pat_rad_main", patRadMainList); // 変更後データ退避
          }

          if (delOrdMainList !=null && !delOrdMainList.isEmpty()) {
            processAndDeleteConnectedData(
              facilityCd,
              delOrdMainList,
              "pat_rad_main",
              (delOrdNos) -> indScheduleDao.selectConnectedRadResultCdByOrdNoList(facilityCd, delOrdNos),
              (fc, indInfoList) -> indScheduleDao.deletePatRadMainToHistoryByIndSchdueInfoList(fc, indInfoList),
              (deletedList, resultMap) -> this.addToMapList(resultMap, "pat_rad_main", (List<Object>)(List<?>) deletedList),
              resultAllChangedDataInfoList
            );
          }

          break;
        case "3":
          break;
        case "4":
          // あり得ないケース
        default:
          // あり得ないケース
          message = " 処理中異常が発生しました。 indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal():" + indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal();
          eventLogMessage.setLogMessage(className + "." + methodName + message);
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          break;
      }
    }
    if (weekPatternDataInfo.getIsEndDateUnset() != null && !weekPatternDataInfo.getIsEndDateUnset()) {
      List<Integer> delWeekList = weekPatternDataInfo.getDelWeekList();

      weekPatternInfoServiceImpl.processWeekChangeLinkedPatterns(
        delOrdMainList,
        delWeekList,
        weekPatternDataInfo.getPatId(),
        indscheduleChangeUserSelectedInfo.getFacilitySetting1007SelectedVal(),
        indscheduleChangeUserSelectedInfo.getFacilitySetting1008SelectedVal(),
        facilityCd,
        indUserId,
        updUserId,
        flag
      );
    }
  }
  // add #11716 曜日パターン変更の不正 関 end
}
