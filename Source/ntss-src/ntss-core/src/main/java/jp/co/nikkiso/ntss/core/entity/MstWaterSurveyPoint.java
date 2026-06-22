package jp.co.nikkiso.ntss.core.entity;

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
 * 水質検査箇所マスタのEntity.
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_water_survey_point")
@Getter
@Setter
public class MstWaterSurveyPoint extends BaseBlankEntity {
	/**
	 * 調査箇所コード.
	 */
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long surveyPointCd;

	/**
	 * 水質検査箇所名.
	 */
	private String pointName;

	/**
	 * 施設コード.
	 */
	private String facilityCd;

	/**
	 * 装置番号.
	 */
	private Long machineNo;

	/**
	   * 水質調査種別.
	   */
	private Long surveyTypeCd;

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
