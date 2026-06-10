package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import static java.util.Collections.emptyList;

import java.io.IOException;
import java.util.List;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Column;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * 職種マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_job")
@Getter
@Setter
public class MstJob extends BaseEntity{

  /**
   * デフォルトメニュー設定クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class DefaultMenuSettings {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 使用可能メニュー デフォルト値.
     */
    public static final List<String> USE_FUNCTIONS_DEFAULT = emptyList();

    /**
     * 初期表示機能コード デフォルト値.
     */
    public static final String INITIAL_FUNCTION_DEFAULT = "";

    /**
     * 使用機能コード.
     */
    @JsonProperty("default_menu_functions")
    private List<String> useFunctions = USE_FUNCTIONS_DEFAULT;

    /**
     * 初期表示機能コード.
     */
    @JsonProperty("initial_menu_function")
    private String initialFunction = INITIAL_FUNCTION_DEFAULT;

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public DefaultMenuSettings(String value) {
      try {
        DefaultMenuSettings obj = objectMapper.readValue(value, DefaultMenuSettings.class);
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

  /**
   * デフォルト通知設定の設定値を格納するクラス
   */
  @Getter
  @Setter
  @NoArgsConstructor
  @EqualsAndHashCode
  public static class NotificationSettingsValue {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 設定項目ID
     */
    @JsonProperty("setting_identifier")
    private String settingId;

    /**
     * 設定値
     */
    @JsonProperty("value")
    private Object settingValue;

    /**
     * 設定項目ID
     */
    @JsonProperty("setting_important")
    private Object settingImportant;

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public NotificationSettingsValue(String value) {
      try {
        NotificationSettingsValue obj = objectMapper.readValue(value, NotificationSettingsValue.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("デフォルト通知設定の設定内容が不正です", e);
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
   * デフォルト通知設定クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  @EqualsAndHashCode
  public static class NotificationSettings {
    /**
     * ObjectMapper
     */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /**
     * ModelMapper
     */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 個人設定タブコード
     */
    @JsonProperty("tab_define_cd")
    private Integer tabDefineCd;

    /**
     * 設定値情報
     */
    @JsonProperty("values")
    private List<NotificationSettingsValue> values = emptyList();

    /**
     * 設定値情報
     */
    @JsonProperty("setting_important")
    private List<NotificationSettingsValue> settingImportant = emptyList();

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    public NotificationSettings(String value) {
      try {
        NotificationSettings obj = objectMapper.readValue(value, NotificationSettings.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("デフォルト通知設定の設定内容が不正です", e);
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
   * 職種コード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long jobCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 職種名.
   */
  private String jobName;

  /**
   * 医師フラグ.
   * 0 : 医師以外、1 : 医師
   */
  private String isDoctor;

  /**
   * デフォルトメニュー設定.
   */
  private DefaultMenuSettings defaultMenuSettings;

  /**
   * 表示フラグ.
   * 0 : 非表示、1 : 仮表示
   */
  private String isDisp;

  /**
   * 削除フラグ.
   * 0 : 通常、1 : 削除
   */
  private String isDel;

  /**
   * 許可権限コード.
   */
  private String defaultAuthorizedAuthorities;

  /**
   * 連携コード.
   */
  @Column(name = "in_hospital_cd_1")
  private String inHospitalCd1;

  /**
   * デフォルト表示設定.
   */
  private String defaultDispSettings;

  /**
   * デフォルト通知設定.
   */
  private NotificationSettings defaultNotificationSettings;
}

