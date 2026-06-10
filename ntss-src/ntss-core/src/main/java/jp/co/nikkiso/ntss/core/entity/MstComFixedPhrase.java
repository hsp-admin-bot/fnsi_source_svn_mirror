package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstComFixedPhraseEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 共通定型文クラス
 */
@Entity(listener = MstComFixedPhraseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_com_fixed_phrase")
@Getter
@Setter
public class MstComFixedPhrase extends BaseBlankEntity {
  /**
   * 共通定型文コード
   */
  @Id
  private Integer comFixedPhraseCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 定型文
   */
  private String comFixedPhrase;
  /**
   * 職種
   */
  private String occupations;
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
