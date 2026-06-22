package jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

/**
 *  通信サーバ用次患者情報のResponse.
 */
@AllArgsConstructor
@Getter
@Setter
public class ComsvNextPatOrdResponse {

  /**
   * 通知有無フラグ[0：不要/1：必要]
   */
  private int needToSend;

  /**
   * 患者名：名
   */
  private String patFirstName;

  /**
   * 患者名：姓
   */
  private String patLastName;

  /**
   * 日付
   */
  private String dialysisDate;

  /**
   * クール
   */
  private String kur;

  /**
   * メモ1
   */
  private LcdResponseStruct memo1;

  /**
   * メモ2
   */
  private LcdResponseStruct memo2;

  /**
   * メモ3
   */
  private LcdResponseStruct memo3;

  /**
   * メモ4
   */
  private LcdResponseStruct memo4;

  /**
   * メモ5
   */
  private LcdResponseStruct memo5;

  /**
   * メモ6
   */
  private LcdResponseStruct memo6;

  /**
   * メモ7
   */
  private LcdResponseStruct memo7;

  /**
   * メモ8
   */
  private LcdResponseStruct memo8;

  /**
   * メモ9
   */
  private LcdResponseStruct memo9;

  /**
   * メモ10
   */
  private LcdResponseStruct memo10;

  // #9147 2023.12.22 add メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 start
  /** メモ11 */
  private LcdResponseStruct memo11;
  /** メモ12 */
  private LcdResponseStruct memo12;
  /** メモ13 */
  private LcdResponseStruct memo13;
  /** メモ14 */
  private LcdResponseStruct memo14;
  /** メモ15 */
  private LcdResponseStruct memo15;
  /** メモ16 */
  private LcdResponseStruct memo16;
  /** メモ17 */
  private LcdResponseStruct memo17;
  /** メモ18 */
  private LcdResponseStruct memo18;
  /** メモ19 */
  private LcdResponseStruct memo19;
  /** メモ20 */
  private LcdResponseStruct memo20;
  // #9147 2023.12.22 add メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 end

  /**
   * 感染症
   */
  private int isInfect;

  /**
   * 治療モード
   */
  private int mode;

  /**
   * コンストラクタ.
   */
  public ComsvNextPatOrdResponse() {

  }

}
