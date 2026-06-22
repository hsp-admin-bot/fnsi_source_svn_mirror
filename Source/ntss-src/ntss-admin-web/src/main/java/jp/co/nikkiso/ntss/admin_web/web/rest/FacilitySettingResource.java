package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.master.user.MstUserService;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;


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
  @Autowired
  private FacilityAccessService facilityAccessService;

  // wp アプリケーションログの適正化 Add End
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  @Autowired
  private MstUserService mstUserService;
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    /**
   * 施設設定マスタ設定値取得
   */
  @GetMapping(value = "/getFacilitySettingValue/{facilityCd}/{settingNo}", produces = MediaType.TEXT_PLAIN_VALUE)
  public ResponseEntity<String> getFacilitySettingValue(
      @PathVariable String facilityCd,
      @PathVariable String settingNo,
      @RequestParam(required = false) Long selectedPatId,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facilityCd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

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
    @PathVariable List<String> settingNos,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (facilityCd != null && !facilityCd.isEmpty() &&
        !facilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "settingNos=" + settingNos.toString() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


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
  public ResponseEntity<?> methodLogin(@RequestParam String facilityHash,
                                       // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                       @AuthenticationPrincipal NtssUser ntssUser
                                       // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(ntssUser != null && !ntssUser.isNkkAdminUser()) {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityHash);
      if (mstFacilityHash != null) {
        String facilityCd = mstFacilityHash.getFacilityCd();
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "facilityHash=" + facilityHash + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end

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
    @RequestParam String cardIdm,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(ntssUser != null && !ntssUser.isNkkAdminUser()) {
      MstUser mstUser = mstUserService.getByUserId(Long.parseLong(userId));
      if (mstUser != null) {
        String facilityCd = mstUser.getFacilityCd();
        if (facilityCd != null && !facilityCd.isEmpty() &&
          !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "userId=" + userId + " " + "cardIdm=" + cardIdm + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end


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
      @PathVariable List<String> masterPhysicalNameList,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      // #11205 特殊ケースのチェックをスキップ（許可）：マスタ一覧-> マスタ編集(施設設定マスタ) -> 152:患者情報共有 -> 設定値: mst_facilityの並び順を取得する
      boolean isAllowedPatientSharingFacilitySelector = "nkknkk".equals(facilityCd) && masterPhysicalNameList.size() == 1 && "mst_facility".equals(masterPhysicalNameList.get(0));
      if (facilityCd != null && !facilityCd.isEmpty() &&
        !facilityCd.equals(ntssUser.getFacilityCd()) &&
        !isAllowedPatientSharingFacilitySelector) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end


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
