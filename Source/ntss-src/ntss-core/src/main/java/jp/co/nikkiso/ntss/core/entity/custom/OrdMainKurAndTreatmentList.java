package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 透析情報（クール＆治療方法）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainKurAndTreatmentList {
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * 指示：クールコード
   */
  private Long indKurCd;

  /**
   * 指示：クール名
   */
  private String indKurName;

  /**
   * 指示：治療方法コード
   */
  private Integer indTreatmentCd;

  /**
   * 指示：治療方法名
   */
  private String indTreatmentName;
}
