package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import lombok.Getter;
import lombok.Setter;

/**
 * 患者リスト用治療情報取得エンティティ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForPatList extends BaseEntity {

  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;
  
  /**
   * 治療日
   */
  private String treatDate;

  /**
   * 実績：治療状況
   */
  private String rstDialysisState;
  
  /**
   * 実績：治療開始日時
   */
  private Timestamp rstStartDate;
  
  /**
   * 実績：治療終了日時
   */
  private Timestamp rstEndDate;
  
  /**
   * 実績：治療条件情報_治療時間
   */
  private String treatTime;
  
  /**
   * 実績：回診記録情報
   */
  private String rstRoundsInfo;

  /**
   * 回診状態強調表示
   */
  private String roundHighlighting;
  
  /**
   * 指示：クール開始時刻
   */
  private String indKurStartTime;
  
  /**
   * 実績：クール開始時刻
   */
  private String rstKurStartTime;
  
  /**
   * 指示：ベッドマスタ表示順
   */
  private Long indBedOrderIndex;
  
  /**
   * 実績：ベッドマスタ表示順
   */
  private Long rstBedOrderIndex;
}
