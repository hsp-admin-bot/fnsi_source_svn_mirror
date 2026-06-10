package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Setter
@Getter
public class HolidayDetail {

	/**
	 * 日
	 */
	private String date;

	/**
	 * 名
	 */
	private String name;

	/**
	 * 区分
	 */
	private String holidayClass;
	
	/**
	 * NKK
	 */
	private boolean isNkk;

}
