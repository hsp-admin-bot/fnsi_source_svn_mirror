package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 機能帳票マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_function_report")
@Getter
@Setter
public class MstFunctionReport extends BaseEntity {

  /**
   * 機能帳票コード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer functionReportCd;

  /**
   * 機能コード.
   */
  private String functionCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * レポートCD.
   */
  private Long reportCd;

  /**
   * 表示フラグ.
   */
  private String isDisp;

  /**
   * 削除フラグ.
   */
  private String isDel;

}
