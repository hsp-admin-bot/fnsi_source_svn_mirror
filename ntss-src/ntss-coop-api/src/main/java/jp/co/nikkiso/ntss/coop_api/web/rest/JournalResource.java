package jp.co.nikkiso.ntss.coop_api.web.rest;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

// mod 2022-07-22 bug 7351 修正 profile連携の取り込み結果の判断処理追加 chen start
import jp.co.nikkiso.ntss.coop_api.aspect.LogAspector;
import jp.co.nikkiso.ntss.coop_api.mapping.DeliveryResult;
import jp.co.nikkiso.ntss.coop_api.request.CallApiJournalRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalConvertSendRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalCreateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalTimeoutRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.request.MntIfEdgeClientConnectRequest;
import jp.co.nikkiso.ntss.coop_api.response.DeliverSendResult;
import jp.co.nikkiso.ntss.coop_api.response.DeliveryResults;
import jp.co.nikkiso.ntss.coop_api.response.ErrorMessage;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultKey;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.coop_api.response.JournalCreateResult;
import jp.co.nikkiso.ntss.coop_api.response.JournalTimeoutResult;
import jp.co.nikkiso.ntss.coop_api.response.JournalUpdateResult;
import jp.co.nikkiso.ntss.coop_api.service.CallApiService;
import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.coop_api.service.CoopJournalErrorComponent;
import jp.co.nikkiso.ntss.coop_api.service.DeliveryService;
import jp.co.nikkiso.ntss.coop_api.service.FacilityStatusService;
import jp.co.nikkiso.ntss.coop_api.service.HealthService;
import jp.co.nikkiso.ntss.coop_api.service.IfEdgeService;
import jp.co.nikkiso.ntss.coop_api.service.JournalConvertSendService;
import jp.co.nikkiso.ntss.coop_api.service.JournalService;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.service.externalCoopOper.CoopSendServiceImpl;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConstant;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertLogUtil;
import jp.co.nikkiso.ntss.coop_api.utils.NotificationApiCallUtil;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.ApiTimingBaStatus;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.ApiTimingIoStatus;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.CoopResult;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopApilink.AfterApiStatus;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.CommonSetting;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.CoopOpeCd;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.CoopOrdCd;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.custom.JournalDistribute;
import jp.co.nikkiso.ntss.core.entity.custom.MstCoopIniInfo;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// mod 2022-07-22 bug 7351 修正 profile連携の取り込み結果の判断処理追加 chen start

@RestController
@RequestMapping("/journal")
public class JournalResource {
  @Autowired
  private JournalService journalService;
  @Autowired
  private DeliveryService deliveryService;
  @Autowired
  private HealthService healthService;
  @Autowired
  private LogService logService;

  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
  @Autowired
  IfEdgeService ifEdgeService;

  @Autowired
  private JournalConvertSendService journalConvertSendService;

  @Autowired
  private ConvertCommonService convertCommonService;
  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end

  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  @Autowired
  private NotificationApiCallUtil notificationApiCallUtil;

  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;
  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

  @Autowired
  private CallApiService callApiService;

  @Autowired
  private OrdMainDao ordMainDao;

  // add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221019 start
  @Autowired
  private JournalConvertReceiveResource doJournal;

  @Autowired
  SysCoopJournalDao sysCoopJournalDao;
  // add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221019 end

  // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230129 zhaoqi start
  @Autowired
  private MstCoopIniDao mstCoopIniDao;
  // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230129 zhaoqi end

  // add 9583 by kangjie 20240401 start
  @Autowired
  CoopJournalErrorComponent coopJournalErrorComponent;
  // add 9583 by kangjie 20240401 end

  @Autowired
  private FacilityStatusService facilityStatusService;

  /** 配信ステータス key: facilityCd, value: start or stop */
  private ConcurrentHashMap<String, String> deliveryStatus = new ConcurrentHashMap<>();

  @Autowired
  private CoopSendServiceImpl coopSendServiceImpl;

  /**
   * ジャーナル更新(/journal/update)
   * @param request : {@link JournalUpdateRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/update")
  public ResponseEntity<?> update(@RequestBody JournalUpdateRequest request) {
    if (!request.validate()) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "リクエストパラメータが不正または不足しています。"
          + "ctl_no:[" + request.getCtlNo() + "],"
          + "ana_result:[" + request.getAnaResult() + "],"
          + "coop_result:[" + request.getCoopResult() + "],"
          + "dump_path:[" + request.getDumpPath() + "],"
          + "user_id:[" + request.getUserId() + "]"
          );
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
      eventLogMessage.setLogMessage(error.getMessage());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end

      // ジャーナル更新場合、施設コードが無し、通知機能API（NotificationApiCallUtil）を呼び出さない

      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    JournalUpdateResult result;
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    SysCoopJournal journal = new SysCoopJournal();
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    try {
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // SysCoopJournal journal = journalService.update(request);
      journal = journalService.update(request);
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end

      // add 2021-03-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
      // 異常データの場合、通知処理を行う。
      // 変換ステータス
      String anaResult = String.valueOf(journal.getAnaResult());
      // 通信ステータス
      String coopResult = String.valueOf(journal.getCoopResult());

      if (String.valueOf(NtssCoopApiConstants.CoopResult.INTERNAL_ERROR_BY_NTSS.getResult()).equals(coopResult)
          || String.valueOf(NtssCoopApiConstants.CoopResult.INTERNAL_ERROR_BY_CARTE.getResult()).equals(coopResult)
          || String.valueOf(NtssCoopApiConstants.CoopResult.SKIP.getResult()).equals(coopResult)
          || String.valueOf(NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult()).equals(anaResult)
          || String.valueOf(NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult()).equals(anaResult)
          || String.valueOf(NtssCoopApiConstants.AnaResult.SKIP.getResult()).equals(anaResult)) {
        // // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//        notificationApiCallUtil.registerNotification(journal.getFacilityCd(), journal.getCoopCd(),
        // journal.getHospPatId(), journal.getBaseDate());
        coopJournalErrorComponent.sendCoopJournalError(journal);
        // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
      }
      // add 2021-03-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

      // ジャーナル更新後の再解析トリガー処理の呼び出し
      requestConvertSend(request, journal);

      result = new JournalUpdateResult(HttpStatus.OK, journal);
    } catch (NtssException e) {
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      eventLogMessage.setLogMessage("ジャーナル更新APIにて例外が発生しました。Message:" + e.getMessage());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // ジャーナル更新場合、施設コードが無し、通知機能API（NotificationApiCallUtil）を呼び出さない

      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "ジャーナル更新APIにて例外が発生しました。");
      return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    // エッジヘルスモニタ更新処理の呼び出し
    try {
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      request.setAnaResult(journal.getAnaResult());
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      healthService.update(request);
    } catch (Exception e) {
      // ジャーナル更新としては 正常として処理するため、何もしない
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      eventLogMessage.setLogMessage("エッジヘルスモニタ更新処理の呼び出しでエラーが発生しました。Message:" + e.getMessage());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  /**
   * ジャーナル更新後の再解析トリガー処理。
   * 
   * coop_result が終了系（完了・エラー・スキップ）になった時に初めてブロック条件から外れるため、
   * coop_result が終了系の時のみ journal/convert/send を呼び出す。
   * 
   * @param r       ジャーナル更新リクエスト。coop_result の判定に使用する
   * @param journal 更新後のジャーナル。再解析リクエストの施設コード等の設定に使用する
   * 
   */
  private void requestConvertSend(JournalUpdateRequest r, SysCoopJournal journal) {
    // coop_result が終了系（完了・エラー・スキップ）の場合は再解析を呼び出す。それ以外は呼び出さない。
    if (!CoopResult.DONE.isSameResult(r.getCoopResult())
        && !CoopResult.INTERNAL_ERROR_BY_NTSS.isSameResult(r.getCoopResult())
        && !CoopResult.INTERNAL_ERROR_BY_CARTE.isSameResult(r.getCoopResult())
        && !CoopResult.SKIP.isSameResult(r.getCoopResult())) {
      return;
    }

    JournalConvertSendRequest request = new JournalConvertSendRequest();
    request.setFacilityCd(journal.getFacilityCd());
    request.setOrdNo(journal.getOrdNo());
    request.setPatId(journal.getPatId());
    request.setHospPatId(journal.getHospPatId());
    request.setUserId(journal.getUserId());
    request.setCoopCd(journal.getCoopCd());

    // @Async が付いた別クラスのメソッドを呼び出すことで非同期実行する
    coopSendServiceImpl.externalCoopOperViwersend(request);
  }

  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start
  /**
   * 応答待ちのジャーナル更新(/journal/updateWaiting)
   * @param request : {@link JournalUpdateRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/updateWaiting")
  public ResponseEntity<?> updateWaiting(@RequestBody JournalDeliveryRequest request) {
    // ログメッセージ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    if (StringUtils.isEmpty(request.getFacilityCd())) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "応答待ちのリクエストパラメータが不正または不足しています。facility_cd:[" + request.getFacilityCd() + "]");

      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setLogMessage(error.getMessage());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }
    // add by shiyw 2023-03-17: Used to ensure that "LogAspector.outputLog()" can get facility_cd
    LogAspector.setCurrentRequestFacilityCd(request.getFacilityCd());

    /* modify by zhangruixue 2023-01-30 [Transaction,CodeOptimization] --start */
    ErrorMessage result = null;
    try {
      result = journalService.updateWaiting(request.getFacilityCd(), request);
    } catch (Exception e) {
      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "応答待ちのジャーナル更新APIにて例外が発生しました。");
      return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    // ErrorMessage result = null;
    // try {
    // int updCnt = journalService.updateWaitingStatus(request.getFacilityCd());
//      result = new ErrorMessage(HttpStatus.OK, String.format("UPDATE CNT[%s].", updCnt));
    // } catch (NtssException e) {
//      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "応答待ちのジャーナル更新APIにて例外が発生しました。");
    //
    // eventLogMessage.setFacilityCd(request.getFacilityCd());
    // eventLogMessage.setInvokeClass(this.getClass().getName());
//      eventLogMessage.setLogMessage(error.getMessage() + "Message:" + e.getMessage());
//      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //
    // return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    // }
    //
    // // エッジヘルスモニタ更新処理の呼び出し
    // try {
    // healthService.update(request);
    // } catch (Exception e) {
    // eventLogMessage.setFacilityCd(request.getFacilityCd());
    // eventLogMessage.setInvokeClass(this.getClass().getName());
//      eventLogMessage.setLogMessage("応答待ちのエッジヘルスモニタ更新処理の呼び出しでエラーが発生しました。Message:" + e.getMessage());
//      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // }
    /* modify by zhangruixue 2023-01-30 [Transaction,CodeOptimization] --end */
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end

  // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /**
   * ジャーナル作成(連携版番号)
   * @param request : {@link JournalCreateRequest}
   * @return {@link JournalCreateResult}
   */
  private JournalCreateResult createByCoopVersion(JournalCreateRequest request) {
    JournalCreateResult result;

    long startTime = System.currentTimeMillis();
    EventLogMessage eventLogMessageTemp = new EventLogMessage();
    eventLogMessageTemp.setFacilityCd(request.getFacilityCd()); // add by shiyw: Ensure that the log is output to the facility directory
    eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.1 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    if (!request.validate()) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "リクエストパラメータが不正または不足しています。"
          + "facility_cd:[" + request.getFacilityCd() + "],"
          // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
          + "ope_cd:[" + request.getOpeCd() + "],"
          // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
          + "coop_cd:[" + request.getCoopCd() + "],"
          + "coop_cd_index:[" + request.getCoopCdIndex() + "],"
          // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          + "coop_version:[" + (StringUtils.isEmpty(request.getCoopVersion()) ? "" : request.getCoopVersion()) + "],"
          + "key0:[" + (StringUtils.isEmpty(request.getKey0()) ? "" : request.getKey0()) + "],"
          // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          + "crud:[" + request.getCrud() + "],"
          + "ord_no:[" + request.getOrdNo() + "],"
          + "coop_ord_no:[" + request.getCoopOrdNo() + "],"
          + "hosp_pat_id:[" + request.getHospPatId() + "],"
          + "pat_id:[" + request.getPatId() + "],"
          + "ana_result:[" + request.getAnaResult() + "],"
          + "coop_result:[" + request.getCoopResult() + "],"
          + "message64:[" + request.getMessage64() + "],"
        + "user_id:[" + request.getUserId() + "]"
      );
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
      eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
      eventLogMessage.setLogMessage(error.getMessage());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end

      // パラメータ不正の場合、通知機能API（NotificationApiCallUtil）を呼び出さない

      // return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
      result = new JournalCreateResult(HttpStatus.BAD_REQUEST, null, error.getMessage());
      return result;
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    // JournalCreateResult result;

