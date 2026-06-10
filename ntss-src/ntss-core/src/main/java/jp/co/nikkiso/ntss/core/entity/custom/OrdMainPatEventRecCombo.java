package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 透析情報クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainPatEventRecCombo {
  @Id
  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;
  /**
   * 治療日
   */
  private String treatDate;
  /**
   * 指示：クールコード
   */
  private Long indKurCd;
  /**
   * 指示：クール名
   */
  private String indKurName;
  /**
   * 指示：ベッドコード
   */
  private Long indBedCd;
  /**
   * 指示：ベッド名
   */
  private String indBedName;
  /**
   * 指示：治療方法コード
   */
  private Long indTreatmentCd;
  /**
   * 指示：治療方法名
   */
  private String indTreatmentName;
  /**
   * 治療状況
   */
  private String rstDialysisState;
  /**
   * 実績：クールコード
   */
  private Long rstKurCd;
  /**
   * 実績：クール名
   */
  private String rstKurName;
  /**
   * 実績：ベッドコード
   */
  private Long rstBedCd;
  /**
   * 実績：ベッド名
   */
  private String rstBedName;
  /**
   * 実績：治療方法コード
   */
  private Integer rstTreatmentCd;
  /**
   * 実績：治療方法名
   */
  private String rstTreatmentName;
  /**
	* 治療日(表示用)
   */
  private String viewTreatDate;
}