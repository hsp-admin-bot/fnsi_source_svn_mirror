package jp.co.nikkiso.ntss.admin_web.service.scheduleAssignment;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.JacksonException;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ObjectNode;
import com.google.common.base.Objects;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.response.checkList.dto.ReceiveRstMediInfoDto;
import jp.co.nikkiso.ntss.admin_web.response.scheduleAssignment.ScheduleAssignmentResponse;
import jp.co.nikkiso.ntss.admin_web.response.scheduleAssignment.ScheduleAssignmentUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.checkList.CheckListService;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.ordMainHst.OrdMainHstService;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.TreatmentStatusListService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfo;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoItem;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoService;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.api.service.additionInfo.AdditionCalculationService;
import jp.co.nikkiso.ntss.api.service.conditionSend.ConditionSendResultService;
import jp.co.nikkiso.ntss.api.service.ordChecklistService.CheckListMakeService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.DBAppWebAPIDao;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicateTimingDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OperateStatusDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainRestoreDao;
import jp.co.nikkiso.ntss.core.dao.OrdTreatConditionDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMainRestore;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForScheduleAssignment;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainUpdateForScheduleAssignment;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import jakarta.annotation.Resource;
import java.io.IOException;
import java.lang.reflect.Field;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.ExecutorService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Slf4j
@Service
public class ScheduleAssignmentServiceImpl implements ScheduleAssignmentService {
  // add FNSI-？？？？患者割り当て 陳 start
  @Autowired
  OrdMainService ordMainService;

  @Autowired
  private OrdMainHstService ordMainHstService;

  @Autowired
  private OrdTreatConditionDao ordTreatConditionDao;

  @Value("${ntss.admin-web.coop-api.url}")
  private String coopApi;

  @Value("${ntss.admin-web.device-edge.url}")
  private String deviceEdgeUrl;

  @Autowired
  private OrdChecklistDao ordChecklistDao;

  @Autowired
  MstComsvSettingDao mstComsvSettingDao;

  @Autowired
  DeviceEdgeOrderService deviceEdgeOrderService;

  @Autowired
  private OrdMainRestoreDao ordMainRestoreDao;

  @Autowired
  private PatUniqueDao patUniqueDao;
  // add FNSI-？？？？患者割り当て 陳 end

  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private MntMachineStateDao mntMachineStateDao;
  @Autowired
  private MstMachineDao mstMachineDao;
  @Autowired
  private OperateStatusDao operateStatusDao;
  @Autowired
  private MntMotionRecordDao mntMotionRecordDao;
  @Autowired
  private MniMonitorDao mniMonitorDao;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private MstTreatmentDao mstTreatmentDao;


  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;
  @Autowired
  CondInfoService condInfoService;
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
  @Autowired
  JournalService journalService;
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;

  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  //DB更新ログ出力ロジック wp end 20210129

  // add FNSI-改修内容追加OrdMain履歴 付 end

  @Autowired
  private TriggerUtil triggerUtil;
  //add #10196 Ord_Material_Save code implementation 20240131 ztc start
  @Autowired
  private TreatmentStatusListService treatmentStatusListService;

  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  //add #10196 Ord_Material_Save code implementation 20240131 ztc end

  // add 11454 時間外加算自動処理が機能していない zkm start
  @Autowired
  private MstMedicateTimingDao mstMedicateTimingDao;
  @Autowired
  private DBAppWebAPIDao dBAppWebAPIDao;
  @Autowired
  CheckListService checkListService;
  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
  @Autowired
  CheckListMakeService checkListMakeService;
  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
  @Autowired
  private MstChecklistDao mstChecklistDao;
  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExector;
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
  ScheduleAssignmentService scheduleAssignmentService;
  @Autowired
  private SendConditionCancelService sendConditionCancelService;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  @Autowired
  ConditionSendResultService conditionSendResultService;
  @Autowired
  AdditionCalculationService additionCalculationService;
  // add 11454 時間外加算自動処理が機能していない zkm end

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public ScheduleAssignmentResponse getOrderByOrderNo(Long ordNo) throws IOException {
    OrdMainForScheduleAssignment ordList = ordMainDao.selectByOrdNoScheduleAssignment(ordNo);
    PatPersonalMain pat = patPersonalMainDao.selectById(ordList.getPatId());
    String patName = "";
    String hospPatId = "";

    // 患者名取得
    if (pat != null) {
      // mod #9485  shiyw start
      String pat_last_name = pat.getPat_last_name() == null?"":pat.getPat_last_name();
      String pat_first_name = pat.getPat_first_name() == null?"":pat.getPat_first_name();
      patName = pat_last_name + " " + pat_first_name;
      // mod #9485  shiyw end
      hospPatId = pat.getHosp_pat_id();
    }

    // 応答用スケジュール情報作成
    ScheduleAssignmentResponse res = new ScheduleAssignmentResponse();
    res.setOrdNo(ordList.getOrdNo());
    res.setHospPatId(hospPatId);
    res.setPatId(ordList.getPatId());
    res.setPatName(patName);
    res.setFacilityCd(ordList.getFacilityCd());
    res.setTreatDate(ordList.getTreatDate());
    res.setTreatWeek(ordList.getTreatWeek());
    res.setRstDialysisState(ordList.getRstDialysisState());
    res.setRstStartDate(ordList.getRstStartDate());
    res.setRstEndDate(ordList.getRstEndDate());
    res.setKurCd(ordList.getRstKurCd());
    res.setKurName(ordList.getRstKurName());
    res.setBedCd(ordList.getRstBedCd());
    res.setBedName(ordList.getRstBedName());

    return res;
  }

  /**
   * 患者一覧情報取得
   * {@inheritDoc}
   */
  @Override
  public List<PatPersonalMainData> getPatlist(String facilityCd) {

    List<PatPersonalMainData> res = new ArrayList<>();

    List<String> facilitylist = new ArrayList<>();
    facilitylist.add(facilityCd);

    // 患者一覧情報取得
    List<PatPersonalMain> pat = patPersonalMainDao.selectAll(facilitylist);
    List<Long> patIdList = new ArrayList<Long>();
    for(PatPersonalMain ppmA : pat) {
      patIdList.add(ppmA.getPat_id());
    }
    List<PatMain> patMainList = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    for(PatPersonalMain ppmB : pat) {
      PatPersonalMainData addIsSame = new PatPersonalMainData();
      addIsSame.setFacility_cd(ppmB.getFacility_cd());
      addIsSame.setPat_id(ppmB.getPat_id());
      addIsSame.setHosp_pat_id(ppmB.getHosp_pat_id());
      addIsSame.setFn_pat_id(ppmB.getFn_pat_id());
      addIsSame.setIn_out_class(ppmB.getIn_out_class());
      addIsSame.setNkk_pat_id(ppmB.getNkk_pat_id());
      addIsSame.setPat_first_name(ppmB.getPat_first_name());
      addIsSame.setPat_last_name(ppmB.getPat_last_name());
      addIsSame.setPat_first_name_kana(ppmB.getPat_first_name_kana());
      addIsSame.setPat_last_name_kana(ppmB.getPat_last_name_kana());
      addIsSame.setPat_sex(ppmB.getPat_sex());
      addIsSame.setIs_die(ppmB.getIs_die());
      addIsSame.setIs_del(ppmB.getIs_del());
      // 患者基本情報から同姓同名フラグを取得
      for (PatMain patMain: patMainList) {
        if (ppmB.getPat_id().equals(Long.valueOf(patMain.getPat_id()))) {
          addIsSame.setIs_same(patMain.getIs_same());
          break;
        }
      }
      res.add(addIsSame);
    }
    return res;
  }

