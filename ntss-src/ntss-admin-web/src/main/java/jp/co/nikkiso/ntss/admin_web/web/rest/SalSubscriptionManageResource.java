package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URI;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import tools.jackson.core.JacksonException;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import tools.jackson.databind.ObjectMapper;
import tools.jackson.core.type.TypeReference;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.json.JSONObject;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import org.springframework.security.access.AccessDeniedException;

import jp.co.nikkiso.ntss.admin_web.MNoticeProperties;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.salSubscriptionManage.SalSubManSearchRequest;
import jp.co.nikkiso.ntss.admin_web.request.salSubscriptionManage.SalSubscriptionManageRequest;
import jp.co.nikkiso.ntss.admin_web.response.salSubscriptionManage.SalSubManResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.salSubscriptionManage.SalSubscriptionManageService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PaginationUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.SalSubscriptionManageDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.SalSubscriptionManage;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

/**
 * オプション申込のリソースクラス
 */
@RestController
@RequestMapping(Uri.SAL_SUBSCRIPTION_MANAGE)
public class SalSubscriptionManageResource {
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
  /**
   * ログ出力Service.
   */
  @Autowired
  LogService logService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

	/**
	 * オプション申込のService実装クラス.
	 */
	@Autowired
	private SalSubscriptionManageService salSubscriptionManageService;

	 /**
    * m-notice接続設定
    */
	 @Autowired
   private MNoticeProperties myPropaties;

	/**
    * 施設マスタのDao.
   */
	@Autowired
  MstFacilityDao mstFacilityDao;

	/**
   * システム設定のDaoインタフェース.
   */
	@Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  private SalSubscriptionManageDao salSubscriptionManageDao;

  /**
   * オンプレミスの管理番号
   */
  private final int CTL_NO_ON_PREMISE = 14;

	/**
	   * すべてのオプションアプリケーションを検索
	   * @param offset
	   * @param limit
	   * @return オプション申込
	*/
	@GetMapping("/getAll")
	public ResponseEntity<List<SalSubscriptionManage>> getAllSalSubManage(
			@RequestParam(value = "page", required = false) Integer offset,
			@RequestParam(value = "per_page", required = false) Integer limit) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SAL_SUBSCRIPTION_MANAGE + "/getAll";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End


		try {
			Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
			Page<SalSubscriptionManage> page = salSubscriptionManageService.findAll(pageable);
			HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.SAL_SUBSCRIPTION_MANAGE,
					offset, limit);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(offset, limit));
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
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
	   * 施設コードで探す
	   * @param offset
	   * @param facilityCd 施設コード
	   * @param limit
	   * @return オプション申込
	*/
	@GetMapping("/getSalSubscriptionManage/{facilityCd}")
	public ResponseEntity<List<SalSubscriptionManage>> getSalSubManageByFacilityCd(@PathVariable String facilityCd,
			@RequestParam(value = "page", required = false) Integer offset,
			@RequestParam(value = "per_page", required = false) Integer limit) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SAL_SUBSCRIPTION_MANAGE + "/getSalSubscriptionManage";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End

		try {
			Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
			Page<SalSubscriptionManage> page = salSubscriptionManageService.findByFacilityCd(pageable, facilityCd);
			HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page,
					Uri.SAL_SUBSCRIPTION_MANAGE + "/" + facilityCd, offset, limit);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(offset, limit));
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
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
	   * オプションアプリケーションの作成
	   * @param salReq オプション申請依頼
	   * @param ntssUser
	   * @return subscriptionNo 申込管理番号
	*/
	@PostMapping("")
	public ResponseEntity<Long> createSalSubscriptionManage(@RequestBody SalSubscriptionManageRequest salReq,
			@AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (salReq.getFacilityCd() != null && !salReq.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + salReq.getFacilityCd() + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
// #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (salReq.getFacilityCd() != null && !salReq.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
      }
    }
