package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
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
 * 帳票マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_report")
@Getter
@Setter
public class MstReport extends BaseEntity {

  /**
   * パス情報クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class ReportPath {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * バケット デフォルト値.
     */
    public static final String BUCKET_DEFAULT = "";

    /**
     * 圧縮ファイル名（帳票デザインExcel） デフォルト値.
     */
    public static final String XLSX_ZIP_DEFAULT = "";

    /**
     * 圧縮ファイル名（帳票デザインHtmlと帳票定義Xml） デフォルト値.
     */
    public static final String REPORT_ZIP_DEFAULT = "";

    /**
     * 帳票デザインExcelファイル名 デフォルト値.
     */
    public static final String XLSX_FILENAME_DEFAULT = "";

    /**
     * 帳票デザインHtmlファイル名 デフォルト値.
     */
    public static final String HTML_FILENAME_DEFAULT = "";

    /**
     * 帳票定義Xmlファイル名 デフォルト値.
     */
    public static final String XML_FILENAME_DEFAULT = "";

    /**
     * バケット.
     */
    @JsonProperty("bucket")
    private String bucket = BUCKET_DEFAULT;

    /**
     * 帳票デザインExcel 圧縮ファイル.
     */
    @JsonProperty("xlsx_zip")
    private String xlsxZip = XLSX_ZIP_DEFAULT;

    /**
     * Htmlと帳票定義xml 圧縮ファイル.
     */
    @JsonProperty("report_zip")
    private String reportZip = REPORT_ZIP_DEFAULT;

    /**
     * 帳票デザインExcelファイル名.
     */
    @JsonProperty("xlsx_filename")
    private String xlsxFilename = XLSX_FILENAME_DEFAULT;

    /**
     * 帳票デザインHtmlファイル名.
     */
    @JsonProperty("html_filename")
    private String htmlFilename = HTML_FILENAME_DEFAULT;

