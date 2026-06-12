package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.util.Enumeration;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.packet.TelegramControl;
import jp.co.nikkiso.ntss.device_edge.service.DatabasePusher;
import jp.co.nikkiso.ntss.device_edge.service.DatabasePusherThread;
import jp.co.nikkiso.ntss.device_edge.service.LogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.util.Utilities;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class UploadApiResource {

  private final String HeaderFacilityCd = "facility_cd";
  private final String HeaderDeviceEdgeNo = "device_edge_no";

  @Autowired
  DatabasePusher dbPusher;

  @Autowired
  private LogService logService;

  @Autowired
  private ApplicationContext applicationContext;

  @GetMapping("/sample")
  public ResponseEntity<String> getAll() throws URISyntaxException {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API GET CALLED");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    return new ResponseEntity<>("sample", HttpStatus.OK);
  }

  // #11157 2024.11.01 add サーバー疎通確認用API TDC片口 start
  @GetMapping("/connection_watch/{facilityCd}/{deviceEdgeNo}")
  public ResponseEntity<Void> connectionWatch(
    @PathVariable("facilityCd") String facilityCd,
    @PathVariable("deviceEdgeNo") String deviceEdgeNo
  ) {
    return new ResponseEntity<>(HttpStatus.OK);
  }
  // #11157 2024.11.01 add サーバー疎通確認用API TDC片口 end

  @PostMapping("/post_file")
  public ResponseEntity<Void> putUseTime(HttpServletRequest request) {
    //log.debug("REST request to putUseTime size : {}", uploadFileDto.getFile().getSize());

    String facility_cd = "";
    String device_edge_no = "";
    Enumeration<String> headernames = request.getHeaderNames();
    while (headernames.hasMoreElements()) {
      String name = (String) headernames.nextElement();

      if (name.equals(HeaderFacilityCd)) {
        Enumeration<String> headervals = request.getHeaders(name);
        while (headervals.hasMoreElements()) {
          facility_cd = (String) headervals.nextElement();
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(name + ":" + facility_cd);
          eventLogMessage.setFacilityCd(facility_cd);
      	  logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
        }
      } else if (name.equals(HeaderDeviceEdgeNo)) {
        Enumeration<String> headervals = request.getHeaders(name);
        while (headervals.hasMoreElements()) {
          device_edge_no = (String) headervals.nextElement();
          EventLogMessage eventLogMessage = new EventLogMessage();
      	  eventLogMessage.setLogMessage(name + ":" + device_edge_no);
          eventLogMessage.setDeviceEdgeNo(device_edge_no);
          eventLogMessage.setFacilityCd(facility_cd);
      	  logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
        }
      }
    }

    if (facility_cd.length() > 0 && device_edge_no.length() > 0 && Utilities.isNumber(device_edge_no)) {
      // 装置死活情報更新
      dbPusher.runWriteAliveMoni(facility_cd, Integer.parseInt(device_edge_no));
    }

    InputStream inputStream = null;
    try {
      inputStream = request.getInputStream();
      if (inputStream != null) {
        // #8266 mod 2023.03.27 DB登録処理を別スレッドで行う TDC米沢 start
        //if (!dbPusher.run(inputStream)) {
        //  return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        //}
        EventLogMessage eventLogMessage = new EventLogMessage();
        try {
          String strTelegram = TelegramControl.convertInputStreamToString(inputStream);
          eventLogMessage.setLogMessage("receive Telegram:" + strTelegram);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          if (strTelegram.trim().length() == 0) {
            // 電文なし
            eventLogMessage.setLogMessage(LogMessage.INFO_TELEGRAM_EMPTY);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
          }else {
            // DB登録処理用スレッドを生成
            DatabasePusherThread trd = new DatabasePusherThread(strTelegram);
            // newによりオブジェクト生成を行った場合、生成オブジェクト内のSpringによる@Autowired対象オブジェクトが自動生成されないため、アプリケーションコンテキストにて@Autowiredのオブジェクトの生成処理を行う
            applicationContext.getAutowireCapableBeanFactory().autowireBean(trd);
            // スレッドによるDB登録処理を実施
            trd.start();
          }
        } catch (IOException e) {
          eventLogMessage.setLogMessage(LogMessage.ERROR_TELEGRAM_STREAM + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
          eventLogMessage.setLogMessage(LogMessage.ERROR_TELEGRAM_STREAM + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
        // #8266 mod 2023.03.27 DB登録処理を別スレッドで行う TDC米沢 end
      } else {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(LogMessage.WARN_NO_STREAM);
        eventLogMessage.setDeviceEdgeNo(device_edge_no);
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
  	  eventLogMessage.setLogMessage(LogMessage.ERROR_DB_PUSH_API);
      eventLogMessage.setDeviceEdgeNo(device_edge_no);
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    } finally {
      if (inputStream != null) {
        try {
          inputStream.close();
        } catch (IOException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
      	  eventLogMessage.setLogMessage(LogMessage.ERROR_CLOSE_STREAM);
          eventLogMessage.setDeviceEdgeNo(device_edge_no);
          eventLogMessage.setFacilityCd(facility_cd);
      	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        }
      }
    }

    return new ResponseEntity<>(HttpStatus.OK);
  }

}
