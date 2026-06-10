package jp.co.nikkiso.ntss.admin_web.web.rest;

//add FNSI redmine 6706 劉祥霖　start
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.checkList.CheckListService;
import jp.co.nikkiso.ntss.admin_web.service.journal.JournalCreatePayloadService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dto.OrdMain.JournalEventLinkByPat;
//add FNSI redmine 6706 劉祥霖　end

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.response.checkList.CheckListScheduleResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.response.scheduleAssignment.ScheduleAssignmentUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.scheduleAssignment.ScheduleAssignmentService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@Slf4j
@RequestMapping(Uri.SCHEDULE_ASSIGNMENT)
public class ScheduleAssignmentResource {

  //add FNSI redmine 6706 劉祥霖　start
  // del 11454 時間外加算自動処理が機能していない zkm start
//  @Autowired
//  private MstMedicateTimingDao mstMedicateTimingDao;

//  @Autowired
//  private DBAppWebAPIDao dBAppWebAPIDao;

//  @Autowired
//  private MntMachineStateDao mntMachineStateDao;
  // del 11454 時間外加算自動処理が機能していない zkm end

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private MstMedicineDao mstMedicineDao;
  //add FNSI redmine 6706 劉祥霖　end

  @Autowired
  WebSocketNotifyService sendWsMsg;
  @Autowired
  ScheduleAssignmentService scheduleAssignmentService;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
	LogService logService;
  // del 11454 時間外加算自動処理が機能していない zkm start
//  // add FNSI-？？？？患者割り当て 徐 start
//  @Autowired
//  private SendConditionCancelService sendConditionCancelService;
//  // add FNSI-？？？？患者割り当て 徐 end
  // del 11454 時間外加算自動処理が機能していない zkm end

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  // del 11454 時間外加算自動処理が機能していない zkm start
//  //add 9480 治療状況(スケジュール割り当て処理),检查计算 gjn start
//  @Resource(name = "crawlExecutorPool")
//  private ExecutorService threadExector;
//  //add 9480 治療状況(スケジュール割り当て処理),检查计算 gjn end
  // del 11454 時間外加算自動処理が機能していない zkm end

  // add 9324 スケジュール割り当て ord_checklistの変更 gjn start
  @Autowired
  CheckListService checkListService;
  // del 11454 時間外加算自動処理が機能していない zkm start
//  @Autowired
//  private MstChecklistDao mstChecklistDao;
  // del 11454 時間外加算自動処理が機能していない zkm end
  // add 9324 スケジュール割り当て ord_checklistの変更 gjn end

  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao strat
  @Autowired
  private JournalService journalService;

  @Autowired
  private JournalCreatePayloadService journalCreatePayloadService;
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

  /**
   * ord_main取得
   * @param orderNo
   * @return
   */
  @GetMapping("getorder/{orderNo}")
  public ResponseEntity<?> getOrderByOrderNo(
      @PathVariable Long orderNo) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SCHEDULE_ASSIGNMENT + "/getorder";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    CheckListScheduleResponse res = new CheckListScheduleResponse();
    // NOTE: ord_mainをorderNoで取得する
    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(scheduleAssignmentService.getOrderByOrderNo(orderNo), HttpStatus.OK);

    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      //res.errorMessage = e.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 患者一覧情報取得
   * @return
   */
  @GetMapping("getpatlist")
  public ResponseEntity<?> getPatlist(
      @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SCHEDULE_ASSIGNMENT + "/getpatlist";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(scheduleAssignmentService.getPatlist(ntssUser.getFacilityCd()), HttpStatus.OK);
  }

