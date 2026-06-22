package jp.co.nikkiso.ntss.admin_web.request.scaleBedState;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ScaleBedSendConditionRequest {
  /**
   * ベッドコード
   */
  private Long bedCd;
  /**
   * 体重計管理コード
   */
  private Long weightCd;
  /**
   * 治療番号
   */
  private Long ordNo;

  /**
   * 測定値
   */
  private BigDecimal measureValue;
}