    // 事前APIキック機能
    CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
    BeanUtils.copyProperties(request, callApiJournalRequest);
    callApiJournalRequest.setApiTimingIo(ApiTimingIoStatus.CREATE.getStatus());
    callApiJournalRequest.setApiTimingBa(ApiTimingBaStatus.BEFORE.getStatus());
    Map<String, AfterApiStatus> afterApiStatusMap = new HashMap<String, AfterApiStatus>();
    // mod 2021-04-07 課題No.1:SQL呼び出しを追加 孫 start
//    boolean callResult = callApiService.callApiJournal(callApiJournalRequest, null, afterApiStatusMap);
    SysCoopJournal journalForApi = new SysCoopJournal();
    BeanUtils.copyProperties(request, journalForApi);
    boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journalForApi, afterApiStatusMap);
    eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.2 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    // mod 2021-04-07 課題No.1:SQL呼び出しを追加 孫 end

    // afterApiStatus上書き
    if (afterApiStatusMap.containsKey("afterApiStatus")) {
      if (!StringUtils.isEmpty(afterApiStatusMap.get("afterApiStatus").getAnaResult())) {
        request.setAnaResult(afterApiStatusMap.get("afterApiStatus").getAnaResult());
      }
      if (!StringUtils.isEmpty(afterApiStatusMap.get("afterApiStatus").getCoopResult())) {
        request.setCoopResult(afterApiStatusMap.get("afterApiStatus").getCoopResult());
      }
    }

    // 後続処理継続不可
    if (!callResult) {
      // result = new JournalCreateResult(HttpStatus.OK, null);
      // return new ResponseEntity<>(result, HttpStatus.OK);
      result = new JournalCreateResult(HttpStatus.OK, null, null);
      return result;
    }

    // add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 start
    // ジャーナル作成
    boolean insertSuccess = false;
    // add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 end
    // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
    List<SysCoopJournal> journals = new ArrayList<>();
    // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end
    try {
      // mod 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
      // List<SysCoopJournal> journals = journalService.insert(request);

      // #7790 初版確定前の治療実績削除で不要なイベントが登録される zhaoqi start
      // del #7790 初版確定前の治療実績削除で不要なイベントが登録される 20220719 zhaoqi start
      // OrdMain ordMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      // Integer rstEdition = null;
      // String rstDialysisState = "";
      // if(ordMain != null){
      // rstEdition = ordMain.getRstEdition();
      // rstDialysisState = ordMain.getRstDialysisState();
      // }
      // if(!"D".equals(request.getCrud())) {
      // journals = journalService.insert(request);
      // } else {
      // if(!(rstEdition == 0 || !"6".equals(rstDialysisState))){
      // journals = journalService.insert(request);
      // }
      // }
      // if(!(rstEdition == 0 || !"6".equals(rstDialysisState))){
      // journals = journalService.insert(request);
      // }
      // del #7790 初版確定前の治療実績削除で不要なイベントが登録される 20220719 zhaoqi end

      // add #7790 初版確定前の治療実績削除で不要なイベントが登録される 20220719 zhaoqi start
      journals = journalService.insert(request);
      // add #7790 初版確定前の治療実績削除で不要なイベントが登録される 20220719 zhaoqi end
      // #7790 初版確定前の治療実績削除で不要なイベントが登録される zhaoqi end

      // add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 start
      insertSuccess = true;
      // add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 end

      // mod 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end
      // result = new JournalCreateResult(HttpStatus.OK, journals);
      result = new JournalCreateResult(HttpStatus.OK, journals, null);

      // 事後APIキック機能
      callApiJournalRequest.setApiTimingBa(ApiTimingBaStatus.AFTER.getStatus());
      eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.2.1 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      for (SysCoopJournal journal : journals) {

        // del 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230210 zhaoqi start
        // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230129 zhaoqi start
//        if (Key0Constant.GX.equals(journal.getKey0()) && "exam_ord".equals(journal.getCoopCd())) {
//          String value = mstCoopIniDao.selectCoopIniInfoValue(request.getFacilityCd(), Key0Constant.GX, "EXAMIN_INFO", "IND_SEND_MODE");
        // if (!"1".equals(value)) {
        // String baseDate = journal.getBaseDate();
        // Long patId = journal.getPatId();
//            SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectJournalForExamOrdCheck(baseDate, patId);
        // if (sysCoopJournal == null) {
        // updateAnaResult(journal, "クール設定された透析予定が存在しないため、スキップする", AnaResult.SKIP);
        // }
        // }
        // }
        // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230129 zhaoqi end
        // del 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない 20230210 zhaoqi end

        callResult = callApiService.callApiJournal(callApiJournalRequest, journal, null);
        if (!callResult) {
          break;
        }
      }
      eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.2.2 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);

    } catch (NotExistException e) {
      eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.2.3 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
      eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
      eventLogMessage.setInvokeClass(this.getClass().getName());
      eventLogMessage.setLogMessage("ジャーナル作成APIにて例外が発生しました。Message:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end

      // add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 start
      // 変換ステータスが「未処理」のレコードをすべて「内部エラー」に更新
      if (insertSuccess) {
        String error = eventLogMessage.getLogMessage();
        journals.parallelStream()
            .filter(journal -> AnaResult.UNPROCESS.getResult().equals(journal.getAnaResult()))
            .forEach(journal -> updateAnaResult(journal, error, AnaResult.INTERNAL_ERROR));
      }
      // add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 end

      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
      // 通知機能APIを呼び出し
      if (JournalConvertConstants.DIRECTION_SEND.equals(request.getDirection()) && -1 == request.getUserId()) {
        // ((S:送信)、画面以外の電文）の場合
        // modify 9583 by kangjie 20240410 start 通知一覧の連携エラー通知の遷移不正
        // JSONObject replaceData = new JSONObject();
//        replaceData.put("COOP_CD", notificationApiCallUtil.GetCoopNameByCd(request.getCoopCd()));
//        Long notificationNo =  CoreConstant.NotificationDefinition.COOP_JOURNAL_SEND_TIME;
//        notificationApiCallUtil.registerNotification(notificationNo, request.getFacilityCd(), replaceData);
        SysCoopJournal journal = new SysCoopJournal();
        BeanUtils.copyProperties(request, journal);
        coopJournalErrorComponent.sendCoopJournalError(journal);
        // modify 9583 by kangjie 20240410 end 通知一覧の連携エラー通知の遷移不正
      } else {
        // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//        notificationApiCallUtil.registerNotification(request.getFacilityCd(), request.getCoopCd(), request.getHospPatId(),
        // request.getBaseDate());
        SysCoopJournal journal = new SysCoopJournal();
        BeanUtils.copyProperties(request, journal);
        coopJournalErrorComponent.sendCoopJournalError(journal);
        // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
      }
      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

      // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 start
      // ErrorMessage error = new ErrorMessage(HttpStatus.NO_CONTENT, e.getMessage());
      // return new ResponseEntity<>(error, HttpStatus.NO_CONTENT);
      ErrorMessage error = new ErrorMessage(HttpStatus.NOT_FOUND, e.getMessage());
      eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.2.4 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      // return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
      result = new JournalCreateResult(HttpStatus.NOT_FOUND, null, error.getMessage());
      return result;
      // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 end
    } catch (Exception e) {
      eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.2.5 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
      eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      eventLogMessage.setLogMessage("ジャーナル作成APIにて例外が発生しました。Message:" + e.getMessage());
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      // mod 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      //logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // mod 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end

      // add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 start
      // 変換ステータスが「未処理」のレコードをすべて「内部エラー」に更新
      if (insertSuccess) {
        String error = eventLogMessage.getLogMessage();
        journals.parallelStream()
            .filter(journal -> AnaResult.UNPROCESS.getResult().equals(journal.getAnaResult()))
            .forEach(journal -> updateAnaResult(journal, error, AnaResult.INTERNAL_ERROR));
      }
      // add 2023-02-05 bug #7237 連携イベントが処理されないタイミングが存在する 孫 end

      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
      // 通知機能APIを呼び出し
      if (JournalConvertConstants.DIRECTION_SEND.equals(request.getDirection()) && -1 == request.getUserId()) {
        // ((S:送信)、画面以外の電文）の場合
        // modify 9583 by kangjie 20240410 start 通知一覧の連携エラー通知の遷移不正
        // JSONObject replaceData = new JSONObject();
//        replaceData.put("COOP_CD", notificationApiCallUtil.GetCoopNameByCd(request.getCoopCd()));
//        Long notificationNo =  CoreConstant.NotificationDefinition.COOP_JOURNAL_SEND_TIME;
//        notificationApiCallUtil.registerNotification(notificationNo, request.getFacilityCd(), replaceData);
        SysCoopJournal journal = new SysCoopJournal();
        BeanUtils.copyProperties(request, journal);
        coopJournalErrorComponent.sendCoopJournalError(journal);
        // modify 9583 by kangjie 20240410 end 通知一覧の連携エラー通知の遷移不正
      } else {
        // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//        notificationApiCallUtil.registerNotification(request.getFacilityCd(), request.getCoopCd(), request.getHospPatId(),
        // request.getBaseDate());
        SysCoopJournal journal = new SysCoopJournal();
        BeanUtils.copyProperties(request, journal);
        coopJournalErrorComponent.sendCoopJournalError(journal);
        // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
      }
      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "ジャーナル作成APIにて例外が発生しました。");
      eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.2.6 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      // return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
      result = new JournalCreateResult(HttpStatus.INTERNAL_SERVER_ERROR, null, error.getMessage());
      return result;
    }

    eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.3 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);

    // エッジヘルスモニタ更新処理の呼び出し
    try {
      healthService.update(request);
    } catch (Exception e) {
      // ジャーナル作成としては 正常として処理するため、何もしない
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
      eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      eventLogMessage.setLogMessage("エッジヘルスモニタ更新処理の呼び出しでエラーが発生しました。Message:" + e.getMessage());
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      // mod 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      //logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // mod 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 send
    }
    eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.4 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);

    // add 2021-01-18 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
    // (R:受信)電文の場合、正常に戻る
    if (JournalConvertConstants.DIRECTION_RECEIVE.equals(request.getDirection())) {
      // return new ResponseEntity<>(result, HttpStatus.OK);
      return result;
    }
    // add 2021-01-18 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end
    // add 2021-08-27 #5887:富士通連携設定の構築の対応 孫 start
    else {
      // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
      String checkMsg = "";
      // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
      // 連携対象患者か判断する
      int checkNgCnt = 0;
      eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.4.1 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      for (SysCoopJournal journalCheck : journals) {
        String resultCheck = journalService.checkCoopExisted(journalCheck);
        if (!StringUtils.isEmpty(resultCheck)) {
          // 対象ジャーナルの変換状態を「スキップ」に更新する。
          // #8348 profile連携の定時処理で作成されたjournalが処理されない 2023-03-31 卓 ---start
          // mod #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 start
          // updateAnaResult(journalCheck, resultCheck, AnaResult.PROCESSING);
          // mod #7969 profile連携のスキップ処理のメッセージが処理の仕方によって異なるものが記録される 王永吉 end
          // updateAnaResult(journalCheck, resultCheck, AnaResult.SKIP);
          journalCheck.setAnaResult(AnaResult.SKIP.getResult());
          journalCheck.setCoopResult(CoopResult.SKIP.getResult());
          journalCheck.setMessage(resultCheck);
          Integer updateCount = journalService.updateJournalSkipWithDate(journalCheck);

          // 事後APIキック機能を呼び出し
          String statusCode = AnaResult.SKIP.getResult();
          if (updateCount > 0
              && (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(statusCode)
                  || NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(statusCode)
                  || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult().equals(statusCode)
                  || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(statusCode))) {

            callApiJournalRequest = new CallApiJournalRequest();
            BeanUtils.copyProperties(journalCheck, callApiJournalRequest);
            if (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(statusCode)) {
              callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_DONE.getStatus());
            } else if (NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(statusCode)) {
              callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_SKIP.getStatus());
            } else if (NtssCoopApiConstants.AnaResult.INTERNAL_ERROR.getResult().equals(statusCode)
                || NtssCoopApiConstants.AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(statusCode)) {
              callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_ERROR.getStatus());
            }
            callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
            callResult = callApiService.callApiJournal(callApiJournalRequest, journalCheck, null);

          }
          // #8348 profile連携の定時処理で作成されたjournalが処理されない 2023-03-31 卓 ---end

          checkNgCnt++;
          // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
          checkMsg = checkMsg + resultCheck;
          // add 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
        }
      }
      eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.4.2 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      if (checkNgCnt == journals.size()) {
        // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 start
        // return new ResponseEntity<>(result, HttpStatus.OK);
        ErrorMessage errorMsg = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, checkMsg);
        // return new ResponseEntity<>(errorMsg, HttpStatus.BAD_REQUEST);
        result = new JournalCreateResult(HttpStatus.INTERNAL_SERVER_ERROR, null, errorMsg.getMessage());
        return result;
        // mod 2022-10-11 bug #6153 イベント作成処理に失敗する 孫 end
      }
    }

    eventLogMessageTemp.setLogMessage( "$$$$$$/journal/createByCoopVersion 1.5 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    // add 2021-08-27 #5887:富士通連携設定の構築の対応 孫 end

    return result;
  }

  // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  // mod 2023-01-14 bug #7627 修正 chen start
  /**
   * ジャーナル作成(/journal/create)
   * @param ctlNoList : {@link List<Long>}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/createList")
  public ResponseEntity<?> createList(@RequestBody List<JournalCreateRequest> ctlNoList) {
    JournalCreateResult result = new JournalCreateResult(HttpStatus.OK, null, null);
    // add by shiyw 2023-03-17: Used to ensure that "LogAspector.outputLog()" can get facility_cd  --start
    if (!ctlNoList.isEmpty()) {
      LogAspector.setCurrentRequestFacilityCd(ctlNoList.get(0).getFacilityCd());
    }
    // add by shiyw 2023-03-17: Used to ensure that "LogAspector.outputLog()" can get facility_cd --end
    for (JournalCreateRequest request : ctlNoList) {
      // Long ctlNo = ctlNoList.get(i);
      // SysCoopJournal SysCoopJournal = sysCoopJournalDao.selectByPK(ctlNo);
      // JournalCreateRequest request = new JournalCreateRequest();
      // request.setFacilityCd(SysCoopJournal.getFacilityCd());
      // request.setCoopCd(SysCoopJournal.getCoopCd());
      // request.setCoopCdIndex(SysCoopJournal.getCoopCdIndex());
      // request.setCrud(SysCoopJournal.getCrud());
      // request.setDirection(SysCoopJournal.getDirection());
      // request.setOrdNo(SysCoopJournal.getOrdNo());
      // request.setCoopOrdNo(SysCoopJournal.getCoopOrdNo());
      // request.setHospPatId(SysCoopJournal.getHospPatId());
      // request.setPatId(SysCoopJournal.getPatId());
      // request.setBaseDate(SysCoopJournal.getBaseDate());
      // request.setAnaResult(SysCoopJournal.getAnaResult());
      // request.setCoopResult(SysCoopJournal.getCoopResult());
      // request.setUserId(SysCoopJournal.getUserId());
      // request.setOpeCd(SysCoopJournal.getOpeCd());
      // request.setMessage(SysCoopJournal.getMessage());
      // request.setKey0(SysCoopJournal.getKey0());
      // request.setCoopVersion(SysCoopJournal.getCoopVersion());
      ResponseEntity<?> resultTmp = createImpl(request);
      // mod #10125 zrx start
      if (resultTmp.getBody() instanceof ErrorMessage body) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setFacilityCd(request.getFacilityCd());
        eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
        eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
        eventLogMessage.setLogMessage(body.getMessage());
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
      // mod #10125 zrx end
    }
    // add #10336 DBが高負荷になる（外部連携由来）2 start
    if (!ctlNoList.isEmpty() && ctlNoList.size() > 0) {
      while (true) {
        // 変換対象ジャーナル取得
        List<SysCoopJournal> journalList = convertCommonService.getJournalList(ctlNoList.get(0).getFacilityCd()
          , JournalConvertConstants.DIRECTION_SEND
          , NtssCoopApiConstants.CoopResult.UNPROCESS.getResult()
          , null, null, null);
        // 対象ジャーナルが1件も存在しない場合break
        if (CollectionUtils.isEmpty(journalList)) {
          break;
        }
        // 同じord_no, pat_id, coop_versionのジャーナルは直列で順番に解析させるため
        // 変換対象ジャーナルが存在しても、処理中ジャーナルと同じord_no, pat_id, coop_versionのジャーナルしか残ってない場合は処理を抜ける
        // 処理中ジャーナル取得
        List<SysCoopJournal> processingJournalList = convertCommonService.getProcessingJournalList(ctlNoList.get(0).getFacilityCd()
          , JournalConvertConstants.DIRECTION_SEND
          , null, null);
        // 対象ジャーナルに処理中ジャーナルと同じord_no, pat_id, coop_versionのジャーナルがあれば除く
        for (SysCoopJournal processingJournal : processingJournalList) {
          journalList = journalList.stream().filter(journal ->
              !journal.getOrdNo().equals(processingJournal.getOrdNo())
              || !journal.getPatId().equals(processingJournal.getPatId())
              || !journal.getCoopVersion().equals(processingJournal.getCoopVersion()))
              .collect(Collectors.toList());
        }
        // 対象ジャーナルが存在しても、処理中ジャーナルと同じord_no, pat_id, coop_versionのジャーナルしか残ってない場合はbreak
        if (CollectionUtils.isEmpty(journalList)) {
          break;
        }
        JournalCreateRequest journalCreateRequest = new JournalCreateRequest();
        journalCreateRequest.setFacilityCd(ctlNoList.get(0).getFacilityCd());
        journalCreateRequest.setOrdNo(null);
        journalCreateRequest.setPatId(null);
        journalCreateRequest.setHospPatId(null);
        if (facilityStatusService.isStatusStart(ctlNoList.get(0).getFacilityCd())) {
          break;
        }
        lockConvert(journalCreateRequest);
      }
    }
    // add #10336 DBが高負荷になる（外部連携由来）2 end
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  /**
   * ジャーナル作成(/journal/create)
   * @param request : {@link JournalCreateRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/create")
  public ResponseEntity<?> create(@RequestBody JournalCreateRequest request) {
    LogAspector.setCurrentRequestFacilityCd(request.getFacilityCd());// add by shiyw 2023-03-17: Used to ensure that "LogAspector.outputLog()" can get facility_cd
    // mod #10336 DBが高負荷になる（外部連携由来）2 start
    // return createImpl(request);
    ResponseEntity<?> resultTmp = createImpl(request);
    while (true) {
      // 変換対象ジャーナル取得
      List<SysCoopJournal> journalList = convertCommonService.getJournalList(request.getFacilityCd()
        , JournalConvertConstants.DIRECTION_SEND
        , NtssCoopApiConstants.CoopResult.UNPROCESS.getResult()
        , null, null, null);
      // 対象ジャーナルが1件も存在しない場合break
      if (CollectionUtils.isEmpty(journalList)) {
        break;
      }
      // 同じord_no, pat_id, coop_versionのジャーナルは直列で順番に解析させるため
      // 変換対象ジャーナルが存在しても、処理中ジャーナルと同じord_no, pat_id, coop_versionのジャーナルしか残ってない場合は処理を抜ける
      // 処理中ジャーナル取得
      List<SysCoopJournal> processingJournalList = convertCommonService.getProcessingJournalList(request.getFacilityCd()
        , JournalConvertConstants.DIRECTION_SEND
        , null, null);
      // 対象ジャーナルに処理中ジャーナルと同じord_no, pat_id, coop_versionのジャーナルがあれば除く
      for (SysCoopJournal processingJournal : processingJournalList) {
        journalList = journalList.stream().filter(journal ->
            !journal.getOrdNo().equals(processingJournal.getOrdNo())
            || !journal.getPatId().equals(processingJournal.getPatId())
            || !journal.getCoopVersion().equals(processingJournal.getCoopVersion()))
            .collect(Collectors.toList());
      }
      // 対象ジャーナルが存在しても、処理中ジャーナルと同じord_no, pat_id, coop_versionのジャーナルしか残ってない場合はbreak
      if (CollectionUtils.isEmpty(journalList)) {
        break;
      }

      JournalCreateRequest journalCreateRequest = new JournalCreateRequest();
      journalCreateRequest.setFacilityCd(request.getFacilityCd());
      journalCreateRequest.setOrdNo(null);
      journalCreateRequest.setPatId(null);
      journalCreateRequest.setHospPatId(null);
      if (facilityStatusService.isStatusStart(request.getFacilityCd())) {
        break;
      }
      lockConvert(journalCreateRequest);
    }
    return resultTmp;
    // mod #10336 DBが高負荷になる（外部連携由来）2 end
  }

  private ResponseEntity<?> createImpl(JournalCreateRequest request) {

    long startTime = System.currentTimeMillis();
    EventLogMessage eventLogMessageTemp = new EventLogMessage();
    eventLogMessageTemp.setFacilityCd(request.getFacilityCd()); // add by shiyw: Ensure that the log is output to the facility directory
    eventLogMessageTemp.setLogMessage("$$$$$$/journal/create start ");
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    // add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 start
    String crud = request.getCrud();
    // del 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
//      if ("1".equals(doJournal.isDieFlagResultMap.get(request.getHospPatId())) && "D".equals(crud)) {
//        Optional<SysCoopJournal> sc = doJournal.scList.stream().filter(sysCoopJournal ->
//          sysCoopJournal.getPatId().equals(request.getPatId()) && sysCoopJournal.getCoopCd().equals(request.getCoopCd())).findFirst();
    // if (sc.isPresent()) {
    // Long ordNo = sc.get().getOrdNo();
    // String baseDate = sc.get().getBaseDate();
    // request.setOrdNo(ordNo);
    // request.setBaseDate(baseDate);
    // doJournal.scList.remove(sc.get());
    // }
    // }
    // add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 end
    // del 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end

    // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    List<JournalCreateRequest> requestsFromDef = new ArrayList<>();
    // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    // 施設コードと操作番号が有り場合、連携設定マスタから、データを取得する
    if (!StringUtils.isEmpty(request.getFacilityCd()) && !StringUtils.isEmpty(request.getOpeCd())) {
      String errorMsg = "";
      try {
        MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(request.getFacilityCd());
        if (mstCoopFacility == null) {
          errorMsg = "施設連携設定が存在しません。";
        } else {
          CommonSetting commonSetting = mstCoopFacility.getCommonSetting();
          if (commonSetting == null) {
            errorMsg = "施設連携設定内の各機能共通設定が存在しません。";
          } else {
            // 外部連携のステータスが(on:有効)が？
            if (!JournalConvertConstants.STATUS_ON.equals(commonSetting.getStatus())) {
              errorMsg = "施設連携設定の外部連携のステータスは「on:有効」ではありません。";
            } else {
              // オペ別毎の設定
              CoopOpeCd coopOpeCd = commonSetting.getCoopOpeCd();
              if (coopOpeCd == null) {
                errorMsg = "施設連携設定のオペ設定が存在しません。";
              } else {
                Boolean sendFlag = false;
                Boolean receiveFlag = false;
                String sendStatus = JournalConvertConstants.STATUS_OFF;
                String receiveStatus = JournalConvertConstants.STATUS_OFF;

                // オペ(送信)
                List<MstCoopFacility.OpeCdStatus> opeCdSends = coopOpeCd.getOpeCdSends();
                if (opeCdSends != null && opeCdSends.size() != 0) {
                  // オペコードをループ
                  for (MstCoopFacility.OpeCdStatus opeStatus : opeCdSends) {
                    // オペコード存在の場合
                    if (request.getOpeCd().equals(opeStatus.getOpeCd())) {
                      sendFlag = true;
                      sendStatus = opeStatus.getStatus();
                      break;
                    }
                  }
                }

                // オペ(受信)
                List<MstCoopFacility.OpeCdStatus> opeCdReceives = coopOpeCd.getOpeCdReceives();
                if (opeCdReceives != null && opeCdReceives.size() != 0) {
                  // オペコードをループ
                  for (MstCoopFacility.OpeCdStatus opeStatus : opeCdReceives) {
                    // オペコード存在の場合
                    if (request.getOpeCd().equals(opeStatus.getOpeCd())) {
                      receiveFlag = true;
                      receiveStatus = opeStatus.getStatus();
                      break;
                    }
                  }
                }

                if (receiveFlag && sendFlag) {
                  errorMsg = "施設連携設定のオペ設定(送信と受信)[" + request.getOpeCd() + "]は同時に存在する。";
                } else if (!receiveFlag && !sendFlag) {
                  errorMsg = "施設連携設定のオペ設定(送信と受信)[" + request.getOpeCd() + "]は同時に存在しません。";
                } else if (sendFlag && !JournalConvertConstants.STATUS_ON.equals(sendStatus)) {
                  errorMsg = "施設連携設定のオペ設定(送信)[" + request.getOpeCd() + "]のステータスは「on:有効」ではありません。";
                } else if (receiveFlag && !JournalConvertConstants.STATUS_ON.equals(receiveStatus)) {
                  errorMsg = "施設連携設定のオペ設定(受信)[" + request.getOpeCd() + "]のステータスは「on:有効」ではありません。";
                } else {
                  // 連携対象の電文種別毎の設定
                  List<CoopOrdCd> coopOrdCds = commonSetting.getCoopOrdCds();
                  if (coopOrdCds == null || coopOrdCds.size() == 0) {
                    errorMsg = "施設連携設定のオーダー種別設定が存在しません。";
                  } else {
                    // add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                    String coopVersionForNullCheck = request.getCoopVersion();
                    // add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                    // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                    // errorMsg = "施設連携設定のオーダー種別設定に「" + request.getOpeCd() + "」が存在しません。";
                    String coopVersionMsg = StringUtils.isEmpty(request.getCoopVersion())?"":request.getCoopVersion();
                    errorMsg = "受信：施設連携設定のオーダー種別設定に「操作番号=" + request.getOpeCd() + "、連携版番号=" + coopVersionMsg + "」が存在しません。";
                    // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                    for (CoopOrdCd coopOrdCd : coopOrdCds) {
                      // オペコード
                      List<String> opeCds = coopOrdCd.getOpeCds();
                      if (opeCds != null && opeCds.size() != 0
                          && opeCds.contains(request.getOpeCd())) {
                        // ジャーナル作成APIリクエストを設定する
                        // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                        // 向き（送受信）が受信の場合、連携版番号が一致するかどうかを判断する
                        if (JournalConvertConstants.DIRECTION_RECEIVE.equals(coopOrdCd.getDirection())) {
                          // 連携版番号
                          String coopVersionDef  = StringUtils.isEmpty(coopOrdCd.getCoopVersion()) ? "" : coopOrdCd.getCoopVersion();
                          String coopVersionReq  = StringUtils.isEmpty(request.getCoopVersion()) ? "" : request.getCoopVersion();
                          // 一致しない場合、処理の継続
                          if (!coopVersionDef.equals(coopVersionReq)) {
                            continue;
                          }
                          // mod 2023-01-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                          // }
                        } else {
                          // 向き（送受信）が送信の場合、連携版番号が一致するかどうかを判断する
                          // 連携版番号
                          String coopVersionDef  = StringUtils.isEmpty(coopOrdCd.getCoopVersion()) ? "" : coopOrdCd.getCoopVersion();
                          String coopVersionReq  = StringUtils.isEmpty(coopVersionForNullCheck) ? "" : coopVersionForNullCheck;
                          // 一致しない場合、処理の継続
                          if (coopVersionForNullCheck != null && !coopVersionDef.equals(coopVersionReq)) {
                            continue;
                          }
                        }
                        // mod 2023-01-06 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                        // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                        // add 2021-02-22 No.741:連携イベント作成・中止ツール 孫 start
                        // 操作番号が「900004:連携イベント作成・中止ツール(送信)」以外の場合、
                        // 電文種別を再設定する
                        if (!JournalConvertConstants.OPE_CD_COOP_EVENT_CREAT_OR_STOP.equals(request.getOpeCd())
                            && !JournalConvertConstants.IGNORE_OPE_CDS.contains(request.getOpeCd())) {
                          // 無視対象ではない操作番号だけ処理
                          request.setCoopCd(coopOrdCd.getCoopCd());
                        }
                        // add 2021-02-22 No.741:連携イベント作成・中止ツール 孫 end
                        // 付帯情報（電文）
                        request.setCoopCdIndex(coopOrdCd.getCoopCdIndex());
                        // 向き（送受信）
                        request.setDirection(coopOrdCd.getDirection());
                        // 変換処理ステータス
                        request.setAnaResult(coopOrdCd.getAnaResult());
                        // 配信処理ステータス
                        // add 2021-06-17 #5261:TSHPlusにおけるデータのジャーナル反映について 孫 start
                        // request.setCoopResult(coopOrdCd.getCoopResult());
                        // 向き（送受信）が受信、かつ、IFEdge(userId==null,-1)、CoopResultがnull以外の場合、受信データのCoopResultを利用する
                        if (JournalConvertConstants.DIRECTION_RECEIVE.equals(coopOrdCd.getDirection())
                            && (request.getUserId() != null && request.getUserId().longValue() == -1)
                            && !StringUtils.isEmpty(request.getCoopResult())) {
                          // 再設定しません。
                        } else {
                          // 以外の場合、common_settingのCoopResultを利用する
                          request.setCoopResult(coopOrdCd.getCoopResult());
                        }
                        // add 2021-06-17 #5261:TSHPlusにおけるデータのジャーナル反映について 孫 end

                        // エラーメッセージを空にします
                        errorMsg = "";
                        // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                        // break;
                        // 電子カルテ種別
                        String key0 = StringUtils.isEmpty(coopOrdCd.getKey0()) ? "" : coopOrdCd.getKey0();
                        request.setKey0(key0);
                        // 連携版番号
                        String coopVersion  = StringUtils.isEmpty(coopOrdCd.getCoopVersion()) ? "" : coopOrdCd.getCoopVersion();
                        request.setCoopVersion(coopVersion);

                        JournalCreateRequest requestDef = new JournalCreateRequest();
                        BeanUtils.copyProperties(request, requestDef);
                        if (!StringUtils.isEmpty(coopOrdCd.getChangeCrud())) {
                          requestDef.setCrud(coopOrdCd.getChangeCrud());
                        }
                        boolean isDelIns = false;
                        if ("U".equals(requestDef.getCrud())) {
                          // crudがUかつind_dialまたはexam_ord、rad_ordの場合、連携設定によってcrud D & Cに切り替える
                          if ("ind_dial".equals(requestDef.getCoopCd()) || "exam_ord".equals(requestDef.getCoopCd()) || "rad_ord".equals(requestDef.getCoopCd())) {
                            String key1String = "";
                            if ("ind_dial".equals(requestDef.getCoopCd())) {
                              key1String = "DIALYSISSCHESEND";
                            } else if ("exam_ord".equals(requestDef.getCoopCd())) {
                              key1String = "EXAMSCHESEND";
                            } else if ("rad_ord".equals(requestDef.getCoopCd())) {
                              key1String = "XRAYSCHESEND";
                            }
                            String iniInfoVal = "";
                            MstCoopIniInfo info = mstCoopIniDao.selectCoopIniInfo(requestDef.getFacilityCd(),
                                requestDef.getKey0(), key1String, "MODIFY_SEND_CLASS");
                            if (null == info || null == info.getIsEffect() ||
                                ("0".equals(info.getIsEffect())) || "".equals(info.getIsEffect())) {
                              iniInfoVal = "0";
                            } else {
                              iniInfoVal = StringUtils.hasLength(info.getVal()) ? info.getVal() : info.getDefaultV();
                            }

                            if ("2".equals(iniInfoVal)) {
                              requestDef.setCrud("D");
                              isDelIns = true;
                            } else if ("1".equals(iniInfoVal)) {
                              MstCoopIniInfo opeCdListInfo = mstCoopIniDao.selectCoopIniInfo(requestDef.getFacilityCd(),
                                  requestDef.getKey0(), key1String, "MODIFY_SEND_CLASS_1LIST");
                              if (null == opeCdListInfo || null == opeCdListInfo.getIsEffect() ||
                                  ("0".equals(opeCdListInfo.getIsEffect())) || "".equals(opeCdListInfo.getIsEffect())) {
                                iniInfoVal = "";
                              } else {
                                iniInfoVal = StringUtils.hasLength(opeCdListInfo.getVal()) ? opeCdListInfo.getVal() : opeCdListInfo.getDefaultV();
                              }
                              String[] opeCdList = iniInfoVal.split(",");
                              if (Arrays.asList(opeCdList).contains(request.getOpeCd())) {
                                requestDef.setCrud("D");
                                isDelIns = true;
                              }
                            }
                          }
                        }
                        requestsFromDef.add(requestDef);
                        if (isDelIns) {
                          JournalCreateRequest requestDef2 = new JournalCreateRequest();
                          BeanUtils.copyProperties(requestDef, requestDef2);
                          requestDef2.setCrud("C");
                          requestsFromDef.add(requestDef2);
                        }
                        // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } catch (Exception e) {
        errorMsg = "連携設定マスタから、データの取得に失敗しました。" + e.getMessage();
      }

      if (!StringUtils.isEmpty(errorMsg)) {
        ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "連携設定マスタ不正:" + errorMsg);

        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setFacilityCd(request.getFacilityCd());
        eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
        eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
        eventLogMessage.setLogMessage(error.getMessage());
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // mod #7641 自動印刷で値が入らない項目がある 鄭爽 start
        //logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        // return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(error, HttpStatus.OK);
        // mod #7641 自動印刷で値が入らない項目がある 鄭爽 end
      }
    }
    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

    // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 連携版番号の対応より、ジャーナル作成のソースに「createByCoopVersion(ジャーナル作成(連携版番号))」を移動しました。
    // 以下ソースは「createByCoopVersion(ジャーナル作成(連携版番号))」を呼び出した、ジャーナルデータを作成する。

    JournalCreateResult result = new JournalCreateResult(HttpStatus.OK, null, null);
    EventLogMessage eventLogMessage = new EventLogMessage();

    int statusLast = -1;
    int statusVer = -1;
    String errorMsgLast = "";
    JournalCreateResult resultError = new JournalCreateResult(HttpStatus.BAD_REQUEST, null, null);
    List<JournalCreateResult.JournalCreateResults> resultsLast = new ArrayList<>();
    int errorCnt = 0;

    // TODO:7304
    List<SysCoopJournal> journalsFromDef = new ArrayList<>();
    for (JournalCreateRequest requestDef : requestsFromDef) {
      JournalCreateResult resultVer = createByCoopVersion(requestDef);
      if (resultVer != null) {
        statusVer = resultVer.getStatus();
        if (statusVer == HttpStatus.OK.value()) {
          BeanUtils.copyProperties(resultVer, result);
          statusLast = statusVer;
        } else {
          BeanUtils.copyProperties(resultVer, resultError);
        }
        String errorMsgVer = resultVer.getErrorMsg();
        if (!StringUtils.isEmpty(errorMsgVer)) {
          errorMsgLast = errorMsgLast + "<<<E:" + String.valueOf(errorCnt) + ">>>" + errorMsgVer;
        }
        List<JournalCreateResult.JournalCreateResults> resultsVer = resultVer.getResult();
        if (resultsVer != null && resultsVer.size() > 0) {
          resultsLast.addAll(resultsVer);
        }
      }
    }
    if (statusLast != HttpStatus.OK.value()) {
      BeanUtils.copyProperties(resultError, result);
      // add 2023-03-08 bug #8424 バックアップファイルのOK/NGフォルダへの移動 孫 start
      int httpValue = result.getStatus();
      return new ResponseEntity<>(result, HttpStatus.resolve(httpValue));
      // add 2023-03-08 bug #8424 バックアップファイルのOK/NGフォルダへの移動 孫 end
    }

    // add 2023-03-08 bug #8424 バックアップファイルのOK/NGフォルダへの移動 孫 start
    // (R:受信)電文の場合、正常に戻る
    if (JournalConvertConstants.DIRECTION_RECEIVE.equals(request.getDirection())) {
      /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --start */
      if (result.getStatus() == HttpStatus.OK.value()) {
        List<Long> ctlNoList = new ArrayList<>();
        if (result.getResult() != null && result.getResult().size() > 0) {
          ctlNoList.addAll(result.getResult().stream().map(e -> e.getCtlNo()).collect(Collectors.toList()));
        }

        if (ctlNoList.size() > 0) {
          // 電文を分解すると受信インタフェースからここに移動することが多い
          List<SysCoopJournal> sysCoopJournalList = convertCommonService.updateJournalListExamRst(request.getFacilityCd(), ctlNoList);
          if (sysCoopJournalList.size() > 0) {
            // 分割された結果セットが返される
            result = new JournalCreateResult(HttpStatus.OK, sysCoopJournalList, null);
          }
        }
      }
      /* add by chamaojia 2023-05-22 検査結果1 file多患者受信時のデータ分割処理とIFedgeファイル移動処理の競合  --end */
      return new ResponseEntity<>(result, HttpStatus.OK);
    }
    // add 2023-03-08 bug #8424 バックアップファイルのOK/NGフォルダへの移動 孫 end
    // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // mod #8435 exam_ord連携 最適化処理が一部にしか行われない 2023-03-09 卓 start
    /* modify by chamaojia 2023-02-01 [7050] ordNo NULL値を追加するための判断条件 --start */
    // mod 2023-02-08 #7781 start
    if (JournalConvertConstants.DIRECTION_SEND.equals(request.getDirection())) {
      // if (request.getOrdNo() != null) {
      // mod 2023-02-08 #7781 end
      // #7239 mod 処理保留イベントの最適化処理が行われない 卓 start
      // 送信しない設定
      SysCoopJournal skipSysCoopJournal = new SysCoopJournal();
      skipSysCoopJournal.setFacilityCd(request.getFacilityCd());
      skipSysCoopJournal.setOrdNo(request.getOrdNo());
      skipSysCoopJournal.setPatId(request.getPatId());
      skipSysCoopJournal.setHospPatId(request.getHospPatId());
      skipSysCoopJournal.setCoopCd(request.getCoopCd());
      journalConvertSendService.updateToSkip(skipSysCoopJournal);
      // #7239 mod 処理保留イベントの最適化処理が行われない 卓 end
    }
    /* modify by chamaojia 2023-02-01 [7050] ordNo NULL値を追加するための判断条件 --end */
    // mod #8435 exam_ord連携 最適化処理が一部にしか行われない 2023-03-09 卓 end
    // mod #10336 DBが高負荷になる（外部連携由来）2 start
    /*
    //#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 start
    Boolean remainJournal = true;
    while (remainJournal) {
      //#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 end

      // add 2021-03-24 No717,730：多重APIコールによる処理負荷増加回避対策 孫 start
    // 課題No.11:もし連携APIが停止した場合の対応がない
    // 全施設で１処理のため、停止してしまうと全施設の連携に影響がでてしまう

      // 施設ステータスをチェックする
      if (facilityStatus.containsKey(request.getFacilityCd())) {
        // 施設がありの場合、施設ステータスをチェックする
        if (JournalConvertConstants.STATUS_START.equals(facilityStatus.get(request.getFacilityCd()))) {
          // 施設が「実行(start)」の場合、正常に戻る
          return new ResponseEntity<>(result, HttpStatus.OK);
        } else {
          // 施設が「停止(stop)」の場合、施設ステータスに「実行(start)」を設定する、続行
          facilityStatus.replace(request.getFacilityCd(), JournalConvertConstants.STATUS_START);
        }
      } else {
        //　施設が無しの場合、施設ステータスに「実行(start)」を追加する、続行
        facilityStatus.put(request.getFacilityCd(), JournalConvertConstants.STATUS_START);
      }
      eventLogMessageTemp.setLogMessage("$$$$$$/journal/create 1.6 : " + (System.currentTimeMillis() - startTime));
      logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);

      // 一つ施設の変換対象ジャーナル
      try {
        eventLogMessageTemp.setLogMessage("$$$$$$/journal/create 1.6.1 : " + (System.currentTimeMillis() - startTime));
        logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
        do {


          // 変換対象ジャーナル取得
          List<SysCoopJournal> journalList = convertCommonService.getJournalList(request.getFacilityCd()
            , JournalConvertConstants.DIRECTION_SEND
            , NtssCoopApiConstants.CoopResult.UNPROCESS.getResult()
     */
    /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --start *//*
                                                                                  
                                                                                  */
    /* add by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加 --start *//*

            // なしはnull値を入力します
            , null, request.getOrdNo(), request.getPatId());
                                                                     */
    /* add by chamaojia 2023-01-10 [7050] インタフェースパラメータの追加 --end *//*
                                                                  
                                                                  */
    /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --end *//*


          // 対象ジャーナルが1件も存在しない場合、実行を停止
          if (CollectionUtils.isEmpty(journalList)) {
            //mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 start
            //          break;
            journalList = convertCommonService.getJournalList(request.getFacilityCd()
              , JournalConvertConstants.DIRECTION_SEND
              , NtssCoopApiConstants.CoopResult.UNPROCESS.getResult()
              , null, null, null);
            if (CollectionUtils.isEmpty(journalList)) {
              break;
            }
            //mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 end

          }
          //mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 start

          // 対象ジャーナルがあり、データを一つずつ処理する
          // ジャナル生成APIから変換APIに通知し、ジャナル変換APIで電文変換を行う。
          for (SysCoopJournal journal : journalList) {
            JournalConvertSendRequest requestConvert = new JournalConvertSendRequest();
            requestConvert.setFacilityCd(journal.getFacilityCd());
            requestConvert.setOrdNo(journal.getOrdNo());
            requestConvert.setPatId(journal.getPatId());
            requestConvert.setHospPatId(journal.getHospPatId());
            requestConvert.setUserId(journal.getUserId());
            requestConvert.setCoopCd(journal.getCoopCd());

            // ジャーナル変換処理
                                                                                 */
    /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --start *//*

            JournalConvertResult resultConvert = journalConvertSendService.convert(requestConvert, requestConvert.getOrdNo(), requestConvert.getPatId());
                                                                                   */
    /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --end *//*

            if (resultConvert.getStatus() == HttpStatus.OK.value()) {
              // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
              if (doJournal.isDieFlagResultMap.size() > 0) {
                // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
                //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 start
                if ("D".equals(crud) && "1".equals(doJournal.isDieFlagResultMap.get(requestConvert.getHospPatId()))) {
                  Optional<SysCoopJournalExtends> sc = doJournal.scList.stream().filter(sysCoopJournal ->
                    sysCoopJournal.getHospPatId().equals(requestConvert.getHospPatId()) && sysCoopJournal.getCoopCd().equals(requestConvert.getCoopCd())).findFirst();
                  if (sc.isPresent()) {
                    //del 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi start
//                Long ordNo = sc.get().getOrdNo();
//                String baseDate = sc.get().getBaseDate();
//                request.setOrdNo(ordNo);
//                request.setBaseDate(baseDate);
                    //del 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi end
                    doJournal.scList.remove(sc.get());
                  }
                }
                //add 6993 profile連携で受信した生存の有無登録 zhaoqi 20221020 end
                //del 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi start
                // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
//            JournalUpdateRequest request2 = new JournalUpdateRequest();
//            request2.setAnaResult(request.getAnaResult());
//            request2.setBaseDate(request.getBaseDate());
//            request2.setCoopResult(request.getCoopResult());
//            request2.setMessage(request.getMessage());
//            request2.setOrdNo(request.getOrdNo());
//            request2.setUserId(request.getUserId());
//            journalService.update(request2);
                //del 6993 【デグレ】profile連携で受信した生存の有無登録 20221123 zhaoqi end
              }
              // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end

              // 成功、かつ、正常データがあり場合
              List<ResultMap> resultList = resultConvert.getResult();
              //     #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 start
              if (resultList.size() == 1) {
                String msg = (String) resultConvert.getResult().get(0).get("message");
                if (msg.contains(JournalConstant.JOURNAL_EMPTY)) {
                  JournalConvertLogUtil.eventMessageError("ジャナル変換API:電文変換失敗。", requestConvert.getFacilityCd(),
                    (requestConvert.getPatId() == null ? "" : requestConvert.getPatId().toString()),
                    (requestConvert.getUserId() == null ? "" : requestConvert.getUserId().toString()),
                    this.getClass().getName());
                  continue;
                }
              }
              //     #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 end
              for (ResultMap resultTmp : resultList) {
                if (AnaResult.DONE.getResult().equals(resultTmp.get(ResultKey.ANA_RESULT.getKey()))) {
                  // WebSocketでIFedgeを連携する
                  // ジャナル変換APIからIFエッジ(サーバへの電文リクエスト)に通知。
                  // mod 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
//              if (!ifEdgeService.SendJournal(request)) {
                  JournalDeliveryRequest requestDelivery = new JournalDeliveryRequest();
                  requestDelivery.setFacilityCd(requestConvert.getFacilityCd());
                  requestDelivery.setSendType("delivery");
                  if (!ifEdgeService.SendJournal(requestDelivery)) {
                    // mod 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end
                    eventLogMessage.setUserId((requestConvert.getUserId() == null ? "" : requestConvert.getUserId().toString()));
                    eventLogMessage.setPatId((requestConvert.getPatId() == null ? "" : requestConvert.getPatId().toString()));
                    eventLogMessage.setInvokeClass(this.getClass().getName());
                    eventLogMessage.setLogMessage("ジャナル変換API：IFエッジ(サーバへの電文リクエスト)に通知失敗。");
                    eventLogMessage.setFacilityCd(requestConvert.getFacilityCd());
                    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                  }
                  break;
                }
              }
              // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 start
//        } else if (resultConvert.getStatus() != HttpStatus.NO_CONTENT.value()) {
            }
            //     #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 start
//        else if (resultConvert.getStatus() != HttpStatus.NOT_FOUND.value()) {
//          // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 end
//          // 失敗の場合
//          eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
//          eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
//          eventLogMessage.setInvokeClass(this.getClass().getName());
//          eventLogMessage.setLogMessage("ジャナル変換API:電文変換失敗。");
//          eventLogMessage.setFacilityCd(request.getFacilityCd());
//          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//
//          break;
//        }
            //     #8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-02-21 end
          }
        } while (true);
        //　施設ステータスに「停止(stop)」を設定する
        facilityStatus.put(request.getFacilityCd(), JournalConvertConstants.STATUS_STOP);
        //mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 end
        eventLogMessageTemp.setLogMessage("$$$$$$/journal/create 1.6.2 : " + (System.currentTimeMillis() - startTime));
        logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
      } catch (Exception ex) {
        //mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 start
        //　施設ステータスに「停止(stop)」を設定する
        facilityStatus.put(request.getFacilityCd(), JournalConvertConstants.STATUS_STOP);
        //mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 end

        // ジャーナル作成としては 正常として処理するため、何もしない
        eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
        eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
        eventLogMessage.setInvokeClass(this.getClass().getName());
        eventLogMessage.setLogMessage("ジャーナル変換処理の呼び出しでエラーが発生しました。Message:" + ex.getMessage());
        eventLogMessage.setFacilityCd(request.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
      //#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 start
      Long journalCount = convertCommonService.getJournalListCount(request.getFacilityCd()
        , JournalConvertConstants.DIRECTION_SEND
        , NtssCoopApiConstants.CoopResult.UNPROCESS.getResult()
        , null, null, null);
      if (journalCount == 0) {
        remainJournal = false;
      }
    }
    //#8350  mod ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 卓 2023-04-26 end
                                                                                 */
    // mod #10336 DBが高負荷になる（外部連携由来）2 end
    eventLogMessageTemp.setLogMessage("$$$$$$/journal/create 1.7 : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    //mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 start
    //　施設ステータスに「停止(stop)」を設定する
//    facilityStatus.put(request.getFacilityCd(), JournalConvertConstants.STATUS_STOP);
    // mod #8350 ini_dial連携受信時のprofile連携（要求）が処理されず患者属性の更新ができないことがある 2023-03-09 卓 end

    // add 2021-03-24 No717,730：多重APIコールによる処理負荷増加回避対策 孫 end

    eventLogMessageTemp.setLogMessage("$$$$$$/journal/create end : " + (System.currentTimeMillis() - startTime));
    logService.log(LogLevel.INFO, eventLogMessageTemp, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  // mod 2023-01-14 bug #7627 修正 chen end
  // add #10336 DBが高負荷になる（外部連携由来）2 start
  public void lockConvert(JournalCreateRequest request) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    String crud = request.getCrud();
    // 施設ステータスをチェックする. 施設がなし、あるいは「停止(stop)」の場合、施設ステータスに「実行(start)」を設定
    if (!facilityStatusService.checkAndPutStatus(request.getFacilityCd())) {
      return;
    }
    try {
      List<SysCoopJournal> journalList = convertCommonService.getJournalList(request.getFacilityCd()
        , JournalConvertConstants.DIRECTION_SEND
        , NtssCoopApiConstants.CoopResult.UNPROCESS.getResult()
        , null, request.getOrdNo(), request.getPatId());
      for (SysCoopJournal journal : journalList) {
        JournalConvertSendRequest requestConvert = new JournalConvertSendRequest();
        requestConvert.setFacilityCd(journal.getFacilityCd());
        requestConvert.setOrdNo(journal.getOrdNo());
        requestConvert.setPatId(journal.getPatId());
        requestConvert.setHospPatId(journal.getHospPatId());
        requestConvert.setUserId(journal.getUserId());
        requestConvert.setCoopCd(journal.getCoopCd());
        // ジャーナル変換処理
        JournalConvertResult resultConvert = journalConvertSendService.convert(requestConvert, requestConvert.getOrdNo(), requestConvert.getPatId());
        if (resultConvert.getStatus() == HttpStatus.OK.value()) {
          // del #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
          // if (doJournal.isDieFlagResultMap.size() > 0) {
//            if ("D".equals(crud) && "1".equals(doJournal.isDieFlagResultMap.get(requestConvert.getHospPatId()))) {
//              Optional<SysCoopJournalExtends> sc = doJournal.scList.stream().filter(sysCoopJournal ->
//                sysCoopJournal.getHospPatId().equals(requestConvert.getHospPatId()) && sysCoopJournal.getCoopCd().equals(requestConvert.getCoopCd())).findFirst();
          // if (sc.isPresent()) {
          // doJournal.scList.remove(sc.get());
          // }
          // }
          // }
          // del #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end
          // 成功、かつ、正常データがあり場合
          List<ResultMap> resultList = resultConvert.getResult();
          if (resultList.size() == 1) {
            String msg = (String) resultConvert.getResult().get(0).get("message");
            if (msg.contains(JournalConstant.JOURNAL_EMPTY)) {
              JournalConvertLogUtil.eventMessageError("ジャナル変換API:電文変換失敗。", requestConvert.getFacilityCd(),
                  (requestConvert.getPatId() == null ? "" : requestConvert.getPatId().toString()),
                  (requestConvert.getUserId() == null ? "" : requestConvert.getUserId().toString()),
                  this.getClass().getName());
              continue;
            }
          }
          for (ResultMap resultTmp : resultList) {
            if (AnaResult.DONE.getResult().equals(resultTmp.get(ResultKey.ANA_RESULT.getKey()))) {
              JournalDeliveryRequest requestDelivery = new JournalDeliveryRequest();
              requestDelivery.setFacilityCd(requestConvert.getFacilityCd());
              requestDelivery.setSendType("delivery");
              if (!ifEdgeService.SendJournal(requestDelivery)) {
                eventLogMessage.setUserId((requestConvert.getUserId() == null ? "" : requestConvert.getUserId().toString()));
                eventLogMessage.setPatId((requestConvert.getPatId() == null ? "" : requestConvert.getPatId().toString()));
                eventLogMessage.setInvokeClass(this.getClass().getName());
                eventLogMessage.setLogMessage("ジャナル変換API：IFエッジ(サーバへの電文リクエスト)に通知失敗。");
                eventLogMessage.setFacilityCd(requestConvert.getFacilityCd());
                logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              }
              break;
            }
          }
        }
      }
    } catch (Exception ex) {
      // ジャーナル作成としては 正常として処理するため、何もしない
      eventLogMessage.setUserId((request.getUserId() == null ? "" : request.getUserId().toString()));
      eventLogMessage.setPatId((request.getPatId() == null ? "" : request.getPatId().toString()));
      eventLogMessage.setInvokeClass(this.getClass().getName());
      eventLogMessage.setLogMessage("ジャーナル変換処理の呼び出しでエラーが発生しました。Message:" + ex.getMessage());
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } finally {
      //　施設ステータスに「停止(stop)」を設定する
      facilityStatusService.replace(request.getFacilityCd(), JournalConvertConstants.STATUS_STOP);
    }
  }
  // add #10336 DBが高負荷になる（外部連携由来）2 end

  // add 2021-06-22 #5264:ソケット接続に失敗した場合にリトライしない 孫 start
  /**
   * 再配信処理(/journal/redelivery)
   * @param request : {@link JournalDeliveryRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/redelivery")
  public ResponseEntity<?> redelivery(@RequestBody JournalDeliveryRequest request) {
    if (StringUtils.isEmpty(request.getFacilityCd())) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "リクエストパラメータが不正または不足しています。facility_cd:[" + request.getFacilityCd() + "]");
      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setLogMessage(error.getMessage());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }
    // add by shiyw 2023-03-17: Used to ensure that "LogAspector.outputLog()" can get facility_cd
    LogAspector.setCurrentRequestFacilityCd(request.getFacilityCd());

    // WebSocketでIFedgeを連携する
    // ジャナル変換APIからIFエッジ(サーバへの電文リクエスト)に通知。
    JournalDeliveryRequest requestDelivery = new JournalDeliveryRequest();
    requestDelivery.setFacilityCd(request.getFacilityCd());
    requestDelivery.setSendType(request.getSendType());
    if (!ifEdgeService.SendJournal(requestDelivery)) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "ジャナル変換API：IFエッジ(サーバへの電文リクエスト)に通知失敗。facility_cd:[" + request.getFacilityCd() + "]");
      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setLogMessage(error.getMessage());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // mod #9406 外部連携稼働ビューア API呼び出しに失敗する 20230811 孟堅　start
      // return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
      // mod #9406 外部連携稼働ビューア API呼び出しに失敗する 20230811 孟堅　end
    }
    return new ResponseEntity<>(request, HttpStatus.OK);
  }
  // add 2021-06-22 #5264:ソケット接続に失敗した場合にリトライしない 孫 end

  /**
   * 配信処理(/journal/delivery)
   * @param request : {@link JournalDeliveryRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/delivery")
  public ResponseEntity<?> delivery(@RequestBody JournalDeliveryRequest request) {
    if (StringUtils.isEmpty(request.getFacilityCd())) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "リクエストパラメータが不正または不足しています。facility_cd:[" + request.getFacilityCd() + "]");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setLogMessage(error.getMessage());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end

      // パラメータ不正(施設コードが無し)の場合、通知機能API（NotificationApiCallUtil）を呼び出さない

      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    // add by shiyw 2023-03-17: Used to ensure that "LogAspector.outputLog()" can get facility_cd
    LogAspector.setCurrentRequestFacilityCd(request.getFacilityCd());

    // #8031 add 2022-10-25 journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 start
    // 通知用リスト
    List<JournalDistribute> notificationList = new ArrayList<>();
    EventLogMessage eventLogMessage = new EventLogMessage();
    DeliveryResults results = null;
    List<JournalDistribute> journalList = new ArrayList<>();
    // sendTypeが"retry"以外の場合、配信ステータスをチェックする
    if (!"retry".equals(request.getSendType())) {
      // 0件と同じ空の結果を用意
      results = new DeliveryResults();
      results.setResult(new ArrayList<>());
      results.setStatus(HttpStatus.OK.value());
      // 対象施設が無しの場合、施設ステータスに「実行(start)」を追加する
      String oldStatus = deliveryStatus.putIfAbsent(request.getFacilityCd(), JournalConvertConstants.STATUS_START);
      if (oldStatus == null) {
        // 配信ステータスにkey: facilityCd, value:「実行(start)」を追加成功。何もせず配信処理に続く
      } else if (JournalConvertConstants.STATUS_START.equals(oldStatus)) {
        // 対象施設が既に「実行(start)」の場合、他スレッドで配信実行中
        // 空の結果をreturnして終了
        return new ResponseEntity<>(results, HttpStatus.OK);
      } else if (JournalConvertConstants.STATUS_STOP.equals(oldStatus)) {
        // 対象施設が「停止(stop)」の場合、配信ステータスに「実行(start)」を設定
        if (deliveryStatus.replace(request.getFacilityCd(), JournalConvertConstants.STATUS_STOP, JournalConvertConstants.STATUS_START)) {
          // 配信ステータスを「実行(start)」に更新成功。何もせず配信処理に続く
        } else {
          // 配信ステータスを「実行(start)」に更新できなかった場合、他スレッドで配信実行中
          // 空の結果をreturnして終了
          return new ResponseEntity<>(results, HttpStatus.OK);
        }
      } else {
        return new ResponseEntity<>(results, HttpStatus.OK);
      }
    }

    try {
      // 配信処理
      DeliverSendResult deliverSendResult = deliveryService.delivery(request);
      journalList = deliverSendResult.getJournalDistributeList();
      results = deliverSendResult.getDeliveryResults();

      // 配信ステータスがE1のデータ場合、通知処理を行う。
      notificationList.addAll(journalList);
      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
      // 配信ステータスがE1のデータ場合、通知処理を行う。
      if (journalList.size() != notificationList.size()) {
        notificationList.removeAll(journalList);
        NotificationForDelivery(notificationList);
      }
      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
    } catch (Exception e) {
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      eventLogMessage.setLogMessage("配信APIにて例外が発生しました。Message:" + e.getMessage());
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
      // 通知処理を行う。
      NotificationForDelivery(notificationList);
      // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "配信APIにて例外が発生しました。");
      return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    } finally {
      // 配信ステータスを「実行(start)」から「停止(stop)」に変更
      deliveryStatus.replace(request.getFacilityCd(), JournalConvertConstants.STATUS_STOP);
    }
    // #8031 add 2022-10-25 journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 end

    // #8031 del 2022-10-25 journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 start
    // // mod 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
////    List<JournalDistribute> journalList = deliveryService.getDeliveryList(request.getFacilityCd());
    // List<JournalDistribute> journalList = new ArrayList<>();
//    if (!StringUtils.isEmpty(request.getSendType()) && "retry".equals(request.getSendType())) {
    // // リトライ配信場合
    // journalList = deliveryService.getRetryDeliveryList(request.getFacilityCd());
    // } else {
    // journalList = deliveryService.getDeliveryList(request.getFacilityCd());
    // }
    // // mod 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end
    //
    // // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    // // 通知用リスト
    // List<JournalDistribute> notificationList = new ArrayList<>();
    // // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
    //
    // EventLogMessage eventLogMessage = new EventLogMessage();
    // DeliveryResults results;
    // try {
    // // add 2020-12-14 FNSI-改修 外部連携720(「修正」のデータは複数作られた場合、最新のデータだけ配信する) 夏 start
    // // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
    // // リトライ配信以外の場合
//      if (StringUtils.isEmpty(request.getSendType()) || !"retry".equals(request.getSendType())) {
    // // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end
    // // 送信用の配信リストを作成する。
    // List<JournalDistribute> journalListTemp = new ArrayList<>();
    // // upd 2022-08-10 修改 【デグレ】削除電文の連携オーダ番号が取得できない場合の修正 #7781 xmj start
    // journalListTemp.addAll(journalEdit(journalList));
    //// journalListTemp.addAll(journalEdit(journalList,"C"));
    //// journalListTemp.addAll(journalEdit(journalList,"U"));
    //// journalListTemp.addAll(journalEdit(journalList,"D"));
    // // upd 2022-08-10 修改 【デグレ】削除電文の連携オーダ番号が取得できない場合の修正 #7781 xmj end
    // journalList.clear();
    // journalList=journalListTemp;
    // // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
    // }
    // // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end
    // // add 2020-12-14 FNSI-改修 外部連携720(「修正」のデータは複数作られた場合、最新のデータだけ配信する) 夏 end
    //
    // // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    // notificationList.addAll(journalList);
    // // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
    //
    // // もらったジャーナルの配信ステータスを全て"1"(処理中)に更新する
    // deliveryService.updateProcessingByCoopResult(journalList);
    // results = deliveryService.execute(journalList);
    //
    // // 事後APIキック機能
    // for (JournalDistribute journalDistribute : journalList) {
    // CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
    // BeanUtils.copyProperties(journalDistribute, callApiJournalRequest);
    // callApiJournalRequest.setApiTimingIo(ApiTimingIoStatus.DELIVERY.getStatus());
    // callApiJournalRequest.setApiTimingBa(ApiTimingBaStatus.AFTER.getStatus());
    // // mod 2021-04-07 課題No.1:SQL呼び出しを追加 孫 start
////        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, null, null);
    // SysCoopJournal journalForApi = new SysCoopJournal();
    // BeanUtils.copyProperties(journalDistribute, journalForApi);
//        boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journalForApi, null);
    // // mod 2021-04-07 課題No.1:SQL呼び出しを追加 孫 end
    // if (!callResult) {
    // break;
    // }
    // }
    //
    // // もらったジャーナルの配信ステータスを全て"8"(応答待ち)に更新する
    // deliveryService.updateWaitingByCoopResult(journalList);
    //
    // // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    // // 配信ステータスがE1のデータ場合、通知処理を行う。
    // if (journalList.size() != notificationList.size()) {
    // notificationList.removeAll(journalList);
    // NotificationForDelivery(notificationList);
    // }
    // // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
    // } catch (NtssException e) {
    // // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    // eventLogMessage.setInvokeClass(this.getClass().getName());
    // // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    // eventLogMessage.setLogMessage("配信APIにて例外が発生しました。Message:" + e.getMessage());
    // eventLogMessage.setFacilityCd(request.getFacilityCd());
//      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //
    // // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    // // 通知処理を行う。
    // NotificationForDelivery(notificationList);
    // // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
    //
//      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "配信APIにて例外が発生しました。");
    // return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    // }
    // #8031 del 2022-10-25 journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 end

    // エッジヘルスモニタ更新処理の呼び出し
    try {
      healthService.update(request);
    } catch (Exception e) {
      // 配信処理としては 正常として処理するため、何もしない
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      eventLogMessage.setLogMessage("エッジヘルスモニタ更新処理の呼び出しでエラーが発生しました。Message:" + e.getMessage());
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    // HttpHeaderの"Title"に後続処理(afterCompletion)で削除するファイルのctl_Noを"_"区切りで連結した文字列を設定する
    HttpHeaders headers = new HttpHeaders();
    String ctlNoList = "";
    List<DeliveryResult> tmpResultList = results.getResult();
    for (DeliveryResult result : tmpResultList) {
      ctlNoList += result.getJournalInfo().getCtlNo() + "_";
    }
    headers.add("Title", ctlNoList);
    return new ResponseEntity<>(results, headers, HttpStatus.OK);

  }

  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  /**
   * 配信処理の通知処理を行う
   *
   * @param journalList 通知対象
   * @return 無し
   * */
  private void NotificationForDelivery(List<JournalDistribute> journalList) {
    for (JournalDistribute ournal : journalList) {
      // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//      notificationApiCallUtil.registerNotification(ournal.getFacilityCd(), ournal.getCoopCd(), ournal.getHospPatId(),
      // ournal.getBaseDate());
      SysCoopJournal journal = new SysCoopJournal();
      BeanUtils.copyProperties(ournal, journal);
      journal.setUserId(Long.valueOf(ournal.getLogUserId()));
      coopJournalErrorComponent.sendCoopJournalError(journal);
      // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
    }
  }

  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
  /**
   * ジャーナルの変換ステータスを更新する
   * ※レコード単位での更新
   *
   * @param journal 更新対象のジャーナル
   * @param message メッセージ
   * @param status  更新する変換ステータス
   * @return 更新件数
   * */
  private int updateAnaResult(SysCoopJournal journal, String message, NtssCoopApiConstants.AnaResult status) {
    journal.setAnaResult(status.getResult());
    journal.setMessage(message);
    return convertCommonService.updateAnaResult(journal.getCtlNo(), message, status.getResult());
  }
  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end

  // #8031 del 2022-10-25 journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 start
  // add 2020-12-14 FNSI-改修 外部連携720(「修正」のデータは複数作られた場合、最新のデータだけ配信する) 夏 start
  // add 2022-07-29 修改 【デグレ】削除電文の連携オーダ番号が取得できない場合の修正 #7781 xmj start
//  private List<JournalDistribute> journalEdit(List<JournalDistribute> journalList){
  // // upd 2022-08-10 修改 【デグレ】削除電文の連携オーダ番号が取得できない場合の修正 #7781 xmj start
////  private List<JournalDistribute> journalEdit(List<JournalDistribute> journalList,String type){
  // // upd 2022-08-10 修改 【デグレ】削除電文の連携オーダ番号が取得できない場合の修正 #7781 xmj end
//    Map<String, JournalDistribute> journalListMapC = new HashMap<String, JournalDistribute>();
//    Map<String, JournalDistribute> journalListMapU = new HashMap<String, JournalDistribute>();
//    Map<String, JournalDistribute> journalListMapD = new HashMap<String, JournalDistribute>();
//    List<JournalDistribute> JournalDistributeListS = new ArrayList<JournalDistribute>();
  // StringBuilder keyTmp = null;
  // String key = null;
  // for (JournalDistribute journal : journalList) {
  // keyTmp = new StringBuilder();
  // keyTmp.append(journal.getCoopCd());
  // keyTmp.append(",");
  // keyTmp.append(journal.getCoopCdIndex());
  // keyTmp.append(",");
  // keyTmp.append(journal.getOrdNo());
  // keyTmp.append(",");
  // keyTmp.append(journal.getCoopOrdNo());
  // key = keyTmp.toString();
  // if ("C".equals(String.valueOf(journal.getCrud()))) {
  // if (!journalListMapD.containsKey(key)) {
  // journalListMapC.put(key, journal);
  // } else {
  // JournalDistributeListS.add(journalListMapD.get(key));
  // JournalDistributeListS.add(journal);
  // journalListMapD.remove(key);
  // }
  // }
  // if ("U".equals(String.valueOf(journal.getCrud()))) {
  // if (!journalListMapD.containsKey(key)) {
  // if (journalListMapU.containsKey(key)) {
  // if (journalListMapU.get(key).getCtlNo() < journal.getCtlNo()) {
  // JournalDistributeListS.add(journalListMapU.get(key));
  // journalListMapU.put(key, journal);
  // }
  // } else {
  // journalListMapU.put(key, journal);
  // }
  // }
  // }
  // if ("D".equals(String.valueOf(journal.getCrud()))) {
  // if (!journalListMapC.containsKey(key)) {
  // journalListMapD.put(key, journal);
  // } else {
  // JournalDistributeListS.add(journalListMapC.get(key));
  // JournalDistributeListS.add(journal);
  // journalListMapC.remove(key);
  // }
  // if (journalListMapU.containsKey(key)) {
  // JournalDistributeListS.add(journalListMapU.get(key));
  // journalListMapU.remove(key);
  // }
  // }
  // }
//    List<JournalDistribute> JournalDistributeList = new ArrayList<JournalDistribute>();
//    for (Map.Entry<String, JournalDistribute> entry : journalListMapC.entrySet()) {
  // JournalDistributeList.add(entry.getValue());
  // }
//    for (Map.Entry<String, JournalDistribute> entry : journalListMapU.entrySet()) {
  // JournalDistributeList.add(entry.getValue());
  // }
//    for (Map.Entry<String, JournalDistribute> entry : journalListMapD.entrySet()) {
  // JournalDistributeList.add(entry.getValue());
  // }
  // deliveryService.updateSkipByCoopResult(JournalDistributeListS);
  // return JournalDistributeList;
  // }
  // Add 2022-07-29 修改 【デグレ】削除電文の連携オーダ番号が取得できない場合の修正 #7781 xmj end
  // #8031 del 2022-10-25 journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 start

  // del 2022-07-29 修改 【デグレ】削除電文の連携オーダ番号が取得できない場合の修正 #7781 xmj start
  // List<JournalDistribute> journalListTemp = new ArrayList<>();
  // JournalDistribute journalDistribute = new JournalDistribute();
  // List<JournalDistribute> journalDistributeList = new ArrayList<>();
  //
  // // ジャーナル毎に取得
  // for (JournalDistribute journal : journalList) {
  // // 通信結果がスキップ以外のジャーナルが配信対象。
//        if (!String.valueOf(NtssCoopApiConstants.CoopResult.SKIP.getResult()).equals(String.valueOf(journal.getCoopResult()))) {
  // // ジャーナルの作成更新区分を判定する
  // if (type.equals(String.valueOf(journal.getCrud()))) {
  // // 作成更新区分：「修正」のデータの場合、最新のデータを取得する。
  // journalDistributeList.clear();
  // journal.setCoopResult(NtssCoopApiConstants.CoopResult.SKIP.getResult());
  // journalDistributeList.add(journal);
  // int count = 0;
  // for (JournalDistribute journalOrd : journalList) {
//              // 管理番号同じ または　作成更新区分：修正以外の場合、対象外として
//              if (String.valueOf(journalOrd.getCtlNo()).equals(String.valueOf(journal.getCtlNo())) ||
  // !type.equals(String.valueOf(journalOrd.getCrud()))) {
  // count++;
  // continue;
//              } else if (String.valueOf(journalOrd.getCoopCd()).equals(String.valueOf(journal.getCoopCd())) &&
//                String.valueOf(journalOrd.getCoopCdIndex()).equals(String.valueOf(journal.getCoopCdIndex())) &&
//                String.valueOf(journalOrd.getOrdNo()).equals(String.valueOf(journal.getOrdNo())) &&
//                String.valueOf(journalOrd.getCoopOrdNo()).equals(String.valueOf(journal.getCoopOrdNo()))) {
  // // 「修正」のデータは複数作られた場合、最新のデータだけ配信する。
  // journalDistribute = journalOrd;
  // journalDistributeList.add(journalDistribute);
  // // 複数データがスキップをセットする
  // journalOrd.setCoopResult(NtssCoopApiConstants.CoopResult.SKIP.getResult());
  // journalList.set(count, journalOrd);
  // }
  // count++;
  // }
  //
  // if (journalDistributeList.size() > 1) {
  // // 最新のデータは「S:スキップ」に更新しません。
  // journalDistributeList.remove(journalDistribute);
  // // DBに配信処理ステータスを「S:スキップ」に更新する。
  // deliveryService.updateSkipByCoopResult(journalDistributeList);
  // }else{
  // journalDistribute = journal;
  // }
  // // 最新のデータは配信リストに追加する。
  // journalListTemp.add(journalDistribute);
  // }
  // }
  // }
  // return journalListTemp;
  // }
  // del 2022-07-29 修改 【デグレ】削除電文の連携オーダ番号が取得できない場合の修正 #7781 xmj end
  // add 2020-12-14 FNSI-改修 外部連携720(「修正」のデータは複数作られた場合、最新のデータだけ配信する) 夏 end

  // add 2022-07-22 bug 7351 修正 profile連携の取り込み結果の判断処理追加 chen start
  /**
   * ジャーナル更新(/journal/timeoutid)
   * @param requests : {@link ArrayList<JournalTimeoutRequest>}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/timeoutid")
  public ResponseEntity<?> timeoutid(@RequestBody ArrayList<JournalTimeoutRequest> requests) {
    JournalTimeoutResult result = new JournalTimeoutResult(HttpStatus.OK, "", -1L);
    // [取込タイムアウト時間]以内にリネームを検知できなかった場合、FNWクライアントに取込みが失敗した旨を通知し
    for (JournalTimeoutRequest request : requests) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      Date baseDate = new Date(request.getIdtime());
      SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");
      formatter.setTimeZone(TimeZone.getDefault());
      // modify 9583 by kangjie 20240401 start 通知一覧の連携エラー通知の遷移不正
//      notificationApiCallUtil.registerNotification(request.getFacilityCd(), request.getCoopCd(),
      // request.getId().toString(), formatter.format(baseDate));
      SysCoopJournal journal = new SysCoopJournal();
      BeanUtils.copyProperties(request, journal);
      coopJournalErrorComponent.sendCoopJournalError(journal);
      // modify 9583 by kangjie 20240401 end 通知一覧の連携エラー通知の遷移不正
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  // add 2022-07-22 bug 7351 修正 profile連携の取り込み結果の判断処理追加 chen end

  // #6993-profile連携で受信した生存の有無登録 周 20230204 add start
  /**
   * sql実行(/journal/setExamOrdSkip)
   * @param request : {@link JournalCreateRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/setExamOrdSkip")
  public ResponseEntity<?> setExamOrdSkip(@RequestBody JournalCreateRequest request) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("/journal/setExamOrdSkip start ");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    try {
      if (StringUtils.isEmpty(request.getFacilityCd())) {
        ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "連携設定マスタ不正:施設連携設定が存在しません。");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
      }
      // add by shiyw 2023-03-17: Used to ensure that "LogAspector.outputLog()" can get facility_cd
      LogAspector.setCurrentRequestFacilityCd(request.getFacilityCd());

      // int upJournalCnt = journalService.upExamOrdJournalToSkip(request);
      // if(upJournalCnt >= 1) {
      // request.setCoopResult(NtssCoopApiConstants.CoopResult.SKIP.getResult());
      // }
      journalService.upExamOrdJournalToSkip(request);
    } catch (Exception ex) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "スキップ処理異常:" + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    JournalCreateResult result = new JournalCreateResult(HttpStatus.OK, null, null);
    eventLogMessage.setLogMessage("/journal/setExamOrdSkip end ");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  // #6993-profile連携で受信した生存の有無登録 周 20230204 add end

  /**
   * sql実行(/journal/setReportDialSkip)
   * @param request : {@link JournalCreateRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/setReportDialSkip")
  public ResponseEntity<?> setReportDialSkip(@RequestBody JournalCreateRequest request) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("/journal/setReportDialSkip start ");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    try {
      if (!StringUtils.hasLength(request.getFacilityCd())) {
        ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "施設コードが設定されていません。");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
      }
      LogAspector.setCurrentRequestFacilityCd(request.getFacilityCd());
      journalService.upReportDialJournalToSkip(request);
    } catch (Exception ex) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "スキップ処理異常:" + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    JournalCreateResult result = new JournalCreateResult(HttpStatus.OK, null, null);
    eventLogMessage.setLogMessage("/journal/setReportDialSkip end ");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  /**
   * sql実行(/journal/ordDialBedReplace)
   * @param request : {@link JournalUpdateRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/ordDialBedReplace")
  public ResponseEntity<?> ordDialBedReplace(@RequestBody JournalUpdateRequest request) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("/journal/ordDialBedReplace start ");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    try {
      if (request.getCtlNo() == null) {
        ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "ctl_noが設定されていません。");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
      }
      journalService.ordDialBedReplace(request);
    } catch (Exception ex) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "オーダ受け連携ベッド入れ替え処理異常:" + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }
    JournalCreateResult result = new JournalCreateResult(HttpStatus.OK, null, null);
    eventLogMessage.setLogMessage("/journal/ordDialBedReplace end ");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  // 連携負荷分散対応 20230714 add 卓 start
  /**
   * websocket送信
   * */
  @PostMapping("/wsClientSend")
  public ResponseEntity<Boolean> wsClientSend(@RequestBody MntIfEdgeClientConnectRequest request) throws IOException {
    Boolean result = journalService.wsClientSend(request);

    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  // 連携負荷分散対応 20230714 add 卓 end

  /**
   * ジャーナル作成(/journal/createIfOrdNoExists)
   * @param request : {@link JournalCreateRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/createIfOrdNoExists")
  public ResponseEntity<?> createIfOrdNoExists(@RequestBody JournalCreateRequest request) {
    if (request.getOrdNo() == 0) {
      return new ResponseEntity<>("ordNo: 0", HttpStatus.OK);
    }
    // #12105 定期処理連携は対象外とする messageにはprofile連携のope_cdが入っている
    if ("031001".equals(request.getMessage())) {
      return new ResponseEntity<>("opeCd: 031001", HttpStatus.OK);
    }
    try {
      ResponseEntity<?> response = create(request);
      return response;
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ex.getLocalizedMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }

}
