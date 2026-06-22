package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;
import java.util.List;

import lombok.Data;

/**
 * 水質管理のRequest.
 */
@Data
public class WaterSurvey {
	/**
	 * 水質調査記録番号.
	 */
	private Long surveyRecordNo;

	/**
	 * 施設コード.
	 */
	private String facilityCd;

	/**
	 * 検査日.
	 */
	private Timestamp inspectionDate;

	/**
	 * 水質データ.
	 */
	private List<WaterSurveyData> surveyData;

	/**
	 * 表示フラグ.
	 */
	private String isDisp;

	/**
	 * 削除フラグ.
	 */
	private String isDel;
}
