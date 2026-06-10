package jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 *  通信サーバ仮想端末透析日報のResponse.
 */
@NoArgsConstructor
@Getter
@Setter
public class DailyReportResponse {

  /** レポート1 **/
  private LcdResponseStruct report1;
  /** レポート2 **/
  private LcdResponseStruct report2;
  /** レポート3 **/
  private LcdResponseStruct report3;
  /** レポート4 **/
  private LcdResponseStruct report4;
  /** レポート5 **/
  private LcdResponseStruct report5;
  /** レポート6 **/
  private LcdResponseStruct report6;
  /** レポート7 **/
  private LcdResponseStruct report7;
  /** レポート8 **/
  private LcdResponseStruct report8;

}
