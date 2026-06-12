package jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.request.sharePatient.DstPatientRequest;
import jp.co.nikkiso.ntss.admin_web.request.sharePatient.ReceivedPatientInfoInput;
import jp.co.nikkiso.ntss.admin_web.request.sharePatient.SrcPatientRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.PersonalUserService;
import jp.co.nikkiso.ntss.admin_web.service.notificationMessage.NotificationMessageService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.PatNameIdentificationDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatientInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PublicPatientInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ReceivedPatientInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class MaterialsSharingPatientInfomationServiceImpl implements MaterialsSharingPatientInfomationService {

  private static final String APPROVED = "1";

  @Autowired
  private PatNameIdentificationDao patNameIdentificationDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  PatInfoService patInfoService;

  @Autowired
  NotificationMessageService notificationService;

  @Autowired
  PersonalUserService personalUserService;

  @Autowired
  private LogService logService;

  /**
   * webAPI呼び出し用
   */
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // DB更新ログ出力ロジック wangzuo End

  @Override
  public List<PatientInfo> selectPatInfoPulic(List<PatPersonalMainData> paramsInput) {

    try {
      List<Long> lstPatInfo = new ArrayList<>();
      List<String> lstFacility_cd = new ArrayList<>();
      // 患者の個人的なメインデータ リストから検索条件を取得する
      List<PatPersonalMainData> patPersonalMainDataLst = new ArrayList<>();
      for (int i = 0; i < paramsInput.size(); i++) {
        patPersonalMainDataLst.add(paramsInput.get(i));
        lstPatInfo.add(paramsInput.get(i).getPat_id());
        lstFacility_cd.add(paramsInput.get(i).getFacility_cd());
      }

      // 患者のリスト
      List<PatientInfo> infoPatientPublic = patNameIdentificationDao.selectPatInfoPublic(lstPatInfo,
        lstFacility_cd);

      for (PatPersonalMainData patMainData : patPersonalMainDataLst) {
        boolean found = false;
        for (PatientInfo patientInfo : infoPatientPublic) {
          if (patientInfo.getPatId().equals(patMainData.getPat_id())) {
            patientInfo.setPatName(patMainData.getPat_last_name() + patMainData.getPat_first_name());
            patientInfo.setPat_last_name_kana(patMainData.getPat_last_name_kana());
            patientInfo.setPat_first_name_kana(patMainData.getPat_first_name_kana());
            patientInfo.setHosp_pat_id(patMainData.getHosp_pat_id());
            // add FNSI-NO423入院患者名の配布 江 start
            //patientInfo.setIs_same(patMainData.getIs_same());
            if(patMainData.getIs_same() != null){
              patientInfo.setIs_same(patMainData.getIs_same());
            }
            if (patMainData.getIn_out_class() != null) {
              patientInfo.setIn_out_class(patMainData.getIn_out_class());
            }
            // add FNSI-NO423入院患者名の配布 江 end
            found = true;
            break;
          }
        }
        if (!found) {
          PatientInfo patientInfo = new PatientInfo();
          patientInfo.setPatName(patMainData.getPat_last_name() + patMainData.getPat_first_name());
          patientInfo.setPat_last_name_kana(patMainData.getPat_last_name_kana());
          patientInfo.setPat_first_name_kana(patMainData.getPat_first_name_kana());
          patientInfo.setAlready(0);
          patientInfo.setNotYet(0);
          patientInfo.setPatId(patMainData.getPat_id());
          patientInfo.setHosp_pat_id(patMainData.getHosp_pat_id());
          // add FNSI-NO423入院患者名の配布 江 start
          //patientInfo.setIs_same(patMainData.getIs_same());
          if(patMainData.getIs_same() != null){
            patientInfo.setIs_same(patMainData.getIs_same());
          }
          if (patMainData.getIn_out_class() != null) {
            patientInfo.setIn_out_class(patMainData.getIn_out_class());
          }
          // add FNSI-NO423入院患者名の配布 江 end
          infoPatientPublic.add(patientInfo);
        }
      }

      return infoPatientPublic;
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return null;
    }
  }

  @Override
  public List<PatientInfo> getPatientListReceive(String loginFacilityCd, List<PatPersonalMainData> paramsInput) {

    List<Long> lstPatInfo = new ArrayList<>();

    List<PatPersonalMainData> patPersonalMainDataLst = new ArrayList<>();
    for (PatPersonalMainData patPersonalMainData : paramsInput) {
      // 患者の個人的なメインデータ リストから検索条件を取得する
      lstPatInfo.add(patPersonalMainData.getPat_id());
      patPersonalMainDataLst.add(patPersonalMainData);
    }
    try {
      // 受信した患者の領収書リスト
      List<PatientInfo> lstPatInfoReceive = new ArrayList<>();

      // 認識されていない患者のリスト
      List<PatientInfo> patLstNotReceive = patNameIdentificationDao
        .selectNotReceivePatientList(loginFacilityCd);

      List<Long> patIdList = new ArrayList<>();
      patLstNotReceive.forEach(s -> {
        if (s.getPat_id_src() != null) {
          patIdList.add(s.getPat_id_src());
        }
      });
      // 患者情報
      List<PatPersonalMain> PatPersonalMain = patPersonalMainDao.selectByIdList(patIdList);
      for (PatientInfo patientInfo : patLstNotReceive) {
        for (PatPersonalMain personalMain : PatPersonalMain) {
          if (personalMain.getPat_id().equals(patientInfo.getPat_id_src())) {
            patientInfo.setPatName(personalMain.getPat_last_name() + personalMain.getPat_first_name());
            patientInfo.setPat_last_name_kana(personalMain.getPat_last_name_kana());
            patientInfo.setPat_first_name_kana(personalMain.getPat_first_name_kana());
            lstPatInfoReceive.add(patientInfo);
            break;
          }
        }
      }

      // 患者のリストが認識されました
      List<PatientInfo> receivedPatientList = patNameIdentificationDao.selectReceivedPatientList(lstPatInfo, loginFacilityCd);
      // List<PatientInfo> allReceivedPatientList = new ArrayList<>();
      for (PatPersonalMainData patPersonal : patPersonalMainDataLst) {
        boolean found = false;
        for (PatientInfo patInfoReceives : receivedPatientList) {
          if (patPersonal.getPat_id().equals(patInfoReceives.getPatId())) {
            patInfoReceives.setPatId(patPersonal.getPat_id());
            patInfoReceives.setPatName(patPersonal.getPat_last_name() + patPersonal.getPat_first_name());
            patInfoReceives.setPat_last_name_kana(patPersonal.getPat_last_name_kana());
            patInfoReceives.setPat_first_name_kana(patPersonal.getPat_first_name_kana());
            patInfoReceives.setHosp_pat_id(patPersonal.getHosp_pat_id());
            patInfoReceives.setAlready(patInfoReceives.getAlready());
            patInfoReceives.setNotYet(patInfoReceives.getNotYet());
            // add FNSI-NO423入院患者名の配布 江 start
            //patInfoReceives.setIs_same(patPersonal.getIs_same());
            if(patPersonal.getIs_same() != null){
              patInfoReceives.setIs_same(patPersonal.getIs_same());
            }
            if (patPersonal.getIn_out_class() != null) {
              patInfoReceives.setIn_out_class(patPersonal.getIn_out_class());
            }
            // add FNSI-NO423入院患者名の配布 江 end
            found = true;
            break;
          }
        }
        if (!found) {
          PatientInfo patInfoReceives = new PatientInfo();
          patInfoReceives.setAlready(0);
          patInfoReceives.setNotYet(0);
          patInfoReceives.setHosp_pat_id(patPersonal.getHosp_pat_id());
          patInfoReceives.setPatId(patPersonal.getPat_id());
          patInfoReceives.setPatName(patPersonal.getPat_last_name() + patPersonal.getPat_first_name());
          patInfoReceives.setPat_last_name_kana(patPersonal.getPat_last_name_kana());
          patInfoReceives.setPat_first_name_kana(patPersonal.getPat_first_name_kana());
          // add FNSI-NO423入院患者名の配布 江 start
          //patInfoReceives.setIs_same(patPersonal.getIs_same());
          if(patPersonal.getIs_same() != null){
            patInfoReceives.setIs_same(patPersonal.getIs_same());
          }
          if (patPersonal.getIn_out_class() != null) {
            patInfoReceives.setIn_out_class(patPersonal.getIn_out_class());
          }
          // add FNSI-NO423入院患者名の配布 江 end
          receivedPatientList.add(patInfoReceives);
        }
      }
      lstPatInfoReceive.addAll(receivedPatientList);

      return lstPatInfoReceive;
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return null;
    }
  }

  @Override
  public List<PublicPatientInfo> getDstFacilities(DstPatientRequest request) {
    return patNameIdentificationDao.selectDstFacilities(request.getFacilityCdLogin(), request.getPatId());
  }

  @Override
  public List<ReceivedPatientInfo> getSrcFacilities(SrcPatientRequest request) {
    List<ReceivedPatientInfo> results;
    Long patIdDst = request.getPatIdDst();
    if (patIdDst != null) {
      results = patNameIdentificationDao.selectSrcFacilities(request.getFacilityCdLogin(), request.getPatIdDst());
    } else {
      results = patNameIdentificationDao.selectSrcFacilitiesByPatIdSrc(request.getFacilityCdLogin(),
        request.getPatIdSrc());
    }
    if (results != null) {
      for (ReceivedPatientInfo receivedPatientInfo : results) {
        PatPersonalMain patPersonalMainSrc = patPersonalMainDao
          .selectById(receivedPatientInfo.getPatId());
        if (patPersonalMainSrc != null) {
          receivedPatientInfo.setPat_name_src(
            patPersonalMainSrc.getPat_last_name() + patPersonalMainSrc.getPat_first_name());
          receivedPatientInfo.setHosp_pat_id_src(patPersonalMainSrc.getHosp_pat_id());
        }

        if (patIdDst != null) {
          PatPersonalMain patPersonalMainDst = patPersonalMainDao.selectById(patIdDst);
          if (patPersonalMainDst != null) {
            receivedPatientInfo.setNew_hosp_pat_id(patPersonalMainDst.getHosp_pat_id());
            receivedPatientInfo.setNew_pat_name(
              patPersonalMainDst.getPat_last_name() + patPersonalMainDst.getPat_first_name());
            receivedPatientInfo.setNew_pat_id(patIdDst);
          }
        }
      }
    }
    return results;
  }

  @Override
  public List<ReceivedPatientInfo> updateSrcFacilities(SrcPatientRequest request) throws Exception {
    List<ReceivedPatientInfoInput> receivedPatientInfos = request.getReceivedPatientInfos();
    if (receivedPatientInfos != null && !receivedPatientInfos.isEmpty()) {
      Timestamp currentDate = new Timestamp(System.currentTimeMillis());
      for (ReceivedPatientInfoInput receivedPatientInfoInput : receivedPatientInfos) {
        String facilityCdLogin = request.getFacilityCdLogin();
        String hospPatId = receivedPatientInfoInput.getHospPatId();
        Map<String, String> payload = receivedPatientInfoInput.getPayload();
        // 新規患者として登録
        if (hospPatId != null && payload != null) {
          patInfoService.create(payload);
          Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCdLogin, hospPatId);

          // 患者新規登録時通知登録
          ObjectMapper mapper = new ObjectMapper();
          PatPersonalMain patPersonalMain = mapper.readValue(payload.get("pat_personal_main"), PatPersonalMain.class);
          JSONObject replaceData = new JSONObject();
          String facilityCd = patPersonalMain.getFacility_cd();
          replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
          replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
          replaceData.put("HOSPPATID", hospPatId);
          replaceData.put("PATID", patId.toString());
          replaceData.put("FACILITYCD", facilityCd);
          webApiCallCommonUtil.registerNotification(NotificationDefinition.CREATE_PAT, facilityCd, replaceData);

          receivedPatientInfoInput.setPatId(patId);

          // DB更新ログ出力ロジック wangzuo Start
          String tableName = "pat_personal_main";
          // SQL検索条件
          StringBuffer wheres = new StringBuffer("");
          wheres.append(" WHERE\n");
          wheres.append(" pat_id = " + patId + "\n");
          // logCommon設定
          DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
          // ログ出力カラム情報及び更新前データ情報取得
          boolean setResult = logCommon.setInfo();
          // DB更新ログ出力ロジック wangzuo End

          //開示した元施設のデータをコピーして、自施設の患者のデータに埋め込む
          int updateCount = patPersonalMainDao.updateByOtherPatId(request.getPatIdSrc(), patId);

          // DB更新ログ出力ロジック wangzuo Start
          // 更新後データ取得、差分あれば、log出力
          if (setResult && updateCount > 0) {
            logCommon.updateLog();
          }
          // DB更新ログ出力ロジック wangzuo End

          request.setPatIdDst(patId);
          request.setPatIdSrc(null);
        } else {
          if (hospPatId != null) {
            receivedPatientInfoInput.setPatId(Long.valueOf(hospPatId));
            request.setPatIdDst(Long.valueOf(hospPatId));
            request.setPatIdSrc(null);
          }
        }
        receivedPatientInfoInput.setUpDate(currentDate);
        patNameIdentificationDao.updateForSrc(toReceivedPatientInfo(receivedPatientInfoInput));
      }
    }
    return getSrcFacilities(request);
  }

  @Override
  public List<PublicPatientInfo> updateDstFacilities(DstPatientRequest request) {
    Timestamp currentDate = new Timestamp(System.currentTimeMillis());
    List<PublicPatientInfo> publicPatientInfos = request.getPublicPatientInfos();
    //add FNSI-削除ボタンがクリックできないバグを修正します 江 start
    if(request.getDeletedPatNameId().size() != 0) {
      List<Long> deletedPatNameId = request.getDeletedPatNameId();
      patNameIdentificationDao.deleteForDst(deletedPatNameId);
    }
    //add FNSI-削除ボタンがクリックできないバグを修正します 江 end
    if (publicPatientInfos != null && !publicPatientInfos.isEmpty()) {
      for (PublicPatientInfo sharingPatientInfo : publicPatientInfos) {
        Long patNameId = sharingPatientInfo.getPatNameId();
        sharingPatientInfo.setUpDate(currentDate);
        if (APPROVED.equals(sharingPatientInfo.getApprove())) {
          sharingPatientInfo.setApproveDate(currentDate);
        }
        // 承認/開示状況
        if (patNameId != null) {
          patNameIdentificationDao.updateForDst(sharingPatientInfo);
          // 追加/施設選択
        } else {
          sharingPatientInfo.setRegDate(currentDate);
          patNameIdentificationDao.insert(toPatNameIdentification(sharingPatientInfo,
            request.getFacilityCdLogin(), request.getPatId()));
        }
      }
    }
    return getDstFacilities(request);
  }

  private PatNameIdentification toPatNameIdentification(PublicPatientInfo info, String facilityCdLogin, Long patId) {
    PatNameIdentification dto = new PatNameIdentification();
    dto.setFacilityCdSrc(facilityCdLogin);
    dto.setPatIdSrc(patId);
    dto.setApprove(info.getApprove());
    dto.setApproveDate(info.getApproveDate());
    dto.setRegDate(info.getRegDate());
    dto.setDoctorInCharge(info.getDoctorInCharge());
    dto.setFacilityCdDst(info.getFacilityCd());
    dto.setReceive("0");
    dto.setIsOpen(info.getIsOpen());
    dto.setUpDate(info.getUpDate());
    dto.setSignUp(info.getSignUp());
    return dto;
  }

  private ReceivedPatientInfo toReceivedPatientInfo(ReceivedPatientInfoInput input) {
    ReceivedPatientInfo info = new ReceivedPatientInfo();
    info.setFacilityCd(input.getFacilityCd());
    info.setIsOpen(input.getIsOpen());
    info.setPatId(input.getPatId());
    info.setPatNameId(input.getPatNameId());
    info.setReceive(input.getReceive());
    info.setUpDate(input.getUpDate());
    info.setSignUp(input.getSignUp());
    return info;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatNameIdentification> getListPatIdSrcFromPatDst(Long pat_id_dst) {
    List<PatNameIdentification> patIdSrc = patNameIdentificationDao.getListPatIdSrcFromPatDst(pat_id_dst);
    return patIdSrc;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Long> getListPatIdSrcFromListPatDst(List<Long> list_pat_id_dst) {
    List<Long> patIdSrc = patNameIdentificationDao.getListPatIdSrcFromListPatDst(list_pat_id_dst);
    return patIdSrc;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void registerPushNotification(Long patId, List<PublicPatientInfo> publicPatientInfos) {
    //通知送信
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);

    // 基本的情報を持った変換用JSONデータを作成
    JSONObject baseReplaceData = new JSONObject();
    baseReplaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
    baseReplaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
    baseReplaceData.put("PATID", patId.toString());
    publicPatientInfos.stream().forEach(patInfo -> {
      String dstFacilityCd = patInfo.getFacilityCd();
      String approve = patInfo.getApprove();
      String isOpen = patInfo.getIsOpen();
      // 承認済みかつ受理していないもののみ通知
      if (approve.equals("1") && isOpen.equals("0")) {
        // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
        JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
        replaceData.put("FACILITYCD", dstFacilityCd);
        try {
          webApiCallCommonUtil.registerNotification(NotificationDefinition.PAT_INFO_SHARE_ACCEPT, dstFacilityCd, replaceData);
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SHARING_PATIENT_INFORMATION, SERVICE_NAME.FNSI, null);
        }
      }
    });
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<String> getListFacilityCdDstApproved(Long pat_id_src) {
    return patNameIdentificationDao.getListFacilityCdDstApproved(pat_id_src);
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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End

  //add #12462 Pat_id_dstから患者IDを取得 患者情報共有 zrx start
  @Override
  public List<PatNameIdentification> getListPatIdSrcFromPatTo(Long pat_id_dst) {

    List<PatNameIdentification> listPatIdSrcFromPatTo = patNameIdentificationDao.getListPatIdSrcFromPatTo(pat_id_dst);

    return listPatIdSrcFromPatTo;
  }

  @Override
  public List<OrdMain> findOrdMainByDateCdSharingInfo(String facility_cd, Long pat_id, String dialysis_date_from,
                                                      String dialysis_date_to, List<Integer> weeksArry) {
    return patNameIdentificationDao.findOrdMainByDateCdSharingInfo(facility_cd, pat_id, dialysis_date_from,
      dialysis_date_to, weeksArry);

  }

  //add #12462 Pat_id_dstから患者IDを取得 患者情報共有 zrx end
}
