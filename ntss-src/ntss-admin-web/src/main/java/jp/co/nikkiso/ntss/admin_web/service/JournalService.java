package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask.OrdMainJournalRequest;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;

/**
 * ジャーナル作成のServiceインターフェース.
 */
public interface JournalService {

	/**
	 * ord_coop_no のレコードがあるかどうかチェック
	 *
	 * @param facilityCd 施設コード
	 * @param ordNo オーダ番号
	 * @param coopCd 連携種別
	 * @return
	 */
	public List<OrdCoopNo> getByCondition(String facilityCd, Long ordNo, String coopCd);

	/**
	 * 通知メッセージリクエストを登録
	 *
	 * @param dateList  検査依頼／放射線依頼の日付リスト
	 * @param beforeDate 現在の治療日
	 * @param afterDate 後日付
	 * @param facilityCd 施設コード
	 * @param ordNo オーダ番号
	 * @param userId ユーザーID
	 * @param patId 患者ID
	 * @param coopCd 連携種別
	 * @return
	 */
//	public void callCreateJournal(List<String> dateList, String beforeDate, String afterDate, String facilityCd,
//			Long ordNo, Long userId, Long patId, String coopCd) throws Exception;
  public void callCreateJournal(List<String> dateList, String beforeDate, String afterDate, String facilityCd,
                                Long ordNo, Long userId, Long patId, String opeCd, String crud) throws Exception;

  /**
   * 通知メッセージリクエストを登録(Payloadデータをそのまま送信するのみの処理)
   *
   * @param payload JournalCreateRequestPayloadのオブジェクト
   * @return
   */
  public void callCreateJournalForPayload(JournalCreateRequestPayload payload);

  // mod 2023-01-14 bug #7627 修正 chen start
  public void callCreateJournalForCtrNo(List<JournalCreateRequestPayload> ctlNoList);
  // mod 2023-01-14 bug #7627 修正 chen end

  //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 start
  /**
   * 通知メッセージリクエストを登録(Payloadデータをそのまま送信するのみの処理)
   *
   * @param ordMainList -{@link OrdMain}
   * @param requestPayload -{@link JournalCreateRequestPayload}
   * @param sendRequest -{@link OrdMainJournalRequest}
   * @return
   */
  public void callCreateJournal(List<OrdMain> ordMainList, JournalCreateRequestPayload requestPayload, List<OrdMainJournalRequest> sendRequest);
  //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 end

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
  void sendJournal(List<OrdMain> journalList, String facilityCd, Long userId);
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

  //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 start
  void sendJournalForDw(List<Map<String, String>> payload, NtssUser user);
  //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 end

  // add #10710 【身体情報関連】⑦データリスト 荘 2024-07-12 start
  /**
   * 身体情報のDW、目標体重設定するの目標体重、変更の相関のジャーナル作成
   *
   * @param patId 患者ID
   * @param effectsIntervalOrdNoList 変更あるの治療予定リスト
   * @param userId 操作者ID
   * @param facilityCd 施設コード
   * @param editMod 作成更新区分
   * @param baseDate 身体情報の検査日
   *
   * */
  void sendJournalForDwAndTw(long patId,
                             List<OrdMainTreatDate> effectsIntervalOrdNoList,
                             Long userId,
                             String facilityCd,
                             String editMod,
                             String baseDate);
  // add #10710 【身体情報関連】⑦データリスト 荘 2024-07-12 end

  // add #10553 連携イベント発生部分不正【最優先】ope_cd修正 荘 2024-07-29 start
  void sendJournalForNotDwAndTw(long patId,
                                Long userId,
                                String facilityCd,
                                String editMod,
                                String baseDate);
  // add #10553 連携イベント発生部分不正【最優先】ope_cd修正 荘 2024-07-29 end
  }
