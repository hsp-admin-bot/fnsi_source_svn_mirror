package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.amazonaws.util.StringUtils;
// #11987 2026.02.03 add スケールベッド対応 スケールベッドサービスの登録 TDC渡辺 start
import jp.co.nikkiso.ntss.admin_web.service.mente.MstWeightScaleBedService;
// #11987 2026.02.03 add スケールベッド対応 スケールベッドサービスの登録 TDC渡辺 end
import jp.co.nikkiso.ntss.admin_web.service.weight.WeightScalePrintThread;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.concurrent.DelegatingSecurityContextRunnable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.WebSocketTopic;
import jp.co.nikkiso.ntss.admin_web.request.weight.WeightPrintRequest;
import jp.co.nikkiso.ntss.admin_web.request.weight.WeightStateRequest;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightPrintResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService.SendTarget;
import jp.co.nikkiso.ntss.admin_web.service.weight.state.MntWeightStateService;
import jp.co.nikkiso.ntss.core.entity.MntWeightState;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@Slf4j
@RequestMapping(Uri.WEIGHT_STATE)
public class WeightStateResource {

  @Autowired
  MntWeightStateService mntWeightStateService;

  @Autowired
  WebSocketNotifyService sendWsMsg;

  @Autowired
  LogService logService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  // #10833 2024.08.23 add 体重計アプリへの印刷指示をスレッドにて実施する TDC米沢 start
  @Autowired
  private ApplicationContext applicationContext;
  // #10833 2024.08.23 add 体重計アプリへの印刷指示をスレッドにて実施する TDC米沢 end

  // #10833 2024.08.08 del static変数削除 TDC米沢 start
  // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
  // @Autowired
  // WeightResource weightResource;
  // private String doMiddle = "";
  // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
  // #10833 2024.08.08 del static変数削除 TDC米沢 end

  // #11987 2026.02.03 add スケールベッド対応 スケールベッドサービスの登録 TDC渡辺 start
  @Autowired
  MstWeightScaleBedService mstWeightScaleBedService;
  // #11987 2026.02.03 add スケールベッド対応 スケールベッドサービスの登録 TDC渡辺 end

