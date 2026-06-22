package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstPatViewerLayoutEntityListener;
import lombok.Getter;
import lombok.Setter;


/**
 * mst_pat_viewer_layout(患者経過総合ビューアレイアウトマスタ)のエンティティクラス
 */
@Entity(listener = MstPatViewerLayoutEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_pat_viewer_layout")
@Getter
@Setter
public class MstPatViewerLayout extends BaseBlankEntity {

  /**
   * レイアウトコード
   */
  private Long layoutCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * レイアウト名
   */
  private String layoutName;

  /**
   * 表示項目
   */
  private String dispItemInfo;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * 表示期間区分
   */
  private String dispPeriodClass;
}
