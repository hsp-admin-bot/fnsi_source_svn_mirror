package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 治療進捗状況更新用一覧取得エンティティ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForAcceptanceStatusInfo {

  /**
   * オーダー番号
   */
  private Long ordNo;
  /**
   * 患者ID
   */
  private Long patId;
  /**
   * 治療状態
   */
  private String rstDialysisState;
  /**
   * 治療開始日時
   */
  private Timestamp rstStartDate;
  /**
   * 治療時間[分]
   */
  private String treatmentTime;
}
