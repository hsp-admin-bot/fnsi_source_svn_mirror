package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;


/**
 * 入外区分・転入出情報更新用の情報取得用エンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatInOutUpdateInfo {
  /**
   * 患者ID.
   */
  private Long patId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 入外・転入出情報・管理番号.
   */
  private Integer ctlNo;

  /**
   * 入外・転入出情報・転入出区分.
   */
  private String moveInOut;

  /**
   * 入外・転入出情報・入外区分.
   */
  private String inOut;

  /**
   * 入外・転入出情報・開始日.
   */
  private String periodStart;

}
