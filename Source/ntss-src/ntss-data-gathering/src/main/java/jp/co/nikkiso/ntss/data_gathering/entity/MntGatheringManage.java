package jp.co.nikkiso.ntss.data_gathering.entity;

import java.sql.Timestamp;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import lombok.Getter;
import lombok.Setter;


/**
 * データ収集管理Entity
 *
 */
@Entity
@Getter
@Setter
@Table(name = "mnt_gathering_manage")
public class MntGatheringManage {
  
  @Id
  @Column(name = "gathering_manage_no")
  private long gatheringManageNo;

  @Column(name = "gathering_status")
  private int gatheringStatus;

  @Column(name = "facility_cd")
  private String facilityCd;

  @Column(name = "gathering_info")
  private String gatheringInfo;

  @Column(name = "ope_info")
  private int opeInfo;

  @Column(name = "parent_manage_no")
  private Long parentManageNo;

  @Column(name = "user_id")
  private Long userId;

  @Column(name = "reg_date")
  private Timestamp regDate;

  @Column(name = "up_date")
  private Timestamp upDate;
  
  /**
   * ログ用
   */
  @Override
  public String toString() {
    String msg = "";
    try {
      msg += "gathering_manage_no:[" + this.gatheringManageNo + "]、";
      msg += "gathering_status:[" + this.gatheringStatus + "]、";
      msg += "facility_cd:[" + this.facilityCd + "]、";
      msg += "gathering_info:[" + this.gatheringInfo + "]、";
      msg += "ope_info:[" + this.opeInfo + "]、";
      msg += "parent_manage_no:[" + this.parentManageNo + "]、";
      msg += "user_id:[" + this.userId + "]、";
      msg += "reg_date:[" + this.regDate + "]、";
      msg += "up_date:[" + this.upDate + "]";
    } catch (Exception e) {
    }

    return msg;
  }
}
