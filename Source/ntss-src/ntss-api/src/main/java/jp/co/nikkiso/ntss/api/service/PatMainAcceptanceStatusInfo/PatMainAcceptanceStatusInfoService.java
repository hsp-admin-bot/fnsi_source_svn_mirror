package jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo;

import java.util.Date;

/**
 * pat_mainのacceptance_status_infoを更新するServiceインタフェース.
 */
public interface PatMainAcceptanceStatusInfoService {

  /**
   * 指定したパラメータでpat_mainのacceptance_status_infoを取得する
   *
   * @param patId           患者ID
   * @return JSONオブジェクト文字列
   */
  public String get(Long patId);

  /**
   * 指定したパラメータでpat_main.acceptance_status_infoを更新する
   *
   * @param patId           患者ID
   * @param ordNo           オーダー番号
   * @param dialysisState   治療状態
   * @param startDateTime   治療開始日時
   * @param treatmentTime   治療時間
   * @return 1：更新成功/else：更新失敗
   */
  int update(Long patId, Long ordNo, String dialysisState, Date startDateTime, String treatmentTime);

  /**
   * 指定した患者IDのpat_main.acceptance_status_infoを再構築する
   *
   * @param patId   患者ID
   * @return 再構築したJSONオブジェクト文字列
   */
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 start
  // public String rebuild(Long patId);
  String rebuild(Long patId, String facilityCd);
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260427 end
}
