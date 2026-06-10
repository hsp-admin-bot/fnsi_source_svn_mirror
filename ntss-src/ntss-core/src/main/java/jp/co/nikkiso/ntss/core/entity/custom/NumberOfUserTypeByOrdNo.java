package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 患者数
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class NumberOfUserTypeByOrdNo {

	/**
	 *
	 *オーダー番号
	 */
	private Long ordNo;


	/**
	 *
	 * 利用種別数
	 */
	private Long count;
}
