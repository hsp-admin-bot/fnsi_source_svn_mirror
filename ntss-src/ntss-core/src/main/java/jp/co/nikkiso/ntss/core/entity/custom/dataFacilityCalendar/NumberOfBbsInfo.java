package jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 施設イベントカテゴリ分繰り返す
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class NumberOfBbsInfo {

	/**
	 * 管理番号
	 */
	private String kindNo;

	/**
	 * 種別名
	 */
	private String kindName;

	/**
	 * 開始日
	 */
	private String startDate;

	/**
	 * 終了日
	 */
	private String endDate;

	/**
	 * 掲示板の数
	 */
	private Integer numberOfBbs;
}
