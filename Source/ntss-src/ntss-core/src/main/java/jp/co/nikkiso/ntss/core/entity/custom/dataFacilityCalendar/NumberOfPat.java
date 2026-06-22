package jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 患者数
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class NumberOfPat {

	/**
	 * 
	 * 日付
	 */
	private String date;
	
	
	/**
	 * 
	 * 患者数
	 */
	private Integer numberOfPat;

    /* add by chamaojia 2023-11-07 [9717] 新規クエリ結果に対応するプロパティ  --start */
    /**
     * ビジネス番号
     */
    private Long busNo;

    /**
     * 転入転出コードを移動する
     */
    private String moveInOutCd;
    /* add by chamaojia 2023-11-07 [9717] 新規クエリ結果に対応するプロパティ  --end */
}
