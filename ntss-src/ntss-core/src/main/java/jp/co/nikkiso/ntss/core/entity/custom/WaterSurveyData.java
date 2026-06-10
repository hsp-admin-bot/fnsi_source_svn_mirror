package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Data;

/**
 * 水質データ.
 */
@Data
public class WaterSurveyData {
	/**
	 * ポイントCD
	 */
	private Long point_cd;

	/**
	 * 予定有無.
	 */
	private String plan;

	/**
	 * 採取時刻.
	 */
	private String time;

	/**
	 * 採取者.
	 */
	private Long picker;

	/**
	 * 検査者.
	 */
	private Long inspector;

	/**
	 * 結果値.
	 */
	private String value;

	/**
	 * 結果文字列番号.
	 */
	private String text;
  // add FNSI-水質検査結果登録で備考欄を追加する 周 start
	/**
	 * 備考.
	 */
	private String memo;
  // add FNSI-水質検査結果登録で備考欄を追加する 周 end

  /**
   * 単位.
   */
  private String unit;

}
