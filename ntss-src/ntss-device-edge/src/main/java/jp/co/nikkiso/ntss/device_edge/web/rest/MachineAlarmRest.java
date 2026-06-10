package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.device_edge.service.SetAlarmList;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogService;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

@RestController
@RequestMapping("/api")
public class MachineAlarmRest {

  @Autowired
  private LogService logService;

  private final String HeaderFacilityCd = "facilitycode";
  private final String HeaderDeviceType = "devicetype";
  private final String HeaderSerialNo = "serialno";

  @Autowired
  SetAlarmList db;

  @PostMapping("/post_machine_alarm")
  public ResponseEntity<Void> setMachineAlarm(HttpServletRequest request) {
    //log.debug("REST request to setMachineAlarm size : {}", uploadFileDto.getFile().getSize());

    StringBuilder sbLogInfo = new StringBuilder();

    String facility_cd = "";
    String machine_type_cd = "";
    String machine_serial = "";
    EventLogMessage eventLogMessage = new EventLogMessage();
    Enumeration<String> headernames = request.getHeaderNames();
    while (headernames.hasMoreElements()) {
      String name = (String) headernames.nextElement();

      if (name.equals(HeaderFacilityCd)) {
        Enumeration<String> headervals = request.getHeaders(name);
        while (headervals.hasMoreElements()) {
          facility_cd = (String) headervals.nextElement();
        eventLogMessage.setLogMessage(name + ":" + facility_cd);
        eventLogMessage.setFacilityCd(facility_cd);
        //FNSI-修正 ログ対応 xiebzh add start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        //FNSI-修正 ログ対応 xiebzh add end
  		  logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
          if (0 < sbLogInfo.length()) {
            sbLogInfo.append(" / ");
          }
          sbLogInfo.append(name + ":" + facility_cd);
        }
      } else if (name.equals(HeaderDeviceType)) {
        Enumeration<String> headervals = request.getHeaders(name);
        while (headervals.hasMoreElements()) {
          machine_type_cd = (String) headervals.nextElement();
          eventLogMessage.setLogMessage(name + ":" + machine_type_cd);
          eventLogMessage.setMachineTypeCd(machine_type_cd);
          eventLogMessage.setFacilityCd(facility_cd);
  		    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
          if (0 < sbLogInfo.length()) {
            sbLogInfo.append(" / ");
          }
          sbLogInfo.append(name + ":" + machine_type_cd);
        }
      } else if (name.equals(HeaderSerialNo)) {
        Enumeration<String> headervals = request.getHeaders(name);
        while (headervals.hasMoreElements()) {
          machine_serial = (String) headervals.nextElement();
          eventLogMessage.setLogMessage(name + ":" + machine_serial);
          eventLogMessage.setMachineTypeCd(machine_type_cd);
          eventLogMessage.setFacilityCd(facility_cd);
  		    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
          if (0 < sbLogInfo.length()) {
            sbLogInfo.append(" / ");
          }
          sbLogInfo.append(name + ":" + machine_serial);
        }
      }
    }

    //
    String strLogInfo = sbLogInfo.toString() + "  ";

    InputStream inputStream = null;
    try {
      inputStream = request.getInputStream();
      if (inputStream != null) {
        if (!db.run(facility_cd, machine_type_cd, machine_serial, inputStream)) {
          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
      } else {
        eventLogMessage.setLogMessage(strLogInfo + LogMessage.WARN_NO_STREAM);
        eventLogMessage.setMachineTypeCd(machine_type_cd);
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage(strLogInfo + LogMessage.ERROR_DB_PUSH_API);
      eventLogMessage.setMachineTypeCd(machine_type_cd);
      eventLogMessage.setFacilityCd(facility_cd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    } finally {
      if (inputStream != null) {
        try {
          inputStream.close();
        } catch (IOException e) {
          eventLogMessage.setLogMessage(strLogInfo + LogMessage.ERROR_CLOSE_STREAM);
          eventLogMessage.setMachineTypeCd(machine_type_cd);
          eventLogMessage.setFacilityCd(facility_cd);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        }
      }
    }

    return new ResponseEntity<>(HttpStatus.OK);
  }
}
