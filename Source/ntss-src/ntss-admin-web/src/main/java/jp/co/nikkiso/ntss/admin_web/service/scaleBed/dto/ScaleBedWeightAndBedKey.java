package jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ScaleBedWeightAndBedKey {

  /**
   * ベッドコード.
   */
  private Long bedCd;

  /**
   * 体重計設定の主キー
   */
  private Long weightCd;

  /**
   * 体重計番号.
   */
  private Integer weightNo;

}
