package jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import lombok.Data;

import java.net.URI;

// #7068 add  患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end
/*
 * ordMain ジャーナル Api リクエスト
 * */
@Data
public class OrdMainJournalRequest {
  /* ジャーナル更新APIリクエスト*/
  private JournalCreateRequestPayload payload;

  private URI uri;

  /**
   * 次世代FutureNetオーダ番号
   */
  private Long ordNo;
  /**
   * 患者番号(次世代FutureNet用)
   */
  private Long patId;
  /**
   * 電文作成区分
   */
  private String crud;


  @Override
  public String toString() {
    return String.format("OrderMainJournalRequest: オーダ番号[%s],患者番号[%s],電文作成区分[%s]", this.ordNo , this.patId , this.crud);
  }
}
// #7068 add  患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end
