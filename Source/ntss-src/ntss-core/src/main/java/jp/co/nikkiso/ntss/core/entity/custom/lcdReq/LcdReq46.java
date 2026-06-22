package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

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
 * 仮想端末情報（検査グラフ）クラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_main")
@Getter
@Setter
public class LcdReq46 {

  /**
   * システムで管理する一意な検査結果ID.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long examMainCd;

  /**
   * 結果時検査日時
   */
  private String resultExamDate;

  /**
   * 登録時検査区分
   */
  private String regOrderClass;

  /**
   * 検査結果情報
   */
  private String examResultInfo;

}
