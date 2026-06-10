package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;

import lombok.Data;

@Data
public class OrdSearchTreatmentCondition {
	/**
	 * 治療日
	 */
	private String treatDate = "19700101";

	/**
	 * 指示：治療方法コード
	 */
	private Long treatmentCode;

	/**
	 * 指示：クールコード
	 */
	private List<Long> kurCode;

	/**
	 * 透析室・ベッドグループコード
	 */
	private Long bedGroup;
}
