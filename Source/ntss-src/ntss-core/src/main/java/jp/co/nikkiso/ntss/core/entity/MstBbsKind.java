package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstBbsKindEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 掲示板種別情報クラス
 */
@Entity(listener = MstBbsKindEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_bbs_kind")
@Getter
@Setter
public class MstBbsKind extends BaseBlankEntity {
  /**
   * 管理番号
   */
  @Id
  private Integer kindNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 種別名
   */
  private String kindName;

  /**
   * デフォルトタイトル
   */
  private String defaultTitle;

  /**
   * デフォルト内容
   */
  private String defaultContents;

  /**
   * FNW+で管理する施設内の一意なクールコード
   */
  private String fnCategoryId;

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
}
