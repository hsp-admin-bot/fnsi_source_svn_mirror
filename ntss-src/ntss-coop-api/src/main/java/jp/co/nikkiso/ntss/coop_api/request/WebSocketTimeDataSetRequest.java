package jp.co.nikkiso.ntss.coop_api.request;

import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.type.TypeReference;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * WebSocketで利用するdata-setリクエスト
 */
@Data
@NoArgsConstructor
public class WebSocketTimeDataSetRequest {
  public WebSocketTimeDataSetRequest(Map<String, Object> map) {
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
//    // datakey配下はdatasetにおけるwhere句だけの用途となるのでsqlCodeはdatakeyと同列にする
//    if (map.containsKey("sqlCode")) {
//      this.sqlCode = Long.parseLong(String.valueOf(map.get("sqlCode")));
//    map.remove("sqlCode");
    if (map.containsKey("tables")) {
      try {
        this.tables = ObjectMapperUtil.readTypeReference(String.valueOf(map.get("tables")),
          new TypeReference<List<Table>>(){});
      } catch (Exception ex) {

      }
      map.remove("tables");
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    }
    this.dataKey = map;
  }

  // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
//  /** sys_data_set.sql_code */
//  @JsonProperty("sqlCode")
//  private Long sqlCode;

  /**
   * テーブル１件を表すクラス
   */
  @Data
  public static class Table {
    /**
     * テーブル名.
     */
    @JsonProperty("tblName")
    private String tblName;
    /**
     * キーテーブル名.
     */
    @JsonProperty("keyName")
    private String keyName;
    /**
     * リクエストを一意に特定するキー名.
     */
    @JsonProperty("jobKeyName")
    private String jobKeyName;

    /**
     * SQLCD のリスト.
     */
    @JsonProperty("sqlCds")
    private List<Long> sqlCds;

    /**
     * 日付.(fromDateとtoDate)
     */
    @JsonProperty("dataKey")
    private Map<String, Object> dataKey;
    // Update 差分機能追加 sichengbo start
    /**
     * 初回ですか
     */
    @JsonProperty("isFirst")
    private boolean isFirst;
    // Update 差分機能追加 sichengbo end
  }

  // テーブルのリスト
  @JsonProperty("tables")
  private List<Table> tables;
  // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end

  /** 施設コード(facilityCd) */
  @JsonProperty("dataKey")
  private Map<String, Object> dataKey;
  
  /**
   * noderedタイムアウト時間ミリ秒.
   */
  @JsonProperty("noderedTimeOut")
  private Long noderedTimeOut;

}
