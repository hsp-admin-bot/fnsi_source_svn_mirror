package jp.co.nikkiso.ntss.admin_web.service.salSubscriptionManage;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import jp.co.nikkiso.ntss.admin_web.request.salSubscriptionManage.SalSubManSearchRequest;
import jp.co.nikkiso.ntss.admin_web.request.salSubscriptionManage.SalSubscriptionManageRequest;
import jp.co.nikkiso.ntss.admin_web.response.salSubscriptionManage.SalSubManResponse;
import jp.co.nikkiso.ntss.core.entity.SalSubscriptionManage;

/**
 * オプション申込のServiceインタフェース.
 */
public interface SalSubscriptionManageService {

	/**
	   * すべてのオプションアプリケーションを検索
	   * @param pageable
	   * @return オプションアプリケーション一覧のResponse
	*/
	Page<SalSubscriptionManage> findAll(Pageable pageable);

	/**
	   * 施設コードで探す
	   * @param pageable
	   * @param facilityCd 施設コード
	   * @return オプションアプリケーション一覧のResponse
	*/
	Page<SalSubscriptionManage> findByFacilityCd(Pageable pageable, String facilityCd);

	/**
	   * オプションアプリケーションの作成
	   * @param salReq オプション申請依頼
	   * @param userId ユーザー
	   * @return subscriptionNo 申込管理番号
	*/
	long createSalSubscriptionManage(SalSubscriptionManageRequest salReq, Long userId) throws Exception;

	/**
	   * 受け入れたオプション申込を更新
	   * @param subscriptionNo 申込管理番号
	   * @param salReq オプション申込依頼
	   * @param userId ユーザー
	*/
	void updateReceptionSalSubscriptionManage(Long subscriptionNo, SalSubscriptionManageRequest salReq, Long userId) throws Exception;

	/**
	   * オプションのアプリケーションを完了します
	   * @param subscriptionNo 申込管理番号
	   * @param salReq オプション申請依頼
	   * @param userId ユーザー
	*/
	void updateCompletionSalSubscriptionManage(Long subscriptionNo, SalSubscriptionManageRequest salReq, Long userId) throws Exception;

	/**
	   * オプションのアプリケーションをキャンセルする
	   * @param subscriptionNo 申込管理番号
	   * @param salReq オプション申請依頼
	   * @param userId ユーザー
	*/
	void updateCancelSalSubscriptionManage(Long subscriptionNo,  SalSubscriptionManageRequest salReq, Long userId) throws Exception;

	/**
	   * データ検索で探す
	   * @param request オプション申請依頼
	   * @param userId ユーザー
	   * @return オプションアプリケーション一覧のResponse
	*/
	Page<SalSubManResponse> findByDataSearch(SalSubManSearchRequest request, Long userId, Pageable pageable);
}
