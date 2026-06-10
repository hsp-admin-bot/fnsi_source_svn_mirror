package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * mst_exam_set(検査セットマスタ)のエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_exam_set")
@Getter
@Setter
public class MstExamSet extends BaseEntity {
  /**
   * システムで管理する一意な検査セットコード
   */
  private Long examSetCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意な検査セットコード
   */
  private String fnExamSetCd;

  /**
   * セット種別
   */
  private String setClass;

  /**
   * 検査セット名
   */
  private String examSetName;

  /**
   * 省略検査セット名
   */
  private String examSetShortName;

  /**
   * セット使用区分
   */
  private String examSetClass;

  // del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
//  /**
//   * 院内院外フラグ
//   */
//  private String isInHospital;
  // del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end

  /**
   * 至急フラグ
   */
  private String canEmergency;

  /**
   * その他検索時刻
   */
  private String otherExamTime;

  /**
   * 検査項目情報
   */
  private String examItemInfo;

  /**
   * 連携コード1
   */
  private String inHospitalCd1;

  /**
   * 属性コード1
   */
  private String sbtCd1;

  /**
   * 連携コード2
   */
  private String inHospitalCd2;

  /**
   * 属性コード2
   */
  private String sbtCd2;

    /**
   * 連携コード3
   */
  private String inHospitalCd3;

  /**
   * 属性コード3
   */
  private String sbtCd3;

  /**
   * ラベル情報
   */
  private String labelInfo;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  // add FNSI-No664 グラフ表示 関 start
  private String graphSet;
  // add FNSI-No664 グラフ表示 関 end

  /**
   * 検査区分
   */
  private String orderClass;
}
