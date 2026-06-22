package jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 *  通信サーバ用次患者情報のDTO.
 */
@NoArgsConstructor
@Getter
@Setter
public class LcdResponseStruct {

  /** 項目コード */
  private int cd;
  /** 名称 */
  private String name;
  /** 設定値 */
  private String value;
  /** 単位 */
  private String unit;
}
