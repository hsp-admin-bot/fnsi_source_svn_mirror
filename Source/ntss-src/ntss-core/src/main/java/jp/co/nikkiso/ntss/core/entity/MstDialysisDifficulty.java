package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstDialysisDifficultyEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 患者情報クラス
 */
@Entity(listener = MstDialysisDifficultyEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_dialysis_difficulty")
@Getter
@Setter
public class MstDialysisDifficulty extends BaseBlankEntity {
  @Id
  /**
   * 透析困難症コード
   */
  private Integer dialysisDifficultyCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意な透析困難コード
   */
  private String fnDialysisDifficultyCd;

  /**
   * 透析困難症名
   */
  private String dialysisDifficultyName;

  /**
   * 連携コード1
   */
  private String inHospitalCd_1;

  /**
   * 連携コード2
   */
  private String inHospitalCd_2;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;
}
