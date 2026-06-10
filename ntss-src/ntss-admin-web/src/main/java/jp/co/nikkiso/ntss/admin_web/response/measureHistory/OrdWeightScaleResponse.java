package jp.co.nikkiso.ntss.admin_web.response.measureHistory;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Data;

/**
 * 体重計測定履歴画面に必要な情報を指示データから取得するためのエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class OrdWeightScaleResponse {

  /**
   * 測定管理番号
   */
  private Long weightScaleNo;
  /**
   * オーダー番号
   */
  private Long ordNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 体重計名称
   */
  private String weightName;
  /**
   * 体重測定状況
   */
  private Short weightScaleStatus;
  /**
   * メッセージ
   */
  private String message;
  /**
   * 測定日時
   */
  private Timestamp measureDate;
  /**
   * ベッドコード
   */
  private Long bedCd;
  /**
   * ベッド名称
   */
  private String bedName;
  /**
   * クールコード
   */
  private Long kurCd;
  /**
   * クール名称
   */
  private String kurName;
  /**
   * 患者ID
   */
  private Long patId;
  // FNSI-add 患者IDの修正 徐 start
  /**
   * 患者ID
   */
  private String hospPatId;
  // FNSI-add 患者IDの修正 徐 end
  /**
   * 患者姓
   */
  private String patLastName;
  /**
   * 患者名
   */
  private String patFirstName;
  /**
   * 測定区分
   */
  private Short scaleClass;
  /**
   * 測定モード
   */
  private Short scaleMode;
  /**
   * 測定値
   */
  private BigDecimal scaleValue;
  /**
   * 風袋
   */
  private String rstTareInfo;
  /**
   * 除水
   */
  private String rstOffWaterInfo;
  /**
   * 除水制限値
   */
  private BigDecimal offWaterLimit;
  /**
   * 体重値
   */
  private BigDecimal weightValue;
  /**
   * 目標体重
   */
  private BigDecimal targetWeightValue;
  /**
  * 車いすコード
  */
  private Long wheelChairCd;
  /**
   * 車いす名称
   */
  private String wheelChairName;
  /**
   * 車いす重量
   */
  private BigDecimal wheelChairWeight;
  /**
   * 担当スタッフID
   */
  private  Long userId;
}
