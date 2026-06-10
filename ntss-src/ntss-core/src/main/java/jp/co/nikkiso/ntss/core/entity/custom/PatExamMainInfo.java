package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.seasar.doma.Id;


/**
 * pat_exam_main(患者検査結果)の患者個別検査結果用個別エンティティクラス
 */
@Getter
@Setter
@NoArgsConstructor
public class PatExamMainInfo {
  /** ObjectMapper */

  /**
   * システムで管理する一意な検査結果ID.
   */
  @Id
  //[DOMA4036] When you use @GeneratedValue, The filed annotated with @Id must be only one in the class hierarchy.
  //@GeneratedValue(strategy = GenerationType.IDENTITY)
  private long examMainCd;

  /**
   * システムで管理する一意な検査結果ID.
   */
  @Id
  private long patId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 登録時検査区分.
   */
  @Id
  private String regOrderClass;

  /**
   * 登録時検査区分名称
   */
  private String regOrderClassName;

  /**
   * 状況区分.
   */
  private String examStatus;

  /**
   * データ登録区分.
   */
  private String dataGenClass;

  /**
   * 結果時検査日時.
   */
  private String resultExamDate;

  /**
   * 結果時検査時刻(YYYYMMDDHH24MISS)
   */
  private String resultExamDateName;

  /**
   * 結果時コメント.
   */
  private String resultComment;

  /**
   * 検査結果情報.
   */
  private String examResultInfo;

}
