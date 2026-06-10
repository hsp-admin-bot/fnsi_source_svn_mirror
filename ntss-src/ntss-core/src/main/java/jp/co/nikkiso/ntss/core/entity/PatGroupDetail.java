package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 患者グループ詳細のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_group_detail")
@Getter
@Setter
public class PatGroupDetail extends BaseEntity{

	/**
	 * 患者グループID
	 */
	private Long patGroupCd;

	/**
	 * 患者ID
	 */
	private Long patId;

	/**
	 * 患者FirstName
	 */
	private String patFirstName;

	/**
	 * 患者LastName
	 */
	private String patLastName;

	/**
	 * 患者HospID
	 */
	private String patHospId;

    /**
     * 施設コード
     */
    private String facilityCd;
  /*add FNSI-改修内容入外区分が入院の場合、患者名は紫色にする 任 start*/
    private Integer inOutClass;
  /*add FNSI-改修内容入外区分が入院の場合、患者名は紫色にする 任 end*/
}
