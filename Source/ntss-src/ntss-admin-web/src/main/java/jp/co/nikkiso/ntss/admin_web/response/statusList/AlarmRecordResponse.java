package jp.co.nikkiso.ntss.admin_web.response.statusList;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * 警報・注意一覧のResponse.
 */
@NoArgsConstructor
public class AlarmRecordResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public AlarmRecordResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 発生日
   */
  public String occurDate;

  /**
   * 履歴タイプ
   */
  public String historyType;

  /**
   * ベッド名.
   */
  public String bedName;

  /**
   * 患者名.
   */
  public String patName;

  /**
   * メッセージ
   */
  public String contents;

  // add FNSI-警報・報知追加 付 start
  /**
   * 型式コード
   */
  public String machineTypeCd;

  /**
   * 製造番号
   */
  public String machineSerial;
  // add FNSI-警報・報知追加 付 end
}
