package jp.co.nikkiso.ntss.core.dto.OrdMain;

import lombok.Data;

/**
 * @author zy
 */
@Data
public class OrdMainRequest {

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * 開始日
   */
  private String dialysisDateFrom;

  /**
   * 終了日
   */
  private String dialysisDateTo;

  /**
   * 施設コード
   */
  private String facilityCd;

}
