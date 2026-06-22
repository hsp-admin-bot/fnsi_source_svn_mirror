package jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * クール別治療件数
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class NumberTreatmentsByCourse {
	/**
	 * クールコード
	 */
	private Long kurCd;

	/**
	 * クール名
	 */
	private String kurName;

	/**
	 * 
	 * 治療日
	 */
	private String treatDate;

	/**
	 * 
	 * 実績数：クール
	 */
	private Integer rstKurCount;

	/**
	 * 
	 * 指示の数：クール
	 */
	private Integer indKurCount;
	
	
}
