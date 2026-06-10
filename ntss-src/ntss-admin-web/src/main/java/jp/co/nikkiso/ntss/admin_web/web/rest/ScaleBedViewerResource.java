package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.WebSocketTopic;
import jp.co.nikkiso.ntss.admin_web.request.scaleBedState.ScaleBedConnectRequest;
import jp.co.nikkiso.ntss.admin_web.request.scaleBedState.ScaleBedSendConditionRequest;
import jp.co.nikkiso.ntss.admin_web.request.scaleBedState.ScaleValueRequest;
import jp.co.nikkiso.ntss.admin_web.request.weight.SendConditionRequest;
import jp.co.nikkiso.ntss.admin_web.request.weight.WeightPrintRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.ScaleBedService;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.ScaleBedServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.ScaleBedListViewDTO;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.ScaleBedWeightAndBedKey;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService.SendTarget;
import jp.co.nikkiso.ntss.admin_web.service.weight.state.ScaleBedStateService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.OrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.*;

@RestController
@Slf4j
@RequestMapping(Uri.SCALE_BED)
public class ScaleBedViewerResource {
  @Autowired
  ScaleBedStateService scaleBedStateService;
  @Autowired
  ScaleBedService  scaleBedService;
  @Autowired
  LogService logService;
  @Autowired
  WeightResource weightResource;
  @Autowired
  OrdWeightScaleDao ordWeightScaleDao;

  @GetMapping("/view_list")
  public ResponseEntity<?> getViewList(@AuthenticationPrincipal NtssUser user) {

    String facilityCd = user.getFacilityCd();
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("REST request to get スケールベッド状況一覧 : "+ facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);

    try {
      List<ScaleBedListViewDTO> response = scaleBedService.getScaleBedList(facilityCd);
      // レスポンス生成
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {
      eventLogMessage.setLogMessage("ERROR スケールベッド状況一覧 : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
      // レスポンス生成
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/target_bed_list")
  public ResponseEntity<?> getTargetBeds(@AuthenticationPrincipal NtssUser user) {

    String facilityCd = user.getFacilityCd();
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("REST request to get スケールベッド対象一覧 : "+ facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);

    try {
      List<ScaleBedWeightAndBedKey> response = scaleBedService.getScaleBedWeightAndBedKeyList(facilityCd);
      // レスポンス生成
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {
      eventLogMessage.setLogMessage("ERROR スケールベッド対象一覧 : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
      // レスポンス生成
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 条件送信
   * @return
   */
  @PostMapping("/send_condition")
  public ResponseEntity<?> postSendConditionScaleBed(
    @RequestBody ScaleBedSendConditionRequest request,
    @AuthenticationPrincipal NtssUser user) {

    String facilityCd = user.getFacilityCd();
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("REST request to post スケールベッド条件送信 bed_cd : " + request.getBedCd());
    logService.log(LogLevel.DEBUG, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);

    try {
      var checkResult = scaleBedService.checkSendableCondition(request.getBedCd(), request.getWeightCd(), request.getOrdNo(), request.getMeasureValue(), user);
      if (!checkResult.isSuccess()) {
        eventLogMessage.setLogMessage("ERROR スケールベッド条件送信 : " + checkResult.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

        Map<String, Object> body = new HashMap<>();
        body.put("message", checkResult.getMessage());

        if (checkResult.getMessage().equals("送信対象ord_no無し")) {
          // 患者未登録の印刷内容jsonをセット
          var entity = ordWeightScaleDao.selectByCd(checkResult.getSendConditionRequest().getWeightScaleNo());
          entity.setPrintContent(checkResult.getSendConditionRequest().getPrintContent());
          ordWeightScaleDao.update(entity);

          body.put("weightScaleNo", checkResult.getSendConditionRequest().getWeightScaleNo());
        }

        return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
      }
      return weightResource.postSendCondition(checkResult.getSendConditionRequest(), user);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("ERROR スケールベッド条件送信 : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
      // レスポンス生成
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  /**
   * 後体重送信
   * @return
   */
  @PostMapping("/send_after_weight")
  public ResponseEntity<?> postSendAfterWeightScaleBed(
    @RequestBody ScaleBedSendConditionRequest request,
    @AuthenticationPrincipal NtssUser user) {

    String facilityCd = user.getFacilityCd();
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("REST request to post スケールベッド後体重送信 bed_cd : " + request.getBedCd());
    logService.log(LogLevel.DEBUG, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);

    try {
      var checkResult = scaleBedService.checkSendableAfterWeight(request.getBedCd(), request.getWeightCd(), request.getOrdNo(), request.getMeasureValue(), user);
      if (!checkResult.isSuccess()) {
        eventLogMessage.setLogMessage("ERROR スケールベッド後体重送信 : " + checkResult.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);

        Map<String, Object> body = new HashMap<>();
        body.put("message", checkResult.getMessage());

        if (checkResult.getMessage().equals("送信対象ord_no無し")) {
          // 患者未登録の印刷内容jsonをセット
          var entity = ordWeightScaleDao.selectByCd(checkResult.getSendConditionRequest().getWeightScaleNo());
          entity.setPrintContent(checkResult.getSendConditionRequest().getPrintContent());
          ordWeightScaleDao.update(entity);

          body.put("printWeightScaleNo", checkResult.getSendConditionRequest().getWeightScaleNo());
        }

        return new ResponseEntity<>(body, HttpStatus.BAD_REQUEST);
      }
      return weightResource.postSendAfterWEight(checkResult.getSendConditionRequest(), user);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("ERROR スケールベッド後体重送信 : "+ e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
      // レスポンス生成
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
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
