package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 指示コメント情報（指示コメント番号で集約）取得エンティティ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatTreatmentPatternIndIndCommentInfo {
  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * 治療曜日
   */
  private Short treatWeek;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 指示：治療方法コード
   */
  private Integer indTreatmentCd;

  /**
   * 指示：クールコード
   */
  private Integer indKurCd;

  /**
   * 指示：指示コメント情報
   */
  private String indIndCommentInfo;
}
