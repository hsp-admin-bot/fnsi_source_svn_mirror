package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class SalSubscriptionManageCustom {

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
	private String subscriptionFnc;
	/**
	 * 申込拡張機能
	 */
	private String subscriptionAdv;
	/**
	 * 申込ステータス
	 */
	private String subscriptionStatus;
	/**
	 * 申込者
	 */
	private Long applicant;

	/**
	 * 登録日時.
	 */
	private Timestamp regDate;

	/**
	 * 受付担当者
	 */
	private Long receptionist;
	/**
	 * 受付日時
	 */
	private Timestamp receptionDate;
	/**
	 * 完了担当者
	 */
	private Long completer;
	/**
	 * 完了日時
	 */
	private Timestamp completeDate;

	private Long canceller;

	private Timestamp cancelDate;
}
