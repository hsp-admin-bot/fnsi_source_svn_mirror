package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import lombok.Getter;
import lombok.Setter;
/**
 * pat_exam_main(患者検査結果)の患者個別検査結果用個別エンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_main")
@Getter
@Setter
public class PatExamMainForPatIdLastDate {

  /**
   * システムで管理する一意な検査結果ID.
   */
  @Id
  private long patId;

  /**
   * 最終検査日
   */
  private String lastDate;
  /**
   * 開示先患者
   */
  private Long patIdDst;
}
