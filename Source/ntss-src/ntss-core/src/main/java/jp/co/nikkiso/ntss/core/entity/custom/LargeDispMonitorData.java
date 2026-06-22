package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 治療状況リスト大画面表示：モニタデータ残り時間取得用Entity
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class LargeDispMonitorData {

  /**
   * オーダー番号
   */
  private Long ordNo;
  /**
   * 発生日時
   */
  private Timestamp occurDate;
  /**
   * 残り時間(除水完了)
   */
  private String remainUf;
  /**
   * 残り時間(透析完了)
   */
  private String remainDialysis;
  /**
   * 残り時間(補液完了)
   */
  private String remainFr;
  /**
   * 最高血圧
   */
  private String bpMax;
  /**
   * 最低血圧
   */
  private String bpMin;
  /**
   * 平均血圧
   */
  private String bpAve;
  /**
   * データ種別
   */
  private String dataType;

}