package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * pat_rad_pattern(患者放射線検査パターン)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_rad_pattern")
@Getter
@Setter
public class PatRadPattern extends BaseBlankEntity {
  /**
   * システムで管理する一意な患者放射線検査セットID
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long radPatternCd;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意な患者ID
   */
  private String fnPatId;

  /**
   * 登録時検査日時
   */
  private Timestamp regRadDate;

  /**
   * 登録時検査区分
   */
  private String regOrderClass;

  /**
   * 検査依頼パターン
   */
  private Integer radPattern;

  /**
   * 指定曜日
   */
  private Integer radWeek;

  /**
   * 指定期間開始日
   */
  private Timestamp radFrom;

  /**
   * 指定期間終了日
   */
  private Timestamp radTo;

  /**
   * 検査依頼コード
   */
  private Long orderRadSetCd;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 登録スタッフ
   */
  private Long regStaff;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * 最終更新スタッフ
   */
  private Long upStaff;

  /**
   * 指示者
   */
  private Long indUserId;
}
