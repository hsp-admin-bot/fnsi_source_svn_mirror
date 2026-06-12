package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.sharePatient.ReceivedPatientInfoInput;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.sharePatient.DstPatientRequest;
import jp.co.nikkiso.ntss.admin_web.request.sharePatient.SrcPatientRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.PersonalUserService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatientInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PublicPatientInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ReceivedPatientInfo;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * 掲示板登録情報系
 *
 */
@RestController
@RequestMapping(Uri.PAT_NAME_IDENTIFICATION)
public class MaterialsSharingPatientInfomationResource {

	@Autowired
	MaterialsSharingPatientInfomationService infomationService;
	@Autowired
	PatInfoService patInfoService;
	@Autowired
	PersonalUserService personalUserService;

	/**
	 * webAPI呼び出し用
	 */
	@Autowired
	WebApiCallCommonUtil webApiCallCommonUtil;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

	/**
	 * 共有患者のリストを取得する
	 *
	 * @param patPersonalMainDataLst 患者の個人的なメインデータ
	 * @return 共有患者リスト
	 * @throws Exception
	 */
	@PostMapping("/sharePatientInfo/getPublicPatient")
	public ResponseEntity<List<?>> getPublicPatientList(@RequestBody List<PatPersonalMainData> patPersonalMainDataLst,
                                                      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                      @AuthenticationPrincipal NtssUser ntssUser
                                                      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        for (PatPersonalMainData patPersonalMainData : patPersonalMainDataLst) {
          if (patPersonalMainData.getFacility_cd() != null && !patPersonalMainData.getFacility_cd().equals(ntssUser.getFacilityCd())) {
            String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + patPersonalMainData.getFacility_cd() + " " + "pat_id=" + patPersonalMainData.getPat_id() + " ";
            InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
            return new ResponseEntity<>(new ArrayList<>(), HttpStatus.FORBIDDEN);
          }
        }
      }

    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