  /**
   * 対象のスケジュール一覧情報取得
   * {@inheritDoc}
   */
  @Override
  public List<ScheduleAssignmentResponse> getSchedulelist(String facilityCd, String startDate, String endDate, Long bedCd) {

    // 治療日、施設コード、ベッドコードが一致するスケジュール取得
    // mod FNSI-？？？？患者割り当て 徐 start
    // List<OrdMainForScheduleAssignment> ordList = ordMainDao.selectScheduleByTreatDateBedCd(facilityCd, startDate, endDate, bedCd);
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    Calendar calendar = Calendar.getInstance();
    Date date = new Date();
    try {
      date = sdf.parse(startDate);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    calendar.setTime(date);
    calendar.add(Calendar.DAY_OF_MONTH, -1);
    startDate = sdf.format(calendar.getTime());
    List<OrdMainForScheduleAssignment> ordList = ordMainDao.selectScheduleByTreatDateFacilityCd(facilityCd, startDate, endDate, bedCd);
    // mod FNSI-？？？？患者割り当て 徐 end

    List<ScheduleAssignmentResponse> reslist = new ArrayList<>();

    for (OrdMainForScheduleAssignment ordMain : ordList) {

      ScheduleAssignmentResponse res = new ScheduleAssignmentResponse();
      PatPersonalMain pat = patPersonalMainDao.selectById(ordMain.getPatId());
      String patName = "";
      String hospPatId = "";
      String patLastName = "";
      String patFirstName = "";
      String patLastNameKana = "";
      String patFirstNameKana = "";
      // 患者名取得
      if (pat != null) {
        // mod #9485  shiyw start
        String pat_last_name = pat.getPat_last_name() == null?"":pat.getPat_last_name();
        String pat_first_name = pat.getPat_first_name() == null?"":pat.getPat_first_name();
        patName = pat_last_name + " " + pat_first_name;
        // mod #9485  shiyw end
        hospPatId = pat.getHosp_pat_id();
        patLastName = pat.getPat_last_name();
        patFirstName = pat.getPat_first_name();
        patLastNameKana = pat.getPat_last_name_kana();
        patFirstNameKana = pat.getPat_first_name_kana();
      }

      res.setOrdNo(ordMain.getOrdNo());
      res.setPatId(ordMain.getPatId());
      res.setPatName(patName);
      res.setHospPatId(hospPatId);
      res.setPatLastName(patLastName);
      res.setPatFirstName(patFirstName);
      res.setPatLastNameKana(patLastNameKana);
      res.setPatFirstNameKana(patFirstNameKana);
      res.setFacilityCd(ordMain.getFacilityCd());
      res.setTreatDate(ordMain.getTreatDate());
      res.setTreatWeek(ordMain.getTreatWeek());
      res.setRstDialysisState(ordMain.getRstDialysisState());
      res.setRstStartDate(ordMain.getRstStartDate());
      res.setRstEndDate(ordMain.getRstEndDate());
      // del FNSI-？？？？患者割り当て 徐 start
      // if ( ordMain.getRstDialysisState().equals("0")) {
      // del FNSI-？？？？患者割り当て 徐 end
      res.setKurCd(ordMain.getIndKurCd());
      res.setKurName(ordMain.getIndKurName());
      res.setBedCd(ordMain.getIndBedCd());
      res.setBedName(ordMain.getIndBedName());
      res.setKurStartTime(ordMain.getIndKurStartTime());
      res.setBedOrderIndex(ordMain.getIndBedOrderIndex());
      // del FNSI-？？？？患者割り当て 徐 start
      // } else {
      //   res.setKurCd(ordMain.getRstKurCd());
      //   res.setKurName(ordMain.getRstKurName());
      //   res.setBedCd(ordMain.getRstBedCd());
      //   res.setBedName(ordMain.getRstBedName());
      // }
      // del FNSI-？？？？患者割り当て 徐 end

      reslist.add(res);
    }
    return reslist;
  }

  /**
   * 患者割り当て
   */
  @Override
  @Transactional
  public ScheduleAssignmentUpdateResponse patAssignment(Long patId, Long ordNo) throws IOException {

    ScheduleAssignmentUpdateResponse res = new ScheduleAssignmentUpdateResponse();

    // 最新のordMain情報取得
    OrdMainForScheduleAssignment ordMain = ordMainDao.selectByOrdNoScheduleAssignment(ordNo);

    // 患者IDが登録されていない(？？？？患者)の場合
    if (ordMain.getPatId() == null) {
      // 更新日時
      Timestamp update = new Timestamp(System.currentTimeMillis());

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(ordNo);
      // mangoDb-updatePatId-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック wangzuo Start
      String tableNamePat = "ord_main";
      // SQL検索条件
      StringBuffer wheresPat = new StringBuffer("");
      wheresPat.append(" WHERE\n");
      wheresPat.append(" ord_no = " + ordNo + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommonPat = getLogCommon(tableNamePat, wheresPat, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResultPat = logCommonPat.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      // ord_main 患者ID登録
      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
      int updateCountPat = ordMainDao.updatePatId(patId, ordNo, update);
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResultPat && updateCountPat > 0) {
        logCommonPat.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      // オーダーの患者IDから患者基本情報を取得
      PatMain patMain = patMainDao.selectById(patId);
      if (patMain != null) {
        String medicalCareInfo = patMain.getMedical_care_info() == null ? "{}" : patMain.getMedical_care_info();
        try {
          ObjectMapper mapMedicalCareInfo = new ObjectMapper();
          JsonNode nodeMedicalCareInfo = null;

          //
          nodeMedicalCareInfo = mapMedicalCareInfo.readTree(medicalCareInfo);

          // 透析回数/浄化治療回数
          Long dialCount = 0L;

          // 治療方法を取得して患者基本情報の透析回数か浄化治療回数を取得
          Integer treatDeviceMode = ordMain.getRstDeviceMode();
          if (treatDeviceMode != null) {

            // 透析：透析回数「dialysis_count」
            String strFieldName = "dialysis_count";
            if (treatDeviceMode.equals(9)) {
              // 特殊浄化：浄化治療回数「purification_count」
              strFieldName = "purification_count";
            }

            // 対象キー存在確認
            if (nodeMedicalCareInfo.has(strFieldName)) {
//              String strDialCount = nodeMedicalCareInfo.get(strFieldName).asText();
              dialCount = nodeMedicalCareInfo.get(strFieldName).isNull() ?
                0 : Long.parseLong(nodeMedicalCareInfo.get(strFieldName).asText());

              // add FNSI-改修内容追加OrdMain履歴 付 start
              getHistory(ordNo);
              // mangoDb-updateRstDialysisCnt-insertSuccess
              // add FNSI-改修内容追加OrdMain履歴 付 end

              // 治療記録の透析回数を更新
              dialCount++;

              // DB更新ログ出力ロジック wangzuo Start
              String tableNameRst = "ord_main";
              // SQL検索条件
              StringBuffer wheresRst = new StringBuffer("");
              wheresRst.append(" WHERE\n");
              wheresRst.append(" ord_no = " + ordNo + "\n");
              // logCommon設定
              DataUpdateLogCommonNew logCommonRst = getLogCommon(tableNameRst, wheresRst, getEventLogMessage());
              // ログ出力カラム情報及び更新前データ情報取得
              boolean setResultRst = logCommonRst.setInfo();
              // DB更新ログ出力ロジック wangzuo End

              oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
              int updateCountRst = ordMainDao.updateRstDialysisCnt(ordNo, dialCount);
              newOrdMain = ordMainDao.selectByOrdNo(ordNo);
              triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
                Collections.singletonList(newOrdMain));

              // DB更新ログ出力ロジック wangzuo Start
              // 更新後データ取得、差分あれば、log出力
              if (setResultRst && updateCountRst > 0) {
                logCommonRst.updateLog();
              }
              // DB更新ログ出力ロジック wangzuo End
            } else {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("API patAssignment: not define pat_main.medical_care_info." + strFieldName + ".");
              eventLogMessage.setSqlIdentification("(ordNo = " + ordNo + ", dialCount = " + dialCount + ")");
              logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.REMS, "OrdMainDao/updateRstDialysisCnt");
            }

          } else {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("API patAssignment: not define ord_main.rst_treatment_cd->device_mode.");
            eventLogMessage.setSqlIdentification("(ordNo = " + ordNo + ")");
            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.REMS, "OrdMainDao/selectByOrdNoScheduleAssignment");
          }
        } catch (Exception e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("API patAssignment: update dialysis count failure. " + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.REMS, null);
        }
      }


      // 装置マスタ情報取得
      List<MstMachine> machines = mstMachineDao.selectByOrdNoRst(ordNo);
      MstMachine machine = new MstMachine();
      if (machines.size() > 0) {
        machine = machines.get(0);
      }
      //DB更新ログ出力ロジック wp start
      // 現患者が？？？？患者の治療記録の場合
      String mmsTbN = "mnt_machine_state";

      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      wheres.append(" AND\n");
      wheres.append(" facility_cd = '" + machine.getFacilityCd() + "'" + "\n");
      wheres.append(" AND\n");
      wheres.append(" machine_type_cd = '" + machine.getMachineTypeCd() + "'" + "\n");
      wheres.append(" AND\n");
      wheres.append(" trim(machine_serial) = trim('" + machine.getMachineSerial() + "')" + "\n");
      DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      //DB更新ログ出力ロジック wp end


      // mnt_machine_state pat_id,next_pat_id登録
      int retCnt = mntMachineStateDao.updatePatId(patId, ordNo, machine.getFacilityCd(), machine.getMachineTypeCd(),
        machine.getMachineSerial(), update);

      //DB更新ログ出力ロジック wp start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && retCnt > 0) {
        logCommon.updateLog();
      }
      //DB更新ログ出力ロジック wp end 20210128

      // 患者割り当て通知用データ作成
      DeviceEdgeOrderRequest dres = new DeviceEdgeOrderRequest();
      dres.setOrdNo(ordNo);
      dres.setMachineNo(machine.getMachineNo());
      dres.setDeviceEdgeNo(machine.getDeviceEdgeNo());
      dres.setFacilityCd(machine.getFacilityCd());

      res.machinedata = dres;

    } else {
      // 既に患者が割り当てられている場合
      res.errorMessage = "既に患者が割り当てられています。";
    }

    return res;

  }

  /**
   * スケジュール割り当て
   */
  @Override
  @Transactional
  public ScheduleAssignmentUpdateResponse scheduleAssignment(Long baseOrdNo, Long ordNo, int rstInputClass, String flg) throws Exception {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // 割当先治療記録の実績展開を実施
    // 割り当て対象の最新の治療情報(ord_main)情報取得
    OrdMainUpdateForScheduleAssignment baseordMain = ordMainDao.selectByOrdNoUpdateScheduleAssignment(baseOrdNo);
    //add FNSI redmine 6706 劉祥霖 start
    boolean afterScheduleAssignmentMediInfo=false;
    String indMediInfo=baseordMain.getIndMediInfo();
    if(indMediInfo!=null&&!"".equals(indMediInfo)&&!"[]".equals(indMediInfo)){
      afterScheduleAssignmentMediInfo=true;
    }
    //add FNSI redmine 6706 劉祥霖 end
    // 毛 ログ改善対応 Add
    eventLogMessage.setFacilityCd(baseordMain.getFacilityCd());
    eventLogMessage.setLogMessage("スケジュール割り当て処理：/scheduleassignment/" +baseOrdNo + "/"  + ordNo + "/"  + rstInputClass);
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 割り当て対象の治療記録の治療状態判定
    String rstDialysisState = baseordMain.getRstDialysisState() == null ? "0" : baseordMain.getRstDialysisState();

    // add FNSI-？？？？患者割り当て 徐 start
    // 割り当てデータがrst_dialysis_state=1の場合は条件送信キャンセル処理を実行する。
    if (rstDialysisState.equals("1")) {
      // 毛 ログ改善対応 Add
      eventLogMessage.setLogMessage("スケジュール割り当て処理⇒条件送信キャンセル開始");
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // 条件送信キャンセルが必要ならば実行する
      sendConditionCancelService.doCancel(baseordMain.getFacilityCd(),
        Long.valueOf((long)baseordMain.getRstBedCd()), baseordMain.getOrdNo());
      // 毛 ログ改善対応 Add
      eventLogMessage.setLogMessage("スケジュール割り当て処理⇒条件送信キャンセル終了");
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    }
    // add FNSI-？？？？患者割り当て 徐 end

    // del FNSI-？？？？患者割り当て 陳 start
    //if ( rstDialysisState.equals("0")) {
    // del FNSI-？？？？患者割り当て 陳 end

    // 未送信

    // 毛 ログ改善対応 Add
    eventLogMessage.setLogMessage("スケジュール割り当て処理⇒指示展開を実施開始");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // 指示展開を実施
    // mod 11454 時間外加算自動処理が機能していない zkm start
//      ResponseEntity<String> ret = webApiCallCommonUtil.sendCondResultOnly(baseOrdNo);
//
//      if (ret.getStatusCode() != HttpStatus.OK) {
//        // 実績展開失敗
//        eventLogMessage.setLogMessage("スケジュール割り当て処理⇒指示展開を実施失敗:" + ret.getBody());
//        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//      }
    try {
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      conditionSendResultService.sendCondResultOnly(baseOrdNo, user.getUserId());
    } catch (RuntimeException e) {
      // 実績展開失敗
      eventLogMessage.setLogMessage("スケジュール割り当て処理⇒指示展開を実施失敗:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    }
    // mod 11454 時間外加算自動処理が機能していない zkm end
    // del FNSI-？？？？患者割り当て 陳 start
    //}
    // del FNSI-？？？？患者割り当て 陳 start

    // add FNSI-？？？？患者割り当て 陳 start
    // ScheduleAssignmentUpdateResponse r = scheduleAssignmentService.scheduleAssignment(baseOrdNo, ordNo);
    short rstClass = (short) rstInputClass;
    // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    //// mod FNSI-外部連携api呼び出対応 陳 start
    ////ScheduleAssignmentUpdateResponse r = scheduleAssignmentService.scheduleAssignment(baseOrdNo, ordNo, rstClass);
    ScheduleAssignmentUpdateResponse r = scheduleAssignmentOnly(baseOrdNo, ordNo, rstClass, flg);
//    OrdMain ordMainChangeBeforeDataInfo = ordMainDao.selectByOrdNo(baseOrdNo);
    //// mod FNSI-外部連携api呼び出対応 陳 end
    // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
    // add FNSI-？？？？患者割り当て 陳 end

    //add FNSI redmine 6706 劉祥霖　start
    //割り当て後、投薬の通知を追加する
    OrdMainUpdateForScheduleAssignment baseordMainData = ordMainDao.selectByOrdNoUpdateScheduleAssignment(baseOrdNo);
    // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    //String facilityCd=baseordMainData.getFacilityCd();
    String facilityCd = baseordMainData.getFacilityCd();
    // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

    // add 11454 時間外加算自動処理が機能していない zkm start
    AdditionCalculationRequest addCalcRequest = new AdditionCalculationRequest();
    addCalcRequest.setOrdNo(baseOrdNo);
    addCalcRequest.setFacilityCd(facilityCd);
    addCalcRequest.setPatId(baseordMainData.getPatId());
    addCalcRequest.setEventId(5);
    additionCalculationService.calculationAddition(addCalcRequest);
    // add 11454 時間外加算自動処理が機能していない zkm end

    //投薬を取得
    String rstMediInfoArray = baseordMainData.getRstMediInfo();
    if (rstMediInfoArray!=null&&!"[]".equals(rstMediInfoArray)) {
      ObjectMapper mapper = new ObjectMapper();
      List<ReceiveRstMediInfoDto> tempReceiveRstMediInfoDtos = mapper.readValue(rstMediInfoArray, new TypeReference<List<ReceiveRstMediInfoDto>>() {
      });
      for (ReceiveRstMediInfoDto element : tempReceiveRstMediInfoDtos) {
        //未実施判定
        if (element.getEffectFlg() == null || (element.getEffectFlg() != null && "0".equals(element.getEffectFlg()))) {
          //治療中の場合、透析前と透析中の投与タイミングを判定
          if (baseordMainData.getRstDialysisState().equals("3")) {
            MstMedicateTiming mstMedicateTiming = mstMedicateTimingDao.selectByCd(facilityCd, element.getTimingCd());
            if (mstMedicateTiming != null && "1".equals(mstMedicateTiming.getIsAlert())) {
              if (mstMedicateTiming.getDialysisProgressCd() != null && "001".equals(mstMedicateTiming.getDialysisProgressCd())) {
                PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(baseordMainData.getPatId());
                String medicineName=element.getName();
                if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
                  Integer cd = element.getCd();
                  Integer medicineType = element.getMedicineType().intValue();
                  //取得したコードを元に薬剤情報から名称を取得(DBから)
                  if (cd != null && medicineType != null) {
                    Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
                      facilityCd,
                      medicineType,
                      cd
                    );
                    medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
                  }
                }
                JSONObject replaceData = new JSONObject();
                replaceData.put("BEDNAME", baseordMainData.getRstBedName());
                replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
                replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
                replaceData.put("ORDNO", String.valueOf(baseOrdNo));
                replaceData.put("PATID", baseordMainData.getPatId().toString());
                replaceData.put("FACILITYCD", facilityCd);
                replaceData.put("MEDICINENAME", medicineName);
                try {
                  webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
                } catch (URISyntaxException e) {
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessageNew = new EventLogMessage();
          eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessageNew.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
                }
              } else if (mstMedicateTiming.getDialysisProgressCd() != null && "002".equals(mstMedicateTiming.getDialysisProgressCd())) {
                if (mstMedicateTiming.getAlertTime() != null) {
                  if (baseordMainData.getRstStartDate() != null) {
                    long addAlertTime = mstMedicateTiming.getAlertTime() * 60 * 1000;
                    long compareTime = baseordMainData.getRstStartDate().getTime() + addAlertTime;
                    if (System.currentTimeMillis() > compareTime) {
                      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(baseordMainData.getPatId());
                      String medicineName=element.getName();
                      if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
                        Integer cd = element.getCd();
                        Integer medicineType = element.getMedicineType().intValue();
                        //取得したコードを元に薬剤情報から名称を取得(DBから)
                        if (cd != null && medicineType != null) {
                          Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
                            facilityCd,
                            medicineType,
                            cd
                          );
                          medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
                        }
                      }
                      JSONObject replaceData = new JSONObject();
                      replaceData.put("BEDNAME", baseordMainData.getRstBedName());
                      replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
                      replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
                      replaceData.put("ORDNO", String.valueOf(baseOrdNo));
                      replaceData.put("PATID", baseordMainData.getPatId().toString());
                      replaceData.put("FACILITYCD", facilityCd);
                      replaceData.put("MEDICINENAME", medicineName);
                      try {
                        webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
                      } catch (URISyntaxException e) {
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessageNew = new EventLogMessage();
          eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessageNew.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
                      }
                    }
                  }
                }
              }
            }
          }
          //前体重未測定の場合、全部の未実施の投薬を通知発送
          else if (baseordMainData.getRstDialysisState().equals("4")) {
            MstMedicateTiming mstMedicateTiming = mstMedicateTimingDao.selectByCd(facilityCd, element.getTimingCd());
            if (mstMedicateTiming != null && "1".equals(mstMedicateTiming.getIsAlert())) {
              PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(baseordMainData.getPatId());
              String medicineName=element.getName();
              if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
                Integer cd = element.getCd();
                Integer medicineType = element.getMedicineType().intValue();
                //取得したコードを元に薬剤情報から名称を取得(DBから)
                if (cd != null && medicineType != null) {
                  Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
                    facilityCd,
                    medicineType,
                    cd
                  );
                  medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
                }
              }
              JSONObject replaceData = new JSONObject();
              replaceData.put("BEDNAME", baseordMainData.getRstBedName());
              replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
              replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
              replaceData.put("ORDNO", String.valueOf(baseOrdNo));
              replaceData.put("PATID", baseordMainData.getPatId().toString());
              replaceData.put("FACILITYCD", facilityCd);
              replaceData.put("MEDICINENAME", medicineName);
              try {
                webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
              } catch (URISyntaxException e) {
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessageNew = new EventLogMessage();
          eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessageNew.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
              }
            }
          }
          //後体重測定済みの場合、患者がベッドにいるかの判定をして、全部の未実施の投薬を通知発送
          else if (baseordMainData.getRstDialysisState().equals("5")) {
            List<MntMachineState> mntMachineStates = mntMachineStateDao.selectByBedCd(baseordMainData.getRstBedCd().longValue());
            if(mntMachineStates.get(0).getOrdNo()==baseOrdNo){
              MstMedicateTiming mstMedicateTiming = mstMedicateTimingDao.selectByCd(facilityCd, element.getTimingCd());
              if (mstMedicateTiming != null && "1".equals(mstMedicateTiming.getIsAlert())) {
                PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(baseordMainData.getPatId());
                String medicineName=element.getName();
                if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
                  Integer cd = element.getCd();
                  Integer medicineType = element.getMedicineType().intValue();
                  //取得したコードを元に薬剤情報から名称を取得(DBから)
                  if (cd != null && medicineType != null) {
                    Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
                      facilityCd,
                      medicineType,
                      cd
                    );
                    medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
                  }
                }
                JSONObject replaceData = new JSONObject();
                replaceData.put("BEDNAME", baseordMainData.getRstBedName());
                replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
                replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
                replaceData.put("ORDNO", String.valueOf(baseOrdNo));
                replaceData.put("PATID", baseordMainData.getPatId().toString());
                replaceData.put("FACILITYCD", facilityCd);
                replaceData.put("MEDICINENAME", medicineName);
                try {
                  webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
                } catch (URISyntaxException e) {
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessageNew = new EventLogMessage();
          eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessageNew.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
                }
              }
            }
          }
        }
      }
    }
    //add FNSI redmine 6706 劉祥霖　end
    // add 9828 by kangjie 20240417 start
    checkListService.indApprovedForStatusMap(baseOrdNo);
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    checkListService.indApprovedForContent(baseOrdNo);
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    // add 9828 by kangjie 20240417 end
    // 毛 ログ改善対応 Add
    eventLogMessage.setLogMessage("スケジュール割り当て処理正常終了：" + baseOrdNo + "/"  + ordNo + "/"  + rstInputClass);
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    //mod FNSI redmine 6706 劉祥霖 追加再修正：？？？？患者予定部分に投薬がないと通知しない end
    r.sendMediNoticeFlag=afterScheduleAssignmentMediInfo;
    //add FNSI redmine 6706 劉祥霖 追加再修正：？？？？患者予定部分に投薬がないと通知しない end

    //add 9480 治療状況(スケジュール割り当て処理) gjn start
    threadExector.execute(() -> {
      // 非同期実行チェック計算
      // #10553 Mod Change Assignment's param to the correct one
      webApiCallCommonUtil.doAutoCalculation(baseOrdNo);
    });
    //add 9480 治療状況(スケジュール割り当て処理) gjn end

    // add 9324 スケジュール割り当て ord_checklistの変更 gjn start
    //取得？？？患者的ord_checklist数据
    List<OrdChecklist> checklistsQuestion = checkListService.getOrdCheckListByOrdNO(ordNo);
    //取得被merge的患者的ord_main对应的ord_checklist数据
    List<OrdChecklist> checklistsMargeOld = checkListService.getOrdCheckListByOrdNO(baseOrdNo);
    //根据？？？患者的checklists，反向生成当时的mst_checklistd的数据,作成JsonNode格式返回
    //割り当取当前mst的数据
    // 最新のチェックリストマスタを取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), baseordMain.getFacilityCd(), "0");
    MstChecklist nowMstChecklist = mstChecklist.get(0);
    String strSetting = nowMstChecklist.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = map.readTree(strSetting);
