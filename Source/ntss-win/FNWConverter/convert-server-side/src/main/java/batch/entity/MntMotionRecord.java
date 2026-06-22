package batch.entity;

import java.sql.Timestamp;

import org.seasar.doma.*;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置動作記録のEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_motion_record")
@Getter
@Setter
public class MntMotionRecord extends BaseEntity{
  /**
   * 緊急発報管理番号.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "mnt_motion_record_motion_record_no_seq")
  private Long motionRecordNo;


  /**
   * イベント発生日時.
   */
  private Timestamp eventRegDate;

  /**
   * 緊急発報ステータス.
   */
  private Integer mNoticeStatus;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * デバイスエッジ番号.
   */
  private Integer deviceEdgeNo;

  /**
   * 型式コード.
   */
  private String machineTypeCd;

  /**
   * 製造番号.
   */

  private String machineSerial;

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

  /**
   * 通信フォーマット.
   */
  private String comFormatCd;

  /**
   * データ種別.
   */
  private Integer dataType;

  /**
   * 自己診断種別.
   */
  private Integer testType;

  /**
   * データ収集管理番号.
   */
  private Long gatheringManageNo;

  /**
   * メール送信日時.
   */
  private Timestamp emailSendDate;

  /**
   * メール本文.
   */
  private String emailText;

  /**
   * 装置記録コード.
   */
  private String machineRecordCd;

  /**
   * 装置記録メッセージ.
   */
  private String machineRecordMessage;

  /**
   * 内容.
   */
  private String contents;

  /**
   * 装置記録補助データ.
   */
  private String machineRecordAuxData;

  /**
   * メールアドレス.
   */
  private String emailAddress;

  /**
   * 宛先名称.
   */
  private String emailName;

  /**
   * 備考.
   */
  private String remarks;

  /**
   * 対処.
   */
  private String isCorrection;

  /**
   * 対処者.
   */
  private Long userId;

  /**
   * オーダー番号
   */
  private Long ordNo;

  /**
   * 装置記録区分
   */
  private Short logType;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * 対処日時.
   */
  private Timestamp isCorrectionUpDate;

  /**
   * サービス対応種別.
   *  0 : 未受付
   *  1 : 1次対応済み
   *  2 : サービス対応済み
   *  3 : サービス対象外
   */
  private String serviceSupportType;

  /**
   * サービス対象者ID.
   */
  private Long serviceSupportUserId;

  /**
   * サービス対応日時.
   */
  private Timestamp serviceSupportUpDate;

  /**
   * 表示フラグ.
   */
  private String reportDispFlg;


  @Override
  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append(eventRegDate == null ? "" : eventRegDate).append(",")
            .append(mNoticeStatus == null ? "" : mNoticeStatus).append(",")
            .append(facilityCd == null ? "" : facilityCd).append(",")
            .append(deviceEdgeNo == null ? "" : deviceEdgeNo).append(",")
            .append(machineTypeCd == null ? "" : machineTypeCd).append(",")
            .append(machineSerial == null ? "" : machineSerial).append(",")
            .append(comFormatCd == null ? "" : comFormatCd).append(",")
            .append(dataType == null ? "" : dataType).append(",")
            .append(testType == null ? "" : testType).append(",")
            .append(gatheringManageNo == null ? "" : gatheringManageNo).append(",")
            .append(emailSendDate == null ? "" : emailSendDate).append(",")
            .append(emailText == null ? "" : emailText).append(",")
            .append(machineRecordCd == null ? "" : machineRecordCd).append(",")
            .append(machineRecordMessage == null ? "" : machineRecordMessage).append(",")
            .append(contents == null ? "" : contents).append(",")
            .append(machineRecordAuxData == null ? "" : machineRecordAuxData).append(",")
            .append(emailAddress == null ? "" : emailAddress).append(",")
            .append(emailName == null ? "" : emailName).append(",")
            .append(remarks == null ? "" : remarks).append(",")
            .append(isCorrection == null ? "" : isCorrection).append(",")
            .append(userId == null ? "" : userId).append(",")
            .append(ordNo == null ? "" : ordNo).append(",")
            .append(logType == null ? "" : logType).append(",")
            .append(regDate == null ? "" : regDate).append(",")
            .append(upDate == null ? "" : upDate).append(",")
            .append(isCorrectionUpDate == null ? "" : isCorrectionUpDate).append(",")
            .append(serviceSupportType == null ? "" : serviceSupportType).append(",")
            .append(serviceSupportUserId == null ? "" : serviceSupportUserId).append(",")
            .append(serviceSupportUpDate == null ? "" : serviceSupportUpDate).append(",")
            .append(reportDispFlg == null ? "" : reportDispFlg).append(",");
            return sb.toString();
  }

}
