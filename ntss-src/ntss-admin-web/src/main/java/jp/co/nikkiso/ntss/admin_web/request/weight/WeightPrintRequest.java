package jp.co.nikkiso.ntss.admin_web.request.weight;

import lombok.Data;

@Data
public class WeightPrintRequest {
  /**
   * 測定記録番号
   */
  private Long weightScaleNo;
  /**
   * 印刷状態
   */
  private Integer printStatus;
  /**
   * 印刷エラーメッセージ
   */
  private String printErrorMessage;

  /**
   * 体重計識別コード
   */
  private Long weightCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 体重計番号
   */
  private Integer weightNo;

}
