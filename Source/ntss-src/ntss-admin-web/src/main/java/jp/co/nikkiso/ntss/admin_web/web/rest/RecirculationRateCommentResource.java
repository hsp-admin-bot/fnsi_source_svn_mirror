package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.io.IOException;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import tools.jackson.core.JacksonException;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.RecirculationRateCommentService;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

@RestController
@RequestMapping(Uri.RE_LOOP_RATE_MAIN_COMMENTS)
public class RecirculationRateCommentResource {

  @Autowired
  RecirculationRateCommentService service;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  @Autowired
  OrdMainService ordMainService;
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

  @PostMapping("/{ordNo}")
  public ResponseEntity<?> update(@PathVariable Long ordNo, @RequestBody OrdMainRstWeightInfo dto)
    throws JacksonException, IOException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.RE_LOOP_RATE_MAIN_COMMENTS ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End
    service.update(ordNo, dto);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(service.get(ordNo), HttpStatus.OK);
  }

  @GetMapping("/{ordNo}")
  public ResponseEntity<?> get(@PathVariable Long ordNo,
                                  // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
                                  @AuthenticationPrincipal NtssUser ntssUser
                                  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
)
    throws JacksonException, IOException {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 start
    if(!ntssUser.isNkkAdminUser()) {
      OrdMain ordMain = ordMainService.selectByOrdNo(ordNo);
      if (ordMain != null && ordMain.getFacilityCd() != null &&
        !ordMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + ordMain.getFacilityCd() + " " + "ordNo=" + ordNo + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260421 end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.RE_LOOP_RATE_MAIN_COMMENTS ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(service.get(ordNo), HttpStatus.OK);
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
