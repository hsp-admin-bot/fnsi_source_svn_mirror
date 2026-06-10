package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 患者名の識別Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_name_identification")
@Getter
@Setter
public class PatNameIdentification extends BaseEntity {

	/**
	 * 患者名ID
	 */
	private Long patNameId;

	/**
	 * 患者IDソース
	 */
	private Long patIdSrc;

	/**
	 * 施設IDソース
	 */
	private String facilityCdSrc;

	/**
	 * 患者IDの宛先
	 */
	private Long patIdDst;

	/**
	 * 施設コード宛先
	 */
	private String facilityCdDst;

	/**
	 * 承認
	 */
	private String approve;

	/**
	 * 受理
	 */
	private String receive;

	/**
	 * 開示状況
	 */
	private String isOpen;

	/**
	 * 担当医
	 */
	private String doctorInCharge;

	/**
	 * 承認日
	 */
	private Timestamp approveDate;
	
	/**
	 * 登録
	 */
	private String signUp;
}
