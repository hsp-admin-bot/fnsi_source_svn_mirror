package jp.co.nikkiso.ntss.core.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.seasar.doma.*;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;

import lombok.Getter;
import lombok.Setter;

/**
 * 体重測定履歴クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_weight_scale")
@Getter
@Setter
public class OrdWeightScale extends BaseEntity {
  /**
   * 条件送信管理番号
   */
  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "ord_weight_scale_weight_scale_no_seq")
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
   * 体重計管理コード
   */
  private Long weightCd;
  /**
   * 体重計名称
   */
  private String weightName;
  /**
   * 装置番号
   */
  private Long machineNo;
  /**
   * 装置名
   */
  private String machineName;
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
   * クール
   */
  private Long kurCd;
  /**
   * クール名称
   */
  private String kurName;
  /**
   * ベッドコード
   */
  private Long bedCd;
  /**
   * ベッド名称
   */
  private String bedName;
  /**
   * 患者ID
   */
  private Long patId;
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
   * 車いす以外の風袋
   */
  private String rstTareInfo;
  /**
   * 除水補正値
   */
  private String rstOffWaterInfo;
  /**
   * 体重値
   */
  private BigDecimal weightValue;
  /**
   * 目標体重
   */
  private BigDecimal targetWeightValue;
  /**
   * 除水制限値
   */
  private BigDecimal offWaterLimit;
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
  private Long userId;
  /**
   * 治療コード
   */
  private Integer treatmentCd;
  /**
   * 治療名
   */
  private String treatmentName;
  /**
   * 装置モード
   */
  private Integer deviceMode;
  /**
   * レシート内容
   */
  private String printContent;
  /**
   * 印刷結果
   */
  private Integer printStatus;
  /**
   * 印刷エラーメッセージ
   */
  private String printErrorMessage;

}
