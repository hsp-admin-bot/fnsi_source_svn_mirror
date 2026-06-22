package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.util.List;
import java.util.Map;

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
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 連携施設マスタEntity
 *
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_coop_facility")
@Getter
@Setter
public class MstCoopFacility extends BaseEntity {

  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  /**
   * 送信・受信オペ別毎の設定を表すクラス
   */
  @Setter
  @Getter
  public static class CoopOpeCd {

    /**
     * 送信オペ.
     */
    @JsonProperty("ope_cd_send")
    private List<OpeCdStatus> opeCdSends;

    /**
     * 受信オペ.
     */
    @JsonProperty("ope_cd_receive")
    private List<OpeCdStatus> OpeCdReceives;
  }

  /**
   * オペ１件を表すクラス
   */
  @Setter
  @Getter
  public static class OpeCdStatus {

    /**
     * オペコード.
     */
    @JsonProperty("ope_cd")
    private String opeCd;

    /**
     * ステータス(on:有効、off:無効).
     */
    @JsonProperty("status")
    private String status;
  }
  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

  /**
   * 電文種別設定１件を表すクラス
   */
  @Setter
  @Getter
  public static class CoopOrdCd {

    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    /**
     * 連番.
     */
    @JsonProperty("ctl_no")
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //private String ctlNo;
    private Long ctlNo;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

    /**
     * 電文種別名.
     */
    @JsonProperty("coop_name")
    private String coopName;
    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

    /**
     * 電文種別.
     */
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
//    @JsonProperty("ord_cd")
//    private String ordCd;
    @JsonProperty("coop_cd")
    private String coopCd;
// mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

    // add 2020-11-04 FNSI-改修 外部連携705 徐 start TODO
    /**
     * スイッチID
     */
    /*@JsonProperty("switch_id")
    private String switchId;*/
    // add 2020-11-04 FNSI-改修 外部連携705 徐 end

    /**
     * INDEX作成有無.
     */
    @JsonProperty("createIndex")
    private boolean createIndex;

    /**
     * 受付番号採番有無.
     */
    @JsonProperty("is_get_no")
    private boolean isGetNo;

    /**
     * 電文種別のレポート可否
     */
    @JsonProperty("report")
    private boolean isReport;

    // add 2020-12-07 FNSI-改修 外部連携715 夏 start
    /**
     * 有効日
     */
    @JsonProperty("effect_days")
    private String effectDays;
    // add 2020-12-07 FNSI-改修 外部連携715 夏 end

    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    /**
     * 付帯情報（電文）.
     */
    @JsonProperty("coop_cd_index")
    private String coopCdIndex;

    /**
     * 向き（送受信）固定値:"S".
     */
    @JsonProperty("direction")
    private String direction;

    /**
     * 変換処理ステータス  固定値:"0".
     */
    @JsonProperty("ana_result")
    private String anaResult;

    /**
     * 配信処理ステータス  固定値:"0".
     */
    @JsonProperty("coop_result")
    private String coopResult;
    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

    // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 start
    /**
     * タイムアウト時間
     */
    @JsonProperty("time_out_second")
    private String timeOutSecond;
    // add 2020-12-21 FNSI-改修内容 変換処理中の処理スキップ機能を追加 商 end

    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    /**
     * カンマ区切りの形でオペコードを設定する。.
     */
    @JsonProperty("ope_cd")
    private List<String> opeCds;
    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    /**
     * レポートタイプ(JSON形式)
     */
    @JsonProperty("report_type")
    private List<Map<String, String>> reportType;

    /** 連携版番号 */
    @JsonProperty("coop_version")
    private String coopVersion;

    /** 電子カルテ種別 */
    @JsonProperty("key0")
    private String key0;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    /** CRUD変更 */
    @JsonProperty("change_crud")
    private String changeCrud;

    /** ベンダー名 */
    @JsonProperty("coop_vender")
    private String coopVender;
  }

  /**
   * レポートタイプ
   */
  @AllArgsConstructor
  @Getter
  public static enum ReportType {
    /** XMLとPDFをまとめてtarにして送付 */
    TAR("tar"),
    /** PDFを送付 */
    PDF("pdf"),
    /** XMLを送付 */
    XML("xml"),
    /** XMLとPDFを別々に送付(リスト有) */
    XML_PDF("xmlpdf"),
    /** XMLとPDFを別々に送付(リスト無) */
    PDF_XML("pdfxml"),
    // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    /** NKK連携、XMLとPDFを別々に送付(リスト有) */
    NKK_REP("nkk_rep"),
    /** NEC連携、XMLとPDFを別々に送付(リスト無) */
    NEC_REP("nec_rep"),

