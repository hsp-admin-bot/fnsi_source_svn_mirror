package jp.co.nikkiso.ntss.core.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
* 水質検査種別マスタのEntity.
*/
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_water_survey_type")
@Getter
@Setter
public class MstWaterSurveyType extends BaseBlankEntity {
	/**
   * 水質検査種別コード.
   */
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long surveyTypeCd;

	/**
   * 水質検査種別名.
   */
	private String surveyTypeName;

	/**
   * 施設コード.
   */
	private String facilityCd;

	/**
   * 整数部桁数.
   */
	private Integer integerDigits;

	/**
   * 小数部桁数.
   */
	private Integer decimalDigits;

	/**
   * 単位.
   */
	private String unit;

	/**
   * 結果初期値.
   */
	private String initialValue;

	/**
   * しきい値判断上下区分.
   */
	private String initialString;

	/**
   * 閾値上限.
   */
	private BigDecimal upperThreshold;

	/**
   * 閾値下限.
   */
	private BigDecimal lowerThreshold;

	/**
   * グラフ上限.
   */
	private BigDecimal graphUpperLimit;

	/**
   * グラフ下限.
   */
	private BigDecimal graphLowerLimit;

	/**
   * 表示フラグ.
   */
	private String isDisp;

	/**
   * 削除フラグ.
   */
	private String isDel;

	/**
   * 登録日.
   */
	private Timestamp regDate;

	/**
   * 更新日.
   */
	private Timestamp upDate;

}