  /**
   * 対象のスケジュール一覧情報取得
   * @param startDate 治療開始日付
   * @param endDate 治療終了日付(治療中の場合は現在日付)
   * @param bedCd ベッドコード
   * @return
   */
  @GetMapping("getschedulelist/{startDate}/{endDate}/{bedCd}")
  public ResponseEntity<?> getSchedulelist(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable String startDate,
      @PathVariable String endDate,
      @PathVariable Long bedCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SCHEDULE_ASSIGNMENT + "/getschedulelist";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(startDate, endDate,bedCd));
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(startDate, endDate,bedCd));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(scheduleAssignmentService.getSchedulelist(ntssUser.getFacilityCd(), startDate, endDate, bedCd), HttpStatus.OK);
  }

  /**
   * 患者割り当て
   * @param patId
   * @param ordNo
   * @return
   */
  @PostMapping("/patassignment/{patId}/{ordNo}")
  public ResponseEntity<?> patAssignment(
      @PathVariable Long patId,
      @PathVariable Long ordNo) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SCHEDULE_ASSIGNMENT + "/getschedulelist";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(patId, ordNo));
    // wp アプリケーションログの適正化 Add End


    try {
      ScheduleAssignmentUpdateResponse r = scheduleAssignmentService.patAssignment(patId, ordNo);


      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(patId, ordNo));
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(r, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      ScheduleAssignmentUpdateResponse r = new ScheduleAssignmentUpdateResponse();
      r.errorMessage = e.getMessage();

      return new ResponseEntity<>(r, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * スケジュール割り当て
   * @param baseOrdNo
   * @param ordNo
   * @param rstInputClass
   * @param flg
   * @return
   */
  @PostMapping("/scheduleassignment/{baseOrdNo}/{ordNo}/{rstInputClass}/{flg}")
  public ResponseEntity<?> scheduleAssignment(
      @PathVariable Long baseOrdNo,
      @PathVariable Long ordNo,
      @PathVariable int rstInputClass,
      @PathVariable String flg) {

    // 毛 ログ改善対応 Add
    EventLogMessage eventLogMessage = new EventLogMessage();

    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    ScheduleAssignmentUpdateResponse r = null;
    String facilityCd = null;
    OrdMain ordMainChangedDataInfo = null; // 連携用、イベントログ用
    OrdMain ordMainChangeBeforeDataInfo = null; // 連携用、イベントログ用
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

    try {

// mod 11454 時間外加算自動処理が機能していない(実装ロジックが同一トランザクションにするために、ScheduleAssignmentServiceImpl.javaのscheduleAssignmentメソッドに移動する) zkm start
//// 割当先治療記録の実績展開を実施
//
//      // 割り当て対象の最新の治療情報(ord_main)情報取得
//      OrdMainUpdateForScheduleAssignment baseordMain = ordMainDao.selectByOrdNoUpdateScheduleAssignment(baseOrdNo);
//      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
//      ordMainChangedDataInfo = ordMainDao.selectByOrdNo(baseOrdNo);
//      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
//      //add FNSI redmine 6706 劉祥霖 start
//      boolean afterScheduleAssignmentMediInfo=false;
//      String indMediInfo=baseordMain.getIndMediInfo();
//      if(indMediInfo!=null&&!"".equals(indMediInfo)&&!"[]".equals(indMediInfo)){
//        afterScheduleAssignmentMediInfo=true;
//      }
//      //add FNSI redmine 6706 劉祥霖 end
//      // 毛 ログ改善対応 Add
//      eventLogMessage.setFacilityCd(baseordMain.getFacilityCd());
//      eventLogMessage.setLogMessage("スケジュール割り当て処理：/scheduleassignment/" +baseOrdNo + "/"  + ordNo + "/"  + rstInputClass);
//      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//
//      // 割り当て対象の治療記録の治療状態判定
//      String rstDialysisState = baseordMain.getRstDialysisState() == null ? "0" : baseordMain.getRstDialysisState();
//
//      // add FNSI-？？？？患者割り当て 徐 start
//      // 割り当てデータがrst_dialysis_state=1の場合は条件送信キャンセル処理を実行する。
//      if (rstDialysisState.equals("1")) {
//        // 毛 ログ改善対応 Add
//        eventLogMessage.setLogMessage("スケジュール割り当て処理⇒条件送信キャンセル開始");
//        logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//        // 条件送信キャンセルが必要ならば実行する
//        sendConditionCancelService.doCancel(baseordMain.getFacilityCd(),
//          Long.valueOf((long)baseordMain.getRstBedCd()), baseordMain.getOrdNo());
//        // 毛 ログ改善対応 Add
//        eventLogMessage.setLogMessage("スケジュール割り当て処理⇒条件送信キャンセル終了");
//        logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//      }
//      // add FNSI-？？？？患者割り当て 徐 end
//
//      // del FNSI-？？？？患者割り当て 陳 start
//      //if ( rstDialysisState.equals("0")) {
//      // del FNSI-？？？？患者割り当て 陳 end
//
//      // 未送信
//
//      // 毛 ログ改善対応 Add
//      eventLogMessage.setLogMessage("スケジュール割り当て処理⇒指示展開を実施開始");
//      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//      // 指示展開を実施
//      ResponseEntity<String> ret = webApiCallCommonUtil.sendCondResultOnly(baseOrdNo);
//
//      if (ret.getStatusCode() != HttpStatus.OK) {
//        // 実績展開失敗
//        eventLogMessage.setLogMessage("スケジュール割り当て処理⇒指示展開を実施失敗:" + ret.getBody());
//        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//      }
//      // del FNSI-？？？？患者割り当て 陳 start
//      //}
//      // del FNSI-？？？？患者割り当て 陳 start
//
//      // add FNSI-？？？？患者割り当て 陳 start
//      // ScheduleAssignmentUpdateResponse r = scheduleAssignmentService.scheduleAssignment(baseOrdNo, ordNo);
//      short rstClass = (short) rstInputClass;
//      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
//      //// mod FNSI-外部連携api呼び出対応 陳 start
//      ////ScheduleAssignmentUpdateResponse r = scheduleAssignmentService.scheduleAssignment(baseOrdNo, ordNo, rstClass);
//      r = scheduleAssignmentService.scheduleAssignment(baseOrdNo, ordNo, rstClass, flg);
//      ordMainChangeBeforeDataInfo = ordMainDao.selectByOrdNo(baseOrdNo);
//      //// mod FNSI-外部連携api呼び出対応 陳 end
//      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
//      // add FNSI-？？？？患者割り当て 陳 end
//
//      //add FNSI redmine 6706 劉祥霖　start
//      //割り当て後、投薬の通知を追加する
//      OrdMainUpdateForScheduleAssignment baseordMainData = ordMainDao.selectByOrdNoUpdateScheduleAssignment(baseOrdNo);
//      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
//      //String facilityCd=baseordMainData.getFacilityCd();
//      facilityCd = baseordMainData.getFacilityCd();
//      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
//      //投薬を取得
//      String rstMediInfoArray = baseordMainData.getRstMediInfo();
//      if (rstMediInfoArray!=null&&!"[]".equals(rstMediInfoArray)) {
//        ObjectMapper mapper = new ObjectMapper();
//        List<ReceiveRstMediInfoDto> tempReceiveRstMediInfoDtos = mapper.readValue(rstMediInfoArray, new TypeReference<List<ReceiveRstMediInfoDto>>() {
//        });
//        for (ReceiveRstMediInfoDto element : tempReceiveRstMediInfoDtos) {
//          //未実施判定
//          if (element.getEffectFlg() == null || (element.getEffectFlg() != null && "0".equals(element.getEffectFlg()))) {
//            //治療中の場合、透析前と透析中の投与タイミングを判定
//            if (baseordMainData.getRstDialysisState().equals("3")) {
//              MstMedicateTiming mstMedicateTiming = mstMedicateTimingDao.selectByCd(facilityCd, element.getTimingCd());
//              if (mstMedicateTiming != null && "1".equals(mstMedicateTiming.getIsAlert())) {
//                if (mstMedicateTiming.getDialysisProgressCd() != null && "001".equals(mstMedicateTiming.getDialysisProgressCd())) {
//                  PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(baseordMainData.getPatId());
//                  String medicineName=element.getName();
//                  if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
//                    Integer cd = element.getCd();
//                    Integer medicineType = element.getMedicineType().intValue();
//                    //取得したコードを元に薬剤情報から名称を取得(DBから)
//                    if (cd != null && medicineType != null) {
//                      Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
//                        facilityCd,
//                        medicineType,
//                        cd
//                      );
//                      medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
//                    }
//                  }
//                  JSONObject replaceData = new JSONObject();
//                  replaceData.put("BEDNAME", baseordMainData.getRstBedName());
//                  replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
//                  replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
//                  replaceData.put("ORDNO", String.valueOf(baseOrdNo));
//                  replaceData.put("PATID", baseordMainData.getPatId().toString());
//                  replaceData.put("FACILITYCD", facilityCd);
//                  replaceData.put("MEDICINENAME", medicineName);
//                  try {
//                    webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
//                  } catch (URISyntaxException e) {
//                    e.printStackTrace();
//                  }
//                } else if (mstMedicateTiming.getDialysisProgressCd() != null && "002".equals(mstMedicateTiming.getDialysisProgressCd())) {
//                  if (mstMedicateTiming.getAlertTime() != null) {
//                    if (baseordMainData.getRstStartDate() != null) {
//                      long addAlertTime = mstMedicateTiming.getAlertTime() * 60 * 1000;
//                      long compareTime = baseordMainData.getRstStartDate().getTime() + addAlertTime;
//                      if (System.currentTimeMillis() > compareTime) {
//                        PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(baseordMainData.getPatId());
//                        String medicineName=element.getName();
//                        if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
//                          Integer cd = element.getCd();
//                          Integer medicineType = element.getMedicineType().intValue();
//                          //取得したコードを元に薬剤情報から名称を取得(DBから)
//                          if (cd != null && medicineType != null) {
//                            Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
//                              facilityCd,
//                              medicineType,
//                              cd
//                            );
//                            medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
//                          }
//                        }
//                        JSONObject replaceData = new JSONObject();
//                        replaceData.put("BEDNAME", baseordMainData.getRstBedName());
//                        replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
//                        replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
//                        replaceData.put("ORDNO", String.valueOf(baseOrdNo));
//                        replaceData.put("PATID", baseordMainData.getPatId().toString());
//                        replaceData.put("FACILITYCD", facilityCd);
//                        replaceData.put("MEDICINENAME", medicineName);
//                        try {
//                          webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
//                        } catch (URISyntaxException e) {
//                          e.printStackTrace();
//                        }
//                      }
//                    }
//                  }
//                }
//              }
//            }
//            //前体重未測定の場合、全部の未実施の投薬を通知発送
//            else if (baseordMainData.getRstDialysisState().equals("4")) {
//              MstMedicateTiming mstMedicateTiming = mstMedicateTimingDao.selectByCd(facilityCd, element.getTimingCd());
//              if (mstMedicateTiming != null && "1".equals(mstMedicateTiming.getIsAlert())) {
//                PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(baseordMainData.getPatId());
//                String medicineName=element.getName();
//                if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
//                  Integer cd = element.getCd();
//                  Integer medicineType = element.getMedicineType().intValue();
//                  //取得したコードを元に薬剤情報から名称を取得(DBから)
//                  if (cd != null && medicineType != null) {
//                    Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
//                      facilityCd,
//                      medicineType,
//                      cd
//                    );
//                    medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
//                  }
//                }
//                JSONObject replaceData = new JSONObject();
//                replaceData.put("BEDNAME", baseordMainData.getRstBedName());
//                replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
//                replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
//                replaceData.put("ORDNO", String.valueOf(baseOrdNo));
//                replaceData.put("PATID", baseordMainData.getPatId().toString());
//                replaceData.put("FACILITYCD", facilityCd);
//                replaceData.put("MEDICINENAME", medicineName);
//                try {
//                  webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
//                } catch (URISyntaxException e) {
//                  e.printStackTrace();
//                }
//              }
//            }
//            //後体重測定済みの場合、患者がベッドにいるかの判定をして、全部の未実施の投薬を通知発送
//            else if (baseordMainData.getRstDialysisState().equals("5")) {
//              List<MntMachineState> mntMachineStates = mntMachineStateDao.selectByBedCd(baseordMainData.getRstBedCd().longValue());
//              if(mntMachineStates.get(0).getOrdNo()==baseOrdNo){
//                MstMedicateTiming mstMedicateTiming = mstMedicateTimingDao.selectByCd(facilityCd, element.getTimingCd());
//                if (mstMedicateTiming != null && "1".equals(mstMedicateTiming.getIsAlert())) {
//                  PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(baseordMainData.getPatId());
//                  String medicineName=element.getName();
//                  if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
//                    Integer cd = element.getCd();
//                    Integer medicineType = element.getMedicineType().intValue();
//                    //取得したコードを元に薬剤情報から名称を取得(DBから)
//                    if (cd != null && medicineType != null) {
//                      Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
//                        facilityCd,
//                        medicineType,
//                        cd
//                      );
//                      medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
//                    }
//                  }
//                  JSONObject replaceData = new JSONObject();
//                  replaceData.put("BEDNAME", baseordMainData.getRstBedName());
//                  replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
//                  replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
//                  replaceData.put("ORDNO", String.valueOf(baseOrdNo));
//                  replaceData.put("PATID", baseordMainData.getPatId().toString());
//                  replaceData.put("FACILITYCD", facilityCd);
//                  replaceData.put("MEDICINENAME", medicineName);
//                  try {
//                    webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
//                  } catch (URISyntaxException e) {
//                    e.printStackTrace();
//                  }
//                }
//              }
//            }
//          }
//        }
//      }
//      //add FNSI redmine 6706 劉祥霖　end
//      // add 9828 by kangjie 20240417 start
//      checkListService.indApprovedForStatusMap(baseOrdNo);
//      // add 9828 by kangjie 20240417 end
//      // 毛 ログ改善対応 Add
//      eventLogMessage.setLogMessage("スケジュール割り当て処理正常終了：" + baseOrdNo + "/"  + ordNo + "/"  + rstInputClass);
//      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//
//      //mod FNSI redmine 6706 劉祥霖 追加再修正：？？？？患者予定部分に投薬がないと通知しない end
//      r.sendMediNoticeFlag=afterScheduleAssignmentMediInfo;
//      //add FNSI redmine 6706 劉祥霖 追加再修正：？？？？患者予定部分に投薬がないと通知しない end
//
//      //add 9480 治療状況(スケジュール割り当て処理) gjn start
//      threadExector.execute(new Runnable() {
//        @Override
//        public void run() {
//          // 非同期実行チェック計算
//          // #10553 Mod Change Assignment's param to the correct one
//          webApiCallCommonUtil.doAutoCalculation(baseOrdNo);
//        }
//      });
//      //add 9480 治療状況(スケジュール割り当て処理) gjn end
//
//      // add 9324 スケジュール割り当て ord_checklistの変更 gjn start
//      //取得？？？患者的ord_checklist数据
//      List<OrdChecklist> checklistsQuestion = checkListService.getOrdCheckListByOrdNO(ordNo);
//      //取得被merge的患者的ord_main对应的ord_checklist数据
//      List<OrdChecklist> checklistsMargeOld = checkListService.getOrdCheckListByOrdNO(baseOrdNo);
//      //根据？？？患者的checklists，反向生成当时的mst_checklistd的数据,作成JsonNode格式返回
//      //割り当取当前mst的数据
//      // 最新のチェックリストマスタを取得
//      List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), baseordMain.getFacilityCd(), "0");
//      MstChecklist nowMstChecklist = mstChecklist.get(0);
//      String strSetting = nowMstChecklist.getChecklistSettings();
//      ObjectMapper map = new ObjectMapper();
//      JsonNode node = map.readTree(strSetting);
////      Map<String, JsonNode> jsonNodeMap = checkListService.makeMstChecklistByOrdChecklist(checklistsMargeOld);
////      String checklistCd = jsonNodeMap.keySet().size()==1 ? jsonNodeMap.keySet().iterator().next() : null;
//      // marge后的治療情報を取得
//      OrdMainForCheckListSchedule ordMains = ordMainDao.selectByOrdNoChecklist(baseOrdNo);
//      //根据merge后的ord_main数据和反推出来的mst_checklistd的数据，调用共通，生成新的ord_checklist数据
//      List<OrdChecklist> newMakeList = checkListService.getRegisterChecklistRst(ordMains, node, nowMstChecklist.getChecklistCd(), true);
//
//      //被marge患者的ord_checklist与新生成的ord_checklist进行marge,checklistsMargeOld作为base
//      checkListService.margeOrdCheckListInsCheckLeft(checklistsMargeOld, newMakeList);
//
//      //再将？？？患者有被check过的状态marge给checklistsMargeOld后的数据
//      //取最新ord_checklist
//      List<OrdChecklist> checklistsMargeAfter = checkListService.getOrdCheckListByOrdNO(baseOrdNo);
//      checkListService.margeOrdCheckListInsCheckRight(checklistsQuestion, checklistsMargeAfter, true);
//
//      // add 9324 スケジュール割り当て ord_checklistの変更 gjn end
//
//      // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
////      return new ResponseEntity<>(r, HttpStatus.OK);
//      // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      ordMainChangedDataInfo = ordMainDao.selectByOrdNo(baseOrdNo);
      r = scheduleAssignmentService.scheduleAssignment(baseOrdNo, ordNo, rstInputClass, flg);
      ordMainChangeBeforeDataInfo = ordMainDao.selectByOrdNo(baseOrdNo);
// mod 11454 時間外加算自動処理が機能していない(実装ロジックが同一トランザクションにするために、ScheduleAssignmentServiceImpl.javaのscheduleAssignmentメソッドに移動する) zkm end

    } catch (Exception e) {
      eventLogMessage.setLogMessage("スケジュール割り当て処理異常終了：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      r = new ScheduleAssignmentUpdateResponse();
      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
      r.errorMessage = e.getMessage();

      return new ResponseEntity<>(r, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    // 連携関連呼出
    if(ordMainChangeBeforeDataInfo.getIndKurCd() != ordMainChangedDataInfo.getIndKurCd()){
      try {
        String actionMode = null;
        // 治療状況リストの場合
        if ("list".equals(flg)) {
          actionMode = "STATUS_LIST_QUESTION_PAT";
        } else {
          actionMode = "STATUS_MAP_QUESTION_PAT";
        }

        Long patId = ordMainChangeBeforeDataInfo.getPatId();
        PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
        String hospPatId = patPersonalMain.getHosp_pat_id();
        Long updUserId = ordMainChangeBeforeDataInfo.getUpUserId();

        Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap = new HashMap<>();
        if(ordMainChangeBeforeDataInfo.getIndKurCd() == 0){
          // 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベント治療日のリスト
          journalCreatePayloadService.addToBeCEventTreatDate(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, ordMainChangeBeforeDataInfo.getTreatDate(), ordMainChangeBeforeDataInfo.getIndKurCd());
        } else {
          // 治療予定が　変更した場合、発行すべきCイベント治療日のリスト
          journalCreatePayloadService.addToBeUEventTreatDate(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, ordMainChangeBeforeDataInfo.getTreatDate(), ordMainChangeBeforeDataInfo.getIndKurCd());
        }
        List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayloadForToBeEventTreatDate(journalEventLinkByPatListMap, updUserId, actionMode);
        journalList = journalList.stream().filter(o -> o.getOpeCd() != null).collect(Collectors.toList());
        if (!org.apache.commons.collections.CollectionUtils.isEmpty(journalList)) {
          journalService.callCreateJournalForCtrNo(journalList);
        }
      } catch (Exception e) {
        //エラー
        eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      }
    }

    return new ResponseEntity<>(r, HttpStatus.OK);
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

  }

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }
}
