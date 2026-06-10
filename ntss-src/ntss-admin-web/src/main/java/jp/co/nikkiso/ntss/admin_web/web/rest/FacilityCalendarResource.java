package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.facilityCalendar.FacilityCalendarService;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.FacilityCalendar;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * 施設カレンダーのリソースクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.FACILITY_CALENDAR)
public class FacilityCalendarResource {

	/**
	 * 施設カレンダーサービス.
	 */
	@Autowired
	FacilityCalendarService calendarService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

	/**
	   * データ機能カレンダーを取得.
	   * @param startDate 開始日
	   * @param endDate 終了日
	   * @param facCalLayoutCd 施設カレンダーレイアウトコード
	   * @param ntssUser NTSS認証ユーザー
	   */
	@GetMapping("/getData")
	public ResponseEntity<?> getDataFacilityCalendar(@RequestParam(name = "startDate") String startDate,
			@RequestParam(name = "endDate") String endDate, @RequestParam(name = "facCalLayoutCd", required = false) Long facCalLayoutCd,
			@AuthenticationPrincipal NtssUser ntssUser) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.FACILITY_CALENDAR + "/getData";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(endDate, facCalLayoutCd));
    // wp アプリケーションログの適正化 Add End

		List<FacilityCalendar> response = calendarService.getDataFacilityCalendar(startDate, endDate, facCalLayoutCd,
				ntssUser.getFacilityCd());

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(endDate, facCalLayoutCd));
    // wp アプリケーションログの適正化 Add End

		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	/**
	   * データ機能カレンダーを取得.
	   * @param date 日付
	   * @param itemName 施設カレンダーのレイアウト項目
	   * @param ntssUser NTSS認証ユーザー
	   */
	@GetMapping("/getPats")
	public ResponseEntity<?> getPatForFacilityCalendar(
			@RequestParam(name = "itemName") String itemName,
			@RequestParam(name = "date") String date,
			@AuthenticationPrincipal NtssUser ntssUser) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add StartFacilityCalendarResource.java
    String mappingUrl = Uri.FACILITY_CALENDAR + "/getPats";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(itemName, date));
    // wp アプリケーションログの適正化 Add End

		List<PatPersonalMain> response = calendarService.getPatByItemInFacilityCalendar(itemName, date, ntssUser.getFacilityCd());

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(itemName, date));
    // wp アプリケーションログの適正化 Add End

		return new ResponseEntity<>(response, HttpStatus.OK);
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
