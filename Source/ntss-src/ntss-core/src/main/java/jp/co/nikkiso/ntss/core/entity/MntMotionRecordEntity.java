package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.entityListener.MntMotionRecordEntityEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.SequenceGenerator;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置動作記録のEntity.
 */
@Entity(listener = MntMotionRecordEntityEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_motion_record")
@Getter
@Setter
public class MntMotionRecordEntity extends BaseEntity{

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
   * 更新日時.
   */
  private Timestamp eventupdate;

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
   * 内容.
   */
  private String contents;

  /**
   * 装置記録メッセージ.
   */
  private String machineRecordMessage;

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
   * 送信用メール本文.
   * データベースへ保存するメール本文は[emailText]を保存します。
   */
  private String sendEmailText;

  /**
   * 備考欄にメッセージを設定.
   *
   * @param text メッセージ
   */
  public void appendRemarks(String text) {
    if (remarks == null) {
      setRemarks(text);
    } else {
      setRemarks(getRemarks() + "\n" + text);
    }
  }

  /**
   * Eメールアドレスのリストを取得します。
   * Eメールアドレスが設定されていな場合は空のリストを返します。
   * @return Eメールアドレスのリスト
   */
  public List<String> getEmailAddresses() {
    if (emailAddress == null) {
      return Collections.emptyList();
    }
    return Arrays.asList(emailAddress.split(","));
  }

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

  //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- start
  /**
   * 表示フラグ.
   */
  private String reportDispFlg;
  //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- end

}
