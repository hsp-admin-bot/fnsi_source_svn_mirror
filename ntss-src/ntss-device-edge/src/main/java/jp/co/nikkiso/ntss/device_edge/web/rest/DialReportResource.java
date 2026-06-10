package jp.co.nikkiso.ntss.device_edge.web.rest;


import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;

import jp.co.nikkiso.ntss.device_edge.service.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.response.dialReport.PastOrderNoResponse;
import jp.co.nikkiso.ntss.device_edge.service.DialReportService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@RequestMapping("/api")
public class DialReportResource {

  @Autowired
  DialReportService dialReportService;

  @Autowired
  private LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  /**
   * 指定したオーダー番号から直近と同一曜日で過去の3回分オーダー番号を取得する
   * @param ord_no オーダー番号
   * @return
   */
  @GetMapping("/past_ordinfo/{ord_no}")
  public ResponseEntity<?> getPastDialInfo(
      @PathVariable("ord_no") Long ord_no) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api" + "/past_ordinfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ord_no);
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("getPastDialInfo API GET CALLED OrdNo = " + ord_no);
//    //FNSI-修正 ログ対応 xiebzh add start
//    eventLogMessage.setInvokeClass(this.getClass().getName());
//    //FNSI-修正 ログ対応 xiebzh add end
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    try {
      PastOrderNoResponse res = dialReportService.getPatDialInfo(ord_no);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        ord_no);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch( Exception e ) {
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 透析レポート画像を取得する
   *
   * @param request
   * @return
   */
  @PostMapping("/dialreport")
  public ResponseEntity<?> makeDialReport(HttpServletRequest request) {
    //log.debug("REST request to setMachineAlarm size : {}", uploadFileDto.getFile().getSize());

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api" + "/dialreport";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    StringBuilder sbLogInfo = new StringBuilder();

    String ord_no = "";
    Enumeration<String> headernames = request.getHeaderNames();
    while (headernames.hasMoreElements()) {
      String name = (String) headernames.nextElement();

      if (name.equals("ord_no")) {
        Enumeration<String> headervals = request.getHeaders(name);
        while (headervals.hasMoreElements()) {
          ord_no = (String) headervals.nextElement();
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(name + ":" + ord_no);
          //FNSI-修正 ログ対応 xiebzh add start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          //FNSI-修正 ログ対応 xiebzh add end
          logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
          if (0 < sbLogInfo.length()) {
            sbLogInfo.append(" / ");
          }
          sbLogInfo.append(name + ":" + ord_no);
        }
      }
    }

    if( !ord_no.isEmpty() ) {
      //
      String strLogInfo = sbLogInfo.toString() + "  ";

      try {
        // 透析レポート作成
        String hexString = dialReportService.getDialReport( Long.parseLong(ord_no) );
        // del 9763 治療方法マスタで透析経過表（装置画像転送用）が未設定だと透析装置で透析記録用紙が表示されない　吉 start
        // if ( ! hexString.isEmpty() ) {
        // del 9763 治療方法マスタで透析経過表（装置画像転送用）が未設定だと透析装置で透析記録用紙が表示されない　吉 end

          // wp アプリケーションログの適正化 Add Start
          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
            ord_no);
          // wp アプリケーションログの適正化 Add End
          return new ResponseEntity<>(hexString, HttpStatus.OK);
        // del 9763 治療方法マスタで透析経過表（装置画像転送用）が未設定だと透析装置で透析記録用紙が表示されない　吉 start
//        }
        // del 9763 治療方法マスタで透析経過表（装置画像転送用）が未設定だと透析装置で透析記録用紙が表示されない　吉 end
      } catch (Exception e) {
//          EventLogMessage eventLogMessage = new EventLogMessage();
//          eventLogMessage.setLogMessage(strLogInfo + e.getMessage());
//          //FNSI-修正 ログ対応 xiebzh add start
//          eventLogMessage.setInvokeClass(this.getClass().getName());
//          //FNSI-修正 ログ対応 xiebzh add end
//          logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ord_no);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
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
