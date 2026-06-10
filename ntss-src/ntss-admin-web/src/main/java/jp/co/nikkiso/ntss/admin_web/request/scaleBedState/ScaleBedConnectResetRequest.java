package jp.co.nikkiso.ntss.admin_web.request.scaleBedState;

import lombok.Data;

import java.util.List;

@Data
public class ScaleBedConnectResetRequest {
  /**
   * ベッドコードのリスト
   */
  private List<Long> bedCdList;
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
}
