package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 自己診断結果記録取得用のEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class TestResultDetail {
  
  /**
   * 発生日付.
   */
  private String eventRegDate;
  
  /**
   * 発生時刻.
   */
  private String eventRegTime;
  
  /**
   * 自己診断種別.
   */
  private Integer testType;
  
  /**
   * 自己診断結果データ.
   */
  @Column(name = "contents")
  private String testResultData;

//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
  /**
   * 装置動作記録番号.
   */
  @Column(name = "motion_record_no")
  private String motionRecordNo;
//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
}
