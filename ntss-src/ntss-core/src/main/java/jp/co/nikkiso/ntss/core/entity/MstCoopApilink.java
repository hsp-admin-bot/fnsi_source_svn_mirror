package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;

import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
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
 * 連携API関連付けマスタEntity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_coop_apilink")
@Getter
@Setter
public class MstCoopApilink extends BaseEntity {

  /** 管理番号 */
  @Id
  private Long ctlNo;

  /** 施設コード */
  private String facilityCd;

  /** 電文種別 */
  private String coopCd;

  /** 付帯情報（電文） */
  private String coopCdIndex;

  /** 作成更新区分 */
  private String crud;

  /** 向き（送受信） */
  private String direction;

  /** 発行タイミング（更新） */
  private String apiTimingIo;

  /** 発行タイミング（前後） */
  private String apiTimingBa;

  /** 発行タイミング（シーケンス） */
  private Long apiTimingSeq;

  // add 2021-04-02 課題No.1:API連動設定:動作条件に「処理完了時」「処理エラー時」「処理スキップ時」を追加 孫 start
  /** API種別 */
  private String apiType;

  /** sql設定 */
  private LayoutExtSetting sqlSetting;
  // add 2021-04-02 課題No.1:API連動設定:動作条件に「処理完了時」「処理エラー時」「処理スキップ時」を追加 孫 end

  /** api-URI */
  private String apiUri;

  /** httpメソッド */
  private String apiMethod;

  /** リクエストbody */
  private String apiBody;

  /** 処理継続レスポンス */
  private ContinueApiStatus continueApiStatus;

  /** 処理後ステータス */
  private AfterApiStatus afterApiStatus;

  /** 削除フラグ */
  private String isDel;

  /** ユーザID */
  private String userId;

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end


  /**
   * 処理継続レスポンスステータスentity
   *
   */
  @Domain(valueType = String.class)
  @Setter
  @Getter
  @NoArgsConstructor
  public static class ContinueApiStatus {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();
    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    @JsonProperty("continue_code")
    private Integer[] continueCode;

    // mod 2021-04-01 課題No.1:API連動設定（mst_coop_apilink）につてい、異常処理を追加する 孫 start
//    @JsonProperty("exit)
//    private Integer[] exit;
    @JsonProperty("exit_code")
    private Integer[] exitCode;
    // mod 2021-04-01 課題No.1:API連動設定（mst_coop_apilink）につてい、異常処理を追加する 孫 end

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public ContinueApiStatus(String value) {
      try {
        ContinueApiStatus obj = objectMapper.readValue(value, ContinueApiStatus.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("連携API関連付けマスタ処理継続レスポンスステータスが不正です。");
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
   * 処理後ステータスentity
   *
   */
  @Domain(valueType = String.class)
  @Setter
  @Getter
  @NoArgsConstructor
  public static class AfterApiStatus {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();
    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    @JsonProperty("ana_result")
    private String anaResult;

    @JsonProperty("coop_result")
    private String coopResult;

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public AfterApiStatus(String value) {
      try {
        AfterApiStatus obj = objectMapper.readValue(value, AfterApiStatus.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("連携API関連付けマスタ処理後ステータスが不正です。");
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
}
