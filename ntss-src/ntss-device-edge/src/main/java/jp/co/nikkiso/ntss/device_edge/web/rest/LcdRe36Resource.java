package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq36;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.lcdReq.LcdReqService;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@RequestMapping("/api/lcdreq36")
public class LcdRe36Resource {

  @Autowired
  private LogService logService;

  /**
   * 仮想端末情報(ログ)の取得
   */
  @Autowired
  private LcdReqService lcdReqService;

  @GetMapping("/{facility_cd}/{machine_type_cd}/{machine_serial}/{cond_send_date}/{ord_no}/{offset}")
  public ResponseEntity<?> getLcdReq(
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable(name = "machine_type_cd", required = false) String machine_type_cd,
      @PathVariable(name = "machine_serial", required = false) String machine_serial,
      @PathVariable(name = "cond_send_date", required = false) String cond_send_date,
      @PathVariable("ord_no") Long ord_no,
      @PathVariable("offset") Integer offset) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setMachineTypeCd(machine_type_cd);
    eventLogMessage.setLogMessage("API GET CALLED ID = " + facility_cd + " " + machine_type_cd + " " + machine_serial + " " + cond_send_date);
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    try {
      Timestamp from_date = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(cond_send_date).getTime());
      List<LcdReq36> res = lcdReqService.lcdReq36SelectMachineRecordMessage(facility_cd, machine_type_cd,
          machine_serial, from_date, ord_no, offset);
      eventLogMessage.setLogMessage("O K");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }

}
