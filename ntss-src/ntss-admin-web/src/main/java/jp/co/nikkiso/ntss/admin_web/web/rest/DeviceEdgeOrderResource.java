package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Objects;
import java.util.concurrent.ExecutorService;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;
import jp.co.nikkiso.ntss.api.service.additionInfo.AdditionCalculationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;

import jakarta.annotation.Resource;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

@RestController
@Slf4j
@RequestMapping(Uri.DEVICE_EDGE_ORDER)
public class DeviceEdgeOrderResource {

  @Autowired
  DeviceEdgeOrderService deviceEdgeOrderService;

  @Autowired
  LogService logService;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  // add 11454 時間外加算自動処理が機能していない zkm start
  @Autowired
  private AdditionCalculationService additionCalculationService;
  // add 11454 時間外加算自動処理が機能していない zkm end

  @Autowired
  private OrdMainDao ordMainDao;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  //add 9480 治療記録(オフライン運転終了指示),检查计算 gjn start
  @Resource(name = "crawlExecutorPool")
  private ExecutorService threadExector;
  //add 9480 治療記録(オフライン運転終了指示),检查计算 gjn end

  @GetMapping("/device-edge-list")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReadOption(
    // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/device-edge-list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(deviceEdgeOrderService.findMstDeviceEdgeNo(ntssUser.getFacilityCd()), HttpStatus.OK);
    } catch (Exception e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(new ArrayList<>(), HttpStatus.BAD_REQUEST);
    }
  }
//  ADD マスタ一覧 1･施設切替を可能とする 孔 START
  @GetMapping("/device-edge-list/{facilityCd}")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReadOptionByFacilityCd(
    // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
    @PathVariable String facilityCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (facilityCd != null && !facilityCd.isEmpty() &&
              !facilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "facilityCd=" + facilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/device-edge-list";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End
    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(deviceEdgeOrderService.findMstDeviceEdgeNo(facilityCd), HttpStatus.OK);
    } catch (Exception e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(new ArrayList<>(), HttpStatus.BAD_REQUEST);
    }
  }
