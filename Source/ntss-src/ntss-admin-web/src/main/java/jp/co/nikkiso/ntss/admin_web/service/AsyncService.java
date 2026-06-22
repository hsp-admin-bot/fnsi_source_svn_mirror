package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask.OrdMainJournalRequest;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;

import java.util.List;


public interface AsyncService {

  // #7068 add 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
  public void sendExternalConnection(JournalCreateRequestPayload journalCreateRequestPayload);
  // #7068 add 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end

  public void sendExternalConnection(List<OrdMain> list, JournalCreateRequestPayload journalCreateRequestPayload);
  // #7068 add 2022-11-17 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
  public void requestApiJournalCreate(List<OrdMain> list, JournalCreateRequestPayload journalCreateRequestPayload);
  // #7068 add 2022-11-17 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end
  // #7068 add 2022-11-21 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
  public void callCreateJournal(List<OrdMainJournalRequest> requests) ;
  // #7068 add 2022-11-21 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end

  public void updateLog(DataUpdateLogCommonNew logCommon);

  // add by shiyw 2023-02-14
  void requestApiJournalCreateList(List<JournalCreateRequestPayload> ctlNoList);
}
