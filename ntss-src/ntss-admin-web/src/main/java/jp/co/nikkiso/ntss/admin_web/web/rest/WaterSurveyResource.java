package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.admin_web.request.waterSurvey.WaterSurveySearchRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.waterSurvey.WaterSurveyService;
import jp.co.nikkiso.ntss.core.entity.MntWaterSurvey;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurvey;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * 水質管理のResourceクラス.
 */
@RestController
@RequestMapping(Uri.WATER_SURVEY)
public class WaterSurveyResource {

	/**
	 * 水質管理Service.
	 */
	@Autowired
	private WaterSurveyService waterSurveyService;

	/**
	 * ロギングのServiceインタフェース.
	 */
	@Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

	/**
	 * リストを取得水質管理
	 *
	 * @param request 水質調査の検索リクエスト
	 * @AuthenticationPrincipal ntssUser
	 * @return リスト水質管理
	 */
	@PostMapping("/filter")
	public ResponseEntity<?> getListWaterSurvey(
			@Valid @RequestBody WaterSurveySearchRequest request,
			@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WATER_SURVEY + "/filter";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

		try {
			List<MntWaterSurvey> res = waterSurveyService.filter(request.getStartDate(), request.getEndDate(), request.getListSurveytypeCd(), request.getBedGroupCd(), ntssUser.getFacilityCd());


      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(res, HttpStatus.OK);
		} catch (Exception e) {
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

			return new ResponseEntity<>(e.toString(), HttpStatus.INTERNAL_SERVER_ERROR);
		}

	}

	/**
	 * 調査記録による選択いいえ
	 *
	 * @param surveyRecordNo 水質調査記録番号
	 * @return 水質管理
	 */
	@GetMapping("/{surveyRecordNo}")
	public ResponseEntity<?> getWaterSurvey(
			@PathVariable Long surveyRecordNo,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
// #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
      ) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WATER_SURVEY ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      surveyRecordNo);
    // wp アプリケーションログの適正化 Add End

		try {
			WaterSurvey res = waterSurveyService.selectBySurveyRecordNo(surveyRecordNo);
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      if(!ntssUser.isNkkAdminUser()) {
        if (res.getFacilityCd() != null && !res.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          // #11205 mod 20260421 start
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + res.getFacilityCd() + " " + "surveyRecordNo=" + surveyRecordNo + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
          // #11205 mod 20260421 end
        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_INFO, mappingUrl, null,
        surveyRecordNo);
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(res, HttpStatus.OK);
		} catch (Exception e) {
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(e.toString(), HttpStatus.INTERNAL_SERVER_ERROR);
		}

	}

	/**
	 * 複数の水質管理を節約
	 *
	 * @param watSurveys 水質管理のリスト
	 * @return httpStatus
	 */
	@PostMapping("/saveMulti")
	public ResponseEntity<?> saveMultiWaterSurvey(@RequestBody List<WaterSurvey> watSurveys,
                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                @AuthenticationPrincipal NtssUser ntssUser
                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      for (WaterSurvey watSurvey : watSurveys) {
        if (watSurvey.getFacilityCd() != null && !watSurvey.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          // #11205 mod 20260421 start
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + watSurvey.getFacilityCd() + " " + "surveyRecordNo=" + (watSurvey.getSurveyRecordNo() != null ? watSurvey.getSurveyRecordNo() : "null") + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
          // #11205 mod 20260421 end
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WATER_SURVEY +"/saveMulti";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

		try {
			waterSurveyService.insertOrUpdateWaterSurveyMulti(watSurveys);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}
	/**
	 * 複数の水質管理を削除する
	 *
	 * @param surveyRecordNo 水質調査記録番号
	 * @param ntssUser
	 * @return httpStatus
	 */
	@PostMapping("/{surveyRecordNo}")
	 public ResponseEntity<Void> removeWaterSurvey(
			@PathVariable Long surveyRecordNo,
			@AuthenticationPrincipal NtssUser ntssUser) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WATER_SURVEY +"/saveMulti";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      surveyRecordNo);
    // wp アプリケーションログの適正化 Add End

		try {
			waterSurveyService.deleteWaterSurvey(surveyRecordNo, ntssUser.getFacilityCd());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_INFO, mappingUrl, null,
        surveyRecordNo);
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}

	}

	/**
	 * 調査データを削除
	 *
	 * @param surveyRecordNo 水質調査記録番号
	 * @param pointCd 調査箇所コード
	 * @param ntssUser
	 * @return httpStatus
	 */
	@PostMapping("/removeSurveyData")
	 public ResponseEntity<Void> removeSurveyData(
			@RequestParam(value = "surveyRecordNo", required = true) Long surveyRecordNo,
			@RequestParam(value = "pointCd", required = true) Long pointCd,
			@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WATER_SURVEY +"/removeSurveyData";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      surveyRecordNo);
    // wp アプリケーションログの適正化 Add End

		try {
			waterSurveyService.deleteSurverDataByPointCd(surveyRecordNo, pointCd, ntssUser.getFacilityCd());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_INFO, mappingUrl, null,
        surveyRecordNo);
      // wp アプリケーションログの適正化 Add End

			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}

	}

	/**
	 * 調査データを削除
	 *
	 * @param surveyRecordNo 水質調査記録番号
	 * @param pointCds 調査箇所コード
	 * @param ntssUser
	 * @return httpStatus
	 */
	@PostMapping("/{surveyRecordNo}/removeListSurveyData")
	 public ResponseEntity<Void> removeListSurveyData(
			@PathVariable Long surveyRecordNo,
			@RequestBody Map<String, String> pointCds,
			@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WATER_SURVEY +"/removeListSurveyData";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      surveyRecordNo);
    // wp アプリケーションログの適正化 Add End
		try {
			waterSurveyService.deleteListSurverData(surveyRecordNo, pointCds, ntssUser.getFacilityCd());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_INFO, mappingUrl, null,
        surveyRecordNo);
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}

	}
	// add FNSI-水質管理_青田の対応 徐 start
	/**
	 * 調査データを結果削除
	 *
	 * @param surveyRecordNo 水質調査記録番号
	 * @param pointCds 調査箇所コード
	 * @param ntssUser
	 * @return httpStatus
	 */
	@PostMapping("/{surveyRecordNo}/deleteListSurveyData")
	public ResponseEntity<Void> deleteListSurveyData(
			@PathVariable Long surveyRecordNo,
			@RequestBody Map<String, String> pointCds,
			@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WATER_SURVEY + "/deleteListSurveyData";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      surveyRecordNo);
    // wp アプリケーションログの適正化 Add End
		try {
			waterSurveyService.removeListSurverData(surveyRecordNo, pointCds, ntssUser.getFacilityCd());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_INFO, mappingUrl, null,
        surveyRecordNo);
      // wp アプリケーションログの適正化 Add End

			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
//			EventLogMessage eventLogMessage = new EventLogMessage();
//			eventLogMessage.setLogMessage(e.getMessage());
//			logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY,SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_WATER_QUALITY_SURVEY, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}
	// add FNSI-水質管理_青田の対応 徐 end

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
