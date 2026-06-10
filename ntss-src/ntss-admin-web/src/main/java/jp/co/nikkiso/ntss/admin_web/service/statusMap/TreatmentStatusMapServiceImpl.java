package jp.co.nikkiso.ntss.admin_web.service.statusMap;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import jp.co.nikkiso.ntss.admin_web.response.exam.ExamRequestResponse;
import jp.co.nikkiso.ntss.admin_web.response.rad.RadRequestResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.exam.ExamRequestService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.patEvent.PatEventService;
import jp.co.nikkiso.ntss.admin_web.service.rad.RadRequestService;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.ScheduleListDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentStatusMapDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatEventShare;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadMainData;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.response.statusMap.MarkerInfoResponse;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForNotAssignedSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusMap;
import org.springframework.util.StringUtils;

@Service
public class TreatmentStatusMapServiceImpl implements TreatmentStatusMapService {

  @Autowired
  private OrdScheduleDao ordScheduleDao;

  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  ScheduleListDao scheduleListDao;

  @Override
  public PatPersonalMain patientSelect(Long patId) {
    return patPersonalMainDao.selectById(patId);
  }

  @Autowired
  TreatmentStatusMapDao treatmentStatusMapDao;

  @Autowired
  MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUnit;

  @Autowired
  PatIndApproveDao patIndApproveDao;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private OrdMainService ordMainService;

  //add FNSI redmine5436 fang start
  @Autowired
  private PatEventDao patEventDao;

  @Autowired
  private ExamRequestService examRequestService;

  @Autowired
  private RadRequestService radRequestService;

  @Autowired
  MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;

  @Autowired
  private PatEventService patEventRecService;
  //add FNSI redmine5436 fang end

  @Autowired
  private LogService logService;

  /**
   * 工程、入外区分、シャント不一致、感染症不一致、治療方法不一致を返す
   * @param markerInfoList
   * @param facilityCd
   * @return
   */
  private List<MarkerInfoResponse> makeMakerInfoList(List<TreatmentStatusMap> markerInfoList, String facilityCd) {
    // patIdのリストを作成
    List<Long> patIdList = new ArrayList<Long>();
    for (int lop = 0; lop < markerInfoList.size(); lop++) {
      TreatmentStatusMap markerInfo = markerInfoList.get(lop);
      patIdList.add(markerInfo.getPatId());
    }

    // patIdのリストに対する患者個人情報を取得
    List<PatPersonalMain> patPersonalList = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);

