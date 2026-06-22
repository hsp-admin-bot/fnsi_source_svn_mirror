package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainTreatDate {
  /**
   * オーダ番号
   */
  private Long ordNo;

  /**
   * 治療状況
   */
  private String rstDialysisState;

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * クール開始時刻
   */
  private String kurStartTime;

  /**
   * 編集不可
   */
  private boolean readOnly;

  /**
   * 編集データ（指示：クールコード）
   */
  private Long indKurCd;

  /**
   * 治療方法コード
   */
  private String indTreatmentCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
  /**
   * 治療曜日
   */
  private String treatWeek;
  // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
  // add FNSI-redmine5676 fang start
  private Timestamp curEditionDate;
  // add FNSI-redmine5676 fang end
  // add FNSI-7216 治療開始時刻を変更してもsys_coop_journalにイベントが作成されない 劉全航 start
  private Long indBedCd;

  private String indTreatStartTime;
  // add FNSI-7216 治療開始時刻を変更してもsys_coop_journalにイベントが作成されない 劉全航 end

  //  add #10710 【身体情報関連】⑦データリスト 荘 2024-07-15 start
  /**
   * 目標体重有無フラグ
   * */
  @Transient
  private boolean targetWeightFlag = false;
  //  add #10710 【身体情報関連】⑦データリスト 荘 2024-07-15 end

  public OrdMainTreatDate() {}

  public OrdMainTreatDate(Long ordNo, String treatDate) {
    this.ordNo = ordNo;
    this.treatDate = treatDate;
  }
}
