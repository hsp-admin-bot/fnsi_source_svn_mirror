package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * 施舍绑定
 */
@Entity(listener = BaseEntityListener.class , naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_user_switch")
@Getter
@Setter
@ToString
public class MstUserSwitch extends BaseEntity {

  private long switchId;
  private String facilityCd;
  private long userId;
  private String groupId;
  private String optStatus;
  private String isDel;
  private Long regStaff;
  private Long upStaff;



}