    /** 予備１ */
    YOBI1("yobi1"),
    /** 予備２ */
    YOBI2("yobi2"),
    /** 予備３ */
    YOBI3("yobi3"),
    /** 予備４ */
    YOBI4("yobi4"),
    /** 予備５ */
    YOBI5("yobi5"),
    /** 予備６ */
    YOBI6("yobi6"),
    /** 予備７ */
    YOBI7("yobi7"),
    /** 予備８ */
    YOBI8("yobi8"),
    /** 予備９ */
    YOBI9("yobi9"),
    // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    // add 2022-01-26 #7022:実績確定で不要なレポート連携動作が行われる 孫 start
    /** 電文を送付 */
    NONE("none");
    // add 2022-01-26 #7022:実績確定で不要なレポート連携動作が行われる 孫 end

    // フィールド変数
    final String type;

    /**
     * レポートタイプを取得
     * @param type レポートタイプ
     * @return ReportType
     */
    public static ReportType getReportType(String type) {
      for (ReportType rt: values()) {
        if (rt.type.equals(type)) {
          return rt;
        }
      }
// mod 2022-01-26 #7022:実績確定で不要なレポート連携動作が行われる 孫 start
//      return null;
      return NONE;
// mod 2022-01-26 #7022:実績確定で不要なレポート連携動作が行われる 孫 end
    }
  }

  /**
   * 施設別共通設定クラス.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class CommonSetting {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    /**
     * オペ別毎の設定のリスト.
     */
    @JsonProperty("coop_ope_cd")
    private CoopOpeCd coopOpeCd;

    /**
     * ステータス(on:有効、off:無効).
     */
    @JsonProperty("status")
    private String status;
    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

    /**
     * 電文種別設定のリスト.
     */
    @JsonProperty("coop_ord_cd")
    private List<CoopOrdCd> coopOrdCds;

    // add 2020-11-04 FNSI-改修 外部連携706 徐 start
    /**
     * journal_keep_daysを不要なジャナル保持日
     */
    @JsonProperty("journal_keep_days")
    private Integer journalKeepDays;
    // add 2020-11-04 FNSI-改修 外部連携706 徐 end

    // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 start
    /**
     * 透析患者ではない患者チェックの電文種別設定のリスト.
     */
    @JsonProperty("ViewSyncTimeOutSecond")
    private Integer viewSyncTimeOutSecond;
    // add 2021-07-06 #5248:処理キャンセルのしくみ 孫 end

    // add 2021-08-02 定時の外部viewのタイムアウト処理の対応 孫 start
    /**
     * 定時のVIEW連携同期のSQLのタイムアウト時間(秒).
     */
    @JsonProperty("hospPatIdCheckCoop")
    private List<String> hospPatIdCheckCoop;
    // add 2021-08-02 定時の外部viewのタイムアウト処理の対応 孫 end

    /**
     * 保険モード（ベンダー別）
     */
    @JsonProperty("ins_mode")
    private String insMode;

    /**
     * sys_data_setを検索時の最大上限
     */
    @JsonProperty("dataset_limit")
    private Integer datasetLimit;

    /**
     * レポートタイプ(JSON形式)
     */
    @JsonProperty("report_type")
    private List<Map<String, String>> reportType;

    // add #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 start
    /**
     * 比較方法を設定する  ("0":そのまま、"1":左ゼロを除去する、"2":右切り取り桁数)
     */
    @JsonProperty("hosp_pat_id_company_method_code")
    private String hospPatIdCompanyMethodCode;
    /**
     * 比較方法は、”2”が場合時に、右切り取り数を設定する
     */
    @JsonProperty("cut_off_digits")
    private Integer cutOffDigits;
    // add #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 end
    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public CommonSetting(String value) {
      try {
        CommonSetting obj = objectMapper.readValue(value, CommonSetting.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        throw new NtssException("施設連携設定マスタの設定内容が不正です");
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

  /** 管理番号 */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long ctlNo;
  /** 施設コード */
  private String facilityCd;
  /** 説明 */
  private String description;
  /** 表示フラグ */
  private String isDisp;
  /** 削除フラグ */
  private String isDel;
  /** IFエッジ設定 */
  private String ifEdgeSetting;
  /** 各機能共通設定 */
  private CommonSetting commonSetting;
  /** 操作者ID */
  private Long userId;

}
