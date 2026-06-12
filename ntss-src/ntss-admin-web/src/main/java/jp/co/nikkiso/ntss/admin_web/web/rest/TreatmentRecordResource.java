package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.core.JacksonException;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import tools.jackson.databind.ObjectMapper;
import com.google.common.base.Objects;
import com.google.common.base.Strings;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
//add FNSI-redmine6060　再修正 劉祥霖 start
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
//add FNSI-redmine6060　再修正 劉祥霖 end
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.MODULE_NAME;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.RecirculationRate;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.TreatmentRecordSummary;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.VitalMonitorData;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordMonitorService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordRoundService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordSettingService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordAddition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordCondition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordDeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordEquipInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMediInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordRoundsInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordSetting;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVitalMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordWeight;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvSet;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentRecordReportInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.aop.framework.AopProxyUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.stream.Collectors;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Authority;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Authority.RST_EDIT;
import static jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Authority.RST_PEDIT;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * 治療記録画面のResourceクラス.
 */
@RestController
@RequestMapping(Uri.TREATMENT_RECORD)
@PreAuthorize("isAuthenticated()")
public class TreatmentRecordResource {
  @Autowired
  private FacilityAccessService facilityAccessService;

  //add FNSI-redmine6060　再修正 劉祥霖 start
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  //add FNSI-redmine6060　再修正 劉祥霖 end

  /**
   * イベントログファクトリー.
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /**
   * 治療記録Service.
   */
  @Autowired
  private TreatmentRecordService treatmentRecordService;
  //add 6832 デグレ】治療記録における特殊血液浄化回数が不正 赵 start
  /* del by songqingyang  2023-02-01 [CodeOptimization]  start */
//  @Autowired
//  private PatMainDao patMainDao;
  /* del by songqingyang  2023-02-01 [CodeOptimization]  end */
  //add 6832 デグレ】治療記録における特殊血液浄化回数が不正 赵 end
  /**
   * 治療記録（モニタ）Service.
   */
  @Autowired
  private TreatmentRecordMonitorService treatmentRecordMonitorService;

  /**
   * 治療記録(装置設定)Service.
   */
  @Autowired
  private TreatmentRecordSettingService treatmentRecordSettingService;

  /**
   * 治療記録(回診記録)Service.
   */
  @Autowired
  private TreatmentRecordRoundService treatmentRecordRoundService;

  /**
   * 条件送信キャンセルService.
   */
  @Autowired
  private SendConditionCancelService sendConditionCancelService ;

  /**
   * デバイスエッジResource.
   */
  @Autowired
  DeviceEdgeOrderResource deviceEdgeOrderResource;

  /**
   * 装置マスタDao.
   */
  @Autowired
  MstMachineDao mstMachineDao;

  // add redmain #4822 鄧シン start
  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;
  // add redmain #4822 鄧シン end

  /**
   * ログ出力Service.
   */
  @Autowired
  LogService logService;

  //add FNSI内容修正 外部Api調用 房 start
  @Autowired
  OrdMainService ordMainService;
  //add 6832 デグレ】治療記録における特殊血液浄化回数が不正 赵 start
  @Autowired
  private TreatmentRecordDao recordDao;
  //add 6832 デグレ】治療記録における特殊血液浄化回数が不正 赵 end

  /* del by songqingyang  2023-02-01 [CodeOptimization]  start */
//  @Value("${ntss.admin-web.device-edge.url}")
//  private String deviceEdgeUrl;
  /* del by songqingyang  2023-02-01 [CodeOptimization]  end */
  //add FNSI内容修正 外部Api調用 房 end

