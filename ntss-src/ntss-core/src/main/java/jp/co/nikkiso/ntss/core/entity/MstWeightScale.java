package jp.co.nikkiso.ntss.core.entity;

import java.math.BigDecimal;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 体重測定設定マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_weight_scale")
@Getter
@Setter
public class MstWeightScale extends BaseEntity {

  /**
   * 体重測定設定管理コード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer weightScaleCd;
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * ICカード種別
   */
  private Integer icCard;
  /**
   * 患者バーコード有効桁
   */
  private Short patIdDigit;
  /**
   * 測定初期画面
   */
  private Integer defaultScreenClass;

  /**
   * 検査結果有効期間
   */
  private Short examPeriod;
  /**
   * 車いす校正有効日数
   */
  private Short wheelChairPeriod;
  /**
   * 風袋初期単位
   */
  private Integer tareUnitClass;
  /**
   * 除水補正初期単位
   */
  private Integer waterUnitClass;

  /**
   * 2回測定チェック
   */
  private String isDoubleCheck;
  /**
   * 2回測定チェック許容値
   */
  private BigDecimal doubleCheckTolerance;

  /**
   * 透析中条件送信画面表示
   */
  private String isDuringDialysisView;
  /**
   * 前回後体重取得元
   */
  private Short previousWeightSourceClass;

}
