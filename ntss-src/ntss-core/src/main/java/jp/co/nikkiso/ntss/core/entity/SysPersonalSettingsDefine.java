package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonValue;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity(immutable = true, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_personal_settings_define")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class SysPersonalSettingsDefine {

  /**
   * 項目のタイプ（どの形式で入力させるか）
   */
  public enum ItemType {
    NUMBER("number"),
    STRING("string"),
    COMBO1("combo1"),
    COMBO2("combo2");

    private final String value;

    ItemType(String value) {
      this.value = value;
    }

    @JsonCreator
    public static ItemType of(String value) {
      for (ItemType itemType : ItemType.values()) {
        if (itemType.value.equals(value)) {
          return itemType;
        }
      }
      throw new IllegalArgumentException(value);
    }

    @JsonValue
    public String getValue() {
      return this.value;
    }
  }

  /**
   * バリデーション設定クラス
   */
  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class ItemInfoValidation {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 桁数
     */
    @JsonProperty("maxlength")
    private Integer maxlength;

    /**
     * 最小値（不要の場合はnull）
     */
    @JsonProperty("min")
    private BigDecimal min;

    /**
     * 最大値（不要の場合はnull）
     */
    @JsonProperty("max")
    private BigDecimal max;

    /**
     * 必須
     */
    @JsonProperty("required")
    private Boolean required;

    /**
     * 小数桁数（不要の場合はnull）
     */
    @JsonProperty("digit")
    private Short digit;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ItemInfoValidation(String value) {
      try {
        ItemInfoValidation obj
          = objectMapper.readValue(value, ItemInfoValidation.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("バリデーション定義の設定内容が不正です") {
        };
      }
    }
  }

  /**
   * 設定項目情報を表すクラス
   */
  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class ItemInfoDetail {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 項目形式
     */
    @JsonProperty("type")
    private ItemType type;

    /**
     * 表示名
     */
    @JsonProperty("title")
    private String title;

    /**
     * 設定項目ID
     */
    @JsonProperty("identifier")
    private String identifier;

    /**
     * バリデーション設定
     */
    @JsonProperty("validation")
    private ItemInfoValidation validation;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ItemInfoDetail(String value) {
      try {
        ItemInfoDetail obj
          = objectMapper.readValue(value, ItemInfoDetail.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("設定項目情報の設定内容が不正です") {
        };
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
      } catch (JsonProcessingException e) {
        return null;
      }
    }
  }

  /**
   * 設定項目情報を表すクラス
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class ItemInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 詳細
     */
    @JsonProperty("item_info")
    private List<ItemInfoDetail> itemInfoDetail;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ItemInfo(String value) {
      try {
        ItemInfo obj
          = objectMapper.readValue(value, ItemInfo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("設定項目情報が不正です") {
        };
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
      } catch (JsonProcessingException e) {
        return null;
      }
    }
  }

  /**
   * 固定コンボの項目を表すクラス
   */
  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class StaticComboValue {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 表示名
     */
    @JsonProperty("text")
    private Object text;

    /**
     * 値
     */
    @JsonProperty("value")
    private Object value;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public StaticComboValue(String value) {
      try {
        StaticComboValue obj
          = objectMapper.readValue(value, StaticComboValue.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("固定型コンボデータの値が不正です") {
        };
      }
    }
  }

  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class StaticCombo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 定義元の設定項目ID
     */
    @JsonProperty("setting_identifier")
    private String settingIdentifier;

    /**
     * コンボに出す項目
     */
    @JsonProperty("values")
    private List<StaticComboValue> values;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public StaticCombo(String value) {
      try {
        StaticCombo obj
          = objectMapper.readValue(value, StaticCombo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("固定型コンボデータの設定内容が不正です") {
        };
      }
    }
  }

  /**
   * 固定型コンボデータを表すクラス
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class StaticComboInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    @JsonProperty("combos")
    private List<StaticCombo> combos;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public StaticComboInfo(String value) {
      try {
        StaticComboInfo obj
          = objectMapper.readValue(value, StaticComboInfo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("固定型コンボデータの定義内容が不正です") {
        };
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
      } catch (JsonProcessingException e) {
        return null;
      }
    }
  }

  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class TargetTable {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 参照マスタの物理名
     */
    @JsonProperty("name")
    private String name;

    /**
     * 参照先マスタのプライマリキーとなる列の物理名
     */
    @JsonProperty("identifier")
    private String identifier;

    /**
     * 表示する列の物理名
     */
    @JsonProperty("display_column")
    private String displayColumn;

    /**
     * 値となる列の物理名
     */
    @JsonProperty("referenced_column")
    private String referencedColumn;

    /**
     * 参照型コンボサービス用のオブジェクトを返す
     */
    public ReferenceComboTargetTable convertToReferenceComboTargetTable() {
      return new ReferenceComboTargetTable(this.name, this.referencedColumn, this.displayColumn, this.identifier);
    }

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public TargetTable(String value) {
      try {
        TargetTable obj
          = objectMapper.readValue(value, TargetTable.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("参照先テーブルの設定内容が不正です") {
        };
      }
    }
  }

  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class ReferenceCombo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 定義元の設定項目ID
     */
    @JsonProperty("setting_identifier")
    private String settingIdentifier;

    /**
     * 参照先マスタ情報
     */
    @JsonProperty("target_table")
    private TargetTable targetTable;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ReferenceCombo(String value) {
      try {
        ReferenceCombo obj
          = objectMapper.readValue(value, ReferenceCombo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("参照型コンボデータの設定内容が不正です") {
        };
      }
    }
  }

  /**
   * 参照型コンボデータを表すクラス
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class ReferenceComboDef {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    @JsonProperty("combos")
    private List<ReferenceCombo> combos;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ReferenceComboDef(String value) {
      try {
        ReferenceComboDef obj
          = objectMapper.readValue(value, ReferenceComboDef.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("参照型コンボデータの定義内容が不正です") {
        };
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
      } catch (JsonProcessingException e) {
        return null;
      }
    }
  }

  /**
   * 共通設定ID.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer personalSettingsCd;

  /**
   * タブ定義コード
   */
  private Integer tabDefineCd;

  /**
   * 表示管理レベル
   */
  private String editLevel;

  /**
   * 設定項目情報
   */
  private ItemInfo itemInfo;

  /**
   * 固定型コンボデータ
   */
  private StaticComboInfo comboData;

  /**
   * 参照型コンボデータ
   */
  private ReferenceComboDef referenceComboDef;

  /**
   * 表示可能なタブかどうかを返す。true: 表示可能、false: 表示不可能
   * @param userType 利用者種別（0: 一般ユーザ、1: 日機装ユーザ）
   * @param isAdministrator 管理者フラグ（0: 一般ユーザ、1: 管理者ユーザ）
   * @return 表示可能なタブかどうか
   */
  public boolean canShow(Integer userType, Integer isAdministrator) {
    if(this.editLevel.equals("1")) return true;

    if(this.editLevel.equals("2")) return isAdministrator.equals(1);

    if(this.editLevel.equals("3")) return userType.equals(1);

    if(this.editLevel.equals("4")) return userType.equals(1) && isAdministrator.equals(1);

    return false;
  }

}
