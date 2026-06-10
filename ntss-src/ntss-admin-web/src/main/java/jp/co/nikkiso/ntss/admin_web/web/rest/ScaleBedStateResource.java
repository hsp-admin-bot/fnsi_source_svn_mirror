package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.WebSocketTopic;
import jp.co.nikkiso.ntss.admin_web.request.scaleBedState.ScaleBedConnectRequest;
import jp.co.nikkiso.ntss.admin_web.request.scaleBedState.ScaleBedConnectResetRequest;
import jp.co.nikkiso.ntss.admin_web.request.scaleBedState.ScaleBedSendConditionRequest;
import jp.co.nikkiso.ntss.admin_web.request.scaleBedState.ScaleValueRequest;
import jp.co.nikkiso.ntss.admin_web.request.weight.WeightPrintRequest;
import jp.co.nikkiso.ntss.admin_web.request.weight.WeightStateRequest;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightPrintResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.ScaleBedService;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.ScaleBedListViewDTO;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService.SendTarget;
import jp.co.nikkiso.ntss.admin_web.service.weight.WeightScalePrintThread;
import jp.co.nikkiso.ntss.admin_web.service.weight.state.MntWeightStateService;
import jp.co.nikkiso.ntss.admin_web.service.weight.state.ScaleBedStateService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.*;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.concurrent.DelegatingSecurityContextRunnable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.*;

@RestController
@Slf4j
@RequestMapping(Uri.SCALE_BED_STATE)
public class ScaleBedStateResource {
  @Autowired
  ScaleBedStateService scaleBedStateService;
  @Autowired
  WebSocketNotifyService sendWsMsg;
  @Autowired
  LogEventUtils logEventUtils;
  @Autowired
  OrdWeightScaleDao ordWeightScaleDao;
  @Autowired
  ScaleBedViewerResource scaleBedViewerResource;
  @Autowired
  MstWeightDao mstWeightDao;
  @Autowired
  MntWeightStateService mntWeightStateService;
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  SysFacilitySettingDao sysFacilitySettingDao;
  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  FacilitySettingService facilitySettingService;

  /**
   * スケールベッドからの測定値をDBに格納し、websocketで通知する
   *
   * @param req {bedCd:ベッドコード, weightCd:体重計管理コード, facilityCd:施設コード, weightNo:体重計番号, scaleValue:測定値, mdCd:MDコード, userId:ユーザID}
   */
  @PutMapping("/scale_value")
  public ResponseEntity<?> postScaleValue(@RequestBody ScaleValueRequest req, @AuthenticationPrincipal NtssUser user) {
    String mappingUrl = Uri.SCALE_BED_STATE + "/scale_value";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl,
      null, null);

