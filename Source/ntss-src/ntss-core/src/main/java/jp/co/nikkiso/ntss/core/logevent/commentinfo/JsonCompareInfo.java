package jp.co.nikkiso.ntss.core.logevent.commentinfo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class JsonCompareInfo {
  /** テーブル名  */
  private String tableName;

  /** コラム名  */
  private String colName;

  /** キー  */
  private String key;

  /** キーコメント  */
  private String keyComment;

  /** 更新前データ  */
  private String oldValue;

  /** 更新後データ  */
  private String newValue;

  /** コラムコメント  */
  private String fieldComment;

  // DB更新ログ出力ロジック xie Start
  private int ordMainHstInsFlg;
  private OrdMainHisInfo ordMainInfo;
  // DB更新ログ出力ロジック xie End
}
