package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 治療記録:治療方法コードに該当する帳票コード情報のEntity.
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Entity(immutable = true, naming = NamingType.SNAKE_LOWER_CASE)
public class TreatmentRecordReportInfo {

  /**
   * 帳票コード
   */
  private long reportId;

  /**
   * 治療方法コード
   */
  private Integer treatmentCd;

  /**
   * 治療方法名
   */
  private String treatmentName;

  /**
   * 実績に格納されている治療方法コード
   */
  private Integer rstTreatmentCd;

  /**
   * 実績に格納されている治療方法名
   */
  private String rstTreatmentName;

  //mod FNSI-改修内容背景色 房 start
  /**
   * 実績に格納されている治療条件設定
   */
  private String treatmentConditionSetting;
  //mod FNSI-改修内容背景色 房 end

}
