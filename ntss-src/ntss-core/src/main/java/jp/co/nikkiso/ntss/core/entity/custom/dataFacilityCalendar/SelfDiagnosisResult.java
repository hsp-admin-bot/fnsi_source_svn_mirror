package jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 *
 * 自己診断結果
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class SelfDiagnosisResult {

	/**
	 *
	 * 登録日時
	 */
	private String regDate;

	/**
	 *
	 * 数
	 */
	private String resultCount;

	/**
	 *
	 * 未実施数
	 */
	private String notDoneCount;

	/**
	 *
	 * 装置記録コード
	 */
	private String machineRecordCd;

}
