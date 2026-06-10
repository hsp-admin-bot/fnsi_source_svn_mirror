package jp.co.nikkiso.ntss.web_api.web.rest;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

import jp.co.nikkiso.ntss.web_api.service.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.request.FacilityExpireRequest;
import jp.co.nikkiso.ntss.web_api.service.FacilityExpireService;
import jp.co.nikkiso.ntss.web_api.service.LogService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;


/**
 * 期間外削除Web API
 */
@RestController
@RequestMapping("facility/expire")
public class FacilityExpireResource {

  // サービス
  /** 期間外削除サービス */
  @Autowired
  private FacilityExpireService facilityExpireService;

  /** ログサービス */
  @Autowired
  private LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 期間外のレコードを削除する。
   *
   * @param req リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/execute")
  public ResponseEntity<String> execute(@RequestBody FacilityExpireRequest req) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/expire" + "/execute";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // 削除基準日
    String baseDate = req.getBaseDate();
    if (StringUtils.isEmpty(baseDate)) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("削除基準日が指定されていません。", HttpStatus.BAD_REQUEST);
    }

    try {
      String tmpDt = baseDate.replace("-", "").replace("/", "");
      facilityExpireService.executeExpire(LocalDateTime.parse(tmpDt, DateTimeFormatter.ofPattern("uuuuMMdd")), LocalTime.MAX, 1, null);
      facilityExpireService.executeExpire(LocalDateTime.parse(tmpDt, DateTimeFormatter.ofPattern("uuuuMMdd")), LocalTime.MAX, 2, null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
       null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("期間外削除を実行しました。", HttpStatus.OK);
    } catch (NtssException e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
      String errMsg = String.format("期間外削除の実行で内部エラーが発生しました。");
//      errorLog(null, errMsg, e);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 期間外のレコードを削除する。
   *
   * @param req リクエストパラメータ
   * @return ResponseEntity
   */
  @PostMapping("/executeFacility")
  public ResponseEntity<String> executeFacility(@RequestBody FacilityExpireRequest req) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "/facility/expire" + "/executeFacility";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // 削除基準日
    String baseDate = req.getBaseDate();
    if (StringUtils.isEmpty(baseDate)) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("削除基準日が指定されていません。", HttpStatus.BAD_REQUEST);
    }
    // 施設コード
    String facilityCd = req.getFacilityCd();
    if (StringUtils.isEmpty(facilityCd)) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("施設コードが指定されていません。", HttpStatus.BAD_REQUEST);
    }

    try {
      String tmpDt = baseDate.replace("-", "").replace("/", "");
      facilityExpireService.executeExpireFacility(LocalDateTime.parse(tmpDt, DateTimeFormatter.ofPattern("uuuuMMdd")), LocalTime.MAX, facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("期間外削除を実行しました。", HttpStatus.OK);
    } catch (NtssException e) {
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    } catch (Exception e) {
      String errMsg = String.format("期間外削除の実行で内部エラーが発生しました。");
      //errorLog(null, errMsg, e);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(errMsg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * エラーログを出力する。
   *
   * @param facilityCd 施設コード
   * @param errMsg エラーメッセージ
   * @param t 例外
   */
  private void errorLog(String facilityCd, String errMsg, Throwable t) {
    EventLogMessage msg = new EventLogMessage();
    msg.setFacilityCd(facilityCd);
    msg.setLogMessage(errMsg);
    msg.setSupportMessage(t.toString());

    logService.log(LogLevel.ERROR, msg, null, SERVICE_NAME.REMS, null);
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
