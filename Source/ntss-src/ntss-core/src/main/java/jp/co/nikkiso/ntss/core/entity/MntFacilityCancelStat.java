package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 施設解約の統計情報を表すエンティティクラス。
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE, immutable = true)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MntFacilityCancelStat extends BaseBlankEntity {
  // このエンティティは特定のテーブルには対応しない。
  // （RDBMSのシステム管理辞書から取得した情報を保持する。）

  /** データベース名 */
  @JsonProperty("db_name")
  private String dbName;

  /** データベース種別（DB4=1、DB5=2、DB6=3） */
  @JsonProperty("db_class")
  private int dbClass;

  /** テーブル名 */
  @JsonProperty("table_name")
  private String tableName;

  /** 施設コード別名のカラム名 */
  @JsonProperty("alias_column_name")
  private String aliasColumnName;

  /** 日時比較対象カラム名 */
  @JsonProperty("time_column_name")
  private String timeColumnName;
}
