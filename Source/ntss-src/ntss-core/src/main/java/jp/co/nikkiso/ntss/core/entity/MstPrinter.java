package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * プリンターマスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_printer")
@Getter
@Setter
@EqualsAndHashCode(callSuper = false)
public class MstPrinter extends BaseEntity {
  /**
   * プリンターコード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long printerCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * クライアント識別子.
   */
  private String clientKey;

  /**
   * プリンタ名.
   */
  private String printerName;

  /**
   * 表示プリンタ名.
   */
  private String dispPrinterName;

  /**
   * 表示フラグ.
   * <p>
   * ('0': 非表示、'1': 表示)
   * </p>
   */
  private String isDisp;

  /**
   * 削除フラグ.
   * <p>
   * ('0': 通常、'1': 削除)
   * </p>
   */
  private String isDel;
}