    // レスポンス格納配列作成
    List<MarkerInfoResponse> responseList = new ArrayList<MarkerInfoResponse>();
    // レスポンス情報作成
    for (TreatmentStatusMap markerInfo: markerInfoList) {
      // markerInfo: リストから取り出したマーカー情報
      // それぞれのレスポンスインスタンス
      MarkerInfoResponse response = new MarkerInfoResponse();

      // オーダー番号取得
      response.setOrdNo(markerInfo.getOrdNo());

      // 工程取得
      String processState = markerInfo.getProcessState();
      response.setProcessState(processState);

      // 入外区分取得
      Long patId = markerInfo.getPatId();
      int inOutClass = this.getInOutClassById(patId, patPersonalList);
      response.setInOutClass(inOutClass);
      ;
      // シャント不一致判定 (不一致：true, 一致：false)
      Short shuntPosition = markerInfo.getShuntPosition();
      String vaDirect = markerInfo.getVaDirect();
      short va = vaDirect != null && StrUtils.isNumber(vaDirect) ? Short.parseShort(vaDirect) : -1;
      response.isShuntMismatch = true;
      //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
      response.setPatVaDirect(vaDirect);
      //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end
      // 判定
      //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx start
//      if ( Objects.equals(shuntPosition, (short)0) || Objects.equals(va, (short)0)) {
//        // どちらかが0：両方かどうか
//        response.isShuntMismatch = false;
//      } else if (Objects.equals(shuntPosition, va) && Objects.equals(shuntPosition, (short)3)) {
//        // 3：なし以外で一致する場合
//        response.isShuntMismatch = false;
//      }
      /**
       * 0:両方
       * 1:左
       * 2:右
       * 3:無
       * -:不明
       */
      //mod #11761 治療状況マップ＞スケジュール画面でVAが未登録の場合のVA方向一致不一致判定ロジックが不正 zrx start
//      if (Objects.equals(va, -1)) {
      if (Objects.equals(va, (short)-1)) {
        //mod #11761 治療状況マップ＞スケジュール画面でVAが未登録の場合のVA方向一致不一致判定ロジックが不正 zrx end
        // null
        response.isShuntMismatch = false;
      }
      if (Objects.equals(shuntPosition, (short)3) || Objects.equals(va, (short)3)) {
        // 3:無
        response.isShuntMismatch = false;
      } else if (Objects.equals(vaDirect, "-")) {
        // -:不明
        response.isShuntMismatch = true;
      }  else if (Objects.equals(va, shuntPosition)) {
        response.isShuntMismatch = false;
      }
      //mod #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 zrx end

      // 感染症不一致判定 (不一致：true, 一致：false)
      String isInfection = markerInfo.getIsInfection();
      String isInfect = markerInfo.getIsInfect();
      response.isInfectionMismatch = true;
      if (Objects.equals(isInfection, isInfect)) {
        response.isInfectionMismatch = false;
      }
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
      //ベッドマスタの感染症が未登録の場合A
      if(!StringUtils.hasText(isInfection)) {
        response.isInfectionMismatch = false;
      }
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end

      // 治療方法不一致判定 (不一致：true, 一致：false)
      Integer deviceMode = markerInfo.getDeviceMode();
      String isSupportHd = markerInfo.getIsSupportHd();
      String isSupportEcum = markerInfo.getIsSupportEcum();
      String isSupportHdf = markerInfo.getIsSupportHdf();
      String isSupportHf = markerInfo.getIsSupportHf();
      String isSupportHdHo = markerInfo.getIsSupportHdHo();
      String isSupportEcumHo = markerInfo.getIsSupportEcumHo();
      String isSupportAfbf = markerInfo.getIsSupportAfbf();
      String isSupportOhdf = markerInfo.getIsSupportOhdf();
      String isSupportOhf = markerInfo.getIsSupportOhf();
      String isSupportIHdf = markerInfo.getIsSupportIhdf();
      String isSupportBloodPurify = markerInfo.getIsSupportBloodPurify();

      boolean ret = true;
      if (deviceMode != null) {
        switch (deviceMode) {
        case 0: // HD
          if (Objects.equals(isSupportHd, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 1: // ECUM
          if (Objects.equals(isSupportEcum, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 2: // HDF
          if (Objects.equals(isSupportHdf, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 3: // HF
          if (Objects.equals(isSupportHf, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 4: // HD+補液
          if (Objects.equals(isSupportHdHo, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 5: // ECUM+補液
          if (Objects.equals(isSupportEcumHo, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 6: // AFBF
          if (Objects.equals(isSupportAfbf, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 7: // OHDF
          if (Objects.equals(isSupportOhdf, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 8: // OHF
          if (Objects.equals(isSupportOhf, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 9: // 特殊浄化
          if (Objects.equals(isSupportBloodPurify, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        case 10:    // I-HDF
          if (Objects.equals(isSupportIHdf, FlagType.FLAG_ON)) {
            ret = false;
          }
          break;
        }
        response.isTreatmentMismatch = ret;
      }

      //add FNSI redmine5436 fang start
      OrdMain ordMain = ordMainDao.selectByOrdNo(markerInfo.getOrdNo());
      //患者イベント
      Timestamp dateFrom =  toTimestampStart(null, Timestamp.valueOf("1970-01-01 00:00:00"));
      Timestamp dateTo = toTimestampEnd(null, Timestamp.valueOf("9999-01-01 00:00:00"));
      List<PatEventShare> patEventShares = patEventDao.selectByPatIdNewestShare(ordMain.getPatId(), null, null, facilityCd);
      List<PatNameIdentification> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatDst(ordMain.getPatId());
      for (PatNameIdentification srcPatId : srcPatIds) {
        //患者ID、起票日時で検索
        List<PatEventShare> newList = patEventRecService.selectByPatIdNewestShare(srcPatId.getPatIdSrc(),
          dateFrom,
          dateTo, facilityCd);
        if(!newList.isEmpty()){
          patEventShares.addAll(newList);
        }
      }
      response.isEventMismatch = false;
      for (PatEventShare patEventShare : patEventShares) {
        if (patEventShare.getEventStartDate() != null && Integer.parseInt(patEventShare.getEventStartDate().replace("-", "")) <= Integer.parseInt(ordMain.getTreatDate())) {
          if (patEventShare.getEventEndDate() == null || Integer.parseInt(patEventShare.getEventEndDate().replace("-", "")) >= Integer.parseInt(ordMain.getTreatDate())) {
            response.isEventMismatch = true;
          }
        }
      }

      List<Long> patIdListForSearch = new ArrayList<>();
      patIdListForSearch.add(ordMain.getPatId());
      String searchDate = null;
      if (ordMain.getTreatDate() != null) {
        searchDate = ordMain.getTreatDate().substring(0,4) + "/" + ordMain.getTreatDate().substring(4,6) + "/" + ordMain.getTreatDate().substring(6,8);
      }
      ExamRequestResponse examRequestResponse = null;
      try {
        //検査予定
        //mod #12462 患者情報共有 zrx start
//        examRequestResponse = examRequestService.createExamRequestResponse(patIdListForSearch, searchDate, searchDate, ordMain.getFacilityCd());
        examRequestResponse = examRequestService.createExamRequestResponse(patIdListForSearch, searchDate, searchDate, ordMain.getFacilityCd(), null);
        //mod #12462 患者情報共有 zrx end
      } catch(Exception e){
        //エラー
        EventLogMessage eventLogMessage = getEventLogMessage();
        eventLogMessage.setLogMessage(e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_STATUS_MAP, LoggingConstant.SERVICE_NAME.FNSI, null);
        throw new RuntimeException(e.getMessage());
      }
      if (examRequestResponse != null && examRequestResponse.patExamMains != null && examRequestResponse.patExamMains.size() > 0) {
        SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
        int haveCnt = 0;
        for (PatExamMainData patExamMainData : examRequestResponse.patExamMains) {
          if (df.format(patExamMainData.getRegExamDate()).equals(ordMain.getTreatDate())) {
            haveCnt += 1;
          }
        }
        if (haveCnt > 0) {
          response.isInspectionMismatch = true;
        } else {
          response.isInspectionMismatch = false;
        }
      } else {
        response.isInspectionMismatch = false;
      }

      //一般撮影検査予定
      //mod #12462 患者情報共有 zrx start
//      RadRequestResponse radRequestResponse = radRequestService.createRadRequestResponse(patIdListForSearch, searchDate, ordMain.getFacilityCd());
      RadRequestResponse radRequestResponse = radRequestService.createRadRequestResponse(patIdListForSearch, searchDate, ordMain.getFacilityCd(), null);
      //mod #12462 患者情報共有 zrx end
      if (radRequestResponse != null && radRequestResponse.patRadMains != null && radRequestResponse.patRadMains.size() > 0) {
        SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
        int haveCnt = 0;
        for (PatRadMainData patRadMainData : radRequestResponse.patRadMains) {
          if (df.format(patRadMainData.getRegRadDate()).equals(ordMain.getTreatDate())) {
            haveCnt += 1;
          }
        }
        if (haveCnt > 0) {
          response.isRadiationMismatch = true;
        } else {
          response.isRadiationMismatch = false;
        }
      } else {
        response.isRadiationMismatch = false;
      }
      response.patId = ordMain.getPatId();
      response.treatDate = ordMain.getTreatDate();
      //add FNSI redmine5436 fang end

      // レスポンスリストに格納
      responseList.add(response);
    }
    return responseList;
  }


  /**
   * 患者個人情報のリストから患者ID指定で入外区分を取得する
   * @param patId 患者ID
   * @param patPersonalList 患者個人情報のリスト
   * @return 入外区分コード
   */
  private int getInOutClassById(Long patId, List<PatPersonalMain> patPersonalList) {
    int rtn = 0;
    for (int lop = 0; lop < patPersonalList.size(); lop++) {
      PatPersonalMain patPersonal = patPersonalList.get(lop);
      if (Objects.equals(patPersonal.getPat_id(), patId) && patPersonal.getIn_out_class() != null) {
        rtn = patPersonal.getIn_out_class();
      }
    }
    return rtn;
  }

  /**
   * 利用者リストの取得
   * @param facilityCd 施設コード
   */
  public List<MstPersonalUser> personalUserSelect(String facilityCd) {
    return mstPersonalUserDao.selectAll(facilityCd, FlagType.FLAG_OFF);
  }


  @Override
  public List<MarkerInfoResponse> getMarkerInfo(List<Long> ordNo, String facilityCd) {
    // ord_mainをもとにしたマーカー情報を取得する
    List<TreatmentStatusMap> markerInfoList = treatmentStatusMapDao.selectMarker(ordNo);

    return makeMakerInfoList(markerInfoList, facilityCd);
  }

  /**
   * 治療予定のベッド移動前チェック結果を取得
   * @param ordNo
   * @param bedCd
   * @param facilityCd
   * @return
   */
  @Override
  public List<MarkerInfoResponse> checkBeforeMoveOrdMain(Long ordNo, Long bedCd, String facilityCd) {
    // ord_mainをもとにしたマーカー情報を取得する
    List<TreatmentStatusMap> markerInfoList = treatmentStatusMapDao.selectBeforeMoveOrdMain(ordNo, bedCd);

    return makeMakerInfoList(markerInfoList, facilityCd);
  }

  /**
   * 未割当の治療情報一覧を取得
   * @param facilityCd
   * @param treatDate
   * @return
   */
  public List<OrdMainForNotAssignedSchedule> getNotAssignedOrdMain(String facilityCd, String treatDate, Long bedCd) {
    return ordMainDao.selectByOrdMainNotAssigned(facilityCd, treatDate, bedCd);
  }

  /**
   * 治療情報データの取得
   */
  public OrdMain getOrdMainByOrdNo(Long ordNo) {
    return ordMainDao.selectByOrdNo(ordNo);
  }

  /**
   * 治療情報にベッドを割り当てる
   * 治療状況は0(条件送信前)に変更する
   */
  public int assignBedToOrdMain(
      String facilityCd,
      Long ordNo,
      Long bedCd,
      String treatDate,
      Long kurCd,
      Long userId) {
    int ret = -1;
    try {

      // add FNSI-改修内容追加OrdMain履歴 付 start
      selectHistoryUtils.insertMangoDbHistory(9, ordNo, null, new ArrayList<>(), new ArrayList<>(), facilityCd, null,
        null, null, null, new ArrayList<>(), new ArrayList<>(), treatDate, null, null,
        new ArrayList<>(), null, null);
      // mangoDb-updateOrdMainData-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      //mod 10860 ind_schedule_user_infoのデータ不正 zhao start
//      ret = scheduleListDao.updateOrdMainData(
//          ordNo,
//          treatDate,
//          facilityCd,
//          treatDate,
//          kurCd,
//          bedCd,
//          //以下のパラメータを追加しました。ord_mainのind_schedule_user_infoの指示者IDと更新者IDの更新用です。
//          //nullの場合は、当該項目は更新しません。
//          null,     //指示者ID 更新対象:治療予定指示者情報(ind_schedule_user_info)のind_user_id
//          userId    //更新者ID 更新対象:治療予定指示者情報(ind_schedule_user_info)のupd_user_id
//          );
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      MstPersonalUser mstPersonalUser = MasterCacheHandler.get().getMstPersonalUser(user.getUserId());
      MstPersonalUser updUser = mstPersonalUserDao.selectById(userId);
      ret = scheduleListDao.updateOrdMainData(
        ordNo,
        treatDate,
        facilityCd,
        treatDate,
        kurCd,
        bedCd,
        //以下のパラメータを追加しました。ord_mainのind_schedule_user_infoの指示者IDと更新者IDの更新用です。
        //nullの場合は、当該項目は更新しません。
        user.getUserId(),     //指示者ID 更新対象:治療予定指示者情報(ind_schedule_user_info)のind_user_id
        userId,    //更新者ID 更新対象:治療予定指示者情報(ind_schedule_user_info)のupd_user_id
        updUser.getUserFirstName(),
        updUser.getUserLastName(),
        mstPersonalUser.getUserFirstName(),
        mstPersonalUser.getUserLastName()
      );
      //mod 10860 ind_schedule_user_infoのデータ不正 zhao end
      if (0 >= ret) {
        throw new RuntimeException("scheduleListDao.updateOrdMainData data not found./");
      }

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "ord_schedule";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      wheres.append(" AND\n");
      wheres.append(" facility_cd = '" + facilityCd + "'\n");
      wheres.append(" AND\n");
      wheres.append(" treat_date = '" + treatDate + "'\n");
      wheres.append(" AND\n");
      wheres.append(" is_dummy = '0'\n");

      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(scheduleListDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      ret = scheduleListDao.updateScheduleListData(
          ordNo,
          treatDate,
          facilityCd,
          treatDate,
          kurCd,
          bedCd);
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && ret > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      if (0 >= ret) {
        throw new RuntimeException("scheduleListDao.updateScheduleListData data not found.");
      }

      // クール・ベッド移動として（施設設定により）指示変更フラグを立てる
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);

      // DB更新ログ出力ロジック wangzuo Start
      String tableNamePat = "pat_ind_approve";
      // SQL検索条件
      String inStrPat = getInStr("ord.ord_no IN ", ordNoList);
      StringBuffer wheresPat = new StringBuffer("");
      wheresPat.append(" WHERE\n");
      wheresPat.append("ord_no IN (" + "\n");
      wheresPat.append("SELECT ord.ord_no" + "\n");
      wheresPat.append("FROM ord_main as ord" + "\n");
      wheresPat.append("JOIN mst_facility_setting as setting" + "\n");
      wheresPat.append("ON ord.facility_cd = setting.facility_cd" + "\n");
      wheresPat.append("WHERE" + "\n");
      wheresPat.append(inStrPat + "\n");
      wheresPat.append("AND setting.facility_setting_no = '1022'" + "\n");
      wheresPat.append("AND value = '1')" + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommonPat = getLogCommon(patIndApproveDao, tableNamePat, wheresPat, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResultPat = logCommonPat.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int patUpdateCount = patIndApproveDao.updateContentChangeListByBedControl(ordNoList, new PatIndApprove());

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResultPat && patUpdateCount > 0) {
        logCommonPat.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

    } catch (Exception e) {
      throw new RuntimeException(e);
    }

    return ret;
  }


  /**
   * 次患者更新処理
   * @param bedCd
   * @return
   */
  public int updateNextPatInfo( Long bedCd ) {
    int ret = 0;

    try {
      LocalDateTime update = LocalDateTime.now();
      if (bedCd != 0) {
        ResponseEntity<String> res = webApiCallCommonUnit.SetNextPatInfo(bedCd, false, update);
        if ( !res.getStatusCode().equals(org.springframework.http.HttpStatus.OK) && !res.getStatusCode().equals(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR)) {
          ret = -1;
          throw new RuntimeException("updateNextPatInfo[SetNextPatInfo] failed. res=(" + res.getStatusCode() +") " + res.getBody());
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(e);
    }

    return ret;
  }

  /**
   * 治療状況マップの指示確認更新
   *
   * @param ord_no
   * @param payload
   * @throws Exception
   */
  @Override
  @Transactional
  public int updatePatIndApproveCheckForMap(Long ordNo, String content) throws Exception {
      PatIndApprove approve = new PatIndApprove();
      approve.setOrd_no(ordNo);
      approve.setContent_for_map(content);
      approve.setIs_content_changed_for_map(FlagType.FLAG_OFF);

      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(approve,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      return patIndApproveDao.updateForMap(approve);
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  public <T> String getInStr(String fieldInfo, List<T> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (T obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }
  // DB更新ログ出力ロジック wangzuo End

  //add FNSI redmine5436 fang start
  /**
   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
   * @param dt  日付文字列(yyyyMMdd)
   * @param def デフォルト
   * @return
   */
  private Timestamp toTimestampStart(String dt, Timestamp def) {
    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
        dt.substring(4, 6) + "-" +
        dt.substring(6, 8) + " " +
        "00:00:00");
    } else {
      return def;
    }
  };

  /**
   * 日付をTimestampへ変換(yyyyMMddからTimestampへ)
   * @param dt  日付文字列(yyyyMMdd)
   * @param def デフォルト
   * @return
   */
  private Timestamp toTimestampEnd(String dt, Timestamp def) {
    if (dt != null && dt.length() == 8 && StrUtils.isNumber(dt)) {
      return Timestamp.valueOf(dt.substring(0, 4) + "-" +
        dt.substring(4, 6) + "-" +
        dt.substring(6, 8) + " " +
        "23:59:59");
    } else {
      return def;
    }
  };
  //add FNSI redmine5436 fang end

  /* add by sunmingyuan  2023-02-01 CodeOptimization  start */
  @Override
  public ResponseEntity<Integer> unassigmentOrdMain(String facilityCd, Long ordNo, Long userId) {
    OrdMain ordMain = getOrdMainByOrdNo(ordNo);

    if (ordMain != null) {
      Long kurCd;
      if (ordMain.getIndKurCd() != null) {
        kurCd = Integer.toUnsignedLong(ordMain.getIndKurCd());
      } else {
        kurCd = 0L;
      }
      Long bedCd = 0L;
      if (ordMain.getIndBedCd() != null) {
        bedCd = Integer.toUnsignedLong(ordMain.getIndBedCd());
      }

      // 治療情報にベッドを割り当てられたベッドを消す
      int ret = assignBedToOrdMain(
        facilityCd,
        ordNo,
        0L,
        ordMain.getTreatDate(),
        kurCd,
        userId);

      // 元ベッドが割り当てられている場合
      if (!bedCd.equals(0L)) {
        // 元ベッドに対して次患者更新実施
        ret = updateNextPatInfo(bedCd);
      }

      return new ResponseEntity<>(ret, HttpStatus.OK);
    } else {
      throw new RuntimeException("unassigmentOrdMain data not found./");
    }
  }
  /* add by sunmingyuan  2023-02-01 CodeOptimization  end */
}