		List<PatientInfo> publicPatientLst = infomationService.selectPatInfoPulic(patPersonalMainDataLst);
		return new ResponseEntity<>(publicPatientLst, HttpStatus.OK);
	}

	/**
	 * 受け取った患者のリストを取得する
	 *
	 * @param patPersonalMainDataLst 患者の個人的なメインデータ
	 * @return 受け取った患者のリスト
	 * @throws Exception
	 */
	@PostMapping("/sharePatientInfo/getReceivePatient")
	public ResponseEntity<List<?>> getReceivePatientList(@RequestBody List<PatPersonalMainData> patPersonalMainDataLst)
			throws Exception {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/sharePatientInfo/getReceivePatient";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    Object nu = authentication.getPrincipal();
    String facd = "";
    if (nu instanceof  NtssUser){
      NtssUser ntssUser = (NtssUser) nu;
      facd = ntssUser.getFacilityCd();
    }
    List<PatientInfo> publicPatientLst = infomationService.getPatientListReceive(facd, patPersonalMainDataLst);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(publicPatientLst, HttpStatus.OK);
  }

	/**
	 * 患者情報共有詳細画面(開示)施設を取得する.
	 *
	 * @param request
	 * @return 与えられた基本リスト
	 * @throws Exception
	 */
	@PostMapping("/sharingPatientInfo/getDstFacilities")
	public ResponseEntity<List<?>> getDstFacilities(@RequestBody DstPatientRequest request,
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                  @AuthenticationPrincipal NtssUser ntssUser
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (request.getFacilityCdLogin() != null && !request.getFacilityCdLogin().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCdLogin=" + request.getFacilityCdLogin() + " " + "patId=" + request.getPatId() + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(new ArrayList<>(), HttpStatus.FORBIDDEN);
        }
      }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/sharingPatientInfo/getDstFacilities";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

		List<PublicPatientInfo> patientDetailLst = infomationService.getDstFacilities(request);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

		return new ResponseEntity<>(patientDetailLst, HttpStatus.OK);
	}

	/**
	 * 患者情報共有詳細画面(受理)施設を取得する.
	 *
	 * @param request
	 * @return 受け取った事業所のリスト
	 * @throws Exception
	 */
	@PostMapping("/sharingPatientInfo/getSrcFacilities")
	public ResponseEntity<List<?>> getSrcFacilities(@RequestBody SrcPatientRequest request,
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                  @AuthenticationPrincipal NtssUser ntssUser
                                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    try{
      if(!ntssUser.isNkkAdminUser()) {
        if (request.getFacilityCdLogin() != null && !request.getFacilityCdLogin().equals(ntssUser.getFacilityCd())) {
          return new ResponseEntity<>(new ArrayList<>(), HttpStatus.FORBIDDEN);
        }
      }
    }catch (Exception ignored) {}
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/sharingPatientInfo/getSrcFacilities";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


		List<ReceivedPatientInfo> patientDetailLst = infomationService.getSrcFacilities(request);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
		return new ResponseEntity<>(patientDetailLst, HttpStatus.OK);
	}

	/**
	 * 患者情報共有詳細画面(受理)変更を更新.
	 *
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@PutMapping("/sharingPatientInfo/updateSrcFacilities")
	public ResponseEntity<?> updateSrcFacilities(@RequestBody SrcPatientRequest request,
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                               @AuthenticationPrincipal NtssUser ntssUser
                                               // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
                                               ) throws Exception {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (request.getReceivedPatientInfos() != null && !request.getReceivedPatientInfos().isEmpty()) {
          for (ReceivedPatientInfoInput receivedPatientInfo : request.getReceivedPatientInfos()) {
            Map<String, String> payload = receivedPatientInfo.getPayload();
            if (payload != null && !payload.isEmpty()) {
              ObjectMapper mapper = new ObjectMapper();
              PatPersonalMain patPersonalMain = mapper.readValue(payload.get("pat_personal_main"), PatPersonalMain.class);
              if (patPersonalMain.getFacility_cd() != null && !patPersonalMain.getFacility_cd().equals(ntssUser.getFacilityCd())) {
                String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facility_cd=" + patPersonalMain.getFacility_cd() + " " + "pat_id=" + patPersonalMain.getPat_id() + " ";
                InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
                return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
              }
            }
          }
        }
      }
// #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/sharingPatientInfo/updateSrcFacilities";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

		return new ResponseEntity<>(infomationService.updateSrcFacilities(request), HttpStatus.OK);
	}

	/**
	 * 患者情報共有詳細画面(開示)変更を更新.
	 *
	 * @param request
	 * @return
	 * @throws Exception
	 */
	@PutMapping("/sharingPatientInfo/updateDstFacilities")
	public ResponseEntity<?> updateDstFacilities(@RequestBody DstPatientRequest request) throws Exception {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/sharingPatientInfo/updateDstFacilities";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

	  // 更新前の承認済み施設コードを取得
	  List<String> approvedFacilityCdList = infomationService.getListFacilityCdDstApproved(request.getPatId());
	  // 更新操作
	  List<PublicPatientInfo> response = infomationService.updateDstFacilities(request);

	  // 患者施設のリストから更新前の承認済み施設を除外(承認済み施設への再通知を防ぐ)
	  List<PublicPatientInfo> filteredResponse = response.stream().filter(patInfo ->{
	    return !approvedFacilityCdList.contains(patInfo.getFacilityCd());
	  }).collect(Collectors.toList());

	  // 通知
	  if(filteredResponse.size() > 0) {
	    infomationService.registerPushNotification(request.getPatId(), filteredResponse);
	  }
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

	  return new ResponseEntity<>(response, HttpStatus.OK);
	}

    /**
     * 医師かどうかチェックする
     */
    @GetMapping("/sharePatientInfo/checkDoctor")
    public ResponseEntity<?> checkDoctor() {

      // wp アプリケーションログの適正化 Add Start
      String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/sharingPatientInfo/checkDoctor";
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
      NtssUser ntssUser = (NtssUser) authentication.getPrincipal();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(personalUserService.checkDoctor(ntssUser.getFacilityCd(), ntssUser.getUserId()),
        HttpStatus.OK);
    }

	/**
	 * webAPIの共有患者情報解除処理を呼び出す
	 *
	 * @param facilityCdList 解除する施設コードリスト
	 * @return
	 * @throws Exception
	 */
	@PostMapping("/sharePatientInfo/cancelSharePatientInfo")
	public ResponseEntity<?> cancelSharePatientInfo(@RequestBody List<String> facilityCdList)
			throws Exception {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_NAME_IDENTIFICATION + "/sharingPatientInfo/cancelSharePatientInfo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

      try {
        webApiCallCommonUtil.cancelSharePatientInfo(facilityCdList);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

        // wp アプリケーションログの適正化 Add Start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>("FAIL", HttpStatus.BAD_REQUEST);
      }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("PASS", HttpStatus.OK);
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
