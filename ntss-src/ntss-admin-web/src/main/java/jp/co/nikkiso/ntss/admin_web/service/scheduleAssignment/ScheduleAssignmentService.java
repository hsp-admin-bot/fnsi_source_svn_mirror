package jp.co.nikkiso.ntss.admin_web.service.scheduleAssignment;

import java.io.IOException;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.scheduleAssignment.ScheduleAssignmentResponse;
import jp.co.nikkiso.ntss.admin_web.response.scheduleAssignment.ScheduleAssignmentUpdateResponse;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;

public interface ScheduleAssignmentService {


  /**
   * オーダー番号からスケジュール情報を取得するREST API
   * @param ordNo
   * @return
   * @throws IOException
   */
  ScheduleAssignmentResponse getOrderByOrderNo(Long ordNo) throws IOException;

  /**
   * 患者一覧情報取得するREST API
   * @param facilityCd  施設コード
   * @return
   */
  List<PatPersonalMainData> getPatlist(String facilityCd);

  /**
   * 対象のスケジュール一覧情報取得するREST API
   * @param facilityCd  施設コード
   * @param startDate  治療開始日付
   * @param endDate  治療終了日付(治療中の場合は現在日付)
   * @param bedCd  ベッドコード
   * @return
   */
  List<ScheduleAssignmentResponse> getSchedulelist(String facilityCd, String startDate, String endDate, Long bedCd);

  /**
   * 患者割り当て
   * @param patId 患者ID
   * @return
   * @throws IOException
   */
  ScheduleAssignmentUpdateResponse patAssignment(Long patId, Long ordNo) throws IOException;

  // mod 11454 時間外加算自動処理が機能していない zkm start
//  // add FNSI-？？？？患者割り当て 陳 start
//  /**
//   * スケジュール割り当て
//   * @param ordNo
//   * @return
//   * @throws IOException
//   */
//  // ScheduleAssignmentUpdateResponse scheduleAssignment(Long baseordNo, Long ordNo) throws IOException;
//  // mod FNSI-外部連携api呼び出対応 陳 start
//  ScheduleAssignmentUpdateResponse scheduleAssignment(Long baseordNo, Long ordNo, Short rstInputClass, String flg) throws IOException;
//  // mod FNSI-外部連携api呼び出対応 陳 end
//  // add FNSI-？？？？患者割り当て 陳 end

  /**
   * スケジュール割り当て
   * @param baseOrdNo 割り当て対象のオーダ番号
   * @param ordNo ？？？？患者対象のオーダ番号
   * @param rstInputClass 実績：登録区分
   *                      3：？？？？患者スケジュール割り当て
   *                      4：？？？？患者患者名割り当て
   * @param flg 画面フラグ
   * @return 割り当て対象
   * @throws IOException
   */
  ScheduleAssignmentUpdateResponse scheduleAssignment(Long baseOrdNo, Long ordNo, int rstInputClass, String flg) throws Exception;
  // mod 11454 時間外加算自動処理が機能していない zkm end
}
