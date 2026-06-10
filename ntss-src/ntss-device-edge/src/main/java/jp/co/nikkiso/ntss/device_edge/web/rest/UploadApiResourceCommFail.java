package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;

import jp.co.nikkiso.ntss.device_edge.service.DatabasePusherCommFail;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class UploadApiResourceCommFail {

  private final String HeaderFacilityCd = "facility_cd";
  private final String HeaderDeviceEdgeNo = "device_edge_no";

  @Autowired
  DatabasePusherCommFail dbPusher;

  @Autowired
  private LogService logService;

//  @GetMapping("/sample")
//  public ResponseEntity<String> getAll() throws URISyntaxException {
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("API GET CALLED");
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
//
//    return new ResponseEntity<>("sample", HttpStatus.OK);
//  }

  @PostMapping("/post_file_commfail")
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

//    if (facility_cd.length() > 0 && device_edge_no.length() > 0 && Utilities.isNumber(device_edge_no)) {
//      // 装置死活情報更新
//      dbPusher.runWriteAliveMoni(facility_cd, Integer.parseInt(device_edge_no));
//    }

    InputStream inputStream = null;
    try {
      inputStream = request.getInputStream();
      if (inputStream != null) {
        if (!dbPusher.run(inputStream)) {
          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
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

  // add AWSとDEの通信断からの復旧 --趙-- start
  /**
   * 死活監視受信(AWSとDEの通信断からの復旧)
   * @return
   */
  @PutMapping("/response_commfail")
  public HttpStatus ResponseCommFail(){
    HttpStatus status = HttpStatus.OK;
    return status;
  }

}
