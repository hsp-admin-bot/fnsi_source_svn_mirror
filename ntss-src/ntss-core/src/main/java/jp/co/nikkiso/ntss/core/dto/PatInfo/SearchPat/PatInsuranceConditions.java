package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import lombok.Data;

@Data
public class PatInsuranceConditions {
  /**
   * 空是不指定，1是有，0是没有
   */
  private String insurance_check_date;
}
