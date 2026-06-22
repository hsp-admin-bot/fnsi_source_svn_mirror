
package jp.co.nikkiso.ntss.api.request;

import lombok.Data;

@Data
public class AdditionCalculationRequest {

	/**
	 * 施設コード
	 */
	private String facilityCd;

	/**
	 * 患者Id
	 */
	private Long patId;

	/**
	 * 治療番号
	 */
	private Long ordNo;

	/**
	 * イベントID
	 *
	 */
	private Integer eventId;
}
