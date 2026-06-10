package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatNameId {

	/**
	 * 患者ID
	 */
	private Long pat_id;

	/**
	 * 患者氏名(漢字名)
	 */
	private String pat_first_name;

	/**
	 * 患者氏名(漢字姓)
	 */
	private String pat_last_name;

	/**
	 * 患者氏名(カタカナ名)
	 */
	private String pat_first_name_kana;

	/**
	 * 患者氏名(カタカナ姓)
	 */
	private String pat_last_name_kana;

	/**
	 * 院内表示用の患者ID
	 */
	private String hosp_pat_id;
}