//      Map<String, JsonNode> jsonNodeMap = checkListService.makeMstChecklistByOrdChecklist(checklistsMargeOld);
//      String checklistCd = jsonNodeMap.keySet().size()==1 ? jsonNodeMap.keySet().iterator().next() : null;
    // marge后的治療情報を取得
    OrdMainForCheckListSchedule ordMains = ordMainDao.selectByOrdNoChecklist(baseOrdNo);
    //根据merge后的ord_main数据和反推出来的mst_checklistd的数据，调用共通，生成新的ord_checklist数据
    // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
    List<OrdChecklist> newMakeList = checkListMakeService.getRegisterChecklistRst(ordMains, node, nowMstChecklist.getChecklistCd(), true);

    //被marge患者的ord_checklist与新生成的ord_checklist进行marge,checklistsMargeOld作为base
    checkListMakeService.margeOrdCheckListInsCheckLeft(checklistsMargeOld, newMakeList);
    // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end

    //再将？？？患者有被check过的状态marge给checklistsMargeOld后的数据
    //取最新ord_checklist
    List<OrdChecklist> checklistsMargeAfter = checkListService.getOrdCheckListByOrdNO(baseOrdNo);
    checkListService.margeOrdCheckListInsCheckRight(checklistsQuestion, checklistsMargeAfter, true);

    // add 9324 スケジュール割り当て ord_checklistの変更 gjn end

    return r;
  }

  /**
   * スケジュール割り当て
   */
// mod 11454 時間外加算自動処理が機能していない zkm start
//  @Override
  @Transactional
