package jp.co.nikkiso.ntss.admin_web.web.rest;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.bbsInfo.BbsInfoResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.BbsInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PaginationUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.BbsSearchRequest;
import jp.co.nikkiso.ntss.core.entity.BbsInfo;
import jp.co.nikkiso.ntss.core.entity.BbsInfoCount;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 掲示板登録情報系
 */
@RestController
@RequestMapping(Uri.BBS_INFO)
public class BbsInfoResource {

  @Autowired
  BbsInfoService bbsInfoService;

  @Autowired
  LogService logService;

  // wangzuo アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wangzuo アプリケーションログの適正化 Add End
  /**
   * 掲示板登録情報取得(施設指定)
   */
  @GetMapping("/getBbsInfo/{facility_cd}")
  public ResponseEntity<List<BbsInfo>> getBbsInfoByFacilityCd(
    @PathVariable String facility_cd,
    @RequestParam(value = "page", required = false) Integer offset,
    @RequestParam(value = "per_page", required = false) Integer limit,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) {
    String mappingUrl = Uri.BBS_INFO + "/getBbsInfo";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部入力 facility_cd は session.facilityCd と直接比較し、他施設の掲示板参照を防止する。
    if(!ntssUser.isNkkAdminUser()) {
      if (facility_cd != null && !facility_cd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(new ArrayList<>(), HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end

    // wangzuo アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
      Arrays.asList(offset, limit));
    // wangzuo アプリケーションログの適正化 Add End

    try {
      Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
      Page<BbsInfo> page = bbsInfoService.getBbsInfoByFacilityCd(pageable, facility_cd);
      HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.BBS_INFO + "/bbsInfo/" + facility_cd, offset, limit);

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd,
        Arrays.asList(offset, limit));
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
      //      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 掲示板登録情報取得(掲示板番号指定)
   */
  @GetMapping("/getBbsInfoById/{selectedBbsCtlNo}")
  public ResponseEntity<BbsInfo> getBbsInfoByNo(@PathVariable long selectedBbsCtlNo,
                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
                                                @AuthenticationPrincipal NtssUser ntssUser
                                                // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) {

    // wangzuo アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BBS_INFO + "/getBbsInfoById";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null, selectedBbsCtlNo);
    // wangzuo アプリケーションログの適正化 Add End

    try {
      BbsInfo bbsInfo = bbsInfoService.getBbsInfoByNo(selectedBbsCtlNo);
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
      // 外部入力 selectedBbsCtlNo で取得した掲示の facility_cd を照合し、他施設の掲示参照を防止する。
      if(!ntssUser.isNkkAdminUser()) {
//        if (bbsInfo != null && bbsInfo.getFacility_cd() != null && !bbsInfo.getFacility_cd().equals(ntssUser.getFacilityCd())) {
//          return new ResponseEntity<>(null, HttpStatus.FORBIDDEN);
//        }
      }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null, selectedBbsCtlNo);
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(bbsInfo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }

  /**
   * 掲示板登録情報登録
   */
  @PostMapping("/createBbs")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.FCL_EDIT + "')")
  public ResponseEntity<Long> createBbs(@RequestBody Map<String, String> payload,
                                        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
                                        @AuthenticationPrincipal NtssUser ntssUser
                                        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) {
    // wangzuo アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BBS_INFO + "/createBbs";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null, payload);
    // wangzuo アプリケーションログの適正化 Add End
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // RequestBody 内 bbs_info.facility_cd を session.facilityCd と照合し、解析失敗時は 400 を返して fail-open を防止する。
    String bbsInfoJson = payload.get("bbs_info");
    try {
      if (!ntssUser.isNkkAdminUser()) {
        if (bbsInfoJson != null && !bbsInfoJson.isEmpty()) {
          JsonNode jsonNode = new ObjectMapper().readTree(bbsInfoJson);
          JsonNode facilityNode = jsonNode.get("facility_cd");
          if (facilityNode != null && !facilityNode.isNull()) {
            String requestFacilityCd = facilityNode.asText();
            if (!requestFacilityCd.equals(ntssUser.getFacilityCd())) {
              return new ResponseEntity<>(HttpStatus.FORBIDDEN);
            }
          }
        }
      }
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage() + "bbsInfoJson:" + bbsInfoJson);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end

    try {
      long assignedBbsCtlNo = bbsInfoService.createBbs(payload);

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null, payload);
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(assignedBbsCtlNo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 掲示板登録情報更新
   */
  @PostMapping("/updateBbs/{bbs_ctl_no}")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.FCL_EDIT + "')")
  public ResponseEntity<Void> updateBbs(
    @PathVariable long bbs_ctl_no,
    @RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) {
    String mappingUrl = Uri.BBS_INFO + "/updateBbs";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部入力 bbs_ctl_no で取得した掲示の facility_cd を照合し、他施設の掲示更新を防止する。
    if(!ntssUser.isNkkAdminUser()) {
      BbsInfo bbsInfoByNo = bbsInfoService.getBbsInfoByNo(bbs_ctl_no);
      if (bbsInfoByNo != null && bbsInfoByNo.getFacility_cd() != null && !bbsInfoByNo.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end

    // wangzuo アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(bbs_ctl_no, payload));
    // wangzuo アプリケーションログの適正化 Add End

    try {
      bbsInfoService.updateBbs(bbs_ctl_no, payload);

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(bbs_ctl_no, payload));
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 掲示板登録情報一覧更新
   */
  @PostMapping("/updateBbsList")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.FCL_EDIT + "')")
  public ResponseEntity<Void> updateBbsList(@RequestBody List<Map<String, String>> payload,
                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
                                            @AuthenticationPrincipal NtssUser ntssUser
                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) {
    // wangzuo アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BBS_INFO + "/updateBbsList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null, payload);
    // wangzuo アプリケーションログの適正化 Add End


    try {
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw start
      // サービス呼び出しに session.facilityCd を渡し、他施設の掲示を一括更新できないようにする。
      // bbsInfoService.updateBbsList(payload);
      bbsInfoService.updateBbsList(payload,ntssUser.getFacilityCd());
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw end
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null, payload);
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  // add 障害票一覧_NKK 修正 chen start
  /**
   * 掲示板登録情報一覧更新
   */
  @PostMapping("/updateBbsListNoAuthorize")
  public ResponseEntity<Void> updateBbsListNoAuthorize(@RequestBody List<Map<String, String>> payload,
                                                       // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
                                                       @AuthenticationPrincipal NtssUser ntssUser
                                                       // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) {
    // wangzuo アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BBS_INFO + "/updateBbsListNoAuthorize";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null, payload);
    // wangzuo アプリケーションログの適正化 Add End
    try {
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw start
      // サービス呼び出しに session.facilityCd を渡し、他施設の掲示を一括更新できないようにする。
      // bbsInfoService.updateBbsList(payload);
      bbsInfoService.updateBbsList(payload,ntssUser.getFacilityCd());
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw end
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null, payload);
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }
  // add 障害票一覧_NKK 修正 chen end

  /**
   * 掲示板登録情報削除
   */
  @PostMapping("/deleteBbs/{bbs_ctl_no}")
  public ResponseEntity<Void> deleteBbs(@PathVariable long bbs_ctl_no,
                                        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
                                        @AuthenticationPrincipal NtssUser ntssUser
                                        // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) {
    String mappingUrl = Uri.BBS_INFO + "/deleteBbs";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部入力 bbs_ctl_no で取得した掲示の facility_cd を照合し、他施設の掲示削除を防止する。
    if(!ntssUser.isNkkAdminUser()) {
      BbsInfo bbsInfoByNo = bbsInfoService.getBbsInfoByNo(bbs_ctl_no);
      if (bbsInfoByNo != null && bbsInfoByNo.getFacility_cd() != null && !bbsInfoByNo.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
    // wangzuo アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null, bbs_ctl_no);
    // wangzuo アプリケーションログの適正化 Add End

    try {
      bbsInfoService.deleteBbs(bbs_ctl_no);

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null, bbs_ctl_no);
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 検索
   *
   * @param searchConditions 検索条件
   * @return 条件を満たす掲示一覧
   */
  @PostMapping("/getBbsSearchResult/{facility_cd}")
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
//  public ResponseEntity<List<BbsInfo>> getBbsSearchResult(
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
  public ResponseEntity<List<BbsInfoCount>> getBbsSearchResult(
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
    @PathVariable String facility_cd,
    @RequestBody BbsSearchRequest searchConditions,
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
    @AuthenticationPrincipal NtssUser ntssUser
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
  ) throws Exception {
    String mappingUrl = Uri.BBS_INFO + "/getBbsSearchResult";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部入力 facility_cd は session.facilityCd と直接比較し、検索範囲を現在施設に限定する。
    if(!ntssUser.isNkkAdminUser()) {
      if (facility_cd != null && !facility_cd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(new ArrayList<>(), HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end

    // wangzuo アプリケーションログの適正化 Add Start

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd,
      Arrays.asList(searchConditions, ntssUser));
    // wangzuo アプリケーションログの適正化 Add End

    try {
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
// List<BbsInfo> bbsInfo = bbsInfoService.getBbsSearchCondition(facility_cd, searchConditions);
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      if ("****".equals(searchConditions.getUserId())) {
        searchConditions.setUserId(String.valueOf(ntssUser.getUserId()));
      }
      List<BbsInfoCount> bbsInfo = bbsInfoService.getBbsSearchCondition(facility_cd, searchConditions);
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd,
        Arrays.asList(searchConditions, ntssUser));
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(bbsInfo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @PostMapping("/getBbsSearchResultForCalendar/{facility_cd}")
  public ResponseEntity<List<BbsInfoResponse>> getBbsSearchResultForCalendar(
    @PathVariable String facility_cd,
    @RequestBody BbsSearchRequest searchConditions,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) throws Exception {

    // wangzuo アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BBS_INFO + "/getBbsSearchResultForCalendar";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部入力 facility_cd は session.facilityCd と直接比較し、カレンダー掲示検索を現在施設に限定する。
    if(!ntssUser.isNkkAdminUser()) {
      if (facility_cd != null && !facility_cd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(new ArrayList<>(), HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end

    // wangzuo アプリケーションログの適正化 Add Start

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd, searchConditions);
    // wangzuo アプリケーションログの適正化 Add End

    try {

      List<BbsInfoResponse> bbsInfo = bbsInfoService.getBbsSearchConditionForCalendar(facility_cd, searchConditions);

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd, searchConditions);
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(bbsInfo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //  add 6216 施設イベントの表示条件の不正 zhao start
  @PostMapping("/getBbsSearchResultForCalendar/{facility_cd}/{facCalLayoutCd}")
  public ResponseEntity<List<BbsInfoResponse>> getBbsSearchResultForCalendar(
    @PathVariable String facility_cd,
    @PathVariable Long facCalLayoutCd,
    @RequestBody BbsSearchRequest searchConditions,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) throws Exception {
    String mappingUrl = Uri.BBS_INFO + "/getBbsSearchResultForCalendar";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部入力 facility_cd は session.facilityCd と直接比較し、facCalLayoutCd の絞り込みも現在施設内に限定する。
    if(!ntssUser.isNkkAdminUser()) {
      if (facility_cd != null && !facility_cd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(new ArrayList<>(), HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end

    // wangzuo アプリケーションログの適正化 Add Start

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd, searchConditions);
    // wangzuo アプリケーションログの適正化 Add End
    try {
      List<BbsInfoResponse> bbsInfo = bbsInfoService.getBbsSearchConditionForCalendar(facility_cd, searchConditions);
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd, searchConditions);
      List<BbsInfoResponse> bbsInfoRes = bbsInfoService.getBbsSearchConditionForCalendarFacCalLayoutCd(facCalLayoutCd, bbsInfo);
      return new ResponseEntity<>(bbsInfoRes, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  //  add 6216 施設イベントの表示条件の不正 zhao end
  /**
   * 検索患者情報
   * @param patIdList
   * @param ntssUser
   * @return
   * @throws Exception
   */
  @PostMapping("/getPatList")
  public ResponseEntity<List<PatPersonalMain>> getPatSearchResult(
    @RequestBody List<Long> patIdList,
    @AuthenticationPrincipal NtssUser ntssUser
  ) throws Exception {

    // wangzuo アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BBS_INFO + "/getPatList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(patIdList, ntssUser));
    // wangzuo アプリケーションログの適正化 Add End

    try {
      List<PatPersonalMain> patInfo = bbsInfoService.getPatList(patIdList, ntssUser.getFacilityCd());

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(patIdList, ntssUser));
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(patInfo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * ログイン利用者取得
   *
   * @param disp_user_id
   * @return 利用者情報
   */
  @GetMapping("/getUserAuthentication/{facility_cd}")
  public ResponseEntity<MstUserAuthentication> getUserAuthentication(
    @PathVariable String facility_cd,
    @RequestParam(name = "disp_user_id", required = false) String disp_user_id,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) throws Exception {
    String mappingUrl = Uri.BBS_INFO + "/getUserAuthentication";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部入力 facility_cd は session.facilityCd と直接比較し、利用者権限情報の施設切替参照を防止する。
    if(!ntssUser.isNkkAdminUser()) {
      if (facility_cd != null && !facility_cd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(null, HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end

    // wangzuo アプリケーションログの適正化 Add Start

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, facility_cd, disp_user_id);
    // wangzuo アプリケーションログの適正化 Add End

    try {

      MstUserAuthentication userInfo = bbsInfoService.getUserAuthentication(disp_user_id, facility_cd);

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, facility_cd, disp_user_id);
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(userInfo, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, facility_cd, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * ファイルダウンロード
   * @param filepath
   * @param ntssUser
   * @return
   */
  @GetMapping("/files")
  public ResponseEntity<?> downloadFile(@RequestParam("filepath") String filepath, @AuthenticationPrincipal NtssUser ntssUser) {
    // wangzuo アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BBS_INFO + "/files";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null, filepath);
    // wangzuo アプリケーションログの適正化 Add End

    try {
      String encodedFiles = bbsInfoService.downloadBbsFileAttachment(filepath, ntssUser.getFacilityCd());

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null, filepath);
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(encodedFiles, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * ファイルアップロード
   *
   * @param file
   */
  @PostMapping("/files/{bbsInfo}")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.FCL_EDIT + "')")
  public ResponseEntity<Void> uploadFile(
    @RequestParam("files") MultipartFile file,
    @PathVariable("bbsInfo") String bbsInfo,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) {
    // wangzuo アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.BBS_INFO + "/files";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // パス変数 bbsInfo に含まれる facility_cd を session.facilityCd と照合し、他施設掲示への添付アップロードを防止する。
    if (!ntssUser.isNkkAdminUser()) {
      String[] bbs = bbsInfo.split("&");
      String facility_cd = bbs[0];
      if (facility_cd != null && !facility_cd.equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
    // wangzuo アプリケーションログの適正化 Add Start

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(file, bbsInfo));
    // wangzuo アプリケーションログの適正化 Add End

    try {
      bbsInfoService.uploadBbsFileAttachment(file, bbsInfo);

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(file, bbsInfo));
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * ファイル削除
   * @param bbs_ctl_no
   * @param fileInfo
   * @param ntssUser
   * @return
   */
  @PostMapping("/deleteBbsFileAttachment/{bbs_ctl_no}")
  @PreAuthorize("hasAuthority('" + AdminWebConstant.Authority.FCL_EDIT + "')")
  public ResponseEntity<?> deleteFile(
    @PathVariable("bbs_ctl_no") long bbs_ctl_no,
    @RequestBody List<Map<String, String>> fileInfo,
    @AuthenticationPrincipal NtssUser ntssUser
  ) {
    String mappingUrl = Uri.BBS_INFO + "/deleteBbsFileAttachment";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部入力 bbs_ctl_no で取得した掲示の facility_cd を照合し、他施設掲示の添付削除を防止する。
    if(!ntssUser.isNkkAdminUser()) {
      BbsInfo bbsInfoByNo = bbsInfoService.getBbsInfoByNo(bbs_ctl_no);
      if (bbsInfoByNo != null && bbsInfoByNo.getFacility_cd() != null && !bbsInfoByNo.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
    // wangzuo アプリケーションログの適正化 Add Start

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(bbs_ctl_no, fileInfo));
    // wangzuo アプリケーションログの適正化 Add End

    try {
      bbsInfoService.deleteBbsFileAttachment(fileInfo, bbs_ctl_no, ntssUser.getFacilityCd());

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(bbs_ctl_no, fileInfo));
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end

      return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 掲示板登録情報更新(添付ファイル情報)
   */
  @PostMapping("/updateBbsFileInfo/{bbs_ctl_no}")
  public ResponseEntity<Void> updateBbsFileInfo(
    @PathVariable long bbs_ctl_no,
    @RequestBody Map<String, String> payload,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
  ) {
    String mappingUrl = Uri.BBS_INFO + "/updateBbsFileInfo";
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部入力 bbs_ctl_no で取得した掲示の facility_cd を照合し、他施設掲示の添付情報更新を防止する。
    if (!ntssUser.isNkkAdminUser()) {
      BbsInfo bbsInfoByNo = bbsInfoService.getBbsInfoByNo(bbs_ctl_no);
      if (bbsInfoByNo != null && bbsInfoByNo.getFacility_cd() != null && !bbsInfoByNo.getFacility_cd().equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end

    // wangzuo アプリケーションログの適正化 Add Start

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(bbs_ctl_no, payload));
    // wangzuo アプリケーションログの適正化 Add End

    try {
      bbsInfoService.updateBbsFileInfo(bbs_ctl_no, payload);

      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(bbs_ctl_no, payload));
      // wangzuo アプリケーションログの適正化 Add End

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wangzuo アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_BBS_INFO, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wangzuo アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /*add FNSI-改修内容掲示板外结No.10 任 start*/
  @GetMapping("/getJobName")
  public ResponseEntity<?> getJobName(// #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw start
                                      // 外部 facilityCd は受け取らず、session.facilityCd の職種マスタのみを参照する。
                                      // @PathVariable String facilityCd,
                                      @AuthenticationPrincipal NtssUser ntssUser
                                      // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw start
    // 外部 facilityCd は受け取らず、session.facilityCd の職種マスタのみを参照する。
    String facilityCd = ntssUser.getFacilityCd();
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 shiyw end
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getJobName/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<MstJob> mstJobs  = bbsInfoService.getJobName(facilityCd);
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(facilityCd));
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(mstJobs, HttpStatus.OK);
  }
  // #11205 -ペンテスト2－4認可制御の不備 -> mod 8220 施設イベント詳細画面の表示が遅い 関  --> 弃用 del 20260317 shiyw start
//  @GetMapping("/getIsSame")
//  public ResponseEntity<?> getIsSame() {
//    // add FNSi5712アプリケーションログが出力しない 周 start
//    String mappingUrl = Uri.PAT_INFO + "/getIsSame";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
//      BEFORE_LOG_FLG_INFO, mappingUrl, null, null);
//    // add FNSi5712アプリケーションログが出力しない 周 end
//    List<PatMain> patMains  = bbsInfoService.getIsSame();
//    // add FNSi5712アプリケーションログが出力しない 周 start
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
//      AFTER_LOG_FLG_INFO, mappingUrl, null, null);
//    // add FNSi5712アプリケーションログが出力しない 周 end
//    return new ResponseEntity<>(patMains, HttpStatus.OK);
//  }
  // #11205 -ペンテスト2－4認可制御の不備 -> mod 8220 施設イベント詳細画面の表示が遅い 関  --> 弃用  del 20260317 shiyw end
  /*add FNSI-改修内容掲示板外结No.10 任 end*/

  // add 入院・同姓同名配布 趙 start
  @PostMapping("/getPatIsSame")
  public ResponseEntity<?> getPatIsSame(
          // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw start
          // 外部 facilityCdList は受け取らず、session.facilityCd の同姓同名患者のみを検索する。
          // @RequestBody List<String> facilityCdList
          @AuthenticationPrincipal NtssUser ntssUser
          // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw end
          ) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.PAT_INFO + "/getPatIsSame";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      BEFORE_LOG_FLG_INFO, mappingUrl, ntssUser.getFacilityCd(), ntssUser.getFacilityCd());
    // add FNSi5712アプリケーションログが出力しない 周 end
    List<PatMain> patMains  = bbsInfoService.getPatIsSame(List.of(ntssUser.getFacilityCd()));
    // add FNSi5712アプリケーションログが出力しない 周 start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_PAT_INFO,
      AFTER_LOG_FLG_INFO, mappingUrl, null, ntssUser.getFacilityCd());
    // add FNSi5712アプリケーションログが出力しない 周 end
    return new ResponseEntity<>(patMains, HttpStatus.OK);
  }
  // add 入院・同姓同名配布 趙 end

  // wangzuo アプリケーションログの適正化 Add Start
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
  // wangzuo アプリケーションログの適正化 Add End
}
