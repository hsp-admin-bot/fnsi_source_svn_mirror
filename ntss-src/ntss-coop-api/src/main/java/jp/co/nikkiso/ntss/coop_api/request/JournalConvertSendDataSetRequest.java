package jp.co.nikkiso.ntss.coop_api.request;

import java.util.Map;
import java.util.regex.Pattern;

import com.fasterxml.jackson.annotation.JsonProperty;

import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 送信変換で利用するntss-apiリクエスト
 *
 */
@Data
@NoArgsConstructor
public class JournalConvertSendDataSetRequest {
  public JournalConvertSendDataSetRequest(Map<String, Object> map) {
    // datakey配下はdatasetにおけるwhere句だけの用途となるのでsqlCodeはdatakeyと同列にする
    if (map.containsKey("sqlCode")) {
      // 条件付き数値チェック
      if (!map.containsKey("dsMerge")
          && !Pattern.compile("^-?[0-9]+$").matcher(String.valueOf(map.get("sqlCode"))).find()) {
        throw new NtssException("sqlCodeが数値以外です。");
      }
      this.sqlCode = String.valueOf(map.get("sqlCode"));
      map.remove("sqlCode");
    }
    this.dataKey = map;
  }

  /** sys_data_set.sql_code */
  @JsonProperty("sqlCode")
  private String sqlCode;

  /** data-setの結果Map<sqlCode, result> */
  @JsonProperty("dataKey")
  private Map<String, Object> dataKey;
}
