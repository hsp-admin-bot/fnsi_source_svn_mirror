package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.shrPatInfo.ShrPatInfoService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.ShrPatInfoDao;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatInsuranceConditionsSharing;
import jp.co.nikkiso.ntss.core.entity.PatientInfoSharingDetails;
import jp.co.nikkiso.ntss.core.entity.ShrPatInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatientInfoSharing;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

@RestController
@RequestMapping(Uri.SHR_PAT_INFO)
public class ShrPatInfoResource {

  @Autowired
  LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;

  @Autowired
  ShrPatInfoService shrPatInfoService;

  @Autowired
  ShrPatInfoDao shrPatInfoDao;

  /**
   * 共有患者のリストを取得する
   *
   * @param PatInsuranceConditionsSharing 患者の個人的なメインデータ
   * @return 共有患者リスト   Patient information sharing
   * @throws Exception
   */
  @PostMapping("/patientInformation/sharing")
  public ResponseEntity<List<?>> patientInformationSharing(@RequestBody PatInsuranceConditionsSharing PatInsuranceConditionsSharing, @AuthenticationPrincipal NtssUser ntssUser)
    throws Exception {
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/patientInformation/sharing";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      List<PatientInfoSharing> publicPatientLst = shrPatInfoService.patientInformationSharing(PatInsuranceConditionsSharing,ntssUser.getFacilityCd());
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(publicPatientLst, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 詳細の共有
   * @param patId
   * @return
   * @throws Exception
   */
  @GetMapping("/sharingDetails/{patId}")
  public ResponseEntity<?> sharingDetails(@PathVariable Long patId, @AuthenticationPrincipal NtssUser ntssUser)
    throws Exception {
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/sharingDetails";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      PatientInfoSharingDetails patientInfoSharingDetails = shrPatInfoService.sharingDetails(patId ,ntssUser.getFacilityCd());
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(patientInfoSharingDetails, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 系列施設対応
   * @param ntssUser
   * @return
   * @throws Exception
   */
  @GetMapping("/correspondingFacilities")
  public ResponseEntity<?> correspondingFacilities(@AuthenticationPrincipal NtssUser ntssUser)
    throws Exception {
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/correspondingFacilities";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      Map<String,List<String>> patientInfoSharingDetails = shrPatInfoService.correspondingFacilities(ntssUser.getFacilityCd());
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(patientInfoSharingDetails, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者情報共有削除
   * @param shrPatInfoId
   * @return
   * @throws Exception
   */
  @PutMapping("/deleteShrPatInfo/{shrPatInfoId}")
  public ResponseEntity<?> deleteShrPatInfo(@PathVariable Long shrPatInfoId,@AuthenticationPrincipal NtssUser ntssUser)
    throws Exception {
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/deleteShrPatInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      // #11205 mod 20260421 start
      if (!ntssUser.isNkkAdminUser()) {
        ShrPatInfo shrPatInfo = shrPatInfoDao.selectShrPatInfoByShrPatInfoId(shrPatInfoId);
        if (shrPatInfo != null
          && !ntssUser.getFacilityCd().equals(shrPatInfo.getFromFacilityCd())
          && !ntssUser.getFacilityCd().equals(shrPatInfo.getToFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "fromFacilityCd=" + shrPatInfo.getFromFacilityCd() + " " + "toFacilityCd=" + shrPatInfo.getToFacilityCd() + " " + "shrPatInfoId=" + shrPatInfoId + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
          // #11205 mod 20260421 end
        }
      }
       shrPatInfoService.deleteShrPatInfo(shrPatInfoId);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者ドロップダウン
   * @return
   * @throws Exception
   */
  @GetMapping("/patientDetailsDown")
  public ResponseEntity<?> patientDetailsDown(@AuthenticationPrincipal NtssUser ntssUser)
    throws Exception {

    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/patientDetailsDown";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      List<PatientInfoSharing> patientDetailsDown = shrPatInfoService.patientDetailsDown(ntssUser.getFacilityCd());
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(patientDetailsDown, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 施設スタドロップダウン
   * @return
   * @throws Exception
   */
  @GetMapping("/facilityCdDown")
  public ResponseEntity<?> facilityCdDown(@AuthenticationPrincipal NtssUser ntssUser)
    throws Exception {

    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/facilityCdDown";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      Map<String, Object> patientDetailsDown = shrPatInfoService.facilityCdDown(ntssUser.getFacilityCd());
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(patientDetailsDown, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * ファイルアップロード
   *
   * @param file
   */
  @PostMapping("/files/{params}")
  public ResponseEntity<Void> uploadFile(
    @RequestParam("files") MultipartFile file,
    @PathVariable("params") String params
  ) {
    String mappingUrl = Uri.SHR_PAT_INFO + "/files";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(file, params));
    try {
      shrPatInfoService.uploadShrFileAttachment(file, params);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(file, params));
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  /**
   * ファイルダウンロード
   * @param filepath
   * @return 16進数文字列
   */
  @GetMapping("/files")
  public ResponseEntity<?> downloadFile(
    @RequestParam("filepath") String filepath,
    @AuthenticationPrincipal NtssUser ntssUser) {
    String mappingUrl = Uri.PAT_EVENT + "/files";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(filepath, ntssUser));
    try {
      String encodedFiles = shrPatInfoService.downloadShrFileAttachment(filepath, ntssUser.getFacilityCd());
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(filepath, ntssUser));
      return new ResponseEntity<>(encodedFiles, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT, LoggingConstant.SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(filepath, ntssUser));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者情報共有新規
   * @param shrPatInfo
   * @param ntssUser
   * @return
   */
    @PostMapping(value = "/saveShrPatInfo",consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Void> saveShrPatInfo(@ModelAttribute ShrPatInfo shrPatInfo,
                                               @AuthenticationPrincipal NtssUser ntssUser,
                                               @RequestPart(value = "files", required = false) MultipartFile[] files)
    {
    String mappingUrl = Uri.PAT_EVENT +"/saveShrPatInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);

    try {
      shrPatInfoService.saveShrPatInfo(shrPatInfo,ntssUser,files);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者情報共有修正
   * @param shrPatInfo
   * @return
   */
  @PutMapping(value ="/updateShrPatInfo",consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
  public ResponseEntity<Void> updateShrPatInfo(@ModelAttribute ShrPatInfo shrPatInfo,
                                               @AuthenticationPrincipal NtssUser ntssUser,
                                               @RequestParam(value = "files", required = false) MultipartFile[] files) {
    String mappingUrl = Uri.PAT_EVENT +"/saveShrPatInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {

      shrPatInfoService.updateShrPatInfo(shrPatInfo,ntssUser,files);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * ファイル削除
   * @param filename
   */
  @PostMapping("/deleteEventFileAttachment/{patId}")
  public ResponseEntity<?> deleteFile(
    @PathVariable("patId") long patId,
    @RequestBody List<Map<String, String>> fileInfo,
    @AuthenticationPrincipal NtssUser ntssUser) {
    String mappingUrl = Uri.PAT_EVENT + "/deleteEventFileAttachment/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, fileInfo, ntssUser));
    try {
      shrPatInfoService.deleteEventFileAttachment(fileInfo, patId, ntssUser.getFacilityCd());
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, fileInfo, ntssUser));
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT, LoggingConstant.SERVICE_NAME.FNSI, null);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_PAT_EVENT,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(patId, fileInfo, ntssUser));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

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
}