//  public ScheduleAssignmentUpdateResponse scheduleAssignment(Long baseordNo, Long ordNo, Short rstInputClass, String flg) throws IOException {
  public ScheduleAssignmentUpdateResponse scheduleAssignmentOnly(Long baseordNo, Long ordNo, Short rstInputClass, String flg) throws IOException {
// mod 11454 時間外加算自動処理が機能していない zkm end
    ScheduleAssignmentUpdateResponse res = new ScheduleAssignmentUpdateResponse();

    // 割り当て対象の最新の治療情報(ord_main)情報取得
    OrdMainUpdateForScheduleAssignment baseordMain = ordMainDao.selectByOrdNoUpdateScheduleAssignment(baseordNo);
    // ？？？？患者の最新の治療情報(ord_main)情報取得
    OrdMainUpdateForScheduleAssignment ordMain = ordMainDao.selectByOrdNoUpdateScheduleAssignment(ordNo);

    // add FNSI-？？？？患者割り当て 陳 start
    boolean dataMerge = false;

    //del スケジュール割り当て,余分な処理の削除 gjn start
//    try {
      // チェックリスト実績 (ord_checklist)データ展開を実施する
      //dataMerge = insertCheckList(ordMain.getFacilityCd(), ordMain.getOrdNo());
//    } catch (URISyntaxException e) {
//      e.printStackTrace();
//    }
    //del スケジュール割り当て,余分な処理の削除 gjn end

    // 外部連携用ジャーナル (sys_coop_journal)データ展開を実施する
    // mod FNSI-外部連携api呼び出対応 陳 start
    // insertCoopJouranal(baseordMain.getOrdNo(),baseordMain.getFacilityCd(),baseordMain.getPatId(),baseordMain.getTreatDate());
    insertCoopJouranal(baseordMain.getOrdNo(),baseordMain.getFacilityCd(),baseordMain.getPatId(),baseordMain.getTreatDate(), flg);
    // mod FNSI-外部連携api呼び出対応 陳 end
    // add FNSI-？？？？患者割り当て 陳 end

    // 患者IDが登録されていない(？？？？患者)の場合
    if (ordMain.getPatId() == null) {

      // 更新日時
      Timestamp update = new Timestamp(System.currentTimeMillis());

      // ord_main情報更新

      // 実績：治療状況 rst_dialysis_state
      baseordMain.setRstDialysisState(ordMain.getRstDialysisState());
//      // 実績：クールコード   rst_kur_cd
//      baseordMain.setRstKurCd(ordMain.getRstKurCd());
//      // 実績：クール名 rst_kur_name
//      baseordMain.setRstKurName(ordMain.getRstKurName());
      // add FNSI-？？？？患者割り当て 徐 start

      // 実績：治療方法処理フラグ
      boolean rstTreamtmentFlg = false;

      // 実績：治療方法コード   rst_treatment_cd
      if (ordMain.getRstTreatmentCd() != null) {
        baseordMain.setRstTreatmentCd(ordMain.getRstTreatmentCd());

        rstTreamtmentFlg = true;

        // # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B Start
        baseordMain.setRstDeviceMode(ordMain.getRstDeviceMode());
        // # 11467【たくしん会】H12条件送信ができない。患者経過総合ビューアのDW表示が不正。　V1.0B End
      }

      // 実績：治療条件情報  	rst_cond_info
      String rstConfInfo = ordMain.getRstCondInfo();
      String baseInfoCOnfInfo = baseordMain.getRstCondInfo();

      ObjectMapper map = new ObjectMapper();

      try {

        if (rstConfInfo != null) {

          // JsonNode方式に変更
          JsonNode node = map.readTree(rstConfInfo);

          if (baseInfoCOnfInfo != null) {

            // mod 11454 時間外加算自動処理が機能していない zkm start
//            String jsonKey =  checkNo(baseInfoCOnfInfo, rstConfInfo);
            List<String> jsonKey =  checkNo(baseInfoCOnfInfo, rstConfInfo);
            // mod 11454 時間外加算自動処理が機能していない zkm end

            JsonNode hateNode = map.readTree(rstConfInfo);
            JsonNode tokuNode = map.readTree(baseInfoCOnfInfo);

            // 実績：治療条件情報の処理
            Iterator<String> keys = hateNode.propertyNames().iterator();
            while (keys.hasNext()) {
              // Json キーを取得する
              String key = keys.next();

              JsonNode itemHate = hateNode.get(key);
              JsonNode itemToku = tokuNode.get(key);

//              if (itemToku != null && itemHate.get("value") != null && !"null".equals(itemHate.get("value").toString())) {
              if (tokuNode.has(key)
                && hateNode.hasNonNull(key)
                && itemHate.hasNonNull("value")
                && !"null".equals(itemHate.get("value").asText()))
              {
//                ObjectNode o = (ObjectNode) itemToku;
//                o.put("value", itemHate.get("value"));
                // mod 11454 時間外加算自動処理が機能していない zkm start
//                ((ObjectNode) itemToku).set("value", itemHate.get("value"));
                ((ObjectNode) tokuNode).set(key, itemHate);
                // mod 11454 時間外加算自動処理が機能していない zkm end
              }

              // ？？？？患者の実績：治療方法名Nullではないこと
              // del 11454 時間外加算自動処理が機能していない zkm start
//              if (ordMain.getRstTreatmentName() != null && "HD".equals(ordMain.getRstTreatmentName())) {
              // del 11454 時間外加算自動処理が機能していない zkm end
                if (itemToku == null) {
//                  ObjectNode o = (ObjectNode) tokuNode;
//                  o.put(key, itemHate);
                  ((ObjectNode) tokuNode).set(key, itemHate);
                }
              // del 11454 時間外加算自動処理が機能していない zkm start
//              }
              // del 11454 時間外加算自動処理が機能していない zkm end
            }

            // 特定患者のjsonのjsonキーは？？？？患者のjsonのjsonキーの中に存在しない場合
            Iterator<String> tokuKeys = tokuNode.propertyNames().iterator();
            while (tokuKeys.hasNext()) {
              // Json キーを取得する
              String key = tokuKeys.next();

              // ？？？？患者の実績：治療方法名Nullではないこと
              // del 11454 時間外加算自動処理が機能していない zkm start
//              if (ordMain.getRstTreatmentName() != null && "HD".equals(ordMain.getRstTreatmentName())) {
              // del 11454 時間外加算自動処理が機能していない zkm end

                if(jsonKey.contains(key)) {
                  tokuKeys.remove();
                }
              // del 11454 時間外加算自動処理が機能していない zkm start
//              }
              // del 11454 時間外加算自動処理が機能していない zkm end
            }

            baseordMain.setRstCondInfo(tokuNode.toString());
            }
          }
      } catch (JacksonException e) {

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      // 実績：治療方法名 rst_treatment_name
      if (ordMain.getRstTreatmentName() != null) {
        baseordMain.setRstTreatmentName(ordMain.getRstTreatmentName());
      }
      // 実績：クールコード   rst_kur_cd
      if (ordMain.getRstKurCd() != null) {
        baseordMain.setRstKurCd(ordMain.getRstKurCd());
      }
      // 実績：クール名 rst_kur_name
      if (ordMain.getRstKurName() != null) {
        baseordMain.setRstKurName(ordMain.getRstKurName());
      }
      // add FNSI-？？？？患者割り当て 陳 start
      // 実績：治療開始日時  rst_start_date
      baseordMain.setRstStartDate(ordMain.getRstStartDate());

      // 実績：治療終了日時  rst_end_date
      baseordMain.setRstEndDate(ordMain.getRstEndDate());

      // 実績：帰宅日時  rst_return_home_date
      baseordMain.setRstReturnHomeDate(ordMain.getRstReturnHomeDate());

      // 実績：穿刺者情報    rst_puncture_user_info
      baseordMain.setRstPunctureUserInfo(ordMain.getRstPunctureUserInfo());

      // 実績：返血者情報    rst_return_user_info
      baseordMain.setRstReturnUserInfo(ordMain.getRstReturnUserInfo());

      // 実績：担当者情報    rst_charge_user_info
      baseordMain.setRstChargeUserInfo(ordMain.getRstChargeUserInfo());

      // 実績：投与薬剤情報  rst_medi_info
      if (baseordMain.getRstMediInfo() == null) {

        baseordMain.setRstMediInfo(ordMain.getRstMediInfo());
      } else {

        JSONArray mediInfotemp = new JSONArray(baseordMain.getRstMediInfo());

        if (ordMain.getRstMediInfo() != null) {

          JSONArray mediInfotemp2 = new JSONArray(ordMain.getRstMediInfo());

          // 最新の番号を算出する
          String maxNo = ordMainDao.selectMaxIndMediInfoNoNew(baseordMain.getPatId(), ordMain.getFacilityCd());
          int noNum = Integer.parseInt(maxNo);

          for (int i = 0; i < mediInfotemp2.length(); i++) {
            noNum = noNum + 1;
            // 最新の番号を算出する
            //long indMediInfoNo = ordMainService.selectMaxIndMediInfoNo();

            JSONObject object = mediInfotemp2.getJSONObject(i);

            // 投与薬剤番号の更新
            object.put("no", noNum);

            mediInfotemp.put(mediInfotemp2.getJSONObject(i));
          }

          baseordMain.setRstMediInfo(mediInfotemp.toString());
        }

      }
      // 実績：医療材料情報  rst_equip_info
      if (baseordMain.getRstEquipInfo() == null) {

        baseordMain.setRstEquipInfo(ordMain.getRstEquipInfo());
      } else {
        JSONArray equipInfotemp = new JSONArray(baseordMain.getRstEquipInfo());
        if (ordMain.getRstEquipInfo() != null) {

          JSONArray equipInfotemp2 = new JSONArray(ordMain.getRstEquipInfo());

          for (int i = 0; i < equipInfotemp2.length(); i++) {
            // mod 11454 時間外加算自動処理が機能していない zkm start
//            equipInfotemp.put(equipInfotemp2.getJSONObject(i));
            JSONObject jsonObjectItem = equipInfotemp2.getJSONObject(i);
            Object equipType = jsonObjectItem.get("equip_type");
            Object equipCd = jsonObjectItem.get("cd");
            Long amount = jsonObjectItem.getLong("amount");
            boolean matched = false;

            for (Object jsonItem : equipInfotemp) {
              JSONObject baseItem = (JSONObject) jsonItem;
              Object baseEquipType = baseItem.get("equip_type");
              Object baseEquipCd = baseItem.get("cd");

              if (baseEquipCd.equals(equipCd) && baseEquipType.equals(equipType)) {
                Long baseAmount = baseItem.getLong("amount");
                baseItem.put("amount", amount + baseAmount);
                matched = true;
                break;
              }
            }

            if (!matched) {
              equipInfotemp.put(jsonObjectItem);
            }
            // mod 11454 時間外加算自動処理が機能していない zkm end
          }

          baseordMain.setRstEquipInfo(equipInfotemp.toString());
        }

      }
      //  実績：指示コメント情報 rst_ind_comment_info
      if (baseordMain.getRstIndCommentInfo() == null) {

        baseordMain.setRstIndCommentInfo(ordMain.getRstIndCommentInfo());
      } else {

        if (ordMain.getRstIndCommentInfo() != null) {

          JSONArray ordCommInfo = new JSONArray(ordMain.getRstIndCommentInfo());

          Map<String,Boolean> mapInfo = new LinkedHashMap<String,Boolean>();

          // 予定採番数
          for (int i = 1; i < 101; i++) {

            mapInfo.put(String.valueOf(i), false);
          }

          // 使用したNo確認
          // 実績：指示コメント情報
          JSONArray commentInfotemp = new JSONArray(baseordMain.getRstIndCommentInfo());

          for (int i = 0;i < commentInfotemp.length(); i++) {
            JSONObject object = commentInfotemp.getJSONObject(i);
            if(object.get("no") != null && mapInfo.get(object.get("no").toString()) != null){

              mapInfo.put(object.get("no").toString(),true);
            }
          }

          // 指示：指示コメント情報
          if(baseordMain.getIndIndCommentInfo() != null){
            JSONArray commentInfotemp2 = new JSONArray(baseordMain.getIndIndCommentInfo());

            for (int i = 0;i < commentInfotemp2.length(); i++) {
              JSONObject object = commentInfotemp2.getJSONObject(i);
              if(object.get("no") != null && mapInfo.get(object.get("no").toString()) != null){

                mapInfo.put(object.get("no").toString(),true);
              }
            }
          }

          String no = checkNo(mapInfo,ordCommInfo.length());
          String noCount[] = no.split(",");

          for (int i = 0; i < ordCommInfo.length(); i++) {

            JSONObject object = ordCommInfo.getJSONObject(i);
            object.put("no", Integer.parseInt(noCount[i]));
            commentInfotemp.put(object);
          }

          baseordMain.setRstIndCommentInfo(commentInfotemp.toString());
        }
      }

      String dialyState = ordMain.getRstDialysisState();

      // 判定フラグ
      boolean afterNull = true;
      boolean beforeNull = true;
      boolean weightBeforeNull = true;
      boolean weightAfterNull = true;

      // 実績：体重情報 rst_weight_info
      if(ordMain.getRstWeightInfo() != null){
        JsonNode weightInfo = map.readTree(ordMain.getRstWeightInfo());
        // 透析前体重測定値（風袋・車いすを含む重量）
//        if(weightInfo.get("weight_measure_before") != null && !"null".equals(weightInfo.get("weight_measure_before").toString())) {
        if(weightInfo.hasNonNull("weight_measure_before")) {
          weightBeforeNull = false;
        }

        // 透析後体重測定値（風袋・車いすを含む重量）
//        if(weightInfo.get("weight_measure_after") != null && !"null".equals(weightInfo.get("weight_measure_after").toString())) {
        if(weightInfo.hasNonNull("weight_measure_after")) {
          weightAfterNull = false;
        }
      }

      // 実績：風袋補正 rst_tare_info
//      if (ordMain.getRstTareInfo() != null){
      if (StringUtils.hasText(ordMain.getRstTareInfo())){
        JsonNode beforeAf = map.readTree(ordMain.getRstTareInfo());
        Iterator<String>  keyInfo = beforeAf.propertyNames().iterator();
        while(keyInfo.hasNext()) {

          String topKey = keyInfo.next();
          JsonNode item = beforeAf.get(topKey);

          Iterator<String> afterKey = item.propertyNames().iterator();

          while(afterKey.hasNext()) {

            String key = afterKey.next();
//            JsonNode innerItem = item.get(key);

//            if("after".equals(topKey) && !"null".equals(innerItem.toString())) {
            if("after".equals(topKey) && !item.hasNonNull(key)) {
              afterNull = false;
              break;
            }

//            if("before".equals(topKey) && !"null".equals(innerItem.toString())) {
            if("before".equals(topKey) && !item.hasNonNull(key)) {
              beforeNull = false;
              break;
            }
          }
        }
      }

      // 実績：風袋補正 after項目
      if (!(weightAfterNull && afterNull )) {

        if (StringUtils.hasText(baseordMain.getRstTareInfo())){
          JsonNode afterNode = map.readTree(baseordMain.getRstTareInfo());
//          ObjectNode oItem = (ObjectNode)afterNode;
//          if (ordMain.getRstTareInfo() != null){
          if (StringUtils.hasText(ordMain.getRstTareInfo())){
            JsonNode ordNode = map.readTree(ordMain.getRstTareInfo());
            ((ObjectNode)afterNode).set("after", ordNode.get("after"));
          }
        }
      }

      // 実績：風袋補正 before項目
      if (!(weightBeforeNull && beforeNull )) {

        if (StringUtils.hasText(baseordMain.getRstTareInfo())){
          JsonNode afterNode = map.readTree(baseordMain.getRstTareInfo());

          if (StringUtils.hasText(ordMain.getRstTareInfo())){
            JsonNode ordNode = map.readTree(ordMain.getRstTareInfo());
            ((ObjectNode)afterNode).set("before", ordNode.get("before"));
          }
        }
      }


      if ("5".equals(dialyState)) {

        //  実績：除水補正 rst_off_water_info
        baseordMain.setRstOffWaterInfo(ordMain.getRstOffWaterInfo());
      }

      //  実績：体重測定記録番号 weight_scale_no
      baseordMain.setWeightScaleNo(ordMain.getWeightScaleNo());

      // 実績：体重情報  rst_weight_info
      if (baseordMain.getRstWeightInfo() == null) {

        baseordMain.setRstWeightInfo(ordMain.getRstWeightInfo());
      } else if (ordMain.getRstWeightInfo() != null){
        JsonNode weightInfoNode = map.readTree(ordMain.getRstWeightInfo());
        JsonNode weightInfoNodeBase = map.readTree(baseordMain.getRstWeightInfo());

        ObjectNode infoNodeBase = (ObjectNode) weightInfoNodeBase;
        ObjectNode infoNode = (ObjectNode) weightInfoNode;

        Iterator<String> infoKeys = weightInfoNode.propertyNames().iterator();
        while (infoKeys.hasNext()) {
          // Json キーを取得する
          String key = infoKeys.next();

          // CTR,CTR測定日時,CTR測定時体重の処理不要となる
          if ("ctr".equals(key) || "ctr_measure_date".equals(key) || "ctr_weight".equals(key)) {

            String ctrInfo = patUniqueDao.selectCtrById(baseordMain.getPatId());
            if (StringUtils.hasText(ctrInfo)) {
//              String keyValue = "";
              String[] ctrData = ctrInfo.split("@@");

              if (ctrData.length > 0) {

                if ("ctr".equals(key)){
//                  keyValue = ctrData[0];
                  // del FNSI-？？？？患者割り当て xiebzh start
                  //infoNodeBase.put(key, "null".equals(ctrData[0])? null:Integer.parseInt(ctrData[0]));
                  // del FNSI-？？？？患者割り当て xiebzh end
                  // add FNSI-？？？？患者割り当て xiebzh start
                  infoNodeBase.put(key, "null".equals(ctrData[0]) || StringUtils.hasText(ctrData[0])? null:Float.parseFloat(ctrData[0]));
                  // add FNSI-？？？？患者割り当て xiebzh end
                }
                if ("ctr_weight".equals(key)){
//                  keyValue = ctrData[1];
                  // del FNSI-？？？？患者割り当て xiebzh start
                  //infoNodeBase.put(key,  "null".equals(ctrData[1])? null:Integer.parseInt(ctrData[1]));
                  // del FNSI-？？？？患者割り当て xiebzh end
                  // add FNSI-？？？？患者割り当て xiebzh start
                  infoNodeBase.put(key,  "null".equals(ctrData[1]) || StringUtils.hasText(ctrData[1])? null:Float.parseFloat(ctrData[1]));
                  // add FNSI-？？？？患者割り当て xiebzh end
                }
                if ("ctr_measure_date".equals(key)){
//                  keyValue = ctrData[2];
                  infoNodeBase.put(key, "null".equals(ctrData[2]) || StringUtils.hasText(ctrData[2])? null:ctrData[2]);
                }
              }

              //infoNodeBase.put(key, keyValue);
            }
          }
          // add FNSI redmine 6717 劉祥霖 start
          //前体重相関データの判定
          else if("weight_before".equals(key) && !infoNode.hasNonNull(key)){
            continue;
          }
          else if("weight_before_date".equals(key) && !infoNode.hasNonNull(key)){
            continue;
          }
          else if("water_removal_target".equals(key) && !infoNode.hasNonNull(key)){
            continue;
          }
          else if("weight_measure_before".equals(key) && !infoNode.hasNonNull(key)){
            continue;
          }

          // add FNSI redmine 6717 劉祥霖 end
          else {
            infoNodeBase.set(key, infoNode.get(key));
          }
        }

        baseordMain.setRstWeightInfo(infoNodeBase.toString());
      }
      //  実績：愁訴情報 rst_complaint_info
      baseordMain.setRstComplaintInfo(ordMain.getRstComplaintInfo());

      // 実績：愁訴処置情報  rst_treatment_info
      baseordMain.setRstTreatmentInfo(ordMain.getRstTreatmentInfo());

      // 実績：愁訴処置者情報 rst_treat_staff_info
      baseordMain.setRstTreatStaffInfo(ordMain.getRstTreatStaffInfo());

      // 実績：回診記録情報 rst_rounds_info
      baseordMain.setRstRoundsInfo(ordMain.getRstRoundsInfo());

      // 実績：ベッドコード   rst_bed_cd
      baseordMain.setRstBedCd(ordMain.getRstBedCd());

      // 実績：ベッド名 rst_bed_name
      baseordMain.setRstBedName(ordMain.getRstBedName());

      // 実績：装置番号 rst_machine_no
      baseordMain.setRstMachineNo(ordMain.getRstMachineNo());

      // 実績：装置名  rst_machine_name
      baseordMain.setRstMachineName(ordMain.getRstMachineName());
      // add FNSI-？？？？患者割り当て 陳 end


      // 実績：条件送信日時 rst_cond_send_date
      baseordMain.setRstCondSendDate(null);
      // 実績：入外区分 rst_in_out_class
      if (ordMain.getRstInOutClass() != null) {
        baseordMain.setRstInOutClass(ordMain.getRstInOutClass());
      } else {
        PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(baseordMain.getPatId());
        if (patPersonalMain != null) {
          int inOutClass = patPersonalMain.getIn_out_class() == null ? 0 :patPersonalMain.getIn_out_class();
          baseordMain.setRstInOutClass(Short.parseShort(String.valueOf(inOutClass)));
        }
      }
      // 実績：病棟コード rst_ward_cd
      if (ordMain.getRstWardCd() != null) {
        baseordMain.setRstWardCd(ordMain.getRstWardCd());
      }
      // 実績：病棟名 rst_ward_name
      if (ordMain.getRstWardName() != null) {
        baseordMain.setRstWardName(ordMain.getRstWardName());
      }
      // 実績：診療科コード rst_course_cd
      if (ordMain.getRstCourseCd() != null) {
        baseordMain.setRstCourseCd(ordMain.getRstCourseCd());
      }
      // 実績：診療科名 rst_course_name
      if (ordMain.getRstCourseName() != null) {
        baseordMain.setRstCourseName(ordMain.getRstCourseName());
      }
      // 実績：DW rst_dw
      if (ordMain.getRstDw() != null) {
        baseordMain.setRstDw(ordMain.getRstDw());
      }
      // add FNSI-？？？？患者割り当て 徐 end
      // del FNSI-？？？？患者割り当て 徐 start
      // 実績：ベッドコード   rst_bed_cd
      // baseordMain.setRstBedCd(ordMain.getRstBedCd());
      // 実績：ベッド名 rst_bed_name
      // baseordMain.setRstBedName(ordMain.getRstBedName());
      // 実績：装置番号 rst_machine_no
      // baseordMain.setRstMachineNo(ordMain.getRstMachineNo());
      // 実績：装置名  rst_machine_name
      // baseordMain.setRstMachineName(ordMain.getRstMachineName());
      // del FNSI-？？？？患者割り当て 徐 end
      // mod FNSI-？？？？患者割り当て 徐 start
      // 実績区分
      // baseordMain.setRstInputClass((short)1);
      // 3：？？？？患者スケジュール割り当て   4：？？？？患者患者名割り当て
      baseordMain.setRstInputClass((short) rstInputClass);
      // mod FNSI-？？？？患者割り当て 徐 end
//      // 実績：治療方法
//      baseordMain.setRstTreatmentCd(ordMain.getRstTreatmentCd());
//      // 実績：治療方法名
//      baseordMain.setRstTreatmentName(ordMain.getRstTreatmentName());
//      // 実績：治療開始日時   rst_start_date
//      baseordMain.setRstStartDate(ordMain.getRstStartDate());
//      // 実績：治療終了日時   rst_end_date
//      baseordMain.setRstEndDate(ordMain.getRstEndDate());
//      // 実績：帰宅日時 rst_return_home_date
//      baseordMain.setRstReturnHomeDate(ordMain.getRstReturnHomeDate());
      // 実績：透析回数 rst_dialysis_cnt
      Integer dialcnt = 0;
      // 割当対象の患者IDから患者基本情報を取得
      PatMain patMain = patMainDao.selectById(baseordMain.getPatId());
      if (patMain != null) {
        String medicalCareInfo = patMain.getMedical_care_info() == null ? "{}" : patMain.getMedical_care_info();
        try {
          ObjectMapper mapMedicalCareInfo = new ObjectMapper();
          JsonNode nodeMedicalCareInfo = null;

          //
          nodeMedicalCareInfo = mapMedicalCareInfo.readTree(medicalCareInfo);

          // 割当先の実績：治療方法か指示：治療方法を取得して患者基本情報の透析回数か浄化治療回数を取得
          Integer treatCd = baseordMain.getRstTreatmentCd() == null
            ? baseordMain.getIndTreatmentCd() == null
            ? 0 : baseordMain.getIndTreatmentCd() : baseordMain.getRstTreatmentCd();
          MstTreatment mstTreat = mstTreatmentDao.selectByCd(treatCd);
          if (mstTreat != null) {
            Integer treatDeviceMode = mstTreat.getDeviceMode();
            if (treatDeviceMode != null) {

              // 透析：透析回数「dialysis_count」
              String strFieldName = "dialysis_count";
              if (treatDeviceMode.equals(9)) {
                // 特殊浄化：浄化治療回数「purification_count」
                strFieldName = "purification_count";
              }

              // 対象キー存在確認
              if (nodeMedicalCareInfo.hasNonNull(strFieldName)) {
                // 現在の透析回数/浄化治療回数
                String strDialCount = nodeMedicalCareInfo.get(strFieldName).asText();
                // mod FNSI-？？？？患者割り当て 陳 start
                // dialcnt = strDialCount == null ? 0: Integer.parseInt(strDialCount);
                dialcnt = (strDialCount == null || "null".equals(strDialCount)) ? 0 : Integer.parseInt(strDialCount);
                // mod FNSI-？？？？患者割り当て 陳 end
                dialcnt++;

                // 実績：治療方法名Null以外の場合
                if (ordMain.getRstTreatmentName() != null) {

                  // 治療方法による更新先判定
                  if (treatDeviceMode.equals(9)) {
                    // 治療記録の浄化治療回数を更新
                    baseordMain.setRstPurificationCnt(dialcnt);
                  } else {
                    // 治療記録の透析回数を更新
                    baseordMain.setRstDialysisCnt(dialcnt);
                  }
                }
              } else {
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("API scheduleAssignment: not define pat_unique.medical_care_info." + strFieldName + ".");
                logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.REMS, null);
              }

            } else {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("API scheduleAssignment: not define treat->devicemode.");
              eventLogMessage.setSqlIdentification("(treatCd = " + treatCd + ")");
              logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.REMS, "MstTreatmentDao/selectByCd");
            }
          }
        } catch (Exception e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("API scheduleAssignment: update dialysis count failure. " + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.REMS, null);
        }
      }
//      // 実績：血液循環積算値  rst_blood_circulate_total
//      baseordMain.setRstBloodCirculateTotal(ordMain.getRstBloodCirculateTotal());
//      // 実績：透析運転時間   rst_running_time
//      baseordMain.setRstRunningTime(ordMain.getRstRunningTime());
//      // 実績：Kt/V rst_kt_v
//      baseordMain.setRstKtV(ordMain.getRstKtV());
//      // 実績：透析記録確認日時 rec_set_date
//      baseordMain.setRecSetDate(ordMain.getRecSetDate());
//      // 実績：送信管理番号   send_ctl_no
//      baseordMain.setSendCtlNo(ordMain.getSendCtlNo());
//      // 実績：血液浄化装置名称 blood_purifier_name
//      baseordMain.setBloodPurifierName(ordMain.getBloodPurifierName());
//      // 実績：プログラム補液引き残し量 pull_leave_amount
//      baseordMain.setPullLeaveAmount(ordMain.getPullLeaveAmount());
//
//      // json形式のデータ
//      // 実績：穿刺者情報    rst_puncture_user_info
//      baseordMain.setRstPunctureUserInfo(ordMain.getRstPunctureUserInfo());
//      // 実績：返血者情報    rst_return_user_info
//      baseordMain.setRstReturnUserInfo(ordMain.getRstReturnUserInfo());
//
//      // マージが必要な項目
//      // 実績：担当者情報    rst_charge_user_info
//      // 割り当て対象の実績：担当者情報
//      String strBaseRstChargeInfo = baseordMain.getRstChargeUserInfo();
//      RstChargeUserInfo baseRstChargeUserInfo = strBaseRstChargeInfo == null || strBaseRstChargeInfo.isEmpty()
//          ? new RstChargeUserInfo()
//          : mapper.readValue(strBaseRstChargeInfo, RstChargeUserInfo.class);
//      // ？？？？患者の実績：担当者情報
//      String strRstChargeInfo = ordMain.getRstChargeUserInfo();
//      RstChargeUserInfo rstChargeUserInfo = strRstChargeInfo == null || strRstChargeInfo.isEmpty()
//          ? new RstChargeUserInfo()
//          : mapper.readValue(strRstChargeInfo, RstChargeUserInfo.class);
//
//      // 担当者1
//      // ？？？？患者の実績で登録情報がある場合
//      if (rstChargeUserInfo.getUserId1() != null) {
//        // 担当者コード1
//        baseRstChargeUserInfo.setUserId1(rstChargeUserInfo.getUserId1());
//        // 担当者1登録日時
//        baseRstChargeUserInfo.setDate1(rstChargeUserInfo.getDate1());
//      }
//      // 担当者2
//      // ？？？？患者の実績で登録情報がある場合
//      if (rstChargeUserInfo.getUserId2() != null) {
//        // 担当者コード2
//        baseRstChargeUserInfo.setUserId2(rstChargeUserInfo.getUserId2());
//        // 担当者2登録日時
//        baseRstChargeUserInfo.setDate2(rstChargeUserInfo.getDate2());
//      }
//
//      baseordMain.setRstChargeUserInfo(baseRstChargeUserInfo.getValue());
//

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(baseordMain.getOrdNo());
      // mangoDb-updateScheduleAssignment-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(baseordMain,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      // 治療情報(ord_main)更新
      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(baseordMain.getOrdNo());
      //add 10860 ind_schedule_user_infoのデータ不正 zhao start
      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      MstPersonalUser mstPersonalUser = MasterCacheHandler.get().getMstPersonalUser(user.getUserId());
      JSONObject indScheduleUserInfo = new JSONObject(baseordMain.getIndScheduleUserInfo());
      indScheduleUserInfo.put("ind_user_id", (null == user.getUserId()) ? JSONObject.NULL : user.getUserId());
      indScheduleUserInfo.put("upd_user_id", (null == user.getUserId()) ? JSONObject.NULL : user.getUserId());
      indScheduleUserInfo.put("ind_user_last_name", (null == mstPersonalUser.getUserLastName()) ? JSONObject.NULL : mstPersonalUser.getUserLastName());
      indScheduleUserInfo.put("upd_user_last_name", (null == mstPersonalUser.getUserLastName()) ? JSONObject.NULL : mstPersonalUser.getUserLastName());
      indScheduleUserInfo.put("ind_user_first_name", (null == mstPersonalUser.getUserFirstName()) ? JSONObject.NULL : mstPersonalUser.getUserFirstName());
      indScheduleUserInfo.put("upd_user_first_name", (null == mstPersonalUser.getUserFirstName()) ? JSONObject.NULL : mstPersonalUser.getUserFirstName());
      indScheduleUserInfo.put("ind_treat_start_time_before", (null == baseordMain.getIndTreatStartTime()) ? JSONObject.NULL : baseordMain.getIndTreatStartTime());
      indScheduleUserInfo.put("ind_kur_cd_before",(null == baseordMain.getIndKurCd()) ? JSONObject.NULL: baseordMain.getIndKurCd());
      baseordMain.setIndScheduleUserInfo(indScheduleUserInfo.toString());
      //add 10860 ind_schedule_user_infoのデータ不正 zhao end
      ordMainDao.updateScheduleAssignment(baseordMain, update);
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(baseordMain.getOrdNo());
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));
      //add #10196 Ord_Material_Save code implementation 20240131 ztc start
      treatmentStatusListService.middleCheck(newOrdMain);
      //add #10196 Ord_Material_Save code implementation 20240131 ztc end
