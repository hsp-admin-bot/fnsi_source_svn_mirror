package jp.co.nikkiso.ntss.m_notice.packet;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.MNoticeError;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.NullEmptyMessage;
import jp.co.nikkiso.ntss.m_notice.constant.TelegramConstant.TelegramElement;

/**
 * 死活監視アプリの構造体クラス.
 */
public class AliveMoniTelegram extends MNoticeTelegram {
  
  /**
   * 死活監視アプリの電文データを分解.
   * 
   * @param buffer 死活監視電文
   */
  public AliveMoniTelegram(byte[] buffer) {
    this.FD_X(TelegramElement.FACILITY_CODE, 1, 6);
    this.FD_X(TelegramElement.DEVICE_EDGE_NUMBER, 7, 2);
    this.FD_X(TelegramElement.OCCURRENCE_DATETIME, 9, 14);
    this.FD_X(TelegramElement.RECORDING_CODE, 23, 4);
    this.setRec(buffer);
    
    // バリデーションチェックを行う
    validNullEmptyAliveMoni(this);
  }
  
  /**
   * 死活監視アプリ電文項目のバリデーションチェック.
   * 
   * @param telegram 電文構造体
   * @throws InvalidAlertFormatException nullまたは空文字の場合、電文エラー
   */
  private void validNullEmptyAliveMoni(MNoticeTelegram telegram) throws InvalidAlertFormatException {
    final List<String> messages = new ArrayList<>();
    
    // null・空文字チェック
    // 施設コード
    if (isEmpty(telegram.getFV(TelegramElement.FACILITY_CODE).toString())) {
      messages.add(NullEmptyMessage.FACILITY_CODE);
    }
    // デバイスエッジ番号
    if (isEmpty(telegram.getFV(TelegramElement.DEVICE_EDGE_NUMBER).toString())) {
      messages.add(NullEmptyMessage.DEVICE_EDGE_NUMBER);
    }
    // 発生日時
    if (isEmpty(telegram.getFV(TelegramElement.OCCURRENCE_DATETIME).toString())) {
      messages.add(NullEmptyMessage.OCCURRENCE_DATETIME);
    }
    // 装置記録コード
    if (isEmpty(telegram.getFV(TelegramElement.RECORDING_CODE).toString())) {
      messages.add(NullEmptyMessage.RECORDING_CODE);
    }
    
    if (!messages.isEmpty()) {
      throw new InvalidAlertFormatException(String.format("%s", String.join(", ", messages)));
    }
  }
  
  /**
   * 発生日時をTimeStamp型に変換.
   * 
   * @param occurrenceDateTime 発生日時
   * @return formattedDatetime フォーマット後の発生日時
   */
  public Timestamp getOccurrenceDateTime(String occurrenceDateTime) {
    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
    try {
      return new Timestamp(simpleDateFormat.parse(occurrenceDateTime).getTime());
    } catch (ParseException e) {
      throw new InvalidAlertFormatException(MNoticeError.GET_EVENT_REG_DATE, e);
    }
  }

}