    try {
      // 対象となるオーダー番号を判断する
      Long targetOrdNo;
      var mms = mntMachineStateDao.selectByBedCd(req.getBedCd()).get(0);
      var isAfter = false;

      if (req.getMdCd().equals("01")) { // 前体重
        targetOrdNo = mms.getNextOrdNo();
      } else if (req.getMdCd().equals("03")) { // 後体重
        isAfter = true;
        var omByMmsOrdNo = ordMainDao.selectByOrdNo(mms.getOrdNo());
        // 現在スケールベッドで治療中だったらそのオーダー番号を対象とする,風袋値は後体重値とする。（isAfter = true）
        if (omByMmsOrdNo != null && omByMmsOrdNo.getRstDialysisState().equals("3")) {
          targetOrdNo = mms.getOrdNo();
        } else {
          var fsScaleBedPatChangeTiming = facilitySettingService.getFacilitySettingValue(req.getFacilityCd(), CoreConstant.FacilitySettingNo.SCALE_BED_PAT_CHANGE_TIMING);
          List<String> targetListOfRstDialysisState;
          if (fsScaleBedPatChangeTiming.equals("1")) {
            targetListOfRstDialysisState = List.of("4"); // 4:排液済
          } else if (fsScaleBedPatChangeTiming.equals("2")) {
            targetListOfRstDialysisState = List.of("4", "5"); // 4:排液済 と 5:後体重測定済み(実績未確定)
          } else {
            targetListOfRstDialysisState = new ArrayList<>();
          }

          var omListTodayAndYesterday = new ArrayList<OrdMain>();
          // 今日
          var yyyyMMddToday = LocalDate.now(ZoneId.of("Asia/Tokyo")).format(DateTimeFormatter.ofPattern("yyyyMMdd"));
          var omListTmpToday = ordMainDao.selectByTreatDateAndFacilityCd(yyyyMMddToday, req.getFacilityCd());
          if (omListTmpToday != null) {
            omListTodayAndYesterday.addAll(omListTmpToday);
          }
          // 昨日
          var yyyyMMddYesterday = LocalDate.now(ZoneId.of("Asia/Tokyo")).minusDays(1).format(DateTimeFormatter.ofPattern("yyyyMMdd"));
          var omListTmpYesterday = ordMainDao.selectByTreatDateAndFacilityCd(yyyyMMddYesterday, req.getFacilityCd());
          if (omListTmpYesterday != null) {
            omListTodayAndYesterday.addAll(omListTmpYesterday);
          }

          if (omListTodayAndYesterday.isEmpty()) {
            targetOrdNo = null;
          } else {
            var omFilteredAndSortedList = omListTodayAndYesterday.stream()
              .filter(x -> Objects.equals(x.getRstBedCd(), req.getBedCd())) // 治療したベッドが同一
              .filter(x -> targetListOfRstDialysisState.contains(x.getRstDialysisState())) // 対象の治療状況
              .sorted(Comparator.comparing(OrdMain::getRstEndDate, Comparator.nullsLast(Comparator.naturalOrder())).reversed()) // 最も最後(最新)
              .toList();

            if (omFilteredAndSortedList.isEmpty()) {
              targetOrdNo = null;
            } else {
              targetOrdNo = omFilteredAndSortedList.get(0).getOrdNo();
            }
          }
        }
      } else { // [前体重/後体重]以外
        targetOrdNo = null;
      }

      OrdWeightScale ows = scaleBedStateService.selectForOrdWeightScaleByBedCd(req.getBedCd(), targetOrdNo, isAfter);

      ows.setFacilityCd(req.getFacilityCd());
      ows.setWeightCd(req.getWeightCd());
      ows.setMeasureDate(Timestamp.valueOf(LocalDateTime.now()));
      ows.setBedCd(req.getBedCd());
      ows.setWeightScaleStatus((short) 0); // 0:測定済み
      ows.setScaleClass((short) 2); // 2:重量測定、後の条件送信(※自動も含む)の際に 0:前体重 とか 1:後体重 とかに変わる
      ows.setScaleMode((short) 0); // 0:体重(「体重＋車いす」とかの区分)
      ows.setScaleValue(req.getScaleValue());
      ows.setUserId(req.getUserId());

      var omByMmsOrdNo = ordMainDao.selectByOrdNo(mms.getOrdNo());
      if (ordWeightScaleDao.insert(ows) > 0) {

        //治療中の場合、スケールベッドステータスに書き込まない。
        if (! (omByMmsOrdNo != null && omByMmsOrdNo.getRstDialysisState().equals("3"))) {
          // スケールベッドステータス書込処理
          if (req.getMdCd().equals("01")) {
            scaleBedStateService.updateScaleValueBefore(req.getBedCd(), req.getWeightCd(), req.getFacilityCd(), ows.getWeightScaleNo());
          } else if (req.getMdCd().equals("03")) {
            scaleBedStateService.updateScaleValueAfter(req.getBedCd(), req.getWeightCd(), req.getFacilityCd(), ows.getWeightScaleNo());
          }
        }
      }

      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.SCALE, req.getFacilityCd(), req.getWeightNo());
      String payload = req.getWeightCd().toString();

      //治療中の場合、条件送信は行わず抜ける
      if (omByMmsOrdNo != null && omByMmsOrdNo.getRstDialysisState().equals("3")) {
        // 通知
        boolean bres = sendWsMsg.sendMsg(SendTarget.browser, req.getFacilityCd(), null, topic, payload);
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);

