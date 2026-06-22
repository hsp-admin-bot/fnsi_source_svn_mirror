package jp.co.nikkiso.ntss.coop_api.service;

/**
 * convertの直列化に使用するfacilityStatus管理クラス
 *
 */
public interface FacilityStatusService {

  /**
   * 施設のコンバート実行中チェック
   *
   * @param facilityCd 施設コード
   * @return 実行中：true、停止中：false
   */
  public boolean isStatusStart(String facilityCd);

  /**
   * 施設のコンバート実行中チェックと更新
   *
   * @param facilityCd 施設コード
   * @return 更新成功：true、更新不可（他スレッドで実行中）：false
  */
  public boolean checkAndPutStatus(String facilityCd);

  /**
   * replace呼び出し
   *
   * @param facilityCd 施設コード
   * @param newValue   更新値
   */
  public void replace(String facilityCd, String newValue);

}
