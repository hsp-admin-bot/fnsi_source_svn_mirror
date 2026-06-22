package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstMedicateTimingEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 投与タイミングクラス
 */
@Entity(listener = MstMedicateTimingEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_medicate_timing")
@Getter
@Setter
public class MstMedicateTiming extends BaseBlankEntity {
  /**
   * 投与タイミングコード
   */
  @Id
  private Integer medicateTimingCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意な投与タイミングコード
   */
  private String fnMedicateTimingCd;
  /**
   * 投与タイミング名称
   */
  private String medicateTimingName;
  /**
   * 透析工程コード
   */
  private String dialysisProgressCd;
  /**
   * 治療開始後通知時間
   */
  private Short alertTime;
  /**
   * 通知フラグ
   */
  private String isAlert;
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
