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

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 体重計マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_weight")
@Getter
@Setter
public class MstWeight extends BaseEntity {

  /**
   * カード読み取りクラス
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class CheckContentClass {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * id
     */
    @JsonProperty("id")
    private String id;

    /**
     * 設定名称
     */
    @JsonProperty("name")
    private String name;

    /**
     * 表示順
     */
    @JsonProperty("disp_no")
    private Integer disp_no;

    /**
     * 表示カテゴリ
     */
    @JsonProperty("is_print")
    private List<String> is_print;
    /**
     * 正常範囲最大値
     */
    @JsonProperty("max_warn")
    private BigDecimal max_warn;
    /**
     * 正常範囲最小値
     */
    @JsonProperty("min_warn")
    private BigDecimal min_warn;
    /**
     * 送信可否カテゴリ
     */
    @JsonProperty("sendable")
    private Integer sendable;

    /**
     * 計算式
     */
    @JsonProperty("calculate")
    private String calculate;
    /**
     * 後文字列
     */
    @JsonProperty("after_word")
    private String after_word;
    /**
     * 前文字列
     */
    @JsonProperty("before_word")
    private String before_word;
    /**
     * 小数点桁数
     */
    @JsonProperty("decimal_point")
    private Integer decimal_point;
    /**
     * 警報チェック有無
     */
    @JsonProperty("is_check_warn")
    private String is_check_warn;
    /**
     * 前体重チェック
     */
    @JsonProperty("is_disp_before")
    private String is_disp_before;
    /**
     * 後体重チェック
     */
    @JsonProperty("is_disp_after")
    private String is_disp_after;

    /**
     * 条件チェック可否
     */
    @JsonProperty("use_condition")
    private Integer use_condition;
    /**
     * 比較カテゴリ
     */
    @JsonProperty("condition_ineq")
    private Integer condition_ineq;
    /**
     * 左辺
     */
    @JsonProperty("condition_left")
    private String condition_left;
    /**
     * 右辺
     */
    @JsonProperty("condition_right")
    private String condition_right;
    /**
     * 印刷パターン
     */
    @JsonProperty("print_datatype")
    private Integer print_datatype;
    /**
     * 印刷書式
     */
    @JsonProperty("print_default_format")
    private String print_default_format;

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public CheckContentClass(String value) {
      try {
        CheckContentClass obj = objectMapper.readValue(value, CheckContentClass.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
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
   * 体重計管理コード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long weightCd;
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 体重計番号
   */
  private Integer weightNo;
  /**
   * 体重計名称
   */
  private String weightName;
  /**
   * 体重計接続ポート
   */
  private String portName;

  /**
   * 体重計機種
   */
  private Short deviceClass;
  /**
   * 前体重自動送信
   */
  private String isAutoSendBefore;
  /**
   * 後体重自動送信
   */
  private String isAutoSendAfter;
  /**
   * 前体重自動送信待ち時間
   */
  private Short waitAutoSendBefore;

  /**
   * 後体重自動送信待ち時間
   */
  private Short waitAutoSendAfter;
  /**
   * 前体重印刷初期状態
   */
  private String isDefaultPrintBefore;

  /**
   * 後体重印刷初期状態
   */
  private String isDefaultPrintAfter;
  /**
   * 使用プリンター
   */
  private Short printerClass;
  /**
   * 所属透析室
   */
  private Integer bedGroupCd;

  /**
   * カードリーダー有無
   */
  private String isHasCardReader;
  /**
   * 体重測定チェック項目
   */
  private String checkContent;
  //  private List<CheckContentClass> checkContent;
  /**
   * 印字設定項目
   */
  private String printSetting;
  /**
   * 配色
   */
  private String colorSetting;
  /**
   * 音声
   */
  private String audioSetting;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 start
  /**
   * データ送信間隔（秒数）
   */
  private Integer dataSendInterval;
  /**
   * データ種類
   */
  private String dataSelectType;
  // add 2020-08-24 FNSI-仕様追加 田中衡機処理 夏 end

  // add 2020-12-23 FNSI-改修内容 体重計との通信フォーマットの外部定義化 商 start
  /**
   * 電文フォーマット
   */
  private String telegramFormat;
  // add 2020-12-23 FNSI-改修内容 体重計との通信フォーマットの外部定義化 商 end

  // #11987 2026.01.06 add カラム追加に対応 TDC石井 start
  /**
   * 体重計種別
   */
  private Short weightType;
  /**
   * スケールベッド設定(json文字列)
   */
  private String scaleBedSetting;
  // #11987 2026.01.06 add カラム追加に対応 TDC石井 end

}
