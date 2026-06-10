package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatNameId;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.PatPersonalMainService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 患者情報の取得するResourceクラス
 *
 */
@RestController
@RequestMapping(Uri.PAT_PERSONAL_MAIN)
public class PatPersonalMainResource {

	@Autowired
	PatPersonalMainService patPersonalMainService;

	@Autowired
	PatPersonalMainDao PatPersonalMainDao;

	@Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
	/**
	 * 患者IDで患者情報の習得
	 *
	 * @param patId
	 * @return
	 */
	@GetMapping("/getPatPersonalMain/{patId}")
	public ResponseEntity<Map<String, String>> getPatPersonalMainByPatId(@PathVariable Long patId) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_PERSONAL_MAIN + "/getPatPersonalMain";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End
		Map<String, String> patPersonalMainJson = null;
		try {
			patPersonalMainJson = patPersonalMainService.selectPatPersonalMainByPatId(patId);
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
		if (patPersonalMainJson == null) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
		return new ResponseEntity<>(patPersonalMainJson, HttpStatus.OK);
	}

    /**
     * 院内患者IDで内部患者IDの習得
     *
     * @param facilityCd 施設コード
     * @param hospPatId  院内患者ID
     * @return 内部患者ID
     */
    @GetMapping("/getPatIdByHospPatId/{hospPatId}")
    public ResponseEntity<Long> getPatIdByHospPatId(
        @AuthenticationPrincipal NtssUser ntssUser,
        @PathVariable String hospPatId) {
        Long patId = 0L;
        String mappingUrl = Uri.PAT_PERSONAL_MAIN + "/getPatPersonalMain";

        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, ntssUser.getFacilityCd(), null);

        try {
          patId = PatPersonalMainDao.selectPatIdByHospPatId(ntssUser.getFacilityCd(), hospPatId);
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
            logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        if (patId == null) {
            logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }

        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null, null);
        return new ResponseEntity<>(patId, HttpStatus.OK);
    }

    /**
     * 施設コードで患者名の習得(削除済み含む)
     *
     * @param facilityCd 施設コード
     * @return
     */
    @GetMapping("/getPatNameByFacilityCd/{facilityCd}")
    public ResponseEntity<?> getPatNameByFacilityCd(@PathVariable String facilityCd) {
      String mappingUrl = Uri.PAT_PERSONAL_MAIN + "/getPatNameByFacilityCd/{facilityCd}";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
          facilityCd);
      try {
        List<PatPersonalMain> patPersonalMainList = patPersonalMainService.getPatNameByFacilityCd(facilityCd);
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
            facilityCd);
        return new ResponseEntity<>(patPersonalMainList, HttpStatus.OK);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null,
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          ExcetionStackTraceToString(e));
        return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    /**
     * 患者IDで患者名の習得(削除済み含む)
     *
     * @param patId 患者ID
     * @return
     */
    @GetMapping("/getPatNameByPatId/{patId}")
    public ResponseEntity<?> getPatNameByPatId(@PathVariable Long patId) {
      String mappingUrl = Uri.PAT_PERSONAL_MAIN + "/getPatNameByPatId/{patId}";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
          patId);
      try {
        PatNameId patPersonalMainList = patPersonalMainService.getPatNameByPatId(patId);
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
            patId);
        return new ResponseEntity<>(patPersonalMainList, HttpStatus.OK);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null,
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
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