    /**
     * 帳票定義Xmlファイル名.
     */
    @JsonProperty("xml_filename")
    private String xmlFilename = XML_FILENAME_DEFAULT;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ReportPath(String value) {
      try {
        ReportPath obj = objectMapper.readValue(value, ReportPath.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("帳票マスタのファイルパス情報設定内容が不正です") {
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
   * 帳票追加情報クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class AdditionalInfo {

    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 面付(ヨコ).
     */
    @JsonProperty("col_count")
    private int colCount = 0;

    /**
     * 面付(タテ).
     */
    @JsonProperty("row_count")
    private int rowCount = 0;

    /**
     * 印刷方向.
     */
    @JsonProperty("print_direct")
    private int printDirect = 0;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    public AdditionalInfo(String value) {
      try {
        AdditionalInfo obj = objectMapper.readValue(value, AdditionalInfo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("帳票マスタの追加情報設定内容が不正です") {
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

  // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
  /**
   * パス情報クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class Extraction {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 用途コード デフォルト値.
     */
    public static final String USE_CD = "";

	// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//    /**
//     * 記録簿コード デフォルト値.
//     */
//    public static final String RECORD_CD = "";
//
//    /**
//     * 点検レイアウトコード デフォルト値.
//     */
//    public static final String LAYOUT_CD = "";

    /**
     * 型式コード デフォルト値.
     */
    public static final String MACHINE_TYPE_CD = "";
	// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

    /**
     * 用途コード.
     */
    @JsonProperty("layout_class")
    private String useCD = USE_CD;

	// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//    /**
//     * 記録簿コード.
//     */
//    @JsonProperty("detail_info_class")
//    private String recordCD = RECORD_CD;
//
//    /**
//     * 点検レイアウトコード.
//     */
//    @JsonProperty("mainte_layout_cd")
//    private String layoutCD = LAYOUT_CD;

    /**
     * 型式コード.
     */
    @JsonProperty("machine_type_cd")
    private String machineTypeCD = MACHINE_TYPE_CD;
	// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public Extraction(String value) {
      try {
        Extraction obj = objectMapper.readValue(value, Extraction.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("帳票マスタのファイルパス情報設定内容が不正です") {
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
  // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

  /**
   * ID(内部用ID).
   */
  @Id
  // del 8559 動作に関する指摘２　NG4　吉 start
  //@GeneratedValue(strategy = GenerationType.IDENTITY)
  // del 8559 動作に関する指摘２　NG4　吉 end
  private Long reportCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 帳票名.
   */
  private String reportName;

  /**
   * 3ファイルのパス.
   */
  private ReportPath reportPath;

  /**
   * 帳票種別.
   */
  private Integer reportClass;

  /**
   * 帳票区分.
   */
  private Integer reportType;

  /**
   * 抽出条件.
   */
  // mod FNSI-699,700,751 装置帳票の記録簿対応 夏 start
  //private String extractionCondition;
  private Extraction extractionCondition;
  // mod FNSI-699,700,751 装置帳票の記録簿対応 夏 end

  /**
   * プリンター初期値.
   */
  private Long defaultPrinter;

  /**
   * 表示フラグ. 0 : 非表示、1 : 仮表示
   */
  private String isDisp;

  /**
   * 削除フラグ. 0 : 通常、1 : 削除
   */
  private String isDel;

  /**
   * 帳票に関する追加情報
   */
  private AdditionalInfo additionalInfo;

  // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 start
  /**
   * 表示順
   */
  private Integer dispOrder;
  // add FNSI-「帳票マスタ」にソート機能が必要:各列でソートができるようにする 孫 end

  // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
  /**
   * 帳票更新履歴情報
   */
  private ReportHstInfo reportHstInfo;
  //add 5565 並び替えを実施してもその情報が保持されない 吉 start
  private String reportSetting;
  //add 5565 並び替えを実施してもその情報が保持されない 吉 end
  //add 6608 2次元帳票excel エクスポート 吉 start
  // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy start
//  private String multiTotalDefaul;
  // del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy end
  //add 6608 2次元帳票excel エクスポート 吉 end

  /**
   * 1カラム帳票更新履歴を表すクラス.
   */
  @Getter
  @Setter
  @JsonIgnoreProperties(ignoreUnknown=true)
  public static class Item
  {
    /**
     * 版数 デフォルト値.
     */
    public static final String CTL_NO_DEFAULT = "";

    /**
     * 更新日時(yyyyMMddHHmmss) デフォルト値.
     */
    public static final String UPD_DATE_DEFAULT = "";

    /**
     * バケット デフォルト値.
     */
    public static final String BUCKET_DEFAULT = "";

    /**
     * 圧縮ファイル名（帳票デザインExcel） デフォルト値.
     */
    public static final String XLSX_ZIP_DEFAULT = "";

    /**
     * 圧縮ファイル名（帳票デザインHtmlと帳票定義Xml） デフォルト値.
     */
    public static final String REPORT_ZIP_DEFAULT = "";

    /**
     * 帳票デザインExcelファイル名 デフォルト値.
     */
    public static final String XLSX_FILENAME_DEFAULT = "";

    /**
     * 帳票デザインHtmlファイル名 デフォルト値.
     */
    public static final String HTML_FILENAME_DEFAULT = "";

    /**
     * 帳票定義Xmlファイル名 デフォルト値.
     */
    public static final String XML_FILENAME_DEFAULT = "";

    /**
     * 適用フラグ(適用：1、未適用：0) デフォルト値.
     */
    public static final String IS_SELECT_DEFAULT = "";

    /**
     * 更新者ID デフォルト値.
     */
    public static final String UPD_USER_ID_DEFAULT = "";

    /**
     * 更新者名 デフォルト値.
     */
    public static final String UPD_USER_NAME_DEFAULT = "";

    /**
     * 版数.
     */
    @JsonProperty("ctl_no")
    private String ctlNo = CTL_NO_DEFAULT;

    /**
     * 更新日時(yyyyMMddHHmmss).
     */
    @JsonProperty("upd_date")
    private String updDate = UPD_DATE_DEFAULT;

    /**
     * バケット.
     */
    @JsonProperty("bucket")
    private String bucket = BUCKET_DEFAULT;

    /**
     * 帳票デザインExcel 圧縮ファイル.
     */
    @JsonProperty("xlsx_zip")
    private String xlsxZip = XLSX_ZIP_DEFAULT;

    /**
     * Htmlと帳票定義xml 圧縮ファイル.
     */
    @JsonProperty("report_zip")
    private String reportZip = REPORT_ZIP_DEFAULT;

    /**
     * 帳票デザインExcelファイル名.
     */
    @JsonProperty("xlsx_filename")
    private String xlsxFilename = XLSX_FILENAME_DEFAULT;

    /**
     * 帳票デザインHtmlファイル名.
     */
    @JsonProperty("html_filename")
    private String htmlFilename = HTML_FILENAME_DEFAULT;

    /**
     * 帳票定義Xmlファイル名.
     */
    @JsonProperty("xml_filename")
    private String xmlFilename = XML_FILENAME_DEFAULT;

    /**
     * 適用フラグ(適用：1、未適用：0).
     */
    @JsonProperty("is_select")
    private String isSelect = IS_SELECT_DEFAULT;

    /**
     * 更新者ID.
     */
    @JsonProperty("upd_user_id")
    private String updUserId = UPD_USER_ID_DEFAULT;

    /**
     * 更新者名.
     */
    @JsonProperty("upd_user_name")
    private String updUserName = UPD_USER_NAME_DEFAULT;
  }

  /**
   * 帳票更新履歴情報クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class ReportHstInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 帳票更新履歴のリスト.
     */
    @JsonProperty("items")
    private List<Item> items;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public ReportHstInfo(String value) {
      try {
        ReportHstInfo obj = objectMapper.readValue(value, ReportHstInfo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("帳票マスタの帳票更新履歴情報設定内容が不正です") {
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
  // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
}
