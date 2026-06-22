package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * pat_exam_main(患者検査結果)のカスタムエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatExamMainWeightPrint {

  /**
   * システムで管理する一意な検査結果ID.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long examMainCd;

  /**
   * システムで管理する一意な検査結果ID.
   */
  private Long patId;

  /**
   * 結果時検査日時.
   */
  private Timestamp resultExamDate;

  /**
   * 検査項目コード
   */
  private String itemCd;

  /**
   * 検査結果
   */
  private String result;

  /**
   * 検査単位
   */
  private String unit;

  /**
   * 検査使用区分
   */
  private String regOrderClass;


}