  //add FNSI-redmine5628 fang start
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  //add FNSI-redmine5628 fang end
  //add FNSI-7528 劉全航 start
  @Value("${ntss.admin-web.coop-api.url}")
  private String coopApi;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
  @Value("${ntss.admin-web.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.admin-web.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  //add FNSI-7528 劉全航 end

  //9480 モニタデータ,前血压，后血压数据变更diff gjn start
  /**
   * モニタデータのDaoインタフェース.
   */
  @Autowired
  private MniMonitorDao mniMonitorDao;

  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExector;
  //9480 モニタデータ,前血压，后血压数据变更diff gjn end

  /**
   * 治療記録（治療概要）取得.
   *
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（治療概要）データのResponse
   */
  @GetMapping("/{ord_no}/summary")
  public ResponseEntity<?> getTreatmentRecordSummary(
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record summary : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（治療概要）の取得
    TreatmentRecordSummary response = treatmentRecordService.getTreatmentRecordSummary(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（実績情報）取得.
   *
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（実績情報）データのResponse
   */
  @GetMapping("/{ord_no}/result")
  public ResponseEntity<?> getTreatmentRecordResult(
      @PathVariable("ord_no") Long ordNo,
      @RequestParam(required = false) Long selectedPatId,
      @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record result : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（実績情報）の取得
    //mod 9694 未登録患者に医療材料を追加できない zy start
    //TreatmentRecordResult response = treatmentRecordService.getTreatmentRecordResult(ordNo);
    TreatmentRecordResult response = null;
    try {
      response = treatmentRecordService.getTreatmentRecordResult(ordNo);
    } catch (NotExistException e) {
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
    }
    //mod 9694 未登録患者に医療材料を追加できない zy end

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  /**
   * 治療記録（死活監視ステータス）取得.
   * @param deviceEdgeNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（死活監視ステータス）データのResponse
   */
  @GetMapping("/monistatus/{deviceEdgeNo}")
  public ResponseEntity<?> getmonistatus(
    @PathVariable("deviceEdgeNo") Long deviceEdgeNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, ntssUser.getFacilityCd(), selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record monistatus : ");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（死活監視ステータス）の取得
    String response = treatmentRecordService.getmonistatus(ntssUser.getFacilityCd(),deviceEdgeNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（実績情報）更新.
   *
   * @param request 治療記録（実績情報）データ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/result")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<?> updateTreatmentRecordResult(
    @PathVariable("ord_no") Long ordNo,
    @Valid @RequestBody TreatmentRecordResult request,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    /* modify by songqingyang  2023-02-01 [CodeOptimization]  start */
    //mod 9480 治療記録（実績情報）更新. guan start
    //取出し修正前の実治療開始時間と実治療終了時間
    OrdMain ordMain = ordMainService.selectByOrdNo(ordNo);
    /* modify by chamaojia 2024-05-10 [10573] processing of adding null values --start */
    Timestamp ini_startDate = ordMain.getRstStartDate() == null ? new Timestamp(0) : ordMain.getRstStartDate();
    Timestamp ini_endDate = ordMain.getRstEndDate() == null ? new Timestamp(0) : ordMain.getRstEndDate();
    /* modify by chamaojia 2024-05-10 [10573] processing of adding null values --end */
    ResponseEntity<?> rs = treatmentRecordService.updateTreatmentRecordResult(ordNo, request, ntssUser);

    boolean countIs = false;
    //更新前透析回数
    Integer ini_drc = ordMain.getRstDialysisCnt();
    //更新後透析回数
    Integer up_drc = request.getRstDialysisCnt();
    if (ini_drc != up_drc) {
      countIs = true;
    }
    /* modify by chamaojia 2024-05-10 [10573] processing of adding null values --start */
    Timestamp up_startDate = request.getRstStartDate() == null ? new Timestamp(0) : request.getRstStartDate();
    Timestamp up_endDate = request.getRstEndDate() == null ? new Timestamp(0) : request.getRstEndDate();
    /* modify by chamaojia 2024-05-10 [10573] processing of adding null values --end */
    //修正前の実際の治療開始時間と修正前の実際の治療終了時間を判断するには、修正後の実際の治療開始時間と実際の治療終了時間のいずれかと異なる場合は検査計算の結果を更新する必要がある
    if (!up_startDate.equals(ini_startDate) || !up_endDate.equals(ini_endDate) || countIs) {
      threadExector.execute(new Runnable() {
        @Override
        public void run() {
          // 非同期実行チェック計算
          webApiCallCommonUtil.doAutoCalculation(ordNo);
        }
      });
    }
    //mod 9480 治療記録（実績情報）更新. guan end
    return rs;
  }

  /**
   * 治療記録（実績情報）更新.
   * ※引数で与えられた{@code processType}により、治療条件も更新する.
   *
   * @param request 治療記録（実績情報）データ
   * @param processType 処理区分
   *                    ※治療方法を変更された場合に治療条件を変更する為の処理区分
   *                    0 : 何もしない
   *                    1 : 補液に透析液をセット
   *                    2 : 治療方法マスタの条件設定に応じて対象外のものをnullにする。
   *                    3 : 補液関連を全てnullにする。
   *                    4 : 補液、補液量、補液使用数、補液速度をnullにする。
   *                    5 : 補液、補液量、補液使用数、補液速度をnullにする。(補液温度と補液選択は設定されているままとする。)
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/{process_type}/result_with_condition")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<?> updateTreatmentRecordResultWithCondition(
    @PathVariable("ord_no") Long ordNo,
    @Valid @RequestBody TreatmentRecordResult request,
    @PathVariable("process_type") int processType,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put treatment record result with condition : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（実績情報）の更新
    treatmentRecordService.updateTreatmentRecordResultWithCondition(ordNo, request, processType, ntssUser.getUserId());
    //add 9324 治療記録−実情報変更で治療法を修正した場合ord）checklistに変更が必要かどうかを判定する gjn start
    // 処理区分(processType)==0 の場合、何もしないのでリターン
    if (processType != 0) {
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATMENT_METHODS_CHANG, ordNoList);
    }
    //add 9324 治療記録−実情報変更で治療法を修正した場合ord）checklistに変更が必要かどうかを判定する gjn end
    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * 治療記録（投与薬剤情報）取得
   *
   * @param ordNo オーダ番号
   * @return
   */
  @GetMapping("/{ord_no}/medi_info")
  public ResponseEntity<TreatmentRecordMediInfo> getTreatmentRecordMediInfo(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    eventLoggerFactory.getLogger(ntssUser.getFacilityCd(), LogClass.APP).info(new EventLogMessage(
      ntssUser.getFacilityCd()
      , ntssUser.getUserId().toString()
      , "クライアントIP"
      , "セッションID"
      , "デバイスエッジNo"
      , "デバイスエッジ製造番号"
      , "型式"
      , "型式コード"
      , "EC2識別"
      , MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.REMS
      , "006"
      , "内部患者ID"
      , "SQL名"
      , "治療記録（投与薬剤）取得API"
      , "対応内容: 特になし"
      , this.getClass().getName(),
      ""
    ));

    TreatmentRecordMediInfo mediInfo = treatmentRecordService.getTreatmentRecordMediInfo(ordNo);
    return new ResponseEntity<>(mediInfo, HttpStatus.OK);
  }

  /**
   * 治療記録（投与薬剤情報）更新.
   *
   * @param request 治療記録（投与薬剤情報）データ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/medi_info")
  public ResponseEntity<?> updateTreatmentRecordMediInfo(
      @PathVariable("ord_no") Long ordNo,
      @Valid @RequestBody TreatmentRecordMediInfo request,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put treatment record mediInfo : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    //mod FNSI修正401対応 房 start
    // 治療記録（投与薬剤情報）の更新
    try {
      treatmentRecordService.updateCheckListMediInfo(ordNo, request, ntssUser.getFacilityCd());
      //add 9324 治療記録（投与薬剤情報）更新 gjn start
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_MEDICINE_UPDATE, ordNoList);
      //add 9324 治療記録（投与薬剤情報）更新 gjn end
    } catch (IOException e) {
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    }
    //mod FNSI修正401対応 房 end

    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * MODIFY_SEND_CLASS取得.
   *
   * @param facilityCd 施設コード
   * @param ntssUser NTSS認証ユーザ
   * @return MODIFY_SEND_CLASSデータのResponse
   */
  @GetMapping("/{facilityCd}/sch-send-class")
  public ResponseEntity<?> getCoopIniSchModifySendClass(
      @PathVariable("facilityCd") String facilityCd,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get DIALYSISSCHESEND MODIFY_SEND_CLASS facilityCd : "+ facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // MODIFY_SEND_CLASSの取得
    Integer response = treatmentRecordService.getCoopIniSchModifySendClass(facilityCd);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（治療条件）取得.
   *
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（治療条件）データのResponse
   */
  @GetMapping("/{ord_no}/condition")
  public ResponseEntity<?> getTreatmentRecordCondition(
      @PathVariable("ord_no") Long ordNo,
      @RequestParam(required = false) Long selectedPatId,
      @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record condition : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（治療条件）の取得
    TreatmentRecordCondition response = treatmentRecordService.getTreatmentRecordCondition(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（治療条件）更新.
   *
   * @param request 治療記録（治療条件）データ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/condition")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<?> updateTreatmentRecordCondition(
      @PathVariable("ord_no") Long ordNo,
      @Valid @RequestBody TreatmentRecordCondition request,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put treatment record condition : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // 治療記録（治療条件）の更新
    //mod FNSI修正401対応 房 start
    try {
      // add #11471 ord_mian操作時の治療モードデータの登録 関 start
      TreatmentRecordReportInfo treatmentRecordReportInfo = treatmentRecordService.getTreatmentRecordReportInfoByOrdNo(ordNo);
      if (treatmentRecordReportInfo != null && treatmentRecordReportInfo.getTreatmentConditionSetting() != null) {
        JSONArray ctlGroups = new JSONArray(treatmentRecordReportInfo.getTreatmentConditionSetting());
        JSONObject rstCondInfo = new JSONObject(request.getRstCondInfo());
        if (rstCondInfo == null) {
          rstCondInfo = new JSONObject();
        }
        for (int i = 0; i < ctlGroups.length(); i++) {
          JSONObject group = ctlGroups.getJSONObject(i);
          if (group == null || !group.has("items")) {
            continue;
          }
          JSONArray items = group.getJSONArray("items");

          for (int j = 0; j < items.length(); j++) {
            JSONObject item = items.getJSONObject(j);
            if (item == null) {
              continue;
            }
            String ctlNo = item.getString("ctl_no");
            String isUse = item.getString("is_use");

            if (!"0".equals(isUse) || !rstCondInfo.has(ctlNo)) {
              continue;
            }

            JSONObject ctlValue = rstCondInfo.optJSONObject(ctlNo);

            if (ctlValue != null && ctlValue.isNull("value")) {
              rstCondInfo.remove(ctlNo);
            }
          }
        }
        request.setRstCondInfo(rstCondInfo.toString());
      }
      // add #11471 ord_mian操作時の治療モードデータの登録 関 end

      treatmentRecordService.updateTreatmentRecordCondition(ordNo, request, ntssUser.getFacilityCd());
//    del 8074 【デグレ】ログに誤った利用者が記録される 関 start
//    add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//      ordMainService.updateUseId(ordNo,ntssUser.getUserId());
//    add 8074 【デグレ】ログに誤った利用者が記録される 関  end
//    del 8074 【デグレ】ログに誤った利用者が記録される 関  end
      //add 9324 治療記録（治療条件）更新 gjn start
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_CONDITION_UPDATE, ordNoList);
      //add 9324 治療記録（治療条件）更新 gjn end
    } catch (Exception e) {
      logService.log(LogLevel.DEBUG, eventLogMessage,e.getMessage(), SERVICE_NAME.FNSI, null);
    }
    //mod FNSI修正401対応 房 end

    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * 再循環率取得.
   *
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 再循環率データのResponse
   */
  @GetMapping("/{ord_no}/recirculation-rate")
  public ResponseEntity<?> getRecirculationRate(
      @PathVariable("ord_no") Long ordNo,
      @RequestParam(required = false) Long selectedPatId,
      @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get recirculation rate : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // 再循環率の取得
    List<RecirculationRate> response = treatmentRecordService.getRecirculationRate(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（体重情報）取得.
   *
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（体重情報）データのResponse
   */
  @GetMapping("/{ord_no}/weight")
  public ResponseEntity<?> getTreatmentRecordWeight(
      @PathVariable("ord_no") Long ordNo,
      @RequestParam(required = false) Long selectedPatId,
      @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record weight : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（体重情報）の取得
    TreatmentRecordWeight response = treatmentRecordService.getTreatmentRecordWeight(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（体重情報）更新.
   *
   * @param request 治療記録（体重情報）データ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/weight")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<?> updateTreatmentRecordWeight(
    @PathVariable("ord_no") Long ordNo,
    @Valid @RequestBody TreatmentRecordWeight request,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put treatment record weight : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // add FNSI-redmine6122 fang start
    request.setUpUserId(ntssUser.getUserId());
    // add FNSI-redmine6122 fang end

    //9480 治療記録（体重情報）更新,检查计算 gjn start
    //変更前に得られた体重情報の前体重と後体重値を取り出しておく
    String ini_weight_before = "";
    String ini_weight_after = "";
    String ini_water_removal_rst = "";
    String ini_add_water_total = "";
    TreatmentRecordWeight treatmentRecordWeight = treatmentRecordService.getTreatmentRecordWeight(ordNo);
    String rstWeightInfo = treatmentRecordWeight.getRstWeightInfo();
    /* modify by chamaojia 2024-07-10 [10774] Add null value judgment for 【rstWeightInfo】 --start */
    if (!ObjectUtils.isEmpty(rstWeightInfo)) {
      JSONObject jsonObject = new JSONObject(rstWeightInfo);
      if (jsonObject.has("weight_before")) {
        ini_weight_before = String.valueOf(jsonObject.get("weight_before"));
      }
      if (jsonObject.has("weight_after")) {
        ini_weight_after = String.valueOf(jsonObject.get("weight_after"));
      }
      if (jsonObject.has("water_removal_rst")) {
        ini_water_removal_rst = String.valueOf(jsonObject.get("water_removal_rst"));
      }
      if (jsonObject.has("add_water_total")) {
        ini_add_water_total = String.valueOf(jsonObject.get("add_water_total"));
      }
    }
    /* modify by chamaojia 2024-07-10 [10774] Add null value judgment for 【rstWeightInfo】 --end */
    // 治療記録（体重情報）更新
    /* modify by chamaojia 2024-07-05 [10774] Add handling of JacksonException exceptions --start */
    try {
      treatmentRecordService.updateTreatmentRecordWeight(ordNo, request);
    } catch (JacksonException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessageNew = new EventLogMessage();
      if (ntssUser != null && !StringUtils.isEmpty(ntssUser.getFacilityCd())) {
        eventLogMessageNew.setFacilityCd(ntssUser.getFacilityCd());
      }
      eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessageNew,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    }
    /* modify by chamaojia 2024-07-05 [10774] Add handling of JacksonException exceptions --end */

    //修正後の前体重と後体重の値を取得する
    String up_weight_before = "";
    String up_weight_after = "";
    String up_water_removal_rst = "";
    String up_add_water_total = "";
    JSONObject request_wei = new JSONObject(request);
    String up_rstWeightInfo = String.valueOf(request_wei.get("rstWeightInfo"));
    JSONObject up_weigh = new JSONObject(up_rstWeightInfo);
    if (up_weigh.has("weight_before")) {
      up_weight_before = String.valueOf(up_weigh.get("weight_before"));
    }
    if (up_weigh.has("weight_after")) {
      up_weight_after = String.valueOf(up_weigh.get("weight_after"));
    }
    if (up_weigh.has("water_removal_rst")) {
      up_water_removal_rst = String.valueOf(up_weigh.get("water_removal_rst"));
    }
    if (up_weigh.has("add_water_total")) {
      up_add_water_total = String.valueOf(up_weigh.get("add_water_total"));
    }
    //前体重と後体重のいずれかが修正されたかどうかを判断する
    if (!up_weight_before.equals(ini_weight_before)
      || !up_weight_after.equals(ini_weight_after)
      || !up_water_removal_rst.equals(ini_water_removal_rst)
      || !up_add_water_total.equals(ini_add_water_total)) {
      threadExector.execute(new Runnable() {
        @Override
        public void run() {
          // 非同期実行チェック計算
          webApiCallCommonUtil.doAutoCalculation(ordNo);
        }
      });
    }
    //9480 治療記録（体重情報）更新,检查计算 gjn end
    // 正常レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * 治療記録（医療材料情報）取得
   *
   * @param ordNo オーダ番号
   * @return
   */
  @GetMapping("/{ord_no}/equip_info")
  public ResponseEntity<TreatmentRecordEquipInfo> getTreatmentRecordEquipInfo(
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record equip_info : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    TreatmentRecordEquipInfo equipInfo = treatmentRecordService.getTreatmentRecordEquipInfo(ordNo);
    return new ResponseEntity<>(equipInfo, HttpStatus.OK);
  }

  /**
   * 治療記録（医療材料情報）更新.
   *
   * @param request 治療記録（医療材料情報）データ
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/equip_info")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<?> updateTreatmentRecordEquipInfo(
      @PathVariable("ord_no") Long ordNo,
      @Valid @RequestBody TreatmentRecordEquipInfo request,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put treatment record equipInfo : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    //mod FNSI修正401対応 房 start
    // 治療記録（医療材料情報）の更新
    try {
      treatmentRecordService.updateCheckListEquipInfo(ordNo, request, ntssUser.getFacilityCd());
      //add 9324 治療記録（医療材料情報）更新 gjn start
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.TREATPLAN_EQUIPMENT_UPDATE, ordNoList);
      //add 9324 治療記録（医療材料情報）更新 gjn end
    } catch (IOException e) {
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.BAD_REQUEST);
    }
    //mod FNSI修正401対応 房 end


    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * 最新オーダ番号取得.
   *
   * @param patId 患者ID
   * @return
   */
  @GetMapping("/{pat_id}/latest-ord-no")
  public ResponseEntity<Long> getLatestOrdNo(
    @PathVariable("pat_id") Long patId,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get latest ord_no : "+ patId);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    Long ordNo = treatmentRecordService.getLatestOrdNo(patId, ntssUser.getFacilityCd());
    return new ResponseEntity<>(ordNo, HttpStatus.OK);
  }

  /**
   * 治療記録（指示コメント）取得.
   *
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（指示コメント）データのResponse
   */
  @GetMapping("/{ord_no}/addition")
  public ResponseEntity<?> getTreatmentRecordAddition(
      @PathVariable("ord_no") Long ordNo,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record addition : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（指示コメント）の取得
    TreatmentRecordAddition response = treatmentRecordService.getTreatmentRecordAddition(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（指示コメント）更新.
   *
   * @param ordNo オーダ番号
   * @param request 治療記録（指示コメント）データのRequest
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/addition")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<?> updateTreatmentRecordAddition(
      @PathVariable("ord_no") Long ordNo,
      @Valid @RequestBody TreatmentRecordAddition request,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put treatment record addition : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（指示コメント）の更新
    treatmentRecordService.updateTreatmentRecordAddition(ordNo, request);

    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * 治療記録（装置モニタデータ(バイタル)情報）取得.
   * @param ordNo オーダ番号
   * @param facilityCd 施設番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（装置モニタデータ(バイタル)情報）データのResponse
   */
  @GetMapping("/{facilityCd}/{ord_no}/vital-monitor")
  public ResponseEntity<?> getTreatmentRecordVitalMonitor(
    @PathVariable("facilityCd") String facilityCd,
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityAndOrdOrSelectedPatShareAccess(ntssUser, facilityCd, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record vital-monitor : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（装置モニタデータ(バイタル)情報）の取得
    List<TreatmentRecordVitalMonitor> response = treatmentRecordService.getTreatmentRecordVitalMonitors(facilityCd, ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（装置モニタデータ(モニタ)情報）取得.
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（装置モニタデータ(モニタ)情報）データのResponse
   */
  @GetMapping("/{ord_no}/monitor")
  public ResponseEntity<?> getTreatmentRecordMonitor(
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record monitor : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（装置モニタデータ(モニタ)情報）の取得
    List<TreatmentRecordMonitor> response = treatmentRecordMonitorService.getTreatmentRecordMonitors(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（設定値読み込み履歴情報）取得.
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（設定値読み込み履歴情報）データのResponse
   */
  @GetMapping("/{ord_no}/setting")
  public ResponseEntity<List<TreatmentRecordSetting>> getTreatmentRecordSetting(
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record setting : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（設定値読み込み履歴情報）の取得
    final List<TreatmentRecordSetting> response = treatmentRecordSettingService.getOrdTreatConditionByOrdNo(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（装置設定情報）取得.
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 治療記録（装置設定情報）データのResponse
   */
  @GetMapping("/{ord_no}/rst-device-set-info")
  public ResponseEntity<TreatmentRecordDeviceSetInfo> getTreatmentRecordDeviceSetInfo(
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record device-set-info : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（装置設定）の取得
    final TreatmentRecordDeviceSetInfo response =
      treatmentRecordSettingService.getTreatmentRecordDeviceSetInfoByOrdNo(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（回診記録情報）取得.
   * @param ordNo オーダ番号
   * @param ntssUser NTSS認証ユーザ
   * @return 回診記録（回診記録情報）データのResponse
   */
  @GetMapping("/{ord_no}/rst-rounds-info")
  public ResponseEntity<TreatmentRecordRoundsInfo> getTreatmentRecordRoundsInfo(
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get treatment record rounds-info : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（回診記録情報）の取得
    final TreatmentRecordRoundsInfo response =
      treatmentRecordRoundService.getTreatmentRecordRoundsInfoByOrdNo(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療記録（回診記録情報）更新.
   *
   * @param ordNo オーダ番号
   * @param request 治療記録（回診記録情報）データのRequest
   * @param ntssUser NTSS認証ユーザ
   * @return
   */
  @PutMapping("/{ord_no}/rst-rounds-info")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<?> updateTreatmentRecordRoundsInfo(
      @PathVariable("ord_no") Long ordNo,
      @Valid @RequestBody TreatmentRecordRoundsInfo request,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put treatment record rounds-info : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 治療記録（回診記録情報）の更新
    treatmentRecordRoundService.updateTreatmentRecordRoundsInfo(ordNo, request);
    //9480 治療記録（回診記録情報）更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn start
    //add FNSI-redmine6060 再修正 劉祥霖 start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    //add FNSI-redmine6060 再修正 劉祥霖 end
    //9480 治療記録（回診記録情報）更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn end
    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * 治療記録（バイタル情報）の登録更新.
   * @param ordNo 登録更新するオーダ番号
   * @param request 登録更新するバイタル情報
   * @param ntssUser サインイン情報
   * @return
   */
  @PutMapping("/{ord_no}/vital-monitor-data")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.RST_EDIT + "') or hasAuthority('" + AdminWebConstant.Authority.RST_PEDIT + "')")
  public ResponseEntity<?> updateTreatmentRecordVitalForMniMonitor(
    @PathVariable("ord_no") Long ordNo,
    @Valid @RequestBody VitalMonitorData request,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put treatment record vital for mni_monitor : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    //add 9480 治療記録（バイタル情報）の登録更新包含实际值变更，调用计算接口 gjn start
    String ini_top = "";
    String ini_low = "";
    String ini_avg = "";
    String up_top = "";
    String up_low = "";
    String up_avg = "";
    List<MniMonitor> mniMonitors = request.getVitalData();
    //前血圧、後血圧をマークするためには、対応する装置情報が存在しない限り、新規であることを意味し、再計算する必要があります
    boolean isNull = false;
    for (MniMonitor up_mniMonitor : mniMonitors) {
      // モニタもバイタルもこのインタフェースを呼び出しているため、モニタには血圧データが含まれていない（9183票で血圧データがモニタ画面から削除された）ため、モニタデータに血圧データが含まれているかどうかに基づいて、計算が必要かどうかを判定する基礎となる
      JSONObject monitorDataJson = new JSONObject(up_mniMonitor.getMonitorData());
      if (!monitorDataJson.isEmpty() &&
        !monitorDataJson.has("90") && !monitorDataJson.has("91") && !monitorDataJson.has("92")) {
        isNull = false;
        continue;
      }
      List<Long> bioMoniCtlNoList = new ArrayList<>();
      Long bioMoniCtlNo = up_mniMonitor.getBioMoniCtlNo();
      bioMoniCtlNoList.add(bioMoniCtlNo);
      List<MniMonitor> mniMonitorList = mniMonitorDao.selectByBioMoniCtlNo(bioMoniCtlNoList);
      if (mniMonitorList.size() > 0) {
        MniMonitor ini_mniMonitor = mniMonitorList.get(0);
        String ini_monitorData = ini_mniMonitor.getMonitorData();
        String up_monitorData = up_mniMonitor.getMonitorData();
        //取り出し修正前の最高、最低、平均血圧値
        JSONObject ini_jsonObject;
        if (!StringUtils.isEmpty(ini_monitorData)) {
          ini_jsonObject = new JSONObject(ini_monitorData);
          if (ini_jsonObject.has("90")) { //最高血圧
            ini_top = String.valueOf(ini_jsonObject.get("90"));
          }
          if (ini_jsonObject.has("91")) { //最低血圧
            ini_low = String.valueOf(ini_jsonObject.get("91"));
          }
          if (ini_jsonObject.has("92")) { //平均血圧
            ini_avg = String.valueOf(ini_jsonObject.get("92"));
          }
        }
        //取り出し修正後の最高、最低、平均血圧値
        JSONObject up_jsonObject;
        if (!StringUtils.isEmpty(up_monitorData)) {
          up_jsonObject = new JSONObject(up_monitorData);
          if (up_jsonObject.has("90")) { //最高血圧
            up_top = String.valueOf(up_jsonObject.get("90"));
          }
          if (up_jsonObject.has("91")) { //最低血圧
            up_low = String.valueOf(up_jsonObject.get("91"));
          }
          if (up_jsonObject.has("92")) { //平均血圧
            up_avg = String.valueOf(up_jsonObject.get("92"));
          }
        }
        //最高、最低、平均、異なる値があると更新されると判断し、再計算する
        if (!up_top.equals(ini_top) || !up_low.equals(ini_low) || !up_avg.equals(ini_avg)) {
          isNull = true;
        }
      } else {
        // mniMonitorList長さが0の場合は追加データとして表示され、計算が必要
        isNull = true;
      }
    }
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    // 登録更新処理
    treatmentRecordService.insertOrUpdateTreatmentRecordForMniMonitor(ordNo, request.getVitalData(), ntssUser.getUserId());

    // isNullに基づいて再計算が必要かどうかを判断する
    if (isNull) {
      threadExector.execute(new Runnable() {
        @Override
        public void run() {
          // 非同期実行チェック計算
          webApiCallCommonUtil.doAutoCalculation(ordNo);
        }
      });
    }
    //add 9480 治療記録（バイタル情報）の登録更新包含实际值变更，调用计算接口 gjn end

    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * オーダ番号の実績:治療方法コード(rst_treatment_cd)に該当する治療方法マスタ取得
   * @param ordNo 対象のオーダ番号
   * @param ntssUser 認証ユーザ情報
   * @return 帳票情報のレスポンス
   */
  @GetMapping("/{ord_no}/report-info")
  public ResponseEntity<TreatmentRecordReportInfo> getTreatmentRecordReportInfoByOrdNo(
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get report info by ord_no : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    /* modify by songqingyang  2023-02-01 [CodeOptimization]  start */
    return treatmentRecordService.getTreatmentRecordReportInfoByOrdNoAndNtssUser(ordNo, ntssUser);

//    // 治療記録の透析レポート情報取得
//    TreatmentRecordReportInfo response = treatmentRecordService.getTreatmentRecordReportInfoByOrdNo(ordNo);
//    //add FNSI-redmine4746 房 start
//    OrdMain ordMain = ordMainService.selectByOrdNo(ordNo);
//      // mod 7007【デグレ】患者リストで患者を切り替えてもヘッダーの患者名が切り替わらない 赵 start
//      //if (ordMain.getPatId() == null && response == null) {
//    if (ordMain.getPatId() == null || response == null) {
//      // mod 7007【デグレ】患者リストで患者を切り替えてもヘッダーの患者名が切り替わらない 赵 end
//      response = new TreatmentRecordReportInfo();
//    }
//    //add FNSI-redmine4746 房 end
//
//    // add redmain #4822 鄧シン start
//    if (response.getReportId() == 0){
//      FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ordMain.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
//      // mod redmine-6352 治療実績の治療方法が未登録の場合に治療記録のレポート表示がされない 房 start
//      if (facilitySettingInfo != null) {
//        long reportCd = new Long(facilitySettingInfo.getValue());
//        response.setReportId(reportCd);
//      }
//      // mod redmine-6352 治療実績の治療方法が未登録の場合に治療記録のレポート表示がされない 房 end
//    }
//    // add redmain #4822 鄧シン end
//
//    //add 帳票コード取得修正 房 start
//    // fix FNSI-修正 バーグ 单体 障害票 治療記録 No.19 孫灝 20201204 start
//    if (response != null && response.getReportId() == 0) {
//      // fix FNSI-修正 バーグ 单体 障害票 治療記録 No.19 孫灝 20201204 end
//      //mod FNSI修正redmine4746 房 start
//      List<ReportCds> reportCds = treatmentRecordService.getReportCds("3004", ntssUser.getFacilityCd());
//      //mod FNSI修正redmine4746 房 end
//      long reportCd = 0;
//      List<ReportCds> tempReportCds = reportCds.stream().filter(x->x.vkey == 1).collect(Collectors.toList());
//      if (tempReportCds != null && tempReportCds.size() > 0) {
//        reportCd = tempReportCds.get(0).getValue();
//      } else {
//        tempReportCds = reportCds.stream().filter(x->x.vkey == 2).collect(Collectors.toList());
//        if (tempReportCds != null && tempReportCds.size() > 0) {
//          reportCd = tempReportCds.get(0).getValue();
//        }
//      }
//      if (reportCd != 0) {
//        response.setReportId(reportCd);
//      }
//    }
//    //add 帳票コード取得修正 房 end
//
//    // レスポンス生成
//    return new ResponseEntity<>(response, HttpStatus.OK);
    /* modify by songqingyang  2023-02-01 [CodeOptimization]  end */
  }

  /**
   * 条件送信キャンセルAPIの呼び出し
   * @param facilityCd:施設コード
   * @param bedCd:ベッドコード
   * @param ordNo:オーダ番号
   * @return
   */
  @PostMapping("/cancelSendCond")
  public ResponseEntity<String> cancelSendCond(@RequestBody Map<String, Object> requestBody,
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException, RuntimeException
    {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      String facilityCd1 = (String) requestBody.get("facilityCd");
      if (facilityCd1 != null && !facilityCd1.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "facilityCd1=" + facilityCd1 + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

      HttpStatus status = HttpStatus.OK;
      String retMsg = null ;

      String facilityCd = (String) requestBody.get("facilityCd");
      Long bedCd = Long.valueOf(requestBody.get("bedCd").toString());
      Long ordNo = Long.valueOf(requestBody.get("ordNo").toString());

      //mod FNSI修正401 房 start

      //mod #10412 次患者更新関連全体見直し対応 朴 start
//      // mod #10132 時間外加算処理不正 dengshen start
//      // SendConditionCancelResponse res = sendConditionCancelService.doCancel(facilityCd, bedCd, ordNo, "1");
//      SendConditionCancelResponse res = sendConditionCancelService.cancelSendMessage(facilityCd, bedCd, ordNo, "1");
//      // mod #10132 時間外加算処理不正 dengshen end
      SendConditionCancelResponse res = sendConditionCancelService.doCancel2(facilityCd, bedCd, ordNo);
      //mod #10412 次患者更新関連全体見直し対応 朴 end

      if (res.exMessage != null && res.exMessage.equals("sendSkip")) {
        return new ResponseEntity<>("", status);
      }
      //mod FNSI修正401 房 end

      if(!res.isSuccess)
      {
        retMsg = res.errorMessage;
      }

      try {
        List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, bedCd);
        if (machines.size() > 0) {
          MstMachine machine = machines.get(0);

          DeviceEdgeOrderRequest deviceEdgeOrder = new DeviceEdgeOrderRequest();
          deviceEdgeOrder.setFacilityCd(facilityCd);
          deviceEdgeOrder.setDeviceEdgeNo(machine.getDeviceEdgeNo());
          deviceEdgeOrder.setMachineNo(machine.getMachineNo());
          ResponseEntity<?> deviceEdgeOrderRes = deviceEdgeOrderResource.PostOrderCancelCondition(deviceEdgeOrder, null);
          status = HttpStatus.valueOf(deviceEdgeOrderRes.getStatusCode().value());
          if (status != HttpStatus.OK) {
            retMsg = "条件送信キャンセル通信サーバーへの通知失敗";
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(retMsg);
            logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
          }
        }
      } catch (RuntimeException e) {
        retMsg = "条件送信キャンセル通信サーバーへの通知失敗";
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(retMsg);
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      }

      return new ResponseEntity<>(retMsg, status);
    }


  /**
   * オーダ番号に対応する装置マスタの取得
   * @param ordNo オーダ番号
   * @return 装置マスタデータのResponse
  */
  @GetMapping("/{ord_no}/mst-machine-rst")
  public ResponseEntity<List<MstMachine>> getMstMachineByOrdNoRst(@PathVariable("ord_no") Long ordNo,
                                                                  @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // オーダ番号に対応する装置マスタの取得
    final List<MstMachine> response =
        treatmentRecordService.getMstMachineByOrdNoRst(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 版確定処理.
   *
   * @param ordNo オーダ番号
   * @return 処理成功有無
   */
  //mod FNSI-7531 劉全航 start
//  @PutMapping("/{ord_no}/{confirm}/confirm")
  @PutMapping("/{ord_no}/{updStaffId}/{confirm}/confirm")
  //mod FNSI-7531 劉全航 end
  public ResponseEntity<?> updateTreatmentRecordConfirm(
    @PathVariable("ord_no") Long ordNo,
    @PathVariable("confirm") String confirm,
    //add FNSI-7531 劉全航 start
    @PathVariable("updStaffId") Long updStaffId,
    @AuthenticationPrincipal NtssUser ntssUser
    //add FNSI-7531 劉全航 end
) throws URISyntaxException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
      if (checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "checkOrdMain.getFacilityCd()=" + checkOrdMain.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205",msg_11205_FORBIDDEN,"11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update treatment record confirm : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // 版確定処理
    // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou start
    //add FNSI-7531 劉全航 start
    // treatmentRecordService.updateTreatmentRecordForConfirm(ordNo, confirm, updStaffId);
    treatmentRecordService.updateTreatmentRecordForConfirm(ordNo, confirm);
    //add FNSI-7531 劉全航 end
    // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou end
    //add FNSI-7528 劉全航 start
    JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
    OrdMain ordMain = ordMainService.selectByOrdNo(ordNo);
    String facilityCd = ordMain.getFacilityCd();
    boolean condition = treatmentRecordService.getTreatmentRecordCondition(ordNo, facilityCd);
    if(condition) {
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(ordMain.getPatId());
      payload.setFacilityCd(ordMain.getFacilityCd());
      payload.setPatId(ordMain.getPatId());
      payload.setHospPatId(patPersonalMain.getHosp_pat_id());
      payload.setOrdNo(ordNo);
      payload.setBaseDate(ordMain.getTreatDate());
      payload.setCrud("D");
      payload.setOpeCd("006008");
      payload.setCoopCdIndex("");
      payload.setUserId(updStaffId);
      RestTemplate rt = new RestTemplate();
      URI uri = new URI(coopApi + "/journal/create");
      RequestEntity<JournalCreateRequestPayload> request = RequestEntity
              .post(uri)
              .contentType(MediaType.APPLICATION_JSON)
              /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
              .header(headerKey, headerValue)
              /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
              .body(payload);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<Object> response = rt.exchange(request, Object.class);
      // log start
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.TreatmentRecordResource");
      map.put("methodName", "updateTreatmentRecordConfirm");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
    }
    //add FNSI-7528 劉全航 end
    // レスポンス生成
    return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
  }

  /**
   * オーダ番号に対応する装置状態の取得
   * @param ordNo オーダ番号
   * @return装置状態データのResponse
  */
  @GetMapping("/{facility_cd}/{ord_no}/mnt-machine-state")
  public ResponseEntity<List<MntMachineState>> getMnMachineState(@PathVariable("facility_cd") String facilityCd,
                                                                @PathVariable("ord_no") Long ordNo,
                                                                @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityAndOrdOrSelectedPatShareAccess(ntssUser, facilityCd, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // オーダ番号に対応する装置状態の取得
    final List<MntMachineState> response =
      treatmentRecordService.getMntMachineState(facilityCd, ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 治療方法コードからそれが特殊浄化治療かどうかを取得
   * @param treatmentCd
   * @return
  */
  @GetMapping("/{treatment_cd}/is-purification")
  public ResponseEntity<String> getIsPurification(@PathVariable("treatment_cd") Integer treatmentCd,
                                                  @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, ntssUser.getFacilityCd(), selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // コードに対応する特殊浄化治療方法の取得
    final String response = treatmentRecordService.getIsPurification(treatmentCd);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  //add FNSI内容修正 外部Api調用 房 start
  /**
   * 治療記録（投与薬剤情報）取得
   *
   * @param ordNo オーダ番号
   * @return
   */
  @GetMapping("/{ord_no}/medi_notice")
  public ResponseEntity<String> getTreatmentRecordMediInfoCheck(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // 治療記録（装置設定）の取得
    // オーダ番号に対応する装置マスタの取得
    final List<MstMachine> response =
      treatmentRecordService.getMstMachineByOrdNoRst(ordNo);
    Integer deviceEdgeNo = 0;
    if (response != null && response.size() > 0) {
      deviceEdgeNo = response.get(0).getDeviceEdgeNo();
    }

    String flag = "";
    try {
      ComsvSet comsvSet = treatmentRecordService.selectComsvSet(ntssUser.getFacilityCd(), deviceEdgeNo);
      if (comsvSet != null) {
        flag = comsvSet.getIsNoticeMedi();
      }
    } catch (Exception te) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(te));
      if (ntssUser != null && !StringUtils.isEmpty(ntssUser.getFacilityCd())) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    Integer count = treatmentRecordService.getCheckIsHave(ordNo, ntssUser.getFacilityCd());
    if ("1".equals(flag) && count > 0) {
      return new ResponseEntity<>("true", HttpStatus.OK);
    } else {
      return new ResponseEntity<>("false", HttpStatus.OK);
    }
  }

  /**
   * 版確定チェック
   *
   * @param ordNo オーダ番号
   * @return
   */
  @GetMapping("/{ord_no}/treating_ordno")
  public ResponseEntity<String> getTreatingOrdNo(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    /* modify by songqingyang  2023-02-01 [CodeOptimization]  start */
    return treatmentRecordService.getTreatingOrdNo(ntssUser, ordNo);
//    boolean resultFlag = false;
//    try {
//      List<String> stateList = new ArrayList<String>(Arrays.asList(new String[]{"1", "2", "3", "4"}));
//      final List<MstMachine> response =
//        treatmentRecordService.getMstMachineByOrdNoRst(ordNo);
//      Integer deviceEdgeNo = 0;
//      if (response != null && response.size() > 0) {
//        deviceEdgeNo = response.get(0).getDeviceEdgeNo();
//        ComsvSet comsvSet = treatmentRecordService.selectComsvSet(ntssUser.getFacilityCd(), deviceEdgeNo);
//        if (comsvSet != null && "1".equals(comsvSet.getPatTiming())){
//          stateList.add("5");
//        }
//        Long patId = ordMainService.selectByOrdNo(ordNo).getPatId();
//        List<OrdMain> ordMains = treatmentRecordService.selectTreatingOrdno(patId, stateList);
//        if (ordMains != null && ordMains.size() > 0) {
//          PastOrderNoResponse res = callWebApi(ordMains.get(0).getOrdNo());
//          for (OrdMainOrdNoAndRstStartDate element : res.getLatestOrdList()) {
//            if (Objects.equal(element.getOrdNo(),ordNo)) {
//              resultFlag = true;
//              break;
//            }
//          }
//          if (!resultFlag) {
//            for (OrdMainOrdNoAndRstStartDate element : res.getSameDayOfTheWeekOrdList()) {
//              if (Objects.equal(element.getOrdNo(),ordNo)) {
//                resultFlag = true;
//                break;
//              }
//            }
//          }
//        }
//      }
//    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("オーダー番号から直近と同一曜日で過去の3回分オーダー番号の取得に失敗しました。");
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//      e.printStackTrace();
//      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//    }
//    if (resultFlag) {
//      return new ResponseEntity<>("true", HttpStatus.OK);
//    } else {
//      return new ResponseEntity<>("false", HttpStatus.OK);
//    }
  }

//  private PastOrderNoResponse callWebApi(Long ordNo)
//    throws URISyntaxException, IOException {
//    // 送信URI TODO: ymlから取得するようにする
//    URI uri = new URI(deviceEdgeUrl + "/api/past_ordinfo/" + ordNo);
//    RequestEntity<Void> request = RequestEntity.get(uri).header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").build();
//    RestTemplate restTemplate = new RestTemplate();
//    ResponseEntity<PastOrderNoResponse> result = restTemplate.exchange(request, PastOrderNoResponse.class);
//    return result.getBody();
//  }
  /* modify by songqingyang  2023-02-01 [CodeOptimization]  end */
  //add FNSI内容修正 外部Api調用 房 end

  //add FNSI内容修正 ベッド切り替え 房 start
  @PutMapping("/result/bed_change/{ord_no}/{bed_Cd}")
  public ResponseEntity<?> bedChangeHandle(
    @PathVariable("ord_no") Long ordNo,
    @PathVariable("bed_Cd") Long bedCd,
    @AuthenticationPrincipal NtssUser ntssUser) {
    List<Long> result = treatmentRecordService.bedChangeHandle(ordNo, bedCd, ntssUser.getFacilityCd());
    // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
//    if (result != null) {
    return new ResponseEntity<>(result, HttpStatus.OK);
//    } else {
//      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
//    }
    // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
  }
  //add FNSI内容修正 ベッド切り替え 房 end

  // #9315 2024.02.14 add 治療状況のみを取得する計量REST APIの追加 TDC片口 start
  /**
   * 治療状況取得
   *
   * @param ordNo オーダ番号
   * @return
   */
  @GetMapping("/{ord_no}/current-dialysis-state")
  public ResponseEntity<String> getRstDialysisState(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get current dialysis state : "+ ordNo);
    eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    // オーダ番号に対応する治療状態の取得
    final String response = treatmentRecordService.getRstDialysisState(ordNo);

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // #9315 2024.02.14 add 治療状況のみを取得する計量REST APIの追加 TDC片口 end
  // add #11471 ord_mian操作時の治療モードデータの登録 関 start
  @GetMapping("/{ord_no}/rst_cond_info_setting")
  public ResponseEntity<TreatmentRecordReportInfo> getRstCondInfoSettingByOrdNo(
    @PathVariable("ord_no") Long ordNo,
    @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasOrdOrSelectedPatShareAccess(ntssUser, ordNo, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }


    return treatmentRecordService.getRstCondInfoSettingByOrdNo(ordNo);
  }
  // add #11471 ord_mian操作時の治療モードデータの登録 関 end

  private boolean hasFacilityAndOrdAccess(NtssUser ntssUser, String facilityCd, Long ordNo) {
    return ntssUser != null
      && facilityCd != null
      && facilityCd.equals(ntssUser.getFacilityCd())
      && hasOrdAccess(ntssUser, ordNo);
  }

  private boolean hasOrdAccess(NtssUser ntssUser, Long ordNo) {
    if (ntssUser == null || ordNo == null) {
      return false;
    }
    if (ntssUser.isNkkAdminUser()) {
      return true;
    }
    OrdMain ordMain = ordMainService.selectByOrdNo(ordNo);
    return ordMain == null || ordMain.getFacilityCd() == null
      || ordMain.getFacilityCd().equals(ntssUser.getFacilityCd());
  }
}
