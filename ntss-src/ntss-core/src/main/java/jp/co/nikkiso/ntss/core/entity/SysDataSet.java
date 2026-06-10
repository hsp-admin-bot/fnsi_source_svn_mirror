package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Column;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.JsonToken;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import static java.util.Collections.emptyList;

/**
 * データセットのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_data_set")
@Getter
@Setter
public class SysDataSet extends BaseEntity {

  /**
   * DB種別：db4.
   */
  public static final Integer DB_CLASS_DB4 = 1;

  /**
   * DB種別：db5.
   */
  public static final Integer DB_CLASS_DB5 = 2;

  /**
   * DB種別：db6.
   */
  public static final Integer DB_CLASS_DB6 = 3;

  // 2021/04/20 add start ウ
  /**
   * DB種別：mongodb.
   */
  public static final Integer DB_CLASS_MONGODB = 4;
  // 2021/04/20 add end ウ

  /**
   * 詳細クラス.
   */
  @Getter
  @Setter
  @JsonIgnoreProperties(ignoreUnknown=true)
  public static class Detail {

    /**
     * 変換リストクラス.
     */
    @Getter
    @Setter
    @JsonIgnoreProperties(ignoreUnknown=true)
    public static class convTableItem {
      /**
       * 値 デフォルト値.
       */
      public static final String CODE_DEFAULT = "";

      /**
       * 候補 デフォルト値.
       */
      public static final String ITEM_DEFAULT = "";

      /**
       * 出力文字列 デフォルト値.
       */
      public static final String DISP_DEFAULT = "";

      /**
       * 事前取得対象SQLコード.
       */
      @JsonProperty("code")
      private String code = CODE_DEFAULT;

      /**
       * 取得するSQL変数名.
       */
      @JsonProperty("item")
      private String item = ITEM_DEFAULT;

      /**
       * データ項目名.
       */
      @JsonProperty("disp")
      private String disp = DISP_DEFAULT;

    }

    /**
     * 取得した値を変数にして値を取得する他SQL設定クラス.
     */
    @Getter
    @Setter
    @JsonIgnoreProperties(ignoreUnknown=true)
    public static class convSqlItem {
      /**
       * 事前取得対象SQLコード デフォルト値.
       */
      public static final Long SQL_CODE_DEFAULT = (Long) null;

      /**
       * 他SQLに渡す際の変数名 デフォルト値.
       */
      public static final String TARGET_VAR_DEFAULT = "";

      /**
       * 他SQLから取得するデータ項目名 デフォルト値.
       */
      public static final String DATA_NAME_DEFAULT = "";

      /**
       * 事前取得対象SQLコード.
       */
      @JsonProperty("sql_cd")
      private Long sqlCd = SQL_CODE_DEFAULT;

      /**
       * 取得するSQL変数名.
       */
      @JsonProperty("target_var")
      private String targetVar = TARGET_VAR_DEFAULT;

      /**
       * データ項目名.
       */
      @JsonProperty("field_name")
      private String fieldName = DATA_NAME_DEFAULT;

    }

    /**
     * データカテゴリ デフォルト値.
     */
    public static final String DATA_CATEGORY_DEFAULT = "";

    /**
     * データクラス デフォルト値.
     */
    public static final String DATA_CLASS_DEFAULT = "";

    /**
     * データ項目コード デフォルト値.
     */
    public static final String DATA_CODE_DEFAULT = "";

    /**
     * データ項目名 デフォルト値.
     */
    public static final String DATA_NAME_DEFAULT = "";

    /**
     * フィールド名 デフォルト値.
     */
    public static final String FIELD_NAME_DEFAULT = "";

    /**
     * 変換リスト デフォルト値.
     */
    public static final String CONV_TABLE_DEFAULT = "";

    /**
     * 取得した値を変数にして値を取得する他SQL デフォルト値.
     */
    public static final String CONV_SQL_DEFAULT = "";

    /**
     * データ型 デフォルト値.
     */
    public static final String DATA_TYPE_DEFAULT = "";

    /**
     * プレビューデータ デフォルト値.
     */
    public static final String PREVIEW_DEFAULT = "";

    /**
     * 既定の書式 デフォルト値.
     */
    public static final String DISP_FORMAT_DEFAULT = "";

    /**
     * 計算式内使用可否 デフォルト値.
     */
    public static final String CAN_CALC_DEFAULT = "";

    /**
     * 施設フィルター種別 デフォルト値.
     */
    public static final String FACILITY_FILTER_TYPE_DEFAULT = "";

    /**
     * 施設コード配列 デフォルト値.
     */
    public static final String FACILITY_TABLE_DEFAULT = "";

    /**
     * データカテゴリ.
     */
    @JsonProperty("data_category")
    private String dataCategory = DATA_CATEGORY_DEFAULT;

    /**
     * データクラス.
     */
    @JsonProperty("data_class")
    private String dataClass = DATA_CLASS_DEFAULT;

    /**
     * データ項目コード.
     */
    @JsonProperty("data_code")
    private String dataCode = DATA_CODE_DEFAULT;

    /**
     * データ項目名.
     */
    @JsonProperty("data_name")
    private String dataName = DATA_NAME_DEFAULT;

    /**
     * フィールド名.
     */
    @JsonProperty("field_name")
    private String fieldName = FIELD_NAME_DEFAULT;

    /**
     * 変換リスト.
     */
    @JsonProperty("conv_table")
    private List<convTableItem> convTable = emptyList();

    /**
     * 変換リスト.
     */
    @JsonProperty("conv_sql")
    private convSqlItem convSql = null;

    /**
     * データ型.
     */
    @JsonProperty("data_type")
    private String dataType = DATA_TYPE_DEFAULT;

    /**
     * プレビューデータ.
     */
    @JsonProperty("preview")
    private String preview = PREVIEW_DEFAULT;

    /**
     * 既定の書式.
     */
    @JsonProperty("disp_format")
    private String dispFormat = DISP_FORMAT_DEFAULT;

    /**
     * 計算式内使用可否.
     */
    @JsonProperty("can_calc")
    private String canCalc = CAN_CALC_DEFAULT;

    /**
     * 施設フィルター種別.
     */
    @JsonProperty("facility_filter_type")
    private String facilityFilterType = FACILITY_FILTER_TYPE_DEFAULT;

    /**
     * 施設コード配列.
     */
    @JsonProperty("facility_table")
    private String facilityTable = FACILITY_TABLE_DEFAULT;

    /**
     * フィルター.
     */
    @JsonProperty("filter_type")
    private String filterType = "";

    // 2020-09-28 DataListデータリストにソート機能を追加 李 start
    /**
     * データ整列化.
     */
    @JsonProperty("data_sort")
    private String dataSort = "";
    // 2020-09-28 DataListデータリストにソート機能を追加 李 end

    // add 2021-08-30 6009画像 李 start
    /**
     * 画像.
     */
    @JsonProperty("is_image")
    private String isImage = "";
    // add 2021-08-30 6009画像 李 end
  }

  /**
   * 詳細情報クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class DetailInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 詳細のリスト.
     */
    private List<Detail> details;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public DetailInfo(String value) {
      try {
        Detail[] obj = objectMapper.readValue(value, Detail[].class);
        details = Arrays.asList(obj);
      } catch (IOException e) {
        throw new NtssException("データセットの詳細設定内容が不正です") {
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
   * 事前取得データ情報クラス.
   */
  @Getter
  @Setter
  public static class PreSqlInfoItem {
    /**
     * 事前取得対象SQLコード デフォルト値.
     */
    public static final Long SQL_CODE_DEFAULT = (Long) null;

    /**
     * 取得するSQL変数名 デフォルト値.
     */
    public static final String REPLACE_VAR_DEFAULT = "";

    /**
     * データ項目名 デフォルト値.
     */
    public static final String DATA_NAME_DEFAULT = "";

    /**
     * 事前取得対象SQLコード.
     */
    @JsonProperty("sql_cd")
    private Long sqlCd = SQL_CODE_DEFAULT;

    /**
     * 取得するSQL変数名.
     */
    @JsonProperty("replace_var")
    private String replaceVar = REPLACE_VAR_DEFAULT;

    /**
     * データ項目名.
     */
    @JsonProperty("field_name")
    @JsonDeserialize(using = FieldNameDeserializer.class)
    private String fieldName = DATA_NAME_DEFAULT;

  }

  /**
   * PreSqlInfoItemの"field_name"プロパティをデシリアライズするためのカスタムデシリアライザ.
   * JSONの値が「文字列」の場合はそのまま文字列として、
   * 「配列」の場合は配列全体をJSON文字列として読み込む。
   */
  public static class FieldNameDeserializer extends JsonDeserializer<String> {

      @Override
      public String deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
          // 現在のJSONトークンを取得
          JsonToken currentToken = p.currentToken();

          if (currentToken == JsonToken.START_ARRAY) {
              // トークンが配列の開始 `[` の場合、配列全体をツリーとして読み取り、その文字列表現を返す
              // 例: ["field_a", "field_b"] -> "[\"field_a\",\"field_b\"]" という文字列になる
              return p.readValueAsTree().toString();
          } else {
              // トークンが文字列の場合、そのテキスト値をそのまま返す
              // 例: "field_a" -> "field_a" という文字列になる
              return p.getText();
          }
      }
  }

  /**
   * 事前取得データ情報クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class PreSqlInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 詳細のリスト.
     */
    private List<PreSqlInfoItem> items;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public PreSqlInfo(String value) {
      try {
        if (value == null || value.isEmpty()) {
          items = new ArrayList<PreSqlInfoItem>();
        } else {
          PreSqlInfoItem[] obj = objectMapper.readValue(value, PreSqlInfoItem[].class);
          items = Arrays.asList(obj);
        }
      } catch (IOException e) {
        throw new NtssException("データセットの事前取得データ情報設定内容が不正です") {
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
   * 帳票種別.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class ReportClasses {

    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 帳票種別.
     */
    @JsonProperty("classes")
    private List<Integer> classes = null;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ReportClasses(String value) {
      try {
        ReportClasses obj = objectMapper.readValue(value, ReportClasses.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("sys_data_setテーブルreport_classの値が不正です") {
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
   * ID(内部用ID).
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long sqlCd;

  /**
   * SQL.
   */
  private String sql;

  /**
   * DB種別.
   */
  private Integer dbClass;

  /**
   * 詳細.
   */
  @Column(name = "detail")
  private DetailInfo detailInfo;

  /**
   * 事前取得データ情報
   */
  private PreSqlInfo preSqlInfo;

  /**
   * 繰返し可否フラグ.
   */
  private String canRepeat;

  /**
   * 使用用途.
   */
  private String useApplication;

  /**
   * 帳票種別.
   */
  private ReportClasses reportClass;

  /**
   * 備考.
   */
  private String memo;

}
