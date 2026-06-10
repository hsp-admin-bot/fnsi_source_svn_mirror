package jp.co.nikkiso.ntss.admin_web.service.ordmain.check;

import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.IndScheduleDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.dto.indSchedule.OrdNoAndConnectedTableKeyData;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class OrdScheduleMoveCheck {

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private IndScheduleDao indScheduleDao;

  @Autowired
  private MstKurDao mstKurDao;

  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  private MstTreatmentDao mstTreatmentDao;

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

  public UpdateScheduleListDataResponse checkOrdScheduleMove(List<IndScheduleInfo> beforeIndScheduleInfoList, List<IndScheduleInfo> afterIndScheduleInfoList,
                                             String facilityCd, IndscheduleChangeUserSelectedInfo indscheduleChangeUserSelectedInfo, Long indUserId, Long updUserId) {

    UpdateScheduleListDataResponse responseInfo = new UpdateScheduleListDataResponse();
    //開始ログ
    final String className = new Object() {}.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {}.getClass().getEnclosingMethod().getName();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);


    // 処理変数定義
    String message = "";
    List<String> msgCdList = new ArrayList<>();
    int count = 0;
    boolean hasRst = false;
    Map<Long, IndScheduleInfo> interfaceUsedIndScheduleInfoMap = new HashMap<>();

    List<IndScheduleInfo> indScheduleInfoListGo = new ArrayList<>();
    List<IndScheduleInfo> indScheduleInfoListBack = new ArrayList<>();

    // 引数チェック・補正
    boolean[] prmCheckErr = new boolean[6]; // prm数8
    if(facilityCd == null){ prmCheckErr[0] = true; }
    if(beforeIndScheduleInfoList == null){ prmCheckErr[1] = true; }
    if(afterIndScheduleInfoList == null){ prmCheckErr[2] = true; }
    if(indscheduleChangeUserSelectedInfo == null){ prmCheckErr[3] = true; }
    if(indUserId == null){ prmCheckErr[4] = true; }
    if(updUserId == null){ prmCheckErr[5] = true; }

    // ログ
    for(int i = 0; i < 6; i++){
      if(prmCheckErr[i]){
        message += " パラメータ[" + i + "]未設定";
      }
    }
    if (message != "") {
      eventLogMessage.setLogMessage(className + "." + methodName + message);
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      responseInfo.setMessage(message);
      responseInfo.setMsgCdList(msgCdList);
      responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.PARAM_ERR.toString());

      return responseInfo;
    }

    if(beforeIndScheduleInfoList.size() != afterIndScheduleInfoList.size()){
      message += " 変更前後のオーダースケジュール件数が一致しません";
      eventLogMessage.setLogMessage(className + "." + methodName + message);
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      responseInfo.setMessage(message);
      responseInfo.setMsgCdList(msgCdList);
      responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.PARAM_ERR.toString());
      return responseInfo;
    }
    for(int i = 0 ; i < beforeIndScheduleInfoList.size(); i++) {
      if (Objects.equals(beforeIndScheduleInfoList.get(i).getOrdNo(), afterIndScheduleInfoList.get(i).getOrdNo())) {
        afterIndScheduleInfoList.get(i).setOrdNo(null);
        afterIndScheduleInfoList.get(i).setPatId(null);
      }
    }
    count = beforeIndScheduleInfoList.size();

    // スケジュール作成可能期間外かどうかをチェック
    if (!CollectionUtils.isEmpty(beforeIndScheduleInfoList)) {

      List<Long> patIdList = beforeIndScheduleInfoList.stream().map(b -> b.getPatId()).filter(Objects::nonNull).distinct().collect(Collectors.toList());

      String treatDate = afterIndScheduleInfoList.stream().map(a -> a.getTreatDate()).filter(Objects::nonNull).findFirst().orElse(null);

      if (!CollectionUtils.isEmpty(patIdList) && StringUtils.hasText(treatDate)) {

        List<Long> outOfSchedulePatIds  = patMainDao.selectPatIdListBySchExtEndDateAfterTreatDate(patIdList, facilityCd, treatDate);

        if (!CollectionUtils.isEmpty(outOfSchedulePatIds)) {
          List<PatPersonalMain> patPersonalMainList = patPersonalMainDao.selectByIdListFacilityCd(outOfSchedulePatIds, facilityCd);

          List<String> patNameList = patPersonalMainList.stream()
              .map(p -> {
                String lastName = StringUtils.hasText(p.getPat_last_name()) ? p.getPat_last_name() : "";
                String firstName = StringUtils.hasText(p.getPat_first_name()) ? p.getPat_first_name() : "";
                return (lastName + " " + firstName).trim();
              })
              .collect(Collectors.toList());

          message += " スケジュール作成可能期間外のため予定を作成できません。";
          eventLogMessage.setLogMessage(className + "." + methodName + message);
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          responseInfo.setMessage(message);
          responseInfo.setMsgCdList(msgCdList);
          responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
          responseInfo.setMsgCd("70000041");
          responseInfo.setOutOfSchedulePatNameList(patNameList);

          return responseInfo;
        }
      }
    }

    // 治療中のデータを移動しているかをチェック
    List<Long> excludeOrdNoListBack = beforeIndScheduleInfoList.stream().map(o -> o.getOrdNo()).filter(Objects::nonNull).collect(Collectors.toList());
    List<Long> excludeOrdNoListGo = afterIndScheduleInfoList.stream().map(o -> o.getOrdNo()).filter(Objects::nonNull).filter(ordNo -> ordNo > 0).collect(Collectors.toList());

    List<Long> mergedAllOrdNoListList = new ArrayList<>();
    mergedAllOrdNoListList.addAll(excludeOrdNoListBack);
    mergedAllOrdNoListList.addAll(excludeOrdNoListGo);
    // 治療中のデータを移動しているかをチェック(行き)
    if(excludeOrdNoListBack.size() > 0){
      indScheduleInfoListGo = indScheduleDao.selectIndScheduleInfoByOrdNoList(facilityCd, excludeOrdNoListBack);
      if(indScheduleInfoListGo.stream()
        .filter(o -> o.getRstDialysisState().equals("3"))
        .collect(Collectors.toList()).size() > 0){
        message += " 治療中患者のスケジュール変更はできません。";
        eventLogMessage.setLogMessage(className + "." + methodName + message);
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        responseInfo.setMessage(message);
        responseInfo.setMsgCdList(msgCdList);
        responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        responseInfo.setMsgCd("22020005");

        return responseInfo;
      }
      if(indScheduleInfoListGo.stream()
        .filter(o -> !o.getRstDialysisState().equals("0"))
        .collect(Collectors.toList()).size() > 0 && indScheduleInfoListGo.size() > 1){
        message += " 複数件の実績あり予定は操作できません。";
        eventLogMessage.setLogMessage(className + "." + methodName + message);
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        responseInfo.setMessage(message);
        responseInfo.setMsgCdList(msgCdList);
        responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());

        return responseInfo;
      }
      switch (indScheduleInfoListGo.get(0).getRstDialysisState()){
        case "4":
        case "5":
        case "6":
          hasRst = true;
          break;
        default:
          break;
      }
      for (IndScheduleInfo indScheduleInfo : indScheduleInfoListGo) {
        interfaceUsedIndScheduleInfoMap.put(indScheduleInfo.getOrdNo(), indScheduleInfo);
      }
    }

    // 治療中のデータを移動しているかをチェック(行き)
    if(excludeOrdNoListGo.size() > 0){
      indScheduleInfoListBack = indScheduleDao.selectIndScheduleInfoByOrdNoList(facilityCd, excludeOrdNoListGo);
      if(indScheduleInfoListBack.stream()
        .filter(o -> o.getRstDialysisState().equals("3"))
        .collect(Collectors.toList()).size() > 0){
        message += " 治療中患者のスケジュール変更はできません。";
        eventLogMessage.setLogMessage(className + "." + methodName + message);
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        responseInfo.setMessage(message);
        responseInfo.setMsgCdList(msgCdList);
        responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        responseInfo.setMsgCd("22020005");

        return responseInfo;
      }
      if(indScheduleInfoListBack.stream()
        .filter(o -> !o.getRstDialysisState().equals("0"))
        .collect(Collectors.toList()).size() > 1){
        message += " 複数件の実績あり予定は操作できません。";
        eventLogMessage.setLogMessage(className + "." + methodName + message);
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        responseInfo.setMessage(message);
        responseInfo.setMsgCdList(msgCdList);
        responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.PARAM_ERR.toString());

        return responseInfo;
      }
      switch (indScheduleInfoListBack.get(0).getRstDialysisState()){
        case "4":
        case "5":
        case "6":
          hasRst = true;
          break;
        default:
          break;
      }
      for (IndScheduleInfo indScheduleInfo : indScheduleInfoListBack) {
        interfaceUsedIndScheduleInfoMap.put(indScheduleInfo.getOrdNo(), indScheduleInfo);
      }
    }
    // 行き方向チェック
    List<IndScheduleInfo> toBeOrdScheduleListGo = new ArrayList<>();
    Set<String> uniqueKeysGo = new HashSet<>();
    List<IndScheduleInfo> dupulicateOrdMainPartsGo = new ArrayList<>();
    for(int i = 0; i < count; i++){
      IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
      indScheduleInfo.setFacilityCd(facilityCd);
      Long ordNo = beforeIndScheduleInfoList.get(i).getOrdNo();
      indScheduleInfo.setOrdNo(ordNo);
      indScheduleInfo.setPatId(beforeIndScheduleInfoList.get(i).getPatId());
      indScheduleInfo.setOldTreatDate(beforeIndScheduleInfoList.get(i).getTreatDate());
      indScheduleInfo.setTreatDate(afterIndScheduleInfoList.get(i).getTreatDate());
      indScheduleInfo.setIndKurCd(afterIndScheduleInfoList.get(i).getIndKurCd());
      indScheduleInfo.setIndBedCd(afterIndScheduleInfoList.get(i).getIndBedCd());
      indScheduleInfo.setIndTreatmentCd(interfaceUsedIndScheduleInfoMap.get(ordNo).getIndTreatmentCd());
      indScheduleInfo.setIndTreatmentTime(interfaceUsedIndScheduleInfoMap.get(ordNo).getIndTreatmentTime());
      indScheduleInfo.setTreatWeek(interfaceUsedIndScheduleInfoMap.get(ordNo).getTreatWeek());
      // 引数のIndex番号を覚える
      indScheduleInfo.setOrgIndex(i);
      toBeOrdScheduleListGo.add(indScheduleInfo);
      String key = indScheduleInfo.getPatId() + "-" + indScheduleInfo.getTreatDate() + "-" + indScheduleInfo.getIndKurCd() + "-" + indScheduleInfo.getIndTreatmentCd();
      if (!uniqueKeysGo.add(key)) {
        dupulicateOrdMainPartsGo.add(indScheduleInfo);
      }

    }
    dupulicateOrdMainPartsGo.addAll(indScheduleDao.selectSamePatDateKurTreatmentByIndScheduleList(facilityCd, toBeOrdScheduleListGo, mergedAllOrdNoListList));
    if(dupulicateOrdMainPartsGo.size() > 0 && toBeOrdScheduleListGo !=null && toBeOrdScheduleListGo.size() >0){
      message += " 移動後同一患者・同一治療日・同一クール・同一治療方法のデータが作成されるため、変更できません。※行き方向";
      eventLogMessage.setLogMessage(className + "." + methodName + message);
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
      logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      responseInfo.setMessage(message);
      responseInfo.setMsgCdList(msgCdList);
      responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
      // 治療方法・クールの重複する治療予定が存在する場合、メッセージを表示する
      responseInfo.setMsgCd("70000001");

      return responseInfo;
    }

    // 帰り方向チェック
    List<IndScheduleInfo> toBeOrdScheduleListBack = new ArrayList<>();
    Set<String> uniqueKeysBack = new HashSet<>();
    List<IndScheduleInfo> dupulicateOrdMainPartsBack = new ArrayList<>();
    for(int i = 0; i < count; i++){
      IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
      indScheduleInfo.setFacilityCd(facilityCd);
      Long ordNo = afterIndScheduleInfoList.get(i).getOrdNo();
      // 空いているベッドへ移動の場合はスルーする
      if(null != ordNo){
        indScheduleInfo.setOrdNo(ordNo);
        indScheduleInfo.setPatId(afterIndScheduleInfoList.get(i).getPatId());
        indScheduleInfo.setOldTreatDate(afterIndScheduleInfoList.get(i).getTreatDate());
        indScheduleInfo.setTreatDate(beforeIndScheduleInfoList.get(i).getTreatDate());
        indScheduleInfo.setIndKurCd(beforeIndScheduleInfoList.get(i).getIndKurCd());
        indScheduleInfo.setIndBedCd(beforeIndScheduleInfoList.get(i).getIndBedCd());
        indScheduleInfo.setIndTreatmentCd(interfaceUsedIndScheduleInfoMap.get(ordNo).getIndTreatmentCd());
        indScheduleInfo.setIndTreatmentTime(interfaceUsedIndScheduleInfoMap.get(ordNo).getIndTreatmentTime());
        indScheduleInfo.setTreatWeek(interfaceUsedIndScheduleInfoMap.get(ordNo).getTreatWeek());
        // 引数のIndex番号を覚える
        indScheduleInfo.setOrgIndex(i);
        toBeOrdScheduleListBack.add(indScheduleInfo);

        String key = indScheduleInfo.getPatId() + "-" + indScheduleInfo.getTreatDate() + "-" + indScheduleInfo.getIndKurCd() + "-" + indScheduleInfo.getIndTreatmentCd();
        if (!uniqueKeysBack.add(key)) {
          dupulicateOrdMainPartsBack.add(indScheduleInfo);
        }
      }
    }
    // 操作対象治療予定が存在しない場合は処理をスルー（帰り）
    if(toBeOrdScheduleListBack.size() > 0){
      dupulicateOrdMainPartsBack.addAll(indScheduleDao.selectSamePatDateKurTreatmentByIndScheduleList(facilityCd, toBeOrdScheduleListBack, mergedAllOrdNoListList));
      if(dupulicateOrdMainPartsBack.size() > 0){
        message += " 移動後同一患者・同一治療日・同一クール・同一治療方法のデータが作成されるため、変更できません。※帰り方向";
        eventLogMessage.setLogMessage(className + "." + methodName + message);
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        responseInfo.setMessage(message);
        // 治療方法・クールの重複する治療予定が存在する場合、メッセージを表示する
        responseInfo.setMsgCdList(msgCdList);
        responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        responseInfo.setMsgCd("70000001");

        return responseInfo;
      }
    }
    SelectOptions options = SelectOptions.get();
    List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, facilityCd, "0");

    Map<String, List<IndScheduleInfo>> toBeOrdScheduleListGoMap = this.complementIndScheduleInfo(facilityCd, toBeOrdScheduleListGo, mstKurList);
    toBeOrdScheduleListGo = toBeOrdScheduleListGoMap.get("indScheduleInfoList");
    List<IndScheduleInfo> toBeOrdScheduleLPriorityDownListGo = toBeOrdScheduleListGoMap.get("indScheduleInfoPriorityDownList");

    Map<String, List<IndScheduleInfo>> toBeOrdScheduleListBackMap = this.complementIndScheduleInfo(facilityCd, toBeOrdScheduleListBack, mstKurList);

    toBeOrdScheduleListBack = toBeOrdScheduleListBackMap.get("indScheduleInfoList");
    List<IndScheduleInfo> toBeOrdScheduleLPriorityDownListBack = toBeOrdScheduleListBackMap.get("indScheduleInfoPriorityDownList");

    if(!toBeOrdScheduleListBack.isEmpty()){
      DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
      for(int i = 0 ; i < toBeOrdScheduleListGo.size(); i++) {
        IndScheduleInfo toBeOrdScheduleBack = null;
        for (IndScheduleInfo indScheduleInfo : toBeOrdScheduleListBack) {
          if (indScheduleInfo.getOrgIndex() == i) {
            toBeOrdScheduleBack = indScheduleInfo;
            break;
          }
        }
        // mod #11716 スケジュール表で、ベッドはあるがKURが未設定の場合の移動エラー修正 関 start
        Long goKurCd = toBeOrdScheduleListGo.get(i).getIndKurCd();
        Long backKurCd = toBeOrdScheduleBack.getIndKurCd();

        if(toBeOrdScheduleBack != null && toBeOrdScheduleBack.getOrdNo() != null && Objects.equals(toBeOrdScheduleListGo.get(i).getIndBedCd(), toBeOrdScheduleBack.getIndBedCd())
        && goKurCd != null && !goKurCd.equals(0L) && backKurCd != null && !backKurCd.equals(0L)){
          // mod #11716 スケジュール表で、ベッドはあるがKURが未設定の場合の移動エラー修正 関 end

          // 行き方向 ファストクール、ラストクール開始時刻
          LocalDateTime firstKurTreatDateTimeGo = LocalDateTime.parse(toBeOrdScheduleListGo.get(i).getFirstKurTreatDateTime(), dateFormat);
          LocalDateTime lastKurTreatDateTimeGo = LocalDateTime.parse(toBeOrdScheduleListGo.get(i).getLastKurTreatDateTime(), dateFormat);
          // 帰り方向 ファストクール、ラストクール開始時刻
          LocalDateTime firstKurTreatDateTimeBack = LocalDateTime.parse(toBeOrdScheduleBack.getFirstKurTreatDateTime(), dateFormat);
          LocalDateTime lastKurTreatDateTimeBack = LocalDateTime.parse(toBeOrdScheduleBack.getLastKurTreatDateTime(), dateFormat);
          boolean isDuplicate = false;
          // case1:行き方向 ファストクール開始時刻 ＝ 帰り方向 ファストクール開始時刻 エラー
          // case2:行き方向 ファストクール開始時刻 ＞ 帰り方向 ファストクール開始時刻
          //     && 行き方向 ファストクール開始時刻 ＜＝ 帰り方向 ラストクール開始時刻 エラー
          // case3:行き方向 ファストクール開始時刻 ＜ 帰り方向 ファストクール開始時刻
          //     && 行き方向 ラストクール開始時刻 ＞＝ 帰り方向 ファストクール開始時刻 エラー

          if(firstKurTreatDateTimeGo.equals(firstKurTreatDateTimeBack)){
            // 入れ替え前後の開始クールが同じになっている（あり得ないケース）
            isDuplicate = true;
          } else if (firstKurTreatDateTimeGo.isAfter(firstKurTreatDateTimeBack) &&
            (firstKurTreatDateTimeGo.equals(lastKurTreatDateTimeBack) || firstKurTreatDateTimeGo.isBefore(lastKurTreatDateTimeBack))) {
            // 行きが後から開始されるため、入れ替えの予定が先終わる必要性あり（行きの開始クール時刻＞帰りのラストクール開始時刻）
            isDuplicate = true;
          } else if (firstKurTreatDateTimeGo.isBefore(firstKurTreatDateTimeBack) &&
            (lastKurTreatDateTimeGo.equals(firstKurTreatDateTimeBack) || lastKurTreatDateTimeGo.isAfter(firstKurTreatDateTimeBack))) {
            // 行きが先に開始されるため、行きの予定が先に終了する必要性あり（行きのラストクール時刻＜帰りのファーストクール開始時刻）
            isDuplicate = true;
          }
          if(isDuplicate){
            message += " 他の予定と重複するためスケジュール変更できません。（移動後入れ替えの予定で重複するためスケジュール変更できません。）";
            eventLogMessage.setLogMessage(className + "." + methodName + message);
            logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
            logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            responseInfo.setMessage(message);
            responseInfo.setMsgCdList(msgCdList);
            responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
            responseInfo.setMsgCd("12000212");

            return responseInfo;
          }
        }
      }
    }
    // 他スケジュールと重複が存在するリスト
    List<IndScheduleInfo> dupulicateOrdScheduleListAll = new ArrayList<>();

    List<IndScheduleInfo> dupulicateOrdScheduleListGo = indScheduleDao.selectDupulicateOrdScheduleByIndScheduleList(facilityCd, toBeOrdScheduleListGo, excludeOrdNoListGo);
    List<IndScheduleInfo> dupulicateOrdScheduleListBack = indScheduleDao.selectDupulicateOrdScheduleByIndScheduleList(facilityCd, toBeOrdScheduleListBack, excludeOrdNoListBack);
    dupulicateOrdScheduleListAll.addAll(dupulicateOrdScheduleListGo);
    dupulicateOrdScheduleListAll.addAll(dupulicateOrdScheduleListBack);
    if(dupulicateOrdScheduleListAll.size() > 0){
      // 重複が存在する場合は、ユーザに選択させる
      if(!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getDupulicateUpdateMode())){
        message += " 移動後他患者の治療予定データと重複が発生します。";
        eventLogMessage.setLogMessage(className + "." + methodName + message);
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        responseInfo.setMessage(message);
        responseInfo.setMsgCdList(msgCdList);
        responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        responseInfo.setMsgCd("70000008");

        return responseInfo;
      }
    }
    // スケジュール移動に伴い、一般検査、一般撮影検査、患者イベントの関連処理が必要かをチェック
    List<IndScheduleInfo> toBeOrdScheduleListAllForCheak = new ArrayList<>();
    toBeOrdScheduleListAllForCheak.addAll(toBeOrdScheduleListGo);
    toBeOrdScheduleListAllForCheak.addAll(toBeOrdScheduleListBack.stream().filter(o -> o.getOrdNo() > 0).collect(Collectors.toList()));

    boolean hasPatEvent = false;
    boolean hasExam = false;
    boolean hasRad = false;
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

    message = "";
    if(hasPatEvent || hasExam || hasRad || hasRst) {
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
                  // responseInfo.setHasRadDeadLineRecords(hasRadDeadLineRecords);
                }
              }
            }
          }
        }
      }
      if(hasRst){
        if(!StringUtils.hasText(indscheduleChangeUserSelectedInfo.getUpdateRst())){
          message += " 実績反映しますか。";
          eventLogMessage.setLogMessage(className + "." + methodName + message);
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
          logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          responseInfo.setMessage(message);
          responseInfo.setHasRst(hasRst);
          responseInfo.setMsgCdList(msgCdList);
          responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
          responseInfo.setMsgCd("12000060");

          return responseInfo;
        }
      }
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

    responseInfo.setHasExam(hasExam);
    responseInfo.setHasRad(hasRad);
    responseInfo.setHasPatEvent(hasPatEvent);
    responseInfo.setToBeOrdScheduleListAllForCheak(toBeOrdScheduleListAllForCheak);
    responseInfo.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.SUCCESS.toString());
    responseInfo.setDupulicateOrdScheduleListAll(dupulicateOrdScheduleListAll);

    return responseInfo;
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
  private Map<String,List<IndScheduleInfo>> complementIndScheduleInfo(String facilityCd, List<IndScheduleInfo> indScheduleInfoList, List<MstKur> mstKurList) {
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
  // チェック：一般検査・一般撮影検査の締切日を過ぎているか
  private boolean checkOverDeadLine(List<IndScheduleInfo> indScheduleInfoList, String scheduleChangeLimitDay, String scheduleChangeLimitTime){
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
}
