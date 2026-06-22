package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 患者グループのEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatGroupCustom {
	/**
	 * 患者グループID
	 */
	// mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
//	private int patGroupCd;
	private String patGroupCd;
	// mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

	/**
	 * 患者グループ名
	 */
	private String patGroupName;

}
