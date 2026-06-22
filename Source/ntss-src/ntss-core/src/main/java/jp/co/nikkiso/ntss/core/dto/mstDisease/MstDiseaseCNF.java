package jp.co.nikkiso.ntss.core.dto.mstDisease;

import lombok.Data;

/**
 * 病名クラス
 */
@Data
public class MstDiseaseCNF {
  /**
   * 病名コード
   */
  private Integer cd;
  /**
   * 病名
   */
  private String nm;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
}
