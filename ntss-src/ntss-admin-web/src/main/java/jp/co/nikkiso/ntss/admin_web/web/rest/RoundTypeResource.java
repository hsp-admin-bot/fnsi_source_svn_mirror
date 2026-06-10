package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.response.roundType.RoundTypeNameAndContentResponse;
import jp.co.nikkiso.ntss.admin_web.service.RoundTypeService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@Slf4j
@RequestMapping(Uri.ROUND_TYPE)
public class RoundTypeResource {

  /**
   * 種別マスタ用のService.
   */
  @Autowired
  private RoundTypeService roundTypeService;

  @Autowired
	LogService logService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  //add #12462 患者情報共有 zrx start
  @Autowired
  private MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;
  //add #12462 患者情報共有 zrx end

  /**
   * 種別マスタ取得.
   * @param facilityCd 施設コード
   * @return
   */
  //mod #12462 患者情報共有 zrx start
//  @GetMapping("{facility_cd}/name-and-content")
  @GetMapping({
    "{facility_cd}/name-and-content",
    "{facility_cd}/name-and-content/{patId}"
  })
  public ResponseEntity<?> getRoundTypeNameAndContent(
      @PathVariable("facility_cd") String facilityCd,
      @PathVariable(value = "patId", required = false) String patId) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.ROUND_TYPE + "/name-and-content";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
     null);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get round type : "+ facilityCd);
//    logService.log(LogLevel.DEBUG, eventLogMessage,"", SERVICE_NAME.FNSI, null);

    // 種別マスタの取得
//    List<RoundTypeNameAndContentResponse> res = roundTypeService.createRoundTypeNameAndContentResponse(facilityCd);
    List<RoundTypeNameAndContentResponse> res =
      new ArrayList<>(roundTypeService.createRoundTypeNameAndContentResponse(facilityCd));
    if (StringUtils.hasText(patId)) {
      List<PatNameIdentification> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatTo(Long.valueOf(patId));
      if(srcPatIds != null && !srcPatIds.isEmpty()) {
        for (PatNameIdentification patIdsrc : srcPatIds) {
          List<RoundTypeNameAndContentResponse> patIdsrcRes = roundTypeService.createRoundTypeNameAndContentResponse(patIdsrc.getFacilityCdSrc());
          if(patIdsrcRes != null && !patIdsrcRes.isEmpty()) {
            res.addAll(patIdsrcRes);
          }
        }
      }
    }
    //mod #12462 患者情報共有 zrx start


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End
    // レスポンス生成
    return new ResponseEntity<>(res, HttpStatus.OK);
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