//
//      // 上書き
//
//      // 実績：風袋補正 rst_tare_info
//      // 後体重の風袋  上書き
//      String strRstTareInfo = ordMain.getRstTareInfo();
//      JSONObject rstTareInfo = strRstTareInfo == null || strRstTareInfo.isEmpty() ? null
//          : new JSONObject(strRstTareInfo);
//      if (rstTareInfo != null) {
//        String afterTare = rstTareInfo.get("after").toString();
//        ordMainDao.updateRstTare(baseordMain.getOrdNo(), "{ \"after\": " + afterTare + " }");
//      }
//
//      // 実績：除水補正 rst_off_water_info
//      // 登録内容作成
//      String strRstOffwaterInfo = getStrRstOffWaterInfo(baseordMain.getRstOffWaterInfo(), ordMain.getRstOffWaterInfo());
//      // 更新
//      ordMainDao.updateRstOffWater(baseordMain.getOrdNo(), strRstOffwaterInfo);
//
//      // 実績：体重情報 rst_weight_info// 登録内容作成
//      String strRstWeightInfo = getStrRstWeightInfo(baseordMain.getRstWeightInfo(), ordMain.getRstWeightInfo());
//      // 更新
//      ordMainDao.updateWeightInfo(baseordMain.getOrdNo(), strRstWeightInfo);

      // 追加項目(ctl_no変更)
      // 実績：バイタル情報   rst_vital_info
      // 実績：愁訴情報 rst_complaint_info
      // 実績：愁訴処置情報   rst_treatment_info
      // 実績：愁訴処置者情報  rst_treat_staff_info
      // 実績：回診記録情報   rst_rounds_info

      // 治療時間
      String treatmentTime = null;
      String condInfoText = ordMain.getRstCondInfo();
      if (null != condInfoText) {
        CondInfo condInfo = condInfoService.createCondInfo(condInfoText);
        CondInfoItem condItem = condInfo.getTreatTime();
        treatmentTime = condItem.getValue();
      }
      // 割り当て対象の患者基本情報(pat_main)更新
      patMainAcceptanceStatusInfoService.update(baseordMain.getPatId(), baseordMain.getOrdNo(), baseordMain.getRstDialysisState(), ordMain.getRstStartDate(), treatmentTime);


      // del FNSI-？？？？患者割り当て 陳 start
