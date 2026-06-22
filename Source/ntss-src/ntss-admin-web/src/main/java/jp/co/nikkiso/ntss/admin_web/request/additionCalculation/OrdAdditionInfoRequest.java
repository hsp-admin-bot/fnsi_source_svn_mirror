
package jp.co.nikkiso.ntss.admin_web.request.additionCalculation;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.OrdMainAdditionInfo;
import lombok.Data;

@Data
public class OrdAdditionInfoRequest {

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
	 * 
	 */
	private List<OrdMainAdditionInfo> additionInfo;

}
