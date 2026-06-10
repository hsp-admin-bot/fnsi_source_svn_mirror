package jp.co.nikkiso.ntss.coop_api.utils;

public class JournalSendSkipConstant {

  // 新規または更新電文に対して、同タイミングで最新の新規または更新電文（CRUD=C,U）が発生した
  public static final String SKIP_MESSAGE_LATEST_TELEGRAM = "最新電文発生のためスキップ";

  // 新規または更新電文に対して、同タイミングで削除電文（CRUD=D）が発生した
  public static final String SKIP_MESSAGE_DELETE_TELEGRAM = "削除電文発生のためスキップ";

  // 削除電文に対して、同タイミングで削除電文（CRUD=D）が発生した
  public static final String SKIP_MESSAGE_DELETE_FOR_INCOMPLETE = "送信未完了に対する削除電文のためスキップ";
}
