package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.SequenceGenerator;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_exception_period")
@Getter
@Setter
public class ExceptionPeriod extends BaseEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "ord_exception_period_exception_period_no_seq")
  private Long exceptionPeriodNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 患者ID
   */
  private Long patId;
  /**
   * 除外期間開始日
   */
  private String exceptionPeriodFrom;
  /**
   * 除外期間終了日
   */
  private String exceptionPeriodTo;
  /**
   * 登録者ID
   */
  private Long regStaffId;
  /**
   * 更新者ID
   */
  private Long updStaffId;
}
