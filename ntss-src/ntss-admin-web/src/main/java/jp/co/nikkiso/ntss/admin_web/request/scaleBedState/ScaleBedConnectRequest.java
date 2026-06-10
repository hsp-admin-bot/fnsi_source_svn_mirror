package jp.co.nikkiso.ntss.admin_web.request.scaleBedState;

import lombok.Data;

@Data
public class ScaleBedConnectRequest {
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
   * 接続状態
   */
  private String isConnect;
}
