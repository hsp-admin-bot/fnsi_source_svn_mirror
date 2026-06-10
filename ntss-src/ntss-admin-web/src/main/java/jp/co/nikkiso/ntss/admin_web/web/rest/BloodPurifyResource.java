package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.bloodPurify.BPOrdInfoResponse;
import jp.co.nikkiso.ntss.admin_web.service.bloodPurify.BloodPurifyService;
import jp.co.nikkiso.ntss.admin_web.service.bloodPurify.DatabasePusher;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;

import jp.co.nikkiso.ntss.core.entity.MstKur;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * 浄化装置通信アプリのResourceクラス.
 */
@RestController
@RequestMapping(Uri.BLOOD_PURIFY)
public class BloodPurifyResource {
  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  @Autowired
  DatabasePusher dbPusher;

  @Autowired
  BloodPurifyService service;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 呼び出し元メソッドのメソッド名を返す
   * @return
   */
  private String methodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

  /**
   * 浄化装置の透析情報を取得する.
   * @return 浄化装置通信アプリ用の透析情報.
   */
  @GetMapping("/ord_main/bp_device/{facilityCd}/{startYyyyMmDd}")
  public ResponseEntity<?> getBloodPurifyOrdInfoForBloodPurifyDevice(
      @PathVariable(name = "facilityCd", required = true) String argFacilityCd,
      @PathVariable(name = "startYyyyMmDd", required = true) String argStartYyyyMmDd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BLOOD_PURIFY + "/ord_main/bp_device";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, argFacilityCd,
      argStartYyyyMmDd);
    // wp アプリケーションログの適正化 Add End
//    EventLogMessage elm = new EventLogMessage();
//
//    elm.setLogMessage("REST " + methodName() + " start");
//    logService.log(LogLevel.INFO, elm, "", SERVICE_NAME.FNSI, null);