        String res = "{ \"websocket_send_responce\":" + bres + "}";
        return new ResponseEntity<>(res, HttpStatus.OK);
      }

      // ここで別スレッドで スケールベッド用の条件送信(測定値チェック、印刷内容json生成、などの実施も含む) を実施
      Runnable myTask = new DelegatingSecurityContextRunnable(() -> {
        var mw = mstWeightDao.selectByWeightCd(req.getWeightCd());
        Long printTargetWeightScaleNo = null;

        if (req.getMdCd().equals("01") && mw.getIsAutoSendBefore().equals("1")) {
          // スケールベッド用の条件送信のREST を ダイレクトに実施
          ScaleBedSendConditionRequest sbscr = new ScaleBedSendConditionRequest();
          sbscr.setBedCd(req.getBedCd());
          sbscr.setWeightCd(req.getWeightCd());
          sbscr.setOrdNo(targetOrdNo);
          sbscr.setMeasureValue(req.getScaleValue());
          var res = scaleBedViewerResource.postSendConditionScaleBed(sbscr, user);

          if (mw.getIsDefaultPrintBefore().equals("1")) {
            if (res.getStatusCode().equals(HttpStatus.BAD_REQUEST) || res.getStatusCode().equals(HttpStatus.OK)) {
              if (res.getBody() instanceof Map<?, ?> mappedBody) {
                printTargetWeightScaleNo = mappedBody.containsKey("weightScaleNo") ? (Long) mappedBody.get("weightScaleNo") : null;
              } else if (res.getBody() instanceof SendConditionResponse scr) {
                printTargetWeightScaleNo = scr.weightScaleNo; // 前体重の際は weightScaleNo に入る仕様
              }
            }
          }
        } else if (req.getMdCd().equals("03") && mw.getIsAutoSendAfter().equals("1")) {
          // スケールベッド用の後体重測定のREST を ダイレクトに実施
          ScaleBedSendConditionRequest sbscr = new ScaleBedSendConditionRequest();
          sbscr.setBedCd(req.getBedCd());
          sbscr.setWeightCd(req.getWeightCd());
          sbscr.setOrdNo(targetOrdNo);
          sbscr.setMeasureValue(req.getScaleValue());
          var res = scaleBedViewerResource.postSendAfterWeightScaleBed(sbscr, user);

          if (mw.getIsDefaultPrintAfter().equals("1")) {
            if (res.getStatusCode().equals(HttpStatus.BAD_REQUEST) || res.getStatusCode().equals(HttpStatus.OK)) {
              if (res.getBody() instanceof Map<?, ?> mappedBody) {
                printTargetWeightScaleNo = mappedBody.containsKey("printWeightScaleNo") ? (Long) mappedBody.get("printWeightScaleNo") : null;
              } else if (res.getBody() instanceof SendConditionResponse scr) {
                printTargetWeightScaleNo = scr.printWeightScaleNo; // 後体重の際は printWeightScaleNo に入る仕様
              }
            }
          }
        }

        // 通知
        boolean bres = sendWsMsg.sendMsg(SendTarget.browser, req.getFacilityCd(), null, topic, payload);
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);

        if (printTargetWeightScaleNo != null) {
          // WebSocket を使用してアプリへ印刷指示
          var printTopic = PayloadBuilder.BuildWeightTopic(AdminWebConstant.WebSocketTopic.WeightState.PRINT, req.getFacilityCd(), req.getWeightNo());
          var printPayload = printTargetWeightScaleNo.toString();
          var printRes = sendWsMsg.sendMsg(WebSocketNotifyService.SendTarget.weightApp, req.getFacilityCd(), req.getWeightNo(), printTopic, printPayload);
          // 印刷指示の結果を ord_weight_scale に書く
          mntWeightStateService.updatePrintStatus(
            printTargetWeightScaleNo,
            printRes ? WeightStateResource.printStatus.ORDER : WeightStateResource.printStatus.NG,
            printRes ? "" : "指示通知失敗"
          );
        }
      }, SecurityContextHolder.getContext());
      new Thread(myTask).start();

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * スケールベッドの接続状況をDBに格納し、websocketで通知する
   *
   * @param req {bedCd:ベッドコード, weightCd:体重計管理コード, facilityCd:施設コード, weightNo:体重計番号, isConnect:接続状態}
   */
  @PutMapping("/scale_bed_connect")
  public ResponseEntity<?> postWriteIsConnect(@RequestBody ScaleBedConnectRequest req) {
    String mappingUrl = Uri.SCALE_BED_STATE + "/scale_bed_connect";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null, null);

    try {
      scaleBedStateService.updateIsConnect(req.getBedCd(), req.getIsConnect());

      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.WEIGHT_CONNECT, req.getFacilityCd(), req.getWeightNo());
      String payload = req.getWeightCd().toString();

      boolean bres = sendWsMsg.sendMsg(SendTarget.browser, req.getFacilityCd(), null, topic, payload);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);

      String res = "{ \"websocket_send_responce\":" + bres + "}";
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * スケールベッドの接続状況を初期化して一括で {"0":"切断"} としてDBに格納し、websocketで通知する
   *
   * @param req {bedCdList:ベッドコードリスト, weightCd:体重計管理コード, facilityCd:施設コード, weightNo:体重計番号}
   */
  @PutMapping("/scale_bed_connect_reset")
  public ResponseEntity<?> postResetIsConnect(@RequestBody ScaleBedConnectResetRequest req) {
    String mappingUrl = Uri.SCALE_BED_STATE + "/scale_bed_connect_reset";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null, null);

    try {
      for (Long one : req.getBedCdList()) {
        scaleBedStateService.updateIsConnect(one, "0"); // {"0":"切断"}
      }

      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.WEIGHT_CONNECT, req.getFacilityCd(), req.getWeightNo());
      String payload = req.getWeightCd().toString();

      boolean bres = sendWsMsg.sendMsg(SendTarget.browser, req.getFacilityCd(), null, topic, payload);

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);

      String res = "{ \"websocket_send_responce\":" + bres + "}";
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
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
