package jp.co.nikkiso.ntss.admin_web.response.exceptionPeriod;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Data
public class ExceptionPeriodResponse {

  private Long exceptionPeriodNo;
  /**
   * 除外期間開始日
   */
  private String exceptionPeriodFrom;
  /**
   * 除外期間終了日
   */
  private String exceptionPeriodTo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 患者ID
   */
  private Long patId;
  /**
   * 削除
   */
  private String isDel;

}
