package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_pat_event_data_template")
@Getter
@Setter
public class MstPatEventDataTemplate extends BaseEntity{
	  /**
	   * テンプレートコード
	   */
	  @Id
	  @GeneratedValue(strategy = GenerationType.IDENTITY)
	  private Long templateCd;

	  /**
	   * 施設コード
	   */
	  private String facilityCd;

	  /**
	   * テンプレート名
	   */
	  private String templateName;

	  /**
	   * 項目情報
	   */
	  private String inputParams;

	  /**
	   * 表示フラグ
	   */
	  private String isDisp;

	  /**
	   * 削除フラグ
	   */
	  private String isDel;

}
