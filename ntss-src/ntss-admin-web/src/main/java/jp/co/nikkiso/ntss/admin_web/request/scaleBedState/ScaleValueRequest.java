package jp.co.nikkiso.ntss.admin_web.request.scaleBedState;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ScaleValueRequest {
  /**
   * ベッドコード
   */
  private Long bedCd;
  /**
   * 体重計管理コード
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
  /**
   * 測定値
   */
  private BigDecimal scaleValue;
  /**
   * 測定モード(MDコード)
   */
  private String mdCd;
  /**
   * ユーザID(※win側ではUserNo)
   */
  private Long userId;
}
