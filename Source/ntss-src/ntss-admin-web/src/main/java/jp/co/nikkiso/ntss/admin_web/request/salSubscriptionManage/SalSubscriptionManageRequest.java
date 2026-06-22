package jp.co.nikkiso.ntss.admin_web.request.salSubscriptionManage;

import lombok.Data;

@Data
public class SalSubscriptionManageRequest {
	/**
	 * 施設コード
	 */
	private String facilityCd;
	/**
	 * 初回申込フラグ
	 */
	private String isFirst;
	/**
	 * 初回申込プラン名
	 */
	private String subscriptionPlanName;
	/**
	 * 申込機能
	 */
	private String subscriptionFnc;
	/**
	 * 申込拡張機能
	 */
	private String subscriptionAdv;
	/**
	 * 申込ステータス
	 */
	private String subscriptionStatus;
}
