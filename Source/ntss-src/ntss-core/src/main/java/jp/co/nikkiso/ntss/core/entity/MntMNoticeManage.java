package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MntMNoticeManageEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 緊急発報管理クラス.
 */
@Entity(listener = MntMNoticeManageEntityListener.class, naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_m_notice_manage")
@Getter
@Setter
public class MntMNoticeManage extends BaseBlankEntity {

  /**
   * 緊急発報管理番号.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long mNoticeManageNo;

  /**
   * イベント発生日時.
   */
  private Timestamp eventRegDate;

  /**
   * 緊急発報ステータス.
   */
  private Integer mNoticeStatus;

  /**
   * 型式コード.
   */
  private String machineTypeCd;

  /**
   * 通信フォーマット.
   */
  private String comFormatCd;

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
   * 施設コード.
   */
  private String facilityCd;

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
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

  /**
   * デバイスエッジ番号.
   */
  private Integer deviceEdgeNo;

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
  public List<String> getEmailAdresses() {
    if (emailAddress == null) {
      return Collections.emptyList();
    }
    return Arrays.asList(emailAddress.split(","));
  }

}
