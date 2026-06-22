package jp.co.nikkiso.ntss.admin_web.web.rest;
import java.net.URI;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.entity.ConIntelligenceListmon;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
import jp.co.nikkiso.ntss.core.entity.MstIfEdge;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.admin_web.response.externalCoopOperViewer.SysCoopJournalDetail;
import jp.co.nikkiso.ntss.admin_web.service.externalCoopOperViewer.ExternalCoopOperViewerService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
// add FNSI-連携情報を追加 李 start
// add FNSI-連携情報を追加 李 end
import jp.co.nikkiso.ntss.core.entity.custom.ExternalCoopPayload;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * 外部連携稼働ビューア系のリソースクラス.
 */
@RestController
@RequestMapping(Uri.EXTERNAL_COOP_OPER_VIEWER)
@Slf4j
public class ExternalCoopOperViewerResource {
  @Value("${ntss.admin-web.coop-api.url}")
  private String coopApi;
  /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
  @Value("${ntss.admin-web.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.admin-web.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */

  @Autowired
  ExternalCoopOperViewerService externalCoopOperViewerService;

  @Autowired
  MstInfoService mstInfoService;

  @Autowired
  SysCoopJournalDao sysCoopJournalDao;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  @PostMapping("/sys_coop_journal/{facilityCd}")
  public ResponseEntity<?> getSysCoopJourlarByCondition(@PathVariable String facilityCd,
                                                        @RequestBody ExternalCoopPayload payload,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                        @AuthenticationPrincipal NtssUser ntssUser
                                                        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/sys_coop_journal";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(externalCoopOperViewerService.getSysCoopJournalByCondition(facilityCd, payload), HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXTERNAL_COOP, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/if_edge_healmon/{facilityCd}")
  public ResponseEntity<?> getHealthmonFacilityConn(@PathVariable String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                    @AuthenticationPrincipal NtssUser ntssUser
                                                    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/if_edge_healmon";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      List<MntIfEdgeHealthmon> list = externalCoopOperViewerService.getMntIfEdgeHealthMonByFacilityCd(facilityCd);
      // add 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 start
      boolean flag = false;
      if(null != list && list.size()>0) {
        MntIfEdgeHealthmon mntIf = list.get(0);
        int mainIntervalmntIf = 0;
        String moniTime = "";
        JSONObject json = new JSONObject(mntIf.getHealthmonServerConn());
        if(json.has("main_interval")  && null != json.get("main_interval") && !"null".equals(json.get("main_interval").toString())){
          mainIntervalmntIf = Integer.valueOf(json.get("main_interval").toString());
          if("01".equals(json.get("status").toString())){
            /* modify by chamaojia 2024-10-11 [11140] 【healthmon_facility_conn】 JSON structure change  --start */
            JSONObject jsonObject = new JSONObject(mntIf.getHealthmonFacilityConn());
            String edgeAll = jsonObject.get("edge").toString();
            JSONObject edgeAllJson = new JSONObject(edgeAll);
            String edge = edgeAllJson.get(CoreConstant.HealthmonFctJson.BUSINESS_HEADER).toString();
            JSONObject edgeJson = new JSONObject(edge);
            moniTime = edgeJson.get("moni_time").toString();
            /* modify by chamaojia 2024-10-11 [11140] 【healthmon_facility_conn】 JSON structure change  --end */
            SimpleDateFormat sdf1=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            SimpleDateFormat sdf2=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            sdf2.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));
            try {
              long diff = sdf1.parse(sdf2.format(new Date())).getTime() - sdf1.parse(moniTime).getTime();
              long day = diff / (24 * 60 * 60 * 1000);
              long hour = (diff / (60 * 60 * 1000) - day * 24);
              long min = ((diff / (60 * 1000)) - day * 24 * 60 - hour * 60);
              long sec = (diff/1000-day*24*60*60-hour*60*60-min*60);
              if (day>0 || hour>0 || (min*60 +sec)> mainIntervalmntIf) {
                final String uri = coopApi + "/ifedge/resetIfEdgeStatusByFacilityCd";
                RestTemplate restTemplate = new RestTemplate();
                HttpHeaders headers = new HttpHeaders();
                headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
                /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
                headers.set(headerKey, headerValue);
                /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
                Map<String,Object> request = new HashMap<>();
                request.put("facilityCd",facilityCd);
                HttpEntity<Object> entity = new HttpEntity<>(request, headers);
				// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
                try {
                  long start = System.currentTimeMillis();
                  ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.POST, entity, String.class);
                  long cost = System.currentTimeMillis() - start;
                  Map<String, Object> map = new HashMap<>();
                  map.put("logType", "RESTTEMPLATE-LOG");
                  map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
                  map.put("methodName", "getHealthmonFacilityConn");
                  map.put("method", HttpMethod.POST);
                  map.put("url", uri);
                  map.put("headers", headers.toSingleValueMap());
                  map.put("requestParameter", request);
                  map.put("status",response.getStatusCode());
                  map.put("cost", cost);
                  map.put("result",response.getBody());
                  EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
                  restTemplateEventLogMessage.setFacilityCd(facilityCd);
                  restTemplateEventLogMessage.setLogMessage(toJson(map));
                  logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
                  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
                  if(200 == response.getStatusCode().value()){
                    flag = true;
                  }
                } catch (RestClientException e) {
                  logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
                }
              }
            } catch (ParseException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }
          }
        }
      }
      if(flag){
        List<MntIfEdgeHealthmon> list1 = externalCoopOperViewerService.getMntIfEdgeHealthMonByFacilityCd(facilityCd);
        return new ResponseEntity<>(list1, HttpStatus.OK);
      }
      // add 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 start
        // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(list, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXTERNAL_COOP, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  // add FNSI-連携情報を追加 李 start
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  @GetMapping("/pat_coop_detail/{facilityCd}/{selectedPatId}")
//  public ResponseEntity<?> getConIntelligenceList(@PathVariable String facilityCd, @PathVariable String selectedPatId) {
  @GetMapping("/pat_coop_detail/{facilityCd}/{coopVersion}/{selectedPatId}")
  public ResponseEntity<?> getConIntelligenceList(@PathVariable String facilityCd, @PathVariable String coopVersion, @PathVariable String selectedPatId,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                  @AuthenticationPrincipal NtssUser ntssUser
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/pat_coop_detail";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      selectedPatId);
    // wp アプリケーションログの適正化 Add End

    try {
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      List<ConIntelligenceListmon> list = externalCoopOperViewerService.getConIntelligenceListByFacilityCd(facilityCd, selectedPatId);
      String coopVersionNew = "";
      if (!StringUtils.isEmpty(coopVersion)) {
        coopVersionNew = coopVersion.substring(1);
      }
      List<ConIntelligenceListmon> list = externalCoopOperViewerService.getConIntelligenceListByFacilityCd(facilityCd,
        coopVersionNew, selectedPatId);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        selectedPatId);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(list, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXTERNAL_COOP, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add FNSI-連携情報を追加 李 end

  @PutMapping("/update_sys_coop_journal")
  public ResponseEntity<?> updateSysCoopJourlar(@RequestBody List<SysCoopJournalDetail> listSys,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                @AuthenticationPrincipal NtssUser ntssUser
                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260423 start
      if(!ntssUser.isNkkAdminUser()) {
        if (!listSys.isEmpty()) {
          for (SysCoopJournalDetail sysCoopJournalDetail : listSys) {
            SysCoopJournal dbSysCoopJournal = sysCoopJournalDao.selectByPK(sysCoopJournalDetail.getCtlNo());
            String dbFacilityCd = dbSysCoopJournal == null ? null : dbSysCoopJournal.getFacilityCd();
            if (dbFacilityCd != null &&
              !dbFacilityCd.equals(ntssUser.getFacilityCd())) {
              String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + dbFacilityCd + " " + "patId=" + dbSysCoopJournal.getPatId() + " " + "ctlNo=" + dbSysCoopJournal.getCtlNo() + " ";
              InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
              return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
            }
          }
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260423 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/update_sys_coop_journal";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      externalCoopOperViewerService.updateSys(listSys);
      // add 8229 外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230129 zhaoqi start
      for (int i = 0; i < listSys.size(); i++) {
        // add FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 start
        //配信処理ステータスは0:未処理の場合
        if("0".equals(listSys.get(i).getCoopResult()) && "0".equals(listSys.get(i).getAnaResult()) && "S".equals(listSys.get(i).getDirection())){
          //
          //連携API → 電文生成API呼び出し
          externalCoopOperViewerService.callCreateJournal(
            listSys.get(i).getFacilityCd(),
            listSys.get(i).getOrdNo(),
            listSys.get(i).getUserId(),
            listSys.get(i).getPatId(),
            listSys.get(i).getCoopCd());
        }
        // add FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 end
      }
      // add 8229 外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230129 zhaoqi end

      HashMap<String, Object> request = new HashMap<String, Object>();
      final String Suri = coopApi + "/journal/redelivery";
      final String Ruri = coopApi + "/journal/convert/externalCoopOperViwerReceive";
      // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
      final String retryUri = coopApi + "/journal/redelivery";
      int retryNum = 0;
      // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end
      // add FutreNetWeb+SI課題管理No4358 趙 start
      // mod #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 start
      //final String Senduri = coopApi + "/journal/convert/send";
      final String Senduri = coopApi + "/journal/convert/externalCoopOperViwersend";
      // mod #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 end
      int Sendnum = 0;
      // add FutreNetWeb+SI課題管理No4358 趙 end
      int Snum = 0;
      int Rnum = 0;
      String facilityCd = "";
      for (SysCoopJournalDetail temp:listSys) {
        if ("S".equals(temp.getDirection()) && "9".equals(temp.getAnaResult()) && "0".equals(temp.getCoopResult())){
            Snum = Snum +1;
            facilityCd= temp.getFacilityCd();
        } else if("R".equals(temp.getDirection()) && "0".equals(temp.getAnaResult()) && "9".equals(temp.getCoopResult())){
            Rnum = Rnum +1;
            facilityCd= temp.getFacilityCd();
        }
        // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
        // mod FutreNetWeb+SI課題管理No4358 API条件変更 趙 start
        // else if("S".equals(temp.getDirection()) && "9".equals(temp.getAnaResult()) && "R".equals(temp.getCoopResult())){
        // retryNum = retryNum +1;
        // facilityCd= temp.getFacilityCd();
        // }
        else if("S".equals(temp.getDirection()) && "0".equals(temp.getAnaResult()) && "0".equals(temp.getCoopResult())){
          Sendnum = Sendnum + 1;
          facilityCd= temp.getFacilityCd();
        }
        // mod FutreNetWeb+SI課題管理No4358 API条件変更 趙 end
        // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end
      }
      try {
      // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
      if(retryNum>0){
        request.put("facility_cd",facilityCd);
        request.put("send_type","retry");
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
        /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
        headers.set(headerKey, headerValue);
        /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
        HttpEntity<Object> entity = new HttpEntity<Object>(request, headers);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<String> response = restTemplate.exchange(retryUri, HttpMethod.POST, entity, String.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
        map.put("methodName", "updateSysCoopJourlar");
        map.put("method", HttpMethod.POST);
        map.put("url", retryUri);
        map.put("headers", headers.toSingleValueMap());
        map.put("requestParameter", request);
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        restTemplateEventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      }
      // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end
      if(Snum>0){
        request.put("facility_cd",facilityCd);
        request.put("send_type","redelivery");
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
        /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
        headers.set(headerKey, headerValue);
        /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
        HttpEntity<Object> entity = new HttpEntity<Object>(request, headers);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<String> response = restTemplate.exchange(Suri, HttpMethod.POST, entity, String.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
        map.put("methodName", "updateSysCoopJourlar");
        map.put("method", HttpMethod.POST);
        map.put("url", retryUri);
        map.put("headers", headers.toSingleValueMap());
        map.put("requestParameter", request);
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        restTemplateEventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      }
      if(Rnum >0){
        request.put("facility_cd",facilityCd);
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
        /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
        headers.set(headerKey, headerValue);
        /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
        HttpEntity<Object> entity = new HttpEntity<Object>(request, headers);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<String> response = restTemplate.exchange(Ruri, HttpMethod.POST, entity, String.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
        map.put("methodName", "updateSysCoopJourlar");
        map.put("method", HttpMethod.POST);
        map.put("url", retryUri);
        map.put("headers", headers.toSingleValueMap());
        map.put("requestParameter", request);
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        restTemplateEventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      }
      // add FutreNetWeb+SI課題管理No4358 趙 start
      if(Sendnum > 0){
        request.put("facility_cd",facilityCd);
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
        /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
        headers.set(headerKey, headerValue);
        /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
        HttpEntity<Object> entity = new HttpEntity<Object>(request, headers);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<String> response = restTemplate.exchange(Senduri, HttpMethod.POST, entity, String.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
        map.put("methodName", "updateSysCoopJourlar");
        map.put("method", HttpMethod.POST);
        map.put("url", retryUri);
        map.put("headers", headers.toSingleValueMap());
        map.put("requestParameter", request);
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        restTemplateEventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      }
      // add FutreNetWeb+SI課題管理No4358 趙 end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);

      // add FutreNetWeb+SI課題管理No6105 趙 start
      } catch (RestClientException e) {
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
        return new ResponseEntity<>(HttpStatus.NOT_ACCEPTABLE);
      }
      // add FutreNetWeb+SI課題管理No6105 趙 end

    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXTERNAL_COOP, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  @PostMapping("start/edge/side/process")
  public ResponseEntity<?> startEdgeSideProcess(@RequestBody Map<String,Object> request){
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "start/edge/side/process";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // add FNSi5712アプリケーションログが出力しない 周 end
    final String uri = coopApi + "/ifedge/maintenance";
    log.info("uri_____________"+uri);
    RestTemplate restTemplate = new RestTemplate();
    HttpHeaders headers = new HttpHeaders();
    headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
    /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
    headers.set(headerKey, headerValue);
    /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
    HttpEntity<Object> entity = new HttpEntity<Object>(request, headers);
	// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
    long start = System.currentTimeMillis();
    ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.POST, entity, String.class);
    String result = response.getBody();
    long cost = System.currentTimeMillis() - start;
    Map<String, Object> map = new HashMap<>();
    map.put("logType", "RESTTEMPLATE-LOG");
    map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
    map.put("methodName", "startEdgeSideProcess");
    map.put("method", HttpMethod.POST);
    map.put("url", uri);
    map.put("headers", headers.toSingleValueMap());
    map.put("requestParameter", request);
    map.put("status",response.getStatusCode());
    map.put("cost", cost);
    map.put("result",response.getBody());
    EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
    restTemplateEventLogMessage.setLogMessage(toJson(map));
    logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
//    String result = "Success";
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  @PostMapping("/coop")
    public ResponseEntity<?> postExternalCoop(@RequestBody Map<String,Object> request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/coop";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      final String uri = coopApi + "/health/update";
      RestTemplate restTemplate = new RestTemplate();
      HttpHeaders headers = new HttpHeaders();
      headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
      /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
      headers.set(headerKey, headerValue);
      /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
      HttpEntity<Object> entity = new HttpEntity<Object>(request, headers);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.POST, entity, String.class);
      String result = response.getBody();
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
      map.put("methodName", "postExternalCoop");
      map.put("method", HttpMethod.POST);
      map.put("url", uri);
      map.put("headers", headers.toSingleValueMap());
      map.put("requestParameter", request);
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_EXTERNAL_COOP, SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
//  add 5615 IFエッジコマンド実行 関 start
  @PostMapping("/commandKey/coop")
  public ResponseEntity<?> postCommandKeyCoop(@RequestBody Map<String,Object> request,
                                              @AuthenticationPrincipal NtssUser ntssUser) {

    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/commandKey/coop";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    String result = null;
    String facilityCd  = null;
    try {
      final String uri = coopApi + "/ifedge/maintenance";
      RestTemplate restTemplate = new RestTemplate();
      HttpHeaders headers = new HttpHeaders();
      headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
      /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
      headers.set(headerKey, headerValue);
      /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
      HttpEntity<Object> entity = null;
      List<String> list = (List<String>) request.get("facility_cd");
      // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
      if (!ntssUser.isNkkAdminUser() && list != null) {
        for (String currentFacilityCd : list) {
          if (currentFacilityCd != null && !currentFacilityCd.isEmpty()
            && !currentFacilityCd.equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "currentFacilityCd=" + currentFacilityCd + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end
      if(list.size() > 0){
        for (int i = 0; i <list.size() ; i++) {
          facilityCd = list.get(i);
          request.put("facility_cd",facilityCd);
          entity = new HttpEntity<Object>(request, headers);
		  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
          long start = System.currentTimeMillis();
          ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.POST, entity, String.class);
          result = response.getBody();
          long cost = System.currentTimeMillis() - start;
          Map<String, Object> map = new HashMap<>();
          map.put("logType", "RESTTEMPLATE-LOG");
          map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
          map.put("methodName", "postCommandKeyCoop");
          map.put("method", HttpMethod.POST);
          map.put("url", uri);
          map.put("headers", headers.toSingleValueMap());
          map.put("requestParameter", request);
          map.put("status",response.getStatusCode());
          map.put("cost", cost);
          map.put("result",response.getBody());
          EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
          restTemplateEventLogMessage.setLogMessage(toJson(map));
          restTemplateEventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        }
      }else{
        entity = new HttpEntity<Object>(request, headers);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        RequestEntity<Map<String, Object>> logRequest = RequestEntity
          .post(URI.create(uri))
          .contentType(MediaType.APPLICATION_JSON)
          .headers(headers)
          .body(request);
        long start = System.currentTimeMillis();
        ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.POST, entity, String.class);
        result = response.getBody();
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
        map.put("methodName", "postCommandKeyCoop");
        map.put("method", logRequest.getMethod());
        map.put("url", logRequest.getUrl());
        map.put("headers", logRequest.getHeaders().toSingleValueMap());
        map.put("requestParameter", logRequest.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        restTemplateEventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      }
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(facilityCd,HttpStatus.BAD_REQUEST);
    }
  }
  @PostMapping("/if_edge_command")
  public ResponseEntity<?> getCommandKey() {

    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/if_edge_command";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {

      Map<String, Object> map  = externalCoopOperViewerService.selectEdgeCommand();
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(map, HttpStatus.OK);

    } catch (Exception e) {

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }
//  add 5615 IFエッジコマンド実行 関 end
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

  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  /**
   * 施設コードにより連携エッジクライアント接続状態取得
   * @param facilityCd
   * @return
   */
  @GetMapping("/if_edge_client_connect/{facilityCd}")
  public ResponseEntity<?> getIfEdgeClientConn(@PathVariable String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/if_edge_client_connect";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,null);
    try {
      MntIfEdgeClientConnect mntIfEdgeClientConnect= externalCoopOperViewerService.getMntIfEdgeClientConn(facilityCd);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,null);
      return new ResponseEntity<>(mntIfEdgeClientConnect, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @PostMapping("if_edge_client_connect_count")
  public ResponseEntity<?> clientCount(@RequestBody Map<String,Object> request){
    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "start/edge/side/check";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, null,null);
    final String uri = coopApi + "/ifedge/clientCount";
    RestTemplate restTemplate = new RestTemplate();
    HttpHeaders headers = new HttpHeaders();
    headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
    /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
    headers.set(headerKey, headerValue);
    /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
    HttpEntity<Object> entity = new HttpEntity<>(request, headers);
	// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
    long start = System.currentTimeMillis();
    ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.POST, entity, String.class);
    String result = response.getBody();
    long cost = System.currentTimeMillis() - start;
    Map<String, Object> map = new HashMap<>();
    map.put("logType", "RESTTEMPLATE-LOG");
    map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
    map.put("methodName", "clientCount");
    map.put("method", HttpMethod.POST);
    map.put("url", uri);
    map.put("headers", headers.toSingleValueMap());
    map.put("requestParameter", request);
    map.put("status",response.getStatusCode());
    map.put("cost", cost);
    map.put("result",response.getBody());
    EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
    restTemplateEventLogMessage.setLogMessage(toJson(map));
    logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, null,null);
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end

  /**
   * 連携エッジ制御指示管理の状態をリセット
   * @param request : {@link Map<String,Object>}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/reset_edge_status")
  public ResponseEntity<?> resetEdgeStatus(@RequestBody Map<String,Object> request,
                                           @AuthenticationPrincipal NtssUser ntssUser){

    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/reset_edge_status";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, null,null);
    try {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
      if (!ntssUser.isNkkAdminUser()) {
        Object facilityCdValue = request.get("facility_cd");
        if (facilityCdValue instanceof List<?>) {
          for (Object facilityCdObj : (List<?>) facilityCdValue) {
            if (facilityCdObj != null) {
              String facilityCd = facilityCdObj.toString();
              if (!facilityCd.isEmpty() && !facilityCd.equals(ntssUser.getFacilityCd())) {
                String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
                InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
                return new ResponseEntity<>(HttpStatus.FORBIDDEN);
              }
            }
          }
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end
      final String uri = coopApi + "/ifedge/resetStatusByFacilityCds";
      RestTemplate restTemplate = new RestTemplate();
      HttpHeaders headers = new HttpHeaders();
      headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
      /* add by chamaojia 2024-06-27 [10574] communication security related additions --start */
      headers.set(headerKey, headerValue);
      /* add by chamaojia 2024-06-27 [10574] communication security related additions --end */
      HttpEntity<Object> entity = new HttpEntity<>(request, headers);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.POST, entity, String.class);
      //結果の取得
      HttpStatus status = HttpStatus.valueOf(response.getStatusCode().value());
      String body = response.getBody();
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.ExternalCoopOperViewerResource");
      map.put("methodName", "resetEdgeStatus");
      map.put("method", HttpMethod.POST);
      map.put("url", uri);
      map.put("headers", headers.toSingleValueMap());
      map.put("requestParameter", request);
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, null,null);
      return new ResponseEntity<>(body, status);
    }catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //add 6085 施設がIFエッジある施設であるかの判断 ljx start
  /**
   * 施設がIFエッジある施設であるかの判断
   * @param facilityCd
   * @return
   */
  @GetMapping("/has_if_edge/{facilityCd}")
  public ResponseEntity<?> getIfEdge(@PathVariable String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                     @AuthenticationPrincipal NtssUser ntssUser
                                     // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    String mappingUrl = Uri.EXTERNAL_COOP_OPER_VIEWER + "/has_if_edge";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,null);
    try {
      List<MstIfEdge> mstIfEdgeList= mstInfoService.getMstIfEdgeByFacilityCd(facilityCd);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,null);
      return new ResponseEntity<>(mstIfEdgeList, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_EXTERNAL_COOP, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //add 6085 施設がIFエッジある施設であるかの判断 ljx end

  //add #9490 電子カルテアイコンの連携先情報の制御について、2023.8.25 lmf start
  /**
   *
   * @param facilityCd 施設コード
   * @return
   */
  @GetMapping("/if_edge_healmon_on/{facilityCd}")
  public ResponseEntity<?> getHealthmonFacilityConnByOn(@PathVariable String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                        @AuthenticationPrincipal NtssUser ntssUser
                                                        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    String jsonString = externalCoopOperViewerService.getHealthmonFacilityConnByOn(facilityCd);
    return new ResponseEntity<>(jsonString, HttpStatus.OK);
  }
  //add #9490 電子カルテアイコンの連携先情報の制御について、2023.8.25 lmf end
}
