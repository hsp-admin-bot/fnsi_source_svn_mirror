package jp.co.nikkiso.ntss.admin_web.response.ordMain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class OrdMainResponse {

  private String procResult;

  /**
   * 警告メッセージ
   */
  public List<String> messageList;
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

}
