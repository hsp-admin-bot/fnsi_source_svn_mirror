package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.util.List;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 送信先グループマスタのEntity.
 */
@Entity(listener = BaseEntityListener.class , naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_destination_group")
@Getter
@Setter
public class MstDestinationGroup extends BaseEntity {

  /**
   * 送信対象1件を表すクラス
   */
  @Setter
  public static class User {

    /**
     * 利用者ID.
     */
    private Long userId;
    @JsonProperty("user_id")
    public Long getUserId()
    {
      return userId;
    }

    /**
     * アドレス1送信フラグ.
     */
    private boolean isAddress1Send;
    @JsonProperty("is_address1_send")
    public boolean isAddress1Send()
    {
      return isAddress1Send;
    }

    /**
     * アドレス2送信フラグ.
     */
    private boolean isAddress2Send;
    @JsonProperty("is_address2_send")
    public boolean isAddress2Send()
    {
      return isAddress2Send;
    }

  }

  /**
   * 送信対象クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class DestinationTarget {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 送信対象のリスト.
     */
    @JsonProperty("users")
    private List<User> users;

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public DestinationTarget(String value) {
      try {
        DestinationTarget obj = objectMapper.readValue(value, DestinationTarget.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        throw new NtssException("送信対象の設定内容が不正です");
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
      } catch (JacksonException e) {
        return null;
      }
    }
  }

  /**
   * 送信先グループコード.
   */
  @Id
  private Long destinationGroupCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 送信先グループ名.
   */
  private String destinationGroupName;

  /**
   * 送信対象.
   */
  private DestinationTarget destinationTarget;

  /**
   * メーカー通知フラグ（0: 通知OFF 1: 通知ON）
   */
  private String isNotice;

  /**
   * 表示フラグ（0: 非表示 1: 表示）
   */
  private String isDisp;

  /**
   * 削除フラグ（0:通常 1:削除）
   */
  private String isDel;

}
