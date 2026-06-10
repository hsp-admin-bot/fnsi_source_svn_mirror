package jp.co.nikkiso.ntss.admin_web.web.rest.util;

// #7068 add  患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
public class OrdMainJournalRequestUtil {

  public final static String LOG_JOURNAL_CREATE = "ジャーナル新規作成APIリクエスト [/journal/create]: ";

  public static String logInfo(String msg, Long ordNo, Long patNo) {
    return LOG_JOURNAL_CREATE + msg + String.format("オーダ番号:[%s],患者ID:[%s]", ordNo, patNo);
  }

}
// #7068 add  患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end