  @PostMapping("/sync-master")
  public ResponseEntity<?> postWeightSyncMnt(@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/sync-master";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    SendConditionResponse res = new SendConditionResponse();
    try {
      mntWeightStateService.syncMaster(ntssUser.getFacilityCd());

      // #11987 2026.02.03 add スケールベッド対応 スケールベッドサービスの登録 TDC渡辺 start
      mstWeightScaleBedService.SyncScaleBedStateWithMaster(ntssUser.getFacilityCd());
      // #11987 2026.02.03 add スケールベッド対応 スケールベッドサービスの登録 TDC渡辺 end

      res.isSuccess = true;

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = e.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }
  // add マスタ一覧 1･施設切替を可能とする 孔s start
  @PostMapping("/sync-master/{facilityCd}")
  public ResponseEntity<?> postWeightSyncMntByFacilityCd(@PathVariable String facilityCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/sync-master";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    SendConditionResponse res = new SendConditionResponse();
    try {
      mntWeightStateService.syncMaster(facilityCd);

      // #11987 2026.02.03 add スケールベッド対応 スケールベッドサービスの登録 TDC渡辺 start
      mstWeightScaleBedService.SyncScaleBedStateWithMaster(facilityCd);
      // #11987 2026.02.03 add スケールベッド対応 スケールベッドサービスの登録 TDC渡辺 end
      
      res.isSuccess = true;
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }
  // add マスタ一覧 1･施設切替を可能とする 孔s end

  /**
   * 体重計状態を取得
   * @param scaleCd 体重計管理コード
   * @return
   */
  @GetMapping("/state/{scaleCd}")
  public ResponseEntity<?> getWeightState(@PathVariable Long scaleCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/state";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      scaleCd);
    // wp アプリケーションログの適正化 Add End
    MntWeightState state = mntWeightStateService.selectByScaleCd(scaleCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      scaleCd);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(state, HttpStatus.OK);
  }

  /**
   * カードの読み取り結果をDBに格納し、websocketでカード読み取りを通知する
   * @param request { weightCd:体重計管理コード, facilityCd:施設コード, weightNo:体重計番号, cardValue:読み取り値,
   *                cardCheckValue: カードチェック結果}
   * @return
   */
  @PutMapping("/card")
  public ResponseEntity<?> postCardRead(
      @RequestBody WeightStateRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/card";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      mntWeightStateService.updateCardReadValue(request.getWeightCd(), request.getCardReadValue().getValue());

      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.CARD_READ, request.getFacilityCd(),
          request.getWeightNo());

      String payload = request.getWeightCd().toString();

      // ブラウザあてにWebsocket通知
      Boolean bres = false;
      if (sendWsMsg.sendMsg(SendTarget.browser, request.getFacilityCd(), null, topic, payload)) {
        bres = true;
      }
      String res = "{ \"websocket_send_responce\":" + bres.toString() + "}";

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 体重計の読み取り結果をDBに格納し、websocketでカード読み取りを通知する
   * @param request { scaleCd:体重計管理コード, facilityCd:施設コード, weightNo:体重計番号, scaleValue:測定値 }
   * @return
   */
  @PutMapping("/scale_value")
  public ResponseEntity<?> postScaleValue(
      @RequestBody WeightStateRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/scale_value";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      // add FNSI-田中衡機の追加 徐 start
      if (!StringUtils.isNullOrEmpty(request.getScaleValueList())) {
        // 田中衡機測定値の更新
        mntWeightStateService.updateScaleValueList(request.getWeightCd(), request.getScaleValueList());
      } else {
        mntWeightStateService.updateScaleValue(request.getWeightCd(), request.getScaleValue());
      }
      // add FNSI-田中衡機の追加 徐 end

      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.SCALE, request.getFacilityCd(),
          request.getWeightNo());

      String payload = request.getWeightCd().toString();

      // ブラウザあてにWebsocket通知
      Boolean bres = false;
      if (sendWsMsg.sendMsg(SendTarget.browser, request.getFacilityCd(), null, topic, payload)) {
        bres = true;
      }
      String res = "{ \"websocket_send_responce\":" + bres.toString() + "}";

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * カードの書き込み内容をDBに格納し、websocketでカード書き込みを指示する
   * @param scaleCd 体重計管理コード
   * @param request { scaleCd:体重計管理コード, facilityCd:施設コード, weightNo:体重計番号, cardWriteValue:書き込み内容 }
   * @return
   */
  @PutMapping("/write_card")
  public ResponseEntity<?> postWriteCard(
      @RequestBody WeightStateRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/write_card";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      mntWeightStateService.updateCardWriteValue(request.getWeightCd(), request.getCardWriteValue());

      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.CARD_WRITE, request.getFacilityCd(),
          request.getWeightNo());

      String payload = request.getWeightCd().toString();

      // 体重計アプリにWebsocket通知
      Boolean bres = false;
      if (sendWsMsg.sendMsg(SendTarget.weightApp, request.getFacilityCd(), request.getWeightNo(), topic, payload)) {
        bres = true;
      }
      String res = "{ \"websocket_send_responce\":" + bres.toString() + "}";

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * カードの書き込み結果をDBに格納し、websocketでカード書き込み結果取得を指示する
   * @param scaleCd 体重計管理コード
   * @param request { scaleCd:体重計管理コード, facilityCd:施設コード, weightNo:体重計番号, writeResult:書き込み結果 }
   * @return
   */
  @PutMapping("/write_card_result")
  public ResponseEntity<?> postWriteCardResult(
      @RequestBody WeightStateRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/write_card";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      mntWeightStateService.updateWriteResult(request.getWeightCd(), request.getWriteResult());

      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.CARD_WRITE_RESULT,
          request.getFacilityCd(), request.getWeightNo());

      String payload = request.getWeightCd().toString();

      // ブラウザあてにWebsocket通知
      Boolean bres = false;
      if (sendWsMsg.sendMsg(SendTarget.browser, request.getFacilityCd(), null, topic, payload)) {
        bres = true;
      }
      String res = "{ \"websocket_send_responce\":" + bres.toString() + "}";

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 体重計装置の接続状況をDBに格納し、websocketで通知する
   * @param scaleCd 体重計管理コード
   * @param request { scaleCd:体重計管理コード, facilityCd:施設コード, weightNo:体重計番号, isConnect:接続状態 }
   * @return
   */
  @PutMapping("/weight_connect")
  public ResponseEntity<?> postWriteIsConnect(
      @RequestBody WeightStateRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/weight_connect";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      mntWeightStateService.updateIsConnect(request.getWeightCd(), request.getIsConnect());

      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.WEIGHT_CONNECT, request.getFacilityCd(),
          request.getWeightNo());

      String payload = request.getWeightCd().toString();

      // ブラウザあてにWebsocket通知
      Boolean bres = false;
      if (sendWsMsg.sendMsg(SendTarget.browser, request.getFacilityCd(), null, topic, payload)) {
        bres = true;
      }
      String res = "{ \"websocket_send_responce\":" + bres.toString() + "}";

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  public class printStatus {
    public static final int NO_PRINT = 0;
    public static final int ORDER = 1;
    public static final int RECV = 2;
    public static final int OK = 3;
    public static final int NG = 4;
  }

  /**
   * 印刷指示
   * @param request
   * @return
   */
  @PostMapping("/print")
  public ResponseEntity<?> postPrintSheet(
    @RequestBody WeightPrintRequest request) {

    // #10833 2024.08.26 mod アプリケーションログのファンクションコードを指定する TDC米沢 start
    // // wp アプリケーションログの適正化 Add Start
    // String mappingUrl = Uri.WEIGHT_STATE + "/print";
    // logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
    //   null);
    // // wp アプリケーションログの適正化 Add End
    String mappingUrl = Uri.WEIGHT_STATE + "/print";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SEND_CONDITION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // #10833 2024.08.26 mod アプリケーションログのファンクションコードを指定する TDC米沢 end

    try {
      // #10833 2024.08.23 add 体重計アプリへの印刷指示をスレッドにて実施する TDC米沢 start
      // String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.PRINT, request.getFacilityCd(),
      //     request.getWeightNo());
      // // #10833 2024.08.08 mod static変数削除 TDC米沢 start
      // // // mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
      // // //String payload = request.getWeightScaleNo().toString();
      // // String payload = "";
      // // // 空欄判断と重複判断
      // // // mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
      // // // if (("".equals(doMiddle) || !doMiddle.equals(weightResource.weightScaleNo)) && !"".equals(weightResource.weightScaleNo)) {
      // // // doMiddle = weightResource.weightScaleNo;
      // // //   payload = weightResource.weightScaleNo;
      // // // }
      // // if (("".equals(doMiddle) || !doMiddle.equals(weightResource.getWeightScaleNo)) && !"".equals(weightResource.getWeightScaleNo)) {
      // //   doMiddle = weightResource.getWeightScaleNo;
      // //   payload = weightResource.getWeightScaleNo;
      // // }
      // // // mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
      // // // mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
      // String payload = request.getWeightScaleNo().toString();
      // // #10833 2024.08.08 mod static変数削除 TDC米沢 end
      // // 体重計アプリにWebsocket通知
      // Boolean bres = false;
      // if (sendWsMsg.sendMsg(SendTarget.weightApp, request.getFacilityCd(), request.getWeightNo(), topic, payload)) {
      //   bres = true;
      //   // 状態を指示中にする
      //   mntWeightStateService.updatePrintStatus(request.getWeightScaleNo(), printStatus.ORDER, "");
      // } else {
      //   // 状態を印刷失敗にする
      //   mntWeightStateService.updatePrintStatus(request.getWeightScaleNo(), printStatus.NG, "指示通知失敗");
      // }
      // String res = "{ \"websocket_send_responce\":" + bres.toString() + "}";
      //
      // // wp アプリケーションログの適正化 Add Start
      // logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      //   null);
      // // wp アプリケーションログの適正化 Add End
      //
      // return new ResponseEntity<>(res, HttpStatus.OK);

      // 体重計アプリへの印刷指示用スレッドを生成
      WeightScalePrintThread trd = new WeightScalePrintThread(
        request.getFacilityCd(),
        request.getWeightNo(),
        request.getWeightScaleNo()
      );

      // newによりオブジェクト生成を行った場合、生成オブジェクト内のSpringによる@Autowired対象オブジェクトが自動生成されないため、アプリケーションコンテキストにて@Autowiredのオブジェクトの生成処理を行う
      applicationContext.getAutowireCapableBeanFactory().autowireBean(trd);

      // スレッド内で記録するログのために本REST呼び出し時のセキュリティ情報(接続情報を含む)をスレッドに渡す
      SecurityContext context = SecurityContextHolder.getContext();
      DelegatingSecurityContextRunnable wrappedRunnable = new DelegatingSecurityContextRunnable(trd, context);

      // スレッドによる印刷指示を実施
      new Thread(wrappedRunnable).start();

      // アプリケーションログ
      // #10833 2024.08.26 mod アプリケーションログのファンクションコードを指定する TDC米沢 start
      // logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      //   null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SEND_CONDITION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // #10833 2024.08.26 mod アプリケーションログのファンクションコードを指定する TDC米沢 end
      return new ResponseEntity<>(null, HttpStatus.OK);
      // #10833 2024.08.23 add 体重計アプリへの印刷指示をスレッドにて実施する TDC米沢 end
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // #10833 2024.08.26 mod アプリケーションログのファンクションコードを指定する TDC米沢 start
      // // wp アプリケーションログの適正化 Add Start
      // logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // // wp アプリケーションログの適正化 Add End
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SEND_CONDITION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // #10833 2024.08.26 mod アプリケーションログのファンクションコードを指定する TDC米沢 end
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 印刷内容を取得
   * @param weightScaleNo 体重測定記録番号
   * @return
   */
  @GetMapping("/print_content/{weightScaleNo}")
  public ResponseEntity<?> getPrintContent(@PathVariable Long weightScaleNo) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/print_content";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    WeightPrintResponse res = new WeightPrintResponse();
    try {
      String content = mntWeightStateService.selectPrintContent(weightScaleNo);
      res.isSuccess = true;
      res.printContent = content;
      res.weightScaleNo = weightScaleNo;

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 印刷結果を更新
   * @param
   * @return
   */
  @PutMapping("/print_status")
  public ResponseEntity<?> putPrintStatus(
      @RequestBody WeightPrintRequest request) {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/print_status";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    WeightPrintResponse res = new WeightPrintResponse();
    try {
      res.weightScaleNo = request.getWeightScaleNo();

      int i = mntWeightStateService.updatePrintStatus(request.getWeightScaleNo(), request.getPrintStatus(),
          request.getPrintErrorMessage());

      if (i < 1) {
        res.isSuccess = false;
        res.errorMessage = "更新対象なし";
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }
      res.isSuccess = true;
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add FNSI-田中衡機の追加 徐 start
  /**
   * 体重Appに「受信開始OK」という通知を送る
   * @param request 体重App
   * @return
   */
  @PostMapping("/weightAppOk")
  public ResponseEntity<?> postWeightAppOk(
    @RequestBody WeightPrintRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_STATE + "/weightAppOk";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.WeightState.SENDOK, request.getFacilityCd(),
        request.getWeightNo());
      String payload = request.getWeightCd().toString();

      // 体重計アプリにWebsocket通知
      Boolean bres = false;
      if (sendWsMsg.sendMsg(SendTarget.weightApp, request.getFacilityCd(), request.getWeightNo(), topic, payload)) {
        bres = true;
      }
      String res = "{ \"websocket_send_responce\":" + bres.toString() + "}";

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add FNSI-田中衡機の追加 徐 end

// #10833 2024.08.08 del 使用しないREST-APIを削除 TDC米沢 start
//   // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
//   /**
//    * 印刷処理前にステータスチェック
//    * @return
//    */
//   @GetMapping("/print_falg")
//   public ResponseEntity<?> postPrintFalg() {
//
//     String mappingUrl = Uri.WEIGHT_STATE + "/print_falg";
//     logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
//       null);
//
//     try {
//       Boolean doIn = false;
//       // 印刷処理前にステータスチェック
//       // mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
//       // if (("".equals(doMiddle) || !doMiddle.equals(weightResource.weightScaleNo)) && !"".equals(weightResource.weightScaleNo)) {
//       if (("".equals(doMiddle) || !doMiddle.equals(weightResource.getWeightScaleNo)) && !"".equals(weightResource.getWeightScaleNo)) {
//       // mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
//         doIn = true;
//       }
//       String res = "{ \"websocket_send_responce\":" + doIn.toString() + "}";;
//       logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
//         null);
//       return new ResponseEntity<>(res, HttpStatus.OK);
//     } catch (Exception e) {
// //      EventLogMessage eventLogMessage = new EventLogMessage();
// //      eventLogMessage.setLogMessage(e.getMessage());
// //      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
//
//       logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
//       return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//     }
//   }
//   // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
// #10833 2024.08.08 del 使用しないREST-APIを削除 TDC米沢 end

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
