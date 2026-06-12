package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.PatIndApproveHistoryService;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dto.PatIndApproveHistory.PatIndApproveHistoryDTO;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApproveHistory;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

import jp.co.nikkiso.ntss.admin_web.response.indications.PatIndApproveHistoryResponse;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@RestController
@RequestMapping(Uri.PAT_IND_APPROVE_HISTORY)
public class PatIndApproveHistoryResource {

  @Autowired
  PatIndApproveHistoryService patIndApproveHistoryService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  // #11205 add 20260421 start
  @Autowired
  OrdMainDao ordMainDao;
  // #11205 add 20260421 end

  /**
   * 指示受け・承認詳細作成
   * @param patIndApproveHistoryDTO 指示受け・承認詳細
   * @return
   */
  @PostMapping("")
  public ResponseEntity<Void> createPathIndApproveHistory(
    @RequestBody PatIndApproveHistoryDTO patIndApproveHistoryDTO,
    // #11205 add 20260421 start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 add 20260421 end
  ) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_IND_APPROVE_HISTORY ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    if (patIndApproveHistoryDTO.getOrdNo() == null
      || patIndApproveHistoryDTO.getOrdNo().size() == 0
      || patIndApproveHistoryDTO.getApproveKind() == null
      || patIndApproveHistoryDTO.getApproveKind().size() == 0) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.NOT_MODIFIED);
    }

    // #11205 add 20260421 start
    if (ntssUser != null && !ntssUser.isNkkAdminUser()
            && patIndApproveHistoryDTO.getOrdNo() != null) {
      for (Long ordNo : patIndApproveHistoryDTO.getOrdNo()) {
        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
        if (ordMain != null && ordMain.getFacilityCd() != null
                && !ordMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
          String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "ordNo=" + ordNo + " " + "ordMain.getFacilityCd()=" + ordMain.getFacilityCd();
          InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
          return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
      }
    }
    // #11205 add 20260421 end
    int count = patIndApproveHistoryService.createHistory(patIndApproveHistoryDTO);
    if (count > 0) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<Void>(HttpStatus.CREATED);
    }

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(HttpStatus.NOT_MODIFIED);
  }

  /**
   * オーダ番号により指示受け・承認詳細取得
   * @param ordNo オーダ番号
   * @param page ページネーション
   * @param size ページネーション
   * @param kind 指示受け承認区分
   * @param sort でソート
   * @return 指示受け・承認詳細のリスト
   */
  //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx start
  @GetMapping("")
  public ResponseEntity<PatIndApproveHistoryResponse> findByOrdNo(
    @RequestParam(name = "ordNo", required = true) Long ordNo,
    @RequestParam(name = "page", required = false, defaultValue = "1") Long page,
    @RequestParam(name = "size", required = false, defaultValue = "5") Long size,
    @RequestParam(name = "kind", required = true) String kind,
    // #11205 add 20260421 start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 add 20260421 end
  ) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_IND_APPROVE_HISTORY ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(ordNo, page, size, kind));
    // wp アプリケーションログの適正化 Add End

    // #11205 add 20260421 start
    if (ntssUser != null && !ntssUser.isNkkAdminUser()) {
      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
      if (ordMain != null && ordMain.getFacilityCd() != null
          && !ordMain.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "ordNo=" + ordNo + " " + "ordMain.getFacilityCd()=" + ordMain.getFacilityCd();
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 add 20260421 end

    PatIndApproveHistoryResponse patIndHistoryRes= new PatIndApproveHistoryResponse();
    List<PatIndApproveHistory> results = patIndApproveHistoryService.findPatIndApproveHistoryByOrdNo(ordNo, page, size, kind);
    Long totalElements = patIndApproveHistoryService.findTotalElements(ordNo, kind);
    Long totalPages = totalElements/size;
    if (totalElements % size != 0) {
      totalPages++;
    }
    patIndHistoryRes.setResult(results);
    patIndHistoryRes.setTotalPages(totalPages);
    patIndHistoryRes.setTotalElements(totalElements);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(ordNo, page, size, kind));
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(patIndHistoryRes, HttpStatus.OK);
  }
  //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx end

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
