package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * プリンターマスターのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstPrinter extends BaseEntity {

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 印刷サーバーアプリ識別子.
   */
  private String clientKey;

  /**
   * プリンタ名.
   */
  private String printerName;

  /**
   * 表示プリンタ名(例. "EPSON LP-S950 1階").
   */
  private String dispPrinterName;

}
