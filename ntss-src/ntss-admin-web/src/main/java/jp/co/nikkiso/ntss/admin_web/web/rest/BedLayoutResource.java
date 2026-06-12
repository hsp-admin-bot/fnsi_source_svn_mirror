package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.statusMap.BedLayoutService;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstStatusMapBedLayout;
//import static jp.co.nikkiso.ntss.core.entity.SysMasterDefine.*;
import lombok.extern.slf4j.Slf4j;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

/**
 * bed_layoutのRestクラス
 */
@Slf4j
@RestController
@RequestMapping(Uri.BED_LAYOUT)
public class BedLayoutResource {

  @Autowired
  private BedLayoutService bedLayoutService;

	@Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  // add #12658 【securify】SQLインジェクション(High) ユーザフロートボタンメニュー zrx start
  private static final Pattern FACILITY_CD_PATTERN = Pattern.compile("^[A-Za-z0-9]{6}$");
  // add #12658 【securify】SQLインジェクション(High) ユーザフロートボタンメニュー zrx end

  /**
   * 治療状況マップベッドレイアウトを一件取得
   * @param facilityCd
   * @param layoutId
   * @return
   */
  @GetMapping("/{facilityCd}/{layoutId}")
  public ResponseEntity<?> getStatusMapBedLayout(
      @PathVariable(name = "facilityCd", required = true) String facilityCd,
      @PathVariable(name = "layoutId", required = true) String layoutId,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (!ntssUser.isNkkAdminUser()) {
        if (facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BED_LAYOUT ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      layoutId);
    // wp アプリケーションログの適正化 Add End

    MstStatusMapBedLayout res = new MstStatusMapBedLayout();

    try {
      if ( StrUtils.isNumber(layoutId) ) {
        res = bedLayoutService.selectByLayoutId(facilityCd, Integer.parseInt(layoutId));

      } else {
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("layoutId is not number.");
//        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//        null);

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
          layoutId);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);

      }

    } catch (Exception e) {
//    	EventLogMessage eventLogMessage = new EventLogMessage();
//    	eventLogMessage.setLogMessage("REST request error by getStatusMapBedLayout : "+ e.getMessage());
//    	logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//    	null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);

    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      layoutId);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * 施設コードの治療状況マップベッドレイアウトの一覧を取得
   * @param facilityCd
   * @return
   */
  @GetMapping("/{facilityCd}")
  public ResponseEntity<?> getStatusMapBedLayoutByFacilityCd(
      @PathVariable(name = "facilityCd", required = true) String facilityCd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BED_LAYOUT ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MstStatusMapBedLayout> res = new ArrayList<MstStatusMapBedLayout>();

    try {
        res = bedLayoutService.selectByFacilityCd(facilityCd);

    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage( "REST request error by getStatusMapBedLayoutByFacilityCd : "+ e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//      null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);

    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * 新規登録
   * @param mstStatusMapBedLayout
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/insert")
  public ResponseEntity<Object> insertBedLayout(
      @RequestBody MstStatusMapBedLayout mstStatusMapBedLayout,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) throws URISyntaxException {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (mstStatusMapBedLayout.getFacilityCd() != null && !mstStatusMapBedLayout.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstStatusMapBedLayout.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BED_LAYOUT + "/insert";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // add #12658 【securify】SQLインジェクション(High) ユーザフロートボタンメニュー zrx start
    String facilityCd = mstStatusMapBedLayout.getFacilityCd();
    if (facilityCd == null || !FACILITY_CD_PATTERN.matcher(facilityCd).matches()) {
      logEventUtils.resourceLogOutput(
        getClassName(),
        getMethodName(),
        "",
        AFTER_LOG_FLG_INFO,
        mappingUrl,
        null,
        "invalid facilityCd: " + facilityCd
      );
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("facilityCdは英数字6桁のみ指定可能です。");
    }

    String layoutName = mstStatusMapBedLayout.getLayoutName();
    if (!StringUtils.hasText(layoutName) || layoutName.length() > 40) {
      logEventUtils.resourceLogOutput(
        getClassName(),
        getMethodName(),
        "",
        AFTER_LOG_FLG_INFO,
        mappingUrl,
        null,
        "invalid layoutName"
      );
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("layoutNameは1文字以上40文字以内で指定してください。");
    }

    String isHomeDialysis = mstStatusMapBedLayout.getIsHomeDialysis();
    if (!StringUtils.hasText(isHomeDialysis) || isHomeDialysis.length() != 1) {
      logEventUtils.resourceLogOutput(
        getClassName(),
        getMethodName(),
        "",
        AFTER_LOG_FLG_INFO,
        mappingUrl,
        null,
        "invalid isHomeDialysis"
      );
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("isHomeDialysisは1文字で指定してください。");
    }
    // add #12658 【securify】SQLインジェクション(High) ユーザフロートボタンメニュー zrx end

    try {
      Long res = bedLayoutService.insertRenew(mstStatusMapBedLayout);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (DuplicateKeyException e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

  /**
   * 更新
   * @param mstStatusMapBedLayout
   * @return
   * @throws URISyntaxException
   */
  @PutMapping("/update")
  public ResponseEntity<Void> updateBedLayout(
      @RequestBody MstStatusMapBedLayout mstStatusMapBedLayout,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (mstStatusMapBedLayout.getFacilityCd() != null && !mstStatusMapBedLayout.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + mstStatusMapBedLayout.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BED_LAYOUT + "/update";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    try {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage("updateBedLayout");
//      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI,
//      null);

      bedLayoutService.update(mstStatusMapBedLayout);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return ResponseEntity.ok().build();
    } catch (DuplicateKeyException e) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
  }

//  /**
//   * 削除
//   * @param mstStatusMapBedLayout
//   * @return
//   * @throws URISyntaxException
//   */
//  @PutMapping("/delete")
//  public ResponseEntity<Void> deleteBedLayout(
//      @RequestBody String facilityCd,
//      @RequestBody String layoutId){
//
//    try {
//      MstStatusMapBedLayout delData = bedLayoutService.selectByLayoutId(facilityCd, Integer.parseInt(layoutId));
//      bedLayoutService.update(delData);
//      bedLayoutService.delete(mstStatusMapBedLayout);
//
//      return ResponseEntity.ok().build();
//    } catch (DuplicateKeyException e) {
//      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
//
//    }
//  }

  /**
   * 装置マスタ一覧を取得
   * @param facilityCd
   * @return
   */
  @GetMapping("/mst_machine/{facilityCd}")
  public ResponseEntity<?> getMstMachine(
      @PathVariable(name = "facilityCd", required = true) String facilityCd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
){
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BED_LAYOUT + "/mst_machine";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MstMachine> res = new ArrayList<MstMachine>();

    try {
      if (!StringUtils.isEmpty(facilityCd)) {
        res = bedLayoutService.selectMstMachineByFacilityCd(facilityCd);

      } else {
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage( "facilityCd is empty.");
//        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//        null);
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);

      }

    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage( "REST request error by getMstMachine : "+ e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//      null);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);

    }

    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * ベッドマスタ一覧を取得
   * @param facilityCd
   * @return
   */
  @GetMapping("/mst_bed/{facilityCd}")
  public ResponseEntity<?> getMstBed(
      @PathVariable(name = "facilityCd", required = true) String facilityCd,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
){
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BED_LAYOUT + "/mst_bed";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MstBed> res = new ArrayList<MstBed>();

    try {
      if (!StringUtils.isEmpty(facilityCd)) {
        res = bedLayoutService.selectMstBedByFacilityCd(facilityCd);

      } else {
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage( "facilityCd is empty.");
//        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//        null);
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage( "REST request error by getMstBed : "+ e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI,
//      null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(res, HttpStatus.OK);
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
