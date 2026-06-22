package jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * アイテム施設カレンダー
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ItemFacilityCalendar {

	/**
	 * 治療日
	 */
	private String date;

	/**
	 *
	 * 達成数：治療方法
	 */
	private Integer rstCount;
	/**
	 *
	 * 指示の数：治療方法
	 */
	private Integer indCount;

    /* add by chamaojia 2023-11-07 [9717] 新規クエリ結果に対応するプロパティ  --start */
    /**
     * 装置モード
     */
    private Integer deviceMode;
    /* add by chamaojia 2023-11-07 [9717] 新規クエリ結果に対応するプロパティ  --end */
}
