package jp.co.nikkiso.ntss.admin_web.response.salSubscriptionManage;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.sysFunction.SysFunctionResponse;
import lombok.Data;

@Data
public class SalSubManResponse {

	/**
	 * 申込管理番号
	 */
	private Long subscriptionNo;
	/**
	 * 施設コード
	 */
	private String facilityCd;

	/**
	 * 施設名.
	 */
	private String facilityName;

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
	private List<SysFunctionResponse> sysFunctionList;

	/**
	 * 申込ステータス
	 */
	private String subscriptionStatus;
	/**
	 * 申込者
	 */
	private Long applicant;
	/**
	 * 申込者名
	 */
	private String applicantName;

	/**
	 * 登録日時.
	 */
	private Timestamp regDate;

	/**
	 * 受付担当者
	 */
	private Long receptionist;
	/**
	 * 受付担当者名
	 */
	private String receptionistName;
	/**
	 * 受付日時
	 */
	private Timestamp receptionDate;
	/**
	 * 完了担当者
	 */
	private Long completer;
	/**
	 * 完了担当者名
	 */
	private String completerName;
	/**
	 * 完了日時
	 */
	private Timestamp completeDate;

	private Long canceller;

	private String cancellerName;

	private Timestamp cancelDate;
}
