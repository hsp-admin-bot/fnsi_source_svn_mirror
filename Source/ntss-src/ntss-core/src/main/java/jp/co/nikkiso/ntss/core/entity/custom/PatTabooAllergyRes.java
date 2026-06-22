package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatTabooAllergyRes {

  /**
   * 禁忌・アレルギーコード or detailInfo的cd
   */
  private String cd;

  /**
   * 対象区分　
   * 1:薬剤、2:調製薬剤、3:医療材料、4:ダイアライザ
   */
  private String classType;

  /**
   * 患者Id
   */
  private Long patId;

  /**
   * 禁忌
   */
  private boolean isTaboo;

  /**
   * アレルギー
   */
  private boolean isAllergy;
}
