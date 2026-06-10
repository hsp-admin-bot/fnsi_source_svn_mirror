package jp.co.nikkiso.ntss.core.entity;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 患者グループのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_group")
@Getter
@Setter
public class PatGroup extends BaseEntity{

	/**
	 * 患者グループID
	 */
	@Id
	private Long patGroupCd;

	/**
	 * 施設コード
	 */
	private String facilityCd;

	/**
	 * 患者グループ名
	 */
	private String patGroupName;

	/**
	 * 表示フラグ. 0 : 非表示、1 : 仮表示
	 */
	private String isDisp;

	/**
	 * 削除フラグ. 0 : 通常、1 : 削除
	 */
	private String isDel;

	/**
	 * 院内コード1
	 */
	private String inHospitalCd_1;
}
