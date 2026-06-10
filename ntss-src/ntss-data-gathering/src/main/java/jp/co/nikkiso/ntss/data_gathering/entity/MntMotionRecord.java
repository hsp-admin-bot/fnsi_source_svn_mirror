package jp.co.nikkiso.ntss.data_gathering.entity;

import java.sql.Timestamp;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import lombok.Getter;
import lombok.Setter;


@Entity
@Getter
@Setter
@Table(name = "mnt_motion_record")
public class MntMotionRecord {

  @Id
  @Column(name = "motion_record_no")
  private Long motionRecordNo;

  @Column(name = "event_reg_date")
  private Timestamp eventRegDate;

  @Column(name = "m_notice_status")
  private Integer mNoticeStatus;

  @Column(name = "facility_cd")
  private String facilityCd;

  @Column(name = "device_edge_no")
  private Integer deviceEdgeNo;

  @Column(name = "machine_type_cd")
  private String machineTypeCd;

  @Column(name = "machine_serial")
  private String machineSerial;
  //スペースを削除する 6901 関 start
  public String getMachineSerial() {
    if (machineSerial != null) {
      return machineSerial.trim();
    }
    return machineSerial;
  }

  public void setMachineSerial(String machineSerial) {
    if (machineSerial != null) {
      this.machineSerial = machineSerial.trim();
    }
  }
  //スペースを削除する 6901 end
  @Column(name = "com_format_cd")
  private String comFormatCd;

  @Column(name = "data_type")
  private Integer dataType;

  @Column(name = "test_type")
  private Integer testType;

  @Column(name = "gathering_manage_no")
  private Long gatheringManageNo;

  @Column(name = "email_send_date")
  private Timestamp emailSendDate;

  @Column(name = "email_text")
  private String emailText;

  @Column(name = "machine_record_cd")
  private String machineRecordCd;

  @Column(name = "machine_record_message")
  private String machineRecordMessage;

  @Column(name = "contents")
  private String contents;

  @Column(name = "machine_record_aux_data")
  private String machineRecordAuxData;

  @Column(name = "email_address")
  private String emailAddress;

  @Column(name = "email_name")
  private String emailName;

  @Column(name = "remarks")
  private String remarks;

  @Column(name = "is_correction")
  private String isCorrection;

  @Column(name = "user_id")
  private Long userId;

  @Column(name = "reg_date")
  private Timestamp regDate;

  @Column(name = "up_date")
  private Timestamp upDate;
}
