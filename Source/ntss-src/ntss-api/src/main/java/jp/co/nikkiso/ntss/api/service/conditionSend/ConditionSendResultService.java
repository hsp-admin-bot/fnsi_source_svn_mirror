package jp.co.nikkiso.ntss.api.service.conditionSend;

/**
 * 手動実績のServiceインタフェース.
 */
// add 11454 時間外加算自動処理が機能していない zkm start
public interface ConditionSendResultService {

  /**
   * 条件送信の結果処理を行う(ord_mainのみの処理)
   *
   * @param ordNo 治療番号
   * @param userId 利用者ID
   */
  void sendCondResultOnly(Long ordNo, Long userId);

  /**
   * 手動実績の処理
   * 以下処理を含む
   * 1-条件送信の結果処理を行う(ord_mainのみの処理)
   * 2-RstStartDate設定
   * 3-LogUserId設定
   * 4-加算再計算(eventId=5)
   * 5-OrdChecklist反映)
   *
   * @param ordNo 治療番号
   * @param userId 利用者ID
   */
  void sendCondResultManualOnly(Long ordNo, Long userId);

  /**
   * 実績送信の処理
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 装置種別
   * @param machineSerial 装置シリアル
   */
  void mainProcessSendCondResult(String facilityCd, String machineTypeCd, String machineSerial);

}
// add 11454 時間外加算自動処理が機能していない zkm end
