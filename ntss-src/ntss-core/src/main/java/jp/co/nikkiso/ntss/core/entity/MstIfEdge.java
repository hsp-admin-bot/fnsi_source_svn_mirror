package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 連携エッジマスタEntity
 *
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_if_edge")
@Getter
@Setter
public class MstIfEdge extends BaseEntity {
  /** 製造番号 */
  @Id
  private String serialNo;
  /** 施設コード */
  private String facilityCd;
  /** IFエッジ番号 */
  private Integer ifEdgeNo;
  /** IFエッジ名 */
  private String ifEdgeName;
  /** 表示フラグ */
  private String isDisp;
  /** 削除フラグ */
  private String isDel;
  /** 設置日 */
  private Timestamp settingDate;
  /** 廃棄日 */
  private Timestamp deleteDate;
  /** メモ */
  private String memo;
}
