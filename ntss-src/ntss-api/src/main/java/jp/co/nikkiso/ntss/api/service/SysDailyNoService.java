package jp.co.nikkiso.ntss.api.service;

/**
 * SysDailyNoの定義に基づいてデータを取得するServiceインタフェース.
 */
public interface SysDailyNoService {

  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
//  /**
//   * 引数の施設コード、採番種別で本日の受付番号を採番して返却する.
//   *
//   * @param facilityCd 施設コード
//   * @param numberingCd 採番種別
//   * @param baseDate 基準日
//   * @return 採番した受付番号
//   */
//  Long numberingReception(String facilityCd, String numberingCd);
  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end

  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
  // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 start
  // Long getAcceptNo(String facilityCd, String numberingCd, String baseDate);
  Long getAcceptNo(String facilityCd, String numberingCd, String baseDate, String coopVersion);
  // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 start
  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end

}
