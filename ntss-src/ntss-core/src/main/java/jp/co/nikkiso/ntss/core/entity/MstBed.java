package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstBedEntityListener;
import lombok.Getter;
import lombok.Setter;


/**
 * mst_bed(ベッドマスタ)のエンティティクラス
 */
@Entity(listener = MstBedEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_bed")
@Getter
@Setter
public class MstBed extends BaseBlankEntity {
  @Id
  /**
   * ベッドコード
   */
  private Long bedCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意なベッド番号
   */
  private Double fnBedNo;

  // del #10280 ベッドマスタに不要なカラムが存在する dengshen start
  // /**
  //  * ベッド番号
  //  */
  // private Integer bedNo;
  // del #10280 ベッドマスタに不要なカラムが存在する dengshen end

  /**
   * ベッド名
   */
  private String bedName;

  /**
   * シャント位置
   */
  // add FNSI-分類不一致判断の追加 徐 start
  // private Double shuntPosition;
  private Short shuntPosition;
  // add FNSI-分類不一致判断の追加 徐 end
  /**
   * 感染症フラグ
   */
  private String isInfection;

  /**
   * 緊急区分
   */
  private Double emergencyClass;

  /**
   * 装置番号
   */
  private Long machineNo;

  /**
   * 出力先プリンタ名
   */
  private String outputPrinter;

  /**
   * 前体重測定時の自動印刷有無
   */
  private String isAutoprintBefore;

  /**
   * 後体重測定時の自動印刷有無
   */
  private String isAutoprintAfter;

  /**
   * 実績確定時の自動印刷有無
   */
  private String isAutoprintCommit;
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;
  /**
   * 連携コード2
   */
  private String inHospitalCd_2;
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
   * 在宅フラグ
   */
  private String isHomeDialysis;
}
