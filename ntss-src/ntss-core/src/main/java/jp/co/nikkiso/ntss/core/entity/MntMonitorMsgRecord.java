package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MntMonitorMsgRecord {

  private String machineRecordMessage;

  private String dispFlg;

  private String userId;

  private String eventRegDate;

  private String upDate;

  private String reportDispFlg;

  private Integer motionRecordNo;

}
