package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * プラン定義テーブル
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_subscription_plan")
@Getter
@Setter
public class SysSubscriptionPlan extends BaseEntity {

	/**
	 * 申込プラン番号
	 */
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long subscriptionPlanNo;
	/**
	 * 申込プラン名
	 */
	private String subscriptionPlanName;
	/**
	 * 申込プラン機能
	 */
	private String subscriptionPlanFnc;
	/**
	 * 申込プラン拡張機能
	 */
	private String subscriptionPlanAdv;
	/**
	 * 表示順
	 */
	private Integer dispOrder;
	/**
	 * 表示設定
	 */
	private String isDisp;
	/**
	 * 削除フラグ
	 */
	private String isDel;
}
