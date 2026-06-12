package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.linkageDefinitionCreateion.LinkageDefinitionCreationService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PaginationUtils;
import jp.co.nikkiso.ntss.core.entity.MstCoopDistribute;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.MstCoopFilename;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.MstCoopApilink;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


@RestController
@RequestMapping(Uri.LINKAGE_DEFINITION)
public class LinkageDefinitionCreationResource {

  /**
   * リンケージ定義作成サービス
   */
  @Autowired
  LinkageDefinitionCreationService creationService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End


  /**
   * すべて連携電文設定マスタを取得
   * @param offset
   * @param limit
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopLayout")
  public ResponseEntity<?> selectAllMstCoopLayout(@RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayout";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstCoopLayout> coopLayoutsRs = creationService.selectAllMstCoopLayout(pageable);
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(coopLayoutsRs, HttpStatus.OK);
  }

  /**
   * CtlNoで連携電文設定マスタを取得
   * @param ctlNo
   * @return
   */
  @PostMapping("/coopLayout/{ctlNo}")
  public ResponseEntity<?> selectMstCoopLayoutByCtlNo(@PathVariable Long ctlNo) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayout";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ctlNo);
    // wp アプリケーションログの適正化 Add End
    MstCoopLayout response = creationService.selectMstCoopLayoutByCtlNo(ctlNo);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ctlNo);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 施設CDまたは連携電文CDで連携電文設定マスタを取得
   * @param coopLayout
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/coopLayout")
  public ResponseEntity<?> selectMstCoopLayoutByFacilityCdOrCoopCdOrCoopCdSub(@RequestBody MstCoopLayout coopLayout) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayout";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<MstCoopLayout> coopLayoutDetails = creationService.selectMstCoopLayoutByFacilityCdOrCoopCdOrCoopCdSub(coopLayout);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(coopLayoutDetails, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携電文名で連携電文設定マスタを取得
   * @param coopName
   * @param offset
   * @param limit
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/coopLayout/coopName/{coopName}")
  public ResponseEntity<?> selectMstCoopLayoutByCoopName(@PathVariable String coopName,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayout/coopName";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(coopName,offset, limit));
    // wp アプリケーションログの適正化 Add End
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstCoopLayout> coopLayoutDetails = creationService.selectMstCoopLayoutByCoopName(pageable, coopName);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(coopName,offset, limit));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(coopLayoutDetails, HttpStatus.OK);
  }

  /**
   * 最新の連携電文レイアウトマスタの管理番号を取得
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopLayout/newestCtlNo/{facilityCd}")
  public ResponseEntity<?> getNewestMstCoopLayoutsByFacilityCd(
      @PathVariable String facilityCd) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayout/newestCtlNo/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<String> lstCtlNo = creationService.selectNewestMstCoopLayoutCtlNoByFacilityCd(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(lstCtlNo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携電文レイアウトマスタを更新する。
   * @param MstCoopLayout
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopLayout/current/{facilityCd}")
  public ResponseEntity<?> getCurrentMstCoopLayoutsByFacilityCd(@PathVariable String facilityCd) {
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayout/current/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      List<MstCoopLayout> mstCoopLayouts = creationService.selectCurrentMstCoopLayoutsByFacilityCd(facilityCd);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(mstCoopLayouts, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null,
        ExcetionStackTraceToString(e));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @PostMapping("/coopLayout/submit")
  public ResponseEntity<?> submitMstCoopLayout(@RequestBody MstCoopLayout mstCoopLayout,
  @AuthenticationPrincipal NtssUser ntssUser) throws URISyntaxException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayout/submit";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submitMstCoopLayout(mstCoopLayout, ntssUser.getUserId());
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携レイアウト詳細を取得
   * @param coopCd
   * @param offset
   * @param limit
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/coopLayoutDetail/coopCd/{coopCd}")
  public ResponseEntity<?> selectAllMstCoopLayoutDetail(@PathVariable String coopCd,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayoutDetail/coopCd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(coopCd,offset, limit));
    // wp アプリケーションログの適正化 Add End
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstCoopLayoutDetail> coopLayoutDetails = creationService.selectAllMstCoopLayoutDetail(pageable);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(coopCd,offset, limit));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(coopLayoutDetails, HttpStatus.OK);
  }

  /**
   * 変換レイアウト詳細マスタの管理番号を取得
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopLayoutDetail/newestCtlNo/{facilityCd}")
  public ResponseEntity<?> getNewestMstCoopLayoutDetailsByFacilityCd(
      @PathVariable String facilityCd) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayoutDetail/newestCtlNo/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<String> lstCtlNo = creationService.selectNewestMstCoopLayoutDetailCtlNoByFacilityCd(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(lstCtlNo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * CtlNoで変換レイアウト詳細マスタを取得
   * @param ctlNo
   * @return
   */
  @GetMapping("/coopLayoutDetail/current/{facilityCd}")
  public ResponseEntity<?> getCurrentMstCoopLayoutDetailsByFacilityCd(@PathVariable String facilityCd) {
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayoutDetail/current/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      List<MstCoopLayoutDetail> mstCoopLayoutDetails = creationService.selectCurrentMstCoopLayoutDetailsByFacilityCd(facilityCd);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(mstCoopLayoutDetails, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null,
        ExcetionStackTraceToString(e));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/coopLayoutDetail/{ctlNo}")
  public ResponseEntity<?> selectMstCoopLayoutDetailByCtlNo(@PathVariable Long ctlNo) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayoutDetail";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ctlNo);
    // wp アプリケーションログの適正化 Add End
    MstCoopLayoutDetail response = creationService.selectMstCoopLayoutDetailByCtlNo(ctlNo);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ctlNo);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 変換レイアウト詳細マスタを更新する。
   * @param MstCoopLayoutDetail
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/coopLayoutDetail/submit")
  public ResponseEntity<?> submitMstCoopLayoutDetail(@RequestBody MstCoopLayoutDetail mstCoopLayoutDetail,
  @AuthenticationPrincipal NtssUser ntssUser) throws URISyntaxException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayoutDetail/submit";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submitMstCoopLayoutDetail(mstCoopLayoutDetail, ntssUser.getUserId());
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携ファイル名マスタの管理番号を取得
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopFilename/newestCtlNo/{facilityCd}")
  public ResponseEntity<?> getNewestMstCoopFilenamesByFacilityCd(
      @PathVariable String facilityCd) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopFilename/newestCtlNo/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<String> lstCtlNo = creationService.selectNewestMstCoopFilenameCtlNoByFacilityCd(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(lstCtlNo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * CtlNoで連携ファイル名マスタを取得
   * @param ctlNo
   * @return
   */
  @GetMapping("/coopFilename/current/{facilityCd}")
  public ResponseEntity<?> getCurrentMstCoopFilenamesByFacilityCd(@PathVariable String facilityCd) {
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopFilename/current/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      List<MstCoopFilename> mstCoopFilenames = creationService.selectCurrentMstCoopFilenamesByFacilityCd(facilityCd);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(mstCoopFilenames, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null,
        ExcetionStackTraceToString(e));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping("/coopFilename/{ctlNo}")
  public ResponseEntity<?> selectMstCoopFilenameByCtlNo(@PathVariable Long ctlNo) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopFilename";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ctlNo);
    // wp アプリケーションログの適正化 Add End
    MstCoopFilename response = creationService.selectMstCoopFilenameByCtlNo(ctlNo);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ctlNo);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 連携ファイル名マスタを保存する。
   * @param MstCoopFilename
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/coopFilename/submit")
  public ResponseEntity<?> submitMstCoopFilename(@RequestBody MstCoopFilename mstCoopFilename,
  @AuthenticationPrincipal NtssUser ntssUser) throws URISyntaxException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopFilename/submit";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submitMstCoopFilename(mstCoopFilename, ntssUser.getUserId());
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携電文配信を取得
   * @param offset
   * @param limit
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopDistribute")
  public ResponseEntity<?> selectAllMstCoopDistribute(@RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopDistribute";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End

    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstCoopDistribute> CoopDistributeRs = creationService.selectALlMstCoopDistribute(pageable);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(CoopDistributeRs, HttpStatus.OK);
  }

  /**
   * CtlNoで連携電文配信
   * @param ctlNo
   * @return
   */
  @PostMapping("/coopDistribute/{ctlNo}")
  public ResponseEntity<?> selectMstCoopDistributeByCtlNo(@PathVariable Long ctlNo) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopDistribute";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ctlNo);
    // wp アプリケーションログの適正化 Add End
    MstCoopDistribute mstCoopDistribute = creationService.selectMstCoopDistributeByCtlNo(ctlNo);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ctlNo);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(mstCoopDistribute, HttpStatus.OK);
  }

  /**
   * 施設CDで連携電文配信を取得
   * @param offset
   * @return
   */
  @PostMapping("/coopDistribute")
  public ResponseEntity<?> selectByCtlNoORFacilityCdAndcoopCd(
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit,
      @RequestBody MstCoopDistribute mstCoopDistribute) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopDistribute";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End
    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    Page<MstCoopDistribute> mstCoopDistributeLst = creationService.selectByCtlNoORFacilityCdAndcoopCd(pageable,
//        mstCoopDistribute.getCtlNo(), mstCoopDistribute.getFacilityCd(), mstCoopDistribute.getCoopCd());
    String coopVersion = StringUtils.isEmpty(mstCoopDistribute.getCoopVersion())?"":mstCoopDistribute.getCoopVersion();
    Page<MstCoopDistribute> mstCoopDistributeLst = creationService.selectByCtlNoORFacilityCdAndcoopCd(pageable,
      mstCoopDistribute.getCtlNo(), mstCoopDistribute.getFacilityCd(), mstCoopDistribute.getCoopCd(), coopVersion);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(mstCoopDistributeLst, HttpStatus.OK);
  }

  /**
   * 最新の連携配信設定マスタの管理番号を取得
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopDistribute/newestCtlNo/{facilityCd}")
  public ResponseEntity<?> getNewestMstCoopDistributeCtlNoByFacilityCd(
      @PathVariable String facilityCd) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/mstCoopDistribute/newestCtlNo/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<String> lstCtlNo = creationService.selectNewestMstCoopDistributeCtlNoByFacilityCd(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(lstCtlNo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携配信設定マスタを更新する。
   * @param MstCoopDistribute
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopDistribute/current/{facilityCd}")
  public ResponseEntity<?> getCurrentMstCoopDistributesByFacilityCd(@PathVariable String facilityCd) {
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopDistribute/current/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    try {
      List<MstCoopDistribute> mstCoopDistributes = creationService.selectCurrentMstCoopDistributesByFacilityCd(facilityCd);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(mstCoopDistributes, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null,
        ExcetionStackTraceToString(e));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @PostMapping("/coopDistribute/submit")
  public ResponseEntity<?> submitMstCoopDistribute(@RequestBody MstCoopDistribute mstCoopDistribute,
  @AuthenticationPrincipal NtssUser ntssUser) throws URISyntaxException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/mstCoopDistribute/submit";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submitMstCoopDistribute(mstCoopDistribute, ntssUser.getUserId());
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 最新の連携施設マスタの管理番号を取得
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopFacility/newestCtlNo")
  public ResponseEntity<?> getNewestMstCoopFacilityCtlNo() throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopFacility/newestCtlNo" ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<String> lstCtlNo = creationService.selectNewestMstCoopFacilityCtlNo();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(lstCtlNo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * CtlNo又は施設CDで連携施設を取得
   * @param offset
   * @param limit
   * @param mstCoopFacility
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/coopFacility")
  public ResponseEntity<?> selectByCtlNoOrFacilityCd(@RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit, @RequestBody MstCoopFacility mstCoopFacility)
      throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopFacility";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End

    Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
    Page<MstCoopFacility> coopFacilities = creationService.selectByCtlNoOrFacilityCd(pageable,
        mstCoopFacility.getCtlNo(), mstCoopFacility.getFacilityCd());

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(coopFacilities, HttpStatus.OK);
  }

  /**
   * 連携施設マスタを更新する。
   * @param MstCoopFacility
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/coopFacility/submit")
  public ResponseEntity<?> submitMstCoopFacility(@RequestBody MstCoopFacility mstCoopFacility,
  @AuthenticationPrincipal NtssUser ntssUser) throws URISyntaxException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopFacility/submit";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submitMstCoopFacility(mstCoopFacility, ntssUser.getUserId());
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * システムデータを取得
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/sysDataSet")
  public ResponseEntity<?> selectAllSysDataSet() {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/sysDataSet";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<SysDataSet> dataSets = creationService.selectAllSysDataSet();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(dataSets, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 項目を登録する。
   * @param payload
   * @param ntssUser
   * @return
   */
  @PostMapping("/submitItem")
  public ResponseEntity<?> submit(@RequestBody Map<String, String> payload,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/submitItem";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submit(payload, ntssUser.getUserId());
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * Occを登録する。
   * @param payload
   * @param ntssUser
   * @return
   */
  @PostMapping("/submitOcc")
  public ResponseEntity<?> submitOcc(@RequestBody Map<String, String> payload,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/submitOcc";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submitOcc(payload, ntssUser.getUserId());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 変換レイアウトマスター詳細を取得する。
   * @param payload
   * @return
   */
  @PostMapping("/mstCoopLayoutDetail/get_by")
  public ResponseEntity<?> getMstCoopLayoutDetail(@RequestBody Map<String, String> payload) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/mstCoopLayoutDetail/get_by";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      MstCoopLayoutDetail item = creationService.selectMstCoopLayoutDetail(payload);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(item, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

    /**
   * 施設CDで連携API関連付けマスタEntityを取得する
   * @param facilityCd
   * @return
   */
  @GetMapping("/mstCoopApilink/{facilityCd}")
  public ResponseEntity<?> selectMstCoopApilinksByFacilityCd(@PathVariable String facilityCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/mstCoopApilink/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<MstCoopApilink> sysCoopNos = creationService.selectMstCoopApilinksByFacility(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(sysCoopNos, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * コピー元の連携配信設定マスタEntityを取得する
   * @param mstCoopDistribute
   * @return
   */
  @PostMapping("/coopDistribute/source")
  public ResponseEntity<?> selectSourceMstCoopDistributes(@RequestBody MstCoopDistribute mstCoopDistribute) {
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopDistribute/source";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      mstCoopDistribute);
    try {
      List<MstCoopDistribute> mstCoopDistributes = creationService.selectSourceMstCoopDistributes(mstCoopDistribute);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(mstCoopDistributes, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null,
        ExcetionStackTraceToString(e));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * コピー元の連携電文レイアウトマスタEntityを取得する
   * @param mstCoopLayout
   * @return
   */
  @PostMapping("/coopLayout/source")
  public ResponseEntity<?> selectSourceMstCoopLayouts(@RequestBody MstCoopLayout mstCoopLayout) {
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayout/source";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      mstCoopLayout);
    try {
      List<MstCoopLayout> mstCoopLayouts = creationService.selectSourceMstCoopLayouts(mstCoopLayout);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(mstCoopLayouts, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null,
        ExcetionStackTraceToString(e));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * コピー元の連携電文レイアウト詳細マスタEntityを取得する
   * @param mstCoopLayoutDetail
   * @return
   */
  @PostMapping("/coopLayoutDetail/source")
  public ResponseEntity<?> selectSourceMstCoopLayoutDetails(@RequestBody MstCoopLayoutDetail mstCoopLayoutDetail) {
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopLayoutDetail/source";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      mstCoopLayoutDetail);
    try {
      List<MstCoopLayoutDetail> mstCoopLayoutDetails = creationService.selectSourceMstCoopLayoutDetails(mstCoopLayoutDetail);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(mstCoopLayoutDetails, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null,
        ExcetionStackTraceToString(e));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * コピー元の連携ファイル名マスタEntityを取得する
   * @param mstCoopFilename
   * @return
   */
  @PostMapping("/coopFilename/source")
  public ResponseEntity<?> selectSourceMstCoopFilenames(@RequestBody MstCoopFilename mstCoopFilename) {
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/coopFilename/source";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      mstCoopFilename);
    try {
      List<MstCoopFilename> mstCoopFilenames = creationService.selectSourceMstCoopFilenames(mstCoopFilename);
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      return new ResponseEntity<>(mstCoopFilenames, HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null,
        ExcetionStackTraceToString(e));
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * コピー元の連携API関連付けマスタEntityを取得する
   * @param mstCoopApilink
   * @return
   */
  @PostMapping("/mstCoopApilink/source")
  public ResponseEntity<?> selectSourceMstCoopApilinks(@RequestBody MstCoopApilink mstCoopApilink) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/mstCoopApilink/source";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      mstCoopApilink);
    // wp アプリケーションログの適正化 Add End
    try {
      List<MstCoopApilink> mstCoopApilinks = creationService.selectSourceMstCoopApilinks(mstCoopApilink);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(mstCoopApilinks, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携API関連付けマスタを登録する。
   * @param sysCoopNo
   * @param ntssUser
   * @return
   */
  @PostMapping("/mstCoopApilink/submit")
  public ResponseEntity<?> submitApilink(@RequestBody MstCoopApilink mstCoopApilink,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/mstCoopApilink/submit";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submitMstCoopApilink(mstCoopApilink, ntssUser.getUserId());
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携設定マスタを取得
   * @param facilityCd
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("/coopIni/{facilityCd}")
  public ResponseEntity<?> getMstCoopIniByFacilityCd(
      @PathVariable String facilityCd) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/mstCoopIni/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      List<MstCoopIni> mstCoopInis = creationService.selectMstCoopIniByFacilityCd(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(mstCoopInis, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(),"", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 連携設定マスタを更新する。
   * @param mstCoopIni
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("/coopIni/submit")
  public ResponseEntity<?> submitMstCoopIni(@RequestBody MstCoopIni mstCoopIni) throws URISyntaxException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/mstCoopIni/submit";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.submitMstCoopIni(mstCoopIni);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @DeleteMapping("uninstallCoop/{facilityCd}")
  public ResponseEntity<?> uninstallCoop(@PathVariable String facilityCd){
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.LINKAGE_DEFINITION + "/uninstallCoop/" + facilityCd;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    try {
      Boolean result = creationService.UninstallCoop(facilityCd);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
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
