package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 連携エッジ制御指示管理Entity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_if_edge_manage")
@Getter
@Setter
public class MntIfEdgeManage extends BaseEntity {

  /** 管理番号 */
  @Id
  private Long ctlNo;

  /** 施設コード */
  private String facilityCd;

  /** 応答ステータス */
  private Integer responseStatus;

  /** 連携エッジ実行結果 */
  private EdgeResult edgeResult;

  /**
   * 連携エッジ実行結果entity
   *
   */
  @Domain(valueType = String.class)
  @Setter
  @Getter
  @NoArgsConstructor
  public static class EdgeResult {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();
    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    @JsonProperty("system")
    private String system;

    @JsonProperty("status")
    private String status;

    @JsonProperty("facility_cd")
    private String facilityCd;

    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
    @JsonProperty("serial_no")
    private String serialNo;
    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
    /** 接続状態チェック間隔(送信) */
    @JsonProperty("journal_interval")
    private String journalInterval;

    /** 接続状態チェック間隔(メンテンス) */
    @JsonProperty("main_interval")
    private String mainInterval;
// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end

    @JsonProperty("result")
    private InnerEdgeResult result ;

    /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
    @JsonProperty("SSECCAYEK")
    private String sseccayek;
    /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public EdgeResult(String value) {
      try {
        EdgeResult obj = objectMapper.readValue(value, EdgeResult.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("連携エッジ制御指示管理Entityパラメータが不正です");
      }
    }

    /**
     * 基本型の値を返す.
     * @return 基本型の値
     */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JsonProcessingException e) {
        return null;
      }
    }
  }

  /**
   * 連携エッジ実行結果entityのinner
   */
  @Setter
  @Getter
  public static class InnerEdgeResult {

    /** 管理NO */
    @JsonProperty("ctl_no")
    private Long ctlNo;

    /** 連携エッジ実行結果ステータス */
    @JsonProperty("status")
    private Integer status;

    /** 連携エッジ実行結果メッセージ */
    @JsonProperty("message")
    private String message;
  }

  /** 削除フラグ */
  private String isDel;

}