////    // ？？？？患者の治療情報(ord_main)削除
////    ordMainDao.updateDeleteByOrdNo(ordNo, update);
//      // ？？？？患者の治療状態判定
//      if (ordMain.getRstDialysisState().equals("3")) {
//        // 治療中の場合
//
//        // 実績：治療終了日時   rst_end_date
//        ordMain.setRstEndDate(update);
//        // 実績：治療状況 rst_dialysis_state 4:排液後(治療終了)
//        ordMain.setRstDialysisState("4");
//
//        // add FNSI-改修内容追加OrdMain履歴 付 start
//        getHistory(ordMain.getOrdNo());
//        // mangoDb-updateScheduleAssignment-insertSuccess
//        // add FNSI-改修内容追加OrdMain履歴 付 end
//
//        // ？？？？患者の治療情報(ord_main)更新
//        ordMainDao.updateScheduleAssignment(ordMain, update);
//      }
      // del FNSI-？？？？患者割り当て 陳 end


//    // 装置動作記録(mnt_motion_record) ord_no更新
//    mntMotionRecordDao.updateOrdNo(baseordNo, ordNo, update);
//
//    // モニタデータ(mni_monitor) ord_no, pat_id更新
//    mniMonitorDao.updateOrdNoPatId(baseordNo, ordNo, baseordMain.getPatId(), update);

