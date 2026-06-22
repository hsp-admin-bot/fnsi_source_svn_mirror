package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.JsonNode;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

import static java.util.Collections.emptyList;

/**
 * 利用者マスタ(医療情報DB)のEntity.
 */
@Entity(listener = BaseEntityListener.class , naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_user")
@Getter
@Setter
@ToString
public class MstUser extends BaseEntity {

  /**
   * 共通設定タブ定義の個人設定情報の設定値を格納するクラス
   */
  @Getter
  @Setter
  @NoArgsConstructor
  public static class SettingValue {
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

    // add FNSI-重要通知設定の追加 江 start
    /**
     * 設定項目ID
     */
    @JsonProperty("setting_important")
    private Object settingImportant;
    // add FNSI-重要通知設定の追加 江 end

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public SettingValue(String value) {
      try {
        SettingValue obj = objectMapper.readValue(value, SettingValue.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        throw new NtssException("共通設定タブ定義設定項目情報の個人設定内容が不正です", e);
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
   * 共通設定タブの個人設定情報を表すクラス.
   */
  @Getter
  @Setter
  @NoArgsConstructor
  public static class PersonalSetting {
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
    private List<SettingValue> values = emptyList();

    // add FNSI-重要通知設定の追加 江 start
    /**
     * 設定値情報
     */
    @JsonProperty("setting_important")
    private List<SettingValue> settingImportant = emptyList();
    // add FNSI-重要通知設定の追加 江 end

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    public PersonalSetting(String value) {
      try {
        PersonalSetting obj = objectMapper.readValue(value, PersonalSetting.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        throw new NtssException("共通設定タブ定義設定項目情報の個人設定内容が不正です", e);
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
   * ユーザー設定クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class UserSettings {
    /**
     * ObjectMapper
     */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /**
     * ModelMapper
     */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * メニュー表示フラグ デフォルト値.
     */
    public static final Integer IS_DISP_MENU_DEFAULT = 1;

    /**
     * フォントサイズ デフォルト値.
     */
    public static final Integer FONT_SIZE_DEFAULT = 1;

    /**
     * テーマ デフォルト値.
     */
    public static final Integer THEME_DEFAULT = 0;

    /**
     * 使用可能メニュー デフォルト値.
     */
    public static final List<String> USE_FUNCTIONS_DEFAULT = emptyList();

    /**
     * 初期表示機能コード デフォルト値.
     */
    public static final String INITIAL_FUNCTION_DEFAULT = "";

    /**
     * 使用可能機能 デフォルト値.
     */
    public static final List<String> AUTHORIZED_FUNCTIONS_DEFAULT = emptyList();

    /**
     * 許可権限コード デフォルト値.
     */
    public static final List<String> AUTHORIZED_AUTHORITIES_DEFAULT = emptyList();

    /**
     * 共通設定タブ定義個人設定値 デフォルト値
     */
    public static final List<PersonalSetting> PERSONAL_SETTINGS_DEFAULT = emptyList();

    /**
     * 個人設定タブ デフォルト設定 デフォルト値.
     */
    public static final JsonNode DEFAULT_SETTING = objectMapper.createObjectNode();

    /**
     * 画面フレーム分割 デフォルト値.
     */
    public static final Integer IS_SPLIT_FRAME_DEFAULT = 1;

    /**
     * 患者共有設定 デフォルト値.
     */
    public static final Integer PAT_SHARE_MODE_DEFAULT = 1;

    /**
     * メニュー表示フラグ.
     */
    @JsonProperty("is_disp_menu")
    private Integer isDispMenu = IS_DISP_MENU_DEFAULT;

    /**
     * フォントサイズ.
     */
    @JsonProperty("font_size")
    private Integer fontSize = FONT_SIZE_DEFAULT;

    /**
     * テーマ.
     */
    @JsonProperty("theme")
    private Integer theme = THEME_DEFAULT;

    /**
     * 使用機能コード.
     */
    @JsonProperty("use_functions")
    private List<String> useFunctions = USE_FUNCTIONS_DEFAULT;

    /**
     * 初期表示機能コード.
     */
    @JsonProperty("initial_function")
    private String initialFunction = INITIAL_FUNCTION_DEFAULT;

    /**
     * 使用可能機能コード.
     */
    @JsonProperty("authorized_functions")
    private List<String> authorizedFunctions = AUTHORIZED_FUNCTIONS_DEFAULT;

    /**
     * 許可権限コード.
     */
    @JsonProperty("authorized_authorities")
    private List<String> authorizedAuthorities = AUTHORIZED_AUTHORITIES_DEFAULT;

    @JsonProperty("personal_settings")
    private List<PersonalSetting> personalSettings = PERSONAL_SETTINGS_DEFAULT;

    /**
     * 個人設定タブ デフォルト設定.
     */
    @JsonProperty("default_setting")
    private JsonNode defaultSetting = DEFAULT_SETTING;

    /**
     * 予実リスト表示パターン.
     */
    @JsonProperty("ind_rst_pattern")
    private Integer indRstPattern = null;

    /**
     * 画面フレーム分割.
     */
    @JsonProperty("is_split_frame")
    private Integer isSplitFrame = IS_SPLIT_FRAME_DEFAULT;

    /**
     * 患者共有設定.
     */
    @JsonProperty("pat_share_mode")
    private Integer patShareMode = PAT_SHARE_MODE_DEFAULT;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    public UserSettings(String value) {
      try {
        UserSettings obj = objectMapper.readValue(value, UserSettings.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        throw new NtssException("利用者マスタのユーザ設定内容が不正です", e);
      }
    }

    /**
     * 基本型の値を返す.
     *
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
   * 利用者ID(内部用ID).
   */
  @Id
  private Long userId;

  /**
   * ユーザー設定.
   */
  private UserSettings userSettings;

  /**
   * 仮登録フラグ.
   * 0 : 本登録、1 : 仮登録
   */
  private int isProvisional;

  /**
   * 患者ID.
   */
  private Long patId;

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
   * 検索条件
   */
  private String tmpLogSearchCondition;
//del 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
  /**
   * アクセスカード番号.
   */
//private String cardIdm;
//del 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
  /**
   * 秘密鍵.
   */
  private String secretKey;

  /**
   * 仮登録秘密鍵フラグ.
   * 0 : 本登録、1 : 仮登録
   */
  private int isSetQrCode;

  /**
   * 個人情報取扱い同意フラグ
   * 0:未同意、1：同意済
   */
  private int isConsent;

  /**
   * 個人情報取扱い同意日時.
   */
  private Timestamp consentDate;

  /**
   * パスワード変更日時.
   */
  private Timestamp regPasswordDate;

  /**
   * 施設コード.
   */
  private String facilityCd;

}
