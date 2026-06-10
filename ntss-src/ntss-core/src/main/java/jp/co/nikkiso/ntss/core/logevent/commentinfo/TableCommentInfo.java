package jp.co.nikkiso.ntss.core.logevent.commentinfo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TableCommentInfo {
  private String tblName;
  private String tblComment;
  private String colName;
  private String colComment;
  private String jsonFlg;
  private int keyStep;
  // DB更新ログ出力ロジック wangzuo Start
  private int pkFlg;
  private int deleteFlg;
  // DB更新ログ出力ロジック wangzuo End

  // DB更新ログ出力ロジック xie Start
  private int ordMainHstInsFlg;
  private OrdMainHisInfo ordMainInfo;
  // DB更新ログ出力ロジック xie End
}
