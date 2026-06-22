package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * Patient Information for Materials Sharing Patient screen
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatientInfo {
	
	/** 患者ID */
	private Long patId;
	
	/** 患者名 */
	private String patName;

	/** 済 */
	private int already;

	/**  未 */
	private int notYet;	
	
	/** 患者IDソース */
	private Long pat_id_src;

	// add FNSI-NO423入院患者名の配布 江 start
	// 同姓同名フラグ
	private String is_same;

	// 入外区分
	private int in_out_class;
	// add FNSI-NO423入院患者名の配布 江 end

	/** 入院患者ID */
	private String hosp_pat_id;
	
	/**患者名フリガナ*/
	private String pat_last_name_kana;
	
	/**患者名フリガナ*/
	private String pat_first_name_kana;
}