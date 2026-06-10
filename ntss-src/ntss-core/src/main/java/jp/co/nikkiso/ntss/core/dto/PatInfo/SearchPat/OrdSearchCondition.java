package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import lombok.Data;

@Data
public class OrdSearchCondition {
	/**
	 * 指示受け・承認の検索 0：治療単位 1： 指示単位
	 */
	private Integer searchType = 0;

	/**
	 * チェック者1
	 */
	private Boolean checker1 = false;

	/**
	 * チェック者2
	 */
	private Boolean checker2 = false;

	/**
	 * 承認者1
	 */
	private Boolean approver1 = false;

	/**
	 * 承認者2
	 */
	private Boolean approver2 = false;

	/**
	 * 指示者
	 */
	private Integer instructorId;

	/**
	 * 治療単位 condition
	 */
	private OrdSearchTreatmentCondition ordSearchTreatmentCondition = null;

	/**
	 * 指示単位 condition
	 */
	private OrdSearchInstCondition ordSearchInstCondition = null;

	/**
	 * 施設コード
	 */
	private String facilityCd;
}