//  ADD マスタ一覧 1･施設切替を可能とする 孔 END

  /**
   * 装置オプション読出し指示
   */
  @PostMapping("/read_option")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReadOption(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/read_option";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      res = deviceEdgeOrderService.orderReadOption(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);


      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 設定値読出し指示
   */
  @PostMapping("/read_setting_value")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReadSettingValue(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/getBbsInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      res = deviceEdgeOrderService.orderReadSettingValue(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo(), targetInfo.getOrdNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  //FNSI-修正 #5525 横展開対応、xugj add
  /**
   * 次患者情報転送指示(患者経過総合ビューア)
   */
  @PostMapping("/send_next_pat_viewer")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderSendNextPatInfo(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
                                             @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    boolean isNextPatFlg = deviceEdgeOrderService.getIsNextPatInfo(request.getOrdNo());
    if(!isNextPatFlg) {
      DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
      return new ResponseEntity<>(res, HttpStatus.OK);
    }

    return PostOrderSendNextPat(request, ntssUser);
  }

  /**
   * 次患者情報転送指示
   */
  @PostMapping("/send_next_pat")
  public ResponseEntity<?> PostOrderSendNextPat(@RequestBody DeviceEdgeOrderRequest request,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/send_next_pat";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null && ntssUser != null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      res = deviceEdgeOrderService.orderSendNextPat(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo(), targetInfo.getOrdNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 通信サーバー設定更新指示
   */
  @PostMapping("/reload_comsv_setting")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReloadComsvSetting(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/reload_comsv_setting";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = request;
      if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
          || request.getDeviceEdgeNo() == null) {
        targetInfo = deviceEdgeOrderService.findMissingData(request);
      }
      res = deviceEdgeOrderService.orderReloadComsvSetting(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 愁訴処置マスタ更新指示
   */
  @PostMapping("/reload_complaint_master")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReloadTreatMaster(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/reload_complaint_master";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = request;
      if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
          || request.getDeviceEdgeNo() == null) {
        targetInfo = deviceEdgeOrderService.findMissingData(request);
      }
      res = deviceEdgeOrderService.orderReloadTreatMaster(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * スタッフマスタ更新指示
   */
  @PostMapping("/reload_staff_master")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReloadStaffMaster(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/reload_staff_master";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = request;
      if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
          || request.getDeviceEdgeNo() == null) {
        targetInfo = deviceEdgeOrderService.findMissingData(request);
      }
      res = deviceEdgeOrderService.orderReloadStaffMaster(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 未登録患者割付
   */
  @PostMapping("/set_unknown_pat")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderSetUnknownPat(@RequestBody DeviceEdgeOrderRequest request,
 // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/set_unknown_pat";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);

      res = deviceEdgeOrderService.orderSetUnknownPat(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo(), targetInfo.getOrdNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 条件送信キャンセル指示
   */
  @PostMapping("/cancel_condition")
  public ResponseEntity<?> PostOrderCancelCondition(@RequestBody DeviceEdgeOrderRequest request,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/cancel_condition";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null && ntssUser != null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);

      res = deviceEdgeOrderService.orderCancelCondition(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 投薬指示変更指示
   */
  @PostMapping("/change_ind_medi")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderChangeIndMedi(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    if(!ntssUser.isNkkAdminUser()) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/change_ind_medi";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      res = deviceEdgeOrderService.orderChangeIndMedi(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo(), targetInfo.getOrdNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 後体重測定指示
   */
  @PostMapping("/after_weight")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderAfterWeight(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    if(!ntssUser.isNkkAdminUser()) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/after_weight";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);

      res = deviceEdgeOrderService.orderAfterWeight(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo());
    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 治療状況確認指示
   */
  @PostMapping("/check_status")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderCheckStatus(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/check_status";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);

      res = deviceEdgeOrderService.orderCheckStatus(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * チェックリストマスタ更新指示
   */
  @PostMapping("/reload_checklist_master")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReloadChecklistMaster(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/reload_checklist_master";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = request;
      if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
          || request.getDeviceEdgeNo() == null) {
        targetInfo = deviceEdgeOrderService.findMissingData(request);
      }
      res = deviceEdgeOrderService.orderReloadChecklistMaster(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      /* upd EOL対応内部 #6976 by ztc 2023-07-09 --start */
//      return ResponseEntity.status(2001).body(res);
      return new ResponseEntity<>(res, HttpStatus.OK);
      /* upd EOL対応内部 #6976 by ztc 2023-07-09 --end */
    }
  }

  /**
   * 仮想端末キャッシュクリア指示
   */
  @PostMapping("/chache_clear")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderCacheClear(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/chache_clear";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);

      res = deviceEdgeOrderService.orderCacheClear(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 検査項目マスタ更新指示
   */
  @PostMapping("/reload_exam_master")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderReloadExamMaster(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/reload_exam_master";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }

      DeviceEdgeOrderRequest targetInfo = request;
      if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
          || request.getDeviceEdgeNo() == null) {
        targetInfo = deviceEdgeOrderService.findMissingData(request);
      }
      res = deviceEdgeOrderService.orderReloadExamMaster(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * オフライン運転開始指示
   * @throws RuntimeException
   * @throws URISyntaxException
   */
  @PostMapping("/start_treat_offline")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderStartTreatOffline(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) throws URISyntaxException, RuntimeException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/start_treat_offline";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);

      res = deviceEdgeOrderService.orderStartTreatOffline(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
          targetInfo.getMachineNo());

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // 加算処理
      AdditionCalculationRequest addReq = new AdditionCalculationRequest();
      OrdMain ordMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      addReq.setFacilityCd(ordMain.getFacilityCd());
      addReq.setPatId(ordMain.getPatId());
      addReq.setOrdNo(ordMain.getOrdNo());
      addReq.setEventId(5);

      // mod 11454 時間外加算自動処理が機能していない zkm start
//      webApiCallCommonUtil.calculationAddition(addReq);
      additionCalculationService.calculationAddition(addReq);
      // mod 11454 時間外加算自動処理が機能していない zkm end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * オフライン運転終了指示
   */
  @PostMapping("/end_treat_offline")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderEndTreatOffline(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null &&
              !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // #10889 2024.09.05 mod 治療終了処理を修正 TDC片口 start
//    // add FNSI-redime5618 fang start
//    boolean result = false;
//    try {
//      result = deviceEdgeOrderService.updateOrdmainAndNextPat(request.getOrdNo());
//    } catch (URISyntaxException e) {
//      // 更新処理ができなかった場合
//      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, "end_treat_offline", null, e.getMessage());
//      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
//        HttpStatus.BAD_REQUEST);
//    }
//    if (result) {
//      //add 9480 治療記録(オフライン運転終了指示) gjn start
//      threadExector.execute(new Runnable() {
//        @Override
//        public void run() {
//          // 非同期実行チェック計算
//          webApiCallCommonUtil.doAutoCalculation(request.getOrdNo());
//        }
//      });
//      //add 9480 治療記録(オフライン運転終了指示) gjn end
//      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
//    }
//    // add FNSI-redime5618 fang end
    try {
      DeviceEdgeOrderService.EndTreatResponse result = deviceEdgeOrderService.endTreat(request.getFacilityCd(), request.getOrdNo());
      if (result == DeviceEdgeOrderService.EndTreatResponse.SUCCESS) {
        // 処理成功ならば加算処理を呼んで処理終了
        threadExector.execute(() -> {
          // 非同期実行チェック計算
          webApiCallCommonUtil.doAutoCalculation(request.getOrdNo());
        });
        return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
      }
      if (result == DeviceEdgeOrderService.EndTreatResponse.ALREADY) {
        // ALREADY ならば更新不要（既に別ルートで治療終了されているなど）なのでそのままOKを返し終了
        return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.OK);
      }
      if (result == DeviceEdgeOrderService.EndTreatResponse.FAILED) {
        // FAILED ならば(次患者更新が)失敗だけど、コードを潜ると発生しないはずなのでここはおまじない
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, Uri.DEVICE_EDGE_ORDER + "/end_treat_offline", request.getFacilityCd(), "次患者更新で例外発生");
        return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
      }
      // result == MUST_NOTIFY ならば下のDE通知処理へ進む

    } catch (Exception e) {
      // 更新処理ができなかった場合
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, Uri.DEVICE_EDGE_ORDER + "/end_treat_offline", request.getFacilityCd(), e.getMessage());
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
        HttpStatus.BAD_REQUEST);
    }
    // #10889 2024.09.05 mod 治療終了処理を修正 TDC片口 end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/end_treat_offline";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);

      // #11192 2025.03.26 mod 治療終了指示にオーダー番号を含める TDC片口 start
//      res = deviceEdgeOrderService.orderEndTreatOffline(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
//          targetInfo.getMachineNo());
      res = deviceEdgeOrderService.orderEndTreatOffline(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
        targetInfo.getMachineNo(), targetInfo.getOrdNo());
      // #11192 2025.03.26 mod 治療終了指示にオーダー番号を含める TDC片口 end

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("There is no MstUser.");
//    	logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    	null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  // add 通信サーバー通信追加 房 start
  /**
   * オフラインレポート更新
   */
  @PostMapping("/send_report_update")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> postOrderReportUpdate(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
                                             @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/send_report_update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null, request);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {

      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #10518 2024.04.19 mod 実績確定時に現患者で装置表示レポート対象であった実績の場合のみ「実績版確定時装置レポート画像更新」通知を行うメソッドの引数を変更 TDC米沢 start
      // DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      //
      // res = deviceEdgeOrderService.orderReportUpdate(request.getOrdNo() ,targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
      //   targetInfo.getMachineNo());
      res = deviceEdgeOrderService.orderReportUpdate(request.getPatId(), request.getOrdNo(), request.getFacilityCd());
      // #10518 2024.04.19 mod 実績確定時に現患者で装置表示レポート対象であった実績の場合のみ「実績版確定時装置レポート画像更新」通知を行うメソッドの引数を変更 TDC米沢 end


    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("There is no MstUser.");
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//        null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null, res);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null, res);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * オフライン終了日更新
   */
  @PostMapping("/send_end_date_update")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> postOrderEndDateUpdate(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
                                             @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/send_end_date_update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);

      res = deviceEdgeOrderService.orderEndDateUpdate(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
        targetInfo.getMachineNo());

    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("There is no MstUser.");
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//        null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }
  // add 通信サーバー通信追加 房 end

  // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うREST-APIを追加 TDC米沢 start
  /**
   * 実績確定・削除時装置レポート画像更新
   */
  @PostMapping("/send_all_report_update_by_pat_id")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> postAllReportUpdateByPatId(@RequestBody DeviceEdgeOrderRequest request,
// #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
                                               @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/send_all_report_update_by_pat_id";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null, request);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      res = deviceEdgeOrderService.orderAllReportUpdateByPatId(request.getFacilityCd(), request.getPatId());

    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("There is no MstUser.");
//      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//        null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null, res);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null, res);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }
  // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うREST-APIを追加 TDC米沢 end

  // add 治療時間変更指示の通信サーバー通信追加 ljx start
  /**
   * 治療時間変更指示
   */
  @PostMapping("/change_treat_time")
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang start
  public ResponseEntity<?> PostOrderChangeTreatTime(@RequestBody DeviceEdgeOrderRequest request,
  // #9698 アプリケーションログの内容修正 20260401 mod yangxuewang end
                                           @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request != null && request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " +
                "request.getFacilityCd()=" + request.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    String mappingUrl = Uri.DEVICE_EDGE_ORDER + "/change_treat_time";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null, request);

    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      if (request.getFacilityCd() == null) {
        request.setFacilityCd(ntssUser.getFacilityCd());
      }
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(request);
      res = deviceEdgeOrderService.orderChangeTreatTime(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(),
        targetInfo.getMachineNo(), targetInfo.getOrdNo());

    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    if (res.isSuccess) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null, res);
      return new ResponseEntity<>(res, HttpStatus.OK);
    } else {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null, res);
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }
  // add 治療時間変更指示の通信サーバー通信追加 ljx end
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
