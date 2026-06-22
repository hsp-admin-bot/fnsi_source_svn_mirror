package jp.co.nikkiso.ntss.admin_web.web.rest;

//import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.statusList.DispItemListResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.TreatmentStatusListService;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;


@RestController
@Slf4j
@RequestMapping(Uri.TREAT_STATUS_LIST)
public class SysTreatmentStatusLayoutResource {
  /**
   * 治療状況リスト情報の取得
   */
  @Autowired
  private TreatmentStatusListService treatmentStatusListService;

  @Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  /**
   * 治療状況レイアウトマスタの装置設定で選択する表示項目の一覧を取得する
   * @param ntssUser
   * @return
   */
  @GetMapping("/master/get/disp_items")
  public ResponseEntity<?> getTreatmentStatusLayoutDispItems(
      @AuthenticationPrincipal NtssUser ntssUser
    ){

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.TREAT_STATUS_LIST + "/master/get";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
      // 装置設定での表示項目の一覧を取得
      List<DispItemListResponse> treatmentStatusLayoutDispItemList =  treatmentStatusListService.getTreatmentStatusListDispItems(ntssUser.getFacilityCd());


      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(treatmentStatusLayoutDispItemList, HttpStatus.OK);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("REST request error by get getTreatmentStatusLayout : "+ e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
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
