package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;
import lombok.Data;

@Data
public class OrdSearchInstCondition {

	/**
	 * 治療日(開始日)
	 */
	private String treatStartDate;

	/**
	 * 治療日(終了日)
	 */
	private String treatEndDate;

	/**
	 * 指示：治療開始時刻
	 */
	private String treatStartTime;

}
