package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import java.sql.Timestamp;

/**
 * ダイアライザクラス
 */
@Entity
@Table(name = "mst_dialyzer")
@Getter
@Setter
public class MstDialyzer extends BaseBlankEntity {

  /**
   * ダイアライザコード
   */
  @Id
  private Integer dialyzerCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意なダイアライザコード
   */
  private String fnDialyzerCd;
  /**
   * メーカ名
   */
  private String maker;
  /**
   * 型番
   */
  private String modelNumber;
  /**
   * ダイアライザ種別
   */
  private String dialyzerType;
  /**
   * 機能分類
   */
  private String functionClass;
  /**
   * 面積
   */
  private Double area;
  /**
   * UFR
   */
  private Double ufr;
  /**
   * KoA
   */
  private Double koa;
  /**
   * 材質
   */
  private String material;
  /**
   * WET/DRY
   */
  private String wetdry;
  /**
   * 滅菌
   */
  private String sterilization;
  /**
   * UFR警告点上限
   */
  private Double ufrWarningMax;
  /**
   * UFR警告点下限
   */
  private Double ufrWarningMin;
  /**
   * UFR低下警報点
   */
  private Double ufrWarningReduction;
  /**
   * 血流量
   */
  private Double bloodamt;
  /**
   * 透析液流量
   */
  private Double alqdFloodVol;
  /**
   * 尿素クリアランス
   */
  private Double ureaClearance;
  /**
   * ガスパージ時間
   */
  private Double gasPurgeTime;
  /**
   * 置換洗浄量（透析液）
   */
  private Double substituentWashAmt;
  /**
   * 膜洗浄（中空糸）
   */
  private String membraneWash;
  /**
   * 入り数
   */
  private Double inNumber;
  /**
   * 使用開始日
   */
  private String useStartDate;
  /**
   * 使用終了日
   */
  private String useEndDate;
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;
  /**
   * 連携コード2
   */
  private String inHospitalCd_2;
  /**
   * 連携コード3
   */
  private String inHospitalCd_3;
  /**
   * 連携コード4
   */
  private String inHospitalCd_4;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
  /**
   * 外部キー専用フィールドのクエリ（その他は不要）
   */
  private String code;

  private String codeupdate;
}
