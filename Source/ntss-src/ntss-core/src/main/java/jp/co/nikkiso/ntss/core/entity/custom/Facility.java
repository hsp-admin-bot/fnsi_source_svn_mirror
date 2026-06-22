package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 施設一覧取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class Facility {
  
  /**
   * 部署符号.
   */
  public String departmentCd;
  
  /**
   * 都道府県名.
   */
  public String prefectureName;
  
  /**
   * 施設コード.
   */
  public String facilityCd;
  
  /**
   * 施設名.
   */
  public String facilityName;
  
  /**
   * 緊急発報件数の合計.
   */
  @Column(name = "total_m_notice_cnt")
  public Integer mNoticeCnt;
  
  /**
   * 予防保守件数の合計.
   */
  @Column(name = "total_preventive_cnt")
  public Integer preventiveCnt;
  
  /**
   * 通信不良数の合計.
   */
  @Column(name = "total_com_problem_cnt")
  public Integer comProblemCnt;

}
