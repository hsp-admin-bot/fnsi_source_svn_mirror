package jp.co.nikkiso.ntss.m_notice.service;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 警報通知マスタのServiceインタフェース.
 */
public interface MstAlarmNotificationService {

  /**
   * 作成したEmailAddressとEmailNameの返却用クラス.
   */
  @Getter
  @AllArgsConstructor
  public class EmailAddressAndName {
    /**
     * 送信先アドレス
     */
    private String EmailAddress;
    /**
     * 送信先名
     */
    private String EmailName;
  }

  /**
   * 対象施設のメール送信情報を作成する.
   *
   * @param mntMotionRecord 装置動作記録
   * @return EmailAddressAndName
   */
  EmailAddressAndName getEmailAddressAndName(MntMotionRecord mntMotionRecord);

}
