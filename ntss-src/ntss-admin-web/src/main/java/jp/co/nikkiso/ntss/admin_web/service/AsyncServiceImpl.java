package jp.co.nikkiso.ntss.admin_web.service;

// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask.OrdMainDelayTaskManager;
import jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask.OrdMainDelayTask;
import jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask.OrdMainJournalRequest;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.OrdMainJournalRequestUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import lombok.extern.slf4j.Slf4j;

// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import org.apache.commons.lang3.StringUtils;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URISyntaxException;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import java.util.HashMap;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import java.util.List;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import java.util.Map;

import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Slf4j
@Service
public class AsyncServiceImpl implements AsyncService {


  @Value("${ntss.admin-web.coop-api.url}")
  private String coopApi;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
  @Value("${ntss.admin-web.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.admin-web.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */

  @Autowired
  private LogService logService;


  // #7068 add 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
  @Async("doSomethingExecutor")
  @Override
  public void sendExternalConnection(JournalCreateRequestPayload journalCreateRequestPayload) {
    log.info("do something, message={}", journalCreateRequestPayload);
    RestTemplate rt = new RestTemplate();
    URI uri = null;
    try {
      uri = new URI(coopApi + "/journal/create");
    } catch (URISyntaxException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (journalCreateRequestPayload != null && StringUtils.isNotEmpty(journalCreateRequestPayload.getFacilityCd())) {
        eventLogMessage.setFacilityCd(journalCreateRequestPayload.getFacilityCd());
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    RequestEntity<JournalCreateRequestPayload> request = RequestEntity
            .post(uri)
            .contentType(MediaType.APPLICATION_JSON)
            /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
            .header(headerKey, headerValue)
            /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
      .body(journalCreateRequestPayload);
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang start
    long start = System.currentTimeMillis();
    ResponseEntity<Object> response = null;
    try {
      response = rt.exchange(request, Object.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.service.AsyncServiceImpl");
      map.put("methodName", "sendExternalConnection");
      map.put("method", request.getMethod());
      map.put("url", uri.getPath());
      map.put("headers", request.getHeaders());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      if (journalCreateRequestPayload != null && StringUtils.isNotEmpty(journalCreateRequestPayload.getFacilityCd())) {
        restTemplateEventLogMessage.setFacilityCd(journalCreateRequestPayload.getFacilityCd());
      }
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang end
    } catch (RestClientException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      log.error("do something request error: ", e);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (journalCreateRequestPayload != null && StringUtils.isNotEmpty(journalCreateRequestPayload.getFacilityCd())) {
        eventLogMessage.setFacilityCd(journalCreateRequestPayload.getFacilityCd());
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
//    try {
//      Thread.sleep(1000);
//    } catch (InterruptedException e) {
//      log.error("do something error: ", e);
//    }
  }
  // #7068 add 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end

  @Async("doSomethingExecutor")
  @Override
  public void sendExternalConnection(List<OrdMain> list, JournalCreateRequestPayload journalCreateRequestPayload) {
    log.info("do something, message={}", journalCreateRequestPayload);
    list.forEach(item -> {
      journalCreateRequestPayload.setOrdNo(item.getOrdNo());
      journalCreateRequestPayload.setBaseDate(item.getTreatDate());
      RestTemplate rt = new RestTemplate();
      URI uri = null;
      try {
        uri = new URI(coopApi + "/journal/create");
      } catch (URISyntaxException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        if (journalCreateRequestPayload != null && StringUtils.isNotEmpty(journalCreateRequestPayload.getFacilityCd())) {
          eventLogMessage.setFacilityCd(journalCreateRequestPayload.getFacilityCd());
        }
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      RequestEntity<JournalCreateRequestPayload> request = RequestEntity
              .post(uri)
              .contentType(MediaType.APPLICATION_JSON)
              /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
              .header(headerKey, headerValue)
              /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
              .body(journalCreateRequestPayload);
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<Object> response = null;
      try {
        response = rt.exchange(request, Object.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.service.AsyncServiceImpl");
        map.put("methodName", "sendExternalConnection");
        map.put("method", request.getMethod());
        map.put("url", uri.getPath());
        map.put("headers", request.getHeaders());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        if (journalCreateRequestPayload != null && StringUtils.isNotEmpty(journalCreateRequestPayload.getFacilityCd())) {
          restTemplateEventLogMessage.setFacilityCd(journalCreateRequestPayload.getFacilityCd());
        }
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang end
      } catch (RestClientException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      log.error("do something request error: ", e);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        if (journalCreateRequestPayload != null && StringUtils.isNotEmpty(journalCreateRequestPayload.getFacilityCd())) {
          eventLogMessage.setFacilityCd(journalCreateRequestPayload.getFacilityCd());
        }
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    });
//    try {
//      Thread.sleep(1000);
//    } catch (InterruptedException e) {
//      log.error("do something error: ", e);
//    }
  }

  // #7068 add 2022-11-17 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
  @Autowired
  OrdMainDelayTaskManager ordMainDelayTaskManager;
  @Override
  public void requestApiJournalCreate(List<OrdMain> ordMainList, JournalCreateRequestPayload requestPayload) {
    ordMainList.forEach(ordMain -> {
      //uri構成
      URI uri = null;
      try {
        uri = new URI(coopApi + "/journal/create");
      } catch (URISyntaxException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
//        log.error(OrdMainJournalRequestUtil.logInfo("uri エラー:", ordMain.getOrdNo(), ordMain.getPatId()));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        if (requestPayload != null && StringUtils.isNotEmpty(requestPayload.getFacilityCd())) {
          eventLogMessage.setFacilityCd(requestPayload.getFacilityCd());
        }
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }

      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
      BeanUtils.copyProperties(requestPayload, payload);
      payload.setOrdNo(ordMain.getOrdNo());
      payload.setBaseDate(ordMain.getTreatDate());
      OrdMainJournalRequest journalRequest = new OrdMainJournalRequest();
      journalRequest.setOrdNo(payload.getOrdNo());
      journalRequest.setPatId(payload.getPatId());
      journalRequest.setCrud(payload.getCrud());
      journalRequest.setPayload(payload);
      journalRequest.setUri(uri);

      //  ディレイタスク作成
      OrdMainDelayTask task = new OrdMainDelayTask(journalRequest, 2);
      try {
        ordMainDelayTaskManager.put(task);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//        log.error(OrdMainJournalRequestUtil.logInfo("遅延キューに追加, エラー:", ordMain.getOrdNo(), ordMain.getPatId()));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        if (requestPayload != null && StringUtils.isNotEmpty(requestPayload.getFacilityCd())) {
          eventLogMessage.setFacilityCd(requestPayload.getFacilityCd());
        }
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    });
  }
  @Async
  @Override
  public void callCreateJournal(List<OrdMainJournalRequest> requests) {
    requests.forEach(request -> {
      //uri構成
      URI uri = null;
      try {
        uri = new URI(coopApi + "/journal/create");
      } catch (URISyntaxException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//        log.error(OrdMainJournalRequestUtil.logInfo("uri エラー:", request.getOrdNo(), request.getPatId()));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      request.setUri(uri);
      //  ディレイタスク作成
      OrdMainDelayTask task = new OrdMainDelayTask(request, 2);
      try {
        ordMainDelayTaskManager.put(task);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//        log.error(OrdMainJournalRequestUtil.logInfo("遅延キューに追加, エラー:", request.getOrdNo(), request.getPatId()));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    });
  }
  // #7068 add 2022-11-17 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 END

  @Async("doUpdateLogExecutor")
  @Override
  public void updateLog(DataUpdateLogCommonNew logCommon) {
    /* modify by chamaojia 2023-03-09 新しいメソッドの呼び出しの変更  --start */
    logCommon.updateLogToAsync();
    /* modify by chamaojia 2023-03-09 新しいメソッドの呼び出しの変更  --end */
    /** modify by wangying 2022-10-28[6118]　治療指示変更時間問題の修正 -- start */
//    try {
//      Thread.sleep(1000);
//    } catch (InterruptedException e) {
//      log.error("do something error: ", e);
//    }
    /** modify by wangying 2022-10-28[6118]　治療指示変更時間問題の修正 -- end */
  }

  // add by shiyw 2023-02-14 start
  @Async("doSomethingExecutor")
  @Override
  public void requestApiJournalCreateList(List<JournalCreateRequestPayload> ctlNoList) {
    try {
      RestTemplate rt = new RestTemplate();
      URI uri = new URI(coopApi + "/journal/createList");
      RequestEntity<List<JournalCreateRequestPayload>> request = RequestEntity.post(uri)
              .contentType(MediaType.APPLICATION_JSON)
              /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
              .header(headerKey, headerValue)
              /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
              .body(ctlNoList);
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<Object> response = rt.exchange(request, Object.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.service.AsyncServiceImpl");
      map.put("methodName", "requestApiJournalCreateList");
      map.put("method", request.getMethod());
      map.put("url", uri.getPath());
      map.put("headers", request.getHeaders());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang end
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }
  // add by shiyw 2023-02-14 end
}
