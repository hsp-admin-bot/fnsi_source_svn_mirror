package jp.co.nikkiso.ntss.admin_web.request.salSubscriptionManage;

import java.util.List;

import lombok.Data;

/**
 * オプション申請依頼
 */
@Data
public class SalSubManSearchRequest {

	/**
	 * 開始日
	 */
	private String startDate;
	
	/**
	 * 終了日
	 */
	private String endDate;
	
	/**
	 * 都道府県コード.
	 */
	private String prefecturesCd;

	/**
	 * 部署符号.
	 */
	private String departmentCd;

	/**
	 * フリーワード
	 */
	private String freeWord;

	/**
	 * 申請状況一覧
	 */
	private List<String> subscriptionStatusList;
}
