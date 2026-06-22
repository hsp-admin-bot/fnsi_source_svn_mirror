package jp.co.nikkiso.ntss.device_edge.web.rest;

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
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.response.lcdReq.LcdReqExamResponse;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.lcdReq.LcdReqService;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@RequestMapping("/api/lcdreq33")
public class LcdRe33Resource {

  @Autowired
  private LogService logService;

  /**
   * 仮想端末情報(検査結果)の取得
   */
  @Autowired
  private LcdReqService lcdReqService;

  @GetMapping("/{pat_id}")
  public ResponseEntity<?> getLcdReq(
      @PathVariable("pat_id") Long pat_id) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      eventLogMessage.setPatId(pat_id.toString());
      eventLogMessage.setLogMessage("API GET CALLED ID = " + pat_id);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      if (pat_id > 0) {
        List<LcdReqExamResponse> resExam = lcdReqService.lcdReqExamResult(pat_id);
        eventLogMessage.setLogMessage("LcdReq33 O K");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(resExam, HttpStatus.OK);
      } else {
        eventLogMessage.setLogMessage("ERROR");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

}