// #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SAL_SUBSCRIPTION_MANAGE ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

		try {
			long subscriptionNo = salSubscriptionManageService.createSalSubscriptionManage(salReq,
					ntssUser.getUserId());
			Map<String, String> SalSubMan = new HashMap<String, String>();
			SalSubMan.put("subscriptionNo", String.valueOf(subscriptionNo));

			MstFacility facility = mstFacilityDao.selectByCd(ntssUser.getFacilityCd());
			if(facility.getSalesEmailAddress() != null) {
				sendMail(SalSubMan);
			}

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

			return new ResponseEntity<>(subscriptionNo, HttpStatus.OK);
		}
		catch (AccessDeniedException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.FORBIDDEN);
		}
		catch (Exception e) {
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
	   * 受け入れられたオプション申請
	   * @param subscriptionNo 申込管理番号
	   * @param salReq オプション申請依頼
	   * @param ntssUser
	*/
	@PutMapping("/updateReception/{subscriptionNo}")
	public ResponseEntity<Void> updateReception(@PathVariable long subscriptionNo,
			@RequestBody SalSubscriptionManageRequest salReq, @AuthenticationPrincipal NtssUser ntssUser) {
    if (!hasSubscriptionAccess(ntssUser, subscriptionNo)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SAL_SUBSCRIPTION_MANAGE + "updateReception" ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

		try {
			salSubscriptionManageService.updateReceptionSalSubscriptionManage(subscriptionNo, salReq,
					ntssUser.getUserId());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (AccessDeniedException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end

      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.FORBIDDEN);
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
	   * オプションのアプリケーションを完了します
	   * @param subscriptionNo 申込管理番号
	   * @param salReq オプション申請依頼
	   * @param ntssUser
	*/
	@PutMapping("/updateCompletion/{subscriptionNo}")
	public ResponseEntity<Void> updateCompletion(@PathVariable long subscriptionNo,
			@RequestBody SalSubscriptionManageRequest salReq, @AuthenticationPrincipal NtssUser ntssUser) {
    if (!hasSubscriptionAccess(ntssUser, subscriptionNo)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SAL_SUBSCRIPTION_MANAGE + "updateCompletion" ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      subscriptionNo);
    // wp アプリケーションログの適正化 Add End

		try {
	        SalSubscriptionManage oldSal = salSubscriptionManageDao.selectBySubscriptionNo(subscriptionNo);
			salSubscriptionManageService.updateCompletionSalSubscriptionManage(subscriptionNo, salReq,
					ntssUser.getUserId());
			Map<String, String> SalSubMan = new HashMap<String, String>();
			SalSubMan.put("subscriptionNo", String.valueOf(subscriptionNo));

			MstFacility facility = mstFacilityDao.selectByCd(ntssUser.getFacilityCd());
			if(facility.getSalesEmailAddress() != null) {
				sendMail(SalSubMan);
			}

            // 完了後に通知実施
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");

            JSONObject replaceData = new JSONObject();
            replaceData.put("DATE", sdf.format(oldSal.getRegDate()));
            replaceData.put("FACILITYCD", ntssUser.getFacilityCd());

            webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.APPLICATION_COMPLETED, ntssUser.getFacilityCd(), replaceData);


      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.OK);
		}catch (AccessDeniedException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // wp アプリケーションログの適正化 Add Start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.FORBIDDEN);
		}
		catch (Exception e) {
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
	   * オプションのアプリケーションをキャンセルする
	   * @param subscriptionNo 申込管理番号
	   * @param salReq オプション申請依頼
	   * @param ntssUser
	*/
	@PutMapping("/updateCancel/{subscriptionNo}")
	public ResponseEntity<Void> updateCancel(@PathVariable long subscriptionNo,
			@RequestBody SalSubscriptionManageRequest salReq, @AuthenticationPrincipal NtssUser ntssUser) {
    if (!hasSubscriptionAccess(ntssUser, subscriptionNo)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SAL_SUBSCRIPTION_MANAGE + "updateCancel" ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      subscriptionNo);
    // wp アプリケーションログの適正化 Add End


		try {
			salSubscriptionManageService.updateCancelSalSubscriptionManage(subscriptionNo, salReq,
					ntssUser.getUserId());
			Map<String, String> SalSubMan = new HashMap<String, String>();
			SalSubMan.put("subscriptionNo", String.valueOf(subscriptionNo));

			MstFacility facility = mstFacilityDao.selectByCd(ntssUser.getFacilityCd());
			if(facility.getSalesEmailAddress() != null) {
				sendMail(SalSubMan);
			}

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        subscriptionNo);
      // wp アプリケーションログの適正化 Add End
			return new ResponseEntity<>(HttpStatus.OK);
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
	   * データ検索で探す
	   * @param request オプション申請依頼
	   * @param ntssUser ユーザー
	   * return オプションアプリケーション一覧
	*/
	@PostMapping("/getSalSubSearchResult")
	public ResponseEntity<List<SalSubManResponse>> getSalSubManByDataSearch(@RequestBody SalSubManSearchRequest request,
			@AuthenticationPrincipal NtssUser ntssUser,
      @RequestParam(value = "page", required = false) Integer offset,
      @RequestParam(value = "per_page", required = false) Integer limit) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.SAL_SUBSCRIPTION_MANAGE + "getSalSubSearchResult" ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      Arrays.asList(offset, limit));
    // wp アプリケーションログの適正化 Add End

		try {
      Pageable pageable = PaginationUtils.generatePageRequest(offset, limit);
      Page<SalSubManResponse> page = salSubscriptionManageService.findByDataSearch(request, ntssUser.getUserId(), pageable);
      HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, Uri.SAL_SUBSCRIPTION_MANAGE,
        offset, limit);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        Arrays.asList(offset, limit));
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
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
	 * メールを送る
	 * @param SalSubMan
	 * @return boolean
	 */
	private boolean sendMail(Map<String, String> SalSubMan) {
			HttpStatus status = HttpStatus.OK;
		 try {
       SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CTL_NO_ON_PREMISE);
       ObjectMapper objectMapper = new ObjectMapper();
       HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
       String onPremiseStatus = onPremise.get("ses");

       if (!onPremiseStatus.equals("on")) {
         return false;
       }

			URI uri = new URI(myPropaties.getMNotice().getUrl()+myPropaties.getMNotice().getMakerNotice() + "/salSubManage/sendMail");
			RestTemplate rt = new RestTemplate();
			RequestEntity<Map<String, String>> request = RequestEntity.post(uri).
					contentType(MediaType.APPLICATION_JSON)
					.header(myPropaties.getMNotice().getHeaderName(), myPropaties.getMNotice().getHeaderValue())
					.body(SalSubMan);
	   // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
       long start = System.currentTimeMillis();
			// リクエスト処理
		      ResponseEntity<String> response = rt.exchange(request, String.class);
		      status = HttpStatus.valueOf(response.getStatusCode().value());
       long cost = System.currentTimeMillis() - start;
       Map<String, Object> map = new HashMap<>();
       map.put("logType", "RESTTEMPLATE-LOG");
       map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.SalSubscriptionManageResource");
       map.put("methodName", "sendMail");
       map.put("method", request.getMethod());
       map.put("url", request.getUrl());
       map.put("headers", request.getHeaders().toSingleValueMap());
       map.put("requestParameter", request.getBody());
       map.put("status",response.getStatusCode());
       map.put("cost", cost);
       map.put("result",response.getBody());
       EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
       restTemplateEventLogMessage.setLogMessage(toJson(map));
       logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      if (HttpStatus.OK == status) {
        return true;
      }

		} catch (Exception e) {
       // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
       // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
       EventLogMessage eventLogMessage = new EventLogMessage();
       // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
       eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
       // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
       logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
	   // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
		}
		return false;
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

  private boolean hasFacilityAccess(NtssUser ntssUser, String facilityCd) {
    boolean hasAccess = ntssUser != null && (ntssUser.isNkkAdminUser() || facilityCd == null || facilityCd.equals(ntssUser.getFacilityCd()));
    // #11205 mod 20260421 start
    if (!hasAccess) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
    }
    // #11205 mod 20260421 end
    return hasAccess;
  }

  private boolean hasSubscriptionAccess(NtssUser ntssUser, long subscriptionNo) {
    if (ntssUser == null) {
      return false;
    }
    if (ntssUser.isNkkAdminUser()) {
      return true;
    }
    SalSubscriptionManage subscription = salSubscriptionManageDao.selectBySubscriptionNo(subscriptionNo);
    boolean hasAccess = subscription == null || subscription.getFacilityCd() == null
      || subscription.getFacilityCd().equals(ntssUser.getFacilityCd());
    // #11205 mod 20260421 start
    if (!hasAccess) {
      String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + (subscription != null ? subscription.getFacilityCd() : "null") + " " + "subscriptionNo=" + subscriptionNo + " ";
      InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
    }
    // #11205 mod 20260421 end
    return hasAccess;
  }

}
