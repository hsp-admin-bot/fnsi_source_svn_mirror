package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.patSearchDetail.MstPatSearchDetailService;
import jp.co.nikkiso.ntss.core.entity.MstPatSearchDetail;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
// #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
import jp.co.nikkiso.ntss.core.dao.MstPatSearchDetailDao;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
// #11205 -ペンテスト2－4認可制御の不備  add 20260420 end

@RestController
@RequestMapping(Uri.PAT_SEARCH_DETAIL)
public class MstPatSearchDetailResource {

  @Autowired
  MstPatSearchDetailService mstPatSearchDetailService;

  // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
  @Autowired
  MstPatSearchDetailDao mstPatSearchDetailDao;
  // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 検索.
   *
   * @param ntssUser NTSS認証ユーザー
   * @return
   */
  @GetMapping
  public ResponseEntity<?> get(@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_SEARCH_DETAIL ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(mstPatSearchDetailService.get(ntssUser), HttpStatus.OK);
  }

  /**
   * 追加.
   *
   * @param mstPatSearchDetail 詳細患者検索
   * @return 作成されるレコードの数
   */
  @PostMapping
  public ResponseEntity<?> create(@RequestBody MstPatSearchDetail mstPatSearchDetail, @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_SEARCH_DETAIL;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    mstPatSearchDetail.setFacilityCd(ntssUser.getFacilityCd());
    mstPatSearchDetail.setUserId(ntssUser.getUserId());

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(mstPatSearchDetailService.create(mstPatSearchDetail), HttpStatus.OK);
  }

  /**
   * 更新.
   *
   * @param mstPatSearchDetail 詳細患者検索
   * @return 作成されるレコードの数
   */
  @PutMapping
  public ResponseEntity<?> update(@RequestBody MstPatSearchDetail mstPatSearchDetail, @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_SEARCH_DETAIL ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    mstPatSearchDetail.setFacilityCd(ntssUser.getFacilityCd());
    mstPatSearchDetail.setUserId(ntssUser.getUserId());


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(mstPatSearchDetailService.update(mstPatSearchDetail), HttpStatus.OK);
  }

  /**
   * 削除.
   *
   * @param searchCd 詳細患者検索コード
   * @return 作成されるレコードの数
   */
  @PutMapping("/{searchCd}")
  public ResponseEntity<?> delete(@PathVariable Long searchCd,
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
    @AuthenticationPrincipal NtssUser ntssUser
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
    if (!ntssUser.isNkkAdminUser()) {
      MstPatSearchDetail target = mstPatSearchDetailDao.selectBySearchCd(searchCd);
      if (target != null && target.getFacilityCd() != null &&
          !target.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " searchCd=" + searchCd + " facilityCd=" + target.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.PAT_SEARCH_DETAIL ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      searchCd);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      searchCd);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(mstPatSearchDetailService.delete(searchCd), HttpStatus.OK);
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
