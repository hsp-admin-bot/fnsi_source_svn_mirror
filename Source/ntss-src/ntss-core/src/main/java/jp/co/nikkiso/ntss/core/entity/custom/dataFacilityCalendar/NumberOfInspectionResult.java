package jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Date;

/**
 * 検査結果の数
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class NumberOfInspectionResult {

	/**
	 * 点検日
	 */

	private String mainteDate;

	/**
	 * 結果入力パターン
	 */
	private String mainteAns;

  // add FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
	/**
	 * レイアウト名
	 */
	private String layoutName;

	/**
	 * 日付
	 */
	private Date upDate;
  // add FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end

	/**
	 * 結果入力パターンの数
	 */
	private Integer numberOfMainteAns;

	private Integer machineNo;
}