    try {
      List<BPOrdInfoResponse> res = service.getBloodPurifyOrdInfoForBloodPurifyDevice(argFacilityCd, argStartYyyyMmDd);

//      elm.setLogMessage("REST " + methodName() + " end");
//      logService.log(LogLevel.INFO, elm, "", SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, argFacilityCd,
        argStartYyyyMmDd);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      elm.setLogMessage("REST " + methodName() + " exception end / msg:" + e.getMessage());
//      logService.log(LogLevel.ERROR, elm, "", SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, argFacilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * クールマスタの情報を取得する.
   * @return クールマスタの情報.
   */
  @GetMapping("/mst_kur/{facilityCd}")
  public ResponseEntity<?> getMstKur(
      @PathVariable(name = "facilityCd", required = true) String argFacilityCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BLOOD_PURIFY + "/mst_kur";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, argFacilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage elm = new EventLogMessage();
//
//    elm.setLogMessage("REST " + methodName() + " start");
//    logService.log(LogLevel.INFO, elm, "", SERVICE_NAME.FNSI, null);

    try {
      List<MstKur> res = service.getMstKur(argFacilityCd);

//      elm.setLogMessage("REST " + methodName() + " end");
//      logService.log(LogLevel.INFO, elm, "", SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST,AFTER_LOG_FLG_INFO , mappingUrl, argFacilityCd,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      elm.setLogMessage("REST " + methodName() + " exception end / msg:" + e.getMessage());
//      logService.log(LogLevel.ERROR, elm, "", SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, argFacilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 日機装透析装置の透析情報を取得する.
   * @return 浄化装置通信アプリ用の透析情報.
   */
  @GetMapping("/ord_main/nkk_device/{facilityCd}/{startYyyyMmDd}")
  public ResponseEntity<?> getBloodPurifyOrdInfoForNkkDevice(
      @PathVariable(name = "facilityCd", required = true) String argFacilityCd,
      @PathVariable(name = "startYyyyMmDd", required = true) String argStartYyyyMmDd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BLOOD_PURIFY + "/ord_main/nkk_device";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, argFacilityCd,
      argStartYyyyMmDd);
    // wp アプリケーションログの適正化 Add End
//    EventLogMessage elm = new EventLogMessage();
//
//    elm.setLogMessage("REST " + methodName() + " start");
//    logService.log(LogLevel.INFO, elm, "", SERVICE_NAME.FNSI, null);

    try {
      List<BPOrdInfoResponse> res = service.getBloodPurifyOrdInfoForNkkDevice(argFacilityCd, argStartYyyyMmDd);

//      elm.setLogMessage("REST " + methodName() + " end");
//      logService.log(LogLevel.INFO, elm, "", SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST,AFTER_LOG_FLG_INFO , mappingUrl, argFacilityCd,
        argStartYyyyMmDd);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
//      elm.setLogMessage("REST " + methodName() + " exception end / msg:" + e.getMessage());
//      logService.log(LogLevel.ERROR, elm, "", SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, argFacilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * データアップロード処理
   * @param request
   * @return
   */
  @PostMapping("/post_data/{ordNo}")
  public ResponseEntity<Void> postData(
      HttpServletRequest request,
      @PathVariable(name = "ordNo", required = true) Long ordNo) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BLOOD_PURIFY + "/post_data";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

//
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST postData ord_no:" + ordNo);
//    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

    // データ登録処理
    InputStream inputStream = null;
    try {
      inputStream = request.getInputStream();
      if (inputStream != null) {
        if (!dbPusher.run(ordNo, inputStream)) {
          // fixed FNSI-モニタデータ取込 孫灝 20201028 start
//          return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
          // wp アプリケーションログの適正化 Add Start
          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null, ordNo);
          // wp アプリケーションログの適正化 Add End
          return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
          // fixed FNSI-モニタデータ取込 孫灝 20201028 end
        }
      } else {
//        eventLogMessage.setLogMessage("REST postData worm. " + LogMessage.WARN_NO_STREAM);
//        logService.log(LogLevel.WARN, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        // fixed FNSI-モニタデータ取込 孫灝 20201028 start
//        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null, ordNo);
        // wp アプリケーションログの適正化 Add End

        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        // fixed FNSI-モニタデータ取込 孫灝 20201028 end
      }
    } catch (Exception e) {
//      eventLogMessage.setLogMessage("REST posData error. " + LogMessage.ERROR_DB_PUSH_API + " / " + e);
//      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    } finally {
      if (inputStream != null) {
        try {
          inputStream.close();
        } catch (IOException e) {
//          eventLogMessage.setLogMessage("REST postData error. " + LogMessage.ERROR_CLOSE_STREAM + " / " + e);
//          logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
          // wp アプリケーションログの適正化 Add Start
          logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
          // wp アプリケーションログの適正化 Add End
        }
      }
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, null, ordNo);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(HttpStatus.OK);
  }

  // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 start
  /**
   * 装置マスタから必要な装置情報を取得する
   * @return 装置情報.
   */
  @GetMapping("/mst_getdialysisdevice/{facilityCd}")
  public ResponseEntity<?> getDialysisDevice(
    @PathVariable(name = "facilityCd", required = true) String argFacilityCd) {
//    EventLogMessage elm = new EventLogMessage();
//
//    elm.setLogMessage("REST " + methodName() + " start");
//    logService.log(LogLevel.INFO, elm, "", SERVICE_NAME.FNSI, null);

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BLOOD_PURIFY + "/mst_getdialysisdevice";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(),  LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, BEFORE_LOG_FLG_INFO, mappingUrl, argFacilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      List<MstMachine> res = service.getDialysisDevice(argFacilityCd);

//      elm.setLogMessage("REST " + methodName() + " end");
//      logService.log(LogLevel.INFO, elm, "", SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_DETAIL_MOTION_RECORD_LIST, AFTER_LOG_FLG_INFO, mappingUrl, argFacilityCd,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {

//      elm.setLogMessage("REST " + methodName() + " exception end / msg:" + e.getMessage());
//      logService.log(LogLevel.ERROR, elm, "", SERVICE_NAME.FNSI, null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, argFacilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  //add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 end

  /**
   * 動作確認用REST
   * TODO:動作確認後に削除
   * @return
   */
  @GetMapping("/test")
  public ResponseEntity<Void> getTest() {
    dbPusher.test();
    return new ResponseEntity<>(HttpStatus.OK);
  }

  // wp アプリケーションログの適正化 Add Start
  /**
   * クラス名取得
   */
  public String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  public String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }
  // wp アプリケーションログの適正化 Add End
}
