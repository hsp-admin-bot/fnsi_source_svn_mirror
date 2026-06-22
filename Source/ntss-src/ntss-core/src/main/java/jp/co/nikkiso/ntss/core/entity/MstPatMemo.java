package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstPatMemoEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 患者メモクラス
 */
@Entity(listener = MstPatMemoEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_pat_memo")
@Getter
@Setter
public class MstPatMemo extends BaseBlankEntity {
  /**
   * 施設コード
   */
  @Id
  private String facilityCd;
  /**
   * 患者メモ番号
   */
  @Id
  private Short patMemoNo;
  /**
   * タイトル
   */
  private String title;
  /**
   * 内容
   */
  private String content;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
}
