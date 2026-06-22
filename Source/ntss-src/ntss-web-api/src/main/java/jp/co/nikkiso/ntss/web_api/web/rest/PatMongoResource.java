package jp.co.nikkiso.ntss.web_api.web.rest;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.PatInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import jp.co.nikkiso.ntss.web_api.service.LogEventUtils;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.service.PatMongoService;
import org.seasar.doma.jdbc.OptimisticLockException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.List;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
@RestController
@RequestMapping("util")
public class PatMongoResource {

  private static final String HAITACODE = "22020006";

  @Autowired
  LogService logService;

  @Autowired
  LogEventUtils logEventUtils;

  @Autowired
  PatMongoService patMongoService;

  // add 10626 データリストのCTR・DW一括登録修正 房 start
  @PutMapping("/insertPatsInfoToMongo")
  public ResponseEntity<String> updateAndInsertPatsInfoToMongo(@RequestBody List<PatInfo> patsInfo) {
    String mappingUrl = "/util/insertPatsInfoToMongo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      patMongoService.updateAndInsertPatsInfoToMongo(patsInfo);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      String exceptionDetailMessage = ExcetionStackTraceToString(e);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        exceptionDetailMessage);
      return new ResponseEntity<>(exceptionDetailMessage,HttpStatus.BAD_REQUEST);
    }
  }
  // add 10626 データリストのCTR・DW一括登録修正 房 end

  @PutMapping("/insertPatToMongo")
  public ResponseEntity<String> updateAndInsertPatDataToMongo(@RequestBody PatInfo patInfo) {
    String mappingUrl = "/util/insertPatToMongo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      // mod #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao start
      //patMongoService.setPatDataToMongoHistory(patInfo);
      if("1".equals(patInfo.getIsSame())){
        patMongoService.setPatIsSameDataToMongoHistory(patInfo);
      }else{
        patMongoService.setPatDataToMongoHistory(patInfo);
      }
      // mod #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao start
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      String exceptionDetailMessage = ExcetionStackTraceToString(e);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        exceptionDetailMessage);
      return new ResponseEntity<>(exceptionDetailMessage,HttpStatus.BAD_REQUEST);
    }
  }

  @PutMapping("/bulkUpdatePatInsu")
  public ResponseEntity<String> updateBulkUpdatePatInsu(@RequestBody List<PatInsuInfo> patInsuInfos) {
    String mappingUrl = "/util/bulkUpdatePatInsu";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, patInsuInfos);
    try {
      patMongoService.updateBulkUpdatePatInsu(patInsuInfos);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, patInsuInfos);
      return new ResponseEntity<>("", HttpStatus.OK);
    } catch (OptimisticLockException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO, LoggingConstant.SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Collections.singletonList(e.getMessage()));
      return new ResponseEntity<>(HAITACODE, HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO, LoggingConstant.SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Collections.singletonList(patInsuInfos));
      return new ResponseEntity<>("", HttpStatus.BAD_REQUEST);
    }
  }

  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
  @PutMapping("/allUpdatePatInsu")
  public ResponseEntity<String> updateUpdatePatInsu(@RequestBody List<PatInsuInfo> patInsuInfos) {
    String mappingUrl = "/util/allUpdatePatInsu";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, patInsuInfos);
    try {
      patMongoService.updateUpdatePatInsu(patInsuInfos);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, patInsuInfos);
      return new ResponseEntity<>("", HttpStatus.OK);
    } catch (OptimisticLockException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO, LoggingConstant.SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Collections.singletonList(e.getMessage()));
      return new ResponseEntity<>(HAITACODE, HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO, LoggingConstant.SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_INFO,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Collections.singletonList(patInsuInfos));
      return new ResponseEntity<>("", HttpStatus.BAD_REQUEST);
    }
  }
  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end

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
//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
