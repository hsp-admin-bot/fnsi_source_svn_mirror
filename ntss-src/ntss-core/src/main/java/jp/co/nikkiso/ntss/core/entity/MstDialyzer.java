package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstDialyzerEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * ダイアライザクラス
 */
@Entity(listener = MstDialyzerEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
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
   * UFR警報点上限
   */
  private Double ufrWarningMax;
  /**
   * UFR警報点下限
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
  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 start
  /**
   * 連携コード4
   */
  private String inHospitalCd_4;
  // add 2021-01-19 No.739:新規マスタを含むオーダ受信時に該当するマスタを新規登録する機能の実装 商 end
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
}
