package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;

import jakarta.validation.Valid;
import java.util.HexFormat;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.DeviceEdgeManageProperties;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeManage.DeviceEdgeManageRequest;
import jp.co.nikkiso.ntss.admin_web.request.motionRecord.DownloadGatheringRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeManage.DeviceEdgeManageResponse;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeManage.ResponseS3Bucket;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeManage.DeviceEdgeManageService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.DeviceEdgeStateWithManage;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

@RestController
@RequestMapping(Uri.DEVICE_EDGE_MANAGE)
public class DeviceEdgeManageResource {

  @Autowired
  private DeviceEdgeManageService deviceEdgeMaganeService;
  @Autowired
  LogService logService;

  @Autowired
  private WebSocketNotifyService webSocketNotifyService;

  @Autowired
  private DeviceEdgeManageProperties myPropaties;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private String exampleS3Bucket = "ntss-s3-root";
  private static final String EXAMPLE_S3_BUCKET = "ntss-s3-root";
  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  private final short statusOrder = 0;
  private final short statusError = -2;

  @GetMapping("/device-edge-info")
  public ResponseEntity<?> getDeviceEdgeStateAll(
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/device-edge-info";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage( "CALL getDeviceEdgeState ");
//    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,null);
    try {
      List<DeviceEdgeStateWithManage> res = deviceEdgeMaganeService.getDeviceEdgeState();
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if (!ntssUser.isNkkAdminUser()) {
        for (DeviceEdgeStateWithManage re : res) {
          if (re != null && re.getFacilityCd() != null &&
            !re.getFacilityCd().equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + re.getFacilityCd() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          }
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

//      eventLogMessage.setLogMessage( "RETURN getDeviceEdgeState ");
//      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//      null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//      null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/device-edge-info/{facility_cd}/{device_edge_no}")
  public ResponseEntity<?> getDeviceEdgeState(@PathVariable("facility_cd") String facilityCd,
      @PathVariable("device_edge_no") Integer deviceEdgeNo,
                                              // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                              @AuthenticationPrincipal NtssUser ntssUser
                                              // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.isEmpty() &&
      !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    try{
      if (facilityCd != null && !facilityCd.isEmpty() &&
        !facilityCd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }catch (Exception ignored) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage(
//        "CALL getDeviceEdgeState [favility_cd: " + facilityCd + ", device_edge_no: " + deviceEdgeNo + "]");
//    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/device-edge-info";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      deviceEdgeNo);
    // wp アプリケーションログの適正化 Add End

    try {
      DeviceEdgeStateWithManage res = deviceEdgeMaganeService.getDeviceEdgeState(facilityCd, deviceEdgeNo);

//      eventLogMessage.setLogMessage(
//          "RETURN getDeviceEdgeState [favility_cd: " + facilityCd + ", device_edge_no: " + deviceEdgeNo + "]");
//      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//          null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        deviceEdgeNo);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//          null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/status/{manage_no}")
  public ResponseEntity<?> getDeviceEdgeUpdaterManageStatus(
      @PathVariable("manage_no") Long manageNo,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (!ntssUser.isNkkAdminUser()) {
      MntDeviceEdgeManage manage = deviceEdgeMaganeService.selectByManageNo(manageNo);
      if (manage != null && manage.getFacilityCd() != null &&
        !manage.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + manage.getFacilityCd() + " " + "manageNo=" + manageNo + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    try{
      MntDeviceEdgeManage manage = deviceEdgeMaganeService.selectByManageNo(manageNo);
      if (manage != null && manage.getFacilityCd() != null &&
        !manage.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }catch (Exception ignored) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/status";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      manageNo);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeManageResponse res = new DeviceEdgeManageResponse();

    try {
      MntDeviceEdgeManage manage = deviceEdgeMaganeService.selectByManageNo(manageNo);
      if (manage == null) {
        res.isSuccess = false;
        res.errorMessage = "値なし";

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
          manageNo);
        // wp アプリケーションログの適正化 Add End

        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }

      res.isSuccess = true;
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
        manageNo);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//          null);

      res.isSuccess = false;
      res.errorMessage = e.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * アプリ開始・停止等指示情報取得
   * @return
   */
  @PostMapping("/device-control")
  public ResponseEntity<?> createAppControlInfo(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody DeviceEdgeManageRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/device-control";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeManageResponse res = new DeviceEdgeManageResponse();
    try {
      String targetFacilityCd = request.getTargetFacilityCd();
      Integer deviceEdgeNo = request.getDeviceEdgeNo();
      MntDeviceEdgeManage param = request.getManageParam();
      MntDeviceEdgeManage.ManageInfo manageInfo = new MntDeviceEdgeManage.ManageInfo();

      /* modify by SongJiHao  2023-02-01 [Transaction,Remote]  */
      res = deviceEdgeMaganeService.sendOrderToEdge(ntssUser, targetFacilityCd, deviceEdgeNo, param, manageInfo, null);

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
    } catch (Exception ex) {
      res.isSuccess = false;
      res.errorMessage = ex.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, ex.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * ログ/Conf収集指示情報取得
   * @param ntssUser
   * @param request
   * @return
   */
  @PostMapping("/file-gather")
  public ResponseEntity<?> orderFileGather(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody DeviceEdgeManageRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/file-gather";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeManageResponse res = new DeviceEdgeManageResponse();
    try {
      String targetFacilityCd = request.getTargetFacilityCd();
      Integer deviceEdgeNo = request.getDeviceEdgeNo();
      MntDeviceEdgeManage param = request.getManageParam();
      MntDeviceEdgeManage.ManageInfo manageInfo = new MntDeviceEdgeManage.ManageInfo();

      /* modify by SongJiHao  2023-02-01 [Transaction,Remote]  */
      res = deviceEdgeMaganeService.sendOrderToEdge(ntssUser, targetFacilityCd, deviceEdgeNo, param, manageInfo, null);

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
    } catch (Exception ex) {
      res.isSuccess = false;
      res.errorMessage = ex.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, ex.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * レストア指示情報取得
   * @param ntssUser
   * @param request
   * @return
   */
  @PostMapping("/restore")
  public ResponseEntity<?> orderRestore(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody DeviceEdgeManageRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/restore";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeManageResponse res = new DeviceEdgeManageResponse();
    try {
      String targetFacilityCd = request.getTargetFacilityCd();
      Integer deviceEdgeNo = request.getDeviceEdgeNo();
      MntDeviceEdgeManage param = request.getManageParam();
      MntDeviceEdgeManage.ManageInfo manageInfo = new MntDeviceEdgeManage.ManageInfo();

      /* modify by SongJiHao  2023-02-01 [Transaction,Remote]  */
      res = deviceEdgeMaganeService.sendOrderToEdge(ntssUser, targetFacilityCd, deviceEdgeNo, param, manageInfo, null);

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
    } catch (Exception ex) {
      res.isSuccess = false;
      res.errorMessage = ex.getMessage();
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, ex.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }

  }

  @GetMapping("/target-s3-bucket")
  public ResponseEntity<ResponseS3Bucket> getUploadTargetInfo(// #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                              @AuthenticationPrincipal NtssUser ntssUser
                                                              // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    try{
      List<SysSystemDefine> data = sysSystemDefineDao.selectByCtlNo(37);
      for (SysSystemDefine datum : data) {
        if (datum != null && datum.getFacilityCd() != null &&
          !datum.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    }catch (Exception ignored) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/target-s3-bucket";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    ResponseS3Bucket res = new ResponseS3Bucket();
    String s3Bucket = EXAMPLE_S3_BUCKET;
    try {
      // DE更新用zipファイルパスのデフォルト設定を取得
      List<SysSystemDefine> data = sysSystemDefineDao.selectByCtlNo(37);
      if (data.size() > 0) {
        String strJson = data.get(0).getValue();
        JSONObject objJson = new JSONObject(strJson);
        s3Bucket = objJson.getString("path");
      }
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null, e.getMessage());
    }
    res.setExists(true);
    // バケット情報を取得して返す
    res.setBucket(s3Bucket);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  @GetMapping("/target-conf-upload-info/{facility_cd}/{device_edge_no}")
  public ResponseEntity<ResponseS3Bucket> getUploadTargetInfo(
      @PathVariable("facility_cd") String facilityCd,
      @PathVariable("device_edge_no") int deviceEdgeNo,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.isEmpty() &&
      !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    try{
      if (facilityCd != null && !facilityCd.isEmpty() &&
        !facilityCd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }catch (Exception ignored) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/target-conf-upload-info";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      deviceEdgeNo);
    // wp アプリケーションログの適正化 Add End

    ResponseS3Bucket res = new ResponseS3Bucket();
    String s3Bucket = EXAMPLE_S3_BUCKET;
    if (myPropaties.getDeviceEdgeManage() != null && myPropaties.getDeviceEdgeManage().getS3Bucket() != null
        && !myPropaties.getDeviceEdgeManage().getS3Bucket().isEmpty()) {
      s3Bucket = myPropaties.getDeviceEdgeManage().getS3Bucket();
    }
    // Pathに施設コードを適用
    String s3BucketInFcd = String.format(s3Bucket, facilityCd);
    res.setExists(false);
    try {
      // アップロード先情報を取得して返す
      res = deviceEdgeMaganeService.findConfS3UpTarget(s3BucketInFcd, deviceEdgeNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        deviceEdgeNo);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      res.setMessage(e.getMessage());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * ログダウンロード先情報取得
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  @GetMapping("/target-log-file-info/{facility_cd}/{device_edge_no}/{date}")
  public ResponseEntity<ResponseS3Bucket> getLogDownloadTargetInfo(
      @PathVariable("facility_cd") String facilityCd,
      @PathVariable("device_edge_no") int deviceEdgeNo,
      @PathVariable("date") String dateStr,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.isEmpty() &&
      !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    try{
      if (facilityCd != null && !facilityCd.isEmpty() &&
        !facilityCd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }catch (Exception ignored) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/target-log-file-info";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      Arrays.asList(deviceEdgeNo, dateStr));
    // wp アプリケーションログの適正化 Add End

    ResponseS3Bucket res = new ResponseS3Bucket();
    res.setExists(false);
    try {
      // ダウンロード先情報を取得して返す
      res = deviceEdgeMaganeService.findLogInfo(facilityCd, deviceEdgeNo, dateStr);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        Arrays.asList(deviceEdgeNo, dateStr));
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      res.setMessage(e.getMessage());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * ログダウンロード処理
   *
   * @param request ファイルダウンロードのリクエスト
   * @return ファイルダウンロード用ResponseEntity
   */
  @PostMapping("/target-log-file/download")
  public ResponseEntity<?> getLogDownloadTarget(@Valid @RequestBody DownloadGatheringRequest request) {
    // ログ出力
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/target-log-file-info/download";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null, null);

    try {
      String localPath = request.getBucket();
      String filename = request.getFilename();

      String fileLocation = localPath + "/" + filename;
      Path path = Paths.get(fileLocation);
      byte[] bytes = Files.readAllBytes(path);
      // 16進数文字列に変換
      String hexString = HexFormat.of().withUpperCase().formatHex(bytes);

      //　ログ出力
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null, null);
      return new ResponseEntity<>(hexString, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * confファイルダウンロード先情報取得
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  @GetMapping("/target-conf-file-info/{facility_cd}/{device_edge_no}")
  public ResponseEntity<ResponseS3Bucket> getLogDownloadTargetInfo(
      @PathVariable("facility_cd") String facilityCd,
      @PathVariable("device_edge_no") int deviceEdgeNo,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if (!ntssUser.isNkkAdminUser() && facilityCd != null && !facilityCd.isEmpty() &&
      !facilityCd.equals(ntssUser.getFacilityCd())) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    try{
      if (facilityCd != null && !facilityCd.isEmpty() &&
        !facilityCd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }catch (Exception ignored) {
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/target-log-file-info";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      deviceEdgeNo);
    // wp アプリケーションログの適正化 Add End

    ResponseS3Bucket res = new ResponseS3Bucket();
    String s3Bucket = EXAMPLE_S3_BUCKET;
    if (myPropaties.getDeviceEdgeManage() != null && myPropaties.getDeviceEdgeManage().getConfUploadPath() != null
        && !myPropaties.getDeviceEdgeManage().getConfUploadPath().isEmpty()) {
      s3Bucket = myPropaties.getDeviceEdgeManage().getConfUploadPath();
    }
    // Pathに施設コードを適用
    String s3BucketInFcd = String.format(s3Bucket, facilityCd);
    res.setExists(false);
    try {
      // ダウンロード先情報を取得して返す
      res = deviceEdgeMaganeService.findConfS3Info(s3BucketInFcd, facilityCd, deviceEdgeNo);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        deviceEdgeNo);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      res.setMessage(e.getMessage());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * アプリ更新指示情報取得
   * @param ntssUser
   * @param request
   * @return
   */
  @PostMapping("/application-update")
  public ResponseEntity<?> createUpdateInfo(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody DeviceEdgeManageRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/application-update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeManageResponse res = new DeviceEdgeManageResponse();
    try {
      String targetFacilityCd = request.getTargetFacilityCd();
      if (!ntssUser.isNkkAdminUser() && targetFacilityCd != null && !targetFacilityCd.isEmpty()
          && !targetFacilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "targetFacilityCd=" + targetFacilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
      Integer deviceEdgeNo = request.getDeviceEdgeNo();
      MntDeviceEdgeManage param = request.getManageParam();
      MntDeviceEdgeManage.ManageInfo manageInfo = new MntDeviceEdgeManage.ManageInfo();
      if (request.getBucket() == null || request.getBucket().isEmpty()) {
        res.isSuccess = false;
        res.errorMessage = "更新用ファイルのパスが未設定です";
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }
      if (request.getBucket().startsWith("s3://")) {
        manageInfo.setDownloadBucket(request.getBucket());
      } else {
        manageInfo.setDownloadBucket("s3://" + request.getBucket());
      }
      manageInfo.setDownloadFile(request.getFileName());

      /* modify by SongJiHao  2023-02-01 [Transaction,Remote]  */
      res = deviceEdgeMaganeService.sendOrderToEdge(ntssUser, targetFacilityCd, deviceEdgeNo, param, manageInfo, request.getAppType(),
          request.getPlanDate());

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
    } catch (Exception ex) {
      res.isSuccess = false;
      res.errorMessage = ex.getMessage();
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, ex.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * confファイル更新指示情報取得
   * @param ntssUser
   * @param request
   * @return
   */
  @PostMapping("/conf-update")
  public ResponseEntity<?> confUpdate(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody DeviceEdgeManageRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/conf-update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeManageResponse res = new DeviceEdgeManageResponse();
    try {
      String targetFacilityCd = request.getTargetFacilityCd();
      if (!ntssUser.isNkkAdminUser() && targetFacilityCd != null && !targetFacilityCd.isEmpty()
          && !targetFacilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "targetFacilityCd=" + targetFacilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
      Integer deviceEdgeNo = request.getDeviceEdgeNo();
      MntDeviceEdgeManage param = request.getManageParam();
      MntDeviceEdgeManage.ManageInfo manageInfo = new MntDeviceEdgeManage.ManageInfo();
      manageInfo.setDownloadBucket(request.getBucket());
      manageInfo.setDownloadFile(request.getFileName());

      /* modify by SongJiHao  2023-02-01 [Transaction,Remote]  */
      res = deviceEdgeMaganeService.sendOrderToEdge(ntssUser, targetFacilityCd, deviceEdgeNo, param, manageInfo, null);

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
    } catch (Exception ex) {
      res.isSuccess = false;
      res.errorMessage = ex.getMessage();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, ex.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 予約キャンセル指示
   * @param ntssUser
   * @param request
   * @return
   */
  @PostMapping("/plan-cancel")
  public ResponseEntity<?> planCancel(
      @AuthenticationPrincipal NtssUser ntssUser,
      @RequestBody DeviceEdgeManageRequest request) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE_MANAGE + "/plan-cancel";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    DeviceEdgeManageResponse res = new DeviceEdgeManageResponse();
    try {
      String targetFacilityCd = request.getTargetFacilityCd();
      if (!ntssUser.isNkkAdminUser() && targetFacilityCd != null && !targetFacilityCd.isEmpty()
          && !targetFacilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "targetFacilityCd=" + targetFacilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
      Integer deviceEdgeNo = request.getDeviceEdgeNo();
      MntDeviceEdgeManage param = request.getManageParam();
      MntDeviceEdgeManage.ManageInfo manageInfo = new MntDeviceEdgeManage.ManageInfo();

      /* modify by SongJiHao  2023-02-01 [Transaction,Remote]  */
      res = deviceEdgeMaganeService.sendOrderToEdge(ntssUser, targetFacilityCd, deviceEdgeNo, param, manageInfo, null);

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
    } catch (Exception ex) {
      res.isSuccess = false;
      res.errorMessage = ex.getMessage();
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_ERROR, mappingUrl, null, ex.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /* del by SongJiHao  2023-02-01 [Transaction,Remote]  start */
//  /**
//   * 指示
//   * @return
//   */
//  public DeviceEdgeManageResponse sendOrderToEdge(
//      NtssUser ntssUser,
//      String targetFacilityCd,
//      Integer deviceEdgeNo,
//      MntDeviceEdgeManage param,
//      MntDeviceEdgeManage.ManageInfo manageInfo,
//      Short appType) {
//    return sendOrderToEdge(ntssUser, targetFacilityCd, deviceEdgeNo, param, manageInfo, appType, null);
//  }
//
//  /**
//   * 指示
//   * @return
//   */
//  public DeviceEdgeManageResponse sendOrderToEdge(
//      NtssUser ntssUser,
//      String targetFacilityCd,
//      Integer deviceEdgeNo,
//      MntDeviceEdgeManage param,
//      MntDeviceEdgeManage.ManageInfo manageInfo,
//      Short appType,
//      String planDate) {
//
//    DeviceEdgeManageResponse res = new DeviceEdgeManageResponse();
//    try {
//      if (param.getOrderClass() == null || param.getOrderClass().shortValue() < 0
//          || param.getOrderClass().shortValue() > DeviceEdgeManageConstant.OrderClass.MAX_CODE_VALUE) {
//        res.isSuccess = false;
//        res.errorMessage = "指示情報不正:命令種別異常";
//        return res;
//      }
//      param.setUserId(ntssUser.getUserId());
//      param.setResponseStatus(statusOrder);
//      param.setManageInfo(manageInfo);
//      Long manageNo = deviceEdgeMaganeService.insertNewRecordManageNo(param);
//
//      param.setManageNo(manageNo);
//      res.manageParam = param;
//      // ペイロード部作成
//      String payload = "";
//      switch (param.getOrderClass().shortValue()) {
//      case DeviceEdgeManageConstant.OrderClass.APP_REBOOT:
//      case DeviceEdgeManageConstant.OrderClass.APP_START:
//      case DeviceEdgeManageConstant.OrderClass.APP_STOP:
//      case DeviceEdgeManageConstant.OrderClass.DEVICE_REBOOT:
//        payload = PayloadBuilder.BuildServiceControlPayload(param.getManageNo());
//
//        break;
//      case DeviceEdgeManageConstant.OrderClass.LOG_GATHER:
//      case DeviceEdgeManageConstant.OrderClass.CONF_GATHER:
//        payload = PayloadBuilder.BuildGatherPayload(param.getManageNo());
//
//        break;
//      case DeviceEdgeManageConstant.OrderClass.RESTORE:
//        payload = PayloadBuilder.BuildAppRestorePayload(param.getManageNo());
//        break;
//      case DeviceEdgeManageConstant.OrderClass.UPDATE:
//        payload = PayloadBuilder.BuildAppUpdatePayload(param.getManageNo(), appType,
//            manageInfo.getDownloadBucket(), manageInfo.getDownloadFile(), planDate);
//        break;
//      case DeviceEdgeManageConstant.OrderClass.CONF_UPDATE:
//        payload = PayloadBuilder.BuildConfUpdatePayload(param.getManageNo(), manageInfo.getDownloadBucket(),
//            manageInfo.getDownloadFile());
//        break;
//      case DeviceEdgeManageConstant.OrderClass.PLAN_CANCEL:
//        payload = PayloadBuilder.BuildPlanCancelPayload(param.getManageNo());
//        break;
//
//      default:
//        res.isSuccess = false;
//        res.errorMessage = "指示情報不正:命令種別異常";
//        return res;
//      }
//
//      String topic = PayloadBuilder.BuildTopic(
//          deviceEdgeMaganeService.getTopicString(param.getOrderClass()), targetFacilityCd,
//          deviceEdgeNo);
//
//      deviceEdgeMaganeService.updateManageOrderInfo(manageNo, statusOrder, topic, payload);
//
//      SendTarget targetAppClass = SendTarget.updater;
//
//      if (param.getOrderTargetClass().shortValue() == (short) 0) {
//        targetAppClass = SendTarget.main;
//      } else if (param.getOrderTargetClass().shortValue() == (short) 1) {
//        targetAppClass = SendTarget.updater;
//      }
//
//      if (webSocketNotifyService.sendMsg(targetAppClass, targetFacilityCd, deviceEdgeNo, topic, payload)) {
//        res.isSuccess = true;
//        return res;
//      } else {
//        res.isSuccess = false;
//        res.errorMessage = "デバイスエッジ指示失敗";
//        deviceEdgeMaganeService.updateManageError(manageNo, statusError, res.errorMessage);
//        return res;
//      }
//    } catch (Exception ex) {
//      res.isSuccess = false;
//      res.errorMessage = ex.getMessage();
//      return res;
//    }
//
//  }
  /* del by SongJiHao  2023-02-01 [Transaction,Remote]  end */

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
