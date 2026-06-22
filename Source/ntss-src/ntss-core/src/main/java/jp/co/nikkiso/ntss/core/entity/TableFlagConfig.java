package jp.co.nikkiso.ntss.core.entity;
// add 10601 eventLog共通処理 gjn start
import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * すべてのテーブルフラグ設定クラス
 */
@Entity(listener = CommonEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "table_flag_config")
@Getter
@Setter
public class TableFlagConfig extends BaseBlankEntity {
  /**
   * テーブル物理名
   */
  private String tblName;

  /**
   * テーブル論理名
   */
  private String tblComment;

  /**
   * コラム物理名
   */
  private String colName;

  /**
   * コラム論理名
   */
  private String colComment;

  /**
   * JSONフラグ
   */
  private String jsonFlg;

  /**
   * フラグ値
   */
  private String flagValue;

  /**
   * フラグ値翻訳
   */
  private String flagComment;

  /**
   * 出力するかどうか
   */
  private String isOutput;

  /**
   * 更新日時.
   */
  private Timestamp createdAt;

}
// add 10601 eventLog共通処理 gjn end
