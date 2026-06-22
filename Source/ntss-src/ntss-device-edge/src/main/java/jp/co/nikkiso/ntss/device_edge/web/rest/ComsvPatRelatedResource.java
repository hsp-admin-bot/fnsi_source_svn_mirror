package jp.co.nikkiso.ntss.device_edge.web.rest;

import jp.co.nikkiso.ntss.device_edge.service.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvPatRelated;
import jp.co.nikkiso.ntss.device_edge.service.ComsvPatRelatedService;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfoService;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfo;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfoItem;

import java.util.Arrays;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@RequestMapping("/api/comsv_pat")

public class ComsvPatRelatedResource {

  @Autowired
  private LogService logService;

  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;
  @Autowired
  CondInfoService condInfoService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End


  /**
   * 通信サーバ用患者情報関連の更新
   */
  @Autowired
  private ComsvPatRelatedService comsvPatRelatedService;

  /**
   * 患者基本情報（治療進捗状態）を更新
   * @param patId システムで管理する一意な患者ID
   * @param ordNo システムで管理する一意なオーダー番号
   * @param statusInfo 治療進捗状態
   * @return
   */
  @PutMapping("/main/{pat_id}/{ord_no}/{status_info}")
  public ResponseEntity<Void> updateDialStatus(
      @PathVariable("pat_id") Long patId,
      @PathVariable("ord_no") Long ordNo,
      @PathVariable(name = "status_info", required = false) String statusInfo) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api/comsv_pat" + "/main";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(patId, ordNo,statusInfo));
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setPatId(patId.toString());
//    eventLogMessage.setLogMessage("API PUT CALLED = " + patId + " / " +ordNo + " / " + statusInfo);
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (patId <= 0) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(patId, ordNo,statusInfo));
      // wp アプリケーションログの適正化 Add End
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    // ord_main取得
    OrdMain ord = ordMainDao.selectByOrdNo(ordNo);
    if( ord == null ) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(patId, ordNo,statusInfo));
      // wp アプリケーションログの適正化 Add End
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    // 治療時間
    String treatmentTime = null;
    String condInfoText = ord.getRstCondInfo();
    if (null != condInfoText) {
      CondInfo condInfo = condInfoService.createCondInfo(condInfoText);
      CondInfoItem condItem = condInfo.getTreatTime();
      treatmentTime = condItem.getValue();
    }
    // 割り当て対象の患者基本情報(pat_main)更新
    int ret = patMainAcceptanceStatusInfoService.update(patId, ordNo, statusInfo, ord.getRstStartDate(), treatmentTime);
    if (ret > 0) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(patId, ordNo,statusInfo));
      // wp アプリケーションログの適正化 Add End
      return ResponseEntity.ok().build();
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(patId, ordNo,statusInfo));
      // wp アプリケーションログの適正化 Add End
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
  }

  /**
   * 患者基本情報（共通診療情報：透析回数）を更新
   * @param pat_id システムで管理する一意な患者ID
   * @return
   */
  @PutMapping("/unique/{pat_id}")
  public ResponseEntity<Void> updateDialCount(
      @PathVariable("pat_id") Long pat_id) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/api/comsv_pat" + "/unique";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      pat_id);
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setPatId(pat_id.toString());
//    eventLogMessage.setLogMessage("API PUT CALLED = " + pat_id);
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (pat_id <= 0) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        pat_id);
      // wp アプリケーションログの適正化 Add End
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    ComsvPatRelated comsv = new ComsvPatRelated();
    comsv.setPatId(pat_id);
    int ret = comsvPatRelatedService.updateDialCount(comsv);
    if (ret > 0) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        pat_id);
      // wp アプリケーションログの適正化 Add End
      return ResponseEntity.ok().build();
    } else {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        pat_id);
      // wp アプリケーションログの適正化 Add End
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return ResponseEntity.badRequest().build();
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
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
