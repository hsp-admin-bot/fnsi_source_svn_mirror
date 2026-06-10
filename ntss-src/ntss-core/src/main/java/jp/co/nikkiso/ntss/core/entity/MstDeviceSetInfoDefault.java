package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;


@Entity(listener = CommonEntityListener.class, naming = NamingType.NONE)
@Table(name = "mst_device_set_info_default")
@Getter
@Setter
public class MstDeviceSetInfoDefault extends BaseBlankEntity {
  @Id
  private String facility_cd;
  private String device_set_info;
  private String reg_date;
  private String up_date;
  /** 風袋補正情報 */
  private String tare_info;
  /** 除水補正情報 */
  private String off_water_info;
  /** ホスト報知情報 */
  private String host_notification_info;

}
