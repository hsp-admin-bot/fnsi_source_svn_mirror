package jp.co.nikkiso.ntss.core.logevent.commentinfo;

import jp.co.nikkiso.ntss.core.logevent.commentinfo.JsonCompareInfo;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UpdateLogInfo {
  /** テーブル名 */
  private String tableName;

  /** テーブルコメント */
  private String tableComment;

  /** コラム名 */
  private String fieldName;

  /** コラムコメント */
  private String fieldComment;

  /** 更新前データ */
  private Object beforeUpdateValue;

  /** 更新後データ */
  private Object afterUpdateValue;

  /** 更新済みフラグ */
  private boolean isUpdated;

  // add 10601 eventLog共通処理 gjn start
  /** 削除済みフラグ */
  private boolean isDeleted;
  // add 10601 eventLog共通処理 gjn end

  /** Jsonデータフラグ */
  private boolean isJson;

  private int keyStep;

  /** Jsonデータリスト */
  private List<JsonCompareInfo> jsonUpdatedlist;

  // DB更新ログ出力ロジック xie Start
  private int ordMainHstInsFlg;
  private OrdMainHisInfo ordMainInfo;
  // DB更新ログ出力ロジック xie End
}
