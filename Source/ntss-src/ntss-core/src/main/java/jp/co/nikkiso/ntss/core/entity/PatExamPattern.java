package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.sql.Date;

/**
 * pat_exam_pattern(患者検査パターン)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_pattern")
@Getter
@Setter
public class PatExamPattern extends BaseEntity {

  /**
   * 患者検査パターンID.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long examPatternCd;

  /**
   * 患者ID.
   */
  private Long patId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意な患者ID.
   */
  private String fnPatId;

  /**
   * 登録時検査日時.
   */
  private Timestamp regExamDate;

  /**
   * 登録時検査区分.
   */
  private String regOrderClass;

  /**
   * 検査パターン.
   */
  private Integer examPattern;

  /**
   * 指定曜日.
   */
  private Integer examWeek;

  /**
   * 指定期間開始日.
   */
  private Date examFrom;

  /**
   * 指定期間終了日.
   */
  private Date examTo;

  /**
   * 検査依頼コード.
   */
  private Long orderExamSetCd;

  /**
   * 検査依頼情報.
   */
  private String examOrderInfo;

  /**
   * ラベル情報.
   */
  private String orderLabelInfo;

  /**
   * 削除フラグ.
   * 0 : 通常、1 : 削除
   */
  private String isDel;

  /**
   * 登録スタッフ.
   */
  private Long regStaff;

  /**
   * 最終更新スタッフ.
   */
  private Long upStaff;

  /**
   * 指示者.
   */
  private Long indUserId;
}
