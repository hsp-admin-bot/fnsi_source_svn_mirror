package jp.co.nikkiso.ntss.core.dto.indSchedule;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import java.util.List;


@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class IndScheduleInfo{
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * オーダ番号
   */
  private Long ordNo;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * 治療日
   */
  private String treatDate;

  /**
   * クールコード
   */
  private Long indKurCd;

  /**
   * ベッドコード
   */
  private Long indBedCd;

  /**
   * 指示：治療方法コード
   */
  private Integer indTreatmentCd;

  /**
   * 指示：治療開始時刻
   */
  private String indTreatStartTime;

  /**
   * 指示：治療時間
   */
  @Column(name = "ind_treatment_time")
  private String indTreatmentTime;

  /**
   * 実績：治療状況
   */
  private String rstDialysisState;

  /**
   * 治療曜日
   */
  private Short treatWeek;

  /**
   * Mst項目：クール内標準治療開始時刻
   */
  @Column(name = "kur_standard_start_time")
  private String kurStandardStartTime;

  /**
   * 計算項目：治療開始日時 = 治療日 + 指示：治療開始時刻(or クール内標準治療開始時刻)
   */
  @Transient
  private String treatStartDateTime;

  /**
   * 計算項目：治療終了日時 = 治療日 + 指示：治療開始時刻(or クール内標準治療開始時刻) + 指示：治療時間
   */
  @Transient
  private String treatEndDateTime;

  /**
   * 計算項目：開始クール治療日 = 治療日
   */
  @Transient
  private String firstKurTreatDate;

  /**
   * 計算項目：開始クール治療時間 = 治療日 + クール内標準治療開始時刻
   */
  @Transient
  private String firstKurTreatDateTime;

  /**
   * 計算項目：最終クール治療日 = （治療日 + クール内標準治療開始時刻）のyyyyMMdd
   */
  @Transient
  private String lastKurTreatDate;

  /**
   * 計算項目：最終クール治療時間 = 治療日 + クール内標準治療開始時刻
   */
  @Transient
  private String lastKurTreatDateTime;

  /**
   * Connected項目：患者イベント主キーリスト(PatEventCdList)
   */
  @Transient
  private List<Long> connectedPatEventCdList;

  /**
   * Connected項目：掲示板主キーリスト(BBSCtlNoList)
   */
  @Transient
  private List<Long> connectedBbsCtlNoList;

  /**
   * Connected項目：一般検査主キーリスト(examMainCdList)
   */
  @Transient
  private List<Long> connectedExamMainCdList;

  /**
   * Connected項目：X線検査依頼主キーリスト(radResultCdList)
   */
  @Transient
  private List<Long> connectedRadResultCdList;

  /**
   * 移動元治療日
   */
  @Transient
  private String oldTreatDate;


  /**
   * 引数の順番
   */
  @Transient
  private Integer orgIndex;
}
