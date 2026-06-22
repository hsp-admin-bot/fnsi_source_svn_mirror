package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import lombok.Getter;
import lombok.Setter;

/**
 * pat_exam_main(患者検査結果)のP-Ca9分割グラフ画面用エンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_main")
@Getter
@Setter
public class PatExamMainForGraph {


  /**
   * システムで管理する一意な検査結果ID.
   */
  @Id
  private Long examMainCd;

  /**
   * システムで管理する一意な患者ID.
   */
  private Long patId;

  /**
   * 施設コード.
   */
  private String facilityCd;
  /**
   * 日付
   */
  private String date;
  /**
   * X軸の検査項目結果
   */
  private String examItemResultX;
  /**
   * Y軸の検査項目結果
   */
  private String examItemResultY;
}
