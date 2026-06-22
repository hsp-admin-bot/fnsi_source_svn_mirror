package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置動作記録詳細_装置記録取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE )
@Getter
@Setter
public class MachineRecordDetail {
  
  /**
   * 装置記録コード.
   */
  private String machineRecordCd;
  
  /**
   * 詳細情報.
   */
  @Column(name = "machine_record_aux_data")
  private String detailInfo;
  
}
