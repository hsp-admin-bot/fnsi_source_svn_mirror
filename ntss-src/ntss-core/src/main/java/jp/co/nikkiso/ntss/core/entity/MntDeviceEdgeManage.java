package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * デバイスエッジアップデータ状態管理のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_device_edge_manage")
@Getter
@Setter
public class MntDeviceEdgeManage extends BaseEntity {

  /**
   * 管理番号.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long manageNo;
  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * デバイスエッジ番号.
   */
  private Integer deviceEdgeNo;

  /**
   * 指示者
   */
  private Long userId;

  /**
   * 指示種別
   */
  private Short orderClass;

  /**
   * 指示対象.
   */
  private Short orderTargetClass;

  /**
   * 応答ステータス.
   */
  private Short responseStatus;

  /**
   * 情報.
   */
  private ManageInfo manageInfo;

  /**
   * 情報JSONクラス
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class ManageInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * payload
     */
    @JsonProperty("payload")
    private String payload;

    /**
     * ダウンロード指示の場合の指定バケット
     */
    @JsonProperty("download_bucket")
    private String downloadBucket;

    /**
     * ダウンロード指示の場合の指定ファイル名
     */
    @JsonProperty("download_file")
    private String downloadFile;

    /**
     * アップロード指示の場合の指定バケット
     */
    @JsonProperty("upload_bucket")
    private String uploadBucket;

    /**
     * アップロード指示の場合の指定ファイル名
     */
    @JsonProperty("upload_file")
    private String uploadFile;

    /**
     * メッセージ内容
     */
    @JsonProperty("message")
    private String message;

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public ManageInfo(String value) {
      try {
        ManageInfo obj = objectMapper.readValue(value, ManageInfo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
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
