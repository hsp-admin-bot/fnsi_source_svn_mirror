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
 * 水質管理のEntity.
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_water_survey")
@Getter
@Setter
public class MntWaterSurvey extends BaseEntity {
	/**
	 * 水質調査記録番号.
	 */
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long surveyRecordNo;

	/**
	 * 施設コード.
	 */
	private String facilityCd;

	/**
	 * 検査日.
	 */
	private Timestamp inspectionDate;

	/**
	 * 水質データ.
	 */
	private String surveyData;

	/**
	 * 表示フラグ.
	 */
	private String isDisp;

	/**
	 * 削除フラグ.
	 */
	private String isDel;

}
