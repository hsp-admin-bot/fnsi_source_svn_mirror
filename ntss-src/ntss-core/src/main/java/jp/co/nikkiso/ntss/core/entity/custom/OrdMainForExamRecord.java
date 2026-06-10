package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import lombok.Getter;
import lombok.Setter;
import java.sql.Timestamp;

/**
 * examRecord機能でのord_main一覧取得(過去5回分)
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
public class OrdMainForExamRecord {
  /**
   * システムで管理する一意なオーダ番号.
   */
  @Id
  private long ordNo;

  /**
   * 検査開始時刻(timestamp).
   */
  private Timestamp rstStartDate;

  /**
   * 検査開始時刻(string).
   */
  private String rstStartDateName;

  /**
   * 画面表示項目名
   */
  private String rstListName;

}
