package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainKurBed {
  /**
   * オーダー番号
   */
  private Long ordNo;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * クール開始時刻
   */
  private String kurStartTime;

  /**
   * ベッド名
   */
  private String bedName;
  // add FNSI-No.341 患者リストのソート項目不足 吉 start
  /**
   * 治療方法
   */
  private String indTreatmentCd;
  // add FNSI-No.341 患者リストのソート項目不足  吉 end

  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  private Integer bedCd;
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
}
