package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 施設ごとの通知回数取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class NoticeCounts {

  /**
   * 緊急発報件数の合計.
   */
  @Column(name = "total_m_notice_cnt")
  private Integer mNoticeCnt;

  /**
   * 予防保守件数の合計.
   */
  @Column(name = "total_preventive_cnt")
  private Integer preventiveCnt;

  /**
   * 通信不良数の合計.
   */
  @Column(name = "total_com_problem_cnt")
  private Integer comProblemCnt;

  /**
   * サービス対応件数の合計.
   */
  @Column(name = "total_service_support_cnt")
  private Integer serviceSupportCnt;

  /**
   * 通知件数を0件に設定したEntityを返すコンストラクタ.
   */
  public NoticeCounts() {
    this.mNoticeCnt = 0;
    this.preventiveCnt = 0;
    this.comProblemCnt = 0;
    this.serviceSupportCnt = 0;
  }
}
