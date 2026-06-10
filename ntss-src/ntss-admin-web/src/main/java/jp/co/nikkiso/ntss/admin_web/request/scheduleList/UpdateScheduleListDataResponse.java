package jp.co.nikkiso.ntss.admin_web.request.scheduleList;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;
import java.util.Map;

/**
 * スケジュールデータのResponse
 */
@NoArgsConstructor
@Setter
@Getter
public class UpdateScheduleListDataResponse extends FlagAndMessageBaseResponse {

  public UpdateScheduleListDataResponse(String errorMessage) {
    super(errorMessage);
  }

  private String message;

  private String PROC_RESULT;

  private String msgCd;

  /**
   * MsgList
   */
  public List<String> msgCdList;

  /**
   * before : 1
   * after : 2
   */
  private String beforOrAfterFlag;

  /**
   * 患者イベントの処理を選択してください
   */
  private boolean hasPatEvent;

  /**
   * 一般検査の処理を選択してください
   */
  private boolean hasExam;

  /**
   * X線検査の処理を選択してください
   */
  private boolean hasRad;

  /**
   * 一般検査の締切日が過ぎている予定移動があります
   */
  private boolean hasExamDeadLineRecords;

  /**
   * 放射線検査の締切日が過ぎている予定移動があります
   */
  private boolean hasRadDeadLineRecords;

  /**
   * 実績反映しますか
   */
  private boolean hasRst;

  /**
   * 条件送信キャンセル
   */
  private boolean hasDoCancel;

  /**
   *条件送信キャンセル ordNo
   */
  private Long doCancelGoSendordNo;

  /**
   * 次患者情報
   */
  @JsonIgnore
  private List<OrdMain> doCallNextPatOrdMainList;

  /**
   * 連携・ログ用情報（変更後データ）
   */
  @JsonIgnore
  private Map<String, List<Object>> resultAllChangedDataInfoList;


  /**
   * 連携・ログ用情報（変更前データ※InsertとDeleteデータは含まない）
   */
  @JsonIgnore
  private Map<String, List<Object>> resultAllChangeBeforeDataInfoList;

  // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
  /**
   * {@link jp.co.nikkiso.ntss.admin_web.service.ordmain.check.IndScheduleUpdateCheck#checkForIndScheduleByOrdMove}
   * 内で {@link jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource#updateIndSchedule2} より前に更新した ord_main の変更前。
   * 旧 {@code updateIndSchedule} の #10553 連携退避と同等のため {@code createJournalPayload} 用にマージする。
   */
  @JsonIgnore
  private List<OrdMain> scheduleCheckCoopOrdMainBeforeList;

  /**
   * 上記チェック処理での ord_main 変更後（同趣旨）
   */
  @JsonIgnore
  private List<OrdMain> scheduleCheckCoopOrdMainAfterList;
  // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end

  /**
   * 指示履歴
   */
  @JsonIgnore
  private List<IndHistory> indHistoryList;

  // add #12306 スケジュール作成可能期間外について、患者経過総合ビューア＆スケジュール表で動作不正 関 start
  /**
   * スケジュール可能期間外の患者名リスト
   */
  private List<String> outOfSchedulePatNameList;
  // add #12306 スケジュール作成可能期間外について、患者経過総合ビューア＆スケジュール表で動作不正 関 end

  // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
  // --- legacy updateIndSchedule parity fields (update_mode=1/2) ---
  @JsonProperty("BedUnregistOrdList")
  private List<Long> bedUnregistOrdList;

  @JsonProperty("DuplicatedOrdNoList")
  private List<Long> duplicatedOrdNoList;

  /**
   * 条件送信を行なった場合の対象 ordNo（旧 updateIndSchedule の "ordNo" と同義）
   */
  private Long ordNo;
  // --- end legacy parity fields ---
  // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end

  // add #11716 曜日パターン変更の不正 関 start
  List<IndScheduleInfo> toBeOrdScheduleListAllForCheak;

  List<IndScheduleInfo> dupulicateOrdScheduleListAll;

  private String conflictMessage;

  private List<IndScheduleInfo> beforeIndScheduleInfo;
  // add #11716 曜日パターン変更の不正 関 end
}
