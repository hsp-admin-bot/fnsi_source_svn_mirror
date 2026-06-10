package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 装置記録コード用のEntity.
 */
/* modify #6746 zhangruixue 2023-03-08  --star */
//@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
/* modify #6746 zhangruixue 2023-03-08  --end */
@Getter
@Setter
public class MtsMachineWithMachineRecordCd extends BaseEntity {

  /**
   * 型式コード
   */
  private String machineTypeCd;

  /**
   * 製造番号
   */
  private String machineSerial;

  /**
   * 装置記録コード
   */
  private String machineRecordCd;

  /**
   * 治療日.
   */
  private String treatDate;
}
