package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdTreatCondition;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.service.ComsvOrdTreatConditionService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;

@RestController
@RequestMapping("/api/comsv_ord")

public class ComsvOrdTreatConditionResource {

  @Autowired
  private LogService logService;

  /**
   * 通信サーバ用設定値読み込み履歴更新
   * @param ord_no
   * @param facility_cd
   * @param machine_no
   * @param receive_date
   * @param treat_class
   * @param body
   */
  @Autowired
  private ComsvOrdTreatConditionService comsvOrdTreatConditionService;

  @PostMapping("/treat_condition/{ord_no}/{facility_cd}/{machine_no}/{receive_date}/{treat_class}")
  @ResponseStatus(HttpStatus.OK)
  public HttpStatus Response(
      @PathVariable("ord_no") Long ord_no,
      @PathVariable(name = "facility_cd", required = false) String facility_cd,
      @PathVariable("machine_no") Long machine_no,
      @PathVariable(name = "receive_date", required = false) String receive_date,
      @PathVariable("treat_class") Integer treat_class,
      @RequestBody String body) throws ParseException, IOException {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setMachineType(machine_no.toString());
    eventLogMessage.setLogMessage("アプリ更新API応答[" + ord_no + "：" + facility_cd + "]:[" + body + "]");
    eventLogMessage.setFacilityCd(facility_cd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    ComsvOrdTreatCondition cond = new ComsvOrdTreatCondition();
    cond.setOrdNo(ord_no);
    cond.setFacilityCd(facility_cd);
    cond.setMachineNo(machine_no);
    try {
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern("uuuuMMddHHmmss");
      Timestamp ReceiveTime = Timestamp.valueOf(LocalDateTime.parse(receive_date, dtf));
      cond.setReceiveDate(ReceiveTime);
    } catch (Exception e) {
      // 受信日時の設定に失敗
      eventLogMessage.setLogMessage("受信日時の展開に失敗[" + e.getMessage() + "]");
      eventLogMessage.setFacilityCd(facility_cd);
  	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      Timestamp ReceiveTime = Timestamp.valueOf(LocalDateTime.now());
      cond.setReceiveDate(ReceiveTime);
    }
    cond.setTreatClass(treat_class);
    cond.setTreatCondition(body);
    try {
      int ret = comsvOrdTreatConditionService.insertCondition(cond);
      if (ret > 0) {
        return HttpStatus.OK;
      } else {
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
        //return HttpStatus.BAD_REQUEST;
        return HttpStatus.INTERNAL_SERVER_ERROR;
        // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
      }
    } catch (Exception e) {
        eventLogMessage.setLogMessage("設定値の書き込みに失敗[" + e.getMessage() + "]");
        eventLogMessage.setFacilityCd(facility_cd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return HttpStatus.INTERNAL_SERVER_ERROR;
    }
  }

}
