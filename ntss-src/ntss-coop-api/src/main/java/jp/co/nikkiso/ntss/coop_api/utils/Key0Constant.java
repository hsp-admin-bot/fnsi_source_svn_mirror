package jp.co.nikkiso.ntss.coop_api.utils;

// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
/**
 * 電子カルテ種別の定数クラス.
 */
public class Key0Constant {

  /**
   * 電子カルテ種別：日機装
   */
  public static final String NKK = "NKK";

  /**
   * 電子カルテ種別：富士通GX
   */
  public static final String GX = "GX";

  /**
   * 電子カルテ種別：富士通CX
   */
  public static final String CX = "CX";

  /* #8584 upd  2023-05-11 連携が処理スキップになる[SSI CSI] 修正 by ztc --start */
  /**
   * 電子カルテ種別：シーエスアイ
   */
  public static final String CSI = "CSI";

  /**
   * 電子カルテ種別：SSI
   */
  public static final String SSI = "SSI";
  /* #8584 upd  2023-05-11 連携が処理スキップになる[SSI CSI] 修正 by ztc --end */

  /**
   * 電子カルテ種別：パナソニックMedicom
   */
  public static final String MED = "MED";
}
// add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
