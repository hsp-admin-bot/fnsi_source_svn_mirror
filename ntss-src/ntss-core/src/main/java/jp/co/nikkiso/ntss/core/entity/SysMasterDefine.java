package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonValue;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import com.google.common.base.CaseFormat;

import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboDefNode;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_CODE;

/**
 * マスタ定義のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_master_define")
@Getter
@Setter
public class SysMasterDefine extends BaseEntity {

  /**
   * バリデーション設定クラス.
   */
  @Getter
  @Setter
  public static class Validation {

    /**
     * 桁数.
     */
    @JsonProperty("maxlength")
    private Integer maxlength;

    /**
     * 最小値.
     */
    @JsonProperty("min")
    private BigDecimal min;

    /**
     * 最大値.
     */
    @JsonProperty("max")
    private BigDecimal max;

    /**
     * 必須.
     */
    @JsonProperty("required")
    private boolean required = false;

  }

  /**
   * 1カラムを表すクラス.
   */
  @Getter
  @Setter
  public static class Field {

    /**
     * 物理項目名 デフォルト値.
     */
    public static final String PHYSICAL_NAME_DEFAULT = "";

    /**
     * 論理項目名 デフォルト値.
     */
    public static final String TITLE_DEFAULT = "";

    /**
     * 物理項目名.
     */
    @JsonProperty("physical_name")
    private String physicalName = PHYSICAL_NAME_DEFAULT;

    /**
     * 論理項目名.
     */
    @JsonProperty("title")
    private String title = TITLE_DEFAULT;

    /**
     * タイプ.
     */
    @JsonProperty("type")
    private FieldType type;

    /**
     * 選択可否.
     */
    @JsonProperty("selectable")
    private Boolean selectable;

    /**
     * 編集可否.
     */
    @JsonProperty("editable")
    private Boolean editable;

    /**
     * バリデーション設定.
     */
    @JsonProperty("validation")
    private Validation validation;

    /**
     * 書式.
     */
    @JsonProperty("format")
    private String format;

    /**
     * 別名指定.
     */
    @JsonProperty("alias")
    private String alias;

    /**
     * 非表示指定.
     */
    @JsonProperty("hidden")
    private Boolean hidden;

    /**
     * 固定列指定.
     */
    @JsonProperty("locked")
    private Boolean locked;

    /**
     * 初期値.
     */
    @JsonProperty("defaultValue")
    private String defaultValue;

    /**
     * フィールドの名称を取得します.
     *
     * @return 別名が設定されている場合：別名、別名が設定されていない場合：物理名称
     */
    public String getFieldName() {
      return Optional.ofNullable(this.alias).orElse(this.physicalName);
    }

    /**
     * キャメルケースのフィールド名称を取得します.
     *
     * @return 別名が設定されている場合：別名、別名が設定されていない場合：物理名称のキャメルケース
     */
    public String getCamelFieldName() {
      return CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, getFieldName());
    }

    /**
     * エイリアスのフィールド名称を取得します.上記メソットgetCamelFieldName()はキャメルケースのフィールド名称を取得できない.
     *
     * @return 別名が設定されている場合：別名、別名が設定されていない場合：物理名称のキャメルケース
     */
    public String getAliasFieldName() {
        String alias =getFieldName();
        if(alias.indexOf("_") != -1) {
      	  alias = getCamelFieldName();
        }
        return alias;
    }

    /**
     * KendoUI用のフィールドタイプを取得します.
     * @return コンボ・表示・削除・JSONの場合：string、左記以外：そのまま
     */
    public FieldType getSchemaType() {
      // コンボ・表示フラグはStringとして作成
      if (this.type.equals(SysMasterDefine.FieldType.COMBO_REFERENCE) ||
          this.type.equals(SysMasterDefine.FieldType.COMBO_SPECIFIC) ||
          this.type.equals(SysMasterDefine.FieldType.DISP) ||
          this.type.equals(SysMasterDefine.FieldType.DEL) ||
          this.type.equals(SysMasterDefine.FieldType.JSON)) {
        return SysMasterDefine.FieldType.STRING;
      } else {
        return this.type;
      }
    }

    /**
     * コンボ表示対象項目かを取得します.
     *
     * @return コンボ・表示フラグ : True、左記以外：false
     */
    public boolean isComboColumn() {
      // コンボ・表示フラグであればTrue
      if (this.type.equals(SysMasterDefine.FieldType.COMBO_REFERENCE)
          || this.type.equals(SysMasterDefine.FieldType.COMBO_SPECIFIC)
          || this.type.equals(SysMasterDefine.FieldType.DISP)) {
        return true;
      } else {
        return false;
      }
    }

    /**
     * ALIASでCode指定された項目かを取得します.
     *
     * @return CODE : True、左記以外：false
     */
    public boolean isAliasCodeColumn() {
      // ALIASにCODEが指定されていればTrue
      return ALIAS_CODE.equals(alias);
    }

    /**
     * 非表示対象項目かを取得します.
     *
     * @return 非表示 : True、左記以外：false
     */
    public boolean isHiddenColumn() {
      // 非表示が指定されていればTrue
      return Optional.ofNullable(hidden).orElse(false);
    }

    /**
     * 固定列対象項目かを取得します.
     *
     * @return 固定列 : True、左記以外：false
     */
    public boolean isLockedColumn() {
      // 非表示が指定されていればTrue
      return Optional.ofNullable(locked).orElse(false);
    }

    /**
     * SQL文作成時に使用するカラム名を取得します.
     *
     * @return CODEカラム：型変換付きの物理名称、それ以外場合：物理名称
     */
    public String getSqlColumnName() {
      // CODEカラムには、Serial型とBigSerial型が存在するため、BigSerial型での取得時の型に統一する
      if (isAliasCodeColumn()) {
        return "CAST(" + physicalName + " AS BIGINT)";
      } else {
        return physicalName;
      }
    }

  }

  /**
   * 項目のタイプクラス.
   */
  private static ObjectMapper createObjectMapper() {
    return new ObjectMapper().rebuild().configureForJackson2().build();
  }

  public enum FieldType {

    /**
     * string型のカラム定義.
     */
    STRING("string"),

    /**
     * number型のカラム定義.
     */
    NUMBER("number"),

    /**
     * boolean型のカラム定義.
     */
    BOOLEAN("boolean"),

    /**
     * date型のカラム定義.
     */
    DATE("date"),

    /**
     * 固定コンボ型のカラム定義.
     */
    COMBO_SPECIFIC("combo1"),

    /**
     * 他テーブル参照型のカラム定義.
     */
    COMBO_REFERENCE("combo2"),

    /**
     * 表示フラグ型のカラム定義.
     */
    DISP("disp"),

    /**
     * 削除フラグ型のカラム定義.
     */
    DEL("del"),

    /**
     * モーダル呼び出しボタン型のカラム定義.
     */
    MODAL("modal"),

    /**
     * JSON型のカラム定義.
     */
    JSON("json"),

    /**
     * INET型のカラム定義
     */
    INET("inet"),

    /**
     * color型のカラム定義
     */
    COLOR("color"),

    /**
     * 暗号化したstring型のカラム定義
     */
    CRYPTO("crypto"),

    /**
     * textarea型のカラム定義
     */
    TEXTAREA("textarea");

    private final String value;

    private FieldType(String value) {
      this.value = value;
    }

    @JsonCreator
    public static FieldType of(String value) {
      for (FieldType jobType : FieldType.values()) {
        if (jobType.value.equals(value)) {
          return jobType;
        }
      }
      throw new IllegalArgumentException(value);
    }

    @JsonValue
    public String getValue() {
      return value;
    }
  }

  /**
   * カラム情報クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class ColumnInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = createObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * カラムのリスト.
     */
    @JsonProperty("fields")
    private List<Field> fields;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ColumnInfo(String value) {
      try {
        ColumnInfo obj = objectMapper.readValue(value, ColumnInfo.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        throw new NtssException("マスタ定義のカラム情報設定内容が不正です") {
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
      } catch (JacksonException e) {
        return null;
      }
    }
  }

  /**
   * コンボバリュークラス.
   */
  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class ComboValue {
    /**
     * コード.
     */
    private Object value;
    /**
     * テキスト.
     */
    private String text;
  }

  /**
   * 1コンボを表すクラス.
   */
  @Getter
  @Setter
  @AllArgsConstructor
  @NoArgsConstructor
  public static class Combo {

    /**
     * カラム名 デフォルト値.
     */
    private final String PHYSICAL_NAME_DEFAULT = "";

    /**
     * カラム名.
     */
    @JsonProperty("physical_name")
    private String physicalName = PHYSICAL_NAME_DEFAULT;

    /**
     * コンボリスト.
     */
    @JsonProperty("values")
    private List<ComboValue> values;

  }

  /**
   * コンボデータクラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class ComboData {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = createObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * コンボのリスト.
     */
    @JsonProperty("combos")
    private List<Combo> combos;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ComboData(String value) {
      try {
        ComboData obj = objectMapper.readValue(value, ComboData.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        throw new NtssException("マスタ定義のコンボデータ設定内容が不正です") {
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
      } catch (JacksonException e) {
        return null;
      }
    }
  }

  /**
   * 参照型コンボの構造データクラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class ReferenceComboDef {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = createObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 参照型コンボの構造データ
     */
    @JsonProperty("combos")
    private List<ReferenceComboDefNode> list;

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
      } catch (JacksonException e) {
        throw new NtssException("参照型コンボ定義の設定内容が不正です") {
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
      } catch (JacksonException e) {
        return null;
      }
    }
  }

  /**
   * マスタ名(表示用).
   */
  private String masterName;

  /**
   * マスタ名(物理名称).
   */
  @Id
  private String masterPhysicalName;

  /**
   * 表示区分.<br>
   * <li>1：日機装社員のみ
   * <li>2：制限なし
   */
  private String dispClass;

  /**
   * 表示管理レベル.<br>
   * <li>1：全ユーザ
   * <li>2：管理者のみ
   * <li>3：日機装社員のみ
   * <li>4：日機装社員・管理者のみ
   */
  private String editLevel;

  /**
   * マスタ編集画面の起動方法.<br>
   * <li>1：モード1
   * <li>2：モード2
   */
  private String mode;

  /**
   * 並び替え可否.<br>
   * <li>0：変更不可
   * <li>1：変更可能
   */
  private String allowSort;

  /**
   * 新規レコード追加可否.<br>
   * <li>0：変更不可
   * <li>1：変更可能
   */
  private String allowAddRecord;

  /**
   * 表示順.
   */
  private Integer dispOrder;

  /**
   * カラム情報.
   */
  private ColumnInfo columnInfo;

  /**
   * コンボデータ.
   */
  private ComboData comboData;

  /**
   * 参照型コンボの構造データ
   */
  private Optional<ReferenceComboDef> referenceComboDef;

  /**
   * システム利用表示区分
   */
  private String systemUseDisp;
}
