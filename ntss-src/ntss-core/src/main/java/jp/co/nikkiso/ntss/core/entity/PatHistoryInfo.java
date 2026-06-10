package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

//add #12462 患者共有情報 by zrx start

/**
 * #12462 患者情報共有 zrx
 * add 施しの情報
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatHistoryInfo {

  /**
   * codeを施す
   */
  private String facilityCd ;
  /**
   * 施しname
   */
  private String facilityName ;
}
//add #12462 患者共有情報 by zrx end
