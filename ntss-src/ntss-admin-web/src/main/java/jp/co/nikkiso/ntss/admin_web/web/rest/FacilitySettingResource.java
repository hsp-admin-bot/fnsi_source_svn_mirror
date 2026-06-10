package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * 施設設定マスタ系
 *
 */
@RestController
@RequestMapping(Uri.FACILITY_SETTING)
public class FacilitySettingResource {

  @Autowired
  FacilitySettingService FacilitySettingService;
  @Autowired
	LogService logService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

    /**
   * 施設設定マスタ設定値取得
   */
  @GetMapping("/getFacilitySettingValue/{facilityCd}/{settingNo}")
  public ResponseEntity<?> getFacilitySettingValue(
      @PathVariable String facilityCd,
      @PathVariable String settingNo) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.FACILITY_SETTING + "/getFacilitySettingValue";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      settingNo);
    // wp アプリケーションログの適正化 Add End
    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        settingNo);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(FacilitySettingService.getFacilitySettingValue(facilityCd, settingNo),
          HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//      null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
  /**
   * 施設設定マスタ設定値取得(バッチ)
   */
  @GetMapping("/getFacilitySettingValueMap/{facilityCd}/{settingNos}")
  public ResponseEntity<?> getFacilitySettingValueMap(
    @PathVariable String facilityCd,
    @PathVariable List<String> settingNos) {

    String mappingUrl = Uri.FACILITY_SETTING + "/getFacilitySettingValueMap";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd, settingNos);
    try {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd, settingNos);

      return new ResponseEntity<>(FacilitySettingService.getFacilitySettingValueMap(facilityCd, settingNos), HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 end

  @GetMapping("/methodLogin")
  public ResponseEntity<?> methodLogin(@RequestParam String facilityHash) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.FACILITY_SETTING + "/methodLogin";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      facilityHash);
    // wp アプリケーションログの適正化 Add End

    try {
      String result = FacilitySettingService.getFacilityLoginMethodValue(facilityHash);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        facilityHash);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
//      e.printStackTrace();
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//      null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/getUserId")
  public ResponseEntity<?> getUserId(
    @RequestParam String facilityHash,
    @RequestParam String userId,
    @RequestParam String cardIdm) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.FACILITY_SETTING + "/getUserId";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(facilityHash, userId,cardIdm));
    // wp アプリケーションログの適正化 Add End
    try {


      String result = FacilitySettingService.getUserIdByCard(facilityHash, userId, cardIdm);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(facilityHash, userId,cardIdm));
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage(e.getMessage());
//    	logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//    	null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 施設設定マスタで使用する参照型コンボボックス.(mst_selectorの値を使用)
   */
  @GetMapping("/getSelectorDataList/{facilityCd}/{masterPhysicalNameList}")
  public ResponseEntity<?> getSelectorDataList(
      @PathVariable String facilityCd,
      @PathVariable List<String> masterPhysicalNameList) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.FACILITY_SETTING + "/getSelectorDataList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      masterPhysicalNameList);
    // wp アプリケーションログの適正化 Add End
    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        masterPhysicalNameList);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(FacilitySettingService.getSelectorDataList(facilityCd, masterPhysicalNameList),
          HttpStatus.OK);
    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage(e.getMessage());
//    	logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//    	null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
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
