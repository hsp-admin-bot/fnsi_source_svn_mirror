package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 *
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_holiday")
@Getter
@Setter
public class MstHoliday extends BaseBlankEntity {
	@Id
	private Long holidayCd;

	/**
	 * 施設コード
	 */
	private String facilityCd;

	/**
	 * 対象年
	 */
	private Integer holidayY;

	/**
	 *
	 */
	private String holidayJson;

	/**
	 * 表示フラグ
	 */
	private String isDisp;

	/**
	 * 削除フラグ
	 */
	private String isDel;

	/**
	 * 設置日
	 */
	private Timestamp regDate;

	/**
	 * 廃棄日
	 */
	private Timestamp upDate;

}
