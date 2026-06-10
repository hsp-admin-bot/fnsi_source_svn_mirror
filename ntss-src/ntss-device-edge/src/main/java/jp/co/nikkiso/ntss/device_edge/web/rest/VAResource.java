package jp.co.nikkiso.ntss.device_edge.web.rest;


import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.VAService;

@RestController
@RequestMapping("/api")
public class VAResource {

  @Autowired
  VAService VAService;
  @Autowired
  private LogService logService;

  /**
   * VA画像を取得する
   *
   * @param request
   * @return
   */
  @PostMapping("/va")
  public ResponseEntity<?> makeDialReport(HttpServletRequest request) {
    //log.debug("REST request to setMachineAlarm size : {}", uploadFileDto.getFile().getSize());
    // 毛 ログ改善対応 add
    EventLogMessage eventLogMessage = new EventLogMessage();
    StringBuilder sbLogInfo = new StringBuilder();

    String ord_no = "";
    Enumeration<String> headernames = request.getHeaderNames();
    while (headernames.hasMoreElements()) {
      String name = (String) headernames.nextElement();

      if (name.equals("ord_no")) {
        Enumeration<String> headervals = request.getHeaders(name);
        while (headervals.hasMoreElements()) {
          ord_no = (String) headervals.nextElement();
          if (0 < sbLogInfo.length()) {
            sbLogInfo.append(" / ");
          }
          sbLogInfo.append(name + ":" + ord_no);
        }
      }
    }

    // 毛 ログ改善対応 Add Start
    eventLogMessage.setLogMessage("VA画像取得処理治療番号(ord_no)：" + sbLogInfo.toString() );
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    // 毛 ログ改善対応 Add End

    if( !ord_no.isEmpty() ) {
      //
      String strLogInfo = sbLogInfo.toString() + "  ";

      try {
        // VA画像作成
        String hexString = VAService.getVAImage( Long.parseLong(ord_no) );
        // 毛 ログ改善対応 Add Start
        eventLogMessage.setLogMessage("VA画像取得処理：" + hexString );
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // 毛 ログ改善対応 Add End
        if ( ! hexString.isEmpty() ) {
          return new ResponseEntity<>(hexString, HttpStatus.OK);
        }
      } catch (Exception e) {
        eventLogMessage.setLogMessage("VA画像取得処理治療番号：" + strLogInfo + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }
    // # 2023.08.07 mod VA画像取得失敗の場合は応答:200、bodyを空で返す TDC米沢 start
    // // 毛 ログ改善対応 Add Start
    // eventLogMessage.setLogMessage("API /va処理失敗！");
    // logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    // // 毛 ログ改善対応 Add End
    // return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    eventLogMessage.setLogMessage("API /va取得失敗！");
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    return new ResponseEntity<>("", HttpStatus.OK);
    // # 2023.08.07 mod VA画像取得失敗の場合は応答:200、bodyを空で返す TDC米沢 end
  }
}