//    // 観察記録
//
//    // チェックリスト


      // スケジュール割り当て通知用データ作成
      DeviceEdgeOrderRequest dres = new DeviceEdgeOrderRequest();
      dres.setPatId(baseordMain.getPatId());
      dres.setOrdNo(baseordNo);

      // ？？？？患者の治療記録から装置情報取得
      List<MstMachine> machines = mstMachineDao.selectByOrdNoRst(ordNo);
      MstMachine machine = new MstMachine();
      if (machines.size() > 0) {
        machine = machines.get(0);

        // 通知先の装置情報
        dres.setFacilityCd(machine.getFacilityCd());
        dres.setDeviceEdgeNo(machine.getDeviceEdgeNo());
        dres.setMachineNo(machine.getMachineNo());

        // 装置治療状態取得
        MntMachineState state = mntMachineStateDao.selectByKey(
          machine.getFacilityCd(),
          machine.getMachineTypeCd(),
          machine.getMachineSerial()
        );
        if (state != null) {
          // 現患者判定
          Long nowOrdNo = state.getOrdNo();
          if (ordNo.equals(nowOrdNo)) {

            // 現患者が？？？？患者の治療記録の場合
            String mmsTbN = "mnt_machine_state";

            // SQL検索条件
            StringBuffer wheres = new StringBuffer("");
            wheres.append(" WHERE\n");
            wheres.append(" ord_no = " + ordNo + "\n");
            wheres.append(" AND\n");
            wheres.append(" facility_cd = '" + machine.getFacilityCd() + "'" + "\n");
            wheres.append(" AND\n");
            wheres.append(" machine_type_cd = '" + machine.getMachineTypeCd() + "'" + "\n");
            wheres.append(" AND\n");
            wheres.append(" trim(machine_serial) = trim('" + machine.getMachineSerial() + "')" + "\n");


            DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
            // ログ出力カラム情報及び更新前データ情報取得
            boolean setResult = logCommon.setInfo();


            // 装置状態管理(mnt_machine_state) ord_no, next_ord_no, pat_id, next_pat_id登録
            int retCnt = mntMachineStateDao.updateOrdNoPatId(baseordMain.getPatId(), baseordNo, ordNo, update,
              machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial());

            //DB更新ログ出力ロジック wp start
            // 更新後データ取得、差分あれば、log出力
            if (setResult && retCnt > 0) {
              logCommon.updateLog();
            }
            //DB更新ログ出力ロジック wp end 20210129

            // 通信サーバーへの通知を依頼
            dres.setIsSendable("1");
          }
        }
      }
      res.machinedata = dres;
      // add FNSI-？？？？患者割り当て 陳 start

      // 装置モニタ(ord_treat_condition) ord_no更新
      ordTreatConditionDao.updateOrdNo(baseordNo, ordNo, update);

      if (dataMerge) {

        // リスト基準のデータを削除する
        //del 9324 ord_checklist共通之外的dao方法删除 gjn start
        //ordChecklistDao.deleteByOrdNoRstClass(ordNo);
        //del 9324 ord_checklist共通之外的dao方法删除 gjn end

        // 指定ordNoのチェックリスト実績取得（？？？？患者）
        List<OrdChecklist> ordList = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);

        // 指定ordNoのチェックリスト実績取得（特定患者）
        List<OrdChecklist> baseordList = ordChecklistDao.selectByOrdNo(SelectOptions.get(), baseordNo);

        OrdChecklist.OrdChecklistRegCheckInfo ordListInfo = null;
        OrdChecklist.OrdChecklistRegCheckInfo baserdListInfo = null;

        for (OrdChecklist ordData : ordList) {

          // チェックリスト情報（？？？？患者）
          ordListInfo = ordData.getRstChecklistInfo();
          for (OrdChecklist baseData : baseordList) {

            // チェックリスト情報（特定患者）
            baserdListInfo = baseData.getRstChecklistInfo();

            // フリーワード場合
            if (ordData.getFuncClass() == 0 && baseData.getFuncClass() == 0 &&
                Objects.equal(ordData.getListCd(),baseData.getListCd()) &&
                (ordListInfo.getItemNumber() != null && baserdListInfo.getItemNumber() != null) &&
                Objects.equal(ordListInfo.getItemNumber(),baserdListInfo.getItemNumber())) {
                //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                // 実施状態の更新
                //ordChecklistDao.updateIscheckByOrdNo(ordData.getIsCheck(), update, baseData.getChecklistCtlNo());

                // チェックリスト実績データのクリア(？？？？患者)
                //ordChecklistDao.deleteByCheckListCtlNo(ordData.getChecklistCtlNo());
                //del 9324 ord_checklist共通之外的dao方法删除 gjn end
            } else {

              if (Objects.equal(ordData.getListCd(),baseData.getListCd()) &&
                (ordListInfo.getCode() != null && baserdListInfo.getCode() != null) &&
                Objects.equal(ordListInfo.getCode(),baserdListInfo.getCode())) {

                int amount = ordListInfo.getAmount() == null ? 0 : Integer.parseInt(ordListInfo.getAmount());
                int amount2 = baserdListInfo.getAmount() == null ? 0 : Integer.parseInt(baserdListInfo.getAmount());
                amount  = amount + amount2;
                //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                //ordChecklistDao.updateAmount(ordData.getChecklistCtlNo(),String.valueOf(amount));
                //ordChecklistDao.deleteByCheckListCtlNo(baseData.getChecklistCtlNo());
                //del 9324 ord_checklist共通之外的dao方法删除 gjn end
              }
            }
          }
        }

        // ？？？？患者ordNo　⇒　特定患者ordNo
        //del 9324 ord_checklist共通之外的dao方法删除 gjn start
        //ordChecklistDao.updateOrdNo(ordNo, baseordNo, update);

        // チェックリスト実績データのクリア(？？？？患者)
        //ordChecklistDao.deleteByOrdNo(ordNo, ordMain.getFacilityCd());
        //del 9324 ord_checklist共通之外的dao方法删除 gjn end
      }

      // 装置モニタ(mni_monitor) ord_no更新
      // mod #10422 ？？？？患者の患者割り当てが遅い 20240314 ztc start
      mniMonitorDao.updateOrdNoByOrdNoFacilityCd(baseordMain.getFacilityCd(), baseordNo, ordNo, update);

      // 装置動作記録(mnt_motion_record) ord_no更新
      mntMotionRecordDao.updateOrdNoFacilityCd(baseordMain.getFacilityCd(), baseordNo, ordNo, update);
      // mod #10422 ？？？？患者の患者割り当てが遅い 20240314 ztc end

      boolean mntFlg = false;

      // 患者切り替えタイミング
      String patTiming = "";

      // mnt_machine_state(装置状態管理)の情報を取得する。
      List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByOrdNo(ordMain.getFacilityCd(), ordNo);
      for (MntMachineState dataInfo : mntMachineStateList) {

        // mst_machine(装置マスタ	)からdevice_edge_noを取得する。
        MstMachine mstMachine = mstMachineDao.selectByCd(dataInfo.getMachineTypeCd(), dataInfo.getMachineSerial(), dataInfo.getFacilityCd());

        // mst_comsv_setting(通信サーバー設定)からpat_timingを取得する。
        MstComsvSetting mstComsvInfo = mstComsvSettingDao.selectByCd(ordMain.getFacilityCd(), mstMachine.getDeviceEdgeNo());
        if (mstComsvInfo != null && mstComsvInfo.getPatTiming() != null) {
          patTiming = mstComsvInfo.getPatTiming();
        }

        if (!"".equals(dataInfo.getNextOrdNo())) {

          // next_ord_no通り,データを検索する
          OrdMain ordMainInfo = ordMainDao.selectByOrdNo(dataInfo.getNextOrdNo());

          // 治療状況が0の場合、更新処理を行う
          if ("0".equals(ordMainInfo.getRstDialysisState())) {

            mntFlg = true;
          }
        }
      }

      // 治療時間
      Long treatmentTimeInfo = 0L;

      if (baseordMain.getRstCondInfo() != null) {

        JsonNode baseNode = map.readTree(baseordMain.getRstCondInfo());

        // 実績：治療条件情報の処理
        Iterator<String> keys = baseNode.propertyNames().iterator();
        while (keys.hasNext()) {
          // Json キーを取得する
          String key = keys.next();

          // 治療時間の取得
          if ("1".equals(key)) {

            // mod #10060 加算マスタで汎用＋手動の組み合わせのマスタ項目で患者情報でチェックONにしても治療記録の加算がONにならない。 dengshen start
            // treatmentTimeInfo = Long.parseLong(baseNode.get("1").get("value").toString());
            // add #9973 Resolve null exception for key 20240117 ztc start
            if(baseNode.hasNonNull("1") && baseNode.get("1").hasNonNull("value")){
            // add #9973 Resolve null exception for key 20240117 ztc end
              treatmentTimeInfo = Long.parseLong(baseNode.get("1").get("value").asText());
            }
            // mod #10060 加算マスタで汎用＋手動の組み合わせのマスタ項目で患者情報でチェックONにしても治療記録の加算がONにならない。 dengshen end
            break;
          }
        }
      }

      // pat_mainのデータ更新
      if (isJsonArray(baseordMain.getPatId())){

        patMainDao.updateAcceptanceStatusInfo(baseordMain.getPatId(), "\""+baseordMain.getRstDialysisState()+"\"", treatmentTimeInfo.toString(),
          getDateString_iso8601(baseordMain.getRstStartDate()), update);
      }

      if ("3".equals(ordMain.getRstDialysisState())) {

        // mnt_machine_stateのデータ更新
        mntMachineStateDao.updateOrdNoPatIdByOrdNo(baseordMain.getPatId(), baseordNo, ordNo, update);

        // 未登録患者割付
        sendRequestPatAssignmentDeviceEdges(baseordMain.getOrdNo(), baseordMain.getFacilityCd());

      } else if ("4".equals(ordMain.getRstDialysisState())) {

        // mnt_machine_stateのデータ更新
        if (mntFlg) {

          mntMachineStateDao.updateOrdNoPatIdByOrdNo(baseordMain.getPatId(), baseordNo, ordNo, update);

          // 未登録患者割付
          sendRequestPatAssignmentDeviceEdges(baseordMain.getOrdNo(), baseordMain.getFacilityCd());
        }

      } else if ("5".equals(ordMain.getRstDialysisState())) {

        // mnt_machine_stateのデータ更新
        if (mntFlg && "1".equals(patTiming)) {

          mntMachineStateDao.updateOrdNoPatIdByOrdNo(baseordMain.getPatId(), baseordNo, ordNo, update);

          // 未登録患者割付
          sendRequestPatAssignmentDeviceEdges(baseordMain.getOrdNo(), baseordMain.getFacilityCd());
        }
      }

      // ord_main_restoreに退避
      setOrdMainRestoreData(ordNo);

      // ？？？？患者データの削除
      oldOrdMain = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
      ordMainDao.delete(oldOrdMain);
      triggerUtil.deleteTriggerOrdMain(Collections.singletonList(oldOrdMain));
      //add #10196 Ord_Material_Save code implementation 20240131 ztc start
      ordMaterialSaveService.deleteOrdMaterialSave(ordMain.getOrdNo());
      //add #10196 Ord_Material_Save code implementation 20240131 ztc end

      if ("3".equals(ordMain.getRstDialysisState())) {

        // 次患者情報送信
        postOrderSendNextPat(baseordMain.getOrdNo(), baseordMain.getFacilityCd());
      }
      // add FNSI-？？？？患者割り当て 陳 end

    } else {
      // 既に患者が割り当てられている場合
      res.errorMessage = "既に患者が割り当てられています。";
    }

    return res;

  }

  // add FNSI-？？？？患者割り当て 陳 start

  /**
   * 未登録患者割付
   *
   * @param facilityCd 　施設コード
   * @param ordNo      　オーダー番号
   */
  private void sendRequestPatAssignmentDeviceEdges(Long ordNo, String facilityCd) {
    DeviceEdgeOrderRequest dres = new DeviceEdgeOrderRequest();

    dres.setOrdNo(ordNo);
    dres.setFacilityCd(facilityCd);

    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(dres);
      deviceEdgeOrderService.orderSetUnknownPat(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
        targetInfo.getMachineNo(), targetInfo.getOrdNo());

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no MstUser.");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
        null);
    }
  }

  /**
   * DateからISO8601形式の日付文字列を取得する。
   *
   * @param date
   * @return ISO8601形式の日付文字列
   */
  private String getDateString_iso8601(Date date) {
    if (date == null) {
      return null;
    } else {
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
      sdf.setTimeZone(TimeZone.getTimeZone("JST"));
      String dateString = "\""+sdf.format(date)+"\"";
      return dateString;
    }
  }

  /**
   * チェックリスト実績のデータ展開処理
   *
   * @param facilityCd 　施設コード
   * @param ordNo      　オーダー番号
   * @return 登録成功
   * @throws URISyntaxException
   */
  private boolean insertCheckList(String facilityCd, Long ordNo) throws URISyntaxException {

    URI uri = new URI(deviceEdgeUrl + "/api/comsv_checklist/ord/createordchecklist/" + facilityCd + "/" + ordNo);
    RequestEntity<Void> request = RequestEntity.get(uri).header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").build();
    RestTemplate restTemplate = new RestTemplate();
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
    long start = System.currentTimeMillis();
    ResponseEntity<Object> response = restTemplate.exchange(request, Object.class);
    long cost = System.currentTimeMillis() - start;
    Map<String, Object> map = new HashMap<>();
    map.put("logType", "RESTTEMPLATE-LOG");
    map.put("className", "jp.co.nikkiso.ntss.admin_web.service.scheduleAssignment.ScheduleAssignmentServiceImpl");
    map.put("methodName", "insertCheckList");
    map.put("method", request.getMethod());
    map.put("url", uri.getPath());
    map.put("headers", request.getHeaders());
    map.put("requestParameter", request.getBody());
    map.put("status",response.getStatusCode());
    map.put("cost", cost);
    map.put("result",response.getBody());
    EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
    restTemplateEventLogMessage.setLogMessage(toJson(map));
    restTemplateEventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    EventLogMessage eventLogMessage = new EventLogMessage();
    if (response.getStatusCode() == HttpStatus.OK) {
      return true;
    } else {
      eventLogMessage.setLogMessage("チェックリスト情報更新API呼び出し失敗 = " + response.getStatusCode());
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

      return false;
    }
  }

  /**
   * ャーナル更新APIリクエスト
   *
   * @param ordNo      オーダ番号
   * @param facilityCd 施設コード
   * @param patId      患者ID
   * @param treatDate  治療日
   * @param flg        画面フラグ
   */
  private void insertCoopJouranal(Long ordNo, String facilityCd, Long patId, String treatDate, String flg) {

    try {

      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
      // mod FNSI-外部連携api呼び出対応 陳 start
      // payload.setOpeCd("011009");
      // 治療状況リストの場合
      if ("list".equals(flg)) {
        payload.setOpeCd("011009");
      } else {
        payload.setOpeCd("012001");
      }
      // mod FNSI-外部連携api呼び出対応 陳 end
      payload.setCrud("C");
      payload.setFacilityCd(facilityCd);
      if (patPersonalMain != null) {
        payload.setHospPatId(patPersonalMain.getHosp_pat_id());
      }
      payload.setPatId(patId);
      payload.setOrdNo(ordNo);
      payload.setBaseDate(treatDate);

      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      if (user != null) {
        payload.setUserId(user.getUserId());
      }
      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
//      RestTemplate rt = new RestTemplate();
//      URI uri = new URI(coopApi + "/journal/create");
//      RequestEntity<JournalCreateRequestPayload> request = RequestEntity
//        .post(uri)
//        .contentType(MediaType.APPLICATION_JSON)
//        .body(payload);
//      rt.exchange(request, Object.class);
      journalService.callCreateJournalForPayload(payload);
      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      eventLogMessage.setFacilityCd(facilityCd);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * ord_main_hstにデータ設定
   *
   * @param ordNo 　オーダ番号
   */
  private void setOrdMainRestoreData(Long ordNo) {

    OrdMain targetOrdMain = ordMainDao.selectByOrdNo(ordNo);
    if (targetOrdMain == null) {
      throw new NotExistException(String.format("？？？？患者割当:オーダ番号に該当する情報が存在しません。オーダ番号[%d]", ordNo));
    }

    OrdMainRestore ordMainRestore = new OrdMainRestore();
    Class<?> ordMainClass = targetOrdMain.getClass();
    Class<?> ordMainRestoreClass = ordMainRestore.getClass();
    Field[] ordMainFields = ordMainClass.getDeclaredFields();
    for (Field f : ordMainFields) {
      Field tempFileld = null;
      try {
        tempFileld = ordMainRestoreClass.getDeclaredField(f.getName());
        tempFileld.setAccessible(true);
        f.setAccessible(true);
        tempFileld.set(ordMainRestore, f.get(targetOrdMain));
      } catch (NoSuchFieldException | IllegalAccessException e) {
        //項目が不一致
      }
    }

    ordMainRestore.setDelDate(new Timestamp(System.currentTimeMillis()));
    ordMainRestoreDao.insert(ordMainRestore);
  }

  /**
   * 次患者情報転送指示
   *
   * @param ordNo      オーダ番号
   * @param facilityCd 施設コード
   */
  private void postOrderSendNextPat(Long ordNo, String facilityCd) {
    DeviceEdgeOrderRequest dres = new DeviceEdgeOrderRequest();

    dres.setOrdNo(ordNo);
    dres.setFacilityCd(facilityCd);

    try {
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(dres);
      deviceEdgeOrderService.orderSendNextPat(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
        targetInfo.getMachineNo(), targetInfo.getOrdNo());

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no MstUser.");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
        null);
    }
  }

  /**
   * 治療進捗状態の情報の判断
   *
   * @param patId 患者ID
   * @return
   */
  private boolean isJsonArray(Long patId ) {

    PatMain pm = patMainDao.selectById(patId);
    try{

      new JSONArray(pm.getAcceptance_status_info());
      return true;
    } catch(Exception e){
      return false;
    }
  }

  /**
   * 実績：指示コメント情報の採番判定
   *
   * @param map 採番ステータス
   * @param selCount 採番数
   * @return
   */
  private String checkNo (Map map, int selCount) {

    String allKey = "";
    int count = 0;
    Iterator iter = map.entrySet().iterator();
    while(iter.hasNext()) {
      Map.Entry entry = (Map.Entry) iter.next();
      boolean val = (Boolean)entry.getValue();

      if (!val) {
        count++;
        allKey = allKey + entry.getKey()+",";

        if(count == selCount) {
          break;
        }
      }
    }
    return allKey;
  }

  /**
   *？？？？患者のjsonのjsonキーは特定患者のjsonのjsonキーの中に存在判定
   *
   * @param jsonValue 特定患者情報
   * @param jsonValue2　？？？？患者情報
   * @return
   */
  // mod 11454 時間外加算自動処理が機能していない zkm start
//  private String checkNo (String jsonValue ,String jsonValue2) {
  private List<String> checkNo (String jsonValue , String jsonValue2) {
    // mod 11454 時間外加算自動処理が機能していない zkm end
    ObjectMapper omMap = new ObjectMapper();

    Map<String,Boolean> keyMap = new LinkedHashMap<String,Boolean>();

    try {
      JsonNode tokuNode = omMap.readTree(jsonValue);
      JsonNode hateNode = omMap.readTree(jsonValue2);

      Iterator<String> keys = tokuNode.propertyNames().iterator();
      while (keys.hasNext()) {
        // Json キーを取得する
        String key = keys.next();
        keyMap.put(key, false);
      }

      Iterator<String> hateKeys = hateNode.propertyNames().iterator();
      while (hateKeys.hasNext()) {
        // Json キーを取得する
        String key = hateKeys.next();
        // mod 11454 時間外加算自動処理が機能していない zkm start
//
//        if (keyMap.get(key)!= null) {
//          keyMap.put(key, true);
//        }
        // シングルニードル
        if ("12".equals(key)) {
          if (null == hateNode.get("11")) {
            keyMap.put("11", true);
          } else {
            keyMap.put("9", true);
            keyMap.put("10", true);
          }
        }
        // mod 11454 時間外加算自動処理が機能していない zkm end
      }

    }catch(Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    // mod 11454 時間外加算自動処理が機能していない zkm start
//    String allKey = "";
    List<String> allKey = new ArrayList<>();
    // mod 11454 時間外加算自動処理が機能していない zkm end

    Iterator iter = keyMap.entrySet().iterator();
    while(iter.hasNext()) {
      Map.Entry entry = (Map.Entry) iter.next();
      boolean val = (Boolean)entry.getValue();

      // mod 11454 時間外加算自動処理が機能していない zkm start
//      if (!val) {
//
//        allKey = allKey + entry.getKey()+",";
      if (val) {
        allKey.add(entry.getKey().toString());
        // mod 11454 時間外加算自動処理が機能していない zkm end
      }

    }

    return allKey;
  }

  // add FNSI-？？？？患者割り当て 陳 end

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo) {
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * 除水補正登録内容作成
   *
   * @param strBaseRstOffWaterInfo 対象のスケジュールの除水補正実績情報
   * @param strRstOffWaterInfo     ？？？？患者のスケジュールの除水補正実績情報
   * @return 登録内容
   * @throws IOException
   * @throws JsonMappingException
   * @throws JacksonException
   */
  public String getStrRstOffWaterInfo(String strBaseRstOffWaterInfo, String strRstOffWaterInfo)
    throws JacksonException, IOException {

    // 割り当て対象の実績：除水補正
    RstOffWaterInfo baseRstOffWaterInfo = strBaseRstOffWaterInfo == null || strBaseRstOffWaterInfo.isEmpty()
      ? new RstOffWaterInfo()
      : mapper.readValue(strBaseRstOffWaterInfo, RstOffWaterInfo.class);
    // ？？？？患者の実績：除水補正
    RstOffWaterInfo rstOffWaterInfo = strRstOffWaterInfo == null || strRstOffWaterInfo.isEmpty() ? new RstOffWaterInfo()
      : mapper.readValue(strRstOffWaterInfo, RstOffWaterInfo.class);

    // 変更箇所の情報セット
    if (rstOffWaterInfo.getName1() != null) {
      baseRstOffWaterInfo.setName1(rstOffWaterInfo.getName1());
    }
    if (rstOffWaterInfo.getName2() != null) {
      baseRstOffWaterInfo.setName2(rstOffWaterInfo.getName2());
    }
    if (rstOffWaterInfo.getName3() != null) {
      baseRstOffWaterInfo.setName3(rstOffWaterInfo.getName3());
    }
    if (rstOffWaterInfo.getName4() != null) {
      baseRstOffWaterInfo.setName4(rstOffWaterInfo.getName4());
    }
    if (rstOffWaterInfo.getName5() != null) {
      baseRstOffWaterInfo.setName5(rstOffWaterInfo.getName5());
    }

    if (rstOffWaterInfo.getWeight1() != null) {
      baseRstOffWaterInfo.setWeight1(rstOffWaterInfo.getWeight1());
    }
    if (rstOffWaterInfo.getWeight2() != null) {
      baseRstOffWaterInfo.setWeight2(rstOffWaterInfo.getWeight2());
    }
    if (rstOffWaterInfo.getWeight3() != null) {
      baseRstOffWaterInfo.setWeight3(rstOffWaterInfo.getWeight3());
    }
    if (rstOffWaterInfo.getWeight4() != null) {
      baseRstOffWaterInfo.setWeight4(rstOffWaterInfo.getWeight4());
    }
    if (rstOffWaterInfo.getWeight5() != null) {
      baseRstOffWaterInfo.setWeight5(rstOffWaterInfo.getWeight5());
    }

    return baseRstOffWaterInfo.getValue();
  }

  /**
   * 体重情報の実績の登録内容作成
   *
   * @param baseWeight 対象のスケジュールの体重情報の実績
   * @param weight     ？？？？患者のスケジュールの体重情報の実績
   * @return 体重情報の実績の登録内容
   * @throws JacksonException
   * @throws JsonMappingException
   * @throws IOException
   */
  private String getStrRstWeightInfo(String baseWeight, String weight)
    throws JacksonException, IOException {

    // 対象のスケジュールの体重情報の実績
    OrdMainRstWeightInfo basedto = baseWeight == null || baseWeight.isEmpty() ? new OrdMainRstWeightInfo()
      : mapper.readValue(baseWeight, OrdMainRstWeightInfo.class);
    // ？？？？患者のスケジュールの体重情報の実績
    OrdMainRstWeightInfo dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
      : mapper.readValue(weight, OrdMainRstWeightInfo.class);

    // 変更箇所の情報セット
    // weight_measure_after: (Number)透析後体重測定値（風袋・車いすを含む重量）
    if (dto.getWeightMeasureAfter() != null) {
      basedto.setWeightMeasureAfter(dto.getWeightMeasureAfter());
    }
    // weight_after: (Number)透析後体重
    if (dto.getWeightAfter() != null) {
      basedto.setWeightAfter(dto.getWeightAfter());
    }
    // weight_after_date: (String)後体重測定日時
    if (dto.getWeightAfterDate() != null) {
      basedto.setWeightAfterDate(dto.getWeightAfterDate());
    }
    // ctr: (Number)CTR
    if (dto.getCtr() != null) {
      basedto.setCtr(dto.getCtr());
    }
    // ctr_measure_date: (String)CTR測定日時
    if (dto.getCtrMeasureDate() != null) {
      basedto.setCtrMeasureDate(dto.getCtrMeasureDate());
    }
    // ctr_weight: (Number)CTR測定時体重
    if (dto.getCtrWeight() != null) {
      basedto.setCtrWeight(dto.getCtrWeight());
    }
    // water_removal_target: (Number)目標除水量
    if (dto.getWaterRemovalTarget() != null) {
      basedto.setWaterRemovalTarget(dto.getWaterRemovalTarget());
    }
    // water_removal_rst: (Number)実績除水量
    if (dto.getWaterRemovalRst() != null) {
      basedto.setWaterRemovalRst(dto.getWaterRemovalRst());
    }
    // add_total: (Number)除水積算値
    if (dto.getAddTotal() != null) {
      basedto.setAddTotal(dto.getAddTotal());
    }
    // add_water_total: (Number)補液積算値
    if (dto.getAddWaterTotal() != null) {
      basedto.setAddWaterTotal(dto.getAddWaterTotal());
    }
    // kt_v_measure: (Number)Kt/V測定値
    if (dto.getKtVMeasure() != null) {
      basedto.setKtVMeasure(dto.getKtVMeasure());
    }
    // urr: (Number)URR
    if (dto.getUrr() != null) {
      basedto.setUrr(dto.getUrr());
    }
    // weight_decreased: (Number)減少量
    if (dto.getWeightDecreased() != null) {
      basedto.setWeightDecreased(dto.getWeightDecreased());
    }
    // re_loop_rate_main:(Number)治療記録で選択された再循環率の番号を格納
    if (dto.getReLoopRateMain() != null) {
      basedto.setReLoopRateMain(dto.getReLoopRateMain());
    }
    return mapper.writeValueAsString(basedto);
  }

  // 担当者情報クラス
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class RstChargeUserInfo {
    /**
     * ObjectMapper
     */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /**
     * ModelMapper
     */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 担当者コード1
     */
    @JsonProperty("user_id_1")
    private Long userId1;

    /**
     * 担当者コード2
     */
    @JsonProperty("user_id_2")
    private Long userId2;

    /**
     * 担当者1登録日時
     */
    @JsonProperty("date_1")
    private Timestamp date1;

    /**
     * 担当者2登録日時
     */
    @JsonProperty("date_2")
    private Timestamp date2;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    public RstChargeUserInfo(String value) {
      try {
        RstChargeUserInfo obj = objectMapper.readValue(value, RstChargeUserInfo.class);
        modelMapper.map(obj, this);
      } catch (tools.jackson.core.JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      }
    }

    /**
     * 基本型の値を返す.
     *
     * @return 基本型の値
     */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JacksonException e) {
        return null;
      }
    }
  }

  // 除水補正情報クラス
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class RstOffWaterInfo {
    /**
     * ObjectMapper
     */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /**
     * ModelMapper
     */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 項目1名称
     */
    @JsonProperty("name_1")
    private String name1;

    /**
     * 項目2名称
     */
    @JsonProperty("name_2")
    private String name2;

    /**
     * 項目3名称
     */
    @JsonProperty("name_3")
    private String name3;

    /**
     * 項目4名称
     */
    @JsonProperty("name_4")
    private String name4;

    /**
     * 項目5名称
     */
    @JsonProperty("name_5")
    private String name5;

    /**
     * 項目1重さ
     */
    @JsonProperty("weight_1")
    private Integer weight1;

    /**
     * 項目2重さ
     */
    @JsonProperty("weight_2")
    private Integer weight2;

    /**
     * 項目3重さ
     */
    @JsonProperty("weight_3")
    private Integer weight3;

    /**
     * 項目4重さ
     */
    @JsonProperty("weight_4")
    private Integer weight4;

    /**
     * 項目5重さ
     */
    @JsonProperty("weight_5")
    private Integer weight5;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    public RstOffWaterInfo(String value) {
      try {
        RstOffWaterInfo obj = objectMapper.readValue(value, RstOffWaterInfo.class);
        modelMapper.map(obj, this);
      } catch (tools.jackson.core.JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      }
    }

    /**
     * 基本型の値を返す.
     *
     * @return 基本型の値
     */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JacksonException e) {
        return null;
      }
    }
  }

  //DB更新ログ出力ロジック wp start


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
   *
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


  //DB更新ログ出力ロジック wp end
}
