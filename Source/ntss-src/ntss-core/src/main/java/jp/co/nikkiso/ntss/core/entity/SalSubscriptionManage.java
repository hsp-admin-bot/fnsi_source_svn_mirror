package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * オプション申込
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sal_subscription_manage")
@Getter
@Setter
public class SalSubscriptionManage extends BaseEntity {

	/**
	 * 申込管理番号
	 */
	@Id
	private Long subscriptionNo;
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
	/**
	 * 申込者
	 */
	private Long applicant;
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
	/**
	 * 表示フラグ
	 */
	private String isDisp;
	/**
	 * 削除フラグ
	 */
	private String isDel;

	private Long canceller;

	private Timestamp cancelDate;
}
